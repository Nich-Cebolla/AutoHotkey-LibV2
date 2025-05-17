/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/Align.ahk
    Author: Nich-Cebolla
    Version: 1.1.0
    License: MIT
*/
; https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/RectHighlight.ahk
#include RectHighlight.ahk


class Align {
    static DPI_AWARENESS_CONTEXT := -3

    /**
     * @description - Centers the Subject window horizontally with respect to the Target window.
     * @param {Gui|Gui.Control|Align} Subject - The window to be centered.
     * @param {Gui|Gui.Control|Align} Target - The reference window.
     */
    static CenterH(Subject, Target) {
        Subject.GetPos(&X1, &Y1, &W1)
        Target.GetPos(&X2, , &W2)
        Subject.Move(X2 + W2 / 2 - W1 / 2, Y1)
    }

    /**
     * @description - Centers the two windows horizontally with one another, splitting the difference
     * between them.
     * @param {Gui|Gui.Control|Align} Win1 - The first window to be centered.
     * @param {Gui|Gui.Control|Align} Win2 - The second window to be centered.
     */
    static CenterHSplit(Win1, Win2) {
        Win1.GetPos(&X1, &Y1, &W1)
        Win2.GetPos(&X2, &Y2, &W2)
        diff := X1 + 0.5 * W1 - X2 - 0.5 * W2
        X1 -= diff * 0.5
        X2 += diff * 0.5
        Win1.Move(X1, Y1)
        Win2.Move(X2, Y2)
    }

    /**
     * @description - Centers the Subject window vertically with respect to the Target window.
     * @param {Gui|Gui.Control|Align} Subject - The window to be centered.
     * @param {Gui|Gui.Control|Align} Target - The reference window.
     */
    static CenterV(Subject, Target) {
        Subject.GetPos(&X1, &Y1, , &H1)
        Target.GetPos( , &Y2, , &H2)
        Subject.Move(X1, Y2 + H2 / 2 - H1 / 2)
    }

    /**
     * @description - Centers the two windows vertically with one another, splitting the difference
     * between them.
     * @param {Gui|Gui.Control|Align} Win1 - The first window to be centered.
     * @param {Gui|Gui.Control|Align} Win2 - The second window to be centered.
     */
    static CenterVSplit(Win1, Win2) {
        Win1.GetPos(&X1, &Y1, , &H1)
        Win2.GetPos(&X2, &Y2, , &H2)
        diff := Y1 + 0.5 * H1 - Y2 - 0.5 * H2
        Y1 -= diff * 0.5
        Y2 += diff * 0.5
        Win1.Move(X1, Y1)
        Win2.Move(X2, Y2)
    }

    /**
     * @description - Centers a list of windows horizontally with respect to one another, splitting
     * the difference between them. The center of each window will be the midpoint between the least
     * and greatest X coordinates of the windows.
     * @param {Array} List - An array of windows to be centered. This function assumes there are
     * no unset indices.
     */
    static CenterHList(List) {
        if !(hDwp := DllCall('BeginDeferWindowPos', 'int', List.Length, 'ptr')) {
            throw Error('``BeginDeferWindowPos`` failed.', -1)
        }
        List[-1].GetPos(&L, &Y, &W)
        Params := [{ Y: Y, M: W / 2, hWnd: List[-1].hWnd }]
        Params.Capacity := List.Length
        R := L + W
        loop List.Length - 1 {
            List[A_Index].GetPos(&X, &Y, &W)
            Params.Push({ Y: Y, M: W / 2, hWnd: List[A_Index].hWnd })
            if X < L
                L := X
            if X + W > R
                R := X + W
        }
        Center := (R - L) / 2 + L
        for ps in Params {
            if !(hDwp := DllCall('DeferWindowPos'
                , 'ptr', hDwp
                , 'ptr', ps.hWnd
                , 'ptr', 0
                , 'int', Center - ps.M
                , 'int', ps.Y
                , 'int', 0
                , 'int', 0
                , 'uint', 0x0001 | 0x0004 | 0x0010 ; SWP_NOSIZE | SWP_NOZORDER | SWP_NOACTIVATE
                , 'ptr'
            )) {
                throw Error('``DeferWindowPos`` failed.', -1)
            }
        }
        if !DllCall('EndDeferWindowPos', 'ptr', hDwp, 'ptr') {
            throw Error('``EndDeferWindowPos`` failed.', -1)
        }
        return
    }

    /**
     * @description - Centers a list of windows vertically with respect to one another, splitting
     * the difference between them. The center of each window will be the midpoint between the least
     * and greatest Y coordinates of the windows.
     * @param {Array} List - An array of windows to be centered. This function assumes there are
     * no unset indices.
     */
    static CenterVList(List) {
        if !(hDwp := DllCall('BeginDeferWindowPos', 'int', List.Length, 'ptr')) {
            throw Error('``BeginDeferWindowPos`` failed.', -1)
        }
        List[-1].GetPos(&X, &T, , &H)
        Params := [{ X: X, M: H / 2, hWnd: List[-1].hWnd }]
        Params.Capacity := List.Length
        B := T + H
        loop List.Length - 1 {
            List[A_Index].GetPos(&X, &Y, , &H)
            Params.Push({ X: X, M: H / 2, hWnd: List[A_Index].hWnd })
            if Y < T
                T := Y
            if Y + H > B
                B := Y + H
        }
        Center := (B - T) / 2 + T
        for ps in Params {
            if !(hDwp := DllCall('DeferWindowPos'
                , 'ptr', hDwp
                , 'ptr', ps.hWnd
                , 'ptr', 0
                , 'int', ps.X
                , 'int', Center - ps.M
                , 'int', 0
                , 'int', 0
                , 'uint', 0x0001 | 0x0004 | 0x0010 ; SWP_NOSIZE | SWP_NOZORDER | SWP_NOACTIVATE
                , 'ptr'
            )) {
                throw Error('``DeferWindowPos`` failed.', -1)
            }
        }
        if !DllCall('EndDeferWindowPos', 'ptr', hDwp, 'ptr') {
            throw Error('``EndDeferWindowPos`` failed.', -1)
        }
        return
    }

    /**
     * @description - Standardizes a group's width to the largest width in the group.
     * @param {Array} List - An array of windows to be standardized. This function assumes there are
     * no unset indices.
     */
    static GroupWidth(List) {
        if !(hDwp := DllCall('BeginDeferWindowPos', 'int', List.Length, 'ptr')) {
            throw Error('``BeginDeferWindowPos`` failed.', -1)
        }
        List[-1].GetPos(, , &GW, &H)
        Params := [{ H: H, hWnd: List[-1].hWnd }]
        Params.Capacity := List.Length
        loop List.Length - 1 {
            List[A_Index].GetPos(, , &W, &H)
            Params.Push({ H: H, hWnd: List[A_Index].hWnd })
            if W > GW
                GW := W
        }
        for ps in Params {
            if !(hDwp := DllCall('DeferWindowPos'
                , 'ptr', hDwp
                , 'ptr', ps.hWnd
                , 'ptr', 0
                , 'int', 0
                , 'int', 0
                , 'int', GW
                , 'int', ps.H
                , 'uint', 0x0002 | 0x0004 | 0x0010 ; SWP_NOMOVE | SWP_NOZORDER | SWP_NOACTIVATE
                , 'ptr'
            )) {
                throw Error('``DeferWindowPos`` failed.', -1)
            }
        }
        if !DllCall('EndDeferWindowPos', 'ptr', hDwp, 'ptr') {
            throw Error('``EndDeferWindowPos`` failed.', -1)
        }
        return
    }

    static GroupWidthCb(G, Callback, ApproxCount := 2) {
        if !(hDwp := DllCall('BeginDeferWindowPos', 'int', ApproxCount, 'ptr')) {
            throw Error('``BeginDeferWindowPos`` failed.', -1)
        }
        GW := -99999
        Params := []
        Params.Capacity := ApproxCount
        for Ctrl in G {
            Ctrl.GetPos(, , &W, &H)
            if Callback(&GW, W, Ctrl) {
                Params.Push({ H: H, hWnd: Ctrl.hWnd })
                break
            }
        }
        for ps in Params {
            if !(hDwp := DllCall('DeferWindowPos'
                , 'ptr', hDwp
                , 'ptr', ps.hWnd
                , 'ptr', 0
                , 'int', 0
                , 'int', 0
                , 'int', GW
                , 'int', ps.H
                , 'uint', 0x0002 | 0x0004 | 0x0010 ; SWP_NOMOVE | SWP_NOZORDER | SWP_NOACTIVATE
                , 'ptr'
            )) {
                throw Error('``DeferWindowPos`` failed.', -1)
            }
        }
        if !DllCall('EndDeferWindowPos', 'ptr', hDwp, 'ptr') {
            throw Error('``EndDeferWindowPos`` failed.', -1)
        }
        return
    }

    /**
     * @description - Standardizes a group's height to the largest height in the group.
     * @param {Array} List - An array of windows to be standardized. This function assumes there are
     * no unset indices.
     */
    static GroupHeight(List) {
        if !(hDwp := DllCall('BeginDeferWindowPos', 'int', List.Length, 'ptr')) {
            throw Error('``BeginDeferWindowPos`` failed.', -1)
        }
        List[-1].GetPos(, , &W, &GH)
        Params := [{ W: W, hWnd: List[-1].hWnd }]
        Params.Capacity := List.Length
        loop List.Length - 1 {
            List[A_Index].GetPos(, , &W, &H)
            Params.Push({ W: W, hWnd: List[A_Index].hWnd })
            if H > GH
                GH := H
        }
        for ps in Params {
            if !(hDwp := DllCall('DeferWindowPos'
                , 'ptr', hDwp
                , 'ptr', ps.hWnd
                , 'ptr', 0
                , 'int', 0
                , 'int', 0
                , 'int', ps.W
                , 'int', GH
                , 'uint', 0x0002 | 0x0004 | 0x0010 ; SWP_NOMOVE | SWP_NOZORDER | SWP_NOACTIVATE
                , 'ptr'
            )) {
                throw Error('``DeferWindowPos`` failed.', -1)
            }
        }
        if !DllCall('EndDeferWindowPos', 'ptr', hDwp, 'ptr') {
            throw Error('``EndDeferWindowPos`` failed.', -1)
        }
        return
    }

    static GroupHeightCb(G, Callback, ApproxCount := 2) {
        if !(hDwp := DllCall('BeginDeferWindowPos', 'int', ApproxCount, 'ptr')) {
            throw Error('``BeginDeferWindowPos`` failed.', -1)
        }
        GH := -99999
        Params := []
        Params.Capacity := ApproxCount
        for Ctrl in G {
            Ctrl.GetPos(, , &W, &H)
            if Callback(&GH, H, Ctrl) {
                Params.Push({ W: W, hWnd: Ctrl.hWnd })
                break
            }
        }
        for ps in Params {
            if !(hDwp := DllCall('DeferWindowPos'
                , 'ptr', hDwp
                , 'ptr', ps.hWnd
                , 'ptr', 0
                , 'int', 0
                , 'int', 0
                , 'int', ps.W
                , 'int', GH
                , 'uint', 0x0002 | 0x0004 | 0x0010 ; SWP_NOMOVE | SWP_NOZORDER | SWP_NOACTIVATE
                , 'ptr'
            )) {
                throw Error('``DeferWindowPos`` failed.', -1)
            }
        }
        if !DllCall('EndDeferWindowPos', 'ptr', hDwp, 'ptr') {
            throw Error('``EndDeferWindowPos`` failed.', -1)
        }
        return
    }

    /**
     * @description - Moves a window (`Subject`) adjacent to another window (`Target`) while
     * ensuring that `Subject` stays within the monitor's work area. `Align.MoveAdjacent` compares
     * the size of `Subject` with the amount of space between `Target` and the edges of the monitor.
     * If `Subject` can fit within the available space, `Align.MoveAdjacent` moves the window into
     * the empty space and aligns the opposite axis with `Subject` so their midpoints align.
     *
     * `Align.MoveAdjacent` searches in this order: Left, Top, Right, Bottom.
     *
     * If `Align.MoveAdjacent` does not find a large enough empty area to move `Target` into,
     * it usess the `DefaultX` and `DefaultY` values instead. `Align.MoveAdjacent` also returns
     * `1` whenever it fails to find a viable space into which to move the window.
     *
     * If you prefer to keep it dynamic, you can set `DefaultX` with a callable object that expects
     * an object as its only parameter. The function should move `Subject`, and optionally return
     * a value. The object will have the following properties:
     * - **Subject, Target, PaddingX, PaddingY, DefaultX,** and **DefaultY** are all included.
     * - **Mon**: The `QuickMon` object that is generated by the function.
     * - **SubjectDimensions** and **TargetDimensions**, both objects with { X, Y, W, H } properties
     * which are the position and size of the windows.
     *
     * The return value from the function is returned by `Align.MoveAdjacent` to the caller.
     *
     * Set `DefaultX` with zero or an empty string to direct `Align.MoveAdjacent` to skip moving
     * `Subject` if no viable space is found. `Align.MoveAdjacent` will still return `1`, but without
     * calling `Subject.Move`.
     *
     * `Align.MoveAdjacent` will also return `1` if the call to `MonitorFromWindow` fails, which
     * would likely be caused by `Target` having an invalid window handle, or if `Target` is not within
     * the visible area of any monitor.
     * @param {*} Subject - The object associated with the window that will be moved.
     * @param {*} Target - The object associated with the window that will be used as a reference.
     * @param {Number} PaddingX - The amount of padding to leave between `Subject` and `Target` on the X-axis.
     * @param {Number} PaddingY - The amount of padding to leave between `Subject` and `Target` on the Y-axis.
     * @param {Number|Func|Object} DefaultX - The X coordinate to move `Subject` to if no viable space is found,
     * or a callable object that will be called with the parameters described above in the function
     * description. Set to zero or an empty string to skip moving `Subject` if no viable space is found.
     * @param {Number} DefaultY - The Y coordinate to move `Subject` to if no viable space is found.
     * @returns {Integer} - Returns `1` if no viable space is found, or the return value of the callable object
     * if one is provided. Returns an empty string if the function is successful.
     */
    static MoveAdjacent(Subject, Target, PaddingX := 20, PaddingY := 20, DefaultX := 100, DefaultY := 100) {
        if hMon := DllCall('User32.dll\MonitorFromWindow', 'ptr', Target.hWnd, 'int', 0, 'ptr') {
            Mon := QuickMon(hMon)
            Target.GetPos(&tarX, &tarY, &tarW, &tarH)
            Subject.GetPos(&subX, &subY, &subW, &subH)
            if tarX - subW - PaddingX >= Mon.LW {
                Subject.Move(tarX - subW - PaddingX)
                this.CenterV(Subject, Target)
            } else if tarY - subH - PaddingY >= Mon.TW {
                Subject.Move(, tarY - subH - PaddingY)
                this.CenterH(Subject, Target)
            } else if tarX + tarW + PaddingX + subW <= Mon.RW {
                Subject.Move(tarX + tarW + PaddingX)
                this.CenterV(Subject, Target)
            } else if tarY + tarH + PaddingY + subH <= Mon.BW {
                Subject.Move(, tarY + tarH + PaddingY)
                this.CenterH(Subject, Target)
            } else {
                return _Default()
            }
        } else {
            return _Default()
        }

        _Default() {
            if DefaultX {
                if IsObject(DefaultX) {
                    return DefaultX({ Subject: Subject, Target: Target, PaddingX: PaddingX, PaddingY: PaddingY
                    , DefaultX: DefaultX, DefaultY: DefaultY, Mon: Mon, SubjectDimensions: { X: subX
                    , Y: subY, W: subW, H: subH }, TargetDimensions: { X: tarX, Y: tarY, W: tarW, H: tarH } })
                } else {
                    Subject.Move(DefaultX, DefaultY)
                }
            }
            return 1
        }
    }

    /**
     * @description - Allows the usage of the `_S` suffix for each function call. When you include
     * `_S` at the end of any function call, the function will call `SetThreadDpiAwarenessContext`
     * prior to executing the function. The value used will be `Align.DPI_AWARENESS_CONTEXT`, which
     * is initialized at `-4`, but you can change it to any value.
     * @example
        Align.DPI_AWARENESS_CONTEXT := -5
     * @
     */
    static __Call(Name, Params) {
        Split := StrSplit(Name, '_')
        if this.HasMethod(Split[1]) && Split[2] = 'S' {
            DllCall('SetThreadDpiAwarenessContext', 'ptr', this.DPI_AWARENESS_CONTEXT, 'ptr')
            if Params.Length {
                return this.%Split[1]%(Params*)
            } else {
                return this.%Split[1]%()
            }
        } else {
            throw PropertyError('Property not found.', -1, Name)
        }
    }
    ; static __New() {
    ;     if this.Prototype.__Class == 'Align' {
    ;         this.DefineProp('SelectControlsHelperCollection', { Value: Map() })
    ;         this.SelectControlsHelperCollection.CaseSense := false
    ;         this.DefineProp('SelectControlsDefault', { Value: {
    ;             Capacity: 100
    ;           , ExcludeNames: ''
    ;           , ExcludeTypes: ''
    ;           , InfoWindowMessage: ''
    ;           , InfoWindowTitle: 'SelectControls'
    ;           , RectHighlightOpt: ''
    ;         } })
    ;     }
    ; }

    /**
     * @description - Creates a proxy for non-AHK windows.
     * @param {hWnd} hWnd - The handle of the window to be proxied.
     */
    __New(hWnd) {
        this.hWnd := hWnd
    }

    GetPos(&X?, &Y?, &W?, &H?) {
        WinGetPos(&X, &Y, &W, &H, this.hWnd)
    }

    Move(X?, Y?, W?, H?) {
        WinMove(X ?? unset, Y ?? unset, W ?? unset, H ?? unset, this.hWnd)
    }

    __Call(Name, Params) {
        Split := StrSplit(Name, '_')
        if this.HasMethod(Split[1]) && Split[2] = 'S' {
            DllCall('SetThreadDpiAwarenessContext', 'ptr', Align.DPI_AWARENESS_CONTEXT, 'ptr')
            if Params.Length {
                return this.%Split[1]%(Params*)
            } else {
                return this.%Split[1]%()
            }
        } else {
            throw PropertyError('Property not found.', -1, Name)
        }
    }
}

/**
 * @classdesc - This is a simplified version of a class from another script I'm working on.
 * `QuickMon` is a buffer object that is intended to be passed to `GetMonitorInfo`. `QuickMon`
 * contains additional properties to simplify usage of the resulting values.
 */
class QuickMon extends Buffer {
    __New(hMon?) {
        this.Size := 40
        NumPut('int', 40, this)
        if IsSet(hMon) {
            this.hMon := hMon
            if !DllCall('user32\GetMonitorInfo', 'ptr', hMon, 'ptr', this, 'int') {
                throw OSError()
            }
        }
    }

    Dpi {
        Get {
            if !DllCall('Shcore\GetDpiForMonitor'
              , 'ptr', this.hMon
              , 'UInt', 0
              , 'UInt*', &DpiX := 0
              , 'UInt*', &DpiY := 0
              , 'UInt'
            ) {
                return DpiX
            } else {
                throw OSError()
            }
        }
    }

    ; Top left coordinate
    TL => { L: this.L, T: this.T }
    ; Bottom right coordinate
    BR => { R: this.R, B: this.B }
    ; Left
    L => NumGet(this, 4, 'Int')
    ; X, same as L
    X => NumGet(this, 4, 'Int')
    ; Top
    T => NumGet(this, 8, 'Int')
    ; Y, same as T
    Y => NumGet(this, 8, 'Int')
    ; Right
    R => NumGet(this, 12, 'Int')
    ; Bottom
    B => NumGet(this, 16, 'Int')
    ; Width
    W => this.R - this.L
    ; Height
    H => this.B - this.T
    ; The window's midpoint along the X-axis relative to the screen
    MidX => (this.R - this.L) / 2
    ; The window's midpoint along the Y-axis relative to the screen
    MidY => (this.B - this.T) / 2
    ; Returns nonzero if the monitor associated with this object is the primary monitor
    Primary => NumGet(this, 36, 'Uint')

    ; The below properties are the same as the above but for the monitor's "work area".
    TLW => { L: this.LW, T: this.TW }
    BRW => { R: this.RW, B: this.BW }
    LW => NumGet(this, 20, 'int')
    XW => NumGet(this, 20, 'Int')
    TW => NumGet(this, 24, 'int')
    YW => NumGet(this, 24, 'Int')
    RW => NumGet(this, 28, 'int')
    BW => NumGet(this, 32, 'int')
    WW => this.RW - this.LW
    HW => this.BW - this.TW
    MidXW => (this.RW - this.LW) / 2
    MidYW => (this.BW - this.TW) / 2
}
