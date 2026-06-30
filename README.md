<!--
USING THIS TEMPLATE — delete this block after creating your repo.
1. Replace every <repo> and one-line-description placeholder (this README, AGENTS.md,
   docs/*, and the package.json name + description).
2. Add your archetype's source tier beside docs/ (see the org REPO-STRUCTURE.md):
   - app / engine: packages/ or src/, tests/, build config, scripts/
   - skills pack: skills/, methodologies/ (or profiles), evals/, scripts/
   - docs-only: nothing beyond docs/
3. Apply the org repo standard (ruleset + merge settings) once the repo exists on GitHub:
     bash scripts/apply-repo-standard.sh <owner>/<repo>
4. Delete this comment block. Keep scripts/apply-repo-standard.sh for future re-runs.
-->

# <repo>

> One-line description of what `<repo>` is and where it sits in the agentic-workflow-kit suite
> spine: `define / PRD -> technical-design -> jig (run) -> learning loop`.

## Status

> Early / planned. Describe current maturity here.

## Development

```bash
pnpm install --frozen-lockfile
pnpm check
```

`pnpm check` is the single required local and CI gate.

## Documentation

- [`docs/product/`](docs/product/) — what & why (audience-facing).
- [`docs/design/`](docs/design/) — how (mechanics, decisions, contracts).

## Relationship to the suite

`<repo>` is part of [`agentic-workflow-kit`](https://github.com/agentic-workflow-kit), a polyrepo
family of standalone, composable products for an agentic software-development lifecycle. Each repo
is independently useful and composes through shared contracts, not internals.

## License

MIT License. See [LICENSE](LICENSE).
