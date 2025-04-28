/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/
    Author: Nich-Cebolla
    Version: 1.2.0
    License: MIT
*/

; Dependencies:
#Include Inheritance_Shared.ahk
#Include GetBaseObjects.ahk

/**
 * @description - Constructs a list of properties and details about the properties for both
 * inherited and own properties for the input object. This function returns a `PropsInfo` object,
 * which is a flexible solution for cases when a project would benefit from being able to quickly
 * obtain a list of all of an object's properties, and/or filter those properties.
 *
 * In this documentation, an instance of `PropsInfo` is referred to as either "a `PropsInfo` object"
 * or `PropsInfoObj`. An instance of `PropsInfoItem` is referred to as either "a `PropsInfoItem` object"
 * or `InfoItemObj`.
 *
 * See example-Inheritance.ahk for some examples and use cases.
 * @param {Object} Obj - The object from which to get the properties.
 * @param {+Integer|String} [StopAt='-Object'] - If an integer, the number of base objects to traverse up
 * the inheritance chain. If a string, the name of the class to stop at. See {@link GetBaseObjects}
 * for full details about this parameter.
 * @param {String} [Exclude=''] - A comma-delimited, case-insensitive list of properties to exclude.
 * For example: "Length,Capacity,__Item".
 * @param {VarRef} [OutBaseObjectsList] - A variable that will receive a reference to the array of
 * base objects that is generated during the function call. When analyzing or responding to the
 * `PropsInfoItem` objects, you can retrieve the base object that owns the property that produced
 * any given `PropsInfoItem` object by using the `Index` property. See the example script for
 * illustration.
 * @returns {PropsInfo} - `PropsInfo` objects are designed to be a flexible solution for accessing
 * and/or analyzing an object's properties, including inherited properties. Whereas `OwnProps` only
 * iterates an objects' own properties, `PropsInfo` objects can perform these functions for both
 * inherited and own properties:
 * - Produce a list of all property names (array of strings).
 * - Produce a `Map` where the key is the property name and the object is a `PropsInfoItem` object
 * for each property.
 * - Produce an array of `PropsInfoItem` objects.
 * - Be passed to a function that expects an iterable object like any of the three above bullet points.
 * - Filter the properties according to any condition.
 *
 * `PropsInfoitem` objects are modified descriptor objects. See:
 * {@link https://www.autohotkey.com/docs/v2/lib/Object.htm#GetOwnPropDesc}.
 * After getting the descriptor object, `GetPropsInfo` changes the descriptor object's base, converting
 * it to a `PropsInfoItem` object and exposing additional properties. In addition to their original
 * properties `Call` or `Value` or one or both of `Get` and `Set`, the following are available:
 * @property {Integer} Index - The index position of the object which owns the property in the
 * inheritance chain, where index 0 is the input object, 1 is the input object's base, 2 is the next
 * base object, etc. The `Index` is aligned with `OutBaseObjectsList`, so to get the object
 * associated with the property you can call `BaseObjectsList[PropsInfoObj.Get(PropName).Index]`.
 * @property {String} Name - The name of the property.
 * @property {String} Type - `Type` will return one of these, depending on the type of function:
 * - Call
 * - Get
 * - Get_Set
 * - Set
 * - Value
 * @property {Array} [Alt] - If only one object in the inheritance chain owns a property by the
 * name, then `Alt` is unset (`HasMethod(InfoItem, 'Alt') == false`). If there are multiple objects
 * that own a property by the same name, `Alt` is set with an array of `PropsInfoItem` objects. The
 * objects within the `Alt` array never have an `Alt` property.
 *
 * The top-level `PropsInfoItem` object is always associated with the input object's own property,
 * or associated with the base object from which the input object inherited the property. The example
 * script example-Inheritance.ahk illustrates this concept.
 *
 */
GetPropsInfo(Obj, StopAt := '-Object', Exclude := '', IncludeBaseProp := true, &OutBaseObjectsList?) {
    OutBaseObjectsList := GetBaseObjects(Obj, &Count, StopAt)
    OutBaseObjectsList.Root := Obj
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
    if IncludeBaseProp {
        ObjSetBase(ItemBase := { Name: 'Base' }, PropsInfoItem.ItemBase)
        ObjSetBase(BasePropItem := { Value: Obj.Base }, ItemBase)
        BasePropItem.Index := 0
        Container.Set('Base', BasePropItem)
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
        if IncludeBaseProp {
            ObjSetBase(Item := { Value: Obj.Base }, BasePropItem.Base)
            Item.Index := i
            BasePropItem.__SetAlt(Item)
        }
    }
    for s in StrSplit(Exclude, ',') {
        Container.Delete(Trim(s, '`s`t'))
    }
    return PropsInfo(Container)
}

/**
 * @class
 * @description - The return value for `GetPropsInfo`. See the parameter hint above `GetPropsInfo` for
 * information.
 */
class PropsInfo {
    static __New() {
        if this.Prototype.__Class == 'PropsInfo' {
            this.Prototype.DefineProp('Filter', { Value: '' })
            this.Prototype.DefineProp('FilterActive', { Value: 0 })
            this.Prototype.DefineProp('__StringMode', { Value: 0 })
            this.Prototype.DefineProp('Get', this.Prototype.GetOwnPropDesc('__ItemGet_Bitypic'))
        }
    }

    /**
     * @description - This is intended to be called by `GetPropsInfo`.
     * @param {Map} Container - The keys are property names and the values are `PropsInfoItem` objects.
     */
    __New(Container) {
        this.__InfoIndex := Map()
        this.__InfoIndex.Default := this.__InfoIndex.CaseSense := false
        this.__InfoItems := []
        this.__InfoItems.Capacity := this.__InfoIndex.Capacity := Container.Count
        for Prop, PropInfo in Container {
            this.__InfoItems.Push(PropInfo)
            this.__InfoIndex.Set(Prop, A_Index)
        }
    }

    /**
     * @description - When the object's reference count reaches 0 its resources should be freed
     * automatically; calling `Dispose` is likely not necessary - I don't believe there's opportunity
     * for any circular references to prevent deleting the object. But it also wouldn't hurt to do
     * some preemptive cleanup. `Dispose` clears any container properties, sets their capacity to 0,
     * then deletes its own props.
     */
    Dispose() {
        this.__InfoIndex.Clear()
        this.__InfoIndex.Capacity := this.__InfoItems.Capacity := this.__InfoItems.Length := 0
        if this.HasOwnProp('__PrimaryContainers') {
            this.__PrimaryContainers.Index.Clear()
            this.__PrimaryContainers.Items.Capacity := this.__PrimaryContainers.Index.Capacity := 0
        }
        if this.Filter is Map {
            this.Filter.Clear()
            this.Filter.Capacity := 0
        }
        for Prop in this.OwnProps() {
            this.DeleteProp(Prop)
        }
    }

    /**
     * @description - Activates the filter, setting property `PropsInfoObj.FilterActive := 1`. While
     * `PropsInfoObj.FilterActive == 1`, the values returned by `Get`, `__Item`, and `__Enum` will
     * be filtered. Note that `GetFilteredProps` does not adhere to `FilterActive` and always processes
     * the original array.
     * @param {String} [CacheName] - If set, the filter will be cached under this name. Else, the
     * filter is not cached.
     * @throws {UnsetItemError} - If no filters have been added.
     */
    FilterActivate(CacheName?) {
        if !this.Filter {
            throw UnsetItemError('No filters have been added.', -1)
        }
        if !this.FilterActive {
            this.__PrimaryContainers := { Index: this.__InfoIndex, Items: this.__InfoItems }
        }
        Filter := this.Filter
        this.__InfoIndex := Map()
        this.__InfoItems := []
        this.__InfoIndex.Capacity := this.__InfoItems.Capacity := this.__PrimaryContainers.Index.Count
        if Filter is Map {
            for PropInfo in this.__PrimaryContainers.Items {
                for FilterIndex, FilterObj in Filter {
                    if FilterObj(PropInfo) {
                        continue 2
                    }
                }
                this.__InfoItems.Push(PropInfo)
                this.__InfoIndex.Set(PropInfo.Name, this.__InfoItems.Length)
            }
        } else {
            for PropInfo in this.__PrimaryContainers.Items {
                if Filter(PropInfo) {
                    continue
                }
                this.__InfoItems.Push(PropInfo)
                this.__InfoIndex.Set(PropInfo.Name, this.__InfoItems.Length)
            }
        }
        this.__InfoIndex.Capacity := this.__InfoItems.Capacity := this.__InfoItems.Length
        this.DefineProp('FilterActive', { Value: 1 })
    }

    /**
     * @description - Activates a cached filter.
     * @param {String} Name - The name of the filter to activate.
     */
    FilterActivateFromCache(Name) {
        if !this.FilterActive {
            this.FilterActive := 1
            this.__PrimaryContainers := { Index: this.__InfoIndex, Items: this.__InfoItems }
        }
        O := this.__FilterCache.Get(Name)
        this.__InfoIndex := O.Index
        this.__InfoItems := O.Items
    }

    /**
     * @description - Adds a filter to `PropsInfoObj.Filter`.
     * @param {Boolean} [Activate=true] - If true, the filter is activated immediately.
     * @param {...String|Func|Object} Filters - The filters to add. This parameter is variadic.
     * There are four built-in filters which you can include by integer:
     * - 1: Exclude all items that are not own properties of the root object.
     * - 2: Exclude all items that are own properties of the root object.
     * - 3: Exclude all items that have an `Alt` property, i.e. exclude all properties that have
     * multiple owners.
     * - 4: Exclude all items that do not have an `Alt` property, i.e. exclude all properties that
     * have only one owner.
     *
     * In addition to the above, you can pass any of the following:
     * - A string value as a property name to exclude, or a comma-delimited list of property
     * names to exclude.
     * - A `Func` object, `BoundFunc` or `Closure`.
     * - An object with a `Call` method.
     * - An object with a `__Call` method.
     */
    FilterAdd(Activate := true, Filters*) {
        if !this.Filter {
            this.DefineProp('Filter', { Value: Map() })
            this.Filter.Exclude := ''
            this.__FilterIndex := 6
        }
        start := this.__FilterIndex
        for Item in Filters {
            if IsObject(Item) {
                if Item is Func || HasMethod(Item, 'Call') || HasMethod(Item, '__Call') {
                    this.Filter.Set(this.__FilterIndex, PropsInfo.Filter(Item, this.__FilterIndex++))
                } else {
                    _Throw()
                }
            } else {
                switch Item, 0 {
                    case '1', '2', '3', '4':
                        this.Filter.Set(Item, PropsInfo.Filter(_Filter_%Item%, Item))
                    default:
                        this.Filter.Exclude .= ',' Item
                }
            }
        }
        if this.Filter.Exclude {
            ; Be ensuring every name has a comma on either side of it, we can check the names by
            ; using `InStr(Filter.Exclude, ',' Prop ',')` which should perform better than RegExMatch.
            this.Filter.Exclude .= ','
            this.Filter.Exclude := RegExReplace(this.Filter.Exclude, ',+', ',')
            this.Filter.Set(5, PropsInfo.Filter(_Exclude, 5))
        }

        if Activate {
            this.FilterActivate()
        }
        ; Return the initial index so the calling function can calculate the indices that were assigned
        ; to the filter objects.
        return Start

        _Exclude(PropInfo) {
            return InStr(this.Filter.Exclude, PropInfo.Name ',')
        }
        _Filter_1(Item) => !Item.Index
        _Filter_2(Item) => Item.Index
        _Filter_3(Item) => Item.HasOwnProp('Alt')
        _Filter_4(Item) => !Item.HasOwnProp('Alt')
        _Throw() {
            throw Error('The value passed to the ``Filter`` parameter is invalid.', -2
            , IsObject(Item) ? 'Type(Filter): ' Type(Item) : 'Filter: ' Item)
        }
    }

    FilterCache(Name) {
        if !this.HasOwnProp('__FilterCache') {
            this.__FilterCache := Map()
        }
        this.DefineProp('FilterCache', { Call: _Set })
        this.FilterCache(Name)
        _Set(Self, Name) => Self.__FilterCache.Set(Name, { Items: Self.__InfoItems, Index: Self.__InfoIndex })
    }

    FilterClear() {
        this.Filter.Clear()
        this.Filter.Exclude := ''
    }

    FilterClearCache() {
        this.__FilterCache.Clear()
        this.__FilterCache.Capacity := 0
    }

    FilterDeactivate(CacheName?) {
        if !this.FilterActive {
            throw Error('The filter is not currently active.', -1)
        }
        if IsSet(CacheName) {
            this.FilterCache(CacheName)
        }
        this.__InfoIndex := this.__PrimaryContainers.Index
        this.__InfoItems := this.__PrimaryContainers.Items
        this.FilterActive := 0
    }

    FilterDelete(Key) {
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

    FilterDeleteFromCache(Name) {
        this.__FilterCache.Delete(Name)
    }

    FilterRemoveFromExclude(Name) {
        if !this.Filter {
            throw UnsetItemError('No filters have been added.', -1)
        }
        Filter := this.Filter
        for _name in StrSplit(Name, ',') {
            Filter.Exclude := StrReplace(Filter.Exclude, ',' _name ',', '')
        }
    }

    Get(Key) {
        ; This is overridden
    }

    GetIndex(Name) {
        return this.__InfoIndex.Get(Name)
    }

    GetProxy(ProxyType) {
        switch ProxyType, 0 {
            case '1': return PropsInfo.Proxy_Array(this)
            case '2': return PropsInfo.Proxy_Map(this)
        }
        throw Error('The input ``ProxyType`` must be ``1`` or ``2``.', -1
        , IsObject(ProxyType) ? 'Type(ProxyType): '  Type(ProxyType) : ProxyType)
    }

    GetFilteredProps(Container?, Function?) {
        if IsSet(Container) {
            if Container is Array {
                Set := _Set_Array
                GetCount := () => Container.Length
            } else if Container is Map {
                if Container.CaseSense != 'Off' {
                    throw Error('CaseSense must be set to ``false``.', -1)
                }
                Set := _Set_Map
                GetCount := () => Container.Count
            } else {
                throw Error('Unexpected container type.', -1, 'Type(Container) == ' Type(Container))
            }
        } else {
            Container := Map()
            Container.CaseSense := false
            Set := _Set_Map
            GetCount := () => Container.Count
            Flag_MakePropsInfo := true
        }
        Source := this.FilterActive ? this.__PrimaryContainers.Items : this.__InfoItems
        Container.Capacity := Source.Length
        if IsSet(Function) || ((Function := this.Filter) && Function is Func) {
            for PropInfo in Source {
                if Function(PropInfo) {
                    continue
                }
                Set(PropInfo)
            }
        } else if this.Filter {
            if this.Filter.Exclude {
                this.Filter.Set(0, _Exclude)
            }
            for PropInfo in Source {
                for FilterIndex, FilterObj in this.Filter {
                    if FilterObj(PropInfo) {
                        continue
                    }
                }
                Set(PropInfo)
            }
        } else {
            throw UnsetItemError('No Filters have been added.', -1)
        }
        Container.Capacity := GetCount()
        return IsSet(Flag_MakePropsInfo) ? PropsInfo(Container) : Container

        _Exclude(PropInfo) {
            return InStr(this.Filter.Exclude, ',' PropInfo.Name ',')
        }
        _Set_Array(PropInfo) => Container.Push(PropInfo)
        _Set_Map(PropInfo) => Container.Set(PropInfo.Name, PropInfo)
    }

    Has(Key) {
        return IsNumber(Key) ? this.__InfoItems.Has(Key) : this.__InfoIndex.Has(Key)
    }

    ToArray(NamesOnly := false) {
        Result := []
        Result.Capacity := this.__InfoItems.Length
        if NamesOnly {
            for Item in this.__InfoItems {
                Result.Push(Item.Name)
            }
        } else {
            for Item in this.__InfoItems {
                Result.Push(Item)
            }
        }
        return Result
    }

    ToMap() {
        Result := Map()
        Result.Capacity := this.__InfoItems.Length
        for Item in this.__InfoItems {
            Result.Set(Item.Name, Item)
        }
        return Result
    }

    Capacity => this.__PropNameIndex.Capacity
    CaseSense => this.__PropNameIndex.CaseSense
    Count => this.__PropNameIndex.Count
    Default => this.__PropNameIndex.Default
    Length => this.__InfoItems.Length

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
            if ++i > this.__InfoItems.Length {
                return 0
            }
            PropInfo := this.__InfoItems[i]
            return 1
        }
        _Enum_2(&Prop, &PropInfo) {
            if ++i > this.__InfoItems.Length {
                return 0
            }
            PropInfo := this.__InfoItems[i]
            Prop := PropInfo.Name
            return 1
        }
        _Enum_StringMode_1(&Prop) {
            if ++i > this.__InfoItems.Length {
                return 0
            }
            Prop := this.__InfoItems[i].Name
            return 1
        }
        _Enum_StringMode_2(&Index, &Prop) {
            if ++i > this.__InfoItems.Length {
                return 0
            }
            Index := i
            Prop := this.__InfoItems[i].Name
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
        return this.__InfoItems[Key].Name
    }

    __ItemGet_Bitypic(Key) {
        return this.__InfoItems[IsNumber(Key) ? Key : this.__InfoIndex.Get(Key)]
    }

    class Filter {
        __New(Function, Index) {
            this.DefineProp('Call', { Call: _Filter })
            this.Function := Function
            this.Index := Index

            _Filter(Self, Item) {
                Function := this.Function
                return Function(Item)
            }
        }
        Name => this.Function.Name
    }

    class Proxy_Array extends PropsInfo.Proxy_Base {
        static __New() {
            if this.Prototype.__Class == 'PropsInfo.Proxy_Array' {
                this.Prototype.DefineProp('__Class', { Value: 'Array' })
            }
        }
        Has(Key) => this.Client.__InfoItems.Has(Key)
        Capacity => this.Client.__InfoItems.Capacity
        Default => this.Client.__InfoItems.Default
        Length => this.Client.__InfoItems.Length
    }

    class Proxy_Base {
        __New(Client) {
            this.Client := Client
        }
        Get(Key) => this.Client.Get(Key)
        __Enum(VarCount) => this.Client.__Enum(VarCount)
        __Item[Key] => this.Client.__Item[Key]
    }

    class Proxy_Map extends PropsInfo.Proxy_Base {
        static __New() {
            if this.Prototype.__Class == 'PropsInfo.Proxy_Map' {
                this.Prototype.DefineProp('__Class', { Value: 'Map' })
            }
        }
        Has(Key) => this.Client.__PropNameIndex.Has(Key)
        Capacity => this.Client.__PropNameIndex.Capacity
        CaseSense => this.Client.__PropNameIndex.CaseSense
        Count => this.Client.__PropNameIndex.Count
        Default => this.Client.__PropNameIndex.Default
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

    GetValue(&OutValue, Obj?) {
        switch this.TypeIndex {
            case 1, 4: return '' ; Call, Set
            case 2, 3:
                try {
                    OutValue := (Get := this.Get)(Obj) ; Get
                    return 1
                }
            case 5:
                OutValue := this.Value
                return 1
        }
    }

    Type => this.__TypeNames[this.TypeIndex]
    TypeIndex => this.DefineTypeIndex()

    __SetAlt(Item) {
        this.Alt := [Item]
        this.DefineProp('__SetAlt', { Call: (Self, Item) => Self.Alt.Push(Item) })
    }
}

