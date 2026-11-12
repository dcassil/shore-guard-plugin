---
name: discovery
description: Investigate a repository and produce an evidence-backed Shore Guard policy proposal for human approval.
---

# Shore Guard discovery

Produce a proposal JSON matching `@shore/guard-policy`'s `PolicyProposal`. This is investigation, not installation: do not write a policy pack, lock, baseline, or generated configuration. Do not alter the repository.

## 1. Establish scope

Inventory the directory topology without generated/vendor directories. Read root and workspace manifests, package-manager workspace declarations, `tsconfig` references and path aliases, build/lint configs, architecture documentation, and any `AGENTS.md`. In a monorepo, investigate and report each workspace separately before proposing cross-workspace boundaries.

If `.shore/policy.lock.json` exists, read it and cite it as `existing-policy` evidence. Explain the existing decision and any proposed change; never silently re-propose or replace it.

## 2. Classify greenfield deterministically

A source file is a non-generated implementation file under the scoped repository/workspace; exclude vendored dependencies, build output, lockfiles, manifests, configuration, documentation, tests, fixtures, and generated code. An internal import edge is a resolvable import from one source file in scope to another.

Classify as **greenfield/near-empty** exactly when there are zero source files, or when there are at most two source files and zero observed internal import edges. Three source files are brownfield even with no edges; one or two files with an internal edge are brownfield. Record counts and cited paths.

For greenfield/near-empty scopes, do not infer architecture. A selected preset enters the same proposal and approval path with empty repository baselines. Use `greenfield` evidence on every proposed module, edge, and rule, explaining that it comes from the user's preset selection rather than observed code.

## 2b. No suitable preset

Continue to the interview when `discover` returns `interviewRequired`, or when the user declines every candidate. If the user declines the interview, return to the existing candidate offer and stop with exit 6 decision semantics; do not assemble a tailored result or write files.

## 2c. Interview

Use this fixed field set: `languages`, `frameworksAndTools`, `repoShape`, `appKind`, `lintSystem`, and `testFramework`.

Show each supported value as `Detected <value> from <evidence>; correct?` and ask only about fields that remain unresolved. Ask the corresponding text below byte-for-byte only when a field has no evidence. Also use the corresponding question when evidence conflicts and cannot support one value, first citing every conflicting fact.

- `languages`: "What language(s) will you use in this project? (JS/TS, Python, Rust, Ruby, Go, other)"
- `frameworksAndTools`: "What frameworks or tools will you use? (for example Vite, Next.js, Webpack, Vercel, Fly, none)"
- `repoShape`: "Is this a single app or a monorepo? If a monorepo, which package kinds will it contain? (web, native, server, cli, plugin, library)"
- `appKind`: "What kind of app is this? (client-side only, server-side only, full-stack, CLI, plugin/extension, library)"
- `lintSystem`: "No lint rules were found. Do you have a preferred rules system? Shore recommends flat ESLint with architecture boundaries: it checks the file you just saved and only requires files to pass once they are touched, grandfathering existing violations behind a ratchet baseline."
- `testFramework`: "No test framework was found. Do you have a preference? Shore recommends Vitest (plus Playwright for browser end-to-end when the app has a UI)."

Confirm corrected detections as asked answers. Record `none` when the user chooses no lint or test system. Retain the evidence paths for every detected or answered field.

## 3. Investigate brownfield evidence

Run `shore-guard discover --json`.

On exit 6, handle `data.reason` as follows:

- `codebase_required`: the repository has several codebases; list every entry in `data.codebases` (`codebaseId`, `rootPath`, `displayName`), ask the user which one to discover, then rerun with `shore-guard discover --codebase <codebaseId> --json`.
- `profile_stale`: relay the remediation returned by the command and stop.
- `scan_not_found`: relay the returned message and remediation and stop.
- Any other reason: apply the `completion-contract` skill (`shore-guard:completion-contract`) table and stop.

For every other nonzero exit, apply the completion-contract table and stop. On success, read `data.proposalPath`. Summarize the returned proposal's modules, edges, rules, and tradeoffs in no more than 10 lines, then list every entry in `data.dropped` with its returned reason. Continue to section 5.

## 4. Discover a greenfield proposal

Gather facts for `languages`, `frameworksAndTools`, `repoShape`, `appKind`, `lintSystem`, and `testFramework`, retaining repository-relative evidence paths for every fact. Write them to `.shore/discovery-facts.json`, then run:

`shore-guard discover --greenfield --facts .shore/discovery-facts.json --json`

For every nonzero exit, apply the completion-contract table and stop. Present every returned candidate with its `fitReasons` and `whenToAvoid` values.

When the user selects a preset, write a proposal with `source: "preset"` and that `presetId` to `.shore/proposals/<YYYY-MM-DD>-preset.json`, using the preset's local pack data, `greenfield` evidence on every item, and empty repository baselines. Summarize the proposal in no more than 10 lines and continue to section 5.

If the result has `interviewRequired`, or the user declines every candidate, follow section 2c. Write the completed answers and evidence to `.shore/discovery-interview.json`, choose a lowercase hyphenated slug and a human-readable name with the user, then run:

`shore-guard discover --interview .shore/discovery-interview.json --slug <slug> --name <name> --json`

For every nonzero exit, apply the completion-contract table and stop. If the returned strength is not strong, relay every entry in `data.strength.reasons`. Read `data.proposalPath`, summarize the proposal in no more than 10 lines, list `data.dropped`, and continue to section 5.

## 5. Approval handoff

Tell the user to review the JSON, edit it if desired, then run `shore-guard adopt --proposal <file> --approve`. Rejection (`--reject`) writes nothing. An existing lock requires `--replace-lock`. Approval is the only path that writes the pack, lock, and fenced Shore Guard section in `AGENTS.md`. After approval, follow the guards skill (`shore-guard:guards`) to install and configure the rule engines that enforce the adopted policy.
If the full steps of that skill are not in your context, read ${CLAUDE_PLUGIN_ROOT}/skills/guards/SKILL.md before doing anything else; do not proceed from this summary alone.

Do not pass --approved-by unless the user has told you the name to record; never take it from git configuration or guess it.

## 6. Offer catalog submission

Run this section only after an adopted proposal with `source: "authored"`. Never offer submission for `preset` or `discovery` sources.

Run `shore-guard blueprint submit --file .shore/blueprints/<id>.json --dry-run --json`. If the command exits 6 with strength reasons in `data.reasons`, stop silently without making an offer. This includes a blueprint that became weak after adoption. If the command says the blueprint id is already listed in `submittedBlueprints`, relay that message and do not offer again. If the command exits 2 because the installed version has no `blueprint` subcommand, tell the user to upgrade Shore Guard and stop. For every other nonzero exit, apply the completion-contract table and stop with its remediation. Continue only on exit 0.

Show this reassurance verbatim:

This sends only a generalized architecture schema: module names, path patterns, edges, and rules. It contains no code, file contents, repository name, URLs, or evidence from your project.

Then print the complete `data.payload` JSON from the dry run and ask exactly:

Submit this blueprint to the public Shore Guard catalog? (yes/no)

Only an explicit yes is consent. For every other answer, say exactly: "Not submitted. You can run `shore-guard blueprint submit --file <path>` later." Then stop.

On yes, run `shore-guard blueprint submit --file .shore/blueprints/<id>.json --json` without `--dry-run`. On exit 0, report `data.issueUrl`. On exit 6 with `data.prefilledUrl`, say that no GitHub credential was found and give the web address to open. On exit 3, tell the user to run `shore-guard login` or escalate; do not complete. On exit 4, report remote availability as a distinct non-completion state and remediate or escalate; never report success. For every other nonzero exit, apply the completion-contract table and stop with its remediation. Relay an already-submitted message and never offer that blueprint id again.

Then follow the report skill (`shore-guard:report`) with stage discovery.
