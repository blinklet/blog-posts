% Using Containerlab to Demonstrate BGP Security Using RPKI and RIR Databases

In this post, I will show you how to use [Containerlab](https://containerlab.dev/) to build a realistic lab environment consisting of a multi-AS topology with routers running the [Free Range Routing (FRR)](https://frrouting.org/) stack in which you can experiment with BGP security mechanisms. 

I last reviewed Containerlab five years ago in 2021, and it has evolved significantly since then. This post will also highlight the features that make Containerlab an excellent choice for building BGP security labs.

You will learn how to:

- Set up a multi-AS topology with routers running the [Free Range Routing (FRR)](https://frrouting.org/) stack
- Emulate an RIR database to support our network scenario and use RIR database information for prefix filtering
- Deploy an RPKI validator using [Routinator](https://github.com/NLnetLabs/routinator) to provide route origin validation
- Simulate a BGP hijack attack and observe how prefix filtering can mitigate it, and how RPKI blocks it

<!--more-->

### Containerlab

[Containerlab](https://containerlab.dev) is an open-source, container-based network emulation platform that lets you build, run, and tear down realistic network topologies using simple, declarative YAML files. It uses lightweight containers and Linux networking to interconnect routers, switches, hosts, and tools into reproducible labs that behave like real networks. It also supports containerized virtual machines, so it can use many commercial router images.

Containerlab supports a wide range of vendor and open-source network operating systems, integrates cleanly with automation tools (such as Ansible and CI/CD pipelines), and emphasizes “lab-as-code” workflows—making it well suited for learning, testing configurations, validating designs, and demonstrating complex scenarios like BGP, EVPN, or data-center fabrics on a single workstation or server. 

When I first [reviewed Containerlab in 2021](https://opensourcenetworksimulators.com/2021/05/use-containerlab-to-emulate-open-source-routers/), it was a promising but relatively new project. It's developers were actively working to add more commercial routers to its library of supported devices. Five years later, [Containerlab](https://containerlab.dev) has matured into a developer-friendly network emulation platform that fully supports many readily-available router software images. 

For open-source routers, Containerlab continues to support the `kind: linux` node type, which enables users to create their own containers that support open-source routers like [FRR](https://frrouting.org/), [BIRD](https://bird.network.cz/), [GoBGP](https://osrg.github.io/gobgp/), and [OpenBGPD](https://www.openbgpd.org/). This is the same as it was five years ago.

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

Fortunately, the networking community has developed defenses. These defenses are not built into the BGP protocol. Instead, they are "best practices" that must be implemented by network operators. For example, network operators may proactively build filters and access control lists based on information from Regional Internet Registry (RIR) databases that provide authoritative information the IP address allocations of each participating Autonomous System (AS) on the Internet. Also, network operators may integrate Resource Public Key Infrastructure (RPKI) validators to provide cryptographic proof that an AS is authorized to announce specific IP prefixes.

*Internet Routing Registries (IRRs)* are databases maintained by Regional Internet Registries (RIRs) like ARIN, RIPE NCC, APNIC, LACNIC, and AFRINIC. These databases contain records of which ASes are authorized to announce which prefixes. Network operators can query IRRs to build prefix filters, which they use to reject announcements that don't match registered information. However, IRR data is not cryptographically signed and relies on voluntary registration, so it can be incomplete or outdated.

*RPKI (Resource Public Key Infrastructure)* addresses the authentication gap with cryptographic verification. RIRs issue digital certificates that bind IP address blocks to the organizations that hold them. Prefix owners then create *Route Origin Authorizations (ROAs)*. ROAs are signed objects that specify which AS numbers are authorized to announce their prefixes and the maximum prefix length allowed.

#### How RPKI Validation Works

RPKI validators fetch ROA data from RIRs' publication points and build a validated cache of prefix-to-AS mappings. Routers connect to these validators using the RPKI-to-Router (RTR) protocol to receive the validated data. When a BGP announcement arrives, the router checks it against the RPKI data and assigns one of three validation states:

* *Valid*: A ROA exists, and it matches the prefix and originating AS
* *Invalid*: A ROA exists, but the announcement doesn't match (wrong AS or prefix too specific)
* *NotFound*: No ROA exists for this prefix

Network operators typically configure their routers to prefer Valid routes, de-prioritize NotFound routes, and reject Invalid routes entirely. This policy effectively blocks hijack attempts where the attacker lacks a valid ROA for the target prefix.

The [MANRS (Mutually Agreed Norms for Routing Security)](https://www.manrs.org/) initiative encourages network operators to implement these practices, and [RPKI adoption](https://isbgpsafeyet.com/) has grown steadily. As of 2026, [over 60% of announced prefixes have ROAs](https://rpki-monitor.antd.nist.gov/), making RPKI increasingly effective at preventing hijacks.

