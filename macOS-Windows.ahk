; =============================================================================
; macOS-Windows.ahk - Mac-style keyboard shortcuts for Windows
; =============================================================================
; Makes Windows behave more like macOS when typing on an Apple Magic
; Keyboard (or any keyboard, if you prefer Mac muscle memory). This is the
; entry point: it only wires up configuration and modules, all behaviour
; lives in config.ahk and modules/.
;
; See README.md for setup, and config.ahk for feature toggles.
; =============================================================================
#Requires AutoHotkey v2.0
#SingleInstance Force
#UseHook
Persistent

; -----------------------------------------------------------------------------
; Load order matters: application-specific modules are included BEFORE the
; general-purpose modules so their #HotIf hotkey variants take precedence
; when both are eligible at the same time. AutoHotkey fires the topmost
; matching variant - see:
; https://www.autohotkey.com/docs/v2/lib/_HotIf.htm#Variants
; -----------------------------------------------------------------------------
#Include config.ahk
#Include modules\fullscreen.ahk

; App-specific tweaks (must load first)
#Include modules\explorer.ahk
#Include modules\terminal.ahk
#Include modules\vscode.ahk
#Include modules\browser.ahk

; General-purpose remaps (load after, so app-specific rules win on overlap)
#Include modules\modifiers.ahk
#Include modules\app-switcher.ahk
#Include modules\navigation.ahk
#Include modules\window-management.ahk
#Include modules\text-editing.ahk

; -----------------------------------------------------------------------------
; Cmd+Option+R - reload the script after editing any file in this project.
; Always active (not gated by RemapsAllowed()), so it still works even while
; a fullscreen app has every other remap disabled, or while troubleshooting
; with features toggled off in config.ahk.
; -----------------------------------------------------------------------------
#!r::Reload()

TrayTip("macOS-Windows shortcuts active", "macOS-Windows", "Mute")
