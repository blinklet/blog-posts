% Open-source network simulation roundup 2025

In this annual update of my list of open-source network simulators and emulators, I check each project's development activity, verify the well-maintained projects, identify new projects that deserve attention, and consider projects that may be fading away.

## Top Projects

Three open-source network emulation projects stand out in 2026, due to their popularity, functionality, and development velocity. 

**[Containerlab](https://containerlab.dev/)** continues its impressive development pace, and seems to have cemented its position as a leading network emulation tool for developers. New features added in 2024 and 2025 include VM snapshot/restore functionality, expanded device support, a system for running labs on Kubernetes clusters, and improved container network configuration.

**[NetLab](https://netlab.tools/)** has matured significantly with regular updates through 2025, continuing to bring infrastructure-as-code concepts to networking labs. Most recently, and of personal interest to me,  NetLab added support for large BGP community lists in routing policies, which is useful for realistic BGP policy testing. The NetLab developers added many major features over the past two years.

**[GNS3](https://www.gns3.com/)** continues steady development and seems to be a leading network emulation tool for engineers. While the 2.x release is still the default download, the GNS3 team released a new 3.0 version that implemented major architectural changes in GNS3. GNS3 remains the most popular GUI-based open-source network emulator.

## Maintained Projects

Many open-source network simulation and emulation projects continue to be well maintained in 2026 and may be used with confidence. Each project's documentation is usable, the developers are responsive to issues and contributions, and the user community is engaged.

**[ns-3](https://www.nsnam.org/)** continues to be the premier open-source discrete-event network simulator. Recent additions include new Zigbee support and improved Wi-Fi simulation helpers. 

**[OMNeT++](https://omnetpp.org/)** shipped its latest release in November, 2025. New features included an AI notebook tool for analysis and Time-Sensitive Networking (TSN) tutorials.

**[Shadow](https://shadow.github.io/)** has evolved into a general-purpose discrete-event network simulator that directly executes real application code. The developer is also re-writing some Shadow components in Rust. Shadow is well maintained, and the development team responds to GitHub issues and pull requests in a timely manner.

**[Cloonix](https://clownix.net/)** continued active development in 2025 with multiple releases. This emulator provides a solid alternative for those preferring VM-based network emulation. The developer is looking for more users to excercise the emulator's features.

**[CORE](https://coreemu.github.io/core/)** is well-maintained with a new release arriving in May, 2025. The latest updates improved Docker support and added Podman nodes with Compose support.

**[IMUNES](https://github.com/imunes/imunes/)** delivered it's latest release in January 2025 and the project has seen new commits as recently as December 2025. IMUNES added FreeBSD 15 support and improved Docker support for Linux.

**[OpenConfig-KNE](https://github.com/openconfig/kne)** is actively maintained and its latest release was delivered in August, 2025. Recent updates include security fixes. The developers are evolving the tool into a general-purpose Kubernetes Network Emulation (KNE) tool for quickly setting up network topologies of containers running various device OSes.  

**[Filius](https://www.lernsoftware-filius.de/Herunterladen)**, an educational network simulator, continued development in 2025, delivering bug fixes and minor enhancements. No major features were added in the past two years. This German-language tool remains an excellent choice for teaching networking concepts to students.

**[Cooja](https://docs.contiki-ng.org/en/develop/doc/tutorials/Running-Contiki-NG-in-Cooja.html)** remains part of the [Contiki-NG](https://www.contiki-ng.org/) IoT operating system project and has received minor updates over the past two years.

**[Meshtasticator](https://github.com/GUVWAF/Meshtasticator)** continues to receive maintenance updates for Meshtastic mesh network simulation.

**[Kathara](https://www.kathara.org/)** has, over the past two years, focused on improving usability, the Python API, and Docker/Kubernetes workflows. The project also introduced a new lab checker tool.

**[Labtainers](https://nps.edu/web/c3o/labtainers)** continued active development over the past two years and its latest release was in December, 2025. This Docker-based cybersecurity lab environment now includes over 50 lab exercises.

## Resurrected Projects and New Projects

Some projects that I had previously considered to be retired have showed signs of life in 2026. I also found some interesting new (or new-to-me) projects worth watching.

**[cnet](https://teaching.csse.uwa.edu.au/units/CITS3002/cnet/index.php)** had previously removed its downloads from the web, but now they are back. Cnet is updated and is now available on Apple M-series processors running macOS Sonoma 14. It also runs on Linux systems. You can get the Linux installer from the University of Western Australia by running the command: `curl -s -o cnet-Linux-x86_64 https://teaching.csse.uwa.edu.au/units/CITS3002/cnet/downloads/cnet-Linux-x86_64`

**[Marrionet](https://www.marionnet.org/site/index.php/en/)** received a few bug fixes in May 2025. I had previously removed it from my list due to inactivity. I will not add it back to the list, yet, but I will keep an eye on this project in case it becomes active again.

**[Mini-NDN](https://github.com/named-data/mini-ndn)** has been available for over ten years and I am adding it to my list now because Mininet is fading away and this project, along with Mininet-WiFi, are forks of Mininet with continued development. Mini-NDN is a lightweight networking emulation tool that enables testing, experimentation, and research on [Named Data Networks (NDN)](https://named-data.net/).

**[Mininet-WiFi](https://mininet-wifi.github.io/)** is also a well-established project that I have written about before. I used to categorize it under "Mininet" but I promoted to its own line in my list in 2026. Again, it's because it is a more active fork of Mininet. In addition to base Mininet functionality, it offers some very interesting WiFi network emulation features. 

**[DONE (Docker Orchestrator for Network Emulation)](https://github.com/IPoAC-SMT/DONE)** is a simple network emulator, inspired by the IMUNES project. It is inspired by IMUNES but is its own unique creation. The developers say they aim to improve the user experience while reducing software dependencies to the bare minimum. It's relatively new, and has seen a few updates since it was released. I won't add it to my list, yet, but I will keep an eye out to see if it develops further.

## Projects Showing Signs of Decline

Other projects from my list have showed significant decline in development activity and user engagement over the past several years. 

### On Watch

The following projects are fading away due to significantly lower involvement from developers and/or users. I probably should remove them from my list, but I am not ready to give up on them.

**[EVE-NG Community Edition](https://www.eve-ng.net/index.php/community/)** last received an update in July, 2024. The EVE-NG development team's focus remains almost exclusively on the commercial EVE-PRO version. In my opinion, users who require active development and open-source should consider alternatives like GNS3 or Containerlab.

**[Mininet](https://mininet.org/)** remains stable at version 2.3.0, last released in February 2021. It continues to work well for SDN development and education, but active development has stopped. GitHub issues are no longer responded to and pull requests are piling up with no action from the maintainers. Also, [no one is responding to questions](https://mailman.stanford.edu/pipermail/mininet-discuss/2025-May/008806.html) on the Mininet mailing list. However, Mininet remains popular with users, based on the level of interest in Mininet posts in my blog, and it is the base for forked projects like [Mininet-WiFi](https://mininet-wifi.github.io/), [Mini-NDN](https://github.com/named-data/mini-ndn), and [Containernet](https://containernet.github.io/). I will keep an eye on all these projects and consider replacing Mininet in my list with one of its forks.

**[NEmu](https://gitlab.com/v-a/nemu/-/wikis/home)** virtual networking environment implemented some bug fixes or minor improvements in the [NEmu GitLab repo](https://gitlab.com/v-a/nemu/) in 2025, but has published no releases since 2023.

**[CupCarbon](http://cupcarbon.com)**, an open source internet of things (IoT) and wireless sensor network (WSN) simulator, has not been updated in 4 years. It seems like further development is no longer open source and has been [moved to a closed-source version of the product](https://github.com/bounceur/CupCarbon/issues/31), re-named [CupCarbon-Klines](http://cupcarbon.com/CupCarbon-Tutorials_7.html). The new version is an "Agentic AI and Digital Twin IoT Simulation Platform". While I investigate the licensing story for this project, I'll keep this on my list because CupCarbon-Klines remains free-to-use and seems interesting. 

### Removed from my Lists

I removed the following projects from my list of tracked projects in 2026. They appear to me to be no longer maintained.

**[vrnetlab](https://github.com/vrnetlab/vrnetlab)**, the original at _github.com/vrnetlab/vrnetlab_, has not received commits in over two years and has no published releases. Users should use the [srl-labs/vrnetlab](https://github.com/srl-labs/vrnetlab) fork, which is actively maintained by Containerlab.and supports the use of VMs in Containerlab. I intend to remove the original vrnetlab project from my list of active projects and will track it as part of Containerlab.

**[Linux Network Stack Test (LNST)](http://lnst-project.org/)** appears to be dormant. The project has no GitHub releases and the [LNST mailing list](https://lists.fedorahosted.org/archives/list/lnst-developers@lists.fedorahosted.org/) shows zero activity.

**[VNX](http://web.dit.upm.es/vnxwiki/index.php/Main_Page)** has not received updates since September 2020. While the software still works, users should consider more actively maintained alternatives like Containerlab or Kathara for new projects. 

**[Educational Network Simulator](https://malkiah.github.io/NetworkSimulator/)** has stopped development. The [hosted web app](https://malkiah.github.io/NetworkSimulator/simulator01.html) is not working well and the [code](https://github.com/malkiah/NetworkSimulator) has not been updated in a long time.

**[CS4G Netsim](https://netsim.erinn.io/)** was a student project that ended. The [hosted web app](https://netsim.erinn.io/) continues to run for educational purposes. The [*NetSim* source code](https://github.com/errorinn/netsim) remains on GitHub.

**[tinet](https://github.com/tinynetwork/tinet)** has not been updated in several years and the developers are not responding to pull requests. I think this project is retired.

### Removed for Other Reasons

I removed a couple of projects from my list because I decided to tighten the focus of my blog to emulators/simulators that can run on a personal computer.

**[Colosseum](https://www.northeastern.edu/colosseum/)** continues as a research platform at Northeastern University. I will remove this from my list because I am tightening the focus of this list to emulators/simulators that can run on a personal computer. 

**[CrowNet](https://github.com/roVer-HM/crownet)** development activity remains low, with only minor updates. I will move this to the "Tools" category because it is an auxiliary tool for simulating crowds and I am tightening the focus of this list to network emulators/simulators.

## Conclusion

The 2024-2025 period saw continued growth in container-based network emulation tools, with Containerlab leading the way. 

Traditional VM-based emulators like GNS3 remain popular for their graphical interfaces and broad hardware vendor support.

For software developers and network engineers learning automation in 2026, I recommend starting with Containerlab for its excellent documentation and active community. For those requiring GUI-based tools, I believe that GNS3 is the best choice in 2026.





