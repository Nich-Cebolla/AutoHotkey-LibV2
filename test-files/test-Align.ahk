#Include ..\Align.ahk
#include ..\RectHighlight.ahk
#include ..\SelectControls.ahk
; https://github.com/Nich-Cebolla/Stringify-ahk
#include <Stringify>
; https://github.com/Nich-Cebolla/AutoHotkey-Array
#include <Array_Reduce>
#include <Array_ForEach>
#include <Array_Find>

; https://github.com/Nich-Cebolla/Stringify-ahk/blob/main/Object.Prototype.Stringify.ahk
#include <Object.Prototype.Stringify_V1.0.0>
; https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/ParseJson.ahk
#include <ParseJson>
; https://github.com/Nich-Cebolla/AutoHotkey-DecodeUnicodeEscapeSequence/blob/main/DecodeUnicodeEscapeSequence.ahk
#include <DecodeUnicodeEscapeSequence>
; https://github.com/Nich-Cebolla/AutoHotkey-GetObjectFromString/blob/main/GetObjectFromString.ahk
#include <GetObjectFromString>

#SingleInstance force

/*
    This file also has a test built into it for "SelectControls.ahk". It's not comprehensive, but
    demonstrates its usage. When the Gui window opens, there's a button that says "SelectControls".
    Clicking that button will launch the SelectControls interface. To test it, you can set options
    on the right-hand side as strings. Then click the "Start" button, which will initiate the test.
    Check any checkboxes, or click the "Check All" button, then either press the hotkey or click
    the "Submit" button on the "InfoWindow" and it will call the function.

    The options edit fields accept strings, numbers, JSON objects, and some other things
    but for this you would only use those three.
*/

Test_Align()

class Test_Align {
    static Inputs :=  [['X1', 'Y1'], ['X2', 'Y2']]
    , Buttons := ['Set position', 'Run', 'Reset', 'Make', 'Close', 'Update pos', 'Restart', 'SelectControls', 'Diagram']
    , DPI_AWARENESS_CONTEXT := -4
    , FontSize := 11
    , FontStandard := 'Aptos,Segoe UI,Roboto'
    , FontMono := 'Mono,Arial Rounded MT,Roboto Mono,IBM Plex Mono,Ubuntu Mono,Chivo Mono'

    , Child_AvgControlWidth := 120
    , Child_ControlStdDevW := 40
    , Child_AvgControlHeight := 50
    , Child_ControlStdDevH := 19
    , Child_Opt := '+Resize'
    , Child_Title := 'Test_Align.Child'
    , Child_GuiBackColor := 'd4c5c5'
    , Child_ControlBackColor := 'FFFFFF'
    , Child_Width := 1100
    , Child_Height := 700
    , Child_ControlCt := 20

    , SC_Types := ['Button', 'Text', 'Checkbox', 'Radio']
    , SC_Buttons := ['Start', 'Check All', 'Cancel', 'Exit']
    , SC_Checkboxes := ['GroupHeight', 'GroupWidth', 'CenterHList', 'CenterVList']
    , SC_DefaultEditWidth := 200
    , SC_EndKey := '!t'
    , SC_ResultEditRows := 15
    , SC_RectHighlightOptText := '{ "Color": "358afa" }'

    , DG_Buttons := ['Run', 'Exit', 'Rename controls']
    , DG_Checkboxes := ['DiagramFromSymbols']
    , DG_Params := ['StartX', 'StartY', 'PaddingX', 'PaddingY']
    , DG_ParamDefaults := [ 10, 10, '', '' ]
    , DG_Renamed_Default_Tests := ['test"quote', 'test``rcr', 'test``nlf', 'test space', 'test``ttab', '55555', 'test\slash']
    , DG_Renamed_Default_Diagram := '
    (
        test\"quote 50 test\rcr 50 test\nlf
        50
        "test space" 50 "test``ttab"
        50
        "55555" 50 test\\slash
    )'
    , DG_EditWidth := 100
    , DG_DiagramWidth := 500
    , DG_DiagramRows := 10
    , DG_ResultRows := 20
    , DG_Child_WindowWidth := 900
    , DG_Child_WindowHeight := 700
    , DG_Child_AvgControlWidth := 120
    , DG_Child_ControlStdDevW := 40
    , DG_Child_AvgControlHeight := 50
    , DG_Child_ControlStdDevH := 19
    , DG_Child_ControlCt := 7

    static Call() {
        Align.DPI_AWARENESS_CONTEXT := this.DPI_AWARENESS_CONTEXT
        DllCall('SetThreadDpiAwarenessContext', 'ptr', this.DPI_AWARENESS_CONTEXT, 'ptr')
        this.Constructor()
    }

    static CacheBtnPos() {
        if this.G['Use_S'].Value {
            DllCall('SetThreadDpiAwarenessContext', 'ptr', this.DPI_AWARENESS_CONTEXT, 'ptr')
        }
        for Btn in this.Btn {
            Btn.GetPos(&cx, &cy)
            Btn.Pos := { X: cx, Y: cy }
        }
    }

    static CachePos(Index?, Name := 'Original') {
        G := this.G
        if IsSet(Index) {
            _Process(Index)
        } else {
            loop this.Children.Length {
                if this.Children.Has(A_Index) {
                    _Process(A_Index)
                }
            }
        }

        _Process(Index) {
            this.UpdateDisplay(Index, Name, &X, &Y, &W, &H)
            this.Children[Index].Pos := { X: X, Y: Y, W: W, H: H }
        }
    }

    static Constructor() {
        G := this.G := Gui('-DPIScale')
        this.Pos := {}
        this.Children := []
        this.Btn := [
            G.Add('Button', 'w100 x50 y10 vBtn1', 'Btn1')
          , G.Add('Button', 'w100 x110 y50 vBtn2', 'Btn2')
        ]
        Y := 100
        G.Add('Text', Format('x{} y{} Section w150 vTxtWidth', G.MarginX, y), 'Available width:')
        G.Add('Text', 'ys vTxtHeight', 'Available height: 100').GetPos(, &cy, , &ch)

        z := 0
        X := G.MarginX
        Y := cy + ch + G.MarginY
        for Name in this.Buttons {
            Btn := G.Add('Button', Format('x{} y{}', X, Y), Name)
            Btn.OnEvent('Click', HClickButton%StrReplace(Name, ' ', '')%)
            Btn.Name := Name
            Btn.GetPos(, , &cw)
            X += cw + G.MarginX
            if !Mod(++z, 3) {
                X := G.MarginX
                Y += ch + G.MarginY + 10
            }
        }

        Y += ch + G.MarginY + 10
        X := G.MarginX
        for Input in this.Inputs {
            G.Add('Text', Format('x{} y{} Section', G.MarginX, Y), Input[1])
            G.Add('Edit', 'ys w60 v' Input[1])
            G.Add('Text', 'ys', Input[2])
            G.Add('Edit', 'ys w60 v' Input[2])
            Y += 30
        }
        G.Add('Checkbox', 'xs Checked Section vUse_S', 'Use ``_S`` suffix').GetPos(, &cy)
        G.Add('Checkbox', 'ys Checked vSpawnOnPrimary', 'Spawn on primary')

        z := 0
        Props := []
        Props.Capacity := ObjOwnPropCount(Align)
        for Prop in Align.OwnProps() {
            if Align.HasMethod(Prop) && SubStr(Prop, 1, 2) !== '__' && !InStr('SelectControls,Diagram', Prop) {
                Props.Push(Prop)
            }
        }
        Props.Capacity := Props.Length
        for Prop in Props {
            z++
            if z == 1 {
                ctrl := G.Add('Checkbox', 'x10 y' (cy + 25) ' Checked Section v' Prop, Prop)
                this.LastChecked := ctrl
            } else if z == Ceil(Props.Length / 2) {
                ctrl := G.Add('Checkbox', 'x150 y' (cy + 25) ' Section v' Prop, Prop)
            } else {
                ctrl :=G.Add('Checkbox', 'xs v' Prop, Prop)
            }
            ctrl.OnEvent('Click', HClickCheckboxAny)
        }
        this.SpawnWindows(2)
        this.CacheBtnPos()
        this.CachePos()
        G.OnEvent('Close', (*) => ExitApp())
        G.Show()
        G.GetClientPos(, , &gw)
        G['TxtWidth'].Text := 'Available width: ' gw

        HClickButtonClose(*) {
            for child in this.Children {
                child.Destroy()
            }
            this.Children := []
        }

        HClickButtonMake(*) {
            this.SpawnWindows(1)
        }

        HClickButtonReset(*) {
            if this.G['Use_S'].Value {
                DllCall('SetThreadDpiAwarenessContext', 'ptr', this.DPI_AWARENESS_CONTEXT, 'ptr')
            }
            loop this.Children.Length {
                _Process(A_Index)
            }
            loop 2 {
                Btn := this.Btn[A_Index]
                Btn.Move(Btn.pos.X, Btn.pos.Y)
            }

            _Process(Index) {
                if this.Children.Has(Index) {
                    _g := this.Children[Index]
                    _g.Move(_g.Pos.X, _g.Pos.Y, _g.Pos.W, _g.Pos.H)
                }
            }
        }

        HClickButtonRun(*) {
            Name := this.LastChecked.Name (G['Use_S'].Value ? '_S' : '')
            if InStr(this.LastChecked.Name, 'List') {
                this.CachePos(, 'Original')
                Align.%Name%(this.Children)
                this.UpdateDisplay(, 'Adjusted')
            } else {
                this.CacheBtnPos()
                this.CachePos(1)
                this.CachePos(2)
                Align.%Name%(this.Btn[1], this.Btn[2])
                Align.%Name%(this.Children[1], this.Children[2])
                this.UpdateDisplay(, 'Adjusted')
            }
        }

        HClickButtonDiagram(*) {
            this.Diagram()
        }

        HClickButtonSelectControls(*) {
            this.SelectControls()
        }

        HClickButtonSetPosition(*) {
            this.Btn[1].Move(G['X1'].Text || this.Btn[1].pos.X, G['Y1'].Text || this.Btn[1].pos.Y)
            this.Btn[2].Move(G['X2'].Text || this.Btn[2].pos.X, G['Y2'].Text || this.Btn[2].pos.Y)
        }

        HClickButtonUpdatePos(*) {
            this.UpdateDisplay(, 'Original')
        }

        HClickCheckboxAny(Ctrl, *) {
            this.LastChecked.Value := 0
            Ctrl.Value := 1
            this.LastChecked := Ctrl
        }

        HClickButtonRestart(*) {
            Reload()
        }
    }

    static Diagram() {
        DG := this.DG := Gui('+Resize')
        DG.SetFont('s11 q5')
        DG.texts := []
        DG.edits := []
        DG.buttons := []
        DG.checkboxes := []
        for Name in this.DG_Buttons {
            _Name := RegExReplace(Name, '\W', '')
            DG.buttons.Push(DG.Add('Button', (A_Index == 1 ? 'Section' : 'ys') ' vBtn' _Name, Name))
            DG.buttons[-1].OnEvent('Click', HClickButton%_Name%)
        }
        for Name in this.DG_Checkboxes {
            _Name := RegExReplace(Name, '\W', '')
            DG.checkboxes.Push(DG.Add('Checkbox', (A_Index == 1 ? 'xs Section' : 'ys') ' vChk' _Name, Name))
        }
        W := 0
        editW := this.DG_EditWidth
        defaults := this.DG_ParamDefaults
        for Param in this.DG_Params {
            DG.texts.Push(DG.Add('Text', 'xs Section vTxt' Param, Param))
            DG.texts[-1].GetPos(, , &txtw)
            DG.edits.Push(DG.Add('Edit', 'w' editW ' ys vEdt' Param, defaults[A_Index]))
            W := Max(W, txtw)
        }
        X := DG.MarginX * 2 + W
        for txt in DG.texts {
            txt.Move(, , W)
            DG.edits[A_Index].Move(X)
        }
        DG.Add('Edit', Format('w{} r{} xs vEdtDiagram', this.DG_DiagramWidth, this.DG_DiagramRows))
        DG.Add('Edit', Format('w{} r{} xs vEdtResult', this.DG_DiagramWidth, this.DG_ResultRows))
        DG.Child := this.MakeChild(
            this.DG_Child_ControlCt
            , this.DG_Child_AvgControlWidth
            , this.DG_Child_ControlStdDevW
            , this.DG_Child_AvgControlHeight
            , this.DG_Child_ControlStdDevH
            , this.DG_Child_WindowWidth
            , this.DG_Child_WindowHeight
        )
        this.SetFonts(DG['EdtDiagram'], this.FontMono)
        this.SetFonts(DG['EdtResult'], this.FontMono)
        DG.Show('x0 y0')
        DG.Child.Show()
        DG.Child.Move(, , this.DG_Child_WindowWidth, this.DG_Child_WindowHeight)
        Align.MoveAdjacent(DG.Child, DG)
        DG.OnEvent('Close', HClickButtonExit)

        return

        HClickButtonExit(*) {
            this.DG.Child.Destroy()
            if this.DG.HasOwnProp('RenameControlsWindow') {
                try {
                    this.DG.RenameControlsWindow.Destroy()
                }
            }
            this.DG.Destroy()
            this.DeleteProp('DG')
        }
        HClickButtonRenameControls(Ctrl, *) {
            tests := this.DG_Renamed_Default_tests
            DG := Ctrl.Gui
            if DG.HasOwnProp('RenameControlsWindow') {
                RCW := DG.RenameControlsWindow
            } else {
                RCW := DG.RenameControlsWindow := this.Gui()
            }
            RCW.Add('Text', 'w25 Right Section vTxt1', 1)
            RCW.Add('Edit', 'w200 ys vEdt1', tests[1])
            DG.Child.Controls[1].Edit := RCW['Edt1']
            i := 1
            loop DG.Child.Controls.Length - 1 {
                RCW.Add('Text', 'xs w25 Right Section vTxt' (++i), i)
                RCW.Add('Edit', 'w200 ys vEdt' i, tests[i])
                DG.Child.Controls[i].Edit := RCW['Edt' i]
            }
            for Name in ['Submit', 'Cancel'] {
                ; _Name := RegExReplace(Name, '\W', '')
                _Name := Name
                btn := RCW.Add('Button', (A_Index == 1 ? 'Section' : 'ys') ' vBtn' _Name, Name)
                btn.OnEvent('Click', HClickButton%_Name%)
            }
            RCW.Show()
            Align.MoveAdjacent(RCW, DG)

            return

            HClickButtonCancel(*) {
                this.DG.RenameControlsWindow.Hide()
                for Ctrl in this.DG.Child.Controls {
                    Ctrl.Edit.Text := Ctrl.Name
                }
            }
            HClickButtonSubmit(Ctrl, *) {
                flag := true
                tests := this.DG_Renamed_Default_tests
                str := ''
                for Ctrl in this.DG.Child.Controls {
                    str .= Ctrl.Edit.Text '`r`n'
                    Ctrl.Name := StrReplace(StrReplace(StrReplace(Ctrl.Edit.Text, '``n', '`n'), '``r', '`r'), '``t', '`t')
                    if Ctrl.Edit.Text != tests[A_Index] {
                        flag := false
                    }
                }
                this.DG['EdtResult'].Text := str '`r`n' this.DG['EdtResult'].Text
                if flag {
                    this.DG['EdtDiagram'].Text := RegExReplace(this.DG_Renamed_Default_Diagram, '\R', '`r`n')
                }
                this.DG.RenameControlsWindow.Hide()
            }
        }
        HClickButtonRun(Ctrl, *) {
            DG := Ctrl.Gui
            if DG['ChkDiagramFromSymbols'].Value {
                Diagram := StrReplace(StrReplace(StrReplace(DG['EdtDiagram'].Text, '``n', '`n'), '``r', '`r'), '``t', '`t')
                Sym := '@'
                Symbols := Map()
                G := DG.Child
                rci := 0xFFFD ; Replacment character
                ch := Chr(rci)
                while InStr(Diagram, ch) {
                    ch := Chr(--rci)
                }
                if InStr(Diagram, '"') {
                    Names := Map()
                    Index := 0
                    Pos := 1
                    loop {
                        if !RegExMatch(Diagram, '(?<=\s|^)"(?<text>.*?)(?<!\\)(?:\\\\)*+"', &Match, Pos) {
                            break
                        }
                        Pos := Match.Pos
                        Names.Set(ch (++Index) ch, Match)
                        Diagram := StrReplace(Diagram, Match[0], ch Index ch)
                    }
                }
                Rows := StrSplit(RegExReplace(RegExReplace(Trim(Diagram, '`s`t`r`n'), '\R+', '`n'), '[`s`t]+', '`s'), '`n')
                loop Rows.Length {
                    Rows[A_Index] := StrSplit(Trim(Rows[A_Index], '`s'), '`s')
                }
                new_diagram := ''
                i := 0
                for Row in Rows {
                    for Value in Row {
                        if IsNumber(Value) {
                            new_diagram .= ' ' Value
                        } else {
                            new_diagram .= ' ' Sym (++i)
                            _ProcValue(&Value)
                            Symbols.Set(Sym i, G[Value])
                        }
                    }
                    new_diagram .= '`n'
                }
                Result := Align.DiagramFromSymbols(
                    DG.Child
                  , Trim(new_diagram, '`n')
                  , Symbols
                  , DG['EdtStartX'].Text || unset
                  , DG['EdtStartY'].Text || unset
                  , DG['EdtPaddingX'].Text || unset
                  , DG['EdtPaddingY'].Text || unset
                )
            } else {
                Result := Align.Diagram(
                    DG.Child
                  , StrReplace(StrReplace(StrReplace(DG['EdtDiagram'].Text, '``n', '`n'), '``r', '`r'), '``t', '`t')
                  , DG['EdtStartX'].Text || unset
                  , DG['EdtStartY'].Text || unset
                  , DG['EdtPaddingX'].Text || unset
                  , DG['EdtPaddingY'].Text || unset
                )
            }
            WinRedraw(DG.hWnd)
            DG['EdtResult'].Text := Stringify(Result) '`r`n`r`n' DG['EdtResult'].Text

            _ProcValue(&Value) {
                if InStr(Value, ch) {
                    Value := Names.Get(Value)['text']
                }
                Value := StrReplace(StrReplace(StrReplace(StrReplace(Value, '\\', '\')
                    , '\r', '`r'), '\n', '`n'), '\"', '"')
            }
        }
    }

    static GetWeights(Length) {
        return [
            { Start: 100, End: Length * 0.1, Weight: 0.05 },
            { Start: Length * 0.1, End: Length * 0.9, Weight: 0.9 },
            { Start: Length * 0.9, End: Length - 100, Weight: 0.05 }
        ]
    }

    static Gui() {
        G := Gui('+Resize')
        G.SetFont('s' this.FontSize)
        for s in StrSplit(this.FontStandard, ',') {
            G.SetFont(, s)
        }
        return G
    }

    static Make(Index) {
        G := this.G
        if Index > this.Children.Length {
            this.Children.Length := Index
        }
        _g := this.Children[Index] := Gui('+Resize +Owner -DPIScale')
        _g.Index := Index
        _g.SetFont('s11', 'Roboto')
        _g.Add('Text', 'Section vTxtOriginal', 'Original')
        _g.Add('Edit', 'xs w150 r5 vOriginal')
        _g.Add('Text', 'Section ys vTxtAdjusted', 'Adjusted')
        _g.Add('Edit', 'xs w150 r5 vAdjusted')
        _g.OnEvent('Close', HChildWinClose)
        return _g

        HChildWinClose(GuiObj, *) {
            this.Children.RemoveAt(GuiObj.Index)
        }
    }

    static MakeChild(Count?, AvgWidth?, StdDevW?, AvgHeight?, StdDevH?, WindowWidth?, WindowHeight?) {
        if !IsSet(Count) {
            Count := this.Child_ControlCt
        }
        CG := Gui('+Resize')
        CG.BackColor := this.Child_GuiBackColor
        xs := CG.xs := GenerateWeightedDistribution(this.GetWeights(WindowWidth ?? this.Child_Width), Count)
        ys := CG.ys := GenerateWeightedDistribution(this.GetWeights(WindowHeight ?? this.Child_Height), Count)
        ws := CG.ws := GenerateGaussianDistribution(AvgWidth ?? this.Child_AvgControlWidth, StdDevW ?? this.Child_ControlStdDevW, Count)
        hs := CG.hs := GenerateGaussianDistribution(AvgHeight ?? this.Child_AvgControlHeight, StdDevH ?? this.Child_ControlStdDevH, Count)
        Controls := CG.Controls := []
        loop Controls.Capacity := Count {
            Controls.Push(CG.Add(_GetType(), Format('x{} y{} w{} h{} Background{} vc{}'
                , xs[A_Index]
                , ys[A_Index]
                , ws[A_Index]
                , hs[A_Index]
                , this.Child_ControlBackColor
                , A_Index
            ), 'Control ' A_Index))
        }

        return CG

        _GetType() {
            if (n := Random()) <= 0.25 {
                return this.SC_Types[1]
            } else if n <= 0.5 {
                return this.SC_Types[2]
            } else if n <= 0.75 {
                return this.SC_Types[3]
            } else {
                return this.SC_Types[4]
            }
        }
    }

    static SelectControls() {
        SC := this.SC := this.Gui()
        SC_child := SC.Child := this.MakeChild()
        BW := CW := TW := EW := 0
        Buttons := SC.Buttons := []
        for Text in this.SC_Buttons {
            if A_Index == 1 {
                Buttons.Push(SC.Add('Button', 'Section vBtn' StrReplace(Text, ' ', ''), Text))
                Buttons[-1].GetPos(&X, &StartY)
            } else {
                Buttons.Push(SC.Add('Button', 'vBtn' StrReplace(Text, ' ', ''), Text))
            }
            Buttons[-1].OnEvent('Click', HClickButton%StrReplace(Text, ' ', '')%)
            Buttons[-1].GetPos(, , &w)
            BW := Max(BW, w)
        }
        for Btn in Buttons {
            Btn.Move(, , BW)
        }
        X += BW + SC.MarginX
        Y := StartY
        Checkboxes := SC.Checkboxes := []
        for Text in this.SC_Checkboxes {
            Checkboxes.Push(SC.Add('Checkbox', Format('x{} y{} vChk{}', X, Y, Text), Text))
            Checkboxes[-1].OnEvent('Click', HClickCheckboxAny)
            Checkboxes[-1].GetPos(, , &w, &h)
            CW := Max(CW, w)
            Y += h + SC.MarginY
        }
        for Chk in Checkboxes {
            Chk.Move(, , CW)
        }
        SC.LastChecked := Checkboxes[1]
        SC.LastChecked.Value := 1
        Y := StartY
        X += CW + SC.MarginX
        Texts := SC.Texts := []
        Edits := SC.Edits := []
        for Prop, Value in SelectControls.Options.Default.OwnProps() {
            if SubStr(Prop, 1, 2) == '__' {
                continue
            }
            Texts.Push(SC.Add('Text', 'x' X ' y' Y ' vTxt' Prop, Prop))
            Edits.Push(SC.Add('Edit', 'x' X ' y' Y ' w' this.SC_DefaultEditWidth ' vEdt' Prop, IsObject(Value) ? '{' Type(Value) '}' : Value))
            Texts[-1].GetPos(, , &w)
            TW := Max(TW, w)
            Edits[-1].Prop := Prop
            if Prop = 'RectHighlightOpt' {
                Edits[-1].Text := this.SC_RectHighlightOptText
            }
        }
        X += TW + SC.MarginX
        Y := StartY
        Edits[1].GetPos(, , , &h)
        for Txt in Texts {
            Txt.Move(, Y, TW)
            Edits[A_Index].Move(X, Y)
            Y += h + SC.MarginY
        }
        SC.Add('Edit', Format('x{} y{} w{} r{} vEdtResult', SC.MarginX, Y + 10, X + this.SC_DefaultEditWidth - SC.MarginX, this.SC_ResultEditRows))
        SC.Show('x100 y25')
        SC.GetPos(&x, &y, &w)
        SC_child.Show(Format('x{} y{}', 50 + x + w, 25))

        return

        HClickButtonStart(Ctrl, *) {
            SC := Ctrl.Gui
            Options := {}
            for e in SC.Edits {
                if e.Text {
                    switch e.Text, 0 {
                        case 'true': Options.%e.Prop% := 1
                        case 'false': Options.%e.Prop% := 0
                        default:
                            Options.%e.Prop% := StringToAhkAction(e.Text)
                    }
                }
            }
            if SC.HasOwnProp('SelectControlsHelper') {
                (fn := SC.SelectControlsHelper)()
            } else {
                SC.SelectControlsHelper := SelectControls(SC.Child, this.SC_EndKey, _Callback, Options)
            }

            _Callback(List) {
                SC.List := List
                for Ctrl in List {
                    Ctrl.GetPos(&x, &y, &w, &h)
                    Ctrl.StartPos := { x:x,y:y,w:w,h:h }
                    Ctrl.Index := A_Index
                }
                Align.%SC.LastChecked.Text%(List)
                for Ctrl in List {
                    Ctrl.GetPos(&x, &y, &w, &h)
                    Ctrl.EndPos := { x:x,y:y,w:w,h:h }
                }
                SC['EdtResult'].Text := Stringify(List, , { PropsList: Map('Gui.Control', 'Name') }) '`r`n`r`n======================`r`n`r`n' SC['EdtResult'].Text
            }
        }
        HClickButtonCancel(Ctrl, *) {
            Ctrl.Gui.SelectControlsHelper.Cancel()
        }
        HClickButtonExit(Ctrl, *) {
            Ctrl.Gui.Destroy()
        }
        HClickButtonCheckAll(Ctrl, *) {
            Ctrl.Gui.SelectControlsHelper.CheckAll()
        }
        HClickCheckboxAny(Ctrl, *) {
            Ctrl.Gui.LastChecked.Value := 0
            Ctrl.Value := 1
            Ctrl.Gui.LastChecked := Ctrl
        }
    }

    static SpawnWindows(Count?, Index?) {
        static MinW := 300
        static MinH := 150
        G := this.G
        if G['Use_S'].Value {
            DllCall('SetThreadDpiAwarenessContext', 'ptr', this.DPI_AWARENESS_CONTEXT, 'ptr')
        }
        if IsSet(index) {
            _Process(Index)
        } else if IsSet(Count) {
            loop Count {
                _Process(this.Children.Length + 1)
            }
        }

        _Process(Index) {
            try {
                if this.Children.Has(Index) {
                    WinExist(this.Children[Index].Hwnd)
                    _g := this.Children[Index]
                } else {
                    _g := this.Make(Index)
                }
            } catch {
                _g := this.Make(Index)
            }
            if G['SpawnOnPrimary'].Value {
                i := 1
            } else {
                z := 0, n := Random(), i := 0
                s := 1 / MonitorGetCount()
                loop {
                    i++, z += s
                    if n <= z {
                        break
                    }
                }
            }
            MonitorGetWorkArea(i, &ml, &mt, &mr, &mb)
            ml += 200
            mt += 200
            mr -= 200
            mb -= 200
            _g.Show(Format('x{} y{} w{} h{}'
                , Random() * (mr - ml) + ml
                , Random() * (mb - mt) + mt
                , MinW + Random() * 200
                , MinH + Random() * 200
            ))
            this.CachePos(Index)
        }
    }

    static UpdateDisplay(Index?, Name := 'Original', &x?, &y?, &w?, &h?) {
        if this.G['Use_S'].Value {
            DllCall('SetThreadDpiAwarenessContext', 'ptr', this.DPI_AWARENESS_CONTEXT, 'ptr')
        }
        if IsSet(Index) {
            _Process(Index)
        } else {
            loop this.Children.Length {
                if this.Children.Has(A_Index) {
                    _Process(A_Index)
                }
            }
        }

        _Process(Index) {
            this.Children[Index].GetPos(&x, &y, &w, &h)
            this.Children[Index][Name].Text := (
                'X: ' x
                '`r`nY: ' y
                '`r`nW: ' w
                '`r`nH: ' h
            )
        }
    }

    static SetFonts(Obj, FontFamilies) {
        for s in StrSplit(FontFamilies, ',') {
            if s {
                Obj.SetFont(, S)
            }
        }
    }
}

/**
 * @description - Creates an array of values that follow a weighted distribution.
 * @param {Array} Input - An object with the following properties:
    @example
    input :=  [
        { Start: 0, End: 25, Weight: 0.3 },
        { Start: 25, End: 50, Weight: 0.2 },
        { Start: 50, End: 75, Weight: 0.4 },
        { Start: 75, End: 100, Weight: 0.1 }
    ]
    arr := GenerateWeightedDistribution(input, 1000)
    @
 * @returns {Array} - An array of values that follow the weighted distribution.
 */
GenerateWeightedDistribution(Input, Length) {
    local Result := [], i := 0
    , CDF := [], Cumulative := 0, TotalWeight := Input.Reduce(_GetTotalWeight, 0)
    Result.Length := Length
    Input.ForEach(_GetCDFItem)
    loop Length
        Result[A_Index] := _GetNumber()
    return Result

    _GetTotalWeight(&Accumulator, Segment, *) {
        Accumulator += Segment.Weight * (Segment.End - Segment.Start)
    }
    _GetNumber() {
        SelectedSegment := CDF.Find(((n, Segment, *) => n <= Segment.Cumulative).Bind(Random()))
        return Random() * (SelectedSegment.End - SelectedSegment.Start) + SelectedSegment.Start
    }
    _GetCDFItem(Segment, *) {
        Cumulative += Segment.Weight * (Segment.End - Segment.Start) / TotalWeight
        CDF.Push({Start: Segment.Start, End: Segment.End, Weight: Segment.Weight, Cumulative: Cumulative})
    }
}

/**
 * @description - Generates an array containing values that follow a Gaussian distribution.
 * @param {Number} Mean - The mean of the Gaussian distribution.
 * @param {Number} StdDev - The standard deviation of the Gaussian distribution.
 * @param {Integer} Length - The length of the resulting array.
 * @returns {Array} - An array of values that follow the Gaussian distribution.
    @example
        ; For demonstration, this example uses the Histogram function
        #Include <Histogram>
        OutputDebug(Histogram(GenerateGaussianDistribution(50, 10, 10000)))
        ; 13.060 - 16.734 : 3
        ; 16.734 - 20.409 : 7
        ; 20.409 - 24.083 : 34
        ; 24.083 - 27.757 : 92    *
        ; 27.757 - 31.431 : 190   ***
        ; 31.431 - 35.106 : 375   *****
        ; 35.106 - 38.780 : 681   *********
        ; 38.780 - 42.454 : 947   *************
        ; 42.454 - 46.128 : 1216  *****************
        ; 46.128 - 49.803 : 1451  ********************
        ; 49.803 - 53.477 : 1402  *******************
        ; 53.477 - 57.151 : 1256  *****************
        ; 57.151 - 60.825 : 989   **************
        ; 60.825 - 64.499 : 611   ********
        ; 64.499 - 68.174 : 418   ******
        ; 68.174 - 71.848 : 199   ***
        ; 71.848 - 75.522 : 83    *
        ; 75.522 - 79.196 : 32
        ; 79.196 - 82.871 : 12
        ; 82.871 - 86.545 : 2
    @
 * {@link https://github.com/Nich-Cebolla/AutoHotkey-Distributions/blob/main/Histogram.ahk}
 */
GenerateGaussianDistribution(Mean, StdDev, Length) {
    Result := [], Result.Length := Length, i := 0
    loop Length
        Result[++i] := Mean + StdDev * Sqrt(-2 * Ln(Random())) * Cos(2 * 3.141592653589793 * Random())
    return Result
}


/*
    `StringToAhkAction` is unfinished, but works well enough for what this script needs.
    `GetParams` is superceded by "ParamsList.ahk" in this repo. "ParamsList.ahk" is much more
    flexible and usable.
*/

/*
    Dependencies:
        Object.Prototype.Stringify.Ahk
        ParseJson.ahk
        DecodeUnicodeEscapeSequence.ahk
        GetObjectFromString.ahk
*/


StringToAhkAction(Str, RootObj?) {
    static PatternQuote := '(?<!``)(?:````)*+([`"`'])(?<text>.*?)(?<!``)(?:````)*+\g{-2}'
    static PatternNumber := '(?<n>-?\d++(?:\.\d++)?)(?<e>[eE][+-]?\d++)?'
    static PatternCurly := '(\{(?:[^}{]++|(?-1))*\})'
    static PatternSquare := '(\[(?:[^\][]++|(?-1))*\])'
    if IsSet(RootObj) {
        if HasProp(RootObj, Str)
            return RootObj.%Str%
    }
    Sections := []
    Pos := 1
    Str := Trim(Str, '`s`t')
    Len := StrLen(Str)
    while RegExMatch(Str, '(\((?:[^)(]++|(?-1))*\))', &MatchParentheses, Pos) {
        Path := SubStr(Str, Pos, MatchParentheses.Pos - 1)
        PathSplit := StrSplit(Path, '.')
        MethodCall := PathSplit.Pop()
        Sections.Push( { Path: PathSplit.Length ? PathSplit : ''
            , Method: SubStr(Str, Pos, MatchParentheses.Pos - 1)
            , Params: GetParams(MatchParentheses[0]) }
        )
        Pos := MatchParentheses.Pos + MatchParentheses.Len + 1
        if Pos >= Len
            break
    }
    Result := []
    if Sections.Length {
        if Sections[1].Path {
            Obj := GetObjectFromString(Sections[1].Path, RootObj ?? unset)
        } else {
            if !IsSet(RootObj)
                throw Error('The input string did not produce a root object.', -1
                , 'Input: ' Str)
            Obj := RootObj
        }
        loop Sections.Length {
            Result.Push(_CallMethod(Obj, Sections, A_Index))
            if A_Index < Sections.Length {
                if IsObject(Result[-1]) {
                    Obj := Result[-1]
                } else
                    throw Error('The input string suggests that there is further processing to do'
                    ' after the ' A_Index ' method call, but the method returned a non-object value.', -1,
                    'Value: ' Result[-1] '`tInput: ' Str)
                if Sections[A_Index + 1].Path {
                    Obj := GetObjectFromString(Sections[A_Index + 1].Path, Obj)
                }
            }
        }
    } else {
        if RegExMatch(Str, 'J)(?<bracket>\{(?:[^}{]++|(?&bracket))*\})|(?<bracket>\[(?:[^[\]]++|(?&bracket))*\])', &Match) {
            if Match.Len == Len {
                return ParseJson(Str)
            } else {
                throw Error('Unable to parse the content at this time.', -1, Str)
            }
        } else if RegExMatch(Str, PatternNumber, &Match) && Match.Len == Len {
            return Number(Match[0])
        }
        if !InStr(Str, '.') && !InStr(Str, '[') {
            return Str
        }
        try {
            return GetObjectFromString(Str, RootObj ?? unset)
        } catch {
            return Str
        }
    }
    return Result

    _CallMethod(Obj, Sections, Index) {
        Params := Sections[Index].Params
        P := []
        for ParamObj in Params {
            if !IsSet(ParamObj) || !Trim(ParamObj.Name, '`s`t`r`n')
                continue
            if RegExMatch(ParamObj.Name, PatternQuote, &MatchQuote) {
                P.Push(MatchQuote['text'])
            } else if RegExMatch(ParamObj.Name, PatternNumber, &MatchNum) {
                P.Push(_HandleNumber(MatchNum))
            } else if RegExMatch(ParamObj.Name, PatternCurly, &MatchCurly) {
                P.Push(ParseJson(MatchCurly[0]))
            } else if RegExMatch(ParamObj.Name, PatternSquare, &MatchSquare) {
                P.Push(ParseJson(MatchSquare[0]))
            } else {
                if InStr(ParamObj.Name, '.')
                    P.Push(GetObjectFromString(ParamObj.Name))
                else
                    P.Push(%ParamObj.Name%)
            }
        }
        return Obj.%Sections[Index].Method%(P*)
    }

    _HandleNumber(MatchNum) {
        return MatchNum['e']
        ? Number(MatchNum['n']) * (10 ** Number(MatchNum['e']))
        : Number(MatchNum[0])
    }
}




/**
 * @description - Parses the parameters of a function definition. The input is a string that contains
 * the parameters bounded by open and close parentheses. You can match with this text by using this
 * pattern:
 * @example
    Pos := LogicToGetPosBeforeParams()
    RegExMatch(Content, '(?<params>\(([^()]++|(?&params))*\))', &Match, Pos)
 * @
 * Referring to the example, as long as `Pos` is some position before the opening parentheses, and
 * there are no other parenthese in between Pos and the function's open parentheses, the pattern
 * will correctly match the entire text between the open and close parentheses, even if there are
 * nested parentheses in-between the open and close parentheses.
 * @param {String} TextParams - The text that contains the parameters, not including the containing
 * parentheses. {@link RemoveContaingParentheses}.
 * @returns {Array} - An array of objects with the following properties:
 * @property {String} Name - The name of the parameter.
 * @property {Boolean} Optional - Whether the parameter is optional.
 * @property {String} [Default] - If the parameter has a default, the string representation of the
 * default value.
 */
GetParams(TextParams) {
    static Brackets := ['{', '}', '[', ']', '(', ')']
    static ObjRpl := Chr(0xFFFC)
    ReplacedText := []
    ; Extract all quoted strings and replace them with a unique identifier that will not interfere with pattern matching.
    while RegExMatch(TextParams, '(?<!``)(?:````)*+([`"`'])[\w\W]*?(?<!``)(?:````)*+\g{-1}', &MatchQuote) {
        ReplacedText.Push(MatchQuote)
        TextParams := StrReplace(TextParams, MatchQuote[0], _GetReplacement())
    }
    loop 3 {
        while RegExMatch(TextParams, Format('\{1}([^{1}\{2}]++|(?R))*\{2}', Brackets[A_Index * 2 - 1], Brackets[A_Index * 2]), &MatchBracket) {
            ReplacedText.Push(MatchBracket)
            TextParams := StrReplace(TextParams, MatchBracket[0], _GetReplacement(), , , 1)
        }
    }
    Params := []
    Split := StrSplit(TextParams, ',')
    for Param in Split {
        if InStr(Param, '?')
            Params.Push({ Name: Trim(SubStr(Param, 1, InStr(Param, '?') - 1), '`s`t`r`n'), Optional: true })
        else if InStr(Param, ':=') {
            Default := Trim(SubStr(Param, InStr(Param, ':=') + 2), '`s`t`r`n')
            while RegExMatch(Default, ObjRpl '(\d+)' ObjRpl, &MatchIndex)
                Default := StrReplace(Default, MatchIndex[0], ReplacedText[MatchIndex[1]][0])
            Params.Push({
                Name: Trim(SubStr(Param, 1, InStr(Param, ':=') - 1), '`s`t`r`n')
                , Default: Default
                , Optional: true
            })
        } else
            Params.Push({ Name: Trim(Param, '`s`t`r`n'), Optional: false })
    }
    return Params

    _GetReplacement() {
        static Index := 0
        return ObjRpl (++Index) ObjRpl
    }
}


RemoveContaingParentheses(TextParams) {
    if !RegExMatch(TextParams, '(?<params>\((?<inner>([^()]++|(?&params))*)\))', &MatchParams) {
        StrReplace(TextParams, '(',,, &CountOpen)
        StrReplace(TextParams, ')',,, &CountClose)
        if CountOpen == CountClose
            throw Error('The input string failed to match with the pattern.', -1)
        else
            throw Error('The input string is invalid, likely caused by an inequal number of open and close parentheses.', -1)
    }
    return MatchParams['inner']
}
