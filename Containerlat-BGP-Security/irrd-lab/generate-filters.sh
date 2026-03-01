#!/bin/bash
#
# generate-filters.sh
# Queries the lab IRRd server and applies prefix filters to AS300 (Transit)
#
# Usage: Run from any host that has Docker access to the Containerlab containers.
#
#   ./generate-filters.sh
#
# Prerequisites:
#   - The Containerlab topology is running (clab-bgplab-* containers exist)
#   - IRRd is ready and serving WHOIS queries on 10.0.0.4:43
#   - The bgpq4 utility container is running and can reach IRRd

set -euo pipefail

IRRD_HOST="10.0.0.4"
IRRD_SOURCE="LABRIR"
TRANSIT_CONTAINER="clab-bgplab-as300"
BGPQ4_CONTAINER="clab-bgplab-bgpq4"

echo "=== Generating IRR-based prefix filters for AS300 ==="
echo ""

# --- Generate prefix-list for AS100 (ISP-A) ---
echo "Querying IRRd for AS100 authorized prefixes..."
AS100_FILTER=$(docker exec "$BGPQ4_CONTAINER" bgpq4 -h "$IRRD_HOST" -S "$IRRD_SOURCE" -l AS100-IN AS-ISP-A)
echo "$AS100_FILTER"
echo ""

# --- Generate prefix-list for AS200 (ISP-B) ---
echo "Querying IRRd for AS200 authorized prefixes..."
AS200_FILTER=$(docker exec "$BGPQ4_CONTAINER" bgpq4 -h "$IRRD_HOST" -S "$IRRD_SOURCE" -l AS200-IN AS-ISP-B)
echo "$AS200_FILTER"
echo ""

# --- Apply filters to AS300's FRR via vtysh ---
echo "Applying prefix filters to ${TRANSIT_CONTAINER}..."

docker exec "$TRANSIT_CONTAINER" vtysh -c "
configure terminal
!
${AS100_FILTER}
${AS200_FILTER}
!
route-map AS100-IN permit 10
 match ip address prefix-list AS100-IN
route-map AS100-IN deny 20
!
route-map AS200-IN permit 10
 match ip address prefix-list AS200-IN
route-map AS200-IN deny 20
!
router bgp 300
 address-family ipv4 unicast
  neighbor 10.0.0.0 route-map AS100-IN in
  neighbor 10.0.0.2 route-map AS200-IN in
 exit-address-family
exit
!
end
"

echo ""
echo "Filters applied. Performing soft reset on BGP sessions..."

docker exec "$TRANSIT_CONTAINER" vtysh -c "clear bgp ipv4 unicast * soft in"

echo ""
echo "=== Done. Verify with: ==="
echo "  docker exec ${TRANSIT_CONTAINER} vtysh -c 'show ip prefix-list'"
echo "  docker exec ${TRANSIT_CONTAINER} vtysh -c 'show ip bgp'"
