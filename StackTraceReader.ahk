

class StackTraceReader {
    static FromError(ErrorObj, LinesBefore := 0, LinesAfter := 0, Callback?, Encoding := 'utf-8') {
        if not ErrorObj is Error {
            throw TypeError('``ErrorObj`` must be an instance of ``Error`` or one of its subclasses.', -1)
        }
        return this.Read(this.ParseStack(ErrorObj), LinesBefore, LinesAfter, Callback ?? unset, Encoding)
    }

    static ParseStack(err) {
        Split := StrSplit(err.Stack, '`n', '`r`t`s')
        Result := []
        Result.Capacity := Split.Length
        for Line in Split {
            if RegExMatch(
                Line
              , '(?<Path>(?<dir>(?:(?<drive>[a-zA-Z]):\\)?(?:[^\r\n\\/:\*\?"<>\|]+\\?)+)\\(?<name>[^\r\n\\/:\*\?"<>\|]+)\.(?<ext>\w+))\b'
                '[ \t]+' '\((?<Line>\d*)\)' '[ \t:]+' '\[(?<Name>.*?)\][ \t]+(?<context>.+)'
              , &Match
            ) {
                Result.Push(Match)
            }
        } else {
            Result.Push(Line)
        }
        return Result
    }

    /**
     * @description - Returns an array of strings containing the requested content.
     * @param {Array} Arr - `Arr` can contain any values of any type or value.
     * - Unset array indices are skipped and are not represented in the result array.
     * - For `StackTraceReader.Read` to process a value, it must match one of the below sets of
     * characteristics. If an item does not match, processing is skipped and it is added to the result
     * array without modification. All items in the result array are objects, so unprocessed values
     * are added as an object with one property `{ Value }`.
     *   - A string value in the format "<line> <lines before> <lines after> <encoding> <path>",
     * where <line> and <path> are required, and each of the others are optional. You cannot
     * specify a <lines after> value without also specifying a <lines before> value, because the
     * function will always interpret the first number after <line> as the value for <lines before>.
     * You can use "0" for the <lines before> value to direct the function to use the input
     * parameter `LinesBefore` and use the specified <lines after> from the string. To set either
     * of <lines before> or <lines after> to literal zero such that no additional lines in the
     * direction are included, use a single hyphen "-".
     * the function. When <lines before>, <lines after>, and <encoding> are not included in the string,
     * the values that are passed to the function call are used.
     * "25 3 3 ..\src\MyClass.ahk" or "603 - 1 utf-8 ..\src\MyClass.ahk" or
     * "311 C:\users\name\documents\autohotkey\lib\myfile.ahk"
     *   - An object that minimally has two properties `{ Path, Line }`, but also may have a property
     * with the same name as the parameters `LinesBefore`, `LinesAfter`, `Callback`, or `Encoding`
     * which will direct `Read` to use those values instead of the values passed to the
     * function. If the values of the property are RegExMatchInfo objects, the `0` item will be used
     * for the string value.
     * - A RegExMatchInfo object with minimally the subcapture groups "path" and "line", but also
     * may have subcapture groups with the same name as the parameters `LinesBefore`, `LinesAfter`,
     * `Callback`, or `Encoding` which will direct `Read` to use those values instead of
     * the values passed to the function.
     * @param {Number} [LinesBefore=0] - The number of lines before the input line number to include
     * in the result string for that item.
     * @param {Number} [LinesAfter=0] - The number of lines after the input line number to include
     * in the result string for that item.
     * @param {Func} [Callback] - A function that will be called on each content item. The only
     * parameter of the function will receive the the `Params` object that gets constructed by
     * the function for each item. (See the description in the @returns section for more information).
     * The content that was read from the file is on the property `Value`. The function can make
     * any changes to the value as needed.
     * - To exclude the string from the result array, the function can set `Value` to an empty string.
     * - To direct `StackTraceReader.Read` to return the result array immediately, the function can
     * return a nonzero value.
     * @param {String} [Encoding='utf-8'] - The encoding of the files to read.
     * @returns {Array} - For each item in the input `Arr`, an object is added to this result array.
     * The base for each object is set to a different object constructed by the function using
     * the input parameter values.
     * @example
     *  Default := { LinesBefore: LinesBefore, LinesAfter: LinesAfter, Callback: Callback ?? '', Encoding: Encoding }
     * @
     * Each object therefore has an effective value for each of this function's parameters, but
     * the base properties will be from the function call's input, and the object's own properties
     * will be only present if the input item specified a value for that parameter.
     * @example
        StackArr := [
            { Line: 303, LinesBefore: 5, LinesAfter: 0, Path: '..\src\file1.ahk' }
          , { Line: 10, Path: '..\data.ahk' }
        ]
        Result := StackTraceReader.Read(StackArr, 2, 2)
        MsgBox(Result[1].LinesBefore) ; 5
        MsgBox(Result[1].LinesAfter) ; 0
        MsgBox(Result[1].Path) ; ..\src\file1.ahk
        ; this is "utf-8" because the default value is "utf-8", which would caused the base object
        ; `Result[1].Base` to have a property `Encoding` with a value "utf-8".
        MsgBox(Result[1].Encoding) ; "utf-8"
        MsgBox(Result[1].HasOwnProp('Encoding')) ; 0
        MsgBox(HasProp(Result[1], 'Encoding')) ; 1
        ; Similarly, these two properties are also from `Result[2].Base`, not `Result[2]`.
        MsgBox(Result[2].LinesBefore) ; 2
        MsgBox(Result[2].LinesAfter) ; 2
        MsgBox(Result[2].HasOwnProp('LinesAfter')) ; 0
        MsgBox(HasProp(Result[2], 'LinesAfter')) ; 1
     * @
     * - If the input item was not processed by the function (i.e. it was a string or number and did
     * not match the required format), then its value in this array is an object with property
     * { Value }. `Value` contains the value.
     * - If the item was processed by the function, an object with minimally the
     * properties { Path, Line, Value } where `Value` is the string value that was read from file
     * after any modifications from calling the callback (if included), and zero or more of the
     * properties '{ LinesBefore, LinesAfter, Callback, Encoding }` depending on whether the
     * associated parameter's value value was specified by the input item. If the input item was
     * a `RegExMatchInfo` object, a property `Match` is included with the match info object.
     */
    static Read(Arr, LinesBefore := 0, LinesAfter := 0, Callback?, Encoding := 'utf-8') {
        Default := { LinesBefore: LinesBefore, LinesAfter: LinesAfter, Callback: Callback ?? '', Encoding: Encoding }
        Result := []
        Objects := []
        Result.Capacity := Arr.Length
        for Item in Arr {
            if !IsSet(Item) {
                continue
            }
            switch Type(Item), 0 {
                case 'String':
                    if RegExMatch(Item
                      , '(?<Line>\d+)[ \t]+'
                        '(?:(?<LinesBefore>-|\d+)[ \t]+)?'
                        '(?:(?<LinesAfter>-|\d+)[ \t]+)?'
                        '(?:(?<Encoding>[^\r\n \t\\.]+)[ \t]+)?'
                        '(?<Path>.+)'
                      , &Match
                    ) {
                        Params := _GetObjFromMatch(Match)
                    } else {
                        Result.Push({ Value: Item })
                        continue
                    }
                case 'RegExMatchInfo':
                    Params := _GetObjFromMatch(Item)
                default:
                    Params := Item
            }
            ObjSetBase(Params, Default)
            Result.Push(Params)
            _Process(Params)
        }

        return Result

        _GetObjFromMatch(Match) {
            try {
                Line := Match.Line
            } catch {
                _Throw(' line number' )
            }
            try {
                Path := Match.Path
            } catch {
                if !Match.Has('Path') {
                    _Throw('file path')
                }
            }
            return {
                Line: Line
              , LinesBefore: HasProp(Match, 'LinesBefore') ? (Match.LinesBefore == '-' ? 0 : Match.LinesBefore) : unset
              , LinesBefore: HasProp(Match, 'LinesBefore') ? (Match.LinesBefore == '-' ? 0 : Match.LinesBefore) : unset
              , Encoding: HasProp(Match, 'Encoding') ? (Match.Encoding || unset) : unset
              , Path: Path
              , Callback: HasProp(Match, 'Callback') ? (Match.Callback || unset) : unset
              , Match: Match
            }
            _Throw(str) {
                throw ValueError('``StackTraceReader`` failed to parse a ' str ' for an item.', -1)
            }
        }
        _Process(Params) {
            f := FileOpen(Params.Path, 'r', Params.Encoding)
            loop Params.Line - Params.LinesBefore {
                f.ReadLine()
            }
            Params.Value := ''
            loop Params.LinesAfter + Params.LinesBefore + 1 {
                Params.Value .= f.ReadLine() '`n'
            }
            Params.Value := SubStr(Params.Value, 1, -1)
            if HasProp(Params, 'Callback') {
                Cb := Params.Callback
                if Cb && Cb(Params) {
                    if !Params.Value {
                        Result.Pop()
                    }
                    return Result
                }
                if !Params.Value {
                    Result.Pop()
                }
            }
            f.Close()
        }
    }
}


/* test


proc(test) {
    a := 1
    b := 2
    c := a + b
    Result := test(a,b,c)
    if (Result) {
        msgbox(1)
    } else {
        return Error('test: Result is false')
    }
}

test(a,b,c) {
    return 0
}

Result := proc(test)
testcallback(parent, name) {
    str := JSON.stringify(parent, 4) '`n`n' name
    A_Clipboard := str
    msgbox(str)
}
btns := Map('Return', 'Press "Return" to return to the calling procedure.', 'Exit', 'Press "Exit" to exit the script.', 'Continue', 'Press "Continue" to continue the script.')
errdisplay := ErrorDisplay({err: Result, callback: testCallback, btns: btns, extraInfo: 'This is extra info.', pathScript: A_ScriptFullPath, pathEditor: '', linesBefore: 5, linesAfter: 5})
