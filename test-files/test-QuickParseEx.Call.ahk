
#include ..\QuickParseEx.ahk

test()

test() {
    root := Map()
    root.CaseSense := false

    obj := QuickParseEx(root, ParseConstructorArray, ParseConstructorObject, ParseSetterArray, ParseSetterObject, , 'test-content-QuickParse.json')

    sleep 1
}

ParseConstructorObject(*) {
    return {}
}

ParseConstructorArray(*) {
    return []
}

ParseSetterObject(Obj, MatchName, Depth, Value?) {
    if Depth > 1 {
        Obj.DefineProp(MatchName['name'], { Value: Value ?? '' })
    } else {
        Obj.Set(MatchName['name'], Value ?? '')
    }
}

ParseSetterArray(Obj, Depth, Value?) {
    Obj.Push(Value ?? unset)
}
