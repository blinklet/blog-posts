% Recreating a Real-World BGP Hijack with Kathara Network Emulator

[Kathará](https://www.kathara.org/) is a container-based network emulator developed by researchers at Roma Tre University in Italy as a modern successor to the [Netkit network emulator](https://opensourcenetworksimulators.com/tag/netkit/). Kathará uses Docker containers to emulate network devices rather than full virtual machines. This approach enables users to create complex topologies comprised of dozens of routers on a modest laptop. Kathará uses simple text-based configuration files that are easy to version control and share. It's open source, actively maintained, and runs on Linux, Windows, and macOS.

In this post, I will use the *Kathará* network emulator to recreate a real-world BGP route leak incident. By building a small 4-AS network topology and simulating the [January 2026 Venezuela route leak](https://blog.cloudflare.com/bgp-route-leak-venezuela/), I expect to learn both the fundamentals of Kathará and to gain hands-on experience with BGP security concepts.

## Why Emulate BGP Hijacks?

BGP, the Border Gateway Protocol, is the glue that holds the Internet together. It allows autonomous systems (ASes) to exchange routing information and determine the best paths to reach destinations across the global network. However, BGP was designed in an era when trust between network operators was assumed, leaving it vulnerable to both accidental misconfigurations and malicious attacks.

[BGP hijacks](https://manrs.org/2020/09/what-is-bgp-prefix-hijacking-part-1/) and [route leaks](https://datatracker.ietf.org/doc/html/rfc7908) are one of the most significant threats to Internet routing security. Understanding how these incidents occur helps network engineers implement proper safeguards. By recreating these scenarios in a safe, isolated lab environment, one can observe exactly how route leaks propagate through a network and experiment with mitigation techniques without affecting real infrastructure.


## Install Kathará

Before we begin, you'll need to install Kathará and set up a basic lab environment.

### Install Docker

Kathará uses Docker (or Podman) as its container runtime. Install Docker on your Linux system using your distribution's package manager. 

I am running Ubuntu 24.04 LTS so I followed the [official Docker installation guide](https://docs.docker.com/engine/install/) for Ubuntu.

After that, add your user to the `docker` group so you can run containers without `sudo`:

```bash
$ sudo usermod -aG docker $USER
```

Log out and log back in for the group change to take effect. Verify Docker is working:

```bash
$ docker run hello-world
```

You should see a message confirming Docker is installed correctly.

### Install Kathará

The [install instructions on the Kathará wiki](https://github.com/KatharaFramework/Kathara/wiki/Linux) **are outdated**[^1] and do not work in Ubuntu 24.04 because they use the deprecated _apt-key_ command. You can skip the _apt-key_ command. Instead, follow the [Kathara instructions on the Launchpad platform](https://launchpad.net/~katharaframework/+archive/ubuntu/kathara) to add the Kathará PPA to Ubuntu, then install Kathará. 

I summarize the modified install commands, below:

```bash
$ sudo add-apt-repository ppa:katharaframework/kathara
$ sudo apt update
$ sudo apt install kathara
```

Verify the installation:

```bash
$ kathara --version
```

You should see output showing the Kathará version, which was 3.8.0 when I wrote this post.

### Verify Your Setup

Run a the _check_ command to proactively [download the Kathará base container](https://hub.docker.com/r/kathara/base) and the [Kathará network plugin container](https://hub.docker.com/r/kathara/katharanp/tags), and validate that Kathará can communicate with Docker:

```text
$ kathara check
```

With your environment ready, we can move on to exploring what Kathará is and how it structures network labs.

### Set the Terminal Emulator

Run the _kathara settings_ command and set the terminal emulator used by emulated devices to be the _Gnome Terminal_. Alternatively, you could install xterm, because it is the default used by Kathará.

```text
$ kathara settings
```

In the menu that appears, select _5_, for _Choose terminal_:

```text
  ╔═════════════════════════════════════════════════════════════════════════╗
  ║                                                                         ║
  ║                            Kathara Settings                             ║
  ║                                                                         ║
  ╠═════════════════════════════════════════════════════════════════════════╣
  ║                                                                         ║
  ║                      Choose the option to change.                       ║
  ║                                                                         ║
  ╠═════════════════════════════════════════════════════════════════════════╣
  ║                                                                         ║
  ║    1 - Choose default manager                                           ║
  ║    2 - Choose default image                                             ║
  ║    3 - Automatically open terminals on startup                          ║
  ║    4 - Choose device shell to be used                                   ║
  ║    5 - Choose terminal emulator to be used                              ║
  ║    6 - Choose Kathara prefixes                                          ║
  ║    7 - Choose logging level to be used                                  ║
  ║    8 - Print Startup Logs on device startup                             ║
  ║    9 - Enable IPv6                                                      ║
  ║   10 - Choose Docker Network Plugin version                             ║
  ║   11 - Automatically mount /hosthome on startup                         ║
  ║   12 - Automatically mount /shared on startup                           ║
  ║   13 - Docker Image Update Policy                                       ║
  ║   14 - Enable Shared Collision Domains                                  ║
  ║   15 - Configure a remote Docker connection                             ║
  ║   16 - Exit                                                             ║
  ║                                                                         ║
  ║                                                                         ║
  ╚═════════════════════════════════════════════════════════════════════════╝
  >> 5

```

Then, choose _2_, to select _gnome-terminal_:

```text
  ╔═════════════════════════════════════════════════════════════════════════╗
  ║                                                                         ║
  ║                   Choose terminal emulator to be used                   ║
  ║                                                                         ║
  ║                         Current: /usr/bin/xterm                         ║
  ║                                                                         ║
  ╠═════════════════════════════════════════════════════════════════════════╣
  ║                                                                         ║
  ║     Terminal emulator application to be used for device terminals.      ║
  ║   **The application must be correctly installed in the host system!**   ║
  ║                      Default is `/usr/bin/xterm`.                       ║
  ║                                                                         ║
  ╠═════════════════════════════════════════════════════════════════════════╣
  ║                                                                         ║
  ║    1 - /usr/bin/xterm                                                   ║
  ║    2 - /usr/bin/gnome-terminal                                          ║
  ║    3 - TMUX                                                             ║
  ║    4 - Choose another terminal emulator                                 ║
  ║    5 - Return to Kathara Settings                                       ║
  ║                                                                         ║
  ║                                                                         ║
  ╚═════════════════════════════════════════════════════════════════════════╝
  >> 2
```

Then select _16_ to _Exit_.

### Pull the FRR Docker Image

We'll use the [*kathara/frr* Docker image](https://hub.docker.com/r/kathara/frr), which includes FRRouting, an open-source routing suite that supports BGP, OSPF, and other protocols. Pull it in advance to save time later:

```bash
$ docker pull kathara/frr
```

### Test a very simple lab

To verify that Kathará is working, create a lab of two routers connected to each other:

Create a test lab:

```
mkdir Kathara
cd Kathara
mkdir kathara-test
cd kathara-test
```

Create a simple lab file:

```
cat > lab.conf << EOF
r1[image]=kathara/frr
r2[image]=kathara/frr
EOF
```

Start the lab:

```
kathara lstart
```

You should see two terminals windows open, each attached to a different router, as seen below:

![]()

Stop and clean up:

```
kathara lclean
```





## Kathará Overview

Kathará's architecture consists of three main components:

1. **The Kathará CLI**: The command-line tool you interact with to start, stop, and manage labs
2. **Docker (or Podman)**: The container runtime that actually runs the network devices
3. **Container images**: Pre-built images containing the software for each device type (routers, hosts, etc.)

When you start a lab, Kathará reads your configuration files, creates Docker containers for each device, and sets up virtual network interfaces to connect them. Each container runs in its own isolated network namespace, giving you the same isolation you'd get with physical hardware or traditional VMs—but with much less overhead.

The *kathara/frr* image we pulled earlier contains FRRouting, giving us fully-featured routers capable of running BGP, OSPF, IS-IS, and other routing protocols. Kathará also provides base images for simple hosts, and you can use any Docker image that suits your needs.

### Lab Structure

A Kathará lab is simply a directory containing configuration files that describe your network topology. The structure is straightforward:

| File/Directory | Purpose |
|----------------|---------|
| `lab.conf` | Main configuration file that defines devices and network connections |
| `<device>/` | Directory for each device containing configuration files |
| `<device>.startup` | Shell script that runs when a device starts |

Let's look at each component in detail.

#### The lab.conf File

The *lab.conf* file is the heart of your lab. It defines which devices exist and how they connect to each other. Here's a simple example:

```
LAB_NAME="My First Lab"
LAB_DESCRIPTION="A simple two-router topology"
LAB_AUTHOR="Your Name"

# Router 1
router1[0]="lan_a"
router1[1]="backbone"
router1[image]="kathara/frr"

# Router 2
router2[0]="lan_b"
router2[1]="backbone"
router2[image]="kathara/frr"

# Host on LAN A
host1[0]="lan_a"
host1[image]="kathara/base"
```

The syntax follows a simple pattern: `device[interface]="collision_domain"`. A collision domain is simply a named network segment—any devices with interfaces on the same collision domain can communicate directly with each other. In the example above, `router1` and `router2` both have interfaces on the `backbone` collision domain, so they can reach each other.

The `[image]` property specifies which Docker image to use for each device. You can use different images for different device types—FRR for routers, a base Linux image for hosts, or any custom image you create.

#### Device Directories

For each device in your lab, you can create a directory with the same name. Files in this directory are copied into the container's filesystem when the lab starts. This is how you provide configuration files to your devices.

For example, if you have a router named `router1`, you might create:

```
mylab/
├── lab.conf
├── router1/
│   └── etc/
│       └── frr/
│           ├── frr.conf
│           └── daemons
└── router1.startup
```

The contents of `router1/etc/frr/` will appear at `/etc/frr/` inside the container. This allows you to pre-configure FRR's routing daemons with your BGP or OSPF settings.

#### Startup Files

The `<device>.startup` file is a shell script that runs inside the container when it starts. This is where you configure network interfaces, start services, or run any initialization commands. For example:

```bash
# router1.startup
ip addr add 10.0.1.1/24 dev eth0
ip addr add 10.0.0.1/30 dev eth1

# Start FRR routing daemons
/etc/init.d/frr start
```

The startup file executes after the device directory contents are copied in, so you can reference any configuration files you've provided.

### Essential Kathará Commands

Kathará provides a simple set of commands to manage your labs. Here are the ones you'll use most often:

#### Starting a Lab

To start a lab, navigate to the lab directory and run:

```bash
$ kathara lstart
```

Kathará reads *lab.conf*, creates the necessary containers and networks, and executes each device's startup script. You'll see output as each device comes online:

```
Starting lab...
=========================== Starting devices ===========================
router1: Container created and started.
router2: Container created and started.
host1: Container created and started.
========================= All devices started ==========================
```

#### Connecting to a Device

To open an interactive terminal session on a running device:

```bash
$ kathara connect router1
```

This drops you into a shell inside the container where you can run commands, check routing tables, or configure the device interactively. To exit, type `exit` or press Ctrl+D.

#### Checking Lab Status

To see information about a running lab:

```bash
$ kathara linfo
```

This displays details about all running devices, their interfaces, and which collision domains they're connected to.

#### Stopping and Cleaning Up

When you're done with a lab, clean up all containers and networks:

```bash
$ kathara lclean
```

This stops and removes all containers created for the lab, freeing up system resources. Always run this before starting a modified version of your lab to ensure you're working with a fresh environment.

#### Other Useful Commands

A few more commands worth knowing:

- `kathara exec <device> <command>` — Run a command on a device without opening an interactive session
- `kathara wipe` — Remove all Kathará containers and networks (useful if something goes wrong)
- `kathara list` — Show all running Kathará devices across all labs

With these fundamentals covered, you now understand how Kathará structures labs and how to interact with them. In the next section, we'll explore the BGP hijack scenario we're going to recreate before building the actual lab.

## Understanding BGP Hijacks and Route Leaks

Before we build our lab, let's examine the different ways BGP routing can go wrong. Understanding these attack types will help you recognize what's happening when we simulate the incident later.

### Types of BGP Routing Incidents

BGP routing incidents generally fall into three categories, each with different characteristics and impacts:

#### Origin Hijack

An origin hijack occurs when an AS announces a prefix it doesn't legitimately own. The hijacking AS claims to be the origin of the route, essentially saying "I own this IP address range" when it doesn't.

For example, if AS400 legitimately owns the prefix 203.0.113.0/24, an origin hijack would occur if AS999 started announcing that same prefix as if it originated there. Routers receiving both announcements would choose between them based on BGP path selection rules—and depending on network topology, some parts of the Internet might start sending traffic for 203.0.113.0/24 toward AS999 instead of the legitimate owner.

Origin hijacks can be:
- **Accidental**: A misconfigured router announces prefixes it shouldn't
- **Malicious**: An attacker deliberately announces someone else's prefixes to intercept or blackhole traffic

#### More-Specific Prefix Hijack

This is a particularly effective variant of origin hijacking. Instead of announcing the same prefix as the victim, the attacker announces a more-specific (longer) prefix that falls within the victim's address space.

BGP routers always prefer more-specific routes. If AS400 announces 203.0.113.0/24 and an attacker announces 203.0.113.0/25 and 203.0.113.128/25, the attacker's more-specific /25 routes will be preferred everywhere in the Internet, completely overriding the legitimate /24 announcement.

This attack is harder to defend against because the victim's route is never withdrawn—it's simply overshadowed by the more-specific announcements.

#### Route Leak

A route leak occurs when an AS violates the expected routing policies by redistributing routes in ways that break the traditional customer-provider-peer relationships. Unlike origin hijacks, the origin AS information remains correct—the problem is that the route is propagated where it shouldn't be.

The BGP community has defined several types of route leaks in RFC 7908. The most relevant for our lab is the **Type-1 "Hairpin" leak**: a customer AS receives routes from one provider and re-announces them to another provider. This violates the fundamental expectation that customers only announce their own prefixes (and their customers' prefixes) to their providers—not routes learned from other providers.

Route leaks are almost always accidental, caused by misconfiguration, but their effects can be severe. When a small customer AS suddenly appears to offer a shortcut to major networks, traffic can flood through infrastructure that was never designed to handle it.

### The January 2026 Venezuela Route Leak

The incident we'll recreate is based on a real-world route leak that occurred on January 2, 2026, involving Venezuelan telecommunications provider CANTV (AS8048). This event provides an excellent case study because it demonstrates the hairpin leak pattern clearly while having limited real-world impact—making it ideal for educational purposes.

#### What Happened

CANTV operates as a customer of multiple upstream providers, including:
- **Sparkle (AS6762)**: An international carrier owned by Telecom Italia
- **GlobeNet (AS52320)**: A Latin American telecommunications provider

Under normal BGP operations, CANTV should only announce its own prefixes and those of its downstream customers to these providers. However, on January 2, 2026, a misconfiguration caused CANTV to leak routes learned from Sparkle to GlobeNet.

The leaked routes included prefixes belonging to Dayco Telecom (AS21980), a Venezuelan ISP. Specifically, routes for the 200.74.224.0/20 address block began flowing through an unintended path.

#### The Traffic Flow Problem

Before the leak, traffic destined for Dayco Telecom's networks would flow through normal paths—perhaps directly from GlobeNet or through other transit providers. After the leak, GlobeNet learned about Dayco's prefixes through CANTV, creating a new (and inappropriate) path:

```
Normal path:    GlobeNet → [various transit] → Sparkle → CANTV → Dayco
Leaked path:    GlobeNet → CANTV → Sparkle → ... → Dayco
```

The leaked path is a "valley"—traffic goes down to a customer (CANTV), then back up to a provider (Sparkle). This violates the valley-free routing principle that keeps Internet routing economically sensible. Traffic flowing through the leaked path would transit CANTV's network unnecessarily, potentially causing congestion and certainly violating the business relationships between the parties.

#### Why the Impact Was Limited

Interestingly, CANTV had implemented heavy AS-path prepending on their announcements—their AS number (8048) appeared 8 or more times in the leaked routes. This made the leaked paths appear much longer than they actually were, and since BGP prefers shorter AS paths, most networks continued using the legitimate routes.

This accidental mitigation demonstrates an important point: while AS-path prepending is often used to influence inbound traffic, it can also inadvertently limit the damage from route leaks. However, it's not a reliable security measure—it merely reduced the impact rather than preventing the leak entirely.

### What We'll Build

In our lab, we'll create a simplified 4-AS topology that mirrors the structure of this incident:

```
     AS100 (Provider-A)          AS200 (Provider-B)
           |                           |
           | eBGP                       | eBGP
           |                           |
     +-----+-----------+---------------+
     |                 |
     |           AS300 (Customer/Leaker)
     |                 |
     |                 | eBGP
     |                 |
     +--------AS400 (Victim)
```

In this topology:
- **AS100 (Provider-A)** represents Sparkle—a transit provider
- **AS200 (Provider-B)** represents GlobeNet—another transit provider
- **AS300 (Customer/Leaker)** represents CANTV—the customer AS that causes the leak
- **AS400 (Victim)** represents Dayco Telecom—the AS whose routes get leaked

We'll first configure this topology with correct BGP policies, verify that routing works as expected, and then introduce the misconfiguration that causes AS300 to leak AS400's routes from Provider-A to Provider-B. You'll be able to observe the route leak in real-time using BGP monitoring commands.

Now that you understand the theory behind what we're recreating, let's build the lab.

## Building the 4-AS BGP Lab

In this section, we'll create a complete Kathará lab with four autonomous systems running BGP. We'll configure proper customer-provider relationships and verify that routing works correctly before we introduce the route leak in the next section.

### Lab Directory Structure

First, create a directory for your lab and set up the required structure:

```bash
$ mkdir -p bgp-hijack-lab
$ cd bgp-hijack-lab
```

Our completed lab will have this structure:

```
bgp-hijack-lab/
├── lab.conf
├── provider_a/
│   └── etc/
│       └── frr/
│           ├── daemons
│           └── frr.conf
├── provider_a.startup
├── provider_b/
│   └── etc/
│       └── frr/
│           ├── daemons
│           └── frr.conf
├── provider_b.startup
├── customer/
│   └── etc/
│       └── frr/
│           ├── daemons
│           └── frr.conf
├── customer.startup
├── victim/
│   └── etc/
│       └── frr/
│           ├── daemons
│           └── frr.conf
└── victim.startup
```

Let's create each file, starting with the main lab configuration.

### The lab.conf File

Create the *lab.conf* file that defines our topology:

```
LAB_NAME="BGP Route Leak Demo"
LAB_DESCRIPTION="4-AS topology demonstrating BGP route leak scenarios"
LAB_AUTHOR="Your Name"

# Provider A (AS100) - represents a transit provider like Sparkle
# eth0: connection to customer (AS300)
provider_a[0]="link_pa_customer"
provider_a[image]="kathara/frr"

# Provider B (AS200) - represents another transit provider like GlobeNet
# eth0: connection to customer (AS300)
provider_b[0]="link_pb_customer"
provider_b[image]="kathara/frr"

# Customer/Leaker (AS300) - represents CANTV, the AS that will leak routes
# eth0: connection to Provider A (AS100)
# eth1: connection to Provider B (AS200)
# eth2: connection to Victim (AS400)
customer[0]="link_pa_customer"
customer[1]="link_pb_customer"
customer[2]="link_customer_victim"
customer[image]="kathara/frr"

# Victim (AS400) - represents Dayco Telecom, whose routes get leaked
# eth0: connection to customer (AS300)
victim[0]="link_customer_victim"
victim[image]="kathara/frr"
```

This configuration creates four devices and connects them with three collision domains (virtual network segments):

- **link_pa_customer**: Connects Provider A to Customer
- **link_pb_customer**: Connects Provider B to Customer
- **link_customer_victim**: Connects Customer to Victim

### IP Addressing Scheme

Before we configure the routers, let's establish our IP addressing plan:

| Link | Network | Device | Interface | IP Address |
|------|---------|--------|-----------|------------|
| Provider A ↔ Customer | 10.0.1.0/30 | provider_a | eth0 | 10.0.1.1/30 |
| | | customer | eth0 | 10.0.1.2/30 |
| Provider B ↔ Customer | 10.0.2.0/30 | provider_b | eth0 | 10.0.2.1/30 |
| | | customer | eth1 | 10.0.2.2/30 |
| Customer ↔ Victim | 10.0.3.0/30 | customer | eth2 | 10.0.3.1/30 |
| | | victim | eth0 | 10.0.3.2/30 |

Each AS will also have a loopback address and announce a prefix representing its "owned" address space:

| AS | Loopback | Announced Prefix |
|----|----------|------------------|
| AS100 (Provider A) | 100.100.100.1/32 | 100.100.0.0/16 |
| AS200 (Provider B) | 200.200.200.1/32 | 200.200.0.0/16 |
| AS300 (Customer) | 30.30.30.1/32 | 30.30.0.0/16 |
| AS400 (Victim) | 40.40.40.1/32 | 40.40.0.0/16 |

### FRR Daemons Configuration

Each router needs a *daemons* file to tell FRR which routing protocols to enable. Create the directory structure and daemons file for each device. The content is identical for all routers:

```bash
$ mkdir -p provider_a/etc/frr
$ mkdir -p provider_b/etc/frr
$ mkdir -p customer/etc/frr
$ mkdir -p victim/etc/frr
```

Create the *daemons* file for each router. Here's the content (same for all four):

```
# /etc/frr/daemons
zebra=yes
bgpd=yes
ospfd=no
ospf6d=no
ripd=no
ripngd=no
isisd=no
pimd=no
ldpd=no
nhrpd=no
eigrpd=no
babeld=no
sharpd=no
staticd=no
pbrd=no
bfdd=no
fabricd=no

vtysh_enable=yes
zebra_options="  -A 127.0.0.1 -s 90000000"
bgpd_options="   -A 127.0.0.1"
```

Save this content to:
- *provider_a/etc/frr/daemons*
- *provider_b/etc/frr/daemons*
- *customer/etc/frr/daemons*
- *victim/etc/frr/daemons*

### Provider A Configuration (AS100)

Provider A is a transit provider. It peers with Customer (AS300) and should accept routes from its customer while announcing its own prefixes.

Create *provider_a/etc/frr/frr.conf*:

```
frr version 8.4
frr defaults traditional
hostname provider_a
log syslog informational
no ipv6 forwarding
service integrated-vtysh-config
!
router bgp 100
 bgp router-id 100.100.100.1
 bgp log-neighbor-changes
 no bgp ebgp-requires-policy
 !
 neighbor 10.0.1.2 remote-as 300
 neighbor 10.0.1.2 description Customer AS300
 !
 address-family ipv4 unicast
  network 100.100.0.0/16
  neighbor 10.0.1.2 activate
  neighbor 10.0.1.2 soft-reconfiguration inbound
 exit-address-family
exit
!
ip route 100.100.0.0/16 blackhole
!
end
```

This configuration:
- Sets up BGP with AS number 100
- Peers with Customer at 10.0.1.2 (AS300)
- Announces the 100.100.0.0/16 prefix
- Creates a blackhole route so the prefix is valid in the routing table

Create *provider_a.startup*:

```bash
ip addr add 10.0.1.1/30 dev eth0
ip addr add 100.100.100.1/32 dev lo
ip link set eth0 up

/etc/init.d/frr start
```

### Provider B Configuration (AS200)

Provider B has a similar role to Provider A—it's another transit provider that peers with Customer.

Create *provider_b/etc/frr/frr.conf*:

```
frr version 8.4
frr defaults traditional
hostname provider_b
log syslog informational
no ipv6 forwarding
service integrated-vtysh-config
!
router bgp 200
 bgp router-id 200.200.200.1
 bgp log-neighbor-changes
 no bgp ebgp-requires-policy
 !
 neighbor 10.0.2.2 remote-as 300
 neighbor 10.0.2.2 description Customer AS300
 !
 address-family ipv4 unicast
  network 200.200.0.0/16
  neighbor 10.0.2.2 activate
  neighbor 10.0.2.2 soft-reconfiguration inbound
 exit-address-family
exit
!
ip route 200.200.0.0/16 blackhole
!
end
```

Create *provider_b.startup*:

```bash
ip addr add 10.0.2.1/30 dev eth0
ip addr add 200.200.200.1/32 dev lo
ip link set eth0 up

/etc/init.d/frr start
```

### Customer Configuration (AS300)

The Customer AS is the multi-homed network that connects to both providers and to the Victim AS. In this initial configuration, we'll set up **correct** BGP policies—the Customer will only announce its own prefix and the Victim's prefix (as a legitimate transit provider for the Victim).

Create *customer/etc/frr/frr.conf*:

```
frr version 8.4
frr defaults traditional
hostname customer
log syslog informational
no ipv6 forwarding
service integrated-vtysh-config
!
! Define prefix lists to control what we announce
ip prefix-list OWN_PREFIXES seq 10 permit 30.30.0.0/16
ip prefix-list CUSTOMER_PREFIXES seq 10 permit 40.40.0.0/16
!
! Route map for announcing to providers - only our prefixes and customer prefixes
route-map TO_PROVIDERS permit 10
 match ip address prefix-list OWN_PREFIXES
exit
!
route-map TO_PROVIDERS permit 20
 match ip address prefix-list CUSTOMER_PREFIXES
exit
!
! Route map to accept everything from providers (for now)
route-map FROM_PROVIDERS permit 10
exit
!
! Route map to accept customer routes
route-map FROM_CUSTOMER permit 10
exit
!
router bgp 300
 bgp router-id 30.30.30.1
 bgp log-neighbor-changes
 no bgp ebgp-requires-policy
 !
 ! Peer with Provider A (AS100)
 neighbor 10.0.1.1 remote-as 100
 neighbor 10.0.1.1 description Provider_A AS100
 !
 ! Peer with Provider B (AS200)
 neighbor 10.0.2.1 remote-as 200
 neighbor 10.0.2.1 description Provider_B AS200
 !
 ! Peer with Victim (AS400) - we provide transit for them
 neighbor 10.0.3.2 remote-as 400
 neighbor 10.0.3.2 description Victim AS400
 !
 address-family ipv4 unicast
  network 30.30.0.0/16
  !
  ! Provider A - apply filters
  neighbor 10.0.1.1 activate
  neighbor 10.0.1.1 soft-reconfiguration inbound
  neighbor 10.0.1.1 route-map FROM_PROVIDERS in
  neighbor 10.0.1.1 route-map TO_PROVIDERS out
  !
  ! Provider B - apply filters
  neighbor 10.0.2.1 activate
  neighbor 10.0.2.1 soft-reconfiguration inbound
  neighbor 10.0.2.1 route-map FROM_PROVIDERS in
  neighbor 10.0.2.1 route-map TO_PROVIDERS out
  !
  ! Victim/Customer AS400
  neighbor 10.0.3.2 activate
  neighbor 10.0.3.2 soft-reconfiguration inbound
  neighbor 10.0.3.2 route-map FROM_CUSTOMER in
 exit-address-family
exit
!
ip route 30.30.0.0/16 blackhole
!
end
```

This configuration is the key to our lab. Notice:
- We define prefix lists for our own prefixes and our customer's prefixes
- The `TO_PROVIDERS` route-map only permits announcing these specific prefixes
- Routes learned from providers are accepted but **not** re-announced to other providers
- This is the correct behavior that prevents route leaks

Create *customer.startup*:

```bash
ip addr add 10.0.1.2/30 dev eth0
ip addr add 10.0.2.2/30 dev eth1
ip addr add 10.0.3.1/30 dev eth2
ip addr add 30.30.30.1/32 dev lo
ip link set eth0 up
ip link set eth1 up
ip link set eth2 up

/etc/init.d/frr start
```

### Victim Configuration (AS400)

The Victim AS represents Dayco Telecom—a customer of the Customer AS. It announces its prefix to Customer, expecting Customer to provide transit.

Create *victim/etc/frr/frr.conf*:

```
frr version 8.4
frr defaults traditional
hostname victim
log syslog informational
no ipv6 forwarding
service integrated-vtysh-config
!
router bgp 400
 bgp router-id 40.40.40.1
 bgp log-neighbor-changes
 no bgp ebgp-requires-policy
 !
 neighbor 10.0.3.1 remote-as 300
 neighbor 10.0.3.1 description Transit_Provider AS300
 !
 address-family ipv4 unicast
  network 40.40.0.0/16
  neighbor 10.0.3.1 activate
  neighbor 10.0.3.1 soft-reconfiguration inbound
 exit-address-family
exit
!
ip route 40.40.0.0/16 blackhole
!
end
```

Create *victim.startup*:

```bash
ip addr add 10.0.3.2/30 dev eth0
ip addr add 40.40.40.1/32 dev lo
ip link set eth0 up

/etc/init.d/frr start
```

### Starting the Lab

With all files in place, start the lab:

```bash
$ kathara lstart
```

You should see output similar to:

```
Starting lab "BGP Route Leak Demo"...
=========================== Starting devices ===========================
provider_a: Container created and started.
provider_b: Container created and started.
customer: Container created and started.
victim: Container created and started.
========================= All devices started ==========================
```

Wait about 10-15 seconds for BGP sessions to establish, then verify the lab is running:

```bash
$ kathara linfo
```

### Verifying BGP Peering

Let's connect to each router and verify that BGP sessions are established.

#### Check Provider A

```bash
$ kathara connect provider_a
```

Once inside the container, enter the FRR shell and check BGP neighbors:

```bash
root@provider_a:/# vtysh
provider_a# show ip bgp summary
```

You should see output showing the BGP session with Customer (AS300) is established:

```
IPv4 Unicast Summary:
BGP router identifier 100.100.100.1, local AS number 100 vrf-id 0
BGP table version 4
RIB entries 7, using 1344 bytes of memory
Peers 1, using 724 KiB of memory

Neighbor        V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt
10.0.1.2        4        300        12        13        4    0    0 00:02:15            2        1

Total number of neighbors 1
```

The `State/PfxRcd` column shows `2`, meaning Provider A has received 2 prefixes from Customer (AS300's own prefix and AS400's prefix that Customer is providing transit for).

Check the BGP table to see the routes:

```bash
provider_a# show ip bgp
```

```
BGP table version is 4, local router ID is 100.100.100.1, vrf id 0
Default local pref 100, local AS 100
Status codes:  s suppressed, d damped, h history, * valid, > best, = multipath,
               i internal, r RIB-failure, S Stale, R Removed
Nexthop codes: @NNN nexthop's vrf id, < announce-nh-self
Origin codes:  i - IGP, e - EGP, ? - incomplete

   Network          Next Hop            Metric LocPrf Weight Path
*> 30.30.0.0/16     10.0.1.2                 0             0 300 i
*> 40.40.0.0/16     10.0.1.2                               0 300 400 i
*> 100.100.0.0/16   0.0.0.0                  0         32768 i

Displayed  3 routes and 3 total paths
```

This shows:
- 30.30.0.0/16 learned from AS300 (Customer's prefix)
- 40.40.0.0/16 learned via AS300 with AS path "300 400" (Victim's prefix, transited through Customer)
- 100.100.0.0/16 is locally originated

Exit the FRR shell and container:

```bash
provider_a# exit
root@provider_a:/# exit
```

#### Check Provider B

```bash
$ kathara connect provider_b
```

```bash
root@provider_b:/# vtysh
provider_b# show ip bgp
```

```
BGP table version is 4, local router ID is 200.200.200.1, vrf id 0
Default local pref 100, local AS 200
Status codes:  s suppressed, d damped, h history, * valid, > best, = multipath,
               i internal, r RIB-failure, S Stale, R Removed
Nexthop codes: @NNN nexthop's vrf id, < announce-nh-self
Origin codes:  i - IGP, e - EGP, ? - incomplete

   Network          Next Hop            Metric LocPrf Weight Path
*> 30.30.0.0/16     10.0.2.2                 0             0 300 i
*> 40.40.0.0/16     10.0.2.2                               0 300 400 i
*> 200.200.0.0/16   0.0.0.0                  0         32768 i

Displayed  3 routes and 3 total paths
```

Notice that Provider B sees the same routes from Customer:
- Customer's own prefix (30.30.0.0/16)
- Victim's prefix via Customer (40.40.0.0/16 with AS path "300 400")

**Importantly, Provider B does NOT see Provider A's prefix (100.100.0.0/16) in routes learned from Customer.** This is because our route-map correctly filters outbound announcements—Customer only announces its own prefix and its customer's prefix, not routes learned from other providers.

Exit:

```bash
provider_b# exit
root@provider_b:/# exit
```

#### Check Customer

```bash
$ kathara connect customer
```

```bash
root@customer:/# vtysh
customer# show ip bgp summary
```

```
IPv4 Unicast Summary:
BGP router identifier 30.30.30.1, local AS number 300 vrf-id 0
BGP table version 5
RIB entries 7, using 1344 bytes of memory
Peers 3, using 2172 KiB of memory

Neighbor        V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt
10.0.1.1        4        100        15        14        5    0    0 00:04:30            1        2
10.0.2.1        4        200        15        14        5    0    0 00:04:28            1        2
10.0.3.2        4        400        14        15        5    0    0 00:04:25            1        4

Total number of neighbors 3
```

All three BGP sessions are established. The `PfxSnt` column shows:
- 2 prefixes sent to each provider (Customer's own + Victim's prefix)
- 4 prefixes sent to Victim (all routes for transit)

Check the full BGP table:

```bash
customer# show ip bgp
```

```
BGP table version is 5, local router ID is 30.30.30.1, vrf id 0
Default local pref 100, local AS 300
Status codes:  s suppressed, d damped, h history, * valid, > best, = multipath,
               i internal, r RIB-failure, S Stale, R Removed
Nexthop codes: @NNN nexthop's vrf id, < announce-nh-self
Origin codes:  i - IGP, e - EGP, ? - incomplete

   Network          Next Hop            Metric LocPrf Weight Path
*> 30.30.0.0/16     0.0.0.0                  0         32768 i
*> 40.40.0.0/16     10.0.3.2                 0             0 400 i
*> 100.100.0.0/16   10.0.1.1                 0             0 100 i
*> 200.200.0.0/16   10.0.2.1                 0             0 200 i

Displayed  4 routes and 4 total paths
```

Customer has learned routes from all neighbors:
- Its own prefix (30.30.0.0/16)
- Victim's prefix (40.40.0.0/16) from AS400
- Provider A's prefix (100.100.0.0/16) from AS100
- Provider B's prefix (200.200.0.0/16) from AS200

Now let's verify what Customer is advertising to each neighbor:

```bash
customer# show ip bgp neighbors 10.0.2.1 advertised-routes
```

```
BGP table version is 5, local router ID is 30.30.30.1, vrf id 0
Default local pref 100, local AS 300
Status codes:  s suppressed, d damped, h history, * valid, > best, = multipath,
               i internal, r RIB-failure, S Stale, R Removed
Nexthop codes: @NNN nexthop's vrf id, < announce-nh-self
Origin codes:  i - IGP, e - EGP, ? - incomplete

   Network          Next Hop            Metric LocPrf Weight Path
*> 30.30.0.0/16     0.0.0.0                  0         32768 i
*> 40.40.0.0/16     10.0.3.2                 0             0 400 i

Total number of prefixes 2
```

This confirms that Customer is only advertising its own prefix and Victim's prefix to Provider B. The route-map is working correctly—Provider A's prefix (100.100.0.0/16) is not being leaked to Provider B.

Exit:

```bash
customer# exit
root@customer:/# exit
```

#### Check Victim

```bash
$ kathara connect victim
```

```bash
root@victim:/# vtysh
victim# show ip bgp
```

```
BGP table version is 5, local router ID is 40.40.40.1, vrf id 0
Default local pref 100, local AS 400
Status codes:  s suppressed, d damped, h history, * valid, > best, = multipath,
               i internal, r RIB-failure, S Stale, R Removed
Nexthop codes: @NNN nexthop's vrf id, < announce-nh-self
Origin codes:  i - IGP, e - EGP, ? - incomplete

   Network          Next Hop            Metric LocPrf Weight Path
*> 30.30.0.0/16     10.0.3.1                 0             0 300 i
*> 40.40.0.0/16     0.0.0.0                  0         32768 i
*> 100.100.0.0/16   10.0.3.1                               0 300 100 i
*> 200.200.0.0/16   10.0.3.1                               0 300 200 i

Displayed  4 routes and 4 total paths
```

Victim sees all networks through its transit provider (Customer). The AS paths show routes going through AS300 to reach the providers.

Exit:

```bash
victim# exit
root@victim:/# exit
```

### Verifying Connectivity

Let's test end-to-end connectivity by pinging between ASes. Connect to the Victim and ping Provider A's loopback:

```bash
$ kathara connect victim
```

```bash
root@victim:/# ping -c 3 100.100.100.1
PING 100.100.100.1 (100.100.100.1) 56(84) bytes of data.
64 bytes from 100.100.100.1: icmp_seq=1 ttl=62 time=0.089 ms
64 bytes from 100.100.100.1: icmp_seq=2 ttl=62 time=0.087 ms
64 bytes from 100.100.100.1: icmp_seq=3 ttl=62 time=0.072 ms

--- 100.100.100.1 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2028ms
rtt min/avg/max/mdev = 0.072/0.082/0.089/0.007 ms
```

The ping succeeds, confirming that routing is working correctly through the BGP-learned paths.

Exit:

```bash
root@victim:/# exit
```

### Lab Status Summary

At this point, we have a fully functional 4-AS BGP topology with **correct** routing policies:

| From | Can Reach | Via Path |
|------|-----------|----------|
| Victim (AS400) | Provider A (AS100) | AS400 → AS300 → AS100 |
| Victim (AS400) | Provider B (AS200) | AS400 → AS300 → AS200 |
| Provider A (AS100) | Victim (AS400) | AS100 → AS300 → AS400 |
| Provider B (AS200) | Victim (AS400) | AS200 → AS300 → AS400 |

The Customer AS (AS300) is correctly:
- Announcing its own prefix (30.30.0.0/16) to both providers
- Announcing its customer's prefix (40.40.0.0/16) to both providers
- **NOT** leaking provider routes to other providers

In the next section, we'll introduce the misconfiguration that causes a route leak and observe its effects.

### Cleaning Up

When you're ready to stop the lab and free up resources:

```bash
$ kathara lclean
```

This removes all containers and networks created for the lab. You can restart the lab at any time with `kathara lstart`.

## Recreating the Route Leak

Now comes the interesting part—we'll introduce the misconfiguration that causes Customer (AS300) to leak routes from Provider A to Provider B, recreating the Venezuela route leak scenario. This demonstrates how a simple configuration error can violate the valley-free routing principle and cause routes to propagate through unintended paths.

### Understanding What We're About to Break

In our current configuration, Customer (AS300) has a route-map called `TO_PROVIDERS` that carefully filters outbound announcements. It only permits:

1. Customer's own prefix (30.30.0.0/16)
2. Customer's customer prefix (40.40.0.0/16 from Victim)

Routes learned from Provider A (100.100.0.0/16) are accepted into Customer's BGP table but are **not** re-announced to Provider B. This is the correct behavior.

The misconfiguration we'll introduce simulates what happens when someone accidentally removes or loosens these filters—perhaps during a late-night maintenance window or when copying a configuration template without understanding it. Suddenly, Customer starts announcing Provider A's routes to Provider B, creating a "hairpin" leak.

### The Before State

Before making changes, let's capture the current state so we can clearly see the difference after the leak. Make sure your lab is running:

```bash
$ kathara lstart
```

Wait for BGP sessions to establish (about 15 seconds), then check Provider B's BGP table:

```bash
$ kathara connect provider_b
```

```bash
root@provider_b:/# vtysh
provider_b# show ip bgp
```

```
BGP table version is 4, local router ID is 200.200.200.1, vrf id 0
Default local pref 100, local AS 200
Status codes:  s suppressed, d damped, h history, * valid, > best, = multipath,
               i internal, r RIB-failure, S Stale, R Removed
Nexthop codes: @NNN nexthop's vrf id, < announce-nh-self
Origin codes:  i - IGP, e - EGP, ? - incomplete

   Network          Next Hop            Metric LocPrf Weight Path
*> 30.30.0.0/16     10.0.2.2                 0             0 300 i
*> 40.40.0.0/16     10.0.2.2                               0 300 400 i
*> 200.200.0.0/16   0.0.0.0                  0         32768 i

Displayed  3 routes and 3 total paths
```

Note that Provider B only sees three routes:
- Customer's prefix (30.30.0.0/16)
- Victim's prefix via Customer (40.40.0.0/16)
- Its own prefix (200.200.0.0/16)

**Provider A's prefix (100.100.0.0/16) is NOT present.** This is the correct, leak-free state.

Exit Provider B:

```bash
provider_b# exit
root@provider_b:/# exit
```

### Introducing the Route Leak

Now we'll modify Customer's BGP configuration to simulate the misconfiguration. We'll add a new rule to the `TO_PROVIDERS` route-map that permits all routes—effectively disabling the outbound filtering.

Connect to Customer:

```bash
$ kathara connect customer
```

Enter the FRR configuration shell:

```bash
root@customer:/# vtysh
customer# configure terminal
```

First, let's look at the current route-map:

```bash
customer(config)# do show running-config | section route-map TO_PROVIDERS
```

```
route-map TO_PROVIDERS permit 10
 match ip address prefix-list OWN_PREFIXES
exit
!
route-map TO_PROVIDERS permit 20
 match ip address prefix-list CUSTOMER_PREFIXES
exit
```

Now, add a new rule that permits everything else. This simulates someone accidentally adding a "permit all" rule:

```bash
customer(config)# route-map TO_PROVIDERS permit 100
customer(config-route-map)# exit
customer(config)# exit
```

The new rule `permit 100` has no match conditions, so it matches (and permits) all routes that weren't matched by the previous rules. This is exactly the kind of mistake that causes real-world route leaks—someone adds a catch-all rule without realizing the implications.

Verify the modified route-map:

```bash
customer# show running-config | section route-map TO_PROVIDERS
```

```
route-map TO_PROVIDERS permit 10
 match ip address prefix-list OWN_PREFIXES
exit
!
route-map TO_PROVIDERS permit 20
 match ip address prefix-list CUSTOMER_PREFIXES
exit
!
route-map TO_PROVIDERS permit 100
exit
```

The damage is done. BGP will now re-evaluate what to advertise to neighbors. Force a route refresh to make the changes take effect immediately:

```bash
customer# clear ip bgp * soft out
```

This command triggers a soft outbound reset, causing Customer to re-advertise routes to all neighbors using the updated route-map.

Exit Customer:

```bash
customer# exit
root@customer:/# exit
```

### Observing the Route Leak

Now let's see the impact. Connect to Provider B and check its BGP table:

```bash
$ kathara connect provider_b
```

```bash
root@provider_b:/# vtysh
provider_b# show ip bgp
```

```
BGP table version is 5, local router ID is 200.200.200.1, vrf id 0
Default local pref 100, local AS 200
Status codes:  s suppressed, d damped, h history, * valid, > best, = multipath,
               i internal, r RIB-failure, S Stale, R Removed
Nexthop codes: @NNN nexthop's vrf id, < announce-nh-self
Origin codes:  i - IGP, e - EGP, ? - incomplete

   Network          Next Hop            Metric LocPrf Weight Path
*> 30.30.0.0/16     10.0.2.2                 0             0 300 i
*> 40.40.0.0/16     10.0.2.2                               0 300 400 i
*> 100.100.0.0/16   10.0.2.2                               0 300 100 i
*> 200.200.0.0/16   0.0.0.0                  0         32768 i

Displayed  4 routes and 4 total paths
```

**There it is!** Provider B now sees a fourth route: **100.100.0.0/16 via Customer (AS300)**. The AS path is "300 100", meaning the route goes through Customer to reach Provider A.

This is the route leak in action. Provider A's prefix is now being announced to Provider B through Customer, violating the expected customer-provider relationship.

### Analyzing the Leaked Route

Let's examine the leaked route in detail:

```bash
provider_b# show ip bgp 100.100.0.0/16
```

```
BGP routing table entry for 100.100.0.0/16, version 5
Paths: (1 available, best #1, table default)
  Advertised to non peer-group peers:
  300 100
    10.0.2.2 from 10.0.2.2 (30.30.30.1)
      Origin IGP, metric 0, valid, external, best (First path received)
      Last update: Sat Jan 25 14:32:15 2026
```

The key information:
- **AS Path: 300 100** — The route came through AS300 (Customer) from AS100 (Provider A)
- **Next Hop: 10.0.2.2** — Traffic would be sent to Customer's interface
- **Origin: IGP** — This was legitimately originated by AS100

This is a classic "valley" in BGP routing. Instead of Provider B reaching Provider A through their normal peering or transit arrangements, traffic could now flow: Provider B → Customer → Provider A. Customer's network becomes an unintended (and likely unpaid) transit path.

### The Valley-Free Violation

To understand why this is problematic, let's visualize the expected vs. actual routing:

**Expected (Valley-Free) Routing:**

```
Provider A (AS100)     Provider B (AS200)
      \                     /
       \                   /
        \                 /
         \               /
          Customer (AS300)
               |
               |
          Victim (AS400)
```

In valley-free routing:
- Traffic flows "down" from providers to customers
- Traffic flows "up" from customers to providers
- Traffic should never go up-down-up (forming a valley)

**After the Route Leak:**

Provider B now has a route to Provider A that goes *down* to Customer, then *up* to Provider A:

```
Provider B → Customer → Provider A
   (down)       (up)
```

This creates a "valley"—traffic descends to a customer, then ascends back to a provider. This pattern violates BGP best practices and the implicit business relationships between networks.

### Checking the Customer's Advertised Routes

Let's verify what Customer is now advertising to Provider B:

```bash
$ kathara connect customer
```

```bash
root@customer:/# vtysh
customer# show ip bgp neighbors 10.0.2.1 advertised-routes
```

```
BGP table version is 5, local router ID is 30.30.30.1, vrf id 0
Default local pref 100, local AS 300
Status codes:  s suppressed, d damped, h history, * valid, > best, = multipath,
               i internal, r RIB-failure, S Stale, R Removed
Nexthop codes: @NNN nexthop's vrf id, < announce-nh-self
Origin codes:  i - IGP, e - EGP, ? - incomplete

   Network          Next Hop            Metric LocPrf Weight Path
*> 30.30.0.0/16     0.0.0.0                  0         32768 i
*> 40.40.0.0/16     10.0.3.2                 0             0 400 i
*> 100.100.0.0/16   10.0.1.1                 0             0 100 i

Total number of prefixes 3
```

Compare this to what we saw earlier (only 2 prefixes). Customer is now advertising 3 prefixes to Provider B, including the leaked route 100.100.0.0/16.

Similarly, check what's being advertised to Provider A:

```bash
customer# show ip bgp neighbors 10.0.1.1 advertised-routes
```

```
BGP table version is 5, local router ID is 30.30.30.1, vrf id 0
Default local pref 100, local AS 300
Status codes:  s suppressed, d damped, h history, * valid, > best, = multipath,
               i internal, r RIB-failure, S Stale, R Removed
Nexthop codes: @NNN nexthop's vrf id, < announce-nh-self
Origin codes:  i - IGP, e - EGP, ? - incomplete

   Network          Next Hop            Metric LocPrf Weight Path
*> 30.30.0.0/16     0.0.0.0                  0         32768 i
*> 40.40.0.0/16     10.0.3.2                 0             0 400 i
*> 200.200.0.0/16   10.0.2.1                 0             0 200 i

Total number of prefixes 3
```

The leak is bidirectional! Customer is also advertising Provider B's prefix (200.200.0.0/16) to Provider A. Both providers are now receiving each other's routes through Customer.

Exit:

```bash
customer# exit
root@customer:/# exit
```

### Real-World Impact of This Leak

In our lab, this leak has limited consequences—we're in an isolated environment with only four ASes. But in the real Internet, a leak like this can cause:

1. **Traffic Redirection**: If the leaked path appears shorter or more attractive, traffic destined for Provider A's networks might flow through Customer instead of direct paths. Customer's network suddenly handles transit traffic it never expected.

2. **Congestion and Outages**: Customer's infrastructure may not be designed to handle transit traffic volumes. Links can become saturated, causing packet loss and increased latency for everyone—including Customer's own users.

3. **Financial Implications**: Transit agreements typically involve payment. Customer is now providing unpaid transit between two providers, potentially violating contracts and losing money.

4. **Security Concerns**: Traffic flowing through an unintended path could be subject to inspection, modification, or interception by the leaking AS (whether intentional or not).

### Why the Venezuela Leak Had Limited Impact

Recall from our earlier discussion that the real January 2026 Venezuela leak (AS8048/CANTV) had limited impact partly due to heavy AS-path prepending. Let's simulate this mitigation technique.

When we look at our current leaked route at Provider B:

```
100.100.0.0/16 ... Path: 300 100
```

The AS path has only 2 hops. In the real incident, CANTV's announcements had AS8048 prepended 8+ times, making paths look like:

```
Path: 300 300 300 300 300 300 300 300 100
```

This long path would be less preferred than shorter alternatives, limiting how far the leak would propagate. Let's add prepending to our Customer configuration to see this effect.

Connect to Customer:

```bash
$ kathara connect customer
```

```bash
root@customer:/# vtysh
customer# configure terminal
```

Modify the route-map to add AS-path prepending for leaked routes:

```bash
customer(config)# route-map TO_PROVIDERS permit 100
customer(config-route-map)# set as-path prepend 300 300 300 300 300 300 300 300
customer(config-route-map)# exit
customer(config)# exit
```

Apply the changes:

```bash
customer# clear ip bgp * soft out
customer# exit
root@customer:/# exit
```

Now check Provider B's view of the leaked route:

```bash
$ kathara connect provider_b
```

```bash
root@provider_b:/# vtysh
provider_b# show ip bgp 100.100.0.0/16
```

```
BGP routing table entry for 100.100.0.0/16, version 6
Paths: (1 available, best #1, table default)
  Advertised to non peer-group peers:
  300 300 300 300 300 300 300 300 300 100
    10.0.2.2 from 10.0.2.2 (30.30.30.1)
      Origin IGP, metric 0, valid, external, best (First path received)
      Last update: Sat Jan 25 14:45:22 2026
```

The AS path is now much longer: "300 300 300 300 300 300 300 300 300 100" (9 AS hops instead of 2). If Provider B had an alternative path to AS100 with a shorter AS path, BGP would prefer that alternative—the leak would have no practical effect on routing decisions.

Exit:

```bash
provider_b# exit
root@provider_b:/# exit
```

### Fixing the Route Leak

Now let's restore proper filtering to stop the leak. Connect to Customer:

```bash
$ kathara connect customer
```

```bash
root@customer:/# vtysh
customer# configure terminal
```

Remove the problematic catch-all rule:

```bash
customer(config)# no route-map TO_PROVIDERS permit 100
customer(config)# exit
```

Verify the route-map is back to its original state:

```bash
customer# show running-config | section route-map TO_PROVIDERS
```

```
route-map TO_PROVIDERS permit 10
 match ip address prefix-list OWN_PREFIXES
exit
!
route-map TO_PROVIDERS permit 20
 match ip address prefix-list CUSTOMER_PREFIXES
exit
```

Apply the fix:

```bash
customer# clear ip bgp * soft out
customer# exit
root@customer:/# exit
```

Check Provider B to confirm the leak is fixed:

```bash
$ kathara connect provider_b
```

```bash
root@provider_b:/# vtysh
provider_b# show ip bgp
```

```
BGP table version is 7, local router ID is 200.200.200.1, vrf id 0
Default local pref 100, local AS 200
Status codes:  s suppressed, d damped, h history, * valid, > best, = multipath,
               i internal, r RIB-failure, S Stale, R Removed
Nexthop codes: @NNN nexthop's vrf id, < announce-nh-self
Origin codes:  i - IGP, e - EGP, ? - incomplete

   Network          Next Hop            Metric LocPrf Weight Path
*> 30.30.0.0/16     10.0.2.2                 0             0 300 i
*> 40.40.0.0/16     10.0.2.2                               0 300 400 i
*> 200.200.0.0/16   0.0.0.0                  0         32768 i

Displayed  3 routes and 3 total paths
```

Provider A's prefix (100.100.0.0/16) is gone. The route leak is fixed.

Exit:

```bash
provider_b# exit
root@provider_b:/# exit
```

### Summary: Before and After Comparison

Here's a side-by-side comparison of Provider B's routing table:

| State | Routes Seen | AS Paths for AS100 Prefix |
|-------|-------------|--------------------------|
| **Before Leak** | 3 routes (own, AS300, AS400) | Not present |
| **During Leak** | 4 routes (+ AS100 prefix) | 300 100 |
| **With Prepending** | 4 routes (+ AS100 prefix) | 300 300 300 300 300 300 300 300 300 100 |
| **After Fix** | 3 routes (own, AS300, AS400) | Not present |

This exercise demonstrates:
1. How easily a route leak can occur (just one misconfigured route-map rule)
2. How to detect route leaks by examining BGP tables and AS paths
3. How AS-path prepending can accidentally mitigate leak impact
4. How to fix the leak by restoring proper outbound filtering

### Cleanup

When you're finished experimenting with the route leak scenario:

```bash
$ kathara lclean
```

This removes all containers and networks, giving you a clean slate for future labs.

## Mitigating BGP Route Leaks

Now that you've seen how easily a route leak can occur, let's discuss the techniques network operators use to prevent them. While we've already demonstrated prefix filtering with route-maps in our lab, there are several complementary approaches that provide defense in depth.

### Prefix Filtering with Prefix Lists and Route Maps

The most fundamental protection against route leaks is explicit prefix filtering. This is exactly what we implemented (and then broke) in our Customer router configuration.

#### The Defense-in-Depth Approach

Proper BGP hygiene requires filtering at multiple points:

1. **Outbound filtering on customer routers**: Customers should only announce their own prefixes and those of their downstream customers. This is what our `TO_PROVIDERS` route-map enforced.

2. **Inbound filtering on provider routers**: Providers should validate that customers only announce prefixes they're authorized to announce. This creates a second line of defense if customer-side filtering fails.

Here's an example of how Provider A could implement inbound filtering to only accept Customer's legitimate prefixes:

```
! On Provider A - inbound filter for Customer
ip prefix-list CUSTOMER_AS300_ALLOWED seq 10 permit 30.30.0.0/16
ip prefix-list CUSTOMER_AS300_ALLOWED seq 20 permit 40.40.0.0/16

route-map FROM_CUSTOMER permit 10
 match ip address prefix-list CUSTOMER_AS300_ALLOWED
exit

router bgp 100
 neighbor 10.0.1.2 route-map FROM_CUSTOMER in
```

With this configuration, even if Customer misconfigures their outbound filters and tries to announce Provider B's prefix (200.200.0.0/16), Provider A would reject it. The leaked routes would never enter Provider A's BGP table.

#### Maintaining Prefix Lists

The challenge with prefix filtering is maintenance. In a small lab with four ASes and four prefixes, it's easy to keep track of everything. In the real Internet, customers may have hundreds of prefixes, and those prefixes change over time as organizations acquire new address space or restructure their networks.

Most providers maintain prefix filters using one of these approaches:

- **Internet Routing Registry (IRR)**: Databases like RADB, RIPE, and ARIN contain records of which ASes are authorized to originate which prefixes. Tools like *bgpq4* can automatically generate prefix lists from IRR data.

- **Manual coordination**: Smaller providers may manually maintain prefix lists based on customer contracts and periodic reviews.

- **RPKI (discussed below)**: The modern cryptographic approach that's increasingly replacing IRR-based filtering.

### BGP Communities for Policy Control

BGP communities provide another layer of control by tagging routes with metadata that influences how they're processed. While communities don't prevent route leaks directly, they enable more sophisticated routing policies that can limit leak propagation.

#### How Communities Work

A BGP community is a 32-bit value attached to a route, typically written as two 16-bit numbers (e.g., `65000:100`). Networks agree on community meanings and use them to signal routing intent.

Common community uses include:

- **Customer/peer/transit tagging**: Mark routes based on where they were learned, then use route-maps to control re-advertisement
- **Geographic tagging**: Indicate where a route was learned (useful for large networks with multiple regions)
- **Action communities**: Request specific behaviors from upstream providers (like "don't announce to peers")

#### Preventing Leaks with Communities

Here's a conceptual example of how communities could help prevent our route leak scenario:

```
! On Customer - tag routes by source
route-map FROM_PROVIDER_A permit 10
 set community 300:100
exit

route-map FROM_PROVIDER_B permit 10
 set community 300:200
exit

! Only announce routes tagged as "from customer" to providers
route-map TO_PROVIDERS permit 10
 match community FROM_CUSTOMERS
exit
```

With this approach, routes learned from providers get tagged with provider-specific communities. The outbound route-map only permits routes that were learned from customers (which would have a different community), automatically blocking provider-learned routes from being re-announced.

#### Well-Known Communities

BGP defines several well-known communities that all implementations should recognize:

| Community | Meaning |
|-----------|---------|
| `NO_EXPORT` | Don't advertise outside the local AS |
| `NO_ADVERTISE` | Don't advertise to any BGP peer |
| `NO_EXPORT_SUBCONFED` | Don't advertise outside the local confederation |

Providers can use `NO_EXPORT` to prevent customers from re-announcing certain routes. However, this only works if the customer's router honors the community—it's not a cryptographic guarantee.

### RPKI and Route Origin Validation

Resource Public Key Infrastructure (RPKI) represents a fundamental shift in BGP security. Instead of relying on trust and manual coordination, RPKI provides cryptographic proof of route authorization.

#### How RPKI Works

RPKI consists of two main components:

1. **Route Origin Authorizations (ROAs)**: Cryptographically signed statements that say "AS X is authorized to originate prefix Y." ROAs are published in distributed repositories maintained by Regional Internet Registries (RIRs).

2. **Route Origin Validation (ROV)**: The process of checking whether a received BGP route matches a valid ROA. Routes can be classified as:
   - **Valid**: The origin AS matches a ROA for that prefix
   - **Invalid**: A ROA exists but specifies a different origin AS
   - **Not Found**: No ROA exists for this prefix

#### RPKI in Practice

When a router performs ROV, it can take action based on the validation state:

```
! Example RPKI configuration (conceptual)
router bgp 100
 rpki cache 192.0.2.1 port 8323
 
 address-family ipv4 unicast
  neighbor 10.0.1.2 route-map RPKI_POLICY in
  
route-map RPKI_POLICY deny 10
 match rpki invalid
!
route-map RPKI_POLICY permit 20
```

This configuration rejects routes that fail RPKI validation (where the origin AS doesn't match the ROA) while accepting valid and not-found routes.

#### RPKI Adoption and Limitations

RPKI adoption has grown significantly in recent years. Major networks including Cloudflare, Google, and many tier-1 providers now validate routes and drop RPKI-invalid announcements. According to NIST's RPKI Monitor, over 50% of the Internet's routes now have valid ROAs.

However, RPKI has limitations:

- **Only validates origin AS**: RPKI proves that an AS is authorized to originate a prefix, but it doesn't validate the AS path. A route leak where the origin remains correct (like our lab scenario) would still appear RPKI-valid.

- **Incomplete coverage**: Many prefixes still lack ROAs, meaning they're classified as "not found" and typically accepted.

- **Deployment challenges**: Creating and maintaining ROAs requires coordination with RIRs and careful attention to avoid accidentally creating ROAs that invalidate legitimate routes.

#### BGPsec: The Next Step

BGPsec extends RPKI to provide path validation, cryptographically signing each AS hop in the path. This would detect our route leak because the path through Customer to Provider A would fail validation. However, BGPsec faces significant deployment challenges:

- Every AS in the path must support BGPsec
- Computational overhead for signing and verification
- Partial deployment provides limited benefit

As of 2026, BGPsec remains largely experimental, though work continues on improving its feasibility.

### Best Practices Summary

Based on what we've learned, here are the key practices for preventing route leaks:

| Layer | Technique | Protection Level |
|-------|-----------|------------------|
| **Customer** | Outbound prefix filtering | First line of defense |
| **Provider** | Inbound prefix filtering (IRR/RPKI) | Catches customer misconfigurations |
| **Community** | Tag and filter by route source | Policy-based protection |
| **RPKI** | Route Origin Validation | Cryptographic origin verification |
| **Future** | BGPsec | Full path validation |

No single technique provides complete protection. The most resilient networks implement multiple layers, recognizing that any individual control can fail due to misconfiguration, software bugs, or malicious intent.

### Further Reading

For deeper exploration of BGP security, I recommend these resources:

- [NIST BGP Security Guidelines (SP 800-189)](https://csrc.nist.gov/publications/detail/sp/800-189/final): Comprehensive guidance on securing BGP infrastructure
- [MANRS (Mutually Agreed Norms for Routing Security)](https://www.manrs.org/): Industry initiative promoting routing security best practices
- [Cloudflare's BGP Security Series](https://blog.cloudflare.com/tag/bgp/): Accessible explanations of BGP incidents and mitigations
- [RPKI Documentation at ARIN/RIPE/APNIC](https://www.arin.net/resources/manage/rpki/): Guides for creating and managing ROAs

## Conclusion

In this post, I've walked you through using Kathará to recreate a real-world BGP route leak incident. By building a 4-AS topology and deliberately introducing a misconfiguration, you've seen firsthand how route leaks occur and propagate—and more importantly, how to detect and fix them.

Here's what we covered:

- **Kathará fundamentals**: How to structure labs with *lab.conf*, device directories, and startup files; essential commands like `kathara lstart`, `lclean`, and `connect`
- **BGP security concepts**: The differences between origin hijacks, more-specific prefix hijacks, and route leaks; the valley-free routing principle
- **Hands-on lab work**: Building a complete 4-AS topology with FRRouting, configuring proper BGP policies, and then breaking them to observe the effects
- **Mitigation techniques**: Prefix filtering, BGP communities, and RPKI/ROV as layers of defense

The beauty of network emulation is that you can experiment freely without risking production infrastructure. I encourage you to extend this lab—try adding more ASes, experiment with different route-map configurations, or simulate other types of BGP incidents like origin hijacks with more-specific prefixes.

### Next Steps with Kathará

If you want to continue exploring BGP scenarios with Kathará, the project maintains an excellent collection of ready-to-use labs:

- **[Kathará Labs Repository](https://github.com/KatharaFramework/Kathara-Labs)**: The official collection of example labs covering various networking topics
- **[Interdomain Routing Labs with FRR](https://github.com/KatharaFramework/Kathara-Labs/tree/main/main-labs/interdomain-routing/frr)**: Specifically focused on BGP scenarios using FRRouting, including eBGP/iBGP configurations, route reflection, and more complex multi-AS topologies
- **[Kathará Wiki](https://github.com/KatharaFramework/Kathara/wiki)**: Comprehensive documentation covering advanced features like bridged networking, custom Docker images, and integration with other tools

### Final Thoughts

BGP route leaks remain one of the Internet's persistent vulnerabilities. While the Venezuela incident we recreated had limited impact thanks to AS-path prepending, other leaks have caused significant outages affecting millions of users. As network engineers, understanding these vulnerabilities—not just theoretically, but through hands-on practice—is essential for building more resilient infrastructure.

The good news is that the tools for preventing and detecting route leaks are improving. RPKI adoption continues to grow, major providers are implementing stricter filtering, and initiatives like MANRS are raising awareness of routing security best practices. By practicing with tools like Kathará, you're building the skills needed to contribute to a more secure Internet.

Happy labbing!


[^1] https://github.com/KatharaFramework/Kathara/wiki/Linux as viewed on January 25, 2026