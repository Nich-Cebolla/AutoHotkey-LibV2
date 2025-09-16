

CombineScripts(List, OutPath?, Separator?, Encoding?, LineEnding := '`n', Overwrite := false, &OutIncludeFilesList?) {
    s := ''
    VarSetStrCapacity(&s, 131072)
    if !IsSet(Separator) {
        Separator := '
        (
            /***************************************************************************************
             *
             *      {}
             *
             ***************************************************************************************/
        )'
    }

    for path in List {
        SplitPath(path, , , , &fileName)
        s .= LineEnding Format(Separator, fileName) LineEnding LineEnding FileRead(path, Encoding ?? unset) LineEnding
    }
    files := LineEnding
    OutIncludeFilesList := []
    pos := 1
    while RegExMatch(s, 'i)(?<=[\r\n]|^)#include[ \t]+(.+)', &match, pos) {
        pos := match.Pos
        OutIncludeFilesList.Push(match)
        files .= match[0] LineEnding
        s := RegExReplace(s, 'i)(?<=[\r\n]|^)\Q' match[0], '')
    }

    VarSetStrCapacity(&s, -1)
    if IsSet(OutPath) {
        if FileExist(OutPath) && !Overwrite {
            throw Error('File already exists.', -1, OutPath)
        }
        f := FileOpen(OutPath, 'w', Encoding ?? unset)
        f.Write(files s)
        f.Close()
    }
    return files s
}

GetScriptList(Pattern, Options := 'F') {
    List := []
    loop Files Pattern, options {
        List.Push(A_LoopFileFullPath)
    }
    return List
}

class ScriptLibraryFolders {
    static __New() {
        this.DeleteProp('__New')
        proto := this.Prototype
        proto.PathLocal := A_ScriptDir '\lib'
        proto.PathUser := A_MyDocuments '\AutoHotkey\lib'
        SplitPath(A_AhkPath, , &Dir)
        proto.PathStandard := Dir '\lib'
    }
    __New() {
        this.ListLocal := Map()
        this.ListUser := Map()
        this.ListStandard := Map()

        for name in [ 'Local', 'User', 'Standard' ] {
            list := this.List%name%
            dir := this.Path%name%
            loop Files dir '\*' {
                SplitPath(A_LoopFileFullPath, , , , &fileName)
                list.Set(fileName, { Path: A_LoopFileFullPath, Name: fileName, Ext: A_LoopFileExt, Dir: A_LoopFileDir })
            }
        }
    }
}
