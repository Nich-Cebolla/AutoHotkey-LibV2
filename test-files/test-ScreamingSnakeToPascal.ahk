
#include ..\ScreamingSnakeToPascal.ahk

test(true)

class test {
    static Call(openTempFolder := true) {
        pathIn := A_Temp '\test-ScreamingSnakeToPascal-input.ahk'
        pathOut1 := A_Temp '\test-ScreamingSnakeToPascal-output1.ahk'
        pathOut2 := A_Temp '\test-ScreamingSnakeToPascal-output2.ahk'
        f := FileOpen(pathIn, 'w')
        f.Write(GetContent())
        f.Close()
        options_calculateOnly := {
            input: { in: pathIn, out: pathOut1 }
          , maxSegments: 4
          , calculateOnly: true
          , prefix: 'CONTAINER'
        }
        result1 := ScreamingSnakeToPascal(options_calculateOnly)
        OutputDebug(result1.GetSymbols() '`n`n')

        options_wordReplacements := {
            input: [
                ; 1st object will use the prefix value of `options_wordReplacements.prefix`.
                { in: pathIn, out: pathOut1 }
                ; 2nd object will use the prefix value of its own "prefix" property and should only
                ; replace "GUICONTROL" and not "CONTAINER".
              , { in: pathIn, out: pathOut2, prefix: { prefix: 'GUICONTROL', replacement: 'GuiControl' } }
            ]
          , maxSegments: 4
          , prefix: [ 'CONTAINER', { prefix: 'GUICONTROL', replacement: 'GuiControl' } ]
          , overwrite: true
          , wordReplacements: Map(
                'SORTTYPE', 'SortType'
              , 'DATESTR', 'DateStr'
              , 'DATEVALUE', 'DateValue'
              , 'STRINGPTR', 'StringPtr'
              , 'INSERTIONSORT', 'InsertionSort'
              , 'CB', 'Cb'
              , 'TYPEINDEX', 'TypeIndex'
              , 'LISTVIEW', 'ListView'
            )
        }
        result2 := ScreamingSnakeToPascal(options_wordReplacements)
        OutputDebug(result2.GetSymbols() '`n')

        if openTempFolder {
            RunWait('explorer "' A_Temp '"')
        }
    }
}


GetContent() {
    return '
    (

Container_SetConstants() {
    global
    local i := 0
    CONTAINER_SORTTYPE_CB_DATE         := ++i
    CONTAINER_SORTTYPE_CB_DATESTR      := ++i
    CONTAINER_SORTTYPE_CB_NUMBER       := ++i
    CONTAINER_SORTTYPE_CB_STRING       := ++i
    CONTAINER_SORTTYPE_CB_STRINGPTR    := ++i
    CONTAINER_SORTTYPE_DATE            := ++i
    CONTAINER_SORTTYPE_DATESTR         := ++i
    CONTAINER_SORTTYPE_DATEVALUE       := ++i
    CONTAINER_SORTTYPE_MISC            := ++i
    CONTAINER_SORTTYPE_NUMBER          := ++i
    CONTAINER_SORTTYPE_STRING          := ++i
    CONTAINER_SORTTYPE_STRINGPTR       := ++i
    CONTAINER_SORTTYPE_END             := i

    CONTAINER_DEFAULT_ENCODING          := 'cp1200'
    CONTAINER_INSERTIONSORT_THRESHOLD   := 16

    i := 0
    GUICONTROL_TYPEINDEX_BUTTON         := ++i
    GUICONTROL_TYPEINDEX_EDIT           := ++i
    GUICONTROL_TYPEINDEX_LISTVIEW       := ++i
    GUICONTROL_TYPEINDEX_END            := i
}

    )'
}
