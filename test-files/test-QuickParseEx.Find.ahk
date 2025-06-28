
#include ..\QuickParseEx.ahk

content := FileRead('example.json')
; content := '{ "prop": ["\n", "\"", -5e-5 ], "prop2": { "prop2_1": 0.12, "prop2_2": null }, "prop3": {}, "prop4": [], "prop5": "string", "prop6": -1000 }'
; content := '{ "prop": ["\n", "\"", -5e-5 ], "prop2": { "prop2_1": 0.12, "prop2_2": null } }'

test()

test() {
    obj := QuickParseEx.Find(ParseFindArray, ParseFindObject, ParseFindCloseArray, ParseFindCloseObject, , 'example.json')
    ; obj := QuickParseEx.Find(ParseFindArray, ParseFindObject, ParseFindCloseArray, ParseFindCloseObject, '{ "prop": ["\n", "\"", -5e-5 ], "prop2": { "prop2_1": 0.12, "prop2_2": null }, "prop3": {}, "prop4": [], "prop5": "string", "prop6": -1000 }')
    ; obj := QuickParseEx.Find(ParseFindArray, ParseFindObject, ParseFindCloseArray, ParseFindCloseObject, '{ "prop": ["\n", "\"", -5e-5 ], "prop2": { "prop2_1": 0.12, "prop2_2": null } }')

    sleep 1
}

ParseFindArray(Stack, Pos, Match, MatchValue?) {
    global content
    ch := SubStr(content, pos, 1)
    if ch !== Match['char'] {
        OutputDebug('`n' ch ' !== ' Match['char'] '`n')
    }
    sleep 1
}

ParseFindObject(Stack, Pos, Match, MatchValue?) {
    global content
    ch := SubStr(content, pos, 1)
    if ch !== Match['char'] {
        OutputDebug('`n' ch ' !== ' Match['char'] '`n')
    }
    sleep 1
}

ParseFindCloseArray(Stack, Pos, Match) {
    global content
    ch := SubStr(content, pos, 1)
    if ch !== Match['char'] {
        OutputDebug('`n' ch ' !== ' Match['char'] '`n')
    }
    sleep 1
}

ParseFindCloseObject(Stack, Pos, Match) {
    global content
    ch := SubStr(content, pos, 1)
    if ch !== Match['char'] {
        OutputDebug('`n' ch ' !== ' Match['char'] '`n')
    }
    sleep 1
}
