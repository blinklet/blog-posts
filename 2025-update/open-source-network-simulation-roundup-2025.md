% Open-source network simulation roundup 2025

This is my annual update, where I check each open-source network simulation and emulation projects's activity level, document version changes to well-maintained projects, identify new projects that deserve attention, and consider projects that may be fading away.

The big story for 2025 is the continued rapid development of *Containerlab*, which seems to have cemented its position as a leading network emulation tool for developers. I also found a few stale projects that users should approach with caution, and I discovered some interesting up-and-coming tools worth watching.

Read the rest of this post for information about the latest open-source network simulator releases, as of January 2026.

## What's New in 2025?

### Winners

**Containerlab** continues its impressive development pace, jumping from version 0.51.3 to 0.72.0 in less than two years. New features include VM snapshot/restore functionality, expanded device support (including Cisco vIOS and ASAv), a new Clabernetes system for running labs on Kubernetes clusters, and improved container network configuration.

**Shadow**, the network simulator focused on Tor research, released version 3.3.0 with significant improvements including better syscall support, netlink socket improvements for Go programs, and the migration of much of the codebase from C to Rust for better reliability.

**Kathara** reached version 3.8.0, adding support for custom volumes, privileged mode, and custom entrypoints for devices. The project also introduced a new `kathara-lab-checker` tool to replace the old `ltest` command.

#
**Filius**, the educational network simulator, continues strong development with version 2.9.4 released in July 2025. This German-language tool remains an excellent choice for teaching networking concepts to students.

### Projects Showing Signs of Decline

**vrnetlab** (the original at github.com/vrnetlab/vrnetlab) has not received commits in over two years and has no published releases. Users should migrate to the [srl-labs/vrnetlab](https://github.com/srl-labs/vrnetlab) fork, which is actively maintained and integrates seamlessly with Containerlab.
**remove**

**VNX** has not received updates since September 2020. While the software still works, users should consider more actively maintained alternatives like Containerlab or Kathara for new projects.
**remove**


**Mininet** remains stable at version 2.3.0, released in February 2021. It continues to work well for SDN development and education, but active development has slowed significantly.

### Up-and-Coming Projects

I found some interesting new projects worth watching:

**NetLab** (formerly netsim-tools) - While not new, NetLab has matured significantly with regular updates through 2025. It provides infrastructure-as-code for networking labs, automatically generating complete IPv4/IPv6 addressing and routing protocol configurations from YAML topology definitions.


Marrionet is seeing bug fixes as recently as May 2025 -- should I add it back to the list?
https://launchpad.net/marionnet/
https://www.marionnet.org/site/index.php/en/
I need to try it out again and see that it works in Ubuntu 26.04 (when available)




## Network Simulators

* **[cnet](https://teaching.csse.uwa.edu.au/units/CITS3002/cnet/index.php)**
  * Updated and available on  Apple M-series 'Silicon' processor (built on macOS Sonoma 14.3)
Apple with 64-bit Intel processor (built on macOS Sonoma 14.3)
Linux on 64-bit Intel processor (built on Ubuntu 23.10) 
`curl -s -o cnet-Linux-x86_64 https://teaching.csse.uwa.edu.au/units/CITS3002/cnet/downloads/cnet-Linux-x86_64`


* **[ns-3](https://www.nsnam.org/)**
  * *ns-3* continues to be the premier open-source discrete-event network simulator. The most recent release is **ns-3.46.1 on December 17, 2025** (up from ns-3.41 in February 2024).
  * Recent additions include new Zigbee support and improved Wi-Fi simulation helpers.
  * The [*ns-3* source code](https://gitlab.com/nsnam/ns-3-dev/) is on GitLab.

* **[OMNeT++](https://omnetpp.org/)**
  * *OMNeT++* remains actively maintained with release **6.3.0 on November 12, 2025** (up from 6.0.3 in February 2024).
  * New features include an AI notebook tool for analysis and TSN (Time-Sensitive Networking) tutorials.
  * The [OMNET++ source code](https://github.com/omnetpp/omnetpp) is on GitHub.

* **[Shadow](https://shadow.github.io/)**
  * *Shadow* has seen excellent progress with release **v3.3.0 on October 16, 2025** (up from v3.1.0 in December 2023).
  * Major improvements include new syscall support (chdir, close_range, fstat), better Go program compatibility, migration of networking code from C to Rust, and improved Fedora 42 support.
  * The [Shadow source code](https://github.com/shadow/shadow) is on GitHub.


## Network Emulators for Engineers

* **[Cloonix](https://clownix.net/)**
  * *Cloonix* continues active development with release **v53.01 on November 4, 2025** (up from v34-00 in December 2023).
  * This KVM-based emulator provides a solid alternative for those preferring VM-based network emulation.

* **[CORE](https://coreemu.github.io/core/)**
  * *CORE* is well-maintained with release **v9.2.1 on May 19, 2025** (up from v9.0.3 in August 2023).
  * The 9.2.x releases improved Docker support and added Podman nodes with compose support.
  * The [*CORE* source code](https://github.com/coreemu/core) is on GitHub.

* **[IMUNES](https://github.com/imunes/imunes/)**
  * *IMUNES* has been actively developed with recent commits as of December 2025. The project added FreeBSD 15 support and improved Docker support for Linux.
  * The [*IMUNES* source code](https://github.com/imunes/imunes/) is on GitHub.

* **[EVE-NG Community Edition](https://www.eve-ng.net/index.php/community/)**
  * The *EVE-NG Community Edition* received an update to **v6.0.2-4 on July 21, 2024**, but development focus remains on the paid EVE-PRO version.
  * ⚠️ Users who require active community edition development should consider alternatives like GNS3 or Containerlab.

* **[GNS3](https://www.gns3.com/)**
  * *GNS3* continues steady development with version **2.2.55** available (up from v2.2.45 in January 2024).
  * The software has surpassed 19.1 million downloads and remains the most popular GUI-based network emulator.
  * The [*GNS3* source code](https://github.com/GNS3) is on GitHub.


## Network Emulators for Developers

* **[Containerlab](https://containerlab.dev/)**
  * 🌟 *Containerlab* remains the standout tool with extremely active development. The latest release is **v0.72.0 on December 3, 2025** (up from v0.51.3 in February 2024).
  * Notable new features include:
    * VM snapshot save/restore functionality for vrnetlab nodes
    * Cisco vIOS and ASAv support
    * SR-SIM (Nokia integrated simulation) support
    * Expanded template functions for dynamic configuration
    * Containerlab events feature for automation
  * The [*Containerlab* source code](https://github.com/srl-labs/containerlab) is on GitHub.

* **[NetLab](https://netlab.tools/)**
  * *NetLab* continues frequent updates through 2025. Note: The project does not use GitHub releases but is actively maintained via commits.
  * NetLab provides complete lab automation from YAML topology definitions to full routing protocol configuration.
  * The [*NetLab* source code](https://github.com/ipspace/netlab) is on GitHub.

* **[OpenConfig-KNE](https://github.com/openconfig/kne)**
  * *OpenConfig-KNE* is actively maintained with release **v0.3.0 on August 4, 2025** (up from v0.1.17 in February 2024).
  * Recent updates include CVE security fixes.
  * The [*OpenConfig-KNE* source code](https://github.com/openconfig/kne) is on GitHub.
**Maybe changing its focus. Look at the web site**

* **[vrnetlab](https://github.com/vrnetlab/vrnetlab)**
  * ⚠️ **STALE PROJECT**: The original *vrnetlab* has not received commits in over two years and has no published releases.
  * Users should migrate to **[srl-labs/vrnetlab](https://github.com/srl-labs/vrnetlab)**, the actively maintained fork that works with Containerlab and received updates as recently as January 2025.

* **[Linux Network Stack Test (LNST)](http://lnst-project.org/)**
  * *LNST* development appears **dormant**. The project has no GitHub releases and the mailing list shows minimal activity.
  * The [*LNST* source code](https://github.com/LNST-project/lnst) is on GitHub.


## Software Defined Networks

* **[Mininet](https://mininet.org/)**
** Getting Stale** 
  * *Mininet* development has been stable but quiet. The **last major release was v2.3.0 in February 2021**.
  * While Mininet remains functional and useful for SDN education and research, users should be aware that active development has slowed significantly.
  * The [*Mininet* mailing list](https://mailman.stanford.edu/pipermail/mininet-discuss/) is still available.
  * The [*Mininet* source code](https://github.com/mininet/mininet) is on GitHub.
Mininet-WiFi   https://mininet-wifi.github.io/
Mini-NDN   https://github.com/named-data/mini-ndn
https://mailman.stanford.edu/pipermail/mininet-discuss/2025-May/008806.html
(no one is responding to questions in the Mininet mailing list)


* **[Containernet](https://containernet.github.io/)**
  * Still maintained, as of one and a half years ago
  * The [*Containernet* source code](https://github.com/containernet/containernet) is on GitHub.


## Mobile and Radio Networks

* **[Colosseum](https://www.northeastern.edu/colosseum/)**
  * The *Colosseum* emulator continues as a research platform. Component updates occur independently.
  * [Source code for *Colosseum* components](https://www.northeastern.edu/colosseum/cellular-software/) is available on the Colosseum website.

* **[Cooja](https://docs.contiki-ng.org/en/develop/doc/tutorials/Running-Contiki-NG-in-Cooja.html)**
  * *Cooja* remains part of the [Contiki-NG](https://www.contiki-ng.org/) IoT operating system project.
  * The [*Cooja* source code](https://github.com/contiki-ng/cooja) is on GitHub.

* **[CrowNet](https://github.com/roVer-HM/crownet)**
  * *CrowNet* development activity remains low, with only minor updates.

* **[CupCarbon](http://cupcarbon.com)**
  * *CupCarbon* IoT/WSN simulator development status is unclear. The license status remains undeclared.
**Not updated in 4 years. Seems like further development is no longer open source (see https://github.com/bounceur/CupCarbon/issues/31). Remove from list**

* **[Meshtasticator](https://github.com/GUVWAF/Meshtasticator)**
  * *Meshtasticator* continues to receive maintenance updates for Meshtastic mesh network simulation.
  * The [*Meshtasticator* source code](https://github.com/GUVWAF/Meshtasticator) is on GitHub.

* **[NEmu](https://gitlab.com/v-a/nemu/-/wikis/home)**
  * *NEmu* virtual networking environment continues development.
  * The [*NEmu* source code](https://gitlab.com/v-a/nemu) is on GitLab.


## Network Emulators Maintained by Universities

* **[Kathara](https://www.kathara.org/)**
  * *Kathara* is actively maintained with release **v3.8.0 on July 29, 2025** (up from v3.7.1 in January 2024).
  * New features include:
    * Custom volume mounting via the `volume` metadata
    * Per-device privileged mode support
    * Custom entrypoint and arguments for devices
    * Per-network-scenario configuration files
    * The `ltest` command has been deprecated in favor of the new `kathara-lab-checker` tool
  * The [*Kathara* source code](https://github.com/KatharaFramework/Kathara) is on GitHub.

* **[Labtainers](https://nps.edu/web/c3o/labtainers)**
  * *Labtainers* continues active development with release **v1.4.4h on December 27, 2025** (up from v1.3.7u in November 2023).
  * This Docker-based cybersecurity lab environment includes over 50 lab exercises.
  * The [*Labtainers* source code](https://github.com/mfthomps/Labtainers) is on GitHub.

* **[VNX](http://web.dit.upm.es/vnxwiki/index.php/Main_Page)**
  * ⚠️ **STALE PROJECT**: The *VNX* emulator **was last updated in September 2020**, making it over five years since the last update.
  * While the software may still work, users should consider more actively maintained alternatives for new projects.


## Network Demonstrators for High School Teachers

* **[Educational Network Simulator](http://projects.bardok.net/educational-network-simulator/)**
  * The [hosted web app](http://projects.bardok.net/networks-live/simulator01.html) remains available for educational use.
  * The [source code](https://github.com/malkiah/NetworkSimulator) is on GitHub.
Hosted web site is down
no updates in a long time
**Remove**

* **[CS4G Netsim](https://netsim.erinn.io/)**
  * The [hosted web app](https://netsim.erinn.io/) continues to run for educational purposes.
  * The [*NetSim* source code](https://github.com/errorinn/netsim) is on GitHub.

* **[Filius](https://www.lernsoftware-filius.de/Herunterladen)**
  * *Filius* continues strong development with release **v2.9.4 on July 20, 2025** (up from v2.5.1 in October 2023).
  * This German-language educational tool remains excellent for teaching networking fundamentals.
  * The [*Filius* source code](https://gitlab.com/filius1/filius) is on GitLab.


## Tools

* **[tinet](https://github.com/tinynetwork/tinet)**
  * *tinet* last received updates with release **v0.0.4 on January 17, 2024**.
  * Development has been quiet since then, but the tool remains functional for quickly generating network topologies using Docker and network namespaces.
  * The [*tinet* source code](https://github.com/tinynetwork/tinet) is on GitHub.
**Remove** not updated and ignoring pull requests

* **[Nix](https://nixos.org/)**
  * *Nix* remains a powerful option for declaratively defining reproducible network lab environments.
  * The NixOS ecosystem continues active development and provides excellent support for building complex, reproducible test environments.
**Remove** NIx is a package manager and operating system for defining systems


## Summary

The 2024-2025 period saw continued growth in container-based network emulation tools, with Containerlab leading the way. Traditional VM-based emulators like GNS3 remain popular for their graphical interfaces and broad hardware vendor support.

**Projects to Watch:**
- Containerlab for container-native network labs
- NetLab for infrastructure-as-code lab automation
- srl-labs/vrnetlab for running vendor VMs in containers

**Projects to Avoid for New Deployments:**
- vrnetlab (original) - migrate to srl-labs/vrnetlab
- VNX - last updated 2020
- Containernet - last released 2019

**Stable and Reliable:**
- GNS3 for GUI-based network emulation
- ns-3 and OMNeT++ for network simulation research
- Kathara and CORE for lightweight container/namespace emulation
- Filius for network education

For network engineers learning automation, I recommend starting with Containerlab for its excellent documentation and active community. For those requiring GUI-based tools or broad vendor appliance support, GNS3 remains the best choice.



https://github.com/cmu-sei/GHOSTS
GHOSTS is an agent orchestration framework that simulates realistic users on all types of computer systems, generating human-like activity across applications, networks, and workflows. Beyond simple automation, it can dynamically reason, chat, and create content via integrated LLMs, enabling adaptive, context-aware behavior. Designed for cyber training, research, and simulation, it produces realistic network traffic, supports complex multi-agent scenarios, and leaves behind realistic artifacts. Its modular architecture allows the addition of new agents, behaviors, and lightweight clients, making it a flexible platform for high-fidelity simulations.

https://github.com/named-data/mini-ndn
Mini-NDN is a lightweight networking emulation tool that enables testing, experimentation, and research on the NDN platform based on Mininet. Mini-NDN uses the NDN libraries, NFD, NLSR, and tools released by the NDN project to emulate an NDN network on a single system.

https://github.com/IPoAC-SMT/DONE
DONE (Docker Orchestrator for Network Emulation) is a simple network emulator, inspired by the IMUNES project. Starting from the features IMUNES offered, we decided to recreate some of them, improving both software reliability and the UX while reducing software dependencies to the bare minimum.

