% Twenty network emulators and five network simulators you can use in 2023

I surveyed the current state of the art in open-source network emulation and simulation. I also reviewed the development and support status of all the network emulators and network simulators previously featured in my blog.  

Of all the network emulators and network simulators I mentioned in my blog over the years, I found that eighteen of them are still active projects. I also found seven new projects that you can try. See below for a brief update about each tool.

<!--more-->

# Active projects

Below is a list of the tools previously featured in my blog that are, in my opinion, still actively supported.

## Cloonix

[Cloonix](http://clownix.net/) version 28 was released in January 2023. Cloonix stitches together Linux networking tools to make it easy to emulate complex networks by linking virtual machines and containers. Cloonix has both a command-line-interface and a graphical user interface.

The Cloonix web site now has a new address at: [clownix.net](http://clownix.net/) and theCloonix project now [hosts code on Github](https://github.com/clownix/cloonix). Cloonix adopted a [new release numbering scheme](http://clownix.net/doc_stored/) since I reviewed it in 2017. So it is now at "v28".

## Cloudsim

[CloudSim](http://www.cloudbus.org/cloudsim/) is still [maintained](https://github.com/Cloudslab/cloudsim). Cloudsim is a network simulator that enables modeling, simulation, and experimentation of emerging Cloud computing infrastructures and application services. It is part of an [ecosystem](http://www.cloudbus.org/) of [projects and extensions](https://github.com/Cloudslab), such as [iFogSim](https://github.com/Cloudslab/iFogSim). CloudSim release 6 was delivered in August, 2022.

## cnet

The [cnet](https://www.csse.uwa.edu.au/cnet/index.php) network simulator is actively maintained. It enables development of and [experimentation](https://www.csse.uwa.edu.au/cnet/introduction.php) with a variety of data-link layer, network layer, and transport layer networking protocols in networks consisting of any combination of wide-area-networking (WAN), local-area-networking (LAN), or wireless-local-area-networking (WLAN) links [^6]. The project maintainers say it is open source but you must provide you name and e-mail address to download the application source code. [Version 3.5.3 was released in April 2022](https://www.csse.uwa.edu.au/cnet/changelog.php).

[^6]: From https://www.csse.uwa.edu.au/cnet/index.php on February 15, 2023

## Containerlab

[Containerlab](https://containerlab.dev/) is still very active. Containerlab is an open-source network emulator that quickly builds network test environments in a devops-style workflow. It provides a command-line-interface for orchestrating and managing container-based networking labs and supports containerized router images available from the major networking vendors. The [most recent release was 0.36.1](https://github.com/srl-labs/containerlab/releases/tag/v0.36.1), released in January, 2023.  

## CORE

The [*Common Open Research Emulator* (CORE)](http://coreemu.github.io/core/) is still active.  CORE consists of a GUI for drawing topologies of lightweight virtual machines, and Python modules for scripting network emulation [^3]. The most recent CORE release, 9.0.1, was [released in November 2022](https://github.com/coreemu). The CORE community is very active on the [CORE Discord server](https://discord.com/channels/382277735575322625/). 

[^3]: From https://github.com/coreemu/core#about on February 12, 2023

## EVE-NG

[EVE-NG Community Edition](https://www.eve-ng.net/index.php/community/) continues to receive updates. It is a network emulator that supports virtualized commercial router images, such as Cisco and NOKIA, and open-source routers. The EVE-NG team seems to focus on the commercial EVE-NG product but still supports the open-source EVE-NG Community version. EVE-NG Community Edition v5.0.1-13 was released in August 2022. I found a new project that creates a [Python API for EVE-NG](https://github.com/ttafsir/evengsdk). 

While I was refreshing this list, I realized EVE-NG Community Edition is not open-source software. It was originally an open-source project called [UNetLab](https://github.com/dainok/unetlab), but the developers turned it into a commercial project and renamed it. I am keeping EVE-NG on this list because the Community Edition is still free to use.

## GNS3

[GNS3](https://gns3.com/) continues to deliver new versions. GNS3 is a very popular network emulation tool that is primarily used to emulate networks comprised of commercial routers, but it also supports open-source routers. It is often used by professionals studying for certification exams. [GNS3 version 2.2.37](https://github.com/GNS3) was released in January 2023.

## IMUNES

[IMUNES](http://imunes.net/) is stable. It is a network emulator. IMUNES and CORE share the same code heritage and their user interfaces are similar, but they have diverged from each other since 2012. IMUNES has seen less development activity than CORE in the past few years. The IMUNES developer made an update a few months ago to support the [Apple M1 processor on Ubuntu 20.04 LTS](https://github.com/imunes/vroot-linux/commit/e49e67b9028c472c1142730dd94a7e4e41a71c08). 

## Kathara

[Kathara](https://www.kathara.org/) is still being [maintained](https://github.com/KatharaFramework/Kathara). It is a network emulator that uses Kubernetes as virtualization manager, which lets you run network emulation scenarios on a variety of environments, including the public cloud. It allows configuration and deployment of virtual networks featuring SDN, NFV, and traditional routing protocols, such as BGP and OSPF. Kathara offers Python APIs that allow user to script the creation of network scenarios. [Version 3.5.5](https://github.com/KatharaFramework/Kathara/releases/tag/3.5.5) was released in January, 2023. 

Kathara was created by the original developers of [Netkit](https://www.netkit.org/) and is intended to be the next evolution in network emulation. A [fork of the original Netkit](https://github.com/netkit-jh/netkit-jh-build) is still being maintained by another author and has [updated documentation](https://netkit-jh.github.io/docs/).

## Labtainers

[Labtainers](https://nps.edu/web/c3o/labtainers) is still being [maintained](https://github.com/mfthomps/Labtainers). It is a network emulator that enable researchers and students to explore network security topics. It has [many lab scenarios](https://nps.edu/web/c3o/labtainer-lab-summary1) based on security topics. [Version 1.3.7](https://github.com/mfthomps/Labtainers/releases/tag/v1.3.7q) was released in January 2023

## Linux Network Test Stack

The [*Linux Network Test Stack*](http://lnst-project.org/) (LNTS), is still being [maintained](https://github.com/lnst-project/lnst). It is a Python package that enables developers to build network emulation scenarios using a Python program. You may use LNTS to control a network of hardware nodes or to control an emulated network of containers. [LNTS version 15.1](https://github.com/LNST-project/lnst/releases/tag/v15.1) was released in August 2019 but the developer is merging pull requests in GitHub as recent as a few weeks ago so I believe this project is still active.

## Mininet

[Mininet](http://mininet.org/) published its last version, 2.3.0, two years ago but it is still being maintained and remains a popular network emulator. It is designed to support research and education in the field of Software Defined Networking systems. On [Mininet's Github repo](https://github.com/mininet/mininet), I see some minor development activity in recent months. [Mininet Wifi](https://mn-wifi.readthedocs.io/en/latest/) has about the same [development activity](https://github.com/intrig-unicamp/mininet-wifi). Both the [Mininet mailing list](https://mailman.stanford.edu/mailman/listinfo/mininet-discuss) and [Mininet WiFi forum](https://groups.google.com/g/mininet-wifi-discuss) are still active. I also found some  examples of [building Mininet](https://github.com/gabisurita/network-labs) [labs](https://github.com/mkucukdemir/mininet-topology) using [Python and FRR](https://github.com/bobuhiro11/mininetlab)

[Mini-NDN](https://github.com/named-data/mini-ndn) is a fork of Mininet designed for emulating Named Data Networking. It's most recent release was at the end of 2021.  

[Containernet](https://containernet.github.io/) is a fork of Mininet that allows to use Docker containers as hosts in emulated network topologies. It is still being [maintained](https://github.com/containernet/containernet). It's last release was in December, 2019, but its GitHub repository has seen a few pull requests merged in 2022.

## NEmu

[NEmu](https://gitlab.com/v-a/nemu), the *Network Emulator for Mobile Universes*, is still being maintained. It creates QEMU VMs to build a dynamic virtual network and does not require root access to your computer. NEmu users write Python scripts to describe the network topology and functionality. [Version 0.8.0](https://gitlab.com/v-a/nemu/-/tags/0.8.0) was released in January 2023. 

## Netlab

[NetLab](https://github.com/ipspace/netlab) is actively maintained. NetLab uses Libvirt and Vagrant to set up a simulated network of configured, ready-to-use devices. It brings DevOps-style infrastructure-as-code and CI/CD concepts to networking labs. [Netlab v1.5](https://github.com/ipspace/netlab/releases/tag/release_1.5.0) was released in February, 2023.

## ns-3

[ns-3](https://www.nsnam.org/) is actively maintained and supported. It is a free, open-source discrete-event network simulator for Internet systems, targeted primarily for research and educational use. [Version 3.37](https://www.nsnam.org/news/2022/11/01/ns-3-37-released.html) was released in November 2022. The [ns-3 source code](https://gitlab.com/nsnam/ns-3-dev#table-of-contents) is on GitLab.


## OMnet++

[Omnet++](https://omnetpp.org/) is in active development. It is a discreet-event network simulator used by many universities for teaching and research. It is published under a license called the [Academic Public License](https://opensource.org/licenses/APL-1.0), which appears to be unique to the Omnet++ project. Commercial users must pay for a license, but academic or personal use is permitted without payment. Non-commercial developers have rights similar to the GPL. [OMNeT++ 6.0.1](https://github.com/omnetpp/omnetpp/releases/tag/omnetpp-6.0.1) was released in September 2022.

## OpenConfig-KNE

[OpenConfig-KNE](https://github.com/openconfig/kne), *Kubernetes Network Emulation*, is actively maintained. It is a network emulator developed by the [OpenConfig](https://www.openconfig.net/) foundation. It extends basic Kubernetes networking so it can support point-to-point virtual connections between nodes in an arbitrary network topology. Additionally, the [OpenConfig organization encourages](https://www.techrepublic.com/article/how-to-get-started-with-openconfig-and-yang-models/) the major networking equipment vendors like [Nokia](https://learn.srlinux.dev/tutorials/infrastructure/kne/), [Cisco](https://www.cisco.com/c/en/us/td/docs/switches/datacenter/nexus9000/sw/93x/progammability/guide/b-cisco-nexus-9000-series-nx-os-programmability-guide-93x/b-cisco-nexus-9000-series-nx-os-programmability-guide-93x_chapter_011001.html), and [Juniper](https://www.juniper.net/documentation/us/en/software/junos/open-config/topics/concept/openconfig-overview.html) to produce standard data models, for configuration, and standard container implementations, for deployment. OpenConfig-KNE also supports standard containers so it can emulate networks comprised of open-source appliances. [Version 0.1.7 was released in December 2022](https://github.com/openconfig/kne/releases/tag/v0.1.7).

## Shadow

[Shadow](https://shadow.github.io/) is still under active development. It is a discrete-event network simulator that directly executes real application code, enabling you to simulate distributed systems with thousands of network-connected processes in realistic and scalable private network experiments using your laptop, desktop, or server running Linux [^4]. [Shadow v2.4.0 was released in January 2023](https://github.com/shadow/shadow/releases/tag/v2.4.0).

[^4]: From https://shadow.github.io/docs/guide/ on February 12, 2023

## VNX

[*Virtual Networks over Linux* (VNX)](http://web.dit.upm.es/vnxwiki/index.php/Main_Page) is stable since 2020. But, [new filesystems](http://vnx.dit.upm.es/vnx/filesystems/) were added in January 2023 so there is still support. VNX is an open-source network simulation tool that builds and modifies virtual network test beds automatically from a user-created network description file. The latest version of VNX was [released on Sep 14th, 2020](http://web.dit.upm.es/vnxwiki/index.php/Vnx-latest-features)

## vrnetlab

[vrnetlab](https://github.com/vrnetlab/vrnetlab) has slowed down development activity. The last commit was in December 2021, which is recent enough. However, on the GitHub repository there are many pull requests open and many issues that have not received a response. I think, for now, I keep listing vrnetlab on the sidebar because some parts of vrnetlab and the vrnetlab documentation may still be useful to users of [Containerlab](https://containerlab.dev/)

# New tools

I surveyed the Internet for information about network emulators and simulators that were created after 2019, which was the last time I did a broad survey of available simulation tools.

I found seven tools that were new to me, and list them all below. Most are related to the emulation of wireless networks and core networks, which is very interesting to me because I could not find emulators for these types of networks back in 2019.

## Colosseum

[Colosseum](https://www.northeastern.edu/colosseum/) provides open-source wireless software for [wireless network emulation](https://docs.srsran.com/en/latest/). The software appears to be based on standard PC hardware and radios. I wonder if one can emulate the radios and build a completely virtual lab, maybe by combining it with [ns-O-RAN](https://openrangym.com/ran-frameworks/ns-o-ran) or [GNUradio](https://wiki.gnuradio.org/index.php?title=What_Is_GNU_Radio). 

This project looks interesting to me because it seems to have open-source versions of key components in wireless RAN and Core networks. The project is made up of many different sub-projects. [srsRAN 22.10](https://github.com/srsran/srsRAN) was released in November 2022.

## Cooja

The [Cooja IoT network emulator](https://docs.contiki-ng.org/en/develop/doc/tutorials/Running-Contiki-NG-in-Cooja.html) is part of the new [Contiki-ng](https://www.contiki-ng.org/) project. Cooja enables fine-grained simulation/emulation of IoT networks that use the Contiki-NG IOT operating system. The [Contiki-NG forum](https://gitter.im/contiki-ng) is very active, with most questions receiving a reply. Cooja has not yet had an official release but the most recent [pull requests were merged](https://github.com/contiki-ng/cooja/pulls?q=is%3Apr+is%3Aclosed) in February 2023.

## CrowNet

[CrowNet](https://github.com/roVer-HM/crownet) is an open-source simulation environment which models pedestrians using wireless communication. It can be used to evaluate pedestrian communication in urban and rural environments. It is based on Omnet++. Development is active. [Version 0.9.0](https://github.com/roVer-HM/crownet/releases/tag/v0.9.0) was released in May, 2022.

## CupCarbon

[CupCarbon](http://cupcarbon.com/) simulates wireless networks in cities and [integrates data](https://www.opensourceforu.com/2019/09/simulating-smart-cities-with-cupcarbon/) from [OpenStreetMap](https://www.openstreetmap.org/). The code is available on [GitHub](https://github.com/bounceur/CupCarbon) but there is no license information and there has been no official release, although some of the recent commit refers to Version 5.2.

## Meshtasticator

[Meshtasticator](https://github.com/GUVWAF/Meshtasticator) is an emulator for Meshtastic software. [Meshtastic](https://meshtastic.org/) is a project that enables you to use inexpensive LoRa radios as a long range off-grid communication platform in areas without existing or reliable communications infrastructure. This project is 100% community driven and open source! [^1] Meshtasticator enables you to emulate the operation of a network of Meshtastic devices communicating with teach other over LoRa radio. It is actively being developed. There is no tagged release but GitHub pull requests have been merged as recently as February 2023.

[^1]: From Meshtastic Introduction: https://meshtastic.org/docs/introduction; February 2023

## MimicNet

[MimicNet](https://github.com/eniac/MimicNet) is a network simulator that uses machine learning to estimate the performance of large data centre networks. It was released in July 2019 but has had no updates since then. MimicNet is the result of a research project and, now that the [paper](https://dl.acm.org/doi/10.1145/3452296.3472926) is published, the project appears to be in maintenance mode. Developers still respond to issues and the last commit was in July 2022. 

## Tinet

[Tinet](https://github.com/tinynetwork/tinet), or *Tiny Network*,  is another container-based network emulator that has a few good scenarios described in the *examples* folder in its repository.  It is intended to be a simple tool that takes a YAML config file as input and generates a shell script to construct virtual network. [Version 0.0.2](https://github.com/tinynetwork/tinet/releases/tag/v0.0.2) was released in July 2020 but [development has continued](https://github.com/tinynetwork/tinet) since then, with GitHub pull requests being merged as recently as January 2023


# Removed from my list

I removed two projects from my list of network emulators and simulators.

[Antidote](https://github.com/nre-learning/antidote) and [NRE Labs](https://github.com/nre-learning/nrelabs-docs) are retired. See the [announcement on the NRE Labs site](https://nrelabs.io/2021/12/goodbye-for-now/)

[Wistar](https://github.com/Juniper/wistar) seems to have been abandoned. There have been no updates in four years and no activity in the [Wistar Slack channel](https://wistar-vtm.slack.com/)

# Conclusion

I refreshed my list of network emulators and simulators. I now have eighteen projects on my active list. I found seven new projects that I will look at in the future and determine if any should be added to my list. I removed two projects from my list.

