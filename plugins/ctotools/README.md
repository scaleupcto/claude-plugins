# ctotools

CTO tools for Claude Code, from [ScaleUpCTO](https://scaleupcto.com).

## vercel-feedback

Leave comments on a Vercel preview with the Vercel Toolbar, and Claude Code makes the
changes, pushes them and replies on each thread.

[Watch the demo on YouTube](https://youtu.be/KtjJzvCc1UY)

### Install

```
/plugin marketplace add scaleupcto/claude-plugins
/plugin install ctotools@scaleupcto
```

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
