/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/
    Author: Nich-Cebolla
    License: MIT
*/

/**
 * @description - Traverses an object's inheritance chain and returns the base objects.
 *
 * @param {Object} Obj - The object from which to get the base objects.
 *
 * @param {Integer|String} [StopAt = GBO_STOP_AT_DEFAULT ?? "-Any"] - If an integer, the number of
 * base objects to traverse up the inheritance chain. If a string, the case-insensitive name of the
 * class to stop at. If falsy, the function will traverse the entire inheritance chain up to
 * but not including `Any`.
 *
 * If you define global variable `GBO_STOP_AT_DEFAULT` with a value somewhere in your code, that
 * value will be used as the default for the function call. Otherwise, '-Any' is used.
 *
 * There are two ways to modify the function's interpretation of this value. These are only relevant
 * for string values.
 *
 * - Stop before or after the class: The default is to stop after the class, such that the base object
 * associated with the class is included in the result array. To change this, include a hyphen "-"
 * anywhere in the value and `GetBaseObjects` will not include the last iterated object in the
 * result array.
 *
 * In the code snippets below, `b` represents the base object being evaluated.
 *
 * - The type of object which will be stopped at:
 *   - Stop at a prototype object (default): `GetBaseObjects` will stop at the first prototype object
 *     with a `__Class` property equal to `StopAt`. This is the literal condition used:
 *     `ObjHasOwnProp(b, "__Class") && (b.__Class = StopAt)`.
 *   - Stop at a class object: To direct `GetBaseObjects` to stop at a class object tby he name
 *     `StopAt`, include ":C" at the end of `StopAt`, e.g. `StopAt := "MyClass:C"`. This is the literal
 *     condition used:
 *     `ObjHasOwnProp(b, "Prototype") && b.Prototype.__Class = StopAt`.
 *   - Stop at an instance object: To direct `GetBaseObjects` to stop at an instance object of type
 *     `StopAt`, incluide ":I" at the end of `StopAt`, e.g. `StopAt := "MyClass:I"`. This is the literal
 *     condition used: `!ObjHasOwnProp(b, "__Class") && b.__Class = StopAt`.
 *
 * @returns {Array} - The array of base objects.
 */
GetBaseObjects(Obj, StopAt := GBO_STOP_AT_DEFAULT ?? '-Any') {
    Result := []
    if IsNumber(StopAt) {
        if stopAt > 0 {
            Result.Push(Obj.Base)
            loop stopAt - 1 {
                Result.Push(Result[-1].Base)
            }
        } else {
            throw ValueError('``Options.StopAt`` must be an integer greater than zero.', , StopAt)
        }
    } else {
        if StopAt {
            if InStr(StopAt, '-') {
                StopAt := StrReplace(StopAt, '-', '')
                flag_stopBefore := 1
            } else {
                flag_stopBefore := 0
            }
        } else {
            flag_stopBefore := 1
            StopAt := 'Any'
        }
        if InStr(StopAt, ':C') {
            StopAt := StrReplace(StopAt, ':C', '')
            check := _CheckClass
        } else if InStr(StopAt, ':I') {
            StopAt := StrReplace(StopAt, ':I', '')
            check := _CheckInstance
        } else {
            check := _CheckPrototype
        }
        b := Obj
        if !check() {
            if flag_stopBefore {
                Loop {
                    if b := b.Base {
                        if check() {
                            break
                        }
                        Result.Push(b)
                    } else {
                        _Throw()
                    }
                }
            } else {
                Loop {
                    if b := b.Base {
                        Result.Push(b)
                        if check() {
                            break
                        }
                    } else {
                        _Throw()
                    }
                }
            }
        }
    }

    return Result

    _CheckClass() {
        return ObjHasOwnProp(b, 'Prototype') && b.Prototype.__Class = StopAt
    }
    _CheckInstance() {
        return !ObjHasOwnProp(b, '__Class') && b.__Class = StopAt
    }
    _CheckPrototype() {
        return ObjHasOwnProp(b, '__Class') && (b.__Class = StopAt)
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
