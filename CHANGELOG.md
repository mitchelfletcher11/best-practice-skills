# Changelog

## v1.0.0 — 2026-06-13
- Initial public release.
- Daily (24h-gated) automatic review of skills against their `observations.md`
  outcomes, session learnings, and skill-authoring best practices, proposed as
  numbered changes; ensures each skill has an observation-writing step.
- Bundled `check-best-practice.sh` trigger + `settings.snippet.json` hook.
- Optional auto-commit of `~/.claude/` to *your own* private dotfiles repo
  (remote derived from your `git remote`, not hard-coded) — documented in SETUP.md.
- Portable: all paths use `$HOME`/`~`.
