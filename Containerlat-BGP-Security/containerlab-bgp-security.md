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



