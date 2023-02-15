Hi Jorge, I assume you want a tool that abstracts the nodes so students do not need to learn a particular network operating system before they experiment with basic concepts. So, I recommend you look at CORE. 



cnet
https://www.csse.uwa.edu.au/cnet/index.php
v3.5.3 updated 4th April 2022
But need to share some personel info to get the software anmd source code
Supports macOS on Apple Silicon


Filius
https://gitlab.com/filius1/filius
https://www.lernsoftware-filius.de/
https://www.lernsoftware-filius.de/downloads/Introduction_Filius.pdf
https://www.lernsoftware-filius.de/Herunterladen
Filius 2.2 The current version is from December 29, 2022:
https://ent2d.ac-bordeaux.fr/disciplines/sti-college/2019/09/25/filius-un-logiciel-de-simulation-de-reseau-simple-et-accessible/
Caution: Choose the language when you first open the software. If an error occurs, delete the . filius containing the language settings found in C:\Users\"user name on the network"\AppData\Local\.filius (under win7).
https://helloworld.raspberrypi.org/articles/HW8-make-networks-interesting-with-filius


NESi
https://github.com/inexio/NESi
v1.4 relesed February 2021
no....


Openconfig KNE
https://github.com/openconfig/kne
0.1.7 December 2022
Defines a container format proposed for vendors to build appliances based on their own software
"The idea of this project is to provide a standard "interface" so that vendors can produce a standard container implementation which can be used to build complex topologies."
--- associated with https://www.openconfig.net/
Nokia support:  https://learn.srlinux.dev/tutorials/infrastructure/kne/srl-with-oc-services/
                https://github.com/srl-labs/learn-srlinux
                https://learn.srlinux.dev/tutorials/infrastructure/kne/
Cisco support:  https://www.cisco.com/c/en/us/td/docs/switches/datacenter/nexus9000/sw/93x/progammability/guide/b-cisco-nexus-9000-series-nx-os-programmability-guide-93x/b-cisco-nexus-9000-series-nx-os-programmability-guide-93x_chapter_011001.html
Juniper:  https://www.juniper.net/documentation/us/en/software/junos/open-config/topics/concept/openconfig-overview.html

Overview of openconfig: https://www.techrepublic.com/article/how-to-get-started-with-openconfig-and-yang-models/

go package: https://pkg.go.dev/github.com/openconfig/kne#section-readme

consider frr yang support?
https://github.com/sonic-net/SONiC/blob/master/doc/mgmt/SONiC_Design_Doc_Unified_FRR_Mgmt_Interface.md


links
------
OMNet++ videos
https://www.youtube.com/channel/UCUZztE5RcobsuNjsTTfvyOQ/playlists


for high school
=======
https://cs.uwaterloo.ca/~m2mazmud/netsim/
"Web-based network simulator for teaching hacking to high schoolers"
https://github.com/errorinn/netsim
https://www.usenix.org/conference/ase17/workshop-program/presentation/atwater


Jorge García created the Educational Network Simulator. It is a very simple educational network simulator intended to be used with his 15-16 year old students. Jorge provides a series of YouTube videos explaining how it works and how to use it.
http://projects.bardok.net/educational-network-simulator/
Last update 2019
http://malkiah.github.io/NetworkSimulator/
https://www.youtube.com/playlist?list=PLx8u37tswCijgs5fGrKyCzOQ78uFZ3SMO

https://studio.code.org/s/netsim/
not open source. Aimed at schools and teachers

open networking lab
https://onl.kmi.open.ac.uk/
based on cisco packet tracer
part of free course

Commercial, pay
https://tetcos.com/netsim-acad.html
At least the manual provides some good instruction material
https://www.tetcos.com/downloads/v13.2/NetSim_Experiment_Manual.pdf

Maybe also see if Marrionet still works



Do-it-yourself
==============

k8s-topo
https://github.com/networkop/k8s-topo

docker-topo
https://github.com/networkop/docker-topo

Meshnet-CNI
https://github.com/networkop/meshnet-cni
"meshnet is a (K8s) CNI plugin to create arbitrary network topologies out of point-to-point links"





Paper about using emulators in education. Did I already mention it?
http://www.wiete.com.au/journals/GJEE/Publish/vol21no2/03-Liu-Q.pdf
https://ieeexplore.ieee.org/document/6465290
inspiration for table describing simulators



RAN simulator  ...no...
https://github.com/sdran/ran-simulator/blob/rel-1.1.1/docs/architecture.md
https://docs.sd-ran.org/master/ran-simulator/README.html


