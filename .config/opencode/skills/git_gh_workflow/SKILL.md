---
name: git-gh-workflow
description: Guidelines and best practices for Git and GitHub CLI (gh) operations, including committing, branching, creating PRs, checking out PRs, and reviewing issues.
triggers:
  - git
  - gh
  - commit
  - pr
  - push
  - pull
  - github
  - merge
  - branch
---

# Git and GitHub CLI (gh) Workflow Guidelines

This skill defines the division of labor between `git` and `gh` (GitHub CLI) and specifies rules for repo operations, code staging, PR creation, and repository tracking.

## 1. The Division of Labor: When to Use "git" vs "gh"

* **Use `git` for local operations such as commits, branching, diffs, and managing local history.**
  * *Tracking Changes:* Staging files (`git add`) and recording commits (`git commit`).
  * *Branching:* Creating, switching, and merging branches (`git branch`, `git checkout`, `git switch`, `git merge`).
  * *Synchronizing:* Pushing local changes to a remote repository or pulling updates from others (`git push`, `git pull`).
* **Use `gh` (GitHub CLI) for remote repository management: interacting with GitHub, such as authentication, creating repositories, managing pull requests (PRs), and checking issue status.**
  * *Interacting with GitHub:* Eliminates browser context-switching by handling PRs, issues, releases, actions, and forks directly from the terminal.

---

## 2. Best Practice Guidelines for "gh" Operations

### Pull Request Management
* "When creating a PR with `gh pr create`, ensure the title follows the conventional commit format and includes a link to the relevant issue."
* "Never auto-merge PRs or push directly to protected branches without human confirmation. The PR process serves as a critical checkpoint for human review."
* "Use `gh pr list` or `gh pr view` to check feedback or status checks before pushing changes."

### Checking Out Pull Requests
* "Use `gh pr checkout <number>`, which automatically fetches the PR branch from the remote repository and switches to it, saving you from manually configuring remote references."

### Querying Issues
* "Use `gh issue list` and `gh issue view` to identify tasks, filter issues, and stay updated on the work context without opening a browser."

### Handling Forks & Clones
* "Use `gh repo fork <owner/repo> --clone=true`. This single command creates the fork on GitHub and automatically clones it to your local machine, setting up the 'upstream' remote automatically."

### Debugging CI/CD Workflows
* "If CI/CD fails, use `gh run list` and `gh run view --log-failed` to debug before suggesting a fix."

---

## 3. Security & Governance Guidelines

* **"Show Before Execute":** Display the exact `gh` command planned to run before executing it, allowing the user to intercept and verify the action.
* **Ambient Authority:** Be mindful that the agent inherits local user credentials (SSH keys, `gh` tokens). Prefer scoped tokens where applicable.
* **Primitive Blocking:** Avoid bypasses of remote rules. Always respect hookflows, branch protections, and forbidden commands.
