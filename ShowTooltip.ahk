/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/ShowTooltip.ahk
    Author: Nich-Cebolla
    Version: 1.0.0
    License: MIT
*/

ShowTooltip(Str, Duration := -2000, X?, Y?, OffsetX := 0, OffsetY := 0) {
    static N := [1,2,3,4,5,6,7]
    Z := N.Pop()
    OM := CoordMode('Mouse', 'Screen')
    OT := CoordMode('Tooltip', 'Screen')
    MouseGetPos(&tempX, &tempY)
    if !IsSet(X) {
        X := tempX
    }
    if !IsSet(Y) {
        Y := tempY
    }
    Tooltip(Str, X + OffsetX, Y + OffsetY, Z)

    SetTimer(_End.Bind(Z), -Abs(Duration))
    CoordMode('Mouse', OM)
    CoordMode('Tooltip', OT)

    _End(Z) {
        ToolTip(,,,Z)
        N.Push(Z)
    }
}
