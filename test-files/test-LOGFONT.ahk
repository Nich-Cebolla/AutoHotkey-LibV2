#Include ..\structs\LOGFONT.ahk
#SingleInstance force

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
txt := g2.Add('Text', 'x10 y10 w300 h150 BackgroundWhite +0x200 Center vTxt', 'Hello, world!')
lf := Logfont(txt.Hwnd)
for prop in proto.OwnProps() {
    if InStr(',CharSet,ClipPrecision,Family,OutPrecision,Orientation,Pitch,', ',' prop ',') {
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

ctrlWidth := 380

startX := width + g2.MarginX + 20
g2.InputControlGroup := Map()
g2.InputControlGroup.CaseSense := false
g2.InputControlGroup.Set(
    'Face names', {
        Text: g2.Add('Text', 'x' startX ' y' g2.MarginY ' Section vTxtFaceNames', 'Face names:'),
        Edit: g2.Add('Edit', 'ys w' ctrlWidth ' vEdtFaceNames')
    })
g2.InputControlGroup.Get('Face names').Text.GetPos(, , &w)
g2.InputControlGroup.Set(
    'Charset', {
        Text: g2.Add('Text', 'xs w' w ' Section vTxtCharset', 'Charset:'),
        Lv: g2.Add('ListView', 'ys w' ctrlWidth ' r7 -Multi Count21 -Hdr vLvCharset', [ 'Name', 'Value' ])
    })
lvCharset := g2.InputControlGroup.Get('Charset').Lv
lvCharset.GetPos(&x, &y, &w, &h)
g2.Add('Button', 'vBtnListFonts', 'List fonts').OnEvent('Click', HClickButtonListFonts)
g2['BtnListFonts'].GetPos(&_btnx, , &_btnw, &_btnh)
g2['BtnListFonts'].Move(x + w - _btnw, y + h + g2.MarginY)
for arr in [
    [ 'None', '' ],
    [ 'ANSI_CHARSET', '0' ],
    [ 'DEFAULT_CHARSET', '1' ],
    [ 'SYMBOL_CHARSET', '2' ],
    [ 'SHIFTJIS_CHARSET', '128' ],
    [ 'HANGEUL_CHARSET', '129' ],
    [ 'HANGUL_CHARSET', '129' ],
    [ 'GB2312_CHARSET', '134' ],
    [ 'CHINESEBIG5_CHARSET', '136' ],
    [ 'OEM_CHARSET', '255' ],
    [ 'JOHAB_CHARSET', '130' ],
    [ 'HEBREW_CHARSET', '177' ],
    [ 'ARABIC_CHARSET', '178' ],
    [ 'GREEK_CHARSET', '161' ],
    [ 'TURKISH_CHARSET', '162' ],
    [ 'VIETNAMESE_CHARSET', '163' ],
    [ 'THAI_CHARSET', '222' ],
    [ 'EASTEUROPE_CHARSET', '238' ],
    [ 'RUSSIAN_CHARSET', '204' ],
    [ 'MAC_CHARSET', '77' ],
    [ 'BALTIC_CHARSET', '186' ]
] {
    lvCharset.Add(A_Index = 2 ? 'Select' : '', arr*)
}
lvCharset.ModifyCol(1, 'AutoHdr')
lvCharset.ModifyCol(2, 'AutoHdr')
slidery := sety + seth + g2.MarginY
g2.Add('Text', 'x' g2.MarginX ' y' slidery ' Section vTxtSliderEscapement', 'Escapement:').GetPos(&txtx, , &txtw)
sliderx := txtx + txtw + g2.MarginX
slider := g2.Add('Slider', 'x' sliderx ' y' slidery ' w' (width - g2.MarginX * 3 - txtw) ' NoTicks AltSubmit Range0-3599 ToolTip vSliderEscapement', 0)
slider.OnEvent('Change', HChangeSliderEscapement)
lvwidth := main_width - g2.MarginX * 2
columns := ['Name']
proto := NewTextMetric.Prototype
for prop in proto.OwnProps() {
    desc := proto.GetOwnPropDesc(prop)
    if HasProp(desc, 'Get') && !InStr(prop, 'Ptr') {
        columns.Push(prop)
    }
}
slider.GetPos(, &sliy, , &slih)
lvy := sliy + slih + g2.MarginY
lv := g2.Add('ListView', 'x' g2.MarginX ' y' lvy ' w' lvwidth ' r15 Sort vLvFonts', columns)
lv.Columns := columns
loop columns.Length {
    lv.ModifyCol(A_Index, 'AutoHdr')
}

for prop, group in controls {
    group.Set.GetPos(&btnx, , &btnw)
    break
}
g2['BtnListFonts'].GetPos(&_btnx, &_btny, &_btnw, &_btnh)
txt.GetPos(, , &txtw, &txth)
txt.Move((main_width - g2.MarginX * 2 - btnx - btnw - txtw) / 2 + btnx + btnw, (lvy - _btny - _btnh - g2.MarginY * 4 - txth) / 2 + _btny + _btnh)


lv.GetPos(, &lvy, , &lvh)
lv.OnEvent('Click', HClickLv)
gheight := lvy + lvh + g2.MarginY
g2.Show('x20 y20 w' main_width ' h' gheight ' NoActivate')
g2.Lf := lf
HClickButtonListFonts(g2['BtnListFonts'])

HClickLv(lv, row) {
    lf := lv.Gui.Lf
    lf.FaceName := lv.Gui['EdtFaceName'].Text := lv.GetText(row, 1)
    lf.Apply()
}
HClickButtonListFonts(Ctrl, *) {
    g := Ctrl.Gui
    lv := g['LvFonts']
    lv.Delete()
    if row := lvCharset.GetNext(0) {
        charSet := lvCharset.GetText(row, 2)
    } else {
        charSet := ''
    }
    faceNames := g.InputControlGroup.Get('Face names').Edit.Text
    Logfont.EnumFonts(
        EnumFontFamExProc
      , StrLen(faceNames) ? faceNames : unset
      , StrLen(charSet) ? charSet : unset
      , ObjPtr(lv))
    loop columns.Length {
        lv.ModifyCol(A_Index, 'AutoHdr')
    }
}
EnumFontFamExProc(lpelfe, lpntme, FontType, lParam) {
    lv := ObjFromPtrAddRef(lParam)
    params := EnumFontFamExProcParams(lpelfe, lpntme, FontType)
    items := [ params.FullName ]
    columns := lv.Columns
    items.Capacity := columns.Length
    if params.IsTrueType {
        tm := params.TextMetric.TextMetric
    } else {
        tm := params.TextMetric
    }
    loop columns.Length - 1 {
        if HasProp(tm, columns[A_Index + 1]) {
            items.Push(tm.%columns[A_Index + 1]%)
        } else {
            items.Push('')
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
