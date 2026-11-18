---
name: guards
description: Install and configure rule engines for a selected blueprint or discovery proposal, with one explicit confirmation.
---
# Guided guards setup

## 0. Follow the safety rules

Never paste or accept a secret credential in chat. Never run a step the user has not approved. `shore-guard <command> --help` is safe. If `shore-guard` is not on PATH, use `node "${CLAUDE_PLUGIN_ROOT}/bin/shore-guard"`. If the CLI is missing, ask the user to run `npx shore-guard setup` or `npm install -g shore-guard` in a terminal.

Before installing anything, read `.shore/guard.json` `setupDecisions`. Never install, add, or wire an item recorded as `declined`; only a later user request to change that decision permits it, and the recorded decision must be updated in the same change.

Apply the `completion-contract` skill (`shore-guard:completion-contract`) exit table to every result. Except for section 4 troubleshooting, stop on every nonzero exit after remediation.

## 1. Read the plan

Carry forward exactly one discovery option. Run `shore-guard guards plan --blueprint <id> --json` or `shore-guard guards plan --source <proposalPath> --json` and parse `data.plan`. If exit 6 asks for a blueprint or source, follow the discovery skill (`shore-guard:discovery`) first and stop. If its full steps are absent, read ${CLAUDE_PLUGIN_ROOT}/skills/discovery/SKILL.md before doing anything else. For every other nonzero exit, apply the completion-contract table and stop.

## 2. Present the plan

Present every `data.plan.capabilities` entry in a table with Capability, Recommended, Existing, and Status columns, using `id`, `recommended`, `existing`, and `status`. List every `data.plan.impacts` line verbatim. List non-empty `data.plan.unsupported` under **Cannot be enforced**.

Present one approval list containing every `data.plan.items` entry whose `status` is `needed`, grouped under these exact headings:

### Required

### Required for commit-time checks

### Suggested, optional

Put each item under the heading matching its `requirement`. Show its title, `installs` (or none), `writes` (or none), and `detail`. Show a recorded `declined` decision as **previously declined — not offered again** and do not ask about it. Show all `present` items together on one line as already in place; they need no approval. Make clear that Shore Guard itself is pinned as an exact devDependency so hooks and CI use the same version on every machine and an update cannot silently change this repository's setup.

After the approval list, list every generated rule file and baseline in `data.plan.writes` as `path — action`, or none, explaining that setup always writes these files.

## 3. Ask for the choices

When `data.plan.choiceRequired` is true, restate every impact and say (b) may leave some rules unenforced (reported as `unenforced`). Ask the tools question first with exactly these options:

(a) Use Shore's recommended tools (recommended): on-save single-file checks, boundary rules, and a baseline that grandfathers today's violations so you can clean up over time

(b) Keep my existing tools where present and add only what is missing — Shore will use them in its hooks and gates as far as they allow

(c) Stop — change nothing

Do not proceed without an explicit tools choice. For (c), say `Nothing was changed.` and stop.

Then ask exactly one approval question with exactly these options:

(a) Yes to all

(b) No — Shore Guard will not work without the required items

(c) Choose each one at a time

For (b), say `Nothing was changed.` and stop. For (c), ask about each undecided `needed` item separately, stating its requirement class before the question. After the last answer, restate every declined item and its consequence. If a required item was declined, or both `commit-hook` and `ci` were declined, say that nothing would run the rules, treat the answer as (b), say `Nothing was changed.`, and stop.

Do not ask again about `present` items or recorded decisions. Do not proceed until every other `needed` item has a decision.

## 4. Apply

For approval option (a), run `shore-guard guards apply --blueprint <id> --choice shore --accept all --json` or `shore-guard guards apply --source <proposalPath> --choice shore --accept all --json`. Use `--choice existing` instead when the tools answer was (b). For approval option (c), pass `--accept <id,id> --decline <id,id>`, listing every undecided `needed` item exactly once; omit items that already have a recorded decision.

Report every `data.steps` entry as `[x]` for `done`, `[ ]` for `skipped`, or `[!]` for `failed`, including `id` and `detail`. Report baseline counts. List every non-empty `data.unenforced` rule id. Report every `data.notSetUp` entry in plain words under this exact heading:

**Not set up**

On exit 6 naming undecided items, ask about exactly those items and rerun with their decisions. On exit 6 for managed-file drift, show every file and ask whether to rerun with `--force`. Add it only after explicit yes, preserving source, tools choice, decisions, and JSON output.

On exit 6 saying guards are already set up from another blueprint or proposal, stop and relay the message. Shore Guard does not replace an existing setup; the repository's rules are changed directly.

If the `hook` step fails because git would not run the Shore Guard hook, follow the remediation in its detail and rerun apply. Never report commit-time checks as set up while this step is failing. If the `ci` step fails because no workflow references `guard:rules`, add the required step to the existing workflow as described in the next section, show the user the diff, and rerun apply.

For another failure, use the failed step, its detail, and `data.resume.nextStep` to diagnose and fix causes within the approved setup. Tell the user before running a supplied manual install command. Follow completion-contract remediation for exits 3, 4, and 5. Never loosen a rule, delete a baseline, or edit generated rules to make apply pass.

After fixing the cause, rerun the same apply command with the same source, tools choice, and decisions. Completed steps remain. The source option and decisions may be omitted on a resume when already recorded. Do not delete generated files and do not pass `--force` to get past a failure. Repeat until exit 0.

If the same step fails twice with the same detail, or a fix lacks user approval, stop and report the blocker, attempts, and incomplete setup. Then follow the report skill (`shore-guard:report`) with stage guards and outcome `partial`.

### CI enforcement

If no CI was found and `ci` was accepted, apply creates `.github/workflows/shore-guard.yml`; show the user that file. If CI exists, add one step to the most suitable existing pull-request workflow. Ensure checkout has full history, then run the package manager's `guard:rules` script with `--baseline-ref` set to the pull request's base commit. For GitHub, the argument is `${{ github.event.pull_request.base.sha }}`. The package script runs `shore-guard guards enforce --all`.

Hooks can be skipped by a developer; CI is the check that cannot be skipped locally. If `ci` was declined, do not create or edit a workflow and report CI under **Not set up**.

## 5. Set up on-save checking for this stack

Boundary rules run in the pre-commit hook through `npx --no-install shore-guard guards enforce --staged` and in CI through `shore-guard guards enforce --all`; `shore-guard verify` includes the same all-files check. `shore-guard check` is the Shore health check. Enforcement needs no login, clean tree, or remote service. A staged check refuses a partially staged JavaScript or TypeScript file and explains why. The commit hook also runs typecheck on every commit; `.shore/guard.json` `commitChecks.typecheck: false` turns it off for commits only, while `--all` always typechecks.

If `on-save` was declined, do not install or configure on-save tooling; say on-save checking is not set up and continue. Otherwise, identify the languages, framework, and module system. Choose the standard per-file tool and configure resolved imports so path aliases, base-relative and absolute specifiers, relative paths, and extensionless imports resolve to the same file the boundary engine sees. Generated ESLint import patterns match import text only; do not call them boundary enforcement.

Present what will be installed, changed, and covered on save. Get an explicit yes before installing or writing anything. The accepted approval-list decision supplies that yes. Reread `setupDecisions` immediately before changing it. Extend existing configuration; never replace or weaken it.

Prove the setup with a planted violation. Use a temporary forbidden import written once as a relative import and once through an alias when aliases exist. Confirm the on-save command reports it, then delete the file. If either style is missed, name the rules enforced only at commit time. If no suitable tool exists, state that boundaries are commit-time only.

## 6. Finish

Rerun `shore-guard guards apply --json` with no option and confirm it reports already applied before saying setup is complete.

When `commit-hook` was accepted, prove the hook with a real commit attempt on a throwaway branch or using a temporary file. Stage a planted forbidden import, run `git commit`, and confirm the commit is rejected and names a rule. Then remove the planted file and unstage it. If the commit succeeds, commit-time checks are not set up: say so and report them under **Not set up**.

`shore-guard check` and `shore-guard verify` refuse to run with uncommitted changes and need the commit on a branch Shore has scanned, so run `shore-guard check` only after the generated files are committed and pushed; exit 7 before that is expected and is not a failed setup.

Explain that saves run the single-file check when accepted, boundary rules run in the commit hook and CI, `shore-guard verify` includes the all-files check, `shore-guard check` checks Shore health, and the baseline only shrinks. Explain that setup choices live in `.shore/guard.json` under `setupDecisions`, and commit-only typechecking is controlled by `commitChecks.typecheck`. Tell the user to review the pull request or recap current-branch changes. State plainly: From here, the rules belong to this repository. Your agent may add, change, or remove them as the architecture evolves, and Shore Guard will not change them again.

Then follow the report skill (`shore-guard:report`) with stage guards.
