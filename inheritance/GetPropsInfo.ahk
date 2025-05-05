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
 * @description - Constructs a `PropsInfo` object, which is a flexible solution for cases when a
 * project would benefit from being able to quickly obtain a list of all of an object's properties,
 * and/or filter those properties.
 *
 * In this documentation, an instance of `PropsInfo` is referred to as either "a `PropsInfo` object"
 * or `PropsInfoObj`. An instance of `PropsInfoItem` is referred to as either "a `PropsInfoItem` object"
 * or `InfoItem`.
 *
 * See example-Inheritance.ahk for a walkthrough on how to use the class.
 *
 * `PropsInfo` objects are designed to be a flexible solution for accessing and/or analyzing an
 * object's properties, including inherited properties. Whereas `OwnProps` only iterates an objects'
 * own properties, `PropsInfo` objects can perform these functions for both inherited and own
 * properties:
 * - Produce an array of property names.
 * - Produce a `Map` where the key is the property name and the object is a `PropsInfoItem` object
 * for each property.
 * - Produce an array of `PropsInfoItem` objects.
 * - Be passed to a function that expects an iterable object like any of the three above bullet points.
 * - Filter the properties according to one or more conditions.
 * - Get the function objects associated with the properties.
 *
 * `PropsInfoItem` objects are modified descriptor objects.
 * @see {@link https://www.autohotkey.com/docs/v2/lib/Object.htm#GetOwnPropDesc}.
 * After getting the descriptor object, `GetPropsInfo` changes the descriptor object's base, converting
 * it to a `PropsInfoItem` object and exposing additional properties. See the parameter hints above
 * each property for details.
 *
 * @param {*} Obj - The object from which to get the properties.
 * @param {Integer|String} [StopAt=GPI_STOP_AT_DEFAULT ?? '-Object'] - If an integer, the number of
 * base objects to traverse up the inheritance chain. If a string, the name of the class to stop at.
 * You can define a global variable `GPI_STOP_AT_DEFAULT` to change the default value. If
 * GPI_STOP_AT_DEFAULT is unset, the default value is '-Object', which directs `GetPropsInfo` to
 * include properties owned by objects up to but not including `Object.Prototype`.
 * @see {@link GetBaseObjects} for full details about this parameter.
 * @param {String} [Exclude=''] - A comma-delimited, case-insensitive list of properties to exclude.
 * For example: "Length,Capacity,__Item".
 * @param {Boolean} [IncludeBaseProp=true] - If true, the object's `Base` property is included. If
 * false, `Base` is excluded.
 * @param {VarRef} [OutBaseObjList] - A variable that will receive a reference to the array of
 * base objects that is generated during the function call.
 * @returns {PropsInfo}
 */
GetPropsInfo(Obj, StopAt := GPI_STOP_AT_DEFAULT ?? '-Object', Exclude := '', IncludeBaseProp := true, &OutBaseObjList?) {
    OutBaseObjList := GetBaseObjects(Obj, StopAt)
    Container := Map()
    Container.Default := Container.CaseSense := false
    for s in StrSplit(Exclude, ',', '`s`t') {
        if (s) {
            Container.Set(s, -1)
        }
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
             * `Count` gets incremented by one for each object which owns a property by the same name.
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
    for s in StrSplit(Exclude, ',', '`s`t') {
        if (s) {
            Container.Delete(s)
        }
    }
    return PropsInfo(Container, PropsInfoItemBase)
}

/**
 * @classdesc - The return value for `GetPropsInfo`. See the parameter hint above `GetPropsInfo`
 * for information.
 */
class PropsInfo {
    static __New() {
        if this.Prototype.__Class == 'PropsInfo' {
            Proto := this.Prototype
            Proto.DefineProp('Filter', { Value: '' })
            Proto.DefineProp('__FilterActive', { Value: 0 })
            Proto.DefineProp('__StringMode', { Value: 0 })
            Proto.DefineProp('Get', Proto.GetOwnPropDesc('__ItemGet_Bitypic'))
            Proto.DefineProp('__OnFilterProperties', { Value: ['Has', 'ToArray', 'ToMap'
            , 'Capacity', 'Count', 'Length'] })
            Proto.DefineProp('__FilteredItems', { Value: '' })
            Proto.DefineProp('__FilteredIndex', { Value: '' })
            Proto.DefineProp('__FilterCache', { Value: '' })
        }
    }

    /**
     * @class - The constructor is intended to be called from `GetPropsInfo`.
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
        for Prop, InfoItem in Container {
            this.__InfoItems.Push(InfoItem)
            this.__InfoIndex.Set(Prop, A_Index)
        }
        this.__PropsInfoItemBase := PropsInfoItemBase
        this.__FilterActive := 0
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
        if this.__FilteredIndex {
            this.__FilteredIndex.Capacity := 0
        }
        if this.__FilteredItems {
            this.__FilteredItems.Clear()
            this.__FilteredItems.Capacity := 0
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
     * `PropsInfoObj.FilterActive == 1`, the values returned by the following methods and properties
     * will be filtered:
     * __Enum, Get, GetFilteredProps (if a function object is not passed to it), Has, ToArray, ToMap,
     * __item, Capacity, Count, Length
     * @param {String|Number} [CacheName] - If set, the filtered containers will be cached under this name.
     * Else, the containers are not cached.
     * @throws {UnsetItemError} - If no filters have been added.
     */
    FilterActivate(CacheName?) {
        if !this.Filter {
            throw UnsetItemError('No filters have been added.', -1)
        }
        Filter := this.Filter
        this.DefineProp('__FilteredIndex', { Value: FilteredIndex := [] })
        this.DefineProp('__FilteredItems', { Value: FilteredItems := Map() })
        FilteredIndex.Capacity := FilteredItems.Capacity := this.__InfoItems.Length
        ; If there's only one filter object in the collection, we can save a bit of processing
        ; time by just getting a reference to the object and skipping the second loop.
        if Filter.Count == 1 {
            for FilterIndex, FilterObj in Filter {
                Fn := FilterObj
            }
            for InfoItem in this.__InfoItems {
                if Fn(InfoItem) {
                    continue
                }
                FilteredItems.Set(A_Index, InfoItem)
                FilteredIndex.Push(A_Index)
            }
        } else {
            for InfoItem in this.__InfoItems {
                for FilterIndex, FilterObj in Filter {
                    if FilterObj(InfoItem) {
                        continue 2
                    }
                }
                FilteredItems.Set(A_Index, InfoItem)
                FilteredIndex.Push(A_Index)
            }
        }
        FilteredIndex.Capacity := FilteredItems.Capacity := FilteredItems.Count
        this.__FilterActive := 1
        if IsSet(CacheName) {
            this.FilterCache(CacheName)
        }
        this.__FilterSwitchProps(1)
    }

    /**
     * @description - Activates a cached filter.
     * @param {String|Number} Name - The name of the filter to activate.
     */
    FilterActivateFromCache(Name) {
        this.__FilterActive := 1
        this.__FilteredItems := this.__FilterCache.Get(Name).Items
        this.__FilteredIndex := this.__FilterCache.Get(Name).Index
        this.__FilterSwitchProps(1)
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
     * Saving the index isn't necessary; you can also delete a filter by passing the function object
     * to `PropsInfo.Prototype.FilterDelete`.
     * The following built-in indices always refer to the same function:
     * - 0: The function which excludes by property name.
     * - 1 through 4: The other built-in filters described above.
     * @throws {ValueError} - If the one of the values passed to `Filters` is invalid.
     */
    FilterAdd(Activate := true, Filters*) {
        if !this.Filter {
            this.DefineProp('Filter', { Value: Map() })
            this.Filter.Exclude := ''
            this.__FilterIndex := 5
        }
        this.DefineProp('FilterAdd', { Call: _FilterAdd })
        this.FilterAdd(Activate, Filters*)

        _FilterAdd(Self, Activate := true, Filters*) {
            Filter := Self.Filter
            for InfoItem in Filters {
                if IsObject(InfoItem) {
                    if InfoItem is Func || HasMethod(InfoItem, 'Call') || HasMethod(InfoItem, '__Call') {
                        if !IsSet(Start) {
                            Start := Self.__FilterIndex
                        }
                        Filter.Set(Self.__FilterIndex, PropsInfo.Filter(InfoItem, Self.__FilterIndex++))
                    } else {
                        throw ValueError('A value passed to the ``Filters`` parameter is invalid.', -1
                        , 'Type(Value): ' Type(InfoItem))
                    }
                } else {
                    switch InfoItem, 0 {
                        case '1', '2', '3', '4':
                            Filter.Set(InfoItem, PropsInfo.Filter(_Filter_%InfoItem%, InfoItem))
                        default:
                            if SubStr(Filter.Exclude, -1, 1) == ',' {
                                Filter.Exclude .= InfoItem
                            } else {
                                Filter.Exclude .= ',' InfoItem
                            }
                            Flag_Exclude := true
                    }
                }
            }
            if IsSet(Flag_Exclude) {
                ; Be ensuring every name has a comma on both sides, we can check the names by
                ; using `InStr(Filter.Exclude, ',' Prop ',')` which should perform better than RegExMatch.
                Filter.Exclude .= ','
                Filter.Set(0, PropsInfo.Filter(_Exclude, 0))
            }

            if Activate {
                Self.FilterActivate()
            }
            ; If a custom filter is added, return the start index so the caller function can keep track.
            return Start ?? ''

            _Exclude(InfoItem) {
                return InStr(Filter.Exclude, ',' InfoItem.Name ',')
            }
            _Filter_1(InfoItem) => !InfoItem.Index
            _Filter_2(InfoItem) => InfoItem.Index
            _Filter_3(InfoItem) => InfoItem.HasOwnProp('Alt')
            _Filter_4(InfoItem) => !InfoItem.HasOwnProp('Alt')
        }
    }

    /**
     * @description - Adds the currently active filter to the cache.
     * @param {String|Number} Name - The value which will be the key that accesses the filter.
     */
    FilterCache(Name) {
        if !this.__FilterCache {
            this.__FilterCache := Map()
        }
        this.DefineProp('FilterCache', { Call: _Set })
        this.FilterCache(Name)
        _Set(Self, Name) => Self.__FilterCache.Set(Name, { Items: Self.__FilteredItems, Index: Self.__FilteredIndex })
    }

    /**
     * @description - Clears the filter.
     * @throws {Error} - If the filter is empty.
     */
    FilterClear() {
        if !this.Filter {
            throw Error('The filter is empty.', -1)
        }
        this.Filter.Clear()
        this.Filter.Capacity := 0
        this.Filter.Exclude := ''
    }

    /**
     * @description - Clears the filter cache.
     * @throws {Error} - If the filter cache is empty.
     */
    FilterClearCache() {
        if !this.__FilterCache {
            throw Error('The filter cache is empty.', -1)
        }
        this.__FilterCache.Clear()
        this.__FilterCache.Capacity := 0
    }

    /**
     * @description - Deactivates the currently active filter.
     * @param {String|Number} [CacheName] - If set, the filter is added to the cache with this name prior
     * to being deactivated.
     * @throws {Error} - If the filter is not currently active.
     */
    FilterDeactivate(CacheName?) {
        if !this.__FilterActive {
            throw Error('The filter is not currently active.', -1)
        }
        if IsSet(CacheName) {
            this.FilterCache(CacheName)
        }
        this.__FilterActive := 0
        this.__FilteredItems := ''
        this.__FilteredIndex := ''
        this.__FilterSwitchProps(0)
    }

    /**
     * @description - Deletes an item from the filter.
     * @param {Func|Integer|PropsInfo.Filter|String} Key - One of the following:
     * - The function object.
     * - The index assigned to the `PropsInfo.Filter` object.
     * - The `PropsInfo.Filter` object.
     * - The function object's name.
     * @returns {PropsInfo.Filter} - The filter object that was just deleted.
     * @throws {UnsetItemError} - If `Key` is a function object and the filter does not contain
     * that function.
     * @throws {UnsetItemError} - If `Key` is a string and the filter does not contain a function
     * with that name.
     */
    FilterDelete(Key) {
        local r
        if Key is Func {
            ptr := ObjPtr(Key)
            for Index, FilterObj in this.Filter {
                if ObjPtr(FilterObj.Function) == ptr {
                    r := FilterObj
                    break
                }
            }
            if IsSet(r) {
                this.Filter.Delete(r.Index)
            } else {
                throw UnsetItemError('The function passed to ``Key`` is not in the filter.', -1)
            }
        } else if IsObject(Key) {
            r := this.Filter.Get(Key.Index)
            this.Filter.Delete(Key.Index)
        } else if IsNumber(Key) {
            r := this.Filter.Get(Key)
            this.Filter.Delete(Key)
        } else {
            for Fn in this.Filter {
                if Fn.Name == Key {
                    r := Fn
                    break
                }
            }
            if IsSet(r) {
                this.Filter.Delete(r.Index)
            } else {
                throw UnsetItemError('The filter does not contain a function with that name.', -2, Key)
            }
        }
        return r
    }

    /**
     * @description - Deletes a filter from the cache.
     * @param {String|Integer} Name - The name assigned to the filter.
     * @returns {Map} - The object containing the filter functions that were just deleted.
     * @throws {Error} - If the filter cache is empty.
     */
    FilterDeleteFromCache(Name) {
        if !this.__FilterCache {
            throw Error('The filter cache is empty.', -1)
        }
        r := this.__FilterCache.Get(Name)
        this.__FilterCache.Delete(Name)
        return r
    }

    /**
     * @description - Removes one or more property names from the exclude list.
     * @param {String} Name - The name to remove or a comma-delimited list of names to remove.
     * @throws {Error} - If the filter is empty.
     */
    FilterRemoveFromExclude(Name) {
        if !this.Filter {
            throw Error('The filter is empty.', -1)
        }
        Filter := this.Filter
        for _name in StrSplit(Name, ',') {
            Filter.Exclude := RegExReplace(Filter.Exclude, ',' _name '(?=,)', '')
        }
    }

    /**
     * @description - Retrieves a `PropsInfoItem` object.
     * @param {String|Integer} Key - While `PropsInfoObj.StringMode == true`, `Key` must be an
     * integer index value. While `PropsInfoObj.StringMode == false`, `Key` can be either a string
     * property name or an integer index value.
     * @returns {PropsInfoItem}
     * @throws {TypeError} - If `Key` is not a number and `PropsInfoObj.StringMode == true`.
     */
    Get(Key) {
        ; This is overridden
    }

    /**
     * @description - Retrieves the index of a property.
     * @param {String} Name - The name of the property.
     * @returns {Integer} - The index of the property.
     */
    GetIndex(Name) {
        return this.__InfoIndex.Get(Name)
    }

    /**
     * @description - Retrieves a proxy object.
     * @param {String} ProxyType - The type of proxy to create. Valid values are:
     * - 1: `PropsInfo.Proxy_Array`
     * - 2: `PropsInfo.Proxy_Map`
     * @returns {PropsInfo.Proxy_Array|PropsInfo.Proxy_Map}
     * @throws {ValueError} - If `ProxyType` is not 1 or 2.
     */
    GetProxy(ProxyType) {
        switch ProxyType, 0 {
            case '1': return PropsInfo.Proxy_Array(this)
            case '2': return PropsInfo.Proxy_Map(this)
        }
        throw ValueError('The input ``ProxyType`` must be ``1`` or ``2``.', -1
        , IsObject(ProxyType) ? 'Type(ProxyType) == ' Type(ProxyType) : ProxyType)
    }

    /**
     * @description - Iterates the `PropsInfo` object, adding the `PropsInfoItem` objects to
     * a container.
     * @param {*} [Container] - The container to add the filtered `PropsInfoItem` objects to. If set,
     * the object must inherit from either `Map` or `Array`.
     * - If `Container` inherits from `Array`, the `PropsInfoItem` objects are added to the array using
     * `Push`.
     * - If `Container` inherits from `Map`, the `PropsInfoItem` objects are added to the map using
     * `Set`, with the property name as the key. The map's `CaseSense` property must be set to
     * "Off".
     * - If `Container` is unset, `GetFilteredProps` returns a new `PropsInfo` object.
     * @param {Function} [Function] -
     * - If set, a function object that accepts a `PropsInfoItem` object as its only parameter. The
     * function should return a nonzero value to exclude the property. Any currently active filters
     * are ignored.
     * - If unset, `GetFilteredProps` uses the filters that are currently active. The difference
     * between `GetFilteredProps` and either `ToMap` or `ToArray` in this case is that you can
     * supply your own container, or get a new `PropsInfo` object.
     * @returns {PropsInfo|Array|Map} - The container with the filtered `PropsInfoItem` objects.
     * If `Container` is unset, a new `PropsInfo` object is returned.
     * @throws {TypeError} - If `Container` is not an `Array` or `Map`.
     * @throws {Error} - If `Container` is a `Map` and its `CaseSense` property is not set to "Off".
     * @throws {Error} - If the filter is empty.
     */
    GetFilteredProps(Container?, Function?) {
        if IsSet(Container) {
            if Container is Array {
                Set := _Set_Array
                GetCount := () => Container.Length
            } else if Container is Map {
                if Container.CaseSense !== 'Off' {
                    throw Error('CaseSense must be set to "Off".', -1)
                }
                Set := _Set_Map
                GetCount := () => Container.Count
            } else {
                throw TypeError('Unexpected container type.', -1, 'Type(Container) == ' Type(Container))
            }
        } else {
            Container := Map()
            Container.CaseSense := false
            Set := _Set_Map
            GetCount := () => Container.Count
            Flag_MakePropsInfo := true
        }
        InfoItems := this.__InfoItems
        Container.Capacity := InfoItems.Length
        if IsSet(Function)  {
            for InfoItem in InfoItems {
                if Function(InfoItem) {
                    continue
                }
                Set(InfoItem)
            }
        } else if this.Filter {
            Filter := this.Filter
            if Filter.Count == 1 {
                for FilterIndex, FilterObj in Filter {
                    Fn := FilterObj
                }
                for InfoItem in InfoItems {
                    if Fn(InfoItem) {
                        continue
                    }
                    Set(InfoItem)
                }
            } else {
                for InfoItem in Infoitems {
                    for FilterIndex, FilterObj in Filter {
                        if FilterObj(InfoItem) {
                            continue 2
                        }
                    }
                    Set(InfoItem)
                }
            }
        } else {
            throw Error('The filter is empty.', -1)
        }
        Container.Capacity := GetCount()
        return IsSet(Flag_MakePropsInfo) ? PropsInfo(Container, this.__PropsInfoItemBase) : Container

        _Set_Array(InfoItem) => Container.Push(InfoItem)
        _Set_Map(InfoItem) => Container.Set(InfoItem.Name, InfoItem)
    }

    /**
     * @description - Checks if a property exists in the `PropsInfo` object.
     */
    Has(Key) {
        return IsNumber(Key) ? this.__InfoItems.Has(Key) : this.__InfoIndex.Has(Key)
    }

    /**
     * @description - Iterates the `PropsInfo` object, adding the `PropsInfoItem` objects to an array,
     * or adding the property names to an array.
     * @param {Boolean} [NamesOnly=false] - If true, the property names are added to the array. If
     * false, the `PropsInfoItem` objects are added to the array.
     * @returns {Array} - The array of property names or `PropsInfoItem` objects.
     */
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

    /**
     * @description - Iterates the `PropsInfo` object, adding the `PropsInfoItem` objects to a map.
     * The keys are the property names.
     * @returns {Map} - The map of property names and `PropsInfoItem` objects.
     */
    ToMap() {
        Result := Map()
        Result.Capacity := this.__InfoItems.Length
        for InfoItem in this.__InfoItems {
            Result.Set(InfoItem.Name, InfoItem)
        }
        return Result
    }

    /**
     * @memberof PropsInfo
     * @instance
     * @readonly
     */
    Capacity => this.__InfoIndex.Capacity
    /**
     * @memberof PropsInfo
     * @instance
     * @readonly
     */
    CaseSense => this.__InfoIndex.CaseSense
    /**
     * @memberof PropsInfo
     * @instance
     * @readonly
     */
    Count => this.__InfoIndex.Count
    /**
     * @memberof PropsInfo
     * @instance
     * @readonly
     */
    Default => this.__InfoIndex.Default
    /**
     * @memberof PropsInfo
     * @instance
     * @readonly
     */
    Length => this.__InfoItems.Length

    /**
     * Set to a nonzero value to activate the current filter. Set to a falsy value to deactivate.
     * While a filter is active, the values retured by the `PropsInfo` object's methods and properties
     * will be filtered. See the parameter hint above `PropsInfo.Prototype.FilterActivate` for
     * additional details.
     * @memberof PropsInfo
     * @instance
     */
    FilterActive {
        Get => this.__FilterActive
        Set {
            if Value {
                if this.__FilterCache.Has(Value) {
                    this.FilterActivateFromCache(Value)
                } else {
                    this.FilterActivate()
                }
            } else {
                this.FilterDeactivate()
            }
        }
    }

    /**
     * Set to a nonzero value to activate string mode. Set to a falsy value to deactivate.
     * While string mode is active, the `PropsInfo` object emulates the behavior of an array of
     * strings. The following properties and methods are influenced by string mode:
     * __Enum, Get, __Item
     * By extension, the proxies are also affected.
     * @memberof PropsInfo
     * @instance
     */
    StringMode {
        Get => this.__StringMode
        Set {
            if this.__FilterActive {
                if Value {
                    this.DefineProp('__StringMode', { Value: 1 })
                    this.DefineProp('Get', { Call: this.__FilteredGet_StringMode })
                } else {
                    this.DefineProp('__StringMode', { Value: 0 })
                    this.DefineProp('Get', { Call: this.__FilteredGet_Bitypic })
                }
            } else {
                if Value {
                    this.DefineProp('__StringMode', { Value: 1 })
                    this.DefineProp('Get', { Call: this.__ItemGet_StringMode })
                } else {
                    this.DefineProp('__StringMode', { Value: 0 })
                    this.DefineProp('Get', { Call: this.__ItemGet_Bitypic })
                }
            }
        }
    }

    __Delete() {
        this.Dispose()
    }

    /**
     * @description - `__Enum` is influenced by both string mode and any active filters. It can
     * be called in either 1-param mode or 2-param mode.
     */
    __Enum(VarCount) {
        i := 0
        if this.__FilterActive {
            Index := this.__FilteredIndex
            FilteredItems := this.__FilteredItems
            return this.__StringMode ? _Filtered_Enum_StringMode_%VarCount% : _Filtered_Enum_%VarCount%
        } else {
            InfoItems := this.__InfoItems
            return this.__StringMode ? _Enum_StringMode_%VarCount% : _Enum_%VarCount%
        }

        _Enum_1(&InfoItem) {
            if ++i > InfoItems.Length {
                return 0
            }
            InfoItem := InfoItems[i]
            return 1
        }
        _Enum_2(&Prop, &InfoItem) {
            if ++i > InfoItems.Length {
                return 0
            }
            InfoItem := InfoItems[i]
            Prop := InfoItem.Name
            return 1
        }
        _Enum_StringMode_1(&Prop) {
            if ++i > InfoItems.Length {
                return 0
            }
            Prop := InfoItems[i].Name
            return 1
        }
        _Enum_StringMode_2(&Index, &Prop) {
            if ++i > InfoItems.Length {
                return 0
            }
            Index := i
            Prop := InfoItems[i].Name
            return 1
        }

        _Filtered_Enum_1(&InfoItem) {
            if ++i > Index.Length {
                return 0
            }
            InfoItem := FilteredItems[Index[i]]
            return 1
        }
        _Filtered_Enum_2(&Prop, &InfoItem) {
            if ++i > Index.Length {
                return 0
            }
            InfoItem := FilteredItems[Index[i]]
            Prop := InfoItem.Name
            return 1
        }
        _Filtered_Enum_StringMode_1(&Prop) {
            if ++i > Index.Length {
                return 0
            }
            Prop := FilteredItems[Index[i]]
            return 1
        }
        _Filtered_Enum_StringMode_2(&Index, &Prop) {
            if ++i > Index.Length {
                return 0
            }
            Index := i
            Prop := FilteredItems[Index[i]]
            return 1
        }
    }

    /**
     * @description - Allows access to the `PropsInfoItem` objects using `Obj[Key]` syntax. Forwards
     * the `Key` to the `Get` method. {@link PropsInfo#Get}.
     */
    __Item[Key] => this.Get(Key)

    __ItemGet_StringMode(Index) {
        if !IsNumber(Index) {
            this.__ThrowTypeError()
        }
        return this.__InfoItems[Index].Name
    }

    __ItemGet_Bitypic(Key) {
        return this.__InfoItems[IsNumber(Key) ? Key : this.__InfoIndex.Get(Key)]
    }

    __FilteredGet_StringMode(Index) {
        if !IsNumber(Index) {
            this.__ThrowTypeError()
        }
        return this.__InfoItems[this.__FilteredIndex[Index]].Name
    }

    __FilteredGet_Bitypic(Key) {
        if IsNumber(Key) {
            return this.__InfoItems[this.__FilteredIndex[Key]]
        } else {
            return this.__FilteredItems.Get(this.__InfoIndex.Get(Key))
        }
    }

    __FilteredHas(Key) {
        if IsNumber(Key) {
            return this.__FilteredItems.Has(this.__InfoIndex.Get(this.__InfoItems[Key].Name))
        } else {
            return this.__FilteredItems.Has(this.__InfoIndex.Get(Key))
        }
    }

    __FilteredToArray(NamesOnly := false) {
        Result := []
        Result.Capacity := this.__FilteredItems.Count
        if NamesOnly {
            for i, InfoItem in this.__FilteredItems {
                Result.Push(InfoItem.Name)
            }
        } else {
            for i, InfoItem in this.__FilteredItems {
                Result.Push(InfoItem)
            }
        }
        return Result
    }

    __FilteredToMap(NamesOnly := false) {
        Result := Map()
        Result.Capacity := this.__FilteredItems.Count
        for i, InfoItem in this.__FilteredItems {
            Result.Set(InfoItem.Name, InfoItem)
        }
        return Result
    }

    __FilterSwitchProps(Value) {
        Proto := PropsInfo.Prototype
        if Value {
            for Name in this.__OnFilterProperties {
                this.DefineProp(Name, Proto.GetOwnPropDesc('__Filtered' Name))
            }
            this.DefineProp('Get', Proto.GetOwnPropDesc(this.__StringMode ? '__FilteredGet_StringMode' : '__FilteredGet_Bitypic'))
        } else {
            for Name in this.__OnFilterProperties {
                this.DefineProp(Name, Proto.GetOwnPropDesc(Name))
            }
            this.DefineProp('Get', Proto.GetOwnPropDesc(this.__StringMode ? '__ItemGet_StringMode' : '__ItemGet_Bitypic'))
        }
    }

    __ThrowTypeError() {
        ; To aid in debugging; if `StringMode == true`, then the object is supposed to behave
        ; like an array of strings, and so accessing an item by name is invalid and represents
        ; an error in the code.
        throw TypeError('Invalid input. While the ``PropsInfo`` object is in string mode,'
        ' items can only be accessed using numeric indices.', -2)
    }

    __FilteredCapacity => this.__FilteredItems.Capacity
    __FilteredCount => this.__FilteredItems.Count
    __FilteredLength => this.__FilteredItems.Count

    /**
     * `PropsInfo.Filter` constructs the filter objects when a filter is added using
     * `PropsInfo.Prototype.FilterAdd`. Filter objects have four properties:
     * - Index: The object's index which can be used to access or delete the object from the filter.
     * - Function: The function object.
     * - Call: The `Call` method which redirects the input parameter to the function and returns
     * the return value.
     * - Name: Returns the function's built-in name.
     * @classdesc
     */
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

    /**
     * `PropsInfo.Proxy_Array` constructs a proxy that can be passed to an external function as an
     * iterable object. Use `PropsInfo.Proxy_Array` when an external function expects an iterable Array
     * object. Using a proxy is slightly more performant than calling `PropsInfo.Prototype.ToArray` in
     * cases where the object will only be iterated once.
     * The function should not try to set or change the items in the collection. If this is necessary,
     * use `PropsInfo.Prototype.ToArray`.
     * @classdesc
     */
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
            ; `PropsInfo` is not compatible with addint new items to the collection.
            ; Set => this.Client.__Item[Index] := Value
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

    /**
     * `PropsInfo.Proxy_Map` constructs a proxy that can be passed to an external function as an
     * iterable object. Use `PropsInfo.Proxy_Map` when an external function expects an iterable Map
     * object. Using a proxy is slightly more performant than calling `PropsInfo.Prototype.ToMap` in
     * cases where the object will only be iterated once.
     * The function should not try to set or change the items in the collection. If this is necessary,
     * use `PropsInfo.Prototype.ToMap`.
     * @classdesc
     */
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
        Has(Key) => this.Client.__InfoIndex.Has(Key)
        __Enum(VarCount) => this.Client.__Enum(VarCount)
        Capacity {
            Get => this.Client.__InfoIndex.Capacity
            Set => this.Client.___InfoIndex.Capacity := Value
        }
        CaseSense => this.Client.__InfoIndex.CaseSense
        Count => this.Client.__InfoIndex.Count
        Default {
            Get => this.Client.__InfoIndex.Default
            Set => this.Client.__InfoIndex.Default := Value
        }
        __Item[Key] {
            Get => this.Client.__Item[Key]
            ; `PropsInfo` is not compatible with addint new items to the collection.
            ; Set => this.Client.__Item[Key] := Value
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
 * @classdesc - For each base object in the input object's inheritance chain (up to the stopping
 * point), the base object's own properties are iterated, generating a `PropsInfoItem` object for
 * each property (unless the property is excluded).
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
     * @class
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
     * @throws {ValueError} - If `Flag_Bind` is not 0, 1, or 2.
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
     * It is possible for this method to return an unexpected value. This is an illustration of how
     * this is possible:
     * @example
     *  class a {
     *      __SomeProp := 0
     *      SomeProp => this.__SomeProp
     *  }
     *  class b extends a {
     *
     *  }
     *  class c {
     *      __SomeOtherProp := 1
     *      SomeProp => this.__SomeOtherProp
     *  }
     *  Obj := b()
     *  PropsInfoObj := GetPropsInfo(Obj)
     *  InfoItem := PropsInfoObj.Get('SomeProp')
     *  OriginalOwner := InfoItem.GetOwner()
     *  Obj.Base.Base := c.Prototype
     *  NewOwner := InfoItem.GetOwner()
     *  MsgBox(ObjPtr(OriginalOwner) == ObjPtr(NewOwner)) ; 0
     * @
     * What the example conveys is that, if one or more of the input object's base objects are altered
     * with an object that owns a property by the same name as the `PropsInfoItem` object, then
     * `PropsInfoItem.Prototype.GetOwner` will return a value that is not the original owner of
     * the property.
     * @returns {*} - The owner of the property.
     * @throws {Error} - The error reads "Unable to retrieve the property's owner." If you get this
     * error, it means the object inheritance chain has been altered since the time the `PropsInfoItem`
     * object was created. The `PropsInfoItem` objects should be considered invalid and you should
     * call `GetPropsInfo` again to get a new `PropsInfo` object.
     */
    GetOwner() {
        b := this.Root
        loop this.Index {
            b := b.Base
        }
        if b.HasOwnProp(this.Name) {
            return b
        } else {
            throw Error('Unable to retrieve the property`'s owner.', -1)
        }
    }

    /**
     * @description - If this is associated with a value property, provides the value that the property
     * had at the time this `PropsInfoItem` object was created. If this is associated with a dynamic
     * property with a `Get` accessor, attempts to access and provide the value.
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
     * @memberof PropsInfoItem
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
     * @memberof PropsInfoItem
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
     * @memberof PropsInfoItem
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
