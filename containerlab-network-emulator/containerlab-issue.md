### Appendix A: Debugging Docker networking issues

The following may be a corner case but I thought it was worth documenting. 

Containerlab does not have a command to stop individual nodes running in the lab. The only way to kill a node in a running lab is to use the *docker stop* command on that node's container.

If one stops a container in the network emulation scenario and then starts it again, the links that connect that node to other nodes will disappear and will not be restored when the container is restarted. And, the network namespace used by the container gets corrupted.

To demonstrate this issue, I stopped and then started a node *PC1* with `docker stop clab-frrlab-PC1` and `docker start clab-frrlab-PC1`. 

First, I review the existing state of *PC1*'s and *Router1*'s links:

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

Everything looks good.

Then, I stopped the *PC1* container:

```
$ sudo docker stop clab-frrlab-PC1
```

I checked the links again. Since I stopped *clab-frrlab-PC1*, I will check the network namespace:

First, check the available network namespaces:

```
$ sudo ip netns ls
clab-frrlab-router1 (id: 5)
clab-frrlab-PC1
clab-frrlab-router2 (id: 3)
clab-frrlab-PC3 (id: 2)
clab-frrlab-router3 (id: 1)
clab-frrlab-PC2 (id: 0)
```

It seems that the namespace *clab-frrlab-PC1* still exists, even though it has no ID number. It should be deleted by Docker when the container stopped. I think that, because Containerlab creates network interfaces on the Docker container that are not managed by Docker, it fails to free up the network namespace completely.

Running commands in the network namespace does not work, as expected, because there is no container running:

```
$ sudo ip netns exec clab-frrlab-PC1 ip link
Cannot open network namespace "clab-frrlab-PC1": No such file or directory
```

I checked the links on *Router1*:

```
$ sudo docker exec clab-frrlab-router1 ip link
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
37: eth0@if38: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default 
    link/ether 02:42:ac:14:14:05 brd ff:ff:ff:ff:ff:ff link-netnsid 0
48: eth2@if47: <BROADCAST,MULTICAST> mtu 65000 qdisc noqueue state DOWN mode DEFAULT group default 
    link/ether 56:8e:93:fe:9c:fe brd ff:ff:ff:ff:ff:ff link-netnsid 1
50: eth1@if49: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 65000 qdisc noqueue state UP mode DEFAULT group default 
    link/ether 5e:35:b1:6f:bc:5a brd ff:ff:ff:ff:ff:ff link-netnsid 3
```

I see that *Router1*'s *eth3* interface disappeared. It looks like, when one container stops, both sides of the *veth* pairs that make up the links between that container and any other containers get deleted.

I expect I should be able to restore the original state of the network by restarting the *PC1* container:

```
$ sudo docker start clab-frrlab-PC1
```

Then, I check the links on *PC1*:

```
$ sudo docker exec clab-frrlab-PC1 ip link
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
55: eth0@if56: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default 
    link/ether 02:42:ac:14:14:06 brd ff:ff:ff:ff:ff:ff link-netnsid 0
```

I saw that *eth1* was not restored. And, if I check *Router1*, I see that *eth3* is not restored on that end.

So, I create link again with:

```
$ sudo containerlab tools veth create -a clab-frrlab-PC1:eth1 -b clab-frrlab-router1:eth3
```

It appears the link is successfully created:

```
INFO[0000] Creating virtual wire: clab-frrlab-PC1:eth1 <--> clab-frrlab-router1:eth3 
INFO[0000] veth interface successfully created!
```

Then, when I reconfigure  *eth1* on *PC1*, the connection works again:

```
$ sudo docker exec -it clab-frrlab-PC1 /bin/ash
/ # ip addr add 192.168.11.2/24 dev eth1
/ # ip route add 192.168.0.0/16 via 192.168.11.1 dev eth1
/ # ip route add 10.10.10.0/24 via 192.168.11.1 dev eth1
```

I can reach *PC3* again from *PC1*:

```
/ # ping 192.168.13.2
PING 192.168.13.2 (192.168.13.2) 56(84) bytes of data.
64 bytes from 192.168.13.2: icmp_seq=1 ttl=62 time=0.272 ms
64 bytes from 192.168.13.2: icmp_seq=2 ttl=62 time=0.056 ms
^C
--- 192.168.13.2 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1004ms
rtt min/avg/max/mdev = 0.056/0.164/0.272/0.108 ms
/ # exit
```

But, I cannot access commands in the container's network namespace:

```
$ sudo ip netns exec clab-frrlab-PC1 ip link
Cannot open network namespace "clab-frrlab-PC1": No such file or directory
```

And, the namespace list still looks odd. It is still missing an ID number:

```
$ sudo ip netns ls
clab-frrlab-PC1
clab-frrlab-router2 (id: 4)
clab-frrlab-router3 (id: 3)
clab-frrlab-PC3 (id: 2)
clab-frrlab-PC2 (id: 1)
clab-frrlab-router1 (id: 0)
```


The host seems to have lost track of the network namespace *clab-frrlab-PC1*. So, *clab-frrlab-PC1* has no netnsid. It should have an netnsid of 5. I list all netnsid's on the host system:

```
$ ip netns list-id
nsid 0 
nsid 1 
nsid 2 
nsid 3 
nsid 4 
nsid 5
```

I see nsid 5 still exists so somehow there's a disconnect. I checked the *netns* directory:


```
$ ls -l /var/run/netns
total 0
lrwxrwxrwx 1 root root 17 May  4 18:25 clab-frrlab-PC1 -> /proc/5050/ns/net
lrwxrwxrwx 1 root root 17 May  4 18:25 clab-frrlab-PC2 -> /proc/4884/ns/net
lrwxrwxrwx 1 root root 17 May  4 18:25 clab-frrlab-PC3 -> /proc/4915/ns/net
lrwxrwxrwx 1 root root 17 May  4 18:25 clab-frrlab-router1 -> /proc/4801/ns/net
lrwxrwxrwx 1 root root 17 May  4 18:25 clab-frrlab-router2 -> /proc/4954/ns/net
lrwxrwxrwx 1 root root 17 May  4 18:25 clab-frrlab-router3 -> /proc/5012/ns/net
```

Everything looks OK, at first. But, what process is container *clab-frrlab-PC1* really using?

```
$ sudo docker inspect --format '{{.State.Pid}}' clab-frrlab-PC1
5851
```

Docker indicates that container *clab-frrlab-PC1* is using process id 5851. But, in the *netns* directory, the container is using process 5050. But, only process 5851 exists in the */proc* directory; process 5050 does not really exist.

```
$ ls /proc | grep 5851
5851
$
$ ls /proc | greo 5050
$
```

So, I needed to create a new symbolic link from *clab-frrlab-PC1* to process 5851 to "reattach" the Docker container to its namespace.

```
$ sudo ln -sf /proc/5851/ns/net /var/run/netns/clab-frrlab-PC1
```

Then, when I list the namespaces, everythink looks OK:

```
$ sudo ip netns list
clab-frrlab-PC1 (id: 5)
clab-frrlab-router2 (id: 4)
clab-frrlab-router3 (id: 3)
clab-frrlab-PC3 (id: 2)
clab-frrlab-PC2 (id: 1)
clab-frrlab-router1 (id: 0)
```

And, the *ip* commands work again in the *clab-frrlab-PC1* network namespace. For example:

```
$ sudo ip netns exec clab-frrlab-PC1 ip link
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
31: eth0@if32: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default 
    link/ether 02:42:ac:14:14:06 brd ff:ff:ff:ff:ff:ff link-netnsid 0
34: eth1@if33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 65000 qdisc noqueue state UP mode DEFAULT group default 
    link/ether 56:75:73:33:b3:e7 brd ff:ff:ff:ff:ff:ff link-netns clab-frrlab-router1
```

Then, I destroyed the topology:

```
$ sudo clab destroy --topo frrlab.yml
INFO[0000] Parsing & checking topology file: frrlab.yml 
INFO[0000] Destroying container lab: frrlab             
INFO[0000] Removed container: clab-frrlab-PC2           
INFO[0011] Removed container: clab-frrlab-PC1           
INFO[0011] Removed container: clab-frrlab-router2       
INFO[0011] Removed container: clab-frrlab-router1       
INFO[0012] Removed container: clab-frrlab-PC3           
INFO[0012] Removed container: clab-frrlab-router3       
INFO[0012] Removing container entries from /etc/hosts file 
INFO[0012] Deleting docker network 'clab'...     
```

And everything seemed to clean up correctly:

```
$ sudo ip netns list
$ sudo ip netns list-id
$ sudo ls -l /var/run/netns
total 0
```

This seems like a minor issue. Users would not notice it unless they were using *ip* comands on the host system to manage interfaces running on the network nodes. But, I wanted to document it because I spent a few hours figuring out what was happening.
