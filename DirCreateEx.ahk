/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/DirCreateEx.ahk
    Author: Nich-Cebolla
    Version: 1.0.0
    License: MIT
*/

/**
 * @description - An alternative to `DirCreate` for creating a directory.
 *
 * An example with no errors:
 * @example
 *  Path := 'C:\Users\Shared\NewDir\Games\Pong.exe'
 *  result := DirCreateEx(Path, , true)
 *  MsgBox(result.Result) ; 0
 *  MsgBox(result.Path) ; C:\Users\Shared\NewDir\Games
 *  MsgBox(result.Created.Length) ; 2
 *  DirDelete('C:\users\Shared', true)
 * @
 *
 * An example with errors:
 * @example
 *  Path := 'C:\Users\NonexistantDir\NewDir\Games\Pong.exe'
 *  result := DirCreateEx(Path, , true)
 *  if result.Result {
 *      result.ShowGui()
 *  }
 * @
 * @param {String} Path - If `Path` is not an absolute path, it is assumed to be relative to the
 * working directory.
 * - If `Path` contains forward slashes ( / ), they are changed to backslashes ( \ ).
 * - Leading and trailing slashes are removed before processing.
 * @param {Boolean} [DeleteOnError = true] - If true, and if an error occurs after creating one or
 * more directories, `DirCreateEx` will attempt to delete the created directories.
 * @param {Boolean} [PathIsFile = false] - If true, `DirCreateEx` will remove the last segment from
 * the path before processing.
 * @returns {DirCreateEx.Result} - An object with the following properties:
 * - Created - If one or more directories were created and not deleted after an error, an array of
 * strings where each string is the path to a created directory. Else, an empty string.
 * - ErrorDirCreate - If the function fails when calling `DirCreate`, the error object is set
 * to this property. Otherwise, this will be `0`.
 * - ErrorDirDelete - If the function fails and `DeleteOnError` is true and an error occurs when
 * deleting a directory that was created by this function, the error object is set to this property.
 * Otherwise, this will be `0`.
 * - ErrorFileExist - If the function fails because a file exists where a directory was expected,
 * the error object is set to this property. Otherwise, this will be `0`.
 * - Path - The input `Path` value after trimming the leading and trailing slashes and after
 * forward slashes ( / ) have been replaced with backslashes ( \ ).
 * - Result - If the function is successful, the value is `0`. Otherwise, `Result` is one of the
 * following integers:
 *   - 1 - The reason the function failed is because a file exists where a directory was expected.
 *   - 2 - The reason the function failed is because `DirCreate` threw an error.
 * - Segments - The return value from `StrSplit(Path, "\")`.
 */
class DirCreateEx {
    static Call(Path, DeleteOnError := true, PathIsFile := false) {
        if FileExist(Path) {
            throw Error('The path already exists.', -1, Path)
        }
        Path := Trim(StrReplace(Path, '/', '\'), '\')
        if PathIsFile {
            Path := SubStr(Path, 1, InStr(Path, '\', , , -1) - 1)
        }
        result := DirCreateEx.Result()
        result.Path := Path
        SplitPath(Path, , , , , &Drive)
        if !Drive {
            Path := A_WorkingDir '\' Path
        }
        split := result.Segments := StrSplit(Path, '\')
        created := []
        i := 1
        p := split[1]
        created.Capacity := split.Length
        loop split.Length - 1 {
            p .= '\' split[++i]
            if (file_exist_result := FileExist(p)) && !InStr(file_exist_result, 'D') {
                result.ErrorFileExist := Error('The path contains a file where a directory was expected.', -1, p)
                _Delete()
                break
            }
            if !DirExist(p) {
                try {
                    DirCreate(p)
                    created.Push(p)
                } catch Error as err {
                    result.ErrorDirCreate := err
                    _Delete()
                    break
                }
            }
        }
        result.Created := created.Length ? created : ''

        return result

        _Delete() {
            if DeleteOnError {
                if created.Length {
                    try {
                        loop created.Length {
                            DirDelete(created[-1], true)
                            created.Pop()
                        }
                    } catch Error as err {
                        result.ErrorDirDelete := err
                    }
                }
            }
        }
    }
    class Result {
        GetError() {
            return this.ErrorDirCreate || this.ErrorFileExist
        }
        ShowGui() {
            s := ''
            for prop in ['ErrorDirCreate', 'ErrorDirDelete', 'ErrorFileExist'] {
                if this.%prop% {
                    _Add(this.%prop%)
                }
            }
            s := RegExReplace(s, '\R', '`r`n')
            g := Gui()
            g.SetFont('s10', 'Segoe UI')
            g.Add('Edit', 'w' (A_ScreenWidth * 0.35) ' Section -wrap +HScroll vEdtError', s)
            if this.Created {
                paths := ''
                for p in this.Created {
                    paths .= p '`r`n'
                }
                paths := Trim(paths, '`r`n')
                g.Add('Edit', 'w' (A_ScreenWidth * 0.35) ' xs -wrap +HScroll vEdtPath', paths)
                g.Add('Checkbox', 'xs Section Checked vChkError', 'Copy error info')
                g.Add('Checkbox', 'ys Checked vChkPath', 'Copy paths')
                g.Add('Button', 'xs Section vBtnCopy', 'Copy').OnEvent('Click', HClickButtonCopy1)
            } else {
                g.Add('Button', 'xs Section vBtnCopy', 'Copy').OnEvent('Click', HClickButtonCopy2)
            }
            g['BtnCopy'].Focus()
            g.Add('Button', 'ys vBtnClose', 'Close').OnEvent('Click', HClickButtonClose)
            g.Add('Button', 'ys vBtnExit', 'Exit').OnEvent('Click', HClickButtonExit)
            g.Show('NoActivate')
            HClickButtonClose(Ctrl, *) {
                Ctrl.Gui.Destroy()
            }
            HClickButtonCopy1(Ctrl, *) {
                g := Ctrl.Gui
                if g['ChkError'].Value {
                    if g['ChkPath'].Value {
                        A_Clipboard := g['EdtError'].Text '`r`n`r`n' g['EdtPath'].Text
                    } else {
                        A_Clipboard := g['EdtError'].Text
                    }
                } else if g['ChkPath'].Value {
                    A_Clipboard := g['EdtPath'].Text
                }
                ShowTooltip('Copied')
            }
            HClickButtonCopy2(Ctrl, *) {
                A_Clipboard := Ctrl.Gui['EdtPath'].Text
                ShowTooltip('Copied')
            }
            HClickButtonExit(Ctrl, *) {
                ExitApp()
            }
            _Add(err) {
                if s {
                    s .= '`r`n==============`r`n'
                }
                s .= (
                    'Type: ' Type(err)
                    '`r`nMessage:`r`n' err.Message
                    '`r`nWhat: ' err.What
                    '`r`nFile: ' err.File
                    '`r`nLine: ' err.Line
                    '`r`nExtra: ' err.Extra
                )
                if err is OSError {
                    s .= '`r`nNumber: ' err.Number
                }
                if VerCompare(A_AhkVersion, '2.1-a10') >= 0 && HasProp(err, 'Hint') {
                    s .= '`r`nHint:`r`n' err.Hint
                }
                s .= '`r`nStack:`r`n' err.Stack
            }
            ShowTooltip(Str, Duration := -2000, X?, Y?, OffsetX := 0, OffsetY := 0) {
                static N := [1,2,3,4,5,6,7]
                Z := N.Pop()
                OM := CoordMode('Mouse', 'Screen')
                OT := CoordMode('Tooltip', 'Screen')
                MouseGetPos(&tempX, &tempY)
                if !IsSet(X) {
                    X := tempX
                }
                if !IsSet(Y) {
                    Y := tempY
                }
                Tooltip(Str, X + OffsetX, Y + OffsetY, Z)

                SetTimer(_End.Bind(Z), -Abs(Duration))
                CoordMode('Mouse', OM)
                CoordMode('Tooltip', OT)

                _End(Z) {
                    ToolTip(,,,Z)
                    N.Push(Z)
                }
            }
        }
        ErrorDirCreate {
            Get => 0
            Set {
                this.DefineProp('ErrorDirCreate', { Value: Value })
                this.DefineProp('Result', { Value: 2 })
            }
        }
        ErrorDirDelete {
            Get => 0
            Set {
                this.DefineProp('ErrorDirDelete', { Value: Value })
            }
        }
        ErrorFileExist {
            Get => 0
            Set {
                this.DefineProp('ErrorFileExist', { Value: Value })
                this.DefineProp('Result', { Value: 1 })
            }
        }
        Result {
            Get => 0
            Set {
                this.DefineProp('Result', { Value: Value })
            }
        }

    }
}
