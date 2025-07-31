
RGB(r := 0, g := 0, b := 0) {
    return (r & 0xFF) | ((g & 0xFF) << 8) | ((b & 0xFF) << 16)
}
ParseColorRef(colorref, &OutR?, &OutG?, &OutB?) {
    OutR := colorref & 0xFF
    OutG := (colorref >> 8) & 0xFF
    OutB := (colorref >> 16) & 0xFF
}
ARGB(a := 0, r := 0, g := 0, b := 0) {
    return ((a & 0xFF) << 24) | ((r & 0xFF) << 16) | ((g & 0xFF) << 8) | (b & 0xFF)
}
ParseARGB(color, &OutA?, &OutR?, &OutG?, &OutB?) {
    OutA := (color >> 24) & 0xFF
    OutR := (color >> 16) & 0xFF
    OutG := (color >> 8) & 0xFF
    OutB := color & 0xFF
}
ColorRefToARGB(colorref, alpha := 255) {
    r := colorref & 0xFF
    g := (colorref >> 8) & 0xFF
    b := (colorref >> 16) & 0xFF
    return ARGB(alpha, r, g, b)
}
