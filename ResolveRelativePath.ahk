/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/ResolveRelativePath.ahk
    Author: Nich-Cebolla
    Version: 1.0.0
    License: MIT
*/

/**
 * @description - Processes a relative path with any number of ".\" or "..\" segments.
 * @param {String} Path - The path to evaluate.
 * @param {String} [RelativeTo] - The location `Path` is relative to. If unset, the working directory
 * is used. `RelativeTo` can also be relative with "..\" leading segments.
 * @returns {String}
 */
ResolveRelativePath(Path, RelativeTo?) {
    if IsSet(RelativeTo) && RelativeTo {
        SplitPath(RelativeTo, , , , , &Drive)
        if !Drive {
            if InStr(RelativeTo, '.\') {
                w := A_WorkingDir
                _Process(&RelativeTo, &w)
            } else {
                RelativeTo := A_WorkingDir '\' RelativeTo
            }
        }
    } else {
        RelativeTo := A_WorkingDir
    }
    if InStr(Path, '.\') {
        _Process(&Path, &RelativeTo)
        return RTrim(Path, '\')
    } else {
        return RTrim(RelativeTo '\' Path, '\')
    }

    _Process(&path, &relative) {
        split := StrSplit(path, '\')
        segments := []
        segments.Capacity := split.Length
        path := ''
        i := 0
        for s in split {
            if s == '.' {
                continue
            } else if s == '..' {
                if Segments.Length {
                    segments.RemoveAt(-1)
                } else {
                    relative := SubStr(relative, 1, InStr(relative, '\', , , -1) - 1)
                }
            } else {
                segments.Push(A_Index)
            }
        }
        if segments.Length {
            for i in segments {
                path .= '\' split[i]
            }
            if relative {
                path := relative path
            } else {
                _Throw()
            }
        } else if relative {
            path := relative
        } else {
            _Throw()
        }
    }
    _Throw() {
        throw ValueError('Invalid input parameters.', -2)
    }
}

/**
 * @description - Processes a relative path with any number of ".\" or "..\" segments.
 * @param {VarRef} Path - A variable containing the relative path to evaluate as string.
 * @param {String} [RelativeTo] - The location `Path` is relative to. If unset, the working directory
 * is used. `RelativeTo` can also be relative with "..\" leading segments.
 */
ResolveRelativePathRef(&Path, RelativeTo?) {
    if IsSet(RelativeTo) && RelativeTo {
        SplitPath(RelativeTo, , , , , &Drive)
        if !Drive {
            if InStr(RelativeTo, '.\') {
                w := A_WorkingDir
                _Process(&RelativeTo, &w)
            } else {
                RelativeTo := A_WorkingDir '\' RelativeTo
            }
        }
    } else {
        RelativeTo := A_WorkingDir
    }
    if InStr(Path, '.\') {
        _Process(&Path, &RelativeTo)
    } else {
        Path := RelativeTo '\' Path
    }
    Path := RTrim(Path, '\')

    _Process(&path, &relative) {
        split := StrSplit(path, '\')
        segments := []
        segments.Capacity := split.Length
        path := ''
        i := 0
        for s in split {
            if s == '.' {
                continue
            } else if s == '..' {
                if Segments.Length {
                    segments.RemoveAt(-1)
                } else {
                    relative := SubStr(relative, 1, InStr(relative, '\', , , -1) - 1)
                }
            } else {
                segments.Push(A_Index)
            }
        }
        if segments.Length {
            for i in segments {
                path .= '\' split[i]
            }
            if relative {
                path := relative path
            } else {
                _Throw()
            }
        } else if relative {
            path := relative
        } else {
            _Throw()
        }
    }
    _Throw() {
        throw ValueError('Invalid input parameters.', -2)
    }
}
