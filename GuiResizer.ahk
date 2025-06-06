/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/GuiResizer.ahk
    Author: Nich-Cebolla
    Version: 1.0.0
    License: MIT
*/

class GuiResizer {
    static Last := ''
    /**
     * @description - Creates a callback function to be used with
     * `Gui.Prototype.OnEvent('Size', Callback)`. This function requires a bit of preparation. See
     * the longer explanation within the source document for more information. Note that
     * `GuiResizer` modifies the `Gui.Prototype.Show` method slightly. This is the change:
        @example
        Gui.Prototype.DefineProp('Show', {Call: _Show})
        _Show(Self, Opt?) {
            Show := Gui.Prototype.Show
            this.JustShown := 1
            Show(Self, Opt ?? unset)
        }
        @
     * @param {Gui} GuiObj - The GUI object that contains the controls to be resized.
     * @param {Integer} [Interval=33] - The interval at which resizing occurs after initiated. Once
     * the `Size` event has been raised, the callback is set to a timer that loops every `Interval`
     * milliseconds and the event handler is temporarily disabled. After the function detects that
     * no size change has occurred within `StopCount` iterations, the timer is disabled and the
     * event handler is re-enabled. For more control over the visual appearance of the display as
     * resizing occurs, set `SetWinDelay` in the Auto-Execute portion of your script.
     * {@link https://www.autohotkey.com/docs/v2/lib/SetWinDelay.htm}
     * @param {Integer} [StopCount=6] - The number of iterations that must occur without a size
     * change before the timer is disabled and the event handler is re-enabled.
     * @param {Boolean} [SetSizerImmediately=true] - If true, the `Size` event is raised immediately
     * after the object is created. When this is true, you can call `GuiResizer` like a function:
     * `GuiResizer(ControlsArr)`. If you do need the instance object in some other portion of the
     * code or at some expected later time, the last instance created is available on the class
     * object `GuiResizer.Last`.
     * @param {Integer} [UsingSetThreadDpiAwarenessContext=-2] - The DPI awareness context to use.
     * This is necessary as a parameter because, when using a THREAD_DPI_AWARENESS_CONTEXT other than
     * the default, AutoHotkey's behavior when returning values from built-in functions is
     * inconsistent unless the awareness context is set each time before calling the function.
     * Understand that if you leave the value at -4, the OS expects that you will handle DPI scaling
     * within your code. Set this parameter to 0 to disable THREAD_DPI_AWARENESS_CONTEXT.
     */
    __New(GuiObj, Interval := 100, StopCount := 6, SetSizerImmediately := true, UsingSetThreadDpiAwarenessContext := -2) {
        GuiResizer.Last := this
        this.DefineProp('_Resize', {Call: ObjBindMEthod(this, 'Resize')})
        GuiObj.DefineProp('Show', {Call: _Show})
        this.Interval := Interval
        this.ExpiredCtrls := []
        this.DeltaW := this.DeltaH := 0
        this.StopCount := StopCount
        this.GuiObj := GuiObj
        this.Active := {ZeroCount: 0, LastW: 0, LastH : 0}
        this.Size := []
        this.Move := []
        this.MoveAndSize := []
        this.CurrentDPI := this.DPI := DllCall("User32\GetDpiForWindow", "Ptr", GuiObj.Hwnd, "UInt")
        this.SetThreadDpiAwarenessContext := UsingSetThreadDpiAwarenessContext
        this.GuiObj.GetClientPos(, , &gw, &gh)
        this.Shown := DllCall('IsWindowVisible', 'Ptr', GuiObj.Hwnd)
        this.Active.W := gw
        this.Active.H := gh
        ; GuiResizer.OutputDebug(this, A_ThisFunc, A_LineNumber, , 'Gui initial size: W' gw ' H' gh)
        for Ctrl in GuiObj {
            if !Ctrl.HasOwnProp('Resizer')
                continue
            Resizer := Ctrl.Resizer, z := FlagSize := FlagMove := 0
            Ctrl.GetPos(&cx, &cy, &cw, &ch)
            Ctrl.Resizer.pos := {x: cx, y: cy, w: cw, h: ch}
            if Resizer.HasOwnProp('x')
                z += 1
            if Resizer.HasOwnProp('y')
                z += 2
            switch z {
                case 0:
                    Resizer.x := 0, Resizer.y := 0
                case 1:
                    Resizer.y := 0, FlagMove := 1
                case 2:
                    Resizer.x := 0, FlagMove := 1
                case 3:
                    FlagMove := 1
            }
            z := 0
            if Resizer.HasOwnProp('w')
                z += 1
            if Resizer.HasOwnProp('h')
                z += 2
            switch z {
                case 0:
                    Resizer.w := 0, Resizer.h := 0
                case 1:
                    Resizer.h := 0, FlagSize := 1
                case 2:
                    Resizer.w := 0, FlagSize := 1
                case 3:
                    FlagSize := 1
            }
            if FlagSize {
                if FlagMove
                    this.MoveAndSize.Push(Ctrl)
                else
                    this.Size.Push(Ctrl)
            } else if FlagMove
                this.Move.Push(Ctrl)
            else
                throw Error('A control has ``Resizer`` property, but the property does not have'
                '`r`na ``w``, ``h``, ``x``, or ``y`` property.', -1, 'Ctrl name: ' Ctrl.Name)

            _Show(Self, Opt?) {
                Show := Gui.Prototype.Show
                this.JustShown := 1
                Show(Self, Opt ?? unset)
            }
        }
        if SetSizerImmediately
            GuiObj.OnEvent('size', this)
    }

    Call(GuiObj, MinMax, Width, Height) {
        if !this.Shown {
            this.GuiObj.GetClientPos(,, &gw, &gh)
            if gw <= 20
                return
            this.Active.W := gw, this.Active.H := gh
            ; GuiResizer.OutputDebug(this, A_ThisFunc, A_LineNumber,
            ; , 'Gui shown for the first time. Size: W' gw ' H' gh)
            this.Shown := 1
        }
        if this.HasOwnProp('JustShown') {
            this.DeleteProp('JustShown')
            ; GuiResizer.OutputDebug(this, A_ThisFunc, A_LineNumber, , 'Gui just shown')
            return
        }
        DPI := DllCall("User32\GetDpiForWindow", "Ptr", this.GuiObj.Hwnd, "UInt")
        if this.DPI != DPI {
            ; GuiResizer.OutputDebug(this, A_ThisFunc, A_LineNumber,
            ; , 'Dpi changed. Old: ' this.DPI '`tNew: ' DPI '.')
            this.DPI := DPI
            return
        }
        this.GuiObj.OnEvent('Size', this, 0)
        ; GuiResizer.OutputDebug(this, A_ThisFunc, A_LineNumber, , 'Resize timer activated.')
        SetTimer(this._Resize, this.Interval)
        this.Resize()
    }

    IterateCtrlContainers(SizeCallback, MoveCallback, MoveAndResizeCallback) {
        for Ctrl in this.Size
            SizeCallback(Ctrl)
        for Ctrl in this.Move
            MoveCallback(Ctrl)
        for Ctrl in this.MoveAndSize
            MoveAndResizeCallback(Ctrl)
    }

    IterateAll(Callback) {
        this.IterateCtrlContainers(Callback, Callback, Callback)
    }

    Resize(*) {
        if this.SetThreadDpiAwarenessContext
            DllCall("SetThreadDpiAwarenessContext", "ptr", this.SetThreadDpiAwarenessContext, "ptr")
        this.GuiObj.GetClientPos(,, &gw, &gh)
        if !(gw - this.Active.LastW) && !(gh - this.Active.LastH) {
            ; GuiResizer.OutputDebug(this, A_ThisFunc, A_LineNumber,
            ; , 'No change since last tick. ZeroCount: ' this.Active.ZeroCount)
            if ++this.Active.ZeroCount >= this.StopCount {
                ; GuiResizer.OutputDebug(this, A_ThisFunc, A_LineNumber, , 'Disabling timer.')
                SetTimer(this._Resize, 0)
                if this.ExpiredCtrls.Length
                    this.HandleExpiredCtrls()
                this.GuiObj.OnEvent('Size', this)
            }
            return
        }
        this.DeltaW := gw - this.Active.W
        this.DeltaH := gh - this.Active.H
        ; GuiResizer.OutputDebug(this, A_ThisFunc, A_LineNumber,
        ; , 'Resize function ticked. Size: W' gw ' H' gh)
        this.IterateCtrlContainers(_Size, _Move, _MoveAndSize)
        this.Active.LastW := gw, this.Active.LastH := gh

        _Size(Ctrl) {
            if !Ctrl.HasOwnProp('Resizer') {
                this.ExpiredCtrls.Push(Ctrl)
                return
            }
            ; GuiResizer.OutputDebug(this, A_ThisFunc, A_LineNumber, Ctrl, 'Before')
            this.GetDimensions(Ctrl, &W, &H)
            Ctrl.Move(,, W, H)
            ; GuiResizer.OutputDebug(this, A_ThisFunc, A_LineNumber, Ctrl, 'After')
        }

        _Move(Ctrl) {
            if !Ctrl.HasOwnProp('Resizer') {
                this.ExpiredCtrls.Push(Ctrl)
                return
            }
            ; GuiResizer.OutputDebug(this, A_ThisFunc, A_LineNumber, Ctrl, 'Before')
            this.GetCoords(Ctrl, &X, &Y)
            Ctrl.Move(X, Y)
            ; GuiResizer.OutputDebug(this, A_ThisFunc, A_LineNumber, Ctrl, 'After')
        }

        _MoveAndSize(Ctrl) {
            if !Ctrl.HasOwnProp('Resizer') {
                this.ExpiredCtrls.Push(Ctrl)
                return
            }
            ; GuiResizer.OutputDebug(this, A_ThisFunc, A_LineNumber, Ctrl, 'Before')
            this.GetCoords(Ctrl, &X, &Y), this.GetDimensions(Ctrl, &W, &H)
            Ctrl.Move(X, Y, W, H)
            ; GuiResizer.OutputDebug(this, A_ThisFunc, A_LineNumber, Ctrl, 'After')
        }
    }

    GetCoords(Ctrl, &X, &Y) {
        Resizer := Ctrl.Resizer, Pos := Resizer.Pos
        X := Resizer.X ? this.DeltaW * Resizer.X + Pos.X : Pos.X
        if X < 0
            X := 0
        Y := Resizer.Y ? this.DeltaH * Resizer.Y + Pos.Y : Pos.Y
        if Y < 0
            Y := 0
    }

    GetDimensions(Ctrl, &W, &H) {
        Resizer := Ctrl.Resizer, Pos := Resizer.Pos
        W := Resizer.W ? this.DeltaW * Resizer.W + Pos.W : Pos.W
        if W < 0
            W := 0
        H := Resizer.H ? this.DeltaH * Resizer.H + Pos.H : Pos.H
        if H < 0
            H := 0
    }

    HandleExpiredCtrls() {
        for Ctrl in this.ExpiredCtrls {
            FlagRemoved := 0
            for Container in [this.Size, this.Move, this.MoveAndSize] {
                for _Ctrl in Container {
                    if Ctrl.Name == _Ctrl.Name {
                        Container.RemoveAt(A_Index)
                        FlagRemoved := 1
                        break
                    }
                }
                if FlagRemoved
                    break
            }
            if FlagRemoved
                break
        }
    }

    /**
     * @description - Assigns the appropriate parameters to controls that are adjacent to one another.
     * The input controls must be aligned along one dimension; this method will not function as
     * expected if some are above others and also some are to the left or right of others. They must
     * be adjacent along a single axis. Use this when you have a small number of controls that you
     * want to be resized along with the GUI window. Be sure to handle any surrounding controls
     * so they don't overlap.
     * Here's some examples:

        ||||| ||||| |||||             |     |||||||
        ||||| ||||| |||||     - OK    |     |||||||         |||||   - NOT OK
        ||||| ||||| |||||             |     |||||||         |||||
        _________________             |     |||||||
        ||||        ||||              |
        ||||        ||||     - OK     |         |||||
        ||||                          |         |||||
              ||||                    |         |||||
              ||||                    |
              ||||                    |
                                      |
        @example
            ; You can run this example to see what it looks like
            GuiObj := Gui('+Resize -DPIScale')
            Controls := []
            Loop 4
                Controls.Push(GuiObj.Add('Edit', Format('x{} y{} w{} h{} vEdit{}'
                , 10 + 220 * (A_Index - 1), 10, 200, 400, A_Index)))
            GuiResizer.SetAdjacentControls(Controls)
            GuiResizer(GuiObj)
            GuiObj.Show()
        @
     * @param {Array} Controls - An array of controls to assign the appropriate parameters to.
     * @param {Boolean} Vertical - If true, the controls are aligned vertically; otherwise, they are aligned horizontally.
     * @param {Boolean} IncludeOpposite - If true, the opposite side of the control will be set to 1; otherwise, it will be set to 0.
     * @returns {Void}
     */
    static SetAdjacentControls(Controls, Vertical := false, IncludeOpposite := true) {
        static Letters := Map('X', 'H', 'Y', 'W', '_X', 'W', '_Y', 'H')
        local Count := Controls.Length, Result := [], CDF := [], Order := []
        , X := Y := W := H := 0
        if Controls.Length < 2 {
            if Controls.Length
                Controls.Resizer := {w: 1, h: 1}, Result.Push(Controls)
            return
        }
        if Vertical
            _Refactored('Y')
        else
            _Refactored('X')

        _Refactored(X_Or_Y) {
            _GetCDF(1 / Count), Proportion := 1 / Count, _GetOrder(X_Or_Y)
            for Ctrl in Order
                Ctrl.Resizer := {}, Ctrl.Resizer.%Letters['_' X_Or_Y]% := Proportion, Ctrl.Resizer.%X_Or_Y% := CDF[A_Index]
                , Ctrl.Resizer.%Letters[X_Or_Y]% := IncludeOpposite ? 1 : 0
        }
        _GetCDF(Step) {
            Loop Count
                CDF.Push(Step * (A_Index - 1))
        }
        _GetOrder(X_Or_Y) {
            for Ctrl in Controls {
                Ctrl.GetPos(&x, &y, &w, &h)
                Ctrl.__Resizer := {x: x, y: y}
                Order.Push(Ctrl)
            }
            InsertionSort(Order, 1, , ((X_Or_Y, a, b) => a.__Resizer.%X_Or_Y% - b.__Resizer.%X_Or_Y%).Bind(X_Or_Y))
            InsertionSort(arr, start, end?, compareFn := (a, b) => a - b) {
                i := start - 1
                while ++i <= (end??arr.Length) {
                    current := arr[i]
                    j := i - 1
                    while (j >= start && compareFn(arr[j], current) > 0) {
                        arr[j + 1] := arr[j]
                        j--
                    }
                    arr[j + 1] := current
                }
                return arr
            }
        }
    }

    /**
     * @description - Returns an integer representing the position of the first object relative
     * to the second object. This function assumes that the two objects do not overlap.
     * The inputs can be any of:
     * - A Gui object, Gui.Control object, or any object with an `Hwnd` property.
     * - An object with properties { L, T, R, B }.
     * - An Hwnd of a window or control.
     * @param {Integer|Object} Subject - The subject of the comparison. The return value indicates
     * the position of this object relative to the other.
     * @param {Integer|Object} Target - The object which the subject is compared to.
     * @returns {Integer} - Returns an integer representing the relative position shared between two objects.
     * The values are:
     * - 1: Subject is completely above target and completely to the left of target.
     * - 2: Subject is completely above target and neither completely to the right nor left of target.
     * - 3: Subject is completely above target and completely to the right of target.
     * - 4: Subject is completely to the right of target and neither completely above nor below target.
     * - 5: Subject is completely to the right of target and completely below target.
     * - 6: Subject is completely below target and neither completely to the right nor left of target.
     * - 7: Subject is completely below target and completely to the left of target.
     * - 8: Subject is completely below target and completely to the left of target.
     */
    static GetRelativePosition(Subject, Target) {
        _Get(Subject, &L1, &T1, &R1, &B1)
        _Get(Target, &L2, &T2, &R2, &B2)
        if L1 < L2 && R1 < L2 {
            if B1 < T2
                return 1
            else if T1 > B2
                return 7
            else
                return 8
        } else if T1 < T2 && B1 < T2 {
            if L1 > R2
                return 3
            else
                return 2
        } else if L1 < R2
            return 6
        else if T1 < B2
            return 4
        else
            return 5

        _Get(Input, &L, &T, &R, &B) {
            if IsObject(Input) {
                if !Input.HasOwnProp('Hwnd') {
                    L := Input.L, T := Input.T, R := Input.R, B := Input.B
                    return
                }
                WinGetPos(&L, &T, &W, &H, Input.Hwnd)
            } else
                WinGetPos(&L, &T, &W, &H, Input)
            R := L + W, B := T + H
        }
    }

    static OutputDebug(Resizer, Fn, Line, Ctrl?, Extra?) {
        if IsSet(Ctrl) {
            Ctrl.GetPos(&cx, &cy, &cw, &ch)
            OutputDebug('`n'
                Format(
                    'Function: {1}`tLine: {2}'
                    '`nControl: {3}'
                    '`nX: {4}`tY: {5}`tW: {6}`tH: {7}'
                    '`nDeltaW: {8}`tDeltaH: {9}'
                    '`nActiveW: {10}`tActiveH: {11}`tLastW: {12}`tLastH: {13}'
                    '`nExtra: {14}'
                    , Fn, Line, Ctrl.Name, cx, cy, cw, ch, Resizer.DeltaW, Resizer.DeltaH, Resizer.Active.W
                    , Resizer.Active.H, Resizer.Active.LastW, Resizer.Active.LastH, Extra ?? ''
                )
            )
        } else {
            OutputDebug('`n'
                Format(
                    'Function: {1}`tLine: {2}'
                    '`nDeltaW: {3}`tDeltaH: {4}'
                    '`nActiveW: {5}`tActiveH: {6}`tLastW: {7}`tLastH: {8}'
                    '`nExtra: {9}'
                    , Fn, Line, Resizer.DeltaW, Resizer.DeltaH, Resizer.Active.W, Resizer.Active.H
                    , Resizer.Active.LastW, Resizer.Active.LastH, Extra ?? ''
                )
            )
        }
    }
}
