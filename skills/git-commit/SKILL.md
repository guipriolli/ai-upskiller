---
name: git-commit
description: Review code changes, prepare a commit message with user approval, and optionally push to GitHub.
disable-model-invocation: true
---

# `git-commit` skill instructions

Stage, review, and commit code changes with an optional push to the remote. Follow these steps
strictly and stop at any explicit halt condition.

## 1. Validate branch

Run `git branch --show-current`. If the branch is `main`, `master` or matches `release/*`, **stop** and ask
the user for a new branch name. Check out the new branch before continuing.

## 2. Identify changes

1. Run `git status` (never use `-uall`).
2. If there are no staged changes, no unstaged changes, and no untracked files, **stop** and inform
   the user there is nothing to commit.

## 3. Stage files

1. Present the list of unstaged and untracked files to the user.
2. Ask which files to stage — offer "all modified/untracked" as a shortcut.
3. **Never** stage files that likely contain secrets (`.env`, `credentials.*`, `*.pem`, etc.). Warn
   the user if they request it.
4. Run `git add <files>` for the approved set.

## 4. Review diff

1. Run `git diff -U5 --staged` to retrieve the staged changes.
2. If a remote exists (`git remote` is non-empty), also run
   `git diff -U5 --merge-base origin/HEAD` to show the full diff against the remote base. If
   `origin/HEAD` is not set, fall back to the default branch (`origin/main` or `origin/master`).
3. If both diffs are empty, **stop** — nothing to commit.

## 5. Update README (conditional)

Scan the staged diff for documentation-relevant changes.

- If any are found: read `README.md`, apply the minimal necessary update (e.g., add/remove a table
  row, fix a path), stage it with `git add README.md`, and include the README change in the summary
  shown to the user in the next step.
- If none are detected, skip silently.

## 6. Draft commit message and confirm

1. Compose a concise, objective commit message. Use a short subject line (≤ 72 chars). Add a body
   only when the "why" is not obvious from the subject.
2. Present the full message to the user along with the list of staged files.
3. **Wait for explicit approval.** Accept edits, a full rewrite, or confirmation before proceeding.

## 7. Commit

Run `git commit` using a heredoc to preserve formatting:

```
git commit -m "$(cat <<'EOF'
<subject>

<optional body>
EOF
)"
```

If the commit fails (e.g., a pre-commit hook), report the error and **stop**. Do not retry
automatically.

## 8. Push (optional)

Ask the user whether to push. If they confirm, run `git push -u origin HEAD`. If the push fails,
report the error and suggest possible causes (no remote, authentication, rejected push). Do not
retry automatically.
