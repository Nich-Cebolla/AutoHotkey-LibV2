
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

/**
 * @example
 * GuiObj := Gui()
 * GuiObj.SetFont('s11 q5 bold')
 * GetColorFromUser(&r, &g, &b)
 * GuiObj.BackColor := RGB(r, g, b)
 * txt := GuiObj.Add('Text', , 'Hello, world!')
 * if RGBToLuminosity(r, g, b) >= 0.7 {
 *    txt.SetFont('c' RGB(0, 0, 0)) ; use a dark font
 * } else {
 *    txt.SetFont('c' RGB(255, 255, 255)) ; use a light font
 * }
 * GuiObj.Show()
 *
 * GetColorFromUser(&r, &g, &b) {
 *     r := Random(0, 255)
 *     g := Random(0, 255)
 *     b := Random(0, 255)
 * }
 * @
 *
 * @returns {Float} - A float between 0 and 1 indicating the luminosity, where 1.0 is totally bright
 * (255, 255, 255) and 0.0 is totally dark (0, 0, 0).
 */
RGBToLuminosity(r, g, b) {
    RsRGB := r / 255
    GsRGB := g / 255
    BsRGB := b / 255
    return 0.2126 * (RsRGB <= 0.04045 ? RsRGB / 12.92 : ((RsRGB + 0.055) / 1.055) ** 2.4)
    + 0.7152 * (GsRGB <= 0.04045 ? GsRGB / 12.92 : ((GsRGB + 0.055) / 1.055) ** 2.4)
    + 0.0722 * (BsRGB <= 0.04045 ? BsRGB / 12.92 : ((BsRGB + 0.055) / 1.055) ** 2.4)
}
