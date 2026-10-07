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

For greenfield/near-empty scopes, do not infer architecture. Offer the F2 preset catalog (`nodeApiPreset`, `reactNextVercelWebappPreset`, `supabaseApiPreset`, `supabaseNodeRagPreset`) with each preset's overview, when-to-avoid guidance, and layers from its metadata description. A selected preset enters the same proposal and approval path with empty repository baselines. Use `greenfield` evidence on every proposed module, edge, and rule, explaining that it comes from the user's preset selection rather than observed code.

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

Use `proposalVersion: 1`, `source: "discovery"` (or `"preset"` plus `presetId`), F1 metadata, exact F1 `pathMappings`, and a matching `moduleEvidence` entry for every module. Each allowed/forbidden edge and every boundary or candidate quality rule must contain a non-empty `evidence` array and `tradeoffs` string. Evidence kinds are `path`, `import-edge`, `manifest-fact`, `docs-intent`, `existing-policy`, and `greenfield`.

Use repository-relative concrete file paths in evidence (not an unverified glob). An `import-edge` cites its concrete source and destination files. A manifest fact includes file, key, observed value, and explanation. Rules retain all F1 fields, including adoption stage. Candidate quality rules use the same rule structure; do not claim enforcement support that has not been verified.

Validate with `validateProposal`. When local repository access is available, enable evidence-path checking. Fix every field-level error. The proposal is ready only when a reviewer can trace every boundary and rule to observations and understand its cost or uncertainty.

## Approval handoff

Tell the user to review the JSON, edit it if desired, then run `shore-guard adopt --proposal <file> --approve`. Rejection (`--reject`) writes nothing. An existing lock requires `--replace-lock`. Approval is the only path that writes the pack, lock, and fenced Shore Guard section in `AGENTS.md`.

See `fixtures/RUBRIC.md` for evaluation cases.
