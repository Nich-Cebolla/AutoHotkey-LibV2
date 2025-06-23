/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/QuickParseEx.ahk
    Author: Nich-Cebolla
    Version: 1.0.0
    License: MIT
*/

/**
 * @classdesc - Parses a JSON string into objects defined by callback functions.
 * - When encountering a "false" value in the JSON string, the parameter that receives the value
 * will receive `0`.
 * - When encountering a "null" value in the JSON string, the parameter that receives the value
 * will be unset. It should be made optional.
 * - When encountering a "true" value in the JSON string, the parameter that receives the value
 * will receive `1`.
 * - Unquoted numeric values are passed to `Number()`.
 * - Quoted numbers are processed as strings.
 * - Escape sequences are un-escaped and external quotations are removed from JSON string values.
 */
class QuickParseEx {
    /**
     * - The callback functions each receive a value that represents the current depth. Consider the
     * below example JSON.
     * - When `CallbackConstructorArray` is called for the open square bracket following "Prop2",
     * the value received by the "current depth" parameter will be `0`.
     * - When `CallbackConstructorObject` is called for the open curly bracket following the open square
     * bracket, the value received by the "current depth" parameter will be `1`.
     * - When `CallbackSetterObject` is called for "val1", the value received by the "current depth"
     * parameter will be `0`.
     * - When `CallbackSetterObject` is called for "val2", the value received by the "current depth"
     * parameter will be `2`.
     * @example
     *  {
     *      "Prop": "val1",
     *      "Prop2": [
     *          {
     *              "Prop3": "val2"
     *          }
     *      ]
     *  }
     * @
     * - See "test-files\test-QuickParseEx.ahk" for a usage example.
     * - Only one of `Str` or `Path` are needed. If `Str` is set, `Path` is ignored. If both `Str`
     * and `Path` are unset, the clipboard's contents are used.
     * @param {*} Root - The root object.
     * @param {*} CallbackConstructorArray - A `Func` or callable object that is called when encountering
     * an open square bracket. The function receives one value: the current depth.
     * @param {*} CallbackConstructorObject - A `Func` or callable object that is called when encountering
     * an open curly bracket. The function receives one value: the current depth.
     * @param {*} CallbackSetterArray - A `Func` or callable object that is called when setting a
     * value from a JSON array. The function receives the following values:
     * - The object currently being constructed.
     * - The current depth.
     * - The value. The value should be optional, as noted in the class's description {@link QuickParseEx}.
     * @param {*} CallbackSetterObject - A `Func` or callable object that is called when setting a
     * value from a JSON object property. The function receives the following values:
     * - The object currently being constructed.
     * - A `RegExMatchInfo` object that has the property name accessible from the "name" subcapture
     * group.
     * - The current depth.
     * - The value. The value should be optional, as noted in the class's description {@link QuickParseEx}.
     * @param {String} [Str] - The string to parse.
     * @param {String} [Path] - The path to the file that contains the JSON content to parse.
     * @param {String} [Encoding] - The file encoding to use if calling `QuickParse` with `Path`.
     * @returns {*}
     */
    static Call(Root, CallbackConstructorArray, CallbackConstructorObject, CallbackSetterArray, CallbackSetterObject, Str?, Path?, Encoding?) {
        ;@region Initialization
        static ArrayItem := QuickParseEx.Patterns.ArrayItem
        , ObjectPropName := QuickParseEx.Patterns.ObjectPropName
        , ArrayNumber := QuickParseEx.Patterns.ArrayNumber
        , ArrayString := QuickParseEx.Patterns.ArrayString
        , ArrayFalse := QuickParseEx.Patterns.ArrayFalse
        , ArrayTrue := QuickParseEx.Patterns.ArrayTrue
        , ArrayNull := QuickParseEx.Patterns.ArrayNull
        , ArrayNextChar := QuickParseEx.Patterns.ArrayNextChar
        , ObjectNumber := QuickParseEx.Patterns.ObjectNumber
        , ObjectString := QuickParseEx.Patterns.ObjectString
        , ObjectFalse := QuickParseEx.Patterns.ObjectFalse
        , ObjectTrue := QuickParseEx.Patterns.ObjectTrue
        , ObjectNull := QuickParseEx.Patterns.ObjectNull
        , ObjectNextChar := QuickParseEx.Patterns.ObjectNextChar
        , ObjectInitialCheck := QuickParseEx.Patterns.ObjectInitialCheck

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

        if Match[0] == '[' {
            Pattern := ArrayItem
        } else {
            Pattern := ObjectPropName
        }
        Stack := []
        Pos := Match.Pos + 1
        Obj := Root
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
                CallbackSetterArray(Obj, Stack.Length, StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(MatchValue['text'], '\n', '`n'), '\r', '`r'), '\"', '"'), '\t', '`t'), '\\', '\'))
            } else if MatchValue['text'] && MatchValue['text'] !== '""' {
                CallbackSetterArray(Obj, Stack.Length, MatchValue['text'])
            } else {
                CallbackSetterArray(Obj, Stack.Length, '')
            }
            _PrepareNextArr(MatchValue)
        }
        OnSquareOpenArr(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len - 1
            CallbackSetterArray(Obj, Stack.Length, CallbackConstructorArray(Stack.Length))
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
            CallbackSetterArray(Obj, Stack.Length, CallbackConstructorObject(Stack.Length))
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
            CallbackSetterArray(Obj, Stack.Length, 0)
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
            CallbackSetterArray(Obj, Stack.Length, 1)
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
            CallbackSetterArray(Obj, Stack.Length, unset)
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
            CallbackSetterArray(Obj, Stack.Length, Number(MatchValue['n']))
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
                CallbackSetterObject(Obj, Match, Stack.Length, StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(MatchValue['text'], '\n', '`n'), '\r', '`r'), '\"', '"'), '\t', '`t'), '\\', '\'))
            } else if MatchValue['text'] && MatchValue.Text !== '""' {
                CallbackSetterObject(Obj, Match, Stack.Length, MatchValue['text'])
            } else {
                CallbackSetterObject(Obj, Match, Stack.Length, '')
            }
            _PrepareNextObj(MatchValue)
        }
        OnSquareOpenObj(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len - 1
            CallbackSetterObject(Obj, Match, Stack.Length, _obj := CallbackConstructorArray(Stack.Length))
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
            CallbackSetterObject(Obj, Match, Stack.Length, _obj :=  CallbackConstructorObject(Stack.Length))
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
            CallbackSetterObject(Obj, Match, Stack.Length, 0)
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
            CallbackSetterObject(Obj, Match, Stack.Length, 1)
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
            CallbackSetterObject(Obj, Match, Stack.Length, '')
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
            CallbackSetterObject(Obj, Match, Stack.Length, Number(MatchValue['n']))
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
