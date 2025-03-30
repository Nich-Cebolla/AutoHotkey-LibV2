
/**
 * @description - Converts a Json string to an AutoHotKey string.
 */
JsonToAhk(VariableName, Json?, PathInput?, Encoding?, &OutputVarCount?, ReplaceLimit?, StartPos := 1) {
    return VariableName ' := ' DecodeUnicodeEscapeSequence(StrReplace(RegExReplace(StrReplace(
        RegExReplace(Json ?? FileRead(PathInput, Encoding ?? unset), '(?<=[\{,\s])"([a-zA-Z0-9_]+)":', '$1:', &OutputVarCount, ReplaceLimit ?? unset, StartPos)
      , '``', '````'), '\\([rn"])', '``$1'), '\\', '\'))
}

DecodeUnicodeEscapeSequence(Str) {
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
    return Str

    _Throw(A, B, C) {
        throw Error('The input matched with the ' A ' capture group but not ' B ', which is'
        '`r`nunexpected and unhandled. Match: ' C, -2)
    }
}

