/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/
    Author: Nich-Cebolla
    Version: 1.2.0
    License: MIT
*/

; Dependencies:
#Include Inheritance_Shared.ahk
#Include GetBaseObjects.ahk

; I need to finish writing the details of the function and classes

/**
 * @description - Constructs a list of properties and details about the properties for both
 * inherited and own properties for the input object. This function is intended to be a substitute
 * for the `Props` method which is available only to Alpha users at the time of this writing.
 * `GetPropsInfo` traverses an object's inheritance chain, calling `ObjOwnProps` for each object along
 * the way and filling an array with `PropsInfo
 * @param {Object} Obj - The object from which to get the properties.
 * @param {VarRef} [OutBaseObjectsList] - A variable that will receive a reference to the array of
 * base objects that is generated during the function call.
 * @param {+Integer|String} [StopAt='-Any'] - If an integer, the number of base objects to traverse up
 * the inheritance chain. If a string, the name of the class to stop at. See {@link GetBaseObjects}
 * for full details about this parameter.
 * @param {String} [Exclude='Base,__Class,Prototype'] - A comma-delimited, case-insensitive list of
 * properties to exclude.
 * @returns {PropsInfo} - `PropsInfo` instances are designed to be
 *
 * - They are constructed from descriptor objects retrieved by calling `Object.Prototype.GetOwnPropDesc`.
 * {@link https://www.autohotkey.com/docs/v2/lib/Object.htm#GetOwnPropDesc}.
 * After getting the descriptor object, `GetPropsInfo` changes the descriptor object's base, converting
 * it to a `PropsInfoItem` object and exposing additional properties. In addition to their original
 * properties `Call` or `value` or one or both of `Get`, `Set`, the following are available:
 * @property {Integer} Index - The index position of the object which owns the property in the
 * inheritance chain, where index 0 is the input object, 1 is the input object's base, 2 is the next
 * base object, etc. The `Index` is aligned with `OutBaseObjectsList`, so to get the object
 * associated with the property you can call `BaseObjectsList[PropsResult.Get(PropName).Index]`.
 * @property {String} Name - The name of the property.
 * @property {String} Type - `Type` will return one of these, depending on the type of function:
 * - Call
 * - Get
 * - Get_Set - I chose to name it this way so each value begins with a different character,
 * so some tasks can be optimized to just check the first character.
 * - Set
 * - Value
 * @property {Array} [Alt] - If only one object in the inheritance chain owns a property by the
 * name, then `Alt` is unset. If there are multiple objects that own a property
 * by the same name, `Alt` is set with an array of objects. The objects are the same as this primary
 * object, except there is no `Alt` property. Specifically, they are initialized as the property
 * descriptor, and { Index, Name, Type } are available as well.
 *
 *
 *
 *
 *
 * The descriptor objects used to create the `PropsInfoItem` are always associated with the
 * value that is owned by or inherited by the input `Obj`, even if multiple objects in the
 * inheritance chain have varying values for the same property name.
 * @example
 *  class a {
 *      method1() {
 *      }
 *  }
 *  class b extends a {
 *      method1() {
 *      }
 *  }
 *  MyObj := b()
 *  Result := GetPropsInfo(MyObj)
 *  MsgBox(Result.Get('method1').Desc.Call.Name) ; b.Prototype.method1
 *  MyObj.DefineProp('method1', { Call: (*) => '' })
 *  Result := GetPropsInfo(MyObj)
 *  MsgBox(Result.Get('method1').Desc.Call.Name) ; Func.Prototype.Call
 * @
 *
 * @
 */
GetPropsInfo(Obj, &OutBaseObjectsList?, StopAt := '-Any', Exclude := 'Base,__Class,Prototype') {
    OutBaseObjectsList := GetBaseObjects(Obj, &Count, StopAt)
    Container := Map()
    Container.Default := Container.CaseSense := false
    for s in StrSplit(Exclude, ',') {
        Container.Set(Trim(s, '`s`t'), -1)
    }

    for Prop in ObjOwnProps(Obj) {
        if Container.Get(Prop) {
            ; Prop is in `Exclude`
            continue
        }
        ObjSetBase(ItemBase := { Name: Prop }, PropsInfoItem.ItemBase)
        ObjSetBase(Item := OBJ_GETOWNPROPDESC(Obj, Prop), ItemBase)
        Item.Index := 0
        Container.Set(Prop, Item)
    }
    i := 0
    for B in OutBaseObjectsList {
        i++
        for Prop in ObjOwnProps(B) {
            if r := Container.Get(Prop) {
                if r == -1 {
                    continue
                }
                ; It's an existing property
                ObjSetBase(Item := OBJ_GETOWNPROPDESC(B, Prop), r.Base)
                Item.Index := i
                r.__SetAlt(Item)
            } else {
                ; It's a new property
                ObjSetBase(ItemBase := { Name: Prop }, PropsInfoItem.Prototype)
                ObjSetBase(Item := OBJ_GETOWNPROPDESC(B, Prop), ItemBase)
                Item.Index := i
                Container.Set(Prop, Item)
            }
        }
    }
    for s in StrSplit(Exclude, ',') {
        Container.Delete(Trim(s, '`s`t'))
    }
    return PropsInfo(Container)
}

class PropsInfo {
    static __New() {
        if this.Prototype.__Class == 'PropsInfo' {
            this.Prototype.DefineProp('FilterActive', { Value: 0 })
            this.Prototype.DefineProp('__StringMode', { Value: 0 })
        }
    }
    __New(Container) {
        this.__PropNameIndex := Map()
        this.__PropNameIndex.Default := this.__PropNameIndex.CaseSense := false
        this.__InfoObjects := []
        this.__InfoObjects.Capacity := this.__PropNameIndex.Capacity := Container.Count
        for Prop, PropInfo in Container {
            this.__InfoObjects.Push(PropInfo)
            this.__PropNameIndex.Set(Prop, A_Index)
        }
        this.DefineProp('Get', PropsInfo.Prototype.GetOwnPropDesc('__ItemGet_Bitypic'))
    }

    ActivateCachedFilter(Name) {
        if !this.FilterActive {
            this.FilterActive := 1
            this.__ObjCache := { Index: this.__ItemIndex, Items: this.__InfoObjects }
        }
        O := this.FilterCache.Get(Name)
        this.__ItemIndex := O.Index
        this.__InfoObjects := O.Items
    }

    ActivateFilter(CacheName?) {
        if !this.HasOwnProp('Filter') {
            throw UnsetItemError('No Filters have been added.', -1)
        }
        if !this.FilterActive {
            this.__ObjCache := { Index: this.__ItemIndex, Items: this.__InfoObjects }
        }
        Filter := this.Filter
        if Filter.Exclude {
            Filter.Set(0, _Exclude)
        }
        this.__ItemIndex := Map()
        this.__InfoObjects := []
        this.__ItemIndex.Capacity := this.__InfoObjects.Capacity := this.__ObjCache.Index.Count
        if this.Filter is Map {
            for PropInfo in this.__ObjCache.Items {
                for FilterIndex, FilterObj in Filter {
                    if FilterObj(PropInfo) {
                        continue
                    }
                }
                this.__InfoObjects.Push(PropInfo)
                this.__ItemIndex.Set(Prop, this.__InfoObjects)
            }
        } else {
            Fn := this.Filter
            for PropInfo in this.__ObjCache.Items {
                if Fn(PropInfo) {
                    continue
                }
                this.__InfoObjects.Push(PropInfo)
                this.__ItemIndex.Set(Prop, this.__InfoObjects)
            }
        }
        this.__ItemIndex.Capacity := this.__InfoObjects.Capacity := this.__InfoObjects.Count
        this.DefineProp('FilterActive', { Value: 1 })

        _Filter(PropInfo) {

        }
        _Exclude(PropInfo) {
            return InStr(this.Filter.Exclude, ',' PropInfo.Name ',')
        }
    }

    AddFilter(Activate := true, Filters*) {
        if !this.HasOwnProp('Filter') {
            this.Filter := Map()
            this.Filter.Exclude := ''
            this.__FilterIndex := 1
        }
        start := this.__FilterIndex
        for Item in Filter {
            if Item is Func {
                FilterItem := Item
            } else if IsObject(Item) {
                _Throw()
            } else {
                switch FilterItem, 0 {
                    case '1', '2', '3', '4': FilterItem := _Filter_%FilterItem%
                    default:
                        this.Filter.Exclude .= ',' Item
                }
            }
            this.Filter.Set(this.__Index, PropsInfo.Filter(FilterItem, this.__Index++))
        }
        if this.Filter.Exclude {
            ; By ensuring every name has a comma on either side of it, we can check the names by
            ; using `InStr(Filter.Exclude, ',' Prop ',')` which should perform better than RegExMatch.
            this.Filter.Exclude .= ','
        }

        if Activate {
            this.ActivateFilter()
        }
        ; Return the initial index so the calling function can calculate the indices that were assigned
        ; to the filter objects.
        return Start

        _Filter_1(Item) => !Item.Index
        _Filter_2(Item) => Item.Index
        _Filter_3(Item) => Item.HasOwnProp('Alt')
        _Filter_4(Item) => !Item.HasOwnProp('Alt')
        _Throw() {
            throw Error('The value passed to the ``Filter`` parameter is invalid.', -2
            , IsObject(Item) ? 'Type(Filter): ' Type(Item) : 'Filter: ' Item)
        }
    }

    DeactivateFilter() {
        this.FilterActive := 0
        this.__ItemIndex := this.__ObjCache.Index
        this.__InfoObjects := this.__ObjCache.Items
    }

    DeleteFilter(Key) {
        if IsObject(Key) {
            r := this.Filter.Get(Key.Index)
            this.Filter.Delete(Key.Index)
        } else if IsNumber(Key) {
            r := this.Filter.Get(Key)
            this.Filter.Delete(Key)
        } else if SubStr(Key, 1, 2) = 'Ex' {
            r := this.Filter.Exclude
            this.Filter.Delete(0)
            this.Filter.Exclude := ''
        } else {
            throw ValueError('Unexpected input.', -1, Key)
        }
        return r
    }

    CacheFilter(Name) {
        if !this.HasOwnProp('FilterCache') {
            this.FilterCache := Map()
        }
        this.DefineProp('CacheFilter', { Call: _Set })
        this.CacheFilter(Name)
        _Set(Self, Name) => Self.FilterCache.Set(Name, { Items: Self.__InfoObjects, Index: Self.__ItemIndex })
    }

    ClearFilter() {
        this.Filter.Clear()
        this.Filter.Exclude := ''
    }

    /**
     * @description - When the object's reference count reaches 0 its resources should be freed
     * automatically; calling `Dispose` is likely not necessary - I don't believe there's opportunity
     * for any circular references to prevent deleting the object. But it also wouldn't hurt to do
     * some preemptive cleanup. `Dispose` clears any container properties, sets their capacity to 0,
     * then deletes its own props.
     */
    Dispose() {
        this.__PropNameIndex.Clear()
        this.__PropNameIndex.Capacity := this.__InfoObjects.Capacity := this.__InfoObjects.Length := 0
        if this.HasOwnProp('__ObjCache') {
            this.__ObjCache.Index.Clear()
            this.__ObjCache.Items.Capacity := this.__ObjCache.Index.Capacity := 0
        }
        if this.HasOwnProp('Filter') && this.Filter is Map {
            this.Filter.Clear()
            this.Filter.Capacity := 0
        }
        for Prop in this.OwnProps() {
            this.DeleteProp(Prop)
        }
    }

    GetProxy(ProxyType) {
        switch ProxyType, 0 {
            case '1': return PropsInfo.Proxy_Array(this)
            case '2': return PropsInfo.Proxy_Map(this)
        }
        throw Error('The input ``ProxyType`` must be ``1`` or ``2``.', -1
        , IsObject(ProxyType) ? 'Type(ProxyType): '  Type(ProxyType) : ProxyType)
    }

    Get(Key) {
        ; This is overridden
    }

    GetFilteredItems(Container?, Function?) {
        if IsSet(Container) {
            if Container is Array {
                Set := _Set_Array
                GetCount := () => Container.Length
            } else if Container is Map {
                Set := _Set_Map
                GetCount := () => Container.Count
            } else {
                throw Error('Unexpected container type.', -1, 'Type(Container) == ' Type(Container))
            }
        } else {
            Container := Map()
            Set := _Set_Map
            GetCount := () => Container.Count
            Flag_MakePropsInfo := true
        }
        Source := this.FilterActive ? this.__ObjCache.Items.Length : this.__InfoObjects.Length
        Container.Capacity := Source.Length
        if IsSet(Function) {
            for PropInfo in Source {
                if Function(PropInfo) {
                    continue
                }
                Set(PropInfo)
            }
        } else if this.HasOwnProp('Filter') {
            if this.Filter.Exclude {
                this.Filter.Set(0, _Exclude)
            }
            for PropInfo in Source {
                for FilterIndex, FilterObj in Filter {
                    if FilterObj(PropInfo) {
                        continue
                    }
                }
                Set(PropInfo)
            }
        }
        Container.Capacity := GetCount()
        return IsSet(Flag_MakePropsInfo) ? PropsInfo(Container) : Result

        _Exclude(PropInfo) {
            return InStr(this.Filter.Exclude, ',' PropInfo.Name ',')
        }
        _Set_Array(PropInfo) => Container.Push(PropInfo)
        _Set_Map(PropInfo) => Container.Set(PropInfo.Name, PropInfo)
    }

    Has(Key) {
        return IsNumber(Key) ? this.__InfoObjects.Has(Key) : this.__PropNameIndex.Has(Name)
    }

    Count => this.__PropNameIndex.Count
    Length => this.__InfoObjects.Length
    Capacity => this.__PropNameIndex.Capacity
    CaseSense => this.__PropNameIndex.CaseSense
    Default => this.__PropNameIndex.Default

    StringMode {
        Get => this.__StringMode
        Set {
            if Value {
                this.DefineProp('__StringMode', { Value: 1 })
                this.DefineProp('Get', { Call: this.__ItemGet_StringMode })
            } else {
                this.DefineProp('__StringMode', { Value: 0 })
                this.DefineProp('Get', { Call: this.__ItemGet_Bitypic })
            }
        }
    }

    __Enum(VarCount) {
        i := 0
        return this.__StringMode ? _Enum_StringMode_%VarCount% : _Enum_%VarCount%

        _Enum_1(&PropInfo) {
            if ++i > this.__InfoObjects.Length {
                return 0
            }
            PropInfo := this.__InfoObjects[i]
            return 1
        }
        _Enum_2(&Prop, &PropInfo) {
            if ++i > this.__InfoObjects.Length {
                return 0
            }
            PropInfo := this.__InfoObjects[i].Name
            Prop := PropInfo.Name
            return 1
        }
        _Enum_StringMode_1(&Prop) {
            if ++i > this.__InfoObjects.Length {
                return 0
            }
            Prop := this.__InfoObjects[i].Name
            return 1
        }
        _Enum_StringMode_2(&Index, &Prop) {
            if ++i > this.__InfoObjects.Length {
                return 0
            }
            Index := i
            Prop := this.__InfoObjects[i].Name
            return 1
        }
    }

    __Item[Key] => this.Get(Key)

    __ItemGet_StringMode(Key) {
        if !IsNumber(Key) {
            ; Because if you already have the property name, there's no reason to find it in the array.
            throw TypeError('Invalid input. While the ``PropsInfo`` object is in string mode,'
            ' items can only be accessed using numeric indices.', -1)
        }
        return this.__InfoObjects[Key].Name
    }
    __ItemGet_Bitypic(Key) {
        return this.__InfoObjects[IsNumber(Key) ? Key : this.__PropNameIndex.Get(Key)]
    }

    class Filter {
        __New(Function, Index) {
            this.DefineProp('Call', { Call: (Self, Item) => (Function := this.Function)(Item) })
            this.Function := Function
            this.Index := Index
        }
    }

    class Proxy_Map extends PropsInfo.Proxy_Base {
        static __New() {
            if this.Prototype.__Class == 'PropsInfo.Proxy_Map' {
                this.Prototype.DefineProp('__Class', { Value: 'Map' })
            }
        }
        Has(Key) => this.Client.__PropNameIndex.Has(Key)
        CaseSense => this.Client.__PropNameIndex.CaseSense
        Count => this.Client.__PropNameIndex.Count
        Default => this.Client.__PropNameIndex.Default
        Capacity => this.Client.__PropNameIndex.Capacity
    }
    class Proxy_Array extends PropsInfo.Proxy_Base {
        static __New() {
            if this.Prototype.__Class == 'PropsInfo.Proxy_Array' {
                this.Prototype.DefineProp('__Class', { Value: 'Array' })
            }
        }
        Has(Key) => this.Client.__InfoObjects.Has(Key)
        Default => this.Client.__InfoObjects.Default
        Length => this.Client.__InfoObjects.Length
        Capacity => this.Client.__InfoObjects.Capacity
    }
    class Proxy_Base {
        __New(Client) {
            this.Client := Client
        }
        Get(Key) => this.Client.Get(Key)
        __Enum(VarCount) => this.Client.__Enum(VarCount)
        __Item[Key] => this.Client.__Item[Key]
    }
}

class PropsInfoItem {
    static __New() {
        if this.Prototype.__Class == 'PropsInfoItem' {
            this.Prototype.__TypeNames := ['Call', 'Get', 'Get_Set', 'Set', 'Value']
            ObjSetBase(this.ItemBase := {}, this.Prototype)
        }
    }

    DefineTypeIndex() {
        if this.HasOwnProp('Call') {
            this.DefineProp('TypeIndex', { Value: 1 })
        } else if this.HasOwnProp('Get') {
            if this.HasOwnProp('Set') {
                this.DefineProp('TypeIndex', { Value: 3 })
            } else {
                this.DefineProp('TypeIndex', { Value: 2 })
            }
        } else if this.HasOwnProp('Set') {
            this.DefineProp('TypeIndex', { Value: 4 })
        } else if this.HasOwnProp('Value') {
            this.DefineProp('TypeIndex', { Value: 5 })
        } else {
            throw Error('Unable to process unexpected value.', -1)
        }
        ; Overwrite with a value property so this is only processed once
        return this.TypeIndex
    }

    GetFunc(&Set?) {
        switch this.TypeIndex {
            case 1: return this.Call
            case 2: return this.Get
            case 3:
                Set := this.Set
                return this.Get
            case 4: return this.Set
            case 5: return ''
        }
        return
    }

    Type => this.__TypeNames[this.TypeIndex]
    TypeIndex => this.DefineTypeIndex()

    __SetAlt(Item) {
        this.Alt := [Item]
        this.DefineProp('__SetAlt', { Call: (Self, Item) => Self.Alt.Push(Item) })
    }
}
