; =============================================================================
; modules/navigation.ahk - macOS-style cursor movement and selection
; =============================================================================
; Cmd+Left/Right    -> beginning/end of line (Home/End)
; Option+Left/Right -> move by word (Ctrl+Left/Right)
; Cmd+Up/Down       -> beginning/end of document (Ctrl+Home/Ctrl+End)
; Shift variants extend the current selection, matching macOS conventions.
;
; app-specific modules (explorer.ahk, browser.ahk, ...) are included BEFORE
; this file and may define higher-precedence overrides for the same key
; combinations (e.g. restoring browser Back/Forward on Option+Left/Right).
; =============================================================================

LineNavEnabled() => Config.SwapModifiers && Config.EnableLineNavigation && RemapsAllowed()
WordNavEnabled() => Config.EnableWordNavigation && RemapsAllowed()
DocNavEnabled()  => Config.SwapModifiers && Config.EnableDocumentNavigation && RemapsAllowed()

; --- Cmd+Left/Right: beginning/end of line ----------------------------------
#HotIf LineNavEnabled()
#Left::Send "{Home}"
#Right::Send "{End}"
#+Left::Send "+{Home}"
#+Right::Send "+{End}"

; --- Option+Left/Right: move by word ----------------------------------------
#HotIf WordNavEnabled()
!Left::Send "^{Left}"
!Right::Send "^{Right}"
!+Left::Send "^+{Left}"
!+Right::Send "^+{Right}"

; --- Cmd+Up/Down: beginning/end of document ---------------------------------
#HotIf DocNavEnabled()
#Up::Send "^{Home}"
#Down::Send "^{End}"
#+Up::Send "^+{Home}"
#+Down::Send "^+{End}"

#HotIf
