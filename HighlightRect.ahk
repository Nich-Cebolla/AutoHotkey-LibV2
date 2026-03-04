/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/HighlightRect.ahk
    Author: Nich-Cebolla
    License: MIT
*/

class HighlightRect extends Gui {
    static __New() {
        this.DeleteProp('__New')
        HighlightRect_SetConstants()
        proto := this.Prototype
        proto.__border := 2
        proto.__duration := 3000
        proto.__offsetL :=
        proto.__offsetT :=
        proto.__offsetR :=
        proto.__offsetB :=
        proto.__priority :=
        proto.__timer := 0
        proto.__callback :=
        proto.__callback_helper :=
        proto.__rect := ''
    }
    /**
     * @desc - Displays a the outline of a rectangle, and has methods for manipulating the rectangle.
     * Adapted from {@link https://github.com/Descolada/UIAutomation}.
     *
     * @class
     *
     * @param {Object} [options] - An object with zero or more options as property : value pairs.
     *
     * @param {Integer} [options.border = 2] - The border thickness in pixels.
     *
     *    Set property {@link HighlightRect#border border} to later change this option.
     *
     * @param {Integer} [options.color = 0x00E6FA] - The color of the highlight. Your code can
     *    use {@link HighlightRect_RGB} or {@link HighlightRect_RGBString} to get a COLORREF value.
     *    The default value is a light blue.
     *
     *    Set property {@link HighlightRect#color color} to later change this option.
     *
     * @param {*} [options.callback] - A `Func` or callable object that is called when `options.timer`
     *    is true. After {@link HighlightRect.Prototype.Call} is called,
     *    `options.callback` is called every `options.duration` milliseconds. `options.callback` is
     *    expected to update the position / dimensions of the highlight rectangle, if needed. If the
     *    callback returns a nonzero value, the timer ends and the highlight rectangle is hidden. If the
     *    callback returns zero or an empty string, the timer continues.
     *
     *    Parameters:
     *    1. **{HighlightRect}** - The {@link HighlightRect} object.
     *
     *    Returns: If the callback returns a nonzero value, the timer ends and the highlight rectangle
     *    is hidden. If the callback returns zero or an empty string, the timer continues.
     *
     *    `options.callback` is ignored if `options.timer` is `0`.
     *
     *    Set property {@link HighlightRect#callback callback} to later change this option.
     *
     * @param {Boolean} [options.deferShow = true] - If `options.deferShow` is true, your code must
     *    call {@link HighlightRect.Prototype.SetRect} or {@link HighlightRect.Prototype.SetRegion} to
     *    update the highlight rectangle's dimensions, then call {@link HighlightRect.Prototype.Call} to
     *    show the highlight rectangle.
     *
     *    If `options.deferShow` is false, those actions are done automatically after the object
     *    is constructed.
     *
     * @param {Integer} [options.duration = 3000] - The effect of `options.duration` depends on
     *    the value of `options.timer`
     *
     *    If `options.timer` is true: `options.duration` is the rate at which `options.callback` is called.
     *
     *    If `options.timer` is false: After {@link HighlightRect.Prototype.Call} is called, a timer
     *    is set to hide the highlight rectangle after `options.duration` milliseconds elapses.
     *
     *    Set property {@link HighlightRect#duration duration} to later change this option.
     *
     * @param {Integer} [options.offsetL] - Any number of pixels to offset the left side of the
     *    highlighted region.
     *
     *    Set property {@link HighlightRect#offsetL offsetL} to later change this option.
     *
     * @param {Integer} [options.offsetT] - Any number of pixels to offset the top of the
     *    highlighted region.
     *
     *    Set property {@link HighlightRect#offsetT offsetT} to later change this option.
     *
     * @param {Integer} [options.offsetR] - Any number of pixels to offset the right side of the
     *    highlighted region.
     *
     *    Set property {@link HighlightRect#offsetR offsetR} to later change this option.
     *
     * @param {Integer} [options.offsetB] - Any number of pixels to offset the bottom of the
     *    highlighted region.
     *
     *    Set property {@link HighlightRect#offsetB offsetB} to later change this option.
     *
     * @param {Integer} [options.priority = 0] - The value to pass to the "priority" parameter of
     *    {@link https://www.autohotkey.com/docs/v2/lib/SetTimer.htm SetTimer}.
     *
     *    Set property {@link HighlightRect#priority priority} to later change this option.
     *
     * @param {HighlightRect_Rect|HighlightRect_WinRect} [options.rect] - Either a
     *    {@link HighlightRect_Rect} or {@link HighlightRect_WinRect} object that contains the
     *    dimensions of the highlight rectangle.
     *
     *    Set property {@link HighlightRect#rect rect} or call {@link HighlightRect.Prototype.SetRect}
     *    to later change this option. Your code can also call {@link HighlightRect.Prototype.SetRegion}
     *    to update the dimensions of the rectangle directly.
     *
     * @param {Boolean} [options.timer = false] - If `options.timer` is true, then after
     *    {@link HighlightRect.Prototype.Call} is called, `options.callback` is called every
     *    `options.duration` milliseconds. `options.callback` is expected to update the position /
     *    dimensions of the highlight rectangle, if needed. If the callback returns a nonzero value,
     *    the timer ends and the highlight rectangle is hidden. If the callback returns zero or an empty
     *    string, the timer continues. If `options.callback` is not set, `options.timer` is ignored.
     *
     *    If `options.timer` is false, then after {@link HighlightRect.Prototype.Call} is called, a timer
     *    is set to hide the highlight rectangle after `options.duration` milliseconds elapses.
     *
     *    Set property {@link HighlightRect#timer timer} to later change this option.
     *
     * @param {String} [options.title = "Highlight Rectangle"] - The title to assign to the window.
     *
     *    Set property {@link Gui.Prototype.Title Title} to later
     *    change this option.
     */
    __New(options?) {
        if IsSet(options) {
            super.__New('+AlwaysOnTop -Caption +ToolWindow -DPIScale +E0x08000000', HasProp(options, 'title') ? options.title : 'Highlight Rectangle')
            if HasProp(options, 'border') {
                this.__border := options.border
            }
            if HasProp(options, 'color') {
                this.BackColor := options.color
            } else {
                this.BackColor := 0x00E6FA
            }
            if HasProp(options, 'callback') {
                this.__callback := options.callback
            }
            if HasProp(options, 'duration') {
                this.__duration := options.duration
            }
            if HasProp(options, 'offsetL') {
                this.__offsetL := options.offsetL
            }
            if HasProp(options, 'offsetT') {
                this.__offsetT := options.offsetT
            }
            if HasProp(options, 'offsetR') {
                this.__offsetR := options.offsetR
            }
            if HasProp(options, 'offsetB') {
                this.__offsetB := options.offsetB
            }
            if HasProp(options, 'rect') {
                this.__rect := options.rect
            } else {
                this.__rect := HighlightRect_Rect(0, 0, 100, 100)
            }
            if HasProp(options, 'timer') {
                this.__timer := options.timer
            }
            this.Show('Hide')
            if HasProp(options, 'deferShow') && !options.deferShow {
                this.SetRect(this.__rect)
                this()
            }
        } else {
            super.__New('+AlwaysOnTop -Caption +ToolWindow -DPIScale +E0x08000000', 'Highlight Rectangle')
            this.BackColor := 0x00E6FA
            this.__rect := HighlightRect_Rect(0, 0, 100, 100)
            this.Show('Hide')
        }
    }
    /**
     * @desc - If the highlight rectangle is currently hidden, it is shown.
     *
     * If {@link HighlightRect#timer} is true and {@link HighlightRect#callback} is set,
     * starts a timer to call {@link HighlightRect#callback} every {@link HighlightRect#duration}
     * milliseconds. {@link HighlightRect#callback} is expected to update the position / dimensions
     * of the highlight rectangle, if needed. If the callback returns a nonzero value, the timer ends
     * and the highlight rectangle is hidden. If the callback returns zero or an empty string, the
     * timer continues.
     *
     * Your code can also call {@link HighlightRect.Prototype.StopTimer} to stop the timer.
     *
     * If {@link HighlightRect#timer} is false, a timer is set to hide the highlight rectangle after
     * {@link HighlightRect#duration} milliseconds elapses.
     *
     * @param {String} [showOptions = "NoActivate"] - The options to pass to
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Show Gui.Prototype.Show}.
     */
    Call(showOptions := 'NoActivate') {
        this.Show(showOptions)
        if this.__timer && this.__callback {
            if !this.__callback_helper {
                this.__callback_helper := HighlightRect_Callback(this.hwnd)
            }
            SetTimer(this.__callback_helper, this.__duration, this.__priority)
        } else {
            SetTimer(ObjBindMethod(this, 'Hide'), -Abs(this.__duration), this.__priority)
        }
    }
    /**
     * @desc - Calls
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Destroy Gui.Prototype.Destroy}.
     */
    Dispose() {
        this.Destroy()
    }
    /**
     * @desc - Adjusts the rectangle's dimensions.
     *
     * @param {HighlightRect_Rect|HighlightRect_WinRect} [rect] - If set, the rect object containing
     * the new dimensions.
     *
     * If unset, the current {@link HighlightRect#rect} object's values are applied to update the
     * highlight rectangle's dimensions.
     *
     * Note that, if any of the "offset" options are in use, the offsets are applied
     * to the new dimensions. The "offset" options are
     * - {@link HighlightRect#offsetL}
     * - {@link HighlightRect#offsetT}
     * - {@link HighlightRect#offsetR}
     * - {@link HighlightRect#offsetB}
     *
     * @param {Integer} [border] - If set, updates the border size ({@link HighlightRect#border}).
     * If unset, the border size is unchanged.
     *
     * @param {Boolean} [show = true] - If true,
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Show Gui.Prototype.Show} is called.
     * If false, `Gui.Prototype.Show` is not called.
     *
     * @param {String} [showOptions = "NoActivate"] - Options to pass to `Gui.Prototype.Show`. This
     * is ignored if `show` is false.
     */
    SetRect(rect?, border?, show := true, showOptions := 'NoActivate') {
        if IsSet(border) {
            this.__border := border
        } else {
            border := this.__border
        }
        if IsSet(rect) {
            this.__rect := rect
        } else {
            rect := this.__rect
        }
        WinSetRegion(Format('0-0 {1}-0 {1}-{2} 0-{2} 0-0    {3}-{4} {5}-{4} {5}-{6} {3}-{6} {3}-{4}'
                , OuterR := rect.W + border * 2 + this.__offsetL + this.__offsetR           ; Outer right - 1
                , OuterB := rect.H + border * 2 + this.__offsetT + this.__offsetB           ; Outer bottom - 2
                , border                                                                    ; Inner left - 3
                , border                                                                    ; Inner top - 4
                , OuterR - border                                                           ; Inner right - 5
                , OuterB - border                                                           ; Inner bottom - 6
            ), this.Hwnd
        )
        this.Move(rect.L - this.__offsetL - border, rect.T - this.__offsetT - border, OuterR, OuterB)
        if show {
            this.Show(showOptions)
        }
    }
    /**
     * @desc - Adjusts the rectangle's dimensions.
     *
     * Note that, if any of the "offset" options are in use, the offsets are applied
     * to the new dimensions. The "offset" options are
     * - {@link HighlightRect#offsetL}
     * - {@link HighlightRect#offsetT}
     * - {@link HighlightRect#offsetR}
     * - {@link HighlightRect#offsetB}
     *
     * @param {Integer} [x] - If set, the new x coordinate. If unset, the x coordinate is not changed.
     *
     * @param {Integer} [y] - If set, the new y coordinate. If unset, the y coordinate is not changed.
     *
     * @param {Integer} [w] - If set, the new width. If unset, the width is not changed.
     *
     * @param {Integer} [h] - If set, the new height. If unset, the height is not changed.
     *
     * @param {Integer} [border] - If set, updates the border size ({@link HighlightRect#border}).
     * If unset, the border size is unchanged.
     *
     * @param {Boolean} [show = true] - If true,
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Show Gui.Prototype.Show} is called.
     * If false, `Gui.Prototype.Show` is not called.
     *
     * @param {String} [showOptions = "NoActivate"] - Options to pass to `Gui.Prototype.Show`. This
     * is ignored if `show` is false.
     */
    SetRegion(x?, y?, w?, h?, border?, show := true, showOptions := 'NoActivate') {
        rect := this.__rect
        if IsSet(x) {
            rect.X := x
        }
        if IsSet(y) {
            rect.Y := y
        }
        if IsSet(w) {
            rect.W := w
        }
        if IsSet(h) {
            rect.H := h
        }
        if IsSet(border) {
            this.__border := border
        } else {
            border := this.__border
        }
        WinSetRegion(Format('0-0 {1}-0 {1}-{2} 0-{2} 0-0    {3}-{4} {5}-{4} {5}-{6} {3}-{6} {3}-{4}'
                , OuterR := rect.W + border * 2 + this.__offsetL + this.__offsetR           ; Outer right - 1
                , OuterB := rect.H + border * 2 + this.__offsetT + this.__offsetB           ; Outer bottom - 2
                , border                                                                    ; Inner left - 3
                , border                                                                    ; Inner top - 4
                , OuterR - border                                                           ; Inner right - 5
                , OuterB - border                                                           ; Inner bottom - 6
            ), this.Hwnd
        )
        this.Move(rect.L - this.__offsetL - border, rect.T - this.__offsetT - border, OuterR, OuterB)
        if show {
            this.Show(showOptions)
        }
    }
    __Delete() {
        this.Destroy()
    }

    border {
        Get => this.__border
        Set => this.__border := value
    }
    color {
        Get => this.BackColor
        Set => this.BackColor := value
    }
    callback {
        Get => this.__callback
        Set => this.__callback := value
    }
    duration {
        Get => this.__duration
        Set => this.__duration := value
    }
    offsetB {
        Get => this.__offsetB
        Set => this.__offsetB := value
    }
    offsetL {
        Get => this.__offsetL
        Set => this.__offsetL := value
    }
    offsetR {
        Get => this.__offsetR
        Set => this.__offsetR := value
    }
    offsetT {
        Get => this.__offsetT
        Set => this.__offsetT := value
    }
    priority {
        Get => this.__priority
        Set => this.__priority := value
    }
    rect {
        Get => this.__rect
        Set => this.SetRect(value, , false)
    }
    timer {
        Get => this.__timer
        Set => this.__timer := value
    }

    Visible => DllCall('IsWindowVisible', 'ptr', this.Hwnd, 'int')
}

/**
 * @param {Integer} [r = 0] - The red value as integer between 0-255, inclusive.
 * @param {Integer} [g = 0] - The green value as integer between 0-255, inclusive.
 * @param {Integer} [b = 0] - The blue value as integer between 0-255, inclusive.
 * @returns {Integer} - The COLORREF value.
 */
HighlightRect_RGB(r := 0, g := 0, b := 0) {
    return (r & 0xFF) | ((g & 0xFF) << 8) | ((b & 0xFF) << 16)
}
/**
 * @desc - Takes a string in the format "R<n> G<n> B<n>" and returns a COLORREF as integer, where
 * <n> is an integer between 0-255, inclusive. For example, "R0 G245 B250".
 * @param {String} str - A string in the format "R<n> G<n> B<n>". For example, "R155 G4 B212".
 * @returns {Integer} - The COLORREF value.
 */
HighlightRect_RGBString(str) {
    if RegExMatch(str, '[rR]\s*(\d+)\s*[gG]\s*(\d+)\s*[bB]\s*(\d+)', &match) {
        return (match[1] & 0xFF) | ((match[2] & 0xFF) << 8) | ((match[3] & 0xFF) << 16)
    } else {
        throw ValueError('The string must be in the format "R<n> G<n> B<n>" where <n> is an integer between 0-255, inclusive. For example, "R0 G200 B250".', , str)
    }
}

class HighlightRect_Point {
    static __New() {
        this.DeleteProp('__New')
        HighlightRect_SetConstants()
        this.Prototype.DefineProp('Clone', { Call: HighlightRect_Clone })
    }
    /**
     * @description - Creates a {@link HighlightRect_Point} object with the client position of the caret.
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getcaretpos}.
     * @returns {HighlightRect_Point}
     */
    static FromCaret() {
        pt := this()
        DllCall(g_user32_GetCaretPos, 'ptr', pt, 'int')
        return pt
    }
    /**
     * @description - Creates a {@link HighlightRect_Point} object with the cursor position in screen coordinates.
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getcursorpos}.
     * @returns {HighlightRect_Point}
     */
    static FromCursor() {
        pt := this()
        DllCall(g_user32_GetCursorPos, 'ptr', pt, 'int')
        return pt
    }
    /**
     * @description - Creates a new {@link HighlightRect_Point} object.
     * @param {Integer} [X] - The X-coordinate.
     * @param {Integer} [Y] - The Y-coordinate.
     */
    __New(X?, Y?) {
        this.Buffer := Buffer(8, 0)
        if IsSet(X) {
            this.X := X
        }
        if IsSet(Y) {
            this.Y := Y
        }
    }
    /**
     * @description - Use this to convert client coordinates (which should already be contained by
     * this {@link HighlightRect_Point} object), to screen coordinates.
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-clienttoscreen}.
     * @param {Integer} Hwnd - The handle to the window whose client area will be used for the conversion.
     * @param {Boolean} [InPlace = false] - If true, the current object is modified. If false, a new
     * {@link HighlightRect_Point} is created.
     * @returns {HighlightRect_Point}
     */
    ClientToScreen(Hwnd, InPlace := false) {
        if InPlace {
            pt := this
        } else {
            pt := HighlightRect_Point(this.X, this.Y)
        }
        if !DllCall(g_user32_ClientToScreen, 'ptr', Hwnd, 'ptr', pt, 'int') {
            throw OSError()
        }
        return pt
    }
    /**
     * @description - Creates a copy of the {@link HighlightRect_Point} object. The buffer on property
     * {@link HighlightRect_Point#Buffer} is different, so changes to one will not affect the other.
     */
    Clone() {
        ; this is overridden
    }
    /**
     * @description - Calls {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getcursorpos}.
     * @returns {Boolean} - True if successful.
     */
    GetCursorPos() => DllCall(g_user32_GetCursorPos, 'ptr', this, 'int')
    /**
     * @description - Calls {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-logicaltophysicalpointforpermonitordpi}.
     * @param {Integer} Hwnd - A handle to the window whose transform is used for the conversion.
     * @returns {Boolean} - True if successful.
     */
    LogicalToPhysicalForPerMonitorDPI(Hwnd) {
        return DllCall(g_user32_LogicalToPhysicalPointForPerMonitorDPI, 'ptr', Hwnd, 'ptr', this, 'int')
    }
    /**
     * @description - Calls {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-logicaltophysicalpoint}.
     * @param {Integer} Hwnd - A handle to the window whose transform is used for the conversion.
     * Top level windows are fully supported. In the case of child windows, only the area of overlap
     * between the parent and the child window is converted.
     */
    LogicalToPhysicalPoint(Hwnd) {
        DllCall(g_user32_LogicalToPhysicalPoint, 'ptr', Hwnd, 'ptr', this)
    }
    /**
     * @description - Calls {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-physicaltologicalpointforpermonitordpi}.
     * @param {Integer} Hwnd - A handle to the window whose transform is used for the conversion.
     * @returns {Boolean} - True if successful.
     */
    PhysicalToLogicalForPerMonitorDPI(Hwnd) {
        return DllCall(g_user32_PhysicalToLogicalPointForPerMonitorDPI, 'ptr', Hwnd, 'ptr', this, 'int')
    }
    /**
     * @description - Calls {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-physicaltologicalpoint}.
     * @param {Integer} Hwnd - A handle to the window whose transform is used for the conversion.
     * Top level windows are fully supported. In the case of child windows, only the area of overlap
     * between the parent and the child window is converted.
     */
    PhysicalToLogicalPoint(Hwnd) {
        DllCall(g_user32_PhysicalToLogicalPoint, 'ptr', Hwnd, 'ptr', this)
    }
    /**
     * @description - Use this to convert screen coordinates (which should already be contained by
     * this {@link HighlightRect_Point} object), to client coordinates.
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-screentoclient}
     * @param {Integer} Hwnd - The handle to the window whose client area will be used for the conversion.
     * @param {Boolean} [InPlace = false] - If true, the current object is modified. If false, a new
     * {@link HighlightRect_Point} is created.
     * @returns {HighlightRect_Point}
     */
    ScreenToClient(Hwnd, InPlace := false) {
        if InPlace {
            pt := this
        } else {
            pt := HighlightRect_Point(this.X, this.Y)
        }
        if !DllCall(g_user32_ScreenToClient, 'ptr', Hwnd, 'ptr', pt, 'int') {
            throw OSError()
        }
        return pt
    }
    /**
     * @description - Calls {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setcaretpos}.
     * @returns {Boolean} - Nonzero if successful.
     */
    SetCaretPos() {
        return DllCall(g_user32_SetCaretPos, 'int', this.X, 'int', this.Y, 'int')
    }

    /**
     * @returns {Integer} - The dpi of the monitor containing the point.
     */
    Dpi {
        Get {
            if DllCall(g_shcore_GetDpiForMonitor, 'ptr', DllCall(g_user32_MonitorFromPoint, 'int', this.Value, 'uint', 0, 'ptr'), 'uint', 0, 'uint*', &DpiX := 0, 'uint*', &DpiY := 0, 'int') {
                throw OSError('``MonitorFomPoint`` received an invalid parameter.')
            } else {
                return DpiX
            }
        }
    }
    /**
     * @returns {Integer} - The handle to the monitor that contains the point.
     */
    Monitor  => DllCall(g_user32_MonitorFromPoint, 'int', this.Value, 'uint', 0, 'ptr')
    Ptr => this.Buffer.Ptr
    Size => this.Buffer.Size
    /**
     * @returns {Integer} - Returns a 64-bit value containing the x-coordinate in the low word and
     * the y-coordinate in the high word.
     */
    Value => (this.X & 0xFFFFFFFF) | (this.Y << 32)
    /**
     * @descriptions - Gets or sets the X coordinate value.
     * @returns {Integer}
     */
    X {
        Get => NumGet(this, 0, 'int')
        Set => NumPut('int', Value, this)
    }
    /**
     * @descriptions - Gets or sets the Y coordinate value.
     * @returns {Integer}
     */
    Y {
        Get => NumGet(this, 4, 'int')
        Set => NumPut('int', Value, this, 4)
    }
}
class HighlightRect_Rect {
    static __New() {
        this.DeleteProp('__New')
        HighlightRect_SetConstants()
        this.Prototype.DefineProp('Clone', { Call: HighlightRect_Clone })
    }
    static FromDimensions(X, Y, W, H) => this(X, Y, X + W, Y + H)
    static FromCursor() {
        rc := this()
        DllCall(g_user32_GetCursorPos, 'ptr', rc, 'int')
        rc.R := rc.L
        rc.B := rc.T
        return rc
    }
    /**
     * @description - Creates a new {@link HighlightRect_Rect} object.
     * @param {Integer} [L] - The left coordinate.
     * @param {Integer} [T] - The top coordinate.
     * @param {Integer} [R] - The right coordinate.
     * @param {Integer} [B] - The bottom coordinate.
     */
    __New(L?, T?, R?, B?) {
        this.Buffer := Buffer(16, 0)
        if IsSet(L) {
            this.L := L
        }
        if IsSet(T) {
            this.T := T
        }
        if IsSet(R) {
            this.R := R
        }
        if IsSet(B) {
            this.B := B
        }
    }
    Clone() {
        ; this is overridden
    }
    Equal(rc) => DllCall(g_user32_EqualRect, 'ptr', this, 'ptr', rc, 'int')
    GetHeightSegment(Divisor, DecimalPlaces := 0) => Round(this.H / Divisor, DecimalPlaces)
    GetWidthSegment(Divisor, DecimalPlaces := 0) => Round(this.W / Divisor, DecimalPlaces)
    Inflate(dx, dy) => DllCall(g_user32_InflateRect, 'ptr', this, 'int', dx, 'int', dy, 'int')
    Intersect(rc) {
        out := HighlightRect_Rect()
        if DllCall(g_user32_IntersectRect, 'ptr', out, 'ptr', this, 'ptr', rc, 'int') {
            return out
        }
    }
    IsEmpty() => DllCall(g_user32_IsRectEmpty, 'ptr', this, 'int')
    MoveAdjacent(Target?, ContainerRect?, Dimension := 'X', Prefer := '', Padding := 0, InsufficientSpaceAction := 0) {
        Result := 0
        if IsSet(Target) {
            tarL := Target.L
            tarT := Target.T
            tarR := Target.R
            tarB := Target.B
        } else {
            mode := CoordMode('Mouse', 'Screen')
            MouseGetPos(&tarL, &tarT)
            tarR := tarL
            tarB := tarT
            CoordMode('Mouse', mode)
        }
        tarW := tarR - tarL
        tarH := tarB - tarT
        if IsSet(ContainerRect) {
            monL := ContainerRect.L
            monT := ContainerRect.T
            monR := ContainerRect.R
            monB := ContainerRect.B
            monW := monR - monL
            monH := monB - monT
        } else {
            buf := Buffer(16)
            NumPut('int', tarL, 'int', tarT, 'int', tarR, 'int', tarB, buf)
            Hmon := DllCall('MonitorFromRect', 'ptr', buf, 'uint', 0x00000002, 'ptr')
            mon := Buffer(40)
            NumPut('int', 40, mon)
            if !DllCall('GetMonitorInfo', 'ptr', Hmon, 'ptr', mon, 'int') {
                throw OSError()
            }
            monL := NumGet(mon, 20, 'int')
            monT := NumGet(mon, 24, 'int')
            monR := NumGet(mon, 28, 'int')
            monB := NumGet(mon, 32, 'int')
            monW := monR - monL
            monH := monB - monT
        }
        subL := this.L
        subT := this.T
        subR := this.R
        subB := this.B
        subW := subR - subL
        subH := subB - subT
        if Dimension = 'X' {
            if Prefer = 'L' {
                if tarL - subW - Padding >= monL {
                    X := tarL - subW - Padding
                } else if tarL - subW >= monL {
                    X := monL
                }
            } else if Prefer = 'R' {
                if tarR + subW + Padding <= monR {
                    X := tarR + Padding
                } else if tarR + subW <= monR {
                    X := monR - subW
                }
            } else if Prefer {
                throw _ValueError('Prefer', Prefer)
            }
            if !IsSet(X) {
                flag_nomove := false
                X := _Proc(subW, tarL, tarR, monL, monR)
                if flag_nomove {
                    return Result
                }
            }
            Y := tarT + tarH / 2 - subH / 2
            if Y + subH > monB {
                Y := monB - subH
            } else if Y < monT {
                Y := monT
            }
        } else if Dimension = 'Y' {
            if Prefer = 'T' {
                if tarT - subH - Padding >= monT {
                    Y := tarT - subH - Padding
                } else if tarT - subH >= monT {
                    Y := monT
                }
            } else if Prefer = 'B' {
                if tarB + subH + Padding <= monB {
                    Y := tarB + Padding
                } else if tarB + subH <= monB {
                    Y := monB - subH
                }
            } else if Prefer {
                throw _ValueError('Prefer', Prefer)
            }
            if !IsSet(Y) {
                flag_nomove := false
                Y := _Proc(subH, tarT, tarB, monT, monB)
                if flag_nomove {
                    return Result
                }
            }
            X := tarL + tarW / 2 - subW / 2
            if X + subW > monR {
                X := monR - subW
            } else if X < monL {
                X := monL
            }
        } else {
            throw _ValueError('Dimension', Dimension)
        }
        this.L := X
        this.T := Y
        this.R := X + subW
        this.B := Y + subH

        return Result

        _Proc(SubLen, TarMainSide, TarAltSide, MonMainSide, MonAltSide) {
            if TarMainSide - MonMainSide > MonAltSide - TarAltSide {
                if TarMainSide - SubLen - Padding >= MonMainSide {
                    return TarMainSide - SubLen - Padding
                } else if TarMainSide - SubLen >= MonMainSide {
                    return MonMainSide + TarMainSide - SubLen
                } else {
                    Result := 1
                    switch InsufficientSpaceAction, 0 {
                        case 0: flag_nomove := true
                        case 1: return TarMainSide - SubLen
                        case 2: return MonMainSide
                        default: throw _ValueError('InsufficientSpaceAction', InsufficientSpaceAction)
                    }
                }
            } else if TarAltSide + SubLen + Padding <= MonAltSide {
                return TarAltSide + Padding
            } else if TarAltSide + SubLen <= MonAltSide {
                return MonAltSide - TarAltSide + SubLen
            } else {
                Result := 1
                switch InsufficientSpaceAction, 0 {
                    case 0: flag_nomove := true
                    case 1: return TarAltSide
                    case 2: return MonAltSide - SubLen
                    default: throw _ValueError('InsufficientSpaceAction', InsufficientSpaceAction)
                }
            }
        }
        _ValueError(name, Value) {
            if IsObject(Value) {
                return TypeError('Invalid type passed to ``' name '``.')
            } else {
                return ValueError('Unexpected value passed to ``' name '``.', , Value)
            }
        }
    }
    Offset(dx, dy) => DllCall(g_user32_OffsetRect, 'ptr', this, 'int', dx, 'int', dy, 'int')
    PtIn(pt) => DllCall(g_user32_PtInRect, 'ptr', this, 'ptr', pt, 'int')
    Set(X?, Y?, W?, H?) {
        if IsSet(X) {
            this.L := X
        }
        if IsSet(Y) {
            this.T := Y
        }
        if IsSet(W) {
            this.R := this.L + W
        }
        if IsSet(H) {
            this.B := this.T + H
        }
    }
    Subtract(rc) {
        out := HighlightRect_Rect()
        DllCall(g_user32_SubtractRect, 'ptr', out, 'ptr', this, 'ptr', rc, 'int')
        return out
    }
    ToClient(Hwnd, InPlace := false) {
        if InPlace {
            rc := this
        } else {
            rc := this.Clone()
        }
        if !DllCall(g_user32_ScreenToClient, 'ptr', Hwnd, 'ptr', rc, 'int') {
            throw OSError()
        }
        if !DllCall(g_user32_ScreenToClient, 'ptr', Hwnd, 'ptr', rc.Ptr + 8, 'int') {
            throw OSError()
        }
        return rc
    }
    ToScreen(Hwnd, InPlace := false) {
        if InPlace {
            rc := this
        } else {
            rc := this.Clone()
        }
        if !DllCall(g_user32_ClientToScreen, 'ptr', Hwnd, 'ptr', rc, 'int') {
            throw OSError()
        }
        if !DllCall(g_user32_ClientToScreen, 'ptr', Hwnd, 'ptr', rc.ptr + 8, 'int') {
            throw OSError()
        }
        return rc
    }
    Union(rc) {
        out := HighlightRect_Rect()
        if DllCall(g_user32_UnionRect, 'ptr', out, 'ptr', this, 'ptr', rc, 'int') {
            return out
        }
    }

    B {
        Get => NumGet(this, 12, 'int')
        Set => NumPut('int', Value, this, 12)
    }
    BL => HighlightRect_Point(NumGet(this, 0, 'int'), NumGet(this, 12, 'int'))
    BR => HighlightRect_Point(NumGet(this, 8, 'int'), NumGet(this, 12, 'int'))
    Dpi {
        Get {
            if DllCall(g_shcore_GetDpiForMonitor, 'ptr', DllCall(g_shcore_MonitorFromRect, 'ptr', this, 'uint', 0, 'ptr'), 'uint', 0, 'uint*', &DpiX := 0, 'uint*', &DpiY := 0, 'int') {
                throw OSError('``MonitorFomPoint`` received an invalid parameter.')
            } else {
                return DpiX
            }
        }
    }
    H {
        Get => NumGet(this, 12, 'int') - NumGet(this, 4, 'int')
        Set => NumPut('int', NumGet(this, 4, 'int') + Value, this, 12)
    }
    L {
        Get => NumGet(this, 0, 'int')
        Set => NumPut('int', Value, this)
    }
    Monitor => DllCall(g_user32_MonitorFromRect, 'ptr', this, 'uint', 0, 'uptr')
    Ptr => this.Buffer.Ptr
    R {
        Get => NumGet(this, 8, 'int')
        Set => NumPut('int', Value, this, 8)
    }
    Size => this.Buffer.Size
    T {
        Get => NumGet(this, 4, 'int')
        Set => NumPut('int', Value, this, 4)
    }
    TL {
        Get => HighlightRect_Point(NumGet(this, 0, 'int'), NumGet(this, 4, 'int'))
    }
    TR {
        Get => HighlightRect_Point(NumGet(this, 8, 'int'), NumGet(this, 4, 'int'))
    }
    W {
        Get => NumGet(this, 8, 'int') - NumGet(this, 0, 'int')
        Set => NumPut('int', NumGet(this, 0, 'int') + Value, this, 8)
    }
}

class HighlightRect_WinRect extends HighlightRect_Rect {
    /**
     * @param {Integer} [Hwnd = 0] - The window handle.
     * @param {Integer} [Flag = 0] - A flag that determines what function is called when
     * measuring the window's dimensions.
     * - 0 : `GetWindowRect`
     * - 1 : `GetClientRect`
     * - 2 : `DwmGetWindowAttribute` passing DWMWA_EXTENDED_FRAME_BOUNDS to dwAttribute.
     *   See {@link https://learn.microsoft.com/en-us/windows/win32/api/dwmapi/nf-dwmapi-dwmgetwindowattribute}.
     * - 3 : `GetWindowRect` is called, then `ScreenToClient` is called for both coordinates using
     *   the parent window's client area for the conversion. If `Hwnd` is a control's window handle,
     *   this would be the same as calling
     *   {@link https://www.autohotkey.com/docs/v2/lib/GuiControl.htm#GetPos Gui.Control.Prototype.GetPos}.
     *
     * Some controls / windows will cause `DwmGetWindowAttribute` to throw an error.
     *
     * For more information see {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getwindowrect}.
     */
    __New(Hwnd := 0, Flag := 0) {
        this.Buffer := Buffer(16)
        this.Flag := Flag
        if this.Hwnd := Hwnd {
            this()
        }
    }
    Call(*) {
        switch this.Flag, 0 {
            case 0:
                if !DllCall(g_user32_GetWindowRect, 'ptr', this.Hwnd, 'ptr', this.Ptr, 'int') {
                    throw OSError()
                }
            case 1:
                if !DllCall(g_user32_GetClientRect, 'ptr', this.Hwnd, 'ptr', this.Ptr, 'int') {
                    throw OSError()
                }
            case 2:
                if HRESULT := DllCall(g_dwmapi_DwmGetWindowAttribute, 'ptr', this.Hwnd, 'uint', 9, 'ptr', this.Ptr, 'uint', 16, 'uint') {
                    throw OSError('``DwmGetWindowAttribute`` failed.', , 'HRESULT: ' Format('{:X}', HRESULT))
                }
            case 3:
                hwndParent := DllCall(g_user32_GetParent, 'ptr', this.Hwnd, 'ptr') || this.Hwnd
                if !DllCall(g_user32_GetWindowRect, 'ptr', this.Hwnd, 'ptr', this.Ptr, 'int') {
                    throw OSError()
                }
                if !DllCall(g_user32_ScreenToClient, 'ptr', hwndParent, 'ptr', this.Ptr, 'int') {
                    throw OSError()
                }
                if !DllCall(g_user32_ScreenToClient, 'ptr', hwndParent, 'ptr', this.Ptr + 8, 'int') {
                    throw OSError()
                }
        }
    }
    Apply(InsertAfter := 0, Flags := 0) {
        return DllCall(g_user32_SetWindowPos, 'ptr', this.Hwnd, 'ptr', InsertAfter, 'int', this.L, 'int', this.T, 'int', this.W, 'int', this.H, 'uint', Flags, 'int')
    }
    GetPos(&X?, &Y?, &W?, &H?) {
        this()
        X := this.L
        Y := this.T
        W := this.W
        H := this.H
    }
    MapPoints(wrc, points) {
        return DllCall(g_user32_MapWindowPoints, 'ptr', this.Hwnd, 'ptr', IsObject(wrc) ? wrc.Hwnd : wrc, 'ptr', points, 'uint', points.Size / 8, 'int')
    }
    Move(X?, Y?, W?, H?, InsertAfter := 0, Flags := 0) {
        this()
        if IsSet(X) {
            this.L := X
        }
        if IsSet(Y) {
            this.T := Y
        }
        if IsSet(W) {
            this.W := W
        }
        if IsSet(H) {
            this.H := H
        }
        if !DllCall(g_user32_SetWindowPos, 'ptr', this.Hwnd, 'ptr', InsertAfter, 'int', this.L, 'int', this.T, 'int', this.W, 'int', this.H, 'uint', Flags, 'int') {
            throw OSError()
        }
    }
}

HighlightRect_Clone(Self) {
    obj := Object.Prototype.Clone.Call(Self)
    obj.Buffer := Buffer(Self.Size)
    ObjSetBase(obj, %Self.__Class%.Prototype)
    DllCall(
        g_msvcrt_memcpy
      , 'ptr', obj.Ptr
      , 'ptr', Self.Ptr
      , 'int', Self.Size
      , 'cdecl'
    )
    return obj
}

HighlightRect_SetConstants(force := false) {
    global
    if IsSet(HighlightRect_constants_set) && !force {
        return
    }

    local hmod := DllCall('GetModuleHandle', 'str', 'User32', 'ptr')
    g_user32_AdjustWindowRectEx := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'AdjustWindowRectEx', 'ptr')
    g_user32_BringWindowToTop := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'BringWindowToTop', 'ptr')
    g_user32_ChildWindowFromPoint := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'ChildWindowFromPoint', 'ptr')
    g_user32_ChildWindowFromPointEx := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'ChildWindowFromPointEx', 'ptr')
    g_user32_ClientToScreen := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'ClientToScreen', 'ptr')
    g_user32_EnumChildWindows := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'EnumChildWindows', 'ptr')
    g_user32_EqualRect := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'EqualRect', 'ptr')
    g_user32_GetCaretPos := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'GetCaretPos', 'ptr')
    g_user32_GetClientRect := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'GetClientRect', 'ptr')
    g_user32_GetCursorPos := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'GetCursorPos', 'ptr')
    g_user32_GetDesktopWindow := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'GetDesktopWindow', 'ptr')
    g_user32_GetDpiForWindow := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'GetDpiForWindow', 'ptr')
    g_user32_GetForegroundWindow := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'GetForegroundWindow', 'ptr')
    g_user32_GetMenu := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'GetMenu', 'ptr')
    g_user32_GetParent := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'GetParent', 'ptr')
    g_user32_GetShellWindow := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'GetShellWindow', 'ptr')
    g_user32_GetTopWindow := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'GetTopWindow', 'ptr')
    g_user32_GetWindow := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'GetWindow', 'ptr')
    g_user32_GetWindowInfo := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'GetWindowInfo', 'ptr')
    g_user32_GetWindowRect := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'GetWindowRect', 'ptr')
    g_user32_InflateRect := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'InflateRect', 'ptr')
    g_user32_IntersectRect := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'IntersectRect', 'ptr')
    g_user32_IsChild := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'IsChild', 'ptr')
    g_user32_IsRectEmpty := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'IsRectEmpty', 'ptr')
    g_user32_IsWindowVisible := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'IsWindowVisible', 'ptr')
    g_user32_LogicalToPhysicalPoint := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'LogicalToPhysicalPoint', 'ptr')
    g_user32_LogicalToPhysicalPointForPerMonitorDPI := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'LogicalToPhysicalPointForPerMonitorDPI', 'ptr')
    g_user32_MapWindowPoints := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'MapWindowPoints', 'ptr')
    g_user32_MonitorFromPoint := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'MonitorFromPoint', 'ptr')
    g_user32_MonitorFromRect := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'MonitorFromRect', 'ptr')
    g_user32_MonitorFromWindow := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'MonitorFromWindow', 'ptr')
    g_user32_OffsetRect := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'OffsetRect', 'ptr')
    g_user32_PhysicalToLogicalPoint := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'PhysicalToLogicalPoint', 'ptr')
    g_user32_PhysicalToLogicalPointForPerMonitorDPI := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'PhysicalToLogicalPointForPerMonitorDPI', 'ptr')
    g_user32_PtInRect := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'PtInRect', 'ptr')
    g_user32_RealChildWindowFromPoint := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'RealChildWindowFromPoint', 'ptr')
    g_user32_ScreenToClient := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'ScreenToClient', 'ptr')
    g_user32_SetActiveWindow := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'SetActiveWindow', 'ptr')
    g_user32_SetCaretPos := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'SetCaretPos', 'ptr')
    g_user32_SetForegroundWindow := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'SetForegroundWindow', 'ptr')
    g_user32_SetParent := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'SetParent', 'ptr')
    g_user32_SetThreadDpiAwarenessContext := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'SetThreadDpiAwarenessContext', 'ptr')
    g_user32_SetWindowPos := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'SetWindowPos', 'ptr')
    g_user32_ShowWindow := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'ShowWindow', 'ptr')
    g_user32_SubtractRect := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'SubtractRect', 'ptr')
    g_user32_UnionRect := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'UnionRect', 'ptr')
    g_user32_WindowFromPoint := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'WindowFromPoint', 'ptr')
    hmod := DllCall('LoadLibrary', 'str', 'Shcore', 'ptr')
    g_shcore_GetDpiForMonitor := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'GetDpiForMonitor', 'ptr')
    g_shcore_MonitorFromRect := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'MonitorFromRect', 'ptr')
    hmod := DllCall('LoadLibrary', 'str', 'Dwmapi', 'ptr')
    g_dwmapi_DwmGetWindowAttribute := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'DwmGetWindowAttribute', 'ptr')
    hmod := DllCall('LoadLibrary', 'str', 'msvcrt', 'ptr')
    g_msvcrt_memcpy := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'memcpy', 'ptr')

    HighlightRect_constants_set := true
}

class HighlightRect_Callback {
    __New(hwnd) {
        this.hwnd := hwnd
    }
    Call() {
        if hrect := GuiFromHwnd(this.hwnd) {
            if hrect.__callback.Call(hrect) {
                SetTimer(this, 0)
            }
        } else {
            SetTimer(this, 0)
        }
    }
}
