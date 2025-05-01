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
 *
 * @param {Object} Obj - The object from which to get the properties.
 * @param {+Integer|String} [StopAt=GPI_STOP_AT_DEFAULT ?? '-Object'] - If an integer, the number of
 * base objects to traverse up the inheritance chain. If a string, the name of the class to stop at.
 * You can define a global variable `GPI_STOP_AT_DEFAULT` to change the default value. If
 * GPI_STOP_AT_DEFAULT is unset, the default value is '-Object', which directs `GetPropsInfo` to
 * include properties owned by objects up to but not including `Object.Prototype`.
 * @see {@link GetBaseObjects} for full details about this parameter.
 * @param {String} [Exclude=''] - A comma-delimited, case-insensitive list of properties to exclude.
 * For example: "Length,Capacity,__Item".
 * @param {VarRef} [OutBaseObjList] - A variable that will receive a reference to the array of
 * base objects that is generated during the function call.
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
 * it to a `PropsInfoItem` object and exposing additional properties. See the parameter hints above
 * each property for details.
 */
GetPropsInfo(Obj, StopAt := GPI_STOP_AT_DEFAULT ?? '-Object', Exclude := '', IncludeBaseProp := true, &OutBaseObjList?) {
    OutBaseObjList := GetBaseObjects(Obj, StopAt)
    Container := Map()
    Container.Default := Container.CaseSense := false
    for s in StrSplit(Exclude, ',') {
        Container.Set(Trim(s, '`s`t'), -1)
    }

    PropsInfoItemBase := PropsInfoItem(Obj)

    for Prop in ObjOwnProps(Obj) {
        if Container.Get(Prop) {
            ; Prop is in `Exclude`
            continue
        }
        ObjSetBase(ItemBase := {
            /**
             * The property name.
             * @memberof PropsInfoItem
             * @instance
             */
                Name: Prop
            /**
             * `Count` gets incremented by one for each object which owns a property by the name
             * `Name`.
             * @memberof PropsInfoItem
             * @instance
             */
              , Count: 1
            }
          , PropsInfoItemBase)
        ObjSetBase(Item := ObjGetOwnPropDesc(Obj, Prop), ItemBase)
        Item.Index := 0
        Container.Set(Prop, Item)
    }
    if IncludeBaseProp {
        ObjSetBase(ItemBase := { Name: 'Base', Count: 1 }, PropsInfoItemBase)
        ObjSetBase(BasePropItem := { Value: Obj.Base }, ItemBase)
        BasePropItem.Index := 0
        Container.Set('Base', BasePropItem)
    }
    i := 0
    for b in OutBaseObjList {
        i++
        for Prop in ObjOwnProps(b) {
            if r := Container.Get(Prop) {
                if r == -1 {
                    continue
                }
                ; It's an existing property
                ObjSetBase(Item := ObjGetOwnPropDesc(b, Prop), r.Base)
                Item.Index := i
                r.__SetAlt(Item)
                r.Base.Count++
            } else {
                ; It's a new property
                ObjSetBase(ItemBase := { Name: Prop, Count: 1 }, PropsInfoItemBase)
                ObjSetBase(Item := ObjGetOwnPropDesc(b, Prop), ItemBase)
                Item.Index := i
                Container.Set(Prop, Item)
            }
        }
        if IncludeBaseProp {
            ObjSetBase(Item := { Value: Obj.Base }, BasePropItem.Base)
            Item.Index := i
            BasePropItem.__SetAlt(Item)
            BasePropItem.Base.Count++
        }
    }
    for s in StrSplit(Exclude, ',') {
        Container.Delete(Trim(s, '`s`t'))
    }
    return PropsInfo(Container, PropsInfoItemBase)
}

/**
 * @class
 * @description - The return value for `GetPropsInfo`. See the parameter hint above `GetPropsInfo`
 * for information.
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
     * @classdesc - The constructor is intended to be called from `GetPropsInfo`.
     * @param {Map} Container - The keys are property names and the values are `PropsInfoItem` objects.
     * @param {PropsInfoItem} PropsInfoItemBase - The base object shared by all instances of
     * `PropsInfoItem` associated with this `PropsInfo` object.
     * @returns {PropsInfo} - The `PropsInfo` instance.
     */
    __New(Container, PropsInfoItemBase) {
        this.__InfoIndex := Map()
        this.__InfoIndex.Default := this.__InfoIndex.CaseSense := false
        this.__InfoItems := []
        this.__InfoItems.Capacity := this.__InfoIndex.Capacity := Container.Count
        for Prop, PropInfo in Container {
            this.__InfoItems.Push(PropInfo)
            this.__InfoIndex.Set(Prop, A_Index)
        }
        this.__PropsInfoItemBase := PropsInfoItemBase
    }

    /**
     * @description - Performs these actions:
     * - Deletes the `Root` property from the `PropsInfoItem` object that is used as the base for
     * all `PropsInfoItem` objects associated with this `PropsInfo` object. This action invalidates
     * some of the `PropsInfoItem` objects' methods and properties, and they should be considered
     * effectively disposed.
     * - Clears the `PropsInfo` object's container properties and sets their capacity to 0
     * - Deletes the `PropsInfo` object's own properties.
     */
    Dispose() {
        this.__PropsInfoItemBase.DeleteProp('Root')
        this.__InfoIndex.Clear()
        this.__InfoIndex.Capacity := this.__InfoItems.Capacity := 0
        if this.HasOwnProp('__PrimaryContainers') {
            this.__PrimaryContainers.Index.Clear()
            this.__PrimaryContainers.Index.Capacity :=
            this.__PrimaryContainers.Items.Capacity := 0
        }
        if this.Filter is Map {
            this.Filter.Clear()
            this.Filter.Capacity := 0
        }
        if this.HasOwnProp('__FilterCache') {
            this.__FilterCache.Clear()
            this.__FilterCache.Capacity := 0
        }
        for Prop in this.OwnProps() {
            this.DeleteProp(Prop)
        }
        this.DefineProp('Dispose', { Call: (*) => '' })
    }

    /**
     * @description - Activates the filter, setting property `PropsInfoObj.FilterActive := 1`. While
     * `PropsInfoObj.FilterActive == 1`, the values returned by the object's methods and properties
     * will be filtered. Note that `GetFilteredProps` does not adhere to `FilterActive` and always
     * processes the original array.
     * @param {String} [CacheName] - If set, the filtered containers will be cached under this name.
     * Else, the containers are not cached.
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
        }
        this.__InfoIndex.Capacity := this.__InfoItems.Capacity := this.__InfoItems.Length
        this.DefineProp('FilterActive', { Value: 1 })
        if IsSet(CacheName) {
            this.FilterCache(CacheName)
        }
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
     * - A `Func`, `BoundFunc` or `Closure`.
     * - An object with a `Call` method.
     * - An object with a `__Call` method.
     *
     * Function objects should accept the `PropsInfoItem` object as its only parameter, and
     * should return a nonzero value to exclude the property. To keep the property, return zero
     * or nothing.
     * @returns {Integer} - If at least one custom filter is added (i.e. a function object or
     * callable object was added), the index that was assignedd to the filter. Indices begin from 5
     * and increment by 1 for each custom filter added. Once an index is used, it will never be used
     * by the `PropsInfo` object again. You can use the index to later delete a filter if needed.
     * The following built-in indices always refer to the same function:
     * - 0: The function which excludes by property name.
     * - 1 through 4: The other built-in filters described above.
     */
    FilterAdd(Activate := true, Filters*) {
        if !this.Filter {
            this.DefineProp('Filter', { Value: Map() })
            this.Filter.Exclude := ''
            this.__FilterIndex := 5
        }
        for Item in Filters {
            if IsObject(Item) {
                if Item is Func || HasMethod(Item, 'Call') || HasMethod(Item, '__Call') {
                    if !IsSet(Start) {
                        Start := this.__FilterIndex
                    }
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
                        FlagExclude := true
                }
            }
        }
        if IsSet(FlagExclude) {
            ; Be ensuring every name has a comma on both sides, we can check the names by
            ; using `InStr(Filter.Exclude, ',' Prop ',')` which should perform better than RegExMatch.
            this.Filter.Exclude .= ','
            this.Filter.Set(0, PropsInfo.Filter(_Exclude, 0))
        }

        if Activate {
            this.FilterActivate()
        }
        ; If a custom filter is added, return the start index so the caller function can keep track.
        return Start ?? ''

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
        , IsObject(ProxyType) ? 'Type(ProxyType) == '  Type(ProxyType) : ProxyType)
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

    __Delete() {
        this.Dispose()
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

    class Proxy_Array extends Array {
        static __New() {
            if this.Prototype.__Class == 'PropsInfo.Proxy_Array' {
                this.Prototype.DefineProp('__Class', { Value: 'Array' })
            }
        }
        __New(Client) {
            this.DefineProp('Client', { Value: Client })
        }
        Get(Index) => this.Client.Get(Index)
        Has(Index) => this.Client.__InfoItems.Has(Index)
        __Enum(VarCount) => this.Client.__Enum(VarCount)
        Capacity {
            Get => this.Client.__InfoItems.Capacity
            Set => this.Client.__InfoItems.Capacity := Value
        }
        Default {
            Get => this.Client.__InfoItems.Default
            Set => this.Client.__InfoItems.Default := Value
        }
        Length {
            Get => this.Client.__InfoItems.Length
            Set => this.Client.__InfoItems.Length := Value
        }
        __Item[Index] {
            Get => this.Client.__Item[Index]
            Set => this.Client.__Item[Index] := Value
        }
        __Get(Name, Params) {
            if Params.Length {
                return this.Client.%Name%[Params*]
            } else {
                return this.Client.%Name%
            }
        }
        __Set(Name, Params, Value) {
            if Params.Length {
                return this.Client.%Name%[Params*] := Value
            } else {
                return this.Client.%Name% := Value
            }
        }
        __Call(Name, Params) {
            if Params.Length {
                return this.Client.%Name%(Params*)
            } else {
                return this.Client.%Name%()
            }
        }
    }

    class Proxy_Map extends Map {
        static __New() {
            if this.Prototype.__Class == 'PropsInfo.Proxy_Map' {
                this.Prototype.DefineProp('__Class', { Value: 'Map' })
            }
        }
        __New(Client) {
            this.DefineProp('Client', { Value: Client })
        }
        Get(Key) => this.Client.Get(Key)
        Has(Key) => this.Client.__PropNameIndex.Has(Key)
        __Enum(VarCount) => this.Client.__Enum(VarCount)
        Capacity {
            Get => this.Client.__PropNameIndex.Capacity
            Set => this.Client.___PropNameIndex.Capacity := Value
        }
        CaseSense => this.Client.__PropNameIndex.CaseSense
        Count => this.Client.__PropNameIndex.Count
        Default {
            Get => this.Client.__PropNameIndex.Default
            Set => this.Client.__PropNameIndex.Default := Value
        }
        __Item[Key] {
            Get => this.Client.__Item[Key]
            Set => this.Client.__Item[Key] := Value
        }
        __Get(Name, Params) {
            if Params.Length {
                return this.Client.%Name%[Params*]
            } else {
                return this.Client.%Name%
            }
        }
        __Set(Name, Params, Value) {
            if Params.Length {
                return this.Client.%Name%[Params*] := Value
            } else {
                return this.Client.%Name% := Value
            }
        }
        __Call(Name, Params) {
            if Params.Length {
                return this.Client.%Name%(Params*)
            } else {
                return this.Client.%Name%()
            }
        }
    }
}

/**
 * For each base object in the input object's inheritance chain (up to the stopping point), the base
 * object's own properties are iterated, generating a `PropsInfoItem` object for each property
 * (unless the property is excluded).
 * @class
 */
class PropsInfoItem {
    static __New() {
        if this.Prototype.__Class == 'PropsInfoItem' {
            this.Prototype.__KindNames := ['Call', 'Get', 'Get_Set', 'Set', 'Value']
        }
    }

    /**
     * @description - Each time `GetPropsInfo` is called, a new `PropsInfoItem` is created.
     * The `PropsInfoItem` object is used as the base object for all further `PropsInfoItem`
     * instances generated within that `GetPropsInfo` function call (and only that function call),
     * allowing properties to be defined once on the base and shared by the rest.
     * `PropsInfoItem.Prototype.__New` is not intended to be called directly.
     * @param {Object} - The objecet that was passed to `GetPropsInfo`.
     * @returns {PropsInfoItem} - The `PropsInfoItem` instance.
     */
    __New(Root) {
        this.Root := Root
    }

    /**
     * @description - Returns the function object, optionally binding an object to the hidden `this`
     * parameter. See {@link https://www.autohotkey.com/docs/v2/Objects.htm#Custom_Classes_method}
     * for information about the hidden `this`.
     * @param {VarRef} [OutSet] - A variable that will receive the `Set` function if this object
     * has both `Get` and `Set`. If this object only has a `Set` property, the `Set` function object
     * is returned as the return value and `OutSet` remains unset.
     * @param {Integer} Flag_Bind - One of the following values:
     * - 0: The function objects are returned as-is, with the hidden `this` parameter still exposed.
     * - 1: The object that was passed to `GetPropsInfo` is bound to the function object(s).
     * - 2: The owner of the property that produced this `PropsInfoItem` object is bound to the
     * function object(s).
     * @returns {Func|BoundFunc} - The function object.
     */
    GetFunc(&OutSet?, Flag_Bind := 0) {
        switch Flag_Bind, 0 {
            case '0':
                switch this.KindIndex {
                    case 1: return this.Call
                    case 2: return this.Get
                    case 3:
                        Set := this.Set
                        return this.Get
                    case 4: return this.Set
                    case 5: return ''
                }
            case '1': return _Proc(this.Root)
            case '2': return _Proc(this.Owner)
            default: throw ValueError('Invalid value passed to the ``Flag_Bind`` parameter.', -1
            , IsObject(Flag_Bind) ? 'Type(Flag_Bind) == ' Type(Flag_Bind) : Flag_Bind)
        }

        _Proc(Obj) {
            switch this.KindIndex {
                case 1: return this.Call.Bind(Obj)
                case 2: return this.Get.Bind(Obj)
                case 3:
                    Set := this.Set.Bind(Obj)
                    return this.Get.Bind(Obj)
                case 4: return this.Set.Bind(Obj)
                case 5: return ''
            }
        }
    }

    /**
     * @description - Returns the owner of the property which produced this `PropsInfoItem` object.
     * @returns {Object}
     */
    GetOwner() {
        b := this.Root
        loop this.Index {
            b := b.Base
        }
        return b
    }

    /**
     * @description - If this is associated with a value property, provides the value that the property
     * had at the time this `PropsInfoItem` object was created. If this is associated with a dynamic
     * property with a `Get` accessor, attempts to provides the value.
     * @param {VarRef} OutValue - Because `GetValue` is expected to sometimes fail, the property's
     * value is set to the `OutValue` variable, and a status code is returned by the function.
     * @param {Boolean} [FromOwner=false] - When true, the object that produced this `PropsInfoItem`
     * object is passed as the first parameter to the `Get` accessor. When false, the root object
     * (the object passed to the `GetPropsInfo` call) is passed as the first parameter to the `Get`
     * accessor.
     * @returns {Integer} - One of these status codes:
     * - An empty string: The value was successfully accessed and `OutValue` is the value.
     * - 1: This `PropsInfoItem` object does not have a `Get` or `Value` property and the `OutValue`
     * variable remains unset.
     * - 2: An error occurred while calling the `Get` function, and `OutValue` is the error object.
     */
    GetValue(&OutValue, FromOwner := false) {
        switch this.KindIndex {
            case 1, 4: return 1 ; Call, Set
            case 2, 3:
                try {
                    if FromOwner {
                        OutValue := (Get := this.Get)(this.Owner)
                    } else {
                        OutValue := (Get := this.Get)(this.Root)
                    }
                } catch Error as err {
                    OutValue := err
                    return 2
                }
            case 5:
                OutValue := this.Value
        }
    }

    /**
     * @description - Calls `Object.Prototype.GetOwnPropDesc` on the owner of the property that
     * produced this `PropsInfoItem` object, and updates this `PropsInfoItem` object according
     * to the return value, replacing or removing the existing properties as needed.
     * @returns {Integer} - The kind index, which indicates the kind of property. They are:
     * - 1: Callable property
     * - 2: Dynamic property with only a getter
     * - 3: Dynamic property with both a getter and setter
     * - 4: Dynamic property with only a setter
     * - 5: Value property
     */
    Refresh() {
        desc := this.Owner.GetOwnPropDesc(this.Name)
        n := 0
        for Prop, Val in desc.OwnProps() {
            if this.HasOwnProp(Prop) {
                n++
            }
            this.DefineProp(Prop, { Value: Val })
        }
        switch this.KindIndex {
            case 1,2,4,5:
                ; The type of property changed
                if !n {
                    this.DeleteProp(this.Type)
                }
            case 3:
                ; One of the accessors no longer exists
                if n == 1 {
                    if desc.HasOwnProp('Get') {
                        this.DeleteProp('Set')
                    } else {
                        this.DeleteProp('Get')
                    }
                ; The type of property changed
                } else if !n {
                    this.DeleteProp('Get')
                    this.DeleteProp('Set')
                }
        }
        return this.__DefineKindIndex()
    }

    /**
     * Returns the owner of the property which produced this `PropsInfoItem` object.
     * @instance
     */
    Owner => this.GetOwner()
    /**
     * A string representation of the kind of property which produced this `PropsInfoItem` object.
     * The possible values are:
     * - Call
     * - Get
     * - Get_Set
     * - Set
     * - Value
     * @instance
     */
    Kind => this.__KindNames[this.KindIndex]
    /**
     * An integer that indicates the kind of property which produced this `PropsInfoItem` object.
     * The possible values are:
     * - 1: Callable property
     * - 2: Dynamic property with only a getter
     * - 3: Dynamic property with both a getter and setter
     * - 4: Dynamic property with only a setter
     * - 5: Value property
     * @instance
     */
    KindIndex => this.__DefineKindIndex()

    /**
     * @description - The first time `KindIndex` is accessed, evaluates the object to determine
     * the property kind, then overrides `KindIndex`.
     */
    __DefineKindIndex() {
        ; Override with a value property so this is only processed once
        if this.HasOwnProp('Call') {
            this.DefineProp('KindIndex', { Value: 1 })
        } else if this.HasOwnProp('Get') {
            if this.HasOwnProp('Set') {
                this.DefineProp('KindIndex', { Value: 3 })
            } else {
                this.DefineProp('KindIndex', { Value: 2 })
            }
        } else if this.HasOwnProp('Set') {
            this.DefineProp('KindIndex', { Value: 4 })
        } else if this.HasOwnProp('Value') {
            this.DefineProp('KindIndex', { Value: 5 })
        } else {
            throw Error('Unable to process an unexpected value.', -1)
        }
        return this.KindIndex
    }
    /**
     * @description - The first time `PropsInfoItem.Prototype.__SetAlt` is called, it sets the `Alt`
     * property with an array, then overrides `__SetAlt` to a function which just add items to the
     * array.
     */
    __SetAlt(Item) {
        /**
         * An array of `PropsInfoItem` objects, each sharing the same name. The property associated
         * with the `PropsInfoItem` object that has the `Alt` property is the property owned by
         * or inherited by the object passed to the `GetPropsInfo` function call. Exactly zero of
         * the `PropsInfoItem` objects contained within the `Alt` array will have an `Alt` property.
         * The below example illustrates this concept but expressed in code:
         * @example
         * Obj := [1, 2]
         * OutputDebug('`n' A_LineNumber ': ' Obj.Length) ; 2
         * ; Ordinarily when we access the `Length` property from an array
         * ; instance, the `Array.Prototype.Length.Get` function is called.
         * OutputDebug('`n' A_LineNumber ': ' Obj.Base.GetOwnPropDesc('Length').Get.Name) ; Array.Prototype.Length.Get
         * ; We override the property for some reason.
         * Obj.DefineProp('Length', { Value: 'Arbitrary' })
         * OutputDebug('`n' A_LineNumber ': ' Obj.Length) ; Arbitrary
         * ; GetPropsInfo
         * PropsInfoObj := GetPropsInfo(Obj)
         * ; Get the `PropsInfoItem` for "Length".
         * PropsInfo_Length := PropsInfoObj.Get('Length')
         * if code := PropsInfo_Length.GetValue(&Value) {
         *     throw Error('GetValue failed.', -1, 'Code: ' code)
         * } else {
         *     OutputDebug('`n' A_LineNumber ': ' Value) ; Arbitrary
         * }
         * ; Checking if the property was overridden (we already know
         * ; it was, but just for example)
         * OutputDebug('`n' A_LineNumber ': ' PropsInfo_Length.Count) ; 2
         * OutputDebug('`n' A_LineNumber ': ' (PropsInfo_Length.HasOwnProp('Alt'))) ; 1
         * PropsInfo_Length_Alt := PropsInfo_Length.Alt[1]
         * ; Calling `GetValue()` below returns the true length because
         * ; `Obj` is passed to `Array.Prototype.Length.Get`, producing
         * ; the same result as `Obj.Length` if we never overrode the
         * ; property.
         * if code := PropsInfo_Length_Alt.GetValue(&Value) {
         *     throw Error('GetValue failed.', -1, 'Code: ' code)
         * } else {
         *     OutputDebug('`n' A_LineNumber ': ' Value) ; 2
         * }
         * ; The objects nested in the `Alt` array never have an `Alt`
         * ; property, but have the other properties.
         * OutputDebug('`n' A_LineNumber ': ' (PropsInfo_Length_Alt.HasOwnProp('Alt'))) ; 0
         * OutputDebug('`n' A_LineNumber ': ' PropsInfo_Length_Alt.Count) ; 2
         * OutputDebug('`n' A_LineNumber ': ' PropsInfo_Length_Alt.Name) ; Length
         * @instance
         */
        this.Alt := [Item]
        this.DefineProp('__SetAlt', { Call: (Self, Item) => Self.Alt.Push(Item) })
    }
}
