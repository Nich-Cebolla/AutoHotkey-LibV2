/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/test-files/demo-MsLlHookStruct-2.ahk
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
        g.Add('Text', , 'Press start then move your mouse around.`r`n')
        g.Add('Edit', 'w300 r1 vEdt')
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
        _mouseHookStruct := MsLlHookStruct(lParam, wParam)
        ; Only respond to WM_MOUSEWHEEL
        if wParam == 0x020A { ; WM_MOUSEWHEEL
            ; A positive value indicates that the wheel was rotated forward, away from the user; a
            ; negative value indicates that the wheel was rotated backward, toward the user. One
            ; wheel click is defined as WHEEL_DELTA, which is 120.
            test.Gui['Edt'].Text := _mouseHookStruct.GetMouseData()
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
    }
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

            ; WM_XBUTTONDOWN, WM_XBUTTONUP, WM_XBUTTONDBLCLK, WM_NCXBUTTONDOWN, WM_NCXBUTTONUP, WM_NCXBUTTONDBLCLK
            case 0x020B, 0x020C, 0x020D, 0x00AB, 0x00AC, 0x00AD:
                return this.MouseData >> 16
        }
    }
    X => NumGet(this, 0, 'int')
    Y => NumGet(this, 4, 'int')
    MouseData => NumGet(this, 8, 'uint')
    Flags => NumGet(this, 12, 'int')
    Time => NumGet(this, 16, 'int')
    dwExtraInfo => NumGet(this, 16 + A_PtrSize, 'int')
}
