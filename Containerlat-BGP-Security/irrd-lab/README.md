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

## Bootstrap a Web UI account (no SMTP)

The entrypoint always creates (or updates) a fixed Web UI admin account before IRRd starts:

- Email: `test@irrtest.com`
- Password: `mypassword`

Run normally:

```bash
$ docker run -d --name irrd-lab -p 8080:8080 -p 43:43 irrd-lab:latest
```


curl 'http://localhost:8080/v1/whois/?q=-i%20mnt-by%20LAB-MNT'

curl 'http://localhost:8080/v1/whois/?q=AS300'

curl 'http://localhost:8080/v1/whois/?q=AS300'

cat > update.json <<'EOF'
{
  "objects": [
    {
      "object_text": "aut-num:        AS200\nas-name:        ISP-B\ndescr:          ISP-B - Peer that will attempt unauthorized announcement\nadmin-c:        LAB-ADMIN\ntech-c:         LAB-ADMIN\nmnt-by:         LAB-MNT\nsource:         LABRIR\n"
    }
  ],
  "passwords": ["mypassword"]
}
EOF

curl -v \
  -H "Content-Type: application/json" \
  --data-binary @update.json \
  http://localhost:8080/v1/submit/



  whois -h localhost -- '-i mnt-by LAB-MNT'

jq -Rs '{objects:[{object_text:.}], passwords:["mypassword"]}' lab-irr-data.rpsl > update2.json