
/**
 * @param {Gui} G - The Gui object.
 * @param {String[]} - The list of properties to make controls for.
 * @param {Object} Options - Property:value pairs
 *
 * @param {Integer} Options.StartX - The start X coordinate.
 * @param {Integer} Options.StartY - The start Y coordinate.
 * @param {Integer} [Options.MaxY] - A threshold at which a new column will be started.
 * @param {Boolean} [Options.GetButton = true] - If true, a button to the right of the edit control
 * with the text "Get" is included.
 * @param {Boolean} [Options.SetButton = true] - If true, a button to the right of the edit control
 * with the text "Set" is included.
 * @param {Integer} [Options.EditWidth = 250] - The width of the edit controls.
 * @param {Integer} [Options.ButtonWidth = 80] - The width of the button controls.
 * StartX, StartY, MaxX?, MaxY?, GetBtn := true, SetBtn := true
 * @param {Integer} [Options.PaddingX = 5] - The padding to add between controls along the X axis.
 * @param {Integer} [Options.PaddingY = 5] - The padding to add between rows.
 * @param {Boolean} [Options.LabelAlignment = "Right"] - The alignment option to include with the
 * label controls.
 */
MakeInputControlGroup(G, PropList, Options) {
    local maxY := getButton := setButton := editWidth := buttonWidth := paddingX := paddingY := labelAlignment := 0
    x := Options.StartX
    y := startY := Options.StartY
    for prop, val in Map('maxY', '', 'getButton', true, 'setButton', true, 'editWidth', 250
    , 'buttonWidth', 80, 'paddingX', 5, 'paddingY', 5, 'labelAlignment', 'Right') {
        if HasProp(Options, prop) {
            %prop% := Options.%prop%
        } else {
            %prop% := val
        }
    }
    controls := Map()
    width := 0
    for prop in PropList {
        controls.Set(
            prop, group := {
                Label: G.Add('Text', 'x' x ' y' y ' ' labelAlignment ' vTxt' prop, prop ':')
              , Edit: G.Add('Edit', 'x' x ' y' y ' w' editWidth ' vEdt' prop)
            }
        )
        if getButton {
            group.Get := G.Add('Button', 'x' x ' y' y ' w' buttonWidth ' vBtnGet' prop, 'Get')
        }
        if setButton {
            group.Set := G.Add('Button', 'x' x ' y' y ' w' buttonWidth ' vBtnSet' prop, 'Set')
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
        controls.Get(PropList[1]).Get.GetPos(, , , &rowh)
    } else if setButton {
        controls.Get(PropList[1]).Set.GetPos(, , , &rowh)
    } else {
        controls.Get(PropList[1]).Edit.GetPos(, , , &rowh)
    }
    controls.Get(PropList[1]).Edit.GetPos(, , , &edth)
    controls.Get(PropList[1]).Label.GetPos(, , , &txth)
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
