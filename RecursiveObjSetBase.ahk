/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/RecursiveSetBase.ahk
    Author: Nich-Cebolla
    Version: 1.0.1
    License: MIT
*/

/**
 * @description - Performs these actions:
 * - Calls `ObjSetBase(Subject, Base)`
 * - Recursively iterates `Subject.OwnProps()`. For any properties that have object values, changes
 * the base of that object using a property by the same name from `Base`. If this property value on
 * `Base` is an empty string or zero, that property is skipped, and the object's own properties
 * are not iterated.
 *
 * In the below example, this is how the objects are paired:
 * - BaseObj.Prop1 is the base of Subject.Prop1
 * - Subject.Prop2 is unchanged because BaseObj.Prop2 is an empty string
 * - BaseObj.Prop3 is the base of Subject.Prop3
 * - BaseObj.Prop3._A is the base of Subject.Prop3._A
 * @example
 *  BaseObj := {
 *      Prop1: { A: 'Val', B: 'Val2' }
 *    , Prop2: ''
 *    , Prop3: { _A: { _B: 'Val3' } }
 *  }
 *
 *  Subject := {
 *      Prop1: { }
 *    , Prop2: { Z: 'Val4', Y: 'Val5' }
 *    , Prop3: { _A: { } }
 *  }
 *
 *  RecursiveObjSetBase(Subject, BaseObj)
 *  MsgBox(Subject.Prop1.A) ; Val
 *  MsgBox(Subject.Prop2.Z) ; Val4
 *  MsgBox(Subject.Prop3._A._B) ; Val3
 * @
 *
 * @param {*} Subject - The object that is subject to the change.
 * @param {*} Base - The base object.
 * @param {String} [RootPath='$'] - This is for error handling. When `RecursiveObjSetBase` throws an
 * error, it will include the object path at which the error occurred. If a calling script calls
 * `RecursiveObjSetBase` in a loop, it can be difficult to identify the source of the error. Passing
 * the name of the object to `RootPath` alleviates this issue.
 * @returns {Array|String} - If there are any properties on `Subject` or its child objects that do
 * not exist on `Base` or its child objects, an array of strings representing the property names is
 * returned. Else, an empty string is returned.
 */
RecursiveObjSetBase(Subject, Base, RootPath := '$') {
    Stack := [ RootPath ]
    InvalidProperty := []
    ObjSetBase(Subject, Base)
    _Recurse(Subject, Base)

    return InvalidProperty.Length ? InvalidProperty : ''

    _Recurse(Subject, Base) {
        for Prop, Val in Subject.OwnProps() {
            if HasProp(Base, Prop) {
                if Base.%Prop% {
                    if IsObject(Val) {
                        if IsObject(Base.%Prop%) {
                            ObjSetBase(Val, Base.%Prop%)
                            Stack.Push(Stack[-1] '.' Prop)
                            _Recurse(Val, Base.%Prop%)
                        } else {
                            throw ValueError('Invalid configuration value.', -1, 'Path: ' Stack[-1] '.' Prop)
                        }
                    }
                }
            } else {
                InvalidProperty.Push(Stack[-1] '.' Prop)
            }
        }
        Stack.Pop()
    }
}
