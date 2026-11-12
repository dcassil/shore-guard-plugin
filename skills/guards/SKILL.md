---
name: guards
description: Install and configure the rule engines that enforce the adopted Shore Guard policy, with one explicit confirmation.
---
# Guided guards setup

## 0. Follow the safety rules

Never paste or accept a secret credential in chat. Never run a step the user has not approved. `shore-guard <command> --help` is safe to run. If `shore-guard` is not on PATH, use `node "${CLAUDE_PLUGIN_ROOT}/bin/shore-guard"` for every command below. If the CLI is missing entirely, ask the user to run `npx shore-guard setup` in a terminal, or `npm install -g shore-guard`.

Apply the `completion-contract` skill (`shore-guard:completion-contract`) exit-code table to every CLI result: 0 continue; 1 remediate findings; 2 repair configuration or the internal error; 3 log in or escalate; 4 remediate remote availability; 5 remediate quota; 6 follow decision and git-safety guidance; 7 commit or restore a clean tree. For any other exit, escalate. Stop on every nonzero exit after giving its remediation.

Manual:
`shore-guard <command> --help`

## 1. Read the plan

Run `shore-guard guards plan --json` and parse `data.plan`. If the exit is nonzero, apply the completion-contract table and stop with the remediation. When exit 6 says `Adopt an architecture policy first (run discovery, then shore-guard adopt).`, tell the user to run the discovery skill (`shore-guard:discovery`) first and stop.
If the full steps of that skill are not in your context, read ${CLAUDE_PLUGIN_ROOT}/skills/discovery/SKILL.md before doing anything else; do not proceed from this summary alone.

Manual:
`shore-guard guards plan --json`

## 2. Present the plan

Present every entry in `data.plan.capabilities` using this table:

| Capability | Recommended | Existing | Status |
| --- | --- | --- | --- |

Use `id`, `recommended`, `existing` when present, and `status` for the four columns.

### What changes if you switch

List every `data.plan.impacts` line verbatim.

### Will install

List every package in `data.plan.installs.dev` and name `data.plan.installs.packageManager`. Say none when the list is empty.

### Will write

List every `data.plan.writes` entry as `path — action`. Say none when the list is empty.

### Cannot be enforced

When `data.plan.unsupported` is non-empty, list every entry. Omit this heading when it is empty.

Manual:
Review the displayed plan without changing any files.

## 3. Ask for one choice

When `data.plan.choiceRequired` is true, restate every impact line before asking and say that (b) may leave some policy rules unenforced (reported after apply as `unenforced`). Then ask exactly one question with exactly these options:

(a) Use Shore's recommended tools (recommended): on-save single-file checks, boundary rules, and a baseline that grandfathers today's violations so you can clean up over time

(b) Keep my existing tools where present and add only what is missing — Shore will use them in its hooks and gates as far as they allow

(c) Stop — change nothing

Do not proceed without an explicit choice. For (c), say `Nothing was changed.` and stop.

Manual:
Choose (a), (b), or (c).

## 4. Apply

For (a), run `shore-guard guards apply --choice shore --json`. For (b), run `shore-guard guards apply --choice existing --json`.

Report every `data.steps` entry as a checklist: `[x]` for `done`, `[ ]` for `skipped`, and `[!]` for `failed`, including its `id` and `detail`. Report baseline counts found in step details. When `data.unenforced` is non-empty, list every policy rule id it contains.

On exit 6 for managed-file drift, show every file listed in the message and ask whether to rerun with `--force`. Add `--force` only after an explicit yes, preserving the selected `--choice` and `--json`. On exit 4 for an install failure, relay the manual command from the message and stop. For every other nonzero exit, apply the completion-contract table and stop with the remediation.

Manual:
`shore-guard guards apply --choice shore --json` or `shore-guard guards apply --choice existing --json`

## 5. Finish

Tell the user that saving a file now runs the single-file check through the edit hook, `shore-guard check` runs the full gate, and the baseline only shrinks: fix grandfathered violations when touching those files.

Then follow the report skill (`shore-guard:report`) with stage guards.

Manual:
`shore-guard check`
