---
name: discovery
description: Investigate a repository, select a catalog blueprint, or produce a short-lived evidence-backed proposal.
---

# Shore Guard discovery

A blueprint is a catalog entry of pre-made architecture and rule definitions. A proposal is produced only when a blueprint must be derived from the repository's own solid architecture; it is used to generate rules, may optionally be submitted as a public blueprint, and is then discarded. Discovery does not install tools or rule configuration.

## 1. Assess

Inventory the topology without generated or vendor directories. Read root and workspace manifests, workspace declarations, `tsconfig` references and aliases, build and lint configuration, architecture documentation, and any `AGENTS.md`.

In a monorepo, assess every codebase separately because packages can differ. Run `shore-guard discover --json` once; it evaluates every codebase and returns `data.mode: "multi-codebase"`, `data.codebases` with an `outcome` for each codebase, and `data.manifestPath`. Decide every codebase without asking the user to select one. One guards installation at the repository root covers all codebases.

A source file is a non-generated implementation file under the scoped repository or workspace; exclude vendored dependencies, build output, lockfiles, manifests, configuration, documentation, tests, fixtures, and generated code. An internal import edge is a resolvable import from one source file in scope to another.

Classify as **greenfield/near-empty** exactly when there are zero source files, or when there are at most two source files and zero observed internal import edges. Three source files are brownfield even with no edges; one or two files with an internal edge are brownfield. Record counts and cited paths.

Get the catalog candidates for every repository, brownfield included. Answer the section 2 fields first, then write `.shore/discovery-facts.json` with exactly these four keys and no others: `languages` (array of strings), `frameworksAndTools` (array of strings; use `["none"]` when there are none), `repoShape` (`single`, `monorepo`, or `unknown`), and `appKind` (`client`, `server`, `fullstack`, `cli`, `plugin`, `library`, or `unknown`). Run `shore-guard discover --greenfield --facts .shore/discovery-facts.json --json`; the option is named for its first use and works for any repository. Keep every `data.candidates` entry: `policyPackId` is the blueprint id that guards takes, and `name`, `score`, `fitReasons`, and `whenToAvoid` describe the fit. Guards does not accept `presetId`. When `data.interviewRequired` is true, no candidate fits on these facts alone.

For brownfield, also run `shore-guard discover --json`. It needs a clean working tree and a commit Shore has scanned. For a single codebase it writes a proposal derived from the repository's own architecture and returns `data.proposalPath`, `data.summary`, and `data.dropped`; list every `data.dropped` entry with its reason. For several codebases, use each `data.codebases` entry and its `outcome`: `proposal` includes `proposalPath`, `summary`, and `dropped`; `none` and `error` include a `reason`.

When the command returns `data.error`, quote its `httpStatus`, `reason`, `message`, and `requestId` fields that are present so the user knows why Shore refused the request. Exit 2 with `data.error` is a rejected request: report it, do not retry blindly, and do not guess that it is quota. Exit 4 means the service could not be reached or is overloaded; retry later. Exit 6 is a decision to make, never an outage. Never infer a cause the output does not state.

On exit 6, handle `data.reason` as follows:

- `profile_stale`: relay the returned remediation and stop.
- `scan_not_found`: relay the returned message and remediation and stop.
- Any other reason: apply the `completion-contract` skill (`shore-guard:completion-contract`) table and stop.

For every other nonzero exit, apply the completion-contract table and stop.

## 2. Interview, answered by the agent

Use exactly these fields: `languages`, `frameworksAndTools`, `repoShape`, `appKind`, `lintSystem`, and `testFramework`.

Answer every field determinable from the repository and record its evidence. Do not ask the user to confirm fields answered from repository evidence. Ask only for fields that cannot be determined or where evidence conflicts. For a conflict, cite every conflicting fact before asking the corresponding question byte-for-byte:

- `languages`: "What language(s) will you use in this project? (JS/TS, Python, Rust, Ruby, Go, other)"
- `frameworksAndTools`: "What frameworks or tools will you use? (for example Vite, Next.js, Webpack, Vercel, Fly, none)"
- `repoShape`: "Is this a single app or a monorepo? If a monorepo, which package kinds will it contain? (web, native, server, cli, plugin, library)"
- `appKind`: "What kind of app is this? (client-side only, server-side only, full-stack, CLI, plugin/extension, library)"
- `lintSystem`: "No lint rules were found. Do you have a preferred rules system? Shore recommends flat ESLint with architecture boundaries: it checks the file you just saved and only requires files to pass once they are touched, grandfathering existing violations behind a ratchet baseline."
- `testFramework`: "No test framework was found. Do you have a preference? Shore recommends Vitest (plus Playwright for browser end-to-end when the app has a UI)."

Record `none` when the user chooses no lint or test system. Retain evidence for every answer.

Run the interview command only when a tailored blueprint is needed: the candidates run returned `data.interviewRequired` true, or no candidate fits and there is no brownfield proposal. If the user declines to answer a field you could not determine, do not run it; choose among the candidates in section 3. Otherwise write `.shore/discovery-interview.json` with one entry per field, each shaped `{ "value": "<answer>", "source": "inferred", "evidence": ["<repository-relative path or fact>"] }`; use `inferred` for a field answered from the repository and `asked` for a field the user answered. Choose a lowercase hyphenated slug and human-readable name with the user, then run `shore-guard discover --interview .shore/discovery-interview.json --slug <slug> --name <name> --json`. It writes `.shore/blueprints/<slug>.json` and a proposal, and returns `data.proposalPath`, `data.blueprintId`, and `data.strength`.

For every nonzero exit, apply the completion-contract table and stop. If `data.strength.strong` is false, relay every `data.strength.reasons` entry.

### Several codebases

For every codebase, including one with a derived proposal, evaluate the catalog using facts from that codebase's own files: its app kind, frameworks and tools, languages, and shape. Write a separate facts file for the codebase and run `shore-guard discover --json --greenfield --facts <file>`. Do not use repository-wide facts for an individual package. Compare the best catalog blueprint with that codebase's derived proposal.

Decide each codebase in this order:

1. Choose a catalog blueprint when it genuinely fits.
2. Otherwise choose the derived proposal when its `outcome` is `proposal`.
3. Otherwise use `--interview` when the codebase has real architecture but neither option fits. Save the authored blueprint and record it as a codebase-relative source.
4. Otherwise choose `none` with a reason. This is a legitimate decision for a workspace root with no code of its own, a thin wrapper with nothing to constrain, or another codebase without enforceable architecture.

For an `error` outcome, report its reason, decide every other codebase, and offer to rerun discovery later for that codebase with `--codebase <id>`. Also decide whether rules between codebases need a whole-repository blueprint. The bundled catalog provides `shore.preset.multi-framework-library-monorepo` for a framework-agnostic core with per-framework wrappers and a docs site; apply it by id even though catalog scoring does not list it yet.

Edit `.shore/architecture-manifest.json` to record every decision. Derived proposals are repository-relative; catalog and authored blueprints are placed under the codebase path by the tool. Use this shape, adapting the entries to the repository:

```json
{
  "schemaVersion": 1,
  "commitSha": "<40 hex>",
  "codebases": [
    {
      "codebaseId": "<uuid>",
      "path": "packages/core",
      "displayName": "core",
      "decision": {
        "kind": "proposal",
        "source": ".shore/proposals/<...>/core.json",
        "pathBase": "repository"
      }
    },
    {
      "codebaseId": "<uuid>",
      "path": "packages/docs",
      "displayName": "docs",
      "decision": {
        "kind": "blueprint",
        "id": "shore.preset.react-next-vercel-webapp"
      }
    },
    {
      "codebaseId": "<uuid>",
      "path": "packages/custom",
      "displayName": "custom",
      "decision": {
        "kind": "proposal",
        "source": ".shore/blueprints/custom.json",
        "pathBase": "codebase"
      }
    },
    {
      "codebaseId": "<uuid>",
      "path": ".",
      "displayName": "root",
      "decision": {
        "kind": "none",
        "reason": "no code of its own"
      }
    }
  ],
  "repository": {
    "kind": "blueprint",
    "id": "shore.preset.multi-framework-library-monorepo"
  }
}
```

Present one table with Codebase path, Decision, and Why columns, then ask once to confirm the whole table. Do not ask separately for each codebase. If the user rejects it, adjust the decisions as directed, show the complete table again, and ask once again. If every codebase is `none` and there is no repository blueprint, explain why nothing can be enforced yet and do not run `guards apply`.

## 3. Decide the outcome

Choose one outcome and tell the user with its sentence verbatim:

1. `We found an architecture that aligns closely to yours.`
2. `We found an architecture that is considered first class for your type of project and suggest creating rules that can transition your code towards this over time.`
3. `We did not have an existing architecture that matches yours, but upon review, your architecture is solid. We will set up rules and guards that will help keep it that way as your codebase evolves.`

For a single codebase, decide by comparing the repository's actual modules and dependencies with each candidate. Outcomes one and two use a candidate's `policyPackId` and pass it as `--blueprint <id>` to guards. If the architecture is neither close to a blueprint nor solid, use outcome two with the best-fitting blueprint and explain what must change. Outcome three passes `--source <proposalPath>` with the `data.proposalPath` from the brownfield run, or from the interview run when that is the only proposal. A proposal whose `data.strength.strong` is false is not a solid architecture; use outcome two. Never author proposal JSON for a catalog blueprint.

## 4. Summarize the rules

In no more than about ten lines, summarize the modules, main forbidden dependencies, entry-point rules, and that today's violations are grandfathered so the code can move toward the architecture over time. Do not ask the user to read or edit JSON. Ask one question: proceed, or stop.

On stop, change nothing. On proceed, follow the guards skill (`shore-guard:guards`) with `--manifest .shore/architecture-manifest.json` for several codebases or the selected source option for a single codebase. If the full steps of that skill are not in your context, read ${CLAUDE_PLUGIN_ROOT}/skills/guards/SKILL.md before doing anything else; do not proceed from this summary alone.

After setup, tell the user to review the pull request or, on the current branch, recap what was written. State plainly: From here, the rules belong to this repository. Your agent may add, change, or remove them as the architecture evolves, and Shore Guard will not change them again.

## 7. Offer catalog submission

Run this section only when outcome three was used and the interview run wrote `.shore/blueprints/<slug>.json`. Never offer it for a catalog blueprint.

Run `shore-guard blueprint submit --file .shore/blueprints/<slug>.json --dry-run --json`. If exit 6 includes strength reasons in `data.reasons`, stop silently. If the id is in `submittedBlueprints`, relay that message and do not offer again. If exit 2 says there is no `blueprint` subcommand, tell the user to upgrade Shore Guard and stop. For every other nonzero exit, apply the completion-contract table and stop. Continue only on exit 0.

Show this reassurance verbatim:

This sends only a generalized architecture schema: module names, path patterns, edges, and rules. It contains no code, file contents, repository name, URLs, or evidence from your project.

Print the complete `data.payload` JSON and ask exactly:

Submit this blueprint to the public Shore Guard catalog? (yes/no)

Only an explicit yes is consent. For every other answer, say exactly: "Not submitted. You can run `shore-guard blueprint submit --file <path>` later." Then stop.

On yes, run the same command without `--dry-run`. On exit 0, report `data.issueUrl`. On exit 6 with `data.prefilledUrl`, say no GitHub credential was found and give the web address to open. On exit 3, tell the user to run `shore-guard login` or escalate; do not complete. On exit 4, report remote availability as a distinct non-completion state and remediate or escalate. For every other nonzero exit, apply the completion-contract table and stop. Relay an already-submitted message and never offer that id again.

Then follow the report skill (`shore-guard:report`) with stage discovery.
