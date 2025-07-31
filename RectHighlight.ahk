/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/RectHighlight.ahk
    Author: Nich-Cebolla
    License: MIT
*/

/**
 * @classdesc -
 * Displays a the outline of a rectangle, and has methods for manipulating the rectangle.
 * Adapted from {@link https://github.com/Descolada/UIAutomation}
 */
class RectHighlight extends Gui {
    /**
     * @class
     * @param {*} [Obj] - The object around which the highlighted region will be drawn, or any object
     * that can provide the needed information. `RectHighlight` will attempt to get the dimensions
     * from the object in this order, stopping as soon as the dimensions have been defined:
     * - If the object has a `GetPos` method, `RectHighlight` will call `Obj.GetPos(&x, &y, &w, &h)`.
     * - If the object has an `hWnd` property, `RectHighlight` will call `WinGetPos(&x, &y, &w, &h, Obj.hWnd)`.
     * - If the object has neither of the above properties, the object may have any of the following
     * combinations of properties:
     *   - { L, T, R, B }
     *   - { Left, Top, Right, Bottom }
     *   - { X, Y, W, H }
     *   - { X, Y, Width, Height }
     * - If none of these are found, `RectHighlight` throws an error.
     *
     * @param {Object} [Options] - An object with zero or more of the following properties:
     * @param {Boolean} [Options.Blink=false] - `Options.Blink` changes the function used when
     * `Options.Duration > 0`. When `Options.Duration > 0`, and when the timer is activated, the
     * function associated with the timer is called every `Options.Duration` milliseconds. When
     * `Options.Blink` is nonzero, each time the function is called, the visibility of the rectangle
     * is toggled on / off. When `Options.Blink` is falsy, each time the function is called the
     * visibility of the rectangle is not cheanged; insteaad, the position and size of the rectangle
     * is updated using the `Obj` object's current position and size. When `Options.Duration <= 0`,
     * `Options.Blink` has no effect.
     * @param {Integer} [Options.Border=2] - The border thickness in pixels.
     * @param {String} [Options.Color='00e0fe'] - The color of the highlighting. The default value is
     * a light blue.
     * @param {Integer} [Options.Duration=-3000] - The duration (milliseconds) passed to `SetTimer`.
     * - See the description of `Options.Blink` for information about how `Options.Duration` is used
     * when it is a positive number.
     * - If `Options.Duration` is a negative number, the highlighted area will be visible for the
     * duration then will auto-hide after the duration passes.
     * - If zero, the highlighted area will be visible indefinitely.
     *
     * @see {@link RectHighlight#Call} for more information about toggling visibility and using the
     * timer.
     *
     * Use `Hide` or `Show` (built-in Gui methods) to toggle visibility independently from the timer.
     * @param {Integer} [Options.OffsetL=0] - Any number of pixels to offset the left side of the
     * highlighted region.
     * @param {Integer} [Options.OffsetT=0] - Any number of pixels to offset the top of the
     * highlighted region.
     * @param {Integer} [Options.OffsetR=0] - Any number of pixels to offset the right side of the
     * highlighted region.
     * @param {Integer} [Options.OffsetB=0] - Any number of pixels to offset the bottom of the
     * highlighted region.
     * @param {String} [Options.PositionFontOpt = "q5 c" Options.Color] - The font options for the coordinates,
     * if the coordinates are in use. If unset, or if the value does not contain a color option,
     * the color will be set to the same as `Options.Color`.
     * @param {String} [Options.PositionFontName = ""] - The name of the font for the
     * coodinates, if the coordinates are in use.
     * @param {String} [Options.Title = "Highlight"] - The title to assign to the window.
     *
     * @param {Boolean} [ShowImmediately=true] - Note that if `Obj` is unset, `ShowImmediately` is
     * ignored. If `ShowImmediately` is nonzero, the rectangle is displayed before `RectHighlght.Call`
     * returns. Additionally, if `Options.Duration` is nonzero, the timer is initiated. If `ShowImmediately`
     * is falsy, the object is created and returned but the window remains hidden.
     * @returns {RectHighlight}
     */
    static Call(Obj?, Options?, ShowImmediately := true) {
        Options := this.Options(Options ?? {})
        ObjSetBase(G := Gui('+AlwaysOnTop -Caption +ToolWindow -DPIScale +E0x08000000', Options.Title), this.Prototype)
        G.Options := Options
        G.Timer := false
        ; Some gui methods return incorrect values if the window was never shown.
        G.Show()
        G.Hide()
        G.L := G.T := G.W := G.H := 0
        G.SetTimerFunc('', 1)
        G.SetTimerFunc('', 2)
        if ShowImmediately && IsSet(Obj) {
            G(Obj, G.Options)
        }
        return G
    }

    /**
     * @description - Toggles the timer, optionally toggling the visibility of the highlighted
     * rectangle. The way visibility is toggled depends on some conditions:
     * - If `RectHighlightObj.Timer` is nonzero at the start of the call, visibility is not toggled.
     * This is an explanation of why this design choice was made: `RectHighlightObj.Timer` is only
     * set with a nonzero value when `Options.Duration > 0`. When `Options.Duration > 0`, and when
     * `Options.Blink` is nonzero, the visibility of the rectangle will be toggled every time the
     * timer calls its function. Therefore, if `RectHighlightObj.Timer > 0`, the visibility is going
     * to be toggled anyway when the timer calls the function for the last time before disabling
     * itself.
     *
     * - If `Options.Blink` is falsy, visibility is never toggled. This is because the timer updates
     * the position and/or size of the rectangle instead of toggling visibility.
     *
     * You can specify a visibility status with the `Visibility` parameter; anything nonzero will
     * show the rectangle, and anything falsy will hide it. Adjusting the visibility using the
     * `Visibility` parameter does not invoke any callbacks you have set.
     *
     * In all other cases, these rules are applied:
     *
     * - If `Options.Duration > 0`, visibility is not toggled.
     * - If `Options.Duration` is falsy:
     *   - If `Visibility` is set, it takes precedence; `RectHighlight.Prototype.Call` will set the
     * visibility according to the value.
     *   - If `Visibility` is not set, visibility is toggled.
     * - If `Options.Duration < 0`, visibility is toggled only when `ReectHighlightObj.Visible` is
     * falsy (i.e. when the rectangle is not currently visible it will be toggled and made visible).
     * If `RectHighlight.Prototype.Call` is called when the rectangle is already visible, the timer
     * is refreshed to `Options.Duration` milliseconds. If you need to force the rectangle to hide,
     * pass zero to `Visibility`.
     * @param {*} [Obj] - This parameter has the same requirements as the `Obj` parameter of
     * `RectHighlight.Call`. When calling `RectHighlight.Prototype.Call`, you can optionally pass a
     * new object to change the characteristics of the highlighted rectangle. Passing an object is
     * unnecessary if you intend to use the same object used when the instance was created or when
     * `RectHighlight.Prototype.Call` was last called; the input object is cached on the `RectHighlight`
     * object.
     * @param {Object} [Options] - An object containing property : value pairs representing the options
     * to set on the `RectHighlight` object. The options are the same as the parameters of
     * `RectHighlight.Call` (except for `Obj` and `ShowImmediately`). Valid values are:
     * { Border, Color, Duration, OffsetL, OffsetT, OffsetR, OffsetB }.
     * @param {Boolean} [Visibility] - If set, the visibility of the highlighted rectangle will be set to
     * this value.
     */
    Call(Obj?, Options?, Visibility?) {
        if IsSet(Options) {
            this.HighlightSetOpt(Options)
        } else {
            this.BackColor := this.Color
        }
        if IsSet(Obj) {
            this.Options.DefineProp('Obj', { Value: Obj })
        } else if !this.Options.Obj {
            throw Error('``RectHighlight`` cannot calculate dimensions until a reference object has been provided.', -1)
        }
        if this.Timer {
            this.Timer := false
        } else {
            if this.Duration {
                if this.Duration > 0 {
                    this.SetRegion(false)
                    this.Timer := true
                    SetTimer(this.TimerFunc, this.Duration)
                } else {
                    this.SetRegion()
                    this.Timer := false
                    SetTimer(this.TimerFunc, this.Duration)
                }
            } else {
                this.Timer := false
                if IsSet(Visibility) {
                    _Proc()
                    return
                }
                if this.Visible {
                    this.TimerHide()
                } else {
                    if this.OnShowActive {
                        this.OnShow()
                    }
                    this.SetRegion()
                }
            }
        }
        if IsSet(Visibility) {
            _Proc()
        }

        _Proc() {
            if Visibility {
                this.SetRegion()
            } else {
                this.Hide()
            }
        }
    }

    ConstructPositionDisplay() {
        Options := this.Options
        G := this.PositionDisplay := Gui('+AlwaysOnTop -Caption +ToolWindow -DPIScale +Owner' this.Hwnd, Options.Title)
        WinSetTransparent(0, G.Hwnd)
        if Options.PositionFontOpt && RegExMatch(Options.PositionFontOpt, '\b[cC]') {
            G.SetFont(Options.PositionFontOpt, Options.PositionFontName || unset)
        } else {
            G.SetFont('c' Options.Color ' ' (Options.PositionFontOpt ? Options.PositionFontOpt : 'q5'), Options.PositionFontName || unset)
        }
        this.TopLeft := G.Add('Text', 'BackgroundTrans vTxtTL', '-00000, -00000')
        this.TopRight := G.Add('Text', 'BackgroundTrans Right vTxtTR', '-00000, -00000')
        this.BottomRight := G.Add('Text', 'BackgroundTrans Right vTxtBR', '-00000, -00000')
        this.BottomLeft := G.Add('Text', 'BackgroundTrans vTxtBL', '-00000, -00000')
        this.TopLeft.Text := this.TopRight.Text := this.BottomRight.Text := this.BottomLeft.Text := ''
        this.TopLeft.GetPos(, , &txtw, &txth)
        this.TopLeft.W := txtw
        this.TopLeft.H := txth
        G.Show()
    }

    /**
     * @description - Deletes the input `Obj` from the `Options` object, and calls `this.Destroy()`.
     */
    Dispose() {
        if this.HasOwnProp('Options') {
            if this.Options.HasOwnProp('Obj') {
                this.Options.DeleteProp('Obj')
            }
            this.DeleteProp('Options')
        }
        this.Destroy()
    }

    /**
     * @description - Returns a function object that can be set as an object method. The function
     * simply calls `RectHighlight.Prototype.Call`, but is compatible with being a method of
     * some other object. The function will forward parameters to `RectHighlight.Prototype.Call`.
     * @param {Boolean} [FirstParamOnly=false] - If true, the function will only forward the first
     * parameter to `RectHighlight.Prototype.Call`. This is useful if you want to use an event handler
     * with a Gui object. Since the first parameter will be the control or Gui object that triggered
     * the event, the object is forwarded to `RectHighlight.Prototype.Call` to highlight it.
     * If false, all parameters are forwarded to `RectHighlight.Prototype.Call`.
     * @returns {BoundFunc} - A function that can be set as an object method.
     *
     * @example
     *  EventHandler := {}
     *  G := Gui('+Resize', , EventHandler)
     *  loop 10 {
     *      G.Add('Button', , 'Button ' A_Index).OnEvent('Click', 'HClickButtonHighlight')
     *  }
     *  ; Call the constructor without an initial object.
     *  Highlighter := RectHighlight(, { Duration: -5000, OffsetR: 5, OffsetL: 5, OffsetT: 5, OffsetB: 5 })
     *  EventHandler.DefineProp('HClickButtonHighlight', { Call: Highlighter.GetFunc(true) })
     *  G.Show()
     *  ; Clicking the buttons should display a highlighted rectangle around the button.
     * @
     */
    GetFunc(FirstParamOnly := false) {
        return FirstParamOnly ? _Call1.Bind(this) : _Call2.Bind(this)
        _Call1(RectHighlightObj, Self, Params*) {
            return RectHighlightObj(Params[1])
        }
        _Call2(RectHighlightObj, Self, Params*) {
            return RectHighlightObj(Params*)
        }
    }

    /**
     * @description - Performs the calculations to get the position and dimensions from the input object.
     * This does not apply offsets.
     * @param {Object} Obj - The object from which to get the position and dimensions.
     * @throws {ValueError} - If the input object does not have the required properties for `RectHighlight`.
     */
    GetPos(Obj) {
        if HasMethod(Obj, 'GetPos') {
            Obj.GetPos(&x, &y, &w, &h)
            if Obj is Gui.Control {
                Obj.Gui.GetClientPos(&gx, &gy)
                x += gx
                y += gy
            }
        } else if HasProp(Obj, 'hWnd') {
            WinGetPos(&x, &y, &w, &h, Obj.hWnd)
            if Obj is Gui.Control {
                Obj.Gui.GetClientPos(&gx, &gy)
                x += gx
                y += gy
            }
        } else {
            for Arr in RectHighlight.__Properties {
                Flag := 1
                for Prop in Arr {
                    if !HasProp(Obj, Prop) {
                        Flag := 0
                        break
                    }
                }
                if Flag {
                    switch A_Index {
                        case 1, 2:
                            x := Obj.%Arr[1]%
                            y := Obj.%Arr[2]%
                            w := x + Obj.%Arr[3]%
                            h := y + Obj.%Arr[4]%
                        case 3, 4:
                            x := Obj.%Arr[1]%
                            y := Obj.%Arr[2]%
                            w := Obj.%Arr[3]%
                            h := Obj.%Arr[4]%
                    }
                    break
                }
            }
        }
        if IsSet(x) {
            result := x !== this.L || y !== this.T || w !== this.W || h !== this.H
            this.L := x
            this.T := y
            this.W := w
            this.H := h
            return result
        } else {
            throw ValueError('The input object dose not have the required properties for ``RectHighlight``.', -1, 'Type(Obj) == ' Type(Obj))
        }
    }

    /**
     * @description - Calculates the position and size of the rectangle, and moves the window.
     */
    HighlightMove() {
        O := this.Options
        if this.GetPos(O.Obj) {
            this.Move(
                this.L - O.OffsetL - O.Border
              , this.T - O.OffsetT - O.Border
              , this.W + O.Border * 2 + O.OffsetL + O.OffsetR
              , this.H + O.Border * 2 + O.OffsetT + O.OffsetB
            )
        }
    }

    /**
     * @description - Updates the options.
     * @param {Object} Options - An object with property : value pairs for zero or more options. See
     * the parameter hint above `RectHighlight.Call` for details about the options. Here is a list
     * of valid options: { Blink, Border, Color, Duration, OffsetL, OffsetT, OffsetR, OffsetB,
     * OnHide, OnShow }
     * @param {Boolean} [SuppressPropertyError=false] - Specifies what `RectHighlight.Prototype.HighlightSetOpt`
     * does if it encounters a property that is not a valid option.
     * - If false, throws an error.
     * - If true, skips the property.
     */
    HighlightSetOpt(Options, SuppressPropertyError := false) {
        if this.HasOwnProp('Options') {
            O := this.Options
            for Prop, Value in Options.OwnProps() {
                if Prop = 'OnHide' {
                    this.SetCallback(Value)
                } else if Prop = 'OnMove' {
                    this.SetCallback( , Value)
                } else if Prop = 'OnShow' {
                    this.SetCallback( , , Value)
                } else if HasProp(O, Prop) {
                    if Value || Value == 0 {
                        O.DefineProp(Prop, { Value: Value })
                    } else {
                        O.DeleteProp(Prop)
                    }
                } else if !SuppressPropertyError {
                    throw PropertyError('Invalid option.', -1, Prop)
                }
            }
        } else {
            this.DefineProp('Options', { Value: RectHighlight.Options(Options) })
            if Options.OnHide {
                this.SetCallback(Options.OnHide)
            }
            if Options.OnMove {
                this.SetCallback(, Options.OnMove)
            }
            if Options.OnShow {
                this.SetCallback(, , Options.OnShow)
            }
        }
        this.BackColor := O.Color
    }

    OnHide() {
        this.__ThrowOverrideError(A_ThisFunc)
    }
    OnMove() {
        this.__ThrowOverrideError(A_ThisFunc)
    }
    OnShow() {
        this.__ThrowOverrideError(A_ThisFunc)
    }

    SetCallback(OnHide?, OnMove?, OnShow?) {
        if IsSet(OnShow) {
            _Proc('OnShow', OnShow)
        }
        if IsSet(OnHide) {
            _Proc('OnHide', OnHide)
        }
        if IsSet(OnMove) {
            _Proc('OnMove', OnMove)
        }
        _Proc(Prop, Value) {
            if Value {
                this.DefineProp(Prop, { Call: Value })
            } else {
                if this.HasOwnProp(Prop) {
                    this.DeleteProp(Prop)
                } else {
                    throw PropertyError('No callback has been set.', -1, Prop)
                }
            }
        }
    }

    SetCoordinates() {
        O := this.Options
        border := O.Border
        this.TopLeft.Text := '( ' this.L ', ' this.T ' )'
        this.TopLeft.Move(border + 1, border + 1)
        this.TopRight.Text := '( ' (this.L + this.W) ', ' this.T ' )'
        this.TopRight.Move(this.W - this.TopLeft.W - border - 1, border + 1)
        this.BottomRight.Text := '( '  (this.L + this.W) ', ' (this.T + this.H) ' )'
        this.TopRight.Move(this.W - this.TopLeft.W - border - 1, this.H - this.TopLeft.H - border - 1)
        this.BottomLeft.Text := '( ' this.L ', ' (this.T + this.H) ' )'
        this.TopRight.Move(border + 1, this.H - this.TopLeft.H - border - 1)
    }

    SetPositionControlsState(Value) {
        this.TopLeft.Visible := this.TopRight.Visible := this.BottomRight.Visible := this.BottomLeft.Visible :=
        this.TopLeft.Enabled := this.TopRight.Enabled := this.BottomRight.Enabled := this.BottomLeft.Enabled := Value
    }

    /**
     * @description - Adjusts the rectangle's dimensions using the options.
     * `RectHighlight.Prototype.SetRegion` uses the following options to set the rectangle's
     * dimensions: Border, OffsetL, OffsetT, OffsetR, OffsetB, Obj.
     * @param {Boolean} [Show=true] - If true, `RectHighlight.Prototype.SetRegion` also does these
     * actions:
     * - Sets `RectHighlightObj.Visible := true`
     * - Calls `RectHighlightObj.Show('NoActivate')`
     */
    SetRegion(Show := true) {
        O := this.Options
        border := O.Border
        if this.GetPos(O.Obj) {
            WinSetRegion(Format('0-0 {1}-0 {1}-{2} 0-{2} 0-0    {3}-{4} {5}-{4} {5}-{6} {3}-{6} {3}-{4}'
                    , OuterR := this.W + border * 2 + O.OffsetL + O.OffsetR           ; Outer right - 1
                    , OuterB := this.H + border * 2 + O.OffsetT + O.OffsetB           ; Outer bottom - 2
                    , border                                                      ; Inner left - 3
                    , border                                                      ; Inner top - 4
                    , OuterR - border                                             ; Inner right - 5
                    , OuterB - border                                             ; Inner bottom - 6
                ), this.hWnd
            )
            this.Move(this.L - O.OffsetL - border, this.T - O.OffsetT - border, OuterR, OuterB)
        }
        if !this.Visible && Show {
            this.Show('NoActivate')
        }
    }

    /**
     * @description - Modifies the function that is called by `SetTimer`. There are two sets of
     * functions, and which is used depends on the value of `Options.Blink`. To modify a specific
     * function, set the `Which` parameter. To modify the function associated with the current
     * `Options.Blink` value, leave `Which` unset.
     *
     * This also changes the value returned by the property `RectHighlight.Prototype.TimerFunc`.
     * @param {*} Function - Any callable object, such as a `Func`, an object with a `Call` method,
     * or an object with a `__Call` method. To direct `RectHighlight.Prototype.SetTimerFunc` to
     * revert a modified function back to the built-in function, pass zero or an empty string to
     * `Function`.
     * @param {Integer} [Which] - Set `Which` to specify which function to adjust. Valid values are:
     * - 1: The function used when `Options.Blink` is falsy will be modified.
     * - 2: The function used when `Options.Blink` is nonzero will be modified.
     * - Unset: The function associated with the current `Options.Blink` value will be modified.
     */
    SetTimerFunc(Function, Which?) {
        if !IsSet(Which) {
            Which := this.Blink ? 2 : 1
        }
        if Which == 1 {
            if Function {
                this.DefineProp('__Func_Move', { Value: Function })
            } else {
                this.DefineProp('__Func_Move', { Value: ObjBindMethod(this, '__Timer_Move') })
            }
        } else {
            if Function {
                this.DefineProp('__Func_Blink', { Value: Function })
            } else {
                this.DefineProp('__Func_Blink', { Value: ObjBindMethod(this, '__Timer_Blink') })
            }
        }
    }

    /**
     * @description - Calls the `OnHide` callback if in use, hides the window, and sets
     * `RectHighlightObj.Visible := false`.
     */
    TimerHide() {
        if this.OnHideActive {
            this.OnHide()
        }
        this.Hide()
    }

    __ThrowOverrideError(fn) {
        throw Error('The method must be overridden.', -2, fn)
    }
    __Timer_Blink() {
        ; To handle cases when the setting is changed directly on the options object while a
        ; timer is currently active.
        if !this.Blink {
            SetTimer(, 0)
            return
        }
        if this.Timer {
            if this.Visible {
                this.TimerHide()
            } else {
                if this.OnShowActive {
                    this.OnShow()
                }
                this.SetRegion()
            }
        } else {
            SetTimer(, 0)
            this.TimerHide()
        }
    }
    __Timer_Move() {
        ; To handle cases when the setting is changed directly on the options object while a
        ; timer is currently active.
        if this.Blink {
            SetTimer(, 0)
            return
        }
        if this.Visible {
            if this.Timer {
                if this.OnMoveActive {
                    this.OnMove()
                }
                this.SetRegion(false)
            } else {
                SetTimer(, 0)
                this.TimerHide()
            }
        } else {
            if this.Timer {
                if this.OnShowActive {
                    this.OnShow()
                }
                this.SetRegion()
            }
        }
    }

    Blink {
        Get => this.Options.Blink
        Set {
            if !Value = !this.Options.Blink {
                return
            }
            SetTimer(this.TimerFunc, 0)
            this.Options.Blink := 1
            if this.Timer {
                SetTimer(this.TimerFunc, this.Duration)
            }
        }
    }

    Border {
        Get => this.Options.Border
        Set => this.Options.Border := Value
    }

    Color {
        Get => this.Options.Color
        Set => this.Options.Color := Value
    }

    Duration {
        Get => this.Options.Duration
        Set => this.Options.Duration := Value
    }

    Obj {
        Get => this.Options.Obj
        Set {
            this.Options.Obj := Value
            this.SetRegion(false)
        }
    }

    OffsetB {
        Get => this.Options.OffsetB
        Set => this.Options.OffsetB := Value
    }

    OffsetL {
        Get => this.Options.OffsetL
        Set => this.Options.OffsetL := Value
    }

    OffsetR {
        Get => this.Options.OffsetR
        Set => this.Options.OffsetR := Value
    }

    OffsetT {
        Get => this.Options.OffsetT
        Set => this.Options.OffsetT := Value
    }

    OnHideActive => this.HasOwnProp('OnHide')
    OnMoveActive => this.HasOwnProp('OnMove')
    OnShowActive => this.HasOwnProp('OnShow')

    /**
     * @description - `RectHighlight.Prototype.TimerFunc` has an optional parameter `Which`.
     * `Which` is intended to be used in cases when getting or setting a specific function object is
     * needed.
     *
     * Regarding the getter:
     *
     * The function returned by the getter depends on the value of `Options.Blink`, and whether you
     * have set your own callback function using `RectHighlight.Prototype.SetTimerFunc`. In either
     * case, the function object is located on the `RectHighlightObj.__Func_Move` property or the
     * `RectHighlightObj.__Func_Blink` property.
     *
     * If `Which` is set, the current value of `Options.Blink` is ignored.
     * - If `Which` is 1, returns `RectHighlightObj.__Func_Move`, which is the function used when
     * `Options.Blink` is falsy.
     * - If `Which` is 2, returns `RectHighlightObj.__Func_Blink`, which is the function used when
     * `Options.Blink` is nonzero.
     * - If `Which` is unset
     *   - If `Options.Blink` is falsy, returns `RectHighlightObj.__Func_Move`.
     *   - If `Options.Blink` is nonzero, returns `RectHighlightObj.__Func_Blink`.
     *
     * Regarding the setter, see the parameter hint above `RectHighlight.Prototype.SetTimerFunc`.
     * @param [Which] - Either 1 or 2 as described in the description.
     * @returns {Func} - A timer function.
     * @instance
     */
    TimerFunc[Which?] {
        Get {
            if IsSet(Which) {
                if Which == 1 {
                    return this.__Func_Move
                }
                if Which == 2 {
                    return this.__Func_Blink
                }
            }
            return this.Options.Blink ? this.__Func_Blink : this.__Func_Move
        }
        Set => this.SetTimerFunc(Value, Which ?? unset)
    }

    Visible => DllCall('IsWindowVisible', 'ptr', this.Hwnd, 'int')

    static __New() {
        if this.Prototype.__Class == 'RectHighlight' {
            this.__Properties := [
                ['L', 'T', 'R', 'B']
              , ['Left', 'Top', 'Right', 'Bottom']
              , ['X', 'Y', 'W', 'H']
              , ['X', 'Y', 'Width', 'Height']
            ]
        }
    }

    /**
     * @class
     * @description - Handles the input options.
     */
    class Options {
        static Default := {
            Blink: false
          , Border: 2
          , Color: '00e0fe'
          , Duration: -3000
          , Obj: ''
          , OffsetL: 0
          , OffsetT: 0
          , OffsetR: 0
          , OffsetB: 0
          , OnHide: ''
          , OnMove: ''
          , OnShow: ''
          , PositionFontOpt: ''
          , PositionFontName: ''
          , Title: 'Highlight'
        }

        /**
         * @description - Sets the base object such that the values are used in this priority order:
         * - 1: The input object.
         * - 2: The configuration object (if present).
         * - 3: The default object.
         * @param {Object} Options - The input object.
         * @return {Object} - The same input object.
         */
        static Call(Options) {
            if IsSet(RectHighlightConfig) {
                ObjSetBase(RectHighlightConfig, RectHighlight.Options.Default)
                ObjSetBase(Options, RectHighlightConfig)
            } else {
                ObjSetBase(Options, RectHighlight.Options.Default)
            }
            return Options
        }
    }
}
