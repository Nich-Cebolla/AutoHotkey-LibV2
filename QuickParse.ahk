/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/QuickParse.ahk
    Author: Nich-Cebolla
    License: MIT
*/

class QuickParse {
    static __New() {
        this.DeleteProp('__New')
        Comment := '/\*[\W\w]*?\*/|//.*'
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
                        '|'
                            Comment
                        ')'
                    '|'
                        Comment
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
                    '|'
                        Comment
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
    static Call(Str?, Path?, Encoding?, Root?, AsMap := false, MapCaseSense := false) {
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
