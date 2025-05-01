/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/GetProps.ahk
    Author: Nich-Cebolla
    Version: 1.1.2
    License: MIT
*/

; For a more advanced version of this same concept, see Inheritance.ahk
; in https://github.com/Nich-Cebolla/AutoHotkey-LibV2/tree/main/inheritance

/**
 * @description - Constructs a list of properties and details about the properties for both
 * inherited and own properties for the input object.
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
    static ObjGetOwnPropDesc := Object.Prototype.GetOwnPropDesc
    OutBaseObjectsList := GetBaseObjects(Obj, StopAt)
    OutBaseObjectsList.InsertAt(1, Obj)
    Result := Map()
    i += 2
    while --i > 0 {
        b := OutBaseObjectsList[i]
        if !ObjOwnPropCount(b) {
            continue
        }
        for Prop in ObjOwnProps(b) {
            if RegExMatch(Prop, 'i)^(?:' Exclude ')$')
                continue
            if Result.Has(Prop) {
                PropObj := Result.Get(Prop)
                if not PropObj.Overridden is Array
                    PropObj.Overridden := []
                PropObj.Overridden.Push({ Index: i-1, Desc: ObjGetOwnPropDesc(b, Prop) })
            } else {
                Result.Set(Prop, {
                    Index: i-1
                , Name: Prop
                , Desc: ObjGetOwnPropDesc(b, Prop)
                , Overridden: false
                })
            }
        }
    }
    return Result

    GetBaseObjects(Obj, StopAt := '-Any') {
        b := Obj.Base
        if !b {
            return []
        }
        Result := [b]
        if !StopAt
            StopAt := '-Any'
        if InStr(StopAt, '-') {
            StopAt := StrReplace(StopAt, '-', '')
            FlagStopBefore := true
        }
        if InStr(StopAt, ':C') {
            StopAt := StrReplace(StopAt, ':C', '')
            CheckStopAt := _CheckStopAt
        } else if InStr(StopAt, ':I') {
            StopAt := StrReplace(StopAt, ':I', '')
            CheckStopAt := _CheckStopAtInstance
        } else {
            CheckStopAt := _CheckStopAtClass
        }

        if IsNumber(StopAt) {
            Loop Number(StopAt) - 1
                _Process()
        } else {
            if IsObject(StopAt)
                throw TypeError('The ``StopAt`` parameter must be an integer or a string.', -1, 'Type(StopAt): ' Type(StopAt))
            if _CheckStopAt() {
                return Result
            }
            Loop {
                _Process()
                if _CheckStopAt()
                    break
            }
        }
        if IsSet(FlagStopBefore) {
            Result.Pop()
        }
        return Result

        _CheckStopAt() {
            if Type(b) == 'Prototype'
                return _CheckStopAtHelper(b.__Class)
        }
        _CheckStopAtClass() {
            if ObjHasOwnProp(b, 'Prototype')
                return _CheckStopAtHelper(b.Prototype.__Class)
        }
        _CheckStopAtInstance() {
            if ObjHasOwnProp(b, 'Base') && ObjHasOwnProp(b.Base, '__Class')
                return _CheckStopAtHelper(b.Base.__Class)
        }

        _CheckStopAtHelper(ClassName) {
            if ClassName = 'Any' && StopAt != 'Any' {
                return Result
            }
            if ClassName = StopAt
                return 1
        }
        _Process() {
            b := b.Base
            Result.Push(b)
        }
    }
}
