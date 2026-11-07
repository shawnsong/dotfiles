# dotfiles

## Standalone commands (macOS and Linux)

```sh
cd ~/work/dotfiles  # the repository may live anywhere
bash ./install-bin.sh

# ~/.local/bin must be on PATH; add this to your shell config if needed:
export PATH="$HOME/.local/bin:$PATH"

# Run from the primary checkout, outside the worktree being removed:
cd /path/to/your/project
git wt-clean feature/example
```

`install-bin.sh` links `~/.local/bin/git-wt-clean` to this repository's
`bin/git-wt-clean`. It requires Git and Python 3.9+; no Python packages, sudo,
GitHub authentication, or shell aliases are needed. It does not run the full
Linux installer or change tmux, zsh, or editor settings. Keep the repository
in place: updating its script updates the installed command automatically.

The installer is safe to rerun. A standalone copy with identical contents is
preserved as `~/.local/bin/git-wt-clean.pre-dotfiles` before linking. Different
existing files, unrelated/broken symlinks, and existing backup conflicts are
rejected rather than overwritten.

`git wt-clean <local-branch>` finds the matching linked worktree, shows what
will be removed, and asks for `y` confirmation. It then removes the worktree
and deletes the local branch with `git branch -D`. If the worktree is already
gone, it can delete just the local branch.

- Protects `main`, `master`, and the primary checkout even on a feature branch.
- Stops on tracked changes, ordinary untracked files, locked worktrees, or when
  run inside the target worktree; it never force-removes a worktree.
- **Ignored files and directories, including a worktree's venv, are also deleted
  after confirmation.** Preserve credentials, datasets, and other needed files
  before using it. Empty input or EOF cancels without deletion.
- **It does not check whether a PR is merged.** Use only for merged branches or
  branches whose commits you intentionally want to discard. It does not merge
  PRs, delete remote branches, or prune other worktrees.

## Tests

Offline tests use the Python standard library, Bash, and Git. They create only
disposable repositories and home directories; no GitHub access is needed.

```sh
python3 -B -m unittest discover -s tests -v
```
