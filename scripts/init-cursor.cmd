@echo off
setlocal enabledelayedexpansion
REM Link source (file or dir) into project .cursor/rules. Prefer symlink, fallback to hard link.
REM Usage: init-cursor [target] [source]   or   init-cursor --target path --source path
REM   Default source "user_rules" = folder next to this script (so it works from any project).

set "SCRIPT_DIR=%~dp0"
if "%SCRIPT_DIR:~-1%"=="\" set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
set "DEFAULT_SOURCE=%SCRIPT_DIR%\user_rules"
set "DEFAULT_TARGET=."
set "TARGET=%DEFAULT_TARGET%"
set "SOURCE=%DEFAULT_SOURCE%"
set "POS1="
set "POS2="

:parse
if "%~1"=="" goto :parsed
if /i "%~1"=="/?"       goto :help
if /i "%~1"=="--help"   goto :help
if /i "%~1"=="-h"       goto :help
if /i "%~1"=="--target" set "TARGET=%~2" & shift & shift & goto :parse
if /i "%~1"=="--source" set "SOURCE=%~2" & shift & shift & goto :parse
if not defined POS1 set "POS1=%~1" & shift & goto :parse
if not defined POS2 set "POS2=%~1" & shift & goto :parse
shift & goto :parse

:parsed
if defined POS1 set "TARGET=!POS1!"
if defined POS2 set "SOURCE=!POS2!"
REM If user passed literal "user_rules", resolve to script's user_rules folder
if "!SOURCE!"=="user_rules" set "SOURCE=%SCRIPT_DIR%\user_rules"

:run
REM Resolve absolute paths (pushd sets CD to the path)
pushd "%TARGET%" 2>nul
if errorlevel 1 (
  echo Error: target not found: %TARGET%
  exit /b 1
)
set "TARGET_ABS=%CD%"
popd

pushd "%SOURCE%" 2>nul
if errorlevel 1 (
  echo Error: source not found: %SOURCE%
  exit /b 1
)
set "SOURCE_ABS=%CD%"
popd

set "RULES_DIR=%TARGET_ABS%\.cursor\rules"
if not exist "%RULES_DIR%" mkdir "%RULES_DIR%"

REM Check if source is file or directory (dir has \. at end when we test)
if exist "%SOURCE_ABS%\*" goto :link_dir
if exist "%SOURCE_ABS%"   goto :link_file
echo Error: source is neither file nor directory: %SOURCE%
exit /b 1

:link_file
for %%a in ("%SOURCE_ABS%") do set "FNAME=%%~nxa"
call :makelink "%RULES_DIR%\!FNAME!" "%SOURCE_ABS%"
if errorlevel 1 exit /b 1
echo Linked 1 file into %RULES_DIR%
goto :done

:link_dir
set "CNT=0"
for %%f in ("%SOURCE_ABS%\*") do (
  set "FNAME=%%~nxf"
  call :makelink "%RULES_DIR%\!FNAME!" "%%f"
  if not errorlevel 1 set /a CNT+=1
)
echo Linked !CNT! file(s) into %RULES_DIR%
goto :done

:makelink
REM Arg1=link path, Arg2=target file path. Try symlink then hard link.
if exist "%~1" del "%~1" 2>nul
mklink "%~1" "%~2" >nul 2>nul
if not errorlevel 1 (echo [symlink] %~1 -^> %~2 & exit /b 0)
mklink /H "%~1" "%~2" >nul 2>nul
if not errorlevel 1 (echo [hardlink] %~1 -^> %~2 & exit /b 0)
echo Error: could not create link: %~1
exit /b 1

:help
echo.
echo init-cursor - link rules into project .cursor/rules
echo.
echo Usage: init-cursor [TARGET] [SOURCE]
echo   TARGET  Project root. Links go to TARGET\.cursor\rules. Default: .
echo   SOURCE  File or directory to link from. Default: user_rules (next to this script)
echo.
echo   No args    = target . , source = script dir\user_rules
echo   One arg    = target ^<%arg^>, source user_rules
echo   Two args   = target ^<%1st^>, source ^<%2nd^>
echo   Options    = --target path --source path
echo.
echo Uses symbolic links when possible; falls back to hard links.
echo /? or --help  Show this help.
echo.
exit /b 0

:done
endlocal
exit /b 0
