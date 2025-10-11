/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/Win32/WindowSubclass.ahk
    Author: Nich-Cebolla
    License: MIT
*/

/**
 * @classdesc -
 * BOOL SetWindowSubclass
 *   HWND          hWnd,
 *   SUBCLASSPROC  pfnSubclass,
 *   UINT_PTR      uIdSubclass,
 *   DWORD_PTR     dwRefData
 * );
 */
class WindowSubclass {
    static __New() {
        this.DeleteProp('__New')
        this.Ids := Map()
        Proto := this.Prototype
        Proto.pfnSubclass := proto.__flag_callbackFree := 0
    }
    static GetUid() {
        loop 100 { ; 100 is arbitrary
            id := Random(0, 2 ** 32 - 1)
            if !this.Ids.Has(id) {
                this.Ids.Set(id, 1)
                return id
            }
        }
        throw Error('Failed to create a unique id.')
    }
    /**
     * Calls {@link https://learn.microsoft.com/en-us/windows/win32/api/commctrl/nf-commctrl-setwindowsubclass SetWindowSubclass}
     *
     * @see {@link https://learn.microsoft.com/en-us/windows/win32/controls/subclassing-overview}
     *
     * @see {@link https://learn.microsoft.com/en-us/windows/win32/api/commctrl/nf-commctrl-defsubclassproc}
     *
     * Each hWnd can have multiple active subclass procedures, as long as each one has a unique uIdSubclass.
     *
     * - Calling SetWindowSubclass with the same hwnd and same uIdSubclass:
     *   - The system will replace the existing subclass proc.
     *   - The system will update `dwRefData` with the new data.
     * - Calling with the same hwnd and a different uIdSubclass:
     *   - The system adds an additional subclass to the chain.
     *   - All subclass procedures are called in reverse order (newest first) during message dispatch.
     * - Calling with a different hwnd and the same uIdSubclass:
     *   - The system will add the uIdSubclass to the window's subclass list, as each window maintains
     *     a separate subclass list.
     *
     * @class
     *
     * @param {Func|Integer} [SubclassProc = 0] - The function that will be used as the
     * subclass procedure, or the pointer to the function. This is set to property
     * {@link WindowSubclass#SubclassProc}. If `SubclassProc` is 0, `SetWindowSubclass`
     * is not called; your code can set the property by calling {@link WindowSubclass.Prototype.SetSubclassProc}.
     *
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/commctrl/nc-commctrl-subclassproc}.
     *
     * @param {Integer} [HwndSubclass] - The handle to the window for which `SubclassProc` will intercept
     * its messages and notifications. If unset, `A_ScriptHwnd` is used.
     *
     * @param {Integer} [uIdSubclass] - Serves as the unique id for this subclass. If set, it must
     * be a ptr-sized integer. If unset, a random integer is generated. This is set to property
     * {@link WindowSubclass#uIdSubclass}.
     *
     * @param {Buffer|Integer} [dwRefData = 0] - A buffer containing data that will be passed to the
     * subclass procedure, or a pointer to a memory address containing the data, or the data itself
     * if the data can be represented as a ptr-sized value.
     *
     * @param {Boolean} [DeferActivation = false] - If true, `SetWindowSubclass` is not called, your
     * code must call {@link WindowSubclass.Prototype.Install}. If `SubclassProc` is 0,
     * `DeferActivation` is ignored; `SetWindowSubclass` is not called if `SubclassProc` is 0.
     */
    __New(SubclassProc := 0, HwndSubclass?, uIdSubclass?, dwRefData := 0, DeferActivation := false) {
        this.SubclassProc := SubclassProc
        this.Hwnd := HwndSubclass ?? A_ScriptHwnd
        if IsSet(uIdSubclass) {
            if WindowSubclass.Ids.Has(uIdSubclass) {
                throw Error('The ``uIdSubclass`` is already in use.', , uIdSubclass)
            }
            this.uIdSubclass := uIdSubclass
            WindowSubclass.Ids.Set(uIdSubclass, 1)
        } else {
            this.uIdSubclass := WindowSubclass.GetUid()
        }
        this.dwRefData := dwRefData
        if !DeferActivation {
            this.Install()
        }
    }
    Dispose() {
        if this.pfnSubclass {
            this.Uninstall()
        }
        WindowSubclass.Ids.Delete(this.uIdSubclass)
        for prop in ['Hwnd', 'uIdSubclass', 'SubclassProc', 'dwRefData'] {
            if this.HasOwnProp(prop) {
                this.DeleteProp(prop)
            }
        }
    }
    /**
     * Installs the subclass.
     * @throws {Error} - The subclass is already installed.
     * @throws {OSError} - The call to `SetWindowSubclass` failed.
     */
    Install() {
        if this.pfnSubclass {
            throw Error('The subclass is already installed.', -1)
        }
        if IsObject(this.SubclassProc) {
            this.pfnSubclass := CallbackCreate(this.SubclassProc)
            this.__flag_callbackFree := 1
        } else {
            this.pfnSubclass := this.SubclassProc
            this.__flag_callbackFree := 0
        }
        if !DllCall(
            'Comctl32.Dll\SetWindowSubclass'
          , 'ptr', this.Hwnd
          , 'ptr', this.pfnSubclass
          , 'ptr', this.uIdSubclass
          , 'ptr', this.dwRefData
          , 'int'
        ) {
            if this.__flag_callbackFree {
                CallbackFree(this.pfnSubclass)
                this.__flag_callbackFree := 0
            }
            throw OSError('The call to ``SetWindowSubclass`` failed.', -1)
        }
    }
    /**
     * Calls `SetWindowSubclass` with new `dwRefData`, replacing the old data if present.
     *
     * @param {Buffer|Integer} dwRefData - A buffer containing data that will be passed to the
     * subclass procedure, or a pointer to a memory address containing the data.
     *
     * @returns {Buffer|Integer} - The previous value.
     */
    SetRefData(dwRefData) {
        previous := this.dwRefData
        this.dwRefData := dwRefData
        this.Install()
        return previous
    }
    /**
     * @param {Func|Integer} SubclassProc - The function that will be used as the
     * subclass procedure, or the pointer to the function. This is set to property
     * {@link WindowSubclass#SubclassProc}.
     *
     * @param {Boolean} [Activate = true] - If true, installs the subclass. If the subclass is already
     * installed, it is first uninstalled, then reinstalled using the new function.
     *
     * If false, only the {@link WindowSubclass#SubclassProc} property is changed.
     *
     * @returns {Func|Integer} - The previous value.
     */
    SetSubclassProc(SubclassProc, Activate := true) {
        previous := this.SubclassProc
        this.SubclassProc := SubclassProc
        if Activate {
            if this.IsInstalled {
                this.Uninstall()
            }
            this.Install()
        }
        return previous
    }
    /**
     * Uninstalls the subclass by calling
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/commctrl/nf-commctrl-removewindowsubclass RemoveWindowSubclass}.
     * Sets property {@link WindowSubclass#pfnSubclass} := 0.
     * @throws {Error} - The subclass is not installed.
     * @throws {OSError} - The call to `RemoveWindowSubclass` failed.
     */
    Uninstall() {
        if this.IsInstalled {
            pfnSubclass := this.pfnSubclass
            this.pfnSubclass := 0
            if !DllCall(
                'Comctl32.Dll\RemoveWindowSubclass'
              , 'ptr', this.Hwnd
              , 'ptr', pfnSubclass
              , 'ptr', this.uIdSubclass
              , 'int'
            ) {
                err := OSError('The call to ``RemoveWindowSubclass`` failed.', -1)
            }
            if this.__flag_callbackFree {
                CallbackFree(pfnSubclass)
                this.__flag_callbackFree := 0
            }
            if IsSet(err) {
                throw err
            }
        } else {
            throw Error('The subclass is not installed.', -1)
        }
    }
    __Delete() {
        if this.pfnSubclass {
            this.Uninstall()
        }
    }

    IsInstalled => this.pfnSubclass ? 1 : 0
}
