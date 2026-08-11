; =============================================================================
; config.ahk - Central feature toggles for macOS-Windows
; =============================================================================
; Flip any value below to true/false to enable/disable a feature area.
; No other file needs to change to turn a whole feature group on or off.
; All modules read from this Config class, so this is the single source of
; truth for the behaviour of the whole project.
; =============================================================================

class Config
{
    ; --- Core modifier behaviour --------------------------------------------
    ; SwapModifiers is the master switch for treating Command (Win) as the
    ; primary macOS-style modifier. Turn this off to disable every Cmd-based
    ; remap at once while leaving Option/Alt-based word navigation untouched.
    static SwapModifiers        := true

    ; Disable ALL custom remaps while a fullscreen app (typically a game) is
    ; active, so games always receive raw, unmodified keyboard input.
    ; See modules/fullscreen.ahk for the detection heuristic.
    static DisableInFullscreen  := true

    ; --- Feature groups ------------------------------------------------------
    static EnableAppShortcuts       := true ; Cmd+C/X/V/Z/A/S/F/T/W/N/Q, Cmd+Shift+Z
    static EnableAppSwitcher        := true ; Cmd+Tab (+Shift) = macOS-style Alt-Tab switcher
    static EnableLineNavigation     := true ; Cmd+Left/Right (+Shift) = start/end of line
    static EnableWordNavigation     := true ; Option+Left/Right (+Shift) = move by word
    static EnableDocumentNavigation := true ; Cmd+Up/Down (+Shift) = start/end of document
    static EnableLineDeletion       := true ; Cmd+Backspace/Delete = delete to start/end of line
    static EnableMinimize           := true ; Cmd+H = minimize the active window

    ; --- Application-specific tweaks -----------------------------------------
    static EnableExplorerTweaks := true ; File Explorer (Finder-style navigation)
    static EnableTerminalTweaks := true ; Windows Terminal
    static EnableVSCodeTweaks   := true ; VS Code and Cursor
    static EnableBrowserTweaks  := true ; Chrome and Edge
}
