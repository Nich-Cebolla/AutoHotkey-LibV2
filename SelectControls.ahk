
/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/SelectControls.ahk
    Author: Nich-Cebolla
    Version: 1.0.0
    License: MIT
*/

; https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/RectHighlight.ahk
#include RectHighlight.ahk
; https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/Align.ahk
#include Align.ahk

/**
 * @classdesc - `SelectControls` does the following:
 * - When called, creates a `SelectControls` object.
 * - For each control in the `Gui` object's window that is both visible and enabled, creates and
 * displays a checkbox near the top-left corner of the control.
 * - Spawns a window that displays an informational message explaining what the user should do.
 *   - What the user is instructed to do is to check the checkboxes for any controls that they want
 * to include in whatever the subsequent action is. This is defined by the `Callback` parameter that
 * you must set. The function is going to receive the `SelectControls` object, which is an `Array`
 * object containing references to the `Gui.Control` objects associated with the checkboxes the user
 * checked.
 *
 * That sums it up. The purpose of this function is to allow the user to select some controls to
 * be included in some action defined by you. The situation I had in mind when I wrote this is
 * aligning controls spatially, like Microsoft Office products. If that sounds useful, you should
 * pair `SelectControls` with `Align`, which I have reviewed to ensure the functions are compatible
 * with `SelectControls`. Any `Align` function that takes an array of controls should work with this.
 *
 * Additional details:
 *
 * - When the user checks a `SelectControls.Checkbox` checkbox, a colored rectangle will outline the
 * control which is associated with that checkbox so the user can have visual feedback that they
 * selected the intended control.
 * - The `SelectControls` object is reusable.
 * - The `SelectControls` object does not keep references to the controls or to the `Gui` object,
 * relying instead on `GuiFromHwnd` and `CtrlFromHwnd`, so there should not be any reference cycles.
 * - You can set the informational message to any message.
 * - See the description of the options below for more details about ways you can customize
 * `SelectControls`.
 */
class SelectControls extends Array {
    /**
     * @class
     * @param {Gui} G - The `Gui` object.
     * @param {String} EndKey - The string representation of the hotkey that the user can use to
     * submit their selection and call the callback.
     * @param {*} Callback - Any callable object, such as a `Func`, an object with a `Call` method,
     * or an object with a `__Call` method.
     * @param {Object} [Options] - An object with zero or more property : value pairs for the
     * following options:
     * @param {Integer} [Options.Capacity=100] - The approximate number of controls that will be
     * iterated by `SelectControls`. The `SelectControls` object will have a property `Checkboxes`
     * that is an array containing references to all of the `SelectControls.Checkbox` objects owned
     * by the input `Gui`. When that array is created, its initial capacity is set to `Options.Capacity`
     * to prevent resizing.
     * @param {String} [ExcludeNames=''] - A comma-delimited string of names of controls that will
     * not be included in any of the class's function calls. Those controls will not have an
     * associated checkbox for the user to press.
     * @param {String} [ExcludeTypes=''] - A comma-delimited string of names of `Gui.Control` types
     * that will not be included in any of the class's function calls. Those controls will not have
     * an associated checkbox for the user to press.
     * @param {String} [FontOpt='s11 q4'] - This option is regarding the "info window" that
     * `SelectControls` creates. The value is passed to `Gui.Prototype.SetFont` for that window.
     * @param {String} [FontFamily='Aptos,Roboto'] - This option is regarding the "info window" that
     * `SelectControls` creates. The value is a comma-delimited list of font names that will be
     * passed to `Gui.Prototype.SetFont` for that window. They are split using `StrSplit` and passed
     * in the order they are listed.
     * @param {String} [InfoWindowMessage] - The message that will be displayed in the "info window"
     * that `SelectControls` creates. This is a small window with a text control (containing this
     * message or the built-in message) and two buttons, "Submit" and "Cancel". If you set your
     * own message, I recommend including text explaining the hotkey they can use to submit the
     * controls. The default message is: "Activate the checkboxes for any controls you want to
     * include, then either press the hotkey " this.EndKey " or click the button below."
     * @param {String} [InfoWindowTitle='SelectControls'] - The title of the "info window".
     * @param {Object} [RectHighlightOpt=''] - An object with property : value pairs for zero or
     * more of the options for the `RectHighlight` class. See "RectHighlight.ahk" for those details.
     * The valid options are: { Border, Color, Duration, OffsetL, OffsetT, OffsetR, OffsetB }.
     * @returns {SelectControls}
     */
    __New(G, EndKey, Callback, Options?) {
        Options := this.Options := SelectControls.Options(Options ?? {})
        Internal := this.__Internal := {}
        this.Callback := Callback
        this.Rect := Buffer(16)
        this.EndKey := EndKey
        this.hWnd := G.hWnd
        this.ProcessControlList(G)
        this.SetInfoWindow(Options.InfoWindowMessage || unset)
        Align.MoveAdjacent(Internal.IW, G)
        this.Highlighter := RectHighlight( , Options.RectHighlightOpt ? Options.RectHighlightOpt : unset)
        this.DefineProp('HighlightToggle', { Call: this.Highlighter.GetFunc() })
        this.__Internal.IW.Show('NoActivate')
        Hotkey(EndKey, this, 'On')
        this.Active := true

        return
    }

    /**
     * @description - The `SelectControls` process has an active and inactive state, represented
     * by the value of `SelectControlsObj.Active`.
     * - When the `SelectControls` object is created, `SelectControlsObj.Active == 1`, meaning
     * the process is currently active, the checkboxes have been created and are visible,
     * the "info window" is visible, and the process is awaiting / responding to user interaction.
     * - When the user submits or cancels the process, and when the submission process completes,
     * `Active` is set to `SelectControlsObj.Active := 0`. The checkboxes are disabled and not
     * visible, and there are no active threads associated with the `SelectControls` object.
     * - Subsequent calls to `SelectControlsObj()` toggles the activity. If it's inactive, then
     * the call activates it, and when the user submits or cancels it, it also calls the same
     * function.
     *
     * The `Param` parameter is used to analyze what called the method to invoke the correct
     * procedure.
     * - If `Param` is a `Gui.Button` object
     *   - If the button's name is "Submit", then the submission procedure is called.
     *   - If the button's name is anything else, then the process is considered "cancelled", which
     * means the code takes no further action after analyzing the button's name.
     * - If `Param` is any other nonzero value, then the submission procedure is called.
     * - If `Param` is a falsy value, then the process is considered "cancelled".
     * @param {Boolean|Gui.Button} [Param=''] - A value indicating whether the process was submitted
     * or cancelled. See the function description for details.
     */
    Call(Param := '', *) {
        if this.Active {
            Hotkey(this.EndKey, this, 'Off')
            this.Active := false
            this.__Internal.IW.Hide()
            Callback := this.Callback
            if Param is Gui.Button {
                if Param.Text == 'Submit' {
                    Result := _Out()
                }
            } else if Param {
                Result := _Out()
            }
            for Chk in this.Checkboxes {
                Chk.Value := Chk.Enabled := Chk.Visible := 0
            }
            return Result ?? ''
        } else {
            this.Active := true
            this.ProcessControlList(this.Gui)
            this.SetInfoWindow(this.Options.InfoWindowMessage || unset)
            Align.MoveAdjacent(this.__Internal.IW, this.Gui)
            Hotkey(this.EndKey, this, 'On')
            this.Active := true
            this.__Internal.IW.Show('NoActivate')
        }

        _Out() {
            if IsObject(Callback) {
                return Callback(this)
            } else {
                return this.%Callback%(this)
            }
        }
    }

    /**
     * @description - Calls the object with an empty string, causing the process to be cancelled.
     */
    Cancel() {
        return this('')
    }

    /**
     * @description - Either checks or unchecks all of the `SelectControls.Checkbox` objects.
     * @param {Boolean} [Value=true] - If true, the checkboxes are checked. If false, the checkboxes
     * are unchecked.
     */
    CheckAll(Value := true) {
        for Chk in this.Checkboxes {
            if Chk.Value || !Chk.HasOwnProp('ControlhWnd') {
                continue
            }
            Chk.Value := Value
            this.Push(Chk.Control)
        }
    }

    /**
     * @description - The event handler for when `SelectControls.Checkbox` objects are checked.
     * This adds the associated control to the array, and invokes `RectHighlight` to outline the
     * selected control. If the checkbox is unchecked, the object is removed from the array.
     * @param {SelectControls.Checkbox} Chk - The control.
     */
    HClickCheckbox(Chk, *) {
        if Chk.Value {
            if !Chk.HasOwnProp('Index') {
                this.Push(Chk.Control)
                Chk.DefineProp('Index', { Value: this.Length })
            }
            this.HighlightToggle(Chk.Control)
        } else if Chk.HasOwnProp('Index') {
            this.RemoveAt(Chk.Index)
            Chk.DeleteProp('Index')
        }
    }

    /**
     * @description - `SelectControls.Prototype.GetControlList` is used internally to generate the
     * list of control references.
     * @param {Gui} G - The `Gui` object.
     */
    GetControlList(G) {
        Options := this.Options
        if Options.ExcludeNames {
            ExcludeNames := ',' Options.ExcludeNames ','
            if Options.ExcludeTypes {
                ExcludeTypes := ',' Options.ExcludeTypes ','
                Condition := (Ctrl) => InStr(ExcludeNames, ',' Ctrl.Name ',') || InStr(ExcludeTypes, ',' Ctrl.Type ',') || !Ctrl.Visible || !Ctrl.Enabled
            } else {
                Condition := (Ctrl) => InStr(ExcludeNames, ',' Ctrl.Name ',') || !Ctrl.Visible || !Ctrl.Enabled
            }
        } else if Options.ExcludeTypes {
            ExcludeTypes := ',' Options.ExcludeTypes ','
            Condition := (Ctrl) => InStr(ExcludeTypes, ',' Ctrl.Type ',') || !Ctrl.Visible || !Ctrl.Enabled
        } else {
            Condition := (Ctrl) => !Ctrl.Visible || !Ctrl.Enabled
        }
        Checkboxes := this.Checkboxes := []
        Checkboxes.Capacity := Options.Capacity
        CtrlList := []
        for Ctrl in G {
            if Type(Ctrl) == 'SelectControls.Checkbox' {
                Checkboxes.Push(Ctrl)
            } else if Condition(Ctrl) {
                continue
            } else {
                CtrlList.Push(Ctrl)
            }
        }
        return CtrlList
    }

    /**
     * @description - `SelectControls.Prototype.ProcessControlList` takes the output from
     * `SelectControls.Prototype.GetControlList` and completes the rest of the core process.
     * @param {Gui} G - The `Gui` object.
     */
    ProcessControlList(G) {
        ; The checkboxes are sorted into four quadrants to reduce processing time needed to
        ; ensure none of them overlap.
        Options := this.Options
        Internal := this.__Internal
        Proto := SelectControls.Checkbox.Prototype
        Rect := this.Rect
        CtrlList := this.GetControlList(G)
        Checkboxes := this.Checkboxes
        if Checkboxes.Length {
            GetCheckbox := _GetCheckbox1
        } else {
            Checkboxes.Push(G.Add('Checkbox'))
            ObjSetBase(Checkboxes[-1], Proto)
            GetCheckbox := _GetCheckbox2
        }
        ; Measure a checkbox.
        if Internal.HasOwnProp('chkW') {
            chkW := Internal.chkW
            chkH := Internal.chkH
        } else {
            Checkboxes[1].GetPos(, , &chkW, &chkH)
            Internal.chkW := chkW * 0.45
            Internal.chkH := chkH
        }
        tl := []
        tr := []
        br := []
        bl := []
        tl.Capacity := tr.Capacity := br.Capacity := bl.Capacity := Options.Capacity
        G.GetPos(, , &gw, &gh)
        midX := gw * 0.5
        midY := gh * 0.5
        fn := ObjBindMethod(this, 'HClickCheckbox')
        i := 0
        for Ctrl in CtrlList {
            Chk := GetCheckbox()
            Ctrl.GetPos(&x, &y)
            NumPut(
                'int', _x := x - chkW > 0 ? x - chkW : 0
              , 'int', _y := y - chkH > 0 ? y - chkH : 0
              , 'int', _x + chkW
              , 'int', _y + chkH
              , Chk.Rect
            )
            Chk.Move(_x, _y, Internal.chkW, Internal.chkH)
            Chk.DefineProp('ControlhWnd', { Value: Ctrl.hWNd })
            if _x > midX {
                if _y > midY {
                    br.Push(Chk)
                } else {
                    tr.Push(Chk)
                }
            } else if _y > midY {
                bl.Push(Chk)
            } else {
                tl.Push(Chk)
            }
            Chk.Visible := Chk.Enabled := 1
            Chk.Value := 0
            Chk.OnEvent('Click', fn)
        }
        Checkboxes.Capacity := Checkboxes.Length
        for Arr in [ tl, tr, br, bl ] {
            i := 0
            loop Arr.Length - 1 {
                Subject := Arr[++i]
                k := i
                loop Arr.Length - k - 1 {
                    ; If the checkboxes overlap
                    if DLLCall('User32.dll\IntersectRect', 'Ptr', Rect, 'Ptr', Arr[++k].Rect, 'Ptr', Subject.Rect, 'int') {
                        ; Whichever Control is lower than the other is moved so they no longer overlap.
                        if NumGet(Subject.Rect, 4, 'int') > NumGet(Arr[k].Rect, 4, 'int') {
                            Subject.Move(NumGet(Rect, 8, 'int'), NumGet(Rect, 12, 'int'))
                        } else {
                            Arr[k].Move(NumGet(Rect, 8, 'int'), NumGet(Rect, 12, 'int'))
                        }
                    }
                }
            }
        }

        _GetCheckbox1() {
            if ++i > Checkboxes.Length {
                GetCheckbox := _GetCheckbox3
                return GetCheckbox()
            }
            return Checkboxes[i]
        }
        _GetCheckbox2() {
            GetCheckbox := _GetCheckbox3
            Checkboxes[1].DefineProp('Rect', { Value: Buffer(16) })
            return Checkboxes[1]
        }
        _GetCheckbox3() {
            Checkboxes.Push(G.Add('CheckBox', '-Background'))
            Checkboxes[-1].DefineProp('Rect', { Value: Buffer(16) })
            ObjSetBase(Checkboxes[-1], Proto)
            return Checkboxes[-1]
        }
    }

    /**
     * @description - Updates zero or more of the options.
     * @param {Object} Options - An object with property : value pairs. See the parameter hint for
     * `SelectControls.Prototype.__New` for details. Valid options are: { Capacity, ExcludeNames,
     * ExcludeTypes, FontOpt, FontFamily, InfoWindowMessage, InfoWindowTitle, RectHighlightOpt }.
     * @param {Boolean} [SuppressPropertyError=false] - Specifies what `RectHighlight.Prototype.HighlightSetOpt`
     * does if it encounters a property that is not a valid option.
     * - If false, throws an error.
     * - If true, skips the property.
     */
    SetOpt(Options, SuppressPropertyError := false) {
        O := this.Options
        for Prop, Value in Options.OwnProps() {
            if HasProp(O, Prop) {
                switch Prop, 0 {
                    case 'Callback', 'EndKey', 'hWnd': this.DefineProp(Prop, { Value: Value })
                    default: O.DefineProp(Prop, { Value: Value })
                }
            } else if !SuppressPropertyError {
                throw PropertyError('Invalid option.', -1, Prop)
            }
        }
    }

    /**
     * @description - Prepares the "info window", a small `Gui` window with one text control and
     * two buttons, "Submit" and "Cancel".
     * @param {String} [Message] - A message to use instead of the built-in message.
     */
    SetInfoWindow(Message?) {
        if this.__Internal.HasOwnProp('IW') {
            try {
                if WinExist(this.__Internal.IW.hWnd) {
                    IW := this.__Internal.IW
                }
            }
            if IsSet(IW) {
                if IsSet(Message) {
                    IW['TxtInfo'].Text := Message
                }
                return IW
            }
        }
        Options := this.Options
        IW := this.__Internal.IW := Gui('+Resize', Options.InfoWindowTitle)
        if Options.FontOpt {
            IW.SetFont(Options.FontOpt)
        }
        if Options.FontFamily {
            for s in StrSplit(Options.FontFamily, ',', '`s`t') {
                if s {
                    IW.SetFont(, s)
                }
            }
        }
        InfoTxt := IW.Add(
            'Text'
          , 'w400 vTxtInfo'
          , Message ?? 'Activate the checkboxes for any controls you want to include, then either'
            ' press the hotkey "' this.EndKey '" or click the button below.'
        )
        InfoBtnSubmit := IW.Add('Button', 'Section vBtnSubmit', 'Submit')
        InfoBtnCancel := IW.Add('Button', 'ys vBtnCancel', 'Cancel')
        ; Centering the buttons.
        InfoBtnSubmit.GetPos(&cx1, , &cw1)
        InfoBtnCancel.GetPos(&cx2, , &cw2)
        InfoTxt.GetPos(&cx3, , &cw3)
        diff := cw3 - (cw2 + cw1 + IW.MarginX)
        InfoBtnSubmit.Move(cx3 + diff / 2)
        InfoBtnCancel.Move(cw3 - cx3 - diff / 2)
        ; Set event handlers
        InfoBtnSubmit.OnEvent('Click', this)
        InfoBtnCancel.OnEvent('Click', this)
        IW.OnEvent('Close', this)
        IW.Show('NoActivate')
        IW.Hide()
        return IW
    }

    Gui {
        Get {
            if WinExist(this.hWnd) {
                return GuiFromHwnd(this.hWnd)
            }
            throw Error('The window no longer exists', -1)
        }
    }

    class Checkbox extends Gui.Checkbox {
        Rect {
            Get {
                this.DefineProp('Rect', { Value: rect := Buffer(16) })
                return rect
            }
        }
        Control => GuiCtrlFromHwnd(this.ControlhWnd)
    }

    class Options {
        static Default := {
            Capacity: 100
          , ExcludeNames: ''
          , ExcludeTypes: ''
          , FontOpt: 's11 q4'
          , FontFamily: 'Aptos,Roboto'
          , InfoWindowMessage: ''
          , InfoWindowTitle: 'SelectControls'
          , RectHighlightOpt: ''
        }
        static Call(Options) {
            ObjSetBase(Options, this.Default)
            return Options
        }
    }
}

