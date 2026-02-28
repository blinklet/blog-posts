% Contributing Code to an Open-Source Project

Open-source projects thrive on community contributions. Even small improvements, like updating documentation, help keep projects healthy and useful. In this post, I will walk through the process of contributing a fix to the [Containerlab](https://containerlab.dev/) project by updating its *frr01* lab example to use the latest container images. Along the way, I will cover the standard GitHub pull request workflow that applies to most open-source projects.

<!--more-->

A while ago, I contributed a lab example to Containerlab that [uses open-source routers in its lab topology](https://www.brianlinkletter.com/2021/05/use-containerlab-to-emulate-open-source-routers/). I recently noticed that the images I used in the [frr01 lab example](https://containerlab.dev/lab-examples/frr01/) are deprecated and will soon be deleted from their image repositories. I need to update the lab example configuration file so it points to the latest images in the new image repositories.

## Proposed changes

The *frr01* lab is a 3-node ring of FRR routers running OSPF, with a PC connected to each router. It is one of the simplest lab examples in the project and serves as a good introduction to using FRR with Containerlab.

The lab's topology file, *frr01.clab.yml*, currently specifies:

- `frrouting/frr:v7.5.1` for the three FRR routers
- `praqma/network-multitool:latest` for the three PCs

The FRR v7.5.1 image was pushed to Docker Hub almost five years ago. Since then, the FRR project has moved its Docker images to [Quay.io](https://quay.io/repository/frrouting/frr) and the latest stable release is FRR 10.5.1. The *praqma/network-multitool* image was also archived and replaced by *wbitt/network-multitool*.

Updating these images is a straightforward change that makes a good demonstration of how to contribute to the project.

## Prerequisites

Before you start contributing, you need to have a development environment set up so you can test your contribution. In this case, a Containerlab development environment consists of the following:

- A [GitHub account](https://github.com/signup)
- [Git](https://git-scm.com/) installed on your computer
- [Docker](https://docs.docker.com/engine/install/) installed (to test the lab locally)
- [Containerlab](https://containerlab.dev/install/) installed (to deploy and test the lab)
- Basic familiarity with Git commands and the Linux command line

## Check the Contribution Guidelines

Before making changes to any open-source project, check for contribution guidelines. Look for files named *CONTRIBUTING.md*, *DEVELOPMENT.md*, or a "Contributing" section in the project's documentation.

The Containerlab project provides a [Developers Guide](https://containerlab.dev/manual/dev/) on its documentation site. The guide covers:

- [Documentation](https://containerlab.dev/manual/dev/doc/) contributions
- [Testing](https://containerlab.dev/manual/dev/test/)
- [Debugging](https://containerlab.dev/manual/dev/debug/)

You can also reach the Containerlab community on the [Containerlab Discord server](https://discord.gg/vAyddtaEV9) if you have questions before contributing.

## Fork the Repository

A *fork* is your personal copy of the project's repository on GitHub. You make your changes in your fork and then propose them to the original project through a pull request. A fork is a GitHub concept and is executed in your user account on the GitHub web site.

1. Navigate to the [Containerlab repository](https://github.com/srl-labs/containerlab) on GitHub
2. Click the **Fork** button in the upper-right corner of the page
3. Select your GitHub account as the destination for the fork
4. Wait for GitHub to create the fork

You now have a copy of the repository at *https://github.com/YOUR-USERNAME/containerlab*.

## Clone Your Fork Locally

Use Git to clone your forked repository to your local machine so you can make changes:

```
$ git clone https://github.com/YOUR-USERNAME/containerlab.git
$ cd containerlab
```

Add the original repository as a remote called *upstream*. This lets you pull in changes from the original project later:

```bash
$ git remote add upstream https://github.com/srl-labs/containerlab.git
```

Verify your remotes are set up correctly:

```bash
$ git remote -v
origin    https://github.com/YOUR-USERNAME/containerlab.git (fetch)
origin    https://github.com/YOUR-USERNAME/containerlab.git (push)
upstream  https://github.com/srl-labs/containerlab.git (fetch)
upstream  https://github.com/srl-labs/containerlab.git (push)
```

Or, use VScode. In the Source Control panel, click on "Clone repository". Paste in the URL of your fork (or select it from the drop-down menu) and press Return.

Then, select the folder into which you want to clone the Containerlab code. I places in in my "Projects" folder.


## Step 4: Create a Branch

Always create a new branch for your changes. Never commit directly to the `main` branch of your fork. Using a descriptive branch name makes it easy for project maintainers to understand what your changes are about:

```bash
$ git checkout -b update-frr01-images
```

## Step 5: Identify the Changes Needed

Navigate to the *frr01* lab example and review the current topology file:

```bash
$ cat lab-examples/frr01/frr01.clab.yml
```

The current file looks like this:

```yaml
name: frr01

topology:
  nodes:
    router1:
      kind: linux
      image: frrouting/frr:v7.5.1
      binds:
        - router1/daemons:/etc/frr/daemons
        - router1/frr.conf:/etc/frr/frr.conf
    router2:
      kind: linux
      image: frrouting/frr:v7.5.1
      binds:
        - router2/daemons:/etc/frr/daemons
        - router2/frr.conf:/etc/frr/frr.conf
    router3:
      kind: linux
      image: frrouting/frr:v7.5.1
      binds:
        - router3/daemons:/etc/frr/daemons
        - router3/frr.conf:/etc/frr/frr.conf
    PC1:
      kind: linux
      image: praqma/network-multitool:latest
    PC2:
      kind: linux
      image: praqma/network-multitool:latest
    PC3:
      kind: linux
      image: praqma/network-multitool:latest

  links:
    - endpoints: ["router1:eth1", "router2:eth1"]
    - endpoints: ["router1:eth2", "router3:eth1"]
    - endpoints: ["router2:eth2", "router3:eth2"]
    - endpoints: ["PC1:eth1", "router1:eth3"]
    - endpoints: ["PC2:eth1", "router2:eth3"]
    - endpoints: ["PC3:eth1", "router3:eth3"]
```

I need to make two changes:

1. **Update the FRR image** from `frrouting/frr:v7.5.1` (Docker Hub) to `quay.io/frrouting/frr:10.5.1` (Quay.io)
2. **Update the network-multitool image** from `praqma/network-multitool:latest` to `wbitt/network-multitool:latest`

### Why the image registry changed

The FRR project stopped publishing Docker images to Docker Hub after version 8.4.0. All newer releases are published to [Quay.io](https://quay.io/repository/frrouting/frr). When updating the image reference, you need to include the full registry path: `quay.io/frrouting/frr`.

Similarly, the *network-multitool* image was originally maintained by Praqma, which was acquired by Eficode. The image is now maintained under the `wbitt` organization on Docker Hub.

## Step 6: Make the Changes

Open the topology file in your text editor and update the image references. You can also use `sed` to make the replacements:

```bash
$ sed -i 's|frrouting/frr:v7.5.1|quay.io/frrouting/frr:10.5.1|g' \
    lab-examples/frr01/frr01.clab.yml
$ sed -i 's|praqma/network-multitool:latest|wbitt/network-multitool:latest|g' \
    lab-examples/frr01/frr01.clab.yml
```

Verify the changes look correct:

```bash
$ cat lab-examples/frr01/frr01.clab.yml
```

The updated file should now reference `quay.io/frrouting/frr:10.5.1` for the routers and `wbitt/network-multitool:latest` for the PCs.

### Update the documentation page

The *frr01* lab example also has a documentation page at *docs/lab-examples/frr01.md*. This page includes a version information table that references the old image tag. Update it to reflect the new image:

```bash
$ grep -n "v7.5.1\|frrouting/frr" docs/lab-examples/frr01.md
```

Edit the file to update the version information to match the new image version.

## Step 7: Test Your Changes Locally

Before submitting your contribution, verify that the updated lab still works correctly. This is an important step that gives the project maintainers confidence in your changes.

```
blinklet@T480:~$ cd Projects/containerlab/lab-examples/frr01/
blinklet@T480:~/Projects/containerlab/lab-examples/frr01$ containerlab deploy
11:55:19 INFO Containerlab started version=0.73.0
11:55:19 INFO Parsing & checking topology file=frr01.clab.yml
11:55:19 INFO Creating docker network name=clab IPv4 subnet=172.20.20.0/24 IPv6 subnet=3fff:172:20:20::/64 MTU=0
11:55:19 INFO Creating lab directory path=/home/blinklet/Projects/containerlab/lab-examples/frr01/clab-frr01
11:55:19 INFO Creating container name=router2
11:55:19 INFO Creating container name=PC3
11:55:19 INFO Creating container name=PC2
11:55:19 INFO Creating container name=router3
11:55:19 INFO Creating container name=PC1
11:55:19 INFO Creating container name=router1
11:55:20 INFO Created link: PC3:eth1 ▪┄┄▪ router3:eth3
11:55:20 INFO Created link: router1:eth2 ▪┄┄▪ router3:eth1
11:55:20 INFO Created link: PC1:eth1 ▪┄┄▪ router1:eth3
11:55:20 INFO Created link: router1:eth1 ▪┄┄▪ router2:eth1
11:55:20 INFO Created link: router2:eth2 ▪┄┄▪ router3:eth2
11:55:20 INFO Created link: PC2:eth1 ▪┄┄▪ router2:eth3
11:55:20 INFO Adding host entries path=/etc/hosts
11:55:20 INFO Adding SSH config for nodes path=/etc/ssh/ssh_config.d/clab-frr01.conf
╭────────────────────┬────────────────────────────────┬─────────┬───────────────────╮
│        Name        │           Kind/Image           │  State  │   IPv4/6 Address  │
├────────────────────┼────────────────────────────────┼─────────┼───────────────────┤
│ clab-frr01-PC1     │ linux                          │ running │ 172.20.20.5       │
│                    │ wbitt/network-multitool:latest │         │ 3fff:172:20:20::5 │
├────────────────────┼────────────────────────────────┼─────────┼───────────────────┤
│ clab-frr01-PC2     │ linux                          │ running │ 172.20.20.2       │
│                    │ wbitt/network-multitool:latest │         │ 3fff:172:20:20::2 │
├────────────────────┼────────────────────────────────┼─────────┼───────────────────┤
│ clab-frr01-PC3     │ linux                          │ running │ 172.20.20.3       │
│                    │ wbitt/network-multitool:latest │         │ 3fff:172:20:20::3 │
├────────────────────┼────────────────────────────────┼─────────┼───────────────────┤
│ clab-frr01-router1 │ linux                          │ running │ 172.20.20.6       │
│                    │ quay.io/frrouting/frr:master   │         │ 3fff:172:20:20::6 │
├────────────────────┼────────────────────────────────┼─────────┼───────────────────┤
│ clab-frr01-router2 │ linux                          │ running │ 172.20.20.7       │
│                    │ quay.io/frrouting/frr:master   │         │ 3fff:172:20:20::7 │
├────────────────────┼────────────────────────────────┼─────────┼───────────────────┤
│ clab-frr01-router3 │ linux                          │ running │ 172.20.20.4       │
│                    │ quay.io/frrouting/frr:master   │         │ 3fff:172:20:20::4 │
╰────────────────────┴────────────────────────────────┴─────────┴───────────────────╯
```

You should see output indicating that all six containers started successfully. 

Test that the OSPF routing is working by connecting to one of the routers and checking the OSPF neighbor table:

```bash
$ sudo docker exec clab-frr01-router1 vtysh -c "show ip ospf neighbor"

Neighbor ID     Pri State           Up Time         Dead Time Address         Interface                        RXmtL RqstL DBsmL
10.10.10.2        1 Full/DR         5m56s             33.524s 192.168.1.2     eth1:192.168.1.1                     0     0     0
10.10.10.3        1 Full/DR         5m51s             33.389s 192.168.2.2     eth2:192.168.2.1                     0     0     0
```

You should see router2 and router3 listed as OSPF neighbors in the `Full` state. Also verify that the PCs can reach each other through the routed network:

```bash
$ sudo docker exec clab-frr01-PC1 ping -c 3 172.20.20.2
PING 172.20.20.2 (172.20.20.2) 56(84) bytes of data.
64 bytes from 172.20.20.2: icmp_seq=1 ttl=64 time=0.164 ms
64 bytes from 172.20.20.2: icmp_seq=2 ttl=64 time=0.041 ms
64 bytes from 172.20.20.2: icmp_seq=3 ttl=64 time=0.059 ms

--- 172.20.20.2 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2080ms
rtt min/avg/max/mdev = 0.041/0.088/0.164/0.054 ms
```

When you are done testing, destroy the lab:

```bash
$ cd lab-examples/frr01
$ sudo containerlab destroy --topo frr01.clab.yml
```

> **Note:** If any tests fail, you need to investigate whether the issue is with the newer image version or with a configuration incompatibility. Check the FRR [release notes](https://github.com/FRRouting/frr/releases) for breaking changes between versions. The jump from FRR 7.5.1 to 10.5.1 spans several major versions, so you may need to verify that the configuration files in the *router1/*, *router2/*, and *router3/* directories are still compatible. In particular, check the *daemons* file and *frr.conf* for any deprecated syntax.

## Step 8: Commit Your Changes

Stage and commit your changes with a clear, descriptive commit message. Good commit messages help project maintainers understand what you changed and why:

```bash
$ git add lab-examples/frr01/frr01.clab.yml
$ git commit -m "lab-examples/frr01: update FRR and multitool images

Update the frr01 lab example to use current container images:
- FRR: frrouting/frr:v7.5.1 -> quay.io/frrouting/frr:10.5.1
- network-multitool: praqma/network-multitool -> wbitt/network-multitool

The FRR project moved its Docker images to Quay.io after v8.4.0.
The praqma/network-multitool image was archived and replaced by
wbitt/network-multitool.

Tested locally: lab deploys successfully and OSPF adjacencies form
between all three routers."
```

### Writing good commit messages

A good commit message has:

- A **short summary line** (50 characters or less) that describes what changed
- A **blank line** separating the summary from the body
- A **body** that explains *why* the change was made and any relevant context
- Mention of any **testing** you performed

## Step 9: Push to Your Fork

Push your branch to your fork on GitHub:

```bash
$ git push origin update-frr01-images
```

Git will display a URL you can use to create a pull request, or you can navigate to your fork on GitHub to create one.

## Step 10: Create a Pull Request

1. Go to your fork on GitHub: `https://github.com/YOUR-USERNAME/containerlab`
2. You should see a banner suggesting you create a pull request for your recently pushed branch. Click **Compare & pull request**
3. Alternatively, click the **Pull requests** tab and then **New pull request**

Fill in the pull request form:

- **Title**: Use a clear, concise title like "lab-examples/frr01: update FRR and multitool container images"
- **Description**: Explain what you changed, why you changed it, and how you tested it. Include:
  - The problem (outdated images from 2021)
  - The solution (updated to latest FRR from Quay.io, updated multitool image)
  - Testing results (lab deploys, OSPF works, PCs can communicate)

Here is an example pull request description:

```markdown
## Summary

Update the frr01 lab example to use current container images.

## Changes

- Updated FRR router image from `frrouting/frr:v7.5.1` (Docker Hub)
  to `quay.io/frrouting/frr:10.5.1` (Quay.io)
- Updated PC image from `praqma/network-multitool:latest`
  to `wbitt/network-multitool:latest`
- Updated version information in the documentation page

## Motivation

The current images are nearly 5 years old. The FRR project moved its
Docker images to Quay.io after version 8.4.0, and the
praqma/network-multitool image has been archived in favor of
wbitt/network-multitool.

## Testing

- Deployed the lab with `containerlab deploy`
- Verified all 6 containers start successfully
- Confirmed OSPF adjacencies form between all three routers
- Tested end-to-end connectivity between PCs
```

Click **Create pull request** to submit it.

## Step 11: Respond to Review Feedback

After you submit your pull request, the project maintainers will review your changes. They may:

- **Approve** the changes and merge them
- **Request changes**, asking you to modify something
- **Comment** with questions or suggestions

If changes are requested, make them in your local branch, commit, and push again. The pull request will automatically update:

```bash
$ # Make the requested changes to the files
$ git add <changed-files>
$ git commit -m "address review feedback: <description>"
$ git push origin update-frr01-images
```

Be patient and respectful in your interactions with maintainers. They are often volunteers who review contributions in their spare time.

## Keeping Your Fork Up to Date

While you wait for your pull request to be reviewed, or for future contributions, keep your fork synchronized with the upstream repository:

```bash
$ git checkout main
$ git fetch upstream
$ git merge upstream/main
$ git push origin main
```

If the upstream `main` branch has changed since you created your branch and the maintainers ask you to rebase, you can do so:

```bash
$ git checkout update-frr01-images
$ git rebase main
$ git push --force-with-lease origin update-frr01-images
```

> **Note:** Use `--force-with-lease` instead of `--force` when force-pushing. It is a safer option that will refuse to push if someone else has pushed changes to the remote branch since you last fetched.

## Tips for Contributing to Open-Source Projects

Based on my experience, here are some tips for making successful contributions:

1. **Start small.** Updating documentation, fixing typos, or refreshing outdated versions are great first contributions. They help you learn the project's workflow without the complexity of code changes.

2. **Read the contribution guidelines.** Every project has its own expectations for commit messages, code style, and pull request format. Following these guidelines shows respect for the maintainers' time.

3. **Test your changes.** Nothing builds confidence like demonstrating that your changes work. Include details about your testing when you submit a pull request.

4. **Communicate clearly.** Write descriptive commit messages and pull request descriptions. Explain *what* you changed and *why*.

5. **Be patient.** Maintainers are often volunteers. It may take days or weeks for your pull request to be reviewed.

6. **Check for existing issues.** Before starting work, check the project's issue tracker to see if someone else is already working on the same thing, or if the maintainers have specific preferences about how it should be done.

7. **Open an issue first for large changes.** If you are planning a significant change, open an issue to discuss it with the maintainers before investing time in the implementation.

## Conclusion

Contributing to open-source projects does not have to be intimidating. The standard GitHub workflow of fork, branch, change, test, and pull request is straightforward once you have done it a few times. Updating the *frr01* lab example in the Containerlab project is a good example of a small, practical contribution that improves the project for everyone.

The Containerlab community is welcoming and the project's [Developers Guide](https://containerlab.dev/manual/dev/) makes it clear that all contributions are valued. If you use Containerlab or any other open-source tool in your work, consider giving back by contributing fixes and improvements when you find opportunities.

## Additional Resources

- [GitHub: Creating a pull request from a fork](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request-from-a-fork)
- [Containerlab Developers Guide](https://containerlab.dev/manual/dev/)
- [FRR Release Notes](https://github.com/FRRouting/frr/releases)
- [Containerlab frr01 Lab Example](https://containerlab.dev/lab-examples/frr01/)
- [First Contributions](https://github.com/firstcontributions/first-contributions) — a beginner-friendly guide to making your first open-source contribution
