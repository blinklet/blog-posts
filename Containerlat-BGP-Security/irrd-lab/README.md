# IRRd + Containerlab Lab

This lab runs IRRd as a dedicated server node inside a Containerlab topology.
You query it from a separate utility node (`bgpq4`) over topology IP connectivity, not via host port mapping.

## What this lab deploys

- `irrd` node: PostgreSQL + Redis + IRRd in one container, reachable on `10.0.0.4` (WHOIS TCP/43)
- `bgpq4` node: query/utility container connected to transit, used to run `bgpq4`, `nc`, and `whois`
- `as100`, `as200`, `as300`: FRR routers for BGP filter testing

## Prerequisites

- Docker
- Containerlab
- `sudo` access for `containerlab deploy`

## Build images

From this directory (`irrd-lab/`):

```bash
$ docker build -t irrd-lab -f Dockerfile.irrd .
$ docker build -t bgpq4-utils -f Dockerfile.bgpq4 .
```

## Access IRRd from your PC browser

The topology publishes IRRd ports to your host PC:

- `http://localhost:8080` → IRRd HTTP API
- `localhost:8043` → IRRd WHOIS (container port 43)

After deploy, open Firefox on your PC and query IRRd directly, for example:

```text
http://localhost:8080/v1/whois/?q=AS300
http://localhost:8080/v1/whois/?q=-i%20origin%20AS100
```

WHOIS query from host shell:

```bash
$ whois -h localhost -p 8043 -- '-i origin AS200'
```

## Deploy topology

```bash
$ sudo containerlab deploy -t topology.yml
```

Wait for IRRd startup:

```bash
$ docker logs -f clab-bgplab-irrd 2>&1 | grep -m1 "IRRd Lab Container Ready"
```

## Query IRRd from the separate query node

Run WHOIS protocol queries from `bgpq4` to the IRRd server IP (`10.0.0.4`):

```bash
$ docker exec clab-bgplab-bgpq4 sh -lc 'echo "-i origin AS100" | nc 10.0.0.4 43'
$ docker exec clab-bgplab-bgpq4 sh -lc 'echo "198.51.100.0/24" | nc 10.0.0.4 43'
$ docker exec clab-bgplab-bgpq4 whois -h 10.0.0.4 -- '-i origin AS200'
```

Run bgpq4 from the same utility node:

```bash
$ docker exec clab-bgplab-bgpq4 bgpq4 -h 10.0.0.4 -S LABRIR -l AS100-IN AS-ISP-A
$ docker exec clab-bgplab-bgpq4 bgpq4 -h 10.0.0.4 -S LABRIR -l AS200-IN AS-ISP-B
```

## Apply generated filters to AS300

```bash
$ ./generate-filters.sh
```

Verify on transit:

```bash
$ docker exec clab-bgplab-as300 vtysh -c 'show ip prefix-list'
$ docker exec clab-bgplab-as300 vtysh -c 'show ip bgp'
```

## Healthcheck notes

The IRRd image `HEALTHCHECK` validates:

- PostgreSQL is ready (`pg_isready -q`)
- Redis responds (`redis-cli ping`)
- IRRd WHOIS listener is up (`nc -z 127.0.0.1 43`)

Use a running container name when inspecting health:

```bash
$ docker inspect --format '{{json .State.Health}}' clab-bgplab-irrd
```

## Clean up

```bash
$ sudo containerlab destroy -t topology.yml
```


## Other clab exec commands

```
clab exec -t topology.yml --label clab-node-name=bgpq4 --cmd 'whois -h 10.0.0.4 AS300'
clab exec -t topology.yml --label clab-node-name=bgpq4 --cmd 'whois -h 10.0.0.4 -i mnt-by LAB-MNT'

docker exec -it clab-bgplab-bgpq4 /bin/bash
```

