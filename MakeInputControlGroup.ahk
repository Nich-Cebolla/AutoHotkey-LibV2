
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

/*
options template

Options := {
    buttonWidth: 80
  , editPrefix: 'Edt'
  , editWidth: 250
  , getButton: true
  , getButtonPrefix: 'BtnGet'
  , labelAlignment: 'Right'
  , labelPrefix: 'Txt'
  , maxY: ''
  , paddingX: 5
  , paddingY: 5
  , setButton: true
  , setButtonPrefix: 'BtnSet'
}
