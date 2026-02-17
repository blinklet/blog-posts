% Using Containerlab to Demonstrate BGP Security: RPKI and RIR Databases in Practice

The Internet's routing system runs on trust. The Border Gateway Protocol (BGP), which directs traffic between networks worldwide, was designed in the 1990s with the assumption that all participants would behave honestly. That assumption has, of course, proven to be naively optimistic.

Recent incidents, such as the [U.S. Research & Education regional network hijack](https://internet2.edu/what-the-research-education-community-learned-from-three-impactful-routing-security-incidents-in-2024/) in July 2024, and the [Kazakstan DNS root server route hijack](https://root-servers.org/media/news/2025-06-20_route_hijack.pdf) in June 2025 continue to demonstrate that BGP's lack of built-in authentication remains a critical vulnerability.

Fortunately, the networking community has developed defenses. But, these defenses are not built into the BGP protocol; they are "best practices" that must be implemented by network operators. For example, network operators can validate received route announcements using Regional Internet Registry (RIR) databases that provide authoritative information the IP address allocations of each participating Autonomous System (AS) on the Internet. Also, network operators may integrate Resource Public Key Infrastructure (RPKI) validators to provide cryptographic proof that an AS is authorized to announce specific IP prefixes.

But, we need a way to appreciate how these Internet-scale solutions improve BGP security by re-creating their operation in small-scale learning labs.

In this post, I will show you how to use [Containerlab](https://containerlab.dev/) to build a realistic lab environment where you can experiment with these BGP security mechanisms. I last reviewed Containerlab five years ago in 2021, and it has evolved significantly since then. This post will also highlight the improvements that make Containerlab an excellent choice for building BGP security labs.

You will learn how to:

- Set up a multi-AS topology with routers running the [Free Range Routing (FRR)](https://frrouting.org/) stack
- Deploy an RPKI validator using [Routinator](https://github.com/NLnetLabs/routinator) to provide route origin validation
- Simulate a BGP hijack attack and observe how RPKI blocks it
- Use RIR database information for prefix filtering

<!--more-->

## Containerlab's Evolution: 2021 to 2026

When I first [reviewed Containerlab in 2021](https://opensourcenetworksimulators.com/2021/05/use-containerlab-to-emulate-open-source-routers/), it was a promising but relatively new project. It was actively working to add more commercial routers to its library of supported devices. The tool worked well, but setting up open-source router labs required understanding Docker internals and careful configuration file management.

Five years later, Containerlab has matured into a network emulation platform that fully supports open-source routers. I list the key improvements over the past few years, below.

### Native Open-Source Router Support

Containerlab now includes dedicated node types for popular open-source routing stacks. Instead of using `kind: linux` and manually configuring everything, you can now use:

- `kind: linux` with the `frr` image type for automatic [FRR](https://frrouting.org/) integration
- Native support for [BIRD](https://bird.network.cz/), [GoBGP](https://osrg.github.io/gobgp/), and [OpenBGPD](https://www.openbgpd.org/)
- Automatic startup script execution and configuration file placement

### Improved VM Support with vrnetlab

The [vrnetlab](https://containerlab.dev/manual/vrnetlab/) integration has expanded significantly. You can now run VM-based network operating systems from VyOS, OpenWRT, and others inside containers. For BGP security labs, this means you can test RPKI configurations against commercial router images if your organization has the appropriate licenses.

### DevOps Integration

Containerlab now integrates smoothly with infrastructure-as-code workflows. It supports Ansible inventory generation that automatically creates Ansible inventory files for lab nodes. Users can manage Containerlab topologies using Terraform. Developers can run Containerlab labs in GitHub Actions, GitLab CI, or Jenkins pipelines. The Containerlab project also provides a [VSCode extension](https://github.com/srl-labs/vscode-containerlab).

### Community and Documentation

The project moved to [containerlab.dev](https://containerlab.dev/) and the documentation has grown substantially. The [community examples repository](https://github.com/srl-labs/containerlab/tree/main/lab-examples) now includes dozens of ready-to-use lab topologies, including several focused on BGP and routing protocols.

### Performance and Reliability

Deployment is faster, cleanup is more reliable, and resource usage is better optimized. The networking issues I documented in my 2021 post, where stopping and starting containers could corrupt network namespaces, have been addressed. Container lifecycle management is now more robust.
