/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/
    Author: Nich-Cebolla
    Version: 1.4.0
    License: MIT
*/
; Dependency:
; #Include Inheritance_Shared.ahk

/**
 * @description - Traverses an object's inheritance chain and returns the base objects.
 * @param {Object} Obj - The object from which to get the base objects.
 * @param {Integer|String} [StopAt=GBO_STOP_AT_DEFAULT ?? '-Any'] - If an integer, the number of
 * base objects to traverse up the inheritance chain. If a string, the case-insensitive name of the
 * class to stop at. If falsy, the function will traverse the entire inheritance chain up to
 * but not including `Any`.
 *
 * If you define global variable `GBO_STOP_AT_DEFAULT` with a value somewhere in your code, that
 * value will be used as the default for the function call. Otherwise, '-Any' is used.
 *
 * There are two ways to modify the function's interpretation of this value:
 *
 * - Stop before or after the class: The default is to stop after the class, such that the base object
 * associated with the class is included in the result array. To change this, include a hyphen "-"
 * anywhere in the value and `GetBaseObjects` will not include the last iterated object in the
 * result array.
 *
 * - The type of object which will be stopped at: This only applies to `StopAt` values which are
 * strings. In the code snippets below, `b` is the object being evaluated.
 *
 *   - Stop at a prototype object (default): `GetBaseObjects` will stop at the first prototype object
 * with a `__Class` property equal to `StopAt`. This is the literal condition used:
 * `Type(b) == 'Prototype' && (b.__Class = 'Any' || b.__Class = StopAt)`.
 *
 *   - Stop at a class object: To direct `GetBaseObjects` to stop at a class object tby he name
 * `StopAt`, include ":C" at the end of `StopAt`, e.g. `StopAt := "MyClass:C"`. This is the literal
 * condition used:
 * `Type(b) == 'Class' && ObjHasOwnProp(b, 'Prototype') && b.Prototype.__Class = StopAt`.
 *
 *  - Stop at an instance object: To direct `GetBaseObjects` to stop at an instance object of type
 * `StopAt`, incluide ":I" at the end of `StopAt`, e.g. `StopAt := "MyClass:I"`. This is the literal
 * condition used: `Type(b) = StopAt`.
 * @returns {Array} - The array of base objects.
 */
GetBaseObjects(Obj, StopAt := GBO_STOP_AT_DEFAULT ?? '-Any') {
    Result := []
    b := Obj
    if StopAt {
        if InStr(StopAt, '-') {
            StopAt := StrReplace(StopAt, '-', '')
            FlagStopBefore := true
        }
    } else {
        FlagStopBefore := true
        StopAt := 'Any'
    }
    if InStr(StopAt, ':C') {
        StopAt := StrReplace(StopAt, ':C', '')
        CheckStopAt := _CheckStopAtClass
    } else if InStr(StopAt, ':I') {
        StopAt := StrReplace(StopAt, ':I', '')
        CheckStopAt := _CheckStopAtInstance
    } else {
        CheckStopAt := _CheckStopAt
    }

    if IsNumber(StopAt) {
        Loop Number(StopAt) - (IsSet(FlagStopBefore) ? 2 : 1) {
            if b := b.Base {
                Result.Push(b)
            } else {
                break
            }
        }
    } else {
        if IsSet(FlagStopBefore) {
            Loop {
                if !(b := b.Base) {
                    _Throw()
                    break
                }
                if CheckStopAt() {
                    break
                }
                Result.Push(b)
            }
        } else {
            Loop {
                if !(b := b.Base) {
                    _Throw()
                    break
                }
                Result.Push(b)
                if CheckStopAt() {
                    break
                }
            }
        }
    }
    return Result

    _CheckStopAt() {
        return  Type(b) == 'Prototype' && (b.__Class = 'Any' || b.__Class = StopAt)
    }
    _CheckStopAtClass() {
        return Type(b) == 'Class' && ObjHasOwnProp(b, 'Prototype') && b.Prototype.__Class = StopAt
    }
    _CheckStopAtInstance() {
        return Type(b) = StopAt
    }
    _Throw() {
        ; If `GetBaseObjects` encounters a non-object base, that means it traversed the inheritance
        ; chain up to Any.Prototype, which returns an empty string. If `StopAt` = 'Any' and
        ; !IsSet(FlagStopBefore) (the user did not include "-" in the param string), then this is
        ; expected. In all other cases, this means that the input `StopAt` value was never
        ; encountered, and results in this error.
        if IsSet(FlagStopBefore) || StopAt != 'Any' {
            throw Error('``GetBaseObjects`` did not encounter an object that matched the ``StopAt`` value.'
            , -2, '``StopAt``: ' (IsSet(FlagStopBefore) ? '-' : '') StopAt)
        }
    }
}
