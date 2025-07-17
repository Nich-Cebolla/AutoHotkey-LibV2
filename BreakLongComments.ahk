

BreakLongComments(Str?, Path?, MaxLen := 100, MinLen := 90, CommentOperator := ';', LineEnding := '`n', Encoding?) {
    if IsSet(Str) {
        split := StrSplit(StrReplace(Str, '`t', '`s`s`s`s'), '`n', '`r')
    } else if IsSet(Path) {
        split := StrSplit(StrReplace(FileRead(Path, Encoding ?? unset), '`t', '`s`s`s`s'), '`n', '`r')
    } else {
        split := StrSplit(StrReplace(A_Clipboard, '`t', '`s`s`s`s'), '`n', '`r')
    }
    Str := ''
    pattern := '^(?<indent> *)' CommentOperator
    for line in split {
        if RegExMatch(line, pattern, &Match) {
            lineLen := StrLen(line)
            if lineLen > MaxLen {
                indLen := Match.Len['indent']
                if indLen < 4 {
                    pos := indLen + 1
                    ind := ''
                    indLen := 0
                } else if indLen > MaxLen {
                    throw Error('The length of the indentation is greater than ``MaxLen``.', -1)
                } else {
                    pos := 1
                    ind := Match['indent']
                }
                posEnd := InStr(SubStr(line, pos, MaxLen), '`s', , , -1)
                if posEnd < MinLen {
                    posEnd := MaxLen
                }
                s := RTrim(SubStr(line, pos, posEnd), '`s')
                segmentMaxLen := MaxLen - indLen - 2
                pos := posEnd + 1
                loop {
                    s .= LineEnding ind CommentOperator '`s'
                    posEnd := InStr(SubStr(line, pos, segmentMaxLen), '`s', , , -1)
                    if posEnd + indLen + 2 < MinLen {
                        posEnd := segmentMaxLen
                    }
                    if posEnd + pos > lineLen {
                        s .= Trim(SubStr(line, pos, lineLen - pos), '`s')
                        break
                    } else {
                        s .= Trim(SubStr(line, pos, posEnd), '`s')
                        pos += posEnd
                    }
                }
                Str .= s LineEnding
            } else {
                if Match.Len['indent'] < 4 {
                    Str .= LTrim(line, '`s') LineEnding
                } else {
                    Str .= line LineEnding
                }
            }
        } else {
            Str .= line LineEnding
        }
    }
    return Str
}


/*
if A_ScriptFullPath == A_LineFile {
    A_Clipboard := BreakLongComments('    ')
    OM := CoordMode('Mouse', 'Screen')
    OT := CoordMode('Tooltip', 'Screen')
    MouseGetpos(&x, &y)
    Tooltip('Done', x, y)
    sleep 1500
}
*/

/**
 * @param {String} [Indent = ""] - The literal string to prefix each line with, not including the
 * single space character that offsets the "*" from the indentation.
 */
BreakLongJsdoc(Indent := '', Str?, Path?, MaxLen := 100, MinLen := 85, LineEnding := '`n', Encoding?) {
    if IsSet(Str) {
        split := StrSplit(Str, '`n', '`r`n`s`t')
    } else if IsSet(Path) {
        split := StrSplit(FileRead(Path, Encoding ?? unset), '`n', '`r`n`s`t')
    } else {
        split := StrSplit(A_Clipboard, '`n', '`r`n`s`t')
    }
    _indentLen1 := StrLen(Indent) + 3
    _indentLen2 := _indentLen1 + 2
    if _indentLen2 > MaxLen {
        throw ValueError('The indentation length is greater than the maximum length.', -1)
    }
    _maxLen1 := MaxLen - _indentLen1
    _maxLen2 := _maxLen1 + 2
    _indent1 := Indent ' * '
    _indent2 := _indent1 '  '
    Str := ''
    for line in split {
        lineLen := StrLen(line)
        if SubStr(line, 1, 1) == '*' {
            if lineLen == 1 {
                line := ''
            } else {
                line := Trim(SubStr(line, 2), '`s')
            }
        }
        if !line {
            if Str {
                Str .= Indent ' *' LineEnding
            }
            continue
        }
        if lineLen > _maxLen1 {
            pos := 1
            flag_first := true
            _max := _maxLen1
            _indent := _indent1
            _indentLen := _indentLen1
            loop {
                if _max + pos >= lineLen {
                    s := Trim(SubStr(line, pos, lineLen - pos), '`s')
                    if s {
                        s := _indent s LineEnding
                    }
                    Str .= s
                    outputdebug(s '`n')
                    break
                }
                posEnd := InStr(SubStr(line, 1, _max + pos), '`s', , , -1)
                outputdebug(substr(line, pos, _max) '`n')
                if posEnd - pos + _indentLen < MinLen {
                    s := _indent Trim(SubStr(line, pos, _max), '`s') LineEnding
                    Str .= s
                    outputdebug(s '`n')
                    pos += _max
                } else {
                    s := _indent Trim(SubStr(line, pos, posEnd - pos), '`s') LineEnding
                    Str .= s
                    outputdebug(s '`n')
                    pos := posEnd
                }
                if flag_first {
                    _max := _maxLen2
                    _indent := _indent2
                    _indentLen := _indentLen2
                    flag_first := false
                }
            }
        } else {
            s := _indent1 Trim(line, '`s') LineEnding
            Outputdebug(s '`n')
            Str .= s
        }
    }
    return Str
}

if A_ScriptFullPath == A_LineFile {
    A_Clipboard := BreakLongJsdoc('    ')
    OM := CoordMode('Mouse', 'Screen')
    OT := CoordMode('Tooltip', 'Screen')
    MouseGetpos(&x, &y)
    Tooltip('Done', x, y)
    sleep 1500
}
