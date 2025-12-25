
#include ..\ParseXlsx.ahk

if !A_IsCompiled && A_LineFile == A_ScriptFullPath {
    test_xlsx()
}

class test_xlsx {
    static Call() {
        xlsx := this.xlsx := ParseXlsx('ParseXlsx-content.xlsx')
        csv1 := '
        (
Sheet1,date,amount,name,block,time,percentage,special,general,test,test2,test3
,46002,100,Topanga,16,0.57638888888888884,0.5,3255,"""red""",<si><t>,"""",©
,46001,100.5,Shiraishi,3,0.60555555555555551,0.229,2342341,"""green""",</t></si><si><t>,',®
,46000,200,Nico,29,0.35347222222222224,0.642,4324,"""blue""",</t></si></sst>,¢,™
,45999,190.75,Al,7,0.25347222222222221,0.889,43,"""yellow""",",",£,&
,45998,210,Futami,33,0.925,10,0,"""teal""","
",,
,,,,,,,,,,,,
,,801.25,,88,,,2349963,,,,

        )'
        csv3 := '
        (
Sheet2,date,amount,name,block,time,percentage,special,general,test,test2,test3
,46002,100,Topanga,16,0.57638888888888884,0.5,3255,"""red""",<si><t>,"""",©
,46001,100.5,Shiraishi,3,0.60555555555555551,0.229,2342341,"""green""",</t></si><si><t>,',®
,46000,200,Nico,29,0.35347222222222224,0.642,4324,"""blue""",</t></si></sst>,¢,™
,45999,190.75,Al,7,0.25347222222222221,0.889,43,"""yellow""",",",£,&
,45998,210,Futami,33,0.925,10,0,"""teal""","
",,
,,,,,,,,,,,,
,,801.25,,88,,,2349963,,,,

        )'
        csv5 := '
        (
Sheet3,date,amount,name,block,time,percentage,special,general,test,test2,test3,,,,,,,,,,,,,
,46002,100,Topanga,16,0.57638888888888884,0.5,3255,"""red""",<si><t>,"""",©,,,,,,,,,,,,,
,46001,100.5,Shiraishi,3,0.60555555555555551,0.229,2342341,"""green""",</t></si><si><t>,',®,,,,,,,,,,,,,
,46000,200,Nico,29,0.35347222222222224,0.642,4324,"""blue""",</t></si></sst>,¢,™,,,,,,,,,,,,,
,45999,190.75,Al,7,0.25347222222222221,0.889,43,"""yellow""",",",£,&,,,,,,,,,,,,,
,45998,210,Futami,33,0.925,10,0,"""teal""","
",,,,,,,,,,,,,,,
,,,,,,,,,,,,,,,,,,,,,,,,,
,,801.25,,88,,,2349963,,,,,,,,,,,,,,,,,
,,,,,,,,,,,,,,,,,,,,,,,,,
,,,,,,,,,,,,,,,,,,,,,,,,,
,,,,,,,,,,,,,,,,,,,,,,,,,
,,,,,,,,,,,,,,,,,,,,,,,,,
,,,,,,,,,,,,,,,,,,,,,,,,,
,,,,,,,,,,,,,,,,,,,,,,,,,
,,,,,,,,,,,,,,date,amount,name,block,time,percentage,special,general,test,test2,test3
,,,,,,,,,,,,,,46002,100,Topanga,16,0.57638888888888884,0.5,3255,"""red""",<si><t>,"""",©
,,,,,,,,,,,,,,46001,100.5,Shiraishi,3,0.60555555555555551,0.229,2342341,"""green""",</t></si><si><t>,',®
,,,,,,,,,,,,,,46000,200,Nico,29,0.35347222222222224,0.642,4324,"""blue""",</t></si></sst>,¢,™
,,,,,,,,,,,,,,45999,190.75,Al,7,0.25347222222222221,0.889,43,"""yellow""",",",£,&
,,,,,,,,,,,,,,45998,210,Futami,33,0.925,10,0,"""teal""","
",,
,,,,,,,,,,,,,,,,,,,,,,,,,
,,,,,,,,,,,,,,,801.25,,88,,,2349963,,,,

        )'
        csv2 := xlsx[1].toCsv2(ParseXlsx_callback)
        csv4 := xlsx[2].toCsv2(ParseXlsx_callback)
        csv6 := xlsx[3].toCsv2(ParseXlsx_callback)
        if csv1 != csv2 {
            throw Error('Invalid csv.')
        }
        if csv3 != csv4 {
            throw Error('Invalid csv.')
        }
        if csv5 != csv6 {
            throw Error('Invalid csv.')
        }

        csv21 := '
        (
Sheet1,date,amount,name,block,time,percentage,special,general,test,test2,test3
,46002,100,Topanga,16,0.57638888888888884,0.5,3255,"""red""",<si><t>,"""",©
,46001,100.5,Shiraishi,3,0.60555555555555551,0.229,2342341,"""green""",</t></si><si><t>,',®
,46000,200,Nico,29,0.35347222222222224,0.642,4324,"""blue""",</t></si></sst>,¢,™
,45999,190.75,Al,7,0.25347222222222221,0.889,43,"""yellow""",",",£,&
,45998,210,Futami,33,0.925,10,0,"""teal""","
",,
,,801.25,,88,,,2349963,,,,

        )'
        csv23 := '
        (
Sheet2,date,amount,name,block,time,percentage,special,general,test,test2,test3
,46002,100,Topanga,16,0.57638888888888884,0.5,3255,"""red""",<si><t>,"""",©
,46001,100.5,Shiraishi,3,0.60555555555555551,0.229,2342341,"""green""",</t></si><si><t>,',®
,46000,200,Nico,29,0.35347222222222224,0.642,4324,"""blue""",</t></si></sst>,¢,™
,45999,190.75,Al,7,0.25347222222222221,0.889,43,"""yellow""",",",£,&
,45998,210,Futami,33,0.925,10,0,"""teal""","
",,
,,801.25,,88,,,2349963,,,,

        )'
        csv25 := '
        (
Sheet3,date,amount,name,block,time,percentage,special,general,test,test2,test3,,,,,,,,,,,,,
,46002,100,Topanga,16,0.57638888888888884,0.5,3255,"""red""",<si><t>,"""",©,,,,,,,,,,,,,
,46001,100.5,Shiraishi,3,0.60555555555555551,0.229,2342341,"""green""",</t></si><si><t>,',®,,,,,,,,,,,,,
,46000,200,Nico,29,0.35347222222222224,0.642,4324,"""blue""",</t></si></sst>,¢,™,,,,,,,,,,,,,
,45999,190.75,Al,7,0.25347222222222221,0.889,43,"""yellow""",",",£,&,,,,,,,,,,,,,
,45998,210,Futami,33,0.925,10,0,"""teal""","
",,,,,,,,,,,,,,,
,,801.25,,88,,,2349963,,,,,,,,,,,,,,,,,
,,,,,,,,,,,,,,date,amount,name,block,time,percentage,special,general,test,test2,test3
,,,,,,,,,,,,,,46002,100,Topanga,16,0.57638888888888884,0.5,3255,"""red""",<si><t>,"""",©
,,,,,,,,,,,,,,46001,100.5,Shiraishi,3,0.60555555555555551,0.229,2342341,"""green""",</t></si><si><t>,',®
,,,,,,,,,,,,,,46000,200,Nico,29,0.35347222222222224,0.642,4324,"""blue""",</t></si></sst>,¢,™
,,,,,,,,,,,,,,45999,190.75,Al,7,0.25347222222222221,0.889,43,"""yellow""",",",£,&
,,,,,,,,,,,,,,45998,210,Futami,33,0.925,10,0,"""teal""","
",,
,,,,,,,,,,,,,,,801.25,,88,,,2349963,,,,

        )'
        csv22 := xlsx[1].toCsv2(ParseXlsx_callback, , , , , , , escapeFields := true, includeEmptyRows := false)
        csv24 := xlsx[2].toCsv2(ParseXlsx_callback, , , , , , , escapeFields := true, includeEmptyRows := false)
        csv26 := xlsx[3].toCsv2(ParseXlsx_callback, , , , , , , escapeFields := true, includeEmptyRows := false)
        if csv21 != csv22 {
            throw Error('Invalid csv2.')
        }
        if csv23 != csv24 {
            throw Error('Invalid csv2.')
        }
        if csv25 != csv26 {
            throw Error('Invalid csv2.')
        }

        ; ParseXlsx

        if xlsx.workbookPr.Count != 1 {
            throw Error('Invalid count.')
        }
        if xlsx.workbookPr.Get('defaultThemeVersion') != '202300' {
            throw Error('Unexpected value.')
        }
        test_strings := [ 'date', 'amount', 'name', 'Topanga', 'Shiraishi', 'Nico', 'Al', 'Futami'
        , 'block', 'time', 'percentage', 'special', 'general', 'test', '&lt;si&gt;&lt;t&gt;'
        , '&lt;/t&gt;&lt;/si&gt;&lt;si&gt;&lt;t&gt;', '&lt;/t&gt;&lt;/si&gt;&lt;/sst&gt;', '"red"'
        , '"green"', '"blue"', '"yellow"', '"teal"', ',', 'test2', '"', '`'', '¢', '£', 'test3'
        , '©', '®', '™', '&amp;', 'Sheet1', 'Sheet2', 'Sheet3' ]
        sharedStrings := xlsx.sharedStrings
        loop test_strings.Length {
            if test_strings[A_Index] != sharedStrings[A_Index].value {
                throw Error('Mismatched string value.', , A_Index)
            }
        }
        if xlsx.getWs(1).name != 'table' {
            throw Error('Unexpected return value.')
        }
        if xlsx.getWs('Sheet1').wsIndex != 2 {
            throw Error('Unexpected return value.')
        }
        if xlsx.getWs('two_', true).name != 'two_blocks' {
            throw Error('Unexpected return value.')
        }

        ; ParseXlsx.Cell

        for ws in xlsx {
            rng := ws.getRange()
            content := FileRead(xlsx.dir '\xl\worksheets\sheet' A_Index '.xml', 'utf-8')
            _cells := []
            pos := 1
            while RegExMatch(content, 's)<c (?:[^>]+/>|.+?</c>)', &match, pos) {
                pos := match.Pos + match.Len
                _cells.Push(match[0])
            }
            loop rng.Length {
                cell := rng[A_Index]
                if !InStr(_cells[A_Index], '"' cell.r '"') {
                    throw Error('Out of order cells.')
                }
                eles := ParseXlsx_ParseElements2(_cells[A_Index])
                for ele in eles {
                    if ele.name = 'c' {
                        continue
                    }
                    test_ele := cell.%ele.name%
                    if test_ele != ele.value {
                        throw Error('Invalid child element.', , ele.name)
                    }
                }
                ; only test the attributes of the cell object.
                attr_str := SubStr(_cells[A_Index], 1, InStr(_cells[A_Index], '>'))
                attrs := ParseXlsx_ParseAttributes2(attr_str)
                for attr in attrs {
                    test_attr := cell.%attr.name%
                    if test_attr != attr.value {
                        throw Error('Invalid attribute.', , attr.name)
                    }
                }
                test_rowIndex := cell.row().rowIndex
                if test_rowIndex != cell.rowIndex {
                    throw Error('Invalid row index.')
                }
            }
        }

        ; ParseXlsx.Row

        for ws in xlsx {
            content := FileRead(xlsx.dir '\xl\worksheets\sheet' A_Index '.xml', 'utf-8')
            _rows := []
            pos := 1
            while RegExMatch(content, 's)<row .+?</row>', &match, pos) {
                pos := match.Pos + match.Len
                _rows.Push({ xml: match[0], cells: [] })
                _cells := _rows[-1].cells
                _pos := 1
                while RegExMatch(match[0], 's)<c (?:[^>]+/>|.+?</c>)', &matchCell, _pos) {
                    _pos := matchCell.Pos + matchCell.Len
                    _cells.Push(matchCell[0])
                }
            }
            i := 0
            for row in ws.rows {
                if !IsSet(row) {
                    continue
                }
                _row := _rows[++i]
                ; only test the attributes of the row object.
                _xml := SubStr(_row.xml, 1, InStr(_row.xml, '>'))
                _row_attr := ParseXlsx_ParseAttributes2(_xml)
                row.getAttributes()
                for attr in _row_attr {
                    test_attr := row.%attr.name%
                    if test_attr != attr.value {
                        throw Error('Invalid attribute.')
                    }
                }
                _cells := _row.cells
                k := 0
                for cell in row {
                    if !IsSet(cell) {
                        continue
                    }
                    test_col := row.cell(cell.col).col
                    if test_col != cell.col {
                        throw Error('Invalid column.')
                    }
                    _cell := _cells[++k]
                    attrs := ParseXlsx_ParseAttributes2(_cell)
                    for attr in attrs {
                        if attr.name = 'r' {
                            if InStr(attr.value, cell.col) {
                                break
                            } else {
                                throw Error('Invalid column.')
                            }
                        }
                    }
                }
            }
        }

        ; ParseXlsx.Worksheet

        for ws in xlsx {
            content := FileRead(xlsx.dir '\xl\worksheets\sheet' A_Index '.xml', 'utf-8')
            _cells := []
            pos := 1
            while RegExMatch(content, 's)<c (?:[^>]+/>|.+?</c>)', &match, pos) {
                pos := match.Pos + match.Len
                _cells.Push(match[0])
            }
            loop ws.columnUbound {
                col := ParseXlsx_IndexToCol(A_Index)
                if column := ws.getColumn(A_Index) {
                    _list := []
                    for _cell in _cells {
                        if InStr(_cell, 'r="' col) {
                            _list.Push(_cell)
                        }
                    }
                    for cell in column {
                        if !IsSet(cell) {
                            continue
                        }
                        if InStr(_list[1], 'r="' cell.r '"') {
                            _list.RemoveAt(1)
                        } else {
                            throw Error('Invalid cell xml.')
                        }
                    }
                    if _list.Length {
                        throw Error('Expected 0 remaining items.')
                    }
                } else {
                    for _cell in _cells {
                        if InStr(_cell, 'r="' col) {
                            throw Error('The cell is absent from the parsed object.')
                        }
                    }
                }
            }
            loop ws.rowUbound {
                rowIndex := A_Index
                if row := ws.getRow(rowIndex) {
                    _list := []
                    for _cell in _cells {
                        if RegExMatch(_cell, 'r="\w' rowIndex '\b') {
                            _list.Push(_cell)
                        }
                    }
                    for cell in row {
                        if !IsSet(cell) {
                            continue
                        }
                        if InStr(_list[1], 'r="' cell.r '"') {
                            _list.RemoveAt(1)
                        } else {
                            throw Error('Invalid cell xml.')
                        }
                    }
                    if _list.Length {
                        throw Error('Expected 0 remaining items.')
                    }
                } else {
                    for _cell in _cells {
                        if RegExMatch(_cell, 'r="\w' rowIndex) {
                            throw Error('The cell is absent from the parsed object.')
                        }
                    }
                }
            }
        }
        OutputDebug(A_ScriptName ' - done`n')
    }
}

ParseXlsx_callback(cell) => RegExReplace(ParseXlsx_FixFloatingPoint(cell.decoded), '\R', '`n')
