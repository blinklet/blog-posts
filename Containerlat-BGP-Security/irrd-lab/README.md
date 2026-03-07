# IRRd Lab Container

This lab image runs PostgreSQL, Redis, and IRRd in one container for Containerlab testing.

## Healthcheck

The image defines a Docker `HEALTHCHECK` that verifies:

- PostgreSQL is accepting connections (`pg_isready -q`)
- Redis is responding (`redis-cli ping` returns `PONG`)
- IRRd WHOIS TCP listener is up on port `43` (`nc -z 127.0.0.1 43`)

## Inspect container health

```bash
$ docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}'
$ docker inspect --format '{{json .State.Health}}' <container_name>
```

A brief initial `starting` or one failed probe can be normal while services initialize.

If you run `docker inspect ... irrd-lab` and `irrd-lab` is an image name (not a container name), Docker will return a template error like `map has no entry for key "State"`.
