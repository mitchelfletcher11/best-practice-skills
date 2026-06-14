---
name: best-practice-skills
description: >
  Daily global sweep that reviews all skills with unreviewed observations or active in the current
  session. Reads each skill's observations.md for entries since last-reviewed, proposes specific
  changes as a numbered list with emoji status, and adds observation-writing steps to skills that
  don't have them. Triggered automatically after the first skill completes in any session, gated
  to once per 24 hours globally.
allowed-tools: Read Write Bash
---

# Best Practice: Skills

Daily global sweep that reviews skills against accumulated observations and session learnings.

---

## Step 0 — Preflight: self-setup (first run)

This skill is meant to **auto-run once per 24h** via a `UserPromptSubmit` hook that
calls a small script. On a fresh install that hook + script don't exist, so nothing
auto-triggers. Detect it and offer to set it up — but **never install executable
code without an explicit yes.**

**1. Detect** (honour a permanent-decline marker):
```bash
if [ -f ~/.claude/skills/best-practice-skills/.no-autorun ]; then echo SKIP
elif [ -x ~/.claude/scripts/check-best-practice.sh ] && grep -q check-best-practice ~/.claude/settings.json 2>/dev/null; then echo INSTALLED
else echo OFFER; fi
```
- `INSTALLED` or `SKIP` → go straight to Step 1.
- `OFFER` → continue.

**2. Warn + ask (REQUIRED — never install on an implied yes).** Show the user exactly this and wait:

> ⚠️ **Auto-run setup installs executable code on your machine.** To run daily on its own, I would:
> - **download a script** to `~/.claude/scripts/check-best-practice.sh` (from this skill's public repo) and make it **executable** — it only reads a local timestamp and, once per 24h, prints a reminder to run this skill; it makes **no network calls** and sends nothing anywhere;
> - add a **`UserPromptSubmit` hook** to `~/.claude/settings.json` that runs that script **on every prompt**.
>
> **Install the auto-run script + hook now? (yes / no)** — on *no*, you can always run `/best-practice-skills` manually.

**3. On an explicit `yes` only:**
```bash
mkdir -p ~/.claude/scripts
curl -sf https://raw.githubusercontent.com/mitchelfletcher11/best-practice-skills/main/check-best-practice.sh \
  -o ~/.claude/scripts/check-best-practice.sh
chmod +x ~/.claude/scripts/check-best-practice.sh
```
Then **show the user this exact hook JSON** and, on their confirmation, merge it into `~/.claude/settings.json` (append to `hooks.UserPromptSubmit` if it exists, else create it):
```json
{ "hooks": { "UserPromptSubmit": [ { "hooks": [ { "type": "command", "command": "bash ~/.claude/scripts/check-best-practice.sh" } ] } ] } }
```

**4. On `no`:** `touch ~/.claude/skills/best-practice-skills/.no-autorun` (so it won't ask again) and say: *"Got it — run `/best-practice-skills` manually anytime."*

**5. Optional — auto-commit (a separate opt-in):**
```bash
git -C ~/.claude rev-parse --is-inside-work-tree 2>/dev/null || echo NOT_GIT
```
If `NOT_GIT`, mention **once**: *"Optional: I can version your `~/.claude` to a **private** repo so your skill edits sync across machines. It writes a git remote + a token file. Set it up? (optional — off by default.)"* On *yes*, warn that it writes a token file, then set it up handling the **zero-state** (a first-time user may have no repo yet — never assume one):
- `git -C ~/.claude init -b main`.
- **Does their private repo exist?** If yes, add it as the remote. If **not** (the first-time case), create it — `gh repo create <name> --private --source ~/.claude --remote origin` when `gh` is authenticated, else point them to <https://github.com/new> (set **Private**) and add the remote. If they have no GitHub account at all, point to <https://github.com/signup> first.
- Write the token (`chmod 600`) — create one at <https://github.com/settings/tokens> (scope `repo`) — and gitignore the secrets. (Or reuse the `git-commit-private` skill, which does exactly this bootstrap.)

On *no*, continue silently.

---

## Step 1 — Check gate

Read `~/.claude/skills/best-practice-skills/last-check.md`.

- If the file does not exist, or more than 24 hours have elapsed since the stored timestamp: proceed to Step 2.
- If less than 24 hours have elapsed: print "Last swept [TIMESTAMP] — [N] hours ago. No sweep needed." and stop.

---

## Step 2 — Identify skills to sweep

Run this bash command to find every skill with unreviewed observations. This is mandatory — do not rely on memory or session context alone:

```bash
for skill_dir in "$HOME"/.claude/skills/*/; do
  skill=$(basename "$skill_dir")
  obs="$skill_dir/observations.md"
  if [ -f "$obs" ]; then
    lr=$(grep "^last-reviewed:" "$obs" | head -1 | awk '{print $2}')
    latest=$(grep "^## 20" "$obs" | head -1 | awk '{print $2}')
    if [ -n "$lr" ] && [ -n "$latest" ] && [[ "$latest" > "$lr" ]]; then
      echo "UNREVIEWED: $skill | last-reviewed=$lr | latest=$latest"
    fi
  fi
done
```

A skill qualifies for the sweep if either of the following are true:

- It appears in the `UNREVIEWED` output above
- It was active in the current session (its content appeared in a skill system-reminder, or it was invoked)

`best-practice-claude` and `best-practice-skills` qualify under the same conditions as any other skill — there is no exclusion.

If no skills qualify: proceed directly to Step 6.

---

## Step 3 — Read each skill

For each skill in the sweep list:
- Read `~/.claude/skills/[skill-name]/SKILL.md` in full
- If `~/.claude/skills/[skill-name]/observations.md` exists: read all entries dated after the `last-reviewed` frontmatter timestamp. Ignore entries at or before that timestamp.

Also read:
- `~/.claude/CLAUDE.md`
- The project CLAUDE.md if it exists
- `~/.claude/skills/skill-creator/SKILL.md` — for skill authoring guidelines

---

## Step 4 — Review each skill against four sources

For each skill, assess against:

1. **Unreviewed observations** — entries in `observations.md` dated after `last-reviewed`. These are the primary input: real recorded outcomes from actual skill runs.
2. **Session learnings** — what was discovered or found lacking in this conversation? Did the skill behave unexpectedly? Did a workaround reveal a gap?
3. **Known best practices** — do the skill's instructions align with the skill-creator guidelines and patterns used across the current skill ecosystem?
4. **Best Practice: Claude findings** — if `/best-practice-claude` ran this session, apply any Anthropic changes that affect this skill's referenced models, tools, or API patterns.
5. **Observation-writing step** — does this skill's SKILL.md end with a Final Step instructing it to write a timestamped one-line entry to its `observations.md`? If not, this is always a proposed addition.

---

## Step 5 — Output

Print to chat:

```
## Best Practice: Skills — [CURRENT DATE]
Last swept: [PREVIOUS TIMESTAMP] ([N] hours/days ago)

Skills swept: [N] · Changes proposed: [N]

1. 🔄 [skill-name] — [section] — [specific text to change]
   Reason: [why, grounded in observation, session learning, or best practice]

2. ➕ [skill-name] — Final Step — Add observation-writing step
   Reason: skill has no mechanism to record outcomes for future sweeps

3. ✅ [skill-name] — no change needed
   Reason: ...

4. ❌ [skill-name] — [section] — [specific text to remove]
   Reason: ...
```

Emoji key: ✅ Keep · 🔄 Update · ➕ Add · ❌ Remove

After the numbered list ask: **"Apply all, apply selected (list numbers), or skip?"**

---

## Step 6 — Apply approved changes

For each approved item: apply the exact proposed change to the skill file using the Write tool. Confirm each change after applying.

**Observation-writing step format** — when adding to a skill's SKILL.md, append this as the final section, substituting the skill's actual directory name for `[skill-name]`:

```
## Final Step — Write observation

Append a timestamped entry to `~/.claude/skills/[skill-name]/observations.md`:

\`\`\`markdown
## [ISO 8601 timestamp]
[One sentence: what worked, what was unclear, any workaround needed, output quality]
\`\`\`

If `observations.md` does not exist, create it with this frontmatter first:

\`\`\`markdown
---
last-reviewed: 1970-01-01T00:00:00Z
---
\`\`\`
```

---

## Step 7 — Update timestamps

After all changes are applied (or skipped):

1. For each skill that was swept: update the `last-reviewed` timestamp in `~/.claude/skills/[skill-name]/observations.md` to the current ISO 8601 timestamp. If the file does not exist, create it with frontmatter only:
   ```markdown
   ---
   last-reviewed: [CURRENT ISO 8601 TIMESTAMP]
   ---
   ```
2. Write the current ISO 8601 timestamp to `~/.claude/skills/best-practice-skills/last-check.md`.

---

## Final Step — Write observation

Append a timestamped entry to `~/.claude/skills/best-practice-skills/observations.md`:

```markdown
## [ISO 8601 timestamp]
[One sentence: how many skills swept, how many proposals made, whether any were applied, any sweep issues]
```

If `observations.md` does not exist, create it with this frontmatter first:

```markdown
---
last-reviewed: 1970-01-01T00:00:00Z
---
```

---

## Auto-commit — Push changes to remote

After the observation is written, commit and push all changes to `~/.claude/` to the private remote repository.

Run the following via the Bash tool:

**1. Check git is initialised:**
```bash
git -C ~/.claude rev-parse --is-inside-work-tree 2>/dev/null || echo "NOT_GIT"
```
If the output is `NOT_GIT`: skip the remaining steps silently.

**2. Check for changes:**
```bash
git -C ~/.claude status --porcelain
```
If output is empty: skip the remaining steps silently.

**3. Stage, commit, and push:**
```bash
DATE=$(date -u +%Y-%m-%d)
git -C ~/.claude add -A
git -C ~/.claude commit -m "auto: ${DATE} — skills sweep"
# Push to whatever private remote ~/.claude/origin points at, authenticating
# with the token in ~/.claude/github-token (see SETUP.md).
REMOTE=$(git -C ~/.claude remote get-url origin)
git -C ~/.claude push "https://$(cat ~/.claude/github-token)@${REMOTE#https://}" main
```

If the push fails, the local commit is retained — do not retry.
