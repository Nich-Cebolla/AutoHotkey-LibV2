
#include ..\ItemScroller.ahk
#include ..\MakeInputControlGroup.ahk

test()

class test {
    static Call() {
        this.scrollers := []
        arr := this.arr := []
        arr.Capacity := 100
        loop 100 {
            arr.Push(Random(1,1000))
        }
        ctrls := this.ctrls := []
        g := this.g := gui()
        g.SetFont('s11', 'Segoe Ui')
        g.Add('Edit', 'w100 Section vEdtPages', '20')
        loop 5 {
            ctrls.Push(g.Add('Text', 'w100 vTxt' A_Index, arr[A_Index]))
        }
        ctrls[-1].GetPos(, &y, , &h)

        ; horizontal layout
        _MakeScroller('H', '1', y + h + 10, &x, &y, &w, &h)

        ; diagram layout
        _MakeScroller(
            'BtnPrevious2`nEdtIndex2 TxtOf2`nTxtTotal2 BtnJump2 BtnNext2'
          , '2', y + h + 25, &x, &y, &w, &h
        )

        ; vertical layout
        _MakeScroller('V', '3', y + h + 25, &x, &y, &w, &h)

        g.Add('Button', 'ys vBtnUpdatePages', 'Update pages').OnEvent('Click', HClickButtonUpdatePages)
        g['BtnUpdatePages'].GetPos(&x, , &w)

        this.SetOrientationInput := MakeInputControlGroup(
            g
          , [ 'Index', 'Orientation', 'StartX', 'StartY', 'PaddingX', 'PaddingY' ]
          , { StartX: x + w + 10, StartY: 10, GetButton: false, SetButton: false, EditWidth: 125, NameSuffix: '4' }
        )
        this.SetOrientationInput.Get('Index').Edit.GetPos(&x, , &w)
        g.Add('Button', 'x' (x + w + 10) ' y10 vBtnSetOrientation', 'SetOrientation').OnEvent('Click', HClickButtonSetOrientation)
        g['BtnSetOrientation'].GetPos(&x, , &w)
        this.SetOrientationInput.Get('StartY').Label.GetPos(&x, &y, &w, &h)

        this.PropertiesInput := MakeInputControlGroup(
            g
          , [ 'Orientation', 'PaddingX', 'PaddingY', 'Pages', 'StartX', 'StartY' ]
          , { StartX: x, StartY: y + h + 10, GetButton: true, SetButton: true, EditWidth: 125, NameSuffix: '5' }
        )
        this.PropertiesInput.Get('StartY').Set.GetPos(&x, , &w)
        for label, group in this.PropertiesInput {
            group.Get.OnEvent('Click', HClickButtonGet)
            group.Set.OnEvent('Click', HClickButtonSet)
        }

        this.scrollers[-1].CtrlNext.GetPos(, &y, , &h)

        g.Show('x20 y20 w' (x + w + 10) ' h' (y + h + 10))

        return

        HClickButtonGet(Ctrl, *) {
            prop := StrReplace(StrReplace(Ctrl.Name, '5', ''), 'BtnGet', '')
            index := this.SetOrientationInput.Get('Index').Edit.Text
            if !index || !IsNumber(index) || (index < 1 || index > 3) {
                MsgBox('Use the "Index" edit control at the top to specify which scroller to target. Input an integer between 1 and 3.')
                return
            }
            this.PropertiesInput.Get(prop).Edit.Text := this.scrollers[index].%prop%
        }

        HClickButtonSet(Ctrl, *) {
            prop := StrReplace(StrReplace(Ctrl.Name, '5', ''), 'BtnSet', '')
            index := this.SetOrientationInput.Get('Index').Edit.Text
            if !index || !IsNumber(index) || (index < 1 || index > 3) {
                MsgBox('Use the "Index" edit control at the top to specify which scroller to target. Input an integer between 1 and 3.')
                return
            }
            this.scrollers[index].%prop% := this.PropertiesInput.Get(prop).Edit.Text
        }

        HClickButtonUpdatePages(Ctrl, *) {
            for scroller in this.scrollers {
                scroller.UpdatePages(Ctrl.Gui['EdtPages'].Text)
            }
        }

        HClickButtonSetOrientation(Ctrl, *) {
            this.scrollers[this.SetOrientationInput.Get('Index').Edit.Text].SetOrientation(
                this.SetOrientationInput.Get('Orientation').Edit.Text ? StrReplace(this.SetOrientationInput.Get('Orientation').Edit.Text, '``n', '`n') : unset
              , this.SetOrientationInput.Get('StartX').Edit.Text || unset
              , this.SetOrientationInput.Get('StartY').Edit.Text || unset
              , this.SetOrientationInput.Get('PaddingX').Edit.Text || unset
              , this.SetOrientationInput.Get('PaddingY').Edit.Text || unset
            )
        }

        _MakeScroller(orientation, name, startY, &x, &y, &w, &h) {
            this.scroller_%name% := ItemScroller(g, 20, _Callback, { StartX: 10, StartY: startY, Orientation: orientation, CtrlNameSuffix: name, NormalizeButtonWidths: false })
            this.scroller_%name%.CtrlNext.GetPos(&x, &y, &w, &h)
            this.scroller_%name%.SetReferenceData('ctrls', ctrls, 'arr', arr)
            this.scrollers.Push(this.scroller_%name%)
        }

        _Callback(Index, scroller) {
            arr := scroller.__Item.Get('arr')
            for ctrl in scroller.__Item.Get('ctrls') {
                ctrl.Text := arr[5 * (Index - 1) + A_Index]
            }
        }
    }
}
