/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/Win32/WindowSubclass.ahk
    Author: Nich-Cebolla
    License: MIT
*/

/**
 * @classdesc -
 * BOOL SetWindowSubclass(
 *   HWND          hWnd,
 *   SUBCLASSPROC  pfnSubclass,
 *   UINT_PTR      uIdSubclass,
 *   DWORD_PTR     dwRefData
 * );
 */
class WindowSubclass {
    static __New() {
        this.DeleteProp('__New')
        this.Ids := []
        Proto := this.Prototype
        Proto.pfnSubclass := 0
    }
    static GetUid() {
        loop {
            n := Random(0, 4294967295)
            for id in this.Ids {
                if n = id {
                    OutputDebug('Congratulations, you should buy a lottery ticket today.`n')
                    continue 2
                }
            }
            this.Ids.Push(n)
            return n
        }
    }
    /**
     * Calls `SetWindowSubclass`.
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/commctrl/nf-commctrl-setwindowsubclass}
     *
     * @see {@link https://learn.microsoft.com/en-us/windows/win32/controls/subclassing-overview}
     *
     * @see {@link https://learn.microsoft.com/en-us/windows/win32/api/commctrl/nf-commctrl-defsubclassproc}
     *
     * Each hWnd can have multiple active subclass procedures, as long as each one has a unique uIdSubclass.
     *
     * - Calling SetWindowSubclass with the same hwnd and same uIdSubclass:
     *   - Windows will replace the existing subclass proc
     *   - The old `dwRefData` is no longer associated with the subclass
     *   - This can be used to update `dwRefData` with new data.
     * - Calling with the same hwnd and a different uIdSubclass:
     *   - Windows adds an additional subclass to the chain.
     *   - All subclass procedures are called in reverse order (newest first) during message dispatch.
     *
     * When your code needs to check if the subclass is already installed or not, use the property
     * "pfnSubclass" as your indicator. If zero, the subclass is not installed. If nonzero, the
     * subclass is installed.
     *
     * @class
     *
     * @param {Func|BoundFunc} SubclassProc - The function that will be used as the subclass procedure.
     *
     * @param {Integer} [Hwnd] - The handle to the window that represents the window class that will
     * be subclassed. If unset, `A_ScriptHwnd` is used.
     *
     * @param {Integer} [uIdSubclass] - If set, this must be an integer between 0 and 4294967295. If
     * unset, a random value is assigned.
     *
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/commctrl/nc-commctrl-subclassproc}.
     *
     * @param {Buffer|Integer} [dwRefData = 0] - A buffer containing data that will be passed to the
     * subclass procedure, or a pointer to a memory address containing the data.
     *
     * @param {Boolean} [DeferActivation = false] - If true, `SetWindowSubclass` is not called, your
     * code must call `WindowSubclass.Prototype.Install`.
     */
    __New(SubclassProc, Hwnd?, uIdSubclass?, dwRefData := 0, DeferActivation := false) {
        this.SubclassProc := SubclassProc
        this.Hwnd := Hwnd ?? A_ScriptHwnd
        this.uIdSubclass := uIdSubclass ?? WindowSubclass.GetUid()
        this.dwRefData := dwRefData
        if !DeferActivation {
            this.Install()
        }
    }
    Dispose() {
        if this.pfnSubclass {
            this.Uninstall()
        }
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
        this.pfnSubclass := CallbackCreate(this.SubclassProc)
        if !DllCall(
            'Comctl32.Dll\SetWindowSubclass'
          , 'ptr', this.Hwnd
          , 'ptr', this.pfnSubclass
          , 'ptr', this.uIdSubclass
          , 'ptr', this.dwRefData
          , 'int'
        ) {
            CallbackFree(this.pfnSubclass)
            throw OSError('The call to ``SetWindowSubclass`` failed.', -1)
        }
    }
    /**
     * Calls `SetWindowSubclass` with new `dwRefData`, replacing the old data if present.
     *
     * @param {Buffer|Integer} dwRefData - A buffer containing data that will be passed to the
     * subclass procedure, or a pointer to a memory address containing the data.
     */
    SetRefData(dwRefData) {
        this.dwRefData := dwRefData
        this.Install()
    }
    /**
     * Uninstalls the subclass.
     * @throws {Error} - The subclass is not installed.
     * @throws {OSError} - The call to `RemoveWindowSubclass` failed.
     */
    Uninstall() {
        if this.pfnSubclass {
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
            CallbackFree(pfnSubclass)
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
}


