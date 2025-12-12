/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/QuickParse.ahk
    Author: Nich-Cebolla
    License: MIT
*/

/**
 * @descrpition - Parses a JSON string into an AHK object. This parser is designed for simplicity
 * and speed.
 * - JSON objects are parsed into instances of either `Object` or `Map`, depending on the value of
 *   the parameter `AsMap`.
 * - JSON arrays are parsed into instances of `Array`.
 * - `false` is represented as `0`.
 * - `true` is represented as `1`.
 * - For arrays, `null` JSON values cause `QuickParse` to call `Obj.Push(unset)` where `Obj` is the
 *   active object being constructed at that time.
 * - For objects, `null` JSON values cause `QuickParse` to set the property with an empty string
 *   value.
 * - Unquoted numeric values are processed through `Number()` before setting the value.
 * - Quoted numbers are processed as strings.
 * - Escape sequences are un-escaped and external quotations are removed from JSON string values.
 * - The function supports JSON with comments.
 *
 * Only one of `Str` or `Path` are needed. If `Str` is set, `Path` is ignored. If both `Str` and
 * `Path` are unset, the clipboard's contents are used.
 *
 * @param {String} [Str] - The string to parse.
 * @param {String} [Path] - The path to the file that contains the JSON content to parse.
 * @param {String} [Encoding] - The file encoding to use if calling `QuickParse` with `Path`.
 * @param {*} [Root] - If set, the root object onto which properties are assigned will be
 * `Root`, and `QuickParse` will return the modified `Root` at the end of the function.
 * - If `AsMap` is true and the first open bracket in the JSON string is a curly bracket, `Root`
 *   must have a method `Set`.
 * - If the first open bracket in the JSON string is a square bracket, `Root` must have methods
 *   `Push`.
 * @param {Boolean} [AsMap = false] - If true, JSON objects are converted into AHK `Map` objects.
 * @param {Boolean} [MapCaseSense = false] - The value set to the `MapObj.CaseSense` property.
 * `MapCaseSense` is ignored when `AsMap` is false.
 * @returns {*}
 */
QuickParse(Str?, Path?, Encoding?, Root?, AsMap := false, MapCaseSense := false) {
    local O
    if !IsSet(Str) {
        Str := IsSet(Path) ? FileRead(Path, Encoding ?? unset) : A_Clipboard
    }
    if AsMap {
        Q := MapCaseSense ? Map : _GetObj, F := F1, G := G1, H := H1, I := I1, J := J1
    } else {
        Q := Object, F := F2, G := G2, H := H2, I := I2, J := J2
    }
    K := K1, M := M1, P := ['']
    ; Used when unescaping json escape sequences.
    R := 0xFFFD
    while InStr(Str, Chr(R)) {
        R++
    }
    R := Chr(R)
    if !RegExMatch(Str, 'S)(\{(*COMMIT)\s*+\K(?CK)(?:(?:"(.*?(?<!\\)(?:\\\\)*+)"\s*+:\s*+(?:"(.*?'
    '(?<!\\)(?:\\\\)*+)"\K(?CI)|(-?+\d++(?:\.\d++)?+(?:[eE][+-]?+\d++)?)\K(?CH)|(?1)|(?5)|false\K'
    '(?CF)|null\K(?CG)|true\K(?CJ)|/\*[\W\w]*?\*/|//.*)|/\*[\W\w]*?\*/|//.*)\s*+,?+\s*+)*+\}\K'
    '(?CL))|(\[(*COMMIT)\s*+\K(?CM)(?:(?:"(.*?(?<!\\)(?:\\\\)*+)"\K(?CD)|(-?+\d++(?:\.\d++)?'
    '(?:[eE][+-]?+\d++)?+)\K(?CC)|(?1)|(?5)|false\K(?CA)|null\K(?CB)|true\K(?CE)|/\*[\W\w]*?\*/|'
    '//.*)\s*+,?+\s*+)*+\]\K(?CL))') || P.Length {
        throw Error('Invalid json.')
    }

    return Root

    _GetObj() {
        local m := Map()
        m.CaseSense := false
        return m
    }
    A(*) {
        O.Push(0)
    }
    B(*) {
        O.Push(unset)
    }
    C(N, *) {
        O.Push(Number(N[7]))
    }
    D(N, *) {
        if InStr(N[6], '\') {
            O.Push(StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(N[6], '\\', R), '\n', '`n'), '\r', '`r'), '\"', '"'), '\t', '`t'), R, '\'))
        } else {
            O.Push(N[6])
        }
    }
    E(*) {
        O.Push(1)
    }
    F1(N, *) {
        O.Set(N[2], 0)
    }
    G1(N, *) {
        O.Set(N[2], '')
    }
    H1(N, *) {
        O.Set(N[2], Number(N[4]))
    }
    I1(N, *) {
        if InStr(N[3], '\') {
            O.Set(N[2], StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(N[3], '\\', R), '\n', '`n'), '\r', '`r'), '\"', '"'), '\t', '`t'), R, '\'))
        } else {
            O.Set(N[2], N[3])
        }
    }
    J1(N, *) {
        O.Set(N[2], 1)
    }
    F2(N, *) {
        O.%N[2]% := 0
    }
    G2(N, *) {
        O.%N[2]% := ''
    }
    H2(N, *) {
        O.%N[2]% := Number(N[4])
    }
    I2(N, *) {
        if InStr(N[3], '\') {
            O.%N[2]% := StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(N[3], '\\', R), '\n', '`n'), '\r', '`r'), '\"', '"'), '\t', '`t'), R, '\')
        } else {
            O.%N[2]% := N[3]
        }
    }
    J2(N, *) {
        O.%N[2]% := 1
    }
    M1(*) {
        if AsMap {
            K := K2, M := M2
        } else {
            K := K3, M := M3
        }
        if IsSet(Root) {
            O := Root
        } else {
            O := Root := Array()
        }
    }
    K1(*) {
        if AsMap {
            K := K2, M := M2
        } else {
            K := K3, M := M3
        }
        if IsSet(Root) {
            O := Root
        } else {
            O := Root := Q()
        }
    }
    M2(N, *) {
        P.Push(O), O := Array()
        if SubStr(P[-1].__Class, 1, 1) = 'A' {
            P[-1].Push(O)
        } else {
            P[-1].Set(N[2], O)
        }
    }
    K2(N, *) {
        P.Push(O), O := Q()
        if SubStr(P[-1].__Class, 1, 1) = 'A' {
            P[-1].Push(O)
        } else {
            P[-1].Set(N[2], O)
        }
    }
    M3(N, *) {
        P.Push(O), O := Array()
        if SubStr(P[-1].__Class, 1, 1) = 'A' {
            P[-1].Push(O)
        } else {
            P[-1].%N[2]% := O
        }
    }
    K3(N, *) {
        P.Push(O), O := Q()
        if SubStr(P[-1].__Class, 1, 1) = 'A' {
            P[-1].Push(O)
        } else {
            P[-1].%N[2]% := O
        }
    }
    L(*) {
        O := P.Pop()
    }
}
