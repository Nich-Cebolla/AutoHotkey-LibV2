
#include ..\QuickParseEx.ahk

test1()
test2()
test3()


test1() {
    global content := FileRead('example.json')
    obj := QuickParseEx.Find(ParseFindArray, ParseFindObject, ParseFindCloseArray, ParseFindCloseObject, , 'example.json')
    sleep 1
}

test2() {
    global content := '{ "prop": ["\n", "\"", -5e-5 ], "prop2": { "prop2_1": 0.12, "prop2_2": null }, "prop3": {}, "prop4": [], "prop5": "string", "prop6": -1000 }'
    obj := QuickParseEx.Find(ParseFindArray, ParseFindObject, ParseFindCloseArray, ParseFindCloseObject, content)
    sleep 1
}

test3() {
    content := '{ "prop": ["\n", "\"", -5e-5 ], "prop2": { "prop2_1": 0.12, "prop2_2": null } }'
    obj := QuickParseEx.Find(ParseFindArray, ParseFindObject, ParseFindCloseArray, ParseFindCloseObject, content)
    sleep 1
}

; test3() {
;     content := '{ "prop": ["\n", "\"", -5e-5 ], "prop2": { "prop2_1": 0.12, "prop2_2": null } }'
;     script := FileRead('..\QuickParseEx.ahk')
;     pos := 1
;     values := []
;     StrReplace(script, '* - 1. Callback', , , &count)
;     if count > 1 || !count {
;         throw Error('The test function needs adjusted.', -1)
;     }
;     start := InStr(script, '* - 1. Callback')
;     if !RegExMatch(script, '(?<segment>\* *- 3rd parameter:.+)\R[ \t]*\* @param', &Match) {
;         throw Error('The test function needs adjusted.', -1)
;     }
;     end := Match.Pos + Match.Len['segment']
;     segment := SubStr(script, start, end - start)
;     for line in StrSplit(segment, '`n', '`r`s`t*') {
;         if RegExMatch(line, 'i)- (?<n>\d+)\. (?<fn>Callback[^:]+)', &Match) {
;             values.Push({ Function: Match['fn'] })
;         } else if RegExMatch(line, '1st.+?Stack\.Length == (?<n>\d+)', &Match) {
;             values[-1].First := Match['n']
;         } else if RegExMatch(line, '2nd.+?(?<n>\d+)', &Match) {
;             values[-1].Second := Match['n']
;         } else if RegExMatch(line, 'i)3rd.+') {
;             values[-1].Third := {}
;             if InStr(line, '"value"') {
;                 if !RegExMatch(line, '"value" = "(?<value>.+?)";', &Match) {
;                     throw Error('Failed to match with value subcapture group example', -1, line)
;                 }
;                 values[-1].Third.value := Match['value']
;             }
;             if InStr(line, '"name"') {
;                 if !RegExMatch(line, '"name" = "(?<name>.+?)";', &Match) {
;                     throw Error('Failed to match with name subcapture group example', -1, line)
;                 }
;                 values[-1].Third.name := Match['name']
;             }
;             if !RegExMatch(line, '"char" = "(?<char>.+?)"$', &Match) {
;                 throw Error('Failed to match with char subcapture group example', -1, line)
;             }
;             values[-1].Third.char := StrReplace(Match['char'], '``"', '"')
;         } else if RegExMatch(line, '4th.+') {
;             switch values.Length {
;                 case 1: values[-1].Fourth := ''
;                 case 2: values[-1].Fourth := { value: '\n', char: ',' }
;                 case 3: values[-1].Fourth := { value: '\"', char: ',' }
;                 case 4: values[-1].Fourth := { value: '-5e-5', char: ']' }
;                 case 6: values[-1].Fourth := { char: '"', mark: 1 }
;                 case 7: values[-1].Fourth := { value: '0.12', char: ',' }
;                 case 8: values[-1].Fourth := { value: 'null', char: '}' }
;                 default: throw Error('Unexpected values.Length', -1, values.Length)
;             }
;         }
;     }
;     i := 0
;     obj := QuickParseEx.Find(CallbackArray, CallbackObject, CallbackCloseArray, CallbackCloseObject, '{ "prop": ["\n", "\"", -5e-5 ], "prop2": { "prop2_1": 0.12, "prop2_2": null } }')
;     sleep 1


;     CallbackArray(Controller, Stack, Pos, Match, MatchValue?) {
;         i++
;         value := values[i]
;         _Check(A_ThisFunc, value, Stack, Pos, Match)
;         if !value.HasOwnProp('Fourth') {
;             throw Error('Missing ``Fourth`` property.', -1)
;         }
;         fourth := value.Fourth
;         if IsSet(MatchValue) {
;             _CheckMatchValue(fourth, MatchValue)
;         } else {
;             if fourth {
;                 throw Error('Invalid ``Fourth`` property.', -1, fourth)
;             }
;         }
;     }

;     CallbackObject(Controller, Stack, Pos, Match, MatchValue?) {
;         i++
;         value := values[i]
;         _Check(A_ThisFunc, value, Stack, Pos, Match)
;         if !value.HasOwnProp('Fourth') {
;             throw Error('Missing ``Fourth`` property.', -1)
;         }
;         fourth := value.Fourth
;         if IsSet(MatchValue) {
;             _CheckMatchValue(fourth, MatchValue)
;         } else {
;             if fourth {
;                 throw Error('Invalid ``Fourth`` property.', -1, fourth)
;             }
;         }
;     }

;     CallbackCloseArray(Controller, Stack, Pos, Match) {
;         i++
;         value := values[i]
;         _Check(A_ThisFunc, value, Stack, Pos, Match)
;     }

;     CallbackCloseObject(Controller, Stack, Pos, Match) {
;         i++
;         value := values[i]
;         _Check(A_ThisFunc, value, Stack, Pos, Match)
;     }

;     _Check(Function, value, Stack, Pos, Match) {
;         if Function !== value.Function {
;             throw Error('Invalid function.', -1, value.Function)
;         }
;         if value.First != Stack.Length {
;             throw Error('Invalid depth.', -1, value.First)
;         }
;         if value.Second != Pos {
;             throw Error('Invalid pos.', -1, value.Second)
;         }
;         if value.Third.HasOwnProp('value') && Match['value'] != value.Third.value {
;             throw Error('Invalid third-value.', -1, value.Third.value)
;         }
;         if value.Third.HasOwnProp('name') && Match['name'] != value.Third.name {
;             throw Error('Invalid third-name.', -1, value.Third.name)
;         }
;         if Match['char'] != value.Third.char {
;             throw Error('Invalid third-char.', -1, value.Third.char)
;         }
;     }
;     _CheckMatchValue(fourth, MatchValue) {
;         if MatchValue.Mark {
;             if !fourth.HasOwnProp('mark') {
;                 throw Error('Missing ``mark`` property.', -1)
;             }
;         } else {
;             if MatchValue['value'] != fourth.value {
;                 throw Error('Invalid ``fourth.value`` value.', -1, fourth.value)
;             }
;         }
;         if MatchValue['char'] != fourth.char {
;             throw Error('Invalid ``fourth.char`` value.', -1, fourth.char)
;         }
;     }
; }

ParseFindArray(Controller, Stack, Pos, Match, MatchValue?) {
    global content
    ch := SubStr(content, pos, 1)
    if ch !== Match['char'] {
        OutputDebug('`n' ch ' !== ' Match['char'] '`n')
    }
    sleep 1
}

ParseFindObject(Controller, Stack, Pos, Match, MatchValue?) {
    global content
    ch := SubStr(content, pos, 1)
    if ch !== Match['char'] {
        OutputDebug('`n' ch ' !== ' Match['char'] '`n')
    }
    sleep 1
}

ParseFindCloseArray(Controller, Stack, Pos) {
    global content
    sleep 1
}

ParseFindCloseObject(Controller, Stack, Pos) {
    global content
    sleep 1
}
