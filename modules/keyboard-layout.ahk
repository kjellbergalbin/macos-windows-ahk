; =============================================================================
; keyboard-layout.ahk - ISO key corrections for Apple keyboards on Windows
; =============================================================================
; Windows receives the Apple Magic Keyboard's physical angle-bracket key as
; SC029 and maps it to § or ½ with the Swedish Windows layout. A Swedish macOS
; layout uses this physical key for <, and Shift plus the same key for >.
; =============================================================================

#HotIf RemapsAllowed()
SC029::SendText "<"
+SC029::SendText ">"
#HotIf
