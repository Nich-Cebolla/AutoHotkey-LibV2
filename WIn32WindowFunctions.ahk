/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/WIn32WindowFunctions.ahk
    Author: Nich-Cebolla
    License: MIT
*/


AllowSetForegroundWindow(PID?) {
    if !DllCall('AllowSetForegroundProcess', 'uint', PID ?? WinGetPid(A_ScriptHwnd), 'int') {
        throw OSError()
    }
}

/**
 * @description - Calls `BeginDeferWindowPos`, which is used to prepare for adjusting the
 * dimensions of multiple windowss at once. This reduces flickering and increases
 * performance. After calling this function, fill the structure by calling `dWin.DeferWindowPos`.
 * All windows must have the same parent window.
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-begindeferwindowpos}
 * @param {Integer} [InitialCount=2] - An estimate of the number of windows that will be
 * adjusted. The count will be adjusted automatically when calling `DeferWindowPos`, so it's
 * okay if this is not exact.
 * @return {Integer} - Returns a handle to the `hWinPosInfo` structure if successful, else 0.
 */
BeginDeferWindowPos(InitialCount := 2) {
    return DllCall('BeginDeferWindowPos', 'int', InitialCount, 'ptr')
}

ChildWindowFromPoint(Hwnd, X, Y) {
    return DllCall('ChildWindowFromPoint', 'ptr', IsObject(Hwnd) ? Hwnd.Hwnd : Hwnd, 'int', (X & 0xFFFFFFFF) | (Y << 32), 'ptr')
}

ChildWindowFromPointEx(Hwnd, X, Y, flags := 0) {
    return DllCall('ChildWindowFromPointEx', 'ptr', IsObject(Hwnd) ? Hwnd.Hwnd : Hwnd, 'int', (X & 0xFFFFFFFF) | (Y << 32), 'int', flags, 'ptr')
}

/**
 * @description - Calls `DeferWindowPos`, which is used to prepare a window for being adjusted
 * when `EndDeferWindowPos` is called.
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-deferwindowpos}
 * @param {Integer} hWinPosInfo - The handle to the `hWinPosInfo` structure created by
 * `BeginDeferWindowPos`.
 * @param {Integer} Hwnd - The handle of the window to adjust.
 * @param {Integer} X - The new x-coordinate of the window.
 * @param {Integer} Y - The new y-coordinate of the window.
 * @param {Integer} W - The new Width of the window.
 * @param {Integer} Y - The new Height of the window.
 * @param {Integer} [uFlags=0] - A set of flags that control the window adjustment. The most
 * common flag is `SWP_NOZORDER` (0x0004), which prevents the window from being reordered. See
 * the link for the table of values.
 * @param {Integer} [HwndInsertAfter=0] - A handle to the window to precede the positioned
 * window in the Z-order, or one of the values listed on the linked webpage.
 * @return {Integer} - Returns the handle the the structure. It is important to use this return
 * value for the next call to `DeferWindowPos` or `EndDeferWindowPos` because the handle may
 * have changed.
 */
DeferWindowPos(hWinPosInfo, Hwnd, X, Y, W, H, uFlags := 0, HwndInsertAfter := 0) {
    return DllCall('DeferWindowPos', 'ptr', hWinPosInfo, 'ptr', IsObject(Hwnd) ? Hwnd.Hwnd : Hwnd, 'ptr', IsObject(HwndInsertAfter) ? HwndInsertAfter.Hwnd : HwndInsertAfter
    , 'int', X, 'int', Y, 'int', W, 'int', H, 'uint', uFlags, 'ptr')
}

DestroyWindow(Hwnd) {
    return DllCall('DestroyWindow', 'ptr', Hwnd, 'int')
}

/**
 * @description - Calls `EndDeferWindowPos`. Use this after setting the DWP struct.
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-enddeferwindowpos}
 * @param {Integer} hDwp - The handle to the `hWinPosInfo` structure.
 * @return {Boolean} - 1 if successful, 0 if unsuccessful.
 */
EndDeferWindowPos(hDwp) {
    return DllCall('EndDeferWindowPos', 'ptr', hDwp, 'ptr')
}

EnumChildWindows(HwndParent, Callback, lParam := 0) {
    cb := CallbackCreate(Callback)
    result := DllCall('EnumChildWindows', 'ptr', IsObject(HwndParent) ? HwndParent.Hwnd : HwndParent, 'ptr', cb, 'uint', lParam, 'int')
    CallbackFree(cb)
    return result
}

EnumThreadWindows(PID, Callback, lParam := 0) {
    cb := CallbackCreate(Callback)
    result := DllCall('EnumThreadWindows', 'uint', PID, 'ptr', cb, 'uint', lParam, 'int')
    CallbackFree(cb)
    return result
}

EnumWindows(Callback, lParam := 0) {
    cb := CallbackCreate(Callback)
    result := DllCall('EnumWindows', 'ptr', cb, 'uint', lParam, 'int')
    CallbackFree(cb)
    return result
}

FromPhysicalPoint(X, Y) {
    return DllCall('WindowFromPhysicalPoint', 'int', (X & 0xFFFFFFFF) | (Y << 32), 'ptr')
}

FromPoint(X, Y) {
    return DllCall('WindowFromPoint', 'int', (X & 0xFFFFFFFF) | (Y << 32), 'ptr')
}

GetActiveWindow() {
    return DllCall('GetActiveWindow', 'ptr')
}

/**
 * @param Flags -
 * - 1 : Retrieves the parent window. This does not include the owner, as it does with the GetParent function.
 * - 2 : Retrieves the root window by walking the chain of parent windows.
 * - 3 : Retrieves the owned root window by walking the chain of parent and owner windows returned by GetParent.
 */
GetAncestor(Hwnd, Flags) {
    return DllCall('GetAncestor', 'ptr', IsObject(Hwnd) ? Hwnd.Hwnd : Hwnd, 'uint', Flags, 'ptr')
}

/**
 * @description - Gets the bounding rectangle of all child windows of a given window.
 * @param {Integer} Hwnd - The handle to the parent window.
 * @returns {Rect} - The bounding rectangle of all child windows, specifically the smallest
 * rectangle that contains all child windows.
 */
GetChildrenBoundingRect(Hwnd) {
    rects := [Buffer(16), Buffer(16), Buffer(16)]
    DllCall('EnumChildWindows', 'ptr', IsObject(Hwnd) ? Hwnd.Hwnd : Hwnd, 'ptr', cb := CallbackCreate(_EnumChildWindowsProc, 'fast',  1), 'int', 0, 'int')
    CallbackFree(cb)
    return rects[1]

    _EnumChildWindowsProc(Hwnd) {
        DllCall('GetWindowRect', 'ptr', IsObject(Hwnd) ? Hwnd.Hwnd : Hwnd, 'ptr', rects[1], 'int')
        DllCall('UnionRect', 'ptr', rects[2], 'ptr', rects[3], 'ptr', rects[1], 'int')
        rects.Push(rects.RemoveAt(1))
        return 1
    }
}

GetDesktopWindow() {
    return DllCall('GetDesktopWindow', 'ptr')
}

GetDpi(Hwnd) => DllCall('GetDpiForWindow', 'ptr', IsObject(Hwnd) ? Hwnd.Hwnd : Hwnd, 'int')

/**
 * @param Cmd -
 * - 2 : Returns a handle to the window below the given window.
 * - 3 : Returns a handle to the window above the given window.
 */
GetNextWindow(Hwnd, Cmd) {
    return DllCall('GetNextWindow', 'ptr', IsObject(Hwnd) ? Hwnd.Hwnd : Hwnd, 'uint', Cmd, 'ptr')
}

GetParent(Hwnd) {
    return DllCall('GetParent', 'ptr', IsObject(Hwnd) ? Hwnd.Hwnd : Hwnd, 'ptr')
}

GetShellWindow() {
    return DllCall('GetShellWindow', 'ptr')
}

GetTopWindow(Hwnd := 0) {
    return DllCall('GetTopWindow', 'ptr', IsObject(Hwnd) ? Hwnd.Hwnd : Hwnd, 'ptr')
}

/**
 * @param Cmd -
 * - GW_CHILD - 5 - The retrieved handle identifies the child window at the top of the Z order,
 *  if the specified window is a parent window; otherwise, the retrieved handle is NULL. The
 *  function examines only child windows of the specified window. It does not examine descendant
 *  windows.
 *
 * - GW_ENABLEDPOPUP - 6 - The retrieved handle identifies the enabled popup window owned by the
 *  specified window (the search uses the first such window found using GW_HwndNEXT); otherwise,
 *  if there are no enabled popup windows, the retrieved handle is that of the specified window.
 *
 * - GW_HwndFIRST - 0 - The retrieved handle identifies the window of the same type that is highest
 *  in the Z order. If the specified window is a topmost window, the handle identifies a topmost
 *  window. If the specified window is a top-level window, the handle identifies a top-level
 *  window. If the specified window is a child window, the handle identifies a sibling window.
 *
 * - GW_HwndLAST - 1 - The retrieved handle identifies the window of the same type that is lowest
 *  in the Z order. If the specified window is a topmost window, the handle identifies a topmost
 *  window. If the specified window is a top-level window, the handle identifies a top-level window.
 *  If the specified window is a child window, the handle identifies a sibling window.
 *
 * - GW_HwndNEXT - 2 - The retrieved handle identifies the window below the specified window in
 *  the Z order. If the specified window is a topmost window, the handle identifies a topmost
 *  window. If the specified window is a top-level window, the handle identifies a top-level
 *  window. If the specified window is a child window, the handle identifies a sibling window.
 *
 * - GW_HwndPREV - 3 - The retrieved handle identifies the window above the specified window in
 *  the Z order. If the specified window is a topmost window, the handle identifies a topmost
 *  window. If the specified window is a top-level window, the handle identifies a top-level
 *  window. If the specified window is a child window, the handle identifies a sibling window.
 *
 * - GW_OWNER - 4 - The retrieved handle identifies the specified window's owner window, if any.
 *  For more information, see Owned Windows.
 */
GetWindow(Hwnd, Cmd) {
    return DllCall('GetWindow', 'ptr', IsObject(Hwnd) ? Hwnd.Hwnd : Hwnd, 'uint', Cmd, 'ptr')
}

IsChild(HwndParent, HwndChild) {
    return DllCall('IsChild', 'ptr', IsObject(HwndParent) ? HwndParent.Hwnd : HwndParent, 'ptr', IsObject(HwndChild) ? HwndChild.Hwnd : HwndChild, 'int')
}

IsVisible(Hwnd) {
    return DllCall('IsWindowVisible', 'ptr', IsObject(Hwnd) ? Hwnd.Hwnd : Hwnd, 'int')
}

LargestRectanglePreservingAspectRatio(W1, H1, &W2, &H2) {
    AspectRatio := W1 / H1
    WidthFromHeight := H2 / AspectRatio
    HeightFromWidth := W2 * AspectRatio
    if WidthFromHeight > W2 {
        W2 := W2
        H2 := HeightFromWidth
    } else {
        W2 := WidthFromHeight
        H2 := H2
    }
}

/**
 * @param code -
 * - 1 : Disables calls to SetForegroundWindow
 * - 2 : Enables calls to SetForegroundWindow
 */
LockSetForegroundWindow(code) {
    return DllCall('LockSetForegroundWindow', 'uint', code, 'int')
}

/**
 * @description - Moves the window, scaling for dpi.
 * @param {Integer} Hwnd - The handle of the window.
 * @param {Integer} [X] - The new x-coordinate of the window.
 * @param {Integer} [Y] - The new y-coordinate of the window.
 * @param {Integer} [W] - The new Width of the window.
 * @param {Integer} [H] - The new Height of the window.
 */
MoveScaled(Hwnd, X?, Y?, W?, H?) {
    OriginalDpi := DllCall('GetDpiForWindow', 'ptr', IsObject(Hwnd) ? Hwnd.Hwnd : Hwnd, 'int')
    NewDpi := IsSet(X) || IsSet(Y) ? dMon.Dpi.Pt(X, Y) : OriginalDpi
    if !NewDpi {
        NewDpi := dMon.Dpi.Pt(X * 96 / A_ScreenDpi, Y * 96 / A_ScreenDpi)
    }
    DpiRatio := NewDpi / OriginalDpi
    WinMove(
        IsSet(X) ? X / DpiRatio : unset
      , IsSet(Y) ? Y / DpiRatio : unset
      , IsSet(W) ? W / DpiRatio : unset
      , IsSet(H) ? H / DpiRatio : unset
      , Hwnd
    )
}

/**
 * @description - Uses RegEx to extract the path from a Window's title.
 * @param {String} Hwnd - The handle to the window.
 * @returns {RegExMatchInfo} - If found, returns the `RegExMatchInfo` object obtained from
 * the match. The object has the subcapture groups available:
 * - drive: The drive letter, if present.
 * - dir: The directory path starting from the drive letter.
 * - name: The file name.
 * - ext: The file extension.
 * If not found, returns an empty string.
 * @example
 *  G := Gui(, 'C:\Users\YourName\Documents\AutoHotkey\lib\Win.ahk')
 *  TitleMatch := dWin.PathFromTitle(G.Hwnd)
 *  MsgBox(TitleMatch.drive) ; C
 *  MsgBox(TitleMatch.dir) ; C:\Users\YourName\Documents\AutoHotkey\lib
 *  MsgBox(TitleMatch.file) ; Win
 *  MsgBox(TitleMatch.ext) ; ahk
 * @
 */
PathFromTitle(Hwnd) {
    if RegExMatch(WinGetTitle(Hwnd)
    , '(?<dir>(?:(?<drive>[a-zA-Z]):\\)?(?:[^\r\n\\/:*?"<>|]++\\?)+)\\(?<file>[^\r\n\\/:*?"<>|]+?)\.(?<ext>\w+)\b'
    , &Match) {
        return Match
    }
}

PhysicalToLogicalPoint(Hwnd, X, Y) {
    return DllCall('PhysicalToLogicalPoint', 'ptr', IsObject(Hwnd) ? Hwnd.Hwnd : Hwnd, 'ptr', Point(X, y), 'ptr')
}

RealChildWindowFromPoint(Hwnd, X, Y) {
    return DllCall('RealChildWindowFromPoint', 'ptr', IsObject(Hwnd) ? Hwnd.Hwnd : Hwnd, 'int', (X & 0xFFFFFFFF) | (Y << 32), 'ptr')
}

SetActiveWindow(Hwnd) {
    return DllCall('SetActiveWindow', 'ptr', IsObject(Hwnd) ? Hwnd.Hwnd : Hwnd, 'int')
}

SetForegroundWindow(Hwnd) {
    return DllCall('SetForegroundWindow', 'ptr', IsObject(Hwnd) ? Hwnd.Hwnd : Hwnd, 'int')
}

/**
 * @param {Integer} Hwnd - The handle to the window that will be modified.
 * @param {Integer} HwndNewParent - The handle to the window that will be set as the parent.
 * @returns {Integer} - The handle to the previous parent window.
 */
SetParent(HwndChild, HwndNewParent := 0) {
    return DllCall('SetParent', 'ptr', IsObject(HwndChild) ? HwndChild.Hwnd : HwndChild, 'ptr', IsObject(HwndNewParent) ? HwndNewParent.Hwnd : HwndNewParent, 'ptr')
}

BringWindowToTop(Hwnd) {
    return DllCall('BringWindowToTop', 'ptr', IsObject(Hwnd) ? Hwnd.Hwnd : Hwnd, 'int')
}

GetForegroundWindow() => DllCall('GetForegroundWindow', 'ptr')
