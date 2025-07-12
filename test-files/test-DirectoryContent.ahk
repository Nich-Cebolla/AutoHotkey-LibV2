
#include ..\DirectoryContent.ahk

; https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/ResolveRelativePath.ahk
#include <ResolveRelativePath>

; https://github.com/Nich-Cebolla/StringifyAll
; Only needed if writing output to file
#include *i <StringifyAll>

wd := A_Temp '\test-DirectoryContent'
if DirExist(wd) {
    DirDelete(wd, 1)
}
DirCreate(wd)
SetWorkingDir(wd)
root := wd '\' test_DirectoryContent.directory
for path in test_DirectoryContent.Paths {
    if !path {
        continue
    }
    if !DirExist(root '\' path) {
        DirCreate(root '\' path)
    }
}
for path in test_DirectoryContent.Files {
    if !DirExist(root '\' path) {
        FileAppend('', root '\' path)
    }
}
OnExit(_DeleteDir.Bind(wd))
_DeleteDir(wd, *) {
    if DirExist(wd) {
        DirDelete(wd, 1)
    }
}

test_DirectoryContent(0)

class test_DirectoryContent {
    static __New() {
        StopAtTypeMap := Map()
        StopAtTypeMap.CaseSense := false
        StopAtTypeMap.Default := '-Object'
        StopAtTypeMap.Set(
            'DirectoryContent.DirectoryCollection', '-Map'
          , 'DirectoryContent.DirectoryList', '-Array'
          , 'DirectoryContent.FileList', '-Array'
        )
        EnumTypeMap := Map()
        EnumTypeMap.CaseSense := false
        EnumTypeMap.Default := 1
        EnumTypeMap.Set('DirectoryContent.DirectoryCollection', 2)
        this.StringifyOptions :=  { StopAtTypeMap: StopAtTypeMap, EnumTypeMap: EnumTypeMap }
    }
    static PathEditor := 'code-insiders'
    , PathOut := A_MyDocuments '\out\test-DirectoryContent.json'
    , PathOutRelativeParent := A_MyDocuments '\out\test-DirectoryContent-relative-parent.json'
    , PathOutRelativeExternal := A_MyDocuments '\out\test-DirectoryContent-relative-external.json'
    , Paths := [ '', '1', '1\2', '1\2\3', '1\2\3\4', '1b', '1c' ]
    , Files := [ 'r', 'r.txt', '1\1', '1\1.txt', '1\2\2', '1\2\2.txt', '1\2\3\3', '1\2\3\3.txt'
        , '1\2\3\4\4', '1\2\3\4\4.txt', '1b\1b', '1b\1b.txt', '1c\1c', '1c\1c.txt' ]
    , Directory := 'directory'
    , DirectoryProperties := 'Dir,FullPath,Name,Path'
    , FileProperties := 'Dir,Ext,FullPath,Name,Path'

    static Call(WriteOut := false) {
        result := this.GetResult()
        if WriteOut {
            options := this.StringifyOptions
            for s in [ '', 'RelativeParent' ] {
                _Write(this.%'PathOut' s%, result.%'content' s%)
            }
        }
        relativePaths := this.Paths
        fullPaths := []
        for path in relativePaths {
            if path {
                fullPaths.Push(A_WorkingDir '\' this.Directory '\' path)
            } else {
                fullPaths.Push(A_WorkingDir '\' this.Directory)
            }
        }
        relativeFiles := this.Files
        fullFiles := []
        for path in relativeFiles {
            fullFiles.Push(A_WorkingDir '\' this.Directory '\' path)
        }
        for name, _result in result.OwnProps() {
            directories := _result.Directories
            files := _result.Files
            if directories.Count !== relativePaths.Length || files.Length !== relativeFiles.Length {
                OutputDebug(Format(A_LineNumber '  :: Invalid number of items`ndirectories: {}`nfiles: {}`n', directories.Count, files.Length))
                return
            }
            for path, items in directories {
                SplitPath(path, , , , , &Drive)
                if Drive {
                    ds := fullPaths
                    fs := fullFiles
                    prop := 'FullPath'
                    dir := A_WorkingDir '\' this.Directory
                } else {
                    ds := relativePaths
                    fs := relativeFiles
                    prop := 'Relative'
                    dir := ''
                }
                break
            }
            cloneDir := ds.Clone()
            cloneFiles := fs.Clone()
            cloneDir2 := ds.Clone()
            for path, items in directories {
                flag := false
                for p in cloneDir {
                    if p = path {
                        flag := true
                        cloneDir.RemoveAt(A_Index)
                        break
                    }
                }
                if !flag {
                    OutputDebug(A_LineNumber '  :: Dir path not found: ' path '`n')
                    return
                }
                if _Search(items.Files, cloneFiles) {
                    return
                }
                if _Search(items.Directories, cloneDir2) {
                    return
                }
            }
            if _Output1(A_LineNumber, 'directories', cloneDir) {
                return
            }
            if _Output1(A_LineNumber, 'files', cloneFiles) {
                return
            }
            if cloneDir2.Length !== 1 || cloneDir2[1] != dir {
                if _Output1(A_LineNumber, 'directories', cloneDir2) {
                    return
                }
            }
        }

        _Recurse(items) {

        }
        _Output1(line, what, arr) {
            if arr.Length {
                s := ''
                for p in arr {
                    s .= p ', '
                }
                OutputDebug(line '  :: ' what ' paths remaining: ' SubStr(s, 1, -2) '`n')
                return 1
            }
        }
        _Search(contentArr, pathArr) {
            for o in contentArr {
                for p in pathArr {
                    if p = o.%prop% {
                        pathArr.RemoveAt(A_Index)
                        continue 2
                    }
                }
                OutputDebug(A_LineNumber '  :: Path not found: ' o.%prop% '`n')
                return 1
            }
        }
        _Write(path, result) {
            f := FileOpen(path, 'w')
            f.Write(StringifyAll(result, options))
            sleep 500
            f.Close()
        }
    }
    static GetResult() {
        result := this.Result := {}
        result.content := DirectoryContent(this.Directory, this.FileProperties, this.DirectoryProperties)
        result.contentRelativeParent := DirectoryContent(this.Directory, this.FileProperties, this.DirectoryProperties, this.Directory)
        try {
            result.contentRelativeExternal := DirectoryContent(this.Directory, this.FileProperties, this.DirectoryProperties, '..\..\SomeDir')
        } catch ValueError as err{

        } else {
            OutputDebug('A ValueError did not occur.`n')
            Exit()
        }
        return result
    }
}
