/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/GDI/GdipStartup.ahk
    Author: Nich-Cebolla
    License: MIT
*/

; https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/LibraryManager.ahk
#include <LibraryManager>

/**
 * @classdesc -
 * The benefit to using {@link GdipStartup} to handle initializing and terminating Gdiplus is that each
 * caller is responsible for managing its own token and its own gdiplus reference, and that
 * responsibility is encapsulated in an easy-to-use class.
 *
 * The Windows API that handles calls to `LoadLibrary` and `FreeLibrary` uses a reference count system.
 * If a library has already been loaded by a process, and if `LoadLibrary` is called for that same
 * library again, the reference count is incremented. When `FreeLibrary` is called, the reference count
 * is decremented. If the reference count reaches 0, the library is actually unloaded. The handle
 * returned by `LoadLibrary` is the same each time.
 *
 * The Windows API that handles calls to `GdiplusStartup` and `GdiplusShutdown` works slightly
 * differently. The token returned by `GdiplusStartup` is different for each call.
 *
 * Using {@link GdipStartup} is straightforward: Each subprocess should obtain its own reference to a
 * {@link GdipStartup} object. When that subprocess is no longer needed, or when that subprocess no
 * longer needs GDI+, it should call {@link GdipStartup.Prototype.Shutdown}. The subprocess can
 * maintain its {@link GdipStartup} object; if GDI+ is needed again in the future, simply call
 * {@link GdipStartup.Prototype.Startup} to obtain a new token.
 *
 * With this approach, there are never any issues with one subprocess freeing GDI+ when another
 * subprocess still needs access to it.
 */
class GdipStartup {
    static __New() {
        global g_proc_gdiplus_GdiplusShutdown, g_proc_gdiplus_GdiplusStartup
        this.DeleteProp('__New')
        this.Prototype.LibToken := 0
        if !IsSet(g_proc_gdiplus_GdiplusShutdown) {
            g_proc_gdiplus_GdiplusShutdown := 0
        }
        if !IsSet(g_proc_gdiplus_GdiplusStartup) {
            g_proc_gdiplus_GdiplusStartup := 0
        }
    }
    /**
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/gdiplusinit/nf-gdiplusinit-gdiplusstartup}
     * @param {Boolean} [Startup = true] - If true, {@link GdipStartup.Prototype.Startup} is called.
     * @param {Integer} [DebugEventCallback = 0] - See
     * {@link https://learn.microsoft.com/en-us/windows/desktop/api/gdiplusinit/ns-gdiplusinit-gdiplusstartupinput GdiplusStartupInput}
     * for info.
     * @param {Integer} [SuppressBackgroundThread = 0] - See
     * {@link https://learn.microsoft.com/en-us/windows/desktop/api/gdiplusinit/ns-gdiplusinit-gdiplusstartupinput GdiplusStartupInput}
     * for info.
     */
    __New(Startup := true, DebugEventCallback := 0, SuppressBackgroundThread := 0) {
        this.Input := GdiplusStartupInput(DebugEventCallback, SuppressBackgroundThread)
        this.__Token := GdiplusToken()
        if Startup {
            this.Startup()
        }
    }
    Startup() {
        if this.Token {
            throw Error('The Gdiplus token is already active.', -1)
        } else {
            this.LibToken := LibraryManager(Map('gdiplus', ['GdiplusStartup', 'GdiplusShutdown']))
            if this.Input.SuppressBackgroundThread {
                if !this.HasOwnProp('Output') {
                    this.Output := GdiplusStartupOutput()
                }
                if status := DllCall(g_proc_gdiplus_GdiplusStartup, 'ptr', this.__Token, 'ptr', this.Input, 'ptr', this.Output, 'uint') {
                    throw OSError('``GdiplusStartup`` failed.', -1, 'Status: ' status)
                }
            } else if status := DllCall(g_proc_gdiplus_GdiplusStartup, 'ptr', this.__Token, 'ptr', this.Input, 'ptr', 0, 'uint') {
                throw OSError('``GdiplusStartup`` failed.', -1, 'Status: ' status)
            }
        }
    }
    Shutdown() {
        if this.Token {
            DllCall(g_proc_gdiplus_GdiplusShutdown, 'ptr', this.Token)
            this.LibToken.Free()
            this.Token := this.LibToken := 0
            if this.HasOwnProp('Output') {
                this.Output.NotificationUnhook := this.Output.NotificationHook := 0
            }
        } else {
            throw Error('There is no Gdiplus token to shutdown.', -1)
        }
    }
    Hook() {
        if !this.HasOwnProp('__NotificationHookToken') {
            this.__NotificationHookToken := GdipNotificationHookToken()
        }
        if this.NotificationHookToken {
            throw Error('The notification hook proc has already been called.', -1)
        } else {
            DllCall(this.Output.NotificationHook, 'ptr', this.__NotificationHookToken)
        }
    }
    Unhook() {
        if this.NotificationHookToken {
            DllCall(this.Output.NotificationUnhook, 'ptr', this.__NotificationHookToken)
            this.NotificationHookToken := 0
        } else {
            throw Error('The notification hook proc has not been called.', -1)
        }
    }
    NotificationHookToken {
        Get => NumGet(this.__NotificationHookToken, 0, 'ptr')
        Set => NumPut('ptr', Value, this.__NotificationHookToken, 0)
    }
    Token {
        Get => NumGet(this.__Token, 0, 'ptr')
        Set => NumPut('ptr', Value, this.__Token, 0)
    }
    __Delete() {
        if this.Token {
            DllCall('gdiplus\GdiplusShutdown', 'ptr', this.Token)
        }
        if this.LibToken {
            this.LibToken.Free()
        }
    }
}

class GdiplusStartupInput {
    static __New() {
        this.DeleteProp('__New')
        proto := this.Prototype
        proto.cbSize :=
        ; Size      Type                Symbol                      Offset               Padding
        A_PtrSize + ; UINT32            GdiplusVersion              0                    +4 on x64 only
        A_PtrSize + ; DebugEventProc    DebugEventCallback          0 + A_PtrSize * 1
        4 +         ; BOOL              SuppressBackgroundThread    0 + A_PtrSize * 2
        4           ; BOOL              SuppressExternalCodecs      4 + A_PtrSize * 2
        proto.offset_GdiplusVersion            := 0
        proto.offset_DebugEventCallback        := 0 + A_PtrSize * 1
        proto.offset_SuppressBackgroundThread  := 0 + A_PtrSize * 2
        proto.offset_SuppressExternalCodecs    := 4 + A_PtrSize * 2
    }
    /**
     * {@link https://learn.microsoft.com/en-us/windows/desktop/api/gdiplusinit/ns-gdiplusinit-gdiplusstartupinput}
     */
    __New(DebugEventCallback := 0, SuppressBackgroundThread := 0) {
        this.Buffer := Buffer(this.cbSize)
        this.GdiplusVersion := 1
        this.DebugEventCallback := DebugEventCallback
        this.SuppressBackgroundThread := SuppressBackgroundThread
        this.SuppressExternalCodecs := 0
    }
    GdiplusVersion {
        Get => NumGet(this.Buffer, this.offset_GdiplusVersion, 'uint')
        Set {
            NumPut('uint', Value, this.Buffer, this.offset_GdiplusVersion)
        }
    }
    DebugEventCallback {
        Get => NumGet(this.Buffer, this.offset_DebugEventCallback, 'ptr')
        Set {
            NumPut('ptr', Value, this.Buffer, this.offset_DebugEventCallback)
        }
    }
    SuppressBackgroundThread {
        Get => NumGet(this.Buffer, this.offset_SuppressBackgroundThread, 'uint')
        Set {
            NumPut('uint', Value, this.Buffer, this.offset_SuppressBackgroundThread)
        }
    }
    SuppressExternalCodecs {
        Get => NumGet(this.Buffer, this.offset_SuppressExternalCodecs, 'uint')
        Set {
            NumPut('uint', Value, this.Buffer, this.offset_SuppressExternalCodecs)
        }
    }
    Ptr => this.Buffer.Ptr
    Size => this.Buffer.Size
}

class GdiplusStartupOutput {
    static __New() {
        this.DeleteProp('__New')
        proto := this.Prototype
        proto.cbSize :=
        ; Size      Type                        Symbol                Offset               Padding
        A_PtrSize + ; NotificationHookProc      NotificationHook      0
        A_PtrSize   ; NotificationUnhookProc    NotificationUnhook    0 + A_PtrSize * 1
        proto.offset_NotificationHook    := 0
        proto.offset_NotificationUnhook  := 0 + A_PtrSize * 1
    }
    __New(NotificationHook?, NotificationUnhook?) {
        this.Buffer := Buffer(this.cbSize)
        if IsSet(NotificationHook) {
            this.NotificationHook := NotificationHook
        }
        if IsSet(NotificationUnhook) {
            this.NotificationUnhook := NotificationUnhook
        }
    }
    NotificationHook {
        Get => NumGet(this.Buffer, this.offset_NotificationHook, 'ptr')
        Set {
            NumPut('ptr', Value, this.Buffer, this.offset_NotificationHook)
        }
    }
    NotificationUnhook {
        Get => NumGet(this.Buffer, this.offset_NotificationUnhook, 'ptr')
        Set {
            NumPut('ptr', Value, this.Buffer, this.offset_NotificationUnhook)
        }
    }
    Ptr => this.Buffer.Ptr
    Size => this.Buffer.Size
}

class GdiplusToken extends Buffer {
    __New() {
        this.Size := A_PtrSize
        NumPut('ptr', 0, this)
    }
}

class GdipNotificationHookToken extends Buffer {
    __New() {
        this.Size := A_PtrSize
        NumPut('ptr', 0, this)
    }
}
