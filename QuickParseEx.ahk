/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/QuickParseEx.ahk
    Author: Nich-Cebolla
    Version: 1.2.2
    License: MIT
*/
; https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/PathObj.ahk
#include <PathObj>

; There's a few more classes beneath `QuickParseEx`. They are helper classes for use with
; `QuickParseEx.Find`.

/**
 * @classdesc - Parses a JSON string into objects defined by callback functions.
 *
 * The parameter that receives the value to be set to the object should be optional, because
 * when the value is "null", the parameter will be unset.
 *
 * - When encountering a "false" value in the JSON string, the parameter that receives the value
 * will receive `0`.
 * - When encountering a "null" value in the JSON string, the parameter that receives the value
 * will be unset.
 * - When encountering a "true" value in the JSON string, the parameter that receives the value
 * will receive `1`.
 * - Unquoted numeric values are passed to `Number()`.
 * - Quoted numbers are processed as strings.
 * - Escape sequences are un-escaped and external quotations are removed from JSON string values.
 */
class QuickParseEx {

    /**
     * The callback functions each receive a value that represents the current depth. Consider the
     * below example JSON.
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
     * - When `CallbackConstructorArray` is called for the open square bracket following "Prop2",
     * the value received by the "current depth" parameter will be `1`.
     * - When `CallbackConstructorObject` is called for the open curly bracket following the open square
     * bracket, the value received by the "current depth" parameter will be `2`.
     * - When `CallbackSetterObject` is called for "val1", the value received by the "current depth"
     * parameter will be `1`.
     * - When `CallbackSetterObject` is called for "val2", the value received by the "current depth"
     * parameter will be `3`.
     *
     * If `CallbackSetterArray` or `CallbackSetterObject` return a nonzero value, `QuickParseEx`
     * will return after completing the current action.
     *
     * See "test-files\test-QuickParseEx.Call.ahk" for a usage example.
     *
     * Only one of `Str` or `Path` are needed. If `Str` is set, `Path` is ignored. If both `Str`
     * and `Path` are unset, the clipboard's contents are used.
     *
     * @param {*} Root - The root object.
     * @param {*} CallbackConstructorArray - A `Func` or callable object that is called when encountering
     * an open square bracket. The function receives one value: the current depth. The function should
     * return the array object.
     * @param {*} CallbackConstructorObject - A `Func` or callable object that is called when encountering
     * an open curly bracket. The function receives one value: the current depth. The function should
     * return the object.
     * @param {*} CallbackSetterArray - A `Func` or callable object that is called when setting a
     * value from a JSON array. The function receives the following values:
     * 1. The object currently being constructed.
     * 2. The current depth.
     * 3. The value. The value should be optional, as noted in the description {@link QuickParseEx.Call}.
     * @param {*} CallbackSetterObject - A `Func` or callable object that is called when setting a
     * value from a JSON object property. The function receives the following values:
     * 1. The object currently being constructed.
     * 2. A `RegExMatchInfo` object that has the property name accessible from the "name" subcapture
     * group.
     * 3. The current depth.
     * 4. The value. The value should be optional, as noted in the description {@link QuickParseEx.Call}.
     * @param {String} [Str] - The string to parse.
     * @param {String} [Path] - The path to the file that contains the JSON content to parse.
     * @param {String} [Encoding] - The file encoding to use if calling `QuickParseEx.Call` with `Path`.
     * @returns {*}
     */
    static Call(
        Root
      , CallbackConstructorArray
      , CallbackConstructorObject
      , CallbackSetterArray
      , CallbackSetterObject
      , Str?
      , Path?
      , Encoding?
    ) {
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

        if !IsSet(Str) {
            If IsSet(Path) {
                Str := FileRead(Path, Encoding ?? unset)
            } else {
                Str := A_Clipboard
            }
        }

        posCurly := InStr(Str, '{')
        posSquare := InStr(Str, '[')
        if posCurly {
            if posSquare {
                if posCurly > posSquare {
                    Pattern := ArrayItem
                    Pos := posSquare + 1
                } else {
                    Pattern := ObjectPropName
                    Pos := posCurly + 1
                }
            } else {
                Pattern := ObjectPropName
                Pos := posCurly + 1
            }
        } else if posSquare {
            Pattern := ArrayItem
            Pos := posSquare + 1
        } else {
            throw Error('Missing open bracket.', -1)
        }
        Controller := { Obj: Root, __Handler: (*) => }
        Stack := ['']
        Obj := Root
        flag_exit := false
        ; Used when unescaping json escape sequences.
        charOrd := 0xFFFD
        while InStr(Str, Chr(charOrd)) {
            charOrd++
        }
        ;@endregion

        while RegExMatch(Str, Pattern, &Match, Pos) {
            if flag_exit {
                return Root
            }
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
            if InStr(MatchValue['value'], '\') {
                if CallbackSetterArray(Obj, Stack.Length, StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(MatchValue['value'], '\\', Chr(charOrd)), '\n', '`n'), '\r', '`r'), '\"', '"'), '\t', '`t'), Chr(charOrd), '\')) {
                    flag_exit := true
                }
            } else if MatchValue['value'] !== '""' {
                if CallbackSetterArray(Obj, Stack.Length, MatchValue['value']) {
                    flag_exit := true
                }
            } else if CallbackSetterArray(Obj, Stack.Length, '') {
                flag_exit := true
            }
            _PrepareNextArr(MatchValue)
        }
        OnSquareOpenArr(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len
            _obj := CallbackConstructorArray(Stack.Length)
            if CallbackSetterArray(Obj, Stack.Length, _obj) {
                flag_exit := true
            }
            if Match['close'] {
                _GetContextArray()
            } else {
                Controller.__Handler := _GetContextArray
                Stack.Push(Controller)
                Obj := _obj
                Controller := { Obj: Obj }
            }
        }
        OnCurlyOpenArr(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len
            _obj := CallbackConstructorObject(Stack.Length)
            if CallbackSetterArray(Obj, Stack.Length, _obj) {
                flag_exit := true
            }
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
        OnFalseArr(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ArrayFalse, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                _Throw(1, Pos)
            }
            if CallbackSetterArray(Obj, Stack.Length, 0) {
                flag_exit := true
            }
            _PrepareNextArr(MatchValue)
        }
        OnTrueArr(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ArrayTrue, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                _Throw(1, Pos)
            }
            if CallbackSetterArray(Obj, Stack.Length, 1) {
                flag_exit := true
            }
            _PrepareNextArr(MatchValue)
        }
        OnNullArr(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ArrayNull, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                _Throw(1, Pos)
            }
            if CallbackSetterArray(Obj, Stack.Length, unset) {
                flag_exit := true
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
            if CallbackSetterArray(Obj, Stack.Length, Number(MatchValue['value'])) {
                flag_exit := true
            }
            _PrepareNextArr(MatchValue)
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
            if InStr(MatchValue['value'], '\') {
                if CallbackSetterObject(Obj, Match, Stack.Length, StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(MatchValue['value'], '\\', Chr(charOrd)), '\n', '`n'), '\r', '`r'), '\"', '"'), '\t', '`t'), Chr(charOrd), '\')) {
                    flag_exit := true
                }
            } else if MatchValue['value'] && MatchValue['value'] !== '""' {
                if CallbackSetterObject(Obj, Match, Stack.Length, MatchValue['value']) {
                    flag_exit := true
                }
            } else if CallbackSetterObject(Obj, Match, Stack.Length, '') {
                flag_exit := true
            }
            _PrepareNextObj(MatchValue)
        }
        OnSquareOpenObj(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len
            _obj := CallbackConstructorArray(Stack.Length)
            if CallbackSetterObject(Obj, Match, Stack.Length, _obj) {
                flag_exit := true
            }
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
        OnCurlyOpenObj(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len
            _obj :=  CallbackConstructorObject(Stack.Length)
            if CallbackSetterObject(Obj, Match, Stack.Length, _obj) {
                flag_exit := true
            }
            if Match['close'] {
                _GetContextObject()
            } else {
                Controller.__Handler := _GetContextObject
                Stack.Push(Controller)
                Obj := _obj
                Controller := { Obj: Obj }
            }
        }
        OnFalseObj(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ObjectFalse, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                _Throw(1, Pos)
            }
            if CallbackSetterObject(Obj, Match, Stack.Length, 0) {
                flag_exit := true
            }
            _PrepareNextObj(MatchValue)
        }
        OnTrueObj(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ObjectTrue, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                _Throw(1, Pos)
            }
            if CallbackSetterObject(Obj, Match, Stack.Length, 1) {
                flag_exit := true
            }
            _PrepareNextObj(MatchValue)
        }
        OnNullObj(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ObjectNull, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                _Throw(1, Pos)
            }
            if CallbackSetterObject(Obj, Match, Stack.Length, '') {
                flag_exit := true
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
            if CallbackSetterObject(Obj, Match, Stack.Length, Number(MatchValue['value'])) {
                flag_exit := true
            }
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
        _Throw(Code, Extra?, n := -2) {
            switch Code, 0 {
                case '1': throw Error('There is an error in the JSON string.', n, IsSet(Extra) ? 'Near pos: ' Extra : '')
            }
        }
        ;@endregion
    }
    /**
     * - `QuickParseEx.Call2` follows the same parsing logic as `QuickParseEx.Call`, but the callback
     * functions receive the same values as `QuickParseEx.Find` in addition to receiving the object
     * being constructed.
     * @see {@link QuickParseEx.Call}.
     * @see {@link QuickParseEx.Find}.
     *
     * @param {*} Root - The root object.
     *
     * @param {*} CallbackConstructorArray - A `Func` or callable object that is called when
     * encountering an open square bracket. The function should not set the current object with the
     * new object value; the setter callback function will be called immediately after.
     *
     * The function receives:
     * 1. The current object.
     * 2. The `Controller` object. See the description above {@link QuickParseEx.Find}. This controller
     * also has additional property "Obj" which is the same value that is passed to parameter 1.
     * 3. The `Stack` array. See the description above {@link QuickParseEx.Find}.
     * 4. The character position of the open bracket.
     * 5. A `RegExMatchInfo` object that has a subcapture group "char". The "char" subcapture group
     * returns the first significant character of the value in the JSON string. In this case it would
     * be the open bracket. The `RegExMatchInfo` object might also have a subcapture group "close"
     * which would indicate the array is empty.
     *
     * The function should return the new object.
     *
     * @param {*} CallbackConstructorObject - A `Func` or callable object that is called when
     * encountering an open curly bracket. The function should not set the current object with the
     * new object value; the setter callback function will be called immediately after.
     *
     * The function receives:
     * 1. The current object.
     * 2. The `Controller` object. See the description above {@link QuickParseEx.Find}. This controller
     * also has additional property "Obj" which is the same value that is passed to parameter 1.
     * 3. The `Stack` array. See the description above {@link QuickParseEx.Find}.
     * 4. The character position of the open bracket.
     * 5. A `RegExMatchInfo` object that has a subcapture group "char". The "char" subcapture group
     * returns the first significant character of the value in the JSON string. In this case it would
     * be the open bracket. The `RegExMatchInfo` object might also have a subcapture group "close"
     * which would indicate the object has no properties.
     *
     * The function should return the new object.
     *
     * @param {*} CallbackSetterArray - A `Func` or callable object that is called for each value in a
     * JSON array. See the notes in the description of `QuickParseEx.Find` for some additional details.
     * If this function returns a nonzero value, `QuickParseEx.Call2` will return after completing
     * the current action.
     *
     * The function receives the following values:
     * 1. The current object.
     * 2. The `Controller` object. See the description above {@link QuickParseEx.Find}. This controller
     * also has additional property "Obj" which is the same value that is passed to parameter 1.
     * 3. The `Stack` array. See the description above {@link QuickParseEx.Find}.
     * 4. The character position of the first significant character of the value.
     * 5. A `RegExMatchInfo` object that has a subcapture group "char". The "char" subcapture group
     * returns the first significant character of the value in the JSON string.
     * 6. This parameter must be optional. The value. See the notes above {@link QuickParseEx}
     * clarifying the value received by this parameter.
     * 7. This parameter must be optional. When the 6th parameter receives a value that is an object,
     * this parameter will be unset. In all other cases, this parameter receives a `RegExMatchInfo`
     * object. The object will always have at least two subcapture groups:
     *   - char: Either a comma or a closing bracket.
     *   - value: For string values, the value's substring without the external quote characters
     * (but still escaped). For other values, the value's unmodified substring.
     *
     * @param {*} CallbackSetterObject - A `Func` or callable object that is called for each value that is
     * a property of a JSON object. See the notes in the description of `QuickParseEx.Find` for some
     * additional details.
     *
     * The function receives the following values:
     * 1. The current object.
     * 2. The `Controller` object. See the description above {@link QuickParseEx.Find}. This controller
     * also has additional property "Obj" which is the same value that is passed to parameter 1.
     * 3. The `Stack` array. See the description above {@link QuickParseEx.Find}.
     * 4. The character position of the first significant character of the value.
     * 5. A `RegExMatchInfo` object that has two subcapture groups:
     *   - char: The first significant character of the value in the JSON string.
     *   - name: The property name without quotes and still escaped.
     * 6. This parameter must be optional. The value. See the notes above {@link QuickParseEx}
     * clarifying the value received by this parameter.
     * 7. This parameter must be optional. When the 6th parameter receives a value that is an object,
     * this parameter will be unset. In all other cases, this parameter receives a `RegExMatchInfo`
     * object. The object will always have at least two subcapture groups:
     *   - char: Either a comma or a closing bracket.
     *   - value: For string values, the value's substring without the external quote characters
     * (but still escaped). For other values, the value's unmodified substring.
     *
     * @param {String} [Str] - The string to parse.
     * @param {String} [Path] - The path to the file that contains the JSON content to parse.
     * @param {String} [Encoding] - The file encoding to use if calling `QuickParse` with `Path`.
     *
     * @returns {*} - The `Root` object
     */
    static Call2(
        Root
      , CallbackConstructorArray
      , CallbackConstructorObject
      , CallbackSetterArray
      , CallbackSetterObject
      , Str?
      , Path?
      , Encoding?
    ) {
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

        if !IsSet(Str) {
            If IsSet(Path) {
                Str := FileRead(Path, Encoding ?? unset)
            } else {
                Str := A_Clipboard
            }
        }

        posCurly := InStr(Str, '{')
        posSquare := InStr(Str, '[')
        if posCurly {
            if posSquare {
                if posCurly > posSquare {
                    Pattern := ArrayItem
                    Pos := posSquare + 1
                } else {
                    Pattern := ObjectPropName
                    Pos := posCurly + 1
                }
            } else {
                Pattern := ObjectPropName
                Pos := posCurly + 1
            }
        } else if posSquare {
            Pattern := ArrayItem
            Pos := posSquare + 1
        } else {
            throw Error('Missing open bracket.', -1)
        }
        Controller := { Obj: Root, Index: 0, Path: PathObj(), __Handler: (*) => '' }
        Stack := ['']
        Obj := Root
        flag_exit := false
        ; Used when unescaping json escape sequences.
        charOrd := 0xFFFD
        while InStr(Str, Chr(charOrd)) {
            charOrd++
        }
        ;@endregion

        while RegExMatch(Str, Pattern, &Match, Pos) {
            if flag_exit {
                return Root
            }
        }

        return Root

        ;@region Array Callbacks
        OnQuoteArr(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            ++Controller.Index
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ArrayString, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                _Throw(1, Pos)
            }
            if InStr(MatchValue['value'], '\') {
                if CallbackSetterArray(
                    Obj
                  , Controller
                  , Stack
                  , Match.Pos['char']
                  , Match
                  , StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(MatchValue['value'], '\\', Chr(charOrd)), '\n', '`n'), '\r', '`r'), '\"', '"'), '\t', '`t'), Chr(charOrd), '\')
                  , MatchValue
                ) {
                    flag_exit := true
                }
            } else if MatchValue['value'] !== '""' {
                if CallbackSetterArray(Obj, Controller, Stack, Match.Pos['char'], Match, MatchValue['value'], MatchValue) {
                    flag_exit := true
                }
            } else if CallbackSetterArray(Obj, Controller, Stack, Match.Pos['char'], Match, '', MatchValue) {
                flag_exit := true
            }
            _PrepareNextArr(MatchValue)
        }
        OnSquareOpenArr(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            ++Controller.Index
            Pos := Match.Pos + Match.Len
            _obj := CallbackConstructorArray(Obj, Controller, Stack, Match.Pos['char'], Match)
            if CallbackSetterArray(Obj, Controller, Stack, Match.Pos['char'], Match, _obj) {
                flag_exit := true
            }
            if Match['close'] {
                _GetContextArray()
            } else {
                Controller.__Handler := _GetContextArray
                Obj := _obj
                _GetControllerArray(Controller.Index)
            }
        }
        OnCurlyOpenArr(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            ++Controller.Index
            Pos := Match.Pos + Match.Len
            _obj := CallbackConstructorObject(Obj, Controller, Stack, Match.Pos['char'], Match)
            if CallbackSetterArray(Obj, Controller, Stack, Match.Pos['char'], Match, _obj) {
                flag_exit := true
            }
            if Match['close'] {
                _GetContextArray()
            } else {
                Controller.__Handler := _GetContextArray
                Obj := _obj
                _GetControllerArray(Controller.Index)
                Pattern := ObjectPropName
            }
        }
        OnFalseArr(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            ++Controller.Index
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ArrayFalse, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                _Throw(1, Pos)
            }
            if CallbackSetterArray(Obj, Controller, Stack, Match.Pos['char'], Match, 0, MatchValue) {
                flag_exit := true
            }
            _PrepareNextArr(MatchValue)
        }
        OnTrueArr(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            ++Controller.Index
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ArrayTrue, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                _Throw(1, Pos)
            }
            if CallbackSetterArray(Obj, Controller, Stack, Match.Pos['char'], Match, 1, MatchValue) {
                flag_exit := true
            }
            _PrepareNextArr(MatchValue)
        }
        OnNullArr(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            ++Controller.Index
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ArrayNull, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                _Throw(1, Pos)
            }
            if CallbackSetterArray(Obj, Controller, Stack, Match.Pos['char'], Match, , MatchValue) {
                flag_exit := true
            }
            _PrepareNextArr(MatchValue)
        }
        OnNumberArr(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            ++Controller.Index
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ArrayNumber, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                _Throw(1, Match.Pos)
            }
            if CallbackSetterArray(Obj, Controller, Stack, Match.Pos['char'], Match, Number(MatchValue['value']), MatchValue) {
                flag_exit := true
            }
            _PrepareNextArr(MatchValue)
        }
        ;@endregion

        ;@region Object Callbacks
        OnQuoteObj(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            ++Controller.Index
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ObjectString, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                _Throw(1, Pos)
            }
            if InStr(MatchValue['value'], '\') {
                if CallbackSetterObject(
                    Obj
                  , Controller
                  , Stack
                  , Match.Pos['char']
                  , Match
                  , StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(MatchValue['value'], '\\', Chr(charOrd)), '\n', '`n'), '\r', '`r'), '\"', '"'), '\t', '`t'), Chr(charOrd), '\')
                  , MatchValue
                ) {
                    flag_exit := true
                }
            } else if MatchValue['value'] !== '""' {
                if CallbackSetterObject(Obj, Controller, Stack, Match.Pos['char'], Match, MatchValue['value'], MatchValue) {
                    flag_exit := true
                }
            } else if CallbackSetterObject(Obj, Controller, Stack, Match.Pos['char'], Match, '', MatchValue) {
                flag_exit := true
            }
            _PrepareNextObj(MatchValue)
        }
        OnSquareOpenObj(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            ++Controller.Index
            Pos := Match.Pos + Match.Len
            _obj := CallbackConstructorArray(Obj, Controller, Stack, Match.Pos['char'], Match)
            if CallbackSetterObject(Obj, Controller, Stack, Match.Pos['char'], Match, _obj) {
                flag_exit := true
            }
            if Match['close'] {
                _GetContextObject()
            } else {
                Controller.__Handler := _GetContextObject
                Obj := _obj
                _GetControllerObject(Match)
                Pattern := ArrayItem
            }
        }
        OnCurlyOpenObj(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            ++Controller.Index
            Pos := Match.Pos + Match.Len
            _obj := CallbackConstructorObject(Obj, Controller, Stack, Match.Pos['char'], Match)
            if CallbackSetterObject(Obj, Controller, Stack, Match.Pos['char'], Match, _obj) {
                flag_exit := true
            }
            if Match['close'] {
                _GetContextObject()
            } else {
                Controller.__Handler := _GetContextObject
                Obj := _obj
                _GetControllerObject(Match)
            }
        }
        OnFalseObj(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            ++Controller.Index
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ObjectFalse, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                _Throw(1, Pos)
            }
            if CallbackSetterObject(Obj, Controller, Stack, Match.Pos['char'], Match, 0, MatchValue) {
                flag_exit := true
            }
            _PrepareNextObj(MatchValue)
        }
        OnTrueObj(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            ++Controller.Index
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ObjectTrue, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                _Throw(1, Pos)
            }
            if CallbackSetterObject(Obj, Controller, Stack, Match.Pos['char'], Match, 1, MatchValue) {
                flag_exit := true
            }
            _PrepareNextObj(MatchValue)
        }
        OnNullObj(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            ++Controller.Index
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ObjectNull, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                _Throw(1, Pos)
            }
            if CallbackSetterObject(Obj, Controller, Stack, Match.Pos['char'], Match, , MatchValue) {
                flag_exit := true
            }
            _PrepareNextObj(MatchValue)
        }
        OnNumberObj(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            ++Controller.Index
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ObjectNumber, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                _Throw(1, Match.Pos)
            }
            if CallbackSetterObject(Obj, Controller, Stack, Match.Pos['char'], Match, Number(MatchValue['value']), MatchValue) {
                flag_exit := true
            }
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
        _GetControllerArray(Index) {
            Stack.Push(Controller)
            Controller := { Obj: Obj, Index: 0, Path: Controller.Path.MakeItem(Index) }
        }
        _GetControllerObject(Match) {
            Stack.Push(Controller)
            if InStr(Match['name'], '\') {
                Controller := { Obj: Obj, Index: 0, Path: Controller.Path.MakeProp(StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(Match['name'], '\\', Chr(charOrd)), '\n', '`n'), '\r', '`r'), '\"', '"'), '\t', '`t'), Chr(charOrd), '\')) }
            } else {
                Controller := { Obj: Obj, Index: 0, Path: Controller.Path.MakeProp(Match['name']) }
            }
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
        _Throw(Code, Extra?, n := -2) {
            switch Code, 0 {
                case '1': throw Error('There is an error in the JSON string.', n, IsSet(Extra) ? 'Near pos: ' Extra : '')
            }
        }
        ;@endregion
    }
    /**
     * `QuickParseEx.Find` can be used to locate the character position of a property or value in
     * a JSON string. It uses the same parsing logic as `QuickParseEx.Call`, but does not actually
     * create the objects.
     *
     * Only one of `Str` or `Path` are needed. If `Str` is set, `Path` is ignored. If both `Str`
     * and `Path` are unset, the clipboard's contents are used.
     *
     * The callback functions each receive the `Controller` object. The `Controller` has two properties
     * { Index, Path, __Handler }.
     * - `Controller.Index` is an integer representing the index of the most recently encountered
     * value relative to the parent object. For example, in the string
     * '{ "Prop1": "Val1", "Prop2": "Val2", "Prop3": { "Prop4": "Val4" } }',
     * "Val1" is at index 1, "Val2" is at index 2, the object $.Prop3 is at index 3, and "Val4" is
     * at index 1 because each object retains its own index. It works the same way for array
     * items.
     * - `Controller.Path` is a `PathObj` object, which simplifies keeping track of object paths
     * using a string representation of the path. To get the current path, just call the property,
     * i.e. `Controller.Path()`, and it returns the object path as a string. Call `Controller.Unescaped()`
     * to get an unescaped version of the path. See {@link PathObj}.
     *
     * The callback functions each receive the `Stack` array. The values in the array are the
     * `Controller` objects that are ancestors of the `Controller` object passed to the first parameter.
     * You can add properties to the objects but do not change any of { Index, Path, __Handler }.
     *
     * The current depth is represented by `Stack.Length`. The root depth is 1.
     *
     * The callback functions do not need to return anything. If a callback function returns a
     * nonzero value, `QuickParseEx.Find` will return after completing the current action.
     *
     * To get a grasp on what values are represented by either `RegExMatchInfo` object passed to
     * the callback functions, you can run any of the test functions in
     * "test-files\test-QuickParseEx.Find.ahk" with a debugger.
     * Set breakpoints on the `sleep 1` statements. Follow along with what you see in the
     * `RegExMatchInfo` objects.
     *
     * Here is the function `test3` example written out:
     * @example
     *  str := '{ "prop": ["\n", "\"", -5e-5 ], "prop2": { "prop2_1": 0.12, "prop2_2": null } }'
     * @
     * 1. CallbackObject:
     *   1. Controller.Path() == "$"
     *   2. Stack.Length == 1
     *   3. 11, the position of the open "["
     *   4. "name" = "prop"; "char" = "["
     *   5. unset
     * 2. CallbackArray:
     *   1. Controller.Path() == "$.prop"
     *   2. Stack.Length == 2
     *   3. 12, the position of the open "["
     *   4. "char" = "`""
     *   5. "value" = "\n"; "char" = ","
     * 3. CallbackArray:
     *   1. Controller.Path() == "$.prop"
     *   2. Stack.Length == 2
     *   3. 18, the position of "`"" after ", "
     *   4. "char" = "`""
     *   5. "value" = "\`""; "char" = ","
     * 4. CallbackArray:
     *   1. Controller.Path() == "$.prop"
     *   2. Stack.Length == 2
     *   3. 24, the position of "-" after ", "
     *   4. "char" = "-"
     *   5. "value" = "-5e-5"; "char" = "]"
     * 5. CallbackCloseArray:
     *   1. Controller.Path() == "$.prop"
     *   2. Stack.Length == 2
     *   3. 30, the position of "]"
     * 6. CallbackObject:
     *   1. Controller.Path() == "$"
     *   2. Stack.Length == 1
     *   3. 42, the position of "{" after "`"prop2`": "
     *   4. "name" = "prop2"; "char" = "{"
     *   5. unset
     * 7. CallbackObject:
     *   1. Controller.Path() == "$.prop2"
     *   2. Stack.Length == 2
     *   3. 55, the position of "0"
     *   4. "name" = "prop2_1"; "char" = "0"
     *   5. "value" = "0.12"; "char" = ","
     * 8. CallbackObject:
     *   1. Controller.Path() == "$.prop2"
     *   2. Stack.Length == 2
     *   3. 72, the position of "n"
     *   4. "name" = "prop2_2"; "char" = "n"
     *   5. "value" = "null"; "char" = "}"
     * 9. CallbackCloseObject:
     *   1. Controller.Path() == "$.prop2"
     *   2. Stack.Length == 2
     *   3. 77, the position of "}"
     * 10. CallbackCloseObject:
     *   1. Controller.Path() == "$"
     *   2. Stack.Length == 1
     *   3. 79, the position of "}"
     *
     * @param {*} CallbackArray - A `Func` or callable object that is called for each value in a
     * JSON array. See the notes in the description of `QuickParseEx.Find` for some additional details.
     * If this function returns a nonzero value, `QuickParseEx.Call2` will return after completing
     * the current action.
     *
     * The function receives the following values:
     * 1. The `Controller` object. See the description above {@link QuickParseEx.Find}. This controller
     * also has additional property "Obj" which is the same value that is passed to parameter 1.
     * 2. The `Stack` array. See the description above {@link QuickParseEx.Find}.
     * 3. The character position of the first significant character of the value.
     * 4. A `RegExMatchInfo` object that has a subcapture group "char". The "char" subcapture group
     * returns the first significant character of the value in the JSON string.
     * 5. This parameter must be optional. When `CallbackArray` is called because `QuickParseEx.Find`
     * encountered an open bracket, this parameter is unset. In all other cases, this parameter
     * receives a `RegExMatchInfo` object. The object will always have at least two subcapture groups:
     *   - char: Either a comma or a closing bracket.
     *   - value: For string values, the value's substring without the external quote characters
     * (but still escaped). For other values, the value's unmodified substring.
     *
     * @param {*} CallbackSetterObject - A `Func` or callable object that is called for each value that
     * is a property of a JSON object. See the notes in the description of `QuickParseEx.Find` for some
     * additional details.
     *
     * The function receives the following values:
     * 1. The `Controller` object. See the description above {@link QuickParseEx.Find}. This controller
     * also has additional property "Obj" which is the same value that is passed to parameter 1.
     * 2. The `Stack` array. See the description above {@link QuickParseEx.Find}.
     * 3. The character position of the first significant character of the value.
     * 4. A `RegExMatchInfo` object that has two subcapture groups:
     *   - char: The first significant character of the value in the JSON string.
     *   - name: The property name without quotes and still escaped.
     * 5. This parameter must be optional. When `CallbackObject` is called because `QuickParseEx.Find`
     * encountered an open bracket, this parameter is unset. In all other cases, this parameter
     * receives a `RegExMatchInfo` object. The object will always have at least two subcapture groups:
     *   - char: Either a comma or a closing bracket.
     *   - value: For string values, the value's substring without the external quote characters
     * (but still escaped). For other values, the value's unmodified substring.
     *
     * @param {*} CallbackCloseArray - A `Func` or callable object that is called whenever a closing
     * square bracket that ends a JSON array is encountered. See the notes in the description of
     * `QuickParseEx.Find` for some additional details.
     *
     * The function receives the following values:
     * 1. The `Controller` object. See the description above {@link QuickParseEx.Find}.
     * 2. The `Stack` array. See the description above {@link QuickParseEx.Find}.
     * 3. The character position of the closing bracket.
     *
     * @param {*} CallbackCloseObject - A `Func` or callable object that is called whenever a closing
     * curly bracket that ends a JSON object is encountered. See the notes in the description of
     * `QuickParseEx.Find` for some additional details.
     *
     * The function receives the following values:
     * 1. The `Controller` object. See the description above {@link QuickParseEx.Find}.
     * 2. The `Stack` array. See the description above {@link QuickParseEx.Find}.
     * 3. The character position of the closing bracket.
     *
     * @param {String} [Str] - The string to parse.
     * @param {String} [Path] - The path to the file that contains the JSON content to parse.
     * @param {String} [Encoding] - The file encoding to use if calling `QuickParseEx.Find` with `Path`.
     *
     * @returns {Integer} - The current position.
     */
    static Find(CallbackArray, CallbackObject, CallbackCloseArray, CallbackCloseObject, Str?, Path?, Encoding?) {
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

        if !IsSet(Str) {
            If IsSet(Path) {
                Str := FileRead(Path, Encoding ?? unset)
            } else {
                Str := A_Clipboard
            }
        }

        posCurly := InStr(Str, '{')
        posSquare := InStr(Str, '[')
        if posCurly {
            if posSquare {
                if posCurly > posSquare {
                    Pattern := ArrayItem
                    Pos := posSquare + 1
                } else {
                    Pattern := ObjectPropName
                    Pos := posCurly + 1
                }
            } else {
                Pattern := ObjectPropName
                Pos := posCurly + 1
            }
        } else if posSquare {
            Pattern := ArrayItem
            Pos := posSquare + 1
        } else {
            throw Error('Missing open bracket.', -1)
        }
        Controller := { Index: 0, Path: PathObj(), __Handler: (*) => '' }
        Stack := ['']
        flag_exit := false
        ; Used when unescaping json escape sequences.
        charOrd := 0xFFFD
        while InStr(Str, Chr(charOrd)) {
            charOrd++
        }
        ;@endregion

        while RegExMatch(Str, Pattern, &Match, Pos) {
            if flag_exit {
                return Pos
            }
        }

        return Pos

        ;@region Array Callbacks
        OnQuoteArr(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            ++Controller.Index
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ArrayString, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                _Throw(1, Pos)
            }
            if CallbackArray(Controller, Stack, Match.Pos['char'], Match, MatchValue) {
                flag_exit := true
            }
            _PrepareNextArr(MatchValue)
        }
        OnSquareOpenArr(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            ++Controller.Index
            Pos := Match.Pos + Match.Len
            if CallbackArray(Controller, Stack, Match.Pos['char'], Match) {
                flag_exit := true
            }
            if Match['close'] {
                _GetControllerArray(Controller.Index)
                if CallbackCloseArray(Controller, Stack, Pos - 1) {
                    flag_exit := true
                }
                Controller := Stack.Pop()
                _GetContextArray()
            } else {
                Controller.__Handler := _GetContextArray
                _GetControllerArray(Controller.Index)
            }
        }
        OnCurlyOpenArr(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            ++Controller.Index
            Pos := Match.Pos + Match.Len
            if CallbackArray(Controller, Stack, Match.Pos['char'], Match) {
                flag_exit := true
            }
            if Match['close'] {
                _GetControllerArray(Controller.Index)
                if CallbackCloseObject(Controller, Stack, Pos - 1) {
                    flag_exit := true
                }
                Controller := Stack.Pop()
                _GetContextArray()
            } else {
                Controller.__Handler := _GetContextArray
                _GetControllerArray(Controller.Index)
                Pattern := ObjectPropName
            }
        }
        OnFalseArr(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            ++Controller.Index
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ArrayFalse, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                _Throw(1, Pos)
            }
            if CallbackArray(Controller, Stack, Match.Pos['char'], Match, MatchValue) {
                flag_exit := true
            }
            _PrepareNextArr(MatchValue)
        }
        OnTrueArr(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            ++Controller.Index
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ArrayTrue, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                _Throw(1, Pos)
            }
            if CallbackArray(Controller, Stack, Match.Pos['char'], Match, MatchValue) {
                flag_exit := true
            }
            _PrepareNextArr(MatchValue)
        }
        OnNullArr(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            ++Controller.Index
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ArrayNull, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                _Throw(1, Pos)
            }
            if CallbackArray(Controller, Stack, Match.Pos['char'], Match, MatchValue) {
                flag_exit := true
            }
            _PrepareNextArr(MatchValue)
        }
        OnNumberArr(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            ++Controller.Index
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ArrayNumber, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                _Throw(1, Match.Pos)
            }
            if CallbackArray(Controller, Stack, Match.Pos['char'], Match, MatchValue) {
                flag_exit := true
            }
            _PrepareNextArr(MatchValue)
        }
        ;@endregion

        ;@region Object Callbacks
        OnQuoteObj(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            ++Controller.Index
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ObjectString, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                _Throw(1, Pos)
            }
            if CallbackObject(Controller, Stack, Match.Pos['char'], Match, MatchValue) {
                flag_exit := true
            }
            _PrepareNextObj(MatchValue)
        }
        OnSquareOpenObj(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            ++Controller.Index
            Pos := Match.Pos + Match.Len
            if CallbackObject(Controller, Stack, Match.Pos['char'], Match) {
                flag_exit := true
            }
            if Match['close'] {
                _GetControllerObject(Match)
                if CallbackCloseArray(Controller, Stack, Pos - 1) {
                    flag_exit := true
                }
                Controller := Stack.Pop()
                _GetContextObject()
            } else {
                Controller.__Handler := _GetContextObject
                _GetControllerObject(Match)
                Pattern := ArrayItem
            }
        }
        OnCurlyOpenObj(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            ++Controller.Index
            Pos := Match.Pos + Match.Len
            if CallbackObject(Controller, Stack, Match.Pos['char'], Match) {
                flag_exit := true
            }
            if Match['close'] {
                _GetControllerObject(Match)
                if CallbackCloseObject(Controller, Stack, Pos - 1) {
                    flag_exit := true
                }
                Controller := Stack.Pop()
                _GetContextObject()
            } else {
                Controller.__Handler := _GetContextObject
                _GetControllerObject(Match)
            }
        }
        OnFalseObj(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            ++Controller.Index
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ObjectFalse, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                _Throw(1, Pos)
            }
            if CallbackObject(Controller, Stack, Match.Pos['char'], Match, MatchValue) {
                flag_exit := true
            }
            _PrepareNextObj(MatchValue)
        }
        OnTrueObj(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            ++Controller.Index
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ObjectTrue, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                _Throw(1, Pos)
            }
            if CallbackObject(Controller, Stack, Match.Pos['char'], Match, MatchValue) {
                flag_exit := true
            }
            _PrepareNextObj(MatchValue)
        }
        OnNullObj(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            ++Controller.Index
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ObjectNull, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                _Throw(1, Pos)
            }
            if CallbackObject(Controller, Stack, Match.Pos['char'], Match, MatchValue) {
                flag_exit := true
            }
            _PrepareNextObj(MatchValue)
        }
        OnNumberObj(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            ++Controller.Index
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ObjectNumber, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                _Throw(1, Match.Pos)
            }
            if CallbackObject(Controller, Stack, Match.Pos['char'], Match, MatchValue) {
                flag_exit := true
            }
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
                if CallbackCloseArray(Controller, Stack, MatchCheck.Pos['char']) {
                    flag_exit := true
                }
                Controller := Stack.Pop()
                if !Controller {
                    return
                }
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
                if CallbackCloseObject(Controller, Stack, MatchCheck.Pos['char']) {
                    flag_exit := true
                }
                Controller := Stack.Pop()
                if !Controller {
                    return
                }
                Controller.__Handler.Call()
            } else {
                Pattern := ObjectPropName
            }
        }
        _GetControllerArray(Index) {
            Stack.Push(Controller)
            Controller := { Index: 0, Path: Controller.Path.MakeItem(Index) }
        }
        _GetControllerObject(Match) {
            Stack.Push(Controller)
            if InStr(Match['name'], '\') {
                Controller := { Index: 0, Path: Controller.Path.MakeProp(StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(Match['name'], '\\', Chr(charOrd)), '\n', '`n'), '\r', '`r'), '\"', '"'), '\t', '`t'), Chr(charOrd), '\')) }
            } else {
                Controller := { Index: 0, Path: Controller.Path.MakeProp(Match['name']) }
            }
        }
        _PrepareNextArr(MatchValue) {
            Pos := MatchValue.Pos + MatchValue.Len
            if MatchValue['char'] == ']' {
                if CallbackCloseArray(Controller, Stack, MatchValue.Pos['char']) {
                    flag_exit := true
                }
                Controller := Stack.Pop()
                if !Controller {
                    return
                }
                Controller.__Handler.Call()
            }
        }
        _PrepareNextObj(MatchValue) {
            Pos := MatchValue.Pos + MatchValue.Len
            if MatchValue['char'] == '}' {
                if CallbackCloseObject(Controller, Stack, MatchValue.Pos['char']) {
                    flag_exit := true
                }
                Controller := Stack.Pop()
                if !Controller {
                    return
                }
                Controller.__Handler.Call()
            }
        }
        _Throw(Code, Extra?, n := -2) {
            switch Code, 0 {
                case '1': throw Error('There is an error in the JSON string.', n, IsSet(Extra) ? 'Near pos: ' Extra : '')
            }
        }
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
            ArrayItem: 'JS)\s*' Format(SignificantChars, 'Arr')
          , ArrayNumber: 'S)(?<value>(?<n>(?:-?\d++(?:\.\d++)?)(?:[eE][+-]?\d++)?))' ArrayNextChar
          , ArrayString: 'S)(?<=[,:[{\s])"(?<value>.*?(?<!\\)(?:\\\\)*+)"(*COMMIT)' ArrayNextChar
          , ArrayFalse: 'S)(?<value>false)' ArrayNextChar
          , ArrayTrue: 'S)(?<value>true)' ArrayNextChar
          , ArrayNull: 'S)(?<value>null)' ArrayNextChar
          , ArrayNextChar: 'S)' ArrayNextChar
          , ObjectPropName: 'JS)\s*"(?<name>.*?(?<!\\)(?:\\\\)*+)"(*COMMIT):\s*' Format(SignificantChars, 'Obj')
          , ObjectNumber: 'S)(?<value>(?<n>-?\d++(?:\.\d++)?)(?<e>[eE][+-]?\d++)?)' ObjectNextChar
          , ObjectString: 'S)(?<=[,:[{\s])"(?<value>.*?(?<!\\)(?:\\\\)*+)"(*COMMIT)' ObjectNextChar
          , ObjectFalse: 'S)(?<value>false)' ObjectNextChar
          , ObjectTrue: 'S)(?<value>true)' ObjectNextChar
          , ObjectNull: 'S)(?<value>null)' ObjectNextChar
          , ObjectNextChar: 'S)' ObjectNextChar
        }
    }
}

/**
 * @classdesc - `JsonValueFinder` is a helper class that simplifies using `QuickParseEx.Find` to
 * find root-level properties by name. `JsonValueFinder` cannot be used to find anything else.
 */
class JsonValueFinder extends Map {
    /**
     * - Only one of `Str` or `Path` are necessary.
     * - Instances of `JsonValueFinder` are `Map` objects. To use, first create the object then
     * call the object.
     * @see {@link JsonValueFinder#Call} for further details.
     * @class
     * @param {String} [Str] - The JSON string.
     * @param {String} [Path] - The path to the file containing the JSON string.
     * @param {String} [Encoding] - The encoding to use when reading `Path`.
     * @param {String} [CaseSense = false] - The value to set to `JsonValueFinderObj.CaseSense`.
     * This also gets applied to `JsonValueFinderObj.Nams` when `JsonValueFinder.Prototype.Call`
     * is called.
     */
    __New(Str?, Path?, Encoding?, CaseSense := false) {
        if IsSet(Str) {
            this.SetPrototype({ Content: Str })
        } else {
            this.SetPrototype({ Content: FileRead(Path, Encoding ?? unset) })
        }
        this.CaseSense := CaseSense
    }
    /**
     * @description - Finds one or more root-level properties by name.
     *
     * After `JsonValueFinder.Prototype.Call` returns, you can check the `JsonValueFinderObj.Names`
     * property for any properties that were not found. During the course of
     * `JsonValueFinder.Prototype.Call`, each time a name is found it is removed from
     * `JsonValueFinderObj.Names` and added to `JsonValueFinderObj`. If all names were found,
     * `JsonValueFinderObj.Names.Count == 0` and `JsonValueFinderObj.Count == <the quantity of names
     * included in the `Names` parameter>`.
     *
     * The "keys" are the names themselves, and the values are instances of one of `FindValueObject`,
     * `FindValuePrimitive`, or `FindValueString`.
     *
     * If `JsonValueFinderObj.Names` is already set from a previous call, it is overwritten when
     * `JsonValueFinder.Prototype.Call` is called again.
     *
     * @example
     *  json := '{ "prop1": "val1", "prop2": { "prop3": "val3" }, "prop4": [ "val4" ] }'
     *  finder := JsonValueFinder(json)
     *  names := ['prop1', 'prop2', 'prop3', 'prop4']
     *  finder(names)
     *  ; 1 name was not found, "prop3", because it is not a property of the root object.
     *  OutputDebug(finder.Names.Count '`n') ; 1
     *  OutputDebug(finder.Names.Has('prop3') '`n') ; 1
     *  ; 3 names were successfully found.
     *  OutputDebug(finder.Count) ; 3
     *  ; Get the substring with the `Value` property.
     *  OutputDebug(finder.Get('prop1').Value '`n') ; "val1"
     *  OutputDebug(finder.Get('prop2').Value '`n') ; { "prop3": "val3" }
     *  OutputDebug(finder.Get('prop4').Value '`n') ; [ "val4" ]
     *  ; Also available `NameLen` and `ValueLen`.
     *  OutputDebug(finder.Get('prop1').NameLen '`n') ; 5
     *  OutputDebug(finder.Get('prop1').ValueLen '`n') ; 6
     * @
     * @param {String|*} Names - Either a single name as string, or an object that returns the names
     * when called in a `for` loop (such as an array or map object). If `Names` is a `Map` object,
     * and if the `Names.CaseSense !== JsonValueFinderObj.CaseSense`, a new `Map` object is created
     * and the names are added from `Names` to the new object.
     */
    Call(Names) {
        this.Result := ''
        if Names is Map && Names.CaseSense == this.CaseSense {
            this.Names := Names
        } else if IsObject(Names) {
            if HasMethod(Names, '__Enum') {
                m := Map()
                m.CaseSense := this.CaseSense = 'On' ? 1 : 0
                for name in Names {
                    if m.Has(name) {
                        throw Error('Duplicate name included in ``Names``.', -1, name)
                    }
                    m.Set(name, 1)
                }
                this.Names := m
            } else {
                throw Error('If ``Names`` is an object, it must have a method ``__Enum``.', -1)
            }
        } else {
            this.Names := Map()
            this.Names.CaseSense := this.CaseSense = 'On' ? 1 : 0
            this.Names.Set(Names, 1)
        }
        QuickParseEx.Find(
            (*) => ''
          , ObjBindMethod(this, 'CallbackObject')
          , ObjBindMethod(this, 'CallbackClose')
          , ObjBindMethod(this, 'CallbackClose')
          , this.Proto.Content
        )
    }
    CallbackClose(Controller, Stack, Pos) {
        if Stack.Length == 2 && this.Result {
            this.Result.ValueEnd := Pos + 1
            this.Set(this.Result.Name, this.Result)
            if this.Names.Count {
                this.Result := ''
            } else {
                this.DeleteProp('Result')
                return 1
            }
        }
    }
    CallbackObject(Controller, Stack, Pos, Match, MatchValue?) {
        if !this.Result && Stack.Length == 1 && this.Names.Has(Match['name']) {
            if IsSet(MatchValue) {
                ; primitive value
                if Match['char'] == '"' {
                    ; quoted string
                    this.Names.Delete(Match['name'])
                    _obj := { Match: Match, ValueEnd: MatchValue.Pos['value'] + MatchValue.Len['value'] + 1, ValueStart: MatchValue.Pos['value'] - 1, Index: Controller.Index, Path: Controller.Path }
                    this.Set(Match['name'], _obj)
                    ObjSetBase(_obj, this.Proto)
                    if !this.Names.Count {
                        this.DeleteProp('Result')
                        return 1
                    }
                } else {
                    this.Names.Delete(Match['name'])
                    _obj := { Match: Match, ValueEnd: MatchValue.Pos['value'] + MatchValue.Len['value'], ValueStart: MatchValue.Pos['value'], Index: Controller.Index, Path: Controller.Path }
                    this.Set(Match['name'], _obj)
                    ObjSetBase(_obj, this.Proto)
                    if !this.Names.Count {
                        this.DeleteProp('Result')
                        return 1
                    }
                }
            } else if Match['char'] == '{' {
                this.Names.Delete(Match['name'])
                this.Result := { Match: Match, ValueStart: Match.Pos['char'], Index: Controller.Index, Path: Controller.Path }
                ObjSetBase(this.Result, this.Proto)
            } else {
                ; open square bracket
                this.Names.Delete(Match['name'])
                this.Result := { Match: Match, ValueStart: Match.Pos['char'], Index: Controller.Index, Path: Controller.Path }
                ObjSetBase(this.Result, this.Proto)
            }
        }
    }
    SetPrototype(protoBase) {
        ObjSetBase(protoBase, FindValueBase.Prototype)
        this.Proto := protoBase
    }

    Content => this.Proto.Content
}

class FindValueBase {
    Name => this.Match['name']
    NameEnd => this.Match.Pos['name'] + this.Match.Len['name']
    NameLen => this.Match.Len['name']
    NameStart => this.Match.Pos['name']
    Value => SubStr(this.Content, this.ValueStart, this.ValueLen)
    ValueLen => this.ValueEnd - this.ValueStart
}
