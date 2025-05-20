/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/HotkeyObj.ahk
    Author: Nich-Cebolla
    Version: 0.0.1
    License: MIT

    Status: This is untested.
*/
; https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/inheritance/ClassFactory.ahk
#include <ClassFactory>

class HotkeyCollection extends Map {
    __New(CollectionName, PageSize) {
        this.CollectionName := CollectionName
        Prototypes := this.Prototypes := {}
        ObjSetBase(Prototypes.Page := [], HotkeyCollection.Page.Prototype)
        Prototypes.Page.CollectionName := CollectionName
        Prototypes.Page.PageSize := PageSize
        ObjSetBase(Prototypes.HotkeyObj := {}, HotkeyObj.Prototype)
        Prototypes.HotkeyObj.CollectionName := CollectionName
        Constructors := this.Constructors := {
            Page: ClassFactory(Prototypes.Page)
        }
        this.CaseSense := false
        this.Pages := []
        this.AddPage()
        this.__PageSize := PageSize
        this.__Page := 1
    }

    Add(Name, KeyName, Action, Options?, HotIfCallback?) {
        ObjSetBase(Hk := {
            KeyName: KeyName
          , Action: Action
          , Options: Options ?? ''
          , HotIfCallback: HotIfCallback ?? ''
          , Status: 0
        }, this.Prototypes.HotkeyObj)
        this.Set(Name, Hk)
        return Hk
    }

    AddPage() {
        this.Pages.Push((cls := this.Constructors.Page)())
        this.Pages[-1].Capacity := this.__PageSize
    }

    Find(Name, &PageNumber, &Index) {
        PageNumber := Index := 0
        if this.Has(Name) {
            for Page in this.Pages {
                PageNumber++
                for hk in Page {
                    if hk.Name = Name {
                        Index := A_Index
                        return 1
                    }
                }
            }
        }
    }

    Set(Name, Hk) {
        if this.Find(Name, &PageNumber, &Index) {
            this.Pages[PageNumber][Index] := Hk
        } else {
            this.__AddToPage(Hk)
        }
        (set := Map.Prototype.Set)(this, Name, Hk)
    }

    SetCtrlCheckBox(Ctrls) {
        this.__SetCtrl(Ctrls, 'CheckBox')
    }

    SetCtrlEdit(Ctrls) {
        this.__SetCtrl(Ctrls, 'Edit')
    }

    SetCtrlHotkey(Ctrls) {
        this.__SetCtrl(Ctrls, 'Hotkey')
    }

    SetCtrlText(Ctrls) {
        this.__SetCtrl(Ctrls, 'Text')
    }

    SetPage(PageNum) {
        if PageNum > this.Pages.Length || PageNum <= this.Pages.Length * -1 || !PageNum {
            throw IndexError('The page number is out of range.', -1, PageNum)
        }
        if PageNum < 0 {
            PageNum := this.Pages.Length + PageNum + 1
        }
        this.__Page := PageNum
    }

    SetPageSize(PageSize) {
        if PageSize = this.__PageSize {
            return
        }
        this.Prototypes.Page.PageSize := PageSize
        Pages := this.Pages
        if PageSize > this.__PageSize {
            if this.Pages.Length > 1 {
                P1 := Pages[1]
                i := 2
                loop Pages.Length {
                    P1.Capacity := PageSize
                    P2 := Pages.RemoveAt(i)
                    while P1.Length < PageSize {
                        if !P2.Length {
                            if i == Pages.Length {
                                break 2
                            }
                            P2 := Pages.RemoveAt(i)
                        }
                        P1.Push(P2.RemoveAt(1))
                    }
                    P1 := P2
                    if ++i > Pages.Length {
                        break
                    }
                }
                if P2.Length {
                    Pages.Push(P2)
                    P2.Capacity := PageSize
                }
            }
        } else {
            P1 := Pages[1]
            NewPages := this.Pages := []
            cls := this.Constructors.Page
            loop Ceil(Pages.Length * this.__PageSize / PageSize) {
                NewPages.Push(Page := cls())
                loop Page.Capacity := PageSize {
                    if !P1.Length {
                        if !Pages.Length {
                            break 2
                        }
                        P1 := Pages.RemoveAt(1)
                    }
                    Page.Push(P1.RemoveAt(1))
                }
            }
        }
        this.__PageSize := PageSize
    }

    __AddToPage(Hk) {
        if this.Pages[-1].Length == this.__PageSize {
            this.AddPage()
        }
        this.Pages[-1].Push(Hk)
    }

    __SetCtrl(Ctrls, Name) {
        if Ctrls.Length !== this.__PageSize {
            throw ValueError('The number of controls in the array is not the same as the page size.', -1, 'Ctrls.Length == ' Ctrls.Length)
        }
        this.Ctrl%Name% := Ctrls
        for Hk in this.Active {
            Hk.SetCtrl%Name%(Ctrls[A_Index])
        }
    }

    Active => this.Pages[this.__Page]

    Page {
        Get => this.__Page
        Set => this.SetPage(Value)
    }

    PageSize {
        Get => this.__PageSize
        Set => this.SetPageSize(Value)
    }

    class Page extends Array {
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
