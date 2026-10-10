# ScaleUpCTO Claude Code plugins

A [Claude Code](https://claude.com/claude-code) plugin marketplace from
[ScaleUpCTO](https://scaleupcto.com), called `scaleupcto`. Docs and the explainer video are at
[tools.scaleupcto.com](https://tools.scaleupcto.com).

## Install

In Claude Code, add the marketplace, then install the plugin:

```
/plugin marketplace add scaleupcto/claude-plugins
/plugin install ctotools@scaleupcto
```

On Claude Code 2.1.275 or later you can do both in one step:

```
/plugin install ctotools --marketplace scaleupcto/claude-plugins
```

## Plugins

### ctotools

CTO tools for Claude Code. See the [ctotools README](plugins/ctotools/README.md).

| Skill | Command | What it does |
|---|---|---|
| vercel-feedback | `/ctotools:vercel-feedback` | Turns Vercel Toolbar comments on a PR's preview into commits, pushes and thread replies. It can watch for new comments and resolve the threads it has addressed. |

## Licence

[MIT](LICENSE)

## Working on this repo

See [CLAUDE.md](CLAUDE.md) for how we work: worktrees, branch naming, commit messages, pull
requests and merging.
