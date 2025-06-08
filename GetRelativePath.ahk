/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/GetRelativePath.ahk
    Author: Nich-Cebolla
    Version: 1.0.0
    License: MIT
*/

/**
 * @description - Converts a path into a relative path.
 * @param {String} Path - The path that will be converted to a relative path.
 * - `Path` can be a path to directory or file.
 * - `Path` can be relative. If `Path` is relative, it will first be resolved relative to the working
 * directory. If `RelativeTo` is the working directory, then there will be no effective change in `Path`.
 * - The path does not need to exist.
 * @param {String} [RelativeTo] - The effective relative location for which `Path` will be evaluated.
 * - If unset, the working directory is used.
 * - `RelativeTo` should always be a directory path. Using a file path will throw off the results by 1
 * directory level.
 * - `RelativeTo` can also be relative. If it is a relative path, `RelativeTo` will be resolved relative
 * to the working directory.
 * - The path does not need to exist.
 * @returns {String|Integer} - If successful, returns the new relative path.
 * - If the input `Path` and input `RelativeTo` are located on different drives, returns `1`.
 */
GetRelativePath(Path, RelativeTo?) {
    if !IsSet(RelativeTo) {
        RelativeTo := A_WorkingDir
    }
    StrReplace(Path, '\', , , &bs)
    Path := StrReplace(Path, '/', '\', , &fs)
    flag_bs := bs > fs
    RelativeTo := StrReplace(RelativeTo, '/', '\')
    SplitPath(Path, , &pDir, &pExt, &pName, &pDrive)
    if !pDrive {
        _ResolvePath(&Path)
        SplitPath(Path, , &pDir, &pExt, &pName, &pDrive)
    }
    SplitPath(RelativeTo, , &rDir, , &rName, &rDrive)
    if !rDrive {
        _ResolvePath(&RelativeTo)
        SplitPath(RelativeTo, , &rDir, , &rName, &rDrive)
    }
    if pDrive !== rDrive {
        return 1
    }
    pSplit := StrSplit(Path, '\')
    if !pSplit[-1] {
        pSplit.Pop()
    }
    rSplit := StrSplit(RelativeTo, '\')
    if !rSplit[-1] {
        rSplit.Pop()
    }
    i := 1
    low := Min(pSplit.Length, rSplit.Length)
    loop {
        if i >= low || pSplit[i] != rSplit[i] {
            break
        }
        ++i
    }
    s := ''
    k := i - 1
    while ++k <= rSplit.Length {
        s .= '..\'
    }
    while i <= pSplit.Length {
        s .= pSplit[i++] '\'
    }
    return Trim(s, '\')

    _ResolvePath(&_Path) {
        w := A_WorkingDir
        while SubStr(_Path, 1, 3) == '..\' {
            w := SubStr(w, 1, InStr(w, '\', , , -1) - 1)
            _Path := SubStr(_Path, 4)
        }
        _Path := StrReplace(w '\' _Path, '\\', '\')
    }

}
