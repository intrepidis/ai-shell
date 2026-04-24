# Gemini CLI Project Configuration

This directory serves as the root for Gemini CLI operations within the `ai-shell` workspace.

## Operational Mandates
- **Local Execution:** All shell commands requested by the user should be executed within or relative to this directory (`$HOME/Code/ai-shell`).
- **Persistence:** Project-specific configurations, logs, or temporary artifacts should be stored within this directory to maintain a clean workspace environment.
- **Safety:** Always verify directory context before executing destructive commands.

## Persistent Memory Workflow
- **State Management:** Project-specific and global context is maintained using the `save_memory` tool.
- **Persistence:** Facts saved via `save_memory` are persistent across sessions and take precedence over transient session data.
- **Best Practice:** Critical project configurations, developer preferences, and workflow notes should be persisted to ensure continuity across sessions. Avoid storing transient data or extensive summaries in persistent memory.

## AI-Shell Integration
To ensure optimal performance and seamless integration with the AI-Shell:
1. **Shell Environment:** This workspace is optimized for the Fish shell. Ensure your shell session is correctly initialized.
2. **Configuration:** Secure API keys using the provided plugin utilities rather than direct file editing where possible.
