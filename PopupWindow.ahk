
class PopupWindow extends Gui {
    static __New() {
        this.DeleteProp('__New')
        proto := this.Prototype
        proto.__Duration :=
        proto.InsufficientSpaceAction :=
        proto.Padding :=
        proto.OffsetX :=
        proto.OffsetY :=
        proto.Priority := 0
        proto.__MarginL :=
        proto.__MarginT :=
        proto.__MarginR :=
        proto.__MarginB := 2
        proto.HwndCtrl :=
        proto.ContainerRect :=
        proto.Dimension :=
        proto.Prefer :=
        proto.WrapTextOptions :=
        proto.__Width := ''
    }
    /**
     * @description - {@link PopupWindow} is an alternative to the native
     * {@link https://www.autohotkey.com/docs/v2/lib/ToolTip.htm ToolTip}. ToolTip uses the Win32
     * {@link https://learn.microsoft.com/en-us/windows/win32/controls/tooltip-control-reference tooltip API};
     * {@link PopupWindow} is just a gui with a text control.
     *
     * {@link PopupWindow} is designed for the following conveniences:
     * - {@link PopupWindow} has built-in text wrapping functionality. If you set `Options.Width` (or
     *   set {@link PopupWindow#Width}), that becomes the maximum width of the window. The text will
     *   be processed through {@link PopupWindow_WrapText}, which, by default, breaks the lines at a
     *   whitespace character or a hyphen. You can modify this behavior by setting
     *   `Options.WrapTextOptions` or {@link PopupWindow#WrapTextOptions}.
     * - {@link PopupWindow} automatically adjusts the text control's dimensions and the window's
     *   dimensions to fit the text content. Use the "Margin" options to control the margins.
     * - Method {@link PopupWindow.Prototype.Show2} automatically calculates the optimal position
     *   to display the window by the mouse pointer. By default, Show2 will ensure that the window
     *   is within the monitor's work area. You can customize the behavior with the following. See
     *   {@link PopupWindow_MoveAdjacent} for details.
     *   - `Options.ContainerRect` / {@link PopupWindow#ContainerRect}
     *   - `Options.Dimension` / {@link PopupWindow#Dimension}
     *   - `Options.Prefer` / {@link PopupWindow#Prefer}
     *   - `Options.Padding` / {@link PopupWindow#Padding}
     *   - `Options.InsufficientSpaceAction` / {@link PopupWindow#InsufficientSpaceAction}
     * - {@link PopupWindow} has a built-in display timer. Set `Options.Duration` or
     *   {@link PopupWindow#Duration}, and the next tim your code calls
     *   {@link PopupWindow.Prototype.Show} or {@link PopupWindow.Prototype.Show2}, the timer will
     *   be invoked and the window will auto-hide after the duration.
     */
    __New(Text?, Options?) {
        if IsSet(Options) {
            super.__New(
                HasProp(Options, 'Opt') ? Options.Opt : '+Owner -SysMenu -Caption',
                HasProp(Options, 'Title') ? Options.Title : unset,
                HasProp(Options, 'EventHandler') ? Options.EventHandler : unset
            )
            if HasProp(Options, 'BackColor') {
                this.BackColor := Options.BackColor
            }
            if HasProp(Options, 'WrapTextOptions') {
                this.WrapTextOptions := Options.WrapTextOptions
            }
            if HasProp(Options, 'Priority') {
                this.Priority := Options.Priority
            }
            if HasProp(Options, 'Duration') {
                this.Duration := Options.Duration
            }
            if HasProp(Options, 'ContainerRect') {
                this.ContainerRect := Options.ContainerRect
            }
            if HasProp(Options, 'Dimension') {
                this.Dimension := Options.Dimension
            }
            if HasProp(Options, 'Prefer') {
                this.Prefer := Options.Prefer
            }
            if HasProp(Options, 'Padding') {
                this.Padding := Options.Padding
            }
            if HasProp(Options, 'InsufficientSpaceAction') {
                this.InsufficientSpaceAction := Options.InsufficientSpaceAction
            }
            if HasProp(Options, 'OffsetX') {
                this.OffsetX := Options.OffsetX
            }
            if HasProp(Options, 'OffsetY') {
                this.OffsetY := Options.OffsetY
            }
            super.SetFont(
                HasProp(Options, 'FontOpt') ? Options.FontOpt : 's11 q5',
                HasProp(Options, 'FaceName') ? Options.FaceName : 'Segoe Ui'
            )
            for prop in [ 'Width', 'MarginL', 'MarginT', 'MarginR', 'MarginB' ] {
                if HasProp(Options, prop) {
                    this.__%prop% := Options.%prop%
                }
            }
            this.HwndCtrl := this.Add('Text', (HasProp(Options, 'TextOpt') ? Options.TextOpt : '')).Hwnd
            super.Show('x' _GetRBound())
            if IsSet(Text) {
                this.SetText(Text)
                if !HasProp(Options, 'DeferShow') || !Options.DeferShow {
                    if HasProp(Options, 'X') || HasProp(Options, 'Y') {
                        this.Show(
                            HasProp(Options, 'X') ? Options.X : unset,
                            HasProp(Options, 'Y') ? Options.Y : unset
                        )
                    } else {
                        this.Show2()
                    }
                }
            } else {
                this.Hide()
                this.Move(0, 0)
            }
        } else {
            super.__New('+Owner -SysMenu -Caption')
            super.SetFont('s11 q5', 'Segoe Ui')
            this.HwndCtrl := this.Add('Text').Hwnd
            x := _GetRBound()
            super.Show('x' x)
            super.Show('x0 y0')
            if IsSet(Text) {
                this.SetText(Text)
                this.Show2()
            } else {
                this.Hide()
                this.Move(0, 0)
            }
        }

        return

        _GetRBound() {
            x := -4294967295
            loop MonitorGetCount() {
                MonitorGet(A_Index, , , &r)
                x := Max(x, r)
            }
            return x + 1
        }
    }
    Call(Text?, X?, Y?) {
        if IsSet(Text) {
            this.SetText(Text)
        }
        if IsSet(X) || IsSet(Y) {
            this.Show(X ?? unset, Y ?? unset)
        } else {
            this.Show2()
        }
    }
    SetFont(FontOpt?, FaceName?) {
        this.Ctrl.SetFont(FontOpt ?? unset, FaceName ?? unset)
        this.UpdateTextRect()
    }
    SetMargin(L?, T?, R?, B?) {
        if IsSet(L) {
            this.__MarginL := L
        }
        if IsSet(T) {
            this.__MarginT := T
        }
        if IsSet(R) {
            this.__MarginR := R
        }
        if IsSet(B) {
            this.__MarginB := B
        }
        this.Ctrl.Move(this.__MarginL, this.__MarginT)
        if DllCall('IsWindowVisible', 'ptr', this.Hwnd, 'int') {
            this.Ctrl.GetPos(, , &w, &h)
            super.Show('w' (this.__MarginL + this.__MarginR + w) ' h' (this.__MarginT + this.__MarginB + h))
        }
    }
    SetText(Text) {
        this.Ctrl.Text := RegExReplace(Text, '\R', '`r`n')
        this.UpdateTextRect()
    }
    Show(X?, Y?) {
        this.Ctrl.GetPos(, , &w, &h)
        super.Show(
            (IsSet(X) ? 'x' X : '')
            (IsSet(Y) ? ' y' Y : '')
            ' w' (this.__MarginL + this.__MarginR + w)
            ' h' (this.__MarginT + this.__MarginB + h)
        )
        if this.__Duration {
            SetTimer(PopupWindow_Hide.Bind(this.Hwnd), this.__Duration, this.Priority)
        }
    }
    Show2() {
        CoordMode('Mouse', 'Screen')
        MouseGetPos(&mx, &my)
        rc := PopupWindow_Rect()
        if HRESULT := DllCall('Dwmapi\DwmGetWindowAttribute', 'ptr', this.Hwnd, 'uint', 9, 'ptr', rc, 'uint', 16, 'uint') {
            throw OSError('``DwmGetWindowAttribute`` failed.', , 'HRESULT: ' Format('{:X}', HRESULT))
        }
        PopupWindow_MoveAdjacent(
            rc,
            { L: mx + this.OffsetX, T: my + this.OffsetY, R: mx + this.OffsetX, B: my + this.OffsetY },
            this.ContainerRect || unset,
            this.Dimension || unset,
            this.Prefer || unset,
            this.Padding,
            this.InsufficientSpaceAction
        )
        this.Ctrl.GetPos(, , &w, &h)
        super.Show(
            'x' rc.L ' y' rc.T
            ' w' (this.__MarginL + this.__MarginR + w)
            ' h' (this.__MarginT + this.__MarginB + h)
        )
        if this.__Duration {
            SetTimer(PopupWindow_Hide.Bind(this.Hwnd), this.__Duration, this.Priority)
        }
    }
    UpdateTextRect() {
        ctrl := this.Ctrl
        if this.__Width {
            options := {
                AdjustObject: true,
                MaxExtent: this.__Width,
                MeasureLines: true,
                EndOfLine: '`r`n'
            }
            if this.WrapTextOptions {
                ObjSetBase(options, this.WrapTextOptions)
            }
            PopupWindow_WrapText(ctrl, &str, options, &w, &h)
        } else {
            PopupWindow_ControlFitText(ctrl, , , false, , &w, &h)
        }
        ctrl.Move(this.__MarginL, this.__MarginT)
        if DllCall('IsWindowVisible', 'ptr', this.Hwnd, 'int') {
            super.Show('w' (this.__MarginL + this.__MarginR + w) ' h' (this.__MarginT + this.__MarginB + h))
        }
    }

    Ctrl => GuiCtrlFromHwnd(this.HwndCtrl)
    Duration {
        Get => this.__Duration
        Set => this.__Duration := -Abs(Value)
    }
    MarginL {
        Get => this.__MarginL
        Set => this.SetMargin(Value)
    }
    MarginT {
        Get => this.__MarginT
        Set => this.SetMargin(, Value)
    }
    MarginR {
        Get => this.__MarginR
        Set => this.SetMargin(, , Value)
    }
    MarginB {
        Get => this.__MarginB
        Set => this.SetMargin(, , , Value)
    }
    Width {
        Get => this.__Width
        Set {
            this.__Width := Value
            this.UpdateTextRect()
        }
    }
    Text {
        Get => this.Ctrl.Text
        Set => this.SetText(Value)
    }
}

PopupWindow_Hide(Hwnd) {
    if WinExist(Hwnd) {
        WinHide(Hwnd)
    }
}

/**
 * @classdesc - Use this as a safe way to access a window's font object. This handles accessing and
 * releasing the device context and font object.
 */
class PopupWindow_SelectFontIntoDc {

    __New(hWnd) {
        this.hWnd := hWnd
        if !(this.hdc := DllCall('GetDC', 'Ptr', hWnd, 'ptr')) {
            throw OSError()
        }
        OnError(this.Callback := ObjBindMethod(this, '__ReleaseOnError'), 1)
        if !(this.hFont := SendMessage(0x0031, 0, 0, , hWnd)) { ; WM_GETFONT
            throw OSError()
        }
        if !(this.oldFont := DllCall('SelectObject', 'ptr', this.hdc, 'ptr', this.hFont, 'ptr')) {
            throw OSError()
        }
    }

    /**
     * @description - Selects the old font back into the device context, then releases the
     * device context.
     */
    Call() {
        if err := this.__Release() {
            throw err
        }
    }

    __ReleaseOnError(thrown, mode) {
        if err := this.__Release() {
            thrown.Message .= '; ' err.Message
        }
        throw thrown
    }

    __Release() {
        if this.oldFont {
            if !DllCall('SelectObject', 'ptr', this.hdc, 'ptr', this.oldFont, 'int') {
                err := OSError()
            }
            this.DeleteProp('oldFont')
        }
        if this.hdc {
            if !DllCall('ReleaseDC', 'ptr', this.hWnd, 'ptr', this.hdc, 'int') {
                if IsSet(err) {
                    err.Message .= '; Another error occurred: ' OSError().Message
                }
            }
            this.DeleteProp('hdc')
        }
        OnError(this.Callback, 0)
        this.DeleteProp('Callback')
        return err ?? ''
    }

    static __New() {
        this.DeleteProp('__New')
        proto := this.Prototype
        proto.DefineProp('hdc', { Value: '' })
        proto.DefineProp('hFont', { Value: '' })
        proto.DefineProp('oldFont', { Value: '' })
    }
}

class PopupWindow_IntegerArray extends Buffer {
    /**
     * @description - A buffer object that can be used with Dll calls or other actions that require a
     * pointer to a buffer to be filled with integers.
     *
     * This class is intended to simplify the handling of any series of integers contained in a buffer;
     * the objects can be enumerated by calling it in a `for` loop, and the items can be accessed by index,
     * which is a slight convenience to using multiples of the byte size with `NumGet`. Negative indices
     * are treated as right-to-left.
     *
     * Note: To adhere to AHK's convention, the value at byte offset 0 is considered index 1.
     *
     * @example
     * ia := PopupWindow_IntegerArray(
     *     Capacity := 4,
     *     IntType := "int",
     *     IntSize := 4,
     *     ; Note I have only added 3 values.
     *     10, 23, 1991
     * )
     * MsgBox(ia[1]) ; 10
     * MsgBox(ia[-2]) ; 1991
     * ia[4] := 18
     * MsgBox(ia[-1]) ; 18
     * ; enumerate the values
     * s := ""
     * for n in ia {
     *     str .= n ", "
     * }
     * MsgBox(SubStr(str, 1, -2)) ; 10, 23, 1991, 18
     *
     * ; If I need to add more, I must increase the capacity.
     * ia.Capacity := 5
     * ia[5] := 30
     * MsgBox(ia[-1]) ; 30
     *
     * ; To use in a `DllCall`, just pass the object directly
     * DllCall('FunctionName', 'ptr', ia)
     * @
     *
     * The object does not track which indices are set; accessing an unset index will still return
     * a value but the value will be meaningless. Consequently, when enumerating the object in a
     * `for` loop, it will iterate the entire buffer even if you never added an integer to any index.
     *
     * You can call {@link PopupWindow_IntegerArray.Prototype.Enum} to restrict the range of indices which get
     * enumerated.
     *
     * @example
     * ia := PopupWindow_IntegerArray(
     *     Capacity := 6,
     *     IntType := "int",
     *     IntSize := 4,
     *     ; Note I have only added 3 values.
     *     10, 9, 10
     * )
     * iaEnumerator := ia.Enum(
     *     VarCount := 1,
     *     StartIndex := 1,
     *     StopIndex := 3
     * )
     * for n in iaEnumerator {
     *     ; work
     * }
     *
     * ; or call the enumerator inline
     * for n in ia.Enum(1, 1, 3) {
     *     ; work
     * }
     *
     * ; or call the enumerator in 2-param mode
     * s := ""
     * for i, n in ia.Enum(VarCount := 2, 1, 3) {
     *     s .= i ": " n ", "
     * }
     * MsgBox(SubStr(s, 1, -2)) ; 1: 10, 2: 9, 3: 10
     * @
     *
     * Regarding the {@link PopupWindow_IntegerArray.Prototype.__Item} property, -1 will always be the last position
     * according to the `Size` property, even if you never added a value there.
     *
     * @class
     *
     * @param {Integer} [Capacity = 0] - The maximum item count in number of items. This value is used
     * to set the {@link https://www.autohotkey.com/docs/v2/lib/Buffer.htm#Size Size} property of
     * the buffer object.
     *
     * @param {String} [IntType = "int"] - The type of integer. This gets used as the `Type` param
     * of {@link https://www.autohotkey.com/docs/v2/lib/NumGet.htm NumGet} and
     * {@link https://www.autohotkey.com/docs/v2/lib/NumPut.htm NumPut}. Also see
     * {@link https://www.autohotkey.com/docs/v2/lib/DllCall.htm#types}.
     *
     * @param {Integer} [IntSize = 4] - The size of the integer in bytes.
     *
     * @param {...Integer} [Values] - Any number of values to be added to the buffer.
     */
    __New(Capacity?, IntType := 'int', IntSize := 4, Values*) {
        this.IntSize := IntSize
        this.IntType := IntType
        if IsSet(Capacity) {
            this.Capacity := Capacity
            if Values.Length > Capacity {
                throw ValueError('The number of values exceeds the capacity.')
            }
        } else {
            this.Capacity := Values.Length
        }
        for Value in Values {
            if IsSet(Value) {
                NumPut(IntType, Value, this, (A_Index - 1) * this.IntSize)
            }
        }
    }

    Enum(VarCount := 1, StartIndex := 1, StopIndex := this.Capacity) {
        i := StartIndex - 1
        intSize := this.IntSize
        intType := this.IntType

        return _Enum%VarCount%

        _Enum1(&Value) {
            if ++i > StopIndex {
                return 0
            }
            Value := NumGet(this, (i - 1) * intSize, intType)
            return 1
        }
        _Enum2(&Index, &Value) {
            if ++i > StopIndex {
                return 0
            }
            Value := NumGet(this, (i - 1) * intSize, intType)
            Index := i
            return 1
        }
    }

    Capacity {
        Get => this.Size / this.IntSize
        Set => this.Size := Value * this.IntSize
    }

    __Enum(VarCount := 1) => this.Enum(VarCount)

    __Item[Index] {
        Get {
            if !Index {
                throw IndexError('Invalid index.', , Index)
            }
            if Abs(Index) > this.Capacity {
                throw IndexError('Index out of range.', , Index)
            }
            return NumGet(this, Index > 0 ? (Index - 1) * this.IntSize : this.Size + Index * this.IntSize, this.IntType)

        }
        Set {
            if !Index {
                throw IndexError('Invalid index.', , Index)
            }
            if Abs(Index) > this.Capacity {
                throw IndexError('Index out of range.', , Index)
            }
            If !IsInteger(Value) {
                throw TypeError('The value must be an integer.', , IsObject(Value) ? '' : Value)
            }
            NumPut(this.IntType, Value, this, Index > 0 ? (Index - 1) * this.IntSize : this.Size + Index * this.IntSize)
        }
    }
}

class PopupWindow_Size extends Buffer {
    /**
     * @description - A buffer representing a
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/windef/ns-windef-size SIZE structure}.
     * @class
     * @param {Integer} [W] - The width.
     * @param {Integer} [H] - The height.
     */
    __New(W?, H?) {
        this.Size := 8
        if IsSet(W) {
            this.W := W
        }
        if IsSet(H) {
            this.H := H
        }
    }
    W {
        Get => NumGet(this, 0, 'int')
        Set => NumPut('int', Value, this)
    }
    H {
        Get => NumGet(this, 4, 'int')
        Set => NumPut('int', Value, this, 4)
    }
}

/**
 * @description - Gets the dimensions of a string within a window's device context. Carriage return
 * and line feed characters are ignored, the returned height is always that of a one-line string.
 *
 * See {@link https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-gettextextentpoint32w}.
 *
 * @param {Integer} hdc - A handle to the device context you want used to measure the string.
 * @param {String} Str - The string to measure.
 * @returns {PopupWindow_Size}
 */
PopupWindow_GetTextExtentPoint32(hdc, Str) {
    ; Measure the text
    if DllCall('Gdi32.dll\GetTextExtentPoint32'
        , 'Ptr', hdc
        , 'Ptr', StrPtr(Str)
        , 'Int', StrLen(Str)
        , 'Ptr', sz := PopupWindow_Size()
        , 'Int'
    ) {
        return sz
    } else {
        throw OSError()
    }
}

/**
 * @description - {@link PopupWindow_GetTextExtentExPoint} measures a string's dimensions and the width (extent
 * point) in pixels of each character's position in the string.
 *
 * See {@link https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-gettextextentexpointw}.
 *
 * @param {Integer} hdc - The handle to the device context to use when measuring the string.
 * @param {String} Str - The string to measure.
 * @param {Integer} [MaxExtent = 0] - The maximum width of the string in pixels. When nonzero,
 * `OutCharacterFit` is set to the number of characters that fit within the `MaxExtent` pixels, and
 * `OutExtentPoints` will only contain extent points up to `OutCharacterFit` number of characters.
 * If 0, `MaxExtent` is ignored, `OutCharacterFit` is assigned 0, and `OutExtentPoints` will contain
 * the extent point for every character in the string.
 * @param {VarRef} [OutCharacterFit] - A variable that will receive the number of characters
 * that fit within the given width. If `MaxExtent` is 0, this will be set to 0.
 * @param {VarRef} [OutExtentPoints] - A variable that will receive an {@link PopupWindow_IntegerArray},
 * a buffer object containing the partial string extent points (the cumulative width of the string at
 * each character from left to right measured from the beginning of the string to the right-side of
 * the character). If `MaxExtent` is nonzero, the number of extent points contained by
 * `OutExtentPoints` will equal `OutCharacterFit`. If `MaxExtent` is zero, `OutExtentPoints` will
 * contain the extent point for every character in the string. See {@link PopupWindow_IntegerArray}
 * for more information.
 * @returns {PopupWindow_Size}
 */
PopupWindow_GetTextExtentExPoint(hdc, Str, MaxExtent := 0, &OutCharacterFit?, &OutExtentPoints?) {
    if MaxExtent {
        if DllCall('Gdi32.dll\GetTextExtentExPoint'
            , 'ptr', hdc
            , 'ptr', StrPtr(Str)                                    ; String to measure
            , 'int', StrLen(Str)                                    ; String length in WORDs
            , 'int', MaxExtent                                      ; Maximum width
            , 'ptr', lpnFit := Buffer(4)                            ; To receive number of characters that can fit
            , 'ptr', OutExtentPoints := PopupWindow_IntegerArray(StrLen(Str))   ; An array to receives partial string extents.
            , 'ptr', sz := PopupWindow_Size()                                   ; To receive the dimensions of the string.
            , 'ptr'
        ) {
            OutCharacterFit := NumGet(lpnFit, 0, 'int')
            return sz
        } else {
            throw OSError()
        }
    } else {
        if DllCall('Gdi32.dll\GetTextExtentExPoint'
            , 'ptr', hdc
            , 'ptr', StrPtr(Str)                                    ; String to measure
            , 'int', StrLen(Str)                                    ; String length in WORDs
            , 'int', 0
            , 'ptr', 0
            , 'ptr', OutExtentPoints := PopupWindow_IntegerArray(StrLen(Str))   ; An array to receives partial string extents.
            , 'ptr', sz := PopupWindow_Size()                                   ; To receive the dimensions of the string.
            , 'ptr'
        ) {
            OutCharacterFit := 0
            return sz
        } else {
            throw OSError()
        }
    }
}

class PopupWindow_WrapText {

    /**
     * @description - Wraps text to a maximum width in pixels.
     *
     * {@link PopupWindow_WrapText} measures the input text
     *
     * If one or more characters between `Options.MinExtent` and `Options.MaxExtent` are break
     * characters, then:
     * - If the break character closest to `Options.MaxExtent` is a whitespace character, then the
     *   line wraps before the whitespace character. Any extra whitespace characters are trimmed from
     *   each line.
     * - If the break character closest to `Options.MaxExtent` is not a whitespace character, then
     *   the line wraps after the character.
     *
     * If there are no break characters, then the line is wrapped after the character closest to
     * `Options.MaxExtent`. A hyphen may be added depending on the character and the input options.
     * {@link PopupWindow_WrapText} ensures that adding a hyphen does not cause the line to exceed `Options.MaxExtent`.
     *
     * Additional details:
     * - When `Options.MeasureLines` is false, and if {@link PopupWindow_WrapText} is directed to use hyphens where
     *   appropriate, there is a small chance that some measurements may be off by one or two pixels. This
     *   is caused by the way {@link PopupWindow_WrapText} handles hyphens. If `Options.MeasureLines` is false, any
     *   measurement that involves a hyphen is produced by adding the width of a hyphen to the width of
     *   a line. This does not account for kerning and other system-dependent conditions, and may produce
     *   an incorrect value. If your application requires precise adherence to `Options.MaxExtent`, set this
     *   to a nonzero value. When false, the possible incorrect values produced by {@link PopupWindow_WrapText} are:
     *   - The width of any line that is hyphenated can potentially be one or two pixels over
     *     `Options.MaxExtent` or one or two pixels under `Options.MinExtent`.
     *   - The value received by `OutWidth` may be one or two pixels off in either direction from the
     *     actual width.
     * - All consecutive end of line characters are converted to a single space character prior to processing.
     * - When making the decision to add additional characters to `Options.BreakChars`, keep in mind that,
     *   if a break character will always be followed by a whitespace character, then adding it to
     *   `Options.BreakChars` will only change the amount of time it takes {@link PopupWindow_WrapText} to process the input.
     *   It will not change the output string. If there is a possibility that the character is followed by
     *   a non-whitespace character, and it is a character that you believe is a natural break character for
     *   your project, then you should add it to the list.
     * - There's no harm if the input string ultimately does not contain one or more of the characters
     *   from `Options.BreakChars`; the string is checked to see if it contains at least one of each
     *   character. If any character is absent, it is purged from the list of possible break characters to
     *   save processing time.
     * - If there are only spaces (and no tabs) in the input string, {@link PopupWindow_WrapText} only checks for spaces
     *   when searching for whitespace, and vise-versa.
     * - A hyphen is never added after a break character, even if the break character is alphanumeric and
     *   the related option is true.
     * - If the difference between `Options.MaxExtent` and `Options.MinExtent` is relatively small,
     *   there is a possibility that no valid wrap position is available within a substring. If this occurs,
     *   {@link PopupWindow_WrapText} will always choose to wrap at an extent less than `Options.MaxExtent`, resulting in a
     *   line shorter than `Options.MinExtent`.
     * - Similar to the above point, if {@link PopupWindow_WrapText} trims whitespace characters from the end of a line,
     *   this can cause the line to be shorter than `Options.MinExtent`.
     *
     * @param {Gui.Control|Integer|Object} Context - Either a handle to the device context to use to
     * measure the text, a `Gui.Control` object, or an object with an `hWnd` property.
     *
     * @param {VarRef} [Str] - The input string, and/or a variable that will receive the result string.
     * - `Str` is required when `Context` is a handle to a device context.
     * - If you set `Str` with a string value, {@link PopupWindow_WrapText} always processes that value, and sets the
     *   variable with the resulting string before {@link PopupWindow_WrapText} returns.
     * - If `Context` is an object, then `Str` is optional. If you leave it unset, or pass it as an unset
     *   VarRef / empty string VarRef, then {@link PopupWindow_WrapText} processes the contents of `Context.Text`. If the
     *   object does not have a `Text` property, AHK will throw an error.
     *
     * @param {Object|PopupWindow_WrapText.Options} [Options] - If `Options` is an
     * {@link PopupWindow_WrapText.Options} object, it does not get passed to
     * {@link PopupWindow_WrapText.Options.Prototype.__New}, saving a bit of processing time.
     * Otherwise, it is an object containing zero or more options as property : value pairs.
     *
     * @param {Boolean} [Options.AdjustObject = false] - If `Options.AdjustObject == true`, then `WrapText`
     * expects `Context` to be an object with a `Text` property and a `Move` method, such as a `Gui.Control`
     * object. Before `WrapText` exits, `WrapText` removes any soft hyphens from the result string, then
     * sets the `Context.Text` property with the result string, then calls `Context.Move`. The width
     * used is the greatest width of each line in the string (same value that `OutWidth` receives).
     * The height used depends on the value of `Options.MeasureLines`. If `Options.MeasureLines` is
     * nonzero, then `OutHeight` is set with the cumulative height of the string, and its value gets
     * used. If `Options.MeasureLines` is false, the height is set to `sz.H * LineCount` where `sz`
     * is the  {@link Display_Size} object produced from the last `GetTextExtentExPoint` function
     * call. In general this will be pretty close to the true height of the string, but should
     * be expected to be slightly off.
     *
     * @param {String} [Options.BreakChars = "-"] - `BreakChars` is a list of characters that defines what
     * characters are valid breakpoints for splitting a line other than a space or tab. Do not include
     * any separators between the characters. Do not escape any characters. See the function description
     * for a description of {@link PopupWindow_WrapText}'s process.
     *
     * @param {Boolean} [Options.HyphenateLetters = true] - When true, {@link PopupWindow_WrapText} hyphenates the line if
     * the last character in the line causes `IsAlpha(char)` to return true. This option is only invoked
     * if a line does not contain any break characters between `Options.MinExtent` and `Options.MaxExtent`.
     *
     * @param {Boolean} [Options.HyphenateNumbers = false] - When true, {@link PopupWindow_WrapText} hyphenates the line if
     * the last character in the line causes `IsNumber(char)` to return true. This option is only invoked
     * if a line does not contain any break characters between `Options.MinExtent` and `Options.MaxExtent`.
     *
     * @param {Integer} [Options.MaxExtent] - The maximum width of a line in pixels. This is optional when
     * `Context` is an object with a `GetPos` method, such as a `Gui.Control` object. If `Options.MaxExtent`
     * is unset, `Context.GetPos(, , &MaxExtent)` is called. The maximum width must be at least three times
     * the width of a "W" character in the device context.
     *
     * @param {Boolean|Array} [Options.MeasureLines] - When a nonzero value, {@link PopupWindow_WrapText} will measure
     * each line during processing. This allows {@link PopupWindow_WrapText} to set `OutHeight` with the correct height
     * of the string, and `OutWidth` with an accurate width of the string (see the note about this
     * in the function description). If `Options.MeasureLines` is an array object, {@link PopupWindow_WrapText} will also
     * add each `Size` object that is produced from the measurement to that array. For large strings
     * or many consecutive function calls, you should set the capacity of the array to what you expect
     * it will need prior to calling {@link PopupWindow_WrapText}. If {@link PopupWindow_WrapText} is false, no additional measurements occur.
     *
     * @param {Number} [Options.MinExtent] - Sets the minimum width of a line, directing {@link PopupWindow_WrapText}
     * to require each line to be at least the minimum before inserting a line break.
     *
     * If `Options.MinExtent` is between 0 and 1, the minimum width of a line is
     * `Ceil(Options.MinExtent * Options.MaxExtent)`. Use this to specify a minimum width as a proportion
     * of the maximum. If `Options.MinExtent` is greater than 1, `Options.MinExtent` is used as the
     * minimum width of a line, in pixels.
     *
     * `Options.MinExtent` directs {@link PopupWindow_WrapText} to break each line at an extent point no less than the minimum.
     * This is useful in most situations, but particularly in situations where the input string contains
     * words/substrings that are generally pretty long relative to `Options.MaxExtent`. {@link PopupWindow_WrapText}'s default
     * behavior might cause a line to be very short, in a way that would be aesthetically unnatural or
     * displeasing. When `Options.MinExtent` is set, if a substring does not contain a valid break character
     * between `Options.MinExtent` and `Options.MaxExtent`, then it will wrap the line at or around
     * `Options.MaxExtent` (depending on the values of the other options) as if there were no break
     * characters in the entire line. The example below depicts the default behavior without
     * `Options.MinExtent`.
     *
     * @example
     * Ctrl := (G := Gui()).AddText()
     * Ctrl.Text := 'She sang supercalifradulisticexpialidocious then went on her merry way.'
     * hdc := DllCall('GetDC', 'Ptr', Ctrl.hWnd, 'Ptr')
     * sz := GetTextExtentPoint32(hdc, 'She sang supercalifradulisticexpialidoc')
     * LineCount := PopupWindow_WrapText(Ctrl, &Str, { MaxExtent: sz.W, AdjustObject: true })
     * Split := StrSplit(Ctrl.Text, '`r`n')
     * MsgBox(Split[1]) ; She sang
     * MsgBox(Split[2]) ; supercalifradulisticexpialidocious then
     * MsgBox(Split[3]) ; went on her merry way.
     * @
     *
     * @param {String} [Options.EndOfLine = "`r`n"] - The end of line character(s) to use.
     *
     * @param {Boolean} [Options.ZeroWidthSpace = true] - When true, if the input text contains Zero Width
     * Space characters (code point U+200B), they will be treated as soft hyphens and will be used as
     * a break character. When a line breaks at a Zero Width Space character, a visible hyphen is placed
     * after the Zero Width Space character and the line wraps after the hyphen. When false, Zero Width
     * Space characters are ignored and when a hard break is necessary, {@link PopupWindow_WrapText} breaks the line at the
     * greatest extent which satisfies the other options. When false and if hyphens are used, a substring
     * may be hyphenated at any position in the word. Generally this should be left true; if no U+200B
     * characters are present in the input string, {@link PopupWindow_WrapText} adjusts its process to avoid using resources
     * searching for them.
     *
     * @param {VarRef} [OutWidth] - A variable that will receive the width of the line with the greatest
     * width in the result string.
     *
     * @param {VarRef} [OutHeight] - A variable that will receive the cumulative height of each line.
     * This only receives a value if `Options.MeasureLines` is nonzero.
     *
     * @returns {Integer} - The number of lines the text was split into.
     */
    static Call(Context, &Str?, Options?, &OutWidth?, &OutHeight?) {
        local Pos
        if IsSet(Options) && Options.__Class != 'PopupWindow_WrapText.Options' {
            Options := PopupWindow_WrapText.Options(Options ?? unset)
        }
        if IsObject(Context) {
            if HasProp(Context, 'hWnd') {
                ; If MaxExtent is unset, use the width of the control.
                if Options.MaxExtent {
                    MaxExtent := Options.MaxExtent
                } else {
                    Context.GetPos(, , &MaxExtent)
                }
                if IsSet(Str) {
                    Text := RegExReplace(Str, '\R+', ' ')
                } else if IsObject(Context.Text) {
                    throw TypeError('``Context.Text`` returned an object.',
                    , 'Type(Context.Text) == ' Type(Context.Text))
                } else {
                    Text := RegExReplace(Context.Text, '\R+', ' ')
                }
                font_context := PopupWindow_SelectFontIntoDc(Context.hWnd)
                hdc := font_context.hdc
            } else {
                _Throw(1, A_LineNumber, A_ThisFunc)
            }
        } else if IsNumber(Context) {
            if !IsSet(Str) || !Options.MaxExtent {
                _Throw(2, A_LineNumber, A_ThisFunc)
            }
            MaxExtent := Options.MaxExtent
            hdc := Context
            Text := RegExReplace(Str, '\R+', ' ')
        } else {
            _Throw(1, A_LineNumber, A_ThisFunc)
        }

        ; Set MinExtent
        if IsNumber(Options.MinExtent) {
            if Options.MinExtent < 1 {
                MinExtent := Ceil(MaxExtent * Options.MinExtent)
            } else {
                MinExtent := Options.MinExtent
            }
        } else {
            MinExtent := 0
        }

        ; Initialize the buffers
        fitBuf := Buffer(4)
        Extent := PopupWindow_IntegerArray(StrLen(Text))
        sz := PopupWindow_Size()

        ; Measure the width of a hyphen
        hyphen := '-'
        if !DllCall('Gdi32.dll\GetTextExtentPoint32', 'Ptr'
            , hdc, 'Ptr', StrPtr(hyphen), 'Int', 1, 'Ptr', sz, 'Int') {
            throw OSError()
        }
        hyphen := sz.W

        ; `MaxExtent` must at least be large enough such that the loops can iterate once or twice
        ; before reaching the beginning of the substring.
        if !DllCall('Gdi32.dll\GetTextExtentPoint32', 'Ptr'
            , hdc, 'Ptr', StrPtr('W'), 'Int', 1, 'Ptr', sz, 'Int') {
            throw OSError()
        }
        if MaxExtent < sz.W * 3 {
            throw ValueError('``Options.MaxExtent`` must be at least three times the width of "W" in the device'
            ' context.', -1, '``Options.MaxExtent``: ' MaxExtent '; Function minimum: ' (sz.W * 3))
        }

        ; Set the condition determining whether a hyphen is used.
        if Options.HyphenateLetters {
            Hyphenate := Options.HyphenateNumbers
            ? () => IsAlnum(SubStr(Text, Pos, 1))
            : () => IsAlpha(SubStr(Text, Pos, 1))
            _Proc_0 := _Proc_0_1
        } else if Options.HyphenateNumbers {
            Hyphenate := () => IsNumber(SubStr(Text, Pos, 1))
            _Proc_0 := _Proc_0_1
        } else {
            _Proc_0 := _Proc_0_0
        }

        ; Check the string for the presence of break characters
        BreakChars := ''
        z := InStr(Text, '`t') ? 1 : 0
        if Options.BreakChars {
            _BreakChars := ''
            for ch in StrSplit(Options.BreakChars) {
                if InStr(Text, ch) {
                    _BreakChars .= ch
                }
            }
            if Options.RespectSoftHyphen && InStr(Text, Chr(0x200B)) {
                _BreakChars .= Chr(0x200B)
                _Proc_B := _Proc_B_1
            } else {
                _Proc_B := _Proc_B_0
            }
            if _BreakChars {
                _BreakChars := RegExReplace(StrReplace(_BreakChars, '\', '\\'), '(\]|-)', '\$1')
                BreakChars := '([' _BreakChars '])[^' _BreakChars ']*$'
                z += 2
            }
        } else if Options.RespectSoftHyphen && InStr(Text, Chr(0x200B)) {
            BreakChars := '([' Chr(0x200B) '])[^' Chr(0x200B) ']*$'
            z += 2
            _Proc_B := _Proc_B_1
        } else {
            _Proc_B := _Proc_B_0
        }
        if InStr(Text, '`s') {
            z += 4
        }
        switch z {
            case 0: Proc := _Proc_0
            case 1: Proc := _Proc_1.Bind('`t')      ; Tabs
            case 2: Proc := _Proc_2                 ; Break chars
            case 3: Proc := _Proc_3.Bind('`t')      ; Tabs + break chars
            case 4: Proc := _Proc_1.Bind('`s')      ; Spaces
            case 5: Proc := _Proc_4                 ; Spaces + tabs
            case 6: Proc := _Proc_3.Bind('`s')      ; Spaces + break chars
            case 7: Proc := _Proc_5                 ; Spaces + tabs + break chars
        }

        if Options.MeasureLines {
            OutHeight := 0
            ; I half the hyphen's width here to limit the number of instances when a line gets measured
            ; and its width exceed `Options.MaxExtent`, causing some steps to be repeated. When preemptively
            ; testing the width of a line, if I add the entire width of a hyphen to the line's width, this
            ; can occasionally cause `PopupWindow_WrapText` to skip a breakpoint that should have been used due to the
            ; imprecise measurement. If I don't test the lines, or test the lines by adding a width that
            ; is too small, there is a greater likelihood that some steps must be repeated. I don't
            ; expect any fonts are designed in a way that more than half of the hyphen's width is tucked
            ; into the previous font's space, and so I figure this is an acceptable approach.
            hyphen *= 0.5
            if Options.MeasureLines is Array {
                Measurements := Options.MeasureLines
                Set := _Set_1
            } else {
                Set := _Set_2
            }
        } else {
            Set := _Set_3
        }

        eol := Options.EndOfLine
        LineCount := 0
        OutWidth := 0
        Str := ''
        VarSetStrCapacity(&Str, StrLen(Text))

        ; Core loop
        loop {
            Len := StrLen(Text)
            ptr := StrPtr(Text)
            if !DllCall('Gdi32.dll\GetTextExtentExPoint'
                , 'ptr', hdc                ; Device context
                , 'ptr', ptr                ; String to measure
                , 'int', Len                ; String length in WORDs
                , 'int', MaxExtent          ; Maximum width
                , 'ptr', fitBuf             ; To receive number of characters that can fit
                , 'ptr', Extent             ; A buffer to receives partial string extents.
                , 'ptr', sz                 ; To receive the dimensions of the string.
                , 'ptr'
            ) {
                throw OSError()
            }
            if (fit := NumGet(fitBuf, 0, 'uint')) >= Len {
                break
            }
            LineCount++
            if Proc() {
                break
            }
        }

        ; Add last piece to the string
        if Text {
            Set(StrLen(Text))
            Str := Trim(Str, '`r`n`s`t')
            LineCount++
        }

        ; Release dc, disable error handler
        if IsObject(Context) {
            if Options.AdjustObject {
                Context.Text := Str
                if Options.MeasureLines {
                    Context.Move(, , OutWidth, OutHeight)
                } else {
                    Context.Move(, , OutWidth, sz.H * LineCount)
                }
            }
            font_context()
        }

        return LineCount

        ; No break characters or whitespace
        ; With hyphens
        _Proc_0_1() {
            Pos := NumGet(fitBuf, 0, 'uint')
            ; The loop checks if a hyphen should be added given the last character, and if so,
            ; checks if adding the hyphen will possibly cause the line to exceed `MaxExtent`.
            loop Pos - 1 {
                if Hyphenate() {
                    if Extent[Pos] + hyphen <= MaxExtent {
                        if Set(Pos, '-') {
                            Pos--
                        } else {
                            return _TrimRight()
                        }
                    } else {
                        Pos--
                    }
                } else {
                    Set(Pos)
                    return _TrimRight()
                }
            }
        }
        ; No break characters or whitespace
        ; Without hyphens
        _Proc_0_0() {
            Set(NumGet(fitBuf, 0, 'uint'))
            return _TrimRight()
        }
        ; Has spaces or tabs
        _Proc_1(ch) {
            if (Pos := InStr(SubStr(Text, 1, fit), ch, , , -1)) && Extent[Pos] >= MinExtent {
                return _Proc_W()
            } else {
                return _Proc_0()
            }
        }
        ; Has break characters
        _Proc_2() {
            if (Pos := RegExMatch(SubStr(Text, 1, fit), BreakChars)) && Extent[Pos] >= MinExtent {
                return _Proc_B()
            } else {
                return _Proc_0()
            }
        }
        ; Has either spaces / tabs, and break characters
        _Proc_3(ch) {
            Part := SubStr(Text, 1, fit)
            Pos := Max(Pos_B := RegExMatch(Part, BreakChars), Pos_W := InStr(Part, ch, , , -1))
            if !Pos || Extent[Pos] < MinExtent {
                return _Proc_0()
            } else if Pos_W > Pos_B {
                return _Proc_W()
            } else {
                return _Proc_B()
            }
        }
        ; Has spaces and tabs
        _Proc_4() {
            Part := SubStr(Text, 1, fit)
            Pos := Max(InStr(Part, '`t', , , -1), InStr(Part, '`s', , , -1))
            if Pos && Extent[Pos] >= MinExtent {
                return _Proc_W()
            } else {
                return _Proc_0()
            }
        }
        ; Has spaces, tabs, and break characters
        _Proc_5() {
            Part := SubStr(Text, 1, fit)
            Pos := Max(
                Pos_B := RegExMatch(Part, BreakChars)
              , Pos_W := Max(
                    InStr(Part, '`t', , , -1)
                  , InStr(Part, '`s', , , -1)
                )
            )
            if !Pos || Extent[Pos] < MinExtent {
                return _Proc_0()
            } else if Pos_W > Pos_B {
                return _Proc_W()
            } else {
                return _Proc_B()
            }
        }
        ; Breaking at a break character
        ; With soft hyphen
        _Proc_B_1() {
            if NumGet(ptr, (Pos - 1) * 2, 'str') == 0x200B {
                ; If adding the hyphen does not cause the width to exceed the max
                if Extent[Pos] + hyphen <= MaxExtent {
                    if Set(Pos, '-') {
                        ; Adjust `fit` to just before the ZWS, then re-check the string
                        fit := Pos - 1
                        return Proc()
                    }
                } else {
                    fit := Pos - 1
                    return Proc()
                }
            } else {
                Set(Pos)
            }
            return _TrimRight()
        }
        ; Breaking at a break character
        ; Without soft hyphen
        _Proc_B_0() {
            Set(Pos)
            return _TrimRight()
        }
        ; Breaking at a whitespace character
        _Proc_W() {
            _TrimLeft()
            ; If after trimming the whitespace, the length of the line is too short
            if Extent[Pos - 1] < MinExtent {
                return _Proc_0()
            } else {
                Set(Pos - 1)
                return _TrimRight()
            }
        }
        _ReleaseDC(Thrown, *) {
            DllCall('ReleaseDC', 'Ptr', Context.hWnd, 'Ptr', hdc, 'Int')
            OnError(_ReleaseDC, 0)
            throw Thrown
        }
        ; Measure string, add size object to array
        _Set_1(SetPos, AddHyphen := '') {
            Part := SubStr(Text, 1, SetPos) AddHyphen
            if DllCall('Gdi32.dll\GetTextExtentPoint32'
                , 'Ptr', hdc
                , 'Ptr', StrPtr(Part)
                , 'Int', StrLen(Part)
                , 'Ptr', measure_sz := PopupWindow_Size()
                , 'Int'
            ) {
                if measure_sz.W > MaxExtent {
                    return 1
                }
                Measurements.Push(measure_sz)
                OutWidth := Max(OutWidth, measure_sz.W)
                OutHeight += sz.H
                Str .= Part eol
            } else {
                throw OSError()
            }
        }
        ; Measure string, no array
        _Set_2(SetPos, AddHyphen := '') {
            Part := SubStr(Text, 1, SetPos) AddHyphen
            if DllCall('Gdi32.dll\GetTextExtentPoint32'
                , 'Ptr', hdc
                , 'Ptr', StrPtr(Part)
                , 'Int', StrLen(Part)
                , 'Ptr', sz
                , 'Int'
            ) {
                if sz.W > MaxExtent {
                    return 1
                }
                OutWidth := Max(OutWidth, sz.W)
                OutHeight += sz.H
                Str .= Part eol
            } else {
                throw OSError()
            }
        }
        ; Don't measure string
        _Set_3(SetPos, AddHyphen := false) {
            if AddHyphen {
                if Extent[SetPos] + hyphen > MaxExtent {
                    return 1
                }
                Part := SubStr(Text, 1, SetPos) '-'
                OutWidth := Max(OutWidth, Extent[SetPos] + hyphen)
                Str .= Part eol
            } else {
                Part := SubStr(Text, 1, SetPos)
                OutWidth := Max(OutWidth, Extent[SetPos])
                Str .= Part eol
            }
        }
        _Throw(Id, Line, Fn) {
            switch Id {
                case 1: err := TypeError('``Context`` must be either a number representing a handle to'
                    ' a device context, or an object with an ``hWnd`` property.', -2, 'Type(Context) == '
                    Type(Context))
                case 2:
                    if IsSet(Str) {
                        Extra := '``Options.MaxExtent`` is unset.'
                    } else if Options.MaxExtent {
                        Extra := '``Str`` is unset.'
                    } else {
                        Extra := '``Str`` and ``Options.MaxExtent`` are unset.'
                    }
                    err := UnsetError('``Str`` and ``Options.MaxExtent`` must be set when ``Context`` is a number.', -2, Extra)
            }
            err.What := Fn
            err.Line := Line
            throw err
        }
        _TrimRight() {
            ; Trim whitespace right
            while NumGet(ptr, Pos * 2, 'str') < 33 {
                Pos++
                if Pos > Len {
                    Text := ''
                    return 1
                }
            }
            Text := SubStr(Text, Pos + 1)
        }
        _TrimLeft() {
            while NumGet(ptr, (Pos - 2) * 2, 'str') < 33 {
                Pos--
            }
        }
    }

    class Options {
        static __New() {
            this.DeleteProp('__New')
            proto := this.Prototype
            proto.AdjustObject := false
            proto.BreakChars := '-'
            proto.EndOfLine := '`r`n'
            proto.HyphenateLetters := true
            proto.HyphenateNumbers := true
            proto.MaxExtent := ''
            proto.MeasureLines := false
            proto.MinExtent := ''
            proto.RespectSoftHyphen := true
        }

        __New(options?) {
            if IsSet(options) {
                if IsSet(WrapTextConfig) {
                    for prop in PopupWindow_WrapText.Options.Prototype.OwnProps() {
                        if HasProp(options, prop) {
                            this.%prop% := options.%prop%
                        } else if HasProp(WrapTextConfig, prop) {
                            this.%prop% := WrapTextConfig.%prop%
                        }
                    }
                } else {
                    for prop in PopupWindow_WrapText.Options.Prototype.OwnProps() {
                        if HasProp(options, prop) {
                            this.%prop% := options.%prop%
                        }
                    }
                }
            } else if IsSet(WrapTextConfig) {
                for prop in PopupWindow_WrapText.Options.Prototype.OwnProps() {
                    if HasProp(WrapTextConfig, prop) {
                        this.%prop% := WrapTextConfig.%prop%
                    }
                }
            }
            if this.HasOwnProp('__Class') {
                this.DeleteProp('__Class')
            }
        }
    }
}

class PopupWindow_InsertHyphenationPoints {
    /**
     * @description - {@link PopupWindow_InsertHyphenationPoints} uses a simple heuristic to insert more natural hyphenation
     * points into the input text. {@link PopupWindow_InsertHyphenationPoints} uses character 0x200B, "Zero Width Space".
     * While not every hyphenation point will feel completely natural, the result with {@link PopupWindow_WrapText}
     * will be much more consistent with what people expect regarding hyphenated words. This should
     * be used with strings that consist of mostly English words. Because the heuristic approximates
     * syllable boundaries, {@link PopupWindow_InsertSoftHyphens} is not intended to be used with non-word text.
     * @param {VarRef} Str - This variable should contain the string to have soft hyphens inserted
     * into. It will be modified directly
     * @param {Integer} [Mode = 1] - Either 1 or 2. At this time, don't use 2. It needs more work.
     */
    static Call(&Str, Mode := 1) {
        Str := RegExReplace(Str, this.Pattern[Mode], '${first}' Chr(0x200B) '${second}')
    }
    static GetPattern(which) {
        switch which, 0 {
            case 1: return (
                'iJ)'
                '(?:'
                    '(?<first>' this.vowel ')' this.boundary '(?<second>' this.consonant ')'
                    '|(?<first>' this.consonant ')' this.boundary '(?<second>' this.vowel ')'
                    '|(?<first>' this.vowel this.clusters this.consonant ')' this.boundary '(?<second>' this.consonant ')'
                    '|(?<first>' this.consonant this.vowel ')' this.boundary '(?<second>' this.consonant ')'
                    '|' this.clusters '(?<first>' this.consonant ')' this.boundary '(?<second>' this.consonant this.vowel ')'
                ')'
            )
            case 2: return (
                'iJ)'
                '(?:'
                    '(?<first>' this.vowel ')' this.boundary '(?<second>' this.consonant this.vowel ')'
                    '|(?<first>' this.vowel this.clusters this.consonant ')' this.boundary '(?<second>' this.consonant this.vowel ')'
                    '|(?<first>' this.consonant this.vowel this.clusters this.consonant ')' this.boundary '(?<second>' this.consonant ')'
                ')'
            )
        }
    }
    static Vowel := '[aeiouy]'
    , Consonant := '[bcdfghjklmnpqrstvwz]'
    , Clusters := '(?!th|ch|ph|sh|wh|qu|gh|ck|ng|wr)' ; words should not be split between these
    , Boundary := '(?<!\W|^)(?<!\W.|^.)(?!\W|$)(?!.\W|.$)' ; don't break too close to non-alphanumeric / beginning / end
    , Pattern := [ this.GetPattern(1), this.GetPattern(2) ]
}

class PopupWindow_ControlFitText {
    static __New() {
        this.DeleteProp('__New')
        this.Cache := this.TextExtentPaddingCollection()
    }

    /**
     * @description -  - Resizes a control according to its text contents.
     *
     * Leave the `UseCache` parameter set with `true` to direct {@link PopupWindow_ControlFitText} and
     * {@link PopupWindow_ControlFitText.MaxWidth} to cache the value for each control type, and use the
     * cached value when available.
     *
     * {@link PopupWindow_ControlFitText.TextExtentPadding} is an imperfect approximation of the padding added
     * to a control's area that displays the text. To get the correct dimensions, each control's text
     * content would have to be evaluated individually. However, any discrepencies will likely be
     * unnoticeable, and you can account for discrepencies by adding an additional pixel or two using
     * the `PaddingX` or `PaddingY` parameters. In most cases you shouldn't need to use additional padding.
     * In my tests, the most common problem was edit controls wrapping text when using a vertical scrollbar;
     * a `PaddingX` value of `1` is sufficient in thise case.
     *
     * Not all controls are compatible with {@link PopupWindow_ControlFitText} and {@link PopupWindow_ControlFitText.MaxWidth}.
     * {@link PopupWindow_ControlFitText} will not evaluate the size correctly unless the control satisfies the following
     * conditions:
     * - `Ctrl.Text` must return a string that is the same as the text that is displayed in the gui.
     * - `Ctrl.GetPos`, when called directly after adding a control to a gui, must return the dimensions
     *   of the control that is relevant to the text's bounding rectangle.
     * - `Ctrl.Move` must resize the portion of the control that is relevant to the text's bounding
     *   rectangle.
     *
     * Invalid control types: DateTime, DropDownList, GroupBox, Hotkey, ListBox, ListView, MonthCal,
     * Picture, Progress, Slider, Tab, Tab2, Tab3, TreeView, and UpDown.
     *
     * Valid control types: ActiveX (possibly), Button, CheckBox, ComboBox, Custom (possibly), Edit,
     * Radio, Text.
     *
     * {@link PopupWindow_ControlFitText} returns the width (`OutWidth`) and height (`OutHeight`) for a
     * control to fit its text contents, plus any additional padding.
     *
     * @param {dGui.Control|Gui.Control} Ctrl - The control object.
     * @param {Integer} [PaddingX = 0] - A number of pixels to add to the width.
     * @param {Integer} [PaddingY = 0] - A number of pixels to add to the height.
     * @param {Boolean} [UseCache = true] - If true, stores or retrieves the output from
     * {@link PopupWindow_ControlFitText.TextExtentPadding}. If false, a new instance is evaluated.
     * @param {VarRef} [OutExtentPoints] - A variable that will receive an array of  {@link PopupWindow_Size} objects
     * returned from `GetMultiExtentPoints`.
     * @param {VarRef} [OutWidth] - A variable that will receive the width as integer.
     * @param {VarRef} [OutHeight] - A variable that will receive the height as integer.
     * @param {Boolean} [MoveControl = true] - If true, the `Gui.Control.Prototype.Move` will be
     * called for `Ctrl` using `OutWidth` and `OutHeight`. If false, the calculations are performed
     * without moving the control.
     */
    static Call(Ctrl, PaddingX := 0, PaddingY := 0, UseCache := true, &OutExtentPoints?, &OutWidth?, &OutHeight?, MoveControl := true) {
        OutExtentPoints := StrSplit(RegExReplace(Ctrl.Text, '\R', '`n'), '`n')
        context := PopupWindow_SelectFontIntoDc(Ctrl.Hwnd)
        hdc := context.Hdc
        _Proc()
        context()
        OutHeight := 0
        if UseCache {
            if !this.Cache.Has(Ctrl.Type) {
                this.Cache.Set(Ctrl.Type, this.TextExtentPadding(Ctrl))
            }
            Padding := this.Cache.Get(Ctrl.Type)
        } else {
            Padding := this.TextExtentPadding(Ctrl)
        }
        OutWidth += PaddingX + Padding.W
        for sz in OutExtentPoints {
            if sz {
                OutHeight += sz.H + Padding.LinePadding
            } else {
                OutHeight += Padding.LineHeight
            }
        }
        OutHeight += PaddingY + Padding.H + Padding.LinePadding * OutExtentPoints.Length
        if MoveControl {
            Ctrl.Move(, , OutWidth, OutHeight)
        }

        return

        _Proc() {
            local sz
            OutWidth := 0
            for Str in OutExtentPoints {
                if Str {
                    if DllCall('Gdi32.dll\GetTextExtentPoint32'
                        , 'Ptr', hdc
                        , 'Ptr', StrPtr(Str)
                        , 'Int', StrLen(Str)
                        , 'Ptr', sz := PopupWindow_Size()
                        , 'Int'
                    ) {
                        OutExtentPoints[A_Index] := sz
                        OutWidth := Max(OutWidth, sz.W)
                    } else {
                        throw OSError()
                    }
                }
            }
        }
    }

    /**
     * @description - {@link PopupWindow_ControlFitText.MaxWidth} resizes a control to fit the text contents of the
     * control plus any additional padding while limiting the width of the control to a maximum value.
     * Note that {@link PopupWindow_ControlFitText.MaxWidth} does not include the width value when calling `Ctrl.Move`;
     * it is assumed your code has handled setting the width.
     *
     * @param {dGui.Control} Ctrl - The control object. See the notes in the class description above
     * {@link PopupWindow_ControlFitText} for compatibility requirements.
     * @param {Integer} [MaxWidth] - The maximum width in pixels. If unset, uses the controls current
     * width.
     * @param {Integer} [PaddingX = 0] - A number of pixels to add to the width.
     * @param {Integer} [PaddingY = 0] - A number of pixels to add to the height.
     * @param {Boolean} [UseCache = true] - If true, stores or retrieves the output from
     * {@link PopupWindow_ControlFitText.TextExtentPadding}. If false, a new instance is evaluated.
     * @param {VarRef} [OutExtentPoints] - A variable that will receive an array of  {@link PopupWindow_Size} objects
     * returned from `GetMultiExtentPoints`.
     * @param {VarRef} [OutHeight] - A variable that will receive an integer value representing the
     * height that was passed to `Ctrl.Move`.
     * @param {Boolean} [MoveControl = true] - If true, the `Gui.Control.Prototype.Move` will be
     * called for `Ctrl` using `OutHeight`. If false, the calculations are performed without moving
     * the control.
     */
    static MaxWidth(Ctrl, MaxWidth?, PaddingX := 0, PaddingY := 0, UseCache := true, &OutExtentPoints?, &OutHeight?, MoveControl := true) {
        OutExtentPoints := StrSplit(RegExReplace(Ctrl.Text, '\R', '`n'), '`n')
        context := PopupWindow_SelectFontIntoDc(Ctrl.Hwnd)
        hdc := context.Hdc
        _Proc()
        context()
        if !IsSet(MaxWidth) {
            Ctrl.GetPos(, , &MaxWidth)
        }
        if UseCache {
            if !this.Cache.Has(Ctrl.Type) {
                this.Cache.Set(Ctrl.Type, this.TextExtentPadding(Ctrl))
            }
            Padding := this.Cache.Get(Ctrl.Type)
        } else {
            Padding := this.TextExtentPadding(Ctrl)
        }
        MaxWidth -= Padding.W + PaddingX
        OutHeight := PaddingY + Padding.H
        for sz in OutExtentPoints {
            if sz {
                lines := Ceil(sz.W / MaxWidth)
                OutHeight += (sz.H + Padding.LinePadding) * lines
            } else {
                OutHeight += Padding.LineHeight
            }
        }
        if MoveControl {
            Ctrl.Move(, , , OutHeight)
        }

        return

        _Proc() {
            local sz
            OutWidth := 0
            for Str in OutExtentPoints {
                if Str {
                    if DllCall('Gdi32.dll\GetTextExtentPoint32'
                        , 'Ptr', hdc
                        , 'Ptr', StrPtr(Str)
                        , 'Int', StrLen(Str)
                        , 'Ptr', sz := PopupWindow_Size()
                        , 'Int'
                    ) {
                        OutExtentPoints[A_Index] := sz
                        OutWidth := Max(OutWidth, sz.W)
                    } else {
                        throw OSError()
                    }
                }
            }
        }
    }

    class TextExtentPadding {
        /**
         * An instance of {@link PopupWindow_ControlFitText.TextExtentPadding} has four properties:
         * - {@link PopupWindow_ControlFitText.TextExtentPadding#W} - The padding added to the text's extent
         * along the X axis.
         * - {@link PopupWindow_ControlFitText.TextExtentPadding#H} - The padding added to the text's extent
         * along the Y axis, not including the padding added for each individual line.
         * - {@link PopupWindow_ControlFitText.TextExtentPadding#LinePadding} - The padding added to the text's
         * extent along the Y axis for each individual line.
         * - {@link PopupWindow_ControlFitText.TextExtentPadding#LineHeight} - The approximate height of an
         * blank line.
         *
         * The values of each property are approximations. See the description above
         * {@link PopupWindow_ControlFitText} for more details and limitations.
         * @class
         *
         * @param {dGui.Control} Ctrl - The control object.
         * @param {String} [Opt = ""] - Options to pass to `Gui.Prototype.Add`.
         * @param {Integer} [ThreadDpiAwarenessContext] - If set, {@link PopupWindow_ControlFitText.TextExtentPadding.__New}
         * calls `SetThreadDpiAwarenessContext` at the beginning, and calls it again before returning
         * to set the thread's context to its original value.
         */
        __New(Ctrl, Opt := '', ThreadDpiAwarenessContext?) {
            if IsSet(ThreadDpiAwarenessContext) {
                originalContext := DllCall('SetThreadDpiAwarenessContext', 'ptr', ThreadDpiAwarenessContext, 'ptr')
            }
            lf := PopupWindow_Logfont(Ctrl.Hwnd)
            G := Gui()
            fontOpt := 's' lf.FontSize ' w' lf.Weight
            if lf.Quality {
                fontOpt .= ' q' lf.Quality
            }
            if lf.Italic {
                fontOpt .= ' italic'
            }
            if lf.StrikeOut {
                fontOpt .= ' strike'
            }
            if lf.Underline {
                fontOpt .= ' underline'
            }
            G.SetFont(fontOpt, lf.FaceName)
            _ctrl := G.Add(Ctrl.Type, Opt, 'line')
            _ctrl.GetPos(, , , &h)
            _ctrl2 := G.Add(Ctrl.Type, Opt, 'line`r`nline')
            _ctrl2.GetPos(, , &w2, &h2)
            sz := _Proc(_ctrl)
            sz2 := _Proc(_ctrl2)
            G.Destroy()
            this.W := w2 - sz2.W
            this.H := h - sz.H
            this.LinePadding := h2 - sz2.H - h + sz.H
            this.LineHeight := (h2 - this.H) / 2
            if IsSet(originalContext) {
                DllCall('SetThreadDpiAwarenessContext', 'ptr', originalContext, 'ptr')
            }

            return

            _Proc(Ctrl) {
                local sz, h, w
                W := H := 0

                lines := StrSplit(RegExReplace(Ctrl.Text, '\R', '`n'), '`n')
                context := PopupWindow_SelectFontIntoDc(Ctrl.Hwnd)
                for line in lines {
                    if line {
                        if DllCall('Gdi32.dll\GetTextExtentPoint32', 'Ptr', context.hdc, 'Ptr', StrPtr(line), 'Int', StrLen(line), 'Ptr', sz := PopupWindow_Size(), 'Int') {
                            H += sz.H
                            W := Max(W, sz.W)
                            lines[A_Index] := sz

                        } else {
                            context()
                            throw OSError()
                        }
                    }
                }
                context()
                return { H: H, Lines: Lines, W: W }
            }
        }
    }

    class TextExtentPaddingCollection extends Map {
    }
}

class PopupWindow_Logfont {
    static __New() {
        this.DeleteProp('__New')
        Proto := this.Prototype
        Proto.Encoding := 'cp1200'
        Proto.Handle := Proto.Hwnd := 0
        Proto.CbSizeInstance :=
        4 + ; LONG  lfHeight                    0
        4 + ; LONG  lfWidth                     4
        4 + ; LONG  lfEscapement                8
        4 + ; LONG  lfOrientation               12
        4 + ; LONG  lfWeight                    16
        1 + ; BYTE  lfItalic                    20
        1 + ; BYTE  lfUnderline                 21
        1 + ; BYTE  lfStrikeOut                 22
        1 + ; BYTE  lfCharSet                   23
        1 + ; BYTE  lfOutPrecision              24
        1 + ; BYTE  lfClipPrecision             25
        1 + ; BYTE  lfQuality                   26
        1 + ; BYTE  lfPitchAndFamily            27
        64  ; WCHAR lfFaceName[LF_FACESIZE]     28
    }
    /**
     * @description - A wrapper around the LOGFONT structure.
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/dimm/ns-dimm-logfontw}
     * @class
     *
     * @param {Integer} [Hwnd] - The window handle to associate with the `Logfont` object. If
     * set, {@link PopupWindow_Logfont.Prototype.Call} is called, filling the structure with the values
     * associated with the window. If unset, the buffer is filled with 0.
     * @param {String} [Encoding] - The encoding used when getting and setting string values associated
     * with LOGFONT members. The default encoding used by `Logfont` objects is UTF-16 (cp1200).
     */
    __New(Hwnd?, Encoding?) {
        /**
         * A reference to the buffer object which is used as the LOGFONT structure.
         * @memberof Logfont
         * @instance
         */
        this.Buffer := Buffer(this.CbSizeInstance, 0)
        if IsSet(Encoding) {
            /**
             * The encoding to use with `StrPut` and `StrGet` when handling strings.
             * @memberof Logfont
             * @instance
             */
            this.Encoding := Encoding
        }
        if IsSet(Hwnd) {
            /**
             * The handle to the window associated with this object, if any.
             * @memberof Logfont
             * @instance
             */
            this.Hwnd := Hwnd
            this()
        }
    }
    /**
     * @description - Calls `CreateFontIndirectW` then sends WM_SETFONT to the window associated
     * with this `Logfont` object.
     * @param {Boolean} [Redraw = true] - The value to pass to the `lParam` parameter when sending
     * WM_SETFONT. If true, the control redraws itself.
     */
    Apply(Redraw := true) {
        hFontOld := SendMessage(0x0031,,, this.Hwnd) ; WM_GETFONT
        Flag := this.Handle = hFontOld
        /**
         * The handle to the font object created by this object.
         * @memberof Logfont
         * @instance
         */
        this.Handle := DllCall('CreateFontIndirectW', 'ptr', this, 'ptr')
        SendMessage(0x0030, this.Handle, Redraw, this.Hwnd) ; WM_SETFONT
        if Flag {
            DllCall('DeleteObject', 'ptr', hFontOld, 'int')
        }
    }
    /**
     * @description - Sends WM_GETFONT to the window associated with this `Logfont` object, updating
     * this object's properties with the values obtained from the window.
     * @throws {OSError} - Failed to get font object.
     */
    Call(*) {
        if !DllCall(
            'Gdi32.dll\GetObject',
            'ptr', SendMessage(0x0031,,, this.Hwnd), ; WM_GETFONT
            'int', this.Size,
            'ptr', this,
            'uint'
        ) {
            throw OSError('Failed to get font object.')
        }
    }
    __Delete() {
        if this.Handle {
            DllCall('DeleteObject', 'ptr', this.Handle)
            this.Handle := 0
        }
    }
    /**
     * Gets or sets the character set.
     * @memberof Logfont
     * @instance
     */
    CharSet {
        Get => NumGet(this, 23, 'uchar')
        Set => NumPut('uchar', Value, this, 23)
    }
    /**
     * Gets or sets the behavior when part of a character is clipped.
     * @memberof Logfont
     * @instance
     */
    ClipPrecision {
        Get => NumGet(this, 25, 'uchar')
        Set => NumPut('uchar', Value, this, 25)
    }
    /**
     * If this `Logfont` object is associated with a window, returns the dpi for the window.
     * @memberof Logfont
     * @instance
     */
    Dpi => this.Hwnd ? DllCall('GetDpiForWindow', 'Ptr', this.Hwnd, 'UInt') : ''
    /**
     * Gets or sets the escapement measured in tenths of a degree.
     * @memberof Logfont
     * @instance
     */
    Escapement {
        Get => NumGet(this, 8, 'int')
        Set => NumPut('int', Value, this, 8)
    }
    /**
     * Gets or sets the font facename.
     * @memberof Logfont
     * @instance
     */
    FaceName {
        Get => StrGet(this.ptr + 28, 32, this.Encoding)
        Set => StrPut(SubStr(Value, 1, 31), this.Ptr + 28, 32, this.Encoding)
    }
    /**
     * Gets or sets the font family.
     * @memberof Logfont
     * @instance
     */
    Family {
        Get => NumGet(this, 27, 'uchar') & 0xF0
        Set => NumPut('uchar', (this.Family & 0x0F) | (Value & 0xF0), this, 27)
    }
    /**
     * Gets or sets the font size. "FontSize" requires that the `Logfont` object is associated
     * with a window handle because it needs a dpi value to work with.
     * @memberof Logfont
     * @instance
     */
    FontSize {
        Get => this.Hwnd ? Round(this.Height * -72 / this.Dpi, 2) : ''
        Set => this.Height := Round(Value * this.Dpi / -72)
    }
    /**
     * Gets or sets the font height.
     * @memberof Logfont
     * @instance
     */
    Height {
        Get => NumGet(this, 0, 'int')
        Set => NumPut('int', Value, this, 0)
    }
    /**
     * Gets or sets the italic flag.
     * @memberof Logfont
     * @instance
     */
    Italic {
        Get => NumGet(this, 20, 'uchar')
        Set => NumPut('uchar', Value ? 1 : 0, this, 20)
    }
    /**
     * Gets or sets the orientation measured in tenths of degrees.
     * @memberof Logfont
     * @instance
     */
    Orientation {
        Get => NumGet(this, 12, 'int')
        Set => NumPut('int', Value, this, 12)
    }
    /**
     * Gets or sets the behavior when multiple fonts with the same name exist on the system.
     * @memberof Logfont
     * @instance
     */
    OutPrecision {
        Get => NumGet(this, 24, 'uchar')
        Set => NumPut('uchar', Value, this, 24)
    }
    /**
     * Gets or sets the pitch.
     * @memberof Logfont
     * @instance
     */
    Pitch {
        Get => NumGet(this, 27, 'uchar') & 0x0F
        Set => NumPut('uchar', (this.Pitch & 0xF0) | (Value & 0x0F), this, 27)
    }
    /**
     * Returns the pointer to the buffer.
     * @memberof Logfont
     * @instance
     */
    Ptr => this.Buffer.Ptr
    /**
     * Gets or sets the quality flag.
     * @memberof Logfont
     * @instance
     */
    Quality {
        Get => NumGet(this, 26, 'uchar')
        Set => NumPut('uchar', Value, this, 26)
    }
    /**
     * Returns the buffer's size in bytes.
     * @memberof Logfont
     * @instance
     */
    Size => this.Buffer.Size
    /**
     * Gets or sets the strikeout flag.
     * @memberof Logfont
     * @instance
     */
    StrikeOut {
        Get => NumGet(this, 22, 'uchar')
        Set => NumPut('uchar', Value ? 1 : 0, this, 22)
    }
    /**
     * Gets or sets the underline flag.
     * @memberof Logfont
     * @instance
     */
    Underline {
        Get => NumGet(this, 21, 'uchar')
        Set => NumPut('uchar', Value ? 1 : 0, this, 21)
    }
    /**
     * Gets or sets the weight flag.
     * @memberof Logfont
     * @instance
     */
    Weight {
        Get => NumGet(this, 16, 'int')
        Set => NumPut('int', Value, this, 16)
    }
    /**
     * Gets or sets the width.
     * @memberof Logfont
     * @instance
     */
    Width {
        Get => NumGet(this, 4, 'int')
        Set => NumPut('int', Value, this, 4)
    }
}

/**
 * @description - Calculates the optimal position to move one rectangle adjacent to another while
 * ensuring that the `Subject` rectangle stays within the monitor's work area. The properties
 * { L, T, R, B } of `Subject` are updated with the new values.
 *
 * @example
 * ; Assume I have Edge and VLC open
 * rcSub := WinRect(WinGetId("ahk_exe msedge.exe"))
 * rcTar := WinRect(WinGetId("ahk_exe vlc.exe"))
 * rcSub.MoveAdjacent(rcTar)
 * rcSub.Apply()
 * @
 *
 * @param {*} Subject - The object representing the rectangle that will be moved. This can be an
 * instance of `Rect` or any class that inherits from `Rect`, or any object with properties
 * { L, T, R, B }. Those four property values will be updated with the result of this function call.
 *
 * @param {*} [Target] - The object representing the rectangle that will be used as reference. This
 * can be an instance of `Rect` or any class that inherits from `Rect`, or any object with properties
 * { L, T, R, B }. If unset, the mouse's current position relative to the screen is used. To use
 * a point instead of a rectangle, set the properties "L" and "R" equivalent to one another, and
 * "T" and "B" equivalent to one another.
 *
 * @param {*} [ContainerRect] - If set, `ContainerRect` defines the boundaries which restrict
 * the area that the window is permitted to be moved within. The object must have poperties
 * { L, T, R, B } to be valid. If unset, the work area of the monitor with the greatest area of
 * intersection with `Target` is used.
 *
 * @param {String} [Dimension = "X"] - Either "X" or "Y", specifying if the window is to be moved
 * adjacent to `Target` on either the X or Y axis. If "X", `Subject` is moved to the left or right
 * of `Target`, and `Subject`'s vertical center is aligned with `Target`'s vertical center. If "Y",
 * `Subject` is moved to the top or bottom of `Target`, and `Subject`'s horizontal center is aligned
 * with `Target`'s horizontal center.
 *
 * @param {String} [Prefer = ""] - A character indicating a preferred side. If `Prefer` is an
 * empty string, the function will move the window to the side the has the greatest amount of
 * space between the monitor's border and `Target`. If `Prefer` is any of the following values,
 * the window will be moved to that side unless doing so would cause the the window to extend
 * outside of the monitor's work area.
 * - "L" - Prefers the left side.
 * - "T" - Prefers the top side.
 * - "R" - Prefers the right side.
 * - "B" - Prefes the bottom.
 *
 * @param {Number} [Padding = 0] - The amount of padding to leave between `Subject` and `Target`.
 *
 * @param {Integer} [InsufficientSpaceAction = 0] - Determines the action taken if there is
 * insufficient space to move the window adjacent to `Target` while also keeping the window
 * entirely within the monitor's work area. The function will always sacrifice some of the padding
 * if it will allow the window to stay within the monitor's work area. If the space is still
 * insufficient, the action can be one of the following:
 * - 0 : The function will not move the window.
 * - 1 : The function will move the window, allowing the window's area to extend into a non-visible
 *   region of the monitor.
 * - 2 : The function will move the window, keeping the window's area within the monitor's work
 *   area by allowing the window to overlap with `Target`.
 *
 * @returns {Integer} - If the insufficient space action was invoked, returns 1. Else, returns 0.
 */
PopupWindow_MoveAdjacent(Subject, Target?, ContainerRect?, Dimension := 'X', Prefer := '', Padding := 0, InsufficientSpaceAction := 0) {
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
    subL := Subject.L
    subT := Subject.T
    subR := Subject.R
    subB := Subject.B
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
            X := _Proc(subW, subL, subR, tarW, tarL, tarR, monW, monL, monR, Prefer = 'L' ? 1 : Prefer = 'R' ? -1 : 0)
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
            Y := _Proc(subH, subT, subB, tarH, tarT, tarB, monH, monT, monB, Prefer = 'T' ? 1 : Prefer = 'B' ? -1 : 0)
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
    Subject.L := X
    Subject.T := Y
    Subject.R := X + subW
    Subject.B := Y + subH

    return Result

    _Proc(SubLen, SubMainSide, SubAltSide, TarLen, TarMainSide, TarAltSide, MonLen, MonMainSide, MonAltSide, Prefer) {
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
            return TypeError('Invalid type passed to ``' name '``.', -2)
        } else {
            return ValueError('Unexpected value passed to ``' name '``.', -2, Value)
        }
    }
}

class PopupWindow_Rect extends Buffer {
    static __New() {
        this.DeleteProp('__New')
        proto := this.Prototype
        proto.offset_l := 0
        proto.offset_t := 4
        proto.offset_r := 8
        proto.offset_b := 12
    }
    __New(L?, T?, R?, B?) {
        this.Size := 16
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
    ToClient(hwndParent) {
        if !DllCall('ScreenToClient', 'ptr', hwndParent, 'ptr', this, 'int') {
            throw OSError()
        }
        if !DllCall('ScreenToClient', 'ptr', hwndParent, 'ptr', this.Ptr + 8, 'int') {
            throw OSError()
        }
    }
    ToScreen(hwndParent) {
        if !DllCall('ClientToScreen', 'ptr', hwndParent, 'ptr', this, 'int') {
            throw OSError()
        }
        if !DllCall('ClientToScreen', 'ptr', hwndParent, 'ptr', this.Ptr + 8, 'int') {
            throw OSError()
        }
    }
    L {
        Get => NumGet(this, this.offset_l, 'int')
        Set => NumPut('int', Value, this, this.offset_l)
    }
    T {
        Get => NumGet(this, this.offset_t, 'int')
        Set => NumPut('int', Value, this, this.offset_t)
    }
    R {
        Get => NumGet(this, this.offset_r, 'int')
        Set => NumPut('int', Value, this, this.offset_r)
    }
    B {
        Get => NumGet(this, this.offset_b, 'int')
        Set => NumPut('int', Value, this, this.offset_b)
    }
    X {
        Get => NumGet(this, this.offset_l, 'int')
        Set => NumPut('int', Value, this, this.offset_l)
    }
    Y {
        Get => NumGet(this, this.offset_t, 'int')
        Set => NumPut('int', Value, this, this.offset_t)
    }
    W {
        Get => NumGet(this, 8, 'int') - NumGet(this, 0, 'int')
        Set => NumPut('int', NumGet(this, this.offset_l, 'int') + Value, this, this.offset_r)
    }
    H {
        Get => NumGet(this, 12, 'int') - NumGet(this, 4, 'int')
        Set => NumPut('int', NumGet(this, this.offset_t, 'int') + Value, this, this.offset_b)
    }
}
