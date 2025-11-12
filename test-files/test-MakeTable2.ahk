
#include ..\MakeTable.ahk

if !A_IsCompiled && A_LineFile == A_ScriptFullPath {
    path := A_Temp '\test-MakeTable.md'
    f := FileOpen(path, 'w')
    f.Write(test())
    f.Close()
    Run('"' A_Temp '"')
}

class test {

    static call() {
        str := '
        (
calldate,src,dst,dcontext,channel
07/14/2025 02:43:44,5555557485,17,play-system-recording,PJSIP/Cox_Trunk-0000d212
07/14/2025 05:58:22,5555557984,s,ivr-6,PJSIP/Cox_Trunk-0000d213
07/14/2025 06:36:41,5555559989,s,ivr-6,PJSIP/Cox_Trunk-0000d214
07/14/2025 06:47:11,5555552202,91017,ext-queues,PJSIP/Cox_Trunk-0000d215
)'
        tbl := MakeTable(
            str
            , {
                AddHeaderSeparator: true
              , ColumnPadding: '`s`s'
              , InputColumnSeparator: ','
              , InputRowSeparator: '\R'
              , LinePrefix: '|  '
              , LineSuffix: '  |'
              , MaxWidths: 20
              , OutputColumnSeparator: '|'
              , OutputLineBetweenRows: 0
              , OutputRowSeparator: '`n'
              , TrimCharacters: '`s'
            }
        )
        OutputDebug(tbl.Value '`n')
        txt := tbl[2][4]('')
        md1 := tbl.GetMarkdown()
        md2 := tbl.GetMarkdown(, '<br>')
        html1 := tbl.GetHtml()
        html2 := tbl.GetHtml({
            TableAttribute: 'class="table"'
          , TdAttribute: 'class="td"'
          , TrAttribute: 'class="tr"'
          , ThAttribute: 'class="th"'
        })
        html3 := tbl.GetHtml({
            TableAttribute: 'class="table"'
          , TdAttribute: [ 'class="td1"', 'class="td2"', 'class="td3"', 'class="td4"', 'class="td5"' ]
          , TrAttribute: [ 'class="tr1"', 'class="tr2"', 'class="tr3"', 'class="tr4"', 'class="tr5"' ]
          , ThAttribute: [ 'class="th1"', 'class="th2"', 'class="th3"', 'class="th4"', 'class="th5"' ]
        })
        html4 := tbl.GetHtml({
            TableAttribute: 'class="table"'
          , TdAttribute: [
                [ 'class="td1-1"', 'class="td1-2"', 'class="td1-3"', 'class="td1-4"', 'class="td1-5"' ]
              , [ 'class="td2-1"', 'class="td2-2"', 'class="td2-3"', 'class="td2-4"', 'class="td2-5"' ]
              , [ 'class="td3-1"', 'class="td3-2"', 'class="td3-3"', 'class="td3-4"', 'class="td3-5"' ]
              , [ 'class="td4-1"', 'class="td4-2"', 'class="td4-3"', 'class="td4-4"', 'class="td4-5"' ]
              , [ 'class="td5-1"', 'class="td5-2"', 'class="td5-3"', 'class="td5-4"', 'class="td5-5"' ]
            ]
          , TrAttribute: [ 'class="tr1"', 'class="tr2"', 'class="tr3"', 'class="tr4"', 'class="tr5"' ]
          , ThAttribute: [ 'class="th1"', 'class="th2"', 'class="th3"', 'class="th4"', 'class="th5"' ]
        })
        html4 := tbl.GetHtml({
            TableStyle: 'color:red;'
          , TdStyle: 'color:red;'
          , TrStyle: 'color:red;'
          , ThStyle: 'color:red;'
          , TableAttribute: 'class="table"'
          , TdAttribute: [
                [ 'class="td1-1"', 'class="td1-2"', 'class="td1-3"', 'class="td1-4"', 'class="td1-5"' ]
              , [ 'class="td2-1"', 'class="td2-2"', 'class="td2-3"', 'class="td2-4"', 'class="td2-5"' ]
              , [ 'class="td3-1"', 'class="td3-2"', 'class="td3-3"', 'class="td3-4"', 'class="td3-5"' ]
              , [ 'class="td4-1"', 'class="td4-2"', 'class="td4-3"', 'class="td4-4"', 'class="td4-5"' ]
              , [ 'class="td5-1"', 'class="td5-2"', 'class="td5-3"', 'class="td5-4"', 'class="td5-5"' ]
            ]
          , TrAttribute: [ 'class="tr1"', 'class="tr2"', 'class="tr3"', 'class="tr4"', 'class="tr5"' ]
          , ThAttribute: [ 'class="th1"', 'class="th2"', 'class="th3"', 'class="th4"', 'class="th5"' ]
        })
        html5 := tbl.GetHtml({
            TableStyle: 'color:red;'
          , TdStyle: [ 'color:red;', 'color:green;', 'color:blue;', 'color:pink;', 'color:purple;' ]
          , TrStyle: [ 'color:red;', 'color:green;', 'color:blue;', 'color:pink;', 'color:purple;' ]
          , ThStyle: [ 'color:red;', 'color:green;', 'color:blue;', 'color:pink;', 'color:purple;' ]
          , TableAttribute: 'class="table"'
          , TdAttribute: [
                [ 'class="td1-1"', 'class="td1-2"', 'class="td1-3"', 'class="td1-4"', 'class="td1-5"' ]
              , [ 'class="td2-1"', 'class="td2-2"', 'class="td2-3"', 'class="td2-4"', 'class="td2-5"' ]
              , [ 'class="td3-1"', 'class="td3-2"', 'class="td3-3"', 'class="td3-4"', 'class="td3-5"' ]
              , [ 'class="td4-1"', 'class="td4-2"', 'class="td4-3"', 'class="td4-4"', 'class="td4-5"' ]
              , [ 'class="td5-1"', 'class="td5-2"', 'class="td5-3"', 'class="td5-4"', 'class="td5-5"' ]
            ]
          , TrAttribute: [ 'class="tr1"', 'class="tr2"', 'class="tr3"', 'class="tr4"', 'class="tr5"' ]
          , ThAttribute: [ 'class="th1"', 'class="th2"', 'class="th3"', 'class="th4"', 'class="th5"' ]
        })
        html6 := tbl.GetHtml({
            TableStyle: 'color:red;'
          , TdStyle: [
                [ 'color:red;', 'color:green;', 'color:blue;', 'color:pink;', 'color:purple;' ]
              , [ 'color:purple;', 'color:red;', 'color:green;', 'color:blue;', 'color:pink;' ]
              , [ 'color:pink;', 'color:purple;', 'color:red;', 'color:green;', 'color:blue;' ]
              , [ 'color:blue;', 'color:pink;', 'color:purple;', 'color:red;', 'color:green;' ]
              , [ 'color:green;', 'color:blue;', 'color:pink;', 'color:purple;', 'color:red;' ]
            ]
          , TrStyle: [ 'color:red;', 'color:green;', 'color:blue;', 'color:pink;', 'color:purple;' ]
          , ThStyle: [ 'color:red;', 'color:green;', 'color:blue;', 'color:pink;', 'color:purple;' ]
          , TableAttribute: 'class="table"'
          , TdAttribute: [
                [ 'class="td1-1"', 'class="td1-2"', 'class="td1-3"', 'class="td1-4"', 'class="td1-5"' ]
              , [ 'class="td2-1"', 'class="td2-2"', 'class="td2-3"', 'class="td2-4"', 'class="td2-5"' ]
              , [ 'class="td3-1"', 'class="td3-2"', 'class="td3-3"', 'class="td3-4"', 'class="td3-5"' ]
              , [ 'class="td4-1"', 'class="td4-2"', 'class="td4-3"', 'class="td4-4"', 'class="td4-5"' ]
              , [ 'class="td5-1"', 'class="td5-2"', 'class="td5-3"', 'class="td5-4"', 'class="td5-5"' ]
            ]
          , TrAttribute: [ 'class="tr1"', 'class="tr2"', 'class="tr3"', 'class="tr4"', 'class="tr5"' ]
          , ThAttribute: [ 'class="th1"', 'class="th2"', 'class="th3"', 'class="th4"', 'class="th5"' ]
        })
        html7 := tbl.GetHtml({
            TableStyle: 'color:red;'
          , TdStyle: [
                [ 'color:red;', 'color:green;', 'color:blue;', 'color:pink;', 'color:purple;' ]
              , [ 'color:purple;', 'color:red;', 'color:green;', 'color:blue;', 'color:pink;' ]
              , [ 'color:pink;', 'color:purple;', 'color:red;', 'color:green;', 'color:blue;' ]
              , [ 'color:blue;', 'color:pink;', 'color:purple;', 'color:red;', 'color:green;' ]
              , [ 'color:green;', 'color:blue;', 'color:pink;', 'color:purple;', 'color:red;' ]
            ]
          , TrStyle: [ 'color:red;', 'color:green;', 'color:blue;', 'color:pink;', 'color:purple;' ]
          , ThStyle: [ 'color:red;', 'color:green;', 'color:blue;', 'color:pink;', 'color:purple;' ]
          , TableAttribute: 'class="table"'
          , TdAttribute: [
                [ 'class="td1-1"', 'class="td1-2"', 'class="td1-3"', 'class="td1-4"', 'class="td1-5"' ]
              , [ 'class="td2-1"', 'class="td2-2"', 'class="td2-3"', 'class="td2-4"', 'class="td2-5"' ]
              , [ 'class="td3-1"', 'class="td3-2"', 'class="td3-3"', 'class="td3-4"', 'class="td3-5"' ]
              , [ 'class="td4-1"', 'class="td4-2"', 'class="td4-3"', 'class="td4-4"', 'class="td4-5"' ]
              , [ 'class="td5-1"', 'class="td5-2"', 'class="td5-3"', 'class="td5-4"', 'class="td5-5"' ]
            ]
          , TrAttribute: [ 'class="tr1"', 'class="tr2"', 'class="tr3"', 'class="tr4"', 'class="tr5"' ]
          , ThAttribute: [ 'class="th1"', 'class="th2"', 'class="th3"', 'class="th4"', 'class="th5"' ]
          , InnerLineSeparator: '<br>'
        })
        return md1 '`n`n<br><br>`n' md2 '`n`n<br><br>`n' html1 '`n`n<br><br>`n' html2 '`n`n<br><br>`n' html3 '`n`n<br><br>`n' html4 '`n`n<br><br>`n' html5 '`n`n<br><br>`n' html6 '`n`n<br><br>`n' html7
    }
}
