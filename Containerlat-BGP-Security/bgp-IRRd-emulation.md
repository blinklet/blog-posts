# Emulating an IRR Database with IRRd, bgpq4, and Containerlab for BGP Prefix Filter Testing

Every day, Internet service providers make trust decisions about which routes to accept from their BGP peers. One of the most important tools they use is the Internet Routing Registry, or IRR — a public database where network operators register which IP prefixes they are authorized to announce. When a BGP neighbor sends a route advertisement, the receiving router checks whether that announcement matches what is registered in the IRR. If it does not match, the route is filtered out.

The standard tool for building these filters is [bgpq4](https://github.com/bgp/bgpq4), a command-line utility that queries IRR servers like [RADB](https://www.radb.net/) and generates router filter configurations automatically. Together, IRR data and bgpq4 form the most widely deployed BGP security mechanism on the Internet today. Yet most network engineers have never set up an IRR server themselves, and many have never seen how bgpq4 queries translate into working router filters.

<!--more-->

In this post, I will show you how to run your own IRR server using [IRRd (Internet Routing Registry Daemon)](https://irrd.readthedocs.io/en/stable/) — the same software that powers production registries like RADB — entirely inside a [Containerlab](https://containerlab.dev/) lab environment. I will populate the IRR database with routing policy objects for a small three-AS network, use bgpq4 to generate [FRR](https://frrouting.org/) prefix-list filters from that data, and then demonstrate how those filters prevent a BGP peer from announcing prefixes it does not own.

Running your own IRRd instance means you can experiment freely: register any prefix, create any AS number, and test filter behavior without touching production infrastructure. Everything runs locally in containers on a single Linux host.

This is the first post in a series on BGP security. Here, I focus on IRR-based prefix filtering, which is the first line of defense. In a future post, I will add RPKI (Resource Public Key Infrastructure) validation, which provides cryptographic proof of prefix ownership on top of the IRR data. A third post will combine both mechanisms in a full multi-AS topology with hijack and route-leak attack scenarios.

By the end of this post, you will have a fully reproducible lab that demonstrates the complete IRR-based filtering workflow: from registering routing policy objects, to generating filters with bgpq4, to blocking an unauthorized BGP announcement.

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

## Lab Architecture

The lab uses three autonomous systems connected in a hub-and-spoke topology, with a Transit provider (AS300) at the center and two ISPs (AS100 and AS200) as peers. An IRRd server is attached to Transit's network, just as a real IRR server like RADB would be reachable over the Internet.

```
      ┌─────────┐    ┌──────────┐    ┌─────────┐
      │  ISP-A  ├────┤ Transit  ├────┤  ISP-B  │
      │  AS100  │    │  AS300   │    │  AS200  │
      └─────────┘    └────┬─────┘    └─────────┘
                          │
                     ┌────┴──────┐
                     │   IRRd    │
                     │(WHOIS :43)│
                     └───────────┘
```

ISP-A and ISP-B reach the IRRd server by routing through Transit — the same way real-world operators reach public IRR servers over the Internet.

Three ASes is the minimum needed to demonstrate transit filtering: a transit provider that applies prefix filters on inbound sessions from two peers. Using [RFC 5737](https://www.rfc-editor.org/rfc/rfc5737) documentation addresses for the announced prefixes keeps the lab completely self-contained.

### Nodes

| Node | AS | Role | Announced Prefixes |
|------|----|------|--------------------|
| ISP-A | AS100 | Legitimate prefix holder | 198.51.100.0/24 |
| ISP-B | AS200 | Peer; will later attempt an unauthorized announcement | 203.0.113.0/24 (own); later tries 198.51.100.0/24 |
| Transit | AS300 | Transit provider; applies IRR-based prefix filters | 100.64.0.0/24 |
| IRRd | — | IRR database server (PostgreSQL + Redis + IRRd in a single container) | — |

### Interconnect Addressing

Each link uses a /31 point-to-point subnet from the 10.0.0.0/24 range:

| Link | Endpoint A | Address | Endpoint B | Address |
|------|-----------|---------|-----------|---------|
| ISP-A – Transit | as100 eth1 | 10.0.0.0/31 | as300 eth1 | 10.0.0.1/31 |
| ISP-B – Transit | as200 eth1 | 10.0.0.2/31 | as300 eth2 | 10.0.0.3/31 |
| IRRd – Transit  | irrd eth1  | 10.0.0.4/31 | as300 eth3 | 10.0.0.5/31 |

Transit (AS300) announces the IRRd link subnet (10.0.0.4/31) into BGP so that ISP-A and ISP-B learn a route to the IRRd server. This means bgpq4 can run from any router in the topology and query IRRd at 10.0.0.4.

### Design Notes

The IRRd server runs PostgreSQL, Redis, and IRRd together in a single "all-in-one" container. Bundling multiple services into one container is not the recommended Docker pattern for production, but it is pragmatic for a lab: it keeps the Containerlab topology file simple (one node instead of three) and lets a single `containerlab deploy` command bring up the entire environment. In production, IRRd, PostgreSQL, and Redis would each run as separate services.

## Building the IRRd Container Image

IRRd does not publish an official Docker image. The [deployment documentation](https://irrd.readthedocs.io/en/stable/admins/deployment/) describes a native installation with PostgreSQL and Redis as separate services. Since we want everything in a single Containerlab topology — no Docker Compose, no external services — we will build a custom all-in-one container that bundles PostgreSQL, Redis, and IRRd together.

This section creates three files: a Dockerfile, an entrypoint script, and an IRRd configuration file. All three go in the *irrd-lab/* directory alongside the Containerlab topology file we will create later.

### The Dockerfile

The Dockerfile starts from `python:3.11-slim-bookworm` (a Debian Bookworm base with Python pre-installed), installs PostgreSQL and Redis from Debian packages, then installs IRRd from PyPI using `pip`. Build dependencies like `gcc` and `rustc` (needed to compile some of IRRd's Python dependencies) are removed after installation to keep the image smaller.

Create the file *irrd-lab/Dockerfile.irrd*:

```dockerfile
# All-in-one IRRd lab container
# Bundles PostgreSQL, Redis, and IRRd into a single image for use
# as a Containerlab node. Not recommended for production — this is
# a lab convenience that trades Docker best practices for simplicity.

FROM python:3.11-slim-bookworm

ENV DEBIAN_FRONTEND=noninteractive \
    PGDATA=/var/lib/postgresql/data \
    IRRD_CONFIG=/etc/irrd.yaml

# Install PostgreSQL, Redis, and build dependencies for IRRd
RUN apt-get update && apt-get install -y --no-install-recommends \
        postgresql \
        redis-server \
        gnupg \
        netcat-openbsd \
        procps \
        curl \
        gcc \
        libpq-dev \
        python3-dev \
        rustc \
        cargo \
    && pip install --no-cache-dir irrd \
    && apt-get purge -y gcc python3-dev rustc cargo \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# Create directories for IRRd
RUN mkdir -p /var/log/irrd /var/run/irrd /etc/irrd /var/lib/irrd/gnupg \
    && chmod 700 /var/lib/irrd/gnupg

# Copy configuration and entrypoint
COPY irrd.yaml /etc/irrd.yaml
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose the WHOIS port
EXPOSE 43

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

# Wait for PostgreSQL to accept connections
echo "Waiting for PostgreSQL to accept connections..."
for i in $(seq 1 30); do
    if su - postgres -c "pg_isready -q" 2>/dev/null; then
        break
    fi
    sleep 1
done

# Create the IRRd database and pgcrypto extension
echo "Creating IRRd database..."
su - postgres -c "psql -tc \"SELECT 1 FROM pg_database WHERE datname='irrd'\" \
    | grep -q 1" || su - postgres -c "createdb irrd"
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
    irrd_load_database --config /etc/irrd.yaml --source LABRIR \
        /etc/irrd/lab-irr-data.rpsl
    echo "RPSL data loaded."
else
    echo "No RPSL data file found — skipping load."
fi

# ------------------------------------------------------------------
# 5. Start IRRd in the foreground
# ------------------------------------------------------------------
echo "Starting IRRd..."
echo "=== IRRd Lab Container Ready ==="
exec irrd --config /etc/irrd.yaml --foreground
```

The script follows a strict startup sequence:

1. **PostgreSQL** starts first. The script initializes a fresh database cluster on the first run, tunes a few key parameters (`random_page_cost`, `work_mem`), and creates the `irrd` database with the required `pgcrypto` extension.
2. **Redis** starts next with persistence disabled (the `--save ""` and `--appendonly no` flags) because lab data does not need to survive a container restart.
3. **`irrd_database_upgrade`** runs the schema migration that creates IRRd's internal tables.
4. If a file is bind-mounted at */etc/irrd/lab-irr-data.rpsl*, the script loads those RPSL objects automatically using `irrd_load_database`. This is how we will populate the IRR with our lab's routing policy data.
5. Finally, **IRRd** starts in the foreground with `--foreground`, so Docker sees it as the container's main process.

### The IRRd Configuration File

IRRd reads its configuration from a YAML file. The [full configuration reference](https://irrd.readthedocs.io/en/stable/admins/configuration/) has dozens of options, but our lab needs very few of them.

Create the file *irrd-lab/irrd.yaml*:

```yaml
irrd:
    database_url: 'postgresql:///irrd'
    redis_url: 'redis://localhost'
    piddir: /var/run/irrd/

    server:
        http:
            interface: '127.0.0.1'
            port: 8080
            url: 'http://localhost:8080/'
            workers: 1
        whois:
            interface: '0.0.0.0'
            port: 43
            max_connections: 5

    auth:
        gnupg_keyring: /var/lib/irrd/gnupg/
        override_password: '$1$lab$3wVEBstb/LcL4FK.G22mP.'
        set_creation:
            COMMON:
                prefix_required: false
                autnum_authentication: disabled

    email:
        from: 'irrd-lab@localhost'
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

- **`database_url`** connects to the local PostgreSQL instance over a Unix socket (both services are in the same container, so `postgresql:///irrd` is sufficient).
- **`redis_url`** connects to the local Redis instance over TCP on localhost.
- **`server.whois.interface: '0.0.0.0'`** makes the WHOIS port listen on all interfaces, so bgpq4 and other tools can query IRRd from the network.
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

### Troubleshooting

If the IRRd container fails to start, the most common issues are:

- **PostgreSQL pgcrypto extension not created** — The entrypoint runs `CREATE EXTENSION IF NOT EXISTS pgcrypto` as a superuser. If you see errors about missing functions, check the PostgreSQL log: `docker exec clab-...-irrd cat /var/log/irrd/postgresql.log`
- **Redis connection refused** — Verify Redis started successfully: `docker exec clab-...-irrd redis-cli ping` should return `PONG`
- **IRRd configuration errors** — IRRd validates its configuration on startup and will refuse to start if it finds problems. Check the container logs: `docker logs clab-...-irrd`
- **Slow startup** — The all-in-one container needs 15–30 seconds to initialize PostgreSQL, run migrations, load RPSL data, and start IRRd. If you query the WHOIS port before IRRd is ready, the connection will be refused. Wait for the "IRRd Lab Container Ready" message in the logs.

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

Create the file *irrd-lab/lab-irr-data.rpsl*:

```
mntner:         LAB-MNT
descr:          Lab maintainer for all objects
admin-c:        LAB-ADMIN
upd-to:         lab@localhost
auth:           MD5-PW $1$lab$3wVEBstb/LcL4FK.G22mP.
mnt-by:         LAB-MNT
source:         LABRIR

person:         Lab Administrator
address:        Lab Network
phone:          +1-555-0100
nic-hdl:        LAB-ADMIN
mnt-by:         LAB-MNT
source:         LABRIR

aut-num:        AS100
as-name:        ISP-A
descr:          ISP-A - Legitimate prefix holder
admin-c:        LAB-ADMIN
mnt-by:         LAB-MNT
source:         LABRIR

aut-num:        AS200
as-name:        ISP-B
descr:          ISP-B - Peer that will attempt unauthorized announcement
admin-c:        LAB-ADMIN
mnt-by:         LAB-MNT
source:         LABRIR

aut-num:        AS300
as-name:        TRANSIT
descr:          Transit provider - applies prefix filters
admin-c:        LAB-ADMIN
mnt-by:         LAB-MNT
source:         LABRIR

as-set:         AS-ISP-A
descr:          AS set for ISP-A and its customers
members:        AS100
mnt-by:         LAB-MNT
source:         LABRIR

as-set:         AS-ISP-B
descr:          AS set for ISP-B and its customers
members:        AS200
mnt-by:         LAB-MNT
source:         LABRIR

route:          198.51.100.0/24
descr:          ISP-A prefix
origin:         AS100
mnt-by:         LAB-MNT
source:         LABRIR

route:          203.0.113.0/24
descr:          ISP-B prefix
origin:         AS200
mnt-by:         LAB-MNT
source:         LABRIR

route:          100.64.0.0/24
descr:          Transit provider prefix
origin:         AS300
mnt-by:         LAB-MNT
source:         LABRIR
```

A few things to note about these objects:

- All objects reference **`LAB-MNT`** as their maintainer and use the same MD5 password hash. In a real IRR, each organization would have its own maintainer with its own credentials. For a lab, a single shared maintainer keeps things simple.
- The **`auth: MD5-PW`** line contains a salted MD5 hash of the password "lab". This matches the override password in our *irrd.yaml* configuration.
- Every object includes **`source: LABRIR`**, which must exactly match the source name defined in the IRRd configuration (case-sensitive).
- The **as-set** objects (AS-ISP-A and AS-ISP-B) each contain a single member AS. In practice, an ISP's as-set might contain dozens of customer ASes. bgpq4 recursively expands as-set membership to find all authorized prefixes — this is how operators build filters for transit customers who have their own downstream networks.

### Loading the Data

The entrypoint script we created in Part 4 automatically loads RPSL data from */etc/irrd/lab-irr-data.rpsl* if the file exists. When we build the Containerlab topology in a later section, we will bind-mount this file into the container. The entrypoint runs:

```bash
irrd_load_database --config /etc/irrd.yaml --source LABRIR /etc/irrd/lab-irr-data.rpsl
```

The `irrd_load_database` command performs a bulk import that replaces all existing objects in the specified source with the contents of the file. This is the same mechanism production IRR operators use to load full database snapshots. For our lab, it loads all 11 objects in a single operation.

If you need to reload the data after the lab is running (for example, after editing the RPSL file), you can run the command manually:

```bash
$ docker exec clab-bgplab-irrd irrd_load_database \
    --config /etc/irrd.yaml --source LABRIR /etc/irrd/lab-irr-data.rpsl
```

### Verifying the Data

Once the IRRd container is running and the data is loaded, you can verify it using WHOIS queries. The WHOIS protocol is text-based: you send a query string over TCP to port 43 and receive the matching objects in plain text.

Query for all route objects registered to AS100:

```bash
$ docker exec clab-bgplab-irrd bash -c 'echo "-i origin AS100" | nc localhost 43'
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
$ docker exec clab-bgplab-irrd bash -c 'echo "198.51.100.0/24" | nc localhost 43'
```

Expand the AS-ISP-A set using IRRd's extended query syntax (the `!i` command):

```bash
$ docker exec clab-bgplab-irrd bash -c 'echo "!iAS-ISP-A" | nc localhost 43'
```

Expected output:

```
A100
```

This confirms that IRRd has loaded the data and is serving it correctly over the WHOIS protocol — exactly as bgpq4 will query it when we generate prefix filters.

## Using bgpq4 to Generate Prefix Filters

With a working IRRd server full of RPSL objects, we can now do what real network operators do every day: use [bgpq4](https://github.com/bgp/bgpq4) to query the registry and automatically generate router prefix-list configurations. This is the step where IRR data becomes actionable — bgpq4 reads the registry, finds which prefixes each AS is authorized to announce, and produces configuration snippets that FRR can apply directly.

### Installing bgpq4

bgpq4 is available in most Linux distributions' package repositories. On Debian or Ubuntu:

```bash
$ sudo apt install bgpq4
```

If your distribution does not package bgpq4, you can build it from the [GitHub repository](https://github.com/bgp/bgpq4):

```bash
$ git clone https://github.com/bgp/bgpq4.git
$ cd bgpq4
$ ./bootstrap   # if building from git
$ ./configure
$ make
$ sudo make install
```

You can also run bgpq4 from a container image without installing anything on your host:

```bash
$ docker run --rm --network host ghcr.io/bgp/bgpq4:latest -h 10.0.0.4 -S LABRIR AS100
```

For this post, I assume bgpq4 is installed on the host. The commands work the same way regardless of how you install it.

### Generating FRR Prefix Filters

bgpq4's default output format is Cisco IOS style, which FRR also accepts. To generate a prefix-list for the routes AS100 is authorized to announce, we query our lab IRRd server and use the AS-ISP-A *as-set* as the query target. The `-h` flag points bgpq4 to our IRRd server instead of the default public server (rr.ntt.net), and `-S` selects the LABRIR source:

```bash
$ bgpq4 -h 10.0.0.4 -S LABRIR -l AS100-IN AS-ISP-A
```

Expected output:

```
no ip prefix-list AS100-IN
ip prefix-list AS100-IN permit 198.51.100.0/24
```

Now generate the prefix-list for AS200:

```bash
$ bgpq4 -h 10.0.0.4 -S LABRIR -l AS200-IN AS-ISP-B
```

Expected output:

```
no ip prefix-list AS200-IN
ip prefix-list AS200-IN permit 203.0.113.0/24
```

We query using the *as-set* names (AS-ISP-A, AS-ISP-B) rather than the AS numbers directly. bgpq4 recursively expands the as-set membership — it finds that AS-ISP-A contains AS100, then looks up all route objects with `origin: AS100`. In our simple lab this produces the same result as querying `AS100` directly, but in production an ISP's as-set might contain dozens of customer ASes, each with their own prefixes. Querying the as-set captures them all in one pass.

You can also query with the AS number directly to see the same result:

```bash
$ bgpq4 -h 10.0.0.4 -S LABRIR -l AS100-IN AS100
```

### Understanding the Output

The output is a pair of FRR (Cisco-style) configuration commands:

- **`no ip prefix-list AS100-IN`** removes any existing prefix-list with that name, ensuring a clean slate
- **`ip prefix-list AS100-IN permit 198.51.100.0/24`** allows exactly the /24 prefix registered in the IRR

Any prefix not explicitly permitted is implicitly denied — FRR appends an invisible `deny any` at the end of every prefix-list. This means AS300 will reject any prefix announcement from AS100 that does not match 198.51.100.0/24.

bgpq4 supports several useful flags for customizing the output:

- **`-j`** produces JSON output, useful for automation scripts that parse the data programmatically
- **`-F`** lets you specify a custom output format string for non-standard router platforms
- **`-A`** enables prefix aggregation — bgpq4 will combine adjacent prefixes into larger blocks where possible, producing shorter prefix-lists
- **`-4`** or **`-6`** restricts output to IPv4 or IPv6 prefixes (bgpq4 generates IPv4 by default)

For example, JSON output for automation:

```bash
$ bgpq4 -h 10.0.0.4 -S LABRIR -j -l AS100-IN AS-ISP-A
```

```json
{
  "AS100-IN": [
    { "prefix": "198.51.100.0/24", "exact": true }
  ]
}
```

### Automation Script

In production, network operators typically automate filter generation. They run bgpq4 on a schedule (often via cron), generate updated prefix-lists from the IRR, and push them to their routers. We can demonstrate this workflow with a simple shell script.

Create the file *irrd-lab/generate-filters.sh*:

```bash
#!/bin/bash
set -euo pipefail

IRRD_HOST="10.0.0.4"
IRRD_SOURCE="LABRIR"
TRANSIT_CONTAINER="clab-bgplab-as300"

echo "=== Generating IRR-based prefix filters for AS300 ==="

# Generate prefix-list for AS100 (ISP-A)
echo "Querying IRRd for AS100 authorized prefixes..."
AS100_FILTER=$(bgpq4 -h "$IRRD_HOST" -S "$IRRD_SOURCE" -l AS100-IN AS-ISP-A)
echo "$AS100_FILTER"

# Generate prefix-list for AS200 (ISP-B)
echo "Querying IRRd for AS200 authorized prefixes..."
AS200_FILTER=$(bgpq4 -h "$IRRD_HOST" -S "$IRRD_SOURCE" -l AS200-IN AS-ISP-B)
echo "$AS200_FILTER"

# Apply filters to AS300's FRR via vtysh
echo "Applying prefix filters to ${TRANSIT_CONTAINER}..."

docker exec "$TRANSIT_CONTAINER" vtysh -c "
configure terminal
${AS100_FILTER}
${AS200_FILTER}
route-map AS100-IN permit 10
 match ip address prefix-list AS100-IN
route-map AS100-IN deny 20
route-map AS200-IN permit 10
 match ip address prefix-list AS200-IN
route-map AS200-IN deny 20
router bgp 300
 address-family ipv4 unicast
  neighbor 10.0.0.0 route-map AS100-IN in
  neighbor 10.0.0.2 route-map AS200-IN in
end
"

echo "Filters applied. Performing soft reset..."
docker exec "$TRANSIT_CONTAINER" vtysh -c "clear bgp ipv4 unicast * soft in"

echo "=== Done ==="
```

The script does three things:

1. **Queries IRRd** for each peer's authorized prefixes using bgpq4 with the as-set names
2. **Generates prefix-lists and route-maps** — the prefix-lists define which prefixes are allowed, and the route-maps attach those lists to each BGP neighbor's inbound session
3. **Applies the configuration** to AS300's running FRR instance via `docker exec ... vtysh` and performs a soft BGP reset so the new filters take effect immediately

Make the script executable:

```bash
$ chmod +x irrd-lab/generate-filters.sh
```

We will use this script after deploying the Containerlab topology in the next section. This is exactly the workflow real operators use — the only difference is that they query public IRR servers like RADB instead of a local lab instance, and they push configurations via NETCONF or SSH rather than `docker exec`.

## Building the Containerlab BGP Network

With the IRRd container image built, RPSL data prepared, and bgpq4 ready to generate filters, we can now assemble everything into a single Containerlab topology. One command will bring up three FRR routers and the IRRd server, establishing a working BGP network that we can then protect with IRR-based prefix filters.

### Containerlab Topology File

Create the file *irrd-lab/topology.yml*:

```yaml
name: bgplab

mgmt:
  network: mgmt-bgplab
  ipv4-subnet: 172.20.30.0/24

topology:

  nodes:

    # ── ISP-A (AS100) — Legitimate prefix holder ─────────
    as100:
      kind: linux
      image: quay.io/frrouting/frr:10.2.1
      binds:
        - configs/as100/daemons:/etc/frr/daemons
        - configs/as100/frr.conf:/etc/frr/frr.conf
      exec:
        - ip addr add 198.51.100.1/24 dev lo
        - ip addr add 10.0.0.0/31 dev eth1

    # ── ISP-B (AS200) — Peer / will attempt hijack ───────
    as200:
      kind: linux
      image: quay.io/frrouting/frr:10.2.1
      binds:
        - configs/as200/daemons:/etc/frr/daemons
        - configs/as200/frr.conf:/etc/frr/frr.conf
      exec:
        - ip addr add 203.0.113.1/24 dev lo
        - ip addr add 10.0.0.2/31 dev eth1

    # ── Transit (AS300) — Applies IRR-based filters ───────
    as300:
      kind: linux
      image: quay.io/frrouting/frr:10.2.1
      binds:
        - configs/as300/daemons:/etc/frr/daemons
        - configs/as300/frr.conf:/etc/frr/frr.conf
      exec:
        - ip addr add 100.64.0.1/24 dev lo
        - ip addr add 10.0.0.1/31 dev eth1
        - ip addr add 10.0.0.3/31 dev eth2
        - ip addr add 10.0.0.5/31 dev eth3

    # ── IRRd server (PostgreSQL + Redis + IRRd) ───────────
    irrd:
      kind: linux
      image: irrd-lab
      binds:
        - lab-irr-data.rpsl:/etc/irrd/lab-irr-data.rpsl
      exec:
        - ip addr add 10.0.0.4/31 dev eth1
        - ip route add 10.0.0.0/30 via 10.0.0.5
        - ip route add 198.51.100.0/24 via 10.0.0.5
        - ip route add 203.0.113.0/24 via 10.0.0.5
        - ip route add 100.64.0.0/24 via 10.0.0.5

  links:
    # AS100 (ISP-A) ↔ AS300 (Transit)
    - endpoints: ["as100:eth1", "as300:eth1"]
    # AS200 (ISP-B) ↔ AS300 (Transit)
    - endpoints: ["as200:eth1", "as300:eth2"]
    # IRRd ↔ AS300 (Transit)
    - endpoints: ["irrd:eth1", "as300:eth3"]
```

A few things to note in this topology:

- The three FRR nodes use the official `quay.io/frrouting/frr:10.2.1` image. The `binds:` stanzas inject the *daemons* and *frr.conf* files directly into each container at startup.
- The `exec:` stanzas assign IP addresses to the loopback and point-to-point interfaces. FRR's *zebra* daemon picks up these addresses from the Linux kernel and makes them available for BGP to announce.
- The **IRRd node** uses our custom `irrd-lab` image built in Part 4. The `lab-irr-data.rpsl` file is bind-mounted into `/etc/irrd/`, where the entrypoint script expects it. The `exec:` stanzas add static routes so the IRRd container can reach all three AS prefixes via AS300.
- AS300's FRR configuration includes `network 10.0.0.4/31` so that AS100 and AS200 learn routes to the IRRd subnet via BGP. This mirrors how operators in the real world reach public IRR servers like RADB — over the Internet, through their transit providers.

### FRR Configuration Files

Each FRR router needs two files: a *daemons* file that tells FRR which protocol daemons to start, and a *frr.conf* file with the routing configuration.

#### Daemons File

The *daemons* file is identical for all three routers. Create it in each router's configuration subdirectory:

```
bgpd=yes
zebra=yes
```

Only *bgpd* (for BGP) and *zebra* (for the kernel interface) are needed.

#### AS100 — ISP-A (Legitimate Prefix Holder)

AS100 announces 198.51.100.0/24 and peers with AS300. Create *irrd-lab/configs/as100/frr.conf*:

```
frr version 10.2
frr defaults traditional
hostname as100
!
ip route 198.51.100.0/24 Null0
!
router bgp 100
 bgp router-id 198.51.100.1
 !
 neighbor 10.0.0.1 remote-as 300
 neighbor 10.0.0.1 description transit-AS300
 !
 address-family ipv4 unicast
  network 198.51.100.0/24
  neighbor 10.0.0.1 activate
 exit-address-family
!
```

The `ip route 198.51.100.0/24 Null0` creates a blackhole static route so that BGP's `network` statement can find the prefix in the routing table. The prefix address is also assigned to the loopback interface in the topology file's `exec:` stanza, which makes it reachable within the container.

#### AS200 — ISP-B (Peer / Future Attacker)

AS200's baseline configuration only announces its own legitimate prefix, 203.0.113.0/24. Later, in the testing section, we will add an unauthorized announcement. Create *irrd-lab/configs/as200/frr.conf*:

```
frr version 10.2
frr defaults traditional
hostname as200
!
ip route 203.0.113.0/24 Null0
!
router bgp 200
 bgp router-id 203.0.113.1
 !
 neighbor 10.0.0.3 remote-as 300
 neighbor 10.0.0.3 description transit-AS300
 !
 address-family ipv4 unicast
  network 203.0.113.0/24
  neighbor 10.0.0.3 activate
 exit-address-family
!
```

#### AS300 — Transit Provider

AS300 peers with both AS100 and AS200. In this base configuration, it accepts all announcements with no prefix filtering — this is the unprotected baseline. AS300 also announces the 10.0.0.4/31 IRRd link subnet into BGP so that AS100 and AS200 can reach the IRR server. Create *irrd-lab/configs/as300/frr.conf*:

```
frr version 10.2
frr defaults traditional
hostname as300
!
ip route 100.64.0.0/24 Null0
!
router bgp 300
 bgp router-id 100.64.0.1
 !
 neighbor 10.0.0.0 remote-as 100
 neighbor 10.0.0.0 description peer-AS100
 neighbor 10.0.0.2 remote-as 200
 neighbor 10.0.0.2 description peer-AS200
 !
 address-family ipv4 unicast
  network 100.64.0.0/24
  network 10.0.0.4/31
  neighbor 10.0.0.0 activate
  neighbor 10.0.0.2 activate
 exit-address-family
!
```

### Deploy and Verify

With all files in place, the *irrd-lab/* directory should look like this:

```
irrd-lab/
├── Dockerfile.irrd
├── entrypoint.sh
├── irrd.yaml
├── lab-irr-data.rpsl
├── topology.yml
├── generate-filters.sh
└── configs/
    ├── as100/
    │   ├── daemons
    │   └── frr.conf
    ├── as200/
    │   ├── daemons
    │   └── frr.conf
    └── as300/
        ├── daemons
        └── frr.conf
```

First, build the IRRd container image (if you have not already):

```bash
$ cd irrd-lab
$ docker build -t irrd-lab -f Dockerfile.irrd .
```

Deploy the entire lab with a single command:

```bash
$ sudo containerlab deploy -t topology.yml
```

This brings up all four containers: three FRR routers and the IRRd server. The IRRd container needs 15–30 seconds to start PostgreSQL, run migrations, load the RPSL data, and start the WHOIS server. Wait for initialization to complete:

```bash
$ docker logs -f clab-bgplab-irrd 2>&1 | grep -m1 "IRRd Lab Container Ready"
```

Once IRRd is ready, verify that BGP sessions are established on AS300:

```bash
$ docker exec clab-bgplab-as300 vtysh -c "show bgp summary"
```

You should see two established BGP peers (AS100 and AS200), each advertising one prefix. Verify the full routing table:

```bash
$ docker exec clab-bgplab-as300 vtysh -c "show ip bgp"
```

Expected output should include three prefixes: 198.51.100.0/24 (from AS100), 203.0.113.0/24 (from AS200), and 100.64.0.0/24 (locally originated by AS300).

Verify that AS100 can reach the IRRd server through AS300:

```bash
$ docker exec clab-bgplab-as100 bash -c 'echo "AS100" | nc 10.0.0.4 43'
```

This confirms end-to-end connectivity: AS100 routes to the IRRd subnet (10.0.0.4/31) via its BGP-learned route through AS300, and IRRd responds with the aut-num object for AS100.

This is the **baseline** state — all BGP announcements are accepted without filtering. AS300 trusts whatever its peers announce. In the next section, we will apply the IRR-based prefix filters generated by bgpq4 to restrict what AS300 accepts from each peer.

## Applying IRR-Based Prefix Filters

Now for the payoff: we will use bgpq4 to query our IRRd server, generate prefix-lists, and apply them to AS300. This is the step where IRR data translates into working router filters that control which BGP announcements AS300 accepts from each peer.

### Generating and Applying the Filters

You can apply the filters manually or use the automation script we created earlier. Let's walk through the manual process first so you can see exactly what happens at each step.

From the host machine, generate the prefix-list for AS100 by querying the IRRd server:

```bash
$ bgpq4 -h 10.0.0.4 -S LABRIR -l AS100-IN AS-ISP-A
```

```
no ip prefix-list AS100-IN
ip prefix-list AS100-IN permit 198.51.100.0/24
```

Generate the prefix-list for AS200:

```bash
$ bgpq4 -h 10.0.0.4 -S LABRIR -l AS200-IN AS-ISP-B
```

```
no ip prefix-list AS200-IN
ip prefix-list AS200-IN permit 203.0.113.0/24
```

Now apply these prefix-lists to AS300, along with route-maps that attach them to each BGP neighbor's inbound session. Enter AS300's vtysh and configure:

```bash
$ docker exec -it clab-bgplab-as300 vtysh
```

```
as300# configure terminal
as300(config)# no ip prefix-list AS100-IN
as300(config)# ip prefix-list AS100-IN permit 198.51.100.0/24
as300(config)# no ip prefix-list AS200-IN
as300(config)# ip prefix-list AS200-IN permit 203.0.113.0/24
as300(config)#
as300(config)# route-map AS100-IN permit 10
as300(config-route-map)# match ip address prefix-list AS100-IN
as300(config-route-map)# exit
as300(config)# route-map AS100-IN deny 20
as300(config-route-map)# exit
as300(config)#
as300(config)# route-map AS200-IN permit 10
as300(config-route-map)# match ip address prefix-list AS200-IN
as300(config-route-map)# exit
as300(config)# route-map AS200-IN deny 20
as300(config-route-map)# exit
as300(config)#
as300(config)# router bgp 300
as300(config-router)# address-family ipv4 unicast
as300(config-router-af)# neighbor 10.0.0.0 route-map AS100-IN in
as300(config-router-af)# neighbor 10.0.0.2 route-map AS200-IN in
as300(config-router-af)# end
as300#
```

The configuration has three layers:

1. **Prefix-lists** define which prefixes are allowed — AS100-IN permits only 198.51.100.0/24, AS200-IN permits only 203.0.113.0/24
2. **Route-maps** reference the prefix-lists — sequence 10 permits matching prefixes, sequence 20 denies everything else
3. **BGP neighbor configuration** applies the route-maps on each peer's inbound session — AS300 now filters what it accepts from AS100 (via 10.0.0.0) and AS200 (via 10.0.0.2)

After applying the configuration, perform a soft inbound reset so that the filters take effect on the existing routes:

```bash
as300# clear bgp ipv4 unicast * soft in
```

Alternatively, you can skip the manual steps and run the automation script from Part 6, which does exactly the same thing:

```bash
$ ./generate-filters.sh
```

### Verifying Filtered Operation

Check that AS300's BGP table still contains the expected routes:

```bash
$ docker exec clab-bgplab-as300 vtysh -c "show ip bgp"
```

You should see:

- **198.51.100.0/24** from AS100 — accepted (matches AS100-IN prefix-list)
- **203.0.113.0/24** from AS200 — accepted (matches AS200-IN prefix-list)
- **100.64.0.0/24** locally originated by AS300

All three prefixes are present because each peer is announcing only its own authorized prefix. The filters are in place but have not blocked anything yet — the network is operating normally.

Verify the prefix-lists are installed:

```bash
$ docker exec clab-bgplab-as300 vtysh -c "show ip prefix-list"
```

Expected output:

```
ip prefix-list AS100-IN: 1 entries
   seq 5 permit 198.51.100.0/24
ip prefix-list AS200-IN: 1 entries
   seq 5 permit 203.0.113.0/24
```

You can also confirm the route-maps are applied to the correct neighbors:

```bash
$ docker exec clab-bgplab-as300 vtysh -c "show ip bgp neighbors 10.0.0.0" | grep "route-map"
```

```
  Route map for incoming advertisements is *AS100-IN
```

The filters are active. AS300 will now reject any prefix from AS100 that is not 198.51.100.0/24, and any prefix from AS200 that is not 203.0.113.0/24. In the next section, we will test this by having AS200 attempt to announce a prefix it does not own.



