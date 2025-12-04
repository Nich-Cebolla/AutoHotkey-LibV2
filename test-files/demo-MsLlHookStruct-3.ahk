/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/test-files/demo-MsLlHookStruct-3.ahk
    Author: Nich-Cebolla
    License: MIT
*/

/**
 * This is a demo for using
 * {@link https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/Win32/MsLlHookStruct.ahk MsLlHookStruct}
 * to respond to the mouse wheel scrolling.
 */
test()

class test {
    static __New() {
        this.DeleteProp('__New')
        this.OnExitCallback := this.Handle := 0
    }
    static Call() {
        ; Get handle to "user32.dll".
        this.hMod := DllCall('GetModuleHandle', 'Str', 'user32.dll', 'Ptr')
        ; Get address to functions.
        for fn in ['SetWindowsHookExW', 'UnhookWindowsHookEx', 'CallNextHookEx'] {
            this.proc_%fn% := DllCall('GetProcAddress', 'Ptr', this.hMod, 'AStr', fn, 'Ptr')
            if !this.proc_%fn% {
                throw OSError()
            }
        }
        ; Get callback ptr.
        this.MouseHookProcPtr := CallbackCreate(LowLevelMouseProc)

        ; A gui is not necessary to use the library; this is for the example.
        g := this.Gui := Gui()
        g.SetFont('s11 q5', 'Segoe Ui')
        g.Add('Text', , 'Press start then scroll your mouse wheel.`r`n')
        g.Add('Edit', 'w300 r1 vEdtMouseMove')
        g.Add('Edit', 'w300 r10 vEdtGeneral')
        g.Add('Button', 'Section vBtnStart', 'Start').OnEvent('Click', HClickButtonStart)
        g.Add('Button', 'ys vBtnStop', 'Stop').OnEvent('Click', HClickButtonStop)
        g.Add('Button', 'ys vBtnExit', 'Exit').OnEvent('Click', (*) => ExitApp())
        g.Show()

        HClickButtonStart(*) {
            if this.Handle {
                MsgBox('The hook is already installed.')
            } else {
                ; Call `SetWindowsHookExW`.
                this.Handle := DllCall(this.proc_SetWindowsHookExW, 'int', 14, 'ptr', this.MouseHookProcPtr, 'ptr', 0, 'ptr', 0, 'int')
                if !this.Handle {
                    throw OSError()
                }
                ; Set an `OnExit` callback.
                this.OnExitCallback := ObjBindMethod(this, 'Unhook')
                OnExit(this.OnExitCallback, 1)
            }
        }
        HClickButtonStop(*) {
            this.Unhook()
        }
    }
    static Unhook(*) {
        ; Call `UnhookWindowsHookEx`.
        if this.Handle {
            DllCall(this.proc_UnhookWindowsHookEx, 'ptr', this.Handle, 'int')
            this.Handle := 0
        } else {
            MsgBox('The hook is not installed.')
        }
        ; Disable `OnExit` callback.
        if this.OnExitCallback {
            OnExit(this.OnExitCallback, 0)
            this.OnExitCallback := 0
        }
    }
}

/**
 * {@link https://learn.microsoft.com/en-us/windows/win32/winmsg/lowlevelmouseproc}.
 */
LowLevelMouseProc(nCode, wParam, lParam) {
    ; Per the advisement "If nCode is less than zero, the hook procedure must pass the message to the
    ; CallNextHookEx function without further processing and should return the value returned by
    ; CallNextHookEx.", we only process the message when nCode == 0.
    if nCode == 0 {
        ; Get an instance of `MsLlHookStruct`
        ms := MsLlHookStruct(lParam, wParam)
        switch wParam {
            case WM_MOUSEMOVE:
                test.Gui['EdtMouseMove'].Text := ('The mouse moved to ( ' ms.X ', ' ms.Y ' )`n')
            case WM_LBUTTONDOWN:
                text := 'LBUTTON down'
            case WM_LBUTTONUP:
                text := 'LBUTTON up'
            case WM_MOUSEWHEEL:
                ; A positive value indicates that the wheel was rotated forward, away from the user; a
                ; negative value indicates that the wheel was rotated backward, toward the user. One
                ; wheel click is defined as WHEEL_DELTA, which is 120.
                if ms.GetMouseData() > 0 {
                    test.Gui['EdtGeneral'].Text := 'Mouse scrolled up`r`n' test.Gui['EdtGeneral'].Text
                } else {
                    test.Gui['EdtGeneral'].Text := 'Mouse scrolled down`r`n' test.Gui['EdtGeneral'].Text
                }
            case WM_RBUTTONDOWN:
                text := 'RBUTTON down'
            case WM_RBUTTONUP:
                text := 'RBUTTON up'
            case WM_MBUTTONDOWN:
                text := 'MBUTTON down'
            case WM_MBUTTONUP:
                text := 'MBUTTON up'
            case WM_XBUTTONDOWN:
                text := 'XBUTTON down'
            case WM_XBUTTONUP:
                text := 'XBUTTON up'
        }
        if IsSet(text) {
            test.Gui['EdtGeneral'].Text := text ' at ( ' ms.X ', ' ms.Y ')`r`n' test.Gui['EdtGeneral'].Text
        }
    }
    return DllCall(
        test.proc_CallNextHookEx
      , 'ptr', 0
      , 'int', nCode
      , 'uptr', wParam
      , 'ptr', lParam
      , 'ptr'
    )
}

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
     * @param {Integer} Ptr - A pointer to a MSLLHOOKSTRUCT structure. This is the `lParam` of
     * {@link https://learn.microsoft.com/en-us/windows/win32/winmsg/lowlevelmouseproc LowLevelMouseProc}
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
}
