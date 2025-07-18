/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/structs/WINDOWINFO.ahk
    Author: Nich-Cebolla
    License: MIT
*/

; https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/structs/RECT.ahk
#include <Rect>

/**
 * Calls `GetWindowInfo`. The object has a number of properties to make using it easier.
 * - cbSize - 0:4 - The size of this structure.
 * - rcWindow - 4:16 - The coordinates of the window.
 * - rcClient - 20:16 - THe coordinates of the client area.
 * - dwStyle - 36:4 - The window styles.
 * {@link https://learn.microsoft.com/en-us/windows/desktop/winmsg/window-styles}
 * - dwExStyle - 40:4 - The extende window styles.
 * {@link https://learn.microsoft.com/en-us/windows/desktop/winmsg/extended-window-styles}
 * - dwWindowStatus - 44:4 - The window status. Returns `1` if the window is active. Else, `0`.
 * - cxWindowBorders - 48:4 - The width of the window borders in pixels.
 * - cyWindowBorders - 52:4 - The height of the window border in pixels.
 * - atomWindowType - 56:2 - The window class atom.
 * {@link https://learn.microsoft.com/en-us/windows/desktop/api/winuser/nf-winuser-registerclassa}.
 * - wCreatorVersion - 58:2 - The Windows version of the application that created the window.
 */
class WindowInfo extends Buffer {
    static __New() {
        this.DeleteProp('__New')
        Proto := this.Prototype
        Proto.WindowStyles := Map()
        Proto.WindowExStyles := Map()
        Proto.WindowStyles.CaseSense := Proto.WindowExStyles.CaseSense := false
        Proto.WindowStyles.Set(
            'WS_OVERLAPPED', 0x00000000
          , 'WS_POPUP', 0x80000000
          , 'WS_CHILD', 0x40000000
          , 'WS_MINIMIZE', 0x20000000
          , 'WS_VISIBLE', 0x10000000
          , 'WS_DISABLED', 0x08000000
          , 'WS_CLIPSIBLINGS', 0x04000000
          , 'WS_CLIPCHILDREN', 0x02000000
          , 'WS_MAXIMIZE', 0x01000000
          , 'WS_CAPTION', 0x00C00000
          , 'WS_BORDER', 0x00800000
          , 'WS_DLGFRAME', 0x00400000
          , 'WS_VSCROLL', 0x00200000
          , 'WS_HSCROLL', 0x00100000
          , 'WS_SYSMENU', 0x00080000
          , 'WS_THICKFRAME', 0x00040000
          , 'WS_GROUP', 0x00020000
          , 'WS_TABSTOP', 0x00010000
          , 'WS_MINIMIZEBOX', 0x00020000
          , 'WS_MAXIMIZEBOX', 0x00010000
        )
        Proto.WindowExStyles.Set(
            'WS_EX_DLGMODALFRAME', 0x00000001
          , 'WS_EX_NOPARENTNOTIFY', 0x00000004
          , 'WS_EX_TOPMOST', 0x00000008
          , 'WS_EX_ACCEPTFILES', 0x00000010
          , 'WS_EX_TRANSPARENT', 0x00000020
          , 'WS_EX_MDICHILD', 0x00000040
          , 'WS_EX_TOOLWINDOW', 0x00000080
          , 'WS_EX_WINDOWEDGE', 0x00000100
          , 'WS_EX_CLIENTEDGE', 0x00000200
          , 'WS_EX_CONTEXTHELP', 0x00000400
          , 'WS_EX_RIGHT', 0x00001000
          , 'WS_EX_LEFT', 0x00000000
          , 'WS_EX_RTLREADING', 0x00002000
          , 'WS_EX_LTRREADING', 0x00000000
          , 'WS_EX_LEFTSCROLLBAR', 0x00004000
          , 'WS_EX_RIGHTSCROLLBAR', 0x00000000
          , 'WS_EX_CONTROLPARENT', 0x00010000
          , 'WS_EX_STATICEDGE', 0x00020000
          , 'WS_EX_APPWINDOW', 0x00040000
        )
        RectBase.Make(this, 4)
        RectBase.Make(this, 20, 'Client')
    }
    __New(Hwnd) {
        this.Hwnd := Hwnd
        this.Size := 60
        NumPut('uint', 60, this)
        this()
    }
    Call() {
        if !DllCall('GetWindowInfo', 'ptr', this.Hwnd, 'ptr', this, 'int') {
            throw OSError()
        }
    }
    /**
     * @description - Input the desired client area and `AdjustWindowRectEx` will change the window's
     * size and to accommodate the desired client area, accounting for the window's characteristics.
     * Optionally include new position values to update the position with one function call. This
     * will update the window's size and change the value of the rcWindow member (bytes 4 - 20).
     * @param {Boolean} [HasMenu = false] - Set to true if the window has a menu bar.
     */
    AdjustWindowRectEx(X?, Y?, W?, H?, HasMenu := false) {
        RECT_Move(4, this, X ?? unset, Y ?? unset, W ?? unset, H ?? unset)
        DllCall('AdjustWindowRectEx', 'ptr', this.ptr + 4, 'uint', this.Style, 'int', HasMenu, 'uint', this.ExStyle, 'int')
    }
    GetClientRect() {
        return Rect.FromPtr(this.ptr + 20)
    }
    GetWindowRect() {
        return Rect.FromPtr(this.ptr + 4)
    }
    GetExStyles() {
        style := this.ExStyle
        result := []
        result.Capacity := this.WindowExStyles.Count
        for k, v in this.WindowExStyles {
            if style & v {
                result.Push(k)
            }
        }
        result.Capacity := result.Length
        return result
    }
    GetStyles() {
        style := this.Style
        result := []
        result.Capacity := this.WindowStyles.Count
        for k, v in this.WindowStyles {
            if style & v {
                result.Push(k)
            }
        }
        result.Capacity := result.Length
        return result
    }
    HasStyle(Name) {
        return this.Style & this.WindowStyles.Get(Name)
    }
    HasExStyle(Name) {
        return this.ExStyle & this.WindowExStyles.Get(Name)
    }

    Atom => NumGet(this, 56, 'short')
    BorderHeight => NumGet(this, 52, 'int')
    BorderWidth => NumGet(this, 48, 'int')
    CreatorVersion => NumGet(this, 58, 'short')
    ExStyle => NumGet(this, 40, 'uint')
    Status => NumGet(this, 44, 'int')
    Style => NumGet(this, 36, 'uint')
}
