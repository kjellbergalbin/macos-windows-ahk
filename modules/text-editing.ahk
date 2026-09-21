; =============================================================================
; modules/text-editing.ahk - macOS-style line deletion
; =============================================================================
; Cmd+Backspace -> delete from cursor to the beginning of the line
; Cmd+Delete    -> delete from cursor to the end of the line
;
; Implemented as select-then-delete (Shift+Home/End followed by
; Backspace/Delete), which works in any standard text control without
; needing app-specific logic.
; =============================================================================

LineDeleteEnabled() => Config.SwapModifiers && Config.EnableLineDeletion && RemapsAllowed()

#HotIf LineDeleteEnabled()
#Backspace::Send "+{Home}{Backspace}"
#Delete::Send "+{End}{Delete}"
!Backspace::Send "^{Backspace}"      ; Alt+Backspace = delete word backward (macOS Opt+Backspace)
!Delete::Send "^{Delete}"           ; Alt+Delete = delete word forward
#HotIf
