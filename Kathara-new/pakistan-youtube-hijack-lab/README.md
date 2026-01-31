# Pakistan YouTube BGP Hijack Lab

This Kathara lab recreates the famous February 24, 2008 BGP hijack incident where Pakistan Telecom (AS17557) accidentally hijacked YouTube's IP address space, causing a global outage.

## Historical Background

On February 24, 2008, the Pakistani government ordered ISPs to block access to YouTube due to a video deemed offensive. Pakistan Telecom attempted to implement this block by creating a null route for YouTube's IP prefix. However, this route was inadvertently advertised to their upstream provider PCCW (AS3491), which then propagated it globally.

YouTube announced `208.65.152.0/22`, while Pakistan Telecom announced the more-specific `208.65.153.0/24`. Due to BGP's longest-prefix-match rule, the /24 was preferred, causing global traffic destined for that range to be blackholed in Pakistan.

## Lab Topology

```
                    +----------+
                    | upstream |
                    |  AS400   |
                    +----+-----+
                         |
                         | 10.0.3.0/24
                         |
                    +----+-----+
                    | transit  |
                    |  AS300   |
                    +----+-----+
                    /           \
       10.0.1.0/24 /             \ 10.0.2.0/24
                  /               \
           +-----+----+     +-----+-----+
           | youtube  |     | pakistan  |
           |  AS100   |     |  AS200    |
           +----------+     +-----------+
           (Victim)         (Hijacker)
```

## IP Addressing

| Router   | AS  | Interface | IP Address    | Role |
|----------|-----|-----------|---------------|------|
| youtube  | 100 | eth0      | 10.0.1.1/24   | Victim |
| youtube  | 100 | lo        | 100.100.0.1   | Router ID (within /22) |
| pakistan | 200 | eth0      | 10.0.2.2/24   | Hijacker |
| pakistan | 200 | lo        | 200.200.0.1   | Router ID |
| transit  | 300 | eth0      | 10.0.1.2/24   | Transit |
| transit  | 300 | eth1      | 10.0.2.1/24   | Transit |
| transit  | 300 | eth2      | 10.0.3.1/24   | Transit |
| transit  | 300 | lo        | 30.30.0.1     | Router ID |
| upstream | 400 | eth0      | 10.0.3.2/24   | Observer |
| upstream | 400 | lo        | 40.40.0.1     | Router ID |

**Important**: Loopback addresses are placed within each AS's announced prefix so they are reachable via BGP. The link addresses (10.0.x.x) are not advertised.

## Announced Prefixes

| Router   | Prefix          | Description |
|----------|-----------------|-------------|
| youtube  | 100.100.0.0/22  | YouTube's legitimate prefix |
| pakistan | 200.200.0.0/16  | Pakistan's legitimate prefix |
| pakistan | 100.100.1.0/24  | Hijacked prefix (added manually) |
| transit  | 30.30.0.0/16    | Transit's prefix |
| upstream | 40.40.0.0/16    | Upstream's prefix |

## Running the Lab

### Start the lab

```bash
cd pakistan-youtube-hijack-lab
kathara lstart
```

### Verify normal operation

Check the BGP table on upstream before the hijack:

```bash
kathara connect upstream
vtysh
show ip bgp
```

You should see YouTube's `100.100.0.0/22` with path `300 100`.

Test connectivity to YouTube's loopback (use `-I lo` to source from loopback):

```bash
exit
ping -I lo -c 3 100.100.0.1
```

This should succeed - traffic reaches YouTube via BGP.

### Simulate the hijack

Connect to Pakistan and add the hijack prefix:

```bash
kathara connect pakistan
vtysh
configure terminal
router bgp 200
 address-family ipv4 unicast
  network 100.100.1.0/24
exit
exit
ip route 100.100.1.0/24 Null0
exit
```

### Observe the hijack

Check upstream's BGP table again:

```bash
kathara connect upstream
vtysh
show ip bgp
```

You'll now see both:
- `100.100.0.0/22` (path: 300 100) - YouTube's legitimate route
- `100.100.1.0/24` (path: 300 200) - Pakistan's hijacked route

Traffic to `100.100.1.x` addresses now goes to Pakistan (blackholed).

### Simulate YouTube's counter-attack

YouTube responded by announcing /25 prefixes to reclaim their address space:

```bash
kathara connect youtube
vtysh
configure terminal
router bgp 100
 address-family ipv4 unicast
  network 100.100.1.0/25
  network 100.100.1.128/25
exit
exit
ip route 100.100.1.0/25 Null0
ip route 100.100.1.128/25 Null0
exit
```

### Verify counter-attack success

```bash
kathara connect upstream
vtysh
show ip bgp
```

YouTube's /25 prefixes now win over Pakistan's /24 due to longest-prefix-match.

### Cleanup

```bash
kathara lclean
```

## Learning Objectives

1. Understand how BGP prefix hijacks work
2. See the longest-prefix-match rule in action
3. Learn how victims can counter-attack using more-specific prefixes
4. Appreciate the importance of prefix filtering and RPKI

## Further Reading

- [RIPE NCC Case Study: YouTube Hijacking](https://www.ripe.net/publications/news/industry-developments/youtube-hijacking-a-ripe-ncc-ris-case-study)
- [BGP Security Best Practices](https://www.manrs.org/)
- [RPKI Documentation](https://www.arin.net/resources/manage/rpki/)
