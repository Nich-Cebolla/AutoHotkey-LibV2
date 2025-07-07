#include ..\PathObj.ahk

Obj := {
    Prop1: {
        NestedProp1: {
            NestedMap: Map(
                'Key1 `r`n"`t``', Map(
                    'Key2', 'Val1'
                )
            )
        }
      , NestedProp2: [ 1, 2, { Prop: 'Val' }, 4 ]
    }
}
; Get an instance of `PathObj`
Root := PathObj('Obj')
; Process the properties / items
O1 := Root.MakeProp('Prop1')
O2 := O1.MakeProp('NestedProp1')
O3 := O2.MakeProp('NestedMap')
O4 := O3.MakeItem('Key1 `r`n"`t``')
O5 := O4.MakeItem('Key2')

; Calling the object produces a path that will apply AHK escape sequences using the backtick as needed.
OutputDebug(O5() '`n') ; Obj.Prop1.NestedProp1.NestedMap["Key1 `r`n`"`t``"]["Key2"]

; You can start another branch
B1 := O1.MakeProp('NestedProp2')
B2 := B1.MakeItem(3)
B3 := B2.MakeProp('Prop')
OutputDebug(B3() '`n') ; Obj.Prop1.NestedProp2[3].Prop

; Some operations don't benefit from having the keys escaped. Save processing time by calling
; the "Unescaped" method.
OutputDebug(O5.Unescaped() '`n')
; Obj.Prop1.NestedProp1.NestedMap["Key1
; "	   `"]["Key2"]

; Normally you would use `PathObj` in some type of recursive loop.
Recurse(obj, PathObj('obj'))
Recurse(obj, path) {
    OutputDebug(path() '`n')
    for p, v in obj.OwnProps() {
        if IsObject(v) {
            Recurse(v, path.MakeProp(p))
        }
    }
    if HasMethod(obj, '__Enum') {
        for k, v in obj {
            if IsObject(v) {
                Recurse(v, path.MakeItem(k))
            }
        }
    }
}
