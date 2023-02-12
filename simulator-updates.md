# Still active

## GNS3

[GNS3](https://gns3.com/) continues to deliver new versions. GNS3 is a very popular network emulation tool that is primarily used to emulate networks of commercial routers, but also supports open-source routers, and is often used by professionals studying for certification exams. [GNS3 version 2.2.37](https://github.com/GNS3) was released in January 2023.

## EVE-NG

[EVE-NG Community Edition](https://www.eve-ng.net/index.php/community/) continues to receive updates. It is a network emulator that supports virtualized commercial router images, such as Cisco and NOKIA, and open-source routers. The EVE-NG team seems to focus on the commercial EVE-NG product but still supports the open-source EVE-NG Community version. EVE-NG Community Edition v5.0.1-13 was released in August 2022.

## Mininet

[Mininet](http://mininet.org/) published its last version, 2.3.0, two years ago. This open-source network emulator is designed to support research and education in the field of Software Defined Networking systems. On [Mininet's Github repo](https://github.com/mininet/mininet), I see some minor development activity in recent months. [Mininet Wifi](https://mn-wifi.readthedocs.io/en/latest/) has about the same [development activity](https://github.com/intrig-unicamp/mininet-wifi). Both the [Mininet mailing list](https://mailman.stanford.edu/mailman/listinfo/mininet-discuss) and [Mininet WiFi forum](https://groups.google.com/g/mininet-wifi-discuss) are still active.

[Mini-NDN](https://github.com/named-data/mini-ndn) is a fork of Mininet designed for emulating Named Data Networking. It's most recent release was at the end of 2021.  I found some  examples of [building Mininet](https://github.com/gabisurita/network-labs) [labs](https://github.com/mkucukdemir/mininet-topology) using [Python and FRR](https://github.com/bobuhiro11/mininetlab)

[Containernet](https://containernet.github.io/) is a fork of Mininet that allows to use Docker containers as hosts in emulated network topologies. It is still being [maintained](https://github.com/containernet/containernet). It's last release was in December, 2019, but its GitHub repository has seen a few pull requests merged in 2022.

## Kathara

[Kathara](https://www.kathara.org/) is still being [maintained](https://github.com/KatharaFramework/Kathara). It is a network emulator that uses Python and Docker. It allows easy configuration and deployment of arbitrary virtual networks featuring SDN, NFV and traditional routing protocols such as BGP and OSPF. [Version 3.5.5](https://github.com/KatharaFramework/Kathara/releases/tag/3.5.5) was released in January, 2023. 

Kathara was created by the original developers of [Netkit](https://www.netkit.org/) and is intended to be the next evolution in network emulation. A [fork of the original Netkit](https://github.com/netkit-jh/netkit-jh-build) is still being maintained by another author and has [updated documentation](https://netkit-jh.github.io/docs/).

## CORE

The [Common Open Research Emulator (CORE)](http://coreemu.github.io/core/) is still active.  CORE consists of a GUI for drawing topologies of lightweight virtual machines, and Python modules for scripting network emulation [^3]. The most recent CORE release, 9.0.1, was [released in November 2022](https://github.com/coreemu). The CORE community is very active on the [CORE Discord server](https://discord.com/channels/382277735575322625/). 

[^3]: From https://github.com/coreemu/core#about on February 12, 2023

## IMUNES

[IMUNES](http://imunes.net/) is stable. The developer made an update a few months ago to support the [Apple M1 processor on Ubuntu 20.04 LTS](https://github.com/imunes/vroot-linux/commit/e49e67b9028c472c1142730dd94a7e4e41a71c08). IMUNES and CORE share the same code heritage and their user interfaces are similar, but they have diverged from each other since 2012. IMUNES has seen less development activity than CORE in the past few years.

## Containerlab

[Containerlab](https://containerlab.dev/) is still very active. Containerlab is an open-source network emulator that quickly builds network test environments in a devops-style workflow. It provides a command-line-interface for orchestrating and managing container-based networking labs and supports containerized router images available from the major networking vendors. The [most recent release was 0.36.1](https://github.com/srl-labs/containerlab/releases/tag/v0.36.1), released in January, 2023.  

## Cloonix

[Cloonix](http://clownix.net/) version 28 was released in January 2023. Cloonix stitches together Linux networking tools to make it easy to emulate complex networks by linking virtual machines and containers. Cloonix has both a command-line-interface and a graphical user interface.

Cloonix now has a new URL at: [clownix.net](http://clownix.net/) and now [hosts code on Github](https://github.com/clownix/cloonix). Cloonix adopted a [new release number scheme](http://clownix.net/doc_stored/) since I reviewed it in 2017. So it is now at "v28".

## VNX

[Virtual Networks over Linux (VNX)](http://web.dit.upm.es/vnxwiki/index.php/Main_Page) has had no updates since September 2020. But, [new filesystems](http://vnx.dit.upm.es/vnx/filesystems/) were added in January 2023 so there is still support. VNX is an open-source network simulation tool that builds and modifies virtual network test beds automatically from a user-created network description file.

## Shadow

[Shadow](https://shadow.github.io/) is still under active development. It is a discrete-event network simulator that directly executes real application code, enabling you to simulate distributed systems with thousands of network-connected processes in realistic and scalable private network experiments using your laptop, desktop, or server running Linux [^4]. [Shadow v2.4.0 was released in January 2023](https://github.com/shadow/shadow/releases/tag/v2.4.0).

[^4]: From https://shadow.github.io/docs/guide/ on February 12, 2023

## Netlab

[NetLab](https://github.com/ipspace/netlab) is actively maintained. NetLab uses Libvirt and Vagrant to quickly set up a simulated network of configured, ready-to-use devices. It brings DevOps-style infrastructure-as-code concepts to networking labs. [Netlab v1.5](https://github.com/ipspace/netlab/releases/tag/release_1.5.0) was released in February, 2023.

## ns-3

[ns-3](https://www.nsnam.org/) is actively maintained and supported. It is a free, open-source discrete-event network simulator for Internet systems, targeted primarily for research and educational use. [Version 3.37](https://www.nsnam.org/news/2022/11/01/ns-3-37-released.html) was released in November 2022. The [ns-3 source code](https://gitlab.com/nsnam/ns-3-dev#table-of-contents) is on GitLab.

## OMnet++

[Omnet++](https://omnetpp.org/) is in active development. It is a discreet-event network simulator used by many universities for teaching and research. It is published under a license called the [Academic Public License](https://opensource.org/licenses/APL-1.0), which appears to be unique to the Omnet++ project. Commercial users must pay for a license, but academic or personal use is permitted without payment. Non-commercial developers have rights similar to the GPL. [OMNeT++ 6.0.1](https://github.com/omnetpp/omnetpp/releases/tag/omnetpp-6.0.1) was released in September 2022.

## Cloudsim

[CloudSim](http://www.cloudbus.org/cloudsim/) is still [maintained](https://github.com/Cloudslab/cloudsim) and Release 6 was delivered in August, 2022. Cloudsim is part of an [ecosystem](http://www.cloudbus.org/) of [projects and extensions](https://github.com/Cloudslab), such as [iFogSim](https://github.com/Cloudslab/iFogSim), 

## Linux Network Test Stack

[LNST](http://lnst-project.org/), the Linux Network Test Stack, is still being [maintained](https://github.com/lnst-project/lnst). 

## NEmu

[NEmu](https://gitlab.com/v-a/nemu) is still being maintained. It creates QEMU VMs to build a dynamic virtual network and does not require root access to your computer.

## Labtainers

[Labtainers](https://nps.edu/web/c3o/labtainers)
is still [maintained](https://github.com/mfthomps/Labtainers). It has [lab scenarios based on security topics](https://nps.edu/web/c3o/labtainer-lab-summary1). 

# New tools

I surveyed the Internet for information about network emulators and simulators that were created after 2019, which was the last time I did a broad survey of available simulation tools.

I found many tools I that were new to me, and list them all below. Most are related to the emulation of wireless networks and core networks, which is very interesting because I could not find emulators for these types of networks back in 2019.

## Cooja

The [Cooja IoT network emulator](https://docs.contiki-ng.org/en/develop/doc/tutorials/Running-Contiki-NG-in-Cooja.html) is part of the new [Contiki-ng](https://www.contiki-ng.org/) project. Cooja enables fine-grained simulation/emulation of IoT networks that use Contiki-NG. The [Contiki-NG forum](https://gitter.im/contiki-ng) is very active, with most questions receiving a reply.

## Tinet

[Tinet](https://github.com/tinynetwork/tinet), or *Tiny Network*,  is another container-based network emulator that has a few good scenarios described in the *examples* folder in its repository.  It is intended to be a simple tool that takes a YAML config file as input and generates a shell script to construct virtual network. First released in 2020 with minor updates since then. The most recent update was in January, 2023.

## CapCarbon

[CupCarbon](http://cupcarbon.com/) simulates wireless networks in cities and [integrates data](https://www.opensourceforu.com/2019/09/simulating-smart-cities-with-cupcarbon/) from OpenStreetMap. The code is available on [GitHub](https://github.com/bounceur/CupCarbon) but there is no license information. 

## Meshtasticator

[Meshtasticator](https://github.com/GUVWAF/Meshtasticator) is an emulator for Meshtastic software. [Meshtastic](https://meshtastic.org/) is a project that enables you to use inexpensive LoRa radios as a long range off-grid communication platform in areas without existing or reliable communications infrastructure. This project is 100% community driven and open source! [^1] Meshtasticator enables you to emulate the operation of a network of Meshtastic devices communicating with teach other over LoRa radio. It is actively being developed.

[^1]: From Meshtastic Introduction: https://meshtastic.org/docs/introduction; February 2023

## CrowNet

[CrowNet](https://github.com/roVer-HM/crownet) is an open-source simulation environment which models pedestrians using wireless communication. It can be used to evaluate pedestrian communication in urban and rural environments. It is based on Omnet++. Development is active.

## Colosseum

[Colosseum](https://www.northeastern.edu/colosseum/) provides open-source wireless software for [wireless network emulation](https://docs.srsran.com/en/latest/). The software appears to be based on standard PC hardware and radios. Can one emulate the radios and build a completely virtual lab?

## MimicNet

[MimicNet](https://dl.acm.org/doi/10.1145/3452296.3472926) is a network simulator that uses machine learning to estimate the performance of large data centre networks. MIT License. Released in July 2019 but no updates since then. MimicNet is the result of a research project and, now that the [paper](https://dl.acm.org/doi/10.1145/3452296.3472926) is published, the project appears to be in maintenance mode. Developers still respond to issues and the last commit was in July 2022. 

## FlowEmu

[FlowEmu](https://github.com/ComNetsHH/FlowEmu) is an open-source, flow-based network emulator. FlowEmu users model communication systems composed of different types of impairments, queues, and processes. It comes with a Python toolchain that supports running experiments in a virtual Docker environment. It seems to be targeted at application developers who want to test how their application works across various network conditions.




# Removed from my list

Wistar seems to have been abandoned. No updates in 4 years and no activity in the Wistar Slack channel

vrnetlab has had no development activitry in several years. But, it is still on my list of simulators because the open containerlab emulator uses some parts of vrnetlab and the vrnetlab documentation may still be useful

[Antidote](https://github.com/nre-learning/antidote) and [NRE Labs](https://github.com/nre-learning/nrelabs-docs) are retired. See the [announcement on the NRE Labs site](https://nrelabs.io/2021/12/goodbye-for-now/)

Netmirage not updated since its first release. probably abandoned

[ESCAPEv2](https://github.com/hsnlab/escape) has had no updates in years.

Marionnet. No development since 2018

Psimulator seems to be dead

Lstacker is dead

http://www.topology-zoo.org/

[VIMINAL](https://sourceforge.net/projects/viminal/) development seems to have stopped.

[Knet](https://github.com/knetsolutions/knet/) is dead.

[AutoNetkit](http://www.autonetkit.org/) was upgraded to Python 3 two years ago but there has been no development since then.

