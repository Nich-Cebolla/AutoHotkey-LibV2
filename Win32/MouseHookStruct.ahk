/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/Win32/MouseHookStruct.ahk
    Author: Nich-Cebolla
    License: MIT
*/

/**
 * See file "test-files\demo-MouseHookStruct.ahk" for a demo using this class.
 */
class MouseHookStruct {
    static __New() {
        this.DeleteProp('__New')
        this.Prototype.Size :=
        8 +         ; POINT         pt
        A_PtrSize + ; HWND          hwnd
        A_PtrSize + ; UINT          wHitTestCode    4 extra bytes for alignment on x64 systems
        A_PtrSize   ; ULONG_PTR     dwExtraInfo
        this.Prototype.HitTestMap := Map(
            18, 'Border'        ; In the border of a window that does not have a sizing border.
          , 15, 'Bottom'        ; In the lower-horizontal border of a resizable window (the user can click the mouse to resize the window vertically).
          , 16, 'Bottomleft'    ; In the lower-left corner of a border of a resizable window (the user can click the mouse to resize the window diagonally).
          , 17, 'Bottomright'   ; In the lower-right corner of a border of a resizable window (the user can click the mouse to resize the window diagonally).
          ,  2, 'Caption'       ; In a title bar.
          ,  1, 'Client'        ; In a client area.
          , 20, 'Close'         ; In a Close button.
          , -2, 'Error'         ; On the screen background or on a dividing line between windows (same as HTNOWHERE, except that the DefWindowProc function produces a system beep to indicate an error).
          ,  4, 'Growbox'       ; In a size box (same as HTSIZE).
          , 21, 'Help'          ; In a Help button.
          ,  6, 'Hscroll'       ; In a horizontal scroll bar.
          , 10, 'Left'          ; In the left border of a resizable window (the user can click the mouse to resize the window horizontally).
          ,  5, 'Menu'          ; In a menu.
          ,  9, 'Maxbutton'     ; In a Maximize button.
          ,  8, 'Minbutton'     ; In a Minimize button.
          ,  0, 'Nowhere'       ; On the screen background or on a dividing line between windows.
          ,  8, 'Reduce'        ; In a Minimize button.
          , 11, 'Right'         ; In the right border of a resizable window (the user can click the mouse to resize the window horizontally).
          ,  4, 'Size'          ; In a size box (same as HTGROWBOX).
          ,  3, 'Sysmenu'       ; In a window menu or in a Close button in a child window.
          , 12, 'Top'           ; In the upper-horizontal border of a window.
          , 13, 'Topleft'       ; In the upper-left corner of a window border.
          , 14, 'Topright'      ; In the upper-right corner of a window border.
          , -1, 'Transparent'   ; In a window currently covered by another window in the same thread (the message will be sent to underlying windows in the same thread until one of them returns a code that is not HTTRANSPARENT).
          ,  7, 'Vscroll'       ; In the vertical scroll bar.
          ,  9, 'Zoom'          ; In a Maximize button.
        )
    }
    /**
     * Calls `SetWindowsHookExW` passing WH_MOUSE to `idHook`
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setwindowshookexw}.
     * {@link https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/Win32/WindowsHook.ahk}.
     *
     * When you pass WH_MOUSE to `SetWindowsHookExW`, your function will receive information
     * about events that occur when the mouse cursor is over an AHK window associated with the
     * AHK process which called `SetWindowsHookExW`.
     *
     * If you need information about the mouse's movement irrespective of what window the mouse is
     * over, see the file "MouseHook.ahk"
     * {@link https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/Win32/MouseHook.ahk}.
     *
     * Here ae the various mouse messages (these would be passed to the `wParam` member of the MOUSEPROC
     * function):
     *
     * |  Hex Code  |  Symbol            |  Meaning                          |
     * |  ----------|--------------------|---------------------------------  |
     * |  0x0200    |  WM_MOUSEMOVE      |  Mouse moved                      |
     * |  0x0201    |  WM_LBUTTONDOWN    |  Left button down                 |
     * |  0x0202    |  WM_LBUTTONUP      |  Left button up                   |
     * |  0x0203    |  WM_LBUTTONDBLCLK  |  Left button double click         |
     * |  0x0204    |  WM_RBUTTONDOWN    |  Right button down                |
     * |  0x0205    |  WM_RBUTTONUP      |  Right button up                  |
     * |  0x0206    |  WM_RBUTTONDBLCLK  |  Right button double click        |
     * |  0x0207    |  WM_MBUTTONDOWN    |  Middle button down               |
     * |  0x0208    |  WM_MBUTTONUP      |  Middle button up                 |
     * |  0x0209    |  WM_MBUTTONDBLCLK  |  Middle button double click       |
     * |  0x020A    |  WM_MOUSEWHEEL     |  Vertical scroll (wheel moved)    |
     * |  0x020B    |  WM_XBUTTONDOWN    |  XButton1/XButton2 down           |
     * |  0x020E    |  WM_MOUSEHWHEEL    |  Horizontal scroll (wheel moved)  |
     *
     * @class
     */
    __New(Ptr) {
        this.Ptr := Ptr
    }
    X => NumGet(this.Ptr, 0, 'int')
    Y => NumGet(this.Ptr, 4, 'int')
    Hwnd => NumGet(this.Ptr, 8, 'ptr')
    HitTestCode => NumGet(this.Ptr, 8 + A_PtrSize, 'uint')
    HitTestStr => this.HitTestMap.Get(this.HitTestCode)
    ExtraInfo => NumGet(this.Ptr, 8 + A_PtrSize * 2, 'ptr')
}
