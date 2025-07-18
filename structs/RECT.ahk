/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/structs/RECT.ahk
    Author: Nich-Cebolla
    License: MIT
*/

; https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/structs/POINT.ahk
#Include <Point>
; https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/SetThreadDPIAwareness__Call.ahk
#include <SetThreadDPIAwareness__Call>

class WinRect extends Rect {
    static __New() {
        this.DeleteProp('__New')
        this.Make(this)
    }
    static Make(Cls, Offset := 0) {
        Proto := Cls.Prototype
        Proto.__Offset := Offset
        if !HasMethod(Cls, '__Call') {
            Cls.DefineProp('__Call', { Call: SetThreadDpiAwareness__Call })
        }
        if !HasMethod(Proto, '__Call') {
            Proto.DefineProp('__Call', { Call: SetThreadDpiAwareness__Call })
        }
        Proto.DefineProp('Move', { Call: WINRECT_Move.Bind(0) })
        Proto.DefineProp('MoveOnly', { Call: WINRECT_MoveOnly.Bind(0) })
    }
    __New(Hwnd, ClientRect := false) {
        this.Hwnd := Hwnd
        this.Size := 16
        if ClientRect {
            this.Client := true
            if !DllCall('User32.dll\GetClientRect', 'ptr', Hwnd, 'ptr', this, 'int') {
                throw OSError()
            }
        } else {
            this.Client := false
            if !DllCall('User32.dll\GetWindowRect', 'ptr', Hwnd, 'ptr', this, 'int') {
                throw OSError()
            }
        }
    }
    ChildFromPoint(X, Y) {
        return DllCall('ChildWindowFromPoint', 'ptr', this.Hwnd, 'int', (X & 0xFFFFFFFF) | (Y << 32), 'ptr')
    }
    /**
     * @param {Integer} [flag = 0] -
     * - CWP_ALL - 0x0000 : Does not skip any child windows
     * - CWP_SKIPDISABLED - 0x0002 : Skips disabled child windows
     * - CWP_SKIPINVISIBLE - 0x0001 : Skips invisible child windows
     * - CWP_SKIPTRANSPARENT - 0x0004 : Skips transparent child windows
     */
    ChildWindowFromPointEx(X, Y, flag := 0) {
        return DllCall('ChildWindowFromPointEx', 'ptr', this.Hwnd, 'int', (X & 0xFFFFFFFF) | (Y << 32), 'int', flag, 'ptr')
    }
    EnumChildWindows(Callback, lParam := 0) {
        cb := CallbackCreate(Callback)
        result := DllCall('EnumChildWindows', 'ptr', this.Hwnd, 'ptr', cb, 'uint', lParam, 'int')
        CallbackFree(cb)
        return result
    }
    GetPos(&X?, &Y?, &W?, &H?) {
        X := this.L
        Y := this.T
        W := this.W
        H := this.H
    }
    IsChild(HwndChild) {
        return DllCall('IsChild', 'ptr', this.Hwnd, 'ptr', HwndChild, 'int')
    }
    IsParent(HwndParent) {
        return DllCall('IsChild', 'ptr', HwndParent, 'ptr', this.Hwnd, 'int')
    }
    IsVisible() {
        return DllCall('IsWindowVisible', 'Ptr', this.hWnd, 'int')
    }
    /**
     * @param {Integer} [X] - The new x-coordinate of the window.
     * @param {Integer} [Y] - The new y-coordinate of the window.
     * @param {Integer} [W] - The new Width of the window.
     * @param {Integer} [H] - The new Height of the window.
     * @param {Integer} [InsertAfter = 0] - Either the handle of another window to insert this
     * window after, or one of the following:
     * - HWND_BOTTOM - (HWND)1 : Places the window at the bottom of the Z order. If the <i>hWnd</i>
     *   parameter identifies a topmost window, the window loses its topmost status and is placed at
     *   the bottom of all other windows.
     * - HWND_NOTOPMOST - (HWND)-2 : Places the window above all non-topmost windows (that is, behind
     *   all topmost windows). This flag has no effect if the window is already a non-topmost window.
     * - HWND_TOP - (HWND)0 : Places the window at the top of the Z order.
     * - HWND_TOPMOST - (HWND)-1 : Places the window above all non-topmost windows. The window
     *   maintains its topmost position even when it is deactivated.
     * @param {Integer} [Flags = 0] - A combination of the following. Use "|" to combine, e.g.
     * `Flags := 0x4000 | 0x0020 | 0x0010`.
     * - SWP_ASYNCWINDOWPOS - 0x4000 : If the calling thread and the thread that owns the window are
     *   attached to different input queues, the system posts the request to the thread that owns the
     *   window. This prevents the calling thread from blocking its execution while other threads
     *   process the request.
     * - SWP_DEFERERASE - 0x2000 : Prevents generation of the WM_SYNCPAINT message.
     * - SWP_DRAWFRAME - 0x0020 : Draws a frame (defined in the window's class description) around the
     *   window.
     * - SWP_FRAMECHANGED - 0x0020 : Applies new frame styles set using the SetWindowLong
     *   function. Sends a WM_NCCALCSIZE message to the window, even if the window's size is not being
     *   changed. If this flag is not specified, <b>WM_NCCALCSIZE</b> is sent only when the window's
     *   size is being changed.
     * - SWP_HIDEWINDOW - 0x0080 : Hides the window.
     * - SWP_NOACTIVATE - 0x0010 : Does not activate the window. If this flag is not set, the window
     *   is activated and moved to the top of either the topmost or non-topmost group (depending on the
     *   setting of the <i>hWndInsertAfter</i> parameter).
     * - SWP_NOCOPYBITS - 0x0100 : Discards the entire contents of the client area. If this flag is
     *   not specified, the valid contents of the client area are saved and copied back into the client
     *   area after the window is sized or repositioned.
     * - SWP_NOMOVE - 0x0002 : Retains the current position (ignores <i>X</i> and <i>Y</i>
     *   parameters).
     * - SWP_NOOWNERZORDER - 0x0200 : Does not change the owner window's position in the Z order.
     * - SWP_NOREDRAW - 0x0008 : Does not redraw changes. If this flag is set, no repainting of any
     *   kind occurs. This applies to the client area, the nonclient area (including the title bar and
     *   scroll bars), and any part of the parent window uncovered as a result of the window being
     *   moved. When this flag is set, the application must explicitly invalidate or redraw any parts
     *   of the window and parent window that need redrawing.
     * - SWP_NOREPOSITION - 0x0200 : Same as the <b>SWP_NOOWNERZORDER</b> flag.
     * - SWP_NOSENDCHANGING - 0x0400 : Prevents the window from receiving the WM_WINDOWPOSCHANGING
     *   message.
     * - SWP_NOSIZE - 0x0001 : Retains the current size (ignores the <i>cx</i> and <i>cy</i>
     *   parameters).
     * - SWP_NOZORDER - 0x0004 : Retains the current Z order (ignores the <i>hWndInsertAfter</i>
     *   parameter).
     * - SWP_SHOWWINDOW - 0x0040 : Displays the window.
     */
    Move(X?, Y?, W?, H?, InsertAfter := 0, Flags := 0) {
        ; This is overridden
    }
    /**
     * Moves the window.
     * @param {Integer} X - X coordinate.
     * @param {Integer} Y - Y coordinate.
     * @param {Integer} [InsertAfter = 0] - @see {@link WinRect#Move}.
     * @param {Integer} [Flags] - `SWP_NOSIZE` is always applied, you must not use it here. Set
     * `Flags` with a combination of any of the other options, or leave it unset.
     * @see {@link WinRect#Move}.
     */
    MoveOnly(X, Y, InsertAfter := 0, Flags?) {
        ; This is overridden
    }
    /**
     * @description - Moves the window adjacent to another window while ensuring that the window stays
     * within the monitor's work area.
     * @param {*} Target - The handle to the window that will be used as a reference, or an object
     * with a property "Hwnd".
     * @param {*} [ContainerRect] - If set, `ContainerRect` defines the boundaries which restrict
     * the area that the window is permitted to be moved within. The object must have poperties
     * { L, T, R, B } to be valid. If unset, the work area of the monitor with which `Target` shares
     * the greatest area of intersection is used.
     * @param {String} [Dimension = "X"] - Either "X" or "Y", specifying if the window is to be moved
     * adjacent to `Target` on either the X or Y axis.
     * @param {String} [Prefer = ""] - A character indicating a preferred side. If `Prefer` is an
     * empty string, the function will move the window to the side the has the greatest amount of
     * space between the monitor's border and `Target`. If `Prefer` is any of the following values,
     * the window will be moved to that side unless doing so would cause the the window to extend
     * outside of the monitor's work area.
     * - "L" - Prefers the left side.
     * - "T" - Prefers the top side.
     * - "R" - Prefers the right side.
     * - "B" - Prefes the bottom.
     * Any other nonzero value is silently ignored.
     * @param {Number} [Padding = 0] - The amount of padding to leave between the window and `Target`.
     * @param {Integer} [InsufficientSpaceAction = 0] - Determins the action taken if there is
     * insufficient space to move the window adjacent to `Target` while also keeping the window
     * entirely within the monitor's work area. The function will always sacrifice some of the padding
     * if it will allow the window to stay within the monitor's work area. If the space is still
     * insufficient, the action can be one of the following:
     * - 0 : The function will not move the window.
     * - 1 : The function will move the window, allowing the window's area to extend into a non-visible
     *   region of the monitor.
     * - 2 : The function will move the window, keeping the window's area within the monitor's work
     *   area by allowing the window to overlap with `Target`.
     * @param {Integer} [Flags] - `SWP_NOSIZE` is always applied, you must not use it here. Set
     * `Flags` with a combination of any of the other options, or leave it unset.
     * @see {@link WinRect#Move}.
     * @returns {Integer} - If the insufficient space action was invoked, returns 1. Else, returns 0.
     */
    MoveAdjacent(Target, ContainerRect?, Dimension := 'X', Prefer := '', Padding := 0, InsufficientSpaceAction := 0, Flags?) {
        if IsInteger(Target) {
            Target := WinRect(Target)
        } else if not Target is WinRect {
            Target := WinRect(Target.Hwnd)
        }
        if IsSet(ContainerRect) {
            monX := ContainerRect.L
            monY := ContainerRect.T
            monR := ContainerRect.R
            monB := ContainerRect.B
            monW := monR - monX
            monH := monB - monY
        } else if Hmon := Target.Monitor {
            mon := Buffer(40)
            NumPut('int', 40, mon)
            if !DllCall('user32\GetMonitorInfo', 'ptr', Hmon, 'ptr', mon, 'int') {
                throw OSError()
            }
            monX := NumGet(mon, 20, 'int')
            monY := NumGet(mon, 24, 'int')
            monR := NumGet(mon, 28, 'int')
            monB := NumGet(mon, 32, 'int')
            monW := monR - monX
            monH := monB - monY
        } else {
            throw Error('``Target`` is not within a monitor`'s visible area.', -1)
        }
        subX := this.X
        subY := this.Y
        subR := this.R
        subB := this.B
        subW := subR - subX
        subH := subB - subY
        tarX := Target.X
        tarY := Target.Y
        tarR := Target.R
        tarB := Target.B
        tarW := tarR - tarX
        tarH := tarB - tarY
        if Dimension = 'X' {
            if Prefer = 'L' {
                if tarX - subW - Padding >= monX {
                    Coord := tarX - subW - Padding
                }
            } else if Prefer = 'R' {
                if Coord <= tarR + subW + Padding {
                    Coord := tarR + subW + Padding
                }
            } else if Prefer {
                throw _ValueError('Prefer', Prefer)
            }
            if !IsSet(Coord) {
                flag_nomove := false
                Coord := _Proc(subW, subX, subR, tarW, tarX, tarR, monW, monX, monR, Prefer = 'L' ? 1 : Prefer = 'R' ? -1 : 0)
                if flag_nomove {
                    return 2
                }
            }
            this.MoveOnly(Coord, tarY + tarH / 2 - subH / 2, , Flags ?? unset)
        } else if Dimension = 'Y' {
            if Prefer = 'T' {
                if tarY - subH - Padding >= monX {
                    Coord := tarY - subH - Padding
                }
            } else if Prefer = 'B' {
                if tarB + subH + Padding <= monR {
                    Coord := tarB + subH + Padding
                }
            } else if Prefer {
                throw _ValueError('Prefer', Prefer)
            }
            this.MoveOnly(tarX + tarW / 2 - subW / 2, _Proc(subH, subY, subB, tarH, tarY, tarB, monH, monY, monB, Prefer = 'T' ? 1 : Prefer = 'B' ? -1 : 0), , Flags ?? unset)
        } else {
            throw _ValueError('Dimension', Dimension)
        }

        _Proc(SubLen, SubMainSide, SubAltSide, TarLen, TarMainSide, TarAltSide, MonLen, MonMainSide, MonAltSide, Prefer) {
            if Prefer == 1 && TarMainSide - SubLen - Padding > MonMainSide {
                return TarMainSide - SubLen - Padding
            } else if Prefer == -1 && TarAltSide + SubLen + Padding < MonAltSide {
                return TarAltSide + SubLen + Padding
            }
            if TarMainSide - MonMainSide > MonAltSide - TarAltSide {
                if TarMainSide - SubLen - Padding >= MonMainSide {
                    return TarMainSide - SubLen - Padding
                } else if TarMainSide - SubLen >= MonMainSide {
                    return MonMainSide + TarMainSide - SubLen
                } else {
                    switch InsufficientSpaceAction, 0 {
                        case 0: flag_nomove := true
                        case 1: return TarMainSide - SubLen
                        case 2: return MonMainSide + SubLen
                        default: throw _ValueError('InsufficientSpaceAction', InsufficientSpaceAction)
                    }
                }
            } else if TarAltSide + SubLen + Padding <= MonMainSide {
                return TarAltSide + SubLen + Padding
            } else if TarAltSide + SubLen >= MonMainSide {
                return TarAltSide + SubLen
            } else {
                switch InsufficientSpaceAction, 0 {
                    case 0: flag_nomove := true
                    case 1: return TarAltSide + SubLen
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
    RealChildFromPoint(X, Y) {
        return DllCall('RealChildWindowFromPoint', 'ptr', this.Hwnd, 'int', (X & 0xFFFFFFFF) | (Y << 32), 'ptr')
    }
    /**
     * @description - Shows the window.
     * @param {Integer} [Flag = 0] - One of the following.
     * - SW_HIDE - 0 - Hides the window and activates another window.
     * - SW_SHOWNORMAL / SW_NORMAL - 1 - Activates and displays a window. If the window is
     *   minimized, maximized, or arranged, the system restores it to its original size and position.
     *   An application should specify this flag when displaying the window for the first time.
     * - SW_SHOWMINIMIZED - 2 - Activates the window and displays it as a minimized window.
     * - SW_SHOWMAXIMIZED / SW_MAXIMIZE - 3 - Activates the window and displays it as a maximized
     *   window.
     * - SW_SHOWNOACTIVATE - 4 - Displays a window in its most recent size and position. This value
     *   is similar to <strong>SW_SHOWNORMAL</strong>, except that the window is not activated.
     * - SW_SHOW - 5 - Activates the window and displays it in its current size and position.
     * - SW_MINIMIZE - 6 - Minimizes the specified window and activates the next top-level window in
     *   the Z order.
     * - SW_SHOWMINNOACTIVE - 7 - Displays the window as a minimized window. This value is similar
     *   to <strong>SW_SHOWMINIMIZED</strong>, except the window is not activated.
     * - SW_SHOWNA - 8 - Displays the window in its current size and position. This value is similar
     *   to <strong>SW_SHOW</strong>, except that the window is not activated.
     * - SW_RESTORE - 9 - Activates and displays the window. If the window is minimized, maximized,
     *   or arranged, the system restores it to its original size and position. An application should
     *   specify this flag when restoring a minimized window.
     * - SW_SHOWDEFAULT - 10 - Sets the show state based on the <strong>SW_</strong> value specified
     *   in the structure passed to the function by the program that started the application.
     * - SW_FORCEMINIMIZE - 11 - Minimizes a window, even if the thread that owns the window is not
     *   responding. This flag should only be used when minimizing windows from a different thread.
     * @returns {Boolean} - If the window was previously visible, the return value is nonzero. If
     * the window was previously hidden, the return value is zero.
     */
    Show(Flag := 0) {
        return DllCall('ShowWindow', 'ptr', this.Hwnd, 'uint', Flag, 'int')
    }

    Dpi => DllCall('GetDpiForWindow', 'ptr', this.Hwnd, 'int')
    Monitor => DllCall('User32.dll\MonitorFromWindow', 'ptr', this.Hwnd, 'int', 0, 'ptr')
    Visible => DllCall('IsWindowVisible', 'Ptr', this.hWnd, 'int')
}

class Rect extends RectBase {
    __New(L?, T?, R?, B?) {
        this.Size := 16
        if IsSet(L) {
            NumPut('int', L, this, 0)
        }
        if IsSet(T) {
            NumPut('int', T, this, 4)
        }
        if IsSet(R) {
            NumPut('int', R, this, 8)
        }
        if IsSet(B) {
            NumPut('int', B, this, 12)
        }
    }

    /**
     * @description - Reorders the objects in an array according to the input options.
     * @example
     *  List := [
     *      { L: 100, T: 100, Name: 1 }
     *    , { L: 100, T: 150, Name: 2 }
     *    , { L: 200, T: 100, Name: 3 }
     *    , { L: 200, T: 150, Name: 4 }
     *  ]
     *  Rect.Order(List, L2R := true, T2B := true, 'H')
     *  OutputDebug(_GetOrder()) ; 1 2 3 4
     *  Rect.Order(List, L2R := true, T2B := true, 'V')
     *  OutputDebug(_GetOrder()) ; 1 3 2 4
     *  Rect.Order(List, L2R := false, T2B := true, 'H')
     *  OutputDebug(_GetOrder()) ; 3 4 1 2
     *  Rect.Order(List, L2R := false, T2B := false, 'H')
     *  OutputDebug(_GetOrder()) ; 4 3 2 1
     *
     *  _GetOrder() {
     *      for item in List {
     *          Str .= item.Name ' '
     *      }
     *      return Trim(Str, ' ')
     *  }
     * @
     * @param {Array} List - The array containing the objects to be ordered.
     * @param {String} [Primary='X'] - Determines which axis is primarily considered when ordering
     * the objects. When comparing two objects, if their positions along the Primary axis are
     * equal, then the alternate axis is compared and used to break the tie. Otherwise, the alternate
     * axis is ignored for that pair.
     * - X: Check horizontal first.
     * - Y: Check vertical first.
     * @param {Boolean} [LeftToRight=true] - If true, the objects are ordered in ascending order
     * along the X axis when the X axis is compared.
     * @param {Boolean} [TopToBottom=true] - If true, the objects are ordered in ascending order
     * along the Y axis when the Y axis is compared.
     * @param {Func} [LeftGetter=(Obj) => Obj.L] - A function that retrieves the left value from the objects.
     * @param {Func} [TopGetter=(Obj) => Obj.T] - A function that retrieves the top value from the objects.
     */
    static Order(List, Primary := 'X', LeftToRight := true, TopToBottom := true
    , LeftGetter := (Obj) => Obj.L, TopGetter := (Obj) => Obj.T) {
        ConditionH := LeftToRight ? (a, b) => LeftGetter(a) < LeftGetter(b) : (a, b) => LeftGetter(a) > LeftGetter(b)
        ConditionV := TopToBottom ? (a, b) => TopGetter(a) < TopGetter(b) : (a, b) => TopGetter(a) > TopGetter(b)
        if Primary = 'X' {
            _InsertionSort(List, _ConditionFnH)
        } else if Primary = 'Y' {
            _InsertionSort(List, _ConditionFnV)
        } else {
            throw ValueError('Unexpected ``Primary`` value.', -1, Primary)
        }

        return

        _InsertionSort(Arr, CompareFn) {
            i := 1
            loop Arr.Length - 1 {
                Current := Arr[++i]
                j := i - 1
                loop j {
                    if CompareFn(Arr[j], Current) < 0
                        break
                    Arr[j + 1] := Arr[j--]
                }
                Arr[j + 1] := Current
            }
        }
        _ConditionFnH(a, b) {
            if a.L == b.L {
                if ConditionV(a, b) {
                    return -1
                }
            } else if ConditionH(a, b) {
                return -1
            }
            return 1
        }
        _ConditionFnV(a, b) {
            if a.T == b.T {
                if ConditionH(a, b) {
                    return -1
                }
            } else if ConditionV(a, b) {
                return -1
            }
            return 1
        }
    }
    static FromDimensions(X, Y, W, H) => this(X, Y, X + W, Y + H)

    static FromPtr(ptr) {
        return this(
            NumGet(ptr, 0, 'int')
          , NumGet(ptr, 4, 'int')
          , NumGet(ptr, 8, 'int')
          , NumGet(ptr, 12, 'int')
        )
    }

    /**
     * @description - Returns the intersection of two rectangles.
     * @param {Rect} Rc1 - The first rectangle.
     * @param {Rect} Rc2 - The second rectangle.
     * @param {Integer} [Offset1 = 0] - The offset to add to `Rc1`'s ptr.
     * @param {Integer} [Offset2 = 0] - The offset to add to `Rc2`'s ptr.
     * @returns {Rect} - If successful, the intersection of the two rectangles. If
     * unsuccessful, an empty string.
     */
    static Intersect(Rc1, Rc2, Offset1 := 0, Offset2 := 0) {
        rc := Rect()
        if DLLCall('User32.dll\IntersectRect', 'ptr', rc, 'ptr', Rc1.Ptr + Offset1, 'ptr', Rc2.Ptr + Offset2) {
            return rc
        }
    }

    /**
     * @description - Splits a length into equivalent segments. The first index in the array
     * is always the same as `Pos`, then each subsequent value is the rounded sum of the previous
     * item's value and `Length / Divisor`.
     * @param {Integer} Pos - The starting position.
     * @param {Integer} Length - The length to split.
     * @param {Integer} Divisor - The number of segments to split the length into.
     * @param {Integer} [DecimalPlaces = 0] - The value passed to `Round`'s second parameter.
     * @returns {Integer[]}
     */
    static Split(Pos, Length, Divisor, DecimalPlaces := 0) {
        Result := [Pos]
        Delta := Length / Divisor
        Result.Capacity := Divisor + 1
        loop Divisor {
            Result.Push(Round(Pos += Delta, DecimalPlaces))
        }
        return Result
    }

    /**
     * Returns the smallest rectangle that completely encompasses both rectangles as a new object.
     * @param {Rect} Rc1 - The first rectangle.
     * @param {Rect} Rc2 - The second rectangle.
     * @param {Integer} [Offset1 = 0] - The offset to add to `Rc1`'s ptr.
     * @param {Integer} [Offset2 = 0] - The offset to add to `Rc2`'s ptr.
     * @returns {Rect} - If successful, the intersection of the two rectangles. If
     * unsuccessful, an empty string.
     */
    static Union(Rc1, Rc2, Offset1 := 0, Offset2 := 0) {
        rc := Rect()
        if DllCall('UnionRect', 'ptr', rc, 'ptr', Rc1.Ptr + Offset1, 'ptr', Rc2.Ptr + Offset2, 'int') {
            return rc
        }
    }
}

class RectBase extends Buffer {
    static __New() {
        this.DeleteProp('__New')
        this.Make(this, 0)
    }
    static Make(Cls, Offset := 0, Prefix := '') {
        Proto := Cls.Prototype
        Proto.__Offset := Offset
        if !HasMethod(Cls, '__Call') {
            Cls.DefineProp('__Call', { Call: SetThreadDpiAwareness__Call })
        }
        if !HasMethod(Proto, '__Call') {
            Proto.DefineProp('__Call', { Call: SetThreadDpiAwareness__Call })
        }
        Proto.DefineProp(Prefix 'B', { Get: RECT_GetCoordinate.Bind(12 + Offset) })
        Proto.DefineProp(Prefix 'BR', { Get: RECT_GetPoint.Bind('R', 'B') })
        Proto.DefineProp(Prefix 'Dpi', { Get: RECT_GetDpi.Bind(Offset) })
        Proto.DefineProp(Prefix 'H', { Get: RECT_GetLength.Bind('B', 'T') })
        Proto.DefineProp(Prefix 'Intersect', { Call: RECT_Intersect.Bind(Offset) })
        Proto.DefineProp(Prefix 'L', { Get: RECT_GetCoordinate.Bind(Offset) })
        Proto.DefineProp(Prefix 'MidX', { Get: RECT_GetSegment.Bind('R', 'L', 2) })
        Proto.DefineProp(Prefix 'MidY', { Get: RECT_GetSegment.Bind('B', 'T', 2) })
        Proto.DefineProp(Prefix 'R', { Get: RECT_GetCoordinate.Bind(8 + Offset) })
        Proto.DefineProp(Prefix 'T', { Get: RECT_GetCoordinate.Bind(4 + Offset) })
        Proto.DefineProp(Prefix 'TL', { Get: RECT_GetPoint.Bind('L', 'T') })
        Proto.DefineProp(Prefix 'Union', { Call: RECT_Union.Bind(Offset) })
        Proto.DefineProp(Prefix 'W', { Get: RECT_GetLength.Bind('R', 'L') })
        Proto.DefineProp(Prefix 'X', { Get: RECT_GetCoordinate.Bind(Offset) })
        Proto.DefineProp(Prefix 'Y', { Get: RECT_GetCoordinate.Bind(4 + Offset) })

    }
    /**
     * @description - Returns the intersection of this rectangle with another rectangle.
     * @param {Buffer|Rect} rc - The second rectangle.
     * @param {Integer} [Offset = 0] - The offset to add to `rc`'s ptr.
     * @returns {Rect} - If successful, the intersection of the two rectangles as a
     * new object. If unsuccessful, an empty string.
     */
    Intersect(rc, Offset := 0) {
        ; This is overridden
    }
    /**
     * @description - Splits a length into equivalent segments. The first index in the array
     * is always the same as `Pos`, then each subsequent value is the rounded sum of the previous
     * item's value and `Length / Divisor`.
     * @param {String} Dimension - Either "H", "Height", "W", or "Width". Only the first letter
     * of `Dimension` is evaluated.
     * @param {Integer} Divisor - The number of segments to split the length into.
     * @param {Integer} [DecimalPlaces = 0] - The value passed to `Round`'s second parameter.
     * @returns {Integer[]}
     */
    Split(Dimension, Divisor, DecimalPlaces := 0) {
        switch SubStr(Dimension, 1, 1), 0 {
            case 'h':
                Length := this.H
                Pos := this.T
            case 'w':
                Length := this.W
                Pos := this.L
            default:
                if IsObject(Dimension) {
                    throw TypeError('Invalid parameter type.', -1)
                } else {
                    throw ValueError('Unexpected value.', -1, Dimension)
                }
        }
        Result := [Pos]
        Delta := Length / Divisor
        Result.Capacity := Divisor + 1
        loop Divisor {
            Result.Push(Round(Pos += Delta, DecimalPlaces))
        }
        return Result
    }
    /**
     * This modifies the object's properties to be relative to a window.
     * @param {Integer} Hwnd - The handle to the window to which the rectangle's dimensions
     * will be evaluated as relative.
     * @param {Boolean} [InPlace = false] - If true, the function modifies the object's properties.
     * If false, the function creates a new object.
     * @returns {Rect}
     */
    ToClient(_Offset, Self, Hwnd, InPlace := false) {
        rc := InPlace ? this : Rect()
        if !DllCall('ScreenToClient', 'ptr', Hwnd, 'ptr', rc.ptr, 'int') {
            throw OSError()
        }
        if !DllCall('ScreenToClient', 'ptr', Hwnd, 'ptr', rc.ptr + 8, 'int') {
            throw OSError()
        }
        return rc
    }
    /**
     * This modifies the object's properties to be relative to the screen.
     * @param {Integer} Hwnd - The handle to the window to which the rectangle's dimensions
     * are currently relative.
     * @param {Boolean} [InPlace = false] - If true, the function modifies the object's properties.
     * If false, the function creates a new object.
     * @returns {Rect}
     */
    ToScreen(Hwnd, InPlace := false) {
        rc := InPlace ? this : Rect()
        if !DllCall('ClientToScreen', 'ptr', Hwnd, 'ptr', rc.ptr, 'int') {
            throw OSError()
        }
        if !DllCall('ClientToScreen', 'ptr', Hwnd, 'ptr', rc.ptr + 8, 'int') {
            throw OSError()
        }
        return rc
    }
    /**
     * Returns the smallest rectangle that completely encompasses both rectangles as a new object.
     * @param {Rect} rc - The second rectangle.
     * @param {Integer} [Offset = 0] - The offset to add to `rc`'s ptr.
     * @returns {Rect}
     */
    Union(rc, Offset := 0) {
        ; This is overridden
    }
}


RECT_GetCoordinate(_Offset, Self) => NumGet(Self, _Offset, 'int')
RECT_GetDpi(_Offset, Self) {
    if DllCall('Shcore\GetDpiForMonitor', 'ptr'
        , DllCall('User32.dll\MonitorFromRect', 'ptr', Self.Ptr + _Offset, 'uint', 0, 'ptr')
    , 'uint', 0, 'uint*', &DpiX := 0, 'uint*', &DpiY := 0, 'int') {
        throw OSError('MonitorFomPoint received an invalid parameter.', -1)
    } else {
        return DpiX
    }
}
RECT_GetLength(Dimension1, Dimension2, Self) => Self.%Dimension2% - Self.%Dimension1%
RECT_GetSegment(Dimension2, Dimension1, Divisor, Self, DecimalPlaces := 0) => Round((Self.%Dimension2% - Self.%Dimension1%) / Divisor, DecimalPlaces)
RECT_GetPoint(Dimension1, Dimension2, Self) => Point(Self.%Dimension1%, Self.%Dimension2%)
RECT_Intersect(_Offset, Self, Rc, Offset := 0) {
    _rc := Rect()
    if DLLCall('User32.dll\IntersectRect', 'ptr', _rc, 'ptr', Self.Ptr + _Offset, 'ptr', rc.Ptr + Offset, 'int') {
        return _rc
    }
}
RECT_Move(_Offset, Self, X?, Y?, W?, H?) {
    if IsSet(W) {
        if IsSet(X) {
            NumPut('int', X, Self, _Offset)
        }
        NumPut('int', X + W, Self, _Offset + 8)
    } else if IsSet(X) {
        NumPut('int', X + Self.W, Self, _Offset + 8)
        NumPut('int', X, Self, _Offset)
    }
    if IsSet(H) {
        if IsSet(Y) {
            NumPut('int', Y, Self, _Offset + 4)
        }
        NumPut('int', Y + H, Self, _Offset + 12)
    } else if IsSet(Y) {
        NumPut('int', Y + Self.H, Self, _Offset + 12)
        NumPut('int', Y, Self, _Offset + 4)
    }
}
RECT_Union(_Offset, Self, rc, Offset := 0) {
    _rc := Rect()
    if DllCall('UnionRect', 'ptr', _rc, 'ptr', rc.Ptr + _Offset, 'ptr', Self.Ptr + _Offset, 'int') {
        return rc
    }
}
WINRECT_Move(_Offset, Self, X?, Y?, W?, H?, InsertAfter := 0, Flags := 0) {
    RECT_Move(_Offset, Self, X ?? unset, Y ?? unset, W ?? unset, H ?? unset)
    if !DllCall('SetWindowPos', 'ptr', Self.Hwnd, 'ptr', InsertAfter, 'int', Self.X, 'int', Self.Y, 'int', Self.W, 'int', Self.H, 'uint', Flags, 'int') {
        throw OSError()
    }
}
WINRECT_MoveOnly(_Offset, Self, X, Y, InsertAfter := 0, Flags?) {
    NumPut('int', X + Self.W, Self, _Offset + 8)
    NumPut('int', X, Self, _Offset)
    NumPut('int', Y + Self.H, Self, _Offset + 12)
    NumPut('int', Y, Self, _Offset + 4)
    if IsSet(Flags) {
        Flags := Flags | 0x0001
    } else {
        Flags := 0x0001
    }
    if !DllCall('SetWindowPos', 'ptr', Self.Hwnd, 'ptr', InsertAfter, 'int', Self.X, 'int', Self.Y, 'int', Self.W, 'int', Self.H, 'uint', Flags, 'int') {
        throw OSError()
    }
}
