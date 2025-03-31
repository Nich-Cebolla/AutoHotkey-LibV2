
class ListViewHelper {

    /**
     * @description - Searches a listview column for a matching string.
     * @param {Gui.ListView} LV - The ListView control object.
     * @param {String} Text - The text to search for.
     * @param {Number} [Col=1] - The column to search in. If set to 0, the search will be performed
     * on each column until a match is found.
     * @returns {Number|Object} - If Col is nonzero, the function returns the row number where the
     * text was found. If Col is zero, the function returns an object with two properties: Row
     * and Col. Row is the row number where the text was found, and Col is the column number where
     * the text was found.
     */
    static Find(LV, Text, Col := 1) {
        if Col {
            loop LV.GetCount() {
                if LV.GetText(A_Index, Col) = Text
                    return A_Index
            }
        } else {
            i := 0
            loop LV.GetCount('Col') {
                i++
                loop LV.GetCount() {
                    if LV.GetText(A_Index, i) = Text
                        return  { Row: A_Index, Col: i }
                }
            }
        }
    }


    /**
     * @description - Returns an array of checked rows.
     * @param {Gui.ListView} LV - The ListView control object.
     * @param {String} [RowType='Checked'] - The type of rows to get. The options are:
     * - 'Checked' or 'C': Returns all checked rows.
     * - 'Focused' or 'F': Returns the focused row.
     * @param {Boolean} [Uncheck=true] - If true, rows are unchecked during the process.
     * @param {Function} [Callback=(LV, Row, Result) => Result.Push({ Row: Row, Text: LV.GetText(Row, 1) })] -
     * If provided, the callback is called for each row. The callback will receive three parameters:
     * the ListView control object, the row number, and the result array. The callback does not need
     * to return anything, and if it does, it is ignored. There's no restriction on what the callback
     * must do, but generally it should probably take an action on the row, or fill the Result array
     * with a value. The Result array is returned at the end of the function process. The default
     * callback fills the Result array with an object for each checked row, the object having
     * two properties: Row and Text. The Text is obtained from the first column in the ListView.
     */
    static GetRows(LV, RowType := 'Checked', Uncheck := true
    , Callback := (LV, Row, Result) => Result.Push({ Row: Row, Text: LV.GetText(Row, 1) })) {
        Row := 0, Result := []
        if SubStr(RowType, 1, 1) == 'C' {
            if Uncheck && Callback
                return _ProcessUncheckCallback()
            if Callback
                return _ProcessCallback()
            if Uncheck
                return _ProcessUncheck()
        } else if SubStr(RowType, 1, 1) == 'F' {
            if Callback
                return _ProcessCallback()
        }
        return _Process()

        _Process() {
            Loop {
                Row := LV.GetNext(Row, RowType)
                if !Row
                    return Result.Length ? Result : ''
                Result.Push(Row)
            }
        }
        _ProcessCallback() {
            Loop {
                Row := LV.GetNext(Row, RowType)
                if !Row
                    return Result.Length ? Result : ''
                Callback(LV, Row, Result)
            }
        }
        _ProcessUncheck() {
            Loop {
                Row := LV.GetNext(Row, RowType)
                if !Row
                    return Result.Length ? Result : ''
                LV.Modify(Row, '-check')
                Result.Push(Row)
            }
        }
        _ProcessUncheckCallback() {
            Loop {
                Row := LV.GetNext(Row, RowType)
                if !Row
                    return Result.Length ? Result : ''
                LV.Modify(Row, '-check')
                Callback(LV, Row, Result)
            }
        }
    }


    /**
     * @description - Adds an object or an array of objects to the ListView control. The column names
     * are used as item keys / property names to access values to add to the ListView row. Regarding
     * object properties, if a column name has characters that would be illegal in a property name,
     * they are removed when applying the name to the object property.
     * @param {Gui.ListView} LV - The ListView control object.
     * @param {Object|Array} Obj - The object or array of objects to add to the ListView. The objects
     * should have keys / properties corresponding to the column names. The objects do not need to
     * have every value, or any for that matter; absent keys and properties will default to an empty
     * string.
     * @param {String} [Opt] - A string containing options for the ListView. The options are the same
     * as those used in the `Modify` method.
     * @returns {Number} - The row number where the object was added.
     */
    static AddObj(LV, Obj, Opt?) {
        local Row
        if Obj is Array {
            for O in Obj
                _Process(O)
        } else
            _Process(Obj)
        return Row

        _Process(Obj) {
            Row := LV.Add(Opt ?? unset)
            if Obj is Map {
                for Col in LVH.Cols(LV, 1) {
                    Col := RegExReplace(Col, '[^a-zA-Z0-9_]', '')
                    LV.Modify(Row, 'Col' A_Index, Obj.Has(Col) ? Obj.Get(Col) : '')
                }
            } else {
                for Col in LVH.Cols(LV, 1) {
                    Col := RegExReplace(Col, '[^a-zA-Z0-9_]', '')
                    LV.Modify(Row, 'Col' A_Index, HasProp(Obj, Col) ? Obj.%Col% : '')
                }
            }
        }
    }


    /**
     * @description - Updates an object or an array of objects within the ListView control. The column
     * names are used as item keys / property names to access values to add to the ListView row.
     * Regarding object properties, if a column name has characters that would be illegal in a
     * property name, they are removed when applying the name to the object property.
     * @param {Gui.ListView} LV - The ListView control object.
     * @param {Object|Array} Obj - The object or array of objects to add to the ListView. The objects
     * should have keys / properties corresponding to the column names. The objects do not need to
     * have every value, or any for that matter; absent keys and properties will default to an empty
     * string.
     * @param {Number} [MatchCol=1] - The column to match the object on. For example, if my ListView
     * has a column "Name" that I want to use for this purpose, my objects must all have a property
     * or key "Name" that matches with a row of text in the ListView.
     * @param {Number} [StartCol=1] - The column to start updating from.
     * @param {Number} [EndCol] - The column to stop updating at.
     * @param {String} [Opt] - A string containing options for the ListView. The options are the same
     * as those used in the `Modify` method.
     */
    static UpdateObj(LV, Obj, MatchCol := 1, StartCol := 1, EndCol?, Opt?) {
        if !IsSet(EndCol)
            EndCol := LV.GetCount('Col')
        MaxRow := LV.GetCount()

        if Obj is Array {
            if Obj[1] is Map {
                Name := LV.GetText(0, MatchCol)
                for O in Obj
                    ListObjText .= O[Name] '`n'
                for RowTxt in LVH.Rows(LV, -1, MatchCol)
                    ListRowText .= RowTxt '`n'
                ListObjText := StrSplit(Sort(Trim(ListObjText, '`n')), '`n')
                ListRowText := StrSplit(Sort(Trim(ListRowText, '`n')), '`n')
                Row := i := 0
                for ObjText in ListObjText {
                    ++i
                    while ++Row <= MaxRow {
                        if ListRowText[Row] = ObjText {
                            k := StartCol - 1
                            while ++k <= EndCol {
                                ColName := LV.GetText(0, k)
                                LV.Modify(Row, 'Col' k, Obj[i].Has(ColName) ? Obj[i].Get(ColName) : '')
                            }
                            if IsSet(Opt)
                                LV.Modify(Row, Opt)
                            break
                        }
                    }
                }
                if i !== ListObjText.Length
                    throw Error('Not all objects were found in the ListView.'
                    'The unmatched object is:`r`n' ListObjText[i], -1)
            } else {
                Name := RegExReplace(LV.GetText(0, MatchCol), '[^a-zA-Z0-9_]', '')
                ; So we only have to call RegExReplace once per column.
                Columns := []
                z := StartCol - 1
                while ++z <= EndCol
                    Columns.Push(RegExReplace(LV.GetText(0, z), '[^a-zA-Z0-9_]', ''))
                for O in Obj
                    ListObjText .= O.%Name% '`n'
                for Txt in LVH.Rows(LV, -1, MatchCol)
                    ListRowText .= Txt '`n'
                ListObjText := StrSplit(Sort(Trim(ListObjText, '`n')), '`n')
                ListRowText := StrSplit(Sort(Trim(ListRowText, '`n')), '`n')
                Row := i := 0
                for ObjText in ListObjText {
                    ++i
                    while ++Row <= MaxRow {
                        if ListRowText[Row] = ObjText {
                            k := StartCol - 1
                            while ++k <= EndCol {
                                LV.Modify(Row, 'Col' k, Obj[i].HasOwnProp(Columns[A_Index]) ? Obj[i].%Columns[A_Index]% : '')
                            }
                            if IsSet(Opt)
                                LV.Modify(Row, Opt)
                            break
                        }
                    }
                }
                if i !== ListObjText.Length
                    throw Error('Not all objects were found in the ListView.'
                    'The unmatched object is:`r`n' ListObjText[i], -1)
            }
        } else {
            if Obj is Map {
                for RowText in LVH.Rows(LV, -1, MatchCol) {
                    if Obj[Name] = RowText {
                        while ++k <= EndCol {
                            ColName := LV.GetText(0, k)
                            LV.Modify(A_Index, 'Col' k, Obj.Has(ColName) ? Obj.Get(ColName) : '')
                        }
                        if IsSet(Opt)
                            LV.Modify(A_Index, Opt)
                        break
                    }
                }
            } else {
                for RowText in LVH.Rows(LV, -1, MatchCol) {
                    if Obj.%RegExReplace(Name, '[^a-zA-Z0-9_]', '')% = RowText {
                        while ++k <= EndCol {
                            ColName := RegExReplace(LV.GetText(0, k), '[^a-zA-Z0-9_]', '')
                            LV.Modify(A_Index, 'Col' k, Obj.HasOwnProp(ColName) ? Obj.%ColName% : '')
                        }
                        if IsSet(Opt)
                            LV.Modify(A_Index, Opt)
                        break
                    }
                }
            }
        }
    }


    /**
     * @description - Enumerates the columns in the ListView control.
<pre>
      Name            |     Age     |   Favorite Anime Character
    --------------------------------------------------------
[*] Johnny Appleseed  |      27     |    Holo
[ ] Albert Einstein   |   Relative  |    Kurisu Makise
[*] The Rock          |      53     |    Konata Izumi
</pre>
     * @example

        for ColName in LVH.Cols(LV)
            Str .= ColName ', '
        MsgBox(Trim(Str, ', ')) ; Name, Age, Favorite Anime Character

        for ColName, RowText in LVH.Cols(LV, 2, 2)
            Str2 .= ColName ': ' RowText ', '
        MsgBox(Trim(Str2, ', ')) ; Name: Albert Einstein, Age: Relative, Favorite Anime Character: Kurisu Makise

    * @
    * @param {Gui.ListView} LV - The ListView control object.
    * @param {Number} [Row=1] - If using the enumerator in its two-parameter mode, you can specify
    * a row from which to obtain the text which gets passed to the second parameter.
    * @param {Number} [VarCount=1] - Specify if you are calling the enumerator in its 1-parameter mode
    * ( `for ColName in LVH.Cols(Lv)` )
    * or its 2-parameter mode
    * ( `for ColName, RowText in LVH.Cols(Lv, n, 2)` ).
    * @returns {Enumerator} - An enumerator function that can be used to iterate over the columns.
    */
    static Cols(LV, Row := 1, VarCount := 1) {
        i := 0, MaxCol := LV.GetCount('Col')
        if VarCount == 1 {
            ObjSetBase(Enum1, Enumerator.Prototype)
            return Enum1
        } else if VarCount == 2 {
            ObjSetBase(Enum2, Enumerator.Prototype)
            return Enum2
        }

        Enum1(&ColName) {
            if ++i > MaxCol
                return 0
            ColName := LV.GetText(0, i)
        }

        Enum2(&ColName, &RowText) {
            if ++i > MaxCol
                return 0
            ColName := LV.GetText(0, i)
            RowText := LV.GetText(Row, i)
        }
    }


    /**
     * @description - Enumerates the rows in the ListView control.
<pre>
      Name            |     Age     |   Favorite Anime Character
    --------------------------------------------------------
[*] Johnny Appleseed  |      27     |    Holo
[ ] Albert Einstein   |   Relative  |    Kurisu Makise
[*] The Rock          |      53     |    Konata Izumi
</pre>
     * @example

        for RowText in LVH.Rows(LV, 'C')
            Str .= RowText ', '
        MsgBox(Trim(Str, ', ')) ; Johnny Appleseed, The Rock

        for Row, RowText in LVH.Rows(LV, 'C', Col := 3, Output := 2)
            Str2 .= Row ': ' RowText ', '
        MsgBox(Trim(Str2, ', ')) ; 1: Holo, 3: Konata Izumi

        OutputText := []
        for Row, RowText in LVH.Rows(LV, -1, , OutputText)
            Str3 .= ArrayJoin(OutputText) '; '
        MsgBox(Trim(Str2, ', ')) ; Johnny Appleseed, 27, Holo; Albert Einstein, ...

        ArrayJoin(Arr, Delimiter := ', ') {
            for Item in Arr
                Str .= Item Delimiter
            return Trim(Str, Delimiter)
        }

     * @
     * @param {Gui.ListView} LV - The ListView control object.
     * @param {String} [RowType] - The type of rows to get. The options are:
     * - 'Checked' or 'C': Iterates the checked rows, if any.
     * - 'Focused' or 'F': Iterates the focused rows, if any.
     * - blank or false: Iterates the selected / highlighted rows, if any.
     * - -1: Iterates every row in sequence.
     * @param {Integer|Integer[]} [Col=1] - The column to get the text from. Note this can also be
     * an array of integers when `Output` is an array, see below for details.
     * @param {Integer|Array} [Output=1] - `Output` can modify the enumerator in the following ways:
     * - Output = 1: The enumerator is alled in single-parameter mode, and the variable receives a
     * string value that corresponds to the cell at the intersection of the row and `Col`.
     * - Output = 2: The enumerator is called in two-parameter mode, and the first variable receives
     * the row number, and the second variable receives the string value that corresponds to the cell
     * at the intersection of the row and `Col`.
     * - Output is Array: The enumerator is called in single-parameter mode, and the variable receives
     * the row number. The `Output` array is then filled with text from that row. The columns that get
     * used depend on the value of `Col`. If `Col` is also an array, then only the columns that are
     * represented in that array are included in the `Output` array. The `Col` array should be an
     * array of integers representing column indices. If `Col` is any non-array value, `Output` will
     * contain the text from every column in the row. Each time the enumerator is called on a row,
     * Output is filled again with the text from the next row.
     * @returns {Enumerator} - An enumerator function that can be used to iterate over the rows.
     */
    static Rows(LV, RowType := 0, Col := 1, Output := 1) {
        i := 0
        if RowType = -1 {
            MaxRow := LV.GetCount()
            if Output = 1 {
                ObjSetBase(EnumRow1, Enumerator.Prototype)
                return EnumRow1
            } else if Output = 2 {
                ObjSetBase(EnumRow2, Enumerator.Prototype)
                return EnumRow2
            } else if Output is Array {
                if Col is Array {
                    ObjSetBase(EnumRowV, Enumerator.Prototype)
                    return EnumRowV
                } else {
                    ObjSetBase(EnumRowAll, Enumerator.Prototype)
                    return EnumRowAll
                }
            } else
                throw Error('Invalid otput parameter: ' IsObject(Output)
                ? '`r`n' Output.Stringify() : Output, -1)
        } else {
            if Output = 1 {
                ObjSetBase(EnumSpecial1, Enumerator.Prototype)
                return EnumSpecial1
            } else if Output = 2 {
                ObjSetBase(EnumSpecial2, Enumerator.Prototype)
                return EnumSpecial2
            } else if Output is Array {
                if Col is Array {
                    ObjSetBase(EnumSpecialV, Enumerator.Prototype)
                    return EnumSpecialV
                } else {
                    ObjSetBase(EnumSpecialAll, Enumerator.Prototype)
                    return EnumSpecialAll
                }
            } else
                throw Error('Invalid otput parameter: ' IsObject(Output)
                ? '`r`n' Output.Stringify() : Output, -1)
        }

        EnumRow1(&RowText) {
            if ++i > MaxRow
                return 0
            RowText := LV.GetText(i, Col)
        }

        EnumRow2(&Row, &RowText) {
            if ++i > MaxRow
                return 0
            Row := i
            RowText := LV.GetText(i, Col)
        }

        EnumRowV(&Row) {
            if ++i > MaxRow
                return 0
            Row := i
            Output.Length := Col.Length
            for C in Col
                Output[A_Index] := LV.GetText(i, C)
        }

        EnumRowAll(&Row) {
            if ++i > MaxRow
                return 0
            Row := i
            Output.Length := LV.GetCount('Col')
            loop Output.Length
                Output[A_Index] := LV.GetText(Row, A_Index)
        }

        EnumSpecial1(&Row) {
            if !(i := (LV.GetNext(i, RowType)))
                return 0
            Row := i
        }

        EnumSpecial2(&Row, &RowText) {
            if !(i := (LV.GetNext(i, RowType)))
                return 0
            Row := i
            RowText := LV.GetText(i, Col)
        }

        EnumSpecialV(&Row) {
            if !(i := (LV.GetNext(i, RowType)))
                return 0
            Row := i
            Output.Length := Col.Length
            for C in Col
                Output[A_Index] := LV.GetText(i, C)
        }

        EnumSpecialAll(&Row) {
            if !(i := (LV.GetNext(i, RowType)))
                return 0
            Row := i
            Output.Length := LV.GetCount('Col')
            loop Output.Length
                Output[A_Index] := LV.GetText(Row, A_Index)
        }
    }




    /**
     * @description - Updates an object or an array of objects within the ListView control. The other
     * `UpdateObj` function connects an object to a row by comparing the text content of an object
     * property / item value to the text content of a cell in the ListView. This may not be possible if
     * every value on the row / object has been changed. `UpdateWithCompareFunc` addresses that problem
     * by accepting a function parameter. The function should accept two input parameters:
     * - The text content of a cell in the ListView. The cell is at the intersection of `MatchCol` and
     * the current row being iterated.
     * - The text content of the property / item on the object that corresponds to the column name of
     * `MatchCol`.
     * The function should return a nonzero value if the object is associated with that row.
     * @param {Gui.ListView} LV - The ListView control object.
     * @param {Object|Array} Obj - The object or array of objects to update in the ListView. The objects
     * should have keys / properties corresponding to the column names. The objects do not need to have
     * every value; absent keys and properties will default to an empty string.
     * @param {Function} CompareFunc - The function that compares the text content of a cell in the ListView
     * to the text content of a property / item on the object. The function should return a nonzero value
     * if the object is associated with that row.
     * @param {Number} [MatchCol=1] - The column to match the object on. For example, if my ListView
     * has a column "Name" that I want to use for this purpose, my objects must all have a property
     * or key "Name" that matches with a row of text in the ListView.
     * @param {Number} [StartCol=1] - The column to start updating from.
     * @param {Number} [EndCol] - The column to stop updating at.
     * @param {String} [Opt] - A string containing options for the ListView. The options are the same
     * as those used in the `Modify` method.
     */
    static UpdateWithCompareFunc(LV, Obj, CompareFunc, MatchCol := 1, StartCol := 1, EndCol?, Opt?) {
        if !IsSet(EndCol)
            EndCol := LV.GetCount('Col')
        MaxRow := LV.GetCount()

        if Obj[1] is Map {
            Name := LV.GetText(0, MatchCol)
            for O in Obj
                ListObjText .= O[Name] '`n'
            for RowTxt in LVH.Rows(LV, -1, MatchCol)
                ListRowText .= RowTxt '`n'
            ListObjText := StrSplit(Sort(Trim(ListObjText, '`n')), '`n')
            ListRowText := StrSplit(Sort(Trim(ListRowText, '`n')), '`n')
            Row := i := 0
            for ObjText in ListObjText {
                ++i
                while ++Row <= MaxRow {
                    if CompareFunc(ListRowText[Row], ObjText) {
                        k := StartCol - 1
                        while ++k <= EndCol {
                            ColName := LV.GetText(0, k)
                            LV.Modify(Row, 'Col' k, Obj[i].Has(ColName) ? Obj[i].Get(ColName) : '')
                        }
                        if IsSet(Opt)
                            LV.Modify(Row, Opt)
                        break
                    }
                }
            }
            if i !== ListObjText.Length
                throw Error('Not all objects were found in the ListView.'
                'The unmatched object is:`r`n' ListObjText[i], -1)
        } else {
            Name := RegExReplace(LV.GetText(0, MatchCol), '[^a-zA-Z0-9_]', '')
            ; So we only have to call RegExReplace once per column.
            Columns := []
            z := StartCol - 1
            while ++z <= EndCol
                Columns.Push(RegExReplace(LV.GetText(0, z), '[^a-zA-Z0-9_]', ''))
            for O in Obj
                ListObjText .= O.%Name% '`n'
            for Txt in LVH.Rows(LV, -1, MatchCol)
                ListRowText .= Txt '`n'
            ListObjText := StrSplit(Sort(Trim(ListObjText, '`n')), '`n')
            ListRowText := StrSplit(Sort(Trim(ListRowText, '`n')), '`n')
            Row := i := 0
            for ObjText in ListObjText {
                ++i
                while ++Row <= MaxRow {
                    if CompareFunc(ListRowText[Row], ObjText) {
                        k := StartCol - 1
                        while ++k <= EndCol {
                            LV.Modify(Row, 'Col' k, Obj[i].HasOwnProp(Columns[A_Index]) ? Obj[i].%Columns[A_Index]% : '')
                        }
                        if IsSet(Opt)
                            LV.Modify(Row, Opt)
                        break
                    }
                }
            }
            if i !== ListObjText.Length
                throw Error('Not all objects were found in the ListView.'
                'The unmatched object is:`r`n' ListObjText[i], -1)
        }
    }

    static ToMap(LV, CaseSense := true) {
        Result := Map()
        Result.CaseSense := CaseSense
        for Row in this.Rows(LV) {
            for ColName in this.Cols(LV) {

            }
        }
    }

    static Stringify(LV, StartCol := 1, EndCol?, IncludeCols?) {

        if IsSet(IncludeCols) {

        }
    }
}
