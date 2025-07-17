
class Point extends Buffer {
        static FromMouse() {
            pt := Point()
            DllCall('User32.dll\GetCursorPos', 'ptr', pt, 'int')
        }
    __New(X?, Y?) {
        this.Size := 8
        if IsSet(X) {
            NumPut('Int', X, this, 0)
        }
        if IsSet(Y) {
            NumPut('Int', Y, this, 0)
        }
    }

    static ScreenToClient(Hwnd, X, Y) {
        pt := Point(X, Y)
        if !DllCall('ScreenToClient', 'ptr', Hwnd, 'ptr', pt, 'int') {
            throw OSError()
        }
        return pt
    }

    static ClientToScreen(Hwnd, X, Y) {
        pt := Point(X, Y)
        if !DllCall('ClientToScreen', 'ptr', Hwnd, 'ptr', pt, 'int') {
            throw OSError()
        }
        return pt
    }

    static GetCaretPos() {
        pt := Point()
        DllCall('GetCaretPos', 'ptr', pt, 'int')
        return pt
    }

    static SetCaretPos(X, Y) {
        return DllCall('SetCaretPos', 'int', X, 'int', Y, 'int')
    }
    /**
     * @param {Integer} X - The X coordinate.
     * @param {Integer} Y - The Y coordinate.
     * @param {String} Unit - One of the following:
     * - "mm" - millimeters
     * - "cm" - centimeters
     * - "in" - inches
     * @param {Integer} [Dpi] - If set, the dpi value. If unset, the dpi of monitor that contains the
     * point is used.
     * @returns {Point}
     */
    static LogToPhysical(X, Y, Unit, Dpi?) {
        switch Unit, 0 {
            case 'mm':
                return Point(X / Dpi * 25.4, Y / Dpi * 25.4)
            case 'cm':
                return Point(X / Dpi * 2.54, Y / Dpi * 2.54)
            case 'in':
                return Point(X / Dpi, Y / Dpi)
            default:
                if IsObject(Unit) {
                    throw TypeError('Invalid parameter type.', -1)
                } else {
                    throw ValueError('Unexpected value.', -1, Unit)
                }
        }
    }
    /**
     * @param {Integer} X - The X coordinate.
     * @param {Integer} Y - The Y coordinate.
     * @param {String} Unit - One of the following:
     * - "mm" - millimeters
     * - "cm" - centimeters
     * - "in" - inches
     * @param {Integer} [Dpi] - If set, the dpi value. If unset, the dpi of monitor that contains the
     * point is used.
     * @returns {Point}
     */
    static PhysicalToLog(X, Y, Unit, Dpi?) {
        switch Unit, 0 {
            case 'mm':
                return Point(X * Dpi / 25.4, Y * Dpi / 25.4)
            case 'cm':
                return Point(X * Dpi / 2.54, Y * Dpi / 2.54)
            case 'in':
                return Point(X * Dpi, Y * Dpi)
            default:
                if IsObject(Unit) {
                    throw TypeError('Invalid parameter type.', -1)
                } else {
                    throw ValueError('Unexpected value.', -1, Unit)
                }
        }
    }
    /**
     * @description - Use this to convert screen coordinates (which should already be contained by
     * this `Point` object), to client coordinates.
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-screentoclient}
     * @param {Integer} Hwnd - The handle to the window whose client area will be used for the conversion.
     * @param {Boolean} [InPlace = false] - If true, the function modifies the object's properties.
     * If false, the function creates a new object.
     * @returns {Point}
     */
    ToClient(Hwnd, InPlace := false) {
        pt := InPlace ? this : Point()
        if !DllCall('ScreenToClient', 'ptr', Hwnd, 'ptr', this, 'int') {
            throw OSError()
        }
        return pt
    }
    /**
     * @description - Use this to convert client coordinates (which should already be contained by
     * this `Point` object), to screen coordinates.
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-clienttoscreen}
     * @param {Integer} Hwnd - The handle to the window whose client area will be used for the conversion.
     * @param {Boolean} [InPlace = false] - If true, the function modifies the object's properties.
     * If false, the function creates a new object.
     * @returns {Point}
     */
    ToScreen(Hwnd, InPlace := false) {
        pt := InPlace ? this : Point()
        if !DllCall('ClientToScreen', 'ptr', Hwnd, 'ptr', this, 'int') {
            throw OSError()
        }
        return pt
    }
    /**
     * @param {String} Unit - One of the following:
     * - "mm" - millimeters
     * - "cm" - centimeters
     * - "in" - inches
     * @param {Boolean} [InPlace = false] - If true, the function modifies the object's properties.
     * If false, the function creates a new object.
     * @returns {Point}
     */
    LogToPhysical(Unit, InPlace := false) {
        pt :=  InPlace ? this : Point()
        switch Unit, 0 {
            case 'mm':
                NumPut('uint', Abs(this.X / this.Dpi * 25.4), 'uint', Abs(this.Y / this.Dpi * 25.4), pt)
            case 'cm':
                NumPut('uint', Abs(this.X / this.Dpi * 2.54), 'uint', Abs(this.Y / this.Dpi * 2.54), pt)
            case 'in':
                NumPut('uint', Abs(this.X / this.Dpi), 'uint', Abs(this.Y / this.Dpi), pt)
            default:
                if IsObject(Unit) {
                    throw TypeError('Invalid parameter type.', -1)
                } else {
                    throw ValueError('Unexpected value.', -1, Unit)
                }
        }
        return pt
    }
    /**
     * @param {String} Unit - One of the following:
     * - "mm" - millimeters
     * - "cm" - centimeters
     * - "in" - inches
     * @param {Boolean} [InPlace = false] - If true, the function modifies the object's properties.
     * If false, the function creates a new object.
     * @returns {Point}
     */
    PhysicalToLog(Unit, InPlace := false) {
        pt :=  InPlace ? this : Point()
        switch Unit, 0 {
            case 'mm':
                NumPut('uint', Abs(this.X * this.Dpi / 25.4), 'uint', Abs(this.Y * this.Dpi / 25.4), pt)
            case 'cm':
                NumPut('uint', Abs(this.X * this.Dpi / 2.54), 'uint', Abs(this.Y * this.Dpi / 2.54), pt)
            case 'in':
                NumPut('uint', Abs(this.X * this.Dpi), 'uint', Abs(this.Y * this.Dpi), pt)
            default:
                if IsObject(Unit) {
                    throw TypeError('Invalid parameter type.', -1)
                } else {
                    throw ValueError('Unexpected value.', -1, Unit)
                }
        }
        return pt
    }
    Dpi {
        Get {
            if DllCall('Shcore\GetDpiForMonitor', 'ptr'
                , DllCall('User32\MonitorFromPoint', 'ptr', this.Value, 'uint', 0, 'ptr')
            , 'uint', 0, 'uint*', &DpiX := 0, 'uint*', &DpiY := 0, 'int') {
                throw OSError('MonitorFomPoint received an invalid parameter.', -1)
            } else {
                return DpiX
            }
        }
    }
    X => NumGet(this, 'int')
    Y => NumGet(this, 4, 'int')
    Value => (this.X & 0xFFFFFFFF) | (this.Y << 32)
}
