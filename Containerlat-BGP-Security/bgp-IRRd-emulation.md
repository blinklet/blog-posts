Example of how RPSL data is submitted to ARIN
https://www.arin.net/resources/manage/irr/?utm_source=chatgpt.com#submitting-routing-information




# Emulating an IRR Database with IRRd, bgpq4, and Containerlab for BGP Prefix Filter Testing

Even today, Internet service providers (ISPs) make decisions about which BGP routing information to accept from their peers based on trust. 

One of the most important tools they use is the Internet Routing Registry (IRR). It is a public database in which network operators register which IP prefixes they are authorized to announce. ISPs periodically pull information about other operators' prefixes from IRRs and use that information to build filters and access lists that help ensure they accept routes only from the operators authorized to announce those routes. 

Obviously, building filters for thousands of routs requires automation. The standard tool for building these filters is [bgpq4](https://github.com/bgp/bgpq4), a command-line utility that queries IRR servers like [RADB](https://www.radb.net/) and generates router filter configurations automatically. Together, IRR data and bgpq4 form the most widely deployed BGP security mechanism on the Internet today. Yet, most network engineers have never set up an IRR server themselves, and many have never seen how bgpq4 queries translate into working router filters.

In this post, I will show you how to run your own IRR server using [IRRd (Internet Routing Registry Daemon)](https://irrd.readthedocs.io/en/stable/), the same software that powers production registries like RADB, entirely inside a [Containerlab](https://containerlab.dev/) lab environment. I will populate the IRR database with routing policy objects for a small four-AS network, use bgpq4 to generate [FRR](https://frrouting.org/) prefix-list filters from that data, and then demonstrate how those filters prevent a BGP peer from announcing prefixes it does not own.

Running your own IRRd instance means you can experiment freely with real-world BGP scenarios. You can register any prefix, create any AS number, and test filter behavior without touching production infrastructure. Everything runs locally in a network emulator on a single Linux host.

By the end of this post, you will have a fully reproducible lab that demonstrates the complete IRR-based filtering workflow: from registering routing policy objects, to generating filters with bgpq4, to blocking an unauthorized BGP announcement.

## Background: IRR, IRRd, and bgpq4

Before building the lab, it helps to understand the four components we will be working with: the Internet Routing Registry system, the language used to describe routing policy, the server software that hosts the registry, and the tool that turns registry data into router configurations.

### What is an Internet Routing Registry?

An Internet Routing Registry (IRR) is a database in which network operators publish information about their routing policy. The data is expressed in a format called Routing Policy Specification Language, or RPSL, defined in [RFC 2622](https://www.rfc-editor.org/rfc/rfc2622). The most important object types for prefix filtering are:

- **route** objects map an IP prefix to the AS number authorized to originate it. For example, "198.51.100.0/24 is originated by AS100"
- **aut-num** objects  describe an autonomous system and its peering policies
- **as-set** objects group multiple AS numbers together under a single name which lets operators define filters for customers who have their own downstream customers. For example, "AS-ISP-A contains AS100 and AS101"

IRR databases are operated by the five Regional Internet Registries (ARIN, RIPE NCC, APNIC, LACNIC, and AFRINIC) and by independent registries such as [RADB](https://www.radb.net/) and [NTT's registry](https://www.gin.ntt.net/support-center/policies-procedures/routing-registry/). Network operators query one or more registries to learn which prefixes each BGP peer is authorized to announce, and then build prefix filters from that data.

### What is IRRd?

[IRRd (Internet Routing Registry Daemon)](https://irrd.readthedocs.io/en/stable/) is open-source software that implements a full-featured IRR server. It is the same software that runs behind production registries like RADB. IRRd version 4, the current release as of early 2026, is maintained by [Reliably Coded](https://www.reliably.com/) with support from NTT, ARIN, and the open-source community.

IRRd can operate in two modes: as an *authoritative* source that accepts local submissions (this is what we will use), or as a *mirror* that replicates data from other IRR databases. Tools like bgpq4 use the WHOIS protocol, defined by [RFC3912](https://datatracker.ietf.org/doc/html/rfc3912), to retrieve routing policy data from an IRR server. 

For our lab, we will configure IRRd with a single authoritative source named `LABRIR` and load a small set of RPSL objects that represent our four-AS network.

### What is bgpq4?

[bgpq4](https://github.com/bgp/bgpq4) is a command-line tool that queries an IRR server and generates router filter configurations. It supports output formats for many router operating systems such as Cisco IOS, Juniper JunOS, FRR, BIRD, Nokia, Mikrotik, Arista, Huawei, and more. By default, bgpq4 queries NTT's IRR mirror at `rr.ntt.net`, but the `-h` flag lets you point it at any IRR server — including our local IRRd instance.

A typical bgpq4 command looks like this:

```bash
$ bgpq4 -h 142.248.64.2 -S LABRIR -l AS100-IN AS100
```

This tells bgpq4 to connect to the IRR server at `142.248.64.2`, query the `LABRIR` source, find all prefixes that AS100 is authorized to originate, and output an FRR-compatible prefix-list named `AS100-IN`. The result is a set of `ip prefix-list` statements that you can paste directly into an FRR router's configuration.

### How the pieces fit together

The workflow mirrors what real-world network operators do every day:

1. Network operators register their prefixes in an IRR by creating *route* objects, which are then stored and served by IRRd.
2. A neighboring operator runs *bgpq4* to query the IRR and generate prefix-list filters for each BGP peer
3. The operator applies those filters to the *FRR* (or other) router, which then only accepts route announcements that match the registered data

The only difference in our lab is that all three components — the IRR server, the filter generation tool, and the routers — run locally inside containers managed by the Containerlab network emulator.

## Lab Architecture

The lab uses four autonomous systems connected in a hub-and-spoke topology, with Transit providers (AS300 and AS400) at the center and two ISPs (AS100 and AS200) as peers. An IRRd server is attached to AS400's network, just as a real IRR server like RADB would be reachable over the Internet.

```
      ┌─────────┐    ┌───────────┐    ┌───────────┐    ┌─────────┐
      │  ISP-A  ├────┤ Transit-1 ├────┤ Transit-2 ├────┤  ISP-B  │
      │  AS100  │    │   AS300   │    │   AS400   │    │  AS200  │
      └─────────┘    └─────┬─────┘    └─────┬─────┘    └─────────┘
                           │                │        
                      ┌────┴────┐      ┌────┴────┐
                      │  bgpq4  │      │  IRRd   │
                      │(utility)│      │(utility)│
                      └─────────┘      └─────────┘
```

ISP-A and ISP-B reach the IRRd server by routing through Transit — the same way real-world operators reach public IRR servers over the Internet.

Three ASes is the minimum needed to demonstrate transit filtering: a transit provider that applies prefix filters on inbound sessions from two peers.

### Nodes

The lab completely self-contained so you may use any IP addressing scheme you wish. In the example below, I am using some prefixes assigned in the ARIN region. 

| Node | AS | Role | Announced Prefixes |
|------|----|------|--------------------|
| ISP-A | AS100 | Peer | 130.12.16.0/20 |
| ISP-B | AS200 | Peer | 131.143.32.0/20 |
| Transit-1 | AS300 | Transit provider | 142.248.48.0/20 |
| Transit-2 | AS400 | Transit provider | 142.248.64.0/20 |
| IRRd | — | IRR database server | — |
| bgpq4 | — | Utility container running bgpq4 | — |

When possible, I still like to use the [RFC1918](https://datatracker.ietf.org/doc/html/rfc1918) and [RFC5737](https://datatracker.ietf.org/doc/html/rfc5737) address spaces (private and documentation IP addresses). But, in this case, I chose to use assigned address space because

### Interconnect Addressing

Each link uses a /31 point-to-point subnet from the 10.0.0.0/24 range:

| Link | Endpoint A | Address | Endpoint B | Address |
|------|-----------|---------|-----------|---------|
| ISP-A – Transit-1 | as100 eth1 | 10.0.0.0/31 | as300 eth1 | 10.0.0.1/31 |
| ISP-B – Transit-2 | as200 eth1 | 10.0.0.2/31 | as400 eth1 | 10.0.0.3/31 |
| Transit-1 – Transit-2 | as300 eth2 | 10.0.0.4/31 | as400 eth2 | 10.0.0.5/31 |


### IP addressing

Specific addressable nodes use IP addresses from the IP address range of their AS's advertised prefix:

| Link | Endpoint A | Address | Endpoint B | Address |
|------|-----------|---------|-----------|---------|
| IRRd – Transit-2  | irrd eth1  | 142.248.64.2/24 | as400 eth3 | 142.248.64.3/24 |
| bgpq4 – Transit-1 | bgpq4 eth1 | 142.248.48.2/24 | as300 eth3 | 142.248.48.3/24 |
| ISP-A network | loopback | 130.12.16.100/24 | — | — |
| ISP-B network | loopback | 130.12.32.100/24 | — | — |


### Container images

#### IRRd Container

IRRd does not publish an official Docker image. So, I created an IRRd image and published it to Docker Hub. The image is [blinklet/irrd-lab](https://hub.docker.com/r/blinklet/irrd-lab)

The IRRd-lab image runs PostgreSQL, Redis, and IRRd together in a single "all-in-one" container. Bundling multiple services into one container is not the recommended Docker pattern for production, but it is pragmatic for a lab. It keeps the Containerlab topology file simple (one node instead of three) and lets a single `containerlab deploy` command bring up the entire environment. In production, IRRd, PostgreSQL, and Redis would each run in separate containers.

See my previous post about [building an IRRd container](https://brianlinkletter.com/2026/03/building-irrd-and-bgpq4-docker-containers-for-network-labs/) for more information about the IRRd container setup and configuration.

#### bgpq4 Container

Similarly, I built and published a bgpq4 container image to Dicker Hub. The bgpq4 image is [blinklet/bgpq4-utils](https://hub.docker.com/r/blinklet/bgpq4-utils).

The bgpq4 utility container is a lightweight Debian container with the `bgpq4` package installed, and some other network tools. It can serve as a "network management workstation" for AS300 in this scenario.

#### FRR Container

The routers in this network lab will run the Free Range Routing (FRR) image. The official FRR container images are at [https://quay.io/repository/frrouting](https://quay.io/repository/frrouting). In this scenario, we'll use the image tagged *10.6.0*.












## Building the Containerlab BGP Network

Now we can now assemble everything into a single Containerlab topology. Once the Contaonerlab topology file is created, one command will bring up four FRR routers, the IRRd server, and the bgpq4 utility container, establishing a working BGP network that we can then protect with prefix filters generated from data in the IRRd server.

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
      image: quay.io/frrouting/frr:10.6.0
      binds:
        - configs/as100/daemons:/etc/frr/daemons
        - configs/as100/frr.conf:/etc/frr/frr.conf
      exec:
        - ip addr add 130.12.16.100/24 dev lo
        - ip addr add 10.0.0.0/31 dev eth1

    # ── ISP-B (AS200) — Peer / will attempt hijack ───────
    as200:
      kind: linux
      image: quay.io/frrouting/frr:10.6.0
      binds:
        - configs/as200/daemons:/etc/frr/daemons
        - configs/as200/frr.conf:/etc/frr/frr.conf
      exec:
        - ip addr add 131.143.32.100/24 dev lo
        - ip addr add 10.0.0.2/31 dev eth1

    # ── Transit-1 (AS300) — Applies IRR-based filters ─────
    as300:
      kind: linux
      image: quay.io/frrouting/frr:10.6.0
      binds:
        - configs/as300/daemons:/etc/frr/daemons
        - configs/as300/frr.conf:/etc/frr/frr.conf
      exec:
        - ip addr add 142.248.48.100/20 dev lo
        - ip addr add 10.0.0.1/31 dev eth1
        - ip addr add 10.0.0.4/31 dev eth2
        - ip addr add 142.248.48.1/24 dev eth3

    # ── Transit-2 (AS400) ──────────────────────────────────
    as400:
      kind: linux
      image: quay.io/frrouting/frr:10.6.0
      binds:
        - configs/as400/daemons:/etc/frr/daemons
        - configs/as400/frr.conf:/etc/frr/frr.conf
      exec:
        - ip addr add 142.248.64.100/20 dev lo
        - ip addr add 10.0.0.3/31 dev eth1
        - ip addr add 10.0.0.5/31 dev eth2
        - ip addr add 142.248.64.3/24 dev eth3

    # ── IRRd server (PostgreSQL + Redis + IRRd) ───────────
    irrd:
      kind: linux
      image: irrd-lab
      exec:
        - ip addr add 142.248.64.2/24 dev eth1
        - ip route add default via 142.248.64.3

    # ── bgpq4 utility container ──────────────────────────
    bgpq4:
      kind: linux
      image: bgpq4-utils
      exec:
        - ip addr add 142.248.48.2/24 dev eth1
        - ip route add default via 142.248.48.3

  links:
    # AS100 (ISP-A) ↔ AS300 (Transit-1)
    - endpoints: ["as100:eth1", "as300:eth1"]
    # AS200 (ISP-B) ↔ AS400 (Transit-2)
    - endpoints: ["as200:eth1", "as400:eth1"]
    # AS300 (Transit-1) ↔ AS400 (Transit-2)
    - endpoints: ["as300:eth2", "as400:eth2"]
    # IRRd ↔ AS400 (Transit-2)
    - endpoints: ["irrd:eth1", "as400:eth3"]
    # bgpq4 ↔ AS300 (Transit-1)
    - endpoints: ["bgpq4:eth1", "as300:eth3"]
```

A few things to note in this topology:

- The four FRR nodes use the official `quay.io/frrouting/frr:10.6.0` image. The `binds:` stanzas inject the *daemons* and *frr.conf* files directly into each container at startup.
- The `exec:` stanzas assign IP addresses to the loopback and point-to-point interfaces. FRR's *zebra* daemon picks up these addresses from the Linux kernel and makes them available for BGP to announce.
- The **IRRd node** uses our custom `irrd-lab` image. A single default route via AS400 (142.248.64.3) gives IRRd full reachability to all other nodes through AS400's BGP routing table.
- The **bgpq4 node** uses the `bgpq4-utils` image. It has a single point-to-point link to AS300 (eth3) and a default route pointing to AS300 at 142.248.48.1. AS300 and AS400 carry reachability to the IRRd subnet (142.248.64.0/20) in their BGP tables, so bgpq4 can reach IRRd at 142.248.64.2 by routing through AS300 and then AS400.
- AS300 (Transit-1) has **three** interfaces: eth1 to AS100, eth2 to AS400, and eth3 to the bgpq4 utility container.
- AS400 (Transit-2) has **three** interfaces: eth1 to AS200, eth2 to AS300, and eth3 to the IRRd server.

### FRR Configuration Files

Each FRR router needs two files: a *daemons* file that tells FRR which protocol daemons to start, and a *frr.conf* file with the routing configuration.

#### Daemons File

The *daemons* file is identical for all four routers. Create it in each router's configuration subdirectory:

```
bgpd=yes
zebra=yes
```

Only *bgpd* (for BGP) and *zebra* (for the kernel interface) are needed.

#### AS100 — ISP-A (Legitimate Prefix Holder)

AS100 announces 130.12.16.0/20 and peers with Transit-1 (AS300). Create *irrd-lab/configs/as100/frr.conf*:

```
frr version 10.5
frr defaults traditional
hostname as100
!
ip route 130.12.16.0/20 Null0
!
router bgp 100
 bgp router-id 130.12.16.100
 !
 neighbor 10.0.0.1 remote-as 300
 neighbor 10.0.0.1 description transit-AS300
 !
 address-family ipv4 unicast
  network 130.12.16.0/20
  neighbor 10.0.0.1 activate
 exit-address-family
!
```

The `ip route 130.12.16.0/20 Null0` creates a blackhole static route so that BGP's `network` statement can find the prefix in the routing table. The loopback address 130.12.16.100 is assigned in the topology file's `exec:` stanza.

#### AS200 — ISP-B (Peer / Future Attacker)

AS200's baseline configuration only announces its own legitimate prefix, 131.143.32.0/20. Later, in the testing section, we will add an unauthorized announcement. AS200 peers with Transit-2 (AS400) via 10.0.0.3. Create *irrd-lab/configs/as200/frr.conf*:

```
frr version 10.5
frr defaults traditional
hostname as200
!
ip route 131.143.32.0/20 Null0
!
router bgp 200
 bgp router-id 131.143.32.100
 !
 neighbor 10.0.0.3 remote-as 400
 neighbor 10.0.0.3 description transit-AS400
 !
 address-family ipv4 unicast
  network 131.143.32.0/20
  neighbor 10.0.0.3 activate
 exit-address-family
```

#### AS300 — Transit-1

AS300 (Transit-1) peers with AS100 to the west and AS400 (Transit-2) to the east. In this base configuration, it accepts all announcements with no prefix filtering — this is the unprotected baseline. AS300 announces its own 142.248.48.0/20 block, which covers the bgpq4 utility subnet (142.248.48.0/24). Create *irrd-lab/configs/as300/frr.conf*:

```
frr version 10.5
frr defaults traditional
hostname as300
!
ip route 142.248.48.0/20 Null0
!
router bgp 300
 bgp router-id 142.248.48.100
 !
 neighbor 10.0.0.0 remote-as 100
 neighbor 10.0.0.0 description peer-AS100
 neighbor 10.0.0.5 remote-as 400
 neighbor 10.0.0.5 description peer-AS400
 !
 address-family ipv4 unicast
  network 142.248.48.0/20
  neighbor 10.0.0.0 activate
  neighbor 10.0.0.5 activate
 exit-address-family
!
```

#### AS400 — Transit-2

AS400 (Transit-2) peers with AS200 to the east and AS300 (Transit-1) to the west. The IRRd server is connected directly to AS400's eth3 interface at 142.248.64.2. AS400 announces its own 142.248.64.0/20 block, which covers the IRRd subnet (142.248.64.0/24), making IRRd reachable from anywhere in the lab via BGP. Create *irrd-lab/configs/as400/frr.conf*:

```
frr version 10.5
frr defaults traditional
hostname as400
!
ip route 142.248.64.0/20 Null0
!
router bgp 400
 bgp router-id 142.248.64.100
 !
 neighbor 10.0.0.2 remote-as 200
 neighbor 10.0.0.2 description peer-AS200
 neighbor 10.0.0.4 remote-as 300
 neighbor 10.0.0.4 description peer-AS300
 !
 address-family ipv4 unicast
  network 142.248.64.0/20
  neighbor 10.0.0.2 activate
  neighbor 10.0.0.4 activate
 exit-address-family
!
```

### Deploy and Verify

With all files in place, the *irrd-lab/* directory should look like this:

```
irrd-lab/
├── Dockerfile.irrd
├── Dockerfile.bgpq4
├── entrypoint.sh
├── irrd.yaml
├── lab-irr-base.rpsl
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
    ├── as300/
    │   ├── daemons
    │   └── frr.conf
    └── as400/
        ├── daemons
        └── frr.conf
```

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

This brings up all six containers: four FRR routers, the IRRd server, and the bgpq4 utility container. The IRRd container needs 15–30 seconds to start PostgreSQL, run migrations, load the RPSL data, and start the WHOIS server. Wait for initialization to complete:

```bash
$ docker logs -f clab-bgplab-irrd 2>&1 | grep -m1 "IRRd Lab Container Ready"
```

Once IRRd is ready, verify that BGP sessions are established on both transit routers:

```bash
$ docker exec clab-bgplab-as300 vtysh -c "show bgp summary"
```

```bash
$ docker exec clab-bgplab-as400 vtysh -c "show bgp summary"
```

AS300 should show two established BGP peers (AS100 and AS400). AS400 should show two established BGP peers (AS200 and AS300). Verify the full routing table on AS300:

```bash
$ docker exec clab-bgplab-as300 vtysh -c "show ip bgp"
```

Expected output should include four prefixes: 130.12.16.0/20 (from AS100), 131.143.32.0/20 (relayed from AS200 via AS400), 142.248.48.0/20 (locally originated by AS300), and 142.248.64.0/20 (from AS400).

Verify that the dedicated query node can reach the IRRd server through AS300:

```bash
$ docker exec clab-bgplab-bgpq4 sh -lc 'echo "AS100" | nc 142.248.64.2 43'
```

This confirms end-to-end connectivity: the bgpq4 utility container routes to the IRRd server (142.248.64.2) through AS300 and AS400, and IRRd responds over WHOIS.

This is the **baseline** state — all BGP announcements are accepted without filtering. AS300 and AS400 trust whatever their peers announce. In the next section, we will apply the IRR-based prefix filters generated by bgpq4 to restrict what each transit router accepts from its peers.

## Applying IRR-Based Prefix Filters

Now for the payoff: we will use bgpq4 to query our IRRd server, generate prefix-lists, and apply them to AS300 and AS400. This is the step where IRR data translates into working router filters that control which BGP announcements each transit router accepts from its directly connected peers.

### Generating and Applying the Filters

You can apply the filters manually or use the automation script we created earlier. Let's walk through the manual process first so you can see exactly what happens at each step.

Generate the prefix-list for AS100 by querying the IRRd server from the bgpq4 utility container:

```bash
$ docker exec clab-bgplab-bgpq4 bgpq4 -h 142.248.64.2 -S LABRIR -l AS100-IN AS-ISP-A
```

```
no ip prefix-list AS100-IN
ip prefix-list AS100-IN permit 130.12.16.0/20
```

Generate the prefix-list for AS200:

```bash
$ docker exec clab-bgplab-bgpq4 bgpq4 -h 142.248.64.2 -S LABRIR -l AS200-IN AS-ISP-B
```

```
no ip prefix-list AS200-IN
ip prefix-list AS200-IN permit 131.143.32.0/20
```

Now apply the AS100-IN prefix-list to AS300, where AS100 is directly connected. Enter AS300's vtysh and configure:

```bash
$ docker exec -it clab-bgplab-as300 vtysh
```

```
as300# configure terminal
as300(config)# no ip prefix-list AS100-IN
as300(config)# ip prefix-list AS100-IN permit 130.12.16.0/20
as300(config)#
as300(config)# route-map AS100-IN permit 10
as300(config-route-map)# match ip address prefix-list AS100-IN
as300(config-route-map)# exit
as300(config)# route-map AS100-IN deny 20
as300(config-route-map)# exit
as300(config)#
as300(config)# router bgp 300
as300(config-router)# address-family ipv4 unicast
as300(config-router-af)# neighbor 10.0.0.0 route-map AS100-IN in
as300(config-router-af)# end
as300#
as300# clear bgp ipv4 unicast * soft in
```

Then apply the AS200-IN prefix-list to AS400, where AS200 is directly connected. Enter AS400's vtysh and configure:

```bash
$ docker exec -it clab-bgplab-as400 vtysh
```

```
as400# configure terminal
as400(config)# no ip prefix-list AS200-IN
as400(config)# ip prefix-list AS200-IN permit 131.143.32.0/20
as400(config)#
as400(config)# route-map AS200-IN permit 10
as400(config-route-map)# match ip address prefix-list AS200-IN
as400(config-route-map)# exit
as400(config)# route-map AS200-IN deny 20
as400(config-route-map)# exit
as400(config)#
as400(config)# router bgp 400
as400(config-router)# address-family ipv4 unicast
as400(config-router-af)# neighbor 10.0.0.2 route-map AS200-IN in
as400(config-router-af)# end
as400#
as400# clear bgp ipv4 unicast * soft in
```

The configuration has three layers:

1. **Prefix-lists** define which prefixes are allowed — AS100-IN permits only 130.12.16.0/20, AS200-IN permits only 131.143.32.0/20
2. **Route-maps** reference the prefix-lists — sequence 10 permits matching prefixes, sequence 20 denies everything else
3. **BGP neighbor configuration** applies the route-maps on each peer's inbound session — AS300 filters what it accepts from AS100 (via 10.0.0.0), and AS400 filters what it accepts from AS200 (via 10.0.0.2)

Alternatively, you can skip the manual steps and run the automation script from Part 6, which applies filters to both transit routers:

```bash
$ ./generate-filters.sh
```

### Verifying Filtered Operation

Check that AS300's BGP table contains the expected routes:

```bash
$ docker exec clab-bgplab-as300 vtysh -c "show ip bgp"
```

You should see:

- **130.12.16.0/20** from AS100 — accepted (matches AS100-IN prefix-list)
- **131.143.32.0/20** from AS400 — accepted (AS400 filtered it from AS200 and propagated it to AS300)
- **142.248.48.0/20** locally originated by AS300
- **142.248.64.0/20** from AS400

All four prefixes are present because each peer is announcing only its own authorized prefix. The filters are in place but have not blocked anything yet — the network is operating normally.

Verify the prefix-list on AS300 is installed:

```bash
$ docker exec clab-bgplab-as300 vtysh -c "show ip prefix-list"
```

Expected output:

```
ip prefix-list AS100-IN: 1 entries
   seq 5 permit 130.12.16.0/20
```

Verify the prefix-list on AS400 is installed:

```bash
$ docker exec clab-bgplab-as400 vtysh -c "show ip prefix-list"
```

Expected output:

```
ip prefix-list AS200-IN: 1 entries
   seq 5 permit 131.143.32.0/20
```

You can also confirm the route-maps are applied to the correct neighbors:

```bash
$ docker exec clab-bgplab-as300 vtysh -c "show ip bgp neighbors 10.0.0.0" | grep "route-map"
```

```
  Route map for incoming advertisements is *AS100-IN
```

```bash
$ docker exec clab-bgplab-as400 vtysh -c "show ip bgp neighbors 10.0.0.2" | grep "route-map"
```

```
  Route map for incoming advertisements is *AS200-IN
```

The filters are active. AS300 will now reject any prefix from AS100 that is not 130.12.16.0/20, and AS400 will reject any prefix from AS200 that is not 131.143.32.0/20. In the next section, we will test this by having AS200 attempt to announce a prefix it does not own.

## Testing — The Unauthorized Announcement

With the filters in place, we can now simulate a BGP prefix hijack and see the IRR-based filter block it. AS200 (ISP-B) will attempt to announce 130.12.16.0/20 — a prefix that belongs to AS100 and is not registered to AS200 in the IRR.

### Simulating the Hijack

Enter AS200's router CLI and add the unauthorized prefix announcement:

```bash
$ docker exec -it clab-bgplab-as200 vtysh
```

```
as200# configure terminal
as200(config)# ip route 130.12.16.0/20 Null0
as200(config)# router bgp 200
as200(config-router)# address-family ipv4 unicast
as200(config-router-af)# network 130.12.16.0/20
as200(config-router-af)# end
as200#
```

The `ip route 130.12.16.0/20 Null0` creates a blackhole static route so that BGP's `network` statement can find the prefix in the routing table. Without this route, BGP would not announce it. AS200 is now advertising two prefixes: its own legitimate 131.143.32.0/20 and the stolen 130.12.16.0/20.

Verify that AS200 is indeed announcing both prefixes:

```bash
$ docker exec clab-bgplab-as200 vtysh -c "show ip bgp"
```

You should see both 131.143.32.0/20 and 130.12.16.0/20 listed with a status of `*>` (valid, best path, selected). AS200 believes it is announcing both prefixes to AS400.

### Observing the Filter in Action

Now check AS400's BGP table to see what it actually accepted from AS200:

```bash
$ docker exec clab-bgplab-as400 vtysh -c "show ip bgp 130.12.16.0/20"
```

Expected output:

```
BGP routing table entry for 130.12.16.0/20, version X
Paths: (1 available, best #1, table default)
  Advertised to non peer-group peers:
  10.0.0.2
  300 100
    10.0.0.4 from 10.0.0.4 (142.248.48.100)
      Origin IGP, metric 0, valid, external, best (First path received)
      Last update: ...
```

Only **one path** is shown — the legitimate route learned from AS300 (via 10.0.0.4), which itself learned it from AS100. The announcement from AS200 (via 10.0.0.2) was filtered and rejected because 130.12.16.0/20 is not in the AS200-IN prefix-list. The filter worked exactly as designed.

Check the prefix-list counters on AS400 to confirm the filter matched and denied the unauthorized announcement:

```bash
$ docker exec clab-bgplab-as400 vtysh -c "show ip prefix-list AS200-IN"
```

Expected output:

```
ip prefix-list AS200-IN: 1 entries
   seq 5 permit 131.143.32.0/20 (hit count: 1)
```

The permit entry shows a hit count for AS200's legitimate prefix. The unauthorized 130.12.16.0/20 did not match any permit entry and was denied by the implicit `deny any` at the end of the prefix-list.

Verify that AS200's legitimate announcement is completely unaffected:

```bash
$ docker exec clab-bgplab-as400 vtysh -c "show ip bgp 131.143.32.0/20"
```

AS200's own legitimate prefix (131.143.32.0/20) is still accepted — the filter only blocked the unauthorized announcement.

### What Happens Without Filters

To understand why IRR-based filtering matters, consider what would happen if AS400 had no prefix filter on its AS200 session. Temporarily remove the route-map from AS200's inbound session on AS400:

```bash
$ docker exec clab-bgplab-as400 vtysh -c "
configure terminal
router bgp 400
 address-family ipv4 unicast
  no neighbor 10.0.0.2 route-map AS200-IN in
end
clear bgp ipv4 unicast * soft in
"
```

Now check the BGP table for 130.12.16.0/20 on AS400:

```bash
$ docker exec clab-bgplab-as400 vtysh -c "show ip bgp 130.12.16.0/20"
```

Without the filter, AS400 now has **two paths** to 130.12.16.0/20: one from AS300 (the legitimate path, learned from AS100) and one from AS200 (the hijacker). BGP's best-path selection will choose one of them — and depending on tie-breaking rules, it might prefer AS200's path since it has a shorter AS path length ("200" vs "300 100"). This is exactly how real-world prefix hijacks work: the hijacker's announcement competes with the legitimate one, and some routers on the Internet may prefer the hijacked path.

Restore the filter to re-secure the network:

```bash
$ docker exec clab-bgplab-as400 vtysh -c "
configure terminal
router bgp 400
 address-family ipv4 unicast
  neighbor 10.0.0.2 route-map AS200-IN in
end
clear bgp ipv4 unicast * soft in
"
```

The unauthorized route from AS200 is once again filtered. This demonstrates the value of IRR-based prefix filtering: it is a simple, effective first line of defense against prefix hijacks. Without it, any BGP peer could announce any prefix and potentially divert traffic away from the legitimate owner.

## Conclusion

In this post, we built a complete IRR-based prefix filtering lab from scratch. We packaged IRRd — the same software that powers production registries like RADB — into a single all-in-one container with PostgreSQL and Redis, populated it with RPSL objects describing four autonomous systems, used bgpq4 to query the registry and generate FRR prefix-list configurations, and deployed a four-AS Containerlab topology that demonstrates how those filters block an unauthorized prefix announcement.

The key takeaway is that IRR-based filtering is straightforward to implement and effective at preventing basic prefix hijacks. The workflow is the same whether you are running a lab or operating a real network: register your prefixes in an IRR, query the registry with bgpq4, and apply the resulting filters to your BGP sessions. Automating this with a script (as we did with *generate-filters.sh*) ensures your filters stay current as the registry is updated.

However, IRR-based filtering has important limitations. IRR registrations are not cryptographically signed — anyone can register a route object claiming to originate any prefix, and some registries do not verify ownership. This means a determined attacker could register fraudulent objects in a permissive registry and bypass IRR-based filters entirely. There is no mathematical proof that the entity registering a prefix actually controls it.

This is where RPKI (Resource Public Key Infrastructure) comes in. RPKI adds cryptographic proof of prefix ownership through Route Origin Authorizations (ROAs) signed by the resource holders themselves, using certificates issued by the Regional Internet Registries. In the next post in this series, I will add an RPKI validator (Routinator) to our Containerlab topology and show how RPKI validation catches hijacks that bypass IRR filters — providing a stronger, cryptographically grounded layer of BGP security on top of the IRR filtering we built here.

## Clean Up

When you are finished experimenting, tear down the lab:

```bash
$ sudo containerlab destroy -t topology.yml
```

This removes all containers and network links created by Containerlab. The Docker image (`irrd-lab`) remains cached locally for future use.

## Additional Resources

- [IRRd Documentation](https://irrd.readthedocs.io/en/stable/) — Full reference for IRRd configuration and operation
- [bgpq4 GitHub Repository](https://github.com/bgp/bgpq4) — Source code, documentation, and examples
- [RPSL RFC 2622](https://www.rfc-editor.org/rfc/rfc2622) — The Routing Policy Specification Language standard
- [NLNOG BGP Filter Guide](http://bgpfilterguide.nlnog.net/) — Community guide for building BGP filters using IRR data
- [MANRS Implementation Guide](https://www.manrs.org/resources/) — Best practices for routing security, including IRR registration and prefix filtering
- [Containerlab Documentation](https://containerlab.dev/) — Containerlab installation, topology file reference, and examples




