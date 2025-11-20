/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/MoveAdjacent.ahk
    Author: Nich-Cebolla
    License: MIT
*/

; For other rect functions, see https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/structs/RECT.ahk

/**
 * @description - Calculates the optimal position to move one rectangle adjacent to another while
 * ensuring that the `Subject` rectangle stays within the monitor's work area. The properties
 * { L, T, R, B } of `Subject` are updated with the new values.
 *
 * @example
 * ; Assume I have Edge and VLC open
 * rcSub := WinRect(WinGetId("ahk_exe msedge.exe"))
 * rcTar := WinRect(WinGetId("ahk_exe vlc.exe"))
 * rcSub.MoveAdjacent(rcTar)
 * rcSub.Apply()
 * @
 *
 * @param {*} Subject - The object representing the rectangle that will be moved. This can be an
 * instance of `Rect` or any class that inherits from `Rect`, or any object with properties
 * { L, T, R, B }. Those four property values will be updated with the result of this function call.
 *
 * @param {*} [Target] - The object representing the rectangle that will be used as reference. This
 * can be an instance of `Rect` or any class that inherits from `Rect`, or any object with properties
 * { L, T, R, B }. If unset, the mouse's current position relative to the screen is used. To use
 * a point instead of a rectangle, set the properties "L" and "R" equivalent to one another, and
 * "T" and "B" equivalent to one another.
 *
 * @param {*} [ContainerRect] - If set, `ContainerRect` defines the boundaries which restrict
 * the area that the window is permitted to be moved within. The object must have poperties
 * { L, T, R, B } to be valid. If unset, the work area of the monitor with the greatest area of
 * intersection with `Target` is used.
 *
 * @param {String} [Dimension = "X"] - Either "X" or "Y", specifying if the window is to be moved
 * adjacent to `Target` on either the X or Y axis. If "X", `Subject` is moved to the left or right
 * of `Target`, and `Subject`'s vertical center is aligned with `Target`'s vertical center. If "Y",
 * `Subject` is moved to the top or bottom of `Target`, and `Subject`'s horizontal center is aligned
 * with `Target`'s horizontal center.
 *
 * @param {String} [Prefer = ""] - A character indicating a preferred side. If `Prefer` is an
 * empty string, the function will move the window to the side the has the greatest amount of
 * space between the monitor's border and `Target`. If `Prefer` is any of the following values,
 * the window will be moved to that side unless doing so would cause the the window to extend
 * outside of the monitor's work area.
 * - "L" - Prefers the left side.
 * - "T" - Prefers the top side.
 * - "R" - Prefers the right side.
 * - "B" - Prefes the bottom.
 *
 * @param {Number} [Padding = 0] - The amount of padding to leave between `Subject` and `Target`.
 *
 * @param {Integer} [InsufficientSpaceAction = 0] - Determines the action taken if there is
 * insufficient space to move the window adjacent to `Target` while also keeping the window
 * entirely within the monitor's work area. The function will always sacrifice some of the padding
 * if it will allow the window to stay within the monitor's work area. If the space is still
 * insufficient, the action can be one of the following:
 * - 0 : The function will not move the window.
 * - 1 : The function will move the window, allowing the window's area to extend into a non-visible
 *   region of the monitor.
 * - 2 : The function will move the window, keeping the window's area within the monitor's work
 *   area by allowing the window to overlap with `Target`.
 *
 * @returns {Integer} - If the insufficient space action was invoked, returns 1. Else, returns 0.
 */
RectMoveAdjacent(Subject, Target?, ContainerRect?, Dimension := 'X', Prefer := '', Padding := 0, InsufficientSpaceAction := 0) {
    Result := 0
    if IsSet(Target) {
        tarL := Target.L
        tarT := Target.T
        tarR := Target.R
        tarB := Target.B
    } else {
        mode := CoordMode('Mouse', 'Screen')
        MouseGetPos(&tarL, &tarT)
        tarR := tarL
        tarB := tarT
        CoordMode('Mouse', mode)
    }
    tarW := tarR - tarL
    tarH := tarB - tarT
    if IsSet(ContainerRect) {
        monL := ContainerRect.L
        monT := ContainerRect.T
        monR := ContainerRect.R
        monB := ContainerRect.B
        monW := monR - monL
        monH := monB - monT
    } else {
        buf := Buffer(16)
        NumPut('int', tarL, 'int', tarT, 'int', tarR, 'int', tarB, buf)
        Hmon := DllCall('MonitorFromRect', 'ptr', buf, 'uint', 0x00000002, 'ptr')
        mon := Buffer(40)
        NumPut('int', 40, mon)
        if !DllCall('GetMonitorInfo', 'ptr', Hmon, 'ptr', mon, 'int') {
            throw OSError()
        }
        monL := NumGet(mon, 20, 'int')
        monT := NumGet(mon, 24, 'int')
        monR := NumGet(mon, 28, 'int')
        monB := NumGet(mon, 32, 'int')
        monW := monR - monL
        monH := monB - monT
    }
    subL := Subject.L
    subT := Subject.T
    subR := Subject.R
    subB := Subject.B
    subW := subR - subL
    subH := subB - subT
    if Dimension = 'X' {
        if Prefer = 'L' {
            if tarL - subW - Padding >= monL {
                X := tarL - subW - Padding
            } else if tarL - subW >= monL {
                X := monL
            }
        } else if Prefer = 'R' {
            if tarR + subW + Padding <= monR {
                X := tarR + Padding
            } else if tarR + subW <= monR {
                X := monR - subW
            }
        } else if Prefer {
            throw _ValueError('Prefer', Prefer)
        }
        if !IsSet(X) {
            flag_nomove := false
            X := _Proc(subW, subL, subR, tarW, tarL, tarR, monW, monL, monR, Prefer = 'L' ? 1 : Prefer = 'R' ? -1 : 0)
            if flag_nomove {
                return Result
            }
        }
        Y := tarT + tarH / 2 - subH / 2
        if Y + subH > monB {
            Y := monB - subH
        } else if Y < monT {
            Y := monT
        }
    } else if Dimension = 'Y' {
        if Prefer = 'T' {
            if tarT - subH - Padding >= monT {
                Y := tarT - subH - Padding
            } else if tarT - subH >= monT {
                Y := monT
            }
        } else if Prefer = 'B' {
            if tarB + subH + Padding <= monB {
                Y := tarB + Padding
            } else if tarB + subH <= monB {
                Y := monB - subH
            }
        } else if Prefer {
            throw _ValueError('Prefer', Prefer)
        }
        if !IsSet(Y) {
            flag_nomove := false
            Y := _Proc(subH, subT, subB, tarH, tarT, tarB, monH, monT, monB, Prefer = 'T' ? 1 : Prefer = 'B' ? -1 : 0)
            if flag_nomove {
                return Result
            }
        }
        X := tarL + tarW / 2 - subW / 2
        if X + subW > monR {
            X := monR - subW
        } else if X < monL {
            X := monL
        }
    } else {
        throw _ValueError('Dimension', Dimension)
    }
    Subject.L := X
    Subject.T := Y
    Subject.R := X + subW
    Subject.B := Y + subH

    return Result

    _Proc(SubLen, SubMainSide, SubAltSide, TarLen, TarMainSide, TarAltSide, MonLen, MonMainSide, MonAltSide, Prefer) {
        if TarMainSide - MonMainSide > MonAltSide - TarAltSide {
            if TarMainSide - SubLen - Padding >= MonMainSide {
                return TarMainSide - SubLen - Padding
            } else if TarMainSide - SubLen >= MonMainSide {
                return MonMainSide + TarMainSide - SubLen
            } else {
                Result := 1
                switch InsufficientSpaceAction, 0 {
                    case 0: flag_nomove := true
                    case 1: return TarMainSide - SubLen
                    case 2: return MonMainSide
                    default: throw _ValueError('InsufficientSpaceAction', InsufficientSpaceAction)
                }
            }
        } else if TarAltSide + SubLen + Padding <= MonAltSide {
            return TarAltSide + Padding
        } else if TarAltSide + SubLen <= MonAltSide {
            return MonAltSide - TarAltSide + SubLen
        } else {
            Result := 1
            switch InsufficientSpaceAction, 0 {
                case 0: flag_nomove := true
                case 1: return TarAltSide
                case 2: return MonAltSide - SubLen
                default: throw _ValueError('InsufficientSpaceAction', InsufficientSpaceAction)
            }
        }
    }
    _ValueError(name, Value) {
        if IsObject(Value) {
            return TypeError('Invalid type passed to ``' name '``.', -2)
        } else {
            return ValueError('Unexpected value passed to ``' name '``.', -2, Value)
        }
    }
}
