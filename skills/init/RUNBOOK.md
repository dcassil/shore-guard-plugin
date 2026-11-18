# Shore Guard initialization runbook

1. Install the CLI globally: `npm install -g shore-guard`.
2. Alternatively, set up the CLI without a global install: `npx shore-guard setup`.
3. Log in from your terminal and never paste the key into chat: `shore-guard login`.
4. In Shore Sight, verify that this repository is connected.
5. Review the planned changes: `shore-guard init --plan --json`.
6. Find the default branch and strip `refs/remotes/origin/`, falling back to `main`: `git symbolic-ref refs/remotes/origin/HEAD`.
7. Optionally create and enter a setup branch: `git switch -c shore-guard/setup <default-branch>`.
8. Initialize the repository: `shore-guard init --json`.
9. Inspect changed paths: `git status --porcelain`.
10. Inspect the ignore changes: `git diff -- .gitignore`.
11. Inspect the complete configuration: `cat .shore/guard.json`.
12. Stage the generated files: `git add .shore/guard.json .gitignore`.
13. Commit the configuration: `git commit -m "chore: add Shore Guard configuration"`.
14. Follow the discovery skill (`shore-guard:discovery`) and run `shore-guard discover --json` for brownfield, or its documented greenfield command.
15. Let the agent answer interview fields supported by repository evidence; answer only unresolved or conflicting fields.
16. Review the agent's short summary of modules, forbidden dependencies, entry-point rules, and grandfathered violations; choose proceed or stop.
17. On proceed, follow the guards skill with `--blueprint <id>` or `--source <proposalPath>`; it shows one approval list of required and optional repository tooling and asks yes to all, no, or choose each item one at a time.
18. To accept the whole list manually, run `shore-guard guards apply --blueprint <id> --choice shore --accept all --json`.
19. For an existing pull-request workflow, add a step that runs `npm run guard:rules -- --baseline-ref <base commit SHA>` and ensure checkout has full history.
20. Inspect and commit the generated rule files and baselines with `git commit -m "chore: add Shore Guard rules and guards"`.
21. Push the setup branch: `git push -u origin shore-guard/setup`.
22. Open the pull request: `gh pr create --base <default-branch> --title "Add Shore Guard configuration" --body "Adds Shore Guard configuration, generated rules, guards, and baselines from /shore-guard:init."`.
23. Check the completed setup: `shore-guard doctor --json`.
24. Rerun `shore-guard guards apply --json` and confirm it reports already applied.

To stay on the current branch, skip steps 7, 19, and 20. From here, the rules belong to this repository. Your agent may add, change, or remove them as the architecture evolves, and Shore Guard will not change them again. For CI, set `SHORE_API_KEY` in the CI secret store.
