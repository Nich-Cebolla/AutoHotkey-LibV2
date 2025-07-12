/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/GetRelativePath.ahk
    Author: Nich-Cebolla
    Version: 1.0.1
    License: MIT
*/

; https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/ResolveRelativePath.ahk
#include <ResolveRelativePath>

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
 * @returns {String} - If successful, returns the new relative path.
 * @throws {ValueError} - If the paths are on different drives.
 * @throws {ValueError} - If `Path` does not resolve as relative to `RelativeTo`.
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
        ResolveRelativePathRef(&Path)
        SplitPath(Path, , &pDir, &pExt, &pName, &pDrive)
    }
    SplitPath(RelativeTo, , &rDir, , &rName, &rDrive)
    if !rDrive {
        ResolveRelativePathRef(&RelativeTo)
        SplitPath(RelativeTo, , &rDir, , &rName, &rDrive)
    }
    if Path = RelativeTo {
        return ''
    }
    if pDrive !== rDrive {
        throw ValueError('The paths must be within the same drive.', -1)
    }
    pSplit := StrSplit(Path, '\')
    rSplit := StrSplit(RelativeTo, '\')
    i := 0
    if pSplit.Length > rSplit.Length {
        loop rSplit.Length {
            ++i
            if pSplit[i] != rSplit[i] {
                throw ValueError('``Path`` does not evaluate as relative to ``RelativeTo``.', -1, Path)
            }
        }
    } else {
        loop pSplit.Length {
            ++i
            if pSplit[i] != rSplit[i] {
                break
            }
        }
    }
    s := ''
    k := i
    while ++k <= rSplit.Length {
        s .= '..\'
    }
    while ++i <= pSplit.Length {
        s .= pSplit[i] '\'
    }
    if flag_bs {
        return SubStr(s, 1, -1)
    } else {
        return StrReplace(SubStr(s, 1, -1), '\', '/')
    }
}
