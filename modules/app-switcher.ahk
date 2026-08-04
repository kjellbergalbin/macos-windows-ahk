; =============================================================================
; modules/app-switcher.ahk - Cmd+Tab as a macOS-style Alt-Tab switcher
; =============================================================================
; On macOS, Cmd+Tab opens the app switcher. Windows' native Win+Tab opens
; Task View instead. This module makes Cmd+Tab drive the classic Windows
; Alt-Tab switcher, which is the much closer macOS equivalent, while leaving
; Task View available on its original combo (Ctrl+Win+Tab) if ever needed.
;
; Implemented as manual Alt-Tab emulation (hold Alt while Win is held, relay
; Tab/Shift+Tab, release Alt when Win is released) rather than AutoHotkey's
; built-in AltTab/ShiftAltTab hotkey actions. Those special actions are
; NOT affected by #HotIf - see
; https://www.autohotkey.com/docs/v2/Hotkeys.htm#AltTabWindow - so they
; would keep firing even inside fullscreen games or with this feature
; turned off in config.ahk. Sending {Alt down}/{Alt up} directly keeps
; Cmd+Tab consistent with every other toggle in this project.
;
; Holding Cmd and pressing Tab repeatedly cycles forward through the
; switcher, exactly like every other Cmd+<key> combo here. Holding Shift
; too reverses direction, matching native Alt+Shift+Tab.
; =============================================================================

; Tracks whether we're mid-switch (i.e. we sent {Alt down} for the
; switcher), so the Win-release hotkey below only ever sends {Alt up} when
; there is a matching {Alt down} to close out - never on an unrelated tap
; or release of the Win key (e.g. after Cmd+C), where a stray Alt-up could
; spuriously activate a classic app's menu bar.
global AppSwitcherActive := false

AppSwitcherEnabled() => Config.SwapModifiers && Config.EnableAppSwitcher && RemapsAllowed()

#HotIf AppSwitcherEnabled()
; LWin/RWin become prefix keys here for the Tab combo only; being standard
; modifier keys, they keep working normally everywhere else (e.g. the #c,
; #x... hotkeys in modifiers.ahk, or a plain tap opening the Start Menu).
;
; No leading "*" here: custom combination ("&") hotkeys are wildcard by
; default, and a literal "*" at the start of a line is also AutoHotkey's
; multiplication/continuation operator - right after the #HotIf expression
; above, that makes the parser merge this line into it as one continued
; expression instead of starting a new hotkey, producing a confusing
; ':' is missing its '?' error.
LWin & Tab::AppSwitcher_Step()
RWin & Tab::AppSwitcher_Step()
#HotIf

; Releasing Cmd activates the highlighted window, mirroring how releasing
; Cmd on macOS confirms the app-switcher selection. Deliberately NOT gated
; by #HotIf: that condition is re-evaluated live at the moment each key
; event fires, so if it happened to be false exactly when Win was released
; (e.g. focus moved to a fullscreen window, or a Config toggle changed
; mid-gesture), this hotkey would simply not fire and Alt would be left
; stuck down with nothing left to release it. Always listening is safe -
; AppSwitcher_Release() itself is a no-op unless AppSwitcherActive is true.
~*LWin Up::AppSwitcher_Release()
~*RWin Up::AppSwitcher_Release()

AppSwitcher_Step(*)
{
    global AppSwitcherActive
    if GetKeyState("Shift", "P")
        Send "{Blind}{Alt down}{Shift down}{Tab}"
    else
        Send "{Blind}{Alt down}{Tab}"
    AppSwitcherActive := true
}

AppSwitcher_Release(*)
{
    global AppSwitcherActive
    if AppSwitcherActive
    {
        Send "{Blind}{Shift up}{Alt up}"
        AppSwitcherActive := false
    }
}
