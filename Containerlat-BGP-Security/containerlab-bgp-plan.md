# Blog Post Plan: BGP Security with Containerlab

## Post Title (Draft)
**"Using Containerlab to Demonstrate BGP Security: RPKI and RIR Databases in Practice"**

---

## Executive Summary

This blog post will demonstrate how researchers and network engineers can use Containerlab to build realistic BGP security labs that showcase how RPKI (Resource Public Key Infrastructure) and RIR (Regional Internet Registry) databases help prevent BGP hijacks and route leaks. The post will highlight Containerlab's evolution since 2021 and provide a hands-on lab with open-source RPKI validators.

---

## Target Audience

- Network engineers learning BGP security concepts
- Researchers studying Internet routing security
- Students preparing for networking certifications or academic projects
- Security professionals investigating BGP attack scenarios

---

## Prerequisites to Mention

- Basic understanding of BGP (AS numbers, prefixes, peering)
- Linux command-line familiarity
- Docker installed and working
- Containerlab installed (link to existing post or official docs)

---

## Post Structure

### Part 1: Introduction (200-300 words)

**Goals:**
- Hook: Reference recent BGP hijack incidents (e.g., Russia/Ukraine 2022, Pakistan/YouTube 2008 as context)
- Make it clear that this post is about two main things: understanding the utility of containerlab, and BGP Security senarios you can create in your own lab
- Briefly explain why BGP security matters (Internet routing trust issues)
- State what readers will learn: build a lab demonstrating route and max prefix validation using RIR databases and also using RPKI-based route validation
- Brief mention of Containerlab as the tool of choice

**Key Points:**
- BGP was designed with implicit trust—no built-in authentication
- BGP hijacks and route leaks continue to cause Internet outages, with recent examples
- RIR databases contain information useful for analyzing prefix announcements for validity
- RPKI provides cryptographic verification of route origin authorization
- Containerlab is ideal for building these educational scenarios

---

### Part 2: Containerlab's Evolution (2021-2026) (400-500 words)

**Goals:**
- Update readers who may have used Containerlab 5 years ago
- Highlight major improvements that make it better for this type of lab

**Topics to Research and Cover:**

1. **Improved VM Support (vrnetlab)**
   - More commercial NOS images supported
   - Better integration with VM-based devices

2. **New Node Types and Kinds**
   - Native support for more open-source routers (FRR, BIRD, GoBGP)
   - Kubernetes integration
   - Improved Linux container support

3. **Topology Features**
   - Multi-node labs with complex topologies
   - Improved link configuration options
   - Network namespaces and external connectivity

4. **DevOps Integration**
   - Better CI/CD pipeline support
   - Improved automation capabilities
   - Integration with Ansible, Terraform

5. **Community Growth**
   - Larger ecosystem of example labs
   - Active GitHub community
   - More documentation and tutorials

6. **Performance Improvements**
   - Faster lab deployment
   - Better resource management
   - Improved cleanup operations

**Research Required:**
- Read files ../containerlab-network-emulator/containerlab.md and ../containerlab-network-emulator/containerlab-issue.md to understand what I previously wrote about Containerlab 5 years ago
- Review Containerlab release notes (2021-2026)
- Check Containerlab GitHub for major milestones
- Identify changes relevant to BGP/routing labs

---

### Part 3: BGP Security Background (500-600 words)

**Goals:**
- Explain the problem Containerlab will help demonstrate
- Cover just enough theory for readers to understand the lab

**Topics:**

1. **BGP Trust Model Problems**
   - No inherent authentication of route announcements
   - AS can announce any prefix
   - Examples of accidental and malicious hijacks

2. **Types of BGP Attacks**
   - Prefix hijacking (more specific prefix)
   - Route leaks (announcing routes that shouldn't propagate)
   - AS path manipulation

3. **Defense Mechanisms Overview**
   - RIR databases (RADB, ARIN, RIPE, APNIC, LACNIC, AFRINIC)
   - Internet Routing Registry (IRR) filtering
   - Max prefix lengths in RIR databases
   - RPKI (ROA, validators, RTR protocol)
   - BGP communities and policies
   - MANRS (Mutually Agreed Norms for Routing Security)

4. **RPKI Deep Dive**
   - Resource certificates (from RIRs)
   - Route Origin Authorizations (ROAs)
   - Validation states: Valid, Invalid, Unknown
   - RPKI-to-Router (RTR) protocol
   - How routers use RPKI data

---

### Part 4: Lab Architecture Design (300-400 words + diagram)

**Goals:**
- Present the lab topology
- Explain each component's role

**Lab Components:**

```
┌─────────────────────────────────────────────────────────────────┐
│                        Lab Topology                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│                     ┌──────────────┐     ┌──────────────┐       │
│                     │   upstream   │     │     RIR      │       │
│                     │    AS400     │_____│  Database    │       │
│                     │   (RPKI-     │     │              │       │
│                     │   enabled)   │     │              │       │
│                     └──────┬───────┘     └──────────────┘       │
│                            │                                    │
│                            │                                    │
│        ┌───────────┐ ┌───────────┐ ┌───────────┐                │
│        │  transit  │_│ transit2  │_│  transit3 │                │
│        │   AS300   │ │   AS301   │ │   AS302   │                │
│        └─────┬─────┘ └─────┬─────┘ └─────┬─────┘                │
│              │             │             │                      │
│        ┌─────┴─────┐       │       ┌─────┴─────┐                │
│        │           │       │       │           │                │
│        │   AS100   │       │       │   AS200   │                │
│        │ (Victim)  │       │       │ (Attacker)│                │
│        └───────────┘       │       └───────────┘                │
│                            │                                    │
│                   ┌────────┴────────┐                           │
│                   │ rpki-validator  │                           │
│                   │  (Routinator)   │                           │
│                   └─────────────────┘                           │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Node Types:**
- **Victim (AS100)**: Legitimate origin AS, announces prefix with valid ROA
- **Attacker (AS200)**: Attacker AS, attempts hijack with invalid/no ROA
- **transit (AS300, 301, 302)**: Transit providers with varying RPKI policies
- **upstream (AS400)**: Top-level provider with strict RPKI validation
- **RIR database**:  Copy of RIR database suitable for building filter lists in this scenario
- **rpki-validator**: Routinator container serving RPKI data via RTR

---

### Part 5: Lab Implementation (1000-1200 words)

**Goals:**
- Step-by-step instructions to build and run the lab

**Sections:**

#### 5.2 Containerlab Topology File

- Define all nodes with appropriate images
- FRR containers for routers
- Routinator container for RPKI validator
- Network links between nodes

#### 5.3 FRR Configuration Files

- BGP peering configuration
- Prefix announcements
- RPKI integration (rpki cache commands)

#### 5.4 RPKI Validator Setup

**Option A: Routinator (from NLnet Labs)**
- Most popular open-source RPKI validator
- Docker image available
- Serves RTR protocol on port 3323
- Can use local test ROAs for lab scenarios

**Option B: Alternative validators to mention**
- rpki-client (OpenBSD)
- gortr (Cloudflare)
- FORT Validator
- Krill (for running your own CA - advanced)

#### 5.5 Creating Test ROAs

- Use Routinator's local exceptions file
- Or use Krill to run a mini-CA
- Explain how to create ROA entries for lab ASes

---

### Part 6: Running the Lab Scenarios (800-1000 words)

**Goals:**
- Walk through actual attack and defense scenarios

**Scenarios:**

#### 6.1 Scenario 1: Normal Operation (Baseline)
- Start the lab
- Verify BGP sessions established
- Check routing tables
- Confirm RPKI validation working
- Show ROAs for AS100 prefix

#### 6.2 Scenario 2: Hijack Attempt Without RPKI
- Disable RPKI on upstream router
- Have attacker announce victim's prefix
- Show how traffic gets hijacked
- Analyze BGP table

#### 6.3 Scenario 3: Hijack Blocked by RPKI
- Re-enable RPKI on upstream router
- Repeat hijack attempt
- Show RPKI validation result (Invalid)
- Demonstrate route rejection
- Show logs and validation states

#### 6.4 Scenario 4: Route Leak Demonstration
- Show how even valid routes can be leaked
- Demonstrate need for AS-path filters
- Discuss ASPA (future RPKI extension)

---

### Part 7: Verification Commands (300-400 words)

**Goals:**
- Provide quick reference for validation

**Commands to Cover:**

```bash
# FRR RPKI commands
show rpki cache-connection
show rpki cache-server
show rpki prefix <prefix>
show ip bgp <prefix>
show ip bgp rpki notfound
show ip bgp rpki invalid
show ip bgp rpki valid

# Routinator commands
routinator vrps -f json
routinator server --rtr
```

---

### Part 8: Advanced Topics (Optional Section) (300-400 words)

**Topics to briefly cover:**

1. **Integrating with Real RPKI Data**
   - Using Routinator with actual RPKI repositories
   - Network connectivity requirements

2. **ASPA (AS Path Authorization)**
   - Future RPKI extension
   - Helps prevent route leaks

3. **BGP Communities for Policy**
   - Using communities alongside RPKI

4. **Automation with Python**
   - Using bgpstuff.net or RIPE RIS APIs
   - Automating validation checks

---

### Part 9: Conclusion (200-300 words)

**Goals:**
- Summarize what was learned
- Encourage adoption of RPKI
- Point to additional resources

**Key Points:**
- Containerlab makes it easy to build realistic BGP security labs
- RPKI effectively blocks prefix hijacks
- Network operators should deploy RPKI validators
- ROA creation is essential for prefix owners

---

## Technical Research Required

### Containerlab Evolution
- [ ] Review Containerlab GitHub releases (2021-2026)
- [ ] Document major new features
- [ ] Test current version compatibility

### RPKI Tools
- [ ] Test Routinator Docker image
- [ ] Verify RTR protocol integration with FRR
- [ ] Document local ROA configuration
- [ ] Test Krill for local CA (optional advanced section)

### FRR RPKI Support
- [ ] Verify FRR version with RPKI support (8.0+)
- [ ] Test rpki configuration commands
- [ ] Document required FRR compilation flags (if any)

### Lab Validation
- [ ] Build and test complete topology
- [ ] Verify all scenarios work as described
- [ ] Screenshot key validation steps
- [ ] Timing estimates for each section

---

## Images/Diagrams Needed

1. **Containerlab splash/logo** (existing or new screenshot)
2. **Lab topology diagram** (created with draw.io or Mermaid)
3. **BGP hijack before/after comparison**
4. **RPKI validation flow diagram**
5. **FRR show commands output screenshots**
6. **Routinator dashboard screenshot**

---

## External Resources to Link

### Official Documentation
- [Containerlab Documentation](https://containerlab.dev/)
- [FRR Documentation - RPKI](https://docs.frrouting.org/en/latest/rpki.html)
- [Routinator Documentation](https://routinator.docs.nlnetlabs.nl/)
- [RIPE NCC RPKI Documentation](https://www.ripe.net/manage-ips-and-asns/resource-management/rpki/)

### BGP Security Resources
- [MANRS (Mutually Agreed Norms for Routing Security)](https://www.manrs.org/)
- [NIST BGP Security Guidelines](https://csrc.nist.gov/publications/detail/sp/800-189/final)
- [BGP Security Wikipedia](https://en.wikipedia.org/wiki/BGP_hijacking)

### Incident References
- [Pakistan/YouTube 2008 Hijack](https://www.ripe.net/publications/news/industry-developments/youtube-hijacking-a-ripe-ncc-ris-case-study)
- [BGPStream - Real-time BGP Monitoring](https://bgpstream.caida.org/)

---

## Estimated Word Count

| Section | Words |
|---------|-------|
| Introduction | 300 |
| Containerlab Evolution | 500 |
| BGP Security Background | 600 |
| Lab Architecture | 400 |
| Lab Implementation | 1200 |
| Running Scenarios | 1000 |
| Verification Commands | 400 |
| Advanced Topics | 400 |
| Conclusion | 300 |
| **Total** | **~5100** |

---

## Open Questions for Author (answered)

1. **Lab Complexity**: Use the more realistic 6-node version shown above

2. **RPKI Validator Choice**: Focus Routinator but compate alternatives

3. **Real vs. Simulated RPKI Data**: Use local test ROAs only, but discuss how to connect to real RPKI repositories

4. **Target Reading Time**: Reading time is not an issue. The post may be as long as needed


---

## Notes on Existing Content

### Containerlab Post (2021)
- Located at: `containerlab-network-emulator/containerlab.md`
- Covers basic FRR lab setup
- Uses Containerlab with FRR v7.5.1
- Good foundation but needs updates for current versions

### Kathara BGP Hijack Lab
- Located at: `Kathara-new/pakistan-youtube-hijack-lab/`
- Demonstrates Pakistan/YouTube hijack scenario
- Uses FRR with BGP
- Does NOT include RPKI - good opportunity for differentiation
- Can reuse hijack scenario concept but add RPKI protection

### Key Differentiation from Kathara Post
- Use Containerlab instead of Kathara
- Add RPKI validation layer
- Show how RPKI prevents the hijack
- Include real RPKI validator container (Routinator)

---

## Timeline Estimate

| Task | Time |
|------|------|
| Research Containerlab changes | 2 hours |
| Research RPKI tools | 2 hours |
| Build and test lab | 4 hours |
| Write draft | 6 hours |
| Create diagrams/screenshots | 2 hours |
| Edit and polish | 2 hours |
| **Total** | **~18 hours** |

---

## Success Criteria

- [ ] Lab deploys successfully with single command
- [ ] All BGP sessions establish properly
- [ ] RPKI validation prevents hijack in Scenario 3
- [ ] Clear screenshots/output showing validation states
- [ ] All commands tested and verified working
- [ ] Links to working lab files in GitHub (optional)
