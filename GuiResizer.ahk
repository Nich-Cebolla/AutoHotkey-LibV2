/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/GuiResizer.ahk
    Author: Nich-Cebolla
    Version: 2.0.0
    License: MIT
*/

class GuiResizer {
    static __New() {
        this.DeleteProp('__New')
        hMod := DllCall('GetModuleHandleW', 'wstr', 'user32', 'ptr')
        global g_user32_BeginDeferWindowPos := DllCall('GetProcAddress', 'ptr', hMod, 'astr', 'BeginDeferWindowPos', 'ptr')
        , g_user32_DeferWindowPos := DllCall('GetProcAddress', 'ptr', hMod, 'astr', 'DeferWindowPos', 'ptr')
        , g_user32_EndDeferWindowPos := DllCall('GetProcAddress', 'ptr', hMod, 'astr', 'EndDeferWindowPos', 'ptr')
        , g_user32_GetClientRect := DllCall('GetProcAddress', 'ptr', hMod, 'astr', 'GetClientRect', 'ptr')
        , g_user32_GetDpiForWindow := DllCall('GetProcAddress', 'ptr', hMod, 'astr', 'GetDpiForWindow', 'ptr')
        , g_user32_GetWindowRect := DllCall('GetProcAddress', 'ptr', hMod, 'astr', 'GetWindowRect', 'ptr')
        , g_user32_ScreenToClient := DllCall('GetProcAddress', 'ptr', hMod, 'astr', 'ScreenToClient', 'ptr')
        , g_user32_SetThreadDpiAwarenessContext := DllCall('GetProcAddress', 'ptr', hMod, 'astr', 'SetThreadDpiAwarenessContext', 'ptr')
        , GuiResizer_Swp_Move := 0x0001 | 0x0010 | 0x0200 | 0x0004 ; SWP_NOSIZE | SWP_NOACTIVATE | SWP_NOOWNERZORDER | SWP_NOZORDER
        , GuiResizer_Swp_MoveAndSize := 0x0010 | 0x0200 | 0x0004 ; SWP_NOACTIVATE | SWP_NOOWNERZORDER | SWP_NOZORDER
        , GuiResizer_Swp_Size := 0x0002 | 0x0010 | 0x0200 | 0x0004 ; SWP_NOMOVE | SWP_NOACTIVATE | SWP_NOOWNERZORDER | SWP_NOZORDER
    }

    /**
     * @description
     * Creates an object that acts as a callback function for the Size event. See
     * test\demo-GuiResizer.ahk for a descriptive demo. See test\test-GuiResizer.ahk to test
     * specific setups.
     *
     * In this documentation, "delta" means the change of position or change in size.
     *
     * All references to the parent window's width or height are referring to the **parent window's
     * client area**.
     *
     * # CtrlObj.Resizer
     *
     * To specify how a control should be modified when the parent window's dimensions change, create
     * a property "Resizer" on the Gui.Control object. The property should be an object with one or
     * more of the following properties:
     *
     * @param {Boolean} [CtrlObj.Resizer.Scale = false] - If set to true, and if the W and/or H
     * properties are set, when the width/height of the gui window changes, the respective width/height
     * of the control is changed according to the scale, not the direct value. For example:
     * - My gui window has a client area of 500w x 500h
     * - I set `CtrlObj.Resizer.Scale =: true`
     * - I set `CtrlObj.Resizer.H := 1`
     * - The current height of `CtrlObj` is 100
     *
     * If the height of the window's client area changes to 550, then the height of `CtrlObj` changes
     * to 110. This is because the gui's height delta is 50, which represents a 10% increase.
     * `100 + 100 * 0.1 = 110`.
     *
     * The scale is also multiplied by the respective W / H value. Using the same example scenario,
     * if I instead set `CtrlObj.Resizer.H := 2`, then the height of `CtrlObj` would change to 120.
     * If I set `CtrlObj.Resizer.H := 0.5`, then the height of `CtrlObj` would change to 105.
     *
     * If `CtrlObj.Resizer.Scale = false`, when the width/height of the gui window changes, the
     * respective width/height of the control is changed by the quotient of the value of the
     * respective W/H property and the gui window's width/height delta. Using a similar example scenario:
     * - My gui window has a client area of 500w x 500h
     * - I set `CtrlObj.Resizer.Scale =: false`
     * - I set `CtrlObj.Resizer.H := 1`
     * - The current height of `CtrlObj` is 100
     *
     * If the height of the window's client area changes to 550, then the height of `CtrlObj` changes
     * to 150. This is because the gui's height delta is 50, and 50 * 1 = 50, and 100 + 50 = 150.
     *
     * The delta is multiplied by the respective W / H value. Using the same example scenario,
     * if I instead set `CtrlObj.Resizer.H := 2`, then the height of `CtrlObj` would change to 200.
     * If I set `CtrlObj.Resizer.H := 0.5`, then the height of `CtrlObj` would change to 125.
     *
     * @property {Number} [CtrlObj.Resizer.X] - If set, the control's position along the horizontal axis
     * will be changed when the gui's width changes. The control's position delta is the quotient
     * of the gui's width delta * this value. For example, if the X value is 0.5 and the gui's width
     * changes by +5, then the control is moved 3 pixels to the right.
     *
     * @property {Number} [CtrlObj.Resizer.MaxX] - If set, the control's position along the horizontal axis
     * will not be permitted to exceed this value.
     *
     * @property {Number} [CtrlObj.Resizer.MinX] - If set, the control's position along the horizontal axis
     * will not be permitted to drop below this value.
     *
     * @property {Number} [CtrlObj.Resizer.W] - If set, the control's width will be changed when the
     * gui's width changes. The control's width delta is the quotient of the gui's width delta * this
     * value. For example, if the W value is 1 and the gui's width changes by +5, then the control's
     * width increases by 5 pixels on the right side.
     *
     * @property {Number} [CtrlObj.Resizer.MaxW] - If set, the control's width will not be permitted to
     * exceed this value.
     *
     * @property {Number} [CtrlObj.Resizer.MinW] - If set, the control's width will not be permitted to
     * drop below this value.
     *
     * @property {Number} [CtrlObj.Resizer.Y] - If set, the control's position along the vertical axis
     * will be changed when the gui's height changes. The control's position delta is the quotient
     * of the gui's height delta * this value. For example, if the Y value is 0.3 and the gui's height
     * changes by +10, then the control is moved 3 pixels down.
     *
     * @property {Number} [CtrlObj.Resizer.MaxY] - If set, the control's position along the vertical axis
     * will not be permitted to exceed this value.
     *
     * @property {Number} [CtrlObj.Resizer.MinY] - If set, the control's position along the vertical axis
     * will not be permitted to drop below this value.
     *
     * @property {Number} [CtrlObj.Resizer.H] - If set, the control's height will be changed when the
     * gui's height changes. The control's height delta is the quotient of the gui's height delta * this
     * value. For example, if the H value is 1 and the gui's height changes by +5, then the control's
     * height increases by 5 pixels on bottom.
     *
     * @property {Number} [CtrlObj.Resizer.MaxH] - If set, the control's height will not be permitted to
     * exceed this value.
     *
     * @property {Number} [CtrlObj.Resizer.MinH] - If set, the control's height will not be permitted to
     * drop below this value.
     *
     * @property {Integer} [CtrlObj.Resizer.Flags] - If set, the value to pass to the uFlags parameter
     * of {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-deferwindowpos DeferWindowPos}
     * for that control. If unset, the relevant default is used ({@link GuiResizer_Swp_Move},
     * {@link GuiResizer_Swp_Size}, or {@link GuiResizer_Swp_MoveAndSize}).
     *
     *
     *
     * @param {Gui} GuiObj - The Gui object.
     *
     * @param {Gui.Control[]} [Controls] - If `Controls` is set, it is an array of `Gui.Control`
     * objects with property "Resizer" with the resize options for that control. See the description
     * above {@link GuiResizer.Prototype.__New} for more information. If `DeferActivation` is true,
     * `Controls` is ignored.
     *
     * @param {Boolean} [DeferActivation = false] - If true, {@link GuiResizer.Prototype.Activate}
     * is not called; your code must call it. If true, `Controls` is ignored. If false,
     * {@link GuiResizer.Prototype.Activate} is called, passing `Controls` as an argument if
     * `Controls` is set.
     *
     *
     *
     * @param {Object} [Options] - An object with options as property : value pairs.
     *
     * @param {Integer} [Options.AddRemove = 1] - The value to pass to the `AddRemove` parameter
     * of {@link https://www.autohotkey.com/docs/v2/lib/GuiOnEvent.htm Gui.Prototype.OnEvent} when
     * setting the Size event handler.
     *
     * @param {*} [Options.Callback] - A `Func` or callable object that is called once per resize
     * cycle.
     *
     * Parameters:
     * 1. The {@link GuiResizer} object
     *
     * The return value is ignored.
     *
     * If your callback must act on the control objects in some way, they are collected among
     * three arrays:
     * - {@link GuiResizer#Move}
     * - {@link GuiResizer#Size}
     * - {@link GuiResizer#MoveAndSize}.
     *
     * @param {Integer} [Options.Delay = -5] - A negative integer specifying the value passed to
     * the `Period` parameter of {@link https://www.autohotkey.com/docs/v2/lib/SetTimer.htm SetTimer}.
     * This occurs once per resize cycle.
     *
     * @param {Integer} [Options.DpiAwarenessContext] - If set, this must be a valid dpi awareness
     * context. Immediately before each resize cycle, SetThreadDpiAwarenessContext is called with
     * this value. If unset, SetThreadDpiAwarenessContext is not called.
     *
     * @param {Number} [Options.MaxH] - If a number, directs the resize function to stop adjusting
     * the controls' height and vertical position when the gui's client area has exceeded this height.
     *
     * @param {Number} [Options.MaxW] - If a number, directs the resize function to stop adjusting
     * the controls' width and horizontal position when the gui's client area has exceeded this width.
     *
     * @param {Number} [Options.MinH] - If a number, directs the resize function to stop adjusting
     * the controls' height and vertical position when the gui's client area has dropped below this
     * height.
     *
     * @param {Number} [Options.MinW] - If a number, directs the resize function to stop adjusting
     * the controls' width and horizontal position when the gui's client area has dropped below this
     * width.
     *
     * @param {Integer} [Options.Priority = 1] - The value to pass to the `Priority` parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/SetTimer.htm SetTimer}. This occurs once per
     * resize cycle.
     *
     * @param {Number} [Options.StopCount = 20] - Sets the threshold that determines when the
     * resize cycle breaks from is core loop and re-enables the Size event handler. The resize cycle
     * must loop with no changes in the width or height of the gui's client area for `Options.StopCount`
     * cycles to end the loop. This must be a number greater than 1.
     *
     * @param {Number} [Options.WinDelay = 10] - If nonzero, immediately before each resize cycle,
     * {@link https://www.autohotkey.com/docs/v2/lib/SetWinDelay.htm SetWinDelay} is called with
     * this value.
     */
    __New(GuiObj, Options?, Controls?, DeferActivation := false) {
        GuiResizer.Options(this, Options ?? unset)
        this.HwndGui := GuiObj.Hwnd
        /**
         * One of the following values:
         * - 0 : The {@link GuiResizer} is not currently a callback for the Size event.
         * - 1 : The {@link GuiResizer} is activating.
         * - 2 : The {@link GuiResizer} is updating.
         * - 3 : The {@link GuiResizer} is set as a callback for the Size event and is idle.
         * - 4 : The {@link GuiResizer} has been called in response to the Size event.
         * - 5 : The {@link GuiResizer} is active in the core resize loop and is adjusting the controls.
         * - 6 : The {@link GuiResizer} is active in the core resize loop and is awaiting the timer.
         * @memberof GuiResizer
         * @instance
         * @type {Integer}
         */
        this.Status := 0
        this.Rect := GuiResizer_Rect()
        constructor := this.Constructor := Class()
        constructor.Base := GuiResizer_Item
        constructor.Prototype := { GuiResizer: this, __Class: constructor.Base.Prototype.__Class }
        ObjRelease(ObjPtr(this))
        ObjSetBase(constructor.Prototype, constructor.Base.Prototype)
        if !DeferActivation {
            this.Activate(Controls ?? unset)
        }
    }

    /**
     * Performs initial calculations and creates the {@link GuiResizer_Item} objects for each
     * control with a "Resizer" property. Also sets the Size event handler.
     *
     * {@link GuiResizer.Prototype.Activate} cannot be called when the gui is minimized.
     *
     * {@link GuiResizer.Prototype.Activate} must be called once before using the {@link GuiResizer}.
     *
     * {@link GuiResizer.Prototype.Activate} can be called multiple times to update the controls
     * that are adjusted when the Size event is raised, and/or change individual controls' resizer
     * options.
     *
     * @param {Gui.Control[]} [Controls] - If `Controls` is set, it is an array of `Gui.Control`
     * objects with property "Resizer" with the resize options for that control. See the description
     * above {@link GuiResizer.Prototype.__New} for more information.
     *
     * If `Controls` is not set, all of the controls in the gui object's internal collection are
     * iterated, and any with a "Resizer" property are processed to create a {@link GuiResizer_Item}
     * object.
     */
    Activate(Controls?) {
        flag_status := this.Status
        this.Status := 1
        if this.DpiAwarenessContext {
            DllCall(g_user32_SetThreadDpiAwarenessContext, 'ptr', this.DpiAwarenessContext, 'ptr')
        }
        this.MinMax := WinGetMinMax(this.HwndGui)
        if this.MinMax = -1 {
            throw Error('The window may not be minimized when calling ``' A_ThisFunc '``.')
        }
        this.Rect.Client(this.HwndGui)
        this.BaseW := this.LastW := this.Rect.W
        this.BaseH := this.LastH := this.Rect.H
        size := this.Size := []
        move := this.Move := []
        moveAndSize := this.MoveAndSize := []
        constructor := this.Constructor
        for ctrl in (Controls ?? this.Gui) {
            if !HasProp(ctrl, 'Resizer') {
                continue
            }
            item := constructor(ctrl.Resizer, ctrl.Hwnd)
            if item.Move {
                if item.Size {
                    moveAndSize.Push(item)
                } else {
                    move.Push(item)
                }
            } else if item.Size {
                size.Push(item)
            } else {
                throw Error('The control`'s resizer parameters are invalid.', , HasProp(ctrl, 'Name') ? 'Control`'s name: ' ctrl.Name : unset)
            }
        }
        if !flag_status {
            this.Gui.OnEvent('Size', this, this.AddRemove)
        }
        this.Status := 3
    }
    /**
     * Called when the Size event is raised. This disables the Size event handler, overrides the
     * "Call" property with the "Resize" method, then calls {@link GuiResizer.Prototype.Resize} to
     * start the core resize loop.
     */
    Call(GuiObj, MinMax, Width, Height) {
        this.Status := 4
        if MinMax = 1 {
            this.MinMax := 1
            if Width = this.LastW && Height = this.LastH {
                this.Status := 3
                return
            }
        } else if MinMax = -1 {
            this.MinMax := -1
            this.Status := 3
            return
        }
        GuiObj.OnEvent('Size', this, 0)
        this.Count := 0
        this.DefineProp('Call', GuiResizer.Prototype.GetOwnPropDesc('Resize'))
        this.Resize()
    }
    /**
     * Disables the Size event callback.
     */
    Deactivate() {
        this.Gui.OnEvent('Size', this, 0)
        this.Status := 0
    }
    /**
     * Called from {@link GuiResizer.Prototype.Call}. This is the core resize loop.
     */
    Resize() {
        originalCritical := Critical(-1)
        this.Status := 5
        if this.DpiAwarenessContext {
            DllCall(g_user32_SetThreadDpiAwarenessContext, 'ptr', this.DpiAwarenessContext, 'ptr')
        }
        if this.WinDelay {
            SetWinDelay(this.WinDelay)
        }
        if hDwp := DllCall(g_user32_BeginDeferWindowPos, 'int', this.Move.Length + this.Size.Length + this.MoveAndSize.Length, 'ptr') {
            this.Rect.Client(this.HwndGui)
            w := this.Rect.W
            h := this.Rect.H
            if w != this.LastW {
                this.LastW := w
                this.LastH := h
                this.Count := 0
            } else if h != this.LastH {
                this.LastH := h
                this.Count := 0
            } else {
                if ++this.Count >= this.StopCount {
                    this.DeleteProp('Call')
                    this.Status := 3
                    Critical(originalCritical)
                    this.Gui.OnEvent('Size', this, this.AddRemove)
                    return
                }
                this.Status := 6
                Critical(originalCritical)
                SetTimer(this, this.Delay, this.Priority)
            }
            if IsNumber(this.MinH) {
                if h >= this.MinH {
                    if IsNumber(this.MaxH) {
                        h := Min(this.MaxH, h)
                    }
                } else {
                    h := this.MinH
                }
            } else if IsNumber(this.MaxH) {
                h := Min(this.MaxH, h)
            }
            if IsNumber(this.MinW) {
                if w >= this.MinW {
                    if IsNumber(this.MaxW) {
                        w := Min(this.MaxW, w)
                    }
                } else {
                    w := this.MinW
                }
            } else if IsNumber(this.MaxW) {
                w := Min(this.MaxW, w)
            }
            diffH := h - this.BaseH
            diffW := w - this.BaseW
            for item in this.Move {
                if hDwp := DllCall(g_user32_DeferWindowPos
                    , 'ptr', hDwp
                    , 'ptr', item.Hwnd
                    , 'ptr', 0                              ; hWndInsertAfter
                    , 'int', item.GetX(diffW)               ; X
                    , 'int', item.GetY(diffH)               ; Y
                    , 'int', 0                              ; W
                    , 'int', 0                              ; H
                    , 'uint', item.Flags_Move                     ; flags
                    , 'ptr'
                ) {
                    continue
                } else {
                    throw OSError()
                }
            }
            for item in this.Size {
                if hDwp := DllCall(g_user32_DeferWindowPos
                    , 'ptr', hDwp
                    , 'ptr', item.Hwnd
                    , 'ptr', 0                              ; hWndInsertAfter
                    , 'int', 0                              ; X
                    , 'int', 0                              ; Y
                    , 'int', item.GetW(diffW)               ; W
                    , 'int', item.GetH(diffH)               ; H
                    , 'uint', item.Flags_Size                     ; flags
                    , 'ptr'
                ) {
                    continue
                } else {
                    throw OSError()
                }
            }
            for item in this.MoveAndSize {
                if hDwp := DllCall(g_user32_DeferWindowPos
                    , 'ptr', hDwp
                    , 'ptr', item.Hwnd
                    , 'ptr', 0                              ; hWndInsertAfter
                    , 'int', item.GetX(diffW)               ; X
                    , 'int', item.GetY(diffH)               ; Y
                    , 'int', item.GetW(diffW)               ; W
                    , 'int', item.GetH(diffH)               ; H
                    , 'uint', item.Flags_MoveAndSize              ; flags
                    , 'ptr'
                ) {
                    continue
                } else {
                    throw OSError()
                }
            }
            if !DllCall(g_user32_EndDeferWindowPos, 'ptr', hDwp, 'ptr') {
                throw OSError()
            }
            if IsObject(this.Callback) {
                this.Callback.Call(this)
            }
            this.Status := 6
            Critical(originalCritical)
            SetTimer(this, this.Delay, this.Priority)
        } else {
            throw OSError()
        }
    }
    /**
     * Updates the cached size and dimension values for the gui window and the controls to their
     * current values. Call {@link GuiResizer.Prototype.Update} when your code has manually made
     * adjustments to the size / position of the controls. For example, if your code responds to
     * a window DPI change, your code should call {@link GuiResizer.Prototype.Update} when finished
     * making those changes so those changes can be reflected when processing future Size events.
     * If {@link GuiResizer.Prototype.Update} is not called, the next Size event will cause
     * unexpected behavior.
     *
     * Do not use {@link GuiResizer.Prototype.Update} if your intent is to add / remove controls
     * from the collection of controls that will be adjusted when the Size event is raised.
     * Use {@link GuiResizer.Prototype.Activate} instead.
     */
    Update() {
        this.Status := 2
        originalCritical := Critical(-1)
        if this.DpiAwarenessContext {
            DllCall(g_user32_SetThreadDpiAwarenessContext, 'ptr', this.DpiAwarenessContext, 'ptr')
        }
        this.MinMax := WinGetMinMax(this.HwndGui)
        if this.MinMax = -1 {
            throw Error('The window may not be minimized when calling ``' A_ThisFunc '``.')
        }
        enum := IsSet(Controls) ? Controls.__Enum : this.Gui.__Enum
        rc := GuiResizer_Rect()
        rc.Client(this.HwndGui)
        this.BaseW := this.LastW := rc.W
        this.BaseH := this.LastH := rc.H
        for list in [ this.Move, this.Size, this.MoveAndSize ] {
            for item in list {
                item.Update()
            }
        }
        this.Status := 3
        Critical(originalCritical)
        this.Gui.OnEvent('Size', this, 1)
    }
    __Delete() {
        if this.HasOwnProp('Constructor') && this.Constructor.HasOwnProp('Prototype') {
            proto := this.Constructor.Prototype
            if proto.HasOwnProp('GuiResizer') && proto.GuiResizer = this {
                ObjPtrAddRef(this)
                proto.DeleteProp('GuiResizer')
            }
        }
    }

    Gui => GuiFromHwnd(this.HwndGui)

    class Options {
        static Default := {
            AddRemove: -1
          , Callback: ''
          , Delay: -5
          , DpiAwarenessContext: ''
          , MaxH: ''
          , MaxW: ''
          , MinH: ''
          , MinW: ''
          , Priority: 0
          , StopCount: 20
          , WinDelay: 10
        }
        static Call(GuiResizerObj, Options?) {
            d := this.Default
            if IsSet(Options) {
                if HasProp(Options, 'Delay') && options.Delay > 0 {
                    throw ValueError('``Options.Delay`` must be <= 0.', , options.Delay)
                }
                if HasProp(Options, 'StopCount') && options.StopCount <= 1 {
                    throw ValueError('``Options.StopCount`` must be > 1.', , options.StopCount)
                }
                for prop in d.OwnProps() {
                    GuiResizerObj.%prop% := HasProp(Options, prop) ? Options.%prop% : d.%prop%
                }
            } else {
                for prop, val in d.OwnProps() {
                    GuiResizerObj.%prop% := val
                }
            }
        }
    }

}


class GuiResizer_Item {
    static __New() {
        this.DeleteProp('__New')
        proto := this.Prototype
        proto.X := proto.MaxX := proto.MinX :=
        proto.Y := proto.MaxY := proto.MinY :=
        proto.W := proto.MaxW := proto.MinW :=
        proto.H := proto.MaxH := proto.MinH :=
        proto.MinMaxX := proto.MinMaxY := proto.MinMaxW := proto.MinMaxH :=
        proto.Scale := proto.Move := proto.Size := proto.Group := 0
        proto.SharedRect := GuiResizer_Rect()
    }
    __New(obj, hwnd) {
        if HasProp(obj, 'X') && obj.X {
            this.X := obj.X
            this.Move := 1
            if HasProp(obj, 'MaxX') {
                this.MaxX := obj.MaxX
                this.MinMaxX := 1
            }
            if HasProp(obj, 'MinX') {
                this.MinX := obj.MinX
                this.MinMaxX := this.MinMaxX + 2
            }
        }
        if HasProp(obj, 'Y') && obj.Y {
            this.Y := obj.Y
            this.Move := this.Move + 2
            if HasProp(obj, 'MaxY') {
                this.MaxY := obj.MaxY
                this.MinMaxY := 1
            }
            if HasProp(obj, 'MinY') {
                this.MinY := obj.MinY
                this.MinMaxY := this.MinMaxY + 2
            }
        }
        if HasProp(obj, 'W') && obj.W {
            this.W := obj.W
            this.Size := 1
            if HasProp(obj, 'MaxW') {
                this.MaxW := obj.MaxW
                this.MinMaxW := 1
            }
            if HasProp(obj, 'MinW') {
                this.MinW := obj.MinW
                this.MinMaxW := this.MinMaxW + 2
            }
        }
        if HasProp(obj, 'H') && obj.H {
            this.H := obj.H
            this.Size := this.Size + 2
            if HasProp(obj, 'MaxH') {
                this.MaxH := obj.MaxH
                this.MinMaxH := 1
            }
            if HasProp(obj, 'MinH') {
                this.MinH := obj.MinH
                this.MinMaxH := this.MinMaxH + 2
            }
        }
        if HasProp(obj, 'Scale') {
            this.Scale := obj.Scale
        }
        this.Hwnd := hwnd
        proto := GuiResizer_Item.Prototype
        switch this.Move {
            case 1:
                this.Group := 1
                switch this.MinMaxX {
                    case 0: this.DefineProp('GetX', proto.GetOwnPropDesc('GetX_NoMaxNoMin'))
                    case 1: this.DefineProp('GetX', proto.GetOwnPropDesc('GetX_Max'))
                    case 2: this.DefineProp('GetX', proto.GetOwnPropDesc('GetX_Min'))
                    case 3: this.DefineProp('GetX', proto.GetOwnPropDesc('GetX_MaxMin'))
                }
                this.DefineProp('GetY', proto.GetOwnPropDesc('GetY_Base'))
            case 2:
                this.Group := 1
                switch this.MinMaxY {
                    case 0: this.DefineProp('GetY', proto.GetOwnPropDesc('GetY_NoMaxNoMin'))
                    case 1: this.DefineProp('GetY', proto.GetOwnPropDesc('GetY_Max'))
                    case 2: this.DefineProp('GetY', proto.GetOwnPropDesc('GetY_Min'))
                    case 3: this.DefineProp('GetY', proto.GetOwnPropDesc('GetY_MaxMin'))
                }
                this.DefineProp('GetX', proto.GetOwnPropDesc('GetX_Base'))
            case 3:
                this.Group := 1
                switch this.MinMaxX {
                    case 0: this.DefineProp('GetX', proto.GetOwnPropDesc('GetX_NoMaxNoMin'))
                    case 1: this.DefineProp('GetX', proto.GetOwnPropDesc('GetX_Max'))
                    case 2: this.DefineProp('GetX', proto.GetOwnPropDesc('GetX_Min'))
                    case 3: this.DefineProp('GetX', proto.GetOwnPropDesc('GetX_MaxMin'))
                }
                switch this.MinMaxY {
                    case 0: this.DefineProp('GetY', proto.GetOwnPropDesc('GetY_NoMaxNoMin'))
                    case 1: this.DefineProp('GetY', proto.GetOwnPropDesc('GetY_Max'))
                    case 2: this.DefineProp('GetY', proto.GetOwnPropDesc('GetY_Min'))
                    case 3: this.DefineProp('GetY', proto.GetOwnPropDesc('GetY_MaxMin'))
                }
        }
        if this.Scale {
            switch this.Size {
                case 1:
                    this.Group := this.Group + 2
                    switch this.MinMaxW {
                        case 0: this.DefineProp('GetW', proto.GetOwnPropDesc('GetW_NoMaxNoMin_Scale'))
                        case 1: this.DefineProp('GetW', proto.GetOwnPropDesc('GetW_Max_Scale'))
                        case 2: this.DefineProp('GetW', proto.GetOwnPropDesc('GetW_Min_Scale'))
                        case 3: this.DefineProp('GetW', proto.GetOwnPropDesc('GetW_MaxMin_Scale'))
                    }
                    this.DefineProp('GetH', proto.GetOwnPropDesc('GetH_Base'))
                case 2:
                    this.Group := this.Group + 2
                    switch this.MinMaxH {
                        case 0: this.DefineProp('GetH', proto.GetOwnPropDesc('GetH_NoMaxNoMin_Scale'))
                        case 1: this.DefineProp('GetH', proto.GetOwnPropDesc('GetH_Max_Scale'))
                        case 2: this.DefineProp('GetH', proto.GetOwnPropDesc('GetH_Min_Scale'))
                        case 3: this.DefineProp('GetH', proto.GetOwnPropDesc('GetH_MaxMin_Scale'))
                    }
                    this.DefineProp('GetW', proto.GetOwnPropDesc('GetW_Base'))
                case 3:
                    this.Group := this.Group + 2
                    switch this.MinMaxW {
                        case 0: this.DefineProp('GetW', proto.GetOwnPropDesc('GetW_NoMaxNoMin_Scale'))
                        case 1: this.DefineProp('GetW', proto.GetOwnPropDesc('GetW_Max_Scale'))
                        case 2: this.DefineProp('GetW', proto.GetOwnPropDesc('GetW_Min_Scale'))
                        case 3: this.DefineProp('GetW', proto.GetOwnPropDesc('GetW_MaxMin_Scale'))
                    }
                    switch this.MinMaxH {
                        case 0: this.DefineProp('GetH', proto.GetOwnPropDesc('GetH_NoMaxNoMin_Scale'))
                        case 1: this.DefineProp('GetH', proto.GetOwnPropDesc('GetH_Max_Scale'))
                        case 2: this.DefineProp('GetH', proto.GetOwnPropDesc('GetH_Min_Scale'))
                        case 3: this.DefineProp('GetH', proto.GetOwnPropDesc('GetH_MaxMin_Scale'))
                    }
            }
        } else {
            switch this.Size {
                case 1:
                    this.Group := this.Group + 2
                    switch this.MinMaxW {
                        case 0: this.DefineProp('GetW', proto.GetOwnPropDesc('GetW_NoMaxNoMin'))
                        case 1: this.DefineProp('GetW', proto.GetOwnPropDesc('GetW_Max'))
                        case 2: this.DefineProp('GetW', proto.GetOwnPropDesc('GetW_Min'))
                        case 3: this.DefineProp('GetW', proto.GetOwnPropDesc('GetW_MaxMin'))
                    }
                    this.DefineProp('GetH', proto.GetOwnPropDesc('GetH_Base'))
                case 2:
                    this.Group := this.Group + 2
                    switch this.MinMaxH {
                        case 0: this.DefineProp('GetH', proto.GetOwnPropDesc('GetH_NoMaxNoMin'))
                        case 1: this.DefineProp('GetH', proto.GetOwnPropDesc('GetH_Max'))
                        case 2: this.DefineProp('GetH', proto.GetOwnPropDesc('GetH_Min'))
                        case 3: this.DefineProp('GetH', proto.GetOwnPropDesc('GetH_MaxMin'))
                    }
                    this.DefineProp('GetW', proto.GetOwnPropDesc('GetW_Base'))
                case 3:
                    this.Group := this.Group + 2
                    switch this.MinMaxW {
                        case 0: this.DefineProp('GetW', proto.GetOwnPropDesc('GetW_NoMaxNoMin'))
                        case 1: this.DefineProp('GetW', proto.GetOwnPropDesc('GetW_Max'))
                        case 2: this.DefineProp('GetW', proto.GetOwnPropDesc('GetW_Min'))
                        case 3: this.DefineProp('GetW', proto.GetOwnPropDesc('GetW_MaxMin'))
                    }
                    switch this.MinMaxH {
                        case 0: this.DefineProp('GetH', proto.GetOwnPropDesc('GetH_NoMaxNoMin'))
                        case 1: this.DefineProp('GetH', proto.GetOwnPropDesc('GetH_Max'))
                        case 2: this.DefineProp('GetH', proto.GetOwnPropDesc('GetH_Min'))
                        case 3: this.DefineProp('GetH', proto.GetOwnPropDesc('GetH_MaxMin'))
                    }
            }
        }
        this.Update()
        if HasProp(obj, 'Flags') {
            switch this.Group {
                case 1: this.DefineProp('Flags_Move', { Value: obj.Flags })
                case 2: this.DefineProp('Flags_Size', { Value: obj.Flags })
                case 3: this.DefineProp('Flags_MoveAndSize', { Value: obj.Flags })
            }
        }
    }
    Update() {
        rc := this.SharedRect
        rc(this.Hwnd)
        rc.ToClient(this.GuiResizer.HwndGui)
        this.BaseX := rc.X
        this.BaseY := rc.Y
        this.BaseW := rc.W
        this.BaseH := rc.H
        this.BaseR := rc.R
        this.BaseB := rc.B
    }
    GetX_Base(*) => this.BaseX
    GetX_NoMaxNoMin(diffW) => this.BaseX + diffW * this.X
    GetX_Max(diffW) => Min(this.BaseX + diffW * this.X, this.MaxX)
    GetX_Min(diffW) => Max(this.BaseX + diffW * this.X, this.MinX)
    GetX_MaxMin(diffW) {
        x := this.BaseX + diffW * this.X
        if x >= this.MinX {
            return Min(x, this.MaxX)
        } else {
            return Max(x, this.MinX)
        }
    }
    GetY_Base(*) => this.BaseY
    GetY_NoMaxNoMin(diffH) => this.BaseY + diffH * this.Y
    GetY_Max(diffH) => Min(this.BaseY + diffH * this.Y, this.MaxY)
    GetY_Min(diffH) => Max(this.BaseY + diffH * this.Y, this.MinY)
    GetY_MaxMin(diffH) {
        y := this.BaseY + diffH * this.Y
        if y >= this.MinY {
            return Min(y, this.MaxY)
        } else {
            return Max(y, this.MinY)
        }
    }
    GetW_Base(*) => this.BaseW
    GetW_NoMaxNoMin(diffW) => this.BaseW + diffW * this.W
    GetW_Max(diffW) => Min(this.BaseW + diffW * this.W, this.MaxW)
    GetW_Min(diffW) => Max(this.BaseW + diffW * this.W, this.MinW)
    GetW_MaxMin(diffW) {
        w := this.BaseW + diffW * this.W
        if w >= this.MinW {
            return Min(w, this.MaxW)
        } else {
            return Max(w, this.MinW)
        }
    }
    GetH_Base(*) => this.BaseH
    GetH_NoMaxNoMin(diffH) => this.BaseH + diffH * this.H
    GetH_Max(diffH) => Min(this.BaseH + diffH * this.H, this.MaxH)
    GetH_Min(diffH) => Max(this.BaseH + diffH * this.H, this.MinH)
    GetH_MaxMin(diffH) {
        h := this.BaseH + diffH * this.H
        if h >= this.MinH {
            return Min(h, this.MaxH)
        } else {
            return Max(h, this.MinH)
        }
    }
    GetW_NoMaxNoMin_Scale(diffW) => this.BaseW * (1 + diffW / this.GuiResizer.BaseW) * this.W
    GetW_Max_Scale(diffW) => Min(this.BaseW * (1 + diffW / this.GuiResizer.BaseW) * this.W, this.MaxW)
    GetW_Min_Scale(diffW) => Max(this.BaseW * (1 + diffW / this.GuiResizer.BaseW) * this.W, this.MinW)
    GetW_MaxMin_Scale(diffW) {
        w := this.BaseW * (1 + diffW / this.GuiResizer.BaseW) * this.W
        if w >= this.MinW {
            return Min(w, this.MaxW)
        } else {
            return Max(w, this.MinW)
        }
    }
    GetH_NoMaxNoMin_Scale(diffH) => this.BaseH * (1 + diffH / this.GuiResizer.BaseH) * this.H
    GetH_Max_Scale(diffH) => Min(this.BaseH * (1 + diffH / this.GuiResizer.BaseH) * this.H, this.MaxH)
    GetH_Min_Scale(diffH) => Max(this.BaseH * (1 + diffH / this.GuiResizer.BaseH) * this.H, this.MinH)
    GetH_MaxMin_Scale(diffH) {
        h := this.BaseH * (1 + diffH / this.GuiResizer.BaseH) * this.H
        if h >= this.MinH {
            return Min(h, this.MaxH)
        } else {
            return Max(h, this.MinH)
        }
    }

    Flags_Move => GuiResizer_Swp_Move
    Flags_MoveAndSize => GuiResizer_Swp_MoveAndSize
    Flags_Size => GuiResizer_Swp_Size
}

class GuiResizer_Rect extends Buffer {
    __New() {
        this.Size := 16
    }
    Call(hwnd) {
        if !DllCall(g_user32_GetWindowRect, 'ptr', hwnd, 'ptr', this, 'int') {
            throw OSError()
        }
    }
    Client(hwnd) {
        if !DllCall(g_user32_GetClientRect, 'ptr', hwnd, 'ptr', this, 'int') {
            throw OSError()
        }
    }
    ToClient(hwndParent) {
        if !DllCall(g_user32_ScreenToClient, 'ptr', hwndParent, 'ptr', this, 'int') {
            throw OSError()
        }
        if !DllCall(g_user32_ScreenToClient, 'ptr', hwndParent, 'ptr', this.Ptr + 8, 'int') {
            throw OSError()
        }
    }
    B => NumGet(this, 12, 'int')
    H => NumGet(this, 12, 'int') - NumGet(this, 4, 'int')
    L => NumGet(this, 0, 'int')
    R => NumGet(this, 8, 'int')
    T => NumGet(this, 4, 'int')
    W => NumGet(this, 8, 'int') - NumGet(this, 0, 'int')
    X => NumGet(this, 0, 'int')
    Y => NumGet(this, 4, 'int')
}
