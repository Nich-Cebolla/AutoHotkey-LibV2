/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/DwmGetWindowRect.ahk
    Author: Nich-Cebolla
    License: MIT
*/

/**
 * @description - Calls `DwmGetWindowAttribute` passing DWMA_EXTENDED_FRAME_BOUNDS to dwAttribute.
 * The purpose of this function is to get a window's rectangle not including the extra padding
 * added by the invisible resize borders described here:
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getwindowrect}.
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/dwmapi/nf-dwmapi-dwmgetwindowattribute}.
 */
DwmGetWindowRect(Hwnd, &OutX?, &OutY?, &OutW?, &OutH?, DpiScale := true) {
    rc := Buffer(16)
    if hresult := DllCall(
        'Dwmapi.dll\DwmGetWindowAttribute'
      , 'ptr', Hwnd
      , 'uint', 9       ; DWMWA_EXTENDED_FRAME_BOUNDS
      , 'ptr', rc
      , 'uint', rc.Size
      , 'uint'
    ) {
        throw oserror('DwmGetWindowAttribute failed.', -1, hresult)
    }
    if DpiScale {
        DllCall('PhysicalToLogicalPointForPerMonitorDPI', 'ptr', Hwnd, 'ptr', rc, 'int')
        DllCall('PhysicalToLogicalPointForPerMonitorDPI', 'ptr', Hwnd, 'ptr', rc.Ptr + 8, 'int')
    }
    OutX := NumGet(rc, 0, 'int')
    OutY := NumGet(rc, 4, 'int')
    OutW := NumGet(rc, 8, 'int') - OutX
    OutH := NumGet(rc, 12, 'int') - OutY
    return rc
}
