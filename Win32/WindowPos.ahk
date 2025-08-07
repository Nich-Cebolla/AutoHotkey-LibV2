/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/Win32/WindowPos.ahk
    Author: Nich-Cebolla
    License: MIT
*/

/**
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-windowpos}
 */
class WindowPos {
    static __New() {
        this.DeleteProp('__New')
        this.Prototype.Size :=
        A_PtrSize +     ; HWND     hwnd
        A_PtrSize +     ; HWND     hwndInsertAfter
        4 +             ; int      x
        4 +             ; int      y
        4 +             ; int      cx
        4 +             ; int      cy
        4               ; UINT     flags
    }
    __New(Ptr) {
        this.Ptr := Ptr
    }
    Hwnd => NumGet(this, 0, 'ptr')
    HwndInsertAfter => NumGet(this, A_PtrSize, 'ptr')
    X => NumGet(this, A_PtrSize * 2, 'int')
    Y => NumGet(this, A_PtrSize * 2 + 4, 'int')
    W => NumGet(this, A_PtrSize * 2 + 8, 'int')
    H => NumGet(this, A_PtrSize * 2 + 12, 'int')
    Flags => NumGet(this, A_PtrSize * 2 + 16, 'uint')
    Drawframe => this.Flags & 0x0020
    Framechanged => this.Flags & 0x0020
    Hidewindow => this.Flags & 0x0080
    Noactivate => this.Flags & 0x0010
    Nocopybits => this.Flags & 0x0100
    Nomove => this.Flags & 0x0002
    Noownerzorder => this.Flags & 0x0200
    Noredraw => this.Flags & 0x0008
    Noreposition => this.Flags & 0x0200
    Nosendchanging => this.Flags & 0x0400
    Nosize => this.Flags & 0x0001
    Nozorder => this.Flags & 0x0004
    Showwindow => this.Flags & 0x0040
}
