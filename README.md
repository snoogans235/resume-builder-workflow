# Resume Builder Workflow

Private backup and installable source for Jonathan Newton's Codex job-application
workflow.

The repository contains:

- Six specialist job-application agents in `agents/`
- The `job-application` skill in `skills/job-application/`
- An installer/updater for Codex
- A sync helper for bringing later installed evidence edits back into Git

The personal career evidence library under
`skills/job-application/references/evidence/` is intentionally excluded from
this repository. It remains local to each installed workflow.

## Install or update Codex

Preview the operation first:

```bash
./installer.sh --dry-run
```

Install into the default locations (`~/.codex/agents` and
`~/.agents/skills`):

```bash
./installer.sh
```

When installed files differ, the installer protects them by default. Review the
differences, sync any wanted installed edits into this repository, and then run:

```bash
./installer.sh --force
```

`--force` replaces only this workflow's six agent files and the
`job-application` skill. It does not touch unrelated agents or skills.

## Sync updated experience Markdown into Git

To copy shareable workflow Markdown and agent definitions from the installed
workflow back into this checkout:

```bash
./scripts/sync-from-installed.sh
```

The command shows the resulting Git status but does not commit or push by
default. To create a commit:

```bash
./scripts/sync-from-installed.sh --commit
```

To commit and push the update to the configured GitHub remote:

```bash
./scripts/sync-from-installed.sh --push
```

Use `--dry-run` at any time to preview copied files. The sync is deliberately
one-way from the installed workflow to this checkout and does not delete files.
Private career evidence under `references/evidence/` is never copied, committed,
or pushed. The installer preserves the complete evidence library that already
exists in the local installed skill.

## Recommended editing loop

1. Update and verify evidence only in the local installed job-application skill.
2. When shareable agent or skill instructions change, run
   `./scripts/sync-from-installed.sh --push` from this repository.
3. On another machine, clone the private repository and run
   `./installer.sh --dry-run`, followed by `./installer.sh` or
   `./installer.sh --force` after reviewing differences.
