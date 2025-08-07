/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/Win32/MsLlHookStruct.ahk
    Author: Nich-Cebolla
    License: MIT
*/

/**
 * @classdesc -
 * For use with `SetWindowsHookExW`. Low-level hooks requires that `SetWindowsHookExE` is
 * called from a DLL. I have prepared a simple DLL that can be called from AHK. You can clone
 * the repo here {@link https://github.com/Nich-Cebolla/MouseHook-LL}.
 *
 * To use:
 * 1. Clone the repo https://github.com/Nich-Cebolla/MouseHook-LL
 *   - `git clone https://github.com/Nich-Cebolla/MouseHook-LL`
 * 2. Compile the dll.
 * 3. Define a LowLevelMouseProc function. See
 * {@link https://learn.microsoft.com/en-us/windows/win32/winmsg/lowlevelmouseproc} for information.
 * In the body of your function, get an `MsLlHookStruct` object
 * `_msLlHookStruct := MsLlHookStruct(lParam, wParam)`.
 * 4. Get a pointer to your function using `CallbackCreate`.
 * {@link https://www.autohotkey.com/docs/v2/lib/CallbackCreate.htm}.
 * 5. Call the dll function StartHook `DllCall("path\to\MouseHook-LL.dll\StartHook", "ptr", LowLevelMouseHookProcPtr, "int")`.
 * 6. Set an `OnExit` callback to call StopHook `DllCall("path\to\MouseHook-LL.dll\StaStopHook", "int")`.
 * {@link https://www.autohotkey.com/docs/v2/lib/OnExit.htm}.
 * 7. When you need to uninstall the hook, call StopHook and also disable the `OnExit` callback.
 *
 * See file "test-files\demo-MsLlHookStruct.ahk" for a working demo. You'll need to have compiled
 * the dll first.
 *
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-msllhookstruct}
 *
 * There are two other libraries for setting mouse hooks in this repo:
 * {@link https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/Win32/MouseHookStruct.ahk}.
 * {@link https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/Win32/MouseHook.ahk}.
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
            case 0x020E:
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
