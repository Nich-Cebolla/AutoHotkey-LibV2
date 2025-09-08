/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/ShowTooltip.ahk
    Author: Nich-Cebolla
    License: MIT
*/

class ShowTooltip {
    /**
     * By default, `ShowTooltip.Numbers` is an array with integers 1-20, and is used to track which
     * tooltip id numbers are available and which are in use. If tooltips are created from multiple
     * sources, then the list is invalid because it may not know about every existing tooltip. To
     * overcome this, `ShowTooltip.Numbers` can be set with an array that is shared by other objects,
     * sharing the pool of available id numbers.
     *
     * All instances of `ShowTooltip` will inherently draw from the same array, and so calling
     * `ShowTooltip.SetNumbersList` is unnecessary if the objects handling tooltip creation are all
     * `ShowTooltip` objects.
     */
    static SetNumbersList(List) {
        this.Numbers := List
    }
    static DefaultOptions := {
        Duration: 2000
      , X: 0
      , Y: 0
      , Mode: 'Mouse' ; Mouse / Absolute (M/A)
    }
    static Numbers := [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]

    /**
     * @param {Object} [DefaultOptions] - An object with zero or more options as property : value pairs.
     * These options are used when a corresponding option is not passed to {@link ShowTooltip.Prototype.Call}.
     * @param {Integer} [DefaultOptions.Duration = 2000] - The duration in milliseconds for which the
     * tooltip displayed. A value of 0 causes the tooltip to b e dislpayed indefinitely until
     * {@link ShowTooltip.Prototype.End} is called with the tooltip number. Negative and positive
     * values are treated the same.
     * @param {Integer} [DefaultOptions.X = 0] - If `DefaultOptions.Mode == "Mouse"` (or "M"), a number
     * of pixels to add to the X-coordinate. If `DefaultOptions.Mode == "Absolute"` (or "A"), the
     * X-coordinate relative to the screen.
     * @param {Integer} [DefaultOptions.Y = 0] - If `DefaultOptions.Mode == "Mouse"` (or "M"), a number
     * of pixels to add to the Y-coordinate. If `DefaultOptions.Mode == "Absolute"` (or "A"), the
     * Y-coordinate relative to the screen.
     * @param {String} [DefaultOptions.Mode = "Mouse"] - One of the following:
     * - "Mouse" or "M" - The tooltip is displayed near the mouse cursor.
     * - "Absolute" or "A" - The tooltip is displayed at the screen coordinates indicated by the
     * options.
     */
    __New(DefaultOptions?) {
        if IsSet(DefaultOptions) {
            o := this.DefaultOptions := {}
            d := ShowTooltip.DefaultOptions
            for p in d.OwnProps()  {
                o.%p% := HasProp(DefaultOptions, p) ? DefaultOptions.%p% : d.%p%
            }
        } else {
            this.DefaultOptions := ShowTooltip.DefaultOptions.Clone()
        }
    }
    /**
     * @param {String} Str - The string to display.
     *
     * @param {Object} [Options] - An object with zero or more options as property : value pairs.
     * If a value is absent, the corresponding value from `ShowTooltipObj.DefaultOptions` is used.
     * @param {Integer} [Options.Duration] - The duration in milliseconds for which the
     * tooltip displayed. A value of 0 causes the tooltip to b e dislpayed indefinitely until
     * {@link ShowTooltip.Prototype.End} is called with the tooltip number. Negative and positive
     * values are treated the same.
     * @param {Integer} [Options.X] - If `Options.Mode == "Mouse"` (or "M"), a number
     * of pixels to add to the X-coordinate. If `Options.Mode == "Absolute"` (or "A"), the
     * X-coordinate relative to the screen.
     * @param {Integer} [Options.Y] - If `Options.Mode == "Mouse"` (or "M"), a number
     * of piYels to add to the Y-coordinate. If `Options.Mode == "Absolute"` (or "A"), the
     * Y-coordinate relative to the screen.
     * @param {String} [Options.Mode] - One of the following:
     * - "Mouse" or "M" - The tooltip is displayed near the mouse cursor.
     * - "Absolute" or "A" - The tooltip is displayed at the screen coordinates indicated by the
     * options.
     *
     * @returns {Integer} - The tooltip number used for the tooltip. If the duration is 0, pass
     * the number to {@link ShowTooltip.Prototype.End} to end the tooltip. Otherwise, you do not need
     * to save the tooltip number, but the tooltip number can be used to target the tooltip when calling
     * `ToolTip`.
     */
    Call(Str, Options?) {
        if ShowTooltip.Numbers.Length {
            n := ShowTooltip.Numbers.Pop()
        } else {
            throw Error('The maximum number of concurrent tooltips (20) has been reached.', -1)
        }
        if IsSet(Options) {
            Get := _Get1
        } else {
            Get := _Get2
        }
        T := CoordMode('Tooltip', 'Screen')
        switch SubStr(Get('Mode'), 1, 1), 0 {
            case 'M':
                M := CoordMode('Mouse', 'Screen')
                MouseGetPos(&X, &Y)
                ToolTip(Str, X + Get('X'), Y + Get('Y'), n)
                CoordMode('Mouse', M)
            case 'A':
                ToolTip(Str, Get('X'), Get('Y'), n)
        }
        CoordMode('Tooltip', T)
        duration := -Abs(Get('Duration'))
        if duration {
            SetTimer(ObjBindMethod(this, 'End', n), duration)
        }

        return n

        _Get1(prop) {
            return HasProp(Options, prop) ? Options.%prop% : this.DefaultOptions.%prop%
        }
        _Get2(prop) {
            return this.DefaultOptions.%prop%
        }
    }
    End(n) {
        ToolTip(,,,n)
        ShowTooltip.Numbers.Push(n)
    }
    /**
     * @param {Object} [DefaultOptions] - An object with zero or more options as property : value pairs.
     * These options are used when a corresponding option is not passed to {@link ShowTooltip.Prototype.Call}.
     * The existing default options are overwritten with the new object.
     */
    SetDefaultOptions(DefaultOptions) {
        this.DefaultOptions := DefaultOptions
    }
}
