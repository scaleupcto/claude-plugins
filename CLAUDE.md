# claude-plugins

Scale Up CTO's Claude Code plugin marketplace, `scaleupcto`. It holds one plugin,
`ctotools`, in `plugins/ctotools/`. Validate changes with `claude plugin validate --strict .`
and `claude plugin validate --strict plugins/ctotools`.

- **GitHub**: [scaleupcto/claude-plugins](https://github.com/scaleupcto/claude-plugins) (public)
- **Vercel**: project `claude-skills` in the `scale-up-cto` team. It serves the static docs
  and marketing site in `site/` (configured in `vercel.json`, no build step) at
  [tools.scaleupcto.com](https://tools.scaleupcto.com).

## How we work

- **Worktrees**: all work is done in git worktrees under `.claude/worktrees/<short-name>`,
  never directly in the main checkout, which stays on `main`.
- **Branches**: prefixed with `scaleupcto/`, e.g. `scaleupcto/some-feature`.
- **Commits**: semantic (Conventional Commits) messages, `type(scope): summary`, with
  type one of `feat`, `fix`, `docs`, `chore`, `refactor`, `test`, `ci`, `build`, `perf`
  or `style`.
- **Pull requests**: each piece of work goes up as a PR to `main`.
- **Merging**: when the user asks you to merge a PR, run these from the main checkout:
  1. `gh pr merge <number> --squash`. Don't pass `--delete-branch`: it fails while a
     worktree still has the branch checked out.
  2. `git worktree remove .claude/worktrees/<short-name>`
  3. `git branch -D scaleupcto/<short-name>`
  4. `git push origin --delete scaleupcto/<short-name>`
  5. Leave the user on a freshly pulled `main` in the main checkout:
     `git checkout main && git pull --prune`
