/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/QuickParseEx.ahk
    Author: Nich-Cebolla
    Version: 1.1.1
    License: MIT
*/
; Required for `QuickParseEx.Find`.
; https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/FillStr.ahk
#include *i <FillStr>

/**
 * @classdesc - Parses a JSON string into objects defined by callback functions.
 * - The parameter that receives the value to be set to the object should be optional, because
 * when the value is "null", the parameter will be unset.
 *   - When encountering a "false" value in the JSON string, the parameter that receives the value
 * will receive `0`.
 *   - When encountering a "null" value in the JSON string, the parameter that receives the value
 * will be unset.
 *   - When encountering a "true" value in the JSON string, the parameter that receives the value
 * will receive `1`.
 *   - Unquoted numeric values are passed to `Number()`.
 *   - Quoted numbers are processed as strings.
 *   - Escape sequences are un-escaped and external quotations are removed from JSON string values.
 */
class QuickParseEx {
    /**
     * `QuickParseEx` does not support comments at this time.
     */
    ; static PatternRemoveComment := 's)(?://.*|(?:\R|^)[ \t]*/\*[\w\W]*?\*/[ \t]*)'

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
     * - If `CallbackSetterArray` or `CallbackSetterObject` return a nonzero value, `QuickParseEx`
     * will return after completing the current action.
     * - See "test-files\test-QuickParseEx.Call.ahk" for a usage example.
     * - Only one of `Str` or `Path` are needed. If `Str` is set, `Path` is ignored. If both `Str`
     * and `Path` are unset, the clipboard's contents are used.
     * @param {*} Root - The root object.
     * @param {*} CallbackConstructorArray - A `Func` or callable object that is called when encountering
     * an open square bracket. The function receives one value: the current depth. The function should
     * return the array object.
     * @param {*} CallbackConstructorObject - A `Func` or callable object that is called when encountering
     * an open curly bracket. The function receives one value: the current depth. The function should
     * return the object.
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
        static ArrayItem := QuickParseEx.Patterns.ArrayItem1
        , ObjectPropName := QuickParseEx.Patterns.ObjectPropName1
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
        flag_exit := false
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
                if CallbackSetterArray(Obj, Stack.Length, StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(MatchValue['value'], '\n', '`n'), '\r', '`r'), '\"', '"'), '\t', '`t'), '\\', '\')) {
                    flag_exit := true
                }
            } else if MatchValue['value'] && MatchValue['value'] !== '""' {
                if CallbackSetterArray(Obj, Stack.Length, MatchValue['value']) {
                    flag_exit := true
                }
            } else {
                if CallbackSetterArray(Obj, Stack.Length, '') {
                    flag_exit := true
                }
            }
            _PrepareNextArr(MatchValue)
        }
        OnSquareOpenArr(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len - 1
            if CallbackSetterArray(Obj, Stack.Length, CallbackConstructorArray(Stack.Length)) {
                flag_exit := true
            }
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
            if CallbackSetterArray(Obj, Stack.Length, CallbackConstructorObject(Stack.Length)) {
                flag_exit := true
            }
            if !RegExMatch(Str, ObjectInitialCheck, &MatchCheck, Pos) || MatchCheck.Pos !== Pos + 1 {
                _Throw(1, Pos)
            }
            if MatchCheck['char'] == '}' {
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
            if CallbackSetterArray(Obj, Stack.Length, 0) {
                flag_exit := true
            }
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
            if CallbackSetterArray(Obj, Stack.Length, 1) {
                flag_exit := true
            }
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
            if CallbackSetterArray(Obj, Stack.Length, unset) {
                flag_exit := true
            }
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
            if CallbackSetterArray(Obj, Stack.Length, Number(MatchValue['value'])) {
                flag_exit := true
            }
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
            if InStr(MatchValue['value'], '\') {
                if CallbackSetterObject(Obj, Match, Stack.Length, StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(MatchValue['value'], '\n', '`n'), '\r', '`r'), '\"', '"'), '\t', '`t'), '\\', '\')) {
                    flag_exit := true
                }
            } else if MatchValue['value'] && MatchValue['value'] !== '""' {
                if CallbackSetterObject(Obj, Match, Stack.Length, MatchValue['value']) {
                    flag_exit := true
                }
            } else {
                if CallbackSetterObject(Obj, Match, Stack.Length, '') {
                    flag_exit := true
                }
            }
            _PrepareNextObj(MatchValue)
        }
        OnSquareOpenObj(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len - 1
            if CallbackSetterObject(Obj, Match, Stack.Length, _obj := CallbackConstructorArray(Stack.Length)) {
                flag_exit := true
            }
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
            if CallbackSetterObject(Obj, Match, Stack.Length, _obj :=  CallbackConstructorObject(Stack.Length)) {
                flag_exit := true
            }
            if !RegExMatch(Str, ObjectInitialCheck, &MatchCheck, Pos) || MatchCheck.Pos !== Pos + 1 {
                _Throw(1, Pos)
            }
            if MatchCheck['char'] == '}' {
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
            if CallbackSetterObject(Obj, Match, Stack.Length, 0) {
                flag_exit := true
            }
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
            if CallbackSetterObject(Obj, Match, Stack.Length, 1) {
                flag_exit := true
            }
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
            if CallbackSetterObject(Obj, Match, Stack.Length, '') {
                flag_exit := true
            }
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
            if CallbackSetterObject(Obj, Match, Stack.Length, Number(MatchValue['value'])) {
                flag_exit := true
            }
            _PrepareNextObj(MatchValue)
        }
        ;@endregion

        ;@region Helper Funcs
        _GetContextArray() {
            if !RegExMatch(Str, ArrayNextChar, &Match, Pos) || Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len
            if Match['char'] == ',' {
                Pattern := ArrayItem
            } else if Match['char'] == ']' {
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
            if Match['char'] == ',' {
                Pattern := ObjectPropName
            } else if Match['char'] == '}' {
                if Stack.Length {
                    Active := Stack.Pop()
                    Obj := Active.Obj
                    Active.Handler.Call()
                }
            }
        }
        _PrepareNextArr(MatchValue) {
            Pos := MatchValue.Pos + MatchValue.Len
            if MatchValue['char'] == ']' {
                if Stack.Length {
                    Active := Stack.Pop()
                    Obj := Active.Obj
                    Active.Handler.Call()
                }
            }
        }
        _PrepareNextObj(MatchValue) {
            Pos := MatchValue.Pos + MatchValue.Len
            if MatchValue['char'] == '}' {
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
    /**
     * - `QuickParseEx.Find` can be used to locate the character position of a property or value in
     * a JSON string. It uses the same parsing logic as `QuickParseEx.Call`, but does not actually
     * create the objects.
     * - Only one of `Str` or `Path` are needed. If `Str` is set, `Path` is ignored. If both `Str`
     * and `Path` are unset, the clipboard's contents are used.
     * - The callback functions each receive the `Stack` array. The values in the array are objects.
     * You can add properties to the objects but do not change or remove the property { __Handler }.
     * The current depth is represented by `Stack.Length`.
     * - If either callback function returns a nonzero value, `QuickParseEx.Find` will return after
     * completing the current action.
     * - This is how you should handle the fourth parameter:
     * @example
     *  Callback(Stack, Pos, Match, MatchValue?) {
     *      if IsSet(MatchValue) {
     *          ; The "char" subcapture group is always available.
     *          DoSomethingChar(MatchValue["char"])
     *          if !MatchValue.Mark {
     *              ; The "value" subcapture group is available
     *              ; only if `MatchValue.Mark` is an empty string
     *              DoSomethingWithValue(MatchValue["value"])
     *          }
     *      }
     *  }
     * @
     * - The reason there is not a `CallbackOpenArray` or `CallbackOpenObject` is because those
     * are handled by `CallbackArray` and `CallbackObject`.
     * - To get a grasp on what values are represented by either `RegExMatchInfo` object passed to
     * the callback functions, you can run "test-files\test-QuickParseEx.Find.ahk" with a debugger.
     * Set breakpoints on the five `sleep 1` statements and have the "test-files\example.json" opened
     * in another window. Follow along in the "example.json" with what you see in the `RegExMatchInfo`
     * objects. Here is a short example written out:
     * @example
     *  str := '{ "prop": ["\n", "\"", -5e-5 ], "prop2": { "prop2_1": 0.12, "prop2_2": null } }'
     * @
     * - 1. CallbackObject:
     *   - 1st parameter: Stack.Length == 0
     *   - 2nd parameter: 11, the position of the open "["
     *   - 3rd parameter: "name" = "prop"; "char" = "["
     *   - 4th parameter: unset
     * - 2. CallbackArray:
     *   - 1st parameter: Stack.Length == 1
     *   - 2nd parameter: 12, the position of "`"" after "["
     *   - 3rd parameter: "char" = "`""
     *   - 4th parameter: "value" = "\n"; "char" = ","
     * - 3. CallbackArray:
     *   - 1st parameter: Stack.Length == 1
     *   - 2nd parameter: 18, the position of "`"" after ", "
     *   - 3rd parameter: "char" = "`""
     *   - 4th parameter: "value" = "\`""; "char" = ","
     * - 4. CallbackArray:
     *   - 1st parameter: Stack.Length == 1
     *   - 2nd parameter: 24, the position of "-" after ", "
     *   - 3rd parameter: "char" = "-"
     *   - 4th parameter: "value" = "-5e-5"; "char" = "]"
     * - 5. CallbackCloseArray:
     *   - 1st parameter: Stack.Length == 1
     *   - 2nd parameter: 30, the position of "]"
     *   - 3rd parameter: "char" = "]"
     * - 6. CallbackObject:
     *   - 1st parameter: Stack.Length == 0
     *   - 2nd parameter: 42, the position of "{" after "`"prop2`": "
     *   - 3rd parameter: "name" = "prop2"; "char" = "{"
     *   - 4th parameter: Match.Mark == "novalue"; "char" = "`"", which is the open quote before "prop2_1"
     * - 7. CallbackObject:
     *   - 1st parameter: Stack.Length == 1
     *   - 2nd parameter: 55, the position of "0"
     *   - 3rd parameter: "name" = "prop2_1"; "char" = "0"
     *   - 4th parameter: "value" = "0.12"; "char" = ","
     * - 8. CallbackObject:
     *   - 1st parameter: Stack.Length == 1
     *   - 2nd parameter: 72, the position of "n"
     *   - 3rd parameter: "name" = "prop2_2"; "char" = "n"
     *   - 4th parameter: "value" = "null"; "char" = "}"
     * - 9. CallbackCloseObject:
     *   - 1st parameter: Stack.Length == 1
     *   - 2nd parameter: 77, the position of "}"
     *   - 3rd parameter: "char" = "}"
     * - 10. CallbackCloseObject:
     *   - 1st parameter: Stack.Length == 0
     *   - 2nd parameter: 79, the position of "}"
     *   - 3rd parameter: "char" = "}"
     * @param {*} CallbackArray - A `Func` or callable object that is called for each value
     * in a JSON array. The function does not need to return anything. Returning a nonzero
     * value will direct `QuickParseEx.Find` to return. See the notes in the description of
     * `QuickParseEx.Find` for some additional details. The function receives the following values:
     * - The `Stack` array.
     * - The character position of the first significant character of the value's substring. This is
     * the position of the "char" subcapture group indicated in paramter #3 below.
     * - A `RegExMatchInfo` object that has a subcapture group "char". The "char" subcapture group
     * returns the first significant character of the value in the JSON string.
     * - The fourth parameter must be optional. A `RegExMatchInfo` object that always has subcapture
     * group "char" and sometimes has subcapture group "value". "char" returns the next significant
     * character in the JSON string after the value (and after the closing quotation mark if the
     * value is a quoted string). To determine whether the object has subcapture group "value", you
     * can check the `Mark` property. If the `Mark` property returns an empty string, then the "value"
     * subcapture group is available. If the `Mark` property returns "novalue", then the "value"
     * subcapture group is not available.
     * @param {*} CallbackObject - A `Func` or callable object that is called for each value
     * that is a property of a JSON object. The function does not need to return anything. Returning
     * a nonzero value will direct `QuickParseEx.Find` to return. See the notes in the description of
     * `QuickParseEx.Find` for some additional details. The function receives the following values:
     * - The `Stack` array.
     * - The character position of the first significant character of the value's substring. This is
     * the position of the "char" subcapture group indicated in paramter #3 below.
     * - A `RegExMatchInfo` object that has subcapture groups "char" and "name". The "char" subcapture
     * group returns the first significant character of the value in the JSON string.
     * - The fourth parameter must be optional. A `RegExMatchInfo` object that always has subcapture
     * group "char" and sometimes has subcapture group "value". "char" returns the next significant
     * character in the JSON string after the value (and after the closing quotation mark if the
     * value is a quoted string). To determine whether the object has subcapture group "value", you
     * can check the `Mark` property. If the `Mark` property returns an empty string, then the "value"
     * subcapture group is available. If the `Mark` property returns "novalue", then the "value"
     * subcapture group is not available.
     * @param {*} CallbackCloseArray - A `Func` or callable object that is called whenever a closing
     * square bracket that ends a JSON array is encountered. The function does not need to return
     * anything. Returning a nonzero value will direct `QuickParseEx.Find` to return. See the notes
     * in the description of `QuickParseEx.Find` for some additional details. The function receives
     * the following values:
     * - The `Stack` array. `Stack.Length` is equal to the depth before removing the active object
     * from the stack.
     * - The character position of the closing bracket.
     * - A `RegExMatchInfo` object that has a subcapture group "char". The "char" subcapture group
     * returns the closing bracket, which will always be a closing square bracket. The object will
     * sometimes be the same object that is passed to parameter 4 of `CallbackArray` or
     * `CallbackObject`. The other subcapture groups will vary; to use them, call the object in a
     * `for` loop, e.g. `for name, value in Match`.
     * @param {*} CallbackCloseObject - A `Func` or callable object that is called whenever a closing
     * curly bracket that ends a JSON object is encountered. The function does not need to return
     * anything. Returning a nonzero value will direct `QuickParseEx.Find` to return. See the notes
     * in the description of `QuickParseEx.Find` for some additional details. The function receives
     * the following values:
     * - The `Stack` array. `Stack.Length` is equal to the depth before removing the active object
     * from the stack.
     * - The character position of the closing bracket.
     * - A `RegExMatchInfo` object that has a subcapture group "char". The "char" subcapture group
     * returns the closing bracket, which will always be a closing curly bracket. The object will
     * sometimes be the same object that is passed to parameter 4 of `CallbackArray` or
     * `CallbackObject`. The other subcapture groups will vary; to use them, call the object in a
     * `for` loop, e.g. `for name, value in Match`.
     * @param {String} [Str] - The string to parse.
     * @param {String} [Path] - The path to the file that contains the JSON content to parse.
     * @param {String} [Encoding] - The file encoding to use if calling `QuickParseEx.Find` with `Path`.
     * @returns {*}
     */
    static Find(CallbackArray, CallbackObject, CallbackCloseArray, CallbackCloseObject, Str?, Path?, Encoding?) {
        ;@region Initialization
        static ArrayItem := QuickParseEx.Patterns.ArrayItem2
        , ObjectPropName := QuickParseEx.Patterns.ObjectPropName2
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

        if !IsSet(FillStr) {
            throw Error('The library ``FillStr.ahk`` must be loaded to use ``QuickParseEx.Find``.', -1)
        }

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
        flag_exit := false
        ;@endregion

        while RegExMatch(Str, Pattern, &Match, Pos) {
            if pos >= 4700 {
                sleep 1
            }
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
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ArrayString, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                _Throw(1, Pos)
            }
            if CallbackArray(Stack, Match.Pos['char'], Match, MatchValue) {
                flag_exit := true
            }
            _PrepareNextArr(MatchValue)
        }
        OnSquareOpenArr(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len - 1
            if CallbackArray(Stack, Match.Pos['char'], Match) {
                flag_exit := true
            }
            Stack.Push({ __Handler: _GetContextArray })
            Pattern := ArrayItem
            Pos++
        }
        OnCurlyOpenArr(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ObjectInitialCheck, &MatchCheck, Pos) || MatchCheck.Pos !== Pos + 1 {
                _Throw(1, Pos)
            }
            if CallbackArray(Stack, Match.Pos['char'], Match, MatchCheck) {
                flag_exit := true
            }
            if MatchCheck['char'] == '}' {
                Pos := MatchCheck.Pos + MatchCheck.Len
                _GetContextArray()
            } else {
                Pos++
                Pattern := ObjectPropName
                Stack.Push({ __Handler: _GetContextArray })
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
            if CallbackArray(Stack, Match.Pos['char'], Match, MatchValue) {
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
            if CallbackArray(Stack, Match.Pos['char'], Match, MatchValue) {
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
            if CallbackArray(Stack, Match.Pos['char'], Match, MatchValue) {
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
            if CallbackArray(Stack, Match.Pos['char'], Match, MatchValue) {
                flag_exit := true
            }
            _PrepareNextArr(MatchValue)
        }
        OnSquareCloseArr(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            if CallbackArray(Stack, Match.Pos['char'], Match) {
                flag_exit := true
            }
            Pos := Match.Pos + Match.Len
            if Stack.Length {
                Active := Stack.Pop()
                Active.__Handler.Call()
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
            if CallbackObject(Stack, Match.Pos['char'], Match, MatchValue) {
                flag_exit := true
            }
            _PrepareNextObj(MatchValue)
        }
        OnSquareOpenObj(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len - 1
            if CallbackObject(Stack, Match.Pos['char'], Match) {
                flag_exit := true
            }
            Stack.Push({ __Handler: _GetContextObject })
            Pattern := ArrayItem
            Pos++
        }
        OnCurlyOpenObj(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ObjectInitialCheck, &MatchCheck, Pos) || MatchCheck.Pos !== Pos + 1 {
                _Throw(1, Pos)
            }
            if CallbackObject(Stack, Match.Pos['char'], Match, MatchCheck) {
                flag_exit := true
            }
            if MatchCheck['char'] == '}' {
                Pos := MatchCheck.Pos + MatchCheck.Len
                _GetContextObject()
            } else {
                Pos++
                Stack.Push({ __Handler: _GetContextObject })
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
            if CallbackObject(Stack, Match.Pos['char'], Match, MatchValue) {
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
            if CallbackObject(Stack, Match.Pos['char'], Match, MatchValue) {
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
            if CallbackObject(Stack, Match.Pos['char'], Match, MatchValue) {
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
            if CallbackObject(Stack, Match.Pos['char'], Match, MatchValue) {
                flag_exit := true
            }
            _PrepareNextObj(MatchValue)
        }
        ;@endregion

        ;@region Helper Funcs
        _GetContextArray() {
            if !RegExMatch(Str, ArrayNextChar, &Match, Pos) || Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len
            if Match['char'] == ',' {
                Pattern := ArrayItem
            } else if Match['char'] == ']' {
                if CallbackCloseArray(Stack, Match.Pos['char'], Match) {
                    flag_exit := true
                }
                if Stack.Length {
                    Stack.Pop().__Handler.Call()
                }
            }
        }
        _GetContextObject() {
            if !RegExMatch(Str, ObjectNextChar, &Match, Pos) || Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len
            if Match['char'] == ',' {
                Pattern := ObjectPropName
            } else if Match['char'] == '}' {
                if CallbackCloseObject(Stack, Match.Pos['char'], Match) {
                    flag_exit := true
                }
                if Stack.Length {
                    Stack.Pop().__Handler.Call()
                }
            }
        }
        _PrepareNextArr(MatchValue) {
            Pos := MatchValue.Pos + MatchValue.Len
            if MatchValue['char'] == ']' {
                if CallbackCloseArray(Stack, MatchValue.Pos['char'], MatchValue) {
                    flag_exit := true
                }
                if Stack.Length {
                    Stack.Pop().__Handler.Call()
                }
            }
        }
        _PrepareNextObj(MatchValue) {
            Pos := MatchValue.Pos + MatchValue.Len
            if MatchValue['char'] == '}' {
                if CallbackCloseObject(Stack, MatchValue.Pos['char'], MatchValue) {
                    flag_exit := true
                }
                if Stack.Length {
                    Stack.Pop().__Handler.Call()
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

    /**
     * - `QuickParseEx.Call2` follows the same parsing logic as `QuickParseEx.Call`, but the callback
     * functions receive the same values as `QuickParseEx.Find` in addition to receiving the object
     * being constructed.
     * @see {@link QuickParseEx.Call}.
     * @see {@link QuickParseEx.Find}.
     * - This is how you should handle the fourth parameter:
     * @example
     *  CallbackSetter(Stack, Obj, Match, MatchValue?) {
     *      if IsSet(MatchValue) {
     *          ; The "char" subcapture group is always available.
     *          DoSomethingChar(MatchValue["char"])
     *          if !MatchValue.Mark {
     *              ; The "value" subcapture group is available
     *              ; only if `MatchValue.Mark` is an empty string
     *              DoSomethingWithValue(MatchValue["value"])
     *          }
     *      }
     *  }
     * @
     * @param {*} Root - The root object.
     * @param {*} CallbackConstructorArray - A `Func` or callable object that is called when
     * encountering an open square bracket. The function should return the array object.
     * The function receives:
     * - The `Stack` array.
     * - A `RegExMatchInfo` object that has a subcapture group "char". The "char" subcapture group
     * returns the first significant character of the value in the JSON string. This main use for
     * this parameter is to check the position of the open bracket, i.e. `Match.Pos["char"]`.
     * @param {*} CallbackConstructorObject - A `Func` or callable object that is called when
     * encountering an open curly bracket. The function should return the object.
     * The function receives:
     * - The `Stack` array.
     * - A `RegExMatchInfo` object that has a subcapture group "char". The "char" subcapture group
     * returns the first significant character of the value in the JSON string. This main use for
     * this parameter is to check the position of the open bracket, i.e. `Match.Pos["char"]`.
     * @param {*} CallbackSetterArray - A `Func` or callable object that is called when setting a
     * value from a JSON array. The function receives the following values:
     * - The array object currently being constructed.
     * - The `Stack` array.
     * - A `RegExMatchInfo` object that has a subcapture group "char". The "char" subcapture group
     * returns the first significant character of the value in the JSON string.
     * - The fourth parameter must be optional. A `RegExMatchInfo` object that always has subcapture
     * group "char" and sometimes has subcapture group "value". "char" returns the next significant
     * character in the JSON string after the value (and after the closing quotation mark if the
     * value is a quoted string). To determine whether the object has subcapture group "value", you
     * can check the `Mark` property. If the `Mark` property returns an empty string, then the "value"
     * subcapture group is available. If the `Mark` property returns "novalue", then the "value"
     * subcapture group is not available.
     * - The fifth parameter must be optional. The fifth parameter receives the value that is to be
     * set to the object. See the description above {@link QuickParseEx}.
     * @param {*} CallbackSetterObject - A `Func` or callable object that is called when setting a
     * value from a JSON object property. The function receives the following values:
     * - The object currently being constructed.
     * - The `Stack` array.
     * - A `RegExMatchInfo` object that has subcapture groups "char" and "name". The "char" subcapture
     * group returns the first significant character of the value in the JSON string.
     * - The fourth parameter must be optional. A `RegExMatchInfo` object that always has subcapture
     * group "char" and sometimes has subcapture group "value". "char" returns the next significant
     * character in the JSON string after the value (and after the closing quotation mark if the
     * value is a quoted string). To determine whether the object has subcapture group "value", you
     * can check the `Mark` property. If the `Mark` property returns an empty string, then the "value"
     * subcapture group is available. If the `Mark` property returns "novalue", then the "value"
     * subcapture group is not available.
     * - The fifth parameter must be optional. The fifth parameter receives the value that is to be
     * set to the object. See the description above {@link QuickParseEx}.
     * @param {String} [Str] - The string to parse.
     * @param {String} [Path] - The path to the file that contains the JSON content to parse.
     * @param {String} [Encoding] - The file encoding to use if calling `QuickParse` with `Path`.
     * @returns {*}
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
        static ArrayItem := QuickParseEx.Patterns.ArrayItem2
        , ObjectPropName := QuickParseEx.Patterns.ObjectPropName2
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
        flag_exit := false
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
                if CallbackSetterArray(Obj, Stack, Match, MatchValue, StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(MatchValue['value'], '\n', '`n'), '\r', '`r'), '\"', '"'), '\t', '`t'), '\\', '\')) {
                    flag_exit := true
                }
            } else if MatchValue['value'] && MatchValue['value'] !== '""' {
                if CallbackSetterArray(Obj, Stack, Match, MatchValue, MatchValue['value']) {
                    flag_exit := true
                }
            } else {
                if CallbackSetterArray(Obj, Stack, Match, MatchValue, '') {
                    flag_exit := true
                }
            }
            _PrepareNextArr(MatchValue)
        }
        OnSquareOpenArr(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len - 1
            if CallbackSetterArray(Obj, Stack, Match, , CallbackConstructorArray(Stack, Match)) {
                flag_exit := true
            }
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
            if !RegExMatch(Str, ObjectInitialCheck, &MatchCheck, Pos) || MatchCheck.Pos !== Pos + 1 {
                _Throw(1, Pos)
            }
            if CallbackSetterArray(Obj, Stack, Match, MatchCheck, CallbackConstructorObject(Stack, Match)) {
                flag_exit := true
            }
            if MatchCheck['char'] == '}' {
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
            if !RegExMatch(Str, ArrayFalse, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                _Throw(1, Pos)
            }
            if CallbackSetterArray(Obj, Stack, Match, MatchValue, 0) {
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
            if CallbackSetterArray(Obj, Stack, Match, MatchValue, 1) {
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
            if CallbackSetterArray(Obj, Stack, Match, MatchValue, unset) {
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
            if CallbackSetterArray(Obj, Stack, Match, MatchValue, Number(MatchValue['value'])) {
                flag_exit := true
            }
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
            if InStr(MatchValue['value'], '\') {
                if CallbackSetterObject(Obj, Stack, Match, MatchValue, StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(MatchValue['value'], '\n', '`n'), '\r', '`r'), '\"', '"'), '\t', '`t'), '\\', '\')) {
                    flag_exit := true
                }
            } else if MatchValue['value'] && MatchValue['value'] !== '""' {
                if CallbackSetterObject(Obj, Stack, Match, MatchValue, MatchValue['value']) {
                    flag_exit := true
                }
            } else {
                if CallbackSetterObject(Obj, Stack, Match, MatchValue, '') {
                    flag_exit := true
                }
            }
            _PrepareNextObj(MatchValue)
        }
        OnSquareOpenObj(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len - 1
            _obj := CallbackConstructorArray(Stack, Match)
            if CallbackSetterObject(Obj, Stack, Match, , _obj) {
                flag_exit := true
            }
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
            if !RegExMatch(Str, ObjectInitialCheck, &MatchCheck, Pos) || MatchCheck.Pos !== Pos + 1 {
                _Throw(1, Pos)
            }
            _obj :=  CallbackConstructorObject(Stack, Match)
            if CallbackSetterObject(Obj, Stack, Match, MatchCheck, _obj) {
                flag_exit := true
            }
            if MatchCheck['char'] == '}' {
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
            if !RegExMatch(Str, ObjectFalse, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                _Throw(1, Pos)
            }
            if CallbackSetterObject(Obj, Stack, Match, MatchValue, 0) {
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
            if CallbackSetterObject(Obj, Stack, Match, MatchValue, 1) {
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
            if CallbackSetterObject(Obj, Stack, Match, MatchValue, unset) {
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
            if CallbackSetterObject(Obj, Stack, Match, MatchValue, Number(MatchValue['value'])) {
                flag_exit := true
            }
            _PrepareNextObj(MatchValue)
        }
        ;@endregion

        ;@region Helper Funcs
        _GetContextArray() {
            if !RegExMatch(Str, ArrayNextChar, &Match, Pos) || Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len
            if Match['char'] == ',' {
                Pattern := ArrayItem
            } else if Match['char'] == ']' {
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
            if Match['char'] == ',' {
                Pattern := ObjectPropName
            } else if Match['char'] == '}' {
                if Stack.Length {
                    Active := Stack.Pop()
                    Obj := Active.Obj
                    Active.Handler.Call()
                }
            }
        }
        _PrepareNextArr(MatchValue) {
            Pos := MatchValue.Pos + MatchValue.Len
            if MatchValue['char'] == ']' {
                if Stack.Length {
                    Active := Stack.Pop()
                    Obj := Active.Obj
                    Active.Handler.Call()
                }
            }
        }
        _PrepareNextObj(MatchValue) {
            Pos := MatchValue.Pos + MatchValue.Len
            if MatchValue['char'] == '}' {
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
        NextChar := '(?:\s*(?<char>,|\{}))'
        ArrayNextChar := Format(NextChar, ']')
        ObjectNextChar := Format(NextChar, '}')
        this.Patterns := {
            ArrayItem1: 'iS)\s*(?<char>"(?COnQuoteArr)|\{(?COnCurlyOpenArr)|\[(?COnSquareOpenArr)|f(?COnFalseArr)|t(?COnTrueArr)|n(?COnNullArr)|[\d-](?COnNumberArr)|\](?COnSquareCloseArr))'
          , ArrayItem2: 'iJS)\s*(?:(?<char>")(?COnQuoteArr)|(?<char>\{)(?COnCurlyOpenArr)|(?<char>\[)(?COnSquareOpenArr)|(?<char>f)(?COnFalseArr)|(?<char>t)(?COnTrueArr)|(?<char>n)(?COnNullArr)|(?<char>[\d-])(?COnNumberArr)|(?<char>\])(?COnSquareCloseArr))'
          , ArrayNumber: 'S)(?<value>(?<n>(?:-?\d++(?:\.\d++)?)(?:[eE][+-]?\d++)?))' ArrayNextChar
          , ArrayString: 'S)(?<=[,:[{\s])"(?<value>.*?)(?<!\\)(?:\\\\)*+"' ArrayNextChar
          , ArrayFalse: 'iS)(?<value>false)' ArrayNextChar
          , ArrayTrue: 'iS)(?<value>true)' ArrayNextChar
          , ArrayNull: 'iS)(?<value>null)' ArrayNextChar
          , ArrayNextChar: ArrayNextChar
          , ObjectPropName1: 'iS)\s*"(?<name>.+?)(?<!\\)(?:\\\\)*+":\s*(?<char>"(?COnQuoteObj)|\{(?COnCurlyOpenObj)|\[(?COnSquareOpenObj)|f(?COnFalseObj)|t(?COnTrueObj)|n(?COnNullObj)|[\d-](?COnNumberObj))'
          , ObjectPropName2: 'iJS)\s*"(?<name>.+?)(?<!\\)(?:\\\\)*+":\s*(?:(?<char>")(?COnQuoteObj)|(?<char>\{)(?COnCurlyOpenObj)|(?<char>\[)(?COnSquareOpenObj)|(?<char>f)(?COnFalseObj)|(?<char>t)(?COnTrueObj)|(?<char>n)(?COnNullObj)|(?<char>[\d-])(?COnNumberObj))'
          , ObjectNumber: 'S)(?<value>(?<n>-?\d++(?:\.\d++)?)(?<e>[eE][+-]?\d++)?)' ObjectNextChar
          , ObjectString: 'S)(?<=[,:[{\s])"(?<value>.*?)(?<!\\)(?:\\\\)*+"' ObjectNextChar
          , ObjectFalse: 'iS)(?<value>false)' ObjectNextChar
          , ObjectTrue: 'iS)(?<value>true)' ObjectNextChar
          , ObjectNull: 'iS)(?<value>null)' ObjectNextChar
          , ObjectNextChar: ObjectNextChar
          , ObjectInitialCheck: 'S)(*MARK:novalue)\s*(?<char>"|\})'
        }
    }
}
