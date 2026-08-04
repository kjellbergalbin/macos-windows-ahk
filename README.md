# macOS-Windows

Mac-style keyboard shortcuts for Windows, built for switching between a Mac
laptop and a Windows desktop (e.g. with an Apple Magic Keyboard) without
retraining your muscle memory. Written in modern [AutoHotkey v2](https://www.autohotkey.com/)
syntax and organized as a small modular project.

## Features

- **Command (Win) as the primary modifier** for `C / X / V / Z / A / S / F / T / W / N / Q`
  (copy, cut, paste, undo, select all, save, find, new tab, close, new window, quit).
- **Option (Alt) left native** - menu access, Alt+F4, Alt+Tab all work exactly
  as before.
- **Line navigation**: `Cmd+Left/Right` = beginning/end of line, with `Shift`
  to select.
- **Word navigation**: `Option+Left/Right` = move by word, with `Shift` to select.
- **Document navigation**: `Cmd+Up/Down` = beginning/end of document.
- **Line deletion**: `Cmd+Backspace` deletes to the start of the line,
  `Cmd+Delete` deletes to the end.
- **`Cmd+Tab` opens a macOS-style app switcher** - drives the classic
  Windows Alt-Tab switcher instead of Task View. Keep holding Cmd and tap
  `Tab` to cycle forward, add `Shift` to reverse, and release Cmd to
  activate the selected window.
- **Never interferes with fullscreen games** - all remaps disable themselves
  automatically while a fullscreen app is active.
- **App-specific tweaks** for File Explorer, Windows Terminal, VS Code/Cursor,
  and Chrome/Edge.
- **Every feature can be toggled independently** in `config.ahk`.

## Requirements

- Windows 10 or 11
- [AutoHotkey v2.0+](https://www.autohotkey.com/download/)

## Project structure

```
macOS-Windows.ahk      Entry point - wires up config and modules only
config.ahk              Feature toggles (edit this to customize)
install.ps1             Optional installer (adds a Startup shortcut)
modules/
  fullscreen.ahk        Shared fullscreen/game detection
  modifiers.ahk         Cmd+C/X/V/Z/A/S/F/T/W/N/Q
  app-switcher.ahk      Cmd+Tab macOS-style app switcher (Alt-Tab)
  navigation.ahk        Cmd/Option + arrow key navigation
  text-editing.ahk       Cmd+Backspace/Delete line editing
  explorer.ahk          File Explorer tweaks
  terminal.ahk          Windows Terminal tweaks
  vscode.ahk            VS Code / Cursor tweaks
  browser.ahk           Chrome / Edge tweaks
```

## Installation

1. Clone this repository.
2. Run the installer from PowerShell:
   ```powershell
   .\install.ps1
   ```
   This adds a shortcut to your Startup folder and launches the script
   immediately. To remove it later: `.\install.ps1 -Uninstall`.

   Alternatively, just double-click `macOS-Windows.ahk` to run it once
   without installing anything.

## Configuration

All feature toggles live in `config.ahk`:

```ahk
class Config
{
    static SwapModifiers        := true
    static DisableInFullscreen  := true
    static EnableAppShortcuts       := true
    static EnableAppSwitcher        := true
    static EnableLineNavigation     := true
    static EnableWordNavigation     := true
    static EnableDocumentNavigation := true
    static EnableLineDeletion       := true
    static EnableExplorerTweaks := true
    static EnableTerminalTweaks := true
    static EnableVSCodeTweaks   := true
    static EnableBrowserTweaks  := true
}
```

Set any value to `false` to disable that feature, then reload the script
(right-click its tray icon > Reload This Script), or use one of the methods
below.

## Updating after making changes

The running script does **not** pick up file edits automatically - after
changing anything in this repo (`config.ahk`, a module, or
`macOS-Windows.ahk` itself), reload it with one of:

- **Hotkey**: press `Cmd+Option+R` (`Win+Alt+R`) from anywhere. This works
  even while a fullscreen app has every other shortcut disabled.
- **Tray icon**: right-click the icon in the system tray > **Reload This
  Script**.

Both reload the whole script in place, so `#Include`d module changes take
effect too - there's no need to restart Windows or re-run `install.ps1`
(that script only manages the Startup shortcut, not the running process).

**If you edit the repo from WSL/Linux** (e.g. via an editor or AI agent) but
run the script from a native Windows path, sync with `git` rather than
copying files by hand - a manual copy can silently miss a file and leave a
stale, half-updated version in place (the actual cause is hard to spot,
since AHK's error output only shows line numbers, not which copy is stale).
Set it up once as a real clone:

```powershell
git clone \\wsl.localhost\Debian\home\<you>\Repositories\macos-windows-ahk C:\Users\<you>\ahk\macos-windows-ahk
```

Then every time you've made changes on the Linux side, just:

```powershell
cd C:\Users\<you>\ahk\macos-windows-ahk
git pull
```

followed by `Cmd+Option+R` to reload. `git pull` always brings every file
fully in sync (added, changed, *and* deleted ones) - unlike a manual copy.

If you installed via `install.ps1`, the Startup shortcut always points at
`macOS-Windows.ahk` in this folder, so `git pull` + reload is enough to pick
up updates; there's nothing to reinstall.

## Design notes

- **No raw key-identity swap.** Rather than remapping the physical Win and
  Ctrl keys at the driver/hook level (a common approach that is prone to
  "stuck modifier" bugs), this project defines explicit `Cmd+<key>` hotkeys
  that send the Ctrl (or Alt-Tab) equivalent. Any Win-key combo left
  undefined - `L`, `D`, `E`, `R`, number keys, etc. - keeps behaving exactly
  like native Windows for free.
- **Trade-off**: native Windows shortcuts on the keys listed above
  (e.g. `Win+V` clipboard history, `Win+X` quick link menu, `Win+Z` snap
  layouts, and now `Win+Tab` Task View) are unavailable while this script is
  running, since Command now takes over those combinations. Task View is
  still reachable from its taskbar button.
- **`Cmd+Tab` app switcher** (`modules/app-switcher.ahk`) doesn't use
  AutoHotkey's built-in `AltTab`/`ShiftAltTab` hotkey actions, because those
  are [never affected by `#HotIf`](https://www.autohotkey.com/docs/v2/Hotkeys.htm#AltTabWindow)
  and would keep firing in fullscreen games or with the feature disabled in
  `config.ahk`. Instead it manually holds `Alt` down for the duration of the
  Win key press and relays `Tab`/`Shift+Tab`, releasing `Alt` (which
  activates the selection) when Cmd is released - the same interaction
  shape as holding `Cmd` on macOS. The Win-release handler that sends
  `{Alt up}` is deliberately **not** gated by `#HotIf`, unlike the
  `Tab`-press handler: `#HotIf` conditions are re-evaluated live at the
  moment each key event fires, so if the condition happened to flip false
  between the Alt-down and the Win-release, a gated release hotkey simply
  wouldn't fire, leaving Alt stuck down system-wide (symptoms: typing gets
  eaten and double-clicking a folder opens its Properties instead). Always
  listening for the release is safe because it's a no-op unless a switch is
  actually in progress.
- **Browser back/forward vs. word navigation**: Windows binds page
  Back/Forward to `Alt+Left/Right`. Inside Chrome/Edge, `modules/browser.ahk`
  restores that native behavior instead of word navigation, since it's used
  far more often in a browser. Word navigation is still available via the
  physical Ctrl key in text fields.
- **App-specific precedence**: `macOS-Windows.ahk` includes app-specific
  modules (`explorer.ahk`, `terminal.ahk`, `vscode.ahk`, `browser.ahk`)
  before the general-purpose modules. AutoHotkey fires the topmost matching
  `#HotIf` variant when more than one could apply, so app-specific bindings
  always win over the general ones on the same key combo.
- **Fullscreen detection** (`modules/fullscreen.ahk`) is a heuristic: a
  window is considered fullscreen when its bounds exactly match its
  monitor's bounds. This covers virtually all borderless and exclusive
  fullscreen games without needing a per-title list.

## Uninstall

```powershell
.\install.ps1 -Uninstall
```

Then close the running script from its tray icon (right-click > Exit).

## Troubleshooting

### "File ... is not digitally signed. You cannot run this script"

This is Windows' default PowerShell execution policy blocking unsigned
scripts, not an issue with this repo. Either run the installer once with:

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

or allow local scripts for your user going forward:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

### Typing stops working / double-clicking a folder opens its Properties

This means `Alt` got stuck in the "held down" state (Windows opens
Properties instead of the folder on an Alt+double-click, and a held Alt
also disrupts normal typing). Press and release the physical `Alt` key once
to clear it. This could happen with old versions of `modules/app-switcher.ahk`
that gated the Cmd-release handler behind `#HotIf` - update to the latest
version, which listens for the release unconditionally.

### Reload reports a syntax error that doesn't match the file's contents

This almost always means the running copy is stale - e.g. it was copied by
hand from WSL instead of kept in sync with `git pull` (see "Updating after
making changes" above), so an old version of a file is on disk even though
the repo itself is fine. Re-sync (re-copy or `git pull`) and reload again.

### Running from a WSL path (`\\wsl.localhost\...`)

`install.ps1` detects this and asks for confirmation, since the Startup
shortcut it creates may fail or be delayed if WSL hasn't started yet at
login. Prefer cloning/copying the repo to a native path (e.g.
`C:\Users\<you>\ahk\macos-windows-ahk`) first; pass `-Force` to skip the
prompt if you want to proceed from WSL anyway.
