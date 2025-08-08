
#include ..\MakeInputControlGroup.ahk

test()

class test {
    static Call() {
        g := this.Gui := Gui()
        g.SetFont('s11 q5', 'Segoe Ui')
        labels := []
        for prop in SomeClass.Prototype.OwnProps() {
            if prop !== '__Class' && prop !== '__New' {
                labels.Push(prop)
            }
        }
        ; We'll just keep the options as their defualts
        this.controls := MakeInputControlGroup(g, labels)
        for label in labels {
            this.controls.Get(label).Get.OnEvent('Click', HClickButtonGet)
            this.controls.Get(label).Set.OnEvent('Click', HClickButtonSet)
        }

        ; Make an instance of `SomeClass` to use with the controls
        this.Instance := SomeClass()

        ; Get the bottom-right corner
        this.controls.Get(labels[-1]).Set.GetPos(&btnx, &btny, &btnw, &btnh)

        ; Show the gui
        g.Show('w' (btnx + btnw + g.MarginX) ' h' (btny + btnh + g.MarginY))

        ; The below functions allows us to get / set the properties of our example object using
        ; inputs from the gui. This example is basic and only supports text, but more complex
        ; logic is feasible.

        HClickButtonGet(Ctrl, *) {
            label := StrReplace(Ctrl.Name, 'BtnGet', '')
            this.controls.Get(label).Edit.Text := this.Instance.%label%
        }
        HClickButtonSet(Ctrl, *) {
            label := StrReplace(Ctrl.Name, 'BtnSet', '')
            this.Instance.%label% := this.controls.Get(label).Edit.Text
        }
    }
}


class SomeClass {
    __New() {
        this.Prop1 := this.Prop2 := this.Prop3 := 0
    }
    Prop1 {
        Get => this.__Prop1
        Set => this.__Prop1 := Value
    }
    Prop2 {
        Get => this.__Prop2
        Set => this.__Prop2 := Value
    }
    Prop3 {
        Get => this.__Prop3
        Set => this.__Prop3 := Value
    }
}
