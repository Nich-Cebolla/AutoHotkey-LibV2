
#include ..\ItemScroller.ahk

test()

class test {
    static Call() {
        g := Gui('+Resize')
        g.Add('text', , 'test text')
        opt := {
            AllFontOpt: 's11 q5'
          , AllFontFamily: 'Consolas'
          , AllBackgroundColor: 'red'
          , startY: 30
        }
        scroller := ItemScroller(g, 3, (*) => '', opt)
        g.Show('w400 h100')
    }
}
