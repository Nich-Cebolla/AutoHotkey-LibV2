

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


if A_ScriptFullPath == A_LineFile {
    A_Clipboard := BreakLongComments()
    OM := CoordMode('Mouse', 'Screen')
    OT := CoordMode('Tooltip', 'Screen')
    MouseGetPos(&x, &y)
    Tooltip('Done', x, y)
    sleep 1500
}
