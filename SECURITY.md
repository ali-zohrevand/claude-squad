# Security Policy

`squad` is a Claude Code plugin made of markdown agents, commands, and skills — it ships no compiled code or network services. Still, if you find a security issue (e.g. an agent/command that could be steered into an unsafe action, or a supply-chain concern in how the plugin is distributed), we want to know.

## Reporting

- **Preferred:** open a [private security advisory](https://github.com/ali-zohrevand/claude-squad/security/advisories/new) on GitHub.
- **Or** email **ksramn97@gmail.com** with details and reproduction steps.

Please do **not** open a public issue for a security report. We'll acknowledge within a few days and work with you on a fix and disclosure timeline.

## Scope

In scope: the plugin's agents/commands/skills and its distribution. Out of scope: vulnerabilities in Claude Code itself (report those to Anthropic) or in third-party tools the plugin invokes.
