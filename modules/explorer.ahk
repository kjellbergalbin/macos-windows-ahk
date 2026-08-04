; =============================================================================
; modules/explorer.ahk - File Explorer (Finder-style) tweaks
; =============================================================================
; Scoped to ahk_class CabinetWClass (an actual Explorer folder window) rather
; than ahk_exe explorer.exe, because explorer.exe also hosts the taskbar,
; desktop and Start menu, which we must not affect.
;
; These hotkeys are defined before the generic navigation/text-editing
; modules, so they take precedence while an Explorer window is active
; (AutoHotkey fires the topmost matching #HotIf variant - see
; https://www.autohotkey.com/docs/v2/lib/_HotIf.htm#Variants).
; =============================================================================

ExplorerActive()  => WinActive("ahk_class CabinetWClass")
ExplorerEnabled() => Config.SwapModifiers && Config.EnableExplorerTweaks && RemapsAllowed() && ExplorerActive()

#HotIf ExplorerEnabled()
#Backspace::Send "{Delete}"    ; Cmd+Backspace -> send selection to Recycle Bin
#Up::Send "!{Up}"              ; Cmd+Up        -> go to parent folder
#Down::Send "{Enter}"          ; Cmd+Down      -> open selected item
#HotIf
