Extra lines from Irrd bgpq4 lab post








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

With the container image built, we need routing policy data for it to serve. In production, IRR databases contain millions of objects registered by thousands of network operators. Our lab needs only a handful: enough to represent four autonomous systems and their authorized prefixes.

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
$ docker exec clab-bgplab-bgpq4 bgpq4 -h 10.0.0.4 -S LABRIR -j -l AS100-IN AS-ISP-A
```

```json
{
  "AS100-IN": [
    { "prefix": "198.51.100.0/24", "exact": true }
  ]
}
```

### Automation Script

In production, network operators typically automate filter generation. They run bgpq4 on a schedule (often via cron), generate updated prefix-lists from the IRR, and push them to their routers. We can demonstrate this workflow with a simple shell script that runs bgpq4 inside the utility container and applies the resulting filters to AS300.

Create the file *irrd-lab/generate-filters.sh*:

```bash
#!/bin/bash
set -euo pipefail

IRRD_HOST="10.0.0.4"
IRRD_SOURCE="LABRIR"
TRANSIT_CONTAINER="clab-bgplab-as300"
BGPQ4_CONTAINER="clab-bgplab-bgpq4"

echo "=== Generating IRR-based prefix filters for AS300 ==="

# Generate prefix-list for AS100 (ISP-A)
echo "Querying IRRd for AS100 authorized prefixes..."
AS100_FILTER=$(docker exec "$BGPQ4_CONTAINER" bgpq4 -h "$IRRD_HOST" -S "$IRRD_SOURCE" -l AS100-IN AS-ISP-A)
echo "$AS100_FILTER"

# Generate prefix-list for AS200 (ISP-B)
echo "Querying IRRd for AS200 authorized prefixes..."
AS200_FILTER=$(docker exec "$BGPQ4_CONTAINER" bgpq4 -h "$IRRD_HOST" -S "$IRRD_SOURCE" -l AS200-IN AS-ISP-B)
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

1. **Queries IRRd** by running bgpq4 inside the utility container via `docker exec`, using the as-set names to look up each peer's authorized prefixes
2. **Generates prefix-lists and route-maps** — the prefix-lists define which prefixes are allowed, and the route-maps attach those lists to each BGP neighbor's inbound session
3. **Applies the configuration** to AS300's running FRR instance via `docker exec ... vtysh` and performs a soft BGP reset so the new filters take effect immediately

Make the script executable:

```bash
$ chmod +x irrd-lab/generate-filters.sh
```

We will use this script after deploying the Containerlab topology in the next section. This is exactly the workflow real operators use — the only difference is that they query public IRR servers like RADB instead of a local lab instance, and they push configurations via NETCONF or SSH rather than `docker exec`.
