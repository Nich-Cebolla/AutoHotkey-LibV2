
/**
 * <pre>
 * typedef struct tagWINDOWINFO {
 *   DWORD cbSize;
 *   RECT  rcWindow;
 *   RECT  rcClient;
 *   DWORD dwStyle;
 *   DWORD dwExStyle;
 *   DWORD dwWindowStatus;
 *   UINT  cxWindowBorders;
 *   UINT  cyWindowBorders;
 *   ATOM  atomWindowType;
 *   WORD  wCreatorVersion;
 * } WINDOWINFO, *PWINDOWINFO, *LPWINDOWINFO;
 * </pre>
 *
 * The RECT members are split into their components.
 */
class WindowInfo {
    static __New() {
        this.DeleteProp('__New')
        proto := this.Prototype
        proto.cbSizeInstance :=
        ; SizeType       Symbol             OffsetPadding
        4 +   ; DWORD    cbSize             0
        4 +   ; INT      lWindow            4
        4 +   ; INT      tWindow            8
        4 +   ; INT      rWindow            12
        4 +   ; INT      bWindow            16
        4 +   ; INT      lClient            20
        4 +   ; INT      tClient            24
        4 +   ; INT      rClient            28
        4 +   ; INT      bClient            32
        4 +   ; DWORD    dwStyle            36
        4 +   ; DWORD    dwExStyle          40
        4 +   ; DWORD    dwWindowStatus     44
        4 +   ; UINT     cxWindowBorders    48
        4 +   ; UINT     cyWindowBorders    52
        2 +   ; ATOM     atomWindowType     56
        2     ; WORD     wCreatorVersion    58
        proto.offset_cbSize           := 0
        proto.offset_lWindow          := 4
        proto.offset_tWindow          := 8
        proto.offset_rWindow          := 12
        proto.offset_bWindow          := 16
        proto.offset_lClient          := 20
        proto.offset_tClient          := 24
        proto.offset_rClient          := 28
        proto.offset_bClient          := 32
        proto.offset_dwStyle          := 36
        proto.offset_dwExStyle        := 40
        proto.offset_dwWindowStatus   := 44
        proto.offset_cxWindowBorders  := 48
        proto.offset_cyWindowBorders  := 52
        proto.offset_atomWindowType   := 56
        proto.offset_wCreatorVersion  := 58

        hMod := DllCall('GetModuleHandleW', 'wstr', 'user32', 'ptr')
        global g_user32_GetWindowInfo := DllCall('GetProcAddress', 'ptr', hMod, 'astr', 'GetWindowInfo', 'ptr')
    }
    __New(Hwnd?) {
        this.Buffer := Buffer(this.cbSizeInstance, 0)
        this.cbSize := this.cbSizeInstance
        if IsSet(Hwnd) {
            this(Hwnd)
        }
    }
    Call(Hwnd?) {
        if IsSet(Hwnd) {
            this.Hwnd := Hwnd
        }
        if !DllCall(g_user32_GetWindowInfo, 'ptr', this.Hwnd, 'ptr', this, 'int') {
            throw OSError()
        }
    }
    cbSize {
        Get => NumGet(this.Buffer, this.offset_cbSize, 'ptr')
        Set {
            NumPut('ptr', Value, this.Buffer, this.offset_cbSize)
        }
    }
    lWindow {
        Get => NumGet(this.Buffer, this.offset_lWindow, 'int')
        Set {
            NumPut('int', Value, this.Buffer, this.offset_lWindow)
        }
    }
    tWindow {
        Get => NumGet(this.Buffer, this.offset_tWindow, 'int')
        Set {
            NumPut('int', Value, this.Buffer, this.offset_tWindow)
        }
    }
    rWindow {
        Get => NumGet(this.Buffer, this.offset_rWindow, 'int')
        Set {
            NumPut('int', Value, this.Buffer, this.offset_rWindow)
        }
    }
    bWindow {
        Get => NumGet(this.Buffer, this.offset_bWindow, 'int')
        Set {
            NumPut('int', Value, this.Buffer, this.offset_bWindow)
        }
    }
    lClient {
        Get => NumGet(this.Buffer, this.offset_lClient, 'int')
        Set {
            NumPut('int', Value, this.Buffer, this.offset_lClient)
        }
    }
    tClient {
        Get => NumGet(this.Buffer, this.offset_tClient, 'int')
        Set {
            NumPut('int', Value, this.Buffer, this.offset_tClient)
        }
    }
    rClient {
        Get => NumGet(this.Buffer, this.offset_rClient, 'int')
        Set {
            NumPut('int', Value, this.Buffer, this.offset_rClient)
        }
    }
    bClient {
        Get => NumGet(this.Buffer, this.offset_bClient, 'int')
        Set {
            NumPut('int', Value, this.Buffer, this.offset_bClient)
        }
    }
    dwStyle {
        Get => NumGet(this.Buffer, this.offset_dwStyle, 'uint')
        Set {
            NumPut('uint', Value, this.Buffer, this.offset_dwStyle)
        }
    }
    dwExStyle {
        Get => NumGet(this.Buffer, this.offset_dwExStyle, 'uint')
        Set {
            NumPut('uint', Value, this.Buffer, this.offset_dwExStyle)
        }
    }
    dwWindowStatus {
        Get => NumGet(this.Buffer, this.offset_dwWindowStatus, 'uint')
        Set {
            NumPut('uint', Value, this.Buffer, this.offset_dwWindowStatus)
        }
    }
    cxWindowBorders {
        Get => NumGet(this.Buffer, this.offset_cxWindowBorders, 'uint')
        Set {
            NumPut('uint', Value, this.Buffer, this.offset_cxWindowBorders)
        }
    }
    cyWindowBorders {
        Get => NumGet(this.Buffer, this.offset_cyWindowBorders, 'uint')
        Set {
            NumPut('uint', Value, this.Buffer, this.offset_cyWindowBorders)
        }
    }
    atomWindowType {
        Get => NumGet(this.Buffer, this.offset_atomWindowType, 'short')
        Set {
            NumPut('short', Value, this.Buffer, this.offset_atomWindowType)
        }
    }
    wCreatorVersion {
        Get => NumGet(this.Buffer, this.offset_wCreatorVersion, 'ushort')
        Set {
            NumPut('ushort', Value, this.Buffer, this.offset_wCreatorVersion)
        }
    }
    Ptr => this.Buffer.Ptr
    Size => this.Buffer.Size
}
