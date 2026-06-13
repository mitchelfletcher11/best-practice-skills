# Setup — best-practice-skills

Three machine-specific pieces: the **trigger script**, the **settings hook**, and
(optional) the **auto-commit to *your own* private dotfiles repo**.

## 1. Install the skill + script

See the [README](README.md) install block — it places:
- `~/.claude/skills/best-practice-skills/SKILL.md`
- `~/.claude/scripts/check-best-practice.sh` (make it executable: `chmod +x`)

## 2. Wire the prompt-submit hook

Merge the `UserPromptSubmit` hook from **`settings.snippet.json`** into your
`~/.claude/settings.json` (under `hooks`):

```json
{
  "hooks": {
    "UserPromptSubmit": [
      { "hooks": [ { "type": "command", "command": "bash ~/.claude/scripts/check-best-practice.sh" } ] }
    ]
  }
}
```

If you already have `UserPromptSubmit` hooks, append this entry. On every prompt
the script checks `~/.claude/skills/best-practice-skills/last-check.md`; if >24h
have passed it prints `Before addressing this message, run: /best-practice-skills`,
which Claude runs. `last-check.md` is created automatically.

## 3. (Optional) Auto-commit to your own private dotfiles repo

The skill's final step commits and pushes `~/.claude/` changes to a **private**
git remote, so your skill edits are versioned. This is **opt-in** — it only runs
if `~/.claude` is a git repo with an `origin` remote. To enable it on your
machine:

```bash
# make ~/.claude a git repo pointing at YOUR OWN private dotfiles repo
cd ~/.claude
git init
git remote add origin https://github.com/<your-user>/<your-private-dotfiles>.git

# store a GitHub token (repo scope) that can push to it
printf '%s' 'ghp_your_token_here' > ~/.claude/github-token
chmod 600 ~/.claude/github-token

# IMPORTANT: gitignore secrets so they're never committed
printf '%s\n' 'github-token' '.credentials.json' '*.jsonl' >> ~/.claude/.gitignore
```

The skill pushes with:
`git -C ~/.claude push "https://$(cat ~/.claude/github-token)@<your-origin-host/path>" main`
— the remote is read from *your* `git remote get-url origin`, so nothing is
hard-coded to the author's account. If you don't want auto-commit, simply don't
make `~/.claude` a git repo (the step no-ops safely).

> **Never** commit `github-token` or any credential file — keep them gitignored.
