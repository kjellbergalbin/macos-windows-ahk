; =============================================================================
; modules/vscode.ahk - VS Code and Cursor tweaks
; =============================================================================
; Cursor is a VS Code fork with an (almost) identical shortcut scheme, so
; both are handled by the same block via ahk_exe matching.
;
; The base Cmd+C/X/V/Z/A/S/F/T/W/N shortcuts already work without any
; app-specific code, because VS Code uses Ctrl as its primary modifier on
; Windows already (modules/modifiers.ahk covers them).
;
; The bindings below extend Mac-style muscle memory to a few extremely
; common editor actions that fall outside the base letter set requested,
; and are scoped to this app only, so they never affect global Win-key
; shortcuts elsewhere.
; =============================================================================

VSCodeActive()  => WinActive("ahk_exe Code.exe") || WinActive("ahk_exe Cursor.exe")
VSCodeEnabled() => Config.SwapModifiers && Config.EnableVSCodeTweaks && RemapsAllowed() && VSCodeActive()

#HotIf VSCodeEnabled()
#p::Send "^p"      ; Cmd+P       -> Quick Open
#+p::Send "^+p"    ; Cmd+Shift+P -> Command Palette
#/::Send "^/"      ; Cmd+/       -> Toggle line comment
#]::Send "^]"      ; Cmd+]       -> Indent line
#[::Send "^["      ; Cmd+[       -> Outdent line
#HotIf
