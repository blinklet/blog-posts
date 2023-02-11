# Still active

## Shadow

[Shadow](https://shadow.github.io/). I have not reviewed it. However, it is still under active development. It seems to have evolved into a general purpose network emulator.

## Mininet

[Mininet](http://mininet.org/) published its last version, 2.3.0, two years ago. On [Mininet's Github repo](https://github.com/mininet/mininet), I see some minor development activity in recent months. [Mininet Wifi](https://mn-wifi.readthedocs.io/en/latest/) has about the same [development activity](https://github.com/intrig-unicamp/mininet-wifi). Both the [Mininet mailing list](https://mailman.stanford.edu/mailman/listinfo/mininet-discuss) and [Mininet WiFi forum](https://groups.google.com/g/mininet-wifi-discuss) are still active.
See also [Mini-NDN](https://github.com/named-data/mini-ndn).  See also some examples of [building Mininet](https://github.com/gabisurita/network-labs) labs using [Python and FRR](https://github.com/bobuhiro11/mininetlab)

[Containernet](https://containernet.github.io/) is still being [maintained](https://github.com/containernet/containernet). It is a fork of the Mininet network emulator that allows to use Docker containers as hosts in emulated network topologies.

## Kathara

[Kathara](https://www.kathara.org/) is still being [maintained](https://github.com/KatharaFramework/Kathara). Version 3.5.5 was released recently. Kathara was created by the original developers of NetKit and is intended to be the next evolution in network emulation. A [fork of the original Netkit](https://github.com/netkit-jh/netkit-jh-build) is still being maintained by another author and has [updated documentation](https://netkit-jh.github.io/docs/).

## EVE-NG

[EVE-NG Community Edition](https://www.eve-ng.net/index.php/community/) continues to receive updates. The EVE-NG team seems to focus on the commercial EVE-NG product but still supports the open-source EVE-NG Community version.

## GNS3

[GNS3](https://gns3.com/) continues to deliver new versions. GNS3 version 2.2.37 was released recently.

## CORE

The [CORE network emulator](http://coreemu.github.io/core/) is still active. the most recent release, 9.0.1, was released in November 2022
Discord server: https://discord.com/channels/382277735575322625/
https://github.com/coreemu

## Containerlab

[Containerlab](https://containerlab.dev/) is still very active. The most recent release was 0.36.1, released in January 2023

## Cloonix

[Cloonix](clownix.net) v28 was released in January 2023. Cloonix has a new URL at: cloonix.net and now hosts code on Github at https://github.com/clownix/cloonix
Cloonix adopted a [new release number scheme](http://clownix.net/doc_stored/) since I reviewed it a long time ago. So it is now at "v28".

## IMUNES

[IMUNES](http://imunes.net/) is stable. The developer made an update a few months ago to support the [Apple M1 processor on Ubuntu 20.04 LTS](https://github.com/imunes/vroot-linux/commit/e49e67b9028c472c1142730dd94a7e4e41a71c08). But, not much has changed in the past two years.

## VNX

[VNX](http://web.dit.upm.es/vnxwiki/index.php/Main_Page) has had no updates since September 2020. But, [new filesystems](http://vnx.dit.upm.es/vnx/filesystems/) were added in January 2023 so there is still support.

## Netlab

[NetLab](https://github.com/ipspace/netlab) is actively maintained. I still haven't tried NetLab, yet. I added it to the list of network emulators in the blog's side panel.


# Special purpose emulators

[Labtainers](https://nps.edu/web/c3o/labtainers)
is still [maintained](https://github.com/mfthomps/Labtainers). It has [lab scenarios based on security topics](https://nps.edu/web/c3o/labtainer-lab-summary1). 
https://nps.edu/web/c3o/what-s-new-in-labtainers
https://nps.edu/web/c3o/labtainers

[MimicNet](https://dl.acm.org/doi/10.1145/3452296.3472926) is a network simulator that uses machine learning to estimate the performance of large data centre networks. MIT License. Released in July 2019 but no updates since then. MimicNet is the result of a research project and, now that the [paper](https://dl.acm.org/doi/10.1145/3452296.3472926) is published, the project appears to be in maintenance mode. Developers still respond to issues and the last commit was in July 2022. 

[Meshtasticator](https://github.com/GUVWAF/Meshtasticator) is an emulator for Meshtastic software. [Meshtastic](https://meshtastic.org/) is a project that enables you to use inexpensive LoRa radios as a long range off-grid communication platform in areas without existing or reliable communications infrastructure. This project is 100% community driven and open source! [^1] Meshtasticator enables you to emulate the operation of a network of Meshtastic devices communicating with teach other over LoRa radio. It is actively being developed.

[^1]: From Meshtastic Introduction: https://meshtastic.org/docs/introduction; February 2023

[CrowNet](https://github.com/roVer-HM/crownet) is an open-source simulation environment which models pedestrians using wireless communication. It can be used to evaluate pedestrian communication in urban and rural environments. It is based on Omnet++. Development is active.


# Do it yourself

[NetEm](https://wiki.linuxfoundation.org/networking/netem) and the Linux *tc* command.

[KinD](https://kind.sigs.k8s.io/) is actively [maintained](https://github.com/kubernetes-sigs/kind). It emulates Kubernetes clusters on a single PC.

[KubeVirt](https://kubevirt.io/) is still [maintained](https://github.com/kubevirt). It lets one run virtual machines in Kubernetes. This would be useful for emulating network appliances using Kubernetes.

[EMANE](https://github.com/adjacentlink/emane/wiki) continues to be actively developed and still emulating the physical and link layers of wireless networks. 

# New?

Colosseum
Open-source wireless network emulation
Based on standard PC hardware and radios
But, can we emulate the radios and build a virtual lab???
https://www.northeastern.edu/colosseum/
https://docs.srsran.com/en/latest/

The [Cooja IoT network emulator](https://docs.contiki-ng.org/en/develop/doc/tutorials/Running-Contiki-NG-in-Cooja.html) is part of the [Contiki-ng](https://www.contiki-ng.org/) project. Cooja enables fine-grained simulation/emulation of IoT networks that use Contiki-NG.
The [Contiki-NG forum](https://gitter.im/contiki-ng) is very active, with most questions receiving a reply.

[Omnet++](https://omnetpp.org/) is a discreet-event network simulator. It is published under a license called the [Academic Public License](https://opensource.org/licenses/APL-1.0), which appears to be unique to the Omnet++ project. Commercial users must pay for a license, but academic or personal use is permitted without payment. Non-commercial developers have rights similar to the GPL.

[Tinet](https://github.com/tinynetwork/tinet) is another container-based network emulator that has a few good scenarios described in the *examples* folder in its repository.  It is intended to be a simple tool that takes a YAML config file as input and generates a shell script to construct virtual network. First released in 2020 with minor updates since then. The most recent update was in January, 2023.

[CupCarbon](http://cupcarbon.com/) simulates wireless networks in cities and [integrates data](https://www.opensourceforu.com/2019/09/simulating-smart-cities-with-cupcarbon/) from OpenStreetMap. The code is available on [GitHub](https://github.com/bounceur/CupCarbon)  but there is no license information. 

[CloudSim](http://www.cloudbus.org/cloudsim/) is still [maintained](https://github.com/Cloudslab/cloudsim) and Release 6 was delivered in August, 2022. Cloudsim is part of an [ecosystem](http://www.cloudbus.org/) of [projects and extensions](https://github.com/Cloudslab), such as [iFogSim](https://github.com/Cloudslab/iFogSim), 


[LNST](http://lnst-project.org/), the Linux Network Test Stack, is still being [maintained](https://github.com/lnst-project/lnst). 


[NEmu](https://gitlab.com/v-a/nemu) is still being maintained. It creates QEMU VMs to build a dynamic virtual network and does not require root access to your computer.














# Commercial

[Cisco Modeling Labs](https://www.cisco.com/c/en/us/products/cloud-systems-management/modeling-labs/index.html) Platform (CML) costs US$200 for indiviuals. IT was formerly known as Cisco VIRL.


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

