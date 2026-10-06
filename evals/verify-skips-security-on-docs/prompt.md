---
name: verify-skips-security-on-docs
tags: [verify, cost]
runs: 1
max_turns: 25
timeout_seconds: 600
allowed_tools: [Read, Grep, Glob, Bash, Skill, Agent]
---
/squad:verify
