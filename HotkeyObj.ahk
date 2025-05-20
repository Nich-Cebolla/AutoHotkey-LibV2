/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/HotkeyObj.ahk
    Author: Nich-Cebolla
    Version: 0.0.1
    License: MIT

    Status: This is untested.
*/

class HotkeyCollection extends Map {
    __New() {
        this.CaseSense := false
    }

    Add(Name, KeyName, Action, Options?, HotIfCallback?) {
        ObjSetBase(hk := {
            KeyName: KeyName
          , Action: Action
          , Options: Options ?? ''
          , HotIfCallback: HotIfCallback ?? ''
          , Status: 0
        }, HotKeyObj.Prototype)
        this.Set(Name, hk)
        return hk
    }

    __Call(Name, Params) {
        if !Params.Length {
            throw Error('Invalid input.', -1, Name)
        }
        if !this.Has(Params[1]) {
            throw UnsetItemError('Item not found in the hotkey collection.', -1, Params[1])
        }
        return this.Get(Params.RemoveAt(1)).%Name%(Params*)
    }
}


class HotkeyObj {
    __New(Name, KeyName, Action, Options?, HotIfCallback?) {
        this.Name := Name
        this.KeyName := KeyName
        this.Action := Action
        this.Options := Options ?? ''
        this.HotIfCallback := HotIfCallback ?? ''
        this.Status := 0
    }

    Set(Value) {
        if this.HasOwnProp('HotIfCallback') {
            PreviousHotIfCriteria := (cb := this.HotIfCallback)(this)
        }
        if Value = 1 {
            HotKey(this.KeyName, this.Action, this.Options ' On')
        } else if Value {
            HotKey(this.KeyName, this.Action, Value)
        } else {
            HotKey(this.KeyName, this.Action, 'Off')
        }
        return PreviousHotIfCriteria ?? ''
    }

    SetAction(Action) {
        if this.Status {
            this.Set(0)
            this.Action := Action
            this.Set(1)
        } else {
            this.Action := Action
        }
    }

    SetCtrlCheckbox(Ctrl) {
        if Ctrl {
            if this.HasOwnProp('CtrlCheckBox') {
                this.CtrlCheckBox.OnEvent('Click', HClickCheckBox, 0)
            }
            this.CtrlCheckBox := Ctrl
            Ctrl.Value := this.Status
            Ctrl.OnEvent('Click', HClickCheckBox)
            this.DefineProp('Status', { Get: _Getter, Set: _Setter })
        } else {
            if this.HasOwnProp('CtrlCheckBox') {
                this.CtrlCheckBox.OnEvent('Click', HClickCheckBox, 0)
            }
            this.DefineProp('Status', { Value: this.CtrlCheckBox.Value })
            this.DeleteProp('CtrlCheckBox')
        }
        HClickCheckBox(Ctrl, *) {
            (set := HotkeyObj.Prototype.Set)(this, Ctrl.Value)
        }
        _Getter(Self) {
            return Self.CtrlCheckBox.Value
        }
        _Set(Self, Value) {
            Self.CtrlCheckBox.Value := Value
            return (set := HotkeyObj.Prototype.Set)(Self, Value)
        }
        _Setter(Self, Value) {
            Self.CeckBox.Value := Value
        }
    }

    SetCtrlEdit(Ctrl) {
        if this.HasOwnProp('CtrlHotkey') {
            this.DeleteProp('CtrlHotkey')
        }
        this.CtrlEdit := Ctrl
        Ctrl.Text := this.KeyName
    }

    SetCtrlHotkey(Ctrl) {
        if this.HasOwnProp('CtrlEdit') {
            this.DeleteProp('CtrlEdit')
        }
        this.CtrlHotkey := Ctrl
        Ctrl.Value := this.KeyName
        if !Ctrl.Value && this.KeyName {
            throw ValueError('The ``HotKey`` control does not support the key name.', -1, this.KeyName)
        }
    }

    SetCtrlText(Ctrl) {
        this.CtrlText := Ctrl
        Ctrl.Text := this.Name
    }

    SetHotIfCallback(HotIfCallback) {
        if this.HotIfCallback && this.Status {
            PreviousHotIfCriteria := (cb := this.HotIfCallback)(this)
            HotKey(this.KeyName, this.Action, 'Off')
            HotIfCallback(this)
            HotKey(this.KeyName, this.Action, this.Options ' On')
        }
        this.HotIfCallback := HotIfCallback
        return PreviousHotIfCriteria ?? ''
    }

    SetKeyName(KeyName?) {
        if IsSet(KeyName) {
            if this.HasOwnProp('CtrlEdit') {
                this.CtrlEdit.Text := KeyName
            } else if this.HasOwnProp('CtrlHotkey') {
                this.CtrlHotkey.Value := KeyName
                if !this.CtrlHotkey.Value {
                    throw ValueError('The ``HotKey`` control does not support the key name.', -1, KeyName)
                }
            }
        } else {
            if this.HasOwnProp('CtrlEdit') {
                KeyName := this.CtrlEdit.Text
            } else if this.HasOwnProp('CtrlHotkey') {
                KeyName := this.CtrlHotkey.KeyName
            } else {
                throw Error('Calling ``' A_ThisFunc '`` without a KeyName requires either '
                '``HotkeyObj.Prototype.SetCtrlEdit`` or ``HotkeyObj.Prototype.SetCtrlHotkey`` to have been '
                'called.', -1)
            }
        }
        if KeyName != this.KeyName {
            if this.Status {
                if this.HotIfCallback {
                    PreviousHotIfCriteria := (cb := this.HotIfCallback)(this)
                }
                HotKey(this.KeyName, this.Action, 'Off')
                HotKey(KeyName, this.Action, this.Options ' On')
            }
            this.KeyName := KeyName
            return PreviousHotIfCriteria ?? ''
        }
    }

    SetOptions(Options) {
        this.Options := Options
        if this.Status {
            HotKey(this.KeyName, this.Action, this.Options ' On')
        }
    }

    Toggle(Options?) {
        if this.HasOwnProp('HotIfCallback') {
            PreviousHotIfCriteria := (cb := this.HotIfCallback)(this)
        }
        this.ToggleSkipCallback(Options ?? unset)
        return PreviousHotIfCriteria
    }

    ToggleSkipCallback(Options?) {
        if !IsSet(Options) {
            Options := this.Options
        }
        if InStr(Options, 'On') {
            this.Status := 1
        } else if InStr(Options, 'Off') {
            this.Status := 0
        } else {
            if this.Status {
                this.Status := 0
                Options .= ' Off'
            } else {
                this.Status := 1
                Options .= ' On'
            }
        }
        HotKey(this.KeyName, this.Action, Options)
    }
}
