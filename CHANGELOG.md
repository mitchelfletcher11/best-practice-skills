# Changelog

## v1.2.0 — 2026-06-14
Optional auto-commit now handles the **zero-state**: creates the private repo (gh / web / signup) instead of assuming one already exists.

## v1.1.0 — 2026-06-14
- Self-bootstrapping **Step 0 Preflight**: on first run the skill detects whether its
  auto-run script + `UserPromptSubmit` hook are installed and offers to set them up —
  with a security warning and explicit confirmation before downloading the script or
  wiring the hook. It never installs executable code silently.
- The optional `~/.claude` auto-commit is now a clearly-flagged, separate opt-in.

## v1.0.0 — 2026-06-13
- Initial public release.
- Daily (24h-gated) automatic review of skills against their `observations.md`
  outcomes, session learnings, and skill-authoring best practices, proposed as
  numbered changes; ensures each skill has an observation-writing step.
- Bundled `check-best-practice.sh` trigger + `settings.snippet.json` hook.
- Optional auto-commit of `~/.claude/` to *your own* private dotfiles repo
  (remote derived from your `git remote`, not hard-coded) — documented in SETUP.md.
- Portable: all paths use `$HOME`/`~`.
