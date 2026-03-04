# Plan: Containerlab Update Blog Post

**Target file:** `containerlab-update.md`  
**Working title:** *Containerlab in 2026: What's Changed Since 2021*

---

## Goal

Write a standalone blog post that revisits Containerlab five years after the original 2021 review. The post should serve as an updated overview and getting-started guide, covering what Containerlab is, how to install and test it, and — most importantly — what has changed in the Containerlab ecosystem since 2021. It should highlight the VS Code extension, the improved `graph` command, and other quality-of-life tools that now surround the project.

This post will complement the upcoming BGP security lab post (`containerlab-bgp-security.md`) by handling all the "Containerlab introduction" material so the BGP post can link to it rather than repeat it.

---

## Source Material

Pull and adapt the following sections from `containerlab-bgp-security.md`:

| Source section | Approx. lines | Use in new post |
|---|---|---|
| **Containerlab** overview (what it is, lab-as-code, history) | Lines 19–37 | Rewrite as the introduction / "What is Containerlab" section |
| **Containerlab Prerequisites** | Lines 39–50 | Keep mostly as-is for the prerequisites section |
| **Install Containerlab** | Lines 52–82 | Keep mostly as-is; update with alternative install methods |
| **Deploy a sample lab to validate the setup** | Lines 84–145 | Keep mostly as-is; add graph/visualization after deploy |
| **Tear down** | Lines 147–150 | Include at the end of the test section |

Also reference the original 2021 post (`containerlab-network-emulator/containerlab.md`) for comparison points (e.g., the old `graph` command behavior, old install method, the need for `sudo`, etc.).

---

## Post Outline (step-by-step writing plan)

### Step 1 — Title and Introduction

Write the title and a short introduction (3–4 paragraphs) that:

- States this is a 2026 revisit of Containerlab, five years after the original review
- Briefly says what Containerlab is (one sentence)
- Lists the key improvements readers will learn about
- Includes the `<!--more-->` tag after the intro paragraph

Use the overview paragraphs from `containerlab-bgp-security.md` (lines 19–37) as a starting point, but reframe them so the *update* angle is the lead.

### Step 2 — "What is Containerlab?" section

Write a concise overview section that:

- Describes Containerlab: container-based, YAML-driven, lab-as-code
- Mentions support for open-source routers (FRR, BIRD, GoBGP, OpenBGPD) via `kind: linux`
- Mentions support for commercial NOS images (Nokia SR Linux, Arista cEOS, etc.) and VM-based images via vrnetlab/boxen
- Links to the official site: <https://containerlab.dev>
- Adapted from `containerlab-bgp-security.md` lines 19–37

### Step 3 — "What's Changed Since 2021" section

Research and write about the key changes in the Containerlab ecosystem. Cover the following sub-sections:

#### 3a — Core Containerlab improvements

- **No more `sudo`**: Containerlab now supports rootless operation and the `clab_admins` group (reference the install section from `containerlab-bgp-security.md`)
- **Declarative node configuration**: The `exec:` stanza in topology files now lets you run commands at startup without needing separate shell scripts (contrast with the 2021 post where shell scripts were needed)
- **`binds:` for config injection**: Bind-mounting config files directly into containers (lab-as-code)
- **Bridge node type**: `kind: bridge` for shared Ethernet segments (like IXP peering LANs)
- **Improved `deploy` and `destroy` commands**: Faster, more reliable lifecycle management
- **Lab examples shipped with install**: `/etc/containerlab/lab-examples/` directory

#### 3b — The Containerlab VS Code Extension

- Describe the [Containerlab VS Code extension](https://marketplace.visualstudio.com/items?itemName=srl-labs.containerlab) (published by Nokia / SR Labs)
- What it does: sidebar panel showing running labs and node status, start/stop/destroy labs from the editor, SSH into nodes, topology file schema validation and auto-complete
- **Topology visualization**: The extension can render a graphical view of the topology directly inside VS Code — describe how to access this (right-click the `.clab.yml` file or use the command palette)
- Include a placeholder for a screenshot: `![VS Code Containerlab extension topology graph](images/vscode-clab-graph.png)`
- Mention it is free and open-source

#### 3c — The `containerlab graph` command (CLI topology visualization)

- Describe the `containerlab graph` command: launches a local web server that serves an interactive topology diagram
- Show the command: `containerlab graph` (run from the lab directory, or pass `--topo <file>`)
- Contrast with the 2021 experience (from the old post: "The graph function, however, does not appear to work" / limited usefulness for small networks)
- Note improvements: better layout, shows interface names, works reliably now
- Mention that the graph can also export to draw.io/diagrams.net format with `--drawio` flag
- Include a placeholder for a screenshot: `![containerlab graph web view](images/clab-graph-web.png)`

#### 3d — Other ecosystem tools and integrations

- **Containerlab community labs**: The [clabs.netdevops.me](https://clabs.netdevops.me/) catalog of community-contributed lab topologies
- **Edgeshark**: Integration with [Edgeshark](https://edgeshark.siemens.io/) for Wireshark packet capture from a web browser (replaces the manual `ip netns exec ... tcpdump | wireshark` workflow from 2021)
- **`clab_admins` group**: No more running every command with `sudo`
- **Improved documentation**: The containerlab.dev site has grown significantly with more examples, quickstarts, and vendor-specific guides

### Step 4 — Prerequisites section

Write the prerequisites section:

- Linux host (bare metal, VM, or WSL2)
- At least 4 cores/vCPUs and 8 GB RAM
- Docker installed and running
- Pull from `containerlab-bgp-security.md` lines 39–50

### Step 5 — Install Containerlab section

Write the installation section:

- Package-based install (apt) — pull from `containerlab-bgp-security.md` lines 52–82
- Mention the quick-install script as an alternative: `bash -c "$(curl -sL https://get.containerlab.dev)"`
- Mention installing the VS Code extension: search "Containerlab" in the Extensions marketplace
- Add user to `clab_admins` group (no more sudo!)
- Verify with `containerlab version`

### Step 6 — Deploy and test a sample lab

Write the hands-on test section:

- Deploy the `frr01` example lab — pull from `containerlab-bgp-security.md` lines 84–145
- Run a ping test to verify connectivity
- **NEW: Visualize the topology with `containerlab graph`** — show the command and describe the web UI that opens
- **NEW: Visualize in VS Code** — describe opening the topology graph from the VS Code extension
- Include screenshot placeholders for both visualization methods
- Tear down the lab with `containerlab destroy`

### Step 7 — Conclusion

Write a short conclusion (2–3 paragraphs) that:

- Summarizes how Containerlab has matured since 2021
- Highlights the key improvements: no sudo, VS Code extension, better graphs, community labs, Edgeshark
- Mentions that the next post will use Containerlab to build a BGP security lab (link to the upcoming post)
- Recommends Containerlab for anyone learning networking or testing configurations

### Step 8 — Additional Resources

Add a list of useful links:

- Containerlab documentation: <https://containerlab.dev>
- Containerlab GitHub: <https://github.com/srl-labs/containerlab>
- VS Code extension: <https://marketplace.visualstudio.com/items?itemName=srl-labs.containerlab>
- Community labs catalog: <https://clabs.netdevops.me/>
- Edgeshark: <https://edgeshark.siemens.io/>
- Your original 2021 Containerlab review (link to brianlinkletter.com post)

---

## Writing Checklist

- [ ] Adapt (and copy verbatim if needed) the overview, install, and test sections from `containerlab-bgp-security.md`
- [ ] Research and verify current VS Code extension features (check the marketplace page and extension docs)
- [ ] Research and verify current `containerlab graph` capabilities (check containerlab.dev docs)
- [ ] Research Edgeshark integration details
- [ ] Research community labs catalog (clabs.netdevops.me)
- [ ] Take or create screenshots for:
  - [ ] VS Code extension sidebar showing a running lab
  - [ ] VS Code extension topology graph view
  - [ ] `containerlab graph` web interface
  - [ ] `containerlab version` output
  - [ ] `containerlab deploy` output (frr01 lab)
- [ ] Proofread for consistency with blog style (first person, practical, hands-on)
- [ ] Verify all commands work on a fresh install
- [ ] Add `<!--more-->` tag after the introduction
- [ ] Ensure all links are correct and point to current URLs

---

## Notes

- The `containerlab-bgp-security.md` post should be updated afterward to *remove* or shorten its Containerlab overview/install/test sections and instead link to this new post.
- The URL for the Containerlab site changed from `containerlab.srlinux.dev` (2021) to `containerlab.dev` (current). Mention this as a sign of the project's growth and independence.
- The install method changed from a curl-pipe-to-bash script (2021) to proper apt/yum packages (current). Highlight this as a maturity improvement.
- In 2021, all commands required `sudo`. Now, with the `clab_admins` group, users can run containerlab without elevated privileges. This is a significant usability improvement worth emphasizing.
