
; https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/Win32/WinEventHook.ahk
#include <WinEventHook>
; I have not tested all combinations of options. If an error occurs please submit issue.

class WinEventFilter {
    static __New() {
        this.DeleteProp('__New')
        this.Collection := Map()
        this.Collection.Default := 0
        proto := this.Prototype
        proto.DeferHook :=
        proto.Process :=
        proto.Thread :=
        0
        proto.Callback :=
        proto.Event :=
        proto.EventHook :=
        proto.Hwnd :=
        proto.Object :=
        proto.TitlePattern :=
        ''
    }
    static __Add(obj) {
        this.Collection.Set(obj.EventHook.Handle, obj)
        ObjRelease(ObjPtr(obj))
    }
    /**
     * @param {Object} Options - An object with options as key : value pairs. The following option
     * is required:
     * - `Options.Callback`.
     *
     * Zero or more of `Options.Event`, `Options.Hwnd`, `Options.Object`, and `Options.TitlePattern`
     * may be set.
     *
     * When both `Options.Event` and `Options.Object` are set, the event constant and object id for
     * the event must both match to invoke `Options.Callback`.
     *
     * When both `Options.Hwnd` and `Options.TitlePattern` are set, the window associated with the
     * event only needs to match one or the other to invoke `Options.Callback`.
     *
     * When one or both of `Options.Hwnd` and `Options.TitlePatten` are set, if the WINEVENTPROC
     * is called with a `hwnd` of `0`, `Options.Callback` is not invoked.
     *
     * @param {*} Options.Callback - The function that will be called when the event occurs and the
     * filter conditions are satisfied.
     *
     * Parameters:
     * 1. **{Integer}** hWinEventHook - The handle returned by
     * {@link https://learn.microsoft.com/en-us/windows/desktop/api/winuser/nf-winuser-setwineventhook SetWinEventHook}.
     * 2. **{Integer}** event - The
     * {@link https://learn.microsoft.com/en-us/windows/win32/winauto/event-constants event constant}.
     * 3.**{Integer}** hwnd - The hwnd of the window that generated the event, or 0 if a window did
     * not generate the event.
     * 4. **{Integer}** idObject - The
     * {@link https://learn.microsoft.com/en-us/windows/win32/winauto/object-identifiers object identifier}.
     * The object id values are set in {@link WinEventHook_SetConstants}.
     * 5. **{Integer}** idChild - Identifies whether the event was triggered by an object or a child
     * element of the object. If this value is CHILDID_SELF (0), the event was triggered by the object;
     * otherwise, this value is the child ID of the element that triggered the event.
     * 6. **{Integer}** idEventThread - The id of the thread that triggered the event.
     * 7. **{Integer}** dwmsEventTime - Specifies the time, in milliseconds, that the event was
     * generated.
     * 8. **{WinEventFilter}** - The {@link WinEventFilter} object.
     *
     * The return value is ignored.
     *
     * @param {Integer} [Options.DeferHook = false] - If true, `SetWinEventHook` is not called;
     * your code must call {@link WinEventFilter.Prototype.Hook}.
     *
     * @param {Integer|Integer[]} [Options.Event] - One or more
     * {@link https://learn.microsoft.com/en-us/windows/win32/winauto/event-constants event constants}.
     *
     * @param {Integer|Integer[]} [Options.Hwnd] - One or more window handles to monitor.
     *
     * @param {Integer|Integer[]} [Options.Object] - One or more
     * {@link https://learn.microsoft.com/en-us/windows/win32/winauto/object-identifiers object identifiers}.
     *
     * @param {Integer} [Options.Process = 0] - The number that will be passed to the `idProcess`
     * parameter of
     * {@link https://learn.microsoft.com/en-us/windows/desktop/api/winuser/nf-winuser-setwineventhook SetWinEventHook}.
     * You can get the process ID by calling
     * {@link https://learn.microsoft.com/en-us/windows/win32/winauto/getprocesshandlefromhwnd GetProcessHandleFromHwnd},
     * then passing the returned handle to
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/processthreadsapi/nf-processthreadsapi-getprocessid GetProcessId}.
     * If the window(s) are owned by the current process, you can simply use
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/processthreadsapi/nf-processthreadsapi-getcurrentprocessid GetCurrentProcessId}.
     * If you need to find a process using some other means, you can use
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/psapi/nf-psapi-enumprocesses EnumProcesses}.
     * If `Options.Process` is `0`, the WINEVENTPROC will receive events from all processes on the
     * current desktop.
     *
     * @param {Integer} [Options.Thread = 0] - The number that will be passed to the `idThread`
     * parameter of
     * {@link https://learn.microsoft.com/en-us/windows/desktop/api/winuser/nf-winuser-setwineventhook SetWinEventHook}.
     * You can leave this 0.
     *
     * @param {String} [Options.TitlePattern] - A regex pattern that will be matched against window
     * titles.
     */
    __New(Options) {
        if HasProp(Options, 'Callback') {
            this.Callback := Options.Callback
        } else {
            throw Error('``WinEventFilter`` requires ``Options.Callback``.')
        }
        z := 0
        if HasProp(Options, 'Hwnd') {
            this.Hwnd := IsObject(Options.Hwnd) ? Options.Hwnd : [ Options.Hwnd ]
            z += 1
        }
        if HasProp(Options, 'TitlePattern') {
            this.TitlePattern := Options.TitlePattern
            z += 2
        }
        if HasProp(Options, 'Event') {
            this.Event := IsObject(Options.Event) ? Options.Event : [ Options.Event ]
            low := 4294967295
            high := 0
            for _event in this.Event {
                if _event < low {
                    low := _event
                }
                if _event > high {
                    high := _event
                }
            }
            this.Min := low
            this.Max := high
            z += 4
        }
        if HasProp(Options, 'Object') {
            this.Object := IsObject(Options.Object) ? Options.Object : [ Options.Object ]
            z += 8
        }
        if HasProp(Options, 'Process') {
            this.Process := Options.Process
        } else {
            this.Process := 0
        }
        if HasProp(Options, 'Thread') {
            this.Thread := Options.Thread
        } else {
            this.Thread := 0
        }
        if !HasProp(options, 'DeferHook') || !options.DeferHook {
            this.Proc := WinEventFilter_%z%
            this.EventHook := WinEventHook(this)
            WinEventFilter.__Add(this)
        }
    }
    Hook() {
        if this.EventHook {
            this.EventHook.Unhook()
        }
        z := 0
        if this.Hwnd {
            if !IsObject(this.Hwnd) {
                this.Hwnd := [ this.Hwnd ]
            }
            z += 1
        }
        if this.TitlePattern {
            z += 2
        }
        if this.Event {
            if !IsObject(this.Event) {
                this.Event := [ this.Event ]
            }
            low := 4294967295
            high := 0
            for _event in this.Event {
                if _event < low {
                    low := _event
                }
                if _event > high {
                    high := _event
                }
            }
            this.Min := low
            this.Max := high
            z += 4
        }
        if this.Object {
            if !IsObject(this.Object) {
                this.Object := [ this.Object ]
            }
            z += 8
        }
        this.Proc := WinEventFilter_%z%
        this.EventHook := WinEventHook(this)
        WinEventFilter.__Add(this)
    }
    Unhook() {
        if this.EventHook {
            if this.EventHook.Handle {
                ObjPtrAddRef(this)
                if WinEventFilter.Collection.Has(this.EventHook.Handle) {
                    WinEventFilter.Collection.Delete(this.EventHook.Handle)
                }
            }
        }
    }
    __Delete() {
        this.Unhook()
    }
}

WinEventFilter_0(hWinEventHook, event, hwnd, idObject, idChild, idEventThread, dwmsEventTime) {
    originalCritical := Critical(-1)
    if filter := WinEventFilter.Collection.Get(hWinEventHook) {
        filter.Callback.Call(hWinEventHook, event, hwnd, idObject, idChild, idEventThread, dwmsEventTime, filter)
    }
    Critical(originalCritical)
}
WinEventFilter_1(hWinEventHook, event, hwnd, idObject, idChild, idEventThread, dwmsEventTime) {
    originalCritical := Critical(-1)
    if filter := WinEventFilter.Collection.Get(hWinEventHook) {
        if WinExist(hwnd) {
            for _hwnd in filter.Hwnd {
                if hwnd = _hwnd {
                    filter.Callback.Call(hWinEventHook, event, hwnd, idObject, idChild, idEventThread, dwmsEventTime, filter)
                    Critical(originalCritical)
                    return
                }
            }
        }
    }
    Critical(originalCritical)
}
WinEventFilter_2(hWinEventHook, event, hwnd, idObject, idChild, idEventThread, dwmsEventTime) {
    originalCritical := Critical(-1)
    if filter := WinEventFilter.Collection.Get(hWinEventHook) {
        if WinExist(hwnd) && RegExMatch(WinGetTitle(hwnd), filter.TitlePattern) {
            filter.Callback.Call(hWinEventHook, event, hwnd, idObject, idChild, idEventThread, dwmsEventTime, filter)
        }
    }
    Critical(originalCritical)
}
WinEventFilter_3(hWinEventHook, event, hwnd, idObject, idChild, idEventThread, dwmsEventTime) {
    originalCritical := Critical(-1)
    if filter := WinEventFilter.Collection.Get(hWinEventHook) {
        if WinExist(hwnd) {
            if RegExMatch(WinGetTitle(hwnd), filter.TitlePattern) {
                filter.Callback.Call(hWinEventHook, event, hwnd, idObject, idChild, idEventThread, dwmsEventTime, filter)
            } else {
                for _hwnd in filter.Hwnd {
                    if hwnd = _hwnd {
                        filter.Callback.Call(hWinEventHook, event, hwnd, idObject, idChild, idEventThread, dwmsEventTime, filter)
                        Critical(originalCritical)
                        return
                    }
                }
            }
        }
    }
    Critical(originalCritical)
}
WinEventFilter_4(hWinEventHook, event, hwnd, idObject, idChild, idEventThread, dwmsEventTime) {
    originalCritical := Critical(-1)
    if filter := WinEventFilter.Collection.Get(hWinEventHook) {
        for _event in filter.Event {
            if event = _event {
                filter.Callback.Call(hWinEventHook, event, hwnd, idObject, idChild, idEventThread, dwmsEventTime, filter)
                Critical(originalCritical)
                return
            }
        }
    }
    Critical(originalCritical)
}
WinEventFilter_5(hWinEventHook, event, hwnd, idObject, idChild, idEventThread, dwmsEventTime) {
    originalCritical := Critical(-1)
    if filter := WinEventFilter.Collection.Get(hWinEventHook) {
        if WinExist(hwnd) {
            for _hwnd in filter.Hwnd {
                if hwnd = _hwnd {
                    for _event in filter.Event {
                        if event = _event {
                            filter.Callback.Call(hWinEventHook, event, hwnd, idObject, idChild, idEventThread, dwmsEventTime, filter)
                            Critical(originalCritical)
                            return
                        }
                    }
                    Critical(originalCritical)
                    return
                }
            }
        }
    }
    Critical(originalCritical)
}
WinEventFilter_6(hWinEventHook, event, hwnd, idObject, idChild, idEventThread, dwmsEventTime) {
    originalCritical := Critical(-1)
    if filter := WinEventFilter.Collection.Get(hWinEventHook) {
        if WinExist(hwnd) && RegExMatch(WinGetTitle(hwnd), filter.TitlePattern) {
            for _event in filter.Event {
                if event = _event {
                    filter.Callback.Call(hWinEventHook, event, hwnd, idObject, idChild, idEventThread, dwmsEventTime, filter)
                    Critical(originalCritical)
                    return
                }
            }
        }
    }
    Critical(originalCritical)
}
WinEventFilter_7(hWinEventHook, event, hwnd, idObject, idChild, idEventThread, dwmsEventTime) {
    originalCritical := Critical(-1)
    if filter := WinEventFilter.Collection.Get(hWinEventHook) {
        if WinExist(hwnd) {
            for _event in filter.Event {
                if event = _event {
                    if RegExMatch(WinGetTitle(hwnd), filter.TitlePattern) {
                        filter.Callback.Call(hWinEventHook, event, hwnd, idObject, idChild, idEventThread, dwmsEventTime, filter)
                    } else {
                        for _hwnd in filter.Hwnd {
                            if hwnd = _hwnd {
                                filter.Callback.Call(hWinEventHook, event, hwnd, idObject, idChild, idEventThread, dwmsEventTime, filter)
                                Critical(originalCritical)
                                return
                            }
                        }
                    }
                    Critical(originalCritical)
                    return
                }
            }
        }
    }
    Critical(originalCritical)
}
WinEventFilter_8(hWinEventHook, event, hwnd, idObject, idChild, idEventThread, dwmsEventTime) {
    originalCritical := Critical(-1)
    if filter := WinEventFilter.Collection.Get(hWinEventHook) {
        for _idObject in filter.Object {
            if idObject = _idObject {
                filter.Callback.Call(hWinEventHook, event, hwnd, idObject, idChild, idEventThread, dwmsEventTime, filter)
                Critical(originalCritical)
                return
            }
        }
    }
    Critical(originalCritical)
}
WinEventFilter_9(hWinEventHook, event, hwnd, idObject, idChild, idEventThread, dwmsEventTime) {
    originalCritical := Critical(-1)
    if filter := WinEventFilter.Collection.Get(hWinEventHook) {
        for _idObject in filter.Object {
            if idObject = _idObject {
                if WinExist(hwnd) {
                    for _hwnd in filter.Hwnd {
                        if hwnd = _hwnd {
                            filter.Callback.Call(hWinEventHook, event, hwnd, idObject, idChild, idEventThread, dwmsEventTime, filter)
                            Critical(originalCritical)
                            return
                        }
                    }
                }
                Critical(originalCritical)
                return
            }
        }
    }
    Critical(originalCritical)
}
WinEventFilter_10(hWinEventHook, event, hwnd, idObject, idChild, idEventThread, dwmsEventTime) {
    originalCritical := Critical(-1)
    if filter := WinEventFilter.Collection.Get(hWinEventHook) {
        for _idObject in filter.Object {
            if idObject = _idObject {
                if WinExist(hwnd) && RegExMatch(WinGetTitle(hwnd), filter.TitlePattern) {
                    filter.Callback.Call(hWinEventHook, event, hwnd, idObject, idChild, idEventThread, dwmsEventTime, filter)
                }
                Critical(originalCritical)
                return
            }
        }
    }
    Critical(originalCritical)
}
WinEventFilter_11(hWinEventHook, event, hwnd, idObject, idChild, idEventThread, dwmsEventTime) {
    originalCritical := Critical(-1)
    if filter := WinEventFilter.Collection.Get(hWinEventHook) {
        if WinExist(hwnd) {
            for _idObject in filter.Object {
                if idObject = _idObject {
                    if RegExMatch(WinGetTitle(hwnd), filter.TitlePattern) {
                        filter.Callback.Call(hWinEventHook, event, hwnd, idObject, idChild, idEventThread, dwmsEventTime, filter)
                    } else {
                        for _hwnd in filter.Hwnd {
                            if hwnd = _hwnd {
                                filter.Callback.Call(hWinEventHook, event, hwnd, idObject, idChild, idEventThread, dwmsEventTime, filter)
                                Critical(originalCritical)
                                return
                            }
                        }
                    }
                    Critical(originalCritical)
                    return
                }
            }
        }
    }
    Critical(originalCritical)
}
WinEventFilter_12(hWinEventHook, event, hwnd, idObject, idChild, idEventThread, dwmsEventTime) {
    originalCritical := Critical(-1)
    if filter := WinEventFilter.Collection.Get(hWinEventHook) {
        for _idObject in filter.Object {
            if idObject = _idObject {
                for _event in filter.Event {
                    if event = _event {
                        filter.Callback.Call(hWinEventHook, event, hwnd, idObject, idChild, idEventThread, dwmsEventTime, filter)
                        Critical(originalCritical)
                        return
                    }
                }
                Critical(originalCritical)
                return
            }
        }
    }
    Critical(originalCritical)
}
WinEventFilter_13(hWinEventHook, event, hwnd, idObject, idChild, idEventThread, dwmsEventTime) {
    originalCritical := Critical(-1)
    if filter := WinEventFilter.Collection.Get(hWinEventHook) {
        if WinExist(hwnd) {
            for _idObject in filter.Object {
                if idObject = _idObject {
                    for _hwnd in filter.Hwnd {
                        if hwnd = _hwnd {
                            for _event in filter.Event {
                                if event = _event {
                                    filter.Callback.Call(hWinEventHook, event, hwnd, idObject, idChild, idEventThread, dwmsEventTime, filter)
                                    Critical(originalCritical)
                                    return
                                }
                            }
                            Critical(originalCritical)
                            return
                        }
                    }
                    Critical(originalCritical)
                    return
                }
            }
        }
    }
    Critical(originalCritical)
}
WinEventFilter_14(hWinEventHook, event, hwnd, idObject, idChild, idEventThread, dwmsEventTime) {
    originalCritical := Critical(-1)
    if filter := WinEventFilter.Collection.Get(hWinEventHook) {
        if WinExist(hwnd) && RegExMatch(WinGetTitle(hwnd), filter.TitlePattern) {
            for _idObject in filter.Object {
                if idObject = _idObject {
                    for _event in filter.Event {
                        if event = _event {
                            filter.Callback.Call(hWinEventHook, event, hwnd, idObject, idChild, idEventThread, dwmsEventTime, filter)
                            Critical(originalCritical)
                            return
                        }
                    }
                    Critical(originalCritical)
                    return
                }
            }
        }
    }
    Critical(originalCritical)
}
WinEventFilter_15(hWinEventHook, event, hwnd, idObject, idChild, idEventThread, dwmsEventTime) {
    originalCritical := Critical(-1)
    if filter := WinEventFilter.Collection.Get(hWinEventHook) {
        if WinExist(hwnd) {
            for _idObject in filter.Object {
                if idObject = _idObject {
                    for _event in filter.Event {
                        if event = _event {
                            if RegExMatch(WinGetTitle(hwnd), filter.TitlePattern) {
                                filter.Callback.Call(hWinEventHook, event, hwnd, idObject, idChild, idEventThread, dwmsEventTime, filter)
                            } else {
                                for _hwnd in filter.Hwnd {
                                    if hwnd = _hwnd {
                                        filter.Callback.Call(hWinEventHook, event, hwnd, idObject, idChild, idEventThread, dwmsEventTime, filter)
                                        Critical(originalCritical)
                                        return
                                    }
                                }
                            }
                            Critical(originalCritical)
                            return
                        }
                    }
                    Critical(originalCritical)
                    return
                }
            }
        }
    }
    Critical(originalCritical)
}
