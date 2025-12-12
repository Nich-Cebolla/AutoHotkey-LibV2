
; tests the performance difference if the function includes a condition to check if a string contains
; a backslash in it, and if it does, to process the escape sequences.
; conclusion: about 4% slower with the test json. results will vary depending on number of escape
; sequences, but this is an acceptable performance loss imo.

test()



class test {
    static Call() {
        ; remove last curly bracket and whitespace
        str := RegExReplace(get(), '\s+\}\s*$', '')
        ; remove open curly bracket
        str2 := SubStr(str, 2)
        ; adjust property names to make it easier to insert numbers so the names are unique
        pos := 1
        while RegExMatch(str2, '\n    "[^"]+', &m, pos) {
            pos := m.Pos + m.Len
            str2 := StrReplace(str2, m[0], m[0] '%')
        }
        ; increase the size of the json
        loop 100 {
            str .= ',' StrReplace(str2, '%', '_' A_Index)
        }
        ; close the json
        str .= '`n}'

        ; add slight delay to avoid startup lag affecting the results

        SetTimer(_test, -5000)

        ; The test is repeated three times

        _test() {
            ProcessSetPriority('High')
            A_ListLines := 0
            Critical(-1)
            t1 := A_TickCount
            loop 100 {
                o := JsonCalloutExample(&str)
            }
            p1 := Round((A_TickCount - t1) / 1000, 3)

            t2 := A_TickCount
            loop 100 {
                JsonCalloutExample2(&str)
            }
            p2 := Round((A_TickCount - t2) / 1000, 3)

            t3 := A_TickCount
            loop 100 {
                JsonCalloutExample(&str)
            }
            p3 := Round((A_TickCount - t3) / 1000, 3)

            t4 := A_TickCount
            loop 100 {
                JsonCalloutExample2(&str)
            }
            p4 := Round((A_TickCount - t4) / 1000, 3)

            t5 := A_TickCount
            loop 100 {
                JsonCalloutExample(&str)
            }
            p5 := Round((A_TickCount - t5) / 1000, 3)

            t6 := A_TickCount
            loop 100 {
                JsonCalloutExample2(&str)
            }
            p6 := Round((A_TickCount - t6) / 1000, 3)

            f1 := Round((p1 + p3 + p5) / 3, 3)
            f2 := Round((p2 + p4 + p6) / 3, 3)

            MsgBox(p1 '`n' p3 '`n' p5 '`n`n' p2 '`n' p4 '`n' p6 '`n`n' f1 ' : ' f2 '`n' Round(f2 / f1, 3))
        }
    }
}

class JsonCalloutExample2 {
    static __New() {
        this.DeleteProp('__New')
        Next := '\s*+,?+\s*+'
        ArrayFalse := 'false\K(?CA)'
        ArrayNull := 'null\K(?CB)'
        ArrayNumber := '(-?+\d++(?:\.\d++)?(?:[eE][+-]?+\d++)?+)\K(?CC)'
        ArrayString := '"(.*?(?<!\\)(?:\\\\)*+)"\K(?CD)'
        ArrayTrue := 'true\K(?CE)'
        ObjectFalse := 'false\K(?CF)'
        ObjectNull := 'null\K(?CG)'
        ObjectNumber := '(-?+\d++(?:\.\d++)?+(?:[eE][+-]?+\d++)?)\K(?CH)'
        ObjectPropName := '"(.*?(?<!\\)(?:\\\\)*+)"\s*+:\s*+'
        ObjectString := '"(.*?(?<!\\)(?:\\\\)*+)"\K(?CI)'
        ObjectTrue := 'true\K(?CJ)'
        pObject := (
            '('
                '\{'
                '(*COMMIT)'
                '\s*+'
                '\K(?CK)'
                '(?:'
                    ObjectPropName
                    ''
                    '(?:'
                        ObjectString
                    '|'
                        ObjectNumber
                    '|'
                        '(?1)'
                    '|'
                        '(?5)'
                    '|'
                        ObjectFalse
                    '|'
                        ObjectNull
                    '|'
                        ObjectTrue
                    ')'
                    Next
                ')*+'
                '\}'
                '\K(?CL)'
            ')'
        )
        pArray := (
            '('
                '\['
                '(*COMMIT)'
                '\s*+'
                '\K(?CM)'
                '(?:'
                    '(?:'
                        ArrayString
                    '|'
                        ArrayNumber
                    '|'
                        '(?1)'
                    '|'
                        '(?5)'
                    '|'
                        ArrayFalse
                    '|'
                        ArrayNull
                    '|'
                        ArrayTrue
                    ')'
                    Next
                ')*+'
                '\]'
                '\K(?CL)'
            ')'
        )
        this.Pattern := 'S)' pObject '|' pArray
    }
    /**
     * @descrpition - Parses a JSON string into an AHK object. This parser is designed for simplicity and
     * speed.
     * - JSON objects are parsed into instances of either `Object` or `Map`, depending on the value of
     * the parameter `AsMap`.
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
     *
     * Only one of `Str` or `Path` are needed. If `Str` is set, `Path` is ignored. If both `Str` and
     * `Path` are unset, the clipboard's contents are used.
     * @class
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
    static Call(&Str?, Path?, Encoding?, Root?, AsMap := false, MapCaseSense := false) {
        local O
        if !IsSet(Str) {
            Str := IsSet(Path) ? FileRead(Path, Encoding ?? unset) : A_Clipboard
        }
        if AsMap {
            Q := MapCaseSense ? Map : _GetObj, F := F_1, G := G_1, H := H_1, I := I_1, J := J_1
        } else {
            Q := Object, F := F_2, G := G_2, H := H_2, I := I_2, J := J_2
        }
        K := K_1, M := M_1, P := ['']
        ; Used when unescaping json escape sequences.
        ch := 0xFFFD
        while InStr(Str, Chr(ch)) {
            ch++
        }
        ch := Chr(ch)
        if !RegExMatch(Str, this.Pattern) || P.Length {
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
                O.Push(StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(N[6], '\\', ch), '\n', '`n'), '\r', '`r'), '\"', '"'), '\t', '`t'), ch, '\'))
            } else {
                O.Push(N[6])
            }
        }
        E(*) {
            O.Push(1)
        }
        F_1(N, *) {
            O.Set(N[2], 0)
        }
        G_1(N, *) {
            O.Set(N[2], '')
        }
        H_1(N, *) {
            O.Set(N[2], Number(N[4]))
        }
        I_1(N, *) {
            if InStr(N[3], '\') {
                O.Set(N[2], StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(N[3], '\\', ch), '\n', '`n'), '\r', '`r'), '\"', '"'), '\t', '`t'), ch, '\'))
            } else {
                O.Set(N[2], N[3])
            }
        }
        J_1(N, *) {
            O.Set(N[2], 1)
        }
        F_2(N, *) {
            O.%N[2]% := 0
        }
        G_2(N, *) {
            O.%N[2]% := ''
        }
        H_2(N, *) {
            O.%N[2]% := Number(N[4])
        }
        I_2(N, *) {
            if InStr(N[3], '\') {
                O.%N[2]% := StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(N[3], '\\', ch), '\n', '`n'), '\r', '`r'), '\"', '"'), '\t', '`t'), ch, '\')
            } else {
                O.%N[2]% := N[3]
            }
        }
        J_2(N, *) {
            O.%N[2]% := 1
        }
        M_1(*) {
            if AsMap {
                K := K_2, M := M_2
            } else {
                K := K_3, M := M_3
            }
            if IsSet(Root) {
                O := Root
            } else {
                O := Root := Array()
            }
        }
        K_1(*) {
            if AsMap {
                K := K_2, M := M_2
            } else {
                K := K_3, M := M_3
            }
            if IsSet(Root) {
                O := Root
            } else {
                O := Root := Q()
            }
        }
        M_2(N, *) {
            P.Push(O), O := Array()
            if SubStr(P[-1].__Class, 1, 1) = 'A' {
                P[-1].Push(O)
            } else {
                P[-1].Set(N[2], O)
            }
        }
        K_2(N, *) {
            P.Push(O), O := Q()
            if SubStr(P[-1].__Class, 1, 1) = 'A' {
                P[-1].Push(O)
            } else {
                P[-1].Set(N[2], O)
            }
        }
        M_3(N, *) {
            P.Push(O), O := Array()
            if SubStr(P[-1].__Class, 1, 1) = 'A' {
                P[-1].Push(O)
            } else {
                P[-1].%N[2]% := O
            }
        }
        K_3(N, *) {
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
}

class JsonCalloutExample {
    static __New() {
        this.DeleteProp('__New')
        Next := '\s*+,?+\s*+'
        ArrayFalse := 'false\K(?CA)'
        ArrayNull := 'null\K(?CB)'
        ArrayNumber := '(-?+\d++(?:\.\d++)?(?:[eE][+-]?+\d++)?+)\K(?CC)'
        ArrayString := '"(.*?(?<!\\)(?:\\\\)*+)"\K(?CD)'
        ArrayTrue := 'true\K(?CE)'
        ObjectFalse := 'false\K(?CF)'
        ObjectNull := 'null\K(?CG)'
        ObjectNumber := '(-?+\d++(?:\.\d++)?+(?:[eE][+-]?+\d++)?)\K(?CH)'
        ObjectPropName := '"(.*?(?<!\\)(?:\\\\)*+)"\s*+:\s*+'
        ObjectString := '"(.*?(?<!\\)(?:\\\\)*+)"\K(?CI)'
        ObjectTrue := 'true\K(?CJ)'
        pObject := (
            '('
                '\{'
                '(*COMMIT)'
                '\s*+'
                '\K(?CK)'
                '(?:'
                    ObjectPropName
                    ''
                    '(?:'
                        ObjectString
                    '|'
                        ObjectNumber
                    '|'
                        '(?1)'
                    '|'
                        '(?5)'
                    '|'
                        ObjectFalse
                    '|'
                        ObjectNull
                    '|'
                        ObjectTrue
                    ')'
                    Next
                ')*+'
                '\}'
                '\K(?CL)'
            ')'
        )
        pArray := (
            '('
                '\['
                '(*COMMIT)'
                '\s*+'
                '\K(?CM)'
                '(?:'
                    '(?:'
                        ArrayString
                    '|'
                        ArrayNumber
                    '|'
                        '(?1)'
                    '|'
                        '(?5)'
                    '|'
                        ArrayFalse
                    '|'
                        ArrayNull
                    '|'
                        ArrayTrue
                    ')'
                    Next
                ')*+'
                '\]'
                '\K(?CL)'
            ')'
        )
        this.Pattern := 'S)' pObject '|' pArray
    }
    /**
     * @descrpition - Parses a JSON string into an AHK object. This parser is designed for simplicity and
     * speed.
     * - JSON objects are parsed into instances of either `Object` or `Map`, depending on the value of
     * the parameter `AsMap`.
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
     *
     * Only one of `Str` or `Path` are needed. If `Str` is set, `Path` is ignored. If both `Str` and
     * `Path` are unset, the clipboard's contents are used.
     * @class
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
    static Call(&Str?, Path?, Encoding?, Root?, AsMap := false, MapCaseSense := false) {
        local O
        if !IsSet(Str) {
            Str := IsSet(Path) ? FileRead(Path, Encoding ?? unset) : A_Clipboard
        }
        if AsMap {
            Q := MapCaseSense ? Map : _GetObj, F := F_1, G := G_1, H := H_1, I := I_1, J := J_1
        } else {
            Q := Object, F := F_2, G := G_2, H := H_2, I := I_2, J := J_2
        }
        K := K_1, M := M_1, P := ['']
        if !RegExMatch(Str, this.Pattern) || P.Length {
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
            O.Push(N[6])
        }
        E(*) {
            O.Push(1)
        }
        F_1(N, *) {
            O.Set(N[2], 0)
        }
        G_1(N, *) {
            O.Set(N[2], '')
        }
        H_1(N, *) {
            O.Set(N[2], Number(N[4]))
        }
        I_1(N, *) {
            O.Set(N[2], N[3])
        }
        J_1(N, *) {
            O.Set(N[2], 1)
        }
        F_2(N, *) {
            O.%N[2]% := 0
        }
        G_2(N, *) {
            O.%N[2]% := ''
        }
        H_2(N, *) {
            O.%N[2]% := Number(N[4])
        }
        I_2(N, *) {
            O.%N[2]% := N[3]
        }
        J_2(N, *) {
            O.%N[2]% := 1
        }
        M_1(*) {
            if AsMap {
                K := K_2, M := M_2
            } else {
                K := K_3, M := M_3
            }
            if IsSet(Root) {
                O := Root
            } else {
                O := Root := Array()
            }
        }
        K_1(*) {
            if AsMap {
                K := K_2, M := M_2
            } else {
                K := K_3, M := M_3
            }
            if IsSet(Root) {
                O := Root
            } else {
                O := Root := Q()
            }
        }
        M_2(N, *) {
            P.Push(O), O := Array()
            if SubStr(P[-1].__Class, 1, 1) = 'A' {
                P[-1].Push(O)
            } else {
                P[-1].Set(N[2], O)
            }
        }
        K_2(N, *) {
            P.Push(O), O := Q()
            if SubStr(P[-1].__Class, 1, 1) = 'A' {
                P[-1].Push(O)
            } else {
                P[-1].Set(N[2], O)
            }
        }
        M_3(N, *) {
            P.Push(O), O := Array()
            if SubStr(P[-1].__Class, 1, 1) = 'A' {
                P[-1].Push(O)
            } else {
                P[-1].%N[2]% := O
            }
        }
        K_3(N, *) {
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
}

get() => '
(
{
    "__Test": ["\r", "\n", "\t", "\"", "\\", "", -1000, -5e-5, 0.12, null, true, false ],
    "A_Array": [
        [
            [
                "AAA\u0FFC"
            ],
            [
                [
                    "AAM",
                    "AAM\u0FFC"
                ]
            ],
            {
                "AAO": "AAO\u0FFC"
            }
        ],
        [
            [
                "AM1",
                [
                    "AMA"
                ]
            ],
            [
                "AM2",
                [
                    [
                        "AMM",
                        "AMM"
                    ]
                ]
            ],
            [
                "AM3",
                {
                    "AMO": "AMO"
                }
            ]
        ],
        {
            "AO1": [
                "AOA",
                1
            ],
            "AO2": [
                [
                    "AOM1",
                    "AOM"
                ],
                [
                    "AOM2",
                    0
                ]
            ],
            "AO3": {
                "AOO1": "AOO",
                "AOO2": ""
            }
        }
    ],
    "A_Condense": [
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        8,
        [
            9,
            10,
            11,
            12,
            13,
            14,
            {
                "Prop": "Value",
                "Prop2": [
                    "Value1",
                    "Value2",
                    "Value3",
                    "Value4"
                ]
            }
        ]
    ],
    "M_Map": [
        [
            "M1",
            [
                [
                    "MAA"
                ],
                [
                    [
                        "MAM",
                        "MAM"
                    ]
                ],
                {
                    "MAO": "MAO"
                }
            ]
        ],
        [
            "M2",
            [
                [
                    "MM1",
                    [
                        "MMA"
                    ]
                ],
                [
                    "MM2",
                    [
                        [
                            "MMM",
                            "MMM"
                        ]
                    ]
                ],
                [
                    "MM3",
                    {
                        "MMO": "MMO"
                    }
                ]
            ]
        ],
        [
            "M3",
            {
                "MO1": [
                    "MOA"
                ],
                "MO2": [
                    [
                        "MOM",
                        "MOM"
                    ]
                ],
                "MO3": {
                    "MOO": "MOO"
                }
            }
        ]
    ],
    "O_Object": {
        "O1": [
            [
                "OAA"
            ],
            [
                [
                    "OAM",
                    "OAM"
                ]
            ],
            {
                "OAO": "OAO"
            }
        ],
        "O2": [
            [
                "OM1",
                [
                    "OMA"
                ]
            ],
            [
                "OM2",
                [
                    [
                        "OMM",
                        "OMM"
                    ]
                ]
            ],
            [
                "OM3",
                {
                    "OMO": "OMO"
                }
            ]
        ],
        "O3": {
            "OO1": [
                "OOA"
            ],
            "OO2": [
                [
                    "OOM",
                    "OOM"
                ]
            ],
            "OO3": {
                "OOO": "OOO"
            }
        }
    },
    "String": "\\\r\\\n\\\t\\\"\\",
    "Number1": 100000,
    "Number2": -100000,
    "Number3": 5e5,
    "Number4": 5e-5,
    "Number5": -5E5,
    "Number6": -0.12E-2,
    "Number7": 10.10,
    "False": false,
    "Null": null,
    "True": true,
    "Object1": {},
    "Object2": { "arr": [] },
    "Object3": { "arr": [{}] },
    "Object4": { "arr": [{},[]] },
    "Object5": { "obj": {} },
    "Array1": [],
    "Array2": [{}],
    "Array3": [[]],
    "Array4": [[],{}],
    "Array5": [[[]],{ "arr": [[ { "nestedProp": "nestedVal" } ]] }]
}
)'
