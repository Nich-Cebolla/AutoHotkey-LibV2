
class ValidateJson {

    /**
     * @description - Validates a JSON string.
     * @param {String} [Str] - The string to parse.
     * @param {String} [Path] - The path to the file that contains the JSON content to parse.
     * @param {String} [Encoding] - The file encoding to use if calling `ValidateJson` with `Path`.
     */
    static Call(Str?, Path?, Encoding?) {
        ;@region Initialization
        static ArrayItem := ValidateJson.Patterns.ArrayItem
        , ObjectPropName := ValidateJson.Patterns.ObjectPropName
        , ArrayNumber := ValidateJson.Patterns.ArrayNumber
        , ArrayString := ValidateJson.Patterns.ArrayString
        , ArrayFalse := ValidateJson.Patterns.ArrayFalse
        , ArrayTrue := ValidateJson.Patterns.ArrayTrue
        , ArrayNull := ValidateJson.Patterns.ArrayNull
        , ArrayNextChar := ValidateJson.Patterns.ArrayNextChar
        , ObjectNumber := ValidateJson.Patterns.ObjectNumber
        , ObjectString := ValidateJson.Patterns.ObjectString
        , ObjectFalse := ValidateJson.Patterns.ObjectFalse
        , ObjectTrue := ValidateJson.Patterns.ObjectTrue
        , ObjectNull := ValidateJson.Patterns.ObjectNull
        , ObjectNextChar := ValidateJson.Patterns.ObjectNextChar
        , ObjectInitialCheck := ValidateJson.Patterns.ObjectInitialCheck

        if !IsSet(Str) {
            If IsSet(Path) {
                Str := FileRead(Path, Encoding ?? unset)
            } else {
                Str := A_Clipboard
            }
        }
        Str := Trim(Str, '`r`n`s`t')

        posCurly := InStr(Str, '{')
        posSquare := InStr(Str, '[')
        if Min(posCurly || 1, posSquare || 1) !== 1 {
            return Error('The first non-whitespace character is not an open bracket.', -1)
        }
        if posCurly > posSquare {
            Pattern := ArrayItem
        } else {
            Pattern := ObjectPropName
        }
        Pos := 2
        Stack := []
        Len := StrLen(Str)
        err := ''
        ;@endregion

        while RegExMatch(Str, Pattern, &Match, Pos) {
            continue
        }
        result := err ? err : Pos >= Len ? '' : Error('Invalid JSON.', -1, 'Near pos: ' Pos)
        return result

        ;@region Array Callbacks
        OnQuoteArr(Match, *) {
            if Match.Pos !== Pos {
                err := _Error(Pos)
                return -1
            }
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ArrayString, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                err := _Error(Pos)
                return -1
            }
            _PrepareNextArr(MatchValue)
        }
        OnSquareOpenArr(Match, *) {
            if Match.Pos !== Pos {
                err := _Error(Pos)
                return -1
            }
            Pos := Match.Pos + Match.Len - 1
            Stack.Push({ __Handler: _GetContextArray })
            Pattern := ArrayItem
            Pos++
        }
        OnCurlyOpenArr(Match, *) {
            if Match.Pos !== Pos {
                err := _Error(Pos)
                return -1
            }
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ObjectInitialCheck, &MatchCheck, Pos) || MatchCheck.Pos !== Pos + 1 {
                err := _Error(Pos)
                return -1
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
                err := _Error(Pos)
                return -1
            }
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ArrayFalse, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                err := _Error(Pos)
                return -1
            }
            _PrepareNextArr(MatchValue)
        }
        OnTrueArr(Match, *) {
            if Match.Pos !== Pos {
                err := _Error(Pos)
                return -1
            }
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ArrayTrue, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                err := _Error(Pos)
                return -1
            }
            _PrepareNextArr(MatchValue)
        }
        OnNullArr(Match, *) {
            if Match.Pos !== Pos {
                err := _Error(Pos)
                return -1
            }
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ArrayNull, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                err := _Error(Pos)
                return -1
            }
            _PrepareNextArr(MatchValue)
        }
        OnNumberArr(Match, *) {
            if Match.Pos !== Pos {
                err := _Error(Pos)
                return -1
            }
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ArrayNumber, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                err := _Error(Match.Pos)
                return -1
            }
            _PrepareNextArr(MatchValue)
        }
        OnSquareCloseArr(Match, *) {
            if Match.Pos !== Pos {
                err := _Error(Pos)
                return -1
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
                err := _Error(Pos)
                return -1
            }
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ObjectString, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                err := _Error(Pos)
                return -1
            }
            _PrepareNextObj(MatchValue)
        }
        OnSquareOpenObj(Match, *) {
            if Match.Pos !== Pos {
                err := _Error(Pos)
                return -1
            }
            Pos := Match.Pos + Match.Len - 1
            Stack.Push({ __Handler: _GetContextObject })
            Pattern := ArrayItem
            Pos++
        }
        OnCurlyOpenObj(Match, *) {
            if Match.Pos !== Pos {
                err := _Error(Pos)
                return -1
            }
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ObjectInitialCheck, &MatchCheck, Pos) || MatchCheck.Pos !== Pos + 1 {
                err := _Error(Pos)
                return -1
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
                err := _Error(Pos)
                return -1
            }
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ObjectFalse, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                err := _Error(Pos)
                return -1
            }
            _PrepareNextObj(MatchValue)
        }
        OnTrueObj(Match, *) {
            if Match.Pos !== Pos {
                err := _Error(Pos)
                return -1
            }
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ObjectTrue, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                err := _Error(Pos)
                return -1
            }
            _PrepareNextObj(MatchValue)
        }
        OnNullObj(Match, *) {
            if Match.Pos !== Pos {
                err := _Error(Pos)
                return -1
            }
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ObjectNull, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                err := _Error(Pos)
                return -1
            }
            _PrepareNextObj(MatchValue)
        }
        OnNumberObj(Match, *) {
            if Match.Pos !== Pos {
                err := _Error(Pos)
                return -1
            }
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ObjectNumber, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                err := _Error(Match.Pos)
                return -1
            }
            _PrepareNextObj(MatchValue)
        }
        ;@endregion

        ;@region Helper Funcs
        _GetContextArray() {
            if !RegExMatch(Str, ArrayNextChar, &MatchCheck, Pos) || MatchCheck.Pos !== Pos {
                err := _Error(Pos)
                return -1
            }
            Pos := MatchCheck.Pos + MatchCheck.Len
            if MatchCheck['char'] == ',' {
                Pattern := ArrayItem
            } else if MatchCheck['char'] == ']' {
                if Stack.Length {
                    Stack.Pop().__Handler.Call()
                }
            }
        }
        _GetContextObject() {
            if !RegExMatch(Str, ObjectNextChar, &MatchCheck, Pos) || MatchCheck.Pos !== Pos {
                err := _Error(Pos)
                return -1
            }
            Pos := MatchCheck.Pos + MatchCheck.Len
            if MatchCheck['char'] == ',' {
                Pattern := ObjectPropName
            } else if MatchCheck['char'] == '}' {
                if Stack.Length {
                    Stack.Pop().__Handler.Call()
                }
            }
        }
        _PrepareNextArr(MatchValue) {
            Pos := MatchValue.Pos + MatchValue.Len
            if MatchValue['char'] == ']' {
                if Stack.Length {
                    Stack.Pop().__Handler.Call()
                } else {
                    Pos := MatchValue.Pos + MatchValue.Len
                }
            }
        }
        _PrepareNextObj(MatchValue) {
            Pos := MatchValue.Pos + MatchValue.Len
            if MatchValue['char'] == '}' {
                if Stack.Length {
                    Stack.Pop().__Handler.Call()
                } else {
                    Pos := MatchValue.Pos + MatchValue.Len
                }
            }
        }
        _Error(Extra?, n := -2) {
            return Error('There is an error in the JSON string.', n, IsSet(Extra) ? 'Near pos: ' Extra : '')
        }
        ;@endregion
    }
    static __New() {
        this.DeleteProp('__New')
        ; SignficantChars := '["{[ftn\d{}-]'
        NextChar := '(?:\s*(?<char>,|\{}))'
        ArrayNextChar := Format(NextChar, ']')
        ObjectNextChar := Format(NextChar, '}')
        this.Patterns := {
            ArrayItem: 'iJS)\s*(?:(?<char>")(?COnQuoteArr)|(?<char>\{)(?COnCurlyOpenArr)|(?<char>\[)(?COnSquareOpenArr)|(?<char>f)(?COnFalseArr)|(?<char>t)(?COnTrueArr)|(?<char>n)(?COnNullArr)|(?<char>[\d-])(?COnNumberArr)|(?<char>\])(?COnSquareCloseArr))'
          , ArrayNumber: 'S)(?<value>(?<n>(?:-?\d++(?:\.\d++)?)(?:[eE][+-]?\d++)?))' ArrayNextChar
          , ArrayString: 'S)(?<=[,:[{\s])"(?<value>.*?(?<!\\)(?:\\\\)*+)"' ArrayNextChar
          , ArrayFalse: 'iS)(?<value>false)' ArrayNextChar
          , ArrayTrue: 'iS)(?<value>true)' ArrayNextChar
          , ArrayNull: 'iS)(?<value>null)' ArrayNextChar
          , ArrayNextChar: ArrayNextChar
          , ObjectPropName: 'iJS)\s*"(?<name>.*?(?<!\\)(?:\\\\)*+)":\s*(?:(?<char>")(?COnQuoteObj)|(?<char>\{)(?COnCurlyOpenObj)|(?<char>\[)(?COnSquareOpenObj)|(?<char>f)(?COnFalseObj)|(?<char>t)(?COnTrueObj)|(?<char>n)(?COnNullObj)|(?<char>[\d-])(?COnNumberObj))'
          , ObjectNumber: 'S)(?<value>(?<n>-?\d++(?:\.\d++)?)(?<e>[eE][+-]?\d++)?)' ObjectNextChar
          , ObjectString: 'S)(?<=[,:[{\s])"(?<value>.*?(?<!\\)(?:\\\\)*+)"' ObjectNextChar
          , ObjectFalse: 'iS)(?<value>false)' ObjectNextChar
          , ObjectTrue: 'iS)(?<value>true)' ObjectNextChar
          , ObjectNull: 'iS)(?<value>null)' ObjectNextChar
          , ObjectNextChar: ObjectNextChar
          , ObjectInitialCheck: 'S)(*MARK:novalue)\s*(?<char>"|\})'
        }
    }
}
