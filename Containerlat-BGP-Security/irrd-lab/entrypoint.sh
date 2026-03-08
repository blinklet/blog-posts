#!/bin/bash
set -e

echo "=== IRRd Lab Container Starting ==="

PGBIN="/usr/lib/postgresql/17/bin"
if [ ! -x "$PGBIN/initdb" ]; then
    echo "ERROR: expected PostgreSQL binaries at $PGBIN, but initdb was not found."
    exit 127
fi
mkdir -p /var/log/irrd
chown postgres:postgres /var/log/irrd

# ------------------------------------------------------------------
# 1. Start PostgreSQL
# ------------------------------------------------------------------
echo "Starting PostgreSQL..."

# Initialize the database cluster if it doesn't exist yet
if [ ! -f "$PGDATA/PG_VERSION" ]; then
    mkdir -p "$PGDATA"
    chown postgres:postgres "$PGDATA"
    su - postgres -c "$PGBIN/initdb -D $PGDATA"
fi

# Tune PostgreSQL for minimal lab use
cat >> "$PGDATA/postgresql.conf" <<EOF
random_page_cost = 1.0
work_mem = 50MB
shared_buffers = 128MB
max_connections = 30
listen_addresses = 'localhost'
EOF

# Allow local connections without a password
cat > "$PGDATA/pg_hba.conf" <<EOF
local   all   all                 trust
host    all   all   127.0.0.1/32  trust
host    all   all   ::1/128       trust
EOF

su - postgres -c "$PGBIN/pg_ctl -D $PGDATA -l /var/log/irrd/postgresql.log start"

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to accept connections..."
for i in $(seq 1 30); do
    if su - postgres -c "$PGBIN/pg_isready -q" 2>/dev/null; then
        break
    fi
    sleep 1
done

# Create the IRRd database and pgcrypto extension
echo "Creating IRRd database..."
su - postgres -c "$PGBIN/psql -tc \"SELECT 1 FROM pg_database WHERE datname='irrd'\" | grep -q 1" || \
    su - postgres -c "$PGBIN/createdb irrd"
su - postgres -c "$PGBIN/psql -d irrd -c 'CREATE EXTENSION IF NOT EXISTS pgcrypto;'"

# ------------------------------------------------------------------
# 2. Start Redis (no persistence, low memory)
# ------------------------------------------------------------------
echo "Starting Redis..."
redis-server \
    --daemonize yes \
    --save "" \
    --appendonly no \
    --maxmemory 64mb \
    --logfile /var/log/irrd/redis.log

# Wait for Redis to be ready
for i in $(seq 1 15); do
    if redis-cli ping 2>/dev/null | grep -q PONG; then
        break
    fi
    sleep 1
done

# ------------------------------------------------------------------
# 3. Run IRRd database migrations
# ------------------------------------------------------------------
echo "Running IRRd database migrations..."
irrd_database_upgrade --config /etc/irrd.yaml

# ------------------------------------------------------------------
# 4. Load RPSL data if a data file is mounted
# ------------------------------------------------------------------
if [ -f /etc/irrd/lab-irr-base.rpsl ]; then
    echo "Loading RPSL objects from /etc/irrd/lab-irr-base.rpsl..."
    irrd_load_database --config /etc/irrd.yaml --source LABRIR /etc/irrd/lab-irr-base.rpsl
    echo "RPSL data loaded."
else
    echo "No RPSL data file found at /etc/irrd/lab-irr-base.rpsl — skipping load."
fi

# ------------------------------------------------------------------
# 5. Bootstrap fixed Web UI admin user (no SMTP required)
# ------------------------------------------------------------------
echo "Bootstrapping IRRd Web UI admin user: test@irrtest.com"
WEBUI_PASSWORD_HASH="$(python - <<'PY'
from passlib.hash import bcrypt
print(bcrypt.hash("mypassword"))
PY
)"

su - postgres -c "$PGBIN/psql -d irrd -v ON_ERROR_STOP=1 <<'SQL'
INSERT INTO auth_user (email, name, password, active, override)
VALUES ('test@irrtest.com', 'Lab Administrator', '$WEBUI_PASSWORD_HASH', true, true)
ON CONFLICT (email)
DO UPDATE SET
    name = EXCLUDED.name,
    password = EXCLUDED.password,
    active = EXCLUDED.active,
    override = EXCLUDED.override,
    updated = now();
SQL"

echo "Web UI user created/updated: test@irrtest.com (override=true)"

# ------------------------------------------------------------------
# 6. Start IRRd in the foreground
# ------------------------------------------------------------------
echo "Starting IRRd..."
echo "=== IRRd Lab Container Ready ==="
exec irrd --config /etc/irrd.yaml --foreground
