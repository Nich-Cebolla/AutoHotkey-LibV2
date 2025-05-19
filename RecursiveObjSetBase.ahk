/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/RecursiveSetBase.ahk
    Author: Nich-Cebolla
    Version: 1.0.0
    License: MIT
*/

/**
 * @description - Performs these actions:
 * - Calls `ObjSetBase(Subject, Base)`
 * - Recursively iterates `Subject.OwnProps()`. For any properties that have object values, changes
 * the base of that object using a property by the same name from `Base`.
 * @param {*} Subject - The object that is subject to the change.
 * @param {*} Base - The base object.
 */
RecursiveObjSetBase(Subject, Base, RootPath) {
    Stack := [ RootPath ]
    InvalidProperty := []
    ObjSetBase(Subject, Base)
    _Recurse(Subject, Base)

    return InvalidProperty.Length ? InvalidProperty : ''

    _Recurse(Subject, Base) {
        for Prop, Val in Subject.OwnProps() {
            if HasProp(Base, Prop) {
                if IsObject(Val) {
                    if IsObject(Base.%Prop%) {
                        ObjSetBase(Val, Base.%Prop%)
                        Stack.Push(Stack[-1] ',' Prop)
                        _Recurse(Val, Base.%Prop%)
                    } else {
                        throw ValueError('Invalid configuration value.', -1, 'Path: ' Stack[-1] '.' Prop)
                    }
                }
            } else {
                InvalidProperty.Push(Stack[-1] '.' Prop)
            }
        }
        Stack.Pop()
    }
}
