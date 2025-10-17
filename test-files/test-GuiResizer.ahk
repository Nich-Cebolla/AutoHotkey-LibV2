
#SingleInstance force
#include ..\GuiResizer.ahk

test()

class test {
    static Call() {
        txtX := ''
        txtY := ''
        txtW := ''
        txtH := ''
        txtMinX := ''
        txtMaxX := ''
        txtMinY := ''
        txtMaxY := ''
        txtMinW := ''
        txtMaxW := ''
        txtMinH := ''
        txtMaxH := ''
        txtScale := ''

        this.Id := 0
        this.controls := Map()
        this.hidden := Map()
        this.controls.CaseSense := this.hidden.CaseSense := false
        this.resizer := ''
        g := this.guicontrol := Gui('+Resize', , EventHandler())
        g.SetFont('s11 q5')
        g.Add('Button', 'Section vBtnAdd', 'Add').OnEvent('Click', 'Add')
        g.Add('Button', 'ys vBtnSetOptions', 'Set options').OnEvent('Click', 'SetOptions')
        g.Add('Button', 'ys vBtnResetPosition', 'Reset position').OnEvent('Click', 'ResetPosition')
        g.Add('Button', 'ys vBtnUpdateCheckedControls', 'Update checked controls').OnEvent('Click', 'UpdateCheckedControls')
        g.Add('Button', 'ys vBtnReload', 'Reload').OnEvent('Click', (*) => Reload())
        g.Add('Button', 'ys vBtnExit', 'Exit').OnEvent('Click', 'Exit')
        g.Add('Text', 'ys vTxtR', 'R:')
        this.r := g.Add('Edit', 'ys w50 vEdtR')
        g.Add('Text', 'ys vTxtG', 'G:')
        this.g := g.Add('Edit', 'ys w50 vEdtG')
        g.Add('Text', 'ys vTxtB', 'B:')
        this.b := g.Add('Edit', 'ys w50 vEdtB')
        columns := this.columns := [ 'Id', 'X', 'Y', 'W', 'H', 'MinX', 'MaxX', 'MinY', 'MaxY', 'MinW', 'MaxW', 'MinH', 'MaxH', 'Scale' ]
        g.Add('Text', 'xs Section vTxtX', 'X:')
        this.X := g.Add('Edit', 'ys w50 vEdtX')
        i := 2
        width := 50
        loop columns.Length - i {
            col := columns[++i]
            if A_Index == 9 {
                g.Add('Text', 'xs Section vTxt' col, col ':')
            } else {
                g.Add('Text', 'ys vTxt' col, col ':')
            }
            this.%col% := g.Add('Edit', 'ys w' width ' vEdt' col)
            if A_Index = 6 {
                width := 75
            }
        }
        g.Add('Text', 'ys vTxtClientArea', 'Client area:')
        this.ClientArea := g.Add('Text', 'ys w300 vTxtClientAreaValue')
        lv := this.lv := g.Add('ListView', 'xs Section w1000 r6 Checked NoSort NoSortHdr -ReadOnly vLv', columns)
        loop columns.Length {
            if A_Index == 1 {
                lv.ModifyCol(A_Index, 75)
            } else if A_Index <= 5 {
                lv.ModifyCol(A_Index, 50)
            } else {
                lv.ModifyCol(A_Index, 75)
            }
        }
        g.Add('Text', 'xs Section vTxtGuiMinW', 'Gui MinW:')
        this.GuiMinW := g.Add('Edit', 'ys 75 vEdtGuiMinW')
        g.Add('Text', 'ys vTxtGuiMaxW', 'Gui MaxW:')
        this.GuiMaxW := g.Add('Edit', 'ys 75 vEdtGuiMaxW')
        g.Add('Text', 'ys vTxtGuiMinH', 'Gui MinH:')
        this.GuiMinH := g.Add('Edit', 'ys 75 vEdtGuiMinH')
        g.Add('Text', 'ys vTxtGuiMaxH', 'Gui MaxH:')
        this.GuiMaxH := g.Add('Edit', 'ys 75 vEdtGuiMaxH')
        g.Add('Text', 'xs Section vTxtDelay', 'Delay:')
        this.Delay := g.Add('Edit', 'ys 75 vEdtDelay')
        g.Add('Text', 'ys vTxtDpiAwareness', 'Dpi awareness:')
        this.DpiAwareness := g.Add('Edit', 'ys 50 vEdtDpiAwareness')
        g.Add('Text', 'ys vTxtStopCount', 'Stop count:')
        this.StopCount := g.Add('Edit', 'ys 75 vEdtStopCount')
        g.Add('Text', 'ys vTxtWinDelay', 'Win delay:')
        this.WinDelay := g.Add('Edit', 'ys 75 vEdtWinDelay')
        this.reposition := g.Add('Checkbox', 'xs Section vChkReposition', 'Reposition')
        this.reposition.OnEvent('Click', 'Reposition')
        this.resize := g.Add('Checkbox', 'ys Section vChkResize', 'Resize')
        this.resize.OnEvent('Click', 'Resize')
        g.Add('Button', 'ys vBtnCallGetRelativePosition', 'Call GetRelativePosition').OnEvent('Click', 'GetRelativePosition')
        g.Add('Text', 'ys vTxtSubject', 'Subject:')
        this.subject := g.Add('Edit', 'ys w100 vEdtSubject')
        g.Add('Text', 'ys vTxtTarget', 'Target:')
        this.target := g.Add('Edit', 'ys w100 vEdtTarget')
        this.getRelativePositionResult := g.Add('Text', 'ys w100 vTxtGetRelativePositionResult')

        this.X.Text := txtX
        this.Y.Text := txtY
        this.W.Text := txtW
        this.H.Text := txtH
        this.MinX.Text := txtMinX
        this.MaxX.Text := txtMaxX
        this.MinY.Text := txtMinY
        this.MaxY.Text := txtMaxY
        this.MinW.Text := txtMinW
        this.MaxW.Text := txtMaxW
        this.MinH.Text := txtMinH
        this.MaxH.Text := txtMaxH
        this.Scale.Text := txtScale

        g.Show('x10 y10')
        g.GetPos(&x, &y, &w, &h)

        g := this.guidisplay := Gui('+Resize -DPIScale')
        g.Show('x100 y' (y + h + 15) ' w500 h500')
        g.SetFont('s10 q5 bold')
        rc := this.rc := GuiResizer_Rect()
        rc.Client(g.Hwnd)
        this.ClientArea.Text := 'W: ' rc.W '; H: ' rc.H

        this.colors := [ 0x000000, 0xC0C0C0, 0x808080, 0xFFFFFF, 0x800000, 0xFF0000, 0x800080, 0xFF00FF, 0x008000, 0x00FF00, 0x808000, 0xFFFF00, 0x000080, 0x0000FF, 0x008080, 0x00FFFF ]
        this.colorIndex := 0
    }
    static GetId() {
        return String(++this.Id)
    }
}

class EventHandler {
    Add(*) {
        id := test.GetId()
        if !test.r.text && !test.g.text && !test.b.text {
            if ++test.colorIndex > test.colors.Length {
                test.colorIndex := 1
            }
            color := test.colors[test.colorIndex]
        } else {
            color := RGB(test.r.text || 0, test.g.text || 0, test.b.text || 0)
        }
        if test.controls.Count {
            for id, txt in test.controls {
                txt.GetPos(&x, &y, &w, &h)
            }
            g := test.guidisplay
            rc := test.rc
            rc.Client(g.Hwnd)
            x += w + g.MarginX
            if x + w > rc.W - g.MarginX {
                x := g.MarginX
                y += h + g.MarginY
                if y + h > rc.H - g.MarginY {
                    g.Show('h' (rc.H + h + g.MarginY))
                }
            }
        } else {
            x := y := 10
        }
        txt := test.guidisplay.Add('Text', 'x' x ' y' y ' w100 h100 Center Border Background' color ' vTest' id)
        txt.GetPos(&x, &y, &w, &h)
        txt.Text := id '`r`nX: ' x '; y: ' y '; w: ' w '; h: ' h
        txt.id := id
        if IsNumber(color) {
            ParseColorRef(color, &r, &g, &b)
            if RGBToLuminosity(r, g, b) < 0.4 {
                txt.SetFont('cWhite')
            }
        }
        test.controls.Set(id, txt)
        lv := test.lv
        columns := test.columns
        values := [id]
        values.Length := columns.Length
        i := 1
        loop columns.Length - i {
            col := columns[++i]
            text := test.%col%.Text
            if StrLen(text) {
                values[i] := text
            }
        }
        lv.Add(, values*)
    }
    SetOptions(*) {
        controls := test.controls
        hidden := test.hidden
        controls.Set(hidden*)
        hidden.Clear()
        lv := test.lv
        for item in ListViewHelper.GetRows(lv) {
            txt := controls.Get(item.Text)
            txt.Visible := 0
            hidden.Set(item.Text, txt)
            controls.Delete(item.Text)
        }
        _controls := []
        columns := test.columns
        for id, txt in controls {
            _controls.Push(txt)
            item := txt.Resizer := {}
            i := 1
            loop columns.Length - i {
                col := columns[++i]
                text := lv.GetText(id, i)
                if StrLen(text) {
                    item.%col% := text
                }
            }
        }
        options := {
            Callback: Callback
          , Delay: test.Delay.Text || unset
          , DpiAwarenessContext: test.DpiAwareness.Text || unset
          , MaxH: test.GuiMaxH.Text || unset
          , MinH: test.GuiMinH.Text || unset
          , MaxW: test.GuiMaxW.Text || unset
          , MinW: test.GuiMinW.Text || unset
          , StopCount: test.StopCount.Text || unset
          , WinDelay: test.WinDelay.Text || unset
        }
        if test.resizer {
            test.guidisplay.OnEvent('Size', test.resizer, 0)
        }
        test.resizer := GuiResizer(test.guidisplay, options, _controls)
        test.activeControls := _controls
    }
    ResetPosition(*) {
        x := y := 10
        g := test.guidisplay
        g.GetPos(, , &w, &h)
        for ctrl in g {
            ctrl.Move(x, y, 100, 100)
            x += 110
            if x > w {
                x := 10
                y += 110
                if y > h {
                    h += 110
                    g.Move(, , , h)
                }
            }
        }
    }
    UpdateCheckedControls(*) {
        lv := test.lv
        columns := test.columns
        for item in ListViewHelper.GetRows(lv) {
            i := 1
            values := [item.Text]
            values.Length := columns.Length
            loop columns.Length - i {
                col := columns[++i]
                text := test.%col%.Text
                if StrLen(text) {
                    values[i] := text
                }
            }
            lv.Modify(item.Text, , values*)
        }
    }
    Exit(*) {
        ExitApp()
    }
    Reposition(ctrl, *) {
        if ctrl.Value {
            if test.resize.Value {
                test.resize.Value := 0
                this.Resize(test.resize)
            }
            Hotkey('+LButton', DynamicMoveControl, 'On')
            ShowTooltip('Hold shift and click and drag a control to reposition.')
        } else {
            Hotkey('+LButton', DynamicMoveControl, 'Off')
        }
    }
    Resize(ctrl, *) {
        if ctrl.Value {
            if test.reposition.Value {
                test.reposition.Value := 0
                this.Reposition(test.reposition)
            }
            Hotkey('+LButton', DynamicResizeControl, 'On')
            ShowTooltip('Hold shift and click and drag a control to resize.')
        } else {
            Hotkey('+LButton', DynamicResizeControl, 'Off')
        }
    }
    GetRelativePosition(*) {
        controls := test.controls
        if controls.Count == 2 {
            for id, txt in controls {
                if A_Index == 1 {
                    subject := txt
                } else {
                    target := txt
                }
            }
        } else {
            subject := controls.Get(test.subject.Text)
            target := controls.Get(test.target.Text)
        }
        test.getRelativePositionResult.Text := GuiResizer.GetRelativePosition(subject, target)
    }
}

Callback(*) {
    test.rc.Client(test.guidisplay.Hwnd)
    test.ClientArea.Text := 'W: ' test.rc.W '; H: ' test.rc.H
    for txt in test.activeControls {
        txt.GetPos(&x, &y, &w, &h)
        txt.Text := txt.id '`r`nX: ' x '; y: ' y '; w: ' w '; h: ' h
    }
}


DynamicMoveControl(*) {
    MouseMode := CoordMode('Mouse', 'Client')
    DpiAwareness := DllCall('SetThreadDpiAwarenessContext', 'ptr', -4, 'ptr')
    MouseGetPos(&x, &y, , &hwnd, 2)
    if !hwnd {
        return
    }
    ControlGetPos(&wx, &wy, &ww, &wh, hwnd)
    cb := (*) => !GetKeyState('LButton', 'P')
    loop {
        if cb() {
            break
        }
        MouseGetPos(&x2, &y2)
        ControlMove(wx + x2 - x, wy + y2 - y, , , hwnd)
        sleep 10
    }
    CoordMode('Mouse', MouseMode)
    DllCall('SetThreadDpiAwarenessContext', 'ptr', DpiAwareness, 'ptr')
}

DynamicResizeControl(*) {
    MouseMode := CoordMode('Mouse', 'Client')
    DpiAwareness := DllCall('SetThreadDpiAwarenessContext', 'ptr', -4, 'ptr')
    MouseGetPos(&x, &y, , &hwnd, 2)
    if !hwnd {
        return
    }
    ControlGetPos(&wx, &wy, &ww, &wh, hwnd)
    if x > wx + ww / 2 {
        x_quotient := 1
        GetX := XCallback1
    } else {
        x_quotient := -1
        GetX := XCallback2
    }
    if y > wy + wh / 2 {
        y_quotient := 1
        GetY := YCallback1
    } else {
        y_quotient := -1
        GetY := YCallback2
    }
    cb := (*) => !GetKeyState('LButton', 'P')
    loop {
        if cb() {
            break
        }
        MouseGetPos(&x2, &y2)
        ControlMove(GetX(), GetY(), ww + (x2 - x) * x_quotient, wh + (y2 - y) * y_quotient, hwnd)
        sleep 10
    }

    CoordMode('Mouse', MouseMode)
    DllCall('SetThreadDpiAwarenessContext', 'ptr', DpiAwareness, 'ptr')

    return

    XCallback1() {
        return wx
    }
    XCallback2() {
        return wx + x2 - x
    }
    YCallback1() {
        return wy
    }
    YCallback2() {
        return wy + y2 - y
    }
}

ShowTooltip(Str) {
    static N := [1,2,3,4,5,6,7]
    Z := N.Pop()
    OM := CoordMode('Mouse', 'Screen')
    OT := CoordMode('Tooltip', 'Screen')
    MouseGetPos(&x, &y)
    Tooltip(Str, x, y, Z)
    SetTimer(_End.Bind(Z), -2000)
    CoordMode('Mouse', OM)
    CoordMode('Tooltip', OT)

    _End(Z) {
        ToolTip(,,,Z)
        N.Push(Z)
    }
}

RGB(r := 0, g := 0, b := 0) {
    return (r & 0xFF) | ((g & 0xFF) << 8) | ((b & 0xFF) << 16)
}

class ListViewHelper {

    /**
     * @description - Searches a listview column for a matching string.
     * @param {Gui.ListView} LV - The ListView control object.
     * @param {String} Text - The text to search for.
     * @param {Number} [Col=1] - The column to search in. If set to 0, the search will be performed
     * on each column until a match is found.
     * @returns {Number|Object} - If Col is nonzero, the function returns the row number where the
     * text was found. If Col is zero, the function returns an object with two properties: Row
     * and Col. Row is the row number where the text was found, and Col is the column number where
     * the text was found.
     */
    static Find(LV, Text, Col := 1) {
        if Col {
            loop LV.GetCount() {
                if LV.GetText(A_Index, Col) = Text
                    return A_Index
            }
        } else {
            i := 0
            loop LV.GetCount('Col') {
                i++
                loop LV.GetCount() {
                    if LV.GetText(A_Index, i) = Text
                        return  { Row: A_Index, Col: i }
                }
            }
        }
    }
    /**
     * @description - Returns an array of checked rows.
     * @param {Gui.ListView} LV - The ListView control object.
     * @param {String} [RowType='Checked'] - The type of rows to get. The options are:
     * - 'Checked' or 'C': Returns all checked rows.
     * - 'Focused' or 'F': Returns the focused row.
     * @param {Boolean} [Uncheck=true] - If true, rows are unchecked during the process.
     * @param {Function} [Callback=(LV, Row, Result) => Result.Push({ Row: Row, Text: LV.GetText(Row, 1) })] -
     * If provided, the callback is called for each row. The callback will receive three parameters:
     * the ListView control object, the row number, and the result array. The callback does not need
     * to return anything, and if it does, it is ignored. There's no restriction on what the callback
     * must do, but generally it should probably take an action on the row, or fill the Result array
     * with a value. The Result array is returned at the end of the function process. The default
     * callback fills the Result array with an object for each checked row, the object having
     * two properties: Row and Text. The Text is obtained from the first column in the ListView.
     */
    static GetRows(LV, RowType := 'Checked', Uncheck := true, Callback := (LV, Row, Result) => Result.Push({ Row: Row, Text: LV.GetText(Row, 1) })) {
        Row := 0, Result := []
        if SubStr(RowType, 1, 1) == 'C' {
            if Uncheck && Callback
                return _ProcessUncheckCallback()
            if Callback
                return _ProcessCallback()
            if Uncheck
                return _ProcessUncheck()
        } else if SubStr(RowType, 1, 1) == 'F' {
            if Callback
                return _ProcessCallback()
        }
        return _Process()

        _Process() {
            Loop {
                Row := LV.GetNext(Row, RowType)
                if !Row
                    return Result
                Result.Push(Row)
            }
        }
        _ProcessCallback() {
            Loop {
                Row := LV.GetNext(Row, RowType)
                if !Row
                    return Result
                Callback(LV, Row, Result)
            }
        }
        _ProcessUncheck() {
            Loop {
                Row := LV.GetNext(Row, RowType)
                if !Row
                    return Result
                LV.Modify(Row, '-check')
                Result.Push(Row)
            }
        }
        _ProcessUncheckCallback() {
            Loop {
                Row := LV.GetNext(Row, RowType)
                if !Row
                    return Result
                LV.Modify(Row, '-check')
                Callback(LV, Row, Result)
            }
        }
    }
    /**
     * @description - Adds an object or an array of objects to the ListView control. The column names
     * are used as item keys / property names to access values to add to the ListView row. Regarding
     * object properties, if a column name has characters that would be illegal in a property name,
     * they are removed when applying the name to the object property.
     * @param {Gui.ListView} LV - The ListView control object.
     * @param {Object|Array} Obj - The object or array of objects to add to the ListView. The objects
     * should have keys / properties corresponding to the column names. The objects do not need to
     * have every value, or any for that matter; absent keys and properties will default to an empty
     * string.
     * @param {String} [Opt] - A string containing options for the ListView. The options are the same
     * as those used in the `Modify` method.
     * @returns {Number} - The row number where the object was added.
     */
    static AddObj(LV, Obj, Opt?) {
        local Row
        if Obj is Array {
            for O in Obj
                _Process(O)
        } else
            _Process(Obj)
        return Row

        _Process(Obj) {
            Row := LV.Add(Opt ?? unset)
            if Obj is Map {
                for Col in ListViewHelper.Cols(LV, 1) {
                    Col := RegExReplace(Col, '[^a-zA-Z0-9_]', '')
                    LV.Modify(Row, 'Col' A_Index, Obj.Has(Col) ? Obj.Get(Col) : '')
                }
            } else {
                for Col in ListViewHelper.Cols(LV, 1) {
                    Col := RegExReplace(Col, '[^a-zA-Z0-9_]', '')
                    LV.Modify(Row, 'Col' A_Index, HasProp(Obj, Col) ? Obj.%Col% : '')
                }
            }
        }
    }
    /**
     * @description - Updates an object or an array of objects within the ListView control. The column
     * names are used as item keys / property names to access values to add to the ListView row.
     * Regarding object properties, if a column name has characters that would be illegal in a
     * property name, they are removed when applying the name to the object property.
     * @param {Gui.ListView} LV - The ListView control object.
     * @param {Object|Array} Obj - The object or array of objects to add to the ListView. The objects
     * should have keys / properties corresponding to the column names. The objects do not need to
     * have every value, or any for that matter; absent keys and properties will default to an empty
     * string.
     * @param {Number} [MatchCol=1] - The column to match the object on. For example, if my ListView
     * has a column "Name" that I want to use for this purpose, my objects must all have a property
     * or key "Name" that matches with a row of text in the ListView.
     * @param {Number} [StartCol=1] - The column to start updating from.
     * @param {Number} [EndCol] - The column to stop updating at.
     * @param {String} [Opt] - A string containing options for the ListView. The options are the same
     * as those used in the `Modify` method.
     */
    static UpdateObj(LV, Obj, MatchCol := 1, StartCol := 1, EndCol?, Opt?) {
        if !IsSet(EndCol)
            EndCol := LV.GetCount('Col')
        MaxRow := LV.GetCount()

        if Obj is Array {
            if Obj[1] is Map {
                Name := LV.GetText(0, MatchCol)
                for O in Obj
                    ListObjText .= O[Name] '`n'
                for RowTxt in ListViewHelper.Rows(LV, -1, MatchCol)
                    ListRowText .= RowTxt '`n'
                ListObjText := StrSplit(Sort(Trim(ListObjText, '`n')), '`n')
                ListRowText := StrSplit(Sort(Trim(ListRowText, '`n')), '`n')
                Row := i := 0
                for ObjText in ListObjText {
                    ++i
                    while ++Row <= MaxRow {
                        if ListRowText[Row] = ObjText {
                            k := StartCol - 1
                            while ++k <= EndCol {
                                ColName := LV.GetText(0, k)
                                LV.Modify(Row, 'Col' k, Obj[i].Has(ColName) ? Obj[i].Get(ColName) : '')
                            }
                            if IsSet(Opt)
                                LV.Modify(Row, Opt)
                            break
                        }
                    }
                }
                if i !== ListObjText.Length
                    throw Error('Not all objects were found in the ListView.'
                    'The unmatched object is:`r`n' ListObjText[i], -1)
            } else {
                Name := RegExReplace(LV.GetText(0, MatchCol), '[^a-zA-Z0-9_]', '')
                ; So we only have to call RegExReplace once per column.
                Columns := []
                z := StartCol - 1
                while ++z <= EndCol
                    Columns.Push(RegExReplace(LV.GetText(0, z), '[^a-zA-Z0-9_]', ''))
                for O in Obj
                    ListObjText .= O.%Name% '`n'
                for Txt in ListViewHelper.Rows(LV, -1, MatchCol)
                    ListRowText .= Txt '`n'
                ListObjText := StrSplit(Sort(Trim(ListObjText, '`n')), '`n')
                ListRowText := StrSplit(Sort(Trim(ListRowText, '`n')), '`n')
                Row := i := 0
                for ObjText in ListObjText {
                    ++i
                    while ++Row <= MaxRow {
                        if ListRowText[Row] = ObjText {
                            k := StartCol - 1
                            while ++k <= EndCol {
                                LV.Modify(Row, 'Col' k, Obj[i].HasOwnProp(Columns[A_Index]) ? Obj[i].%Columns[A_Index]% : '')
                            }
                            if IsSet(Opt)
                                LV.Modify(Row, Opt)
                            break
                        }
                    }
                }
                if i !== ListObjText.Length
                    throw Error('Not all objects were found in the ListView.'
                    'The unmatched object is:`r`n' ListObjText[i], -1)
            }
        } else {
            if Obj is Map {
                for RowText in ListViewHelper.Rows(LV, -1, MatchCol) {
                    if Obj[Name] = RowText {
                        while ++k <= EndCol {
                            ColName := LV.GetText(0, k)
                            LV.Modify(A_Index, 'Col' k, Obj.Has(ColName) ? Obj.Get(ColName) : '')
                        }
                        if IsSet(Opt)
                            LV.Modify(A_Index, Opt)
                        break
                    }
                }
            } else {
                for RowText in ListViewHelper.Rows(LV, -1, MatchCol) {
                    if Obj.%RegExReplace(Name, '[^a-zA-Z0-9_]', '')% = RowText {
                        while ++k <= EndCol {
                            ColName := RegExReplace(LV.GetText(0, k), '[^a-zA-Z0-9_]', '')
                            LV.Modify(A_Index, 'Col' k, Obj.HasOwnProp(ColName) ? Obj.%ColName% : '')
                        }
                        if IsSet(Opt)
                            LV.Modify(A_Index, Opt)
                        break
                    }
                }
            }
        }
    }
    /**
     * @description - Enumerates the columns in the ListView control.
<pre>
      Name            |     Age     |   Favorite Anime Character
    --------------------------------------------------------
[*] Johnny Appleseed  |      27     |    Holo
[ ] Albert Einstein   |   Relative  |    Kurisu Makise
[*] The Rock          |      53     |    Konata Izumi
</pre>
     * @example

        for ColName in ListViewHelper.Cols(LV)
            Str .= ColName ', '
        MsgBox(Trim(Str, ', ')) ; Name, Age, Favorite Anime Character

        for ColName, RowText in ListViewHelper.Cols(LV, 2, 2)
            Str2 .= ColName ': ' RowText ', '
        MsgBox(Trim(Str2, ', ')) ; Name: Albert Einstein, Age: Relative, Favorite Anime Character: Kurisu Makise

    * @
    * @param {Gui.ListView} LV - The ListView control object.
    * @param {Number} [Row=1] - If using the enumerator in its two-parameter mode, you can specify
    * a row from which to obtain the text which gets passed to the second parameter.
    * @param {Number} [VarCount=1] - Specify if you are calling the enumerator in its 1-parameter mode
    * ( `for ColName in ListViewHelper.Cols(Lv)` )
    * or its 2-parameter mode
    * ( `for ColName, RowText in ListViewHelper.Cols(Lv, n, 2)` ).
    * @returns {Enumerator} - An enumerator function that can be used to iterate over the columns.
    */
    static Cols(LV, Row := 1, VarCount := 1) {
        i := 0, MaxCol := LV.GetCount('Col')
        if VarCount == 1 {
            ObjSetBase(Enum1, Enumerator.Prototype)
            return Enum1
        } else if VarCount == 2 {
            ObjSetBase(Enum2, Enumerator.Prototype)
            return Enum2
        }

        Enum1(&ColName) {
            if ++i > MaxCol
                return 0
            ColName := LV.GetText(0, i)
        }

        Enum2(&ColName, &RowText) {
            if ++i > MaxCol
                return 0
            ColName := LV.GetText(0, i)
            RowText := LV.GetText(Row, i)
        }
    }
    /**
     * @description - Enumerates the rows in the ListView control.
     * @param {Gui.ListView} LV - The ListView control object.
     * @param {String} [RowType] - The type of rows to get. The options are:
     * - 'Checked' or 'C': Iterates the checked rows, if any.
     * - 'Focused' or 'F': Iterates the focused rows, if any.
     * - blank or false: Iterates the selected / highlighted rows, if any.
     * - -1: Iterates every row in sequence.
     * @param {Integer|Integer[]} [Col=1] - The column to get the text from. Note this can also be
     * an array of integers when `Output` is an array, see below for details.
     * @param {Integer|Array} [Output=1] - `Output` can modify the enumerator in the following ways:
     * - Output = 1: The enumerator is alled in single-parameter mode, and the variable receives a
     * string value that corresponds to the cell at the intersection of the row and `Col`.
     * - Output = 2: The enumerator is called in two-parameter mode, and the first variable receives
     * the row number, and the second variable receives the string value that corresponds to the cell
     * at the intersection of the row and `Col`.
     * - Output is Array: The enumerator is called in single-parameter mode, and the variable receives
     * the row number. The `Output` array is then filled with text from that row. The columns that get
     * used depend on the value of `Col`. If `Col` is also an array, then only the columns that are
     * represented in that array are included in the `Output` array. The `Col` array should be an
     * array of integers representing column indices. If `Col` is any non-array value, `Output` will
     * contain the text from every column in the row. Each time the enumerator is called on a row,
     * Output is filled again with the text from the next row.
     * @returns {Enumerator} - An enumerator function that can be used to iterate over the rows.
     */
    static Rows(LV, RowType := 0, Col := 1, Output := 1) {
        i := 0
        if RowType = -1 {
            MaxRow := LV.GetCount()
            if Output = 1 {
                ObjSetBase(EnumRow1, Enumerator.Prototype)
                return EnumRow1
            } else if Output = 2 {
                ObjSetBase(EnumRow2, Enumerator.Prototype)
                return EnumRow2
            } else if Output is Array {
                if Col is Array {
                    ObjSetBase(EnumRowV, Enumerator.Prototype)
                    return EnumRowV
                } else {
                    ObjSetBase(EnumRowAll, Enumerator.Prototype)
                    return EnumRowAll
                }
            } else
                throw Error('Invalid otput parameter: ' IsObject(Output)
                ? '`r`n' Output.Stringify() : Output, -1)
        } else {
            if Output = 1 {
                ObjSetBase(EnumSpecial1, Enumerator.Prototype)
                return EnumSpecial1
            } else if Output = 2 {
                ObjSetBase(EnumSpecial2, Enumerator.Prototype)
                return EnumSpecial2
            } else if Output is Array {
                if Col is Array {
                    ObjSetBase(EnumSpecialV, Enumerator.Prototype)
                    return EnumSpecialV
                } else {
                    ObjSetBase(EnumSpecialAll, Enumerator.Prototype)
                    return EnumSpecialAll
                }
            } else
                throw Error('Invalid otput parameter: ' IsObject(Output)
                ? '`r`n' Output.Stringify() : Output, -1)
        }

        EnumRow1(&RowText) {
            if ++i > MaxRow
                return 0
            RowText := LV.GetText(i, Col)
        }

        EnumRow2(&Row, &RowText) {
            if ++i > MaxRow
                return 0
            Row := i
            RowText := LV.GetText(i, Col)
        }

        EnumRowV(&Row) {
            if ++i > MaxRow
                return 0
            Row := i
            Output.Length := Col.Length
            for C in Col
                Output[A_Index] := LV.GetText(i, C)
        }

        EnumRowAll(&Row) {
            if ++i > MaxRow
                return 0
            Row := i
            Output.Length := LV.GetCount('Col')
            loop Output.Length
                Output[A_Index] := LV.GetText(Row, A_Index)
        }

        EnumSpecial1(&Row) {
            if !(i := (LV.GetNext(i, RowType)))
                return 0
            Row := i
        }

        EnumSpecial2(&Row, &RowText) {
            if !(i := (LV.GetNext(i, RowType)))
                return 0
            Row := i
            RowText := LV.GetText(i, Col)
        }

        EnumSpecialV(&Row) {
            if !(i := (LV.GetNext(i, RowType)))
                return 0
            Row := i
            Output.Length := Col.Length
            for C in Col
                Output[A_Index] := LV.GetText(i, C)
        }

        EnumSpecialAll(&Row) {
            if !(i := (LV.GetNext(i, RowType)))
                return 0
            Row := i
            Output.Length := LV.GetCount('Col')
            loop Output.Length
                Output[A_Index] := LV.GetText(Row, A_Index)
        }
    }
    /**
     * @description - Updates an object or an array of objects within the ListView control. The other
     * `UpdateObj` function connects an object to a row by comparing the text content of an object
     * property / item value to the text content of a cell in the ListView. This may not be possible if
     * every value on the row / object has been changed. `UpdateWithCompareFunc` addresses that problem
     * by accepting a function parameter. The function should accept two input parameters:
     * - The text content of a cell in the ListView. The cell is at the intersection of `MatchCol` and
     * the current row being iterated.
     * - The text content of the property / item on the object that corresponds to the column name of
     * `MatchCol`.
     * The function should return a nonzero value if the object is associated with that row.
     * @param {Gui.ListView} LV - The ListView control object.
     * @param {Object|Array} Obj - The object or array of objects to update in the ListView. The objects
     * should have keys / properties corresponding to the column names. The objects do not need to have
     * every value; absent keys and properties will default to an empty string.
     * @param {Function} CompareFunc - The function that compares the text content of a cell in the ListView
     * to the text content of a property / item on the object. The function should return a nonzero value
     * if the object is associated with that row.
     * @param {Number} [MatchCol=1] - The column to match the object on. For example, if my ListView
     * has a column "Name" that I want to use for this purpose, my objects must all have a property
     * or key "Name" that matches with a row of text in the ListView.
     * @param {Number} [StartCol=1] - The column to start updating from.
     * @param {Number} [EndCol] - The column to stop updating at.
     * @param {String} [Opt] - A string containing options for the ListView. The options are the same
     * as those used in the `Modify` method.
     */
    static UpdateWithCompareFunc(LV, Obj, CompareFunc, MatchCol := 1, StartCol := 1, EndCol?, Opt?) {
        if !IsSet(EndCol)
            EndCol := LV.GetCount('Col')
        MaxRow := LV.GetCount()

        if Obj[1] is Map {
            Name := LV.GetText(0, MatchCol)
            for O in Obj
                ListObjText .= O[Name] '`n'
            for RowTxt in ListViewHelper.Rows(LV, -1, MatchCol)
                ListRowText .= RowTxt '`n'
            ListObjText := StrSplit(Sort(Trim(ListObjText, '`n')), '`n')
            ListRowText := StrSplit(Sort(Trim(ListRowText, '`n')), '`n')
            Row := i := 0
            for ObjText in ListObjText {
                ++i
                while ++Row <= MaxRow {
                    if CompareFunc(ListRowText[Row], ObjText) {
                        k := StartCol - 1
                        while ++k <= EndCol {
                            ColName := LV.GetText(0, k)
                            LV.Modify(Row, 'Col' k, Obj[i].Has(ColName) ? Obj[i].Get(ColName) : '')
                        }
                        if IsSet(Opt)
                            LV.Modify(Row, Opt)
                        break
                    }
                }
            }
            if i !== ListObjText.Length
                throw Error('Not all objects were found in the ListView.'
                'The unmatched object is:`r`n' ListObjText[i], -1)
        } else {
            Name := RegExReplace(LV.GetText(0, MatchCol), '[^a-zA-Z0-9_]', '')
            ; So we only have to call RegExReplace once per column.
            Columns := []
            z := StartCol - 1
            while ++z <= EndCol
                Columns.Push(RegExReplace(LV.GetText(0, z), '[^a-zA-Z0-9_]', ''))
            for O in Obj
                ListObjText .= O.%Name% '`n'
            for Txt in ListViewHelper.Rows(LV, -1, MatchCol)
                ListRowText .= Txt '`n'
            ListObjText := StrSplit(Sort(Trim(ListObjText, '`n')), '`n')
            ListRowText := StrSplit(Sort(Trim(ListRowText, '`n')), '`n')
            Row := i := 0
            for ObjText in ListObjText {
                ++i
                while ++Row <= MaxRow {
                    if CompareFunc(ListRowText[Row], ObjText) {
                        k := StartCol - 1
                        while ++k <= EndCol {
                            LV.Modify(Row, 'Col' k, Obj[i].HasOwnProp(Columns[A_Index]) ? Obj[i].%Columns[A_Index]% : '')
                        }
                        if IsSet(Opt)
                            LV.Modify(Row, Opt)
                        break
                    }
                }
            }
            if i !== ListObjText.Length
                throw Error('Not all objects were found in the ListView.'
                'The unmatched object is:`r`n' ListObjText[i], -1)
        }
    }
    static ToMap(LV, CaseSense := true) {
        Result := Map()
        Result.CaseSense := CaseSense
        for Row in this.Rows(LV) {
            for ColName in this.Cols(LV) {

            }
        }
    }
    static Stringify(LV, StartCol := 1, EndCol?, IncludeCols?) {

        if IsSet(IncludeCols) {

        }
    }
}

RGBToLuminosity(r, g, b) {
    RsRGB := r / 255
    GsRGB := g / 255
    BsRGB := b / 255
    return 0.2126 * (RsRGB <= 0.04045 ? RsRGB / 12.92 : ((RsRGB + 0.055) / 1.055) ** 2.4)
    + 0.7152 * (GsRGB <= 0.04045 ? GsRGB / 12.92 : ((GsRGB + 0.055) / 1.055) ** 2.4)
    + 0.0722 * (BsRGB <= 0.04045 ? BsRGB / 12.92 : ((BsRGB + 0.055) / 1.055) ** 2.4)
}
ParseColorRef(colorref, &OutR?, &OutG?, &OutB?) {
    OutR := colorref & 0xFF
    OutG := (colorref >> 8) & 0xFF
    OutB := (colorref >> 16) & 0xFF
}
