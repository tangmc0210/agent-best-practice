# Scripts

## init-cursor — link rules into a project’s `.cursor/rules`

- **Linux/macOS:** `init_cursor.sh` or `init-cursor`
- **Windows:** `init-cursor.cmd` (pure CMD, no PowerShell)

**Target** is the **project root**. Links are always created under `TARGET\.cursor\rules`.  
**Source** is a file or directory (default: `user_rules`). Symbolic links are used when possible; hard links are used as fallback (e.g. Windows without symlink support).

### Help

- Bash: `./init_cursor.sh --help` or `-h`
- Windows: `init-cursor /?` or `init-cursor --help`

### Run from the project folder

1. **Add the `scripts` directory to your PATH.**

   - **Windows:**  
     - System: Settings → System → About → Advanced system settings → Environment Variables → edit “Path” → New → e.g. `C:\Users\<You>\Projects\Personal\agent_rules\scripts`.  
     - Or in PowerShell (current user):  
       `[Environment]::SetEnvironmentVariable('Path', $env:Path + ';C:\Users\<You>\Projects\Personal\agent_rules\scripts', 'User')`
   - **Linux/macOS:**  
     In `~/.bashrc`, `~/.zshrc`, or similar:  
     `export PATH="$PATH:/path/to/agent_rules/scripts"`  
     Then run `source ~/.bashrc` (or restart the terminal).

2. **In the project directory, run:**

   - **Windows:** `init-cursor` (or `init-cursor.cmd`)
   - **Linux/macOS:** `init-cursor` or `init_cursor.sh`  
     (Make `init-cursor` executable once: `chmod +x /path/to/agent_rules/scripts/init-cursor`)

With no arguments, the script uses the **current directory** as the project (target) and `user_rules` as the source, so links are created in `.\.cursor\rules`.
