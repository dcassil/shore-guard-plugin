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

For greenfield/near-empty scopes, do not infer architecture. Offer the F2 preset catalog (`nodeApiPreset`, `reactNextVercelWebappPreset`, `supabaseApiPreset`, `supabaseNodeRagPreset`, `viteClientSideWebappPreset`) with each preset's overview, when-to-avoid guidance, and layers from its metadata description. A selected preset enters the same proposal and approval path with empty repository baselines. Use `greenfield` evidence on every proposed module, edge, and rule, explaining that it comes from the user's preset selection rather than observed code.

## 2b. No suitable preset

Continue to the interview only when the user declines every catalog preset for a greenfield/near-empty scope, or when brownfield evidence establishes that every preset's **When to avoid** guidance applies. For a brownfield scope, cite `manifest-fact` evidence for each determination. Before continuing, list all five preset identifiers (`nodeApiPreset`, `reactNextVercelWebappPreset`, `supabaseApiPreset`, `supabaseNodeRagPreset`, and `viteClientSideWebappPreset`) and give the specific rejection reason for each one.

Offer the interview. If the user declines it, return to the existing preset offer and stop with exit 6 decision semantics; do not assemble a tailored result or write files.

## 2c. Interview (inference first)

Infer only what repository evidence supports, and cite a `manifest-fact` or repository-relative path for every pre-answered field. Show each supported value as `Detected <value> from <evidence>; correct?` and ask only about fields that remain unresolved. Use this fixed field set:

| Field | Inference sources |
| --- | --- |
| `languages` | Manifest dependencies, `tsconfig`, and source file extensions. |
| `frameworksAndTools` | Manifest dependencies and scripts, lockfile, `vite.config.*`, and `next.config.*`. |
| `repoShape` | `pnpm-workspace.yaml`, manifest `workspaces`, directory topology, and workspace manifests; record `single` or `monorepo`, and for a monorepo record each package as `web`, `native`, `server`, `cli`, `plugin`, or `library`. |
| `appKind` | Manifest dependencies and scripts, `vite.config.*`, `next.config.*`, repository entry files, and workspace manifests; record `client`, `server`, `fullstack`, `cli`, `plugin`, or `library`. |
| `lintSystem` | Manifest dependencies and scripts, `eslint.config.*`, and `biome.json`. |
| `testFramework` | Manifest dependencies and scripts, `vitest.config.*`, `jest.config.*`, and `playwright.config.*`. |

Ask the corresponding text below byte-for-byte only when a field has no evidence. Also use the corresponding question when evidence conflicts and cannot support one value, first citing every conflicting fact (for example, both Vite and Next.js signals).

- `languages`: "What language(s) will you use in this project? (JS/TS, Python, Rust, Ruby, Go, other)"
- `frameworksAndTools`: "What frameworks or tools will you use? (for example Vite, Next.js, Webpack, Vercel, Fly, none)"
- `repoShape`: "Is this a single app or a monorepo? If a monorepo, which package kinds will it contain? (web, native, server, cli, plugin, library)"
- `appKind`: "What kind of app is this? (client-side only, server-side only, full-stack, CLI, plugin/extension, library)"
- `lintSystem`: "No lint rules were found. Do you have a preferred rules system? Shore recommends flat ESLint with architecture boundaries: it checks the file you just saved and only requires files to pass once they are touched, grandfathering existing violations behind a ratchet baseline."
- `testFramework`: "No test framework was found. Do you have a preference? Shore recommends Vitest (plus Playwright for browser end-to-end when the app has a UI)."

Confirm corrected detections as asked answers. Record `none` when the user chooses no lint or test system and note that renderers will not be installed. For non-JS languages, complete the interview and state plainly that assembly may produce a modules-only blueprint with no renderer support. For a monorepo with different package kinds, retain the per-package kinds; assembly remains per workspace.

End the skill's working output with an `interview` JSON block in this shape for blueprint assembly. Replace every placeholder with the final value, set each `source` to `inferred` or `asked`, and retain the evidence that supported an inference or prompted and resolved a conflicting signal. An asked field with no repository evidence cites the user's answer.

```json
{
  "interview": {
    "languages": { "value": "<value>", "source": "inferred", "evidence": ["<manifest-fact or path>"] },
    "frameworksAndTools": { "value": "<value>", "source": "inferred", "evidence": ["<manifest-fact or path>"] },
    "repoShape": { "value": "<value>", "source": "inferred", "evidence": ["<manifest-fact or path>"] },
    "appKind": { "value": "<value>", "source": "inferred", "evidence": ["<manifest-fact or path>"] },
    "lintSystem": { "value": "<value>", "source": "asked", "evidence": ["user answer: <value>"] },
    "testFramework": { "value": "<value>", "source": "asked", "evidence": ["user answer: <value>"] }
  }
}
```

## 3. Investigate brownfield evidence

Build an import graph from actual import/require statements and resolved aliases. For each candidate boundary inspect:

- concrete directories and files;
- observed import edges in both directions;
- dependencies, scripts, exports, workspace declarations, and alias facts from manifests/configs;
- documentation that states architectural intent;
- existing enforcement/configuration.

Heuristics and preset vocabulary may only seed questions to investigate. **Never turn a name, framework stereotype, or directory-pattern match into a conclusion.** Every conclusion must cite concrete evidence. If evidence is insufficient, omit the rule or identify the uncertainty in tradeoffs.

When documentation and imports disagree, cite both, describe the contradiction and migration cost in plain language, and present it as a tradeoff. Never silently choose one as truth.

## 4. Emit the proposal

Write the proposal to `.shore/proposals/<YYYY-MM-DD>-discovery.json` so it is tracked and reviewable.

Use `proposalVersion: 1`, `source: "discovery"` (or `"preset"` plus `presetId`), F1 metadata, exact F1 `pathMappings`, and a matching `moduleEvidence` entry for every module. Each allowed/forbidden edge and every boundary or candidate quality rule must contain a non-empty `evidence` array and `tradeoffs` string. Evidence kinds are `path`, `import-edge`, `manifest-fact`, `docs-intent`, `existing-policy`, and `greenfield`.

Use repository-relative concrete file paths in evidence (not an unverified glob). An `import-edge` cites its concrete source and destination files. A manifest fact includes file, key, observed value, and explanation. Rules retain all F1 fields, including adoption stage. Candidate quality rules use the same rule structure; do not claim enforcement support that has not been verified.

Validate with `validateProposal`. When local repository access is available, enable evidence-path checking. Fix every field-level error. The proposal is ready only when a reviewer can trace every boundary and rule to observations and understand its cost or uncertainty.

## 4b. Assembling an authored blueprint

When the interview calls for a tailored greenfield design, assemble an authored blueprint with `source: "authored"` and `blueprintId: "shore.authored.<slug>"`, where the slug contains lowercase letters, numbers, and single hyphens. Its catalog description must have **Overview**, **When to avoid**, and **Layers** passages. Start from the nearest presets, but translate the interview answers rather than copying a preset blindly: model public-entry features, isolate a pure core, forbid upward imports, and keep Node builtins and build tooling out of browser bundles. Set `no-cycles` to `warn` and `no-orphans` to `observe`.

Use only known rule kinds. Every module, allowed or forbidden edge, and rule must cite `interview` or `greenfield` evidence and state its tradeoffs. Interview evidence records the question field, the answer value, and why it supports the choice. Do not place repository-identifying strings anywhere except `pathMappings`; authored descriptions, evidence, diagnostics, and remediation must remain reusable catalog language.

Strip proposal support metadata and run `validate` on the resulting policy pack, then run `validateProposal` on the complete authored proposal. Fix every reported error before presenting it for review.

## Approval handoff

Tell the user to review the JSON, edit it if desired, then run `shore-guard adopt --proposal <file> --approve`. Rejection (`--reject`) writes nothing. An existing lock requires `--replace-lock`. Approval is the only path that writes the pack, lock, and fenced Shore Guard section in `AGENTS.md`.

## 6. Offer catalog submission

Run this section only after an adopted proposal with `source: "authored"`. Never offer submission for `preset` or `discovery` sources.

Run `shore-guard blueprint submit --file .shore/blueprints/<id>.json --dry-run --json`. If the command exits 6 with strength reasons in `data.reasons`, stop silently without making an offer. This includes a blueprint that became weak after adoption. If the command says the blueprint id is already listed in `submittedBlueprints`, relay that message and do not offer again. If the command exits 2 because the installed version has no `blueprint` subcommand, tell the user to upgrade Shore Guard and stop. For every other nonzero exit, apply the completion-contract table and stop with its remediation. Continue only on exit 0.

Show this reassurance verbatim:

This sends only a generalized architecture schema: module names, path patterns, edges, and rules. It contains no code, file contents, repository name, URLs, or evidence from your project.

Then print the complete `data.payload` JSON from the dry run and ask exactly:

Submit this blueprint to the public Shore Guard catalog? (yes/no)

Only an explicit yes is consent. For every other answer, say exactly: "Not submitted. You can run `shore-guard blueprint submit --file <path>` later." Then stop.

On yes, run `shore-guard blueprint submit --file .shore/blueprints/<id>.json --json` without `--dry-run`. On exit 0, report `data.issueUrl`. On exit 6 with `data.prefilledUrl`, say that no GitHub credential was found and give the web address to open. On exit 3, tell the user to run `shore-guard login` or escalate; do not complete. On exit 4, report remote availability as a distinct non-completion state and remediate or escalate; never report success. For every other nonzero exit, apply the completion-contract table and stop with its remediation. Relay an already-submitted message and never offer that blueprint id again.

See `fixtures/RUBRIC.md` for evaluation cases.
