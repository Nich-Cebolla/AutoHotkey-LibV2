
/**
 * @param {Integer} hwndChild - The handle to the window that will have its parent changed.
 * @param {Integer} [hwndNewParent = 0] - One of the following:
 * - 0 : The desktop window becomes the parent to `hwndChild`.
 * - -3 (HWND_MESSAGE) - `hwndChild` becomes a message-only window.
 * - The handle to another window - `hwndNewParent` becomes the parent to `hwndChild`.
 * @returns {Integer} - The previous parent window's handle.
 */
WinSetParent(hwndChild, hwndNewParent := 0) {
    oldParent := DllCall('SetParent', 'ptr', hwndChild, 'ptr', hwndNewParent, 'ptr')
    if uiStateFlags := SendMessage(0x0129, 0, 0, hwndNewParent) { ; WM_QUERYUISTATE
        ; UIS_SET = 1
        SendMessage(0x0128, (1 & 0xFFFF) | (uiStateFlags << 16), 0, hwndChild) ; WM_UPDATEUISTATE
    }
    return oldParent
}
