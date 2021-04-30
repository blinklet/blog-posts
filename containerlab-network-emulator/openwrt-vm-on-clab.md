

https://containerlab.srlinux.dev/manual/vrnetlab/

https://www.brianlinkletter.com/2019/03/vrnetlab-emulate-networks-using-kvm-and-docker/

https://github.com/hellt/vrnetlab

```
$ sudo apt install -y python3-bs4 sshpass make
$ git clone https://github.com/hellt/vrnetlab.git
$ cd vrnetlab/openwrt
$ wget https://downloads.openwrt.org/releases/19.07.7/targets/x86/64/openwrt-19.07.7-x86-64-combined-ext4.img.gz
$ sudo make build
$ sudo docker image ls
$ sudo docker tag vrnetlab/vr-openwrt:18.06.2 openwrt
```

Now we have a Docker image named *openwrt* that will run an OpenWRT VM.

```
$ sudo docker image ls
```



