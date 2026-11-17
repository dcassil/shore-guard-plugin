---
name: guards
description: Install and configure rule engines for a selected blueprint or discovery proposal, with one explicit confirmation.
---
# Guided guards setup

## 0. Follow the safety rules

Never paste or accept a secret credential in chat. Never run a step the user has not approved. `shore-guard <command> --help` is safe. If `shore-guard` is not on PATH, use `node "${CLAUDE_PLUGIN_ROOT}/bin/shore-guard"`. If the CLI is missing, ask the user to run `npx shore-guard setup` or `npm install -g shore-guard` in a terminal.

Apply the `completion-contract` skill (`shore-guard:completion-contract`) exit table to every result. Except for section 4 troubleshooting, stop on every nonzero exit after remediation.

## 1. Read the plan

Carry forward exactly one discovery option. Run `shore-guard guards plan --blueprint <id> --json` or `shore-guard guards plan --source <proposalPath> --json` and parse `data.plan`. If exit 6 asks for a blueprint or source, follow the discovery skill (`shore-guard:discovery`) first and stop. If its full steps are absent, read ${CLAUDE_PLUGIN_ROOT}/skills/discovery/SKILL.md before doing anything else. For every other nonzero exit, apply the completion-contract table and stop.

## 2. Present the plan

Present every `data.plan.capabilities` entry in a table with Capability, Recommended, Existing, and Status columns, using `id`, `recommended`, `existing`, and `status`. List every `data.plan.impacts` line verbatim. List packages in `data.plan.installs.dev` and its package manager, or none. List every `data.plan.writes` entry as `path — action`, or none. List non-empty `data.plan.unsupported` under **Cannot be enforced**.

## 3. Ask for one choice

When `data.plan.choiceRequired` is true, restate every impact and say (b) may leave some rules unenforced (reported as `unenforced`). Ask exactly one question with exactly these options:

(a) Use Shore's recommended tools (recommended): on-save single-file checks, boundary rules, and a baseline that grandfathers today's violations so you can clean up over time

(b) Keep my existing tools where present and add only what is missing — Shore will use them in its hooks and gates as far as they allow

(c) Stop — change nothing

Do not proceed without an explicit choice. For (c), say `Nothing was changed.` and stop.

## 4. Apply

For (a), run `shore-guard guards apply --blueprint <id> --choice shore --json` or `shore-guard guards apply --source <proposalPath> --choice shore --json`. For (b), use the same source option with `--choice existing`.

Report every `data.steps` entry as `[x]` for `done`, `[ ]` for `skipped`, or `[!]` for `failed`, including `id` and `detail`. Report baseline counts. List every non-empty `data.unenforced` rule id.

On exit 6 for managed-file drift, show every file and ask whether to rerun with `--force`. Add it only after explicit yes, preserving source, choice, and JSON output.

On exit 6 saying guards are already set up from another blueprint or proposal, stop and relay the message. Shore Guard does not replace an existing setup; the repository's rules are changed directly.

For another failure, use the failed step, its detail, and `data.resume.nextStep` to diagnose and fix causes within the approved setup. Tell the user before running a supplied manual install command. Follow completion-contract remediation for exits 3, 4, and 5. Never loosen a rule, delete a baseline, or edit generated rules to make apply pass.

After fixing the cause, rerun the same `shore-guard guards apply --blueprint <id> --choice <same choice> --json` or `shore-guard guards apply --source <proposalPath> --choice <same choice> --json` command. Completed steps remain. The option may be omitted on a resume. Do not delete generated files and do not pass `--force` to get past a failure. Repeat until exit 0.

If the same step fails twice with the same detail, or a fix lacks user approval, stop and report the blocker, attempts, and incomplete setup. Then follow the report skill (`shore-guard:report`) with stage guards and outcome `partial`.

## 5. Set up on-save checking for this stack

Boundary rules run in the pre-commit hook and `shore-guard verify`. `shore-guard check` is the Shore health check. On save, Shore runs `.shore/guard.json`'s `lint.singleFileCommand`.

Identify the languages, framework, and module system. Choose the standard per-file tool and configure resolved imports so path aliases, base-relative and absolute specifiers, relative paths, and extensionless imports resolve to the same file the boundary engine sees. Generated ESLint import patterns match import text only; do not call them boundary enforcement.

Present what will be installed, changed, and covered on save. Get an explicit yes before installing or writing anything. Extend existing configuration; never replace or weaken it.

Prove the setup with a planted violation. Use a temporary forbidden import written once as a relative import and once through an alias when aliases exist. Confirm the on-save command reports it, then delete the file. If either style is missed, name the rules enforced only at commit time. If no suitable tool exists, state that boundaries are commit-time only.

## 6. Finish

Rerun `shore-guard guards apply --json` with no option and confirm it reports already applied before saying setup is complete. `shore-guard check` and `shore-guard verify` refuse to run with uncommitted changes and need the commit on a branch Shore has scanned, so run `shore-guard check` only after the generated files are committed and pushed; exit 7 before that is expected and is not a failed setup.

Explain that saves run the single-file check, boundary rules run in the pre-commit hook and `shore-guard verify`, `shore-guard check` checks Shore health, and the baseline only shrinks. Tell the user to review the pull request or recap current-branch changes. State plainly: From here, the rules belong to this repository. Your agent may add, change, or remove them as the architecture evolves, and Shore Guard will not change them again.

Then follow the report skill (`shore-guard:report`) with stage guards.
