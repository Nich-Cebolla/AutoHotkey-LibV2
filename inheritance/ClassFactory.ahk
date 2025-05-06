/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/
    Author: Nich-Cebolla
    Version: 1.2.0
    License: MIT
*/

/**
 * @description - Constructs a new class based off an existing class and prototype.
 * @param {*} Prototype - The object to use as the new class's prototype.
 * @param {String} [Name] - The name of the new class. This gets assigned to `Prototype.__Class`.
 * @param {Function} [Constructor] - An optional constructor function that is assigned to
 * `NewClassObj.Prototype.__New`. When set, this function is called for each new instance. When
 * unset, the constructor function associated with `Prototype.__Class` is called.
 */
ClassFactory(Prototype, Name?, Constructor?) {
    Cls := Class()
    Cls.Base := GetObjectFromString(Prototype.__Class)
    Cls.Prototype := Prototype
    if IsSet(Name) {
        Prototype.__Class := Name
    }
    if IsSet(Constructor) {
        Cls.Prototype.DefineProp('__New', { Call: Constructor })
    }
    return Cls

    GetObjectFromString(Path) {
        Split := StrSplit(Path, '.')
        if !IsSet(%Split[1]%)
            return
        OutObj := %Split[1]%
        i := 1
        while ++i <= Split.Length {
            if !OutObj.HasOwnProp(Split[i])
                return
            OutObj := OutObj.%Split[i]%
        }
        return OutObj
    }

}
