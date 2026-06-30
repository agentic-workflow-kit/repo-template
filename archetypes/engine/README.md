# Engine-archetype tooling standard

The base template carries the **common spine** only (docs, `AGENTS.md`/`CLAUDE.md`, prettier-based
`check`). That is the right surface for docs-only and skills-pack repos, where `pnpm check` is a
formatting gate over Markdown/YAML/JSON.

This directory is the **engine-archetype standard**: the tooling an engine repo carries the moment
it grows real TypeScript source — type checking, linting, and a tested coverage gate. It is
**archetype-scoped, not optional**: every engine repo conforms to it, and docs/skills repos must
**not** adopt it (it would over-tool prose-heavy repositories). This mirrors how the repo standard
already varies the _source tier_ by archetype — here the _gate_ varies too.

> Validated end-to-end on Node 26.4.0 with the versions below: `pnpm check` runs biome, `tsc -b`,
> and vitest (100% coverage on the sample module) and exits 0. Re-validate and re-pin when bumping
> any tool major.

## Lint/format stance

Per the org decision: **biome for code, prettier for docs.**

- **biome** formats, lints, and organizes imports for TypeScript / JS / JSON (one fast tool,
  recommended ruleset).
- **prettier** keeps handling Markdown / YAML — the formats it is strongest at and that the docs
  repos already standardize on.

Each repo runs exactly one formatter per file type, so there is no in-repo conflict; the org simply
has both tools present across the two archetypes.

## What's here

| File                 | Role                                                                      |
| -------------------- | ------------------------------------------------------------------------- |
| `biome.json`         | Format + lint + import-sort (recommended rules, 120 cols, single quotes). |
| `tsconfig.base.json` | Shared strict compiler options (`composite`, `NodeNext`, declarations).   |
| `tsconfig.json`      | Single-package project config; `tsc -b` builds `src` + `tests`.           |
| `vitest.config.ts`   | Unit + integration projects with a 90% coverage threshold.                |

## Adopting it in an engine repo

1. Copy the four files above into the repo root.

2. Set the `package.json` `scripts` to the engine gate (replacing the prettier-only `format`/
   `lint`/`check` from the spine):

   ```json
   {
     "format": "biome check --write . && prettier --write \"**/*.{md,yml,yaml}\"",
     "format:check": "prettier --check \"**/*.{md,yml,yaml}\"",
     "lint": "biome check .",
     "typecheck": "tsc -b",
     "test": "vitest run --coverage --passWithNoTests",
     "check": "pnpm lint && pnpm format:check && pnpm typecheck && pnpm test"
   }
   ```

   `biome check` runs format + lint + import-sorting in one pass; `--write` applies fixes, the
   bare form is the read-only gate. prettier owns only `md`/`yml`/`yaml` (biome owns `json`).

3. Add the dev dependencies (validated versions — caret-ranged):

   ```
   @biomejs/biome ^2.5.1   typescript ^6.0.3   vitest ^4.1.9
   @vitest/coverage-v8 ^4.1.9   @types/node ^26.0.1   prettier ^3.9.3
   ```

4. Ensure the repo's `.gitignore` covers the generated artifacts (the template's already does):

   ```
   dist/
   coverage/
   *.tsbuildinfo
   ```

   biome's `vcs.useIgnoreFile: true` reads `.gitignore`, so it must exist — every repo from the
   template has one.

5. Run `pnpm install && pnpm check` to confirm the gate is green.

6. **Multi-worktree dev:** add `enableGlobalVirtualStore: true` to `pnpm-workspace.yaml`. An engine
   repo carries a real dependency tree (~70 packages), so when it is worked in more than one
   concurrent worktree this makes each worktree's `node_modules` symlink-only into one shared store —
   the first install populates it, later worktree installs are near-instant
   ([pnpm.io/git-worktrees](https://pnpm.io/git-worktrees)). It is a local-dev accelerator only; CI
   (single checkout) is unaffected. Docs/skills repos skip it.

## Deliberately omitted (add only when the repo earns it)

- **turbo** — task caching pays off across many packages/tasks; a single light package does not
  need it. Add when build/test time or package count justifies it.
- **dependency-cruiser** — architecture-boundary enforcement matters once there are layers to
  protect. Add when the package has internal boundaries worth a rule.
- **monorepo project references** — `tsconfig.json` here is single-package. Convert to a root
  `references` graph only if the repo becomes a `packages/*` workspace.

## Notes

- The biome ruleset uses `"linter": { "rules": { "preset": "recommended" } }` (biome 2.5.1; the
  older `"recommended": true` form is deprecated). Keep `$schema` pinned to the installed biome
  version and run `biome migrate` after a biome bump.
- `engines.node` and the pinned `packageManager` come from the spine `package.json` — this overlay
  does not change the toolchain pin. Local dev runs Node 26 (`.nvmrc`); CI runs the `engines.node`
  floor.
