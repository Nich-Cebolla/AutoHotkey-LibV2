/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/Win32/WindowsHook.ahk
    Author: Nich-Cebolla
    License: MIT
*/

/**
 * Calls `SetWindowsHookExW`.
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setwindowshookexw}
 */
class WindowsHook {
    static __New() {
        this.DeleteProp('__New')
        Proto := this.Prototype
        Proto.Handle := Proto.HookProcPtr := 0
    }
    /**
     * @class
     *
     * @param {Integer} HookId - The type of hook to be installed.
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setwindowshookexw}
     *
     * |  Hook Name           |  ID  |  Proc Type             |  lParam Points To       |  Use Case                                         |
     * |  --------------------|------|------------------------|-------------------------|-------------------------------------------------  |
     * |  WH_CALLWNDPROC      |  4   |  CallWndProc           |  CWPSTRUCT              |  Monitor before a message is processed            |
     * |  WH_CALLWNDPROCRET   |  12  |  CallWndRetProc        |  CWPRETSTRUCT           |  Monitor after a message is processed             |
     * |  WH_CBT              |  5   |  CBTProc               |  Varies by nCode        |  Window activation, creation, move, resize, etc.  |
     * |  WH_DEBUG            |  9   |  DebugProc             |  DEBUGHOOKINFO          |  Debugging other hook procedures                  |
     * |  WH_FOREGROUNDIDLE   |  11  |  ForegroundIdleProc    |  lParam unused          |  Detect idle foreground thread                    |
     * |  WH_GETMESSAGE       |  3   |  GetMsgProc            |  MSG                    |  Intercept message queue on removal               |
     * |  WH_JOURNALPLAYBACK  |  1   |  JournalPlaybackProc   |  EVENTMSG               |  Replay input events (obsolete)                   |
     * |  WH_JOURNALRECORD    |  0   |  JournalRecordProc     |  EVENTMSG               |  Record input events (obsolete)                   |
     * |  WH_KEYBOARD         |  2   |  KeyboardProc          |  lParam = packed flags  |  Keyboard input (per-thread)                      |
     * |  WH_KEYBOARD_LL      |  13  |  LowLevelKeyboardProc  |  KBDLLHOOKSTRUCT        |  Global keyboard input                            |
     * |  WH_MOUSE            |  7   |  MouseProc             |  MOUSEHOOKSTRUCT        |  Mouse events (per-thread)                        |
     * |  WH_MOUSE_LL         |  14  |  LowLevelMouseProc     |  MSLLHOOKSTRUCT         |  Global mouse input                               |
     * |  WH_MSGFILTER        |  -1  |  MessageProc           |  MSG                    |  Pre-translate messages in modal loops            |
     * |  WH_SHELL            |  10  |  ShellProc             |  Varies by nCode        |  Shell events (task switch, window create, etc.)  |
     * |  WH_SYSMSGFILTER     |  6   |  MessageProc           |  MSG                    |  Like WH_MSGFILTER, but system-wide               |
     *
     * @param {Func|BoundFunc} HookProc - The function that will be registered as the hook procedure.
     * You should read {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nc-winuser-hookproc}
     * before proceeding. I recommend defining a helper class that maps the struct member offsets
     * to object properties, but this is personal preference. Below is an example that uses the helper
     * class `MouseHookStruct`. You can run this example in the file "test\test-MouseHookStruct.ahk".
     * @example
     *  #include <WindowsHook>
     *  #include <MouseHookStruct>
     *
     *  MouseProc(code, wParam, lParam) {
     *      if code == 0 && wParam == 0x0200 {
     *          _mouseHookStruct := MouseHookStruct(lParam)
     *          test.Gui['Edt'].Text := ('The mouse moved to ( ' _mouseHookStruct.X ', ' _mouseHookStruct.Y ' )`n')
     *      }
     *      return DllCall(
     *          'CallNextHookEx'
     *        , 'ptr', 0
     *        , 'int', code
     *        , 'uptr', wParam
     *        , 'ptr', lParam
     *        , 'ptr'
     *      )
     *  }
     *
     * @param {Integer} [Hmod = 0] - The handle to the module that contains the dll. Leave 0 unless
     * you are specifically using this with an external dll.
     *
     * @param {Integer} [ThreadId] - The identifier of the thread with which the hook procedure is to
     * be associated. For desktop apps, if this parameter is zero, the hook procedure is associated
     * with all existing threads running in the same desktop as the calling thread. If unset, the
     * return value from `GetWindowThreadProcessId` for `A_ScriptHwnd` is used.
     *
     * @param {Boolean} [SetOnExit = true] - If true, sets an `OnExit` callback to call
     * `UnhookWindowsHookEx`. This is recommended by Microsoft:
     * "Before terminating, an application must call the UnhookWindowsHookEx function function to
     * free system resources associated with the hook."
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setwindowshookexw}.
     *
     * if `DeferActivation` is true, `SetOnExit` is ignored.
     *
     * @param {Boolean} [DeferActivation = false] - If true, `SetWindowsHookExW` is not called, your
     * code must call `WindowsHook.Prototype.Hook`.
     */
    __New(HookId, HookProc, Hmod := 0, ThreadId?, SetOnExit := true, DeferActivation := false) {
        this.HookId := HookId
        this.HookProc := HookProc
        this.HookProcPtr := CallbackCreate(HookProc)
        this.Hmod := Hmod
        this.ThreadId := ThreadId ?? DllCall('GetWindowThreadProcessId', 'ptr', A_ScriptHwnd, 'ptr', 0, 'uint')
        if !DeferActivation {
            this.Hook(SetOnExit)
        }
    }

    Dispose(*) {
        this.Unhook()
        if this.HookProcPtr {
            CallbackFree(this.HookProcPtr)
            this.HookProcPtr := 0
        }
    }

    /**
     * @param {Boolean} [SetOnExit = true] - If true, sets an `OnExit` callback to call
     * `UnhookWindowsHookEx`. This is recommended by Microsoft:
     * "Before terminating, an application must call the UnhookWindowsHookEx function function to
     * free system resources associated with the hook."
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setwindowshookexw}.
     */
    Hook(SetOnExit := true) {
        if this.Handle {
            throw Error('The hook is already active.', -1)
        }
        if this.Handle := DllCall(
            'SetWindowsHookExW'
          , 'int', this.HookId
          , 'ptr', this.HookProcPtr
          , 'ptr', this.Hmod
          , 'uint', this.ThreadId
          , 'int'
        ) {
            if SetOnExit {
                this.OnExitCallback := ObjBindMethod(this, 'Unhook')
                OnExit(this.OnExitCallback, 1)
            }
        } else {
            throw OSError()
        }
    }

    /**
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-unhookwindowshookex}
     * @returns {Boolean} - If the function succeeds, the return value is nonzero.
     * If the function fails, the return value is zero. To get extended error information, call `OSError`.
     */
    Unhook(*) {
        if this.Handle {
            handle := this.Handle
            this.Handle := 0
            OnExit(this.OnExitCallback, 0)
            return DllCall('UnhookWindowsHookEx', 'ptr', Handle, 'int')
        } else {
            throw Error('The hook is not currently active.', -1)
        }
    }

    __Delete() {
        this.Dispose()
    }
}
