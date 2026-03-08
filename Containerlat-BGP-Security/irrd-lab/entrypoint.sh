#!/bin/bash
set -e

echo "=== IRRd Lab Container Starting ==="

if [ ! -x "/usr/lib/postgresql/17/bin/initdb" ]; then
    echo "ERROR: expected PostgreSQL binaries at /usr/lib/postgresql/17/bin, but initdb was not found or is not executable."
    exit 127
fi
mkdir -p /var/log/irrd
chown postgres:postgres /var/log/irrd

# ------------------------------------------------------------------
# Start PostgreSQL
# ------------------------------------------------------------------
echo "Starting PostgreSQL..."

# Initialize the database cluster if it doesn't exist yet
if [ ! -f "/var/lib/postgresql/data/PG_VERSION" ]; then
    install -d -o postgres -g postgres -m 0700 "/var/lib/postgresql/data"
    su - postgres -c "/usr/lib/postgresql/17/bin/initdb -D /var/lib/postgresql/data"
fi

# Tune PostgreSQL for minimal lab use
cat >> "/var/lib/postgresql/data/postgresql.conf" <<EOF
random_page_cost = 1.0
work_mem = 50MB
max_connections = 30
listen_addresses = 'localhost'
EOF

# Allow local connections without a password
cat > "/var/lib/postgresql/data/pg_hba.conf" <<EOF
local   all   all                 trust
host    all   all   127.0.0.1/32  trust
host    all   all   ::1/128       trust
EOF

su - postgres -c "/usr/lib/postgresql/17/bin/pg_ctl -D /var/lib/postgresql/data -l /var/log/irrd/postgresql.log start"

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to accept connections..."
for i in $(seq 1 30); do
    if su - postgres -c "/usr/lib/postgresql/17/bin/pg_isready -q" 2>/dev/null; then
        break
    fi
    sleep 1
done

# Create the IRRd database and pgcrypto extension
echo "Creating IRRd database..."
su - postgres -c "/usr/lib/postgresql/17/bin/psql -tc \"SELECT 1 FROM pg_database WHERE datname='irrd'\" | grep -q 1" || \
    su - postgres -c "/usr/lib/postgresql/17/bin/createdb irrd"
su - postgres -c "/usr/lib/postgresql/17/bin/psql -d irrd -c 'CREATE EXTENSION IF NOT EXISTS pgcrypto;'"

# ------------------------------------------------------------------
# Start Redis (no persistence, low memory)
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
# Run IRRd database migrations
# ------------------------------------------------------------------
echo "Running IRRd database migrations..."
irrd_database_upgrade --config /etc/irrd.yaml

# Load RPSL data if a data file is mounted
irrd_load_database --config /etc/irrd.yaml --source LABRIR /etc/irrd/lab-irr-base.rpsl
echo "RPSL data loaded."


# ------------------------------------------------------------------
# Bootstrap fixed Web UI admin user (no SMTP required)
# ------------------------------------------------------------------
echo "Creating IRRd Web UI admin user: test@irrtest.com"
WEBUI_PASSWORD_HASH="$(python - <<'PY'
from passlib.hash import bcrypt
print(bcrypt.hash("mypassword"))
PY
)"

su - postgres -c "/usr/lib/postgresql/17/bin/psql -d irrd -v ON_ERROR_STOP=1 <<'SQL'
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
# Start IRRd in the foreground
# ------------------------------------------------------------------
echo "Starting IRRd..."
echo "=== IRRd Lab Container Ready ==="
exec irrd --config /etc/irrd.yaml --foreground
