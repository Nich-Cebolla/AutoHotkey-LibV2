/*
   Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/Inheritance.ahk
    Author: Nich-Cebolla
    Version: 1.1.1
    License: MIT
*/

/**
 * @description - Traverses an object's inheritance chain and returns the base objects.
 * @param {Object} Obj - The object from which to get the base objects.
 * @param {VarRef} [OutCount] - A variable that will receive the number of base objects.
 * @param {+Integer|String} [StopAt='-Any'] - If an integer, the number of base objects to traverse up
 * the inheritance chain. If a string, the case-insensitive name of the class to stop at. If zero or
 * false, the function will traverse the entire inheritance chain up to but not including `Any`.
 * There are two ways to modify the function's interpretation of this value:
 * - Stop before or after the class: The default is to stop after the class, such that the base object
 * associated with the class is included in the result array. To change this, include a hyphen "-"
 * anywhere in the value, and this will cause the last base object to be removed from the result array
 * prior to returning it.
 * - The type of object which will be stopped at: This only applies to `StopAt` values which are
 * strings. The default behavior is to stop at a prototype object for the class by the name of
 * `StopAt` (case-insensitive). Specifically, `BaseObject.__Class = StopAt` is the condition. To
 * instead stop at a Class object, include ":C" at the end of `StopAt`. To instead stop at an
 * instance object, include ":I" at the end of `StopAt`.
 * @returns {Array} - The array of base objects.
 */
GetBaseObjects(Obj, &OutCount?, StopAt := '-Any') {
    b := Obj.Base
    Result := [b]
    OutCount := 1
    if !StopAt
        StopAt := '-Any'
    if InStr(StopAt, '-')
        StopAt := StrReplace(StopAt, '-', ''), FlagStopBefore := true
    if InStr(StopAt, ':C')
        StopAt := StrReplace(StopAt, ':C', ''), CheckStopAt := _CheckStopAt
    else if InStr(StopAt, ':I')
        StopAt := StrReplace(StopAt, ':I', ''), CheckStopAt := _CheckStopAtInstance
    else
        CheckStopAt := _CheckStopAtClass

    if IsNumber(StopAt) {
        Loop Number(StopAt) - 1
            _Process()
    } else {
        if IsObject(StopAt)
            throw TypeError('The ``StopAt`` parameter must be an integer or a string.', -1, 'Type(StopAt): ' Type(StopAt))
        Loop {
            _Process()
            if _CheckStopAt()
                break
        }
    }
    if IsSet(FlagStopBefore)
        Result.Pop(), OutCount--
    return Result

    _CheckStopAt() {
        if Type(b) == 'Prototype'
            return _CheckStopAtHelper(b.__Class)
    }
    _CheckStopAtClass() {
        if b.HasOwnProp('Prototype')
            return _CheckStopAtHelper(b.Prototype.__Class)
    }
    _CheckStopAtInstance() {
        if b.HasOwnProp('Base') && b.Base.HasOwnProp('__Class')
            return _CheckStopAtHelper(b.Base.__Class)
    }

    _CheckStopAtHelper(ClassName) {
        if ClassName = 'Any' && StopAt != 'Any' {
            throw Error('GetBaseObjects never arrived at the provided ``StopAt`` class.'
            , -1, 'StopAt: ' StopAt)
        }
        if ClassName = StopAt
            return 1
    }
    _Process() {
        b := b.Base
        OutCount++
        Result.Push(b)
    }
}


/**
 * @description - Constructs a list of properties and details about the properties for both
 * inherited and own properties for the input object,
 * @param {Object} Obj - The object from which to get the properties.
 * @param {VarRef} [OutBaseObjectsList] - A variable that will receive a reference to the array of
 * base objects that is generated during the function call.
 * @param {+Integer|String} [StopAt='-Any'] - If an integer, the number of base objects to traverse up
 * the inheritance chain. If a string, the name of the class to stop at. See {@link GetBaseObjects}
 * for full details about this parameter.
 * @param {String} [Exclude='Base|__Class|Prototype'] - A pipe-delimited list of properties to exclude.
 * @returns {Map} - A map object, where each key is a property name and each value is an object
 * with the following properties:
 * - `Index` - The index position of the object which owns the property in the inheritance chain, where
 * index 0 is the input object, 1 is the input object's base, 2 is the next base object, etc.
 * - `Name` - The name of the property, same as the key.
 * - `Desc` - The property descriptor object.
 * {@link https://www.autohotkey.com/docs/v2/lib/Object.htm#GetOwnPropDesc}
 * - `Overridden` - If only one object in the inheritance chain owns a property by the name, then
 * this value is `false`. Else, the value is an array of objects, one object being added for each
 * additional base object which owns a property by the name. The objects have the following properties:
 *  - `Index` - The index position of the base object in the inheritance chain.
 *  - `Desc` - The property descriptor object.
 */
GetProps(Obj, &OutBaseObjectsList?, StopAt := '-Any', Exclude := 'Base|__Class|Prototype') {
    OutBaseObjectsList := GetBaseObjects(Obj, &i, StopAt)
    OutBaseObjectsList.InsertAt(1, Obj)
    Result := Map()
    i += 2
    while --i > 0 {
        b := OutBaseObjectsList[i]
        for Prop in b.OwnProps() {
            if RegExMatch(Prop, 'i)^(?:' Exclude ')$')
                continue
            if Result.Has(Prop) {
                PropObj := Result.Get(Prop)
                if not PropObj.Overridden is Array
                    PropObj.Overridden := []
                PropObj.Overridden.Push({ Index: i-1, Desc: b.GetOwnPropDesc(Prop) })
            } else {
                Result.Set(Prop, {
                    Index: i-1
                  , Name: Prop
                  , Desc: b.GetOwnPropDesc(Prop)
                  , Overridden: false
                })
            }
        }
    }
    return Result
}

/**
 * @description - Gets the property descriptor object for the specified property of the input object.
 * {@link https://www.autohotkey.com/docs/v2/lib/Object.htm#GetOwnPropDesc}
 * @param {Object} Obj - The object from which to get the property descriptor.
 * @param {String} Prop - The name of the property.
 * @param {VarRef} [OutObj] - A variable that will receive the object which owns the property.
 * @param {VarRef} [OutIndex] - A variable that will receive the index position of the object which
 * owns the property in the inheritance chain.
 * @returns {Object} - If the property exists, the property descriptor object. Else, an empty string.
 */
GetPropDesc(Obj, Prop, &OutObj?, &OutIndex?) {
    static GetOwnPropDesc := Object.Prototype.GetOwnPropDesc
    , HasOwnProp := Object.Prototype.HasOwnProp
    if !HasProp(Obj, Prop) {
        return ''
    }
    OutObj := Obj
    OutIndex := 0
    while !HasOwnProp(OutObj, Prop) {
        OutIndex++
        if OutObj.__Class == 'Any' {
            break
        }
        OutObj := OutObj.Base
    }
    return GetOwnPropDesc(OutObj, Prop)
}
