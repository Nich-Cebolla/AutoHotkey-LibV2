
class Msg {
    static __New() {
        this.DeleteProp('__New')
        proto := this.Prototype
        proto.cbSizeInstance :=
        ; Size      Type        Symbol      Offset                Padding
        A_PtrSize + ; HWND      hwnd        0
        A_PtrSize + ; UINT      message     0 + A_PtrSize * 1     +4 on x64 only
        A_PtrSize + ; WPARAM    wParam      0 + A_PtrSize * 2
        A_PtrSize + ; LPARAM    lParam      0 + A_PtrSize * 3
        4 +         ; DWORD     time        0 + A_PtrSize * 4
        4 +         ; INT       x           4 + A_PtrSize * 4
        4 +         ; INT       y           8 + A_PtrSize * 4
        4           ; DWORD     lPrivate    12 + A_PtrSize * 4
        proto.offset_hwnd      := 0
        proto.offset_message   := 0 + A_PtrSize * 1
        proto.offset_wParam    := 0 + A_PtrSize * 2
        proto.offset_lParam    := 0 + A_PtrSize * 3
        proto.offset_time      := 0 + A_PtrSize * 4
        proto.offset_x         := 4 + A_PtrSize * 4
        proto.offset_y         := 8 + A_PtrSize * 4
        proto.offset_lPrivate  := 12 + A_PtrSize * 4

        Msg_SetConstants()
    }
    __New(hwnd?, message?, wParam?, lParam?, time?, x?, y?, lPrivate?) {
        this.Buffer := Buffer(this.cbSizeInstance)
        if IsSet(hwnd) {
            this.hwnd := hwnd
        }
        if IsSet(message) {
            this.message := message
        }
        if IsSet(wParam) {
            this.wParam := wParam
        }
        if IsSet(lParam) {
            this.lParam := lParam
        }
        if IsSet(time) {
            this.time := time
        }
        if IsSet(x) {
            this.x := x
        }
        if IsSet(y) {
            this.y := y
        }
        if IsSet(lPrivate) {
            this.lPrivate := lPrivate
        }
    }
    Peek(Hwnd := 0, MsgFilterMin := 0, MsgFilterMax := 0, RemoveMsg := PM_NOREMOVE) {
        return DllCall(
            'PeekMessageW'
          , 'ptr', this
          , 'ptr', Hwnd
          , 'uint', MsgFilterMin
          , 'uint', MsgFilterMax
          , 'uint', RemoveMsg
          , 'int'
        )
    }
    hwnd {
        Get => NumGet(this.Buffer, this.offset_hwnd, 'ptr')
        Set {
            NumPut('ptr', Value, this.Buffer, this.offset_hwnd)
        }
    }
    message {
        Get => NumGet(this.Buffer, this.offset_message, 'uint')
        Set {
            NumPut('uint', Value, this.Buffer, this.offset_message)
        }
    }
    wParam {
        Get => NumGet(this.Buffer, this.offset_wParam, 'ptr')
        Set {
            NumPut('ptr', Value, this.Buffer, this.offset_wParam)
        }
    }
    lParam {
        Get => NumGet(this.Buffer, this.offset_lParam, 'ptr')
        Set {
            NumPut('ptr', Value, this.Buffer, this.offset_lParam)
        }
    }
    time {
        Get => NumGet(this.Buffer, this.offset_time, 'uint')
        Set {
            NumPut('uint', Value, this.Buffer, this.offset_time)
        }
    }
    x {
        Get => NumGet(this.Buffer, this.offset_x, 'int')
        Set {
            NumPut('int', Value, this.Buffer, this.offset_x)
        }
    }
    y {
        Get => NumGet(this.Buffer, this.offset_y, 'int')
        Set {
            NumPut('int', Value, this.Buffer, this.offset_y)
        }
    }
    lPrivate {
        Get => NumGet(this.Buffer, this.offset_lPrivate, 'uint')
        Set {
            NumPut('uint', Value, this.Buffer, this.offset_lPrivate)
        }
    }
    Ptr => this.Buffer.Ptr
    Size => this.Buffer.Size
}

Msg_SetConstants(force := false) {
    global
    if IsSet(Msg_constants_set) && !force {
        return
    }

    WM_KEYFIRST             := 0x0100
    WM_MOUSEFIRST           := 0x0200
    PM_NOREMOVE             := 0x0000
    PM_REMOVE               := 0x0001
    PM_NOYIELD              := 0x0002
    QS_KEY                  := 0x0001
    QS_MOUSEMOVE            := 0x0002
    QS_MOUSEBUTTON          := 0x0004
    QS_POSTMESSAGE          := 0x0008
    QS_TIMER                := 0x0010
    QS_PAINT                := 0x0020
    QS_SENDMESSAGE          := 0x0040
    QS_HOTKEY               := 0x0080
    QS_ALLPOSTMESSAGE       := 0x0100
    QS_RAWINPUT             := 0x0400
    QS_TOUCH                := 0x0800
    QS_POINTER              := 0x1000
    QS_MOUSE := QS_MOUSEMOVE | QS_MOUSEBUTTON
    QS_INPUT := QS_MOUSE | QS_KEY | QS_RAWINPUT | QS_TOUCH | QS_POINTER
    ; Process mouse and keyboard messages.
    PM_QS_INPUT := QS_INPUT << 16
    ; Process all posted messages, including timers and hotkeys.
    PM_QS_POSTMESSAGE := (QS_POSTMESSAGE | QS_HOTKEY | QS_TIMER) << 16
    ; Process paint messages.
    PM_QS_PAINT := QS_PAINT << 16
    PM_QS_SENDMESSAGE := QS_SENDMESSAGE << 16

    Msg_constants_set := 1
}
