; =============================================================================
; modules/fullscreen.ahk - Fullscreen / game detection
; =============================================================================
; Provides RemapsAllowed(), a single source of truth used by every other
; module's #HotIf condition. When Config.DisableInFullscreen is true, all
; custom hotkeys are automatically disabled while a borderless or exclusive
; fullscreen window (typically a game) is active, so games always receive
; raw, unmodified keyboard input.
; =============================================================================

RemapsAllowed()
{
    if !Config.DisableInFullscreen
        return true
    return !IsFullScreenActive()
}

; Heuristic: a window is treated as "fullscreen" when its bounds exactly
; match the monitor it sits on (i.e. it has no title bar/border and covers
; the entire screen). This matches both borderless-fullscreen and exclusive
; fullscreen games/apps without needing a per-title allow-list.
IsFullScreenActive()
{
    hwnd := WinExist("A")
    if !hwnd
        return false

    ; Ignore desktop/shell surfaces, which can otherwise report odd bounds.
    activeClass := WinGetClass("ahk_id " hwnd)
    if (activeClass = "WorkerW" || activeClass = "Progman" || activeClass = "Shell_TrayWnd")
        return false

    WinGetPos(&winX, &winY, &winW, &winH, "ahk_id " hwnd)

    ; Find the monitor whose bounds contain the window's top-left corner.
    monLeft := 0, monTop := 0, monRight := 0, monBottom := 0
    Loop MonitorGetCount()
    {
        MonitorGet(A_Index, &l, &t, &r, &b)
        if (winX >= l && winX < r && winY >= t && winY < b)
        {
            monLeft := l, monTop := t, monRight := r, monBottom := b
            break
        }
    }
    ; Fall back to the primary monitor if no match was found (e.g. a window
    ; positioned partly off-screen).
    if (monRight = 0 && monBottom = 0)
        MonitorGet(MonitorGetPrimary(), &monLeft, &monTop, &monRight, &monBottom)

    return winX = monLeft && winY = monTop
        && winW = (monRight - monLeft) && winH = (monBottom - monTop)
}
