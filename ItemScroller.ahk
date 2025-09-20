/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/ItemScroller.ahk
    Author: Nich-Cebolla
    License: MIT
*/

/**
 * @classdesc - This adds a content scroller to a Gui window.
 *
 * See file "test-files\test-ItemScroller.ahk" for an interactive example. The test code itself
 * probably isn't very easy to follow, but the gui window shows what it looks like and allows you
 * to adjust the various properties to see the effect.
 *
 * There's 6 elements included, each set to a property on the instance object:
 * - `ItemScrollerObj.CtrlPrevious` - Back button
 * - `ItemScrollerObj.CtrlIndex` - An edit control that shows / changes the current item index
 * - `ItemScrollerObj.CtrlOf` - A text control that says "Of"
 * - `ItemScrollerObj.CtrlTotal` - A text control that displays the number of items in the
 * container array
 * - `ItemScrollerObj.CtrlJump` - Jump button - when clicked, the current item index is changed to
 * whatever number is in the edit control
 * - `ItemScrollerObj.CtrlNext` - Next button
 *
 * The gui passed to `GuiObj` has a value property "ItemScroller" added with a value of the
 * `ItemScroller` instance.
 *
 * ### Orientation
 *
 * The `Orientation` parameter can be defined in three ways.
 * - "H" for horizontal orientation. The order is: Back, Edit, Of, Total, Jump, Next
 * - "V" for vertical orientation. The order is the same as horizontal.
 * - Diagram: You can customize the relative position of the controls by creating a string diagram.
 * See the documentation for {@link ItemScroller.Diagram} for details. The names of the controls are
 * customizable, but the defaults are:
 *
 * BtnPrevious EdtIndex TxtOf TxtTotal BtnJump BtnNext
 *
 * If you use the option "CtrlNameSuffix" don't forget to include that with the names.
 * The return object from `ItemScroller.Diagram` is set to the property `ItemScrollerObj.Diagram`.
 */
class ItemScroller {

    /**
     * @description - Centers a list of windows horizontally with respect to one another, splitting
     * the difference between them. The center of each window will be the midpoint between the least
     * and greatest X coordinates of the windows.
     * @param {Gui.Control[]} List - An array of controls to be centered. This function assumes there
     * are no unset indices.
     */
    static CenterHList(List) {
        if !(hDwp := DllCall('BeginDeferWindowPos', 'int', List.Length, 'ptr')) {
            throw Error('``BeginDeferWindowPos`` failed.', -1)
        }
        List[-1].GetPos(&L, &Y, &W)
        Params := [{ Y: Y, M: W / 2, Hwnd: List[-1].Hwnd }]
        Params.Capacity := List.Length
        R := L + W
        loop List.Length - 1 {
            List[A_Index].GetPos(&X, &Y, &W)
            Params.Push({ Y: Y, M: W / 2, Hwnd: List[A_Index].Hwnd })
            if X < L
                L := X
            if X + W > R
                R := X + W
        }
        Center := (R - L) / 2 + L
        for ps in Params {
            if !(hDwp := DllCall('DeferWindowPos'
                , 'ptr', hDwp
                , 'ptr', ps.Hwnd
                , 'ptr', 0
                , 'int', Center - ps.M
                , 'int', ps.Y
                , 'int', 0
                , 'int', 0
                , 'uint', 0x0001 | 0x0004 | 0x0010 ; SWP_NOSIZE | SWP_NOZORDER | SWP_NOACTIVATE
                , 'ptr'
            )) {
                throw Error('``DeferWindowPos`` failed.', -1)
            }
        }
        if !DllCall('EndDeferWindowPos', 'ptr', hDwp, 'ptr') {
            throw Error('``EndDeferWindowPos`` failed.', -1)
        }
        return
    }

    /**
     * @description - Centers a list of windows vertically with respect to one another, splitting
     * the difference between them. The center of each window will be the midpoint between the least
     * and greatest Y coordinates of the windows.
     * @param {Gui.Control[]} List - An array of windows to be centered. This function assumes there are
     * no unset indices.
     */
    static CenterVList(List) {
        if !(hDwp := DllCall('BeginDeferWindowPos', 'int', List.Length, 'ptr')) {
            throw Error('``BeginDeferWindowPos`` failed.', -1)
        }
        List[-1].GetPos(&X, &T, , &H)
        Params := [{ X: X, M: H / 2, Hwnd: List[-1].Hwnd }]
        Params.Capacity := List.Length
        B := T + H
        loop List.Length - 1 {
            List[A_Index].GetPos(&X, &Y, , &H)
            Params.Push({ X: X, M: H / 2, Hwnd: List[A_Index].Hwnd })
            if Y < T
                T := Y
            if Y + H > B
                B := Y + H
        }
        Center := (B - T) / 2 + T
        for ps in Params {
            if !(hDwp := DllCall('DeferWindowPos'
                , 'ptr', hDwp
                , 'ptr', ps.Hwnd
                , 'ptr', 0
                , 'int', ps.X
                , 'int', Center - ps.M
                , 'int', 0
                , 'int', 0
                , 'uint', 0x0001 | 0x0004 | 0x0010 ; SWP_NOSIZE | SWP_NOZORDER | SWP_NOACTIVATE
                , 'ptr'
            )) {
                throw Error('``DeferWindowPos`` failed.', -1)
            }
        }
        if !DllCall('EndDeferWindowPos', 'ptr', hDwp, 'ptr') {
            throw Error('``EndDeferWindowPos`` failed.', -1)
        }
        return
    }

    /**
     * @description - Arranges controls using a string diagram.
     * - Rows are separated by newline characters.
     * - Columns are separated by spaces or tabs.
     *
     * - Use controls' names to represent their relative position.
     *   - If a control's name contains spaces or tabs, or if a control's name is completely numeric,
     * enclose the name in double quotes.
     *   - If a control's name contains carriage returns, line feeds, double quotes, or a backslash,
     * escape them with a backslash (e.g. \r \n \" \\).
     *   - If the names of the controls in the `Gui` object's collection are long or otherwise cause
     * arranging them by name to be problematic or hard to read, `Align.DiagramFromSymbols` might be
     * a better alternative. {@link https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/Align.ahk}.
     *
     * - By default, the distance between the controls will be the value of `PaddingX` and `PaddingY`
     * for their respective dimensions.
     *   - You can add additional space in-between controls along the X axis by including a number
     * that represents the number of pixels to add to the padding.
     *   - You can add additional space in-between rows of controls by including a single number
     * in-between two diagram rows.
     *
     * In the below example, the top-left coordinates of `BtnGo` are (60, 100). The distance between
     * the bottom of `EdtInput` and the top of `LVData` is `105`.
     * @example
     *  Diagram := '
     *  (
     *     10 BtnGo 10 BtnExit
     *     EdtInput
     *     5
     *     30 LVData
     *  )'
     *  ; Assume `MyGui` is already created
     *  ItemScroller.Diagram(MyGui, Diagram, 50, 100)
     * @
     * @param {Gui} GuiObj - The `Gui` object that contains the controls to be arranged.
     * @param {String} Diagram - The string diagram that describes the arrangement of the controls.
     * @param {Number} [StartX] - The X coordinate used for the beginning of each row. If unset,
     * the X coordinate of the first control in the first row will be used.
     * @param {Number} [StartY] - The Y coordinate used for the controls in the top row. If unset,
     * the Y coordinate of the first control in the first row will be used.
     * @param {Number} [PaddingX] - The amount of padding to leave between controls on the X-axis.
     * If unset, the value of `GuiObj.MarginX` will be used.
     * @param {Number} [PaddingY] - The amount of padding to leave between controls on the Y-axis.
     * If unset, the value of `GuiObj.MarginY` will be used.
     * @return {Object} - An object with the following properties:
     * - **Left**: The leftmost X coordinate of the arranged controls.
     * - **Top**: The topmost Y coordinate of the arranged controls.
     * - **Right**: The rightmost X coordinate of the arranged controls.
     * - **Bottom**: The bottommost Y coordinate of the arranged controls.
     * - **Rows**: An array of objects representing each row in the diagram. Each object has the following properties:
     *   - **Left**: The leftmost X coordinate of the row.
     *   - **Top**: The topmost Y coordinate of the row.
     *   - **Right**: The rightmost X coordinate of the row.
     *   - **Bottom**: The bottommost Y coordinate of the row.
     *   - **Controls**: An array of controls in the row.
     * @throws {ValueError} - If the diagram string is invalid.
     */
    static Diagram(GuiObj, Diagram, StartX?, StartY?, PaddingX?, PaddingY?) {
        rci := 0xFFFD ; Replacment character
        ch := Chr(rci)
        while InStr(Diagram, ch) {
            ch := Chr(--rci)
        }
        if InStr(Diagram, '"') {
            Names := Map()
            Index := 0
            Pos := 1
            loop {
                if !RegExMatch(Diagram, '(?<=\s|^)"(?<text>.*?)(?<!\\)(?:\\\\)*+"', &Match, Pos) {
                    break
                }
                Pos := Match.Pos
                Names.Set(ch (++Index) ch, Match)
                Diagram := StrReplace(Diagram, Match[0], ch Index ch)
            }
        }
        Rows := StrSplit(RegExReplace(RegExReplace(Trim(Diagram, '`s`t`r`n'), '\R+', '`n'), '[`s`t]+', '`s'), '`n')
        loop Rows.Length {
            Rows[A_Index] := StrSplit(Trim(Rows[A_Index], '`s'), '`s')
        }
        if !IsSet(StartX) || !IsSet(StartY) {
            for Row in Rows {
                i := A_Index
                for Value in Row {
                    k := A_Index
                    if !IsNumber(Value) {
                        Name := Value
                        break 2
                    }
                }
            }
            if !IsSet(Name) {
                throw ValueError('Invalid diagram string input.', -1)
            }
            if i > 1 {
                throw ValueError('The first row in the diagram cannot contain only numbers.', -1)
            }
            _ProcValue(&Name)
            GuiObj[Name].GetPos(&cx, &cy)
            if !IsSet(StartX) {
                if k > 1 {
                    throw ValueError('The input diagram options does not include a ``StartX`` value,'
                    ' and the diagram string includes leading numbers on the top row, which is invalid.', -1)
                }
                StartX := cx
            }
            if !IsSet(StartY) {
                StartY := cy
            }
        }
        if !IsSet(PaddingX) {
            PaddingX := GuiObj.MarginX
        }
        if !IsSet(PaddingY) {
            PaddingY := GuiObj.MarginY
        }
        Output := { Left: X := StartX, Top: Y := StartY, Right: 0, Bottom: 0, Rows: _rows := [] }
        Right := 0
        for Row in Rows {
            if IsNumber(Row[1]) && Row.Length == 1 {
                Y += Row[1]
                continue
            }
            X := StartX
            while IsNumber(Row[1]) {
                X += Row.RemoveAt(1)
                if !Row.Length {
                    throw ValueError('It is invalid for a row to contain only numbers if the row contains'
                    ' more than one number.', -1)
                }
            }
            _rows.Push(row_info := { Left: X, Top: Y, Right: 0, Bottom: 0, Controls: [] })
            Height := 0
            for Value in Row {
                if IsNumber(Value) {
                    X += Value
                } else {
                    _ProcValue(&Value)
                    Ctrl := GuiObj[Value]
                    Ctrl.Move(X, Y)
                    Ctrl.GetPos(&ctrlx, , &ctrlw, &ctrlh)
                    X += ctrlw + PaddingX
                    Height := Max(Height, ctrlh)
                    row_info.Controls.Push(Ctrl)
                }
            }
            Right := Max(row_info.Right := ctrlx + ctrlw, Right)
            row_info.Bottom := row_info.Top + Height
            Y += Height + PaddingY
        }
        Output.Right := Right
        Output.Bottom := row_info.Bottom

        return Output

        _ProcValue(&Value) {
            if InStr(Value, ch) {
                Value := Names.Get(Value)['text']
            }
            if InStr(Value, '\') {
                Value := StrReplace(StrReplace(StrReplace(StrReplace(Value, '\\', '\')
                    , '\r', '`r'), '\n', '`n'), '\"', '"')
            }
        }
    }

    /**
     * Adds controls to a gui that can be used to scroll through items or pages using a caller-defined
     * callback function.
     * @class
     * @param {Gui} GuiObj - The `Gui` to which the controls will be added.
     * @param {Integer} Pages - The number of pages to be represented by the scroller.
     * @param {*} Callback - A function or callable object that will be called whenever the user
     * clicks "Back", "Next", or "Jump". The function will receive:
     * 1. The new index value.
     * 2. The `ItemScroller` object.
     * @param {Object} [Options] - An object with options as property : value pairs.
     * Commonly used options are `StartX` and `StartY`.
     * @see {@link ItemScroller.Options}
     */
    __New(GuiObj, Pages, Callback, Options?) {
        local buttonFontOpt := buttonFontFamily := textFontOpt := textFontFamily := editFontOpt := editFontFamily :=
        textBackgroundColor := editBackgroundColor := ''
        Options := this.Options := ItemScroller.Options(Options ?? unset)
        this.GuiHwnd := GuiObj.Hwnd
        this.Index := 0
        this.Callback := Callback
        this.__Item := Map()
        this.CallbackClear := options.CallbackClear
        List := this.List := []
        List.Length := ObjOwnPropCount(Options.Controls)
        suffix := Options.CtrlNameSuffix
        paddingX := Options.PaddingX
        paddingY := Options.PaddingY
        GreatestW := 0
        for str in [ 'button', 'text', 'edit' ] {
            %str%FontOpt := Options.%str%FontOpt || Options.AllFontOpt
            %str%FontFamily := Options.%str%FontFamily || Options.AllFontFamily
            if str != 'button' {
                %str%BackgroundColor := Options.%str%BackgroundColor || Options.AllBackgroundColor
            }
        }
        for Name, Obj in Options.Controls.OwnProps() {
            if name = 'Clear' && !Options.CallbackClear {
                continue
            }
            ; Set the font first so it is reflected in the width.
            GuiObj.SetFont()
            switch Obj.Type, 0 {
                case 'Button':
                    if buttonFontOpt {
                        GuiObj.SetFont(buttonFontOpt)
                    }
                    _SetFontFamily(buttonFontFamily)
                case 'Edit':
                    if editFontOpt {
                        GuiObj.SetFont(editFontOpt)
                    }
                    _SetFontFamily(editFontFamily)
                case 'Text':
                    if textFontOpt {
                        GuiObj.SetFont(textFontOpt)
                    }
                    _SetFontFamily(textFontFamily)
            }
            this.Ctrl%Name% := List[Obj.Index] := GuiObj.Add(
                Obj.Type
              , 'x10 y10 ' (Obj.Opt ? _GetParam(Obj, 'Opt') : '')
              , Obj.Text ? _GetParam(Obj, 'Text') : ''
            )
            List[Obj.Index].Name := Obj.Name suffix
            List[Obj.Index].Options := Obj
            if Obj.Type == 'Button' {
                List[Obj.Index].GetPos(, , &cw, &ch)
                if cw > GreatestW {
                    GreatestW := cw
                }
                List[Obj.Index].OnEvent('Click', HClickButton%Name%)
            }
        }
        this.UpdatePages(Pages)
        this.CtrlIndex.Move(, , Options.EditWidth)
        if Options.NormalizeButtonWidths {
            for ctrl in List {
                if ctrl.Type == 'Button' {
                    ctrl.Move(, , GreatestW)
                }
            }
        }
        if StrLen(editBackgroundColor) {
            this.CtrlIndex.Opt('Background' editBackgroundColor)
        }
        if StrLen(textBackgroundColor) {
            this.CtrlOf.Opt('Background' textBackgroundColor)
            this.CtrlTotal.Opt('Background' textBackgroundColor)
        }
        this.SetOrientation()
        if !GuiObj.HasOwnProp('ItemScroller') {
            GuiObj.DefineProp('ItemScroller', { Get: ItemScroller_PropertyAccessorGet, Set: ItemScroller_PropertyAccessorSet })
            GuiObj.DefineProp('__ItemScroller', { Value: Map() })
        }
        i := 1
        while GuiObj.__ItemScroller.Has(i) {
            ++i
        }
        GuiObj.__ItemScroller.Set(i, this)
        this.__Key := i

        return

        HChangeEditIndex(Ctrl, *) {
            Ctrl.Text := RegExReplace(Ctrl.Text, '[^\d-]', '', &ReplaceCount)
            ControlSend('{End}', Ctrl)
        }

        HClickButtonClear(Ctrl, *) {
            Ctrl.Gui.__ItemScroller.Get(this.__Key).CallbackClear.Call(this)
        }

        HClickButtonPrevious(Ctrl, *) {
            Ctrl.Gui.__ItemScroller.Get(this.__Key).IncIndex(-1)
        }

        HClickButtonNext(Ctrl, *) {
            Ctrl.Gui.__ItemScroller.Get(this.__Key).IncIndex(1)
        }

        HClickButtonJump(Ctrl, *) {
            Ctrl.Gui.__ItemScroller.Get(this.__Key).SetIndex(Ctrl.Gui.__ItemScroller.Get(this.__Key).CtrlIndex.Text)
        }

        _GetParam(Obj, Prop) {
            if Obj.%Prop% is Func {
                fn := Obj.%Prop%
                return fn(Obj, List, GuiObj, this)
            }
            return Obj.%Prop%
        }
        _SetFontFamily(Options) {
            for s in StrSplit(Options, ',') {
                if s {
                    GuiObj.SetFont(, s)
                }
            }
        }
    }

    Dispose() {
        if this.HasOwnProp('GuiHwnd') {
            G := this.Gui
            if G.HasOwnProp('ItemScroller') {
                G.DeleteProp('ItemScroller')
            }
            this.DeleteProp('GuiHwnd')
        }
        list := []
        list.Capacity := ObjOwnPropCount(this)
        for prop, val in this.OwnProps() {
            if IsObject(val) {
                list.Push(prop)
            }
        }
        for prop in list {
            this.DeleteProp(prop)
        }
    }

    IncIndex(N) {
        if !this.Pages {
            return 1
        }
        this.SetIndex(this.Index + N)
    }

    /**
     * @param {String} Str - The string to measure. Multi-line strings are not valid.
     * @param {Gui.Control} Ctrl - The control to use for the device context. If unset, "CtrlTotal"
     * is used.
     * @param {VarRef} [OutHeight] - A variable that will receive the width of the string in pixels.
     * @param {VarRef} [OutHeight] - A variable that will receive the height of the string in pixels.
     */
    MeasureText(Str, Ctrl?, &OutWidth?, &OutHeight?) {
        buf := Buffer(StrPut(Str, 'UTF-16'))
        StrPut(str, buf, 'UTF-16')
        sz := Buffer(8)
        context := ItemScrollerSelectFontIntoDc(IsSet(Ctrl) ? Ctrl.Hwnd : this.CtrlTotal.Hwnd)
        if DllCall(
            'Gdi32.dll\GetTextExtentPoint32'
          , 'Ptr', context.Hdc
          , 'Ptr', buf
          , 'Int', StrLen(str)
          , 'Ptr', sz
          , 'Int'
        ) {
            context()
            OutHeight := NumGet(sz, 4, 'int')
            OutWidth := NumGet(sz, 0, 'int')
        } else {
            context()
            throw OSError()
        }
    }

    /**
     * Adjusts a control's width and height as a function of the dimensions of its text content. Use
     * this to adjust a control's dimensions after updating the font size / font name. You might
     * want to call {@link ItemScroller.Prototype.MeasureText} before and after changing the font
     * size, so you can use the ratio to multiply by the width and height to get evenly scaled
     * dimensions.
     * @param {String} Ctrl - The control to measure. The value returned by the control's "Text"
     * property is measured, using the control as the device context. The control's width and height
     * are updated using the text's dimensions to determine the width and height
     * @param {Integer} [WidthPadding = 0] - The number of pixels to add to the control's width.
     * @param {Integer} [HeightPadding = 0] - The number of pixels to add to the control's height.
     * @param {VarRef} [OutWidth] - A variable that will receive the control's new width.
     * @param {VarRef} [OutHeight] - A variable that will receive the control's new height.
     */
    ScaleControlText(Ctrl, FontOpt?, FontName?, WidthPadding := 0, HeightPadding := 0, &OutWidth?, &OutHeight?) {
        this.MeasureText(Ctrl.Text, Ctrl, &w1, &h1)
        Ctrl.SetFont(FontOpt ?? unset, FontName ?? unset)
        this.MeasureText(Ctrl.Text, Ctrl, &w2, &h2)
        Ctrl.GetPos(, , &w, &h)
        OutWidth := w * w2 / w1 + WidthPadding
        OutHeight := h * h2 / h1 + HeightPadding
        Ctrl.Move(, , OutWidth, OutHeight)
    }

    SetIndex(Value) {
        if !this.Pages {
            return 1
        }
        Value := Number(Value)
        if (Diff := Value - this.Pages) > 0 {
            this.Index := Diff
        } else if Value < 0 {
            this.Index := this.Pages + Value + 1
        } else if Value == 0 {
            this.Index := this.Pages
        } else if Value {
            this.Index := Value
        }
        this.CtrlIndex.Text := this.Index
        return this.Callback.Call(this.Index, this)
    }

    SetOrientation(Orientation?, StartX?, StartY?, PaddingX?, PaddingY?) {
        options := this.Options
        if IsSet(StartX) {
            options.StartX := StartX
        } else {
            StartX := options.StartX
        }
        if IsSet(StartY) {
            options.StartY := StartY
        } else {
            StartY := options.StartY
        }
        if IsSet(PaddingX) {
            options.PaddingX := PaddingX
        } else {
            PaddingX := options.PaddingX
        }
        if IsSet(PaddingY) {
            options.PaddingY := PaddingY
        } else {
            PaddingY := options.PaddingY
        }
        if IsSet(Orientation) {
            options.Orientation := Orientation
        } else {
            orientation := options.Orientation
        }
        if options.ButtonWidth {
            this.CtrlPrevious.Move(, , options.ButtonWidth)
            this.CtrlJump.Move(, , options.ButtonWidth)
            this.CtrlNext.Move(, , options.ButtonWidth)
        }
        if options.ButtonHeight {
            this.CtrlPrevious.Move(, , , options.ButtonHeight)
            this.CtrlJump.Move(, , , options.ButtonHeight)
            this.CtrlNext.Move(, , , options.ButtonHeight)
        }
        if options.EditWidth {
            this.CtrlIndex.Move(, , options.EditWidth)
        }
        if options.EditHeight {
            this.CtrlIndex.Move(, , , options.EditHeight)
        }
        if options.TextOfWidth {
            this.CtrlOf.Move(, , options.TextOfWidth)
        }
        if options.TextOfHeight {
            this.CtrlOf.Move(, , , options.TextOfHeight)
        }
        if options.TextTotalWidth {
            this.CtrlTotal.Move(, , options.TextTotalWidth)
        }
        if options.TextTotalHeight {
            this.CtrlTotal.Move(, , , options.TextTotalHeight)
        }
        switch this.Orientation, 0 {
            case 'H':
                maxH := 0
                for ctrl in this.List {
                    ctrl.GetPos(, , , &h)
                    if h > maxH {
                        maxH := h
                    }
                }
                X := StartX
                for ctrl in this.List {
                    ctrl.GetPos(, , &w, &h)
                    if h == maxH {
                        ctrl.Move(X, StartY)
                    } else {
                        ctrl.Move(X, StartY + 0.5 * (maxH - h))
                    }
                    X += w + PaddingX
                }
            case 'V':
                maxW := 0
                for ctrl in this.List {
                    ctrl.GetPos(, , &w)
                    if w > maxW {
                        maxW := w
                    }
                }
                Y := StartY
                for ctrl in this.List {
                    ctrl.GetPos(, , &w, &h)
                    if w == maxW {
                        ctrl.Move(StartX, Y)
                    } else {
                        ctrl.Move(StartX + 0.5 * (maxW - w), Y)
                    }
                    Y += h + PaddingY
                }
            default:
                this.Diagram := ItemScroller.Diagram(this.Gui, orientation, StartX, StartY, PaddingX, PaddingY)
                for row in this.Diagram.Rows {
                    ItemScroller.CenterVList(Row.Controls)
                }

        }
    }

    SetReferenceData(values*) {
        this.__Item.Set(values*)
    }

    UpdatePages(Pages?) {
        if IsSet(Pages) {
            this.__Pages := Pages
            this.CtrlTotal.Text := Pages
        }
        if this.CtrlIndex.Text > this.__Pages {
            this.CtrlIndex.Text := this.__Pages
        }
        this.CtrlTotal.Text := this.__Pages
        this.MeasureText(this.__Pages, , &w, &h)
        if !this.Options.TextTotalWidth {
            this.CtrlTotal.Move(, , w)
        }
        if !this.Options.TextTotalHeight {
            this.CtrlTotal.Move(, , , h)
        }
        this.SetOrientation()
    }

    __Enum(VarCount := 2) {
        list := [
            this.CtrlPrevious
          , this.CtrlIndex
          , this.CtrlOf
          , this.CtrlTotal
          , this.CtrlJump
          , this.CtrlNext
          , this.CtrlClear
        ]
        i := 0
        if VarCount = 1 {
            return _Enum1
        } else if VarCount = 2 {
            return _Enum2
        } else {
            throw ValueError('Invalid ``VarCount``.', -1, VarCount)
        }

        _Enum1(&ctrl) {
            if ++i <= list.Length {
                ctrl := list[i]
                return 1
            }
            return 0
        }
        _Enum2(&name, &ctrl) {
            if ++i <= list.Length {
                ctrl := list[i]
                name := ctrl.Name
                return 1
            }
            return 0
        }
    }

    Gui => GuiFromHwnd(this.GuiHwnd)

    Orientation {
        Get => this.Options.Orientation
        Set => this.SetOrientation(Value)
    }

    PaddingX {
        Get => this.Options.PaddingX
        Set => this.SetOrientation(, , , Value)
    }

    PaddingY {
        Get => this.Options.PaddingY
        Set => this.SetOrientation(, , , , Value)
    }

    Pages {
        Get => this.__Pages
        Set => this.UpdatePages(Value)
    }

    StartX {
        Get => this.Options.StartX
        Set => this.SetOrientation(, Value)
    }

    StartY {
        Get => this.Options.StartY
        Set => this.SetOrientation(, , Value)
    }

    /**
     * @class
     * @description - Handles the input options.
     */
    class Options {
        static Default := {
            ; "All" font options will apply to all three types of controls (text, edit, button)
            ; but can be superceded by the option for a specific type.
            AllFontFamily: ''
          , AllFontOpt: ''
          , AllBackgroundColor: ''
          , ButtonFontFamily: ''
          , ButtonFontOpt: ''
          , ButtonHeight: ''
          , ButtonWidth: ''
          , CallbackClear: ''
          , CtrlNameSuffix: ''
          , EditBackgroundColor: ''
          , EditFontFamily: ''
          , EditFontOpt: ''
          , EditHeight: ''
          , EditWidth: 30
          , NormalizeButtonWidths: true
          ; Orientation can be "H" for horizontal, "V" for vertical, or it can be a diagrammatic
          ; representation of the arrangement as described in the description of this class.
          , Orientation: 'H'
          , PaddingX: 5
          , PaddingY: 5
          , StartX: 10
          , StartY: 10
          , TextBackgroundColor: ''
          , TextFontFamily: ''
          , TextFontOpt: ''
          , TextOfHeight: ''
          , TextOfWidth: ''
          , TextTotalHeight: ''
          , TextTotalWidth: ''
          , Controls: {
                ; The "Type" cannot be altered, but you can change their name, opt, text, or index.
                ; If `Opt` or `Text` are function objects, the function will be called passing
                ; these values to the function:
                ; - The control options object (not the actual Gui.Control, but the object like the
                ; ones below).
                ; - The array that is being filled with these controls
                ; - The Gui object
                ; - The ItemScroller instance object.
                ; The function should then return the string to be used for the options / text
                ; parameter. I don't recommend returning a size or position value, because this
                ; function handles that internally.
                Previous: { Name: 'BtnPrevious', Type: 'Button', Opt: '', Text: '<', Index: 1 }
              , Index: { Name: 'EdtIndex', Type: 'Edit', Opt: '', Text: '1', Index: 2 }
              , Of: { Name: 'TxtOf', Type: 'Text', Opt: '', Text: 'of', Index: 3 }
              , Total: { Name: 'TxtTotal', Type: 'Text', Opt: '', Text: '', Index: 4  }
              , Jump: { Name: 'BtnJump', Type: 'Button', Opt: '', Text: 'Jump', Index: 5 }
              , Next: { Name: 'BtnNext', Type: 'Button', Opt: '', Text: '>', Index: 6 }
              , Clear: { Name: 'BtnClear', Type: 'Button', Opt: '', Text: 'Clear', Index: 7 }
            }
        }

        /**
         * Handles processing the input options.
         * @param {Object} [Options] - The input object.
         * @return {Object}
         */
        static Call(Options?) {
            if IsSet(Options) {
                o := {}
                d := this.Default
                for prop in d.OwnProps() {
                    o.%prop% := HasProp(Options, prop) ? Options.%prop% : d.%prop%
                }
                return o
            } else {
                return this.Default.Clone()
            }
        }
    }
}


/**
 * @classdesc - Use this as a safe way to access a window's font object. This handles accessing and
 * releasing the device context and font object.
 */
class ItemScrollerSelectFontIntoDc {

    __New(Hwnd) {
        this.Hwnd := Hwnd
        if !(this.Hdc := DllCall('GetDC', 'Ptr', Hwnd, 'ptr')) {
            throw OSError()
        }
        OnError(this.Callback := ObjBindMethod(this, '__ReleaseOnError'), 1)
        if !(this.Hfont := SendMessage(0x0031, 0, 0, , Hwnd)) { ; WM_GETFONT
            throw OSError()
        }
        if !(this.OldFont := DllCall('SelectObject', 'ptr', this.Hdc, 'ptr', this.Hfont, 'ptr')) {
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
        if this.OldFont {
            if !DllCall('SelectObject', 'ptr', this.Hdc, 'ptr', this.OldFont, 'int') {
                err := OSError()
            }
            this.DeleteProp('OldFont')
        }
        if this.Hdc {
            if !DllCall('ReleaseDC', 'ptr', this.Hwnd, 'ptr', this.Hdc, 'int') {
                if IsSet(err) {
                    err.Message .= '; Another error occurred: ' OSError().Message
                }
            }
            this.DeleteProp('Hdc')
        }
        OnError(this.Callback, 0)
        return err ?? ''
    }

    __Delete() => this()

    static __New() {
        if this.Prototype.__Class == 'SelectFontIntoDc' {
            Proto := this.Prototype
            Proto.DefineProp('Hdc', { Value: '' })
            Proto.DefineProp('Hfont', { Value: '' })
            Proto.DefineProp('OldFont', { Value: '' })
        }
    }
}


ItemScroller_PropertyAccessorGet(Self, Index := 1) {
    return Self.__ItemScroller[Index]
}
ItemScroller_PropertyAccessorSet(Self, Value, Index := 1) {
    if !IsSet(Value) {
        return
    }
    Self.__ItemScroller.Set(Index, Value)
}
