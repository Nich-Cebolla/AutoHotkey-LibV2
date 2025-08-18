
#include ..\ItemScroller.ahk

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

        g.Show('x20 y20 w' (x + w + 10) ' h' (y + h + 10))

        return

        HClickButtonUpdatePages(Ctrl, *) {
            for scroller in this.scrollers {
                scroller.UpdatePages(Ctrl.Gui['EdtPages'].Text)
            }
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
