---
name: fix-home-ownership
description: Restore ownership of root-written files in the invoking user's home directory on explicit request.
---

# Fix home ownership

Use this skill only when the user explicitly requests a broad ownership repair. Resolve the repository root (for example with `git rev-parse --show-toplevel`) and run:

```bash
scripts/return-home-ownership.sh --full-home
```

Before running it, print the resolved target account and home and obtain explicit user intent. This is ownership-only, but broad in scope: it may be expensive and affects the complete resolved `$SUDO_USER` home. Afterward, verify both user and group ownership with `ls -ld` and representative `ls -l` checks.

Normal sessions should use `--path`, `--paths-from-stdin`, and `--session`, not this skill.

Project-local slash-command registration depends on the OpenCode version. If the local command is unavailable, invoke this skill directly; do not modify the global OpenCode configuration.
