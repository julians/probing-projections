# Probing Projections

Interactive MDS visualisation (Julian Stahnke’s bachelor thesis, 2015). Everything runs in the
browser; the app lives in `web/` (CoffeeScript 2, Handlebars, jQuery, d3 v3, built with Vite).

```sh
cd web
pnpm install
pnpm dev      # localhost:9000
pnpm build    # → web/dist
```

## Project tracking

Plans, issues and history live in `docs/`. Read `docs/PLAN.md`, the open issues and the top of
`docs/agent-log.md` before bigger tasks.

- **`docs/PLAN.md`**: the modernisation roadmap, phase by phase, linking to issues.
- **`docs/issues/open/`** and **`docs/issues/done/`**: one Markdown file per issue, named
  `NNN-short-slug.md`. Numbers are never reused or changed, so "see 014" stays valid. Take the
  next free number across both folders.
- Status is the folder. When an issue is finished, fill in its *Done* section (commits, what
  actually happened) and `git mv` it to `done/`. Update the checkboxes in `PLAN.md`.
- Issue files start with `# NNN Title` and a `Phase:` line (a phase from `PLAN.md`, `bug` or
  `idea`), followed by the sections *Why*, *Tasks* (checkboxes), *Notes* and *Done*. Keep them
  short. No frontmatter, no status fields.
- New problems found along the way get an issue instead of a silent fix or a forgotten TODO.

## Agent Log

After a non-trivial task (several files, a debugging session, a decision), append an entry to
**`docs/agent-log.md`**. It is a quick check for humans and a starting point for the next agent;
read it before bigger tasks.

- Newest entry on top, as `## YYYY-MM-DD — <short title>`.
- Below it a short bullet list: what you did, what you found out, and what didn’t work (and why).
  Mention decisions together with their reasons.
- Keep it concise: ~3–8 bullets, one line each, link files and issues instead of explaining
  them. No code dumps, no repeating the diff. Skip trivial tasks (typos, one-line fixes, pure
  questions).

## Working conventions

- Split larger changes into logical commits that each make sense on their own.
- Verify changes in the browser (`pnpm dev`), not just with `pnpm build`. There are no automated
  tests yet (see issues 011 and 012).
