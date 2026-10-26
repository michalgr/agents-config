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
* **No autonomous destructive commands.** Never run commands that discard uncommitted working-tree changes or untracked files (`git reset --hard`, `git restore`, `git checkout -- <file>`, `git clean`) without explicit user instruction.
* **No autonomous remote or history mutations.** Never run commands that publish or rewrite repository history (`git push`, `git rebase`, `git commit --amend`, `gh pr merge`) without explicit user approval.
* **Selective staging over blind adds:** Stage specific modified files by path (`git add <file>`) rather than blind bulk staging (`git add -A`, `git add .`), preventing accidental staging of untracked scratch files, local secrets, or temporary artifacts.
