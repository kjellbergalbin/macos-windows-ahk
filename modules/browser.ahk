; =============================================================================
; modules/browser.ahk - Chrome and Edge tweaks
; =============================================================================
; Windows binds page Back/Forward navigation to Alt+Left/Right, which would
; otherwise be shadowed by the global Option+Left/Right word-navigation
; hotkeys (modules/navigation.ahk). Because this module is included first,
; its variants take precedence while a browser window is active, so
; Option+Left/Right goes back to meaning Back/Forward here - the far more
; common action in a browser. Word navigation still works via the physical
; Ctrl key.
;
; A couple of other extremely common Mac browser shortcuts are added too,
; scoped to the browser only.
; =============================================================================

BrowserActive()  => WinActive("ahk_exe chrome.exe") || WinActive("ahk_exe msedge.exe")
BrowserEnabled() => Config.EnableBrowserTweaks && RemapsAllowed() && BrowserActive()

#HotIf BrowserEnabled()
!Left::Send "{Blind}!{Left}"    ; Restore native Back
!Right::Send "{Blind}!{Right}"  ; Restore native Forward

#+t::Send "^+t"    ; Cmd+Shift+T -> Reopen closed tab
#l::Send "^l"      ; Cmd+L       -> Focus address bar
#HotIf
