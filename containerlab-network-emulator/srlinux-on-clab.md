
Get srlinux file and license file from website

Create image
Make a directory to store the srlinux file

```
mkdir ~/srl
```

Get srlinux file and license file from website and save them in the new folder

```
ls ~/srl
21.3.1-410.tar.xz  license.key
```

Load the *tar.xz* file into a Docker image

```
$ cd ~/srl
$ sudo docker image load -i ./21.3.1-410.tar.xz
fbc567608feb: Loading layer  1.088GB/1.088GB
Loaded image: srlinux:21.3.1-410
```

Check the image name:

```
$ sudo docker images
REPOSITORY                 TAG          IMAGE ID       CREATED       SIZE
praqma/network-multitool   latest       293c239dd855   9 days ago    38.1MB
debian                     latest       0d587dfbc4f4   2 weeks ago   114MB
frrouting/frr              v7.5.1       c3e13a4c5918   2 weeks ago   123MB
srlinux                    21.3.1-410   0fe16823d2ba   4 weeks ago   1.06GB
```

Let's first test the lab example *srl02* provided by the Containerlab project. The *srl02* lab example should be in the directory */etc/containerlab/lab-examples/srl02*. Copy the directory to your home folder:

```
$ cp -r /etc/containerlab/lab-examples/srl02 ~/
```

Copy the srl license key into the lab folder

```
$ cp ~/srl/license.key ~/srl02/
```

The lab directory should contain the following files:

```
$ls
license.key  srl02.clab.yml  srl1.cfg.json  srl2.cfg.json
```

The *srl02.clab.yml* file describes the topology. Docker needs the full image name, with its tag so you need to edit the topology file and change the *image* value to *srlinux:21.3.1-410*. The new file will look like:

```
# topology documentation: http://containerlab.srlinux.dev/lab-examples/two-srls/
name: srl02

topology:
  kinds:
    srl:
      type: ixr6 # See https://www.nokia.com/networks/products/7250-interconnect-router/
      image: srlinux:21.3.1-410
      license: license.key
  nodes:
    srl1:
      kind: srl
      config: srl1.cfg.json
    srl2:
      kind: srl
      config: srl2.cfg.json

  links:
    - endpoints: ["srl1:e1-1", "srl2:e1-1"]
```




You can see that Containerlab's built-in support for srlinux allows users to specify a configuration file that each srlinux node will use when it starts. This lets you to start the lab in a known state.

Run the topology

```
$ sudo clab deploy --topo srl02.clab.yml
INFO[0000] Parsing & checking topology file: srl02.clab.yml 
INFO[0000] Creating lab directory: /home/brian/srl02/clab-srl02 
INFO[0000] Creating container: srl1                     
INFO[0000] Creating container: srl2                     
INFO[0001] Creating virtual wire: srl1:e1-1 <--> srl2:e1-1 
INFO[0001] Writing /etc/hosts file                      
+---+-----------------+--------------+--------------------+------+-------+---------+----------------+----------------------+
| # |      Name       | Container ID |       Image        | Kind | Group |  State  |  IPv4 Address  |     IPv6 Address     |
+---+-----------------+--------------+--------------------+------+-------+---------+----------------+----------------------+
| 1 | clab-srl02-srl1 | 5dbdcf63fa62 | srlinux:21.3.1-410 | srl  |       | running | 172.20.20.2/24 | 2001:172:20:20::2/64 |
| 2 | clab-srl02-srl2 | f28e8da55a1c | srlinux:21.3.1-410 | srl  |       | running | 172.20.20.3/24 | 2001:172:20:20::3/64 |
+---+-----------------+--------------+--------------------+------+-------+---------+----------------+----------------------+
```

srl01 and srl02 have been configured with an ssh server so we can login using SSH

```
$ ssh admin@clab-srl02-srl1
Last login: Thu Apr 29 18:14:43 2021 from 172.20.20.1
Using configuration file(s): []
Welcome to the srlinux CLI.
Type 'help' (and press <ENTER>) if you need any help using this.
--{ running }--[  ]--                                                           
A:srl1#
```








