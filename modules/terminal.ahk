; =============================================================================
; modules/terminal.ahk - Windows Terminal tweaks
; =============================================================================
; Inside a shell, Ctrl+C/Ctrl+F/etc. are meaningful to the running program
; (SIGINT, readline search, ...), so Windows Terminal deliberately binds its
; own actions to Ctrl+Shift+<key> instead of plain Ctrl+<key>. To keep Cmd
; as a reliable "app-level" modifier here (matching its meaning everywhere
; else), Cmd+<key> is mapped to Windows Terminal's actual Ctrl+Shift+<key>
; default bindings for the keys where it matters.
;
; Keys deliberately left alone (A, S, X, Z, Q) fall through to the shell's
; own handling (e.g. Ctrl+A = "move to start of line" in readline), which is
; the more useful behaviour in a terminal.
; =============================================================================

TerminalActive()  => WinActive("ahk_exe WindowsTerminal.exe")
TerminalEnabled() => Config.SwapModifiers && Config.EnableTerminalTweaks && RemapsAllowed() && TerminalActive()

#HotIf TerminalEnabled()
#c::Send "^+c"    ; Cmd+C -> Copy (unambiguous, avoids sending SIGINT)
#v::Send "^+v"    ; Cmd+V -> Paste
#f::Send "^+f"    ; Cmd+F -> Find
#t::Send "^+t"    ; Cmd+T -> New Tab
#w::Send "^+w"    ; Cmd+W -> Close Tab
#n::Send "^+n"    ; Cmd+N -> New Window
#HotIf
