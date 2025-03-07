/*
    Dependency:
        DecodeUnicodeEscapeSequence.ahk
*/

/**
 * @description - Parses a JSON string. If the JSON was created with the associated OBJECT_STRINGIFY
 * function, this may also be able to preserve the object's type. Limitations:
 * - Map objects' CaseSense value is not preserved; the default (true) is used. If this
 * is undesirable, this behavior can be avoided by using this code somewhere in your script prior to
 * calling ParseJson (all Map objects will default to CaseSense = false):
 * @example
    Map.Prototype.DefineProp('__New', { Call: MAP_CONSTRUCTOR })
    MAP_CONSTRUCTOR(Self, Items*) {
        Self.CaseSense := false
        if Items.Length
            Self.Set(Items*)
        return Self
    }
    ; Below is just example code, only the top code is needed.
    o := Map('A', 'value')
    msgbox(o.Has('a')) ; 1
 * @
 * - If the JSON was created from an AHK object, any dynamic properties become value properties when
 * parsed. This may be addressed in a future update.
 */
ParseJson(Str?, Path?, Encoding?) {
    if IsSet(Path)
        Str := FileRead(Path, Encoding ?? unset)
    else if !IsSet(Str)
        Str := A_Clipboard
    ; Replace all external whitespace with a single space character, decode unicode escape sequences.
    Str := DecodeUnicodeEscapeSequence(RegExReplace(Str, 'm)^\s+|\s+$', ' '))
    Controller := [], Completed := []
    if InStr(Str, '{') < InStr(Str, '[') ? '{' : '['
        return _ProcessCurly(_GetObject(false))
    else
        return _ProcessSquare(_GetObject(true))

    _GetObject(Square := false) {
        if !RegExMatch(Str, Square ? '\[([^\[\]]++|(?R))*\]' : '\{([^\{\}]++|(?R))*\}', &MatchObj)
            throw Error('The string does not contain a valid JSON object.', -1)
        return MatchObj
    }

    ;@region Square
    _ProcessSquare(MatchObj, ActiveObj?) {
        if IsSet(ActiveObj) {
            Controller.Push({ Active: ActiveObj, Nested: [] })
            if ActiveObj is Map
                _LoopMap()
            else if ActiveObj is Array
                _LoopArray()
        } else {
            ; Checking the next non-whitesepace character after the open bracket.
            RegExMatch(MatchObj[0], '^\[\s*(?<char>\S)', &MatchChar)
            ; If it's another square bracket, it may be a map object.
            if MatchChar['char'] == '[' {
                Controller.Push({ Active: Map(), Nested: [] })
                _LoopMap()
            } else {
                Controller.Push({ Active: [], Nested: [] })
                _LoopArray()
            }
        }
        Completed.Push(Controller.Pop())
        return Completed[-1].Active

        _LoopMap() {
            Pos := InStr(MatchObj[0], '[', , , 2)
            InnerText := Trim(SubStr(MatchObj[0], Pos, MatchObj.Len - Pos - 1), '`r`n`s`t')
            SquareMatches := []
            ; Collecting repeat nested square-bracketed text.
            while RegExMatch(InnerText, '\[([^\[\]]++|(?R))*\]', &MatchSquare) {
                SquareMatches.Push(MatchSquare)
                InnerText := StrReplace(InnerText, MatchSquare[0], '')
            }
            ; If this is a map object, there will only be remaining whitespace and commas.
            if RegExMatch(InnerText, '[^\s,]') {
                ; If other characters are present, this must be an array.
                Controller[-1].Active := []
                _LoopArray()
                return
            } else {
                ; At this point, we know this is an array of arrays, but whether it is a map is still
                ; uncertain so we must continue validating. If each nested array contains a key-value
                ; pair, where the key is a primitive value (number or string) and the value is anything,
                ; then the active object will stay a map. Otherwise, this switches to `_LoopArray`.
                FlagArray := false
                ; `KVPairs` retains the key-value pairs observed, so if this object turns out
                ; to be an array, we can use what we have parsed.
                KVPairs := []
                Nested := Controller[-1].Nested, ActiveObj := Controller[-1].Active
                for MatchSquare in SquareMatches {
                    NestedText := Trim(SubStr(MatchSquare[0], 2, MatchSquare.Len - 2), '`r`n`s`t')
                    ; This pattern is a combination of the quote pattern, the number pattern, and
                    ; keywords which may be unquoted in JSON.
                    if !RegExMatch(NestedText,
                            '^(?:'
                                '"(?<value>.*?)(?<!\\)(?:\\\\)*"(*MARK:quote)'
                            '|' '(?<n>-?\d++(?:\.\d++)?)(?<e>[eE][+-]?\d++)?(*MARK:number)'
                            '|' 'true(*MARK:true)|false(*MARK:false)|null(*MARK:null)'
                            ')\s*,\s*(?<char>\S)', &MatchName) {
                        FlagArray := true
                        break
                    }
                    ; The above pattern also gets the first non-whitespace character after the comma.
                    switch MatchName['char'] {
                        case '[':
                            MatchObj := _HandleOpenBracket(&NestedText, MatchName, true)
                            if _CheckLength(MatchObj.Pos + MatchObj.Len)
                                break
                            Nested.Push({ Name: MatchName, Val: MatchObj, Index: A_Index, Square: true })
                        case '{':
                            MatchObj := _HandleOpenBracket(&NestedText, MatchName, false)
                            if _CheckLength(MatchObj.Pos + MatchObj.Len)
                                break
                            Nested.Push({ Name: MatchName, Val: MatchObj, Index: A_Index, Square: false })
                        case '"':
                            MatchQuote := _GetQuotedString(MatchName, &NestedText)
                            if _CheckLength(MatchQuote.Pos + MatchQuote.Len)
                                break
                            KVPairs.Push({ Name: MatchName, Val: MatchQuote, Index: A_Index })
                        default:
                            Pos := _HandleValue(&NestedText, MatchName, &Value)
                            if _CheckLength(Pos)
                                break
                            KVPairs.Push({ Name: MatchName, Val: Value, Index: A_Index })
                    }
                }
                if FlagArray {
                    ActiveObj := Controller[-1].Active := []
                    ActiveObj.Length := SquareMatches.Length
                    for PairItem in KVPairs {
                        if PairItem.Val is RegExMatchInfo
                            ActiveObj[PairItem.Index] := [_On%PairItem.Name.Mark%M(PairItem.Name), PairItem.Val['value']]
                        else
                            ActiveObj[PairItem.Index] := [_On%PairItem.Name.Mark%M(PairItem.Name), PairItem.Val]
                    }
                    SquareMatches.RemoveAt(1, KVPairs.Length)
                    if KVPairs.Length
                        _LoopRemainingNestedArrays(SquareMatches, Max(KVPairs[-1].Index
                        , Nested[-1].Index) + 1)
                    for NestedItem in Nested {
                        if NestedItem.Square
                            ActiveObj[NestedItem.Index] := [_On%NestedItem.Name.Mark%M(NestedItem.Name), _ProcessSquare(NestedItem.Val)]
                        else
                            ActiveObj[NestedItem.Index] := [_On%NestedItem.Name.Mark%M(NestedItem.Name), _ProcessCurly(NestedItem.Val)]
                    }
                } else {
                    for PairItem in KVPairs {
                        if PairItem.Val is RegExMatchInfo
                            ActiveObj.Set(_On%PairItem.Name.Mark%M(PairItem.Name), PairItem.Val['value'])
                        else
                            ActiveObj.Set(_On%PairItem.Name.Mark%M(PairItem.Name), PairItem.Val)
                    }
                    for NestedItem in Nested {
                        if NestedItem.Square
                            ActiveObj.Set(_On%NestedItem.Name.Mark%M(NestedItem.Name), _ProcessSquare(NestedItem.Val))
                        else
                            ActiveObj.Set(_On%NestedItem.Name.Mark%M(NestedItem.Name), _ProcessCurly(NestedItem.Val))
                    }
                }
            }

            ; The key and value should cover the entire NestedText string.
            _CheckLength(Pos) {
                if Pos !== StrLen(NestedText) + 1 {
                    FlagArray := true
                    KVPairs.Length := A_Index - 1
                    return 1
                }
            }
            _OnFalseM(*) => false
            _OnNullM(*) => ''
            _OnNumberM(MatchNum) => _HandleNumber(MatchNum)
            _OnQuoteM(MatchQuote) => MatchQuote['value']
            _OnTrueM(*) => true
        }

        _LoopArray() {
            ActiveObj := Controller[-1].Active
            Pos := 1
            InnerText := Trim(SubStr(MatchObj[0], 2, MatchObj.Len - 2), '`r`n`s`t')
            while RegExMatch(InnerText,
                '\[(?COnSquareA)'
                '|\{(?COnCurlyA)'
                '|(?<n>-?\d++(?:\.\d++)?)(?<e>[eE][+-]?\d++)?(?COnNumberA)'
                '|"(?<value>.*?)(?<!\\)(?:\\\\)*"(?COnQuoteA)'
                '|true(?COnTrueA)|false(?COnFalseA)|null(?COnNullA)'
            , &MatchArrayItem, Pos) {
                continue
            }

            OnSquareA(MatchArrayItem, *) {
                MatchObj := _HandleOpenBracket(&InnerText, MatchArrayItem, Square := true)
                Pos := MatchObj.Pos + MatchObj.Len
                ActiveObj.Push(_ProcessSquare(MatchObj))
            }
            OnCurlyA(MatchArrayItem, *) {
                MatchObj := _HandleOpenBracket(&InnerText, MatchArrayItem, Square := false)
                Pos := MatchObj.Pos + MatchObj.Len
                ActiveObj.Push(_ProcessCurly(MatchObj))
            }
            OnNumberA(MatchArrayItem, *) {
                Pos := MatchArrayItem.Pos + MatchArrayItem.Len
                ActiveObj.Push(_HandleNumber(MatchArrayItem))
            }
            OnQuoteA(MatchArrayItem, *) {
                Pos := MatchArrayItem.Pos + MatchArrayItem.Len
                ActiveObj.Push(MatchArrayItem['value'])
            }
            OnTrueA(MatchArrayItem, *) {
                Pos := MatchArrayItem.Pos + MatchArrayItem.Len
                ActiveObj.Push(true)
            }
            OnFalseA(MatchArrayItem, *) {
                Pos := MatchArrayItem.Pos + MatchArrayItem.Len
                ActiveObj.Push(false)
            }
            OnNullA(MatchArrayItem, *) {
                Pos := MatchArrayItem.Pos + MatchArrayItem.Len
                ActiveObj.Push('')
            }
        }
        _LoopRemainingNestedArrays(SquareMatches, StartIndex) {
            CurrentActive := Controller[-1].Active
            for MatchSquare in SquareMatches
                CurrentActive[StartIndex++] := _ProcessSquare(MatchSquare, [])
        }
    }
    ;@endregion

    ;@region Curly
    _ProcessCurly(MatchObj) {
        ; We default the active object to an object, but it may change if a `__Type` tag is encountered.
        Controller.Push({ Active: {}, Nested: [] })
        ; We create a copy of the text so we can modify the copy during the loop.
        InnerText := Trim(SubStr(MatchObj[0], 2, MatchObj.Len - 2), '`r`n`s`t')
        ; `_LoopCurly` returns the correct object after accounting for a `__Type` tag.
        Controller[-1].Active := _LoopCurly()
        ; Nested objects are collected to be parsed afterward.
        for NestedItem in Controller[-1].Nested {
            ; If `OBJECT_STRINGIFY` was used, and if an array had additional own-properties
            ; added to it, the object apears in the JSON as an object with a property `__ArrayItem`
            ; containing the values in the array. `OBJECT_PARSE` will convert this back to an array.
            if NestedItem.Name['name'] == '__ArrayItem' {
                if Controller[-1].Active is Array
                    _ProcessSquare(NestedItem.Val, Controller[-1].Active)
                else
                    Controller[-1].Active := _TransferProps(Controller[-1].Active, _ProcessSquare(NestedItem.Val, []))
            ; If `OBJECT_STRINGIFY` is used, and if a map has additional non-builtin properties
            ; added to it, the object apears in the JSON as an object with a property `__MapItem`
            ; containing the values in the map. `OBJECT_PARSE` will convert this back to a map.
            } else if NestedItem.Name['name'] == '__MapItem' {
                if Controller[-1].Active is Map
                    _ProcessSquare(NestedItem.Val, Controller[-1].Active)
                else
                    Controller[-1].Active := _TransferProps(Controller[-1].Active, _ProcessSquare(NestedItem.Val, Map()))
            } else {
                if NestedItem.Square
                    Controller[-1].Active.%NestedItem.Name['name']% := _ProcessSquare(NestedItem.Val)
                else
                    Controller[-1].Active.%NestedItem.Name['name']% := _ProcessCurly(NestedItem.Val)
            }
        }
        Completed.Push(Controller.Pop())
        return Completed[-1].Active

        _LoopCurly() {
            Pos := 1
            HandleString := _HandleString
            ActiveObj := Controller[-1].Active, Nested := Controller[-1].Nested
            ; This pattern matches with a JSON-notation property, and the first non-whitespace
            ; character after the colon.
            while RegExMatch(InnerText, '(?:(?:^|(?<=[\]}{[,\s]))"(?<name>[\w\d_]+)(?<!\\)(?:\\\\)*":\s*+(?<char>.))'
            , &MatchName, Pos) {
                switch MatchName['char'], 0 {
                    case '[':
                        MatchObj := _HandleOpenBracket(&InnerText, MatchName, true)
                        Pos := MatchObj.Pos + MatchObj.Len
                        Nested.Push({ Name: MatchName, Val: MatchObj, Square: true })
                    case '{':
                        MatchObj := _HandleOpenBracket(&InnerText, MatchName, false)
                        Pos := MatchObj.Pos + MatchObj.Len
                        Nested.Push({ Name: MatchName, Val: MatchObj, Square: false })
                    case '"':
                        Pos := HandleString(MatchName, &ActiveObj)
                    default:
                        Pos := _HandleValue(&InnerText, MatchName, &Value)
                        ActiveObj.%MatchName['name']% := Value
                }
            }
            return ActiveObj

            _HandleString(MatchName, &ActiveObj) {
                ; The `__Type` faux property is always first, so we can save one calculation per iteration
                ; by swapping the function.
                HandleString := _HandleStringNoType
                MatchQuote := _GetQuotedString(MatchName, &InnerText)
                if MatchName['name'] == '__Type'
                    ActiveObj := Controller[-1].Active := _HandleType(MatchQuote)
                else
                    ActiveObj.%MatchName['name']% := MatchQuote['value']
                return MatchQuote.Pos + MatchQuote.Len
            }

            _HandleStringNoType(MatchName, &ActiveObj) {
                MatchQuote := _GetQuotedString(MatchName, &InnerText)
                ActiveObj.%MatchName['name']% := MatchQuote['value']
                return MatchQuote.Pos + MatchQuote.Len
            }

            _HandleType(MatchQuote) {
                Obj := {}
                Split := StrSplit(MatchQuote['value'], ':')
                if Split[1] == Split[2] {
                    switch Split[1], 0 {
                        case 'Array':
                            Obj := []
                        case 'Map':
                            Obj := Map()
                        case 'Object':
                        default:
                        ; To allow for flexibility when handling custom classes, we check for
                        ; inheritance from some built-in classes, and make an object of that type.
                        ; The `is` keyword will return true if an object is a type that inherits from
                        ; the class.
                        ; This is necessary to avoid the "Invalid base" error.
                            ClassObj := _GetObjectFromString(Split[1])
                            if !ClassObj
                                return Obj
                            if ClassObj.Prototype is Array
                                Obj := Array()
                            else if ClassObj.Prototype is Buffer
                                Obj := Buffer()
                            else if ClassObj.Prototype is Error
                                Obj := ClassObj()
                            else if ClassObj.Prototype is Gui
                                Obj := Gui()
                            else if ClassObj.Prototype is Map
                                Obj := Map()
                            try
                                ObjSetBase(Obj, ClassObj.Prototype)
                    }
                } else if Split[2] == 'Prototype' {
                    if Result := _GetObjectFromString(Split[1])
                        Obj := Result.Prototype
                } else if Split[2] == 'Class' {
                    if Result := _GetObjectFromString(Split[1])
                        Obj := Result
                    else
                        ObjSetBase(Obj, Class)
                } else
                    throw Error('Unexpected type in ``__Type`` tag: ' MatchQuote[0], -1)
                return Obj
            }
        }

        _GetObjectFromString(Path) {
            SplitPath := StrSplit(Path, '.')
            if !IsSet(%SplitPath[1]%)
                return
            OutObj := %SplitPath[1]%
            i := 1
            while ++i <= SplitPath.Length {
                if !OutObj.HasOwnProp(SplitPath[i])
                    return
                OutObj := OutObj.%SplitPath[i]%
            }
            return OutObj
        }
        _TransferProps(Obj, NewObj) {
            for Prop, Val in Obj.OwnProps()
                NewObj.%Prop% := Val
            return NewObj
        }
    }
    ;@endregion

    ;@region Shared
    _GetQuotedString(MatchName, &Text) {
        if !RegExMatch(Text, '"(?<value>.*?)(?<!\\)(?:\\\\)*"', &MatchQuote, MatchName.Pos + MatchName.Len - 1)
            throw Error('There may be a missing closing quote around position ' MatchName.Pos + MatchName.Len - 1, -1)
        return MatchQuote
    }

    _HandleOpenBracket(&Text, Match, Square := false) {
        if !RegExMatch(Text, Square ? '\[([^\[\]]++|(?R))*\]' : '\{([^\{\}]++|(?R))*\}'
        , &MatchObj, Match.Pos + Match.Len - 1)
            throw Error('The object is missing a closing square bracket. Text:`r`n' Match[0], -1)
        if MatchObj.Pos !== Match.Pos + Match.Len - 1
            throw Error('The position of the matched object text does not begin at the expected position.'
            '`r`nThis indicates a syntax error in the JSON string. Match:`r`n' Match[0]
            '`r`nMatched object:`r`n' MatchObj[0]
            '`r`nMatch position: ' MatchObj.Pos, -1)
        return MatchObj
    }

    _HandleNumber(MatchNum) {
        return  MatchNum['e'] ? Number(MatchNum['n']) * (10 ** Number(MatchNum['e'])) : Number(MatchNum[0])
    }

    _HandleValue(&InnerText, MatchName, &Value) {
        if RegExMatch(InnerText, '(?<n>-?\d++(?:\.\d++)?)(?<e>[eE][+-]?\d++)?', &MatchNum
        , MatchName.Pos + MatchName.Len - 1) {
            Value := _HandleNumber(MatchNum)
            return MatchNum.Pos + MatchNum.Len
        } else {
            switch SubStr(InnerText, MatchName.Pos + MatchName.Len - 1, 4) {
                case 'true':
                    Value := true
                    return MatchName.Pos + MatchName.Len + 3
                case 'fals':
                    Value := false
                    return MatchName.Pos + MatchName.Len + 4
                case 'null':
                    Value := '""'
                    return MatchName.Pos + MatchName.Len + 3
            }
        }
        throw ValueError('An unexpected value was encountered.'
        '`r`nContext: ' MatchName[0] '`tPosition: ' MatchName.Pos, -1)
    }
    ;@endregion
}
