# Copilot Instructions for Brian Linkletter's Technical Blog

This workspace contains work-in-progress posts for the blog [brianlinkletter.com](https://brianlinkletter.com), which focuses on open-source network simulation, network emulation, and Python programming for network engineers.

## Blog Focus and Scope

### Primary Topics
- **Network simulation and emulation tools**: Reviews, tutorials, and comparisons of open-source network simulators and emulators (GNS3, Containerlab, CORE, Mininet, EVE-NG, Kathara, Filius, etc.)
- **Python for network engineers**: Practical tutorials on Python programming aimed at network engineers learning automation
- **Network automation**: Tools and techniques for automating network management tasks
- **Open-source networking**: Open-source routers (FRR), SDN tools, and related technologies

### Secondary Topics
- Cloud infrastructure management (Azure) with Python
- DevOps tools relevant to network engineers
- Educational resources for teaching networking concepts

### Out of Scope
- General web development (unless directly supporting network tools)
- Non-networking programming topics (unless they serve as teaching examples)
- Commercial/proprietary tools (unless comparing to open-source alternatives)

## Writing Style Guidelines

### Voice and Tone
- Write in **first person** ("I will show you...", "I found that...")
- Use a **practical, hands-on approach** — show readers how to do things, not just describe them
- Be **helpful and encouraging** to beginners while still providing value to experienced users
- Acknowledge when topics are complex and guide readers through step-by-step
- Include **personal experience** and lessons learned ("I learned a lot about...", "I found this did not work...")

### Structure and Format
- Start posts with a brief introduction explaining what the reader will learn
- Use the `<!--more-->` tag after the introduction for WordPress excerpt handling
- Break content into **clear sections with descriptive headings** (H2, H3)
- Include **code examples** with proper syntax highlighting using fenced code blocks
- Provide **step-by-step instructions** with numbered or bulleted lists where appropriate
- Include **screenshots and diagrams** to illustrate concepts (store in `./Images/` subdirectory)
- End with a conclusion or recommendation when appropriate

### Code Examples
- Use **bash code blocks** for terminal commands, prefixed with `$` for user commands
- Use **appropriate language identifiers** for code blocks (python, bash, yaml, etc.)
- Show **complete, working examples** that readers can copy and run
- Include **output examples** when helpful for understanding
- Explain what each code section does, especially for beginners

### Technical Writing Best Practices
- Define acronyms and technical terms on first use
- Link to **official documentation** and authoritative sources
- Use **footnotes** for additional context that might interrupt the flow
- Cite sources using double parentheses format: `((Source description))`
- Prefer **practical examples** over abstract explanations
- Include **prerequisites** section when tools or knowledge are required

### Formatting Conventions
- Use *italics* for file names, package names, and application names (e.g., *azruntime*, *platformer.pyxres*)
- Use `code formatting` for commands, function names, and technical identifiers
- Use **bold** for emphasis on key concepts
- Use blockquotes (>) for important notes or warnings

## Content Categories

When writing posts, consider which category applies:
- **Network Simulation**: Reviews and tutorials for network emulators/simulators
- **Network Automation**: Python scripts, automation tools, and techniques
- **Open Source Networking**: Open-source routers, SDN, and related projects
- **Miscellaneous**: Related topics that don't fit other categories

## Target Audience

- **Network engineers** learning Python and automation
- **Students and educators** exploring network simulation tools
- **IT professionals** evaluating open-source networking solutions
- **DevOps engineers** interested in network infrastructure automation

Write content that is accessible to beginners but includes enough depth to be valuable to intermediate users. Assume readers have basic networking knowledge but may be new to programming or specific tools.

## Post Template Structure

```markdown
% Post Title

Brief introduction explaining what the post covers and what readers will learn.

<!--more-->

## Prerequisites (if applicable)

List any required software, knowledge, or setup steps.

## Main Content Sections

### Step-by-step instructions with clear headings

Include code examples:

```bash
$ command-to-run
```

Include explanations of what the code does.

## Conclusion

Summary of what was covered and recommendations.

## Additional Resources (if applicable)

Links to documentation, related posts, or further reading.
```

## File Organization

- Each post should have its own directory
- Images go in an `images/` subdirectory within the post directory
- Use descriptive, URL-friendly directory and file names (lowercase, hyphens)
- Published posts go in the `Published/` directory
- Work-in-progress posts stay in topic-specific directories
- Notes and research go in the `Notes/` directory

## Quality Checklist

Before publishing, ensure posts:
- [ ] Have been tested (all commands and code examples work)
- [ ] Include proper attribution and links to sources
- [ ] Have clear, descriptive headings
- [ ] Include relevant images with alt text
- [ ] Are accessible to the target audience
- [ ] Follow the established writing style
- [ ] Include a clear introduction and conclusion
