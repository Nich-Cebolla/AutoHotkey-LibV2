#singleInstance force
g := Gui()
g.Add('Text', 'w400 h400 vTxt')
g.Add('Button', 'Section vBtn', 'Start loop').OnEvent('Click', ObjBindMethod(ToggleLoop, 'Call'))
g.Add('Button', 'ys vExit', 'Exit').OnEvent('Click', (*) => ExitApp())
g.Show()

kbs := KeyboardState()
; To get the keyboard state, call the object
kbs()

class ToggleLoop {
    static Status := 0
    static Call(*) {
        global kbs, g
        this.Status := !this.Status
        if this.Status {
            this.Loop()
            g['Btn'].Text := 'Stop loop'
        } else {
            g['Btn'].Text := 'Start loop'
        }
    }
    static Loop(*) {
        global kbs, g
        if !this.Status {
            return
        }
        proto := KeyboardState.Prototype
        kbs()
        s := ''
        ct := 0
        for prop in proto.OwnProps() {
            desc := proto.GetOwnPropDesc(prop)
            if desc.HasOwnProp('Get') {
                if !InStr(',Toggle,__Item,Byte,Ptr,Size,', ',' prop ',') {
                    if kbs.%prop% {
                        if ++ct > 10 {
                            s := SubStr(s, 1, -2) '`n'
                            ct := 0
                        }
                        s .= prop ', '
                    }
                }
            }
        }
        g['txt'].Text := SubStr(s, 1, -2)
        if this.Status {
            SetTimer(ObjBindMethod(this, 'Loop'), -25)
        }
    }
}


!1::QueryLButton()
!2::QueryRButton()
!3::QueryYButton()
!4::QuerySpaceBar()
^1::QueryLButton2()
^2::QueryRButton2()
^3::QueryYButton2()
^4::QuerySpaceBar2()


QueryLButton() {
    kbs.Async()
    MsgBox(kbs.LBUTTON)
}
QueryRButton() {
    kbs.Async()
    MsgBox(kbs.RBUTTON)
}
QueryYButton() {
    kbs.Async()
    MsgBox(kbs.Y)
}
QuerySpaceBar() {
    kbs.Async()
    MsgBox(kbs.SPACE)
}


QueryLButton2() {
    kbs()
    MsgBox(kbs.LBUTTON)
}
QueryRButton2() {
    kbs()
    MsgBox(kbs.RBUTTON)
}
QueryYButton2() {
    kbs()
    MsgBox(kbs.Y)
}
QuerySpaceBar2() {
    kbs()
    MsgBox(kbs.SPACE)
}


class wMsg {
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

        wMsg_SetConstants()
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
            g_user32_PeekMessageW
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

wMsg_SetConstants(force := false) {
    global
    if IsSet(wMsg_constants_set) && !force {
        return
    }

    local hMod := DllCall('GetModuleHandleW', 'wstr', 'user32', 'ptr')
    g_user32_PeekMessageW := DllCall('GetProcAddress', 'ptr', hMod, 'astr', 'PeekMessageW', 'ptr')

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

    wMsg_constants_set := 1
}

/**
 * @classdesc - Gets the state of all keys on the keyboard, or sets the state of the keys for
 * the current thread.
 *
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getkeyboardstate}
 *
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setkeyboardstate}
 *
 * There are two methods for getting the state of every key:
 * - {@link KeyboardState.Prototype.Call} will get the key state only for the script's thread. That
 *   is, if the foreground window is not owned by the script's process, it will not capture any changes
 *   in the up/down state of the keys.
 * - {@link KeyboardState.Prototype.Async} will work regadless of the owner of the foreground window.
 *
 * See the test script test-files\test-KeyboardState.ahk for a demo.
 */
class KeyboardState {
    static __New() {
        this.DeleteProp('__New')
        proto := this.Prototype
        proto.Msg := wMsg()
        KeyboardState_SetConstants()
    }
    /**
     * Thread-local keyboard state wrapper around GetKeyboardState / SetKeyboardState.
     * High bit (0x80) = key is down; low bit (0x01) = toggle (for toggle keys).
     */
    __New() {
        this.Buffer := Buffer(256, 0)
        this()
    }

    /**
     * Refreshes the values.
     */
    Call() {
        while this.Msg.Peek() {
            Sleep(16)
        }
        this.Get()
    }
    /**
     * Applies the values to the current thread.
     */
    Apply() {
        if !DllCall(g_user32_SetKeyboardState, 'ptr', this.Buffer, 'int') {
            throw OSError()
        }
    }
    Async() {
        ; Update 'down' (bit 7) from live async state
        loop 256 {
            vk := A_Index - 1
            async := DllCall(g_user32_GetAsyncKeyState, 'int', vk, 'short')
            b := NumGet(this.Buffer, vk, 'uchar') & 0x01 ; keep toggle bit
            if (async & 0x8000)
                b |= 0x80
            NumPut('uchar', b, this.Buffer, vk)
        }
        ; Refresh toggle keys' bit 0 from GetKeyState so toggles are accurate
        for vk in [0x14, 0x90, 0x91] { ; CAPS, NUM, SCROLL
            s := DllCall(g_user32_GetKeyState, 'int', vk, 'short')
            b := NumGet(this.Buffer, vk, 'uchar') & 0xFE
            if (s & 1)
                b |= 1
            NumPut('uchar', b, this.Buffer, vk)
        }
        return this
    }
    Get() {
        if !DllCall(g_user32_GetKeyboardState, 'ptr', this.Buffer, 'int') {
            throw OSError()
        }
    }

    /**
     * Boolean up/down accessor by VK code.
     */
    __Item[vk] {
        ; returns 0/1 (false/true)
        get => (NumGet(this.Buffer, vk, 'uchar') >> 7) & 1
        set {
            b := NumGet(this.Buffer, vk, 'uchar')
            NumPut('uchar', Value ? (b | 0x80) : (b & 0x7F), this.Buffer, vk)
        }
    }

    /**
     * Toggle-bit accessor (bit 0) for toggle keys
     */
    Toggle[vk] {
        get => NumGet(this.Buffer, vk, 'uchar') & 1
        set {
            b := NumGet(this.Buffer, vk, 'uchar')
            NumPut('uchar', Value ? (b | 0x01) : (b & 0xFE), this.Buffer, vk)
        }
    }

    /**
     * Optional: raw byte accessor (handy for debugging)
     */
    Byte[vk] {
        get => NumGet(this.Buffer, vk, 'uchar')            ; 0..255
        set => NumPut('uchar', Value & 0xFF, this.Buffer, vk)
    }

    LBUTTON {
        get => this[0x01]
        set => this[0x01] := Value
    }
    RBUTTON {
        get => this[0x02]
        set => this[0x02] := Value
    }
    CANCEL {
        get => this[0x03]
        set => this[0x03] := Value
    }
    MBUTTON {
        get => this[0x04]
        set => this[0x04] := Value
    }
    XBUTTON1 {
        get => this[0x05]
        set => this[0x05] := Value
    }
    XBUTTON2 {
        get => this[0x06]
        set => this[0x06] := Value
    }

    BACK {
        get => this[0x08]
        set => this[0x08] := Value
    }
    TAB {
        get => this[0x09]
        set => this[0x09] := Value
    }
    CLEAR {
        get => this[0x0C]
        set => this[0x0C] := Value
    }
    RETURN {
        get => this[0x0D]
        set => this[0x0D] := Value
    }

    SHIFT {
        get => this[0x10]
        set => this[0x10] := Value
    }
    CONTROL {
        get => this[0x11]
        set => this[0x11] := Value
    }
    MENU {
        get => this[0x12]
        set => this[0x12] := Value
    } ; Alt
    PAUSE {
        get => this[0x13]
        set => this[0x13] := Value
    }

    CAPITAL {
        get => this[0x14]
        set => this[0x14] := Value
    } ; CapsLock
    CAPITAL_TOGGLE {
        get => this.Toggle[0x14]
        set => this.Toggle[0x14] := Value
    }

    KANA {
        get => this[0x15]
        set => this[0x15] := Value
    }
    HANGUL {
        get => this[0x15]
        set => this[0x15] := Value
    }

    IME_ON {
        get => this[0x16]
        set => this[0x16] := Value
    }
    JUNJA {
        get => this[0x17]
        set => this[0x17] := Value
    }
    FINAL {
        get => this[0x18]
        set => this[0x18] := Value
    }
    HANJA {
        get => this[0x19]
        set => this[0x19] := Value
    }
    KANJI {
        get => this[0x19]
        set => this[0x19] := Value
    }
    IME_OFF {
        get => this[0x1A]
        set => this[0x1A] := Value
    }

    ESCAPE {
        get => this[0x1B]
        set => this[0x1B] := Value
    }
    CONVERT {
        get => this[0x1C]
        set => this[0x1C] := Value
    }
    NONCONVERT {
        get => this[0x1D]
        set => this[0x1D] := Value
    }
    ACCEPT {
        get => this[0x1E]
        set => this[0x1E] := Value
    }
    MODECHANGE {
        get => this[0x1F]
        set => this[0x1F] := Value
    }

    SPACE {
        get => this[0x20]
        set => this[0x20] := Value
    }
    PRIOR {
        get => this[0x21]
        set => this[0x21] := Value
    } ; PgUp
    NEXT {
        get => this[0x22]
        set => this[0x22] := Value
    } ; PgDn
    END {
        get => this[0x23]
        set => this[0x23] := Value
    }
    HOME {
        get => this[0x24]
        set => this[0x24] := Value
    }
    LEFT {
        get => this[0x25]
        set => this[0x25] := Value
    }
    UP {
        get => this[0x26]
        set => this[0x26] := Value
    }
    RIGHT {
        get => this[0x27]
        set => this[0x27] := Value
    }
    DOWN {
        get => this[0x28]
        set => this[0x28] := Value
    }
    SELECT {
        get => this[0x29]
        set => this[0x29] := Value
    }
    PRINT {
        get => this[0x2A]
        set => this[0x2A] := Value
    }
    EXECUTE {
        get => this[0x2B]
        set => this[0x2B] := Value
    }
    SNAPSHOT {
        get => this[0x2C]
        set => this[0x2C] := Value
    } ; PrintScreen
    INSERT {
        get => this[0x2D]
        set => this[0x2D] := Value
    }
    DELETE {
        get => this[0x2E]
        set => this[0x2E] := Value
    }
    HELP {
        get => this[0x2F]
        set => this[0x2F] := Value
    }

    ; Digits (top row)
    0 {
        get => this[0x30]
        set => this[0x30] := Value
    }
    1 {
        get => this[0x31]
        set => this[0x31] := Value
    }
    2 {
        get => this[0x32]
        set => this[0x32] := Value
    }
    3 {
        get => this[0x33]
        set => this[0x33] := Value
    }
    4 {
        get => this[0x34]
        set => this[0x34] := Value
    }
    5 {
        get => this[0x35]
        set => this[0x35] := Value
    }
    6 {
        get => this[0x36]
        set => this[0x36] := Value
    }
    7 {
        get => this[0x37]
        set => this[0x37] := Value
    }
    8 {
        get => this[0x38]
        set => this[0x38] := Value
    }
    9 {
        get => this[0x39]
        set => this[0x39] := Value
    }

    ; Letters
    A {
        get => this[0x41]
        set => this[0x41] := Value
    }
    B {
        get => this[0x42]
        set => this[0x42] := Value
    }
    C {
        get => this[0x43]
        set => this[0x43] := Value
    }
    D {
        get => this[0x44]
        set => this[0x44] := Value
    }
    E {
        get => this[0x45]
        set => this[0x45] := Value
    }
    F {
        get => this[0x46]
        set => this[0x46] := Value
    }
    G {
        get => this[0x47]
        set => this[0x47] := Value
    }
    H {
        get => this[0x48]
        set => this[0x48] := Value
    }
    I {
        get => this[0x49]
        set => this[0x49] := Value
    }
    J {
        get => this[0x4A]
        set => this[0x4A] := Value
    }
    K {
        get => this[0x4B]
        set => this[0x4B] := Value
    }
    L {
        get => this[0x4C]
        set => this[0x4C] := Value
    }
    M {
        get => this[0x4D]
        set => this[0x4D] := Value
    }
    N {
        get => this[0x4E]
        set => this[0x4E] := Value
    }
    O {
        get => this[0x4F]
        set => this[0x4F] := Value
    }
    P {
        get => this[0x50]
        set => this[0x50] := Value
    }
    Q {
        get => this[0x51]
        set => this[0x51] := Value
    }
    R {
        get => this[0x52]
        set => this[0x52] := Value
    }
    S {
        get => this[0x53]
        set => this[0x53] := Value
    }
    T {
        get => this[0x54]
        set => this[0x54] := Value
    }
    U {
        get => this[0x55]
        set => this[0x55] := Value
    }
    V {
        get => this[0x56]
        set => this[0x56] := Value
    }
    W {
        get => this[0x57]
        set => this[0x57] := Value
    }
    X {
        get => this[0x58]
        set => this[0x58] := Value
    }
    Y {
        get => this[0x59]
        set => this[0x59] := Value
    }
    Z {
        get => this[0x5A]
        set => this[0x5A] := Value
    }

    LWIN {
        get => this[0x5B]
        set => this[0x5B] := Value
    }
    RWIN {
        get => this[0x5C]
        set => this[0x5C] := Value
    }
    APPS {
        get => this[0x5D]
        set => this[0x5D] := Value
    }
    SLEEP {
        get => this[0x5F]
        set => this[0x5F] := Value
    }

    ; Numpad digits
    NUMPAD0 {
        get => this[0x60]
        set => this[0x60] := Value
    }
    NUMPAD1 {
        get => this[0x61]
        set => this[0x61] := Value
    }
    NUMPAD2 {
        get => this[0x62]
        set => this[0x62] := Value
    }
    NUMPAD3 {
        get => this[0x63]
        set => this[0x63] := Value
    }
    NUMPAD4 {
        get => this[0x64]
        set => this[0x64] := Value
    }
    NUMPAD5 {
        get => this[0x65]
        set => this[0x65] := Value
    }
    NUMPAD6 {
        get => this[0x66]
        set => this[0x66] := Value
    }
    NUMPAD7 {
        get => this[0x67]
        set => this[0x67] := Value
    }
    NUMPAD8 {
        get => this[0x68]
        set => this[0x68] := Value
    }
    NUMPAD9 {
        get => this[0x69]
        set => this[0x69] := Value
    }

    MULTIPLY {
        get => this[0x6A]
        set => this[0x6A] := Value
    }
    ADD {
        get => this[0x6B]
        set => this[0x6B] := Value
    }
    SEPARATOR {
        get => this[0x6C]
        set => this[0x6C] := Value
    }
    SUBTRACT {
        get => this[0x6D]
        set => this[0x6D] := Value
    }
    DECIMAL {
        get => this[0x6E]
        set => this[0x6E] := Value
    }
    DIVIDE {
        get => this[0x6F]
        set => this[0x6F] := Value
    }

    ; Function keys
    F1 {
        get => this[0x70]
        set => this[0x70] := Value
    }
    F2 {
        get => this[0x71]
        set => this[0x71] := Value
    }
    F3 {
        get => this[0x72]
        set => this[0x72] := Value
    }
    F4 {
        get => this[0x73]
        set => this[0x73] := Value
    }
    F5 {
        get => this[0x74]
        set => this[0x74] := Value
    }
    F6 {
        get => this[0x75]
        set => this[0x75] := Value
    }
    F7 {
        get => this[0x76]
        set => this[0x76] := Value
    }
    F8 {
        get => this[0x77]
        set => this[0x77] := Value
    }
    F9 {
        get => this[0x78]
        set => this[0x78] := Value
    }
    F10 {
        get => this[0x79]
        set => this[0x79] := Value
    }
    F11 {
        get => this[0x7A]
        set => this[0x7A] := Value
    }
    F12 {
        get => this[0x7B]
        set => this[0x7B] := Value
    }
    F13 {
        get => this[0x7C]
        set => this[0x7C] := Value
    }
    F14 {
        get => this[0x7D]
        set => this[0x7D] := Value
    }
    F15 {
        get => this[0x7E]
        set => this[0x7E] := Value
    }
    F16 {
        get => this[0x7F]
        set => this[0x7F] := Value
    }
    F17 {
        get => this[0x80]
        set => this[0x80] := Value
    }
    F18 {
        get => this[0x81]
        set => this[0x81] := Value
    }
    F19 {
        get => this[0x82]
        set => this[0x82] := Value
    }
    F20 {
        get => this[0x83]
        set => this[0x83] := Value
    }
    F21 {
        get => this[0x84]
        set => this[0x84] := Value
    }
    F22 {
        get => this[0x85]
        set => this[0x85] := Value
    }
    F23 {
        get => this[0x86]
        set => this[0x86] := Value
    }
    F24 {
        get => this[0x87]
        set => this[0x87] := Value
    }

    NUMLOCK {
        get => this[0x90]
        set => this[0x90] := Value
    }
    NUMLOCK_TOGGLE {
        get => this.Toggle[0x90]
        set => this.Toggle[0x90] := Value
    }

    SCROLL {
        get => this[0x91]
        set => this[0x91] := Value
    }
    SCROLL_TOGGLE {
        get => this.Toggle[0x91]
        set => this.Toggle[0x91] := Value
    }

    LSHIFT {
        get => this[0xA0]
        set => this[0xA0] := Value
    }
    RSHIFT {
        get => this[0xA1]
        set => this[0xA1] := Value
    }
    LCONTROL {
        get => this[0xA2]
        set => this[0xA2] := Value
    }
    RCONTROL {
        get => this[0xA3]
        set => this[0xA3] := Value
    }
    LMENU {
        get => this[0xA4]
        set => this[0xA4] := Value
    }
    RMENU {
        get => this[0xA5]
        set => this[0xA5] := Value
    }

    BROWSER_BACK {
        get => this[0xA6]
        set => this[0xA6] := Value
    }
    BROWSER_FORWARD {
        get => this[0xA7]
        set => this[0xA7] := Value
    }
    BROWSER_REFRESH {
        get => this[0xA8]
        set => this[0xA8] := Value
    }
    BROWSER_STOP {
        get => this[0xA9]
        set => this[0xA9] := Value
    }
    BROWSER_SEARCH {
        get => this[0xAA]
        set => this[0xAA] := Value
    }
    BROWSER_FAVORITES {
        get => this[0xAB]
        set => this[0xAB] := Value
    }
    BROWSER_HOME {
        get => this[0xAC]
        set => this[0xAC] := Value
    }

    VOLUME_MUTE {
        get => this[0xAD]
        set => this[0xAD] := Value
    }
    VOLUME_DOWN {
        get => this[0xAE]
        set => this[0xAE] := Value
    }
    VOLUME_UP {
        get => this[0xAF]
        set => this[0xAF] := Value
    }

    MEDIA_NEXT_TRACK {
        get => this[0xB0]
        set => this[0xB0] := Value
    }
    MEDIA_PREV_TRACK {
        get => this[0xB1]
        set => this[0xB1] := Value
    }
    MEDIA_STOP {
        get => this[0xB2]
        set => this[0xB2] := Value
    }
    MEDIA_PLAY_PAUSE {
        get => this[0xB3]
        set => this[0xB3] := Value
    }

    LAUNCH_MAIL {
        get => this[0xB4]
        set => this[0xB4] := Value
    }
    LAUNCH_MEDIA_SELECT {
        get => this[0xB5]
        set => this[0xB5] := Value
    }
    LAUNCH_APP1 {
        get => this[0xB6]
        set => this[0xB6] := Value
    }
    LAUNCH_APP2 {
        get => this[0xB7]
        set => this[0xB7] := Value
    }

    OEM_1 {
        get => this[0xBA]
        set => this[0xBA] := Value
    }
    OEM_PLUS {
        get => this[0xBB]
        set => this[0xBB] := Value
    }
    OEM_COMMA {
        get => this[0xBC]
        set => this[0xBC] := Value
    }
    OEM_MINUS {
        get => this[0xBD]
        set => this[0xBD] := Value
    }
    OEM_PERIOD {
        get => this[0xBE]
        set => this[0xBE] := Value
    }
    OEM_2 {
        get => this[0xBF]
        set => this[0xBF] := Value
    }
    OEM_3 {
        get => this[0xC0]
        set => this[0xC0] := Value
    }

    OEM_4 {
        get => this[0xDB]
        set => this[0xDB] := Value
    }
    OEM_5 {
        get => this[0xDC]
        set => this[0xDC] := Value
    }
    OEM_6 {
        get => this[0xDD]
        set => this[0xDD] := Value
    }
    OEM_7 {
        get => this[0xDE]
        set => this[0xDE] := Value
    }
    OEM_8 {
        get => this[0xDF]
        set => this[0xDF] := Value
    }

    OEM_102 {
        get => this[0xE2]
        set => this[0xE2] := Value
    }

    PROCESSKEY {
        get => this[0xE5]
        set => this[0xE5] := Value
    }
    PACKET {
        get => this[0xE7]
        set => this[0xE7] := Value
    }

    ATTN {
        get => this[0xF6]
        set => this[0xF6] := Value
    }
    CRSEL {
        get => this[0xF7]
        set => this[0xF7] := Value
    }
    EXSEL {
        get => this[0xF8]
        set => this[0xF8] := Value
    }
    EREOF {
        get => this[0xF9]
        set => this[0xF9] := Value
    }
    PLAY {
        get => this[0xFA]
        set => this[0xFA] := Value
    }
    ZOOM {
        get => this[0xFB]
        set => this[0xFB] := Value
    }
    NONAME {
        get => this[0xFC]
        set => this[0xFC] := Value
    }
    PA1 {
        get => this[0xFD]
        set => this[0xFD] := Value
    }
    OEM_CLEAR {
        get => this[0xFE]
        set => this[0xFE] := Value
    }

    Ptr  => this.Buffer.Ptr
    Size => this.Buffer.Size
}

KeyboardState_SetConstants(force := false) {
    global
    if IsSet(KeyboardState_constants_set) && !force {
        return
    }
    local hMod := DllCall('GetModuleHandleW', 'wstr', 'user32', 'ptr')
    g_user32_SetKeyboardState := DllCall('GetProcAddress', 'ptr', hMod, 'astr', 'SetKeyboardState', 'ptr')
    g_user32_GetAsyncKeyState := DllCall('GetProcAddress', 'ptr', hMod, 'astr', 'GetAsyncKeyState', 'ptr')
    g_user32_GetKeyState := DllCall('GetProcAddress', 'ptr', hMod, 'astr', 'GetKeyState', 'ptr')
    g_user32_GetKeyboardState := DllCall('GetProcAddress', 'ptr', hMod, 'astr', 'GetKeyboardState', 'ptr')

    KeyboardState_constants_set := 1
}
