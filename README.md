# best-practice-skills — Claude Code skill

A daily, automatic review of your **skills** — it sweeps every skill that has new
`observations.md` entries (or was used this session), checks each against its
recorded outcomes and current skill-authoring best practices, and proposes
concrete numbered changes you approve or skip. Also ensures every skill has an
observation-writing step.

Runs at most **once per 24 hours**, triggered automatically by a prompt-submit
hook.

## Install

```bash
# 1. the skill
mkdir -p ~/.claude/skills/best-practice-skills
curl -sf https://raw.githubusercontent.com/mitchelfletcher11/best-practice-skills/main/SKILL.md \
  -o ~/.claude/skills/best-practice-skills/SKILL.md

# 2. the trigger script
mkdir -p ~/.claude/scripts
curl -sf https://raw.githubusercontent.com/mitchelfletcher11/best-practice-skills/main/check-best-practice.sh \
  -o ~/.claude/scripts/check-best-practice.sh
chmod +x ~/.claude/scripts/check-best-practice.sh
```

Then add the hook from **[SETUP.md](SETUP.md)** to `~/.claude/settings.json`, and
(optionally) configure the auto-commit step. Those are the machine-specific
pieces — once set up, prompting Claude reproduces the author's exact behaviour.

> Pairs with **best-practice-claude** (reviews your `CLAUDE.md` the same way).
> They share one hook + one script — install either or both.
