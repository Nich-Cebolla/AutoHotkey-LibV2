
/**
 * @description - Converts a Json string to an AutoHotKey string.
 * @param {String} [VariableName] - If set, the retun value is prefixed with `VariableName " := "`.
 * If unset, only the converted string is returned.
 * @param {String} [Json] - The json string to convert.
 * @param {String} [PathInput] - If `Json` is unset, the path to the file containing the json string
 * to convert.
 * @param {String} [Encoding] - If set, and if `Json` is unset, the encoding of the file at `PathInput`.
 * @param {VarRef} [OutPropCount] - A variable that will receive the number of object properties
 * contained in the json string.
 * @param {Integer} [ReplaceLimit] - If set, the value to pass to the `Limit` parameter of
 * `RegExReplace`.
 * @param {Integer} [StartPos = 1] - The start character position in `Json` that is to be converted.
 * @param {String} [QuoteChar = "`""] - For string literal values, if you prefer a different quote
 * character other than the double-quote, set `QuoteChar` with your preference.
 * @param {String} [LineEnding = "`r`n"] - Modifies the line endings used in the converted string.
 * @returns {String}
 */
JsonToAhk(VariableName?, Json?, PathInput?, Encoding?, &OutPropCount?, ReplaceLimit?, StartPos := 1, QuoteChar := '"', LineEnding := '`r`n') {
    if !IsSet(Json) {
        Json := FileRead(PathInput, Encoding ?? unset)
    }
    StrUnescapeJson(&Json)
    DecodeUnicodeEscapeSequence(&Json)
    ; Remove quotes from properties
    Json := RegExReplace(
        Json
      , '(?<=[\{,\s])"((?:[\p{L}_]|[^\x00-\x7F\x80-\x9F])(?:[\p{L}_0-9]|[^\x00-\x7F\x80-\x9F])+)":'
      , '$1:'
      , &OutPropCount
      , ReplaceLimit ?? unset
      , StartPos
    )
    ; Replace string literal quotes with preferred quote character
    if QuoteChar !== '"' {
        Json := RegExReplace(Json, '(?<=[,:[{\s])"(?<text>.*?(?<!\\)(?:\\\\)*+)"', QuoteChar '$1' QuoteChar)
    }
    ; Replace line endings
    Json := RegExReplace(Json, '\R', LineEnding)
    if IsSet(VariableName) {
        return VariableName ' := ' Json
    } else {
        return Json
    }
}

DecodeUnicodeEscapeSequence(&Str) {
    while RegExMatch(Str, '\\u([dD][89aAbB][0-9a-fA-F]{2})\\u([dD][c-fC-F][0-9a-fA-F]{2})|\\u([0-9a-fA-F]{4})', &Match) {
        if Match[1] && Match[2]
            Str := StrReplace(Str, Match[0], Chr(((Number('0x' Match[1]) - 0xD800) << 10) + (Number('0x' Match[2]) - 0xDC00) + 0x10000))
        else if Match[3]
            Str := StrReplace(Str, Match[0], Chr('0x' Match[3]))
        else if Match[1]
            _Throw('first', 'second', Match[0])
        else
            _Throw('second', 'first', Match[0])
    }

    _Throw(A, B, C) {
        throw Error('The input matched with the ' A ' capture group but not ' B ', which is'
        '`r`nunexpected and unhandled. Match: ' C, -2)
    }
}

StrUnescapeJson(&Str) {
    n := 0xFFFD
    while InStr(Str, Chr(n)) {
        n++
    }
    Str := StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(Str, '\\', Chr(n)), '\n', '`n'), '\r', '`r'), '\"', '"'), '\t', '`t'), Chr(n), '\')
}

