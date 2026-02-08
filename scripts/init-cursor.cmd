@echo off
REM Wrapper so you can run "init-cursor" from any project directory (with scripts on PATH).
REM Runs init_cursor.ps1; when no args, uses current directory as target (project root).

set "SCRIPT_DIR=%~dp0"
if "%~1"=="" (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%init_cursor.ps1" -Target .
) else (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%init_cursor.ps1" %*
)
