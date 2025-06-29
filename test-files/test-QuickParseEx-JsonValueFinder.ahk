#SingleInstance force
#include ..\QuickParseEx.ahk

; try {
;     test()
;     OutputDebug('0`n')
; } catch Error as err {
;     OutputDebug(err.Message '`n' err.Extra '`n')
; }

test()

test() {
    finder := JsonValueFinder(, 'example.json')
    content := FileRead('example.json')
    if finder.PrototypeObject.Base.Content !== content {
        throw Error('Invalid content.', -1)
    }
    names := Map()
    positions := Map()
    pos := 1
    while RegExMatch(content, '(?<=[\r\n]`s`s`s`s")(?<name>[^"]+)', &Match, pos) {
        names.Set(Match['name'], 1)
        switch SubStr(content, Match.Pos + Match.Len + 3, 1) {
            case '[':
                pattern := '(\[(?:[^\][]++|(?-1))*\])'
            case '{':
                pattern := '(\{(?:[^}{]++|(?-1))*\})'
            default:
                pattern := '(?<=": ).+?(?:(?=,[\r\n])|(?=[\r\n]))'
        }
        if !RegExMatch(content, pattern, &MatchValue, Match.Pos + Match.Len) || MatchValue.Pos !== Match.Pos + Match.Len + 3 {
            throw Error('Unmatched bracket', -1, '{')
        }
        positions.Set(Match['name'], { Start: MatchValue.Pos, End: MatchValue.Pos + MatchValue.Len, Value: MatchValue, Name: Match })
        OutputDebug(Match['name'] '`n' MatchValue[0] '`n')
        pos := MatchValue.Pos + MatchValue.Len
    }
    finder(names)
    if finder.Names.Count {
        s := ''
        for name in finder {
            s .= name ', '
        }
        throw Error('One or more names were not found.', -1, SubStr(s, 1, -2))
    }
    if finder.Count !== positions.Count {
        throw Error('The number of items is invalid', -1, 'Actual: ' positions.Count '; result: ' finder.Count)
    }
    for name, item in finder {
        if !positions.Has(name) {
            throw Error('An invalid name was included', -1, name)
        }
        if item.Name !== name {
            throw Error('An item`'s name does not match the intended name.', -1, 'Intended name: ' name '; Item`'s name: ' item.Name)
        }
        control := positions.Get(name)
        if item.NameStart !== control.Name.Pos {
            throw Error('An item`'s ``NameStart`` property is incorrect.', -1, 'Actual: ' control.Name.Pos '; result: ' item.NameStart)
        }
        if item.NameEnd !== control.Name.Pos + control.Name.Len {
            throw Error('An item`'s ``NameEnd`` property is incorrect.', -1, 'Actual: ' (control.Name.Pos + control.Name.Len) '; result: ' item.NameEnd)
        }
        if item.NameLen !== control.Name.Len {
            throw Error('An item`'s ``NameLen`` property is incorrect.', -1, 'Actual: ' control.Name.Len '; result: ' item.NameLen)
        }
        if item.ValueStart !== control.Start {
            throw Error('An item`'s ``ValueStart`` property is incorrect.', -1, 'Actual: ' control.Start '; result: ' item.ValueStart)
        }
        if item.ValueEnd !== control.End {
            throw Error('An item`'s ``ValueEnd`` property is incorrect.', -1, 'Actual: ' control.End '; result: ' item.ValueEnd)
        }
        if item.ValueLen !== control.End - control.Start {
            throw Error('An item`'s ``ValueLen`` property is incorrect.', -1, 'Actual:`n' (control.End - control.Start) '`n`nResult:`n' item.ValueLen)
        }
        if item.Value !== control.Value[0] {
            throw Error('An item`'s ``Value`` property is incorrect.', -1, 'Actual:`n' control.Value[0] '`n`nResult:`n' item.Value)
        }
    }
}
