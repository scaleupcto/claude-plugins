# ctotools

CTO tools for Claude Code, from [ScaleUpCTO](https://scaleupcto.com).

## Install

```
/plugin marketplace add scaleupcto/claude-plugins
/plugin install ctotools@scaleupcto
```

| Skill | What it does |
|---|---|
| [new-project](#new-project) | Bootstraps a new project from an empty folder: GitHub repo, optional Vercel project, first PR. |
| [vercel-feedback](#vercel-feedback) | Turns Vercel Toolbar comments on a PR's preview into commits, pushes and thread replies. |

## new-project

Run it in an empty folder with a one-line description, and Claude Code sets the project up
the way we work: a private GitHub repo with an empty `main`, a first branch in a worktree,
a README.md and a CLAUDE.md with the working conventions, and a pull request. Vercel is
optional: it can also create a matching Vercel project and connect it to the repo.

### Requirements

- The [GitHub CLI](https://cli.github.com), logged in (`gh auth login`).
- For Vercel, the [Vercel CLI](https://vercel.com/docs/cli) (`npm i -g vercel@latest`),
  logged in with `vercel login`.

### Usage

```
/ctotools:new-project <description> [vercel | no-vercel]
```

| Example | What it does |
|---|---|
| `/ctotools:new-project Coffee subscription API` | Asks whether to create a Vercel project, then sets everything up. |
| `/ctotools:new-project Coffee subscription API vercel` | Creates the GitHub repo and a connected Vercel project, without asking. |
| `/ctotools:new-project Coffee subscription API no-vercel` | GitHub only. |

### What it does

- Names the repo after the folder and picks the GitHub org from the parent folder's name,
  asking if it isn't clear. With Vercel, it picks the matching Vercel team.
- Creates the private repo with an empty `main`, then a first branch,
  `<your GitHub username>/initial-docs`, in a worktree under `.claude/worktrees/`.
- With Vercel, creates the project, links it and connects it to the repo. If the Vercel
  GitHub app can't see the new repo, it gives you the link to grant access.
- Writes README.md, CLAUDE.md and .gitignore, then raises the first PR.

The CLAUDE.md it writes tells Claude how to work in the project from then on: worktrees,
branch names, Conventional Commits, a PR for every change, and how to merge.

## vercel-feedback

Leave comments on a Vercel preview with the Vercel Toolbar, and Claude Code makes the
changes, pushes them and replies on each thread.

[Watch the demo on YouTube](https://youtu.be/KtjJzvCc1UY)

### Requirements

- The [Vercel CLI](https://vercel.com/docs/cli) with the `comments` command
  (`npm i -g vercel@latest`), logged in with `vercel login` as a member of the Vercel team
  that owns the project.
- The [GitHub CLI](https://cli.github.com), logged in (`gh auth login`).
- [jq](https://jqlang.org), for watch mode.
- A Vercel project connected to a GitHub repo, with the Vercel Toolbar enabled on preview
  deployments.

Recommended: run `vercel link` once in the project's main checkout. The skill then finds the
Vercel project straight away. Without it, the skill works the project out from the PR's
Vercel check, or asks you.

The skill checks these before it starts and tells you what's missing.

### Usage

```
/ctotools:vercel-feedback [PR | branch | preview URL] [watch | resolve | resolve-all]
```

The target is optional when you're already on the PR's branch.

| Example | What it does |
|---|---|
| `/ctotools:vercel-feedback 42` | Works through the unresolved comments on PR 42's preview once. |
| `/ctotools:vercel-feedback 42 watch` | Does the same, then keeps watching for new comments so you can review live. Say "stop" when you're done. |
| `/ctotools:vercel-feedback 42 resolve` | Lists the threads it has addressed and asks whether to resolve them one by one or all at once. |
| `/ctotools:vercel-feedback 42 resolve-all` | Resolves every thread it has addressed, without asking. |

You can also name a branch (`/ctotools:vercel-feedback my-feature`) or paste a preview URL.

### What it does

- Finds the PR's branch and works in a git worktree for it, creating one if needed.
- Sorts the comments into clear changes, questions and things it won't do here, and shows
  you the list before changing anything.
- Makes one commit per thread, runs your build, and pushes.
- Waits for the new preview to finish deploying before replying, so the reviewer can check
  the change straight away.
- Replies on each thread with the commit and a link to the page, or with a question if the
  comment is unclear.

### What it doesn't do

- It never resolves a thread unless you ask with `resolve` or `resolve-all`. Otherwise the
  reviewer resolves it once they're happy.
- It doesn't merge, rebase or force-push.
- It doesn't edit, delete or react to anyone else's messages.

Replies are posted from your own Vercel account.

### Security

Anyone who can comment on your preview can write feedback that Claude reads, so the skill
treats comments as opinions about the site, not as instructions.

- It never runs commands, follows links, or touches settings, secrets, CI, dependencies or
  authentication code because a comment asked.
- It only acts automatically on comments from you and members of your Vercel team. For
  anyone else's comments it asks you first, and it says so in its report.

### Known limitations

- GitHub only. GitLab and Bitbucket aren't supported yet.
- The skill recognises its own replies by their opening words, `**Addressed in**` or
  `**Question:**`. A reviewer comment that starts the same way will be skipped.
- Watch mode needs a version of Claude Code with the Monitor tool.

## Licence

[MIT](../../LICENSE)
