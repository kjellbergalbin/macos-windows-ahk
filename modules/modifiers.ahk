; =============================================================================
; modules/modifiers.ahk - Command (Win) as the primary modifier
; =============================================================================
; Design decision: instead of doing a raw identity swap of LWin<->LCtrl (a
; common approach that reliably causes "stuck modifier" bugs and breaks
; Win+Tab, see the AutoHotkey forums), we leave the physical Win and Ctrl
; keys untouched and instead define explicit Cmd+<key> hotkeys that send the
; equivalent Ctrl+<key> combination. This has two benefits:
;   1. Any Win-key combo we do NOT define below (L, D, E, R, numbers...)
;      keeps behaving exactly like native Windows, with no extra code.
;      (Cmd+Tab is handled separately in app-switcher.ahk.)
;   2. It sidesteps the well-known key-hook "stuck key" issues that come
;      from remapping a modifier key's identity.
;
; Option (Alt) is intentionally left completely alone here - it keeps
; behaving exactly like native Windows Alt (menu access, Alt+F4, Alt+Tab,
; etc.), matching "Keep Option behaving like macOS" by simply not touching it.
; Word-navigation via Option+Left/Right is added separately in navigation.ahk.
;
; Bare `#` and `!` hotkeys match either the left or right Win/Alt key, so
; this also works with the second Command/Option key found on full-size
; Apple Magic Keyboards.
; =============================================================================

ModifiersEnabled() => Config.SwapModifiers && Config.EnableAppShortcuts && RemapsAllowed()
MinimizeEnabled() => Config.SwapModifiers && Config.EnableMinimize && RemapsAllowed()

#HotIf ModifiersEnabled()
#c::Send "^c"           ; Cmd+C -> Copy
#x::Send "^x"           ; Cmd+X -> Cut
#v::Send "^v"           ; Cmd+V -> Paste
#z::Send "^z"           ; Cmd+Z -> Undo
#+z::Send "^y"          ; Cmd+Shift+Z -> Redo
#a::Send "^a"           ; Cmd+A -> Select All
#s::Send "^s"           ; Cmd+S -> Save
#f::Send "^f"           ; Cmd+F -> Find
#d::Send "^d"           ; Cmd+D -> Duplicate
#t::Send "^t"           ; Cmd+T -> New Tab
#w::Send "^w"           ; Cmd+W -> Close Tab/Window
#n::Send "^n"           ; Cmd+N -> New Window
#q::Send "!{F4}"        ; Cmd+Q -> Quit (closest Windows equivalent: close window)
#i::Send "^i"           ; Cmd+I -> Italic text
#b::Send "^b"           ; Cmd+B -> Bold text
#HotIf

; Cmd+H -> minimize the active window (kept as its own toggle/#HotIf since,
; unlike the shortcuts above, it has no Ctrl equivalent to send - it calls
; WinMinimize directly). WinMinimize works on a fullscreen window exactly
; like any other, so this needs no special-casing to satisfy "fullscreen or
; not".
#HotIf MinimizeEnabled()
#h::WinMinimize("A")    ; Cmd+H -> Minimize
#HotIf
