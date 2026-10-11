---
name: new-project
description: Bootstrap a new project in the current empty directory. Creates a private GitHub repo in the right org, optionally a matching Vercel project connected to it, and a first PR from a worktree with a README.md and a CLAUDE.md that set out how we work. Use when the user runs /ctotools:new-project or asks to set up, initialise or bootstrap a new project or repo.
argument-hint: "<description of the project> [vercel | no-vercel]"
---

# New project

Bootstrap a new project in the current directory. `$ARGUMENTS` is the project
description. If it's empty, ask the user what the project does before you start.

## Vercel is optional

Work out whether to create a Vercel project before doing anything else:

- The last word of `$ARGUMENTS` is `no-vercel`: skip Vercel.
- The last word is `vercel`: create the Vercel project.
- Either way, that last word isn't part of the description. A description that merely
  mentions Vercel ("a dashboard for our Vercel usage") doesn't count.
- Neither: ask with AskUserQuestion whether to create a Vercel project too, with
  "Create a Vercel project" and "GitHub only" as the options. If the session isn't
  interactive, don't create one, and say in the report how to add it later
  (step 4's commands).

Everything below marked **(Vercel)** applies only when you're creating the Vercel project.

## 0. Preflight

Check the tools before doing anything else. If a check fails, stop and say what's missing
and how to fix it. Run the checks together and report every failure at once.

- **Git**: `git --version` must work.
- **GitHub CLI**: `gh auth status` must pass. If `gh` is missing, point the user to
  <https://cli.github.com>. If it isn't logged in, ask them to run `gh auth login`.
- **(Vercel) Vercel CLI**: `vercel whoami` must show a logged-in user. If `vercel` is
  missing, ask the user to run `npm i -g vercel@latest`. If it isn't logged in, ask them to
  run `vercel login`. If they'd rather not, offer to carry on without Vercel.

## 1. Work out the names

- **Repo name**: the basename of the current directory.
- **GitHub org**: the parent directory's name, matched against `gh org list`. If nothing
  matches clearly, ask. Use the user's personal account only if they say so.
- **GitHub username**: `gh api user --jq .login`. It's the branch prefix.
- **(Vercel) Vercel team**: from `vercel teams ls`, the team whose slug or name matches the
  org. Ask if it's ambiguous.

Check that the directory is empty, or holds nothing worth keeping, and that it isn't
already a git repo. Check that `<org>/<repo>` doesn't already exist on GitHub. Look at
sibling directories' `CLAUDE.md` files for conventions you can reuse.

## 2. Create the repo with an empty main

```bash
git init -b main
git commit --allow-empty -m "chore: initial commit"
gh repo create <org>/<repo> --private --description "<one-line summary>" --source . --remote origin --push
```

## 3. Create the first branch in a worktree

```bash
git worktree add .claude/worktrees/initial-docs -b <username>/initial-docs
```

Do all the remaining file work inside that worktree.

## 4. (Vercel) Create the Vercel project

Skip this step without Vercel.

```bash
vercel project add <repo> --scope <team>
vercel link --yes --project <repo> --scope <team>   # run inside the worktree
vercel git connect git@github.com:<org>/<repo>.git --yes --scope <team>
```

If `git connect` fails, the Vercel GitHub app usually lacks access to the new repo
(its installation covers selected repositories only). Check with
`gh api orgs/<org>/installations --jq '.installations[] | {app_slug, repository_selection, id}'`.
Only an org owner can add the repo, at
`https://github.com/organizations/<org>/settings/installations/<id>`. Give the user that
link and re-run `vercel git connect` after they've done it. Don't treat this failure as
a blocker for the rest of the steps.

## 5. Write the files

**README.md**: the project name, what it does (from the description), its current
status (early setup), where it's hosted (the Vercel project and team, or "not deployed
yet" without Vercel), and a pointer to CLAUDE.md.

**CLAUDE.md**: the project name and description, the GitHub repo and, with Vercel, the
Vercel project and team. Then a "How we work" section with these rules, using the real
username:

- **Worktrees**: all work is done in git worktrees under `.claude/worktrees/<short-name>`,
  never directly in the main checkout, which stays on `main`.
- **Branches**: prefixed with `<username>/`, e.g. `<username>/some-feature`.
- **Commits**: semantic (Conventional Commits) messages, `type(scope): summary`, with
  type one of `feat`, `fix`, `docs`, `chore`, `refactor`, `test`, `ci`, `build`, `perf`
  or `style`.
- **Pull requests**: each piece of work goes up as a PR to `main`.
- **Merging**: when the user asks you to merge a PR, run these from the main checkout:
  1. `gh pr merge <number> --squash`. Don't pass `--delete-branch`: it fails while a
     worktree still has the branch checked out.
  2. `git worktree remove .claude/worktrees/<short-name>`
  3. `git branch -D <username>/<short-name>`
  4. `git push origin --delete <username>/<short-name>`
  5. Leave the user on a freshly pulled `main` in the main checkout:
     `git checkout main && git pull --prune`

**.gitignore**: at least `.claude/worktrees/`, `.env*` (with `!.env.example`),
`node_modules/` and `.DS_Store`, plus `.vercel` with Vercel.

## 6. Commit, push and raise the PR

```bash
git add README.md CLAUDE.md .gitignore
git commit -m "docs: add README and CLAUDE.md with working conventions"
git push -u origin <username>/initial-docs
gh pr create --base main --title "docs: add README and CLAUDE.md with working conventions" --body "..."
```

Follow any commit and PR attribution rules in effect. With Vercel, make sure the
`vercel link` output (`.vercel/`, `.env.local`) isn't committed.

## 7. Report

Give the user the GitHub repo URL and the PR URL, and with Vercel, the Vercel project. Say
plainly about anything that needs them, such as granting the Vercel GitHub app access.
Without Vercel, say how to add it later: run step 4's commands from the main checkout,
then add the project to README.md and CLAUDE.md.
