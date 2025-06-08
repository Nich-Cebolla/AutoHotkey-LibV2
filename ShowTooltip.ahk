/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/ShowTooltip.ahk
    Author: Nich-Cebolla
    Version: 1.0.0
    License: MIT
*/

ShowTooltip(Str, Duration := -2000) {
    static N := [1,2,3,4,5,6,7]
    Z := N.Pop()
    OM := CoordMode('Mouse', 'Screen')
    OT := CoordMode('Tooltip', 'Screen')
    MouseGetPos(&x, &y)
    Tooltip(Str, x, y, Z)

    SetTimer(_End.Bind(Z), -Abs(Duration))
    CoordMode('Mouse', OM)
    CoordMode('Tooltip', OT)

    _End(Z) {
        ToolTip(,,,Z)
        N.Push(Z)
    }
}
