
; I have not released TestInterface yet, you cannot run this test.
#include <TestInterfaceConfig>

; #include any scripts
; Note - you have to change the name of the classes because they conflict with classes in "Display"
; at least until you merge them.
#include ..\structs\Rect.ahk
#include ..\structs\Point.ahk
#include ..\structs\WindowInfo.ahk

; ~~~ End include

; Filter := PropsInfo.FilterGroup()

; Filter := PropsInfo.FilterGroup(FilterFunc)

; FilterFunc(InfoItem) {

; }

; ~~~ End filters

; include any extra files that aren't #included above

; paths := []

; Dirs := [
; ]
; paths := RecursiveGetFiles(Dirs, , paths ?? unset)

NameTestInterface := 'Rect'
Exclude := '__Init,Prototype,Base'
SubjectsVar := 'Subjects'
FilterVar := ''

; StopAt := GPI_STOP_AT_DEFAULT ?? '-Object'
; Exclude := ''
; IncludeBaseProp := true
; &OutBaseObjList?
; ExcludeMethods := false
PropsInfoParamsCallback(cls, collection) {
    return [ '-Class', '__Init,__New', false ]
}

ScriptNameCallback(index, path) {
    return ''
}
ToInitialValuesCodePaamsCallback(Name, Subject) {
    Obj := Subject.PropsInfo.Root
    if obj is Class {
        return GetGetPropsInfoParamsString('-Class')
    } else if Obj is Array {
        return GetGetPropsInfoParamsString('-Array')
    } else if Obj is Map {
        return GetGetPropsInfoParamsString('-Map')
    } else {
        return GetGetPropsInfoParamsString('-Object')
    }
}

GetGetPropsInfoParamsString(
    StopAt := "''"
  , Exclude := "''"
  , IncludeBaseProp := 'false'
  , OutBaseObjList := ''
  , ExcludeMethods := 'false'
) {
    return Format("'{}, {}, {}, {}, {}'", StopAt, Exclude, IncludeBaseProp, OutBaseObjList, ExcludeMethods)
}

; ~~~ End config


RecursiveGetFiles(Dirs, opt := 'FR', paths?) {
    if !IsSet(paths) {
        paths := []
    }
    for Dir in Dirs {
        loop Files Dir '\*', opt {
            if SubStr(A_LoopFileName, 1, 1) == '.' {
                continue
            }
            if A_LoopFileExt = 'ahk' {
                paths.Push(A_LoopFileFullPath)
            }
        }
    }
    return paths
}

; ~~~ End paths

Content := FileRead(A_ScriptFullPath)
pos1 := InStr(Content, '; ~~~ End include')
pos2 := InStr(Content, '; ~~~ End filters')
Indent := '`s`s`s`s`s`s`s`s'
codeHeader := Trim(SubStr(Content, 1, pos1 - 1), '`r`n')
codeHeaderPart := ''
if IsSet(paths) {
    for path in paths {
        codeHeaderPart .= '#include ' path '`n'
    }
}
codeFilters := ''
for line in StrSplit(Trim(SubStr(Content, pos1 + 18, pos2 - pos1 - 18), '`r`n'), '`n', '`r') {
    codeFilters .= Indent line '`n'
}

pos := 1
if !IsSet(paths) {
    paths := []
}
while RegExMatch(codeHeader,
    'J)'
    '(?<dir>'
        '(?:'
            '(?<drive>[a-zA-Z])'
            ':'
        '|'
            '\.\.'
        '|'
            '[^\r\n\\/:*?"<>|]++'
        ')'
        '\\'
        '(?:[^\r\n\\/:*?"<>|]++\\?)+'
    ')'
    '\\'
    '(?<file>[^\r\n\\/:*?"<>|]+?)'
    '\.'
    '(?<ext>\w+)'
    '\b'
  , &Match, pos) {
    pos := Match.Pos + Match.Len
    paths.Push(StrReplace(Match[0], '#include ', ''))
}
codeHeader .= '`n' codeHeaderPart

AllSubjects := Map()

for path in paths {
    if path is RegExMatchInfo {
        if path['drive'] {
            fullPath := path[0]
        } else {
            loop Files path[0] {
                fullPath := A_LoopFileFullPath
            }
        }
        name := path['file']
    } else {
        SplitPath(path, , , , &name, &Drive)
        if Drive {
            fullPath := path
        } else {
            loop Files path {
                fullPath := A_LoopFileFullPath
            }
        }
    }
    AllSubjects.Set(fullPath, obj := {})
    obj.ScriptParser := ScriptParser(fullPath)
    obj.FileName := name
    obj.Fullpath := fullPath
    obj.Subjects := TestInterface.SubjectCollection.FromScriptParser(
        obj.ScriptParser
        ; SubjectCollectionObj
      , unset
        ; Filter
      , IsSet(Filter) && Filter.Count ? Filter : unset
        ; Functions
      , true
        ; Classes
      , true
        ; PropsInfoParamsCallback
      , PropsInfoParamsCallback
    )
}

code := (
    codeHeader
    '`n`ntest()`n`n'
    'class test {`n'
    '    static Call() {`n'
    codeFilters
    Indent 'Subjects := TestInterface.SubjectCollection()`n'
    '`n'
)

for path, obj in AllSubjects {
    scriptName := ScriptNameCallback(A_Index, Path)
    code .= (
        Indent '; ' obj.FileName '`n'
        Indent scriptName ' := ScriptParser(`'' obj.FullPath '`')`n'
        obj.Subjects.ToInitialValuesCode(
            ; FunctionInitialValue
            ''
            ; MethodInitialValue
          , ', '
            ; PropGetInitialValue
          , ', '
            ; PropSetInitialValue
          , ', '
            ; GetPropsInfoParams
          ,
            ; SubjectsVar
          , SubjectsVar
            ; ScriptParserVar
          , scriptName
            ; FilterVar
          , FilterVar
            ; Indent
          , Indent
        )
    )
}

code .= (
    '`n' Indent 'TI := this.TI := TestInterface(`'' NameTestInterface '`', Subjects)`n'
    '`n`s`s`s`s}'
    '`n}'
)

A_Clipboard := code
