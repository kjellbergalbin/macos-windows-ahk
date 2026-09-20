; =============================================================================
; modules/window-management.ahk - Rectangle-inspired window management
; =============================================================================
; Uses Ctrl+Option+Command (Ctrl+Alt+Win) for window management so native
; Windows Win+Arrow behavior and the project's existing macOS text navigation
; shortcuts stay available. All placement uses the target monitor's work area,
; keeping windows clear of the taskbar and reserved display edges.
; =============================================================================

WindowManagementEnabled() => Config.EnableWindowManagement && RemapsAllowed()
DisplayControlsEnabled() => WindowManagementEnabled() && Config.EnableDisplayControls
WindowTilingEnabled() => WindowManagementEnabled() && Config.EnableWindowTiling
WideLayoutsEnabled() => WindowManagementEnabled() && Config.EnableWideLayouts

; --- Core display controls ---------------------------------------------------
#HotIf DisplayControlsEnabled()
^!#Left::MoveActiveWindowToAdjacentMonitor(-1)
^!#Right::MoveActiveWindowToAdjacentMonitor(1)
^!Enter::ToggleActiveWindowMaximize()
^!#h::MaximizeActiveWindowHeight()

; --- Everyday tiling ---------------------------------------------------------
#HotIf WindowTilingEnabled()
^!#a::TileActiveWindow(0, 0, 0.5, 1)
^!#d::TileActiveWindow(0.5, 0, 0.5, 1)
^!#w::TileActiveWindow(0, 0, 1, 0.5)
^!#s::TileActiveWindow(0, 0.5, 1, 0.5)
^!#q::TileActiveWindow(0, 0, 0.5, 0.5)
^!#e::TileActiveWindow(0.5, 0, 0.5, 0.5)
^!#z::TileActiveWindow(0, 0.5, 0.5, 0.5)
^!#c::TileActiveWindow(0.5, 0.5, 0.5, 0.5)

; --- Wide-screen layouts -----------------------------------------------------
#HotIf WideLayoutsEnabled()
^!#1::TileActiveWindow(0, 0, 1 / 3, 1)
^!#2::TileActiveWindow(1 / 3, 0, 1 / 3, 1)
^!#3::TileActiveWindow(2 / 3, 0, 1 / 3, 1)
^!+#1::TileActiveWindow(0, 0, 2 / 3, 1)
^!+#2::TileActiveWindow(1 / 6, 0, 2 / 3, 1)
^!+#3::TileActiveWindow(1 / 3, 0, 2 / 3, 1)
#HotIf

ToggleActiveWindowMaximize()
{
    hwnd := WinExist("A")
    if !hwnd
        return

    windowTitle := "ahk_id " hwnd
    if WinGetMinMax(windowTitle) = 1
        WinRestore(windowTitle)
    else
        WinMaximize(windowTitle)
}

MaximizeActiveWindowHeight()
{
    hwnd := WinExist("A")
    if !hwnd
        return

    monitorIndex := GetActiveWindowMonitor(hwnd)
    MonitorGetWorkArea(monitorIndex, &left, &top, &right, &bottom)
    windowTitle := "ahk_id " hwnd

    WinRestore(windowTitle)
    WinGetPos(&x, &ignoredY, &width, &ignoredHeight, windowTitle)

    workWidth := right - left
    width := Min(width, workWidth)
    x := Clamp(x, left, right - width)
    WinMove(x, top, width, bottom - top, windowTitle)
}

TileActiveWindow(xRatio, yRatio, widthRatio, heightRatio)
{
    hwnd := WinExist("A")
    if !hwnd
        return

    monitorIndex := GetActiveWindowMonitor(hwnd)
    MonitorGetWorkArea(monitorIndex, &left, &top, &right, &bottom)
    windowTitle := "ahk_id " hwnd

    WinRestore(windowTitle)

    workWidth := right - left
    workHeight := bottom - top
    x := Round(left + workWidth * xRatio)
    y := Round(top + workHeight * yRatio)
    width := Round(workWidth * widthRatio)
    height := Round(workHeight * heightRatio)

    WinMove(x, y, width, height, windowTitle)
}

MoveActiveWindowToAdjacentMonitor(direction)
{
    hwnd := WinExist("A")
    if !hwnd
        return

    currentMonitor := GetActiveWindowMonitor(hwnd)
    targetMonitor := FindAdjacentMonitor(currentMonitor, direction)
    if targetMonitor = currentMonitor
        return

    MonitorGetWorkArea(currentMonitor, &currentLeft, &currentTop, &currentRight, &currentBottom)
    MonitorGetWorkArea(targetMonitor, &targetLeft, &targetTop, &targetRight, &targetBottom)

    windowTitle := "ahk_id " hwnd
    wasMaximized := WinGetMinMax(windowTitle) = 1
    WinRestore(windowTitle)
    WinGetPos(&x, &y, &width, &height, windowTitle)

    currentWidth := currentRight - currentLeft
    currentHeight := currentBottom - currentTop
    targetWidth := targetRight - targetLeft
    targetHeight := targetBottom - targetTop

    relativeX := (x - currentLeft) / currentWidth
    relativeY := (y - currentTop) / currentHeight
    width := Min(Round(width * targetWidth / currentWidth), targetWidth)
    height := Min(Round(height * targetHeight / currentHeight), targetHeight)
    x := Clamp(Round(targetLeft + relativeX * targetWidth), targetLeft, targetRight - width)
    y := Clamp(Round(targetTop + relativeY * targetHeight), targetTop, targetBottom - height)

    WinMove(x, y, width, height, windowTitle)
    if wasMaximized
        WinMaximize(windowTitle)
}

GetActiveWindowMonitor(hwnd)
{
    WinGetPos(&x, &y, &width, &height, "ahk_id " hwnd)
    centerX := x + width / 2
    centerY := y + height / 2

    Loop MonitorGetCount()
    {
        MonitorGet(A_Index, &left, &top, &right, &bottom)
        if centerX >= left && centerX < right && centerY >= top && centerY < bottom
            return A_Index
    }

    return MonitorGetPrimary()
}

FindAdjacentMonitor(currentMonitor, direction)
{
    MonitorGet(currentMonitor, &currentLeft, &currentTop, &currentRight, &currentBottom)
    currentCenterX := (currentLeft + currentRight) / 2
    currentCenterY := (currentTop + currentBottom) / 2
    candidate := currentMonitor
    bestScore := ""

    Loop MonitorGetCount()
    {
        if A_Index = currentMonitor
            continue

        MonitorGet(A_Index, &left, &top, &right, &bottom)
        horizontalDelta := (left + right) / 2 - currentCenterX
        if (direction < 0 && horizontalDelta >= 0) || (direction > 0 && horizontalDelta <= 0)
            continue

        score := Abs(horizontalDelta) * 10000 + Abs((top + bottom) / 2 - currentCenterY)
        if bestScore = "" || score < bestScore
        {
            bestScore := score
            candidate := A_Index
        }
    }

    return candidate
}

Clamp(value, minimum, maximum)
{
    return Min(Max(value, minimum), maximum)
}
