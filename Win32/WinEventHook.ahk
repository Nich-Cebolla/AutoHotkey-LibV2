
class WinEventHook {
    static __New() {
        this.DeleteProp('__New')
        proto := this.Prototype
        proto.Handle :=
        proto.Options :=
        proto.Proc :=
        ''
    }
    /**
     * @description - {@link WinEventHook} is a wrapper around
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setwineventhook}.
     *
     * Process functions:
     * - {@link https://learn.microsoft.com/en-us/windows/win32/winauto/getprocesshandlefromhwnd}
     * - {@link https://learn.microsoft.com/en-us/windows/win32/api/processthreadsapi/nf-processthreadsapi-getprocessid}
     * - {@link https://learn.microsoft.com/en-us/windows/win32/api/processthreadsapi/nf-processthreadsapi-getcurrentprocessid}
     * - {@link https://learn.microsoft.com/en-us/windows/win32/api/psapi/nf-psapi-enumprocesses}
     *
     *
     * Common event constants:
     * - EVENT_OBJECT_CONTENTSCROLLED - 0x8015
     * - EVENT_OBJECT_CREATE - 0x8000
     * - EVENT_OBJECT_DESTROY - 0x8001
     * - EVENT_OBJECT_FOCUS - 0x8005
     * - EVENT_OBJECT_HIDE - 0x8003
     * - EVENT_OBJECT_INVOKED - 0x8013
     * - EVENT_OBJECT_LOCATIONCHANGE - 0x800B
     * - EVENT_OBJECT_NAMECHANGE - 0x800C
     * - EVENT_OBJECT_TEXTSELECTIONCHANGED - 0x8014
     * - EVENT_SYSTEM_FOREGROUND - 0x0003
     * - EVENT_SYSTEM_MOVESIZEEND - 0x000B
     * - EVENT_SYSTEM_MOVESIZESTART - 0x000A
     * - EVENT_SYSTEM_SCROLLINGEND - 0x0013
     * - EVENT_SYSTEM_SCROLLINGSTART - 0x0012
     * - EVENT_OBJECT_SHOW - 0x8002
     * - EVENT_SYSTEM_SOUND - 0x0001
     * - EVENT_SYSTEM_SWITCHEND - 0x0015
     * - EVENT_SYSTEM_SWITCHSTART - 0x0014
     *
     * @param {Object} Options - An object with options as property : value pairs.
     * The property "Proc" is required.
     *
     * @param {Boolean} [Options.DeferHook = false] - If true, `SetWinEventHook` is not called;
     * your code must call {@link WinEventHook.Prototype.Hook}.
     *
     * @param {Integer} [Options.Flags = WINEVENT_OUTOFCONTEXT] - The following flag combinations
     * are valid:
     * - WINEVENT_INCONTEXT | WINEVENT_SKIPOWNPROCESS
     * - WINEVENT_INCONTEXT | WINEVENT_SKIPOWNTHREAD
     * - WINEVENT_OUTOFCONTEXT | WINEVENT_SKIPOWNPROCESS
     * - WINEVENT_OUTOFCONTEXT | WINEVENT_SKIPOWNTHREAD
     *
     * Additionally, client applications can specify WINEVENT_INCONTEXT, or WINEVENT_OUTOFCONTEXT alone.
     *
     * @param {Integer} [Options.Hmod = 0] - Handle to the DLL that contains the hook function at
     * lpfnWinEventProc, if the WINEVENT_INCONTEXT flag is specified in the dwFlags parameter. If
     * the hook function is not located in a DLL, or if the WINEVENT_OUTOFCONTEXT flag is specified,
     * this parameter is NULL.
     *
     * @param {Integer} [Options.Min = 0x00000001] - Specifies the
     * {@link https://learn.microsoft.com/en-us/windows/desktop/WinAuto/event-constants event constant}
     * for the lowest event value in the range of events that are handled by the hook function. This
     * parameter can be set to EVENT_MIN to indicate the lowest possible event value. The default
     * is EVENT_MIN.
     *
     * @param {Integer} [Options.Max = 0x7FFFFFFF] - Specifies the
     * {@link https://learn.microsoft.com/en-us/windows/desktop/WinAuto/event-constants event constant}
     * for the greatest event value in the range of events that are handled by the hook function. This
     * parameter can be set to EVENT_MAX to indicate the highest possible event value. THe default
     * is EVENT_MAX.
     *
     * @param {*} Options.Proc - A `Func`, callable object, or pointer to a
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nc-winuser-wineventproc WINEVENTPROC}.
     *
     * @param {Integer} [Options.Process = 0] - Specifies the ID of the process from which the hook
     * function receives events. Specify zero (0) to receive events from all processes on the current
     * desktop.
     *
     * @param {Integer} [Options.Thread = 0] - Specifies the ID of the thead from which the hook
     * function receives events. Specify zero (0) to receive events from all thread on the current
     * desktop.
     */
    __New(Options) {
        options := this.Options := WinEventHook.Options(Options)
        if !options.DeferHook {
            this.Hook()
        }
    }
    Hook() {
        if !this.Handle {
            options := this.Options
            if !this.Proc {
                if IsObject(options.Proc) {
                    this.Proc := CallbackCreate(options.Proc)
                } else {
                    this.Proc := options.Proc
                }
            }
            if !(this.Handle := DllCall(
                'SetWinEventHook'
              , 'uint', options.Min
              , 'uint', options.Max
              , 'ptr', options.Hmod
              , 'ptr', this.Proc
              , 'ptr', options.Process
              , 'ptr', options.Thread
              , 'uint', options.Flags
              , 'ptr'
            )) {
                if IsObject(options.Proc) {
                    CallbackFree(this.Proc)
                }
                this.DeleteProp('Proc')
                this.DeleteProp('Handle')
                throw OSError()
            }
        }
    }
    Unhook() {
        if this.Handle {
            if !DllCall('UnhookWinEvent', 'ptr', this.Handle, 'int') {
                throw OSError()
            }
            this.DeleteProp('Handle')
        }
        if this.Proc {
            if IsObject(this.Options.Proc) {
                CallbackFree(this.Proc)
            }
            this.DeleteProp('Proc')
        }
    }
    __Delete() {
        this.Unhook()
    }
    class Options {
        static __New() {
            this.DeleteProp('__New')
            WinEventHook_SetConstants()
            proto := this.Prototype
            proto.DeferHook := false
            proto.Flags := WINEVENT_OUTOFCONTEXT
            proto.Max := 0x7FFFFFFF
            proto.Min := 0x00000001
            proto.Proc := ''
            proto.Hmod :=
            proto.Process :=
            proto.Thread :=
            0
        }

        __New(options) {
            if !HasProp(options, 'Proc') {
                throw Error('``Options.Proc`` is expected to be a ``WINEVENTPROC``.')
            }
            for prop, val in WinEventHook.Options.Prototype.OwnProps() {
                if HasProp(options, prop) {
                    this.%prop% := options.%prop%
                }
            }
            if this.HasOwnProp('__Class') {
                this.DeleteProp('__Class')
            }
        }
    }
}

WinEventHook_SetConstants(force := false) {
    global
    if IsSet(WinEventHook_constants_set) && !force {
        return
    }
    WINEVENT_OUTOFCONTEXT := 0x0000
    WINEVENT_SKIPOWNTHREAD := 0x0001
    WINEVENT_SKIPOWNPROCESS := 0x0002
    WINEVENT_INCONTEXT := 0x0004
    OBJID_WINDOW := 0x00000000
    OBJID_SYSMENU := 0xFFFFFFFF
    OBJID_TITLEBAR := 0xFFFFFFFE
    OBJID_MENU := 0xFFFFFFFD
    OBJID_CLIENT := 0xFFFFFFFC
    OBJID_VSCROLL := 0xFFFFFFFB
    OBJID_HSCROLL := 0xFFFFFFFA
    OBJID_SIZEGRIP := 0xFFFFFFF9
    OBJID_CARET := 0xFFFFFFF8
    OBJID_CURSOR := 0xFFFFFFF7
    OBJID_ALERT := 0xFFFFFFF6
    OBJID_SOUND := 0xFFFFFFF5
    OBJID_QUERYCLASSNAMEIDX := 0xFFFFFFF4
    OBJID_NATIVEOM := 0xFFFFFFF0

    WinEventHook_constants_set := true
}
