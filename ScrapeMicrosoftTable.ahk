
/*
    patterns

<td><strong>(?<name>[^<]+)</strong><br>(?:<strong>(?<name2>[^<]+)</strong>)?<br>(?<value>[^<]+)</td>\R<td>(?<desc>.+?)</td>\R

<strong>(?<symbol>\w+)</strong><br>L"(?<value>[^"]+)"</td>\R(?<description>.+)
    <td><strong>BCRYPT_3DES_ALGORITHM</strong><br>L"3DES"</td>
    <td>The triple data encryption standard symmetric encryption algorithm.<br> Standard: SP800-67, SP800-38A</td>

'<dt><b>([^<]+).+\R+<dt>([^<]+)[\w\W]+?<td width="60%">\R(.+)[\w\W]+?(?:(?=<dt><b>)|$)'
'`n     * $1 - $2 : $3'

*/


ScrapeMicrosoftTable(Pattern, ResultPattern, html?, LinePrefix := '') {
    if !IsSet(html) {
        html := A_Clipboard
    }
    str := ''
    return RegExReplace(html, pattern, resultpattern)
}


if A_LineFile == A_ScriptFullPath {
    A_Clipboard := ScrapeMicrosoftTable('<dt><b>([^<]+).+\R+<dt>([^<]+)[\w\W]+?<td width="60%">\R(.+)[\w\W]+?(?:(?=<dt><b>)|$)', '`n     * $1 - $2 : $3')
    OM := CoordMode('Mouse', 'Screen')
    OT := CoordMode('Tooltip', 'Screen')
    MouseGetPos(&x, &y)
    Tooltip('Done', x, y)
    sleep 1500
}



/*

ScrapeMicrosoftTable(Pattern, ResultPattern, html?, LinePrefix := '') {
    if !IsSet(html) {
        html := A_Clipboard
    }
    str := ''
    Pos := 1
    while RegExMatch(html, pattern, &Match, Pos) {
        pos := Match.Pos + Match.Len
        str .=
    }

    return str
}


if A_LineFile == A_ScriptFullPath {
    A_Clipboard := ScrapeMicrosoftTable('<dt><b>(\w+).+[\r\n]+<dt>(\w+)[\w\W]+?(?=<dt><b>)', '$1 := $2')
    OM := CoordMode('Mouse', 'Screen')
    OT := CoordMode('Tooltip', 'Screen')
    MouseGetPos(&x, &y)
    Tooltip('Done', x, y)
    sleep 1500
}
