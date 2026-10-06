---
name: method
description: The squad's shared working method — design principles, the brief file every phase writes once and passes by path, the one-line decision log, token rules, and output caps. Loaded once per phase by the orchestrator; agents follow it without reloading.
user-invocable: false
---

# Squad method

Load this once at the start of a phase. Agents get the relevant parts inside their brief; they do not reload it.

## Principles (how the squad works)

1. **Shape before polish.** Settle the one idea, the user outcome, and the smallest correct model of the change first. Polish (naming, style, docs) is the last pass.
2. **Ask the review questions before designing.** Who is this for? What changes for them? Does this need a new name, or can it stay invisible inside what exists?
3. **Never start from nothing.** Anchor every design to real paths in this repo. Name the file and function you will extend before proposing new ones.
4. **Go wide, then decide.** For any real fork, put 2 or 3 directions side by side, mark the winner, and say why in one line. The plan doubles as the decision log.
5. **Restraint is taste.** You can build anything, so cut whatever does not serve the outcome. Fewer files, fewer agents, fewer words.
6. **Every claim has a source.** A finding has `path:line`. A pass/fail has command output. A number has where it came from, or it goes.
7. **Run the checks; do not claim them.** Verification is executed, with output pasted, before anything is called done.

## Autonomy

Make routine creative and technical calls yourself. Log each one as a single line under **Decisions** in the phase output: `- <call made> — <why, 10 words>`. Stop and ask only for: missing rights (external services, secrets), unsafe or destructive actions, or an ambiguity that changes the goal.

## The brief (write once, pass by path)

Before fanning out, write ONE file, `squad-brief.md`, to your scratchpad directory (fall back to `/tmp/squad-brief.md`). Pass its absolute path to every agent plus a 3-line summary of what that agent must do. Never paste the diff or the design into N delegation prompts; each paste is paid again in your own context.

```markdown
# Brief — <phase> — <one-line task>
## Stack
<languages, frameworks, key dirs, exact verify commands, house rules from CLAUDE.md>
## Scope
<files/areas touched; for verify: `git diff --stat` and the diff itself, or a path to it>
## Design / ownership        (implement only)
<agreed approach; owned paths per writer>
## Acceptance criteria        (when they exist)
## Decisions
- ...
```

Agents: if a brief path is given, read it and skip stack detection and skill loading. Only re-detect when there is no brief.

## Token rules

- **Skip a lens before you shrink one.** The cheapest agent is the one not dispatched.
- **Stack signals come from the command's injected context** (manifests, `CLAUDE.md`), not from an opus dispatch. Dispatch `tech-lead` for design, never for detection alone.
- **Classification-only work runs on a cheaper model.** Pass the Agent tool's `model` override (`sonnet`, or `haiku` for mechanical tasks) when the task is sorting, listing, or running commands.
- **Continue, don't re-dispatch.** To send a follow-up to an agent that already has the context (a failing check back to its writer, a question to a reviewer), continue that same agent instead of starting a fresh one that re-reads the repo.
- **Mechanical work runs in the background.** Start `tester` with `run_in_background` and collect it at consolidation; review lenses run meanwhile.
- **Summaries back, never code dumps.** Each agent returns at most ~300 words or 10 ranked items unless the orchestrator asks for more.
- **Agents have `maxTurns`.** A partial return is a signal to narrow the ask, not to raise the cap.

## Output caps (what each agent returns)

| Agent | Returns |
|---|---|
| tech-lead | stack report (≤ 12 lines), recommended approach, ordered build list, ≤ 3 risks |
| product-owner | one-line scope, ≤ 6 stories, ≤ 10 acceptance criteria, cut list |
| frontend-dev / backend-dev | diff plan as a table (file, change, why), ≤ 3 risks; in writer mode the verify output |
| qa | test plan table, ≤ 12 cases; in writer mode the run output |
| tester | check table, PASS/FAIL per command, failing lines only |
| security-owasp | ≤ 8 findings, each with severity, `path:line`, attack path, fix; or "clean" |
