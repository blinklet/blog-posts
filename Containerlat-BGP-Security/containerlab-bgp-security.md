# Using Containerlab to Demonstrate BGP Security Using RPKI and RIR Databases

In this post, I will show you how to use [Containerlab](https://containerlab.dev/) to build a realistic lab environment consisting of a multi-AS topology with routers running the [Free Range Routing (FRR)](https://frrouting.org/) stack. I will use this emulated network to experiment with BGP security mechanisms. 

I last reviewed Containerlab five years ago in 2021, and it has evolved significantly since then. This post will also highlight the features that make Containerlab an excellent choice for building BGP security labs.

This post will show how to:

- Set up a multi-AS topology with routers running the [Free Range Routing (FRR)](https://frrouting.org/) stack
- Emulate an RIR database to support our network scenario and use RIR database information for prefix filtering
- Deploy an RPKI validator using [Routinator](https://github.com/NLnetLabs/routinator) to provide route origin validation
- Simulate a BGP hijack attack and observe how prefix filtering can mitigate it, and how RPKI blocks it

<!--more-->

### Containerlab

[Containerlab](https://containerlab.dev) is an open-source, container-based network emulation platform that lets you build, run, and tear down realistic network topologies using simple, declarative YAML files. It uses lightweight containers and Linux networking to interconnect routers, switches, hosts, and tools into reproducible labs that behave like real networks. It also supports containerized virtual machines, so it can use many commercial router images.

Containerlab supports a wide range of vendor and open-source network operating systems, integrates cleanly with automation tools (such as Ansible, Nornir, and CI/CD pipelines), and emphasizes “lab-as-code” workflows. It well suited for learning, testing configurations, validating designs, and demonstrating complex scenarios like BGP, EVPN, or data-center fabrics on a single workstation or server. 

When I first [reviewed Containerlab in 2021](https://opensourcenetworksimulators.com/2021/05/use-containerlab-to-emulate-open-source-routers/), it was a promising but relatively new project. It's developers were actively working to add more commercial routers to its library of supported devices. Five years later, [Containerlab](https://containerlab.dev) has matured into a developer-friendly network emulation platform that fully supports many readily-available router software images. 

For open-source routers, Containerlab continues to support the `kind: linux` node type, which enables users to create their own containers that support open-source routers like [FRR](https://frrouting.org/), [BIRD](https://bird.network.cz/), [GoBGP](https://osrg.github.io/gobgp/), and [OpenBGPD](https://www.openbgpd.org/). This is the same as it was five years ago.

Before we build the full BGP security lab, Install Containerlab and test it by launching launch one of the demo topologies. 

#### Containerlab Prerequisites

To install Containerlab, on a Linux host (bare metal, VM, or WSL2) ensure you have at least 4 cores or vCPUs, and 8 GB RAM.

Then, check that Docker is installed and running:

```
$ sudo systemctl is-active docker
```

You should see the following output:

```
active
```

#### Install Containerlab

The Containerlab project offers [multiple install methods](https://containerlab.dev/install/). I chose to install it from a package:

```
$ echo "deb [trusted=yes] https://netdevops.fury.site/apt/ /" | \
  sudo tee -a /etc/apt/sources.list.d/netdevops.list
$ sudo apt update
$ sudo apt install containerlab
```

After the installer finishes, add your user ID to the _clab\_admins_ group.

```
$ sudo usermod -aG clab_admins blinklet
$ newgrp clab_admins
```

Then, check the version to ensure the binary is on your path:

```
$ containerlab version
```

You should see the following output:

```
  ____ ___  _   _ _____  _    ___ _   _ _____ ____  _       _     
 / ___/ _ \| \ | |_   _|/ \  |_ _| \ | | ____|  _ \| | __ _| |__  
| |  | | | |  \| | | | / _ \  | ||  \| |  _| | |_) | |/ _` | '_ \ 
| |__| |_| | |\  | | |/ ___ \ | || |\  | |___|  _ <| | (_| | |_) |
 \____\___/|_| \_| |_/_/   \_\___|_| \_|_____|_| \_\_|\__,_|_.__/ 

    version: 0.73.0
     commit: 611350001
       date: 2026-02-08T13:22:45Z
     source: https://github.com/srl-labs/containerlab
 rel. notes: https://containerlab.dev/rn/0.73/
```

#### Deploy a sample lab to validate the setup

The Containerlab team maintains a repository of ready-made lab scenarios. Start with a small FRR lab because it exercises Docker networking, link creation, and teardown.

When you installed Containerlab, it copied the lab example files to the directory, _/etc/containerlab/lab-examples/_. We want to run the [*frr01* lab](https://containerlab.dev/lab-examples/frr01/).

```
$ cd /etc/containerlab/lab-examples/frr01
$ containerlab deploy
```

You will see output indicating that containers are being created, links created, and configurations implemented. Finally, you should see a summary of the lab, as shown below:

```
╭────────────────────┬─────────────────────────────────┬─────────┬───────────────────╮
│        Name        │            Kind/Image           │  State  │   IPv4/6 Address  │
├────────────────────┼─────────────────────────────────┼─────────┼───────────────────┤
│ clab-frr01-PC1     │ linux                           │ running │ 172.20.20.5       │
│                    │ wbitt/network-multitool:latest  │         │ 3fff:172:20:20::5 │
├────────────────────┼─────────────────────────────────┼─────────┼───────────────────┤
│ clab-frr01-PC2     │ linux                           │ running │ 172.20.20.6       │
│                    │ wbitt/network-multitool:latest  │         │ 3fff:172:20:20::6 │
├────────────────────┼─────────────────────────────────┼─────────┼───────────────────┤
│ clab-frr01-PC3     │ linux                           │ running │ 172.20.20.4       │
│                    │ wbitt/network-multitool:latest  │         │ 3fff:172:20:20::4 │
├────────────────────┼─────────────────────────────────┼─────────┼───────────────────┤
│ clab-frr01-router1 │ linux                           │ running │ 172.20.20.3       │
│                    │ quay.io/frrouting/frr:master    │         │ 3fff:172:20:20::3 │
├────────────────────┼─────────────────────────────────┼─────────┼───────────────────┤
│ clab-frr01-router2 │ linux                           │ running │ 172.20.20.2       │
│                    │ quay.io/frrouting/frr:master    │         │ 3fff:172:20:20::2 │
├────────────────────┼─────────────────────────────────┼─────────┼───────────────────┤
│ clab-frr01-router3 │ linux                           │ running │ 172.20.20.7       │
│                    │ quay.io/frrouting/frr:master    │         │ 3fff:172:20:20::7 │
╰────────────────────┴─────────────────────────────────┴─────────┴───────────────────╯
```

The FRR routers are arranged in a triangle and each one has a "PC" attached to it. If the lab is working correctly, each PC should be able to ping the other.

To test that the lab works, run a ping command from the PC1 container. 

```
$ docker exec clab-frr01-PC1 ping -c 1 172.20.20.4
```

**NOTE:** We use the *docker exec* command because Containerlab's SSH functionality does not work with either the _frrouting/frr_ image or the _wbitt/network-multitool_ image. Both those containers are based on Alpine Linux and do not have an SSH server installed. 

You should see the following output:

```
PING 172.20.20.4 (172.20.20.4) 56(84) bytes of data.
64 bytes from 172.20.20.4: icmp_seq=1 ttl=64 time=0.124 ms

--- 172.20.20.4 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.124/0.124/0.124/0.000 ms
```

We see that the ping test works. You can do more tests to verify that containerlab is working. See [my previous post about using open-source routers in Containerlab](https://www.brianlinkletter.com/2021/05/use-containerlab-to-emulate-open-source-routers/) for more details.


When you are done, tear the lab down so the bridge interfaces and containers are removed:

```
$ containerlab destroy
```

At this point we have confirmed that Containerlab, Docker networking, and your user permissions are working. We can now focus on building the BGP network topology.


### BGP Security: The Problem and the Solutions

Before building our lab, let's understand the security challenges that BGP faces and the mechanisms designed to address them.

#### The BGP Trust Model Problem

BGP was designed in an era when the Internet was a small research network where all participants knew and trusted each other. The protocol has no built-in mechanism for verifying that an Autonomous System (AS) is actually authorized to announce a particular IP prefix. When a router receives a BGP announcement, it simply trusts that the information is accurate.

Recent incidents, such as the [U.S. Research & Education regional network hijack](https://internet2.edu/what-the-research-education-community-learned-from-three-impactful-routing-security-incidents-in-2024/) in July 2024, and the [Kazakstan DNS root server route hijack](https://root-servers.org/media/news/2025-06-20_route_hijack.pdf) in June 2025 continue to demonstrate that BGP's lack of built-in authentication remains a critical vulnerability.

#### Attack vectors

BGP routing faces two primary attack vectors:

* *Prefix hijacking*: An attacker announces someone else's IP prefix, either accidentally or maliciously. Traffic destined for the legitimate owner gets routed to the attacker instead. The famous [2008 Pakistan/YouTube incident](https://opensourcenetworksimulators.com/2026/02/bgp-hijack-with-kathara-network-emulator/) is a classic example.
* *Route leaks*: An AS incorrectly propagates routes it should not, often due to misconfiguration. This can cause traffic to take unexpected paths, potentially through networks that lack capacity or that enable surveillance. A recent example of a route leak that affected the Internet is the [Verizon/Pensylvania route leak incident](https://blog.cloudflare.com/how-verizon-and-a-bgp-optimizer-knocked-large-parts-of-the-internet-offline-today/).

#### Defense Mechanisms

Fortunately, the networking community has developed defenses. But, these defenses are not built into the BGP protocol. Instead, they are "best practices" that must be implemented by network operators. The *[MANRS (Mutually Agreed Norms for Routing Security)](https://www.manrs.org/)* initiative encourages network operators to implement these practices.

For example, network operators may proactively build filters and access control lists based on information from *Internet Routing Registries (IRRs)* that provide authoritative information the IP address allocations of each participating Autonomous System (AS). Also, network operators may integrate Resource *Public Key Infrastructure (RPKI)* validators to provide cryptographic proof that an AS is authorized to announce specific IP prefixes.

#### How Prefix Filtering Works

Internet Routing Registries (IRRs) are databases maintained by Regional Internet Registries (RIRs) like ARIN, RIPE NCC, APNIC, LACNIC, and AFRINIC. These databases contain records of which ASes are authorized to announce which prefixes. Network operators can query IRRs to build prefix filters, which they use to reject announcements that don't match registered information.

When an organization obtains IP address space, they register their allocation in the appropriate IRR along with their AS number. This creates a public record stating "AS64500 is authorized to announce 203.0.113.0/24." Other network operators can query these databases to learn which prefixes each AS should be announcing.

To implement filtering, operators periodically extract prefix information from IRRs and convert it into router configurations using tools like *[bgpq4](https://nsrc.org/workshops/2025/nsrc-ngnog2025-bgp/networking/bgp-deploy/en/presentations/BGPQ4-Introduction.pdf)*. The router then applies these prefix filters to incoming announcements. If a peer announces a prefix that isn't in their registered set, the router rejects the announcement. This prevents peers from advertising prefixes they don't own.

The main limitation of IRR-based filtering is that the data is not cryptographically signed. Registration is voluntary, and validation of entries varies between registries. This means IRR data can be incomplete, outdated, or in some cases, fraudulently registered. Despite these limitations, IRR filtering remains a widely-deployed first line of defense against route hijacks.

#### How RPKI Validation Works

RPKI (Resource Public Key Infrastructure) addresses the authentication gap with cryptographic verification. RIRs issue digital certificates that bind IP address blocks to the organizations that hold them. Prefix owners then create *Route Origin Authorizations (ROAs)*. ROAs are signed objects that specify which AS numbers are authorized to announce their prefixes and the maximum prefix length allowed.

RPKI validators fetch ROA data from RIRs' publication points and build a validated cache of prefix-to-AS mappings. Routers connect to these validators using the RPKI-to-Router (RTR) protocol to receive the validated data. When a BGP announcement arrives, the router checks it against the RPKI data and assigns one of three validation states:

* *Valid*: A ROA exists, and it matches the prefix and originating AS
* *Invalid*: A ROA exists, but the announcement doesn't match (wrong AS or prefix too specific)
* *NotFound*: No ROA exists for this prefix

Network operators typically configure their routers to prefer Valid routes, de-prioritize NotFound routes, and reject Invalid routes entirely. This policy effectively blocks hijack attempts where the attacker lacks a valid ROA for the target prefix. [RPKI adoption](https://isbgpsafeyet.com/) has grown steadily so that, as of 2026, [over 60% of announced prefixes have ROAs](https://rpki-monitor.antd.nist.gov/).

### Lab Architecture

Now let's design a lab topology that demonstrates how these BGP security tools work in practice. The multi-AS network will includes legitimate network operators, a potential attacker, and the services needed to support both IRR-based filtering and RPKI validation.

#### Lab Topology

The lab consists of six routers representing different Autonomous Systems, plus three infrastructure containers that provide RIR database, RPKI repository services, and RPKI validation. The topology simulates a simplified Internet hierarchy with a top-level upstream provider, multiple transit networks, and edge networks that include both a victim and an attacker.

```
                  ┌───────────┐  ┌────────────┐
                  │    RIR    │  │   RPKI     │
                  │  Database │  │ Repository │
                  └────────┬──┘  └──┬─────────┘
                           │        │
                        ┌──┴────────┴──┐   ┌───────────┐
                        │   upstream   │   │   RPKI    │
                        │    AS500     ├───┤ Validator │
                        └──────┬───────┘   └───────────┘
                               │
                         ┌─────┴─────┐
                         │    IXP    │
                         │   AS400   │
                         └──┬──┬──┬──┘
                            │  │  │
          ┌─────────────────┘  │  └─────────────────┐
          │                    │                    │
    ┌─────┴─────┐        ┌─────┴─────┐        ┌─────┴─────┐
    │ transit-1 │        │ transit-2 │        │ transit-3 │
    │   AS300   │        │   AS301   │        │   AS302   │
    └─────┬─────┘        └───────────┘        └─────┬─────┘
          │                                         │
    ┌─────┴─────┐                             ┌─────┴─────┐
    │   ISP-1   │                             │   ISP-2   │
    │  victim   │                             │ attacker  │
    │   AS100   │                             │   AS200   │
    └───────────┘                             └───────────┘
```

This topology is realistic enough to demonstrate real-world scenarios. The multi-tier AS hierarchy mirrors how the actual Internet works, with edge networks connecting through transit providers to larger upstream networks. It is also simple enough to run on a laptop computer. Seven routers plus four infrastructure containers can run comfortably on a laptop with 8GB of RAM. Finally, the lab uses public IP prefixes assigned in the ARIN region to emulate real routing policies and realistic prefix lengths. These prefixes are used only inside the Containerlab emulator and will not be announced outside the lab environment.

#### Lab Components

Each component in the lab serves a specific purpose in demonstrating BGP security mechanisms.

##### Internet Service Providers

The *Victim (AS100)* router router represents a legitimate network operator who owns IP address space and wants to protect it from hijacking. The victim announces a /16 prefix and has both an IRR registration and a valid ROA for their address space. In our scenarios, we will observe how traffic flows to this AS under normal conditions and during a hijack attempt.

The *Attacker (AS200)* router simulates a malicious or misconfigured network that announces prefixes it does not own. When attempting to hijack the Victim's prefix, the attacker will announce a more specific /24 route that falls within the victim's /16 prefix. The attacker has no valid ROA for the victim's prefix.

##### Transit 

The *Transit Provider* routers (AS300, AS301, AS302) represent intermediate networks that carry traffic between customer networks and other transit providers. They do not implement RPKI validation in this lab scenario.

The *Upstream Provider* router (AS500) represents the rest of the Internet. It sits at the top of our topology and peers with all transit networks. It will implement RPKI validation to demonstrates how a well-configured upstream provider can protect its customers from hijack attempts even when the attacker's immediate upstream does not implement RPKI.

The *Internet Exchange Provider (IXP)* is a simple layer‑2 switch that lets the transit and upstream providers (AS300, AS301, AS302, and AS500) peer with each other. It doesn’t affect routing policies but provides a more realistic peering fabric for the lab topology. 

##### Services

*RIR Database*: This container hosts a simplified Internet Routing Registry database that contains registration information for all prefixes in our lab. Network operators can query this database to build prefix filters. In a real network, operators would query databases like RADB, or the IRR databases maintained by ARIN, RIPE, APNIC, LACNIC, or AFRINIC.

*RPKI Repository*: This container hosts a repository of RPKI ROAs, registered by prefix owners. The RPKI validators will download information from the RPKI Repository. In the real world, operators typically pull ROAs directly from RIR publication points (or mirror servers) instead of maintaining their own repo, but this lab uses a local copy to keep the scenario self‑contained and repeatable.

*RPKI Validators*: These containers run an open-source RPKI validator that fetches and validates ROA data, then serves validated prefix-to-AS mappings to routers via the RPKI-to-Router (RTR) protocol. In our lab, we configure the RPKI validators with local test ROAs rather than connecting to real RIR publication points.

#### IP Addressing Scheme

To keep the lab organized and realistic, we use a consistent addressing scheme based on public ARIN-region carrier-style address space. Each AS has its own internal IP space for loopbacks and customer destinations.

| Network | AS Number | Legitimate Prefix Space | Router Loopback |
|---------|-----------|--------------------------|-----------------|
| Victim | AS100 | 12.10.0.0/16 | 12.10.255.100/32 |
| Attacker | AS200 | 24.71.0.0/16 | 24.71.255.200/32 |
| Transit-1 | AS300 | 66.20.0.0/16 | 66.20.255.1/32 |
| Transit-2 | AS301 | 68.30.0.0/16 | 68.30.255.2/32 |
| Transit-3 | AS302 | 69.40.0.0/16 | 69.40.255.3/32 |
| Upstream | AS500 | 70.50.0.0/16 | 70.50.255.4/32 |

For simplicity, point-to-point links between AS routers use addresses from the 198.51.100.0/24 interconnect range. The RIR database and RPKI validator are attached to a separate operations subnet (71.255.255.0/24) used for service access, not for router loopbacks.

To simulate customer networks inside each AS, I define destination subnets and test hosts from each AS's own address space:

| AS | Customer Subnet | Example Test Host | Purpose |
|----|------------------|-------------------|---------|
| AS100 (Victim) | 12.10.10.0/24 | 12.10.10.10 | Legitimate destination network |
| AS100 (Victim) | 12.10.20.0/24 | 12.10.20.10 | Second legitimate destination network |
| AS200 (Attacker) | 24.71.10.0/24 | 24.71.10.10 | Attacker's real customer network |
| AS200 (Attacker) | 12.10.10.0/24 (forged) | 12.10.10.66 | Hijacked destination used in attack scenario |
| AS300 (Transit-1) | 66.20.10.0/24 | 66.20.10.10 | ISP-1 internal/customer test network |
| AS301 (Transit-2) | 68.30.10.0/24 | 68.30.10.10 | ISP-2 internal/customer test network |
| AS302 (Transit-3) | 69.40.10.0/24 | 69.40.10.10 | Transit internal/customer test network |
| AS500 (Upstream) | 70.50.10.0/24 | 70.50.10.10 | Upstream internal/customer test network |

#### Lab notes

In this lab, AS100 (the victim) legitimately owns the IP prefix 12.10.0.0/16 and announces it to the Internet through its upstream transit provider AS300. The victim has properly registered their prefix in the RIR database and has created a valid ROA authorizing AS100 to announce 12.10.0.0/16.

AS200 (the attacker) attempts a classic prefix hijack by announcing a more specific route: 12.10.10.0/24. Because BGP prefers more specific prefixes, routers that receive both announcements would normally forward traffic destined for 12.10.10.0/24 toward AS200 instead of toward the legitimate owner, AS100.

The transit providers (AS300, AS301, AS302) represent networks with varying levels of security implementation. AS500, the upstream provider, will implement strict RPKI validation and serve as the demonstration point for how RPKI blocks the hijack attempt.











### Building the BGP Security Lab

Now that we understand the topology and addressing scheme, let's build the lab. I will walk through each component: the Containerlab topology file, the FRR router configurations, the IRR database, the RPKI validator, and the scripts that tie everything together.

#### Interconnect Addressing

Before we look at any configuration files, we need to nail down the IP addresses used on the links between routers. The existing tables above cover each AS's prefix space and loopbacks; here I add the point-to-point and IXP peering-LAN addresses.

**Point-to-point links (198.51.100.0/24):**

| Link | Node A | Address A | Node B | Address B |
|------|--------|-----------|--------|-----------|
| AS100 – AS300 | as100 eth1 | 198.51.100.0/31 | as300 eth1 | 198.51.100.1/31 |
| AS200 – AS302 | as200 eth1 | 198.51.100.2/31 | as302 eth1 | 198.51.100.3/31 |

**IXP peering LAN (203.0.113.0/24):**

| Router | Interface | IXP Address |
|--------|-----------|-------------|
| AS300 (Transit-1)  | eth2 | 203.0.113.1/24 |
| AS301 (Transit-2)  | eth1 | 203.0.113.2/24 |
| AS302 (Transit-3)  | eth2 | 203.0.113.3/24 |
| AS500 (Upstream)    | eth1 | 203.0.113.4/24 |

The IXP peering LAN is a shared Ethernet segment (a Linux bridge in Containerlab) where all four transit and upstream routers exchange BGP routes, just as they would at a real Internet Exchange Point.

#### Lab Directory Structure

Create a project directory and subdirectories for each component's configuration files:

```bash
$ mkdir -p bgp-security-lab/configs/{as100,as200,as300,as301,as302,as500}
$ mkdir -p bgp-security-lab/{irr,routinator/tals}
$ cd bgp-security-lab
```

The final directory tree will look like this:

```
bgp-security-lab/
├── topology.yml
├── configs/
│   ├── as100/
│   │   ├── daemons
│   │   └── frr.conf
│   ├── as200/
│   │   ├── daemons
│   │   └── frr.conf
│   ├── as300/
│   │   ├── daemons
│   │   └── frr.conf
│   ├── as301/
│   │   ├── daemons
│   │   └── frr.conf
│   ├── as302/
│   │   ├── daemons
│   │   └── frr.conf
│   └── as500/
│       ├── daemons
│       └── frr.conf
├── irr/
│   ├── server.py
│   └── routes.db
└── routinator/
    ├── routinator.conf
    ├── slurm.json
    └── tals/          (empty directory)
```

#### Containerlab Topology File

The topology file is the heart of a Containerlab lab. It describes every node, the container image each node uses, the configuration files that get bind-mounted into each container, and the links between nodes.

Create the file *topology.yml* in the *bgp-security-lab/* directory:

```yaml
name: bgp-security

mgmt:
  network: mgmt-bgp
  ipv4-subnet: 172.20.20.0/24

topology:

  nodes:

    # ── Edge ISPs ─────────────────────────────────────────
    as100:
      kind: linux
      image: quay.io/frrouting/frr:10.2.1
      binds:
        - configs/as100/daemons:/etc/frr/daemons
        - configs/as100/frr.conf:/etc/frr/frr.conf
      exec:
        - ip addr add 12.10.255.100/32 dev lo
        - ip addr add 12.10.10.1/24   dev lo
        - ip addr add 12.10.20.1/24   dev lo
        - ip addr add 198.51.100.0/31 dev eth1

    as200:
      kind: linux
      image: quay.io/frrouting/frr:10.2.1
      binds:
        - configs/as200/daemons:/etc/frr/daemons
        - configs/as200/frr.conf:/etc/frr/frr.conf
      exec:
        - ip addr add 24.71.255.200/32 dev lo
        - ip addr add 24.71.10.1/24    dev lo
        - ip addr add 198.51.100.2/31  dev eth1

    # ── Transit providers ─────────────────────────────────
    as300:
      kind: linux
      image: quay.io/frrouting/frr:10.2.1
      binds:
        - configs/as300/daemons:/etc/frr/daemons
        - configs/as300/frr.conf:/etc/frr/frr.conf
      exec:
        - ip addr add 66.20.255.1/32   dev lo
        - ip addr add 66.20.10.1/24    dev lo
        - ip addr add 198.51.100.1/31  dev eth1
        - ip addr add 203.0.113.1/24   dev eth2

    as301:
      kind: linux
      image: quay.io/frrouting/frr:10.2.1
      binds:
        - configs/as301/daemons:/etc/frr/daemons
        - configs/as301/frr.conf:/etc/frr/frr.conf
      exec:
        - ip addr add 68.30.255.2/32  dev lo
        - ip addr add 68.30.10.1/24   dev lo
        - ip addr add 203.0.113.2/24  dev eth1

    as302:
      kind: linux
      image: quay.io/frrouting/frr:10.2.1
      binds:
        - configs/as302/daemons:/etc/frr/daemons
        - configs/as302/frr.conf:/etc/frr/frr.conf
      exec:
        - ip addr add 69.40.255.3/32   dev lo
        - ip addr add 69.40.10.1/24    dev lo
        - ip addr add 198.51.100.3/31  dev eth1
        - ip addr add 203.0.113.3/24   dev eth2

    # ── Upstream provider ─────────────────────────────────
    as500:
      kind: linux
      image: quay.io/frrouting/frr:10.2.1
      binds:
        - configs/as500/daemons:/etc/frr/daemons
        - configs/as500/frr.conf:/etc/frr/frr.conf
      exec:
        - ip addr add 70.50.255.4/32  dev lo
        - ip addr add 70.50.10.1/24   dev lo
        - ip addr add 203.0.113.4/24  dev eth1

    # ── IXP (layer-2 bridge) ─────────────────────────────
    ixp:
      kind: bridge

    # ── IRR database (mini WHOIS server) ──────────────────
    irr:
      kind: linux
      image: python:3.12-alpine
      binds:
        - irr/server.py:/opt/server.py
        - irr/routes.db:/opt/routes.db
      cmd: python3 /opt/server.py

    # ── RPKI Validator (Routinator) ───────────────────────
    routinator:
      kind: linux
      image: nlnetlabs/routinator:latest
      binds:
        - routinator/routinator.conf:/home/routinator/.routinator.conf
        - routinator/slurm.json:/etc/routinator/slurm.json
        - routinator/tals:/home/routinator/.rpki-cache/tals
      mgmt-ipv4: 172.20.20.31
      cmd: >-
        server
        --no-rir-tals
        --config /home/routinator/.routinator.conf

  links:
    # AS100 (victim) ↔ AS300 (transit-1)
    - endpoints: ["as100:eth1", "as300:eth1"]
    # AS200 (attacker) ↔ AS302 (transit-3)
    - endpoints: ["as200:eth1", "as302:eth1"]
    # AS300 ↔ IXP
    - endpoints: ["as300:eth2", "ixp:eth1"]
    # AS301 ↔ IXP
    - endpoints: ["as301:eth1", "ixp:eth2"]
    # AS302 ↔ IXP
    - endpoints: ["as302:eth2", "ixp:eth3"]
    # AS500 ↔ IXP
    - endpoints: ["as500:eth1", "ixp:eth4"]
```

A few things worth noting in this topology file:

- The `kind: linux` nodes use `binds:` to inject FRR configuration files directly into the container at startup. This is the "lab-as-code" approach — all configuration lives in the project directory alongside the topology file.
- The `exec:` stanzas assign loopback, customer-subnet, and link addresses inside each router container at launch time. FRR's *zebra* daemon will pick up these addresses from the Linux kernel and make them available for BGP to announce.
- The `kind: bridge` IXP node is a Linux bridge that provides a shared Ethernet segment for AS300, AS301, AS302, and AS500 to peer across — just as a real IXP peering LAN works.
- The *irr* container uses a lightweight Python image to run a minimal WHOIS server that will serve our IRR route objects.
- Routinator gets a fixed management IP (`172.20.20.31`) so AS500 can connect to it via the RTR protocol. The `--no-rir-tals` flag tells Routinator not to download real-world RIR data; our lab uses local ROA assertions instead.

#### FRR Configuration Files

Each FRR router needs two files: a *daemons* file that tells FRR which protocol daemons to start, and a *frr.conf* file that holds the routing configuration.

##### Daemons File

The *daemons* file is identical for every router in this lab. Create it once and copy it into each router's configuration subdirectory:

```
bgpd=yes
zebra=yes
```

Only *bgpd* (for BGP) and *zebra* (for the kernel interface) are needed. The RPKI functionality in FRR is a module loaded by *bgpd* — it does not require a separate daemon.

```bash
$ for as in as100 as200 as300 as301 as302 as500; do
    cp configs/as100/daemons configs/$as/daemons
  done
```

##### AS100 — Victim

AS100 is the legitimate prefix owner. It announces its /16 aggregate along with two more-specific /24 subnets to its upstream transit provider, AS300.

```
frr version 10.2
frr defaults traditional
hostname as100
!
ip route 12.10.0.0/16 Null0
!
router bgp 100
 bgp router-id 12.10.255.100
 !
 neighbor 198.51.100.1 remote-as 300
 neighbor 198.51.100.1 description transit-AS300
 !
 address-family ipv4 unicast
  network 12.10.0.0/16
  network 12.10.10.0/24
  network 12.10.20.0/24
  neighbor 198.51.100.1 activate
 exit-address-family
!
```

The `ip route 12.10.0.0/16 Null0` creates a blackhole static route so that BGP's `network` statement can find the /16 in the routing table. Without this route, BGP would not announce the aggregate. The two /24 subnets are already present as connected routes because we assigned their addresses to the loopback interface in the topology file's `exec:` stanza.

##### AS200 — Attacker

The attacker's baseline configuration only advertises its own legitimate prefix. Later, in the scenarios section, we will add the hijack announcement.

```
frr version 10.2
frr defaults traditional
hostname as200
!
ip route 24.71.0.0/16 Null0
!
router bgp 200
 bgp router-id 24.71.255.200
 !
 neighbor 198.51.100.3 remote-as 302
 neighbor 198.51.100.3 description transit-AS302
 !
 address-family ipv4 unicast
  network 24.71.0.0/16
  network 24.71.10.0/24
  neighbor 198.51.100.3 activate
 exit-address-family
!
```

##### AS300 — Transit-1

AS300 peers downstream with its customer AS100, and peers at the IXP with the other transit networks and the upstream provider. In the base configuration, it accepts all announcements from all peers and propagates them — no filtering or RPKI validation is applied yet.

```
frr version 10.2
frr defaults traditional
hostname as300
!
ip route 66.20.0.0/16 Null0
!
router bgp 300
 bgp router-id 66.20.255.1
 !
 neighbor 198.51.100.0 remote-as 100
 neighbor 198.51.100.0 description customer-AS100
 neighbor 203.0.113.2  remote-as 301
 neighbor 203.0.113.2  description peer-AS301-ixp
 neighbor 203.0.113.3  remote-as 302
 neighbor 203.0.113.3  description peer-AS302-ixp
 neighbor 203.0.113.4  remote-as 500
 neighbor 203.0.113.4  description upstream-AS500-ixp
 !
 address-family ipv4 unicast
  network 66.20.0.0/16
  network 66.20.10.0/24
  neighbor 198.51.100.0 activate
  neighbor 203.0.113.2  activate
  neighbor 203.0.113.3  activate
  neighbor 203.0.113.4  activate
 exit-address-family
!
```

##### AS301 — Transit-2

AS301 is a transit-only network in this lab. It has no direct customer connections — it peers at the IXP and propagates routes.

```
frr version 10.2
frr defaults traditional
hostname as301
!
ip route 68.30.0.0/16 Null0
!
router bgp 301
 bgp router-id 68.30.255.2
 !
 neighbor 203.0.113.1 remote-as 300
 neighbor 203.0.113.1 description peer-AS300-ixp
 neighbor 203.0.113.3 remote-as 302
 neighbor 203.0.113.3 description peer-AS302-ixp
 neighbor 203.0.113.4 remote-as 500
 neighbor 203.0.113.4 description upstream-AS500-ixp
 !
 address-family ipv4 unicast
  network 68.30.0.0/16
  network 68.30.10.0/24
  neighbor 203.0.113.1 activate
  neighbor 203.0.113.3 activate
  neighbor 203.0.113.4 activate
 exit-address-family
!
```

##### AS302 — Transit-3

AS302 peers downstream with AS200 (the attacker) and upstream at the IXP. Like the other transit networks, it does not apply filtering or RPKI validation in the base configuration.

```
frr version 10.2
frr defaults traditional
hostname as302
!
ip route 69.40.0.0/16 Null0
!
router bgp 302
 bgp router-id 69.40.255.3
 !
 neighbor 198.51.100.2 remote-as 200
 neighbor 198.51.100.2 description customer-AS200
 neighbor 203.0.113.1  remote-as 300
 neighbor 203.0.113.1  description peer-AS300-ixp
 neighbor 203.0.113.2  remote-as 301
 neighbor 203.0.113.2  description peer-AS301-ixp
 neighbor 203.0.113.4  remote-as 500
 neighbor 203.0.113.4  description upstream-AS500-ixp
 !
 address-family ipv4 unicast
  network 69.40.0.0/16
  network 69.40.10.0/24
  neighbor 198.51.100.2 activate
  neighbor 203.0.113.1  activate
  neighbor 203.0.113.2  activate
  neighbor 203.0.113.4  activate
 exit-address-family
!
```

##### AS500 — Upstream Provider (with RPKI Validation)

AS500 is the most interesting configuration in the lab. In addition to standard BGP peering, it connects to Routinator via the RTR protocol and uses RPKI validation state to influence route selection.

```
frr version 10.2
frr defaults traditional
hostname as500
!
ip route 70.50.0.0/16 Null0
!
rpki
 rpki cache 172.20.20.31 3323 preference 1
exit
!
route-map RPKI-FILTER permit 10
 match rpki valid
 set local-preference 200
!
route-map RPKI-FILTER permit 20
 match rpki notfound
 set local-preference 100
!
route-map RPKI-FILTER deny 30
 match rpki invalid
!
router bgp 500
 bgp router-id 70.50.255.4
 !
 neighbor 203.0.113.1 remote-as 300
 neighbor 203.0.113.1 description peer-AS300-ixp
 neighbor 203.0.113.2 remote-as 301
 neighbor 203.0.113.2 description peer-AS301-ixp
 neighbor 203.0.113.3 remote-as 302
 neighbor 203.0.113.3 description peer-AS302-ixp
 !
 address-family ipv4 unicast
  network 70.50.0.0/16
  network 70.50.10.0/24
  neighbor 203.0.113.1 activate
  neighbor 203.0.113.1 route-map RPKI-FILTER in
  neighbor 203.0.113.2 activate
  neighbor 203.0.113.2 route-map RPKI-FILTER in
  neighbor 203.0.113.3 activate
  neighbor 203.0.113.3 route-map RPKI-FILTER in
 exit-address-family
!
```

The `rpki` block tells FRR where to find the RTR server — in our case, Routinator at management IP 172.20.20.31. The three `route-map` entries implement the standard RPKI route policy:

- **Valid** routes (ROA matches prefix and origin AS) get `local-preference 200`, making them the preferred path.
- **NotFound** routes (no ROA exists for this prefix) get `local-preference 100`. They are accepted but deprioritized compared to Valid routes.
- **Invalid** routes (a ROA exists but the origin AS or prefix length does not match) are dropped by the `deny 30` entry.

This route-map is applied inbound on every IXP peer with the `route-map RPKI-FILTER in` statement.

#### Setting Up the IRR Database

In the Lab Architecture section, I described the RIR Database container as a simplified Internet Routing Registry. We will implement it as a lightweight WHOIS server using a short Python script. It won't replicate the full complexity of production IRRd instances, but it does serve RPSL (Routing Policy Specification Language) objects that are structurally identical to what you would find in a real IRR like RADB, RIPE, or ARIN's IRR.

##### IRR WHOIS Server

Create the file *irr/server.py*:

```python
#!/usr/bin/env python3
"""Minimal WHOIS server for the lab's IRR database."""
import socketserver

with open("/opt/routes.db") as f:
    DB_TEXT = f.read()
OBJECTS = [obj.strip() for obj in DB_TEXT.split("\n\n") if obj.strip()]


class WhoisHandler(socketserver.StreamRequestHandler):
    def handle(self):
        query = self.rfile.readline().decode().strip().lower()
        results = [obj for obj in OBJECTS if query in obj.lower()]
        if results:
            self.wfile.write(("\n\n".join(results) + "\n").encode())
        else:
            self.wfile.write(b"% No matching objects found\n")


if __name__ == "__main__":
    server = socketserver.TCPServer(("0.0.0.0", 43), WhoisHandler)
    print("IRR WHOIS server listening on port 43")
    server.serve_forever()
```

The server listens on TCP port 43 (the standard WHOIS port), reads a one-line query from the client, and returns every RPSL object whose text matches the query string. This is the same basic behavior as a real WHOIS server.

##### IRR Route Objects

Create the file *irr/routes.db* with RPSL objects for every AS in the lab:

```
aut-num:  AS100
as-name:  VICTIM-NET
descr:    Victim ISP – legitimate prefix holder
source:   LABRIR

route:    12.10.0.0/16
descr:    Victim aggregate
origin:   AS100
source:   LABRIR

route:    12.10.10.0/24
descr:    Victim customer subnet A
origin:   AS100
source:   LABRIR

route:    12.10.20.0/24
descr:    Victim customer subnet B
origin:   AS100
source:   LABRIR

aut-num:  AS200
as-name:  ATTACKER-NET
descr:    Attacker ISP
source:   LABRIR

route:    24.71.0.0/16
descr:    Attacker aggregate
origin:   AS200
source:   LABRIR

route:    24.71.10.0/24
descr:    Attacker customer subnet
origin:   AS200
source:   LABRIR

aut-num:  AS300
as-name:  TRANSIT1-NET
descr:    Transit Provider 1
source:   LABRIR

route:    66.20.0.0/16
descr:    Transit-1 aggregate
origin:   AS300
source:   LABRIR

aut-num:  AS301
as-name:  TRANSIT2-NET
descr:    Transit Provider 2
source:   LABRIR

route:    68.30.0.0/16
descr:    Transit-2 aggregate
origin:   AS301
source:   LABRIR

aut-num:  AS302
as-name:  TRANSIT3-NET
descr:    Transit Provider 3
source:   LABRIR

route:    69.40.0.0/16
descr:    Transit-3 aggregate
origin:   AS302
source:   LABRIR

aut-num:  AS500
as-name:  UPSTREAM-NET
descr:    Upstream Provider
source:   LABRIR

route:    70.50.0.0/16
descr:    Upstream aggregate
origin:   AS500
source:   LABRIR
```

Notice that the only route objects with `origin: AS100` are the 12.10.0.0/16 aggregate and the two /24 subnets. There is **no** route object authorizing AS200 to announce anything in the 12.10.0.0/16 range. If a network operator queries this IRR before accepting routes from AS200, they will find no authorization for that prefix and can build a filter to reject it.

##### How Operators Use IRR Data in Practice

In the real world, network operators query IRR databases using tools like *[bgpq4](https://github.com/bgp/bgpq4)*. For example, to generate an FRR prefix-list for routes that AS200 is authorized to announce, an operator would run:

```bash
$ bgpq4 -F "ip prefix-list AS200-FILTER permit %n/%l le %L\n" AS200
```

Which would produce output like:

```
ip prefix-list AS200-FILTER permit 24.71.0.0/16 le 24
ip prefix-list AS200-FILTER permit 24.71.10.0/24 le 24
```

The operator then applies this prefix-list to the inbound BGP session from AS200. Any announcement not covered by the filter — such as an attempt to announce 12.10.10.0/24 — would be rejected. We will demonstrate IRR-based prefix filtering in the scenarios section later.

For now, our IRR database container is populated and ready to be queried. After the lab is deployed, you can test it directly:

```bash
$ docker exec clab-bgp-security-as300 sh -c \
    'echo "AS200" | nc clab-bgp-security-irr 43'
```

This should return the `aut-num` and `route` objects for AS200.

#### RPKI Validator Setup

For the RPKI validator, we use [Routinator](https://routinator.docs.nlnetlabs.nl/) from NLnet Labs. In production, Routinator fetches ROA data from the five RIR Trust Anchors over the Internet, validates the cryptographic chain, and serves the results to routers. In our lab, we don't connect to the real RPKI infrastructure. Instead, we use *SLURM (Simplified Local Internet Number Resource Management with the RPKI)*, standardized in [RFC 8416](https://www.rfc-editor.org/rfc/rfc8416), to define ROA assertions locally.

> **Note:** For a more realistic setup, you could run [Krill](https://krill.docs.nlnetlabs.nl/) — an open-source RPKI Certificate Authority from NLnet Labs — alongside Routinator. Krill would act as a local mini-RIR, issuing resource certificates and signing ROAs. Routinator would then fetch and validate those ROAs through the standard RPKI trust chain. I use SLURM here because it achieves the same result for lab scenarios with significantly less setup complexity.

##### SLURM File — Local ROA Assertions

Create the file *routinator/slurm.json*:

```json
{
  "slurmVersion": 1,
  "validationOutputFilters": {
    "prefixFilters": [],
    "bgpsecFilters": []
  },
  "locallyAddedAssertions": {
    "prefixAssertions": [
      {
        "asn": 100,
        "prefix": "12.10.0.0/16",
        "maxPrefixLength": 24,
        "comment": "Victim AS100 – authorized for /16 through /24"
      },
      {
        "asn": 200,
        "prefix": "24.71.0.0/16",
        "maxPrefixLength": 24,
        "comment": "Attacker AS200 – own prefix only"
      },
      {
        "asn": 300,
        "prefix": "66.20.0.0/16",
        "maxPrefixLength": 24,
        "comment": "Transit-1 AS300"
      },
      {
        "asn": 301,
        "prefix": "68.30.0.0/16",
        "maxPrefixLength": 24,
        "comment": "Transit-2 AS301"
      },
      {
        "asn": 302,
        "prefix": "69.40.0.0/16",
        "maxPrefixLength": 24,
        "comment": "Transit-3 AS302"
      },
      {
        "asn": 500,
        "prefix": "70.50.0.0/16",
        "maxPrefixLength": 24,
        "comment": "Upstream AS500"
      }
    ],
    "bgpsecAssertions": []
  }
}
```

Each `prefixAssertions` entry is the equivalent of a ROA (Route Origin Authorization). The critical entry for our attack scenario is:

```json
{"asn": 100, "prefix": "12.10.0.0/16", "maxPrefixLength": 24}
```

This says: *only AS100 is authorized to announce 12.10.0.0/16 or any more-specific prefix up to a /24.* When AS200 later announces `12.10.10.0/24` — which falls inside that /16 — Routinator will flag it as **Invalid** because AS200 is not the authorized origin for that prefix block.

Notice that AS200 does have a valid ROA for its own prefix (24.71.0.0/16). Only its fraudulent announcement of the victim's prefix will be flagged.

##### Routinator Configuration

Create the file *routinator/routinator.conf*:

```toml
exceptions = ["/etc/routinator/slurm.json"]
rtr-listen = ["0.0.0.0:3323"]
http-listen = ["0.0.0.0:8323"]
log-level = "info"
```

This tells Routinator to:

- Load our SLURM file and use its ROA assertions
- Serve the RTR protocol on port 3323 (where AS500's FRR will connect)
- Serve the HTTP API and dashboard on port 8323 (useful for inspecting validation state)

##### How It All Connects

When the lab is running, the RPKI data flows through the following chain:

1. **Routinator** starts, finds no RIR TAL files (because we passed `--no-rir-tals`), but loads the SLURM file and builds a Validated ROA Payload (VRP) list from our local assertions.
2. **AS500's FRR** connects to Routinator's RTR server at 172.20.20.31:3323 and downloads the VRP list.
3. When a **BGP announcement** arrives at AS500, FRR checks the prefix and origin AS against the VRP list and assigns a validation state: *Valid*, *Invalid*, or *NotFound*.
4. The **RPKI-FILTER route-map** on AS500 uses this state to accept, deprioritize, or reject the route.

#### Deploying the Lab

With all configuration files in place, deploy the topology from the *bgp-security-lab/* directory:

```bash
$ sudo containerlab deploy -t topology.yml
```

You will see Containerlab pull container images (on first run), create the containers, set up the network links, and execute the `exec:` commands. When the deployment finishes, you should see a summary table listing all nodes.

Verify that every container is in the `running` state:

```bash
$ sudo containerlab inspect -t topology.yml
```

You should see output similar to:

```
╭───────────────────────────────┬────────────────────────────────┬─────────┬──────────────────╮
│            Name               │          Kind/Image            │  State  │  IPv4 Address    │
├───────────────────────────────┼────────────────────────────────┼─────────┼──────────────────┤
│ clab-bgp-security-as100       │ linux                          │ running │ 172.20.20.11     │
│                               │ quay.io/frrouting/frr:10.2.1  │         │                  │
├───────────────────────────────┼────────────────────────────────┼─────────┼──────────────────┤
│ clab-bgp-security-as200       │ linux                          │ running │ 172.20.20.12     │
│                               │ quay.io/frrouting/frr:10.2.1  │         │                  │
├───────────────────────────────┼────────────────────────────────┼─────────┼──────────────────┤
│ clab-bgp-security-as300       │ linux                          │ running │ 172.20.20.13     │
│                               │ quay.io/frrouting/frr:10.2.1  │         │                  │
├───────────────────────────────┼────────────────────────────────┼─────────┼──────────────────┤
│ clab-bgp-security-as301       │ linux                          │ running │ 172.20.20.14     │
│                               │ quay.io/frrouting/frr:10.2.1  │         │                  │
├───────────────────────────────┼────────────────────────────────┼─────────┼──────────────────┤
│ clab-bgp-security-as302       │ linux                          │ running │ 172.20.20.15     │
│                               │ quay.io/frrouting/frr:10.2.1  │         │                  │
├───────────────────────────────┼────────────────────────────────┼─────────┼──────────────────┤
│ clab-bgp-security-as500       │ linux                          │ running │ 172.20.20.16     │
│                               │ quay.io/frrouting/frr:10.2.1  │         │                  │
├───────────────────────────────┼────────────────────────────────┼─────────┼──────────────────┤
│ clab-bgp-security-irr         │ linux                          │ running │ 172.20.20.20     │
│                               │ python:3.12-alpine             │         │                  │
├───────────────────────────────┼────────────────────────────────┼─────────┼──────────────────┤
│ clab-bgp-security-routinator  │ linux                          │ running │ 172.20.20.31     │
│                               │ nlnetlabs/routinator:latest    │         │                  │
╰───────────────────────────────┴────────────────────────────────┴─────────┴──────────────────╯
```

#### Verifying the Base Configuration

Before running any attack scenarios, verify that the base lab is operating correctly. Three things need to be true:

1. BGP sessions are established between all peers
2. Each AS has learned the expected prefixes from its neighbors
3. AS500 is connected to Routinator and RPKI validation is active

##### Check BGP Sessions

Verify that AS100's BGP session to AS300 is established:

```bash
$ docker exec clab-bgp-security-as100 vtysh -c "show bgp summary"
```

You should see a line for the AS300 peer with a state showing the number of received prefixes (not a state like `Active` or `Idle`):

```
IPv4 Unicast Summary:
Neighbor        V    AS   MsgRcvd  MsgSent  TblVer   InQ  OutQ  Up/Down  State/PfxRcd
198.51.100.1    4   300        42       38       0     0     0 00:05:12           12
```

The `State/PfxRcd` column should show a number (the count of prefixes received), not a connection state like `Active`. If you see `Active` or `Connect`, the BGP session has not established — check that the link addresses are correct and that FRR has started.

Repeat for AS500 to confirm it has sessions with all three IXP peers:

```bash
$ docker exec clab-bgp-security-as500 vtysh -c "show bgp summary"
```

##### Check Routing Tables

Verify that AS500 has learned the victim's prefix:

```bash
$ docker exec clab-bgp-security-as500 vtysh -c "show bgp ipv4 unicast 12.10.0.0/16"
```

You should see a BGP table entry showing the path through AS300 and AS100:

```
BGP routing table entry for 12.10.0.0/16, version 5
Paths: (1 available, best #1, table default)
  Advertised to non peer-group peers:
  203.0.113.1 203.0.113.2 203.0.113.3
  300 100
    203.0.113.1 from 203.0.113.1 (66.20.255.1)
      Origin IGP, valid, external, best (First path received)
      Last update: Mon Feb 28 10:15:42 2026
```

##### Check RPKI Validation

Verify that AS500 has an active RTR connection to Routinator:

```bash
$ docker exec clab-bgp-security-as500 vtysh -c "show rpki cache-connection"
```

You should see the connection to 172.20.20.31 in the `connected` state:

```
Connected to group 1
rpki tcp cache 172.20.20.31 3323 pref 1
```

Check the RPKI validation state of the victim's prefix on AS500:

```bash
$ docker exec clab-bgp-security-as500 vtysh -c "show rpki prefix 12.10.0.0/16"
```

This should show that AS100 is the authorized origin:

```
Prefix                                   Prefix Length  Origin-AS
12.10.0.0/16                             16 - 24        100
```

You can also verify the Routinator dashboard and API from the host:

```bash
$ curl -s http://172.20.20.31:8323/api/v1/status | python3 -m json.tool
```

And list all Validated ROA Payloads (VRPs):

```bash
$ curl -s http://172.20.20.31:8323/api/v1/vrps
```

This should return JSON containing all six ROAs from our SLURM file.

With all BGP sessions established, prefixes propagating correctly, and RPKI validation active on AS500, the lab is ready. In the next section, we will run the attack scenarios: first demonstrating a successful hijack when defenses are absent, then showing how IRR-based prefix filtering and RPKI validation each block the attack.
