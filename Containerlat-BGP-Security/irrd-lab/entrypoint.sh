#!/bin/bash
set -e

echo "=== IRRd Lab Container Starting ==="

# ------------------------------------------------------------------
# 1. Start PostgreSQL
# ------------------------------------------------------------------
echo "Starting PostgreSQL..."

# Initialize the database cluster if it doesn't exist yet
if [ ! -f "$PGDATA/PG_VERSION" ]; then
    mkdir -p "$PGDATA"
    chown postgres:postgres "$PGDATA"
    su - postgres -c "initdb -D $PGDATA"
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

su - postgres -c "pg_ctl -D $PGDATA -l /var/log/irrd/postgresql.log start"

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to accept connections..."
for i in $(seq 1 30); do
    if su - postgres -c "pg_isready -q" 2>/dev/null; then
        break
    fi
    sleep 1
done

# Create the IRRd database and pgcrypto extension
echo "Creating IRRd database..."
su - postgres -c "psql -tc \"SELECT 1 FROM pg_database WHERE datname='irrd'\" | grep -q 1" || \
    su - postgres -c "createdb irrd"
su - postgres -c "psql -d irrd -c 'CREATE EXTENSION IF NOT EXISTS pgcrypto;'"

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
if [ -f /etc/irrd/lab-irr-data.rpsl ]; then
    echo "Loading RPSL objects from /etc/irrd/lab-irr-data.rpsl..."
    irrd_load_database --config /etc/irrd.yaml --source LABRIR /etc/irrd/lab-irr-data.rpsl
    echo "RPSL data loaded."
else
    echo "No RPSL data file found at /etc/irrd/lab-irr-data.rpsl — skipping load."
fi

# ------------------------------------------------------------------
# 5. Start IRRd in the foreground
# ------------------------------------------------------------------
echo "Starting IRRd..."
echo "=== IRRd Lab Container Ready ==="
exec irrd --config /etc/irrd.yaml --foreground
