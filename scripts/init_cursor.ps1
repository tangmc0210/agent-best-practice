<#
.SYNOPSIS
    Links source (file or directory) into a project's .cursor/rules.

.DESCRIPTION
    Target is the project root; links are created under TARGET/.cursor/rules.
    Prefer symbolic links; fall back to hard links if symlinks are not allowed
    (e.g. Windows without admin/developer mode).

.PARAMETER Target
    Project root directory. Default: current directory (.).

.PARAMETER Source
    File or directory to link from. If a directory, all files inside (one level)
    are linked. Default: user_rules.

.EXAMPLE
    .\init_cursor.ps1
    # TARGET=., SOURCE=user_rules -> links into ./.cursor/rules

.EXAMPLE
    .\init_cursor.ps1 C:\Projects\MyApp
    # Links into C:\Projects\MyApp\.cursor\rules from user_rules

.EXAMPLE
    .\init_cursor.ps1 -Target . -Source my_rules
#>

param(
    [Parameter(Position = 0)]
    [string] $Target = ".",
    [Parameter(Position = 1)]
    [string] $Source = "user_rules",
    [Parameter(Mandatory = $false)]
    [switch] $Help
)

if ($Help) {
    Get-Help $MyInvocation.MyCommand.Path -Full
    exit 0
}

$ErrorActionPreference = "Stop"

# Resolve paths relative to current directory
$sourcePath = [System.IO.Path]::GetFullPath((Join-Path (Get-Location) $Source))
if (-not (Test-Path $sourcePath)) {
    Write-Error "Source not found: $Source"
    exit 1
}

# Target is project root; we write into project/.cursor/rules
$targetProjectRoot = [System.IO.Path]::GetFullPath((Join-Path (Get-Location) $Target))
$targetDir = Join-Path $targetProjectRoot ".cursor" "rules"
New-Item -ItemType Directory -Path $targetDir -Force | Out-Null

function New-Link {
    param([string] $LinkPath, [string] $TargetPath)
    if (Test-Path $LinkPath) { Remove-Item $LinkPath -Force }
    try {
        New-Item -ItemType SymbolicLink -Path $LinkPath -Target $TargetPath -Force | Out-Null
        Write-Host "[symlink] $LinkPath -> $TargetPath"
        return $true
    } catch {
        try {
            [System.IO.File]::CreateHardLink($LinkPath, $TargetPath) | Out-Null
            Write-Host "[hardlink] $LinkPath -> $TargetPath"
            return $true
        } catch {
            Write-Host "Error: could not create link: $LinkPath"
            return $false
        }
    }
}

if (Test-Path $sourcePath -PathType Leaf) {
    $linkPath = Join-Path $targetDir ([System.IO.Path]::GetFileName($sourcePath))
    if (-not (New-Link -LinkPath $linkPath -TargetPath $sourcePath)) { exit 1 }
} elseif (Test-Path $sourcePath -PathType Container) {
    $count = 0
    $fail = 0
    Get-ChildItem -Path $sourcePath -File | ForEach-Object {
        $linkPath = Join-Path $targetDir $_.Name
        if (New-Link -LinkPath $linkPath -TargetPath $_.FullName) { $count++ } else { $fail++ }
    }
    if ($count -eq 0 -and $fail -eq 0) {
        Write-Host "Warning: no files to link in source directory: $Source"
    } else {
        Write-Host "Linked $count file(s) into $targetDir"
        if ($fail -gt 0) { Write-Host "Failed: $fail"; exit 1 }
    }
} else {
    Write-Error "Source is neither a file nor a directory: $Source"
    exit 1
}
