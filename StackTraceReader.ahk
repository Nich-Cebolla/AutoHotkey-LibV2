

/**
 * This is a description of every property on the objects that are returned by `StackTraceReader.Read`
 * and `StackTraceReader.FromError`.
 * The parameters that were used to construct the object are all included. Specifically,
 * { LinesBefore, LinesAfter, Callback, Encoding }
 * Additionally:
 * @property {Integer} Line - The line number of the item in the file.
 * @property {String} Path - The path to the file.
 * @property {String} Value - The content that was read from the file.
 * @property {RegExMatchInfo} Match - The RegExMatchInfo object that was used to parse the input.
 * This is not preset if the input `Arr` was an array of objects, because nothing would need parsed.
 * When present, the object will have these subcapture groups:
 * - **path, drive, dir, file and ext** - The path to the file, and the components of the path.
 * - If `StackTraceReader.FromError` was used, the subcapture groups `name` and `context` are also
 * present. These are the name of the function and the context of the error.
 * - If `StackTraceReader.Read` was used, the subcapture groups `line`, `linesbefore`,
 * `linesafter`, `encoding` are also present. These are the values that were used to construct the
 * object. The values are the same as the parameters of the function.
 *
 */

class StackTraceReader {

    /**
     * @description - Pass `StackTraceReader.FromError` an error object, and it will read
     * lines from the source file.
     * @example
        try {
            SomeOperation()
        } catch Error as err {
            StackLines := StackTraceReader.FromError(err, 5, 5)
            for StackObj in StackLines {
                str .= StackObj.Value '`n'
            }
            MsgBox(str)
        }
     * @
     * @param {Error} ErrorObj - An instance of `Error` or one of its subclasses.
     * @param {Number} [LinesBefore=0] - The number of lines before the input line number to include
     * in the result string for that item.
     * @param {Number} [LinesAfter=0] - The number of lines after the input line number to include
     * in the result string for that item.
     * @param {Func} [Callback] - A function that will be called on each content item. The only
     * parameter of the function will receive the the `Params` object that gets constructed by
     * the `StackTraceReader` for each item. (See the description in the parameter hint for
     * `StackTraceReader.Read` for moreinformation).
     * @param {String} [Encoding='utf-8'] - The encoding of the files to read.
     * @returns {Array} - An array of objects. See the description in the @returns section of
     * `StackTraceReader.Read` for more information.
     */
    static FromError(ErrorObj, LinesBefore := 0, LinesAfter := 0, Callback?, Encoding := 'utf-8') {
        if not ErrorObj is Error {
            throw TypeError('``ErrorObj`` must be an instance of ``Error`` or one of its subclasses.', -1)
        }
        return this.Read(this.ParseStack(ErrorObj), LinesBefore, LinesAfter, Callback ?? unset, Encoding)
    }


    /**
     * @description - Returns an array of strings containing the requested content.
     * @example
        try {
            SomeOperation()
        } catch Error as err {
            StackLines := StackTraceReader.FromError(err, 5, 5)
            for StackObj in StackLines {
                str .= StackObj.Value '`n'
            }
            MsgBox(str)
        }
     * @
     * @param {Array} Arr - `Arr` can contain any values of any type or value, but only some of them
     * would be processed by `StackTraceReader.Read`.
     * - Unset array indices are skipped and are not represented in the result array.
     * - For `StackTraceReader.Read` to process a value, it must match one of the below sets of
     * characteristics. If an item does not match, processing is skipped and it is added to the result
     * array without modification. All items in the result array are objects, so unprocessed values
     * are added as an object with one property `{ Value }`.
     *   - An object that minimally has two properties `{ Path, Line }`, but also may have a property
     * with the same name as the parameters `LinesBefore`, `LinesAfter`, `Callback`, or `Encoding`
     * which will direct `Read` to use those values instead of the values passed to the
     * function. If the values of the property are RegExMatchInfo objects, the `0` item will be used
     * for the string value.
     *   - A RegExMatchInfo object with minimally the subcapture groups "path" and "line", but also
     * may have subcapture groups with the same name as the parameters `LinesBefore`, `LinesAfter`,
     * `Callback`, or `Encoding` which will direct `Read` to use those values instead of
     * the values passed to the function.
     *   - A string value in the format "<line> <lines before> <lines after> <encoding> <path>",
     *     - <line> and <path> are required, the others are optional
     *     - You cannot specify a <lines after> value without also specifying a <lines before> value,
     * because the function will always interpret the first number after <line> as the value for
     * <lines before>.
     *     - You can use "0" for the <lines before> value to direct the function to use the input
     * parameter `LinesBefore` and use the specified <lines after> from the string.
     *     - To set either of <lines before> or <lines after> to literal zero such that no additional
     * lines in the direction are included, use a single hyphen "-".
     * When <lines before>, <lines after>, and <encoding> are not included in the string, the values
     * that are passed to the function call are used.
     * Examples:
     * @example
     *  Input := [
     *      "25 3 3 ..\src\MyClass.ahk"
     *    , "603 - 1 utf-8 ..\src\MyClass.ahk"
     *    , "311 C:\users\name\documents\autohotkey\lib\myfile.ahk"
     *  ]
     * @
     * @param {Number} [LinesBefore=0] - The number of lines before the input line number to include
     * in the result string for that item.
     * @param {Number} [LinesAfter=0] - The number of lines after the input line number to include
     * in the result string for that item.
     * @param {Func} [Callback] - A function that will be called on each content item. The only
     * parameter of the function will receive the the `Params` object that gets constructed by
     * the `StackTraceReader.Read` for each item. You will mostly be interested in the content that
     * was read from the file, to evaluate whether or not you want to keep it in the result. That
     * is accessible from the property `Value` of each object. Your callback function can make any
     * changes to the value as needed. These additional operations are possible:
     * - To exclude the item from the result array completely, set `Value` to an empty string.
     * - To direct `StackTraceReader.Read` to return the result array immediately, treturn a nonzero
     * value.
     * <br>
     * For a complete description of all of the properties on the object, see the top of the code
     * file.
     * @param {String} [Encoding='utf-8'] - The encoding of the files to read.
     * @returns {Array} - For each item in the input `Arr`, an object is added to this result array.
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
        Result.Capcity := Arr.Length
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
            if _Process(Params) {
                break
            }
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
                if f.AtEOF {
                    break
                }
            }
            Params.Value := ''
            loop Params.LinesAfter + Params.LinesBefore + 1 {
                Params.Value .= f.ReadLine() '`n'
                if f.AtEOF {
                    break
                }
            }
            f.Close()
            Params.Value := SubStr(Params.Value, 1, -1)
            if HasProp(Params, 'Callback') {
                if Cb := Params.Callback {
                    r := Cb(Params)
                    if !Params.Value {
                        Result.Pop()
                    }
                    return r
                }
            }
        }
    }

    static ParseStack(err) {
        Split := StrSplit(err.Stack, '`n', '`r`t`s')
        Result := []
        Result.Capacity := Split.Length
        for Line in Split {
            if RegExMatch(
                Line
              , '(?<path>(?<dir>(?<drive>[a-zA-Z]):\\(?:[^\r\n\\/:*?"<>|]++\\?)+)\\(?<file>[^\r\n\\/:*?"<>|]+?)\.(?<ext>\w+))\b'
                '[ \t]+' '\((?<line>\d*)\)' '[ \t:]+' '\[(?<name>.*?)\][ \t]+(?<context>.+)'
              , &Match
            ) {
                Result.Push(Match)
            }
        } else {
            Result.Push(Line)
        }
        return Result
    }
}

