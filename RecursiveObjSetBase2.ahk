/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/RecursiveSetBase2.ahk
    Author: Nich-Cebolla
    Version: 1.0.0
    License: MIT
*/

/**
 * @description - Performs these actions:
 * - Calls `ObjSetBase(Subject, Base)`
 * - Recursively iterates `Subject.OwnProps()`. For any properties that have object values, changes
 * the base of that object using a property by the same name from `Base`.
 *
 * This version of the function also keeps track of the ptr addresses of every object recursed into
 * to prevent a recurse limit error.
 * @param {*} Subject - The object that is subject to the change.
 * @param {*} Base - The base object.
 * @param {String} [RootPath='$'] - This is for error handling. When `RecursiveObjSetBase` throws an
 * error, it will include the object path at which the error occurred. If a calling script calls
 * `RecursiveObjSetBase` in a loop, it can be difficult to identify the source of the error. Passing
 * the name of the object to `RootPath` alleviates this issue.
 */
RecursiveObjSetBase2(Subject, Base, RootPath := '$') {
    Stack := [ RootPath ]
    InvalidProperty := []
    ptrs := Map(ObjPtr(Subject), 1)
    ObjSetBase(Subject, Base)
    _Recurse(Subject, Base)

    return InvalidProperty.Length ? InvalidProperty : ''

    _Recurse(Subject, Base) {
        for Prop, Val in Subject.OwnProps() {
            if HasProp(Base, Prop) {
                if IsObject(Val) {
                    if IsObject(Base.%Prop%) && !ptrs.Has(ObjPtr(Base.%Prop%)) {
                        ObjSetBase(Val, Base.%Prop%)
                        Stack.Push(Stack[-1] ',' Prop)
                        ptrs.Set(ObjPtr(Base.%Prop%), 1)
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
