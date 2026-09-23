; =============================================================================
; keyboard-layout.ahk - ISO key corrections for Apple keyboards on Windows
; =============================================================================
; Windows can interpret the ISO key between left Shift and Z on an Apple Magic
; Keyboard as ½ or a mathematical symbol. A Swedish macOS layout uses that
; physical key for <, and Shift plus the same key for >.
; =============================================================================

#HotIf RemapsAllowed()
SC056::SendText "<"
+SC056::SendText ">"
#HotIf
