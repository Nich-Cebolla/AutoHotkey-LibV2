/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/CreateMissingDirectories.ahk
    Author: Nich-Cebolla
    Version: 1.0.0
    License: MIT
*/

/**
 * @description - An alternative to `DirCreate` for creating a directory.
 */
DirCreateEx(Path, DeleteOnError := true) {
    Path := Trim(StrReplace(Path, '/', '\'), '\')
    SplitPath(Path, , &Dir, , , &Drive)
    if !Drive {
        Path := A_WorkingDir '\' Path
        SplitPath(Path, , &Dir, , , &Drive)
    }
    split := StrSplit(Path, '\')
    result := { Path: Path, Segments: split, Created: created := [], Result: 0 }
    p := split.RemoveAt(1)
    created.Capacity := split.Length
    for segment in split {
        p .= '\' segment
        if (file_exist_result := FileExist(p)) && !InStr(file_exist_result, 'D') {
            result.Result := [Error('The path contains a file where a directory was expected.', -1, p)]
            _Delete()
            return result
        }
        if !DirExist(p) {
            try {
                DirCreate(p)
                created.Push(p)
            } catch Error as err {
                result.Result := [err]
                _Delete()
                return result
            }
        }
    }

    return result

    _Delete() {
        if DeleteOnError {
            if created.Length {
                try {
                    DirDelete(created[1], true)
                    result.Created := ''
                } catch Error as err {
                    result.Result.Push(err)
                }
            } else {
                result.Created := ''
            }
        }
    }
}
