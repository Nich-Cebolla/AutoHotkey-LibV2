/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/QuickParse.ahk
    Author: Nich-Cebolla
    Version: 1.0.1
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
        , ObjectInitialCheck := QuickParse.Patterns.ObjectInitialCheck

        if !IsSet(Str) {
            If IsSet(Path) {
                Str := FileRead(Path, Encoding ?? unset)
            } else {
                Str := A_Clipboard
            }
        }
        if !RegExMatch(Str, '[[{]', &Match) {
            throw ValueError('Invalid JSON.', -1)
        }
        if AsMap {
            GetObj := MapCaseSense ? Map : _GetObj
            SetValue := _SetProp1
        } else {
            GetObj := Object
            SetValue := _SetProp2
        }

        if IsSet(Root) {
            if Match[0] == '[' {
                if !HasMethod(Root, 'Push') || !HasMethod(Root, 'Pop') {
                    throw ValueError('The value passed to the ``Root`` parameter is required to have'
                        ' methods ``Push`` and ``Pop`` when the opening bracket in the JSON is a square'
                        ' bracket.', -1)
                }
                Pattern := ArrayItem
                Obj := Root
            } else {
                if AsMap && !HasMethod(Root, 'Set') {
                    throw ValueError('The value passed to the ``Root`` parameter is required to have'
                        ' a ``Set`` method when ``AsMap`` is true.', -1)
                }
                Pattern := ObjectPropName
                Obj := Root
            }
        } else {
            if Match[0] == '[' {
                Root := Obj := []
                Pattern := ArrayItem
            } else {
                Root := Obj := GetObj()
                Pattern := ObjectPropName
            }
        }
        Stack := []
        Pos := Match.Pos + 1
        ;@endregion

        while RegExMatch(Str, Pattern, &Match, Pos) {
            continue
        }

        return Root

        ;@region Array Callbacks
        OnQuoteArr(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ArrayString, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                _Throw(1, Pos)
            }
            if InStr(MatchValue['text'], '\') {
                Obj.Push(StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(MatchValue['text'], '\n', '`n'), '\r', '`r'), '\"', '"'), '\t', '`t'), '\\', '\'))
            } else if MatchValue['text'] && MatchValue['text'] !== '""' {
                Obj.Push(MatchValue['text'])
            } else {
                Obj.Push('')
            }
            _PrepareNextArr(MatchValue)
        }
        OnSquareOpenArr(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len - 1
            Obj.Push([])
            Stack.Push({ Obj: Obj, Handler: _GetContextArray })
            Obj := Obj[-1]
            Pattern := ArrayItem
            Pos++
        }
        OnCurlyOpenArr(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len - 1
            Obj.Push(GetObj())
            if !RegExMatch(Str, ObjectInitialCheck, &MatchCheck, Pos) || MatchCheck.Pos !== Pos + 1 {
                _Throw(1, Pos)
            }
            if MatchCheck['nextchar'] == '}' {
                Pos := MatchCheck.Pos + MatchCheck.Len
                _GetContextArray()
            } else {
                Pos++
                Pattern := ObjectPropName
                Stack.Push({ Obj: Obj, Handler: _GetContextArray })
                Obj := Obj[-1]
            }
        }
        OnFalseArr(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len - 1
            Obj.Push(0)
            if !RegExMatch(Str, ArrayFalse, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                _Throw(1, Pos)
            }
            _PrepareNextArr(MatchValue)
        }
        OnTrueArr(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len - 1
            Obj.Push(1)
            if !RegExMatch(Str, ArrayTrue, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                _Throw(1, Pos)
            }
            _PrepareNextArr(MatchValue)
        }
        OnNullArr(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len - 1
            Obj.Push(unset)
            if !RegExMatch(Str, ArrayNull, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                _Throw(1, Pos)
            }
            _PrepareNextArr(MatchValue)
        }
        OnNumberArr(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ArrayNumber, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                _Throw(1, Match.Pos)
            }
            Obj.Push(Number(MatchValue['n']))
            _PrepareNextArr(MatchValue)
        }
        OnSquareCloseArr(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len
            if Stack.Length {
                Active := Stack.Pop()
                Obj := Active.Obj
                Active.Handler.Call()
            }
        }
        ;@endregion

        ;@region Object Callbacks
        OnQuoteObj(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ObjectString, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                _Throw(1, Pos)
            }
            if InStr(MatchValue['text'], '\') {
                SetValue(Match, StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(MatchValue['text'], '\n', '`n'), '\r', '`r'), '\"', '"'), '\t', '`t'), '\\', '\'))
            } else if MatchValue['text'] && MatchValue.Text !== '""' {
                SetValue(Match, MatchValue['text'])
            } else {
                SetValue(Match, '')
            }
            _PrepareNextObj(MatchValue)
        }
        OnSquareOpenObj(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len - 1
            SetValue(Match, _obj := [])
            Stack.Push({ Obj: Obj, Handler: _GetContextObject })
            Obj := _obj
            Pattern := ArrayItem
            Pos++
        }
        OnCurlyOpenObj(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len - 1
            SetValue(Match, _obj := GetObj())
            if !RegExMatch(Str, ObjectInitialCheck, &MatchCheck, Pos) || MatchCheck.Pos !== Pos + 1 {
                _Throw(1, Pos)
            }
            if MatchCheck['nextchar'] == '}' {
                Pos := MatchCheck.Pos + MatchCheck.Len
                _GetContextObject()
            } else {
                Pos++
                Stack.Push({ Obj: Obj, Handler: _GetContextObject })
                Obj := _obj
            }
        }
        OnFalseObj(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len - 1
            SetValue(Match, 0)
            if !RegExMatch(Str, ObjectFalse, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                _Throw(1, Pos)
            }
            _PrepareNextObj(MatchValue)
        }
        OnTrueObj(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len - 1
            SetValue(Match, 1)
            if !RegExMatch(Str, ObjectTrue, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                _Throw(1, Pos)
            }
            _PrepareNextObj(MatchValue)
        }
        OnNullObj(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len - 1
            SetValue(Match, '')
            if !RegExMatch(Str, ObjectNull, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                _Throw(1, Pos)
            }
            _PrepareNextObj(MatchValue)
        }
        OnNumberObj(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ObjectNumber, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                _Throw(1, Match.Pos)
            }
            SetValue(Match, Number(MatchValue['n']))
            _PrepareNextObj(MatchValue)
        }
        ;@endregion

        ;@region Helper Funcs
        _GetContextArray() {
            if !RegExMatch(Str, ArrayNextChar, &Match, Pos) || Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len
            if Match['nextchar'] == ',' {
                Pattern := ArrayItem
            } else if Match['nextchar'] == ']' {
                if Stack.Length {
                    Active := Stack.Pop()
                    Obj := Active.Obj
                    Active.Handler.Call()
                }
            }
        }
        _GetContextObject() {
            if !RegExMatch(Str, ObjectNextChar, &Match, Pos) || Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len
            if Match['nextchar'] == ',' {
                Pattern := ObjectPropName
            } else if Match['nextchar'] == '}' {
                if Stack.Length {
                    Active := Stack.Pop()
                    Obj := Active.Obj
                    Active.Handler.Call()
                }
            }
        }
        _GetObj() {
            m := Map()
            m.CaseSense := false
            return m
        }
        _PrepareNextArr(MatchValue) {
            Pos := MatchValue.Pos + MatchValue.Len
            if MatchValue['nextchar'] == ']' {
                if Stack.Length {
                    Active := Stack.Pop()
                    Obj := Active.Obj
                    Active.Handler.Call()
                }
            }
        }
        _PrepareNextObj(MatchValue) {
            Pos := MatchValue.Pos + MatchValue.Len
            if MatchValue['nextchar'] == '}' {
                if Stack.Length {
                    Active := Stack.Pop()
                    Obj := Active.Obj
                    Active.Handler.Call()
                }
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
        SignficantChars := '["{[ftn\d{}-]'
        NextChar := '(?:\s*(?<nextchar>,|\{}))'
        ArrayNextChar := Format(NextChar, ']')
        ObjectNextChar := Format(NextChar, '}')
        this.Patterns := {
            ArrayItem: 'is)\s*(?<char>"(?COnQuoteArr)|\{(?COnCurlyOpenArr)|\[(?COnSquareOpenArr)|f(?COnFalseArr)|t(?COnTrueArr)|n(?COnNullArr)|[\d-](?COnNumberArr)|\](?COnSquareCloseArr))'
          , ArrayNumber: 's)(?<n>(?:-?\d++(?:\.\d++)?)(?:[eE][+-]?\d++)?)' ArrayNextChar
          , ArrayString: 's)(?<=[,:[{\s])"(?<text>.*?)(?<!\\)(?:\\\\)*+"' ArrayNextChar
          , ArrayFalse: 'is)false' ArrayNextChar
          , ArrayTrue: 'is)true' ArrayNextChar
          , ArrayNull: 'is)null' ArrayNextChar
          , ArrayNextChar: ArrayNextChar
          , ObjectPropName: 'is)\s*"(?<name>.+?)(?<!\\)(?:\\\\)*+":\s*(?<nextchar>"(?COnQuoteObj)|\{(?COnCurlyOpenObj)|\[(?COnSquareOpenObj)|f(?COnFalseObj)|t(?COnTrueObj)|n(?COnNullObj)|[\d-](?COnNumberObj))'
          , ObjectNumber: 's)(?<n>-?\d++(?:\.\d++)?)(?<e>[eE][+-]?\d++)?' ObjectNextChar
          , ObjectString: 's)(?<=[,:[{\s])"(?<text>.*?)(?<!\\)(?:\\\\)*+"' ObjectNextChar
          , ObjectFalse: 'is)false' ObjectNextChar
          , ObjectTrue: 'is)true' ObjectNextChar
          , ObjectNull: 'is)null' ObjectNextChar
          , ObjectNextChar: ObjectNextChar
          , ObjectInitialCheck: 's)\s*(?<nextchar>"|\})'
        }
    }
}
