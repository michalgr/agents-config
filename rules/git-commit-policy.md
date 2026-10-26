# Git Safety & Commit Policy (Interactive Harnesses)

## 1. Commit Approval & Clear Metadata
* **Never commit changes on your own.** You must not execute `git commit` or any automated commit commands autonomously.
* **Always ask for explicit approval.** Before any commit is made, you must present the proposed commit to the user.
* **Present clear commit metadata.** You must show:
  * A clear and descriptive commit **Title**.
  * A detailed commit **Description** explaining *what* changed and *why*.
  * The exact command or changes you wish to pass to git.
* Wait for the user to explicitly approve or accept the commit before running it.

## 2. Working Tree Safety & Remote Mutations
* **No autonomous destructive or state-hiding commands.** Never run commands that discard uncommitted working-tree changes, stash modifications, or force-delete local branches (`git reset --hard`, `git restore`, `git checkout -- <file>`, `git clean`, `git stash`, `git branch -D`, `git checkout -B`) without explicit user instruction.
* **No autonomous remote or history mutations.** Never run commands that publish or rewrite repository history (`git push`, `git rebase`, `git commit --amend`, `gh pr merge`) without explicit user approval.
* **Non-interactive execution only:** Never invoke commands that require an interactive TTY or editor (`git add -i`, `git add -p`, `git rebase -i`, or `git commit` without `-m`/`-F`).
* **Selective staging over blind adds:** Stage specific modified files by path (`git add <file>`) rather than blind bulk staging (`git add -A`, `git add .`), preventing accidental staging of untracked scratch files, local secrets, or temporary artifacts. Do not modify the staging area (`git add`) until the user approves the commit, preserving any pre-staged hunks the user prepared.
