/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/
    Author: Nich-Cebolla
    Version: 1.2.0
    License: MIT
*/
; Dependency:
; #Include Inheritance_Shared.ahk

/**
 * @description - Traverses an object's inheritance chain and returns the base objects.
 * @param {Object} Obj - The object from which to get the base objects.
 * @param {VarRef} [OutCount] - A variable that will receive the number of base objects.
 * @param {+Integer|String} [StopAt='-Any'] - If an integer, the number of base objects to traverse up
 * the inheritance chain. If a string, the case-insensitive name of the class to stop at. If zero or
 * false, the function will traverse the entire inheritance chain up to but not including `Any`.
 * There are two ways to modify the function's interpretation of this value:
 * - Stop before or after the class: To directThe default is to stop after the class, such that the base object
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
    OutCount := 0
    Result := []
    b := Obj
    if InStr(StopAt, '-') {
        StopAt := StrReplace(StopAt, '-', '')
        FlagStopBefore := true
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
                OutCount++
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
                OutCount++
                Result.Push(b)
            }
        } else {
            Loop {
                if !(b := b.Base) {
                    _Throw()
                    break
                }
                OutCount++
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
            throw Error('``GetBaseObjects`` did not encounter an object that matched the ``StopAt`` value.', -2, 'Stop at: ' StopAt)
        }
    }
}
