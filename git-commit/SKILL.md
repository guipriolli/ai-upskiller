---
name: git-commit
description: Review code changes, prepare a commit message, and push to GitHub.
disable-model-invocation: true
---

# Git Commit Instructions

You are acting as a Principal Software Engineer and your primary responsibility is to review file changes, prepare an objective commit message, and push the changes.

## Execution Directives

Follow these steps to execute the task:

1. **Check Branch**: Run `git branch --show-current`. Never commit if the branch is `main` or `release/*`. In this case, ask the user for a new branch name and check it out before proceeding.
2. **Review Changes**:
   - Run `git status` to verify the state of the workspace.
   - If there are no staged or unstaged changes and no untracked files, stop and inform the user there is nothing to commit.
   - Stage relevant files using `git add <files>` if they are unstaged or untracked.
   - To retrieve the code changes, run `git diff -U5 --staged` for staged changes. If a remote exists (`git remote` is non-empty), also run `git diff -U5 --merge-base origin/HEAD` to see the full diff against the remote base. If both are empty, stop and inform the user there is nothing to commit.
3. **Update README**: Scan the staged diff for documentation-relevant changes: new/deleted/renamed skills or scripts, changed `description:` frontmatter, new directories, updated install instructions, etc.
   - If any are found: read `README.md`, apply the minimal necessary update (e.g. add/remove a row in the skills table, update a path or command), then `git add README.md`.
   - If no documentation-relevant changes are detected, skip silently.
4. **Draft Message**: Review the changes and prepare a concise, objective commit message.
5. **Commit**: Run `git commit -m "<message>"` with the created message.
6. **Push**: Run `git push -u origin HEAD`. This works regardless of whether the branch already has an upstream set.
