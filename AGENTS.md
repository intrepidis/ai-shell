# AI Shell

## Operational Mandates
- **Local Execution:** All shell commands requested by the user should be executed within or relative to this directory (`$HOME/Code/ai-shell`).
- **Persistence:** Project-specific configurations, logs, or temporary artifacts should be stored within this directory to maintain a clean workspace environment.
- **Safety:** Always verify directory context before executing destructive commands.

## Root Execution & File Ownership
- **Context:** This project is frequently run in the OpenCode harness as administrator via `sudo`, so the agent and its subagents execute as root. Files written into the user's home (`~`) then become owned by root and are inaccessible to the user without `sudo`.
- **Return ownership after writes:** Whenever the agent or a subagent creates or modifies a file — directly or indirectly — return its ownership to the invoking (non-root) user via the repository script `scripts/return-home-ownership.sh` (root-safe, generic via `$SUDO_USER`):
  - After each known write, run `scripts/return-home-ownership.sh --path <file>`.
  - Collect paths written by subagents into a newline list and pass via `scripts/return-home-ownership.sh --paths-from-stdin`.
  - At session start, create a marker file; at session end run `scripts/return-home-ownership.sh --session --since-marker <marker>` over the collected paths and the project directory to catch indirect root writes.
  - If files remain root-owned or a full repair is needed, the user can invoke `/fix-home-ownership`, which runs `scripts/return-home-ownership.sh --full-home`.
- **Safety:** The script is a no-op when not running as root, never hardcodes a username, and only recurses (`chown -R`) in `--full-home` mode. Do not substitute a manual `chown`; always use the script.

## Persistent Memory Workflow
- **State Management:** Project-specific and global context should be managed using the `MEMORY.md` file.
- **Best Practice:** Critical project configurations, developer preferences, and workflow notes should be persisted to ensure continuity across sessions. Avoid storing transient data.

## AI-Shell Integration
To ensure optimal performance and seamless integration:
1. **Desktop Environment:** We are using GNOME on Wayland. Never suggest changing to Xorg or X11.
2. **Toolkit Preference:** Prefer GTK over Qt when recommending applications or tooling.
3. **Shell Environment:** This workspace is optimized for the Fish shell. Bash is available but generally not used.
4. **Editor Preference:** We use the Xed text editor. Do not suggest Nano unless explicitly requested.
5. **Configuration:** Secure API keys using the provided plugin utilities rather than direct file editing where possible.

## Installation Preferences
- **Preferred:** `sudo apt install`.
- **Next best:** downloading and installing a `.deb` package.
- **Avoid if possible:** AppImage, and only recommend it if absolutely necessary.
- **Least preferred:** Flatpak. Never suggest Flatpak unless explicitly asked or if it is the only way to install an app.
