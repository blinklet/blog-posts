# Blog Post Plan: Emulating an IRR Database for BGP Filter Testing

## Post Title (Draft)
**"Emulating an IRR Database with IRRd, bgpq4, and Containerlab for BGP Prefix Filter Testing"**

---

## Series Context

This is the **first post** in a series leading to a comprehensive BGP security lab. The series will progressively build the reader's lab from a simple IRR-based prefix filtering scenario to a full multi-AS topology with RPKI validation, route-origin authorization, and hijack demonstrations.

**Series roadmap:**
1. **This post** — Set up a local IRRd server, populate it with RPSL objects, use bgpq4 to generate prefix filters, and demonstrate prefix filtering in a small Containerlab BGP network.
2. **Post 2** — Add RPKI validation with Routinator and SLURM-based ROA assertions; show how RPKI blocks hijacks that bypass IRR filters.
3. **Post 3** — Full multi-AS topology combining IRR filtering, RPKI validation, and hijack/route-leak attack scenarios (the comprehensive lab described in `containerlab-bgp-security.md`).

---

## Executive Summary

This post will show readers how to run [IRRd (Internet Routing Registry Daemon)](https://irrd.readthedocs.io/en/stable/) along with its PostgreSQL and Redis dependencies entirely within a Containerlab topology, populate it with RPSL route objects that represent a small lab network, and then use [bgpq4](https://github.com/bgp/bgpq4) to query the local IRRd instance and generate FRR prefix-list filters. The generated filters are applied to a small three-AS BGP network — all managed by a single Containerlab topology file — to demonstrate how IRR-based prefix filtering prevents a peer from announcing prefixes it does not own.

---

## Target Audience

- Network engineers learning BGP security best practices
- Students and researchers studying Internet routing registry infrastructure
- Network operators who want to understand how bgpq4 and IRRd work together
- Readers of the existing Containerlab blog post who want to go deeper into BGP security

---

## Prerequisites to Mention

- Linux host (bare metal, VM, or WSL2) with at least 4 GB RAM and 2 cores
- Docker installed
- Containerlab installed (link to the existing Containerlab install instructions in the companion post)
- Basic understanding of BGP (AS numbers, prefixes, peering)
- Familiarity with the Linux command line

---

## Post Structure

### Part 1: Introduction (300–400 words)

**Goals:**
- Explain why this post exists as the first in a series
- Motivate the reader: IRR-based prefix filtering is the most widely deployed BGP security mechanism, yet most engineers have never set up or queried an IRR server themselves
- Explain what the reader will build: a local IRRd instance, bgpq4 filter generation, and a working Containerlab lab that uses those filters

**Key points:**
- Network operators build prefix filters from IRR data to decide which route announcements to accept from their BGP peers
- The standard tool for generating these filters is *bgpq4*, which queries IRR servers like RADB (rr.ntt.net) to extract authorized prefix-to-AS mappings
- Running your own IRRd instance lets you experiment freely — you can register any prefix, any AS, and test filter behavior without touching production infrastructure
- By the end of the post readers will have a reproducible lab that demonstrates the full IRR-based filtering workflow

---

### Part 2: Background — IRRd, RPSL, and bgpq4 (500–600 words)

**Goals:**
- Give readers enough theory to understand the lab, without duplicating the comprehensive BGP security explainer already in the companion post

**Topics:**

1. **What is an Internet Routing Registry (IRR)?**
   - A database of RPSL (Routing Policy Specification Language) objects
   - Contains *route* objects (prefix → origin AS mapping), *aut-num* objects (AS metadata), and *as-set* objects (groups of ASes)
   - Operated by RIRs (ARIN, RIPE NCC, APNIC, LACNIC, AFRINIC) and independent registries (RADB, NTTCOM, etc.)
   - Network operators query IRRs to learn which prefixes each peer AS is authorized to announce

2. **What is IRRd?**
   - Open-source IRR daemon, version 4.5.0 (February 2026), maintained by Reliably Coded / NTT / ARIN / community
   - Provides a WHOIS query interface on port 43 (the query protocol that bgpq4 speaks)
   - Stores RPSL objects in a PostgreSQL database, uses Redis for inter-process communication
   - Can operate as an authoritative source (accept local submissions) or mirror external IRR databases
   - For our lab, we will configure a single authoritative source and load objects locally

3. **What is bgpq4?**
   - Command-line tool that queries an IRR server and generates router filter configurations
   - Supports output for Cisco IOS, Juniper JunOS, FRR, BIRD, Nokia, Mikrotik, Arista, Huawei, and custom formats
   - Default query target is rr.ntt.net (NTT's IRR mirror); the `-h` flag redirects queries to any IRR host
   - Example: `bgpq4 -h 10.0.0.4 -S LABRIR -l AS100-IN AS100` queries the lab IRRd server for AS100's authorized prefixes and produces an FRR prefix-list

4. **How the pieces fit together**
   - IRRd stores the authoritative prefix registrations
   - bgpq4 reads them and emits router configuration snippets
   - The network operator pastes (or scripts) those snippets into FRR, which then applies the filters to BGP sessions
   - This is exactly the workflow used by real-world network operators, but we run every component locally inside containers

---

### Part 3: Lab Architecture (200–300 words + diagram)

**Goals:**
- Present the simple three-AS topology
- Show where IRRd and bgpq4 fit in the picture
- Explain why this topology is large enough to demonstrate filtering

**Lab topology:**

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

  ISP-A and ISP-B reach IRRd by routing through Transit
```

**Nodes:**

| Node | AS | Role | Prefixes |
|------|----|------|----------|
| ISP-A  | AS100 | Legitimate prefix holder | 198.51.100.0/24 |
| ISP-B  | AS200 | Peer; will attempt unauthorized announcement | 203.0.113.0/24 (own); later tries 198.51.100.0/24 |
| Transit | AS300 | Transit provider; applies IRR-based prefix filters on customer/peer sessions | 100.64.0.0/24 (own) |
| IRRd | — | IRR database server (custom image with PostgreSQL + Redis + IRRd), connected to Transit's network | 10.0.0.4/31 (link to AS300) |

**Interconnect addressing:**

| Link | Endpoint A | Address A | Endpoint B | Address B |
|------|-----------|-----------|-----------|-----------|
| AS100 – AS300 | as100 eth1 | 10.0.0.0/31 | as300 eth1 | 10.0.0.1/31 |
| AS200 – AS300 | as200 eth1 | 10.0.0.2/31 | as300 eth2 | 10.0.0.3/31 |
| IRRd – AS300  | irrd eth1  | 10.0.0.4/31 | as300 eth3 | 10.0.0.5/31 |

**Design notes:**
- Three ASes is the minimum needed to demonstrate transit filtering (a transit provider filtering announcements from two peers)
- Using RFC 5737 (198.51.100.0/24, 203.0.113.0/24) addresses for the announced prefixes keeps the lab self-contained
- The IRRd server is connected to Transit (AS300) via a point-to-point link, just as a real IRR server would be hosted in a provider's network. ISP-A and ISP-B reach IRRd by routing through Transit — exactly as real-world operators reach public IRR servers like RADB over the Internet.
- AS300 originates the IRRd link subnet (10.0.0.4/31) into BGP so that AS100 and AS200 learn routes to it
- bgpq4 runs from within a utility container connected to Transit's network, queries IRRd at 10.0.0.4, and the generated filter configs are applied to the FRR routers

---

### Part 4: Building the IRRd Container Image (600–800 words)

**Goals:**
- Build a custom all-in-one Docker image that bundles IRRd, PostgreSQL, and Redis into a single container
- Explain each component and configuration choice
- This is the most technically novel part of the post — packaging a production-grade IRR server for lab use in Containerlab

**Research required:**
- Determine whether an official IRRd Docker image exists or whether we need to build one (no official image found — likely need a custom Dockerfile)
- Confirm minimum resource requirements for a nearly-empty database (the 32 GB / 150 GB production recommendations are for full Internet IRR data; our lab has < 20 objects)
- Test `irrd_load_database` command for bulk-loading RPSL objects from a text file
- Test running PostgreSQL, Redis, and IRRd together in a single container managed by a process supervisor (e.g., `supervisord` or a simple entrypoint script)

**Sections:**

#### 4.1 Custom IRRd Dockerfile

- Build a single all-in-one container image that includes PostgreSQL, Redis, and IRRd
- Base image: `python:3.11-slim` (or `debian:bookworm-slim`)
- Install PostgreSQL server and Redis server from Debian packages, plus `pip install irrd`
- Use a startup entrypoint script (`entrypoint.sh`) that:
  1. Starts PostgreSQL
  2. Creates the database and enables the `pgcrypto` extension
  3. Starts Redis
  4. Runs `irrd_database_upgrade` (schema migration)
  5. Optionally loads RPSL objects from a bind-mounted file using `irrd_load_database`
  6. Starts IRRd in the foreground
- This "all-in-one" approach keeps the Containerlab topology file clean — one node for IRRd instead of three
- PostgreSQL tuned for minimal use: `random_page_cost=1.0`, `work_mem=50MB`
- Redis persistence disabled (not needed for lab)

#### 4.2 IRRd Configuration File (`irrd.yaml`)

- Minimal configuration for a lab scenario:
  - `database_url`: pointing to localhost PostgreSQL (all services in one container)
  - `redis_url`: pointing to localhost Redis (all services in one container)
  - `server.whois.interface`: `0.0.0.0`
  - `server.whois.port`: `43`
  - A single authoritative source named `LABRIR` with `authoritative: true` and `keep_journal: true`
  - No email configuration (not needed)
  - No RPKI integration (that's a later post)
  - Disable scope filtering and other advanced features

#### 4.3 Building the Image

- `docker build -t irrd-lab -f Dockerfile.irrd .`
- The built image will be referenced in the Containerlab topology file
- Containerlab can also build images automatically using the `image` and `build` directives in the topology file (research whether this is supported)

#### 4.4 Troubleshooting

- Common issues: PostgreSQL pgcrypto extension not created, Redis connection refused, entrypoint script ordering
- How to inspect logs inside the running container: `docker exec clab-...-irrd cat /var/log/irrd/irrd.log`

---

### Part 5: Populating the IRR Database (400–500 words)

**Goals:**
- Create RPSL objects for the lab's three ASes
- Load them into IRRd using `irrd_load_database` or the WHOIS submission interface
- Verify the loaded data with manual WHOIS queries

**Sections:**

#### 5.1 RPSL Objects File

Create a file `lab-irr-data.rpsl` containing:

- `mntner` objects for each AS (required for authoritative sources)
- `aut-num` objects: AS100, AS200, AS300
- `as-set` objects: AS-ISP-A (containing AS100), AS-ISP-B (containing AS200)
- `route` objects:
  - 198.51.100.0/24 origin AS100
  - 203.0.113.0/24 origin AS200
  - 100.64.0.0/24 origin AS300
- Note: NO route object for 198.51.100.0/24 with origin AS200

**Key teaching point**: The `as-set` objects are important because bgpq4 can expand an as-set to find all member ASes and their registered prefixes. This is how operators filter customers who have their own downstream customers.

#### 5.2 Loading Data

- Use `docker exec clab-...-irrd irrd_load_database --source LABRIR /path/to/lab-irr-data.rpsl` inside the IRRd container
- Alternatively, the entrypoint script can auto-load the RPSL file on first boot if it detects a bind-mounted data file
- Or: submit objects via the WHOIS interface (educational, but slower)

#### 5.3 Verifying the Data

- Query with standard WHOIS from the host (Containerlab exposes the management network): `docker exec clab-...-irrd bash -c 'echo "-i origin AS100" | nc localhost 43'`
- Query for route objects: `docker exec clab-...-irrd bash -c 'echo "198.51.100.0/24" | nc localhost 43'`
- Query for as-set expansion: `docker exec clab-...-irrd bash -c 'echo "!iAS-ISP-A" | nc localhost 43'`

---

### Part 6: Using bgpq4 to Generate Prefix Filters (500–600 words)

**Goals:**
- Show how to install bgpq4
- Demonstrate querying the local IRRd instance
- Generate FRR prefix-list configurations for each peer

**Sections:**

#### 6.1 Installing bgpq4

- Option 1: Install from package manager (`apt install bgpq4` or build from source)
- Option 2: Use the container image (`ghcr.io/bgp/bgpq4:latest`)
- Show both methods; container method is simpler for readers who don't want to compile

#### 6.2 Generating FRR Prefix Filters

- Generate a prefix-list for routes AS100 is authorized to announce (run from AS300's container or a utility container on Transit's network):
  ```bash
  $ bgpq4 -h 10.0.0.4 -S LABRIR -l AS100-IN AS100
  ```
  Expected output:
  ```
  no ip prefix-list AS100-IN
  ip prefix-list AS100-IN permit 198.51.100.0/24
  ```

- Generate a prefix-list for routes AS200 is authorized to announce:
  ```bash
  $ bgpq4 -h 10.0.0.4 -S LABRIR -l AS200-IN AS200
  ```
  Expected output:
  ```
  no ip prefix-list AS200-IN
  ip prefix-list AS200-IN permit 203.0.113.0/24
  ```

- Also demonstrate as-set expansion:
  ```bash
  $ bgpq4 -h 10.0.0.4 -S LABRIR -l AS-ISP-A-IN AS-ISP-A
  ```

#### 6.3 Understanding the Output

- Explain the `no ip prefix-list` / `ip prefix-list permit` syntax (FRR/Cisco format)
- Show how `-F` flag can customize the output format
- Show JSON output with `-j` flag for automation
- Mention `-A` flag for aggregation

#### 6.4 Automation Script

- Write a small shell script `generate-filters.sh` that:
  1. Queries IRRd for each peer's authorized prefixes
  2. Generates the FRR prefix-list configuration
  3. Applies the configuration to the running FRR router via `docker exec ... vtysh`
- The script runs from within AS300's container (or a utility container on Transit's network) and queries IRRd at 10.0.0.4
- This demonstrates the real-world workflow where operators automate filter updates on a cron schedule

---

### Part 7: Building the Containerlab BGP Network (400–500 words)

**Goals:**
- Create the three-AS topology using Containerlab
- Configure basic BGP peering between all three ASes (no filters yet)
- Verify that BGP sessions are established and routes are propagated

**Sections:**

#### 7.1 Containerlab Topology File (`topology.yml`)

- Three `kind: linux` FRR nodes (as100, as200, as300)
- One `kind: linux` IRRd node using the custom `irrd-lab` image built in Part 4
- Four nodes total, all managed by a single `sudo containerlab deploy -t topology.yml` command
- Three point-to-point links: as100–as300, as200–as300, irrd–as300
- `exec:` stanzas for IP address assignment on loopback and interfaces
- `binds:` for the IRRd node: mount `irrd.yaml`, `lab-irr-data.rpsl`, and optionally the entrypoint script
- `binds:` for FRR nodes: mount FRR daemons and config files
- AS300's FRR config includes a `network 10.0.0.4/31` statement (or static route redistribution) so AS100 and AS200 learn routes to the IRRd subnet

#### 7.2 FRR Configuration Files (Base — No Filters)

- AS100: announces 198.51.100.0/24, peers with AS300
- AS200: announces 203.0.113.0/24, peers with AS300
- AS300: peers with both AS100 and AS200, no prefix filters applied

#### 7.3 Deploy and Verify

- `sudo containerlab deploy -t topology.yml` — this single command brings up all six components: three FRR routers plus the IRRd node (which internally runs PostgreSQL, Redis, and IRRd)
- Wait for the IRRd entrypoint script to finish initializing (check with `docker logs clab-...-irrd`)
- Check BGP sessions: `docker exec ... vtysh -c "show bgp summary"`
- Verify routing tables: all three ASes should see all three prefixes
- Verify IRRd reachability from AS100: `docker exec clab-...-as100 bash -c 'echo "AS100" | nc 10.0.0.4 43'`
- This is the **baseline** — no filtering, everything is accepted

---

### Part 8: Applying IRR-Based Prefix Filters (500–600 words)

**Goals:**
- Apply the bgpq4-generated prefix-lists to AS300
- Demonstrate that AS300 now only accepts authorized prefixes from each peer
- This is the payoff: the reader sees IRR data translate into working router filters

**Sections:**

#### 8.1 Applying the Prefix Filters to AS300

- Use `docker exec clab-...-as300 vtysh` to enter the router CLI
- Apply the prefix-lists generated by bgpq4
- Apply route-maps that reference the prefix-lists on each neighbor's inbound session
- Alternatively: bake the filters into the FRR startup config and re-deploy

#### 8.2 Verifying Filtered Operation

- AS300 should accept 198.51.100.0/24 from AS100 (matches AS100-IN list)
- AS300 should accept 203.0.113.0/24 from AS200 (matches AS200-IN list)
- Both peers' own-AS routes are accepted; transit is working normally

---

### Part 9: Testing — The Unauthorized Announcement (400–500 words)

**Goals:**
- Have AS200 attempt to announce AS100's prefix
- Show that AS300's IRR-based filter blocks it
- Contrast with what would happen without the filter

**Sections:**

#### 9.1 Simulating the Hijack

- Enter AS200's vtysh and add `network 198.51.100.0/24` to BGP
- Add a static route to null0 for the prefix (so BGP can announce it)
- Wait for the announcement to propagate

#### 9.2 Observing the Filter in Action

- On AS300: `show bgp ipv4 unicast 198.51.100.0/24`
  - Should show only the path via AS100
  - The announcement from AS200 should be filtered (rejected) because 198.51.100.0/24 is not in AS200-IN
- Check filter counters: `show ip prefix-list AS200-IN` to see the hit count on deny entries
- Show that AS100's legitimate announcement is unaffected

#### 9.3 Comparing With and Without Filters

- Briefly show what would happen if the filter were removed:
  - AS300 would accept the more-specific /24 from AS200 if AS200 announced a more-specific, or would have two paths if AS200 announced the same /24
  - This makes the case for why IRR-based filtering matters

---

### Part 10: Conclusion (200–300 words)

**Goals:**
- Summarize what the reader accomplished
- Explain the limitations of IRR-based filtering (no cryptographic verification, voluntary registration)
- Tease the next post in the series (RPKI validation)

**Key points:**
- IRRd gives you a fully functional Internet Routing Registry that bgpq4 can query — exactly the same software that powers RADB and other production registries
- bgpq4 automates the tedious work of extracting prefix data and converting it to router configuration
- IRR filtering is effective but has limitations: registrations are not cryptographically signed, and some registries allow anyone to register any prefix
- The next post will introduce RPKI, which adds cryptographic proof of prefix ownership on top of IRR data

---

## Technical Research Required

### IRRd Containerization
- [ ] Determine if an official IRRd Docker image exists (seems unlikely based on docs — Docker page returned 404)
- [ ] If not, create an all-in-one Dockerfile that bundles PostgreSQL, Redis, and IRRd into a single container
- [ ] Write entrypoint script that starts PostgreSQL → creates DB + pgcrypto → starts Redis → runs irrd_database_upgrade → optionally loads RPSL data → starts IRRd
- [ ] Test PostgreSQL pgcrypto extension setup inside the all-in-one container
- [ ] Test `irrd_database_upgrade` (schema migration) works inside the container
- [ ] Test `irrd_load_database` for loading RPSL objects from a file
- [ ] Determine minimum viable IRRd configuration for a lab (disable email, RPKI, scope filter, etc.)
- [ ] Confirm memory usage with < 20 RPSL objects (production docs say 32 GB, but that's for full Internet data)
- [ ] Test that the all-in-one container works as a Containerlab `kind: linux` node

### bgpq4
- [ ] Test `bgpq4 -h 10.0.0.4` against the local IRRd instance (from within the routed network)
- [ ] Test `-S LABRIR` source selection flag
- [ ] Test prefix-list generation in FRR format (default Cisco format should work for FRR)
- [ ] Test as-set expansion with `!i` queries
- [ ] Test container image: `docker run --rm ghcr.io/bgp/bgpq4:latest -h 10.0.0.4 -S LABRIR AS100` (from within Transit's network namespace)

### RPSL Object Authoring
- [ ] Create minimal valid `mntner` objects (required for authoritative IRRd sources)
- [ ] Create `aut-num`, `as-set`, and `route` objects with correct RPSL syntax
- [ ] Test loading objects with `irrd_load_database`
- [ ] Test submitting objects via the WHOIS submission interface (as an alternative)

### Containerlab Integration
- [ ] Test the all-in-one IRRd container as a `kind: linux` node in the Containerlab topology
- [ ] Test that the IRRd entrypoint script completes successfully when Containerlab starts the container
- [ ] Test that bgpq4 running from AS300's container can reach IRRd at 10.0.0.4 over the routed link
- [ ] Test that AS100 and AS200 can reach IRRd at 10.0.0.4 via Transit (AS300) after BGP converges
- [ ] Write and test the complete topology file with three FRR nodes plus the IRRd node
- [ ] Write and test FRR configs for the three-AS network

### End-to-End Validation
- [ ] Deploy the full topology with a single `containerlab deploy` command
- [ ] Run bgpq4, generate filters, apply to AS300
- [ ] Simulate hijack attempt from AS200
- [ ] Confirm the filter blocks the unauthorized prefix announcement
- [ ] Document all verification commands and expected output

---

## Key Technical Challenges

### Challenge 1: Running IRRd in a Single Container

IRRd does not publish an official Docker image. The deployment documentation describes a native install with PostgreSQL and Redis dependencies. Since we want a single Containerlab topology (no Docker Compose), we need to bundle everything into one container:
- Create a custom Dockerfile that installs PostgreSQL, Redis, and IRRd from PyPI
- Write an entrypoint script that starts all three services in the correct order
- Handle database migration on first startup
- Ensure the WHOIS port (43) is accessible on the container's network interfaces

**Mitigation:** Use a process-supervisor approach in the entrypoint script: start PostgreSQL, wait for it to be ready, create the database and pgcrypto extension, start Redis, run `irrd_database_upgrade`, then start IRRd in the foreground. This is a common pattern for lab/dev containers that bundle multiple services. The entrypoint script can also auto-load RPSL data on first boot.

### Challenge 2: IRRd Resource Requirements

Production IRRd recommends 32 GB RAM and 150 GB disk. Our lab has fewer than 20 RPSL objects.

**Mitigation:** Test with minimal resources. The 32 GB recommendation is for mirroring the full Internet routing registry. A local authoritative-only instance with a handful of objects should run with < 1 GB RAM. Document the actual resource usage observed during testing.

### Challenge 3: bgpq4 Query Protocol Compatibility

bgpq4 uses IRRd's extended WHOIS query protocol (e.g., `!gas-set`, `!i` inverse queries), not standard WHOIS. The simple Python WHOIS server used in the existing companion post (containerlab-bgp-security.md) will **not** work with bgpq4.

**Mitigation:** This is the primary reason for using the real IRRd software rather than a lightweight stand-in. IRRd version 4.5.0 fully supports bgpq4's query protocol.

### Challenge 4: All-in-One Container Complexity

Bundling PostgreSQL, Redis, and IRRd into a single container is not a Docker best practice (one process per container), but it greatly simplifies the Containerlab topology — one node instead of three, and no need for a separate Docker Compose stack.

**Mitigation:** This is a lab environment, not production. The all-in-one approach is pragmatic: a single `containerlab deploy` brings up the entire lab. The entrypoint script handles service ordering and health checks internally. Document this design choice in the post and note that in production, IRRd, PostgreSQL, and Redis would run as separate services.

---

## Images/Diagrams Needed

1. **Lab topology diagram** — Three-AS network with IRRd server connected to Transit (AS300), showing ISP-A and ISP-B reaching IRRd via routing through Transit
2. **IRR data flow diagram** — Shows: RPSL objects → IRRd → bgpq4 → FRR prefix-list → BGP filtering
3. **Screenshot: bgpq4 output** — Terminal output showing generated prefix-lists
4. **Screenshot: FRR BGP table before and after filtering** — Shows the unauthorized prefix being accepted (before) and rejected (after)
5. **Screenshot: FRR prefix-list counters** — Shows filter hit counts

---

## File Organization

```
Containerlat-BGP-Security/
├── bgp-IRRd-emulation-plan.md          (this plan)
├── bgp-IRRd-emulation.md               (the blog post)
├── containerlab-bgp-plan.md             (plan for full BGP security post)
├── containerlab-bgp-security.md         (full BGP security post)
├── irrd-lab/
│   ├── Dockerfile.irrd                  (all-in-one IRRd + PostgreSQL + Redis image)
│   ├── entrypoint.sh                    (startup script for the IRRd container)
│   ├── irrd.yaml                        (IRRd configuration)
│   ├── lab-irr-data.rpsl                (RPSL objects for the lab)
│   ├── topology.yml                     (Containerlab topology — the single orchestration file)
│   ├── generate-filters.sh              (bgpq4 automation script)
│   ├── configs/
│   │   ├── as100/
│   │   │   ├── daemons
│   │   │   └── frr.conf
│   │   ├── as200/
│   │   │   ├── daemons
│   │   │   └── frr.conf
│   │   └── as300/
│   │       ├── daemons
│   │       └── frr.conf
│   └── Images/
└── Images/
```

---

## External Resources to Link

### Official Documentation
- [IRRd Documentation](https://irrd.readthedocs.io/en/stable/)
- [IRRd GitHub Repository](https://github.com/irrdnet/irrd)
- [bgpq4 GitHub Repository](https://github.com/bgp/bgpq4)
- [RPSL RFC 2622](https://www.rfc-editor.org/rfc/rfc2622)
- [FRR BGP Prefix List Documentation](https://docs.frrouting.org/en/latest/filter.html)
- [Containerlab Documentation](https://containerlab.dev/)

### Tutorials and Guides
- [NLNOG BGP Filter Guide](http://bgpfilterguide.nlnog.net/) — Community guide for building BGP filters
- [NSRC bgpq4 Introduction](https://nsrc.org/workshops/2025/nsrc-ngnog2025-bgp/networking/bgp-deploy/en/presentations/BGPQ4-Introduction.pdf) — Workshop slides on bgpq4
- [MANRS Implementation Guide](https://www.manrs.org/resources/) — Best practices for routing security

### IRR Registries
- [RADB (Merit)](https://www.radb.net/) — One of the most widely used IRR databases
- [NTT IRR Mirror](https://www.gin.ntt.net/support-center/policies-procedures/routing-registry/) — The default server bgpq4 queries (rr.ntt.net)

---

## Estimated Word Count

| Section | Words |
|---------|-------|
| Introduction | 350 |
| Background (IRRd, RPSL, bgpq4) | 550 |
| Lab Architecture | 250 |
| Building the IRRd Container Image | 700 |
| Populating the IRR Database | 450 |
| Using bgpq4 to Generate Filters | 550 |
| Building the Containerlab Network | 450 |
| Applying Prefix Filters | 550 |
| Testing — Unauthorized Announcement | 450 |
| Conclusion | 250 |
| **Total** | **~4550** |

---

## Relationship to Existing Work

### Companion post (`containerlab-bgp-security.md`)

The existing companion post currently uses a lightweight Python WHOIS server (`irr/server.py`) as an IRR stand-in. This does not work with bgpq4 because bgpq4 uses IRRd's extended query protocol, not standard WHOIS text matching.

**After this post is written**, the companion post's IRR section (Part 5.3 "Setting Up the IRR Database") should be updated to either:
- Reference this post for the full IRRd approach, or
- Replace the Python WHOIS server with the IRRd all-in-one container described here

### Kathara BGP hijack lab (`Kathara-new/pakistan-youtube-hijack-lab/`)

The existing Kathara lab demonstrates a BGP hijack without any defense mechanisms. This new post differentiates by introducing the first line of defense (IRR-based filtering) using a real IRR server.

---

## Open Questions

1. **IRRd Docker image**: Does a third-party or community Docker image for IRRd exist, or do we need to build our own? Initial research suggests we need our own.

2. **RPSL mntner objects**: IRRd authoritative sources require `mntner` (maintainer) objects with authentication. For a lab, we need to determine the simplest authentication scheme (likely `md5-pw` with a known password like "lab-password"). Need to test whether `irrd_load_database` bypasses authentication requirements.

3. **bgpq4 source flag**: When bgpq4 queries with `-S LABRIR`, does IRRd need any special configuration to respond correctly? Need to verify that the source name in `irrd.yaml` matches what bgpq4 sends.

4. **IRRd container startup timing**: The all-in-one IRRd container runs PostgreSQL, Redis, and IRRd sequentially via an entrypoint script. Need to test whether the startup time is acceptable and whether Containerlab's health checks or `startup-delay` can accommodate this. Also need to ensure the WHOIS port (43) is ready before attempting bgpq4 queries.

5. **Post length**: The plan targets ~4500 words. Given the all-in-one IRRd container build is somewhat involved, the post might run longer. This is acceptable per the established guidelines ("The post may be as long as needed").

---

## Timeline Estimate

| Task | Time |
|------|------|
| Research IRRd Docker deployment | 3 hours |
| Build and test all-in-one IRRd container image | 3 hours |
| Create and load RPSL objects | 1 hour |
| Test bgpq4 against local IRRd | 1 hour |
| Build and test Containerlab topology | 2 hours |
| Write draft | 5 hours |
| Create diagrams/screenshots | 2 hours |
| Edit and polish | 2 hours |
| **Total** | **~19 hours** |

---

## Success Criteria

- [ ] IRRd starts inside the all-in-one Containerlab node with a working PostgreSQL and Redis backend
- [ ] RPSL objects for all three lab ASes are loaded and queryable via WHOIS
- [ ] bgpq4 successfully queries the local IRRd and generates correct FRR prefix-lists
- [ ] Containerlab topology deploys with three FRR routers and all BGP sessions establish
- [ ] Prefix filters generated by bgpq4 are applied to AS300 and working
- [ ] AS200's unauthorized announcement of 198.51.100.0/24 is blocked by the filter on AS300
- [ ] All commands and configurations in the post are tested and reproducible
- [ ] Post clearly connects to the broader series (teases RPKI in the next post)
