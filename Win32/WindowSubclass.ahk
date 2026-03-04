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
     * for details. Also see the bottom of this script for a template.
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

class WindowSubclassController {
    static __New() {
        this.DeleteProp('__New')
        proto := this.Prototype
        proto.commandCollection :=
        proto.flag_Command :=
        proto.flag_Message :=
        proto.flag_Notify :=
        proto.messageCollection :=
        proto.notifyCollection :=
        proto.windowSubclass := 0
    }
    /**
     * @desc - A {@link WindowSubclassController} is a tool to organize a window subclass using
     * callback functions, instead of writing the logic directly into the subclass procedure.
     *
     * The {@link WindowSubclassController} object has three properties defined with map objects:
     *
     * - {@link WindowSubclassController#commandCollection commandCollection}
     * - {@link WindowSubclassController#messageCollection messageCollection}
     * - {@link WindowSubclassController#notifyCollection notifyCollection}
     *
     * The keys are message codes and the values are arrays of functions.
     *
     * {@link WindowSubclassController} should be used with the template subclass procedure at
     * the bottom of this file. Here is the template:
     *
     * @example
     * SubclassProc(HwndSubclass, uMsg, wParam, lParam, uIdSubclass, dwRefData) {
     *     Critical('On')
     *     subclassController := ObjFromPtrAddRef(dwRefData)
     *     switch uMsg {
     *     case 0x0111: ; WM_COMMAND
     *         if subclassController.flag_Command {
     *             if callbackCollection := subclassController.CommandGet((wParam >> 16) & 0xFFFF) {
     *                 for cb in callbackCollection {
     *                     if result := cb(subclassController, (wParam >> 16) & 0xFFFF, HwndSubclass, uMsg, wParam, lParam, uIdSubclass) {
     *                         return result
     *                     }
     *                 }
     *             }
     *         }
     *     case 0x004E: ; WM_NOTIFY
     *         if subclassController.flag_Notify {
     *             hdr := WindowSubclass_Nmhdr(lParam)
     *             if callbackCollection := subclassController.NotifyGet(hdr.code_int) {
     *                 for cb in callbackCollection {
     *                     if result := cb(subclassController, hdr, HwndSubclass, uMsg, wParam, lParam, uIdSubclass) {
     *                         return result
     *                     }
     *                 }
     *             }
     *         }
     *     default:
     *         if subclassController.flag_Message {
     *             if callbackCollection := subclassController.MessageGet(uMsg) {
     *                 for cb in callbackCollection {
     *                     if result := cb(subclassController, HwndSubclass, uMsg, wParam, lParam, uIdSubclass) {
     *                         return result
     *                     }
     *                 }
     *             }
     *         }
     *     }
     *     return DllCall(
     *         g_comctl32_DefSubclassProc
     *       , 'ptr', HwndSubclass
     *       , 'uint', uMsg
     *       , 'uptr', wParam
     *       , 'ptr', lParam
     *       , 'ptr'
     *     )
     * }
     * @
     *
     * Within the body of the subclass procedure:
     *
     * - A reference to this {@link WindowSubclassController} object is obtained by passing `dwRefData`
     *   to {@link https://www.autohotkey.com/docs/v2/Objects.htm#ObjFromPtr ObjFromPtrAddRef}.
     * - If the message is
     *   {@link https://learn.microsoft.com/en-us/windows/win32/menurc/wm-command WM_COMMAND},
     *   "commandCollection" is checked for the command code. If an item is found, the functions are
     *   iterated.
     * - If the message is
     *   {@link https://learn.microsoft.com/en-us/windows/win32/controls/wm-notify WM_NOTIFY},
     *   the NMHDR pointer is passed to {@link WindowSubclass_Nmhdr}, which is a wrapper around the
     *   {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-nmhdr NMHDR}
     *   structure. Then "notifyCollection" is checked for the notification code. If an item is found,
     *   the functions are iterated.
     * - If the message is any other message, "messageCollection" is checked for the message code.
     *   If an item is found, the functions are iterated.
     *
     * If any of the functions returns a nonzero value, that value gets returned to the system. The
     * effect of this depends on the message. In some cases it means the window never receives the
     * message. You will need to read the documentation for the individual message to learn
     * the significance of returning a value.
     *
     * Although this approach will perform slightly worse compared to defining all the logic within
     * the subclass procedure directly, it is a helpful system when the logic is not known ahead of time,
     * i.e. when writing code that is intended to be consumed by other developers.
     *
     * See {@link https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/test-files/test-WindowSubclass.ahk}
     * for an usage example.
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
     * for details. Also see the bottom of this script for a template.
     *
     * @param {Integer} uIdSubclass - Serves as the unique id for this subclass.
     *
     * @param {Integer} HwndSubclass - The handle to the window for which `SubclassProc`
     * will intercept its messages and notifications. Note that the window must have been
     * created by the AHK process.
     */
    __New(SubclassProc, uIdSubclass, HwndSubclass) {
        this.windowSubclass := WindowSubclass(SubclassProc, uIdSubclass, HwndSubclass, ObjPtr(this))
    }
    /**
     * @desc - Adds a function to be called when the specified WM_COMMAND is sent.
     *
     * @param {Integer} CommandCode - The WM_COMMAND code.
     *
     * @param {*} Callback - A `Func` or callable object to call.
     *
     * Parameters:
     * 1. **{WindowSubclassController}** - This {@link WindowSubclassController} object
     * 2. **{Integer}** - The WM_COMMAND code
     * 3. **{Integer}** - HwndSubclass
     * 4. **{Integer}** - uMsg
     * 5. **{Integer}** - wParam
     * 6. **{Integer}** - lParam
     * 7. **{Integer}** - uIdSubclass
     *
     * If the function returns a nonzero value, that value gets returned to the system and no further
     * functions are called. The effect of this depends on the message.
     *
     * @param {Integer} [InsertAt] - If set, an integer indicating the index at which the function
     * is to be inserted in the list of functions. If unset, the function is appended to the end
     * of the list.
     *
     * @returns {Integer} - The index at which the function was inserted.
     */
    CommandAdd(CommandCode, Callback, InsertAt?) {
        this.__Add('Command', CommandCode, Callback, InsertAt ?? unset)
    }
    /**
     * @desc - Deletes one or all functions associated with `CommandCode`.
     *
     * @param {Integer} CommandCode - The WM_COMMAND code.
     *
     * @param {*} [Callback] - If set, the function to delete. If unset, all of the functions
     * associated with `CommandCode` are deleted.
     */
    CommandDelete(CommandCode, Callback?) {
        this.__DeleteCallback('Command', CommandCode, Callback ?? unset)
    }
    /**
     * @param {Integer} Code - The code.
     *
     * @returns {WindowSubclass_CallbackCollection|String} - If `Code` exists in the collection,
     * returns the array of functions. Else, returns an empty string.
     */
    CommandGet(Code) {
        if this.commandCollection.Has(Code) {
            return this.commandCollection.Get(Code)
        }
    }
    Dispose() {
        if this.windowSubclass {
            this.windowSubclass.Uninstall()
            this.DeleteProp('WindowSubclass')
        }
        for name in [ 'Command', 'Message', 'Notify' ] {
            if this.HasOwnProp(name 'Collection') {
                collection := this.%name%Collection
                for code, callbackCollection in collection {
                    callbackCollection.length := 0
                }
                collection.Clear()
                this.DeleteProp(name 'Collection')
            }
        }
    }
    /**
     * @desc - Adds a function to be called when the specified message is sent.
     *
     * @param {Integer} MessageCode - The message code.
     *
     * @param {*} Callback - A `Func` or callable object to call.
     *
     * Parameters:
     * 1. **{WindowSubclassController}** - This {@link WindowSubclassController} object
     * 2. **{Integer}** - HwndSubclass
     * 3. **{Integer}** - uMsg
     * 4. **{Integer}** - wParam
     * 5. **{Integer}** - lParam
     * 6. **{Integer}** - uIdSubclass
     *
     * If the function returns a nonzero value, that value gets returned to the system and no further
     * functions are called. The effect of this depends on the message.
     *
     * @param {Integer} [InsertAt] - If set, an integer indicating the index at which the function
     * is to be inserted in the list of functions. If unset, the function is appended to the end
     * of the list.
     *
     * @returns {Integer} - The index at which the function was inserted.
     */
    MessageAdd(MessageCode, Callback, InsertAt?) {
        this.__Add('Message', MessageCode, Callback, InsertAt ?? unset)
    }
    /**
     * @desc - Deletes one or all functions associated with `MessageCode`.
     *
     * @param {Integer} MessageCode - The message code.
     *
     * @param {*} [Callback] - If set, the function to delete. If unset, all of the functions
     * associated with `CommandCode` are deleted.
     */
    MessageDelete(MessageCode, Callback?) {
        this.__DeleteCallback('Message', MessageCode, Callback ?? unset)
    }
    /**
     * @param {Integer} Code - The code.
     *
     * @returns {WindowSubclass_CallbackCollection|String} - If `Code` exists in the collection,
     * returns the array of functions. Else, returns an empty string.
     */
    MessageGet(Code) {
        if this.messageCollection.Has(Code) {
            return this.messageCollection.Get(Code)
        }
    }
    /**
     * @desc - Adds a function to be called when the specified WM_NOTIFY is sent.
     *
     * @param {Integer} NotifyCode - The WM_NOTIFY code. This should be a signed value, not an
     * unsigned value.
     *
     * @param {*} Callback - A `Func` or callable object to call.
     *
     * Parameters:
     * 1. **{WindowSubclassController}** - This {@link WindowSubclassController} object
     * 2. **{WindowSubclass_Nmhdr}** - The {@link WindowSubclass_Nmhdr} object
     * 3. **{Integer}** - HwndSubclass
     * 4. **{Integer}** - uMsg
     * 5. **{Integer}** - wParam
     * 6. **{Integer}** - lParam
     * 7. **{Integer}** - uIdSubclass
     *
     * If the function returns a nonzero value, that value gets returned to the system and no further
     * functions are called. The effect of this depends on the message.
     *
     * @param {Integer} [InsertAt] - If set, an integer indicating the index at which the function
     * is to be inserted in the list of functions. If unset, the function is appended to the end
     * of the list.
     *
     * @returns {Integer} - The index at which the function was inserted.
     */
    NotifyAdd(NotifyCode, Callback, InsertAt?) {
        this.__Add('Notify', NotifyCode, Callback, InsertAt ?? unset)
    }
    /**
     * @desc - Deletes one or all functions associated with `NotifyCode`.
     *
     * @param {Integer} NotifyCode - The WM_NOTIFY code.
     *
     * @param {*} [Callback] - If set, the function to delete. If unset, all of the functions
     * associated with `CommandCode` are deleted.
     */
    NotifyDelete(NotifyCode, Callback?) {
        this.__DeleteCallback('Notify', NotifyCode, Callback ?? unset)
    }
    /**
     * @param {Integer} Code - The code.
     *
     * @returns {WindowSubclass_CallbackCollection|String} - If `Code` exists in the collection,
     * returns the array of functions. Else, returns an empty string.
     */
    NotifyGet(Code) {
        if this.notifyCollection.Has(Code) {
            return this.notifyCollection.Get(Code)
        }
    }
    __Add(Name, Code, Callback, InsertAt?) {
        if !this.flag_%Name% {
            if !this.HasOwnProp(Name 'Collection') {
                this.%Name%Collection := Map()
            }
            this.flag_%Name% := 1
            if !this.windowSubclass.isInstalled {
                this.windowSubclass.Install()
            }
        }
        collection := this.%Name%Collection
        if !collection.Has(Code) {
            callbackCollection := WindowSubclass_CallbackCollection(Code)
            collection.Set(code, callbackCollection)
        }
        if IsSet(InsertAt) {
            callbackCollection.InsertAt(InsertAt, Callback)
            return InsertAt
        } else {
            callbackCollection.Push(Callback)
            return callbackCollection.Length
        }
    }
    __DeleteCallback(Name, Code, Callback?) {
        collection := this.%Name%Collection
        if IsSet(Callback) {
            if collection.Has(Code) {
                callbackCollection := collection.Get(Code)
                ; DeleteCallback returns the number of items in the collection after deletion.
                if !callbackCollection.DeleteCallback(Callback) {
                    collection.Delete(Code)
                }
            } else {
                throw UnsetItemError('Code not found.', , Code)
            }
        } else {
            collection.Delete(Code)
        }
        if !collection.count {
            this.flag_%Name% := 0
        }
        if this.flag_Notify + this.flag_Message + this.flag_Command = 0 {
            this.windowSubclass.Uninstall()
        }
    }
    __Delete() {
        this.Dispose()
    }
    hwndSubclass => this.windowSubclass.hwndSubclass
    uIdSubclass => this.windowSubclass.uIdSubclass
}

class WindowSubclass_CallbackCollection extends Array {
    __New(code) {
        this.code := code
    }
    DeleteCallback(Callback) {
        ptr := ObjPtr(Callback)
        for cb in this {
            if ptr = ObjPtr(cb) {
                this.RemoveAt(A_Index)
                return this.Length
            }
        }
        throw UnsetItemError('Callback not found.', , HasProp(Callback, 'Name') ? Callback.Name : '')
    }
}

class WindowSubclass_Nmhdr {
    static __New() {
        this.DeleteProp('__New')
        this.Prototype.Size := A_PtrSize * 2 + 4
    }
    __New(ptr) {
        this.ptr := ptr
    }
    code => NumGet(this.ptr, A_PtrSize * 2, 'uint')
    code_int => NumGet(this.ptr, A_PtrSize * 2, 'int')
    hwndFrom => NumGet(this.ptr, 'ptr')
    idFrom => NumGet(this.ptr, A_PtrSize, 'ptr')
}


/*

Here's a SubclassProc template. This template assumes the use of the WindowSubclassController class.

/**
 * @desc - {@link https://learn.microsoft.com/en-us/windows/win32/api/commctrl/nc-commctrl-subclassproc}
 *
 * @param {Integer} HwndSubclass - The handle to the subclassed window (the handle passed to `SetWindowSubclass`).
 *
 * @param {Integer} uMsg - The message being passed.
 *
 * @param {Integer} wParam - Additional message information. The contents of this parameter depend on the value of uMsg.
 *
 * @param {Integer} lParam - Additional message information. The contents of this parameter depend on the value of uMsg.
 *
 * @param {Integer} uIdSubclass - The subclass ID. This is the value pased to the `uIdSubclass` parameter of `SetWindowSubclass`.
 *
 * @param {Integer} dwRefData - The reference data provided to `SetWindowSubclass`.

SubclassProc(HwndSubclass, uMsg, wParam, lParam, uIdSubclass, dwRefData) {
    Critical('On')
    subclassController := ObjFromPtrAddRef(dwRefData)
    switch uMsg {
    case 0x0111: ; WM_COMMAND
        if subclassController.flag_Command {
            if callbackCollection := subclassController.CommandGet((wParam >> 16) & 0xFFFF) {
                for cb in callbackCollection {
                    if result := cb(subclassController, (wParam >> 16) & 0xFFFF, HwndSubclass, uMsg, wParam, lParam, uIdSubclass) {
                        return result
                    }
                }
            }
        }
    case 0x004E: ; WM_NOTIFY
        if subclassController.flag_Notify {
            hdr := WindowSubclass_Nmhdr(lParam)
            if callbackCollection := subclassController.NotifyGet(hdr.code_int) {
                for cb in callbackCollection {
                    if result := cb(subclassController, hdr, HwndSubclass, uMsg, wParam, lParam, uIdSubclass) {
                        return result
                    }
                }
            }
        }
    default:
        if subclassController.flag_Message {
            if callbackCollection := subclassController.MessageGet(uMsg) {
                for cb in callbackCollection {
                    if result := cb(subclassController, HwndSubclass, uMsg, wParam, lParam, uIdSubclass) {
                        return result
                    }
                }
            }
        }
    }
    return DllCall(
        g_comctl32_DefSubclassProc
      , 'ptr', HwndSubclass
      , 'uint', uMsg
      , 'uptr', wParam
      , 'ptr', lParam
      , 'ptr'
    )
}
