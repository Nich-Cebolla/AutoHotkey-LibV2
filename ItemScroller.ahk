/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/ItemScroller.ahk
    Author: Nich-Cebolla
    License: MIT
*/

/**
 * @classdesc - This adds a content scroller to a Gui window. There's 6 elements included, each set
 * to a property on the instance object:
 * - `ItemScrollerObj.CtrlPrevious` - Back button
 * - `ItemScrollerObj.CtrlIndex` - An edit control that shows / changes the current item index
 * - `ItemScrollerObj.CtrlOf` - A text control that says "Of"
 * - `ItemScrollerObj.CtrlTotal` - A text control that displays the number of items in the
 * container array
 * - `ItemScrollerObj.CtrlJump` - Jump button - when clicked, the current item index is changed to
 * whatever number is in the edit control
 * - `ItemScrollerObj.CtrlNext` - Next button
 *
 * ### Orientation
 *
 * The `Orientation` parameter can be defined in three ways.
 * - "H" for horizontal orientation. The order is: Back, Edit, Of, Total, Jump, Next
 * - "V" for vertical orientation. The order is the same as horizontal.
 * - Diagram: You can customize the relative position of the controls by creating a string diagram.
 * See the documentation for {@link ItemScroller.Diagram} for details. The names of the controls are
 * customizable, but the defaults are: BtnPrevious, EdtIndex, TxtOf, TxtTotal, BtnJump, BtnNext. If
 * you use the option "CtrlNameSuffix" don't forget to include that with the names.
 * The return object from `ItemScroller.Diagram` is set to the property `ItemScrollerObj.Diagram`.
 */
class ItemScroller {

    static AlignH(CtrlToMove, ReferenceCtrl) {
        CtrlToMove.GetPos(&X1, &Y1, &W1)
        ReferenceCtrl.GetPos(&X2, , &W2)
        CtrlToMove.Move(X2 + W2 / 2 - W1 / 2, Y1)
    }

    static AlignV(CtrlToMove, ReferenceCtrl) {
        CtrlToMove.GetPos(&X1, &Y1, , &H1)
        ReferenceCtrl.GetPos( , &Y2, , &H2)
        CtrlToMove.Move(X1, Y2 + H2 / 2 - H1 / 2)
    }
    /**
     * Adds controls to a gui that can be used to scroll through items in an array.
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
        Options := this.Options := ItemScroller.Options(Options ?? {})
        this.DefineProp('Index', { Value: 1 })
        this.DefineProp('DisableTooltips', { Value: Options.DisableTooltips })
        this.Pages := Pages
        this.Callback := Callback
        this.__Item := Map()
        List := []
        List.Length := ObjOwnPropCount(Options.Controls)
        suffix := Options.CtrlNameSuffix
        GreatestW := 0
        for Name, Obj in Options.Controls.OwnProps() {
            ; Set the font first so it is reflected in the width.
            GuiObj.SetFont()
            switch Obj.Type, 0 {
                case 'Button':
                    if Options.BtnFontOpt {
                        GuiObj.SetFont(Options.BtnFontOpt)
                    }
                    _SetFontFamily(Options.BtnFontFamily)
                case 'Edit':
                    if Options.EditFontOpt {
                        GuiObj.SetFont(Options.EditFontOpt)
                    }
                    _SetFontFamily(Options.EditFontFamily)
                case 'Text':
                    if Options.TextFontOpt {
                        GuiObj.SetFont(Options.TextFontOpt)
                    }
                    _SetFontFamily(Options.TextFontFamily)
            }
            this.Ctrl%Name% := List[Obj.Index] := GuiObj.Add(
                Obj.Type
              , 'x10 y10 ' _GetParam(Obj, 'Opt') || unset
              , _GetParam(Obj, 'Text') || unset
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
        X := Options.StartX
        Y := Options.StartY
        ButtonHeight := ch
        if Options.Orientation = 'H' || (Options.HasOwnprop('Horizontal') && Options.Horizontal) {
            for Ctrl in List {
                Obj := Ctrl.Options
                Ctrl.DeleteProp('Options')
                if Ctrl.Type = 'Button' {
                    BtnIndex := Obj.Index
                    if Options.NormalizeButtonWidths {
                        Ctrl.Move(X, Y, GreatestW)
                        X += GreatestW + Options.PaddingX
                        continue
                    }
                }
                Ctrl.Move(X, Y)
                Ctrl.GetPos(, , &cw)
                X += cw + Options.PaddingX
            }
            for Ctrl in List {
                if Ctrl.Type !== 'Button' {
                    ItemScroller.AlignV(Ctrl, List[BtnIndex])
                }
            }
        } else if Options.Orientation = 'V' || (Options.HasOwnprop('Horizontal') && !Options.Horizontal) {
            for Ctrl in List {
                Obj := Ctrl.Options
                Ctrl.DeleteProp('Options')
                if Ctrl.Type = 'Button' {
                    BtnIndex := Obj.Index
                    if Options.NormalizeButtonWidths {
                        Ctrl.Move(X, Y, GreatestW)
                        Y += Buttonheight + Options.PaddingY
                        continue
                    }
                }
                Ctrl.Move(X, Y)
                Ctrl.GetPos(, , , &ch)
                Y += cH + Options.PaddingY
            }
            for Ctrl in List {
                if Ctrl.Type !== 'Button' {
                    ItemScroller.AlignH(Ctrl, List[BtnIndex])
                }
            }
        } else {
            for Ctrl in List {
                Obj := Ctrl.Options
                Ctrl.DeleteProp('Options')
                if Ctrl.Type = 'Button' {
                    if Options.NormalizeButtonWidths {
                        Ctrl.Move(, , GreatestW)
                        continue
                    }
                }
            }
            this.Diagram := ItemScroller.Diagram(GuiObj, Options.Orientation, Options.StartX, Options.StartY, Options.PaddingX, Options.PaddingY)
        }
        if StrLen(Options.Orientation) == 1 {
            this.Left := Options.StartX
            this.Top := Options.StartY
            GreatestX := GreatestY := 0
            for Ctrl in List {
                Ctrl.GetPos(&cx, &cy, &cw, &ch)
                if cx + cw > GreatestX {
                    GreatestX := cx + cw
                }
                if cy + ch > GreatestY {
                    GreatestY := cy + ch
                }
            }
            this.Right := GreatestX
            this.Bottom := GreatestY
        } else {
            this.Left := this.Diagram.Left
            this.Top := this.Diagram.Top
            this.Right := this.Diagram.Right
            this.Bottom := this.Diagram.bottom
        }
        if StrLen(Options.EditBackgroundColor) {
            this.CtrlIndex.Opt('Background' Options.EditBackgroundColor)
        }
        if StrLen(Options.TextBackgroundColor) {
            this.CtrlOf.Opt('Background' Options.TextBackgroundColor)
            this.CtrlTotal.Opt('Background' Options.TextBackgroundColor)
        }
        this.CtrlTotal.Text := this.Pages

        return

        HChangeEditIndex(Ctrl, *) {
            Ctrl.Text := RegExReplace(Ctrl.Text, '[^\d-]', '', &ReplaceCount)
            ControlSend('{End}', Ctrl)
        }

        HClickButtonPrevious(Ctrl, *) {
            this.IncIndex(-1)
        }

        HClickButtonNext(Ctrl, *) {
            this.IncIndex(1)
        }

        HClickButtonJump(Ctrl, *) {
            this.SetIndex(this.CtrlIndex.Text)
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

    IncIndex(N) {
        if !this.Pages {
            return 1
        }
        this.SetIndex(this.Index + N)
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

    SetReferenceData(values*) {
        this.__Item.Set(values*)
    }

    UpdateValues() {
        len := this.Pages
        if this.CtrlIndex.Text > len {
            this.CtrlIndex.Text := len
        }
        this.CtrlTotal.Text := len
    }

    /**
     * @class
     * @description - Handles the input options.
     */
    class Options {
        static Default := {
            Controls: {
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
                Previous: { Name: 'BtnPrevious', Type: 'Button', Opt: '', Text: 'Back', Index: 1 }
              , Index: { Name: 'EdtIndex', Type: 'Edit', Opt: 'w30', Text: '1', Index: 2 }
              , Of: { Name: 'TxtOf', Type: 'Text', Opt: '', Text: 'of', Index: 3 }
              , Total: { Name: 'TxtTotal', Type: 'Text', Opt: 'w30', Text: '1', Index: 4  }
              , Jump: { Name: 'BtnJump', Type: 'Button', Opt: '', Text: 'Jump', Index: 5 }
              , Next: { Name: 'BtnNext', Type: 'Button', Opt: '', Text: 'Next', Index: 6 }
            }
          , BtnFontFamily: ''
          , BtnFontOpt: ''
          , CtrlNameSuffix: ''
          , DisableTooltips: false
          , EditBackgroundColor: ''
          , EditFontFamily: ''
          , EditFontOpt: ''
          , NormalizeButtonWidths: true
          ; Orientation can be "H" for horizontal, "V" for vertical, or it can be a diagrammatic
          ; representation of the arrangement as described in the description of this class.
          , Orientation: 'H'
          , PaddingX: 10
          , PaddingY: 10
          , StartX: 10
          , StartY: 10
          , TextBackgroundColor: ''
          , TextFontFamily: ''
          , TextFontOpt: ''
        }

        /**
         * @description - Clones `ItemScroller.Options.Default` then iterates the input `Options`
         * properties, overwriting the property values on the cloned object.
         * @param {Object} [Options] - The input object.
         * @return {Object}
         */
        static Call(Options?) {
            O := this.Default.Clone()
            if IsSet(Options) {
                for prop, val in Options.OwnProps() {
                    O.%prop% := val
                }
            }
            return O
        }
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
}

