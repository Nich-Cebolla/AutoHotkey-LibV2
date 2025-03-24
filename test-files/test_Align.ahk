#Include Align.ahk
#SingleInstance force

Test_Align()

class Test_Align {
    static Inputs :=  [['X1', 'Y1'], ['X2', 'Y2']]
    , Buttons := ['Set position', 'Run', 'Reset', 'Make', 'Close', 'Update pos', 'Restart']
    , DPI_AWARENESS_CONTEXT := -4
    static Call() {
        Align.DPI_AWARENESS_CONTEXT := this.DPI_AWARENESS_CONTEXT
        DllCall('SetThreadDpiAwarenessContext', 'ptr', this.DPI_AWARENESS_CONTEXT, 'ptr')
        this.Constructor()
    }
    static Constructor() {
        G := this.G := Gui('-DPIScale +AlwaysOnTop')
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
        for Prop in Align.OwnProps() {
            if Align.HasMethod(Prop) && SubStr(Prop, 1, 2) !== '__' {
                z++
                if z == 1 {
                    ctrl := G.Add('Checkbox', 'x10 y' (cy + 25) ' Checked Section v' Prop, Prop)
                    this.LastChecked := ctrl
                } else if z == 5 {
                    ctrl := G.Add('Checkbox', 'x150 y' (cy + 25) ' Section v' Prop, Prop)
                } else {
                    ctrl :=G.Add('Checkbox', 'xs v' Prop, Prop)
                }
                ctrl.OnEvent('Click', HClickCheckboxAny)
            }
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
