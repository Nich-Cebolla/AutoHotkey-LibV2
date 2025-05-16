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
    , Buttons := ['Set position', 'Run', 'Reset', 'Make', 'Close', 'Update pos', 'Restart', 'SelectControls']
    , DPI_AWARENESS_CONTEXT := -4
    , FontSize := 11
    , FontStandard := 'Aptos,Segoe UI,Roboto'
    , FontMono := 'Mono,Ubuntu Mono,Chivo Mono'

    , SC_ControlCt := 20
    , SC_Width := 1100
    , SC_Height := 700
    , SC_AvgControlWidth := 120
    , SC_ControlStdDevW := 40
    , SC_AvgControlHeight := 50
    , SC_ControlStdDevH := 19
    , SC_Types := ['Button', 'Text', 'Checkbox', 'Radio']
    , SC_Buttons := ['Start', 'Check All', 'Cancel', 'Exit']
    , SC_Checkboxes := ['GroupHeight', 'GroupWidth', 'CenterHList', 'CenterVList']
    , SC_DefaultEditWidth := 200
    , SC_EndKey := '!t'
    , SC_ResultEditRows := 15
    , SC_GuiBackColor := 'd4c5c5'
    , SC_ControlBackColor := 'FFFFFF'
    , SC_RectHighlightOptText := '{ "Color": "358afa" }'
    , SC_Weights := [
        { Start: 100, End: this.SC_Width * 0.1, Weight: 0.05 },
        { Start: this.SC_Width * 0.1, End: this.SC_Width * 0.9, Weight: 0.9 },
        { Start: this.SC_Width * 0.9, End: this.SC_Width - 100, Weight: 0.05 }
    ]

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
            if Align.HasMethod(Prop) && SubStr(Prop, 1, 2) !== '__' && Prop !== 'SelectControls' {
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

    static SelectControls() {
        SC := this.SC := Gui('+Resize')
        SC.SetFont('s' this.FontSize)
        for s in StrSplit(this.FontStandard, ',') {
            SC.SetFont(, s)
        }
        SC_child := SC.Child := Gui('+Resize')
        SC_child.BackColor := this.SC_GuiBackColor
        Controls := SC.Controls := []
        xs := SC.xs := GenerateWeightedDistribution(this.SC_Weights, this.SC_ControlCt)
        ys := SC.ys := GenerateWeightedDistribution(this.SC_Weights, this.SC_ControlCt)
        ws := SC.ws := GenerateGaussianDistribution(this.SC_AvgControlWidth, this.SC_ControlStdDevW, this.SC_ControlCt)
        hs := SC.hs := GenerateGaussianDistribution(this.SC_AvgControlHeight, this.SC_ControlStdDevH, this.SC_ControlCt)
        loop Controls.Capacity := this.SC_ControlCt {
            Controls.Push(SC_child.Add(_GetType(), Format('x{} y{} w{} h{} Background{} vc{}', xs[A_Index], ys[A_Index], ws[A_Index], hs[A_Index], this.SC_ControlBackColor, A_Index), 'Control ' A_Index))
        }
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
 * parentheses. {@link RemoveContainigParentheses}.
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


RemoveContainigParentheses(TextParams) {
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
