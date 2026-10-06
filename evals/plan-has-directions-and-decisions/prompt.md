---
name: plan-has-directions-and-decisions
tags: [plan]
runs: 1
max_turns: 30
timeout_seconds: 900
allowed_tools: [Read, Grep, Glob, Bash, Skill, Agent, Write]
---
/squad:plan add a `subtract(a, b)` helper next to `add` with the same typing and a test
