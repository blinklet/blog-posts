

https://containerlab.srlinux.dev/manual/vrnetlab/

https://www.brianlinkletter.com/2019/03/vrnetlab-emulate-networks-using-kvm-and-docker/

https://github.com/hellt/vrnetlab

```
$ sudo apt install -y python3-bs4 sshpass make gnupg-agent
$ git clone https://github.com/hellt/vrnetlab.git
$ cd vrnetlab/openwrt
$ wget https://downloads.openwrt.org/releases/19.07.7/targets/x86/64/openwrt-19.07.7-x86-64-combined-ext4.img.gz
$ sudo make build
$ sudo docker image ls
$ sudo docker tag vrnetlab/vr-openwrt:19.07.7 openwrt
```

Now we have a Docker image named *openwrt* that will run an OpenWRT VM.

```
$ sudo docker image ls
REPOSITORY                 TAG          IMAGE ID       CREATED          SIZE
openwrt                    latest       ccb86129352f   56 seconds ago   545MB
vrnetlab/vr-openwrt        19.07.7      ccb86129352f   56 seconds ago   545MB
praqma/network-multitool   latest       293c239dd855   11 days ago      38.1MB
debian                     stretch      fe718d1e4082   2 weeks ago      101MB
debian                     latest       0d587dfbc4f4   2 weeks ago      114MB
frrouting/frr              v7.5.1       c3e13a4c5918   2 weeks ago      123MB
srlinux                    21.3.1-410   0fe16823d2ba   4 weeks ago      1.06GB
srlinux                    latest       0fe16823d2ba   4 weeks ago      1.06GB
```

Add the OpenWRT router in the network topology

Edit *frrlab2.yml* and add an OpenWRT router between PC1 and Router1:

```
name: frrlab

topology:
  nodes:
    openwrt1:
      kind: linux
      image: openwrt
    router1:
      kind: linux
      image: frrouting/frr:v7.5.1
      binds:
        - router1/daemons:/etc/frr/daemons
        - router1/frr.conf:/etc/frr/frr.conf
    router2:
      kind: linux
      image: frrouting/frr:v7.5.1
      binds:
        - router2/daemons:/etc/frr/daemons
        - router2/frr.conf:/etc/frr/frr.conf
    router3:
      kind: linux
      image: frrouting/frr:v7.5.1
      binds:
        - router3/daemons:/etc/frr/daemons
        - router3/frr.conf:/etc/frr/frr.conf
    PC1:
      kind: linux
      image: praqma/network-multitool:latest
    PC2:
      kind: linux
      image: praqma/network-multitool:latest
    PC3:
      kind: linux
      image: praqma/network-multitool:latest

  links:
    - endpoints: ["PC1:eth1", "openwrt1:eth1"]
    - endpoints: ["router1:eth1", "router2:eth1"]
    - endpoints: ["router1:eth2", "router3:eth1"]
    - endpoints: ["router2:eth2", "router3:eth2"]
    - endpoints: ["openwrt1:eth2", "router1:eth3"]
    - endpoints: ["PC2:eth1", "router2:eth3"]
    - endpoints: ["PC3:eth1", "router3:eth3"]
``` 

