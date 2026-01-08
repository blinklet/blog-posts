% Open-source network simulation roundup 2025

This is my annual update, where I check each open-source network simulation and emulation projects's activity level, document version changes to well-maintained projects, identify new projects that deserve attention, and consider projects that may be fading away.

## Active projects

**[Containerlab](https://containerlab.dev/)** continues its impressive development pace, and seems to have cemented its position as a leading network emulation tool for developers. New features added in 2024 and 2025 include VM snapshot/restore functionality, expanded device support, a system for running labs on Kubernetes clusters, and improved container network configuration.

**[NetLab](https://netlab.tools/)** has matured significantly with regular updates through 2025, continuing to bring infrastructure-as-code concepts to networking labs. Most recently, and of personal interest to me,  NetLab added support for large BGP community lists in routing policies, which is useful for realistic BGP policy testing. The NetLab developers added many major features over the past two years.

**[GNS3](https://www.gns3.com/)** continues steady development and seems to be a leading network emulation tool for engineers. While the 2.x release i still the default download, the GNS3 team released a new 3.0 version that implemented major architectural changes in GNS3. GNS3 remains the most popular GUI-based network emulator.

## Steady-state projects

**[ns-3](https://www.nsnam.org/)** continues to be the premier open-source discrete-event network simulator. Recent additions include new Zigbee support and improved Wi-Fi simulation helpers. 

**[Shadow](https://shadow.github.io/)** has evolved into a general-purpose discrete-event network simulator that directly executes real application code. The developer is also re-writing some Shadow components in Rust. Shadow is well maintained, and the development team responds to GitHub issues and pull requests in a timely manner.

**[Kathara](https://www.kathara.org/)** has, over the past two years, focused on improving usability, the Python API, and Docker/Kubernetes workflows. The project also introduced a new lab checker tool.

**[Filius](https://www.lernsoftware-filius.de/Herunterladen)**, an educational network simulator, continued development in 2025, delivering bug fixes and minor enhancements. No major deatures were added in the past two years. This German-language tool remains an excellent choice for teaching networking concepts to students.

**[OpenConfig-KNE](https://github.com/openconfig/kne)**
  * *OpenConfig-KNE* is actively maintained with release **v0.3.0 on August 4, 2025** (up from v0.1.17 in February 2024).
  * Recent updates include CVE security fixes.
  * The [*OpenConfig-KNE* source code](https://github.com/openconfig/kne) is on GitHub.
**Maybe changing its focus. Look at the web site**

**[Cloonix](https://clownix.net/)**
  * *Cloonix* continues active development with release **v53.01 on November 4, 2025** (up from v34-00 in December 2023).
  * This KVM-based emulator provides a solid alternative for those preferring VM-based network emulation.
  * **two steps forward, two steps back**

**[CORE](https://coreemu.github.io/core/)**
  * *CORE* is well-maintained with release **v9.2.1 on May 19, 2025** (up from v9.0.3 in August 2023).
  * The 9.2.x releases improved Docker support and added Podman nodes with compose support.
  * The [*CORE* source code](https://github.com/coreemu/core) is on GitHub.

**[IMUNES](https://github.com/imunes/imunes/)**
  * *IMUNES* has been actively developed with recent commits as of December 2025. The project added FreeBSD 15 support and improved Docker support for Linux.
  * The [*IMUNES* source code](https://github.com/imunes/imunes/) is on GitHub.

**[ns-3](https://www.nsnam.org/)** continues to be the premier open-source discrete-event network simulator. Recent additions include new Zigbee support and improved Wi-Fi simulation helpers.

**[OMNeT++](https://omnetpp.org/)**
  * *OMNeT++* remains actively maintained with release **6.3.0 on November 12, 2025** (up from 6.0.3 in February 2024).
  * New features include an AI notebook tool for analysis and TSN (Time-Sensitive Networking) tutorials.
  * The [OMNET++ source code](https://github.com/omnetpp/omnetpp) is on GitHub.

**[Meshtasticator](https://github.com/GUVWAF/Meshtasticator)**
  * *Meshtasticator* continues to receive maintenance updates for Meshtastic mesh network simulation.
  * The [*Meshtasticator* source code](https://github.com/GUVWAF/Meshtasticator) is on GitHub.

**[Cooja](https://docs.contiki-ng.org/en/develop/doc/tutorials/Running-Contiki-NG-in-Cooja.html)**
  * *Cooja* remains part of the [Contiki-NG](https://www.contiki-ng.org/) IoT operating system project.
  * The [*Cooja* source code](https://github.com/contiki-ng/cooja) is on GitHub.
  Contiki / Cooja continue to see minor updates

**[Labtainers](https://nps.edu/web/c3o/labtainers)**
  * *Labtainers* continues active development with release **v1.4.4h on December 27, 2025** (up from v1.3.7u in November 2023).
  * This Docker-based cybersecurity lab environment includes over 50 lab exercises.
  * The [*Labtainers* source code](https://github.com/mfthomps/Labtainers) is on GitHub.



## Up-and-Coming and Resurrected Projects

I found some interesting new projects worth watching:

Marrionet is seeing bug fixes as recently as May 2025 -- should I add it back to the list?
https://launchpad.net/marionnet/
https://www.marionnet.org/site/index.php/en/
I need to try it out again and see that it works in Ubuntu 26.04 (when available)

**[cnet](https://teaching.csse.uwa.edu.au/units/CITS3002/cnet/index.php)**
  * Updated and available on  Apple M-series 'Silicon' processor (built on macOS Sonoma 14.3)
Apple with 64-bit Intel processor (built on macOS Sonoma 14.3)
Linux on 64-bit Intel processor (built on Ubuntu 23.10) 
`curl -s -o cnet-Linux-x86_64 https://teaching.csse.uwa.edu.au/units/CITS3002/cnet/downloads/cnet-Linux-x86_64`

https://github.com/cmu-sei/GHOSTS
GHOSTS is an agent orchestration framework that simulates realistic users on all types of computer systems, generating human-like activity across applications, networks, and workflows. Beyond simple automation, it can dynamically reason, chat, and create content via integrated LLMs, enabling adaptive, context-aware behavior. Designed for cyber training, research, and simulation, it produces realistic network traffic, supports complex multi-agent scenarios, and leaves behind realistic artifacts. Its modular architecture allows the addition of new agents, behaviors, and lightweight clients, making it a flexible platform for high-fidelity simulations.
I'll add this to the Tools section...

https://github.com/named-data/mini-ndn
Mini-NDN is a lightweight networking emulation tool that enables testing, experimentation, and research on the NDN platform based on Mininet. Mini-NDN uses the NDN libraries, NFD, NLSR, and tools released by the NDN project to emulate an NDN network on a single system.

https://github.com/IPoAC-SMT/DONE
DONE (Docker Orchestrator for Network Emulation) is a simple network emulator, inspired by the IMUNES project. Starting from the features IMUNES offered, we decided to recreate some of them, improving both software reliability and the UX while reducing software dependencies to the bare minimum.



## Projects Showing Signs of Decline

**[EVE-NG Community Edition](https://www.eve-ng.net/index.php/community/)**
  * The *EVE-NG Community Edition* received an update to **v6.0.2-4 on July 21, 2024**, but development focus remains on the paid EVE-PRO version.
  * ⚠️ Users who require active community edition development should consider alternatives like GNS3 or Containerlab.

**[vrnetlab](https://github.com/vrnetlab/vrnetlab)** (the original at github.com/vrnetlab/vrnetlab) has not received commits in over two years and has no published releases. Users should use Containerlab, instead. The the [srl-labs/vrnetlab](https://github.com/srl-labs/vrnetlab) fork, is actively maintained by Containerlab.and supports the use of VMs in Containerlab. I intend to remove the "classic" vrnetlab project from my list of active projects.

**[Linux Network Stack Test (LNST)](http://lnst-project.org/)**
  * *LNST* development appears **dormant**. The project has no GitHub releases and the mailing list shows minimal activity.
  * The [*LNST* source code](https://github.com/LNST-project/lnst) is on GitHub.


**[VNX](http://web.dit.upm.es/vnxwiki/index.php/Main_Page)** has not received updates since September 2020. While the software still works, users should consider more actively maintained alternatives like Containerlab or Kathara for new projects.
**remove**


**[Mininet](https://mininet.org/)** remains stable at version 2.3.0, released in February 2021. It continues to work well for SDN development and education, but active development has slowed significantly.
  * *Mininet* development has been stable but quiet. The **last major release was v2.3.0 in February 2021**.
  * While Mininet remains functional and useful for SDN education and research, users should be aware that active development has slowed significantly.
  * The [*Mininet* mailing list](https://mailman.stanford.edu/pipermail/mininet-discuss/) is still available.
  * The [*Mininet* source code](https://github.com/mininet/mininet) is on GitHub.
Mininet-WiFi   https://mininet-wifi.github.io/
Mini-NDN   https://github.com/named-data/mini-ndn
https://mailman.stanford.edu/pipermail/mininet-discuss/2025-May/008806.html
(no one is responding to questions in the Mininet mailing list)
**[Containernet](https://containernet.github.io/)**
  * Still maintained, as of one and a half years ago
  
**[Educational Network Simulator](http://projects.bardok.net/educational-network-simulator/)**
  * The [hosted web app](http://projects.bardok.net/networks-live/simulator01.html) remains available for educational use.
  * The [source code](https://github.com/malkiah/NetworkSimulator) is on GitHub.
Hosted web site is down
no updates in a long time
**Remove**

**[CS4G Netsim](https://netsim.erinn.io/)**
  * The [hosted web app](https://netsim.erinn.io/) continues to run for educational purposes.
  * The [*NetSim* source code](https://github.com/errorinn/netsim) is on GitHub.
  **Remove** no longer maintained, [web site does not accept new users](https://github.com/errorinn/netsim/issues/26)

**[CupCarbon](http://cupcarbon.com)**
  * *CupCarbon* IoT/WSN simulator development status is unclear. The license status remains undeclared.
**Not updated in 4 years. Seems like further development is no longer open source (see https://github.com/bounceur/CupCarbon/issues/31). Remove from list**


**[CrowNet](https://github.com/roVer-HM/crownet)**
  * *CrowNet* development activity remains low, with only minor updates.
  **Remove** because I am tightening the focus of this list to emulators/simulators that can run on a personal computer

**[NEmu](https://gitlab.com/v-a/nemu/-/wikis/home)**
  * *NEmu* virtual networking environment continues development.
  * The [*NEmu* source code](https://gitlab.com/v-a/nemu) is on GitLab.
  ** Keep, for now, some bug fixes or minor improvements in repo in 2025 but no releases since 2023

* **[tinet](https://github.com/tinynetwork/tinet)**
  * *tinet* last received updates with release **v0.0.4 on January 17, 2024**.
  * Development has been quiet since then, but the tool remains functional for quickly generating network topologies using Docker and network namespaces.
  * The [*tinet* source code](https://github.com/tinynetwork/tinet) is on GitHub.
**Remove** not updated and ignoring pull requests

## Removed for other reasons

**[Colosseum](https://www.northeastern.edu/colosseum/)**
  * The *Colosseum* emulator continues as a research platform. Component updates occur independently.
  * [Source code for *Colosseum* components](https://www.northeastern.edu/colosseum/cellular-software/) is available on the Colosseum website.
  **Remove** because I am tightening the focus of this list to emulators/simulators that can run on a personal computer

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





