/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/Win32/WindowSubclass.ahk
    Author: Nich-Cebolla
    License: MIT
*/

class WindowSubclass {
    static __New() {
        this.DeleteProp('__New')
        proto := this.Prototype
        proto.dwRefData :=
        proto.hwndSubclass :=
        proto.isInstalled :=
        proto.pfnSubclass :=
        proto.uIdSubclass :=
        proto.__flag_callbackFree := 0

        hmod := DllCall('GetModuleHandleW', 'wstr', 'Comctl32', 'ptr')
        global g_comctl32_DefSubclassProc := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'DefSubclassProc', 'ptr')
        , g_comctl32_SetWindowSubclass := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'SetWindowSubclass', 'ptr')
        , g_comctl32_RemoveWindowSubclass := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'RemoveWindowSubclass', 'ptr')
    }
    /**
     * @desc - Calls {@link https://learn.microsoft.com/en-us/windows/win32/api/commctrl/nf-commctrl-setwindowsubclass SetWindowSubclass}
     *
     * A subclass allows your code to intercept every message that gets sent to a window that was
     * created in the AHK process. This offers complete control in how to respond to the messages.
     *
     * Further reading:
     *
     * - {@link https://learn.microsoft.com/en-us/windows/win32/controls/subclassing-overview}
     * - {@link https://learn.microsoft.com/en-us/windows/win32/api/commctrl/nf-commctrl-defsubclassproc}
     *
     * @class
     *
     * @param {*} SubclassProc - Tthe function that will be used as the subclass procedure, or the
     * pointer to the function.
     *
     * If `SubclassProc` is a function object, it is passed to
     * {@link https://www.autohotkey.com/docs/v2/lib/CallbackCreate.htm CallbackCreate}, passing
     * option "F" to the "Options" parameter.
     *
     * See {@link https://learn.microsoft.com/en-us/windows/win32/api/commctrl/nc-commctrl-subclassproc}
     * for details.
     *
     * @param {Integer} uIdSubclass - Serves as the unique id for this subclass.
     *
     * @param {Integer} [HwndSubclass = A_ScriptHwnd] - The handle to the window for which `SubclassProc`
     * will intercept its messages and notifications. Note that the window must have been
     * created by the AHK process. The default is
     * {@link https://www.autohotkey.com/docs/v2/Variables.htm#ScriptHwnd A_ScriptHwnd}.
     *
     * @param {Buffer|Integer} [dwRefData] - If set, a buffer containing data that will be passed to the
     * subclass procedure, or a pointer to a memory address containing the data, or the data itself
     * if the data can be represented as a ptr-sized value.
     *
     * To later change this option, call {@link WindowSubclass.Prototype.SetRefData}.
     *
     * @param {Boolean} [DeferActivation = false] - If true, `SetWindowSubclass` is not called; your
     * code must call {@link WindowSubclass.Prototype.Install}.
     */
    __New(SubclassProc, uIdSubclass, HwndSubclass := A_ScriptHwnd, dwRefData?, DeferActivation := false) {
        this.uIdSubclass := uIdSubclass
        this.hwndSubclass := HwndSubclass
        if IsSet(dwRefData) {
            this.dwRefData := dwRefData
        }
        if IsObject(SubclassProc) {
            this.pfnSubclass := CallbackCreate(SubclassProc, 'F')
            this.__flag_callbackFree := true
        } else {
            this.pfnSubclass := SubclassProc
        }
        if !DeferActivation {
            this.Install()
        }
    }
    /**
     * @desc - If the subclass has not been installed, installs it. If the subclass has already
     * been installed, this has no effect.
     *
     * @throws {OSError} - "The call to `SetWindowSubclass` failed."
     */
    Install() {
        if !this.isInstalled {
            if DllCall(
                g_comctl32_SetWindowSubclass
              , 'ptr', this.hwndSubclass
              , 'ptr', this.pfnSubclass
              , 'uptr', this.uIdSubclass
              , 'uptr', this.dwRefData
              , 'int'
            ) {
                this.isInstalled := true
            } else {
                throw OSError('The call to ``SetWindowSubclass`` failed.')
            }
        }
    }
    /**
     * @desc - Changes the value of property {@link WindowSubclass#dwRefData}. Then, if the window
     * subclass is installed, uninstalls it and reinstalls it using the new value.
     *
     * @param {Buffer|Integer} dwRefData - A buffer containing data that will be passed to the
     * subclass procedure, or a pointer to a memory address containing the data.
     *
     * @returns {Buffer|Integer} - The previous value.
     */
    SetRefData(dwRefData) {
        previous := this.dwRefData
        this.dwRefData := dwRefData
        if this.isInstalled {
            this.Uninstall()
            this.Install()
        }
        return previous
    }
    /**
     * @desc - If the window subclass is installed, uninstalls it by calling
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/commctrl/nf-commctrl-removewindowsubclass RemoveWindowSubclass}.
     * If the window subclass is not installed, this has no effect.
     *
     * @throws {OSError} - "The call to `RemoveWindowSubclass` failed."
     */
    Uninstall() {
        if this.isInstalled {
            if DllCall(
                g_comctl32_RemoveWindowSubclass
              , 'ptr', this.hwndSubclass
              , 'ptr', this.pfnSubclass
              , 'uptr', this.uIdSubclass
              , 'int'
            ) {
                this.isInstalled := false
            } else {
                throw OSError('The call to ``RemoveWindowSubclass`` failed.')
            }
        }
    }
    __Delete() {
        if this.isInstalled {
            this.Uninstall()
        }
        if this.__flag_callbackFree {
            CallbackFree(this.pfnSubclass)
        }
    }
    /**
     * This has the following own properties:
     *
     * - dwRefData {@link WindowSubclas#dwRefData}
     * - hwndSubclass {@link WindowSubclas#hwndSubclass}
     * - isInstalled {@link WindowSubclas#isInstalled}
     * - pfnSubclass {@link WindowSubclas#pfnSubclass}
     * - uIdSubclass {@link WindowSubclas#uIdSubclass}
     */
}

class WindowSubclass_Nmhdr {
    static __New() {
        this.DeleteProp('__New')
        this.Prototype.Size := A_PtrSize * 2 + 4
    }
    /**
     * @desc - A wrapper around the
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-nmhdr NMHDR}
     * structure.
     *
     * @param {Integer} ptr - The value passed to the "lParam" parameter of
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/commctrl/nc-commctrl-subclassproc SUBCLASSPROC}
     * when the message is
     * {@link https://learn.microsoft.com/en-us/windows/win32/controls/wm-notify WM_NOTIFY}.
     */
    __New(ptr) {
        this.ptr := ptr
    }
    code => NumGet(this.ptr, A_PtrSize * 2, 'uint')
    code_int => NumGet(this.ptr, A_PtrSize * 2, 'int')
    hwndFrom => NumGet(this.ptr, 'ptr')
    idFrom => NumGet(this.ptr, A_PtrSize, 'ptr')
}
