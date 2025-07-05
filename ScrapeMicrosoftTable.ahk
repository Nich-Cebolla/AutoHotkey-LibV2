
/*
    patterns

<strong>(?<symbol>\w+)</strong><br>L"(?<value>[^"]+)"</td>\R(?<description>.+)

<td><strong>BCRYPT_3DES_ALGORITHM</strong><br>L"3DES"</td>
<td>The triple data encryption standard symmetric encryption algorithm.<br> Standard: SP800-67, SP800-38A</td>


*/



ScrapeMicrosoftTable(pattern, html?) {
    if !IsSet(html) {
        html := A_Clipboard
    }
    str := ''
    split := StrSplit(html, '</tr>')
    for line in split {
        if !RegExMatch(line, pattern, &Match) {
            throw Error('Did not match pattern.', -1, line)
        }
        str .= '; ' RegExReplace(StrReplace(Match['description'], '<br>', '`n; '), '<[^>]*>', '') '`n' Match['symbol'] ' := `'' Match['value'] '`'`n`n'
    }

    return str
}


if A_LineFile == A_ScriptFullPath {
    A_Clipboard := ScrapeMicrosoftTable('<strong>(?<symbol>\w+)</strong><br>L"(?<value>[^"]+)"</td>\R(?<description>.+)')
    OM := CoordMode('Mouse', 'Screen')
    OT := CoordMode('Tooltip', 'Screen')
    MouseGetPos(&x, &y)
    Tooltip('Done', x, y)
    sleep 1500
}
