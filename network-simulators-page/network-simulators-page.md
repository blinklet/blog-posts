### Latest News

February 16, 2023

Major update to the list of network simulators and emulators. 

* Updated the summaries for projects already in the list: [Cloonix](), [Containerlab](), [CORE](), [EVE-NG](), [GNS-3](), [IMUNES](), [Kathara](), [Mininet](), [ns-3](), [Shadow](), [VNX](), and [vrnetlab]().
* Added summaries for many other projects: [Cloudsim](), [cnet](), [Labtainters](), [LNTS](), [NEmu](), [NetLab](), [OMnet++](), and [OpenConfig-KNE](). 
* Removed old, low-activity projects: [Antidote](https://docs.nrelabs.io/), [Wistar](), [YANS](https://github.com/kennethjiang/YANS), [LStacker](https://brettchaldecott.github.io/lstacker/), [LINE](https://wiki.epfl.ch/line/documents/line.html), [Marionnet](https://www.marionnet.org/site/index.php/en/), [Psimulator2](https://gitlab.fit.cvut.cz/psimulator2/Psimulator2), [DockEmu](https://github.com/jmarcos-cano/dockemu), [NetMirage](https://crysp.uwaterloo.ca/software/netmirage/), [KNet](https://github.com/knetsolutions/knet/), and [ESCAPE](https://github.com/hsnlab/escape).

Older news is archived on the [Network Simulator News](https://www.brianlinkletter.com/open-source-network-simulators/network-simulator-news/) page.
&nbsp;

### List of Network Simulators and Emulators

This is a list of open-source network simulators and network emulators that run on Linux or BSD. Please post a comment on this page to let me know about any other open-source network simulation tools I did not include in this list.

<a name="cloonix"></a>
### Cloonix

<a href="https://www.brianlinkletter.com/tag/cloonix/"><img src="https://www.brianlinkletter.com/wp-content/uploads/2015/06/Cloonixv26-002-1024x617.png" alt="Cloonixv26-002" width="1024" height="617" class="aligncenter size-large wp-image-3646" /></a>

The <a href="https://www.brianlinkletter.com/tag/cloonix/">Cloonix</a> network simulator provides a relatively easy-to-use graphical user interface. Cloonix uses QEMU/KVM to create virtual machines. Cloonix provides a wide variety of pre-built filesystems that can be used as virtual machines and provides simple instructions for creating other virtual machine root filesystems. Cloonix has an active development team, who update the tool every two or three months and who are very responsive to user input.

Please **<a href="https://www.brianlinkletter.com/tag/cloonix/">click here to see my posts about Cloonix</a>**.

Cloonix web site: <a href="http://clownix.net" target="_blank" rel="noopener noreferrer">http://clownix.net</a>

<a name="containerlab"></a>
### Containerlab

<img src="https://www.brianlinkletter.com/wp-content/uploads/2021/05/containerlab-splash-001-1024x568.png" alt="" width="1024" height="568" class="aligncenter size-large wp-image-5660" />

<a href="https://www.brianlinkletter.com/tag/Containerlab/">Containerlab</a> is an <a href="https://github.com/srl-labs/containerlab">open-source</a> network emulator that quickly builds network test environments in a devops-style workflow. It provides a command-line-interface for orchestrating and managing container-based networking labs. It starts the containers, builds virtual wiring between them to create lab topologies, and manages each lab's lifecycle.

Containerlab supports containerized router images available from the major networking vendors. More interestingly, Containerlab supports any open-source network operating system that is published as a container image, such as the <a href="https://frrouting.org/">Free Range Routing (FRR) router</a>. Containerlab also <a href="https://containerlab.srlinux.dev/manual/vrnetlab/">supports VM-based network devices</a> so users may run <a href="https://containerlab.srlinux.dev/manual/vrnetlab/#supported-vm-products">commercial router disk images</a> in network emulation scenarios. 

Please **<a href="https://www.brianlinkletter.com/tag/Containerlab/">click here to see my posts about Containerlab</a>**.

Containerlab web site: <a href="https://containerlab.srlinux.dev/" target="_blank" rel="noopener noreferrer">https://containerlab.srlinux.dev/</a> and <a href="https://github.com/srl-labs/containerlab" target="_blank" rel="noopener noreferrer">https://github.com/srl-labs/containerlab</a>

<a name="core"></a>
### CORE

<a href="https://www.brianlinkletter.com/tag/core/"><img src="https://www.brianlinkletter.com/wp-content/uploads/2013/02/CORE_possible_desktop_1.png" alt="CORE desktop" width="1024" height="768" class="aligncenter size-full wp-image-726" /></a>

The <a href="https://www.brianlinkletter.com/tag/core/">Common Open Research Emulator (CORE)</a> provides a GUI interface and uses the Network Namespaces functionality in Linux Containers (LXC) as a virtualization technology. This allows CORE to start up a large number of virtual machines quickly. CORE supports the simulation of fixed and mobile networks.

CORE will run on Linux and on FreeBSD. CORE is a fork of the IMUNES network simulator, and it adds some new functionality compared to IMUNES. 

Please **<a href="https://www.brianlinkletter.com/tag/core/">click here to see my posts about the CORE Network Emulator</a>**.

CORE web site: <a href="http://cs.itd.nrl.navy.mil/work/core/index.php" target="_blank" rel="noopener noreferrer">http://cs.itd.nrl.navy.mil/work/core/index.php</a> and <a href="https://github.com/coreemu/core" target="_blank" rel="noopener noreferrer">https://github.com/coreemu/core</a>

<a name="unetlab"></a><a name="eve-ng"></a>
### EVE-NG

<img src="https://www.brianlinkletter.com/wp-content/uploads/2016/01/UNL.jpg" alt="UNL" width="996" height="698" class="aligncenter size-full wp-image-4412" />

<a href="https://www.brianlinkletter.com/tag/eve-ng/">EVE-NG</a> is a network emulator that supports virtualized commercial router images (such as Cisco and NOKIA) and open-source routers. It uses Dynamips and IOS-on-Linux to support Cisco router and switch images, and KVM/QEMU to support all other devices. It is available as a virtual machine image and may also be installed on a dedicated server running Ubuntu Linux.

EVE-NG is available in two editions: a professional version and a <a href="https://www.eve-ng.net/community/" rel="noopener noreferrer" target="_blank">community edition</a>. The community license is not clearly stated and I cannot find the source code, so I am wondering if this project is no longer an open-source project?

EVE-NG web site: <a href="https://www.eve-ng.net/community/" target="_blank" rel="noopener noreferrer">https://www.eve-ng.net/community/</a> 

<a name="gns3"></a>
### GNS3

<a href="https://www.brianlinkletter.com/tag/GNS3/"><img src="https://www.brianlinkletter.com/wp-content/uploads/2014/01/Using-GNS3-cover-border2-1024x641.png" alt="Open-source Linux GNS3 simulation" width="1024" height="641" class="aligncenter size-large wp-image-1708" /></a>

<a href="https://www.brianlinkletter.com/tag/GNS3/" target="_blank" rel="noopener noreferrer">GNS3</a> is a graphical network simulator focused mostly on supporting Cisco and Juniper software. GNS3 has a large user base, made up mostly of people studying for Cisco exams, and there is a lot of information freely available on the web about using GNS3 to simulate Cisco equipment.

GNS3 can also be used to simulate a network composed exclusively of VirtualBox and/or Qemu virtual machines running open-source software. GNS3 provides a variety of prepared open-source virtual appliances, and users can create their own.

Please **<a href="https://www.brianlinkletter.com/tag/GNS3/">click here to see my posts about GNS3</a>**.

GNS3 web site: <a href="http://www.gns3.com/" target="_blank" rel="noopener noreferrer">http://www.gns3.com</a>

<a name="imunes"></a>
### IMUNES

<a href="https://www.brianlinkletter.com/tag/imunes/"><img src="https://www.brianlinkletter.com/wp-content/uploads/2013/02/IMUNES-Snapshot-1-Running-1024x820.jpg" alt="IMUNES open-source network routing simulator" width="1024" height="820" class="aligncenter size-large wp-image-949" /></a>

A team of researchers at the University of Zagreb developed the <a href="https://www.brianlinkletter.com/tag/imunes/">Integrated Multi-protocol Network Emulator/Simulator (IMUNES)</a> for use as a network research tool.  IMUNES runs on both the FreeBSD and Linux operating systems. It uses the kernel-level network stack virtualization technology provided by FreeBSD. It uses Docker containers and Open vSwitch on Linux.

IMUNES supports a graphical user interface. It works well and offers good performance, even when running IMUNES in a VirtualBox virtual machine.

Please **<a href="https://www.brianlinkletter.com/tag/imunes/">click here to see my posts about IMUNES</a>**.

IMUNES web site: <a href="http://www.imunes.net" target="_blank" rel="noopener noreferrer">http://www.imunes.net</a> or <a href="https://github.com/imunes/" target="_blank" rel="noopener noreferrer">https://github.com/imunes</a>

<a name="netkit"></a><a name="kathara"></a>
### Kathara

<a href="https://www.brianlinkletter.com/tag/netkit/"><img src="https://www.brianlinkletter.com/wp-content/uploads/2013/01/Netkit_Knoppix_DVD-1024x640.png" alt="Netkit open source single-area OSPF pre-configured lab" width="1024" height="640" class="aligncenter size-large wp-image-604" /></a>

<a href="https://www.brianlinkletter.com/tag/netkit/">Kathara</a> is a new version of <a href="https://www.brianlinkletter.com/tag/netkit/">Netkit</a>, implemented using modern technologies like Docker, and backwards-compatible with Netkit labs. The Netkit project's web site has a long list of interesting lab scenarios to practice, with documentation for each scenario. 

Please **<a href="https://www.brianlinkletter.com/tag/netkit/">click here to see my posts about Kathara and Netkit</a>**.

Kathara web site: <a href="http://www.kathara.org/" target="_blank" rel="noopener noreferrer">http://www.kathara.org/</a>
Netkit web site: <a href="http://wiki.netkit.org" target="_blank" rel="noopener noreferrer">http://wiki.netkit.org</a>



<a name="mininet"></a>
### Mininet

<a href="https://www.brianlinkletter.com/tag/mininet/"><img src="https://www.brianlinkletter.com/wp-content/uploads/2014/12/MiniEdit-503b-1024x641.png" alt="MiniEdit-503b" width="1024" height="641" class="aligncenter size-large wp-image-3425" /></a>

<a href="https://www.brianlinkletter.com/tag/mininet/">Mininet</a> is designed to support research in Software Defined Networking technologies. It uses Linux network namespaces as its virtualization technology to create virtual nodes. The web site indicates that the tool can support thousands of virtual nodes on a single operating system. Mininet is most useful to researchers who are building SDN controllers and need a tool to verify the behavior and performance of SDN controllers. Knowledge of the Python scripting language is very useful when using Mininet.

The Mininet project provides excellent documentation and, judging from the activity on the <a href="https://mailman.stanford.edu/mailman/listinfo/mininet-discuss" target="_blank" rel="noopener noreferrer">Mininet mailing list</a>, the project is actively used by a large community of researchers. 

Some researchers have created forks of Mininet that focus on specific technologies. I list projects based on Mininet below:

* [Mini-NDN](https://github.com/named-data/mini-ndn)
* [Mini-CCNx](https://github.com/chesteve/mn-ccnx/wiki)
* [Mininet-WiFi](https://github.com/intrig-unicamp/mininet-wifi)
* [ESCAPE](http://sb.tmit.bme.hu/mediawiki/index.php/ESCAPE)

Please **<a href="https://www.brianlinkletter.com/tag/mininet/">click here to see my posts about Mininet</a>**.

Mininet web site: <a href="http://www.mininet.org" target="_blank" rel="noopener noreferrer">http://www.mininet.org</a>


<a name="ns3"></a>
### NS-3

<img src="https://www.brianlinkletter.com/wp-content/uploads/2016/01/Ns-3-logo.png" alt="Ns-3-logo" width="492" height="90" class="aligncenter size-full wp-image-4349" />

<a href="https://www.nsnam.org/" target="_blank" rel="noopener noreferrer">NS-3</a> is a discrete-event open-source network simulator for Internet systems, used primarily for research and educational use. NS-3 is a complex tool that runs simulations described by code created by users, so you may need programming skills to use it.

NS-3 can run real software on simulated nodes using its [Direct Code Execution](https://www.nsnam.org/docs/dce/release/1.4/manual/singlehtml/index.html) feature. This allows researchers to test real software like Quagga or web servers in a discreet-event network simulation to produce repeatable experiments.

NS-3 is meant to replace <a href="http://nsnam.sourceforge.net/wiki/index.php/Main_Page" target="_blank" rel="noopener noreferrer">NS-2</a>, a previous version of the network simulator. NS-2 is no longer actively maintained but is still used by some researchers.

I have not used NS-3, yet.

NS-3 web site: <a href="https://www.nsnam.org/" target="_blank" rel="noopener noreferrer">https://www.nsnam.org/</a>

<a name="shadow"></a>
### Shadow

<img src="https://www.brianlinkletter.com/wp-content/uploads/2016/01/Shadow.jpg" alt="Shadow" width="872" height="506" class="aligncenter size-full wp-image-4351" />

<a href="https://shadow.github.io/" target="_blank" rel="noopener noreferrer">Shadow</a> is an open-source network simulator/emulator hybrid that runs real applications like Tor and Bitcoin over a simulated Internet topology on a single Linux computer, and also on a pre-configured AMI instance on Amazon EC2. Users run a simulation by creating an XML file to describe the network topology and plugins to link their application code to nodes in the simulation. They see the results of their experiments in log files generated by Shadow. 

Shadow operates as a discrete-event simulator so experimental results are repeatable. Shadow can also run real software on its virtual nodes, using <a href="https://github.com/shadow/shadow/wiki/2-Simulation-Execution-and-Analysis#shadow-plug-ins" target="_blank" rel="noopener noreferrer">plugins created by the user</a>. This combination of features -- discreet-event simulation coupled with real software emulation -- makes Shadow a unique tool. 

I have not yet used Shadow. It seems to be useful to developers who want to test the performance of distributed or peer-to-peer applications like TOR and Bitcoin.

Shadow network simulator web site: <a href="https://shadow.github.io/" target="_blank" rel="noopener noreferrer">https://shadow.github.io/</a>

<a name="vnx"></a>
### VNX and VNUML

<a href="https://www.brianlinkletter.com/tag/vnx/"><img src="https://www.brianlinkletter.com/wp-content/uploads/2013/12/VNX-desktop-border-1024x640.png" alt="VNX linux open-source network simulator" width="1024" height="640" class="aligncenter size-large wp-image-1560" /></a>

<a href="https://www.brianlinkletter.com/tag/vnx/">VNX</a> supports two different virtualization techniques and uses an XML-style scripting language to define the virtual network. It also supports chaining multiple physical workstations together to support distributed virtual labs that operate across multiple physical workstations. It is supported by a small community and has been updated within the past year.

VNX replaces <a href="www.dit.upm.es/vnuml" target="_blank" rel="noopener noreferrer">VNUML</a>. The old VNUML web site still has sample labs and other content that would be useful when using VNX.

Please **<a href="https://www.brianlinkletter.com/tag/vnx/">click here to see my posts about VNX and VNUML</a>**.

VNX web site: <a href="http://www.dit.upm.es/vnx" target="_blank" rel="noopener noreferrer">http://www.dit.upm.es/vnx</a>

<a name="vrnetlab"></a>
### vrnetlab

<img src="https://www.brianlinkletter.com/wp-content/uploads/2019/03/vrnetlag-logo.png" alt="" width="822" height="184" class="aligncenter size-full wp-image-5379" />

<a href="https://www.brianlinkletter.com/tag/vrnetlab/">Vrnetlab</a>, or VR Network Lab, is an open-source network emulator that runs virtual routers using KVM and Docker. Software developers and network engineers use vrnetlab, along with continuous-integration processes, for testing network provisioning changes in a virtual network. Researchers and engineers may also use the vrnetlab command line interface to create and modify network emulation labs in an interactive way.

Please **<a href="https://www.brianlinkletter.com/tag/vrnetlab/">click here to see my posts about vrnetlab</a>**.

vrnetlab web site: <a href="https://github.com/plajjan/vrnetlab" target="_blank" rel="noopener noreferrer">https://github.com/plajjan/vrnetlab</a>

<a name="devops"></a>
### Do it yourself using Linux tools and applications

<img src="https://www.brianlinkletter.com/wp-content/uploads/2016/01/devstack2.png" alt="devstack2" width="1024" height="512" class="aligncenter size-full wp-image-4466" />

Linux provides many different ways to build a network emulator using open-source<a href="https://www.brianlinkletter.com/tag/DevOps/">virtualization technology and tools</a>. Some examples are: KVM and Libvirt, Docker and Compose, Openstack and Devstack, VirtualBox, Vagrant, Ansible, Linux bridges, Open vSwitch, and many more. 

Many of the network emulators described in this blog us some of the tools mentioned above to implement their functionality.

Please **<a href="https://www.brianlinkletter.com/tag/DevOps/">click here to see my posts about building your own network emulator</a>**.

### Other Emulators and Simulators ###

I list projects below that are either very new or that are older with low development activity.

#### New projects (on the radar) ####

[Containernet](https://github.com/containernet/containernet) is a fork of the Mininet network emulator that allows you to use Docker containers as hosts in emulated network topologies.

The [Educational Network Simulator](http://malkiah.github.io/NetworkSimulator/) is a very simple educational network simulator intended to be used with 15-16 year old students.  

[Labtainers](https://my.nps.edu/web/c3o/labtainers) is a network emulator based on Docker containers that also provides [many prepared labs](https://my.nps.edu/web/c3o/labtainer-lab-summary1) that focus on cybersecurity scenarios.

The [cnet network simulator](http://www.csse.uwa.edu.au/cnet/) enables development of and experimentation with a variety of networking protocols in WAN, LAN, and WLAN networks.

[OMNeT++ discrete event simulator](https://omnetpp.org/intro/) and the [INET Framework](https://inet.omnetpp.org/) combine to simulate wired, wireless and mobile networks.

