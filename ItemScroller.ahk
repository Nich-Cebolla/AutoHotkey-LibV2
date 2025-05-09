/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/ItemScroller.ahk
    Author: Nich-Cebolla
    Version: 1.0.0
    License: MIT

    Status: Core functionality has been tested and is working, but not all of the options are tested.
*/

/**
 * @class
 * @description - This adds a content scroller to a Gui window. There's 6 elements included by default:
 * - Back button
 * - An edit control that shows / changes the current item index
 * - A text control that says "Of"
 * - A text control that displayss the number of items in the container array
 * - Jump button - when clicked, the current item index is changed to whatever number is in the edit control
 * - Next button
 *
 * I attempted to write this in a way that permits a degree of customization, but its limited because
 * portions of the code expect the default control names, so you are effectively tied to the default
 * controls. While you can't change the controls' type or names, you can change the options, text,
 * and order, along with the other various options listed in the ItemScroller.Params class.
 */
class ItemScroller {

    /**
     * @class
     * @description - Handles the input params.
     */
    class Params {
        static Default := {
            Controls: {
                ; The "Name" and "Type" cannot be altered, but you can change their order or other
                ; values. If `Opt` or `Text` are function objects, the function will be called passing
                ; these values to the function:
                ; - The control params object (not the actual Gui.Control, but the object like the
                ; ones below).
                ; - The array that is being filled with these controls
                ; - The Gui object
                ; - The ItemScroller instance object.
                ; The function should then return the string to be used for the options / text
                ; parameter. I don't recommend returning a size or position value, because this
                ; function handles that internally.
                Previous: { Name: 'Back', Type: 'Button', Opt: '', Text: 'Back', Index: 1 }
              , Index: { Name: 'Index', Type: 'Edit', Opt: 'w30', Text: '1', Index: 2 }
              , TxtOf: { Name: 'TxtOf', Type: 'Text', Opt: '', Text: 'of', Index: 3 }
              , Total: { Name: 'TxtTotal', Type: 'Text', Opt: 'w30', Text: '1', Index: 4  }
              , Jump: { Name: 'Jump', Type: 'Button', Opt: '', Text: 'Jump', Index: 5 }
              , Next: { Name: 'Next', Type: 'Button', Opt: '', Text: 'Next', Index: 6 }
            }
          , Array: ''
          , StartX: 10
          , StartY: 10
          ; I wrote the code for vertical alingment (horizontal = false) but I've been procrastinating
          ; testing it, so it may not work as expected.
          , Horizontal: true
          , ButtonStep: 1
          , NormalizeButtonWidths: true
          , PaddingX: 10
          , PaddingY: 10
          , BtnFontOpt: ''
          , BtnFontFamily: ''
          , EditFontOpt: ''
          , EditFontFamily: ''
          , TextFontOpt: ''
          , TextFontFamily: ''
          , DisableTooltips: false
          , Callback: ''
        }

        /**
         * @description - Sets the base object such that the values are used in this priority order:
         * - 1: The input object.
         * - 2: The configuration object (if present).
         * - 3: The default object.
         * @param {Object} Params - The input object.
         * @return {Object} - The same input object.
         */
        static Call(Params) {
            if IsSet(ItemScrollerConfig) {
                ObjSetBase(ItemScrollerConfig, ItemScroller.Params.Default)
                ObjSetBase(Params, ItemScrollerConfig)
            } else {
                ObjSetBase(Params, ItemScroller.Params.Default)
            }
            return Params
        }
    }
    /**
     * @class -
     * Instructions:
     * Define the `Params` object with at leaast the `Array` and `Callback` properties.
     * Also commonly used params would be `StartX` and `StartY`.
     * `Array` should be the array containing the items to scroll.
     * `Callback` should be a function that is called when the scroll index is changed.
     * The first parameter is the new index, and the second is the ItemScroller object.
     */
    __New(GuiObj, Params?) {
        Params := this.Params := ItemScroller.Params(Params ?? {})
        this.DefineProp('Index', { Value: 1 })
        this.DefineProp('DisableTooltips', { Value: Params.DisableTooltips })
        if Params.Array {
            this.__Item := Params.Array
        }
        List := []
        List.Length := ObjOwnPropCount(Params.Controls)
        GreatestW := 0
        for Name, Obj in Params.Controls.OwnProps() {
            ; Set the font first so it is reflected in the width.
            switch Obj.Type, 0 {
                case 'Button':
                    if Params.BtnFontOpt || Params.BtnFontFamily {
                        GuiObj.SetFont(Params.BtnFontOpt || unset, Params.BtnFontFamily || unset)
                    }
                case 'Edit':
                    if Params.EditFontOpt || Params.EditFontFamily {
                        GuiObj.SetFont(Params.EditFontOpt || unset, Params.EditFontFamily || unset)
                    }
                case 'Text':
                    if Params.TextFontOpt || Params.TextFontFamily {
                        GuiObj.SetFont(Params.TextFontOpt || unset, Params.TextFontFamily || unset)
                    }
            }
            List[Obj.Index] := GuiObj.Add(
                Obj.Type
              , _GetParam(Obj, 'Opt') || unset
              , _GetParam(Obj, 'Text') || unset
            )
            List[Obj.Index].Name := Obj.Name
            List[Obj.Index].Params := Obj
            if Obj.Type == 'Button' {
                List[Obj.Index].GetPos(, , &cw, &ch)
                if cw > GreatestW {
                    GreatestW := cw
                }
            }
        }
        X := Params.StartX
        Y := Params.StartY
        ButtonHeight := ch
        Flag := 0
        if Params.Horizontal {
            for Ctrl in List {
                Obj := Ctrl.Params
                Ctrl.DeleteProp('Params')
                switch Ctrl.Type, 0 {
                    case 'Button':
                        BtnIndex := Obj.Index
                        Ctrl.OnEvent('Click', HClickButton%Obj.Name%)
                        if Params.NormalizeButtonWidths {
                            Ctrl.Move(X, Y, GreatestW)
                            X += GreatestW + Params.PaddingX
                            continue
                        }
                    case 'Edit':
                        this.EditCtrl := Ctrl
                        Ctrl.OnEvent('Change', HChangeEdit%Obj.Name%)
                    case 'Text':
                        if !Flag {
                            this.TxtOf := Ctrl
                            Flag := 1
                        } else {
                            this.TxtTotal := Ctrl
                        }
                }
                Ctrl.Move(X, Y)
                Ctrl.GetPos(, , &cw)
                X += cw + Params.PaddingX
            }
            for Ctrl in List {
                if Ctrl.Type !== 'Button' {
                    ItemScroller.AlignV(Ctrl, List[BtnIndex])
                }
            }
        } else {
            for Ctrl in List {
                Obj := Ctrl.Params
                Ctrl.DeleteProp('Params')
                switch Ctrl.Type, 0 {
                    case 'Button':
                        BtnIndex := Obj.Index
                        Ctrl.OnEvent('Click', HClick%Obj.Name%)
                        if Params.NormalizeButtonWidths {
                            Ctrl.Move(X, Y, GreatestW)
                            Y += Buttonheight + Params.PaddingY
                            continue
                        }
                    case 'Edit':
                        this.EditCtrl := Ctrl
                        Ctrl.OnEvent('Change', HChange%Obj.Name%)
                    case 'Text':
                        if !Flag {
                            this.TxtOf := Ctrl
                            Flag := 1
                        } else {
                            this.TxtTotal := Ctrl
                        }
                }
                Ctrl.Move(X, Y)
                Ctrl.GetPos(, , , &ch)
                Y += cH + Params.PaddingY
            }
            for Ctrl in List {
                if Ctrl.Type !== 'Button' {
                    ItemScroller.AlignH(Ctrl, List[BtnIndex])
                }
            }
        }
        this.Left := Params.StartX
        this.Top := Params.StartY
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

        return

        HChangeEditIndex(Ctrl, *) {
            Ctrl.Text := RegExReplace(Ctrl.Text, '[^\d-]', '', &ReplaceCount)
            ControlSend('{End}', Ctrl)
        }

        HClickButtonBack(Ctrl, *) {
            this.IncIndex(-1)
        }

        HClickButtonNext(Ctrl, *) {
            this.IncIndex(1)
        }

        HClickButtonJump(Ctrl, *) {
            this.SetIndex(this.EditCtrl.Text)
        }

        _GetParam(Obj, Prop) {
            if Obj.%Prop% is Func {
                fn := Obj.%Prop%
                return fn(Obj, List, GuiObj, this)
            }
            return Obj.%Prop%
        }
    }

    SetIndex(Value) {
        if !this.__Item.Length {
            return 1
        }
        Value := Number(Value)
        if (Diff := Value - this.__Item.Length) > 0 {
            this.Index := Diff
        } else if Value < 0 {
            this.Index := this.__Item.Length + Value + 1
        } else if Value == 0 {
            this.Index := this.__Item.Length
        } else if Value {
            this.Index := Value
        }
        this.EditCtrl.Text := this.Index
        this.TxtTotal.Text := this.__Item.Length
        if cb := this.Params.Callback {
            return cb(this.Index, this)
        }
    }

    IncIndex(N) {
        if !this.__Item.Length {
            return 1
        }
        this.SetIndex(this.Index + N)
    }

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
}

