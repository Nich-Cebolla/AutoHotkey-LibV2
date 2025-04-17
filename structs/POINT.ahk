
class Point extends Buffer {
    __New(X?, Y?) {
        this.Size := 8
        if IsSet(X) {
            NumPut('Int', X, this, 0)
        }
        if IsSet(Y) {
            NumPut('Int', Y, this, 0)
        }
    }

    static ScreenToClient(X, Y) {
        Pt := Point(X, Y)
        Pt.ToClient()
        return Pt
    }

    static ClientToScreen(X, Y) {
        Pt := Point(X, Y)
        Pt.ToScreen()
        return Pt
    }

    static GetCaretPos() {
        DllCall('GetCaretPos', 'ptr', Pt := Point(), 'int')
        return Pt
    }

    static SetCaretPos(X, Y) {
        return DllCall('SetCaretPos', 'int', X, 'int', Y, 'int')
    }

    /**
     * @description - Use this to convert screen coordinates (which should already be contained by
     * this Point), to client coordinates. This converts the points in-place; it does not return
     * a new object.
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-screentoclient}
     * @param {Integer} Hwnd - The handle to the window whose client area will be used for the conversion.
     * @returns {Boolean} - If succesful, 1. If unsuccessful, 0.
     */
    ToClient(Hwnd) {
        return DllCall("ScreenToClient", "ptr", Hwnd, "ptr", this, 'int')
    }


    /**
     * @description - Use this to convert client coordinates (which should already be contained by
     * this Point), to screen coordinates. This converts the points in-place; it does not return
     * a new object.
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-clienttoscreen}
     * @param {Integer} Hwnd - The handle to the window whose client area will be used for the conversion.
     * @returns {Boolean} - If succesful, 1. If unsuccessful, 0.
     */
    ToScreen(Hwnd) {
        return DllCall("ClientToScreen", "ptr", Hwnd, "ptr", this, 'int')
    }

    X => NumGet(this, 'int')
    Y => NumGet(this, 4, 'int')
    Value => (this.X & 0xFFFFFFFF) | (this.Y << 32)
}
