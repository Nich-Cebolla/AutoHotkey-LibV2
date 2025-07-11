/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/
    Author: Nich-Cebolla
    License: MIT
*/
; Dependency:
; #Include Inheritance_Shared.ahk

/**
 * @description - Gets the property descriptor object for the specified property of the input object.
 * {@link https://www.autohotkey.com/docs/v2/lib/Object.htm#GetOwnPropDesc}
 * @param {Object} Obj - The object from which to get the property descriptor.
 * @param {String} Prop - The name of the property.
 * @param {VarRef} [OutObj] - A variable that will receive a reference to the object which owns the
 * property.
 * @param {VarRef} [OutIndex] - A variable that will receive the index position of the object which
 * owns the property in the inheritance chain.
 * @returns {Object} - If the property exists, the property descriptor object. Else, an empty string.
 */
GetPropDesc(Obj, Prop, &OutObj?, &OutIndex?) {
    if !HasProp(Obj, Prop) {
        return ''
    }
    OutObj := Obj
    OutIndex := 0
    while OutObj && !ObjHasOwnProp(OutObj, Prop) {
        OutIndex++
        OutObj := OutObj.Base
    }
    if OutObj {
        return ObjGetOwnPropDesc(OutObj, Prop)
    } else {
        throw Error('``GetPropDesc`` failed to identify the object which owns the property.', -1)
    }
}

