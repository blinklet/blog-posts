Prerequisites:

https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-20-04

```
sudo apt install apt-transport-https
sudo apt install ca-certificates
sudo apt install curl
sudo apt install software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt update
apt-cache policy docker-ce
sudo apt install docker-ce
```

Create a temporary directory in which to download the containerlab files

```
mkdir /tmp/containerlab
cd /tmp/containerlab
```


In browser, go to:

https://github.com/srl-labs/containerlab/releases/latest

See latest release (in this example, it is 0.13.0)


Download the latest release binary:

```
wget https://github.com/srl-labs/containerlab/releases/download/v0.13.0/containerlab_0.13.0_Linux_amd64.tar.gz
```

Unpack the archive

```
tar xf containerlab_0.13.0_Linux_amd64.tar.gz
rm containerlab_0.13.0_Linux_amd64.tar.gz
```

Move binary to path

```
sudo mv containerlab /usr/bin/
```

Move examples and templates to */etc/containerlab*.

```
sudo mkdir /etc/containerlab
sudo mv lab-examples /etc/containerlab/
sudo mv templates /etc/containerlab/
```

Test it starts

```
containerlab version
                           _                   _       _
                 _        (_)                 | |     | |
 ____ ___  ____ | |_  ____ _ ____   ____  ____| | ____| | _
/ ___) _ \|  _ \|  _)/ _  | |  _ \ / _  )/ ___) |/ _  | || \
( (__| |_|| | | | |_( ( | | | | | ( (/ /| |   | ( ( | | |_) )
\____)___/|_| |_|\___)_||_|_|_| |_|\____)_|   |_|\_||_|____/

version: 0.13.0
 commit: fa230f6
   date: 2021-04-13T17:37:22Z
 source: https://github.com/srl-labs/containerlab
```
 
Create symlink so users can use the "clab" command as a shortcut when using containerlab. This will ensure that any example commands you copy-and-paste from the Containerlab user guide will work.

```
sudo ln -s /usr/bin/containerlab /usr/bin/clab
```


Now, try a sample lab. 

The [topology definition files](https://containerlab.srlinux.dev/manual/topo-def-file/) use a simple YAML syntax. 

The file starts with the name of the lab, followed by the lab topology. The topology consists of nodes and links.

In this example, we will use [FRR](https://hub.docker.com/r/frrouting/frr) containers and [network-multitool](https://hub.docker.com/r/praqma/network-multitool) containers. 

```
name: frrlab

topology:
  nodes:
    router1:
      kind: linux
      image: frrouting/frr:latest
      config: router1.cfg
      binds:
        - router1-config/daemons:/etc/frr/daemons
    router2:
      kind: linux
      image: frrouting/frr:latest
      config: router2.cfg
      binds:
        - router2-config/daemons:/etc/frr/daemons
    router3:
      kind: linux
      image: frrouting/frr:latest
      config: router3.cfg
      binds:
        - router3-config/daemons:/etc/frr/daemons
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
    - endpoints: ["router1:eth1", "router2:eth1"]
    - endpoints: ["router1:eth2", "router3:eth1"]
    - endpoints: ["router2:eth2", "router3:eth2"]
    - endpoints: ["PC1:eth1", "router1:eth3"]
    - endpoints: ["PC2:eth1", "router2:eth3"]
    - endpoints: ["PC3:eth1", "router3:eth3"]
```

container init caused: rootfs_linux mounting to rootfs at caused: not a directory


Config file for each FRR router

router1.cfg

```
interface eth1
 ip address 192.168.1.1/24
!
interface eth2
 ip address 192.168.2.1/24
!
interface eth3
 ip address 192.168.11.1/24
!
interface lo
 ip address 10.10.10.1/32
!
```
 
router2.cfg

```
interface eth1
 ip address 192.168.1.2/24
!
interface eth2
 ip address 192.168.3.1/24
!
interface eth3
 ip address 192.168.12.1/24
!
interface lo
 ip address 10.10.10.2/32
!
```

router3.cfg

```
interface eth1
 ip address 192.168.2.2/24
!
interface eth2
 ip address 192.168.3.2/24
!
interface eth3
 ip address 192.168.13.1/24
!
interface lo
 ip address 10.10.10.3/32
!
```

Copy the standard [FRR daemons config file](https://docs.frrouting.org/en/latest/setup.html#daemons-configuration-file) from the FRR documentation to the directory and change ospfd, ospf6d, and ldpd to "yes".



Then run the command

```
clab deploy --topo frrlab.clab.yml
```
```
INFO[0000] Parsing & checking topology file: frrlab.clab.yml 
INFO[0000] Pulling docker.io/praqma/network-multitool:latest Docker image 
INFO[0010] Done pulling docker.io/praqma/network-multitool:latest 
INFO[0010] Pulling docker.io/frrouting/frr:latest Docker image 
INFO[0040] Done pulling docker.io/frrouting/frr:latest  
WARN[0040] Only 1 vcpu detected on this container host. Most containerlab nodes require at least 2 vcpu 
INFO[0040] Creating lab directory: /home/brian/containerlab/lab-examples/frrlab/clab-frrlab 
INFO[0040] Creating docker network: Name='clab', IPv4Subnet='172.20.20.0/24', IPv6Subnet='2001:172:20:20::/64', MTU='1500' 
INFO[0041] Creating container: PC1                      
INFO[0041] Creating container: router3                  
INFO[0041] Creating container: PC2                      
INFO[0041] Creating container: PC3                      
INFO[0041] Creating container: router1                  
INFO[0041] Creating container: router2    
ERRO[0044] failed to create node router3: Error response from daemon: OCI runtime create failed: container_linux.go:367: starting container process caused: process_linux.go:495: container init caused: rootfs_linux.go:60: mounting "/home/brian/containerlab/lab-examples/frrlab/daemons" to rootfs at "/var/lib/docker/overlay2/c149f1e3f5a6ff3145aeed77164f99e22181a2e5665a4c3ff86ae9243467e331/merged/etc/frr/daemons" caused: not a directory: unknown: Are you trying to mount a directory onto a file (or vice-versa)? Check if the specified host path exists and is the expected type 
ERRO[0045] failed to create node router2: Error response from daemon: OCI runtime create failed: container_linux.go:367: starting container process caused: process_linux.go:495: container init caused: rootfs_linux.go:60: mounting "/home/brian/containerlab/lab-examples/frrlab/daemons" to rootfs at "/var/lib/docker/overlay2/4ed66dcfbdc06a3f6c955af27970b3470eb7f661c459cf27d891851b2d93ffef/merged/etc/frr/daemons" caused: not a directory: unknown: Are you trying to mount a directory onto a file (or vice-versa)? Check if the specified host path exists and is the expected type 
ERRO[0046] failed to create node router1: Error response from daemon: OCI runtime create failed: container_linux.go:367: starting container process caused: process_linux.go:495: container init caused: rootfs_linux.go:60: mounting "/home/brian/containerlab/lab-examples/frrlab/daemons" to rootfs at "/var/lib/docker/overlay2/3a666729c8f0e104fdf73a635c4307eb6afd3da9a97278e312b32062e4623002/merged/etc/frr/daemons" caused: not a directory: unknown: Are you trying to mount a directory onto a file (or vice-versa)? Check if the specified host path exists and is the expected type 
INFO[0049] Creating virtual wire: PC2:eth1 <--> router2:eth3 
INFO[0049] Creating virtual wire: PC3:eth1 <--> router3:eth3 
INFO[0049] Creating virtual wire: router1:eth1 <--> router2:eth1 
INFO[0049] Creating virtual wire: PC1:eth1 <--> router1:eth3 
INFO[0049] Creating virtual wire: router1:eth2 <--> router3:eth1 
INFO[0049] Creating virtual wire: router2:eth2 <--> router3:eth2 
ERRO[0049] failed to Statfs "": no such file or directory 
ERRO[0049] failed to Statfs "": no such file or directory 
ERRO[0049] failed to Statfs "": no such file or directory 
ERRO[0049] failed to Statfs "": no such file or directory 
ERRO[0049] failed to Statfs "": no such file or directory 
ERRO[0049] failed to Statfs "": no such file or directory 
ERRO[0049] failed to run postdeploy task for node router2: failed to Statfs "": no such file or directory 
ERRO[0049] failed to run postdeploy task for node router3: failed to Statfs "": no such file or directory 
ERRO[0049] failed to run postdeploy task for node router1: failed to Statfs "": no such file or directory 
INFO[0049] Writing /etc/hosts file                    
+---+---------------------+--------------+---------------------------------+-------+-------+---------+----------------+----------------------+
| # |        Name         | Container ID |              Image              | Kind  | Group |  State  |  IPv4 Address  |     IPv6 Address     |
+---+---------------------+--------------+---------------------------------+-------+-------+---------+----------------+----------------------+
| 1 | clab-frrlab-PC1     | 52c817381fad | praqma/network-multitool:latest | linux |       | running | 172.20.20.3/24 | 2001:172:20:20::3/64 |
| 2 | clab-frrlab-PC2     | 19c6ec269692 | praqma/network-multitool:latest | linux |       | running | 172.20.20.6/24 | 2001:172:20:20::6/64 |
| 3 | clab-frrlab-PC3     | 45afcee44d5c | praqma/network-multitool:latest | linux |       | running | 172.20.20.5/24 | 2001:172:20:20::5/64 |
| 4 | clab-frrlab-router1 | d6883639ccba | frrouting/frr:latest            | linux |       | created | 172.20.20.7/24 | 2001:172:20:20::7/64 |
| 5 | clab-frrlab-router2 | 466883dd3245 | frrouting/frr:latest            | linux |       | created | 172.20.20.2/24 | 2001:172:20:20::2/64 |
| 6 | clab-frrlab-router3 | bb913615b9ad | frrouting/frr:latest            | linux |       | created | 172.20.20.4/24 | 2001:172:20:20::4/64 |
+---+---------------------+--------------+---------------------------------+-------+-------+---------+----------------+----------------------+
```

Clean up the lab with the command:

```
clab destroy --topo frrlab.clab.yml
```

Fix: do not bind a file. Bind a directory. But a copy of the daemons file in a unique directory and bind it.
Or, to configure the daemons using /etc/frr from a host volume, put the config files in, say, ./docker/etc and bind mount that into the container:

******
Fix
use frr-debian, not frr
maybe frr is just the software with no other filesystem or networking and frr-debian has everything you need. Propose fix to project.
******
TODO: update topology file



https://containerlab.srlinux.dev


Use the [FRR container from DockerHub](https://hub.docker.com/r/frrouting/frr).
 
wget 


/usr/bin/containerlab