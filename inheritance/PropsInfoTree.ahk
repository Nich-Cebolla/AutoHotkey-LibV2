/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/
    Author: Nich-Cebolla
    Version: 1.4.0
    License: MIT
*/

class PropsInfoTree extends Gui.TreeView {
    static Call(GuiObj, SetEventHandler := true, Options?) {
        if !IsSet(Options) {
            Options := {}
        }
        ObjSetBase(Options, this.Default)
        TV := GuiObj.Add('TreeView', Options.OptTv || unset)
        ObjSetBase(TV, this.Prototype)
        TV.Init(Options)
        if SetEventHandler {
            TV.OnEvent('ItemEdit', ObjBindMethod(TV, 'HItemEdit'))
            TV.OnEvent('ItemExpand', ObjBindMethod(TV, 'HItemExpand'))
        }
        return TV
    }

    static Default := {
        OptItem: ''
      , StopAt: ''
      , Exclude: 'Prototype,Base'
      , IncludeMethods: true
      , OptTv: '-ReadOnly'
    }


    Clear() {
        if this.HasOwnProp('RootCollection') {
            for id1, collection in this.RootCollection {
                for id2, GenObj in collection {
                    GenObj.PropsInfo.Dispose()
                }
            }
            this.RootCollection.Clear()
        }
        if this.HasOwnProp('Items') {
            this.Items.Clear()
        }
        this.Delete()
    }

    Init(Options?, ShowTooltips := true) {
        if !IsSet(Options) {
            Options := {}
        }
        this.RootCollection := RootCollection(false)
        this.Items := PropsInfoTreeItemCollection(false)
        this.__ShowTooltips := ShowTooltips
        ObjSetBase(this.Options := Options, PropsInfoTree.Default)
    }

    AddMethod(firstGenObj, InfoItem) {
        switch InfoItem.KindIndex {
            case 1: _Add(InfoItem.GetFunc(), 7)
            case 2: _Add(InfoItem.GetFunc(), 8)
            case 3:
                _Add(InfoItem.GetFunc(&setter), 8)
                _Add(setter, 9)
            case 4: _Add(InfoItem.GetFunc(&setter), 9)
        }

        return

        _Add(FuncObj, GenType) {
            secondGenMethodId := this.Add('', firstGenObj.Id, this.Options.OptItem || unset)
            ObjSetBase(methodGenObj := { Type: GenType, Parent: firstGenObj.Id, InfoItem: InfoItem, Id: secondGenMethodId, Value: FuncObj }, firstGenObj.Base)
            methodGenObj.Placeholder := this.Add('', secondGenMethodId)
            ObjSetBase(placeholderObj := { Type: 11, Id: methodGenObj.Placeholder }, firstGenObj.Base)
            this.Items.Set(methodGenObj.Placeholder, placeholderObj)
            this.Modify(secondGenMethodId, , methodGenObj())
            this.Items.Set(secondGenMethodId, methodGenObj)
        }
    }

    AddRoot(Obj, Name, Parent := 0, GenObj?) {
        Options := this.Options
        if Obj is PropsInfo {
            PropsInfoObj := Obj
            Obj := PropsInfoObj.__PropsInfoItemBase.Root
        } else {
            PropsInfoObj := GetPropsInfo(Obj, Options.StopAt || unset, Options.Exclude || unset, false, , !Options.IncludeMethods)
        }
        if IsSet(GenObj) {
            firstGenId := GenObj.Id
            ObjSetBase(Base := { ParentName: Name, FirstGen: firstGenId, PropsInfo: PropsInfoObj }, PropsInfoTree.Generation.Prototype)
            ObjSetBase(firstGenObj := { Type: 1, Parent: GenObj.Parent, Id: firstGenId }, Base)
        } else {
            firstGenId := this.Add('', Parent, Options.OptItem || unset)
            ObjSetBase(Base := { ParentName: Name, FirstGen: firstGenId, PropsInfo: PropsInfoObj }, PropsInfoTree.Generation.Prototype)
            ObjSetBase(firstGenObj := { Type: 1, Parent: Parent, Id: firstGenId }, Base)
            this.Modify(firstGenId, , firstGenObj())
            this.Items.Set(firstGenId, firstGenObj)
        }
        PropsInfoObj.Id := firstGenId
        this.RootCollection.AddToCategory(firstGenObj.Parent, firstGenObj.Id, firstGenObj)
        if HasMethod(Obj, '__Enum') && Type(Obj) !== 'Prototype' {
            this.EnumerateObj(Obj, firstGenObj)
        }
        getGenObj := ''
        for InfoItem in PropsInfoObj {
            if Options.IncludeMethods && InfoItem.KindIndex !== 5 {
                this.AddMethod(firstGenObj, InfoItem)
            }
            if InfoItem.GetValue(&Value) {
                if IsSet(Value) {
                    Value := this.ProcessError(Value)
                } else {
                    continue
                }
            }
            secondGenId := InfoItem.Id := this.Add('', firstGenId, Options.OptItem || unset)
            ObjSetBase(secondGenObj := { Parent: firstGenId, InfoItem: InfoItem, Id: secondGenId, Value: Value }, firstGenObj.Base)
            if IsObject(Value) {
                secondGenObj.Type := 5
                secondGenObj.Placeholder := this.Add('', secondGenId)
                ObjSetBase(placeholderObj := { Type: 11, Id: secondGenObj.Placeholder }, firstGenObj.Base)
                this.Items.Set(secondGenObj.Placeholder, placeholderObj)
            } else {
                secondGenObj.Type := 6
            }
            this.Modify(secondGenId, , secondGenObj())
            this.Items.Set(secondGenId, secondGenObj)
            Value := unset
        }
        firstGenObj.Expanded := true
    }

    DeleteChildren(id) {
        list := [child := this.GetChild(id)]
        while child {
            list.Push(child := this.GetNext(child))
        }
        for id in list {
            this.Delete(id)
        }
    }

    Refresh(Id := 0) {
        if Id {
            if this.RootCollection.Has(Id) {
                this.RefreshRoot(GenObj)
                return
            }
            if this.Items.Has(Id) {
                GenObj := this.Items.Get(Id)
            } else {
                throw UnsetItemError('An item with that id does not exist in the colleciton.', -1, Id)
            }
            if GenObj.Type == 1 {
                this.RefreshRoot(GenObj)
            } else {
                this.RefreshRoot(this.Items.Get(GenObj.FirstGen))
            }
        } else {
            for name, firstGenObj in this.RootCollection.Get(0) {
                this.RefreshRoot(firstGenObj)
            }
        }
    }

    RefreshMethod(firstGenObj, InfoItem) {
        switch InfoItem.KindIndex {
            case 1: _Refresh(InfoItem.GetFunc(), 7)
            case 2: _Refresh(InfoItem.GetFunc(), 8)
            case 3:
                _Refresh(InfoItem.GetFunc(&setter), 8)
                _Refresh(setter, 9)
            case 4: _Refresh(InfoItem.GetFunc(&setter), 9)
        }

        return

        _Refresh(FuncObj, GenType) {
            secondGenMethodId := this.Add('', firstGenObj.Id, this.Options.OptItem || unset)
            ObjSetBase(secondGenObj := { Type: GenType, Parent: firstGenObj.Id, InfoItem: InfoItem, Id: secondGenMethodId, Value: FuncObj }, firstGenObj.Base)
            secondGenObj.Placeholder := this.Add('', secondGenMethodId)
            ObjSetBase(placeholderObj := { Type: 11, Id: secondGenObj.Placeholder }, firstGenObj.Base)
            this.Items.Set(secondGenObj.Placeholder, placeholderObj)
            this.Modify(secondGenMethodId, , secondGenObj())
            this.Items.Set(secondGenMethodId, secondGenObj)
        }
    }

    RefreshRoot(firstGenObj) {
        this.RefreshProps(firstGenObj)
        if firstGenObj.HasOwnProp('Enum') {
            this.RefreshEnum(firstGenObj)
        }
    }

    RefreshEnum(firstGenObj) {
        Options := this.Options
        enumGenObj := firstGenObj.Enum
        secondGenEnumId := enumGenObj.Id
        child := this.GetChild(secondGenEnumId)
        PropsInfoObj := firstGenObj.PropsInfo
        Proc := _Modify
        i := 0
        try {
            for key, item in firstGenObj.Root {
                if !IsSet(item) {
                    continue
                }
                ++i
                Proc(&key, &item)
            }
        } catch {
            if i {
                this.DeleteChildren(secondGenEnumId)
            }
            try {
                i := 0
                for item in firstGenObj.Root {
                    ++i
                    if !IsSet(item) {
                        continue
                    }
                    Proc(&i, &item)
                }
            } catch Error as err {
                if i || enumGenObj.Type == 2 {
                    this.DeleteChildren(secondGenEnumId)
                }
                enumGenObj.Type := 10
                enumGenObj.Value := err
                this.Modify(enumGenObj.Id, enumGenObj())
            }
        }
        if child {
            list := [child]
            while child {
                list.Push(child := this.GetNext(child))
            }
            for id in list {
                this.Delete(id)
            }
        }

        return

        _Modify(&key, &item) {
            if !child {
                Proc := _Add
                _Add(&key, &item)
                return
            }
            enumGenObj := this.Items.Get(child)
            enumGenObj.Key := key
            enumGenObj.Value := item
            this.Modify(child, , enumGenObj())
            child := this.GetNext(child)
        }
        _Add(&key, &item) {
            thirdGenId := this.Add('', secondGenEnumId, Options.OptItem || unset)
            ObjSetBase(thirdGenObj := { Parent: secondGenEnumId, SecondGen: secondGenEnumId, Id: thirdGenId, Value: item, Key: key }, firstGenObj.Base)
            if IsObject(Value) {
                thirdGenObj.Type := 3
                thirdGenObj.Placeholder := this.Add('', thirdGenId)
                ObjSetBase(placeholderObj := { Type: 11, Id: thirdGenObj.Placeholder }, firstGenObj.Base)
                this.Items.Set(thirdGenObj.Placeholder, placeholderObj)
            } else {
                thirdGenObj.Type := 4
            }
            this.Modify(thirdGenId, thirdGenObj())
            this.Items.Set(thirdGenId, thirdGenObj)
        }
    }

    RefreshProps(firstGenObj) {
        Options := this.Options
        for InfoItem in firstGenObj.PropsInfo {
            InfoItem.Refresh()
            if Options.IncludeMethods && InfoItem.KindIndex !== 5 {
                this.RefreshMethod(firstGenObj, InfoItem)
            }
            if InfoItem.GetValue(&Value) {
                if IsSet(Value) {
                    Value := this.ProcessError(Value)
                } else {
                    continue
                }
            }
            secondGenObj := this.Items.Get(InfoItem.Id)
            secondGenObj.Value := Value
            if IsObject(Value) {
                secondGenObj.Type := 5
            } else {
                secondGenObj.Type := 6
            }
            this.Modify(InfoItem.Id, , secondGenObj())
            Value := unset
        }
    }

    RefreshProp(InfoItem) {
        InfoItem.Refresh()
        if InfoItem.GetValue(&Value) {
            if IsSet(Value) {
                Value := this.ProcessError(Value)
            } else if this.Options.Options.IncludeMethods {
                return
            } else {
                Value := InfoItem.GetFunc()
            }
        }
        secondGenObj := this.Items.Get(InfoItem.Id)
        secondGenObj.Value := Value
        if IsObject(Value) {
            secondGenObj.Type := 5
        } else {
            secondGenObj.Type := 6
        }
        this.Modify(InfoItem.Id, , secondGenObj())
        Value := unset
    }

    EnumerateObj(Obj, firstGenObj, secondGenEnumId?) {
        local enumGenObj
        Options := this.Options
        i := 0
        try {
            for key, item in Obj {
                if A_Index == 1 && !IsSet(secondGenEnumId) {
                    _MakeGenObj()
                }
                if !IsSet(Item) {
                    continue
                }
                ++i
                _Add(&key, &item)
            }
        } catch {
            if i {
                this.DeleteChildren(secondGenEnumId)
            }
            i := 0
            try {
                for item in Obj {
                    if A_Index == 1 && !IsSet(secondGenEnumId) {
                        _MakeGenObj()
                    }
                    if !IsSet(Item) {
                        continue
                    }
                    ++i
                    _Add(&key, &item)
                }
            } catch Error as err {
                if i {
                    this.DeleteChildren(secondGenEnumId)
                }
                if !IsSet(secondGenEnumId) {
                    secondGenEnumId := this.Add('', firstGenObj.Id, Options.OptItem || unset)
                }
                ObjSetBase(firstGenObj.Enum := enumGenObj := { Type: 10, Parent: firstGenObj.Id, Value: err, Id: secondGenEnumId }, firstGenObj.Base)
                this.Items.Set(secondGenEnumId, enumGenObj)
            }
        }

        _Add(&key, &item) {
            thirdGenId := this.Add('', secondGenEnumId, Options.OptItem || unset)
            ObjSetBase(thirdGenObj := { Parent: secondGenEnumId, SecondGen: secondGenEnumId, Id: thirdGenId, Value: item, Key: key }, firstGenObj.Base)
            if IsObject(Value) {
                thirdGenObj.Type := 3
                thirdGenObj.Placeholder := this.Add('', thirdGenId)
                ObjSetBase(placeholderObj := { Type: 11, Id: thirdGenObj.Placeholder }, firstGenObj.Base)
                this.Items.Set(thirdGenObj.Placeholder, placeholderObj)
            } else {
                thirdGenObj.Type := 4
            }
            this.Modify(thirdGenId, thirdGenObj())
            this.Items.Set(thirdGenId, thirdGenObj)
        }
        _MakeGenObj() {
            secondGenEnumId := this.Add('', firstGenObj.Id, Options.OptItem || unset)
            ObjSetBase(firstGenObj.Enum := enumGenObj := { Type: 2, Parent: firstGenObj.Id, Id: secondGenEnumId }, firstGenObj.Base)
            this.Modify(secondGenEnumId, , enumGenObj())
            this.Items.Set(secondGenEnumId, enumGenObj)
        }
    }

    SetOptions(Options) {
        ObjSetBase(this.Options := Options, PropsInfoTree.Default)
    }

    HItemExpand(Ctrl, Item, Expanded) {
        if Expanded {
            Options := this.Options
            GenObj := this.Items.Get(Item)
            if GenObj.HasOwnProp('Placeholder') {
                this.Delete(GenObj.Placeholder)
                this.Items.Delete(GenObj.Placeholder)
                GenObj.DeleteProp('Placeholder')
            }
            if GenObj.HasOwnProp('Expanded') {
                this.RefreshRoot(this.Items.Get(GenObj.FirstGen))
            } else if GenObj.Type == 1 {
                ShowTooltip('Refreshing the items!.', -4000)
                this.RefreshRoot(GenObj)
            } else if GenObj.Kind == 'Prop' {
                InfoItem := GenObj.InfoItem
                if InfoItem.GetValue(&Value) {
                    if !Options.IncludeMethods {
                        this.AddRoot(fn := InfoItem.GetFunc(), fn.Name, GenObj.Parent, GenObj)
                    }
                } else if IsObject(Value) {
                    ShowTooltip('Adding new root object!.', -4000)
                    this.AddRoot(Value, InfoItem.Name, GenObj.Parent, GenObj)
                } else {
                    ShowTooltip('The value is not an object!.', -4000)
                    this.Modify(Item, Options.OptItem || unset, InfoItem.Name ' :: ' Value)
                    return
                }
            } else if GenObj.Kind == 'Enum' {
                if GenObj.HasOwnProp('Item') {
                    ShowTooltip('Adding new root object!.', -4000)
                    this.AddRoot(GenObj.Item, GenObj.Key, GenObj.Parent, GenObj)
                } else {
                    ShowTooltip('No object values available!.', -4000)
                }
            }
        }
    }
    HItemEdit(Ctrl, Item) {
        if this.Items.Has(Item) {
            Obj := this.Items.Get(Item)
        } else {
            throw UnsetItemError('An item with that id does not exist in the colleciton.', -1, Item)
        }
        Options := this.Options
        if Obj.Kind == 'Enum' {
            ShowTooltip('Modifying items returned by the enumerator is not currently supported.', -4000)
        } else if Obj.Kind == 'Prop' {
            InfoItem := Obj.InfoItem
            switch InfoItem.KindIndex {
                case 1, 2:
                    ShowTooltip('Item is read only!', -4000)
                    this.RefreshProp(InfoItem)
                case 3, 4:
                    Setter := InfoItem.Set.Bind(InfoItem.Root)
                    try {
                        Setter(this.GetText(Item))
                        this.Refresh(Item)
                        _Success()
                    } catch Error as err {
                        ShowTooltip(this.ProcessError(err, '`n'), -4000)
                    }
                case 5:
                    InfoItem.Root.DefineProp(InfoItem.Name, { Value: this.GetText(Item) })
                    _Success()
            }
        }

        _Success() {
            this.Modify(InfoItem, Options.OptItem || unset, InfoItem.Name ' :: ' this.GetText(Item))
            ShowTooltip('Successfully updated property ``' InfoItem.Name '`` to value "' this.GetText(Item) '".', -4000)
        }
    }
    HClick(Ctrl, Item) {
        ShowTooltip(Item)
    }
    ProcessError(err, separator := ', ') {
        return Type(err) ' :: ' Format(
            '[ "Message" ][ "' err.Message '" ]{1}'
            '[ "What" ][ "' err.What '" ]{1}'
            '[ "File" ][ "' err.File '" ]{1}'
            '[ "Line" ][ "' err.Line '" ]{1}'
            '[ "Extra" ][ "' err.Extra '" ]', separator
        )
    }
    ShowTooltips {
        Get => this.__ShowTooltips
        Set => this.__ShowTooltips := Value
    }

    class Generation {
        Call() {
            return this.Name%this.Type%()
        }
        Name1() {
            return this.ParentName ' :: { ' Type(this.Root) ' : ' ObjPtr(this.Root) ' }'
        }
        Name2() {
            return '__Enum() :: ' this.ParentName
        }
        Name3() {
            if IsObject(this.Key) {
                return '__Enum() :: [ { ' Type(this.Key) ' :: ' ObjPtr(this.Key) ' } ][ { ' Type(this.Value) ' :: ' ObjPtr(this.Value) ' } ]'
            } else {
                return '__Enum() :: [ ' (this.Key is Number ? this.Key : '"' this.Key '"') ' ][ { ' Type(this.Value) ' :: ' ObjPtr(this.Value) ' } ]'
            }
        }
        Name4() {
            if IsObject(this.Key) {
                return '__Enum() :: [ { ' Type(this.Key) ' :: ' ObjPtr(this.Key) ' } ][ ' (this.Value is Number ? this.Value : '"' this.Value '"') ' ]'
            } else {
                return '__Enum() :: [ ' (this.Key is Number ? this.Key : '"' this.Key '"') ' ][ ' (this.Value is Number ? this.Value : '"' this.Value '"') ' ]'
            }
        }
        Name5() {
            return this.Prop ' :: { ' Type(this.Value) ' : ' ObjPtr(this.Value) ' }'
        }
        Name6() {
            return this.Prop ' :: ' this.Value
        }
        Name7() {
            return '__Enum() :: ' this.ParentName ' :: ' this.ProcessError(this.Value)
        }
        Root => this.PropsInfo.__PropsInfoItemBase.Root
        Prop => this.HasOwnProp('InfoItem') ? this.InfoItem.Name : ''
    }
}




class PropsInfoTreeCollection extends Map {
    static Default := {
        Opt: ''
      , ErrorProps: 'Message,What,File,Line,Extra'
      , Options: ''
      , StopAt: ''
      , Exclude: ''
      , IncludeMethods: ''
    }
    __New(GuiObj, CaseSense := false) {
        this.CaseSense := CaseSense
        this.hWnd := GuiObj.hWnd
        GuiObj.DefineProp('PropsInfoTreeCollection', { Value: this })
    }
    MakeTab(Which := 'Tab2', Opt?, Text?) {
        GuiObj := this.Gui
        this.Tab := dTab(GuiObj, Which, Opt ?? unset, Text ?? unset)
        return this.Tab
    }
    AddTreeView(Obj, Name, Parent?, Container?, Options?) {
        if this.Has(Name) {
            throw Error('An item already exists with that name.', -1, Name)
        }
        if !IsSet(Options) {
            Options := {}
        }
        ObjSetBase(Options, PropsInfoTreeCollection.Default)

        tab := this.Tab
        tab.Add([Name])
        tab.UseTab(tab.GetItemCount())
        tab.Value := tab.GetItemCount()
        if !this.Count {
            tabDisplayRect := tab.GetClientDisplayRect()
        }
        if !IsObject(Obj) {
            Obj := GetObjectFromString(Obj)
        }
        if not Obj is PropsInfo {
            Obj := GetPropsInfo(Obj, StopAt ?? unset, Exclude ?? unset, false, , true)
        }
        for n, tv in this {
            tv.GetPos(&tvx, &tvy, &tvw, &tvh)
            break
        }
        this.Set(Name
          , Obj.ToTreeView(
            this.Gui
          , Format(
                'x{} y{} w{} h{} v{} {}'
              , tvx ?? tabDisplayRect.Left
              , tvy ?? tabDisplayRect.Top
              , tvw ?? tabDisplayRect.Width
              , tvh ?? tabDisplayRect.Height
              , Name
              , Options.Opt || ''
            )
          , Parent ?? unset
          , Container ?? unset
          , Options
        ))
    }

    Gui => GuiFromHwnd(this.hWnd)
}

class PropsInfoTreeItemCollection extends MapEx {
}

class RootCollection extends MapEx {

}

class PropsInfoEnumCollection extends MapEx {

}

class TreeItemMethodCollection extends MapEx {

}
