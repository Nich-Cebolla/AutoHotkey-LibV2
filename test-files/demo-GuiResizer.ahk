
#SingleInstance force
#include ..\GuiResizer.ahk

demo()

class demo {
    static Call() {
        ; Make the gui.
        g := this.g := Gui('+Resize')

        ; We are going to add some controls. First, a ListView.
        lv := g.Add('ListView', 'Section w400 r6 vLv', [ 'Col1', 'Col2', 'Col3' ])

        ; Let's place an edit control beneath this ListView.
        edt := g.Add('Edit', 'xs w400 r5 vEdt')

        ; To the right of the ListView are some buttons stacked on top of each other.
        buttons := [ g.Add('Button', 'Section ys vBtn1', 'Button 1') ]
        i := 1
        loop 3 {
            ++i
            buttons.Push(g.Add('Button', 'xs vBtn' i, 'Button ' i))
        }

        ; We want the ListView to grow in width when the gui window's width changes.
        ; The ListView can consume all of the extra width, so we set its W value to 1.
        lv.Resizer := { W: 1 }

        ; Since we have the buttons to the right of the ListView, we need to make sure they move out
        ; of the way. Since the ListView will be growing at a rate of 1, the buttons must move at
        ; a rate of 1. We set the X value to 1.
        for btn in buttons {
            btn.Resizer := { X: 1 }
        }

        ; Let's have both the ListView and the edit control consume a portion of the change in height.
        lv.Resizer.H := 0.5
        ; The edit control will need to move out of the way at the same rate the ListView grows, so
        ; we set both its H and Y value to 0.5. Let's also let is width grow since there's nothing
        ; to its right. For sake of demonstration, we'll let it's width grow a little faster than
        ; the rest to consume the extra empty space.
        edt.Resizer := { H: 0.5, Y: 0.5, W: 1.15 }

        ; That should do it for the resizer objects. The gui must be shown at least once before the
        ; GuiResizer can be activated.
        g.Show('x20 y20')

        ; I like to cache the GuiResizer object as a property on the Gui object.
        g.Resizer := GuiResizer(g)
        ; Notice we are using the default options. I tested out various combinations of options and
        ; chose the defaults because they looked best on my machine. You can easily test a variety
        ; of options on your machine by running the test script test\test-GuiResizer.ahk.
    }
}
