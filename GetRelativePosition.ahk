/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/GetRelativePosition.ahk
    Author: Nich-Cebolla
    License: MIT
*/

/**
 * @description - Returns an integer representing the position of the first object relative
 * to the second object.
 * The inputs can be any of:
 * - A Gui object, Gui.Control object, or any object with an `Hwnd` property.
 * - An object with properties { L, T, R, B }.
 * - An Hwnd of a window or control.
 *
 * @param {Gui|Gui.Control|Object|Integer} Subject - The subject of the comparison. The return
 * value indicates the position of this object relative to the other.
 *
 * @param {Gui|Gui.Control|Object|Integer} Target - The object which the subject is compared to.
 *
 * @returns {Integer} - Returns an integer representing the relative position shared between two
 * objects. The values are:
 * - 0: Subject overlaps with target by at least one pixel.
 * - 1: Subject is completely above target and completely to the left of target.
 * - 2: Subject is completely above target and neither completely to the right nor left of target.
 * - 3: Subject is completely above target and completely to the right of target.
 * - 4: Subject is completely to the right of target and neither completely above nor below target.
 * - 5: Subject is completely to the right of target and completely below target.
 * - 6: Subject is completely below target and neither completely to the right nor left of target.
 * - 7: Subject is completely below target and completely to the left of target.
 * - 8: Subject is completely to the left of target and neither completely above nor below target.
 */
GetRelativePosition(Subject, Target) {
    _Get(Subject, &L1, &T1, &R1, &B1)
    _Get(Target, &L2, &T2, &R2, &B2)
    ; If subject is completely to the left of target
    if R1 <= L2 {
        ; If subject is completely above target
        if B1 <= T2 {
            return 1
        ; If subject is completely below target
        } else if T1 >= B2 {
            return 7
        } else {
            return 8
        }
    ; If subject is completely above target
    } else if B1 <= T2 {
        ; If subject is completely to the right of target
        if L1 >= R2 {
            return 3
        } else {
            return 2
        }
    ; If subject is completely to the right of target
    } else if L1 >= R2 {
        ; If subject is completely below target
        if T1 >= B2 {
            return 5
        } else {
            return 4
        }
    ; If subject is completely below target
    } else if T1 >= B2 {
        return 6
    } else {
        return 0
    }

    _Get(Input, &L, &T, &R, &B) {
        if Input is Gui.Control {
            Input.GetPos(&L, &T, &W, &H)
            R := L + W
            B := T + H
        } else if IsObject(Input) {
            if HasProp(Input, 'Hwnd') {
                WinGetPos(&L, &T, &W, &H, Input.Hwnd)
            } else {
                L := Input.L
                T := Input.T
                R := Input.R
                B := Input.B
            }
        } else {
            WinGetPos(&L, &T, &W, &H, Input)
            R := L + W
            B := T + H
        }
    }
}
