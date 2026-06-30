# AGENTS.md — <repo>

The contract for working in this repo. **Self-contained:** act on it with only this repo checked
out (including Claude or Codex cloud runs). Don't work from memory — read the doc here that owns
your subject, then plan before non-trivial work.

`<repo>` is <one-line description and where it sits in the agentic-workflow-kit suite>. <If it
owns a shared contract/seam other repos depend on, name it here and treat it as a versioned
boundary — changing its shape is a cross-repo event.>

## Ground truth — read what your task touches

Altitude: `docs/product/` owns _what & why_; `docs/design/` owns _how_. Product is the contract
design reconciles to; where they conflict, name it rather than silently resolving.

| Task                                           | Read            |
| ---------------------------------------------- | --------------- |
| What this is, who it serves, when to use it    | `docs/product/` |
| How it works (mechanics, decisions, contracts) | `docs/design/`  |

<Add a row per major area as the corpus grows; keep this map current and small. Point to source
dirs (skills/, packages/, …) here too once they exist.>

## Gate and conventions

- **`pnpm check`** before claiming any change done; show its output as evidence, don't assert
  success. Keep the gate lightweight for docs/skills repos; grow it as source lands. Where the
  repo produces code, work is test-driven (state the coverage target here).
- **`main`-based:** branch from `main`, PR into it, green `check` required, review conversations
  resolved, squash-merge. Conventional commit subjects (`feat:`/`fix:`/`docs:`/…); no attribution
  footers.
- **Setup & worktrees:** `pnpm dev:setup` prepares a checkout (Node check, Corepack, frozen
  install); `pnpm worktree:new <branch>` creates a worktree and runs setup in it. Worktrees are
  **external siblings** of this checkout — never nested under the repo root (a nested worktree gets
  walked by broad globs and its duplicate `AGENTS.md` misleads agents). If a repo needs no setup
  beyond `pnpm install`, drop `dev:setup`/`worktree:new`; keep the external-sibling rule regardless.
- **No emojis** anywhere. **Immutability** — return new values, don't mutate inputs. Handle errors
  explicitly and validate external input at boundaries. Diagrams in Mermaid, inline. No hardcoded
  secrets — credentials via environment only; redact secrets, tokens, and PII in logs; if you find
  an exposed secret, stop and rotate it.
