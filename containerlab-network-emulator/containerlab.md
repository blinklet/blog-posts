## Prerequisites:

[Install Docker](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-20-04)

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

Create a temporary directory in which to download the Containerlab files

```
mkdir /tmp/containerlab
cd /tmp/containerlab
```


In a web browser, go to the [latest release of Containerlab on GitHub](https://github.com/srl-labs/containerlab/releases/latest) at the following URL:

```
https://github.com/srl-labs/containerlab/releases/latest
```

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

Use the [FRR container from DockerHub](https://hub.docker.com/r/frrouting/frr).

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
      image: frrouting/frr:v7.5.1
      binds:
        - router1-config/daemons:/etc/frr/daemons
    router2:
      kind: linux
      image: frrouting/frr:v7.5.1
      binds:
        - router2-config/daemons:/etc/frr/daemons
    router3:
      kind: linux
      image: frrouting/frr:v7.5.1
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

```
$ sudo clab deploy --topo frrlab.clab.yml
INFO[0000] Parsing & checking topology file: frrlab.clab.yml 
INFO[0000] Creating lab directory: /home/brian/containerlab/lab-examples/frrlab/clab-frrlab 
INFO[0000] Creating docker network: Name='clab', IPv4Subnet='172.20.20.0/24', IPv6Subnet='2001:172:20:20::/64', MTU='1500' 
INFO[0000] Creating container: router2                  
INFO[0000] Creating container: router1                  
INFO[0000] Creating container: router3                  
INFO[0000] Creating container: PC1                      
INFO[0000] Creating container: PC2                      
INFO[0000] Creating container: PC3                      
INFO[0006] Creating virtual wire: router1:eth2 <--> router3:eth1 
INFO[0006] Creating virtual wire: router2:eth2 <--> router3:eth2 
INFO[0006] Creating virtual wire: PC1:eth1 <--> router1:eth3 
INFO[0006] Creating virtual wire: router1:eth1 <--> router2:eth1 
INFO[0006] Creating virtual wire: PC2:eth1 <--> router2:eth3 
INFO[0006] Creating virtual wire: PC3:eth1 <--> router3:eth3 
INFO[0006] Writing /etc/hosts file                      
+---+---------------------+--------------+---------------------------------+-------+-------+---------+----------------+----------------------+
| # |        Name         | Container ID |              Image              | Kind  | Group |  State  |  IPv4 Address  |     IPv6 Address     |
+---+---------------------+--------------+---------------------------------+-------+-------+---------+----------------+----------------------+
| 1 | clab-frrlab-PC1     | 3be7d5136a58 | praqma/network-multitool:latest | linux |       | running | 172.20.20.4/24 | 2001:172:20:20::4/64 |
| 2 | clab-frrlab-PC2     | 447d4a3fd09d | praqma/network-multitool:latest | linux |       | running | 172.20.20.5/24 | 2001:172:20:20::5/64 |
| 3 | clab-frrlab-PC3     | 146915d85bfe | praqma/network-multitool:latest | linux |       | running | 172.20.20.6/24 | 2001:172:20:20::6/64 |
| 4 | clab-frrlab-router1 | fa4beabef9e4 | frrouting/frr:v7.5.1            | linux |       | running | 172.20.20.2/24 | 2001:172:20:20::2/64 |
| 5 | clab-frrlab-router2 | c65b32cc2b46 | frrouting/frr:v7.5.1            | linux |       | running | 172.20.20.7/24 | 2001:172:20:20::7/64 |
| 6 | clab-frrlab-router3 | c992143448f7 | frrouting/frr:v7.5.1            | linux |       | running | 172.20.20.3/24 | 2001:172:20:20::3/64 |
+---+---------------------+--------------+---------------------------------+-------+-------+---------+----------------+----------------------+
```


Connect to PC1:

```
docker exec -it clab-frrlab-PC1 /bin/ash
```
```
exit
```

Connect to Router1:

```
docker exec -it clab-frrlab-router1 /bin/ash
```

Check out the Linux kernel's view of the network:

```
$ docker exec -it clab-frrlab-router1 /bin/ash
/ # ip link
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
62: eth0@if63: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default 
    link/ether 02:42:ac:14:14:02 brd ff:ff:ff:ff:ff:ff link-netnsid 0
75: eth2@if74: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 65000 qdisc noqueue state UP mode DEFAULT group default 
    link/ether 16:df:15:1d:e7:73 brd ff:ff:ff:ff:ff:ff link-netnsid 3
78: eth3@if79: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 65000 qdisc noqueue state UP mode DEFAULT group default 
    link/ether 82:0b:77:83:46:42 brd ff:ff:ff:ff:ff:ff link-netnsid 1
81: eth1@if80: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 65000 qdisc noqueue state UP mode DEFAULT group default 
    link/ether 7a:7b:21:3b:44:e8 brd ff:ff:ff:ff:ff:ff link-netnsid 2
/ # ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
62: eth0@if63: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    link/ether 02:42:ac:14:14:02 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 172.20.20.2/24 brd 172.20.20.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 2001:172:20:20::2/64 scope global nodad 
       valid_lft forever preferred_lft forever
    inet6 fe80::42:acff:fe14:1402/64 scope link 
       valid_lft forever preferred_lft forever
75: eth2@if74: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 65000 qdisc noqueue state UP group default 
    link/ether 16:df:15:1d:e7:73 brd ff:ff:ff:ff:ff:ff link-netnsid 3
    inet6 fe80::14df:15ff:fe1d:e773/64 scope link 
       valid_lft forever preferred_lft forever
78: eth3@if79: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 65000 qdisc noqueue state UP group default 
    link/ether 82:0b:77:83:46:42 brd ff:ff:ff:ff:ff:ff link-netnsid 1
    inet6 fe80::800b:77ff:fe83:4642/64 scope link 
       valid_lft forever preferred_lft forever
81: eth1@if80: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 65000 qdisc noqueue state UP group default 
    link/ether 7a:7b:21:3b:44:e8 brd ff:ff:ff:ff:ff:ff link-netnsid 2
    inet6 fe80::787b:21ff:fe3b:44e8/64 scope link 
       valid_lft forever preferred_lft forever
 # ip route
default via 172.20.20.1 dev eth0 
172.20.20.0/24 dev eth0 proto kernel scope link src 172.20.20.2
```

We see four interfaces: eth0-3. Eth0 is configured 
Note: cannot ssh into these containers. They are based on Alpine Linux so ssh is not enabled.

[Alpine Linux network configuration](https://unix.stackexchange.com/questions/602646/content-of-etc-network-in-alpine-linux-image)


Management network *clab* is managed by docker and assigns IP address to each node's *eth0* interface. BUT the wires between nodes are not managed by docker so do not show up in the `docker network ls` command's output.










Copy the standard [FRR daemons config file](https://docs.frrouting.org/en/latest/setup.html#daemons-configuration-file) from the FRR documentation to the directory and change ospfd, ospf6d, and ldpd to "yes".




## Configure nodes


Connect to PC1:

```
docker exec -it clab-frrlab-PC1 /bin/ash
```
```
ip addr add 192.168.11.2/24 dev eth1
ip route add 192.168.0.0/16 via 192.168.11.1 dev eth1
ip route add 10.10.10.0/24 via 192.168.11.1 dev eth1
exit
```

> If you are using network traffic generators, you may want to delete the default route (`ip route delete default`) so if someone makes a mistake during testing, their test traffic does not get sent to the management network


```
docker exec -it clab-frrlab-PC2 /bin/ash
```
```
ip addr add 192.168.12.2/24 dev eth1
ip route add 192.168.0.0/16 via 192.168.12.1 dev eth1
ip route add 10.10.10.0/24 via 192.168.12.1 dev eth1
exit
```
```
docker exec -it clab-frrlab-PC3 /bin/ash
```
```
ip addr add 192.168.13.2/24 dev eth1
ip route add 192.168.0.0/16 via 192.168.13.1 dev eth1
ip route add 10.10.10.0/24 via 192.168.13.1 dev eth1
exit
```




Connect to *vtysh* on Router1:

```
docker exec -it clab-frrlab-router1 vtysh
```
```
configure terminal 
service integrated-vtysh-config
interface eth1
 ip address 192.168.1.1/24
 exit
interface eth2
 ip address 192.168.2.1/24
 exit
interface eth3
 ip address 192.168.11.1/24
 exit
interface lo
 ip address 10.10.10.1/32
 exit
exit
write
exit
```


Connect to *vtysh* on Router2:

```
docker exec -it clab-frrlab-router2 vtysh
```
```
configure terminal 
service integrated-vtysh-config
interface eth1
 ip address 192.168.1.2/24
 exit
interface eth2
 ip address 192.168.3.1/24
 exit
interface eth3
 ip address 192.168.12.1/24
 exit
interface lo
 ip address 10.10.10.2/32
 exit
exit
write
exit
```

Connect to *vtysh* on Router3:

```
docker exec -it clab-frrlab-router3 vtysh
```
```
configure terminal 
service integrated-vtysh-config
interface eth1
 ip address 192.168.2.2/24
 exit
interface eth2
 ip address 192.168.3.2/24
 exit
interface eth3
 ip address 192.168.13.1/24
 exit
interface lo
 ip address 10.10.10.3/32
 exit
exit
write
exit
```

### Some quick tests.

Should be able to ping from PC1 to any IP address configured on router1, but not to interfaces on other nodes.

```
docker exec -it clab-frrlab-PC1 /bin/ash
```
```
/ # ping -c1 192.168.11.1
PING 192.168.11.1 (192.168.11.1) 56(84) bytes of data.
64 bytes from 192.168.11.1: icmp_seq=1 ttl=64 time=0.066 ms

--- 192.168.11.1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.066/0.066/0.066/0.000 ms
/ #
```

### Add OSPF

Connect to *vtysh* on Router1:

```
docker exec -it clab-frrlab-router1 vtysh
```
```
configure terminal 
router ospf
 passive-interface eth3
 passive-interface lo
 network 192.168.1.0/24 area 0.0.0.0
 network 192.168.2.0/24 area 0.0.0.0
 network 192.168.11.0/24 area 0.0.0.0
 exit
exit
write
exit
```


Connect to *vtysh* on Router2:

```
docker exec -it clab-frrlab-router2 vtysh
```
```
configure terminal 
router ospf
 passive-interface eth3
 network 192.168.1.0/24 area 0.0.0.0
 network 192.168.3.0/24 area 0.0.0.0
 network 192.168.12.0/24 area 0.0.0.0
 exit
exit
write
exit
```

Connect to *vtysh* on Router3:

```
docker exec -it clab-frrlab-router3 vtysh
```
```
configure terminal 
router ospf
 passive-interface eth3
 network 192.168.2.0/24 area 0.0.0.0
 network 192.168.3.0/24 area 0.0.0.0
 network 192.168.13.0/24 area 0.0.0.0
 exit
exit
write
exit
```

### OSPF testing

Now, PC1 should be able to ping any interface on any network node

```
$ docker exec -it clab-frrlab-PC1 /bin/ash
```
```
/ # traceroute 192.168.13.2
traceroute to 192.168.13.2 (192.168.13.2), 30 hops max, 46 byte packets
 1  192.168.11.1 (192.168.11.1)  0.004 ms  0.005 ms  0.004 ms
 2  192.168.2.2 (192.168.2.2)  0.004 ms  0.005 ms  0.005 ms
 3  192.168.13.2 (192.168.13.2)  0.004 ms  0.007 ms  0.004 ms
/ # exit
```

Now see impact if the link between R1 and R3 goes down:

```
docker exec -it clab-frrlab-router1 /bin/ash
```
```
/ # ip link set dev eth2 down
/ # exit
```
```
$ docker exec -it clab-frrlab-PC1 /bin/ash
```
```
/ # traceroute 192.168.13.2
traceroute to 192.168.13.2 (192.168.13.2), 30 hops max, 46 byte packets
 1  192.168.11.1 (192.168.11.1)  0.005 ms  0.004 ms  0.004 ms
 2  192.168.1.2 (192.168.1.2)  0.005 ms  0.004 ms  0.002 ms
 3  192.168.3.2 (192.168.3.2)  0.002 ms  0.005 ms  0.002 ms
 4  192.168.13.2 (192.168.13.2)  0.002 ms  0.007 ms  0.011 ms
/ # exit
```

Then, restore link

```
docker exec -it clab-frrlab-router1 /bin/ash
```
```
/ # ip link set dev eth2 up
/ # exit
```
```
docker exec -it clab-frrlab-PC1 /bin/ash
```
```
/ # traceroute 192.168.13.2
traceroute to 192.168.13.2 (192.168.13.2), 30 hops max, 46 byte packets
 1  192.168.11.1 (192.168.11.1)  0.004 ms  0.005 ms  0.003 ms
 2  192.168.2.2 (192.168.2.2)  0.004 ms  0.004 ms  0.002 ms
 3  192.168.13.2 (192.168.13.2)  0.002 ms  0.005 ms  0.003 ms
```

### network defect introduction

Currently, there is no function in containerlab that allows the user to control the network connections between nodes. So you cannot disable a link or introduce link errors using containerlab commands.

Maybe use ip and tc commands on the host? Since the veth interfaces are managed by the host?

https://containerlab.srlinux.dev/manual/wireshark/

```
$ sudo ip netns exec clab-frrlab-router1 ip link
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
91: eth0@if92: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default 
    link/ether 02:42:ac:14:14:02 brd ff:ff:ff:ff:ff:ff link-netnsid 0
106: eth2@if105: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 65000 qdisc noqueue state UP mode DEFAULT group default 
    link/ether 16:36:c6:ca:4e:77 brd ff:ff:ff:ff:ff:ff link-netns clab-frrlab-router3
107: eth3@if108: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 65000 qdisc noqueue state UP mode DEFAULT group default 
    link/ether f2:4e:6d:f5:e9:01 brd ff:ff:ff:ff:ff:ff link-netns clab-frrlab-PC1
114: eth1@if113: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 65000 qdisc noqueue state UP mode DEFAULT group default 
    link/ether 42:ca:0d:5c:15:3c brd ff:ff:ff:ff:ff:ff link-netns clab-frrlab-router2
$
$ sudo ip netns exec clab-frrlab-router1 ip link set dev eth2 down
```
```
$ docker exec -it clab-frrlab-PC1 /bin/ash
```
```
/ # traceroute 192.168.13.2
traceroute to 192.168.13.2 (192.168.13.2), 30 hops max, 46 byte packets
 1  192.168.11.1 (192.168.11.1)  0.007 ms  0.006 ms  0.005 ms
 2  192.168.1.2 (192.168.1.2)  0.006 ms  0.009 ms  0.006 ms
 3  192.168.3.2 (192.168.3.2)  0.005 ms  0.008 ms  0.004 ms
 4  192.168.13.2 (192.168.13.2)  0.004 ms  0.007 ms  0.004 ms
/ # exit
```


Then bring the veth back up...

```
$ sudo ip netns exec clab-frrlab-router1 ip link set dev eth2 up
```
```
$ docker exec -it clab-frrlab-PC1 /bin/ash
```
```
/ # traceroute 192.168.13.2
traceroute to 192.168.13.2 (192.168.13.2), 30 hops max, 46 byte packets
 1  192.168.11.1 (192.168.11.1)  0.008 ms  0.006 ms  0.003 ms
 2  192.168.3.2 (192.168.3.2)  0.005 ms  0.008 ms  0.005 ms
 3  192.168.13.2 (192.168.13.2)  0.005 ms  0.006 ms  0.005 ms
/ # 
```

So we see we can impact network behavior using ip commands on the host system. 


### Persistent configuration


Containerlab does not save the configuration files for Linux containers. It will [save configuration files for some other types of nodes](https://containerlab.srlinux.dev/manual/conf-artifacts/), such as the sr-linux type.


### Get lab info

```
$ sudo containerlab inspect --name frrlab
+---+-----------------+----------+---------------------+--------------+---------------------------------+-------+-------+---------+----------------+----------------------+
| # |    Topo Path    | Lab Name |        Name         | Container ID |              Image              | Kind  | Group |  State  |  IPv4 Address  |     IPv6 Address     |
+---+-----------------+----------+---------------------+--------------+---------------------------------+-------+-------+---------+----------------+----------------------+
| 1 | frrlab.clab.yml | frrlab   | clab-frrlab-PC1     | 02eea96ab0f0 | praqma/network-multitool:latest | linux |       | running | 172.20.20.4/24 | 2001:172:20:20::4/64 |
| 2 |                 |          | clab-frrlab-PC2     | 9987d5ac6bd9 | praqma/network-multitool:latest | linux |       | running | 172.20.20.6/24 | 2001:172:20:20::6/64 |
| 3 |                 |          | clab-frrlab-PC3     | 66c24d270c1a | praqma/network-multitool:latest | linux |       | running | 172.20.20.7/24 | 2001:172:20:20::7/64 |
| 4 |                 |          | clab-frrlab-router1 | 4936f56d28b2 | frrouting/frr:v7.5.1            | linux |       | running | 172.20.20.2/24 | 2001:172:20:20::2/64 |
| 5 |                 |          | clab-frrlab-router2 | 610563b7052a | frrouting/frr:v7.5.1            | linux |       | running | 172.20.20.3/24 | 2001:172:20:20::3/64 |
| 6 |                 |          | clab-frrlab-router3 | 9f501e040a65 | frrouting/frr:v7.5.1            | linux |       | running | 172.20.20.5/24 | 2001:172:20:20::5/64 |
+---+-----------------+----------+---------------------+--------------+---------------------------------+-------+-------+---------+----------------+----------------------+
```



### Stopping individual nodes create problems

I stopped and then started a node PC1 with `docker stop clab-frrlab-PC1` and `docker start clab-frrlab-PC1`. The link between PC1 and Router1 disappeared. 


I think stopping the container causes the attached veth to disconnect.


Create link again with:

```
sudo containerlab tools veth create -a clab-frrlab-PC1:eth1 -b clab-frrlab-router1:eth3
```

Then, reconfigure the IP address on PC1 (Router1 does not lose its configuration because it is was not stopped)

```
docker exec -it clab-frrlab-PC1 /bin/ash
```
```
ip addr add 192.168.11.2/24 dev eth1
exit
```


There's no clab command for stopping and starting individual nodes.

How to pre-configure the PC network? Maybe bind a copy of */etc/network/interfaces* in the topology file?


Experiment:

Base state of PC1 and Router1

```
$ sudo ip netns exec clab-frrlab-PC1 ip link
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
95: eth0@if96: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default 
    link/ether 02:42:ac:14:14:04 brd ff:ff:ff:ff:ff:ff link-netnsid 0
108: eth1@if107: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 65000 qdisc noqueue state UP mode DEFAULT group default 
    link/ether ca:66:10:68:80:cf brd ff:ff:ff:ff:ff:ff link-netns clab-frrlab-router1

$ sudo ip netns exec clab-frrlab-router1 ip link
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
91: eth0@if92: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default 
    link/ether 02:42:ac:14:14:02 brd ff:ff:ff:ff:ff:ff link-netnsid 0
106: eth2@if105: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 65000 qdisc noqueue state UP mode DEFAULT group default 
    link/ether 16:36:c6:ca:4e:77 brd ff:ff:ff:ff:ff:ff link-netns clab-frrlab-router3
107: eth3@if108: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 65000 qdisc noqueue state UP mode DEFAULT group default 
    link/ether f2:4e:6d:f5:e9:01 brd ff:ff:ff:ff:ff:ff link-netns clab-frrlab-PC1
114: eth1@if113: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 65000 qdisc noqueue state UP mode DEFAULT group default 
    link/ether 42:ca:0d:5c:15:3c brd ff:ff:ff:ff:ff:ff link-netns clab-frrlab-router2
```

Stop PC1 container

```
$ sudo docker stop clab-frrlab-PC1
```

Then check links

```
$ sudo ip netns exec clab-frrlab-PC1 ip link
Cannot open network namespace "clab-frrlab-PC1": No such file or directory
$
$ sudo ip netns exec clab-frrlab-router1 ip link
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
91: eth0@if92: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default 
    link/ether 02:42:ac:14:14:02 brd ff:ff:ff:ff:ff:ff link-netnsid 0
106: eth2@if105: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 65000 qdisc noqueue state UP mode DEFAULT group default 
    link/ether 16:36:c6:ca:4e:77 brd ff:ff:ff:ff:ff:ff link-netns clab-frrlab-router3
114: eth1@if113: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 65000 qdisc noqueue state UP mode DEFAULT group default 
    link/ether 42:ca:0d:5c:15:3c brd ff:ff:ff:ff:ff:ff link-netns clab-frrlab-router2
```

I see eth3 is gone also on Router 1

Restart PC1 container

```
$ sudo docker start clab-frrlab-PC1
```
Then check links


```
$ sudo ip netns exec clab-frrlab-router1 ip link
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
91: eth0@if92: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default 
    link/ether 02:42:ac:14:14:02 brd ff:ff:ff:ff:ff:ff link-netnsid 0
106: eth2@if105: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 65000 qdisc noqueue state UP mode DEFAULT group default 
    link/ether 16:36:c6:ca:4e:77 brd ff:ff:ff:ff:ff:ff link-netns clab-frrlab-router3
114: eth1@if113: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 65000 qdisc noqueue state UP mode DEFAULT group default 
    link/ether 42:ca:0d:5c:15:3c brd ff:ff:ff:ff:ff:ff link-netns clab-frrlab-router2
$
$ sudo ip netns exec clab-frrlab-PC1 ip link
Cannot open network namespace "clab-frrlab-PC1": No such file or directory
```

Hmmm. No namespace for PC1...

Create link again with:

```
$ sudo containerlab tools veth create -a clab-frrlab-PC1:eth1 -b clab-frrlab-router1:eth3
INFO[0000] Creating virtual wire: clab-frrlab-PC1:eth1 <--> clab-frrlab-router1:eth3 
INFO[0000] veth interface successfully created!         
$
$ sudo ip netns exec clab-frrlab-PC1 ip link
Cannot open network namespace "clab-frrlab-PC1": No such file or directory
```








### Graph

does not appear to work

Run:

```
containerlab graph
```




Then point browser to URL: `https://localhost:50080`

No image. Did not detect running lab and render it.


```
$ clab graph --offline --topo frrlab.clab.yml
```

Gives picture below:

![](./Images/clab-graph-001.png)

But, because it is not based on a running lab, it does not show the IP addresses









# Config files

#### Router1:

/etc/frr/frr.conf

```
frr version 7.5.1_git
frr defaults traditional
hostname router1
no ipv6 forwarding
!
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
router ospf
 passive-interface eth3
 network 192.168.1.0/24 area 0.0.0.0
 network 192.168.2.0/24 area 0.0.0.0
 network 192.168.11.0/24 area 0.0.0.0
!
line vty
!
```

#### Router2:

/etc/frr/frr.conf

```
frr version 7.5.1_git
frr defaults traditional
hostname router2
no ipv6 forwarding
!
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
router ospf
 passive-interface eth3
 network 192.168.1.0/24 area 0.0.0.0
 network 192.168.3.0/24 area 0.0.0.0
 network 192.168.12.0/24 area 0.0.0.0
!
line vty
!
```

#### Router3:

/etc/frr/frr.conf


```
frr version 7.5.1_git
frr defaults traditional
hostname router3
no ipv6 forwarding
!
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
router ospf
 passive-interface eth3
 network 192.168.2.0/24 area 0.0.0.0
 network 192.168.3.0/24 area 0.0.0.0
 network 192.168.13.0/24 area 0.0.0.0
!
line vty
!
```


















# Debugging issue with frrouting/frr:latest



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


Initial setup


Log into each node and run config commands from teh config files saved in the project directory.



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



 
Try:

```
docker run -d -it \
  --name frr1 \
  --mount type=bind,source="$(pwd)"/router1-config/daemons,target=/etc/frr/daemons \
  frrouting/frr
```
```
ecbf60555b42666838f705deb1179c22d3b99505c218b467c601edee5c20dac3
docker: Error response from daemon: OCI runtime create failed: container_linux.go:367: starting container process caused: process_linux.go:495: container init caused: rootfs_linux.go:60: mounting "/home/brian/containerlab/lab-examples/frrlab/router1-config/daemons" to rootfs at "/var/lib/docker/overlay2/0ef350bb9cd8ce8017f7d901af944e18e2596358c6a1dd0d7a44aaf600f78175/merged/etc/frr/daemons" caused: not a directory: unknown: Are you trying to mount a directory onto a file (or vice-versa)? Check if the specified host path exists and is the expected type.
```

The tried:
```
docker run -d -it \
  --name frr1 \
  frrouting/frr
```

But it also failed:
```
docker logs frr1
cannot run start: /etc/frr/daemons does not exist
```


Try volumes:
```
docker run -it \
  --name frr3 \
  -v `pwd`/router1-config:/etc/frr frrouting/frr:latest
```

OK. So this is a problem in the "latest" version but it works OK in the "stable" version v7.5.1. [I opened issue #8558 in FRR's GitHub repo](https://github.com/FRRouting/frr/issues/8558) so see what the developers say.

docker run -d \
--name frr1 \
--mount type=bind,source="$(pwd)"/router1-config/daemons,target=/etc/frr/daemons \
frrouting/frr



docker run -it --rm -v `pwd`/docker/etc:/etc/frr frr:latest


/usr/bin/containerlab







cat <<EOF > /etc/network/interfaces
auto lo
iface lo inet loopback
                    
auto eth0
                              
iface eth1 inet static
       address 192.168.11.2/24
       gateway 192.168.11.1
EOF

