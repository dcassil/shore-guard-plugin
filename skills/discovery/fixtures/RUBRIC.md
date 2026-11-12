# Discovery evaluation rubric

All proposals must validate, cite every module/edge/rule, use concrete evidence rather than names as proof, and explain tradeoffs in plain language.

Brownfield cases require a connected, scanned fixture before running `discover`.

## greenfield

`greenfield/` contains only a manifest and README: zero source files. A good result classifies it greenfield, records the counts, offers all five presets with their catalog overview/avoid/layers metadata, and does not infer a policy before selection. A selected preset uses `source: "preset"`, `presetId`, greenfield evidence throughout, and empty baselines.

## Vite client greenfield interview

`vite-client-greenfield/` has one source file and no internal edge, so it is greenfield/near-empty. If the user declines every preset, the proposal returned by `discover` identifies `languages` as JS/TS from `package.json`, `tsconfig.json`, and `src/main.ts`; `frameworksAndTools` as Vite and TypeScript from manifest facts and `vite.config.ts`; `repoShape` as `single` from the root manifest and topology; and `appKind` as `client` from Vite, `index.html`, and `src/main.ts`. The agent must show those four detections for confirmation and cite evidence for each. It must ask exactly:

"No lint rules were found. Do you have a preferred rules system? Shore recommends flat ESLint with architecture boundaries: it checks the file you just saved and only requires files to pass once they are touched, grandfathering existing violations behind a ratchet baseline."

"No test framework was found. Do you have a preference? Shore recommends Vitest (plus Playwright for browser end-to-end when the app has a UI)."

It must not ask the language, tools, shape, or app-kind questions.

## No-fit brownfield interview

`no-fit-brownfield/` has three Python source files and two internal import edges, so it is brownfield. After the proposal returned by `discover` cites manifest facts showing why every preset's **When to avoid** guidance applies and lists every rejected preset identifier with its reason, it identifies `languages` as Python from `pyproject.toml` and the `.py` extensions; `frameworksAndTools` as Flask from `pyproject.toml`; `repoShape` as `single` from the root project declaration and topology; `appKind` as `server` from the Flask dependency, imports, and README; and `testFramework` as pytest from `pyproject.toml`. The agent must show those five detections for confirmation and cite evidence for each. It must ask exactly:

"No lint rules were found. Do you have a preferred rules system? Shore recommends flat ESLint with architecture boundaries: it checks the file you just saved and only requires files to pass once they are touched, grandfathering existing violations behind a ratchet baseline."

It must not ask the language, tools, shape, app-kind, or test-framework questions.

## clear brownfield

`clear-brownfield/` has an API file importing a domain file, matching its README. A good result cites both concrete files, the observed edge, and stated intent; proposes the allowed API-to-domain direction; and does not invent persistence/UI layers.

## ambiguous brownfield

`ambiguous-brownfield/` documents a UI/domain separation but both files import each other. A good result surfaces the contradiction, cycle, and migration tradeoff. It must not silently privilege the README or infer a forbidden edge solely from directory names.

## near-empty boundaries

- `near-empty/two-no-edge`: two source files, no internal edge => greenfield.
- `near-empty/two-with-edge`: two source files with one internal edge => brownfield.
- `near-empty/three-no-edge`: three source files, no internal edge => brownfield.

Generated files, tests, fixtures, manifests, configs, docs, dependencies, and build output do not count as source files.

## submission

After an authored blueprint is adopted, a good result dry-runs the submission command. For a strong result it shows exactly "This sends only a generalized architecture schema: module names, path patterns, edges, and rules. It contains no code, file contents, repository name, URLs, or evidence from your project.", prints the full `data.payload` JSON, and asks exactly "Submit this blueprint to the public Shore Guard catalog? (yes/no)" once. A weak result stops silently without an offer. A declined or non-explicit answer prints exactly "Not submitted. You can run `shore-guard blueprint submit --file <path>` later." and does not submit. An explicit yes runs the submission command without `--dry-run`; a successful run reports `data.issueUrl`. An unauthenticated run with `data.prefilledUrl` says no GitHub credential was found and gives the web address to open. Preset and discovery proposals are never offered, and an id in `submittedBlueprints` is never offered again.
