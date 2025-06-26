
#include ..\QuickParseEx.ahk

content := FileRead('example.json')
; content := '{ "prop": ["\n", "\"", -5e-5 ], "prop2": { "prop2_1": 0.12, "prop2_2": null } }'

test()

test() {
    obj := QuickParseEx.Find(ParseSetterArray, ParseSetterObject, , 'example.json')
    ; obj := QuickParseEx.Find(ParseSetterArray, ParseSetterObject, '{ "prop": ["\n", "\"", -5e-5 ], "prop2": { "prop2_1": 0.12, "prop2_2": null } }')

    sleep 1
}

ParseSetterArray(Stack, Pos, Match, MatchValue?) {
    global content
    ch := SubStr(content, pos, 1)
    if ch !== Match['char'] {
        OutputDebug('`n' ch ' !== ' Match['char'] '`n')
    }
    sleep 1
}

ParseSetterObject(Stack, Pos, Match, MatchValue?) {
    global content
    ch := SubStr(content, pos, 1)
    if ch !== Match['char'] {
        OutputDebug('`n' ch ' !== ' Match['char'] '`n')
    }
    sleep 1
}
