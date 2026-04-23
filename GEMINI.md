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

## Setup Requirements for AI-Shell Integration
To ensure seamless operation within this workspace:
1. **Shell Environment:** The user is operating in the Fish shell.
2. **Plugin Integration:** Follow the standard `fisher install Realiserad/fish-ai` workflow as documented in the system session.
3. **Configuration:** Maintain the `~/.config/fish-ai.ini` file for backend connectivity (OpenAI/Ollama).
