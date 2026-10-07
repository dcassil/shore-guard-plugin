# Discovery evaluation rubric

All proposals must validate, cite every module/edge/rule, use concrete evidence rather than names as proof, and explain tradeoffs in plain language.

## greenfield

`greenfield/` contains only a manifest and README: zero source files. A good result classifies it greenfield, records the counts, offers all four presets with their catalog overview/avoid/layers metadata, and does not infer a policy before selection. A selected preset uses `source: "preset"`, `presetId`, greenfield evidence throughout, and empty baselines.

## clear brownfield

`clear-brownfield/` has an API file importing a domain file, matching its README. A good result cites both concrete files, the observed edge, and stated intent; proposes the allowed API-to-domain direction; and does not invent persistence/UI layers.

## ambiguous brownfield

`ambiguous-brownfield/` documents a UI/domain separation but both files import each other. A good result surfaces the contradiction, cycle, and migration tradeoff. It must not silently privilege the README or infer a forbidden edge solely from directory names.

## near-empty boundaries

- `near-empty/two-no-edge`: two source files, no internal edge => greenfield.
- `near-empty/two-with-edge`: two source files with one internal edge => brownfield.
- `near-empty/three-no-edge`: three source files, no internal edge => brownfield.

Generated files, tests, fixtures, manifests, configs, docs, dependencies, and build output do not count as source files.
