<#
.SYNOPSIS
    Installs (or uninstalls) macOS-Windows so it starts automatically at login.

.DESCRIPTION
    Creates a shortcut in the current user's Startup folder that launches
    macOS-Windows.ahk with AutoHotkey v2, then starts it immediately.

.PARAMETER Uninstall
    Removes the startup shortcut instead of installing it.

.PARAMETER Force
    Skip the confirmation prompt when installing from a WSL UNC path.

.EXAMPLE
    .\install.ps1
    .\install.ps1 -Uninstall
#>
[CmdletBinding()]
param(
    [switch]$Uninstall,
    [switch]$Force
)

$ErrorActionPreference = "Stop"

$RepoRoot     = Split-Path -Parent $MyInvocation.MyCommand.Path
$ScriptPath   = Join-Path $RepoRoot "macOS-Windows.ahk"
$StartupDir   = [Environment]::GetFolderPath("Startup")
$ShortcutPath = Join-Path $StartupDir "macOS-Windows.lnk"

if ($Uninstall) {
    if (Test-Path $ShortcutPath) {
        Remove-Item $ShortcutPath -Force
        Write-Host "Removed startup shortcut: $ShortcutPath"
    } else {
        Write-Host "No startup shortcut found. Nothing to do."
    }
    return
}

if (-not (Test-Path $ScriptPath)) {
    throw "Could not find macOS-Windows.ahk next to install.ps1 (expected: $ScriptPath)"
}

# Warn (and confirm) if installing from a WSL UNC path: the Startup shortcut
# below must launch on every login, but \\wsl.localhost\... / \\wsl$\... only
# becomes available once WSL has started, which can delay or silently break
# auto-start. See README.md "Troubleshooting" for details.
if (-not $Force -and $RepoRoot -match '^\\\\wsl(\.localhost|\$)?\\') {
    Write-Warning "This repo lives on a WSL path ($RepoRoot)."
    Write-Warning "The Startup shortcut may fail or be delayed if WSL hasn't started yet at login."
    Write-Warning "Recommended: copy/clone this repo to a native path (e.g. C:\Users\<you>\ahk\macos-windows-ahk) instead."
    $reply = Read-Host "Continue installing from this WSL path anyway? [y/N]"
    if ($reply -notmatch '^[Yy]') {
        Write-Host "Aborted. Re-run from a native Windows path, or pass -Force to skip this check."
        exit 1
    }
}

# Locate an AutoHotkey v2 executable (64-bit preferred).
$Candidates = @(
    "$env:ProgramFiles\AutoHotkey\v2\AutoHotkey64.exe",
    "$env:ProgramFiles\AutoHotkey\v2\AutoHotkey32.exe",
    "${env:ProgramFiles(x86)}\AutoHotkey\v2\AutoHotkey64.exe",
    "$env:ProgramFiles\AutoHotkey\AutoHotkey64.exe"
)
$AhkExe = $Candidates | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $AhkExe) {
    $cmd = Get-Command AutoHotkey64.exe -ErrorAction SilentlyContinue
    if ($cmd) { $AhkExe = $cmd.Source }
}

if (-not $AhkExe) {
    Write-Warning "AutoHotkey v2 was not found on this system."
    Write-Host "Download it from https://www.autohotkey.com/ and re-run this installer."
    exit 1
}

# Create a Startup shortcut so the script launches automatically at login.
$Shell = New-Object -ComObject WScript.Shell
$Shortcut = $Shell.CreateShortcut($ShortcutPath)
$Shortcut.TargetPath = $AhkExe
$Shortcut.Arguments = '"' + $ScriptPath + '"'
$Shortcut.WorkingDirectory = $RepoRoot
$Shortcut.Description = "macOS-Windows keyboard shortcuts"
$Shortcut.Save()

Write-Host "Installed startup shortcut: $ShortcutPath"

# Launch it right now too.
Start-Process -FilePath $AhkExe -ArgumentList ('"' + $ScriptPath + '"')
Write-Host "macOS-Windows is now running."
Write-Host "Edit config.ahk to customize, then reload the script (right-click its tray icon) to apply changes."
