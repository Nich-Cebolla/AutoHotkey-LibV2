/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/QuickParse.ahk
    Author: Nich-Cebolla
    Version: 1.0.4
    License: MIT
*/

/**
 * @classdesc - Parses a JSON string into an AHK object. This parser is designed for simplicity and
 * speed.
 * - JSON objects are parsed into instances of either `Object` or `Map`, depending on the value of
 * the parameter `AsMap`.
 * - JSON arrays are parsed into instances of `Array`.
 * - `false` is represented as `0`.
 * - `true` is represented as `1`.
 * - For arrays, `null` JSON values cause `QuickParse` to call `Obj.Push(unset)` where `Obj` is the
 * active object being constructed at that time.
 * - For objects, `null` JSON values cause `QuickParse` to set the property with an empty string value.
 * - Unquoted numeric values are processed through `Number()` before setting the value.
 * - Quoted numbers are processed as strings.
 * - Escape sequences are un-escaped and external quotations are removed from JSON string values.
 */
class QuickParse {
    /**
     * Only one of `Str` or `Path` are needed. If `Str` is set, `Path` is ignored. If both `Str`
     * and `Path` are unset, the clipboard's contents are used.
     * @param {String} [Str] - The string to parse.
     * @param {String} [Path] - The path to the file that contains the JSON content to parse.
     * @param {String} [Encoding] - The file encoding to use if calling `QuickParse` with `Path`.
     * @param {*} [Root] - If set, the root object onto which properties are assigned will be
     * `Root`, and `QuickParse` will return the modified `Root` at the end of the function.
     * - If `AsMap` is true and the first open bracket in the JSON string is a curly bracket, `Root`
     * must have a method `Set`.
     * - If the first open bracket in the JSON string is a square bracket, `Root` must have methods
     * `Push` and `Pop`.
     * @param {Boolean} [AsMap = false] - If true, JSON objects are converted into AHK `Map` objects.
     * @param {Boolean} [MapCaseSense = false] - The value set to the `MapObj.CaseSense` property.
     * `MapCaseSense` is ignored when `AsMap` is false.
     * @returns {Object|Array}
     */
    static Call(Str?, Path?, Encoding?, Root?, AsMap := false, MapCaseSense := false) {
        ;@region Initialization
        static ArrayItem := QuickParse.Patterns.ArrayItem
        , ObjectPropName := QuickParse.Patterns.ObjectPropName
        , ArrayNumber := QuickParse.Patterns.ArrayNumber
        , ArrayString := QuickParse.Patterns.ArrayString
        , ArrayFalse := QuickParse.Patterns.ArrayFalse
        , ArrayTrue := QuickParse.Patterns.ArrayTrue
        , ArrayNull := QuickParse.Patterns.ArrayNull
        , ArrayNextChar := QuickParse.Patterns.ArrayNextChar
        , ObjectNumber := QuickParse.Patterns.ObjectNumber
        , ObjectString := QuickParse.Patterns.ObjectString
        , ObjectFalse := QuickParse.Patterns.ObjectFalse
        , ObjectTrue := QuickParse.Patterns.ObjectTrue
        , ObjectNull := QuickParse.Patterns.ObjectNull
        , ObjectNextChar := QuickParse.Patterns.ObjectNextChar

        if !IsSet(Str) {
            If IsSet(Path) {
                Str := FileRead(Path, Encoding ?? unset)
            } else {
                Str := A_Clipboard
            }
        }

        if AsMap {
            CallbackConstructorObject := MapCaseSense ? Map : _GetObj
            CallbackSetterObject := _SetProp1
        } else {
            CallbackConstructorObject := Object
            CallbackSetterObject := _SetProp2
        }

        if !RegExMatch(Str, '\[|\{', &Match) {
            throw Error('Missing open bracket.', -1)
        }

        Pos := Match.Pos + 1

        if IsSet(Root) {
            if Match[0] == '[' {
                if !HasMethod(Root, 'Push') || !HasMethod(Root, 'Pop') {
                    throw ValueError('The value passed to the ``Root`` parameter is required to have'
                        ' methods ``Push`` and ``Pop`` when the opening bracket in the JSON is a square'
                        ' bracket.', -1)
                }
                Pattern := ArrayItem
            } else {
                if AsMap && !HasMethod(Root, 'Set') {
                    throw ValueError('The value passed to the ``Root`` parameter is required to have'
                        ' a ``Set`` method when ``AsMap`` is true.', -1)
                }
                Pattern := ObjectPropName
            }
        } else if Match[0] == '[' {
            Root := []
            Pattern := ArrayItem
        } else {
            Root := CallbackConstructorObject()
            Pattern := ObjectPropName
        }

        Controller := { Obj: Root, __Handler: (*) => '' }
        Stack := ['']
        Obj := Root
        ; Used when unescaping json escape sequences.
        ch := 0xFFFD
        while InStr(Str, Chr(ch)) {
            ch++
        }
        ch := Chr(ch)
        ;@endregion

        while RegExMatch(Str, Pattern, &Match, Pos) {
            continue
        }

        return Root

        ;@region Array Callbacks
        OnQuoteArray(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ArrayString, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                _Throw(1, Pos)
            }
            if InStr(MatchValue['value'], '\') {
                Obj.Push(StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(MatchValue['value'], '\\', ch), '\n', '`n'), '\r', '`r'), '\"', '"'), '\t', '`t'), ch, '\'))
            } else if MatchValue['value'] !== '""' {
                Obj.Push(MatchValue['value'])
            } else {
                Obj.Push('')
            }
            _PrepareNextArr(MatchValue)
        }
        OnSquareOpenArray(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len
            _obj := []
            Obj.Push(_obj)
            if Match['close'] {
                _GetContextArray()
            } else {
                Controller.__Handler := _GetContextArray
                Stack.Push(Controller)
                Obj := _obj
                Controller := { Obj: Obj }
            }
        }
        OnCurlyOpenArray(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len
            _obj := CallbackConstructorObject()
            Obj.Push(_obj)
            if Match['close'] {
                _GetContextArray()
            } else {
                Controller.__Handler := _GetContextArray
                Stack.Push(Controller)
                Obj := _obj
                Controller := { Obj: Obj }
                Pattern := ObjectPropName
            }
        }
        OnFalseArray(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ArrayFalse, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                _Throw(1, Pos)
            }
            Obj.Push(0)
            _PrepareNextArr(MatchValue)
        }
        OnTrueArray(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ArrayTrue, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                _Throw(1, Pos)
            }
            Obj.Push(1)
            _PrepareNextArr(MatchValue)
        }
        OnNullArray(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ArrayNull, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                _Throw(1, Pos)
            }
            Obj.Push(unset)
            _PrepareNextArr(MatchValue)
        }
        OnNumberArray(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ArrayNumber, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                _Throw(1, Match.Pos)
            }
            Obj.Push(Number(MatchValue['value']))
            _PrepareNextArr(MatchValue)
        }
        ;@endregion

        ;@region Object Callbacks
        OnQuoteObject(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ObjectString, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                _Throw(1, Pos)
            }
            if InStr(MatchValue['value'], '\') {
                CallbackSetterObject(Match, StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(MatchValue['value'], '\\', ch), '\n', '`n'), '\r', '`r'), '\"', '"'), '\t', '`t'), ch, '\'))
            } else if MatchValue['value'] && MatchValue['value'] !== '""' {
                CallbackSetterObject(Match, MatchValue['value'])
            } else {
                CallbackSetterObject(Match, '')
            }
            _PrepareNextObj(MatchValue)
        }
        OnSquareOpenObject(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len
            _obj := []
            CallbackSetterObject(Match, _obj)
            if Match['close'] {
                _GetContextObject()
            } else {
                Controller.__Handler := _GetContextObject
                Stack.Push(Controller)
                Obj := _obj
                Controller := { Obj: Obj }
                Pattern := ArrayItem
            }
        }
        OnCurlyOpenObject(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len
            _obj :=  CallbackConstructorObject()
            CallbackSetterObject(Match, _obj)
            if Match['close'] {
                _GetContextObject()
            } else {
                Controller.__Handler := _GetContextObject
                Stack.Push(Controller)
                Obj := _obj
                Controller := { Obj: Obj }
            }
        }
        OnFalseObject(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ObjectFalse, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                _Throw(1, Pos)
            }
            CallbackSetterObject(Match, 0)
            _PrepareNextObj(MatchValue)
        }
        OnTrueObject(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ObjectTrue, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                _Throw(1, Pos)
            }
            CallbackSetterObject(Match, 1)
            _PrepareNextObj(MatchValue)
        }
        OnNullObject(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ObjectNull, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                _Throw(1, Pos)
            }
            CallbackSetterObject(Match, '')
            _PrepareNextObj(MatchValue)
        }
        OnNumberObject(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ObjectNumber, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                _Throw(1, Match.Pos)
            }
            CallbackSetterObject(Match, Number(MatchValue['value']))
            _PrepareNextObj(MatchValue)
        }
        ;@endregion

        ;@region Helper Funcs
        _GetContextArray() {
            if !RegExMatch(Str, ArrayNextChar, &MatchCheck, Pos) || MatchCheck.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := MatchCheck.Pos + MatchCheck.Len
            if MatchCheck['char'] == ']' {
                Controller := Stack.Pop()
                if !Controller {
                    return
                }
                Obj := Controller.Obj
                Controller.__Handler.Call()
            } else {
                Pattern := ArrayItem
            }
        }
        _GetContextObject() {
            if !RegExMatch(Str, ObjectNextChar, &MatchCheck, Pos) || MatchCheck.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := MatchCheck.Pos + MatchCheck.Len
            if MatchCheck['char'] == '}' {
                Controller := Stack.Pop()
                if !Controller {
                    return
                }
                Obj := Controller.Obj
                Controller.__Handler.Call()
            } else {
                Pattern := ObjectPropName
            }
        }
        _GetObj() {
            m := Map()
            m.CaseSense := false
            return m
        }
        _PrepareNextArr(MatchValue) {
            Pos := MatchValue.Pos + MatchValue.Len
            if MatchValue['char'] == ']' {
                Controller := Stack.Pop()
                if !Controller {
                    return
                }
                Obj := Controller.Obj
                Controller.__Handler.Call()
            }
        }
        _PrepareNextObj(MatchValue) {
            Pos := MatchValue.Pos + MatchValue.Len
            if MatchValue['char'] == '}' {
                Controller := Stack.Pop()
                if !Controller {
                    return
                }
                Obj := Controller.Obj
                Controller.__Handler.Call()
            }
        }
        _SetProp1(MatchName, Value) {
            Obj.Set(MatchName['name'], Value)
        }
        _SetProp2(MatchName, Value) {
            Obj.DefineProp(MatchName['name'], { Value: Value })
        }
        _Throw(Code, Extra?, n := -2) {
            switch Code, 0 {
                case '1': throw Error('There is an error in the JSON string.', n, IsSet(Extra) ? 'Near pos: ' Extra : '')
            }
        }
        ;@endregion
    }

    static __New() {
        this.DeleteProp('__New')
        ; SignficantChars := '["{[ftn\d{}-]'
        ArrayNextChar := '\s*(?<char>,|\])'
        ObjectNextChar := '\s*(?<char>,|\})'
        SignificantChars := (
            '(?:'
                '(?<char>")(?COnQuote{1})'
                '|(?<char>\{)(?<close>\s*\})?(?COnCurlyOpen{1})'
                '|(?<char>\[)(?<close>\s*\])?(?COnSquareOpen{1})'
                '|(?<char>f)(?COnFalse{1})'
                '|(?<char>t)(?COnTrue{1})'
                '|(?<char>n)(?COnNull{1})'
                '|(?<char>[\d-])(?COnNumber{1})'
            ')'
        )
        this.Patterns := {
            ArrayItem: 'JS)\s*' Format(SignificantChars, 'Array')
          , ArrayNumber: 'S)(?<value>(?<n>(?:-?\d++(?:\.\d++)?)(?:[eE][+-]?\d++)?))' ArrayNextChar
          , ArrayString: 'S)(?<=[,:[{\s])"(?<value>.*?(?<!\\)(?:\\\\)*+)"(*COMMIT)' ArrayNextChar
          , ArrayFalse: 'S)(?<value>false)' ArrayNextChar
          , ArrayTrue: 'S)(?<value>true)' ArrayNextChar
          , ArrayNull: 'S)(?<value>null)' ArrayNextChar
          , ArrayNextChar: 'S)' ArrayNextChar
          , ObjectPropName: 'JS)\s*"(?<name>.*?(?<!\\)(?:\\\\)*+)"(*COMMIT):\s*' Format(SignificantChars, 'Object')
          , ObjectNumber: 'S)(?<value>(?<n>-?\d++(?:\.\d++)?)(?<e>[eE][+-]?\d++)?)' ObjectNextChar
          , ObjectString: 'S)(?<=[,:[{\s])"(?<value>.*?(?<!\\)(?:\\\\)*+)"(*COMMIT)' ObjectNextChar
          , ObjectFalse: 'S)(?<value>false)' ObjectNextChar
          , ObjectTrue: 'S)(?<value>true)' ObjectNextChar
          , ObjectNull: 'S)(?<value>null)' ObjectNextChar
          , ObjectNextChar: 'S)' ObjectNextChar
        }
    }
}
