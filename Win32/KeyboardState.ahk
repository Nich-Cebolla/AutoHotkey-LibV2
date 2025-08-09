
/**
 * @classdesc - Gets the state of all keys on the keyboard, or sets the state of the keys for
 * the current thread.
 *
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getkeyboardstate}
 *
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setkeyboardstate}
 */
class KeyboardState {
    __New(DeferActivation := false) {
        this.Buffer := Buffer(256)
        if !DeferActivation {
            this()
        }
    }
    Apply() {
        if !DllCall(
            'SetKeyboardState'
          , 'ptr', this.Buffer
          , 'int'
        ) {
            throw OSError()
        }
    }
    Call() {
        if !DllCall(
            'GetKeyboardState'
          , 'ptr', this.Buffer
          , 'int'
        ) {
            throw OSError()
        }
    }

    LBUTTON {    ; Left mouse button
        Get => NumGet(this, 0x01, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x01)
        }
    }
    RBUTTON {    ; Right mouse button
        Get => NumGet(this, 0x02, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x02)
        }
    }
    CANCEL {    ; Control-break processing
        Get => NumGet(this, 0x03, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x03)
        }
    }
    MBUTTON {    ; Middle mouse button
        Get => NumGet(this, 0x04, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x04)
        }
    }
    XBUTTON1 {    ; X1 mouse button
        Get => NumGet(this, 0x05, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x05)
        }
    }
    XBUTTON2 {    ; X2 mouse button
        Get => NumGet(this, 0x06, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x06)
        }
    }
    BACK {    ; Backspace key
        Get => NumGet(this, 0x08, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x08)
        }
    }
    TAB {    ; Tab key
        Get => NumGet(this, 0x09, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x09)
        }
    }
    CLEAR {    ; Clear key
        Get => NumGet(this, 0x0C, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x0C)
        }
    }
    RETURN {    ; Enter key
        Get => NumGet(this, 0x0D, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x0D)
        }
    }
    SHIFT {    ; Shift key
        Get => NumGet(this, 0x10, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x10)
        }
    }
    CONTROL {    ; Ctrl key
        Get => NumGet(this, 0x11, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x11)
        }
    }
    MENU {    ; Alt key
        Get => NumGet(this, 0x12, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x12)
        }
    }
    PAUSE {    ; Pause key
        Get => NumGet(this, 0x13, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x13)
        }
    }
    CAPITAL {    ; Caps lock key
        Get => NumGet(this, 0x14, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x14)
        }
    }
    CAPITAL_TOGGLE {
        Get => NumGet(this, 0x14, 'uchar') & 0x01
        Set {
            SetCapsLockState(Value)
        }
    }
    KANA {    ; IME Kana mode
        Get => NumGet(this, 0x15, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x15)
        }
    }
    HANGUL {    ; IME Hangul mode
        Get => NumGet(this, 0x15, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x15)
        }
    }
    IME_ON {    ; IME On
        Get => NumGet(this, 0x16, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x16)
        }
    }
    JUNJA {    ; IME Junja mode
        Get => NumGet(this, 0x17, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x17)
        }
    }
    FINAL {    ; IME final mode
        Get => NumGet(this, 0x18, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x18)
        }
    }
    HANJA {    ; IME Hanja mode
        Get => NumGet(this, 0x19, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x19)
        }
    }
    KANJI {    ; IME Kanji mode
        Get => NumGet(this, 0x19, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x19)
        }
    }
    IME_OFF {    ; IME Off
        Get => NumGet(this, 0x1A, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x1A)
        }
    }
    ESCAPE {    ; Esc key
        Get => NumGet(this, 0x1B, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x1B)
        }
    }
    CONVERT {    ; IME convert
        Get => NumGet(this, 0x1C, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x1C)
        }
    }
    NONCONVERT {    ; IME nonconvert
        Get => NumGet(this, 0x1D, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x1D)
        }
    }
    ACCEPT {    ; IME accept
        Get => NumGet(this, 0x1E, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x1E)
        }
    }
    MODECHANGE {    ; IME mode change request
        Get => NumGet(this, 0x1F, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x1F)
        }
    }
    SPACE {    ; Spacebar key
        Get => NumGet(this, 0x20, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x20)
        }
    }
    PRIOR {    ; Page up key
        Get => NumGet(this, 0x21, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x21)
        }
    }
    NEXT {    ; Page down key
        Get => NumGet(this, 0x22, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x22)
        }
    }
    END {    ; End key
        Get => NumGet(this, 0x23, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x23)
        }
    }
    HOME {    ; Home key
        Get => NumGet(this, 0x24, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x24)
        }
    }
    LEFT {    ; Left arrow key
        Get => NumGet(this, 0x25, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x25)
        }
    }
    UP {    ; Up arrow key
        Get => NumGet(this, 0x26, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x26)
        }
    }
    RIGHT {    ; Right arrow key
        Get => NumGet(this, 0x27, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x27)
        }
    }
    DOWN {    ; Down arrow key
        Get => NumGet(this, 0x28, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x28)
        }
    }
    SELECT {    ; Select key
        Get => NumGet(this, 0x29, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x29)
        }
    }
    PRINT {    ; Print key
        Get => NumGet(this, 0x2A, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x2A)
        }
    }
    EXECUTE {    ; Execute key
        Get => NumGet(this, 0x2B, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x2B)
        }
    }
    SNAPSHOT {    ; Print screen key
        Get => NumGet(this, 0x2C, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x2C)
        }
    }
    INSERT {    ; Insert key
        Get => NumGet(this, 0x2D, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x2D)
        }
    }
    DELETE {    ; Delete key
        Get => NumGet(this, 0x2E, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x2E)
        }
    }
    HELP {    ; Help key
        Get => NumGet(this, 0x2F, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x2F)
        }
    }
    0 {    ; 0 key
        Get => NumGet(this, 0x30, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x30)
        }
    }
    1 {    ; 1 key
        Get => NumGet(this, 0x31, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x31)
        }
    }
    2 {    ; 2 key
        Get => NumGet(this, 0x32, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x32)
        }
    }
    3 {    ; 3 key
        Get => NumGet(this, 0x33, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x33)
        }
    }
    4 {    ; 4 key
        Get => NumGet(this, 0x34, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x34)
        }
    }
    5 {    ; 5 key
        Get => NumGet(this, 0x35, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x35)
        }
    }
    6 {    ; 6 key
        Get => NumGet(this, 0x36, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x36)
        }
    }
    7 {    ; 7 key
        Get => NumGet(this, 0x37, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x37)
        }
    }
    8 {    ; 8 key
        Get => NumGet(this, 0x38, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x38)
        }
    }
    9 {    ; 9 key
        Get => NumGet(this, 0x39, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x39)
        }
    }
    A {    ; A key
        Get => NumGet(this, 0x41, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x41)
        }
    }
    B {    ; B key
        Get => NumGet(this, 0x42, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x42)
        }
    }
    C {    ; C key
        Get => NumGet(this, 0x43, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x43)
        }
    }
    D {    ; D key
        Get => NumGet(this, 0x44, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x44)
        }
    }
    E {    ; E key
        Get => NumGet(this, 0x45, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x45)
        }
    }
    F {    ; F key
        Get => NumGet(this, 0x46, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x46)
        }
    }
    G {    ; G key
        Get => NumGet(this, 0x47, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x47)
        }
    }
    H {    ; H key
        Get => NumGet(this, 0x48, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x48)
        }
    }
    I {    ; I key
        Get => NumGet(this, 0x49, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x49)
        }
    }
    J {    ; J key
        Get => NumGet(this, 0x4A, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x4A)
        }
    }
    K {    ; K key
        Get => NumGet(this, 0x4B, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x4B)
        }
    }
    L {    ; L key
        Get => NumGet(this, 0x4C, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x4C)
        }
    }
    M {    ; M key
        Get => NumGet(this, 0x4D, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x4D)
        }
    }
    N {    ; N key
        Get => NumGet(this, 0x4E, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x4E)
        }
    }
    O {    ; O key
        Get => NumGet(this, 0x4F, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x4F)
        }
    }
    P {    ; P key
        Get => NumGet(this, 0x50, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x50)
        }
    }
    Q {    ; Q key
        Get => NumGet(this, 0x51, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x51)
        }
    }
    R {    ; R key
        Get => NumGet(this, 0x52, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x52)
        }
    }
    S {    ; S key
        Get => NumGet(this, 0x53, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x53)
        }
    }
    T {    ; T key
        Get => NumGet(this, 0x54, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x54)
        }
    }
    U {    ; U key
        Get => NumGet(this, 0x55, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x55)
        }
    }
    V {    ; V key
        Get => NumGet(this, 0x56, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x56)
        }
    }
    W {    ; W key
        Get => NumGet(this, 0x57, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x57)
        }
    }
    X {    ; X key
        Get => NumGet(this, 0x58, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x58)
        }
    }
    Y {    ; Y key
        Get => NumGet(this, 0x59, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x59)
        }
    }
    Z {    ; Z key
        Get => NumGet(this, 0x5A, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x5A)
        }
    }
    LWIN {    ; Left Windows logo key
        Get => NumGet(this, 0x5B, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x5B)
        }
    }
    RWIN {    ; Right Windows logo key
        Get => NumGet(this, 0x5C, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x5C)
        }
    }
    APPS {    ; Application key
        Get => NumGet(this, 0x5D, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x5D)
        }
    }
    SLEEP {    ; Computer Sleep key
        Get => NumGet(this, 0x5F, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x5F)
        }
    }
    NUMPAD0 {    ; Numeric keypad 0 key
        Get => NumGet(this, 0x60, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x60)
        }
    }
    NUMPAD1 {    ; Numeric keypad 1 key
        Get => NumGet(this, 0x61, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x61)
        }
    }
    NUMPAD2 {    ; Numeric keypad 2 key
        Get => NumGet(this, 0x62, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x62)
        }
    }
    NUMPAD3 {    ; Numeric keypad 3 key
        Get => NumGet(this, 0x63, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x63)
        }
    }
    NUMPAD4 {    ; Numeric keypad 4 key
        Get => NumGet(this, 0x64, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x64)
        }
    }
    NUMPAD5 {    ; Numeric keypad 5 key
        Get => NumGet(this, 0x65, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x65)
        }
    }
    NUMPAD6 {    ; Numeric keypad 6 key
        Get => NumGet(this, 0x66, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x66)
        }
    }
    NUMPAD7 {    ; Numeric keypad 7 key
        Get => NumGet(this, 0x67, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x67)
        }
    }
    NUMPAD8 {    ; Numeric keypad 8 key
        Get => NumGet(this, 0x68, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x68)
        }
    }
    NUMPAD9 {    ; Numeric keypad 9 key
        Get => NumGet(this, 0x69, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x69)
        }
    }
    MULTIPLY {    ; Multiply key
        Get => NumGet(this, 0x6A, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x6A)
        }
    }
    ADD {    ; Add key
        Get => NumGet(this, 0x6B, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x6B)
        }
    }
    SEPARATOR {    ; Separator key
        Get => NumGet(this, 0x6C, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x6C)
        }
    }
    SUBTRACT {    ; Subtract key
        Get => NumGet(this, 0x6D, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x6D)
        }
    }
    DECIMAL {    ; Decimal key
        Get => NumGet(this, 0x6E, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x6E)
        }
    }
    DIVIDE {    ; Divide key
        Get => NumGet(this, 0x6F, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x6F)
        }
    }
    F1 {    ; F1 key
        Get => NumGet(this, 0x70, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x70)
        }
    }
    F2 {    ; F2 key
        Get => NumGet(this, 0x71, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x71)
        }
    }
    F3 {    ; F3 key
        Get => NumGet(this, 0x72, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x72)
        }
    }
    F4 {    ; F4 key
        Get => NumGet(this, 0x73, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x73)
        }
    }
    F5 {    ; F5 key
        Get => NumGet(this, 0x74, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x74)
        }
    }
    F6 {    ; F6 key
        Get => NumGet(this, 0x75, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x75)
        }
    }
    F7 {    ; F7 key
        Get => NumGet(this, 0x76, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x76)
        }
    }
    F8 {    ; F8 key
        Get => NumGet(this, 0x77, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x77)
        }
    }
    F9 {    ; F9 key
        Get => NumGet(this, 0x78, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x78)
        }
    }
    F10 {    ; F10 key
        Get => NumGet(this, 0x79, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x79)
        }
    }
    F11 {    ; F11 key
        Get => NumGet(this, 0x7A, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x7A)
        }
    }
    F12 {    ; F12 key
        Get => NumGet(this, 0x7B, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x7B)
        }
    }
    F13 {    ; F13 key
        Get => NumGet(this, 0x7C, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x7C)
        }
    }
    F14 {    ; F14 key
        Get => NumGet(this, 0x7D, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x7D)
        }
    }
    F15 {    ; F15 key
        Get => NumGet(this, 0x7E, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x7E)
        }
    }
    F16 {    ; F16 key
        Get => NumGet(this, 0x7F, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x7F)
        }
    }
    F17 {    ; F17 key
        Get => NumGet(this, 0x80, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x80)
        }
    }
    F18 {    ; F18 key
        Get => NumGet(this, 0x81, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x81)
        }
    }
    F19 {    ; F19 key
        Get => NumGet(this, 0x82, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x82)
        }
    }
    F20 {    ; F20 key
        Get => NumGet(this, 0x83, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x83)
        }
    }
    F21 {    ; F21 key
        Get => NumGet(this, 0x84, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x84)
        }
    }
    F22 {    ; F22 key
        Get => NumGet(this, 0x85, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x85)
        }
    }
    F23 {    ; F23 key
        Get => NumGet(this, 0x86, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x86)
        }
    }
    F24 {    ; F24 key
        Get => NumGet(this, 0x87, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x87)
        }
    }
    NUMLOCK {    ; Num lock key
        Get => NumGet(this, 0x90, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x90)
        }
    }
    NUMLOCK_TOGGLE {
        Get => NumGet(this, 0x90, 'uchar') & 0x01
        Set {
            SetNumLockState(Value)
        }
    }
    SCROLL {    ; Scroll lock key
        Get => NumGet(this, 0x91, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0x91)
        }
    }
    SCROLL_TOGGLE {
        Get => NumGet(this, 0x91, 'uchar') & 0x01
        Set {
            SetScrollLockState(Value)
        }
    }
    LSHIFT {    ; Left Shift key
        Get => NumGet(this, 0xA0, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0xA0)
        }
    }
    RSHIFT {    ; Right Shift key
        Get => NumGet(this, 0xA1, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0xA1)
        }
    }
    LCONTROL {    ; Left Ctrl key
        Get => NumGet(this, 0xA2, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0xA2)
        }
    }
    RCONTROL {    ; Right Ctrl key
        Get => NumGet(this, 0xA3, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0xA3)
        }
    }
    LMENU {    ; Left Alt key
        Get => NumGet(this, 0xA4, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0xA4)
        }
    }
    RMENU {    ; Right Alt key
        Get => NumGet(this, 0xA5, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0xA5)
        }
    }
    BROWSER_BACK {    ; Browser Back key
        Get => NumGet(this, 0xA6, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0xA6)
        }
    }
    BROWSER_FORWARD {    ; Browser Forward key
        Get => NumGet(this, 0xA7, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0xA7)
        }
    }
    BROWSER_REFRESH {    ; Browser Refresh key
        Get => NumGet(this, 0xA8, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0xA8)
        }
    }
    BROWSER_STOP {    ; Browser Stop key
        Get => NumGet(this, 0xA9, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0xA9)
        }
    }
    BROWSER_SEARCH {    ; Browser Search key
        Get => NumGet(this, 0xAA, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0xAA)
        }
    }
    BROWSER_FAVORITES {    ; Browser Favorites key
        Get => NumGet(this, 0xAB, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0xAB)
        }
    }
    BROWSER_HOME {    ; Browser Start and Home key
        Get => NumGet(this, 0xAC, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0xAC)
        }
    }
    VOLUME_MUTE {    ; Volume Mute key
        Get => NumGet(this, 0xAD, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0xAD)
        }
    }
    VOLUME_DOWN {    ; Volume Down key
        Get => NumGet(this, 0xAE, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0xAE)
        }
    }
    VOLUME_UP {    ; Volume Up key
        Get => NumGet(this, 0xAF, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0xAF)
        }
    }
    MEDIA_NEXT_TRACK {    ; Next Track key
        Get => NumGet(this, 0xB0, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0xB0)
        }
    }
    MEDIA_PREV_TRACK {    ; Previous Track key
        Get => NumGet(this, 0xB1, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0xB1)
        }
    }
    MEDIA_STOP {    ; Stop Media key
        Get => NumGet(this, 0xB2, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0xB2)
        }
    }
    MEDIA_PLAY_PAUSE {    ; Play/Pause Media key
        Get => NumGet(this, 0xB3, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0xB3)
        }
    }
    LAUNCH_MAIL {    ; Start Mail key
        Get => NumGet(this, 0xB4, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0xB4)
        }
    }
    LAUNCH_MEDIA_SELECT {    ; Select Media key
        Get => NumGet(this, 0xB5, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0xB5)
        }
    }
    LAUNCH_APP1 {    ; Start Application 1 key
        Get => NumGet(this, 0xB6, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0xB6)
        }
    }
    LAUNCH_APP2 {    ; Start Application 2 key
        Get => NumGet(this, 0xB7, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0xB7)
        }
    }
    OEM_1 {    ; It can vary by keyboard. For the US ANSI keyboard, the Semiсolon and Colon key
        Get => NumGet(this, 0xBA, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0xBA)
        }
    }
    OEM_PLUS {    ; For any country/region, the Equals and Plus key
        Get => NumGet(this, 0xBB, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0xBB)
        }
    }
    OEM_COMMA {    ; For any country/region, the Comma and Less Than key
        Get => NumGet(this, 0xBC, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0xBC)
        }
    }
    OEM_MINUS {    ; For any country/region, the Dash and Underscore key
        Get => NumGet(this, 0xBD, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0xBD)
        }
    }
    OEM_PERIOD {    ; For any country/region, the Period and Greater Than key
        Get => NumGet(this, 0xBE, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0xBE)
        }
    }
    OEM_2 {    ; It can vary by keyboard. For the US ANSI keyboard, the Forward Slash and Question Mark key
        Get => NumGet(this, 0xBF, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0xBF)
        }
    }
    OEM_3 {    ; It can vary by keyboard. For the US ANSI keyboard, the Grave Accent and Tilde key
        Get => NumGet(this, 0xC0, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0xC0)
        }
    }
    OEM_4 {    ; It can vary by keyboard. For the US ANSI keyboard, the Left Brace key
        Get => NumGet(this, 0xDB, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0xDB)
        }
    }
    OEM_5 {    ; It can vary by keyboard. For the US ANSI keyboard, the Backslash and Pipe key
        Get => NumGet(this, 0xDC, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0xDC)
        }
    }
    OEM_6 {    ; It can vary by keyboard. For the US ANSI keyboard, the Right Brace key
        Get => NumGet(this, 0xDD, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0xDD)
        }
    }
    OEM_7 {    ; It can vary by keyboard. For the US ANSI keyboard, the Apostrophe and Double Quotation Mark key
        Get => NumGet(this, 0xDE, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0xDE)
        }
    }
    OEM_8 {    ; It can vary by keyboard. For the Canadian CSA keyboard, the Right Ctrl key
        Get => NumGet(this, 0xDF, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0xDF)
        }
    }
    OEM_102 {    ; It can vary by keyboard. For the European ISO keyboard, the Backslash and Pipe key
        Get => NumGet(this, 0xE2, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0xE2)
        }
    }
    PROCESSKEY {    ; IME PROCESS key
        Get => NumGet(this, 0xE5, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0xE5)
        }
    }
    PACKET {    ; Used to pass Unicode characters as if they were keystrokes. *Note1
        Get => NumGet(this, 0xE7, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0xE7)
        }
    }
    ATTN {    ; Attn key
        Get => NumGet(this, 0xF6, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0xF6)
        }
    }
    CRSEL {    ; CrSel key
        Get => NumGet(this, 0xF7, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0xF7)
        }
    }
    EXSEL {    ; ExSel key
        Get => NumGet(this, 0xF8, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0xF8)
        }
    }
    EREOF {    ; Erase EOF key
        Get => NumGet(this, 0xF9, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0xF9)
        }
    }
    PLAY {    ; Play key
        Get => NumGet(this, 0xFA, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0xFA)
        }
    }
    ZOOM {    ; Zoom key
        Get => NumGet(this, 0xFB, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0xFB)
        }
    }
    NONAME {    ; Reserved
        Get => NumGet(this, 0xFC, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0xFC)
        }
    }
    PA1 {    ; PA1 key
        Get => NumGet(this, 0xFD, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0xFD)
        }
    }
    OEM_CLEAR {    ; Clear key
        Get => NumGet(this, 0xFE, 'uchar') & 0x80
        Set {
            NumPut('uchar', Value ? 0x80 : 0, this, 0xFE)
        }
    }

    Ptr => this.Buffer.Ptr
    Size => this.Buffer.Size
}
