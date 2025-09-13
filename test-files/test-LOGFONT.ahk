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

inputControlGroupOpt := {
    paddingX: g2.MarginX
  , paddingY: g2.MarginY
  , getButton: false
  , setButton: false
  , startX: width + g2.MarginX + 20
  , startY: g2.MarginY
}
inputControlGroupNames := [ 'Face names', 'Charset' ]
g2.InputControlGroup := MakeInputControlGroup(g2, inputControlGroupNames, inputControlGroupOpt)
g2.InputControlGroup.Get('Face names').Edit.GetPos(&edtx, &edty, &edtw, &edth)
g2.Add('Button', 'vBtnListFonts', 'List fonts').OnEvent('Click', HClickButtonListFonts)
g2['BtnListFonts'].GetPos(&_btnx, , &_btnw, &_btnh)
g2['BtnListFonts'].Move(edtx + edtw - _btnw, edty + edth + g2.MarginY)

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

for prop, group in controls {
    group.Set.GetPos(&btnx, , &btnw)
    break
}
g2['BtnListFonts'].GetPos(&_btnx, &_btny, &_btnw, &_btnh)
txt.GetPos(, , &txtw, &txth)
txt.Move((main_width - g2.MarginX * 2 - btnx - btnw - txtw) / 2 + btnx + btnw, (lvy - _btny - _btnh - g2.MarginY * 2 - txth) / 2 + _btny + _btnh)


lv.GetPos(, &lvy, , &lvh)
gheight := lvy + lvh + g2.MarginY
g2.Show('x20 y20 w' main_width ' h' gheight ' NoActivate')
g2.Lf := lf

HClickButtonListFonts(Ctrl, *) {
    g := Ctrl.Gui
    lv := g['LvFonts']
    Logfont.EnumFonts(
        EnumFontFamExProc
      , g.InputControlGroup.Get('Face names').Edit.Text || unset
      , g.InputControlGroup.Get('Charset').Edit.Text || unset
      , ObjPtr(lv))
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




/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/MakeInputControlGroup.ahk
    Author: Nich-Cebolla
    License: MIT
*/

/**
 * `MakeInputControlGroup` is a function that creates a group of controls in a series of rows and
 * columns, where each row is associated with a particular input item from the parameter `LabelList`.
 * The types of controls that can be created are:
 * 1. Text control - a label indicating what value to input.
 * 2. Edit control - the edit that accepts input from the user.
 * 3. Button control - a button that says "Get".
 * 4. Button control - a button that says "Set".
 *
 * The buttons "Get" and "Set" are optional; that is, you can choose to have zero, one, or both
 * of each in each row. This function does not currently allow customizing the controls on an
 * individual-row basis; each row must have the same controls.
 *
 * You can customize how the controls are named to a degree, but ultimately the format for the
 * names is: `prefix RegExReplace(label, "\W", "")`. The `RegExReplace` expression removes all
 * non-word characters. For example, if the prefix for a control is "BtnGet", and the label for
 * the group is "Option 1", then that control's name is "BtnGetOption1".
 *
 * For a demo, see "test-files\demo-MakeInputControlGroup.ahk".
 *
 * @param {Gui} G - The Gui object.
 *
 * @param {String[]} LabelList - The list of labels for each control group.
 *
 * @param {Object} Options - Property:value pairs
 * @param {Integer} [Options.StartX] - The start X coordinate. If unset, `G.MarginX` is used.
 * @param {Integer} [Options.StartY] - The start Y coordinate. If unset, `G.MarginY` is used.
 * @param {Integer} [Options.MaxY] - A threshold at which a new column will be started.
 * @param {Boolean} [Options.GetButton = true] - If true, a button to the right of the edit control
 * with the text "Get" is included.
 * @param {Boolean} [Options.SetButton = true] - If true, a button to the right of the edit control
 * with the text "Set" is included.
 * @param {Integer} [Options.EditWidth = 250] - The width of the edit controls.
 * @param {Integer} [Options.ButtonWidth = 80] - The width of the button controls.
 * @param {Integer} [Options.PaddingX = 5] - The padding to add between controls along the X axis.
 * @param {Integer} [Options.PaddingY = 5] - The padding to add between rows.
 * @param {Boolean} [Options.LabelAlignment = "Right"] - The alignment option to include with the
 * label controls.
 * @param {String} [Options.LabelPrefix = "Txt"] - The literal string that prefixes the labels.
 * @param {String} [Options.EditPrefix = "Edt"] - The literal string that prefixes the edit controls.
 * @param {String} [Options.GetButtonPrefix = "BtnGet"] - The literal string that prefixes the name
 * of the "Get" buttons.
 * @param {String} [Options.SetButtonPrefix = "BtnSet"] - The literal string that prefixes the name
 * of the "Set" buttons.
 * @param {String} [Options.NameSuffix = ""] - The literal string that will be appended to all
 * control names.
 */
MakeInputControlGroup(G, LabelList, Options?) {
    local maxY := getButton := setButton := editWidth := buttonWidth := paddingX := paddingY :=
    labelAlignment := labelPrefix := editPrefix := getButtonPrefix := setButtonPrefix := nameSuffix := 0
    if !IsSet(Options) {
        Options := {}
    }
    x := HasProp(Options, 'StartX') ? Options.StartX : G.MarginX
    y := startY := HasProp(Options, 'StartY') ? Options.StartY : G.MarginY
    for prop, val in Map('maxY', '', 'getButton', true, 'setButton', true, 'editWidth', 250
    , 'buttonWidth', 80, 'paddingX', 5, 'paddingY', 5, 'labelAlignment', 'Right'
    , 'labelPrefix', 'Txt', 'editPrefix', 'Edt', 'getButtonPrefix', 'BtnGet', 'setButtonPrefix', 'BtnSet'
    , 'nameSuffix', ''
    ) {
        if HasProp(Options, prop) {
            %prop% := Options.%prop%
        } else {
            %prop% := val
        }
    }
    controls := Map()
    controls.NameSuffix := nameSuffix
    width := 0
    for label in LabelList {
        _label := RegExReplace(label, '\W', '')
        controls.Set(
            label, group := {
                Label: G.Add('Text', 'x' x ' y' y ' ' labelAlignment ' v' labelPrefix _label nameSuffix, label ':')
              , Edit: G.Add('Edit', 'x' x ' y' y ' w' editWidth ' v' editPrefix _label nameSuffix)
            }
        )
        if getButton {
            group.Get := G.Add('Button', 'x' x ' y' y ' w' buttonWidth ' v' getButtonPrefix _label nameSuffix, 'Get')
        }
        if setButton {
            group.Set := G.Add('Button', 'x' x ' y' y ' w' buttonWidth ' v' setButtonPrefix _label nameSuffix, 'Set')
        }
        group.Label.GetPos(, , &txtw)
        if txtw > width {
            width := txtw
        }
    }
    x2 := x + width + paddingX
    x3 := x2 + editWidth + paddingX
    x4 := x3 + buttonWidth + paddingX
    if getButton {
        controls.Get(LabelList[1]).Get.GetPos(, , , &rowh)
    } else if setButton {
        controls.Get(LabelList[1]).Set.GetPos(, , , &rowh)
    } else {
        controls.Get(LabelList[1]).Edit.GetPos(, , , &rowh)
    }
    controls.Get(LabelList[1]).Edit.GetPos(, , , &edth)
    controls.Get(LabelList[1]).Label.GetPos(, , , &txth)
    txtYOffset := (rowh - txth) / 2
    edtYOffset := (rowh - edth) / 2
    for prop, group in controls {
        group.Label.Move(x, y + txtYOffset, width)
        group.Edit.Move(x2, y + edtYOffset)
        if getButton {
            group.Get.Move(x3, y)
            if setButton {
                group.Set.Move(x4, y)
            }
        } else if setButton {
            group.Set.Move(x3, y)
        }
        y += edth + paddingY
        if maxY && y + edth > maxY {
            y := startY
            if getButton {
                if setButton {
                    x := x4 + buttonWidth + paddingX
                } else {
                    x := x3 + buttonWidth + paddingX
                }
            } else if setButton {
                x := x3 + buttonWidth + paddingX
            } else {
                x := x2 + editWidth + paddingX
            }
            x2 := x + width + paddingX
            x3 := x2 + editWidth + paddingX
            x4 := x3 + buttonWidth + paddingX
        }
    }
    return controls
}
