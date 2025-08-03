#Include ..\structs\LOGFONT.ahk

main_width := 1100

; `HClickButtonGet` and `HClickButtonSet` are the two callback functions used by the gui

HClickButtonGet(Ctrl, *) {
    prop := StrReplace(Ctrl.Name, 'BtnGet', '')
    ; I stored a reference to the `Logfont` object on the property "Lf" for convenience
    lf := Ctrl.Gui.Lf
    ; To get the value of a LOGFONT member, you just access the member by name using
    ; property notation
    value := lf.%prop%
    Ctrl.Gui['Edt' prop].Text := value
}

HClickButtonSet(Ctrl, *) {
    prop := StrReplace(Ctrl.Name, 'BtnSet', '')
    value := Ctrl.Gui['Edt' prop].Text
    lf := Ctrl.Gui.Lf
    ; There are two ways to set the value of a LOGFONT member. If you use property notation like
    ; below, you must also call "Apply" to apply it. Though not seen here, you can also call the
    ; method "SetValue" which will both set the value and call "Apply".
    lf.%prop% := value
    lf.Apply()
    if prop = 'Escapement' {
        Ctrl.Gui['SliderEscapement'].Value := value
    }
}

proto := Logfont.Prototype
props := []
controls := Map()
width := 0
g2 := Gui('+Resize')
g2.SetFont('s11 q5', 'Segoe Ui')
txt := g2.Add('Text', 'x10 y10 w300 h150 Center vTxt', '`r`n`r`n`r`nHello, world!')
lf := Logfont(txt.Hwnd)
for prop in proto.OwnProps() {
    if InStr(',CharSet,ClipPrecision,Family,Orientation,OutPrecision,Pitch,Height,', ',' prop ',') {
        continue
    }
    desc := proto.GetOwnPropDesc(prop)
    if HasProp(desc, 'Get') && HasProp(desc, 'Set') {
        controls.Set(prop, {
            Label: g2.Add('Text', 'vTxt' prop, prop ':')
          , Edit: g2.Add('Edit', 'w250 vEdt' prop)
          , Get: g2.Add('Button', 'w80 vBtnGet' prop, 'Get')
          , Set: g2.Add('Button', 'w80 vBtnSet' prop, 'Set')
        })
        controls.Get(prop).Label.GetPos(, , &txtw)
        if txtw > width {
            width := txtw
        }
    }
}

y := g2.MarginY
x := g2.MarginX
x2 := x + width + g2.MarginX
x3 := x2 + 250 + g2.MarginX
x4 := x3 + 80 + g2.MarginX
for prop, group in controls {
    group.Label.Move(x, y, width)
    group.Edit.Move(x2, y)
    group.Get.Move(x3, y)
    group.Set.Move(x4, y)
    group.Edit.GetPos(, , , &edth)
    group.Edit.Text := lf.%prop%
    group.Get.OnEvent('Click', HClickButtonGet)
    group.Set.OnEvent('Click', HClickButtonSet)
    group.Set.GetPos(&setx, &sety, &setw, &seth)
    y += g2.MarginY + edth
}
width := setx + setw + g2.MarginX
height := sety + seth + g2.MarginY
g2.Add('Button', 'x' (width + g2.MarginX) ' y' g2.MarginY ' vBtnListFonts', 'List fonts').OnEvent('Click', HClickButtonListFonts)
g2['BtnListFonts'].GetPos(&btnx, , &btnw)
txt.Move(btnx + btnw + g2.MarginX, g2.MarginY + 100)
slidery := sety + seth + g2.MarginY
g2.Add('Text', 'x' g2.MarginX ' y' slidery ' Section vTxtSliderEscapement', 'Escapement:').GetPos(&txtx, , &txtw)
sliderx := txtx + txtw + g2.MarginX
slider := g2.Add('Slider', 'x' sliderx ' y' slidery ' w' (width - g2.MarginX * 3 - txtw) ' NoTicks AltSubmit Range0-3599 ToolTip vSliderEscapement', 0)
slider.OnEvent('Change', HChangeSliderEscapement)
lvwidth := main_width - g2.MarginX * 2
columns := ['Name']
for proto in [TextMetric.Prototype, NewTextMetric.Prototype] {
    for prop in proto.OwnProps() {
        desc := proto.GetOwnPropDesc(prop)
        if HasProp(desc, 'Get') && !InStr(prop, 'Ptr') {
            columns.Push(prop)
        }
    }
}
slider.GetPos(, &sliy, , &slih)
lvy := sliy + slih + g2.MarginY
lv := g2.Add('ListView', 'x' g2.MarginX ' y' lvy ' w' lvwidth ' r15 vLvFonts', columns)
lv.Columns := columns
loop columns.Length {
    lv.ModifyCol(A_Index, 'AutoHdr')
}
lv.GetPos(, &lvy, , &lvh)
gheight := lvy + lvh + g2.MarginY
g2.Show('x20 y20 w' main_width ' h' gheight ' NoActivate')
g2.Lf := lf

HClickButtonListFonts(Ctrl, *) {
    g := Ctrl.Gui
    lv := g['LvFonts']
    Logfont.EnumFonts(EnumFontFamExProc, , , ObjPtr(lv))
    loop columns.Length {
        lv.ModifyCol(A_Index, 'AutoHdr')
    }
}
EnumFontFamExProc(lpelfe, lpntme, FontType, lParam) {
    lv := ObjFromPtrAddRef(lParam)
    params := EnumFontFamExProcParams(lpelfe, lpntme, FontType)
    items := [params.FullName]
    columns := lv.Columns
    items.Capacity := columns.Length
    if params.IsTrueType {
        ntm := params.TextMetric.TextMetric
        loop columns.Length - 1 {
            items.Push(ntm.%columns[A_Index + 1]%)
        }
    } else {
        tm := params.TextMetric
        loop columns.Length - 5 {
            items.Push(tm.%columns[A_Index + 1]%)
        }
    }
    lv.Add(, items*)
    return 1
}
HChangeSliderEscapement(Ctrl, Info) {
    g := Ctrl.Gui
    lf := g.Lf
    lf.Escapement := Ctrl.Value
    g['EdtEscapement'].Text := Ctrl.Value
    lf.Apply()
}
