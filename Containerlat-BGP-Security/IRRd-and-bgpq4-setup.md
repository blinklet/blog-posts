% Emulating an IRR Database for Prefix Filter Testing



Every day, Internet service providers make trust decisions about which routes to accept from their BGP peers. One of the most important tools they use is the Internet Routing Registry, or IRR — a public database where network operators register which IP prefixes they are authorized to announce. When a BGP neighbor sends a route advertisement, the receiving router checks whether that announcement matches what is registered in the IRR. If it does not match, the route is filtered out.

The standard tool for building these filters is [bgpq4](https://github.com/bgp/bgpq4), a command-line utility that queries IRR servers like [RADB](https://www.radb.net/) and generates router filter configurations automatically. Together, IRR data and bgpq4 form the most widely deployed BGP security mechanism on the Internet today. Yet most network engineers have never set up an IRR server themselves, and many have never seen how bgpq4 queries translate into working router filters.

In this post, I will show you how to run your own IRR server using [IRRd (Internet Routing Registry Daemon)](https://irrd.readthedocs.io/en/stable/) — the same software that powers production registries like RADB — entirely inside a [Containerlab](https://containerlab.dev/) lab environment. I will populate the IRR database with routing policy objects for a small three-AS network, use bgpq4 to generate [FRR](https://frrouting.org/) prefix-list filters from that data, and then demonstrate how those filters prevent a BGP peer from announcing prefixes it does not own.

Running your own IRRd instance means you can experiment freely: register any prefix, create any AS number, and test filter behavior without touching production infrastructure. Everything runs locally in containers on a single Linux host.

By the end of this post, you will have a re-usable container that runs the IRRd server and can be used to demonstrate IRR-based filtering workflows: from registering routing policy objects, to generating filters with bgpq4.

## Background: IRR, RPSL, IRRd, and bgpq4

Before building the lab, it helps to understand the four components we will be working with: the Internet Routing Registry system, the language used to describe routing policy, the server software that hosts the registry, and the tool that turns registry data into router configurations.

### What is an Internet Routing Registry?

An Internet Routing Registry (IRR) is a database where network operators publish information about their routing policy. The data is expressed in a format called RPSL — Routing Policy Specification Language, defined in [RFC 2622](https://www.rfc-editor.org/rfc/rfc2622). The most important object types for prefix filtering are:

- **route** objects — map an IP prefix to the AS number authorized to originate it (for example, "198.51.100.0/24 is originated by AS100")
- **aut-num** objects — describe an autonomous system and its peering policies
- **as-set** objects — group multiple AS numbers together under a single name (for example, "AS-ISP-A contains AS100 and AS101"), which lets operators define filters for customers who have their own downstream customers

IRR databases are operated by the five Regional Internet Registries (ARIN, RIPE NCC, APNIC, LACNIC, and AFRINIC) and by independent registries such as [RADB](https://www.radb.net/) and NTT's registry. Network operators query these registries to learn which prefixes each BGP peer is authorized to announce, and then build prefix filters from that data.

### What is IRRd?

[IRRd (Internet Routing Registry Daemon)](https://irrd.readthedocs.io/en/stable/) is open-source software that implements a full-featured IRR server. It is the same software that runs behind production registries like RADB. IRRd version 4 — the current release as of early 2026 — is maintained by [Reliably Coded](https://www.reliably.com/) with support from NTT, ARIN, and the community.

IRRd provides a WHOIS query interface on TCP port 43, which is the protocol that tools like bgpq4 use to retrieve routing policy data. Internally, it stores RPSL objects in a [PostgreSQL](https://www.postgresql.org/) database and uses [Redis](https://redis.io/) for inter-process communication. IRRd can operate in two modes: as an *authoritative* source that accepts local submissions (this is what we will use), or as a *mirror* that replicates data from other IRR databases.

For our lab, we will configure IRRd with a single authoritative source named `LABRIR` and load a small set of RPSL objects that represent our three-AS network. The full production deployment guide recommends 32 GB of RAM and 150 GB of storage, but those figures are for mirroring the entire Internet routing registry. Our lab has fewer than 20 objects and will run comfortably with minimal resources.

### What is bgpq4?

[bgpq4](https://github.com/bgp/bgpq4) is a command-line tool that queries an IRR server and generates router filter configurations. It supports output formats for Cisco IOS, Juniper JunOS, FRR, BIRD, Nokia, Mikrotik, Arista, Huawei, and others. By default, bgpq4 queries NTT's IRR mirror at `rr.ntt.net`, but the `-h` flag lets you point it at any IRR server — including our local IRRd instance.

A typical bgpq4 command looks like this:

```bash
$ bgpq4 -h 10.0.0.4 -S LABRIR -l AS100-IN AS100
```

This tells bgpq4 to connect to the IRR server at `10.0.0.4`, query the `LABRIR` source, find all prefixes that AS100 is authorized to originate, and output an FRR-compatible prefix-list named `AS100-IN`. The result is a set of `ip prefix-list` statements that you can paste directly into an FRR router's configuration.

### How the pieces fit together

The workflow mirrors what real-world network operators do every day:

1. Network operators register their prefixes in an IRR by creating **route** objects (stored and served by IRRd)
2. A neighboring operator runs **bgpq4** to query the IRR and generate prefix-list filters for each BGP peer
3. The operator applies those filters to the **FRR** (or other) router, which then only accepts route announcements that match the registered data

The only difference in our lab is that all three components — the IRR server, the filter generation tool, and the routers — run locally inside containers managed by Containerlab.



### Design Notes

The IRRd server runs PostgreSQL, Redis, and IRRd together in a single "all-in-one" container. Bundling multiple services into one container is not the recommended Docker pattern for production, but it is pragmatic for a lab. It keeps the lab topologies simple, with one node instead of three to create the IRRd server. In production, IRRd, PostgreSQL, and Redis would each run as separate services.

The bgpq4 utility container is a lightweight Debian container with the `bgpq4` package installed. It is intended to reach the IRRd server similar to how a network management station on an operator's network would query public IRR servers. Running bgpq4 inside the topology means everything the lab needs is self-contained.

## Building the IRRd Container Image

IRRd does not publish an official Docker image. The [deployment documentation](https://irrd.readthedocs.io/en/stable/admins/deployment/) describes a native installation with PostgreSQL and Redis as separate services. Since we want everything in a single lab topology, with no Docker Compose and no external services, we will build a custom all-in-one container that bundles PostgreSQL, Redis, and IRRd together.

We will create three files: a Dockerfile, an entrypoint script, and an IRRd configuration file.

### The Dockerfile

The Dockerfile starts from `python:3.14-slim-trixie` (a Debian Trixie base with Python pre-installed), installs PostgreSQL and Redis from Debian packages, then installs IRRd from PyPI using `pip`. Build dependencies like `gcc` and `rustc` (needed to compile some of IRRd's Python dependencies) are removed after installation to keep the image smaller. It also adds a Docker healthcheck and includes a basic RPSL data file in the image, to create a maintainer and password.

Create the file *irrd-lab/Dockerfile.irrd*:

```dockerfile
# All-in-one IRRd lab container

FROM python:3.14-slim-trixie

ENV DEBIAN_FRONTEND=noninteractive \
    IRRD_CONFIG=/etc/irrd.yaml

# Install PostgreSQL, Redis, and build dependencies for IRRd
RUN apt-get update && apt-get install -y --no-install-recommends \
        postgresql \
        redis-server \
        gnupg \
        iproute2 \
        net-tools \
        netcat-openbsd \
        procps \
        curl \
        gcc \
        libpq-dev \
        python3-dev \
        rustc \
        cargo \
        apache2-utils \
    && pip install --no-cache-dir irrd \
    && apt-get purge -y gcc python3-dev rustc cargo \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# Create directories for IRRd
RUN mkdir -p /var/log/irrd /var/run/irrd /etc/irrd /var/lib/irrd/gnupg \
    && chmod 700 /var/lib/irrd/gnupg

# Make PostgreSQL binaries available on PATH (Debian Trixie defaults to PostgreSQL 17)
ENV PATH="/usr/lib/postgresql/17/bin:${PATH}"

# Copy configuration and entrypoint
COPY irrd.yaml /etc/irrd.yaml
RUN mkdir -p /etc/irrd/data
COPY lab-irr-base.rpsl /etc/irrd/data/lab-irr-base.rpsl
RUN ln -sf /etc/irrd/data/lab-irr-base.rpsl /etc/irrd/lab-irr-base.rpsl
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Bind-mount host directory with RPSL files to /etc/irrd/data
# VOLUME ["/etc/irrd/data"]

EXPOSE 43
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=45s --retries=3 \
    CMD sh -ec "pg_isready -q && redis-cli ping | grep -q PONG && nc -z 127.0.0.1 43"

ENTRYPOINT ["/entrypoint.sh"]
```

The image is intentionally self-contained: PostgreSQL data, Redis state, and IRRd logs all live inside the container. Since this is a disposable lab, we do not need persistent volumes.

### The Entrypoint Script

The entrypoint script is the key to making the all-in-one container work. It starts each service in the correct order, waits for dependencies to become ready, and then starts IRRd in the foreground so that Docker can track the process.

Create the file *irrd-lab/entrypoint.sh*:

```bash
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
WEBUI_PASSWORD_HASH="$(htpasswd -bnBC 12 "" "mypassword" | tr -d ':\n')"

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
```

The script follows a strict startup sequence:

1. **PostgreSQL** starts first. The script initializes a fresh database cluster on the first run, tunes a few key parameters (`random_page_cost`, `work_mem`), and creates the `irrd` database with the required `pgcrypto` extension.
2. **Redis** starts next with persistence disabled (the `--save ""` and `--appendonly no` flags) because lab data does not need to survive a container restart.
3. **`irrd_database_upgrade`** runs the schema migration that creates IRRd's internal tables.
4. If a file exists at */etc/irrd/lab-irr-base.rpsl* (either copied into the image or bind-mounted), the script loads those RPSL objects automatically using `irrd_load_database`. This is how we will populate the IRR with our lab's routing policy data.
5. Finally, **IRRd** starts in the foreground with `--foreground`, so Docker sees it as the container's main process.

### The IRRd Configuration File

IRRd reads its configuration from a YAML file. The [full configuration reference](https://irrd.readthedocs.io/en/stable/admins/configuration/) has dozens of options, but our lab needs very few of them.

Create the file *irrd-lab/irrd.yaml*:

```yaml
irrd:
    database_url: 'postgresql://postgres@localhost/irrd'
    redis_url: 'redis://localhost'
    piddir: /var/run/irrd/
    user: postgres
    group: postgres

    server:
        http:
            interface: '0.0.0.0'
            port: 8080
            url: 'http://localhost:8080/'
            workers: 1
        whois:
            interface: '0.0.0.0'
            port: 43
            max_connections: 5

    auth:
        gnupg_keyring: /var/lib/irrd/gnupg/
        override_password: '$1$test$4PzmqjLUwdD2j1Otz/LSw.' # password: mypassword
        set_creation:
            COMMON:
                prefix_required: false
                autnum_authentication: disabled

    email:
        from: 'test@irrtest.com'
        footer: ''
        smtp: 'localhost'

    log:
        level: INFO

    rpki:
        roa_source: null
    
    compatibility:
        inetnum_search_disabled: true

    sources_default:
        - LABRIR

    sources:
        LABRIR:
            authoritative: true
            keep_journal: true
            authoritative_non_strict_mode_dangerous: true
```

The key settings:

- **`database_url`** connects to the local PostgreSQL instance over localhost TCP using the `postgres` role (`postgresql://postgres@localhost/irrd`).
- **`redis_url`** connects to the local Redis instance over TCP on localhost.
- **`user`** and **`group`** run IRRd as the `postgres` user/group in this lab container.
- **`server.http.interface: '0.0.0.0'`** and **`server.whois.interface: '0.0.0.0'`** make both interfaces reachable from outside the container network namespace.
- **`server.whois.port: 43`** is the standard WHOIS port — the same port that bgpq4 queries by default.
- **`server.http.workers: 1`** and **`server.whois.max_connections: 5`** keep memory usage low. Each WHOIS connection uses about 200–250 MB, so limiting to 5 connections keeps the lab under 2 GB.
- **`rpki.roa_source: null`** disables RPKI integration entirely — that is for a future post.
- **`sources.LABRIR`** defines our single authoritative source. The `authoritative: true` flag means this IRRd instance accepts local data submissions. The `authoritative_non_strict_mode_dangerous: true` flag relaxes RPSL validation, which makes it easier to load lab objects that may not have full referential integrity. The `keep_journal: true` flag enables change tracking.
- **`auth.override_password`** sets an override password hash (for the password "lab") that can bypass authentication when loading data. The `set_creation` settings disable the requirement for `as-set` names to have an AS number prefix, which simplifies our lab objects.

### Building the Image

With all three files in the *irrd-lab/* directory, build the Docker image:

```bash
$ cd irrd-lab
$ docker build -t irrd-lab -f Dockerfile.irrd .
```

The build takes several minutes because IRRd has many Python dependencies (including some that require compilation). Once built, the image is cached locally and does not need to be rebuilt unless you change the Dockerfile.

### Checking Container Health

The image defines a Docker `HEALTHCHECK` that verifies three things:

- PostgreSQL is accepting connections (`pg_isready -q`)
- Redis is responding (`redis-cli ping` returns `PONG`)
- IRRd's WHOIS listener is up on TCP port 43 (`nc -z 127.0.0.1 43`)

Check health status with:

```bash
$ docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}'
$ docker inspect --format '{{json .State.Health}}' <container_name>
```

A brief initial `starting` state, or even one failed probe while services initialize, can be normal.

### Troubleshooting

If the IRRd container fails to start, the most common issues are:

- **PostgreSQL pgcrypto extension not created** — The entrypoint runs `CREATE EXTENSION IF NOT EXISTS pgcrypto` as a superuser. If you see errors about missing functions, check the PostgreSQL log: `docker exec clab-...-irrd cat /var/log/irrd/postgresql.log`
- **Redis connection refused** — Verify Redis started successfully: `docker exec clab-...-irrd redis-cli ping` should return `PONG`
- **IRRd configuration errors** — IRRd validates its configuration on startup and will refuse to start if it finds problems. Check the container logs: `docker logs clab-...-irrd`
- **Slow startup** — The all-in-one container needs 15–30 seconds to initialize PostgreSQL, run migrations, load RPSL data, and start IRRd. If you query the WHOIS port before IRRd is ready, the connection will be refused. Wait for the "IRRd Lab Container Ready" message in the logs.
- **`docker inspect` template error** — If you run `docker inspect --format '{{json .State.Health}}' irrd-lab` and `irrd-lab` is an image name (not a container name), Docker returns a template error like `map has no entry for key "State"`. Use the running container name instead.

## Populating the IRR Database

With the container image built, we need routing policy data for it to serve. In production, IRR databases contain millions of objects registered by thousands of network operators. Our lab needs only a handful: enough to represent three autonomous systems and their authorized prefixes.

### The RPSL Objects File

RPSL (Routing Policy Specification Language) uses a simple text format: each object is a block of `attribute: value` lines, with a blank line between objects. We need four types of objects for our lab:

- A **mntner** (maintainer) object that provides authentication — required by IRRd for any authoritative source
- A **person** object for the administrative contact (referenced by the maintainer)
- Three **aut-num** objects describing AS100, AS200, and AS300
- Two **as-set** objects that group ASes together (AS-ISP-A and AS-ISP-B) — these are what bgpq4 expands when generating filters for customers with downstream networks
- Three **route** objects that map each prefix to its authorized origin AS

The critical detail is what we *do not* register: there is no route object for 198.51.100.0/24 with origin AS200. This is the gap that the prefix filter will enforce — when AS200 later tries to announce that prefix, bgpq4's filter will block it because the IRR has no matching registration.

Create the file *irrd-lab/lab-irr-base.rpsl*:

```
mntner:         LAB-MNT
descr:          Lab maintainer for all objects; password is "mypassword"
admin-c:        LAB-ADMIN
upd-to:         test@irrtest.com
auth:           MD5-PW $1$test$4PzmqjLUwdD2j1Otz/LSw.
mnt-by:         LAB-MNT
source:         LABRIR

person:         Lab Administrator
address:        Lab Network
phone:          +1-555-0100
nic-hdl:        LAB-ADMIN
mnt-by:         LAB-MNT
source:         LABRIR
```

A few things to note about these objects:

- All objects reference **`LAB-MNT`** as their maintainer and use the same MD5 password hash. In a real IRR, each organization would have its own maintainer with its own credentials. For a lab, a single shared maintainer keeps things simple.
- The **`auth: MD5-PW`** line contains a salted MD5 hash of the password "mypassword". This matches the override password in our *irrd.yaml* configuration.
- Every object includes **`source: LABRIR`**, which must exactly match the source name defined in the IRRd configuration (case-sensitive).
- The **as-set** objects (AS-ISP-A and AS-ISP-B) each contain a single member AS. In practice, an ISP's as-set might contain dozens of customer ASes. bgpq4 recursively expands as-set membership to find all authorized prefixes — this is how operators build filters for transit customers who have their own downstream networks.

### Loading the Data

The entrypoint script we created in Part 4 automatically loads RPSL data from */etc/irrd/lab-irr-base.rpsl* if the file exists. When we build the Containerlab topology in a later section, we will bind-mount this file into the container. The entrypoint runs:

```bash
irrd_load_database --config /etc/irrd.yaml --source LABRIR /etc/irrd/lab-irr-base.rpsl
```

The `irrd_load_database` command performs a bulk import that replaces all existing objects in the specified source with the contents of the file. This is the same mechanism production IRR operators use to load full database snapshots. For our lab, it loads all 11 objects in a single operation.

If you need to reload the data after the lab is running (for example, after editing the RPSL file), you can run the command manually:

```bash
$ docker exec clab-bgplab-irrd irrd_load_database \
    --config /etc/irrd.yaml --source LABRIR /etc/irrd/lab-irr-base.rpsl
```

### Verifying the Data

Once the IRRd container is running and the data is loaded, you can verify it from the separate bgpq4 utility container. This confirms the IRRd node is reachable at its topology IP, not just from inside the IRRd container itself. The WHOIS protocol is text-based: you send a query string over TCP to port 43 and receive the matching objects in plain text.

Query for all route objects registered to AS100:

```bash
$ docker exec clab-bgplab-bgpq4 sh -lc 'echo "-i origin AS100" | nc 10.0.0.4 43'
```

Expected output:

```
route:          198.51.100.0/24
descr:          ISP-A prefix
origin:         AS100
mnt-by:         LAB-MNT
source:         LABRIR
```

Query for a specific prefix:

```bash
$ docker exec clab-bgplab-bgpq4 sh -lc 'echo "198.51.100.0/24" | nc 10.0.0.4 43'
```

Expand the AS-ISP-A set using IRRd's extended query syntax (the `!i` command):

```bash
$ docker exec clab-bgplab-bgpq4 sh -lc 'echo "!iAS-ISP-A" | nc 10.0.0.4 43'
```

Expected output:

```
A100
```

This confirms that IRRd has loaded the data and is serving it correctly over the WHOIS protocol — exactly as bgpq4 will query it when we generate prefix filters.

## Using bgpq4 to Generate Prefix Filters

With a working IRRd server full of RPSL objects, we can now do what real network operators do every day: use [bgpq4](https://github.com/bgp/bgpq4) to query the registry and automatically generate router prefix-list configurations. This is the step where IRR data becomes actionable — bgpq4 reads the registry, finds which prefixes each AS is authorized to announce, and produces configuration snippets that FRR can apply directly.

### Building the bgpq4 Utility Container

Rather than installing bgpq4 on the host, we will run it inside a lightweight utility container that is part of the Containerlab topology. This keeps the entire lab self-contained — everything runs with `containerlab deploy`.

The Dockerfile is minimal. It installs bgpq4 from Debian's package repository plus query tools (`nc` and `whois`), and uses `sleep infinity` to keep the container running. Create the file *irrd-lab/Dockerfile.bgpq4*:

```dockerfile
# Linux container with bgpq4 and other utilities

FROM debian:trixie-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        bgpq4 \
        curl \
        iproute2 \
        traceroute \
        net-tools \
        netbase \
        netcat-openbsd \
        iputils-ping \
        whois \
    && rm -rf /var/lib/apt/lists/*

CMD ["sleep", "infinity"]
```

Build the image:

```bash
$ cd irrd-lab
$ docker build -t bgpq4-utils -f Dockerfile.bgpq4 .
```

The bgpq4 container will be connected to Transit's network in the Containerlab topology, giving it a Layer 3 path to the IRRd server. We will run bgpq4 commands inside this container using `docker exec`.

### Generating FRR Prefix Filters

bgpq4's default output format is Cisco IOS style, which FRR also accepts. To generate a prefix-list for the routes AS100 is authorized to announce, we query our lab IRRd server and use the AS-ISP-A *as-set* as the query target. The `-h` flag points bgpq4 to our IRRd server instead of the default public server (rr.ntt.net), and `-S` selects the LABRIR source. We run the command inside the bgpq4 utility container using `docker exec`:

```bash
$ docker exec clab-bgplab-bgpq4 bgpq4 -h 10.0.0.4 -S LABRIR -l AS100-IN AS-ISP-A
```

Expected output:

```
no ip prefix-list AS100-IN
ip prefix-list AS100-IN permit 198.51.100.0/24
```

Now generate the prefix-list for AS200:

```bash
$ docker exec clab-bgplab-bgpq4 bgpq4 -h 10.0.0.4 -S LABRIR -l AS200-IN AS-ISP-B
```

Expected output:

```
no ip prefix-list AS200-IN
ip prefix-list AS200-IN permit 203.0.113.0/24
```

We query using the *as-set* names (AS-ISP-A, AS-ISP-B) rather than the AS numbers directly. bgpq4 recursively expands the as-set membership — it finds that AS-ISP-A contains AS100, then looks up all route objects with `origin: AS100`. In our simple lab this produces the same result as querying `AS100` directly, but in production an ISP's as-set might contain dozens of customer ASes, each with their own prefixes. Querying the as-set captures them all in one pass.

You can also query with the AS number directly to see the same result:

```bash
$ docker exec clab-bgplab-bgpq4 bgpq4 -h 10.0.0.4 -S LABRIR -l AS100-IN AS100
```



### Automation Script

In production, network operators typically automate filter generation. They run bgpq4 on a schedule (often via cron), generate updated prefix-lists from the IRR, and push them to their routers. We can demonstrate this workflow with a simple shell script that runs bgpq4 inside the utility container and applies the resulting filters to AS300.


Make the script executable:

```bash
$ chmod +x irrd-lab/generate-filters.sh
```

We will use this script after deploying the Containerlab topology in the next section. This is exactly the workflow real operators use — the only difference is that they query public IRR servers like RADB instead of a local lab instance, and they push configurations via NETCONF or SSH rather than `docker exec`.



### Deploy and Verify


First, build both container images (if you have not already):

```bash
$ cd irrd-lab
$ docker build -t irrd-lab -f Dockerfile.irrd .
$ docker build -t bgpq4-utils -f Dockerfile.bgpq4 .
```

Deploy the entire lab with a single command:

```bash
$ sudo containerlab deploy -t topology.yml
```

This brings up all five containers: three FRR routers, the IRRd server, and the bgpq4 utility container. The IRRd container needs 15–30 seconds to start PostgreSQL, run migrations, load the RPSL data, and start the WHOIS server. Wait for initialization to complete:

```bash
$ docker logs -f clab-bgplab-irrd 2>&1 | grep -m1 "IRRd Lab Container Ready"
```



## Applying IRR-Based Prefix Filters

Now for the payoff: we will use bgpq4 to query our IRRd server, generate prefix-lists, and apply them to AS300. This is the step where IRR data translates into working router filters that control which BGP announcements AS300 accepts from each peer.

### Generating and Applying the Filters

You can apply the filters manually or use the automation script we created earlier. Let's walk through the manual process first so you can see exactly what happens at each step.

Generate the prefix-list for AS100 by querying the IRRd server from the bgpq4 utility container:

```bash
$ docker exec clab-bgplab-bgpq4 bgpq4 -h 10.0.0.4 -S LABRIR -l AS100-IN AS-ISP-A
```

```
no ip prefix-list AS100-IN
ip prefix-list AS100-IN permit 198.51.100.0/24
```

Generate the prefix-list for AS200:

```bash
$ docker exec clab-bgplab-bgpq4 bgpq4 -h 10.0.0.4 -S LABRIR -l AS200-IN AS-ISP-B
```

```
no ip prefix-list AS200-IN
ip prefix-list AS200-IN permit 203.0.113.0/24
```



## Conclusion



## Clean Up



## Additional Resources

- [IRRd Documentation](https://irrd.readthedocs.io/en/stable/) — Full reference for IRRd configuration and operation
- [bgpq4 GitHub Repository](https://github.com/bgp/bgpq4) — Source code, documentation, and examples
- [RPSL RFC 2622](https://www.rfc-editor.org/rfc/rfc2622) — The Routing Policy Specification Language standard
- [NLNOG BGP Filter Guide](http://bgpfilterguide.nlnog.net/) — Community guide for building BGP filters using IRR data
- [MANRS Implementation Guide](https://www.manrs.org/resources/) — Best practices for routing security, including IRR registration and prefix filtering
- [Containerlab Documentation](https://containerlab.dev/) — Containerlab installation, topology file reference, and examples




