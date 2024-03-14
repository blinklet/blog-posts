% History of SDN in Google's datacentre

"""
A quick overview of Urs Hölzle’s LinkedIn post about how Google developed the "SDN-based fabric" that many hyperscale datacentres use today.
"""

I recently read a [very interesting post on LinkedIn](https://www.linkedin.com/feed/update/urn:li:activity:7169073511582420994/) in which Urs Hölzle, one of the original Google network engineers, celebrated twenty years of Google network innovation and provided links to the recent paper from Google describing [how Google developed its datacentre network](https://research.google/pubs/jupiter-rising-a-decade-of-clos-topologies-and-centralized-control-in-googles-datacenter-network/) and how it has evolved since then. It describes how Google applied the [Clos network topology](https://docs.nvidia.com/networking-ethernet-software/guides/EVPN-Network-Reference/Introduction/) and its early implementations of software-defined-networking that controled data flows across the network.

One point that was really interesting, which came up in the [comments](https://www.linkedin.com/feed/update/urn:li:ugcPost:7169073508470255616?commentUrn=urn%3Ali%3Acomment%3A%28ugcPost%3A7169073508470255616%2C7169763157870137344%29&dashCommentUrn=urn%3Ali%3Afsd_comment%3A%287169763157870137344%2Curn%3Ali%3AugcPost%3A7169073508470255616%29) to the article, is that Google implemented the original network routing code in *Python*.

Mr. Hölzle also linked to an [independant research report](https://nyquistcapital.com/2007/11/16/googles-secret-10gbe-switch/) that came out at the time, that provided the initial view of what Google was developing, and is interesting to read almost 20 years after it was written.