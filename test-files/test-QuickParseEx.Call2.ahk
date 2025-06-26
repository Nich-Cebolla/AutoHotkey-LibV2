
#include ..\QuickParseEx.ahk

content := FileRead('example.json')
; content := '{ "prop": ["\n", "\"", -5e-5 ], "prop2": { "prop2_1": 0.12, "prop2_2": null } }'

test()

test() {
    root := Map()
    root.CaseSense := false

    obj := QuickParseEx.Call2(root, ParseConstructorArray, ParseConstructorObject, ParseSetterArray, ParseSetterObject, , 'example.json')

    sleep 1
}

ParseConstructorObject(*) {
    return {}
}

ParseConstructorArray(*) {
    return []
}

ParseSetterObject(Obj, Stack, Match, MatchValue?, Value?) {
    if Stack.Length {
        Obj.DefineProp(Match['name'], { Value: Value ?? '' })
    } else {
        Obj.Set(Match['name'], Value ?? '')
    }
}

ParseSetterArray(Obj, Stack, Match, MatchValue?, Value?) {
    Obj.Push(Value ?? unset)
}
