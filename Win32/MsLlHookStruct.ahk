/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/Win32/MsLlHookStruct.ahk
    Author: Nich-Cebolla
    License: MIT
*/

/**
 * @classdesc -
 * For use with `SetWindowsHookExW`.
 *
 * To use:
 * 1. Define a LowLevelMouseProc function. See
 * {@link https://learn.microsoft.com/en-us/windows/win32/winmsg/lowlevelmouseproc} for information.
 * In the body of your function, get an `MsLlHookStruct` object
 * `_msLlHookStruct := MsLlHookStruct(lParam, wParam)`.
 * 2. Get a pointer to your function using `CallbackCreate`.
 * {@link https://www.autohotkey.com/docs/v2/lib/CallbackCreate.htm}.
 * 3. Call `SetWindowsHookExW`.
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setwindowshookexw}.
 * 4. Set an `OnExit` callback to call StopHook `DllCall("path\to\MouseHook-LL.dll\StopHook", "int")`.
 * {@link https://www.autohotkey.com/docs/v2/lib/OnExit.htm}.
 * 5. When you need to uninstall the hook, call StopHook and also disable the `OnExit` callback.
 *
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-msllhookstruct}
 *
 * There is one other library for setting a mouse hook in this repo:
 * {@link https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/Win32/MouseHookStruct.ahk}.
 */
class MsLlHookStruct {
    static __New() {
        this.DeleteProp('__New')
        this.Prototype.Size :=
        8 +                 ; POINT                                     pt              0
        4 +                 ; DWORD                                     mouseData       8
        4 +                 ; DWORD                                     flags           12
        A_PtrSize +         ; DWORD + 4 bytes for alignment on x64      time            16
        A_PtrSize           ; ULONG_PTR                                 dwExtraInfo     16 + A_PtrSize
        MsLlHookStruct_SetConstants()
    }
    /**
     * @desc - A wrapper around
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-msllhookstruct MSLLHOOKSTRUCT}.
     *
     * Relevant constants:
     *
     * |  Name                |  Value   |  Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
     * |  --------------------|----------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------  |
     * |  WM_CAPTURECHANGED   |  0x0215  |  Sent to the window that is losing the mouse capture. A window receives this message through its [WindowProc](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nc-winuser-wndproc) function.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
     * |  WM_LBUTTONDBLCLK    |  0x0203  |  Posted when the user double-clicks the left mouse button while the cursor is in the client area of a window. If the mouse is not captured, the message is posted to the window beneath the cursor. Otherwise, the message is posted to the window that has captured the mouse. A window receives this message through its [WindowProc](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nc-winuser-wndproc) function.                                                                                                                                                                                                                                                            |
     * |  WM_LBUTTONDOWN      |  0x0201  |  Posted when the user presses the left mouse button while the cursor is in the client area of a window. If the mouse is not captured, the message is posted to the window beneath the cursor. Otherwise, the message is posted to the window that has captured the mouse. A window receives this message through its [WindowProc](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nc-winuser-wndproc) function.                                                                                                                                                                                                                                                                  |
     * |  WM_LBUTTONUP        |  0x0202  |  Posted when the user releases the left mouse button while the cursor is in the client area of a window. If the mouse is not captured, the message is posted to the window beneath the cursor. Otherwise, the message is posted to the window that has captured the mouse. A window receives this message through its [WindowProc](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nc-winuser-wndproc) function.                                                                                                                                                                                                                                                                 |
     * |  WM_MBUTTONDBLCLK    |  0x0209  |  Posted when the user double-clicks the middle mouse button while the cursor is in the client area of a window. If the mouse is not captured, the message is posted to the window beneath the cursor. Otherwise, the message is posted to the window that has captured the mouse. A window receives this message through its [WindowProc](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nc-winuser-wndproc) function.                                                                                                                                                                                                                                                          |
     * |  WM_MBUTTONDOWN      |  0x0207  |  Posted when the user presses the middle mouse button while the cursor is in the client area of a window. If the mouse is not captured, the message is posted to the window beneath the cursor. Otherwise, the message is posted to the window that has captured the mouse. A window receives this message through its [WindowProc](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nc-winuser-wndproc) function.                                                                                                                                                                                                                                                                |
     * |  WM_MBUTTONUP        |  0x0208  |  Posted when the user releases the middle mouse button while the cursor is in the client area of a window. If the mouse is not captured, the message is posted to the window beneath the cursor. Otherwise, the message is posted to the window that has captured the mouse. A window receives this message through its [WindowProc](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nc-winuser-wndproc) function.                                                                                                                                                                                                                                                               |
     * |  WM_MOUSEACTIVATE    |  0x0021  |  Sent when the cursor is in an inactive window and the user presses a mouse button. The parent window receives this message only if the child window passes it to the [DefWindowProc](https://learn.microsoft.com/en-us/windows/desktop/api/winuser/nf-winuser-defwindowproca) function. A window receives this message through its [WindowProc](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nc-winuser-wndproc) function.                                                                                                                                                                                                                                                   |
     * |  WM_MOUSEHOVER       |  0x02A1  |  Posted to a window when the cursor hovers over the client area of the window for the period of time specified in a prior call to [TrackMouseEvent](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-trackmouseevent). A window receives this message through its [WindowProc](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nc-winuser-wndproc) function.                                                                                                                                                                                                                                                                                               |
     * |  WM_MOUSEHWHEEL      |  0x020E  |  Sent to the active window when the mouse's horizontal scroll wheel is tilted or rotated. The [DefWindowProc](https://learn.microsoft.com/en-us/windows/desktop/api/winuser/nf-winuser-defwindowproca) function propagates the message to the window's parent. There should be no internal forwarding of the message, since DefWindowProc propagates it up the parent chain until it finds a window that processes it. A window receives this message through its [WindowProc](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nc-winuser-wndproc) function.                                                                                                                     |
     * |  WM_MOUSELEAVE       |  0x02A3  |  Posted to a window when the cursor leaves the client area of the window specified in a prior call to [TrackMouseEvent](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-trackmouseevent). A window receives this message through its [WindowProc](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nc-winuser-wndproc) function.                                                                                                                                                                                                                                                                                                                           |
     * |  WM_MOUSEMOVE        |  0x0200  |  Posted to a window when the cursor moves. If the mouse is not captured, the message is posted to the window that contains the cursor. Otherwise, the message is posted to the window that has captured the mouse. A window receives this message through its [WindowProc](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nc-winuser-wndproc) function.                                                                                                                                                                                                                                                                                                                         |
     * |  WM_MOUSEWHEEL       |  0x020A  |  Sent to the focus window when the mouse wheel is rotated. The [DefWindowProc](https://learn.microsoft.com/en-us/windows/desktop/api/winuser/nf-winuser-defwindowproca) function propagates the message to the window's parent. There should be no internal forwarding of the message, since DefWindowProc propagates it up the parent chain until it finds a window that processes it. A window receives this message through its [WindowProc](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nc-winuser-wndproc) function.                                                                                                                                                    |
     * |  WM_NCHITTEST        |  0x0084  |  Sent to a window in order to determine what part of the window corresponds to a particular screen coordinate. This can happen, for example, when the cursor moves, when a mouse button is pressed or released, or in response to a call to a function such as [WindowFromPoint](https://learn.microsoft.com/en-us/windows/desktop/api/winuser/nf-winuser-windowfrompoint). If the mouse is not captured, the message is sent to the window beneath the cursor. Otherwise, the message is sent to the window that has captured the mouse. A window receives this message through its [WindowProc](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nc-winuser-wndproc) function.  |
     * |  WM_NCLBUTTONDBLCLK  |  0x00A3  |  Posted when the user double-clicks the left mouse button while the cursor is within the nonclient area of a window. This message is posted to the window that contains the cursor. If a window has captured the mouse, this message is not posted. A window receives this message through its [WindowProc](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nc-winuser-wndproc) function.                                                                                                                                                                                                                                                                                        |
     * |  WM_NCLBUTTONDOWN    |  0x00A1  |  Posted when the user presses the left mouse button while the cursor is within the nonclient area of a window. This message is posted to the window that contains the cursor. If a window has captured the mouse, this message is not posted. A window receives this message through its [WindowProc](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nc-winuser-wndproc) function.                                                                                                                                                                                                                                                                                              |
     * |  WM_NCLBUTTONUP      |  0x00A2  |  Posted when the user releases the left mouse button while the cursor is within the nonclient area of a window. This message is posted to the window that contains the cursor. If a window has captured the mouse, this message is not posted. A window receives this message through its [WindowProc](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nc-winuser-wndproc) function.                                                                                                                                                                                                                                                                                             |
     * |  WM_NCMBUTTONDBLCLK  |  0x00A9  |  Posted when the user double-clicks the middle mouse button while the cursor is within the nonclient area of a window. This message is posted to the window that contains the cursor. If a window has captured the mouse, this message is not posted. A window receives this message through its [WindowProc](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nc-winuser-wndproc) function.                                                                                                                                                                                                                                                                                      |
     * |  WM_NCMBUTTONDOWN    |  0x00A7  |  Posted when the user presses the middle mouse button while the cursor is within the nonclient area of a window. This message is posted to the window that contains the cursor. If a window has captured the mouse, this message is not posted. A window receives this message through its [WindowProc](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nc-winuser-wndproc) function.                                                                                                                                                                                                                                                                                            |
     * |  WM_NCMBUTTONUP      |  0x00A8  |  Posted when the user releases the middle mouse button while the cursor is within the nonclient area of a window. This message is posted to the window that contains the cursor. If a window has captured the mouse, this message is not posted. A window receives this message through its [WindowProc](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nc-winuser-wndproc) function.                                                                                                                                                                                                                                                                                           |
     * |  WM_NCMOUSEHOVER     |  0x02A0  |  Posted to a window when the cursor hovers over the nonclient area of the window for the period of time specified in a prior call to [TrackMouseEvent](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-trackmouseevent). A window receives this message through its [WindowProc](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nc-winuser-wndproc) function.                                                                                                                                                                                                                                                                                            |
     * |  WM_NCMOUSELEAVE     |  0x02A2  |  Posted to a window when the cursor leaves the nonclient area of the window specified in a prior call to [TrackMouseEvent](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-trackmouseevent). A window receives this message through its [WindowProc](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nc-winuser-wndproc) function.                                                                                                                                                                                                                                                                                                                        |
     * |  WM_NCMOUSEMOVE      |  0x00A0  |  Posted to a window when the cursor is moved within the nonclient area of the window. This message is posted to the window that contains the cursor. If a window has captured the mouse, this message is not posted. A window receives this message through its [WindowProc](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nc-winuser-wndproc) function.                                                                                                                                                                                                                                                                                                                       |
     * |  WM_NCRBUTTONDBLCLK  |  0x00A6  |  Posted when the user double-clicks the right mouse button while the cursor is within the nonclient area of a window. This message is posted to the window that contains the cursor. If a window has captured the mouse, this message is not posted. A window receives this message through its [WindowProc](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nc-winuser-wndproc) function.                                                                                                                                                                                                                                                                                       |
     * |  WM_NCRBUTTONDOWN    |  0x00A4  |  Posted when the user presses the right mouse button while the cursor is within the nonclient area of a window. This message is posted to the window that contains the cursor. If a window has captured the mouse, this message is not posted. A window receives this message through its [WindowProc](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nc-winuser-wndproc) function.                                                                                                                                                                                                                                                                                             |
     * |  WM_NCRBUTTONUP      |  0x00A5  |  Posted when the user releases the right mouse button while the cursor is within the nonclient area of a window. This message is posted to the window that contains the cursor. If a window has captured the mouse, this message is not posted. A window receives this message through its [WindowProc](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nc-winuser-wndproc) function.                                                                                                                                                                                                                                                                                            |
     * |  WM_NCXBUTTONDBLCLK  |  0x00AD  |  Posted when the user double-clicks either XBUTTON1 or XBUTTON2 while the cursor is in the nonclient area of a window. This message is posted to the window that contains the cursor. If a window has captured the mouse, this message is not posted. A window receives this message through its [WindowProc](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nc-winuser-wndproc) function.                                                                                                                                                                                                                                                                                      |
     * |  WM_NCXBUTTONDOWN    |  0x00AB  |  Posted when the user presses either XBUTTON1 or XBUTTON2 while the cursor is in the nonclient area of a window. This message is posted to the window that contains the cursor. If a window has captured the mouse, this message is not posted. A window receives this message through its [WindowProc](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nc-winuser-wndproc) function.                                                                                                                                                                                                                                                                                            |
     * |  WM_NCXBUTTONUP      |  0x00AC  |  Posted when the user releases either XBUTTON1 or XBUTTON2 while the cursor is in the nonclient area of a window. This message is posted to the window that contains the cursor. If a window has captured the mouse, this message is not posted. A window receives this message through its [WindowProc](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nc-winuser-wndproc) function.                                                                                                                                                                                                                                                                                           |
     * |  WM_RBUTTONDBLCLK    |  0x0206  |  Posted when the user double-clicks the right mouse button while the cursor is in the client area of a window. If the mouse is not captured, the message is posted to the window beneath the cursor. Otherwise, the message is posted to the window that has captured the mouse. A window receives this message through its [WindowProc](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nc-winuser-wndproc) function.                                                                                                                                                                                                                                                           |
     * |  WM_RBUTTONDOWN      |  0x0204  |  Posted when the user presses the right mouse button while the cursor is in the client area of a window. If the mouse is not captured, the message is posted to the window beneath the cursor. Otherwise, the message is posted to the window that has captured the mouse. A window receives this message through its [WindowProc](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nc-winuser-wndproc) function.                                                                                                                                                                                                                                                                 |
     * |  WM_RBUTTONUP        |  0x0205  |  Posted when the user releases the right mouse button while the cursor is in the client area of a window. If the mouse is not captured, the message is posted to the window beneath the cursor. Otherwise, the message is posted to the window that has captured the mouse. A window receives this message through its [WindowProc](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nc-winuser-wndproc) function.                                                                                                                                                                                                                                                                |
     * |  WM_XBUTTONDBLCLK    |  0x020D  |  Posted when the user double-clicks either XBUTTON1 or XBUTTON2 while the cursor is in the client area of a window. If the mouse is not captured, the message is posted to the window beneath the cursor. Otherwise, the message is posted to the window that has captured the mouse. A window receives this message through its [WindowProc](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nc-winuser-wndproc) function.                                                                                                                                                                                                                                                      |
     * |  WM_XBUTTONDOWN      |  0x020B  |  Posted when the user presses either XBUTTON1 or XBUTTON2 while the cursor is in the client area of a window. If the mouse is not captured, the message is posted to the window beneath the cursor. Otherwise, the message is posted to the window that has captured the mouse. A window receives this message through its [WindowProc](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nc-winuser-wndproc) function.                                                                                                                                                                                                                                                            |
     * |  WM_XBUTTONUP        |  0x020C  |  Posted when the user releases either XBUTTON1 or XBUTTON2 while the cursor is in the client area of a window. If the mouse is not captured, the message is posted to the window beneath the cursor. Otherwise, the message is posted to the window that has captured the mouse. A window receives this message through its [WindowProc](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nc-winuser-wndproc) function.                                                                                                                                                                                                                                                           |
     *
     * Additional constants:
     *
     * |  Name         |  Value   |  Description                       |
     * |  -------------|----------|----------------------------------  |
     * |  MK_CONTROL   |  0x0008  |  The CTRL key is down.             |
     * |  MK_LBUTTON   |  0x0001  |  The left mouse button is down.    |
     * |  MK_MBUTTON   |  0x0010  |  The middle mouse button is down.  |
     * |  MK_RBUTTON   |  0x0002  |  The right mouse button is down.   |
     * |  MK_SHIFT     |  0x0004  |  The SHIFT key is down.            |
     * |  MK_XBUTTON1  |  0x0020  |  The XBUTTON1 is down.             |
     * |  MK_XBUTTON2  |  0x0040  |  The XBUTTON2 is down.             |
     * |  WHEEL_DELTA  |  120     |  Value for rolling one detent.     |
     *
     * @param {Integer} Ptr - A pointer to a MSLLHOOKSTRUCT structure. This is the `lParam` of
     * {@link https://learn.microsoft.com/en-us/windows/win32/winmsg/lowlevelmouseproc LowLevelMouseProc}.
     *
     * See {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-msllhookstruct MSLLHOOKSTRUCT}.
     *
     * @param {Integer} uMsg - The window message. This is the `wParam` of
     * {@link https://learn.microsoft.com/en-us/windows/win32/winmsg/lowlevelmouseproc LowLevelMouseProc}
     */
    __New(Ptr, uMsg) {
        this.Ptr := Ptr
        this.Msg := uMsg
    }
    /**
     * If the message is WM_MOUSEWHEEL, the high-order word of this member is the wheel delta. The
     * low-order word is reserved. A positive value indicates that the wheel was rotated forward,
     * away from the user; a negative value indicates that the wheel was rotated backward, toward
     * the user. One wheel click is defined as WHEEL_DELTA, which is 120.
     *
     * If the message is WM_XBUTTONDOWN, WM_XBUTTONUP, WM_XBUTTONDBLCLK, WM_NCXBUTTONDOWN,
     * WM_NCXBUTTONUP, or WM_NCXBUTTONDBLCLK, the high-order word specifies which X button was
     * pressed or released, and the low-order word is reserved. This value can be one or more of
     * the following values. Otherwise, mouseData is not used.
     *
     * - XBUTTON1 - 0x0001 - The first X button was pressed or released.
     * - XBUTTON2 - 0x0002 - The second X button was pressed or released.
     */
    GetMouseData() {
        switch this.Msg {
            ; WM_MOUSEWHEEL
            case 0x020A:
                value := this.MouseData >> 16
                return (value & 0x8000) ? value - 0x10000 : value
            default: return this.MouseData >> 16
        }
    }
    X => NumGet(this, 0, 'int')
    Y => NumGet(this, 4, 'int')
    MouseData => NumGet(this, 8, 'uint')
    Flags => NumGet(this, 12, 'int')
    Time => NumGet(this, 16, 'int')
    dwExtraInfo => NumGet(this, 16 + A_PtrSize, 'int')
}

MsLlHookStruct_SetConstants(force := false) {
    global
    if IsSet(MsLlHookStruct_constants_set) && !force {
        return
    }
    ; https://learn.microsoft.com/en-us/windows/win32/inputdev/wm-lbuttondown

    ; ; The CTRL key is down.
    ; MK_CONTROL := 0x0008
    ; ; The left mouse button is down.
    ; MK_LBUTTON := 0x0001
    ; ; The middle mouse button is down.
    ; MK_MBUTTON := 0x0010
    ; ; The right mouse button is down.
    ; MK_RBUTTON := 0x0002
    ; ; The SHIFT key is down.
    ; MK_SHIFT := 0x0004
    ; ; The XBUTTON1 is down.
    ; MK_XBUTTON1 := 0x0020
    ; ; The XBUTTON2 is down.
    ; MK_XBUTTON2 := 0x0040

    WM_MOUSEMOVE := 0x0200
    WM_LBUTTONDOWN := 0x0201
    WM_LBUTTONUP := 0x0202
    WM_MOUSEWHEEL := 0x020A
    WM_RBUTTONDOWN := 0x0204
    WM_RBUTTONUP := 0x0205
    WM_MBUTTONDOWN := 0x0207
    WM_MBUTTONUP := 0x0208
    WM_MBUTTONDBLCLK := 0x0209
    WM_MOUSEHWHEEL := 0x020E
    WM_XBUTTONDOWN := 0x020B
    WM_XBUTTONUP := 0x020C
    ; WM_XBUTTONDBLCLK := 0x020D
    ; WM_LBUTTONDBLCLK := 0x0203
    ; WM_RBUTTONDBLCLK := 0x0206
    ; WHEEL_DELTA := 120
    ; WM_NCXBUTTONDOWN := 0x00AB
    ; WM_NCXBUTTONUP := 0x00AC
    ; WM_NCXBUTTONDBLCLK := 0x00AD
    MsLlHookStruct_constants_set := true
}
