
class ParseXlsx extends Array {
    static __New() {
        this.DeleteProp('__New')
        this.Collection := Map()
        this.Collection.CaseSense := this.Collection.Default := false
        proto := this.Prototype
        proto.encoding := 'utf-8'
        proto.__setOnExit := 0
        proto.callbackOnExit := ''
        ParseXlsx_SetConstants()
    }
    /**
     * @class
     * @description -
     *
     * View the full documentation on Reddit: {@link https://www.reddit.com/r/AutoHotkey/comments/1pvq3rc/parsexlsx_parses_a_workbook_into_a_data_object_no/}
     *
     * ## Example 1
     *
     * Instantiating the class and getting a worksheet
     * @example
     * #include <ParseXlsx>
     *
     * path := "workbook.xlsx"
     * xlsx := ParseXlsx(path)
     *
     * ; `xlsx` is an array of `ParseXlsx.Worksheet` objects
     * ; xlsx.Length is the number of worksheets in the workbook
     * OutputDebug(xlsx.Length "`n")
     * ; Get a worksheet by index
     * ws1 := xlsx[1]
     * ; Get a worksheet by name
     * ws2 := xlsx.getWs("Sheet2")
     * ; Get a worksheet using a pattern
     * ws3 := xlsx.getWs("\w+3", true)
     * @
     *
     * ## Example 2
     *
     * Producing a csv copy of the worksheet
     * @example
     * #include <ParseXlsx>
     *
     * xlsx := ParseXlsx("workbook.xlsx")
     *
     * ; Get an unmodified csv copy of the worksheet
     * ws := xlsx[1]
     * FileAppend(ws.toCsv(), "sheet1.csv", "utf-8")
     *
     * ; using a callback to modify the cell values. You can copy this callback to your code
     * ; and it will work.
     * callback(cell) {
     *     ; All together this expression does:
     *     ; Standardizes end of line to line feed
     *     ; Fixes floating point imprecision using the built-in ParseXlsx_FixFloatingPoint
     *     ; Decodes "&amp;", "&gt;", and "&lt;"
     *     return RegExReplace(ParseXlsx_FixFloatingPoint(cell.decoded), '\R', '`n')
     * }
     * ws3 := xlsx[3]
     * ; call "toCsv2" instead of "toCsv"
     * FileAppend(ws3.toCsv2(callback), "sheet3.csv", "utf-8")
     * @
     *
     * ## Example 3
     *
     * Access individual cells
     * @example
     * #include <ParseXlsx>
     *
     * xlsx := ParseXlsx("workbook.xlsx")
     * ws := xlsx[1]
     * ca1 := ws.cell(1, 1)
     * cb3 := ws.cell(3, "B")
     * caz19 := ws.cell(19, "AZ")
     * @
     *
     * ## Example 4
     *
     * Using a cell object
     * @example
     *
     * #include <ParseXlsx>
     *
     * xlsx := ParseXlsx("workbook.xlsx")
     * ws := xlsx[1]
     * ca1 := ws.cell(1, 1)
     * ; value
     * OutputDebug(ca1.value "`n")
     * ; decoded value
     * OutputDebug(ca1.decoded "`n")
     * ; xml attributes. See the documentation for ParseXlsx.Cell for details
     * OutputDebug(ca1.r "`n")
     * OutputDebug(ca1.s "`n")
     * ; xml child elements See the documentation for ParseXlsx.Cell for details
     * ; The cell's formula, if applicable.
     * OutputDebug(ca1.f "`n")
     * ; The <v> element might be the cell's value or it might be an integer pointing to a shared string
     * OutputDebug(ca1.v "`n")
     * @
     *
     * ## Example 5
     *
     * Get a range of cells
     * @example
     * #include <ParseXlsx>
     *
     * xlsx := ParseXlsx("workbook.xlsx")
     * ws := xlsx[1]
     * ; Get the range R5C3:R9C9
     * r1 := 5
     * c1 := 3
     * r2 := 9
     * c2 := 9
     * rng := ws.getRange(r1, r2, c1, c2)
     * for cell in rng {
     *     ; skip blank cells
     *     if !IsSet(cell) {
     *         continue
     *     }
     *     ; do work...
     * }
     * @
     *
     * ## Example 6
     *
     * Use {@link https://github.com/Nich-Cebolla/AutoHotkey-DateObj DateObj} to work with dates.
     * See section "Dates" for more information.
     * @example
     * #include <DateObj>
     * #include <ParseXlsx>
     *
     * xlsx := ParseXlsx("workbook.xlsx")
     *
     * ; Get the base date as a DateObj object.
     * if xlsx.date1904 {
     *     baseDate := DateObj.FromTimestamp("19040101000000")
     * } else {
     *     baseDate := DateObj.FromTimestamp("18991230000000")
     * }
     *
     * ; Assume cell A1 of the first worksheet has a date value of 46016.2291666667.
     * cell := xlsx[1].cell(1, 1)
     * OutputDebug(cell.value "`n") ; 46016.2291666667
     * ; Call "AddToNew".
     * a1Date := baseDate.AddToNew(cell.value, "D")
     * ; `a1Date` is now a usable date object for the date in the cell.
     * OutputDebug(a1Date.Get("yyyy-MM-dd HH:mm:ss") "`n") ; 2025-12-25 05:30:00
     * @
     *
     * ## Example 7
     *
     * Work with dates without external scripts. See section "Dates" for more information.
     * @example
     * #include <ParseXlsx>
     *
     * xlsx := ParseXlsx("workbook.xlsx")
     *
     * ; Get the base date as a DateObj object.
     * if xlsx.date1904 {
     *     ts := "19040101000000"
     * } else {
     *     ts := "18991230000000"
     * }
     *
     * ; Assume cell A1 of the first worksheet has a date value of 46016.2291666667.
     * cell := xlsx[1].cell(1, 1)
     * OutputDebug(cell.value "`n") ; 46016.2291666667
     * ; Call DateAdd
     * tsA1 := DateAdd(ts, cell.value, "D")
     * ; Work with the timestamp
     * OutputDebug(FormatTime(tsA1, "yyyy-MM-dd HH:mm:ss") "`n") ; 2025-12-25 05:30:00
     * @
     *
     * # Documentation
     *
     * Converts an xlsx document into a nested data structure. The conversion
     * process decompresses the xlsx document then parses the xml documents. This approach does
     * not require Excel to be installed on the machine. This approach uses the Shell.Application
     * COM object to decompress the xlsx document.
     *
     * I designed the parsing logic by following ecma reference for
     * {@link https://ecma-international.org/publications-and-standards/standards/ecma-376/ Office Open XML}.
     * Specifically, Part 1 "Fundamentals And Markup Language Reference", section 18
     * "SpreadsheetML Reference Material" (pg. 1523-2435).
     *
     * {@link ParseXlsx} provides functionality limited to extracting and interpreting values from
     * the worksheets.
     *
     * ## ParseXlsx
     *
     * The {@link ParseXlsx} objects have the following properties:
     *
     * - {@link ParseXlsx#baseDate} - Returns the base date as yyyyMMddHHmmss timestamp.
     * - {@link ParseXlsx#date1904} - Returns 1 if the workbook uses the 1904 date system. Returns
     *   0 otherwise. See section "Dates" below for more information.
     * - {@link ParseXlsx#workbookPr} - Returns a `Map` object, each key : value pair representing the name
     *   and value of a workbook property defined in xl\\workbook.xml.
     * - {@link ParseXlsx#sharedStrings} - A {@link ParseXlsx.SharedStringCollection} object.
     *   See section "ParseXlsx.SharedStringCollection and ParseXlsx.SharedString" below for more
     *   information.
     *
     * The {@link ParseXlsx} objects have the following methods:
     *
     * - {@link ParseXlsx.Prototype.call} - Invokes the parsing process.
     * - {@link ParseXlsx.Prototype.decompress} - Invokes the decompression process.
     * - {@link ParseXlsx.Prototype.getWs} - Accepts an index / name / pattern and returns the matching worksheet.
     *
     * ## ParseXlsx.Cell
     *
     * The {@link ParseXlsx.Cell} objects have the following properties:
     *
     * - {@link ParseXlsx.Cell#col} - The column index represented as letters, e.g. "A", "B", "AZ".
     * - {@link ParseXlsx.Cell#columnIndex} - The 1-based column index as integer.
     * - {@link ParseXlsx.Cell#date} - If the cell's value is a number, returns the return value from
     *   adding the value to the workbook's base date.
     * - {@link ParseXlsx.Cell#decoded} - Returns the cell's value, decoding "&amp;amp;", "&amp;gt;", and "&amp;lt;"
     *   to "&", ">", and "<", respectively.
     * - {@link ParseXlsx.Cell#r} - The full cell reference, e.g. "A1", "B6", "AZ12".
     * - {@link ParseXlsx.Cell#rowIndex} - The 1-based row index as integer.
     * - {@link ParseXlsx.Cell#text} - Returns the cell's xml text, e.g. "<c r=`"A1`" t=`"s`"><v>33</v></c>".
     * - {@link ParseXlsx.Cell#value} - Returns the cell's value. For cells that have a formula, the
     *   value is the last calculated value for that cell. For cells that do not have a formula, the
     *   value is simply the value of the cell. Number formatting is not applied to the value. For
     *   example, dates are represented as serial date-time values. See section "Dates" below for more
     *   information.
     * - {@link ParseXlsx.Cell#wsIndex} - The 1-based index of the worksheet of which the cell is part.
     *   This is defined on the base object; see the body of {@link ParseXlsx.Worksheet.Prototype.__New}.
     * - {@link ParseXlsx.Cell#ws} - Returns the {@link ParseXlsx.Worksheet} object associated with the cell.
     * - {@link ParseXlsx.Cell#xlsx} - Returns the {@link ParseXlsx} object associated with the cell.
     *
     * The {@link ParseXlsx.Cell} objects have the following methods:
     *
     * - {@link ParseXlsx.Cell.Prototype.row} - Returns the {@link ParseXlsx.Row} object associated with the cell.
     * - {@link ParseXlsx.Cell.Prototype.getAttributes} - Calls {@link ParseXlsx_ParseAttributes} for the object.
     * - {@link ParseXlsx.Cell.Prototype.getElements} - Calls {@link ParseXlsx_ParseElements} for the object.
     * - {@link ParseXlsx.Cell.Prototype.__Get} - This meta-function is defined to give you access to
     *   a cell's attributes and child elements (if any). See section "Beyond cell values" below
     *   for more information.
     *
     * ### Dates
     *
     * Dates are typically represented as serial date-time values. When Excel renders the cell's
     * contents, the cell's number format is applied to the value to produce the text that is displayed
     * in the cell. For details about how Excel works with dates, see section 18.17.4 "Dates and Times"
     * in {@link https://ecma-international.org/publications-and-standards/standards/ecma-376/ Office Open XML}.
     *
     * I included some code to help working with date values. If you refer to the section 18.7.4, you
     * will learn that date values are added or subtracted from the workbook's base date. The
     * base date depends on the date system used by the workbook - either the 1900 date system, or
     * the 1904 date system. If a workbook uses the 1904 date system, the property
     * {@link ParseXlsx#date1904} will return 1. If a workbook uses the 1900 date system, the property
     * {@link ParseXlsx#date1904} will return 0.
     *
     * Working with dates will generally require your code to know beforehand which cells contain
     * date values, or you can parse the xl\\styles.xml document to identify cells which have a date
     * number format, but this library does not do that. See examples 6 and 7 for examples working
     * with dates.
     *
     * ### Beyond cell values
     *
     * There are some additional pieces of information made available to you by this library, but to
     * understand them you will need to review the relevant portions of the ecma reference for
     * {@link https://ecma-international.org/publications-and-standards/standards/ecma-376/ Office Open XML}.
     * Specifically, Part 1 "Fundamentals And Markup Language Reference", section 18.3.1.4 "c (Cell)"
     * and section 18.18 "Simple Types". Skip reading this section if your main objective is to parse
     * cell values.
     *
     * In addition to the above properties, the
     * {@link https://www.autohotkey.com/docs/v2/Objects.htm#Meta_Functions __Get meta-function}
     * is defined to parse the cell element's xml text to identify any attributes and child elements.
     * If you are working with a cell object and need to check if a style index is defined, you can
     * simply access the "s" property and, if there is an "s" attribute for that cell, the value
     * of the attribute is returned. It works the same for elements. If you need to check if the cell
     * has a nested "t" element, just access the "t" property. If the attribute / child element is
     * undefined, the return value is an empty string.
     *
     * The following is a list of possible attributes for the cell object:
     *
     * |  Attributes                 |  Description                                                                                                                                                                                                                                                                                                                         |
     * |  ---------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------  |
     * |  cm (Cell Metadata Index)   |  The zero-based index of the cell metadata record associated with this cell. Metadata information is found in the Metadata Part. Cell metadata is extra information stored at the cell level, and is attached to the cell (travels through moves, copy / paste, clear, etc). Cell metadata is not accessible via formula reference.  |
     * |  ph (Show Phonetic)         |  A Boolean value indicating if the spreadsheet application should show phonetic information. Phonetic information is displayed in the same cell across the top of the cell and serves as a 'hint' which indicates how the text should be pronounced. This should only be used for East Asian languages.                              |
     * |  r (Reference)              |  An A1 style reference to the location of this cell.                                                                                                                                                                                                                                                                                 |
     * |  s (Style Index)            |  The index of this cell's style. Style records are stored in the Styles Part.                                                                                                                                                                                                                                                        |
     * |  t (Cell Data Type)         |  An enumeration representing the cell's data type.                                                                                                                                                                                                                                                                                   |
     * |  vm (Value Metadata Index)  |  The zero-based index of the value metadata record associated with this cell's value. Metadata records are stored in the Metadata Part. Value metadata is extra information stored at the cell level, but associated with the value rather than the cell itself. Value metadata is accessible via formula reference.                 |
     *
     * The cell data type is defined by attribute "t", e.g. `t="<type>"`. Note that not every cell
     * has a "t" attribute. For cells that do not have a "t" attribue, you can parse the number
     * format for the cell, but this library does not include that functionality. The relevant sections
     * in the reference material are 18.8.30 "numFmt (Number Format)" and 18.8.31 "numFmts (Number Formats)".
     *
     * The following is a list of possible data types:
     *
     * |  Enumeration  |  Value          |  Description                                   |
     * |  -------------|-----------------|----------------------------------------------  |
     * |  b            |  Boolean        |  Cell containing a boolean.                    |
     * |  d            |  Date           |  Cell contains a date in the ISO 8601 format.  |
     * |  e            |  Error          |  Cell containing an error.                     |
     * |  inlineStr    |  Inline String  |  Cell containing an (inline) rich string.      |
     * |  n            |  Number         |  Cell containing a number.                     |
     * |  s            |  Shared String  |  Cell containing a shared string.              |
     * |  str          |  String         |  Cell containing a formula string.             |
     *
     * The cell may have the zero or more of the following child elements:
     *
     * |  Name    |  Description                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
     * |  --------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------  |
     * |  extLst  |  This element provides a convention for extending spreadsheetML in predefined locations. The locations shall be denoted with the extLst element, and are called extension lists.                                                                                                                                                                                                                                                                              |
     * |  f       |  This element contains the formula for the cell.                                                                                                                                                                                                                                                                                                                                                                                                              |
     * |  is      |  This element allows for strings to be expressed directly in the cell definition instead of implementing the shared string table.                                                                                                                                                                                                                                                                                                                             |
     * |  v       |  This element expresses the value contained in a cell. If the cell contains a string, then this value is an index into the shared string table, pointing to the actual string value. Otherwise, the value of the cell is expressed directly in this element. Cells containing formulas express the last calculated result of the formula in this element. The "value" property automatically retrieves the value from the shared string table if applicable.  |
     *
     * ## ParseXlsx.Row
     *
     * The {@link ParseXlsx.Row} objects have the following properties:
     *
     * - {@link ParseXlsx.Row#ws} - Returns the {@link ParseXlsx.Worksheet} object associated with the cell.
     * - {@link ParseXlsx.Row#xlsx} - Returns the {@link ParseXlsx} object associated with the cell.
     * - {@link ParseXlsx.Row#__Item} - Access a cell object using `row[columnIndex]` notation.
     *
     * The {@link ParseXlsx.Row} objects have the following methods:
     *
     * - {@link ParseXlsx.Row.Prototype.cell} - Returns a {@link ParseXlsx.Cell} object.
     * - {@link ParseXlsx.Row.Prototype.getAttributes} - Calls {@link ParseXlsx_ParseAttributes} for the object.
     * - {@link ParseXlsx.Row.Prototype.__Get} - Instead of calling {@link ParseXlsx.Row.Prototype.getAttributes},
     *   you can check for the existence of an attribute by accessing the attribute as a property.
     *   For example, to retrieve the "spans" xml attribute, access `rowObj.spans` (where "rowObj"
     *   is an instance of {@link ParseXlsx.Row}). If the attribute does not exist in the xml text,
     *   an empty string is returned.
     *
     * ## ParseXlsx.Rows
     *
     * The {@link ParseXlsx.Row} objects have the following methods:
     *
     * - {@link ParseXlsx.Row.Prototype.row} - Returns a {@link ParseXlsx.Row} object.
     *
     * ## ParseXlsx.SharedStringCollection and ParseXlsx.SharedString
     *
     * This library parses the xl\\sharedStrings.xml document, which contains a number of strings
     * that are referenced by more than one object. For each item in xl\\sharedStrings.xml, a
     * {@link ParseXlsx.SharedString} object is created.
     *
     * The {@link ParseXlsx.SharedString} objects have the following properties:
     *
     * - {@link ParseXlsx.SharedString#attributes} - Returns the xml text for any attributes associated
     *   with the string. This property is defined within the body of
     *   {@link ParseXlsx.SharedStringCollection.Prototype.__New}.
     * - {@link ParseXlsx.SharedString#decoded} - Returns the string value, replacing "&amp;amp;", "&amp;gt;",
     *   and "&amp;lt;" with "&", ">", "<", respectively.
     * - {@link ParseXlsx.SharedString#value} - Returns the string value. This property is defined
     *   within the body of {@link ParseXlsx.SharedStringCollection.Prototype.__New}.
     *
     * ## ParseXlsx.Worksheet
     *
     * The {@link ParseXlsx.Worksheet} objects have the following properties:
     *
     * - {@link ParseXlsx.Worksheet#name} - Returns the worksheet's name.
     * - {@link ParseXlsx.Worksheet#wsIndex} - Returns the worksheet's 1-based index.
     * - {@link ParseXlsx.Worksheet#rows} - Returns an array of {@link ParseXlsx.Row} objects.
     * - {@link ParseXlsx.Worksheet#columnUbound} - Returns the index of the greatest column used in
     *   the worksheet.
     * - {@link ParseXlsx.Worksheet#rowUbound} - Returns the index of the greatest row used in the
     *   worksheet.
     * - {@link ParseXlsx.Worksheet#xlsx} - Returns the {@link ParseXlsx} object associated with the
     *   object.
     *
     * The {@link ParseXlsx.Worksheet} objects have the following methods:
     *
     * - {@link ParseXlsx.Worksheet.Prototype.cell} - Returns a {@link ParseXlsx.Cell} object.
     * - {@link ParseXlsx.Worksheet.Prototype.getColumn} - Returns an array of {@link ParseXlsx.Cell}
     *   objects, each occupying the indicated column.
     * - {@link ParseXlsx.Worksheet.Prototype.getRange} - Returns an array of {@link ParseXlsx.Cell}
     *   objects, each within the indicated range.
     * - {@link ParseXlsx.Worksheet.Prototype.getRow} - Returns an array of {@link ParseXlsx.Cell}
     *   objects, each occupying the indicated row.
     * - {@link ParseXlsx.Worksheet.Prototype.row} - Returns a {@link ParseXlsx.Row} object.
     * - {@link ParseXlsx.Worksheet.Prototype.toCsv} - Converts a range of cell values into a csv string.
     * - {@link ParseXlsx.Worksheet.Prototype.toCsv2} - Converts a range of cell values into a csv string,
     *   passing each value to a callback function to allow your code to modify the value before adding
     *   it to the csv string.
     *
     * @param {String} path - `path` can be one of the following:
     * - The path to the xlsx document. {@link ParseXlsx} will make a copy and decompress the copy.
     * - The path to a directory containing the contents from a previously decompressed document.
     *
     * The following information is only relevant when `path` is a path to a file.
     *
     * {@link ParseXlsx} decompresses the document at `path` to `dir`. If parameter `setOnExit` is
     * 0, the decompressed documents will remain after the script exits. If you make changes to the
     * workbook then try running your script again, you will likely not see the changes because the
     * decompression function will not overwrite the existing documents. This can be troublesome,
     * particularly during testing and development when you might want to make changes to the workbook
     * then see how the script responds.
     *
     * By default, `setOnExit` is 1, which will cause the script to clean up the output directory,
     * avoiding this issue. See the details for parameters `dir` and `setOnExit` for more information.
     *
     * @param {String} [dir] - The directory to which the xlsx document will be decompressed. Leave
     * `dir` unset to direct {@link ParseXlsx} to create a temp directory.
     *
     * `dir` does not need to exist. An error is thrown if `dir` already
     * contains at least one of the following files: .\[Content_Types].xml, .\docProps\app.xml,
     * .\xl\sharedStrings.xml, .\xl\styles.xml, .\xl\workbook.xml, .\xl\worksheets\sheet1.xml.
     *
     * `dir` is ignored when `path` is a path to a directory.
     *
     * If `dir` is unset, the default `A_Temp "\ParseXlsx-output"` is used. If `A_Temp "\ParseXlsx-output"`
     * already exists, a hyphen and integer is added to the end of the name. The integer is incremented
     * by 1 until it produces a path that does not yet exist.
     *
     * @param {String} [encoding = "utf-8"] - The file encoding of the xml documents. Excel uses
     * utf-8 by default.
     *
     * @param {Boolean} [deferProcess = false] - If true, the core process is not invoked; your code
     * must call {@link ParseXlsx.Prototype.Decompress} if applicable, and/or call {@link ParseXlsx.Prototype.Call}.
     *
     * @param {Integer} [setOnExit = 1] - An integer directing {@link ParseXlsx} to set, or not set,
     * {@link ParseXlsx_OnExit} as an {@link https://www.autohotkey.com/docs/v2/lib/OnExit.htm OnExit}
     * callback.
     *
     * One of the following values:
     * - 0 : Does not set the callback.
     * - 1 : If parameter `path` is a path to a file, sets the callback. Else, does not set the callback.
     *       The directory is deleted.
     * - 2 : Sets the callback. The directory is deleted.
     * - 3 : If parameter `path` is a path to a file, sets the callback. Else, does not set the callback.
     *       The directory is recycled.
     * - 4 : Sets the callback. The directory is recycled.
     *
     * If `path` is a path to a file, and if `deferProcess` is true, and if your code never
     * calls {@link ParseXlsx.Prototype.decompress}, `setOnExit` is ignored.
     *
     * @throws {Error} - "The ParseXlsx output directory is already occupied."
     */
    __New(path, dir?, encoding := 'utf-8', deferProcess := false, setOnExit := 1) {
        ; Assign a unique id and cache a reference to this object within the
        ; ParseXlsx.Collection map. This allows related objects to obtain a reference
        ; to one another without creating a reference cycle.
        loop 100 {
            n := Random(1, 4294967295)
            if !ParseXlsx.Collection.Has(n) {
                this.id := n
                ParseXlsx.Collection.Set(n, this)
                break
            }
        }
        ObjRelease(ObjPtr(this))
        if encoding != this.encoding {
            this.encoding := encoding
        }
        this.__setOnExit := setOnExit
        if DirExist(path) {
            this.dir := path
            this.path := ''
            if setOnExit = 2 {
                this.callbackOnExit := ParseXlsx_OnExit_Delete.Bind(path, encoding)
                OnExit(this.callbackOnExit, 1)
            } else if setOnExit = 4 {
                this.callbackOnExit := ParseXlsx_OnExit_Recycle.Bind(path, encoding)
                OnExit(this.callbackOnExit, 1)
            }
            if !deferProcess {
                this()
            }
        } else {
            if IsSet(dir) {
                this.dir := dir
            } else {
                dir := A_Temp '\ParseXlsx-output'
                if FileExist(dir) {
                    i := 2
                    while FileExist(A_Temp '\ParseXlsx-output-' i) {
                        ++i
                    }
                    this.dir := A_Temp '\ParseXlsx-output-' i
                } else {
                    this.dir := dir
                }
            }
            this.path := path
            if !deferProcess {
                this.decompress()
                this()
            }
        }
    }
    /**
     * @description - Invokes the parsing process.
     */
    call() {
        ; Instead of defining a property "id" on every instance, we create a
        ; prototype for each class and define "id" on the prototype. This is just to reduce
        ; memory usage slightly.
        (this.proto_cell := {}).Base := ParseXlsx.Cell.Prototype
        (this.proto_row := []).Base := ParseXlsx.Row.Prototype
        (this.proto_rows := []).Base := ParseXlsx.Rows.Prototype
        (proto_ws := {}).Base := ParseXlsx.Worksheet.Prototype
        proto_ws.id := this.id
        for name in [ 'cell', 'row', 'rows' ] {
            this.proto_%name%.id := this.id
        }
        ; Parse xl/sharedStrings.xml, which serializes strings that are referenced by more than one cell.
        this.sharedStrings := ParseXlsx.SharedStringCollection(this)
        content := FileRead(this.dir '\docProps\app.xml', this.encoding)
        if !RegExMatch(content, '<TitlesOfParts><vt:vector size="(\d+)"', &match) {
            throw Error('The pattern failed to match, which might indicate a logical error in the'
            ' ``ParseXlsx`` library, or a syntax error in the xml.')
        }
        this.Capacity := match[1]
        content := SubStr(content, match.Pos + match.Len)
        ; Get the worksheet names, create a worksheet object for each.
        pos := 1
        while RegExMatch(content, '(?<=<vt:lpstr>).+?(?=</vt:lpstr>)', &match, pos) {
            pos := match.Pos + match.Len
            (ws := {}).Base := proto_ws
            ws.__New(this, match[0], A_Index)
            this.Push(ws)
        }
        if this.Length != this.Capacity {
            throw Error('Unexpected count, indicating a logical error in the ``ParseXlsx`` library.')
        }
        if !RegExMatch(FileRead(this.dir '\xl\workbook.xml'), 's)(?<=<workbookPr\s).*?(?=/>)', &match) {
            throw Error('Failed to match with the "workbookPr" element. This probably indicates an'
            ' error in the parsing logic.')
        }
        workbookPr := this.workbookPr := Map()
        workbookPr.Default := ''
        s := match[0]
        pos := 1
        while RegExMatch(s, ParseXlsx_PatternAttributes, &match, pos) {
            pos := match.Pos + match.Len
            workbookPr.Set(match[1], match[2])
        }
        this.DeleteProp('proto_cell')
        this.DeleteProp('proto_row')
        this.DeleteProp('proto_rows')
    }
    /**
     * @description - Calls {@link ParseXlsx_Decompress} with the `path` and `dir` values
     * passed to {@link ParseXlsx.Prototype.__New}. Also sets the
     * {@link https://www.autohotkey.com/docs/v2/lib/OnExit.htm OnExit} callback depending on the
     * value of {@link ParseXlsx#setOnExit}.
     */
    decompress() {
        ParseXlsx_Decompress(this.path, this.dir)
        if this.__setOnExit = 2 || (this.__setOnExit = 1 && !DirExist(this.path)) {
            this.callbackOnExit := ParseXlsx_OnExit_Delete.Bind(this.dir, this.encoding)
            OnExit(this.callbackOnExit, 1)
        } else if this.__setOnExit = 4 || (this.__setOnExit = 3 && !DirExist(this.path)) {
            this.callbackOnExit := ParseXlsx_OnExit_Recycle.Bind(this.dir, this.encoding)
            OnExit(this.callbackOnExit, 1)
        }
    }
    /**
     * @description - Retuns the {@link ParseXlsx.Worksheet} object for `value`.
     * @param {Integer|String} value - If `value` is an integer, it is intepreted as the 1-based
     * worksheet index and that worksheet is returned. If `value` is a string, it is interpreted
     * as the worksheet's name. The {@link ParseXlsx.Worksheet} objects are iterated until finding
     * a matching name. If no match is found, this returns an empty string.
     * @param {Boolean} [regex = false] - When true, and if `value` is a string, searches for
     * a match using `RegExMatch`. When false, and if `value` is a string, searches for a match
     * with `value = ws.name`. When `value` is an integer, `regex` is ignored.
     * @returns {ParseXlsx.Worksheet|String} - If found, the {@link ParseXlsx.Worksheet} object.
     * If not found, an empty string.
     */
    getWs(value, regex := false) {
        if value is Number {
            return this[value]
        } else if value {
            if regex {
                for ws in this {
                    if RegExMatch(ws.name, value) {
                        return ws
                    }
                }
            } else {
                for ws in this {
                    if value = ws.name {
                        return ws
                    }
                }
            }
        }
    }
    __Delete() {
        ObjPtrAddRef(this)
        if ParseXlsx.Collection.Has(this.id) {
            ParseXlsx.Collection.Delete(this.id)
        }
        if this.callbackOnExit {
            OnExit(this.callbackOnExit, 0)
            this.callbackOnExit.Call()
            this.DeleteProp('callbackOnExit')
        }
    }

    /**
     * @description - When {@link ParseXlsx#date1904} is true, returns "19040101000000". Else,
     * returns "18991230000000". These are the yyyyMMddHHmmss timestamp of the relevant base date.
     * @instance
     * @memberof ParseXlsx
     * @type {String}
     */
    baseDate => this.date1904 ? '19040101000000' : '18991230000000'
    /**
     * @description - When true, the workbook uses the 1904 date system. When false, the workbook
     * uses the 1900 date system.
     *
     * In the 1900 date system, the lower limit is January 1st, 0001 00:00:00, which has a serial
     * datetime of -693593. The upper-limit is December 31st, 9999, 23:59:59.999, which has a serial
     * date-time of 2,958,465.9999884. The base date for this system is 00:00:00 on December 30th,
     * 1899, which has a serial date-time of 0.
     *
     * In the 1904 date system, the lower limit is January 1st, 0001, 00:00:00, which has a serial
     * date-time of -695055. The upper limit is December 31st, 9999, 23:59:59.999, which has a
     * serial date-time of 2,957,003.9999884. The base date for this system is 00:00:00 on January
     * 1st, 1904, which has a serial date-time of 0.
     * @instance
     * @memberof ParseXlsx
     * @type {Boolean}
     */
    date1904 => this.workbookPr.Get('date1904')

    class Cell {
        static __New() {
            this.DeleteProp('__New')
            proto := this.Prototype
            proto.id :=
            proto.wsIndex :=
            ''
        }
        __New() {
            this.text := '<c ' A_LoopField '</c>'
            if !RegExMatch(this.text, '(?<=r=")([A-Z]+)(\d+)(?=")', &match) {
                throw Error('The pattern failed to match, which might indicate a logical error in the'
                ' ``ParseXlsx`` library, or a syntax error in the xml.')
            }
            this.r := match[0]
            this.rowIndex := match[2]
            this.columnIndex := ParseXlsx_ColToIndex(match[1])
            this.col := match[1]
        }
        /**
         * @description - Calls {@link ParseXlsx_ParseAttributes} passing the object to the function.
         */
        getAttributes() {
            ParseXlsx_ParseAttributes(this)
        }
        /**
         * @description - Calls {@link ParseXlsx_ParseElements} passing the object to the function.
         */
        getElements() {
            ParseXlsx_ParseElements(this)
        }
        /**
         * @description - Returns the {@link ParseXlsx.Row} object associated with the cell.
         */
        row() {
            return this.ws.row(this.rowIndex)
        }
        __Get(name, *) {
            s := this.Text
            if InStr(s, name)
            && RegExMatch(s, 's)<' name '[^>]*>(.+?)</' name '>', &match)
            || RegExMatch(SubStr(s, 1, InStr(s, '>') - 1), name '="(.*?(?<!")(?:"")*+)"', &match) {
                this.DefineProp(name, { Value: match[1] })
                return this.%name%
            }
        }
        /**
         * @description - Calls {@link https://www.autohotkey.com/docs/v2/lib/DateAdd.htm DateAdd}
         * to get the date value.
         * @returns {String}
         */
        date => IsNumber(this.value) ? DateAdd(this.xlsx.baseDate, this.value, 'D') : ''
        /**
         * @description - Returns the cell's value, decoding "&amp;", "&gt;", and "&lt;" to "&", ">",
         * and "<", respectively.
         * @memberof ParseXlsx.Cell
         * @instance
         */
        decoded {
            Get {
                if this.t = 's' {
                    value := this.xlsx.sharedStrings[this.v + 1].value
                } else {
                    value := this.v
                }
                if InStr(value, '&') {
                    return StrReplace(StrReplace(StrReplace(value, '&gt;', '>'), '&lt;', '<'), '&amp;','&')
                } else {
                    return value
                }
            }
        }
        /**
         * @description - Returns the cell's value. For cells that have a formula, the value is the last
         * calculated value for that cell. For cells that do not have a formula, the value is simply
         * the value of the cell. Number formatting is not applied to the value. For example, dates
         * are represented as serial date-time values.
         * @memberof ParseXlsx.Cell
         * @instance
         */
        value {
            Get {
                if this.t = 's' {
                    return this.xlsx.sharedStrings[this.v + 1].value
                } else {
                    return this.v
                }
            }
        }
        ws => this.xlsx.GetWs(this.wsIndex)
        xlsx => ParseXlsx.Collection.Get(this.id)
    }
    class Row extends Array {
        static __New() {
            this.DeleteProp('__New')
            proto := this.Prototype
            proto.DefineProp('Get2', { Call: Array.Prototype.GetOwnPropDesc('__Item').Get })
            proto.DefineProp('Set2', { Call: Array.Prototype.GetOwnPropDesc('__Item').Set })
            proto.id :=
            proto.wsIndex :=
            ''
        }
        __New() {
            this.text := '<row ' A_LoopField
            if !RegExMatch(A_LoopField, '(?<=r=")[^"]+', &match) {
                throw Error('Failed to match with pattern, likely indicating an error in the'
                ' parsing logic.')
            }
            this.rowIndex := match[0]
        }
        /**
         * @description - Returns the {@link ParseXlsx.Cell} object at the indicated column.
         * @param {Integer|String} col - Either the 1-based column index of the column, or the
         * letter(s) of the column.
         */
        cell(col) {
            if !IsNumber(col) {
                col := ParseXlsx_ColToIndex(col)
            }
            if col > this.Length {
                return ''
            } else {
                return this.Get2(col)
            }
        }
        /**
         * @description - Parses the row's xml text. For each attribute of the row element, a
         * property is defined with the same name and value as the attribute.
         */
        getAttributes() => ParseXlsx_ParseAttributes(this)
        __Get(name, *) {
            s := this.Text
            if InStr(s, name)
            && RegExMatch(SubStr(s, 1, InStr(s, '>') - 1), name '="(.*?(?<!")(?:"")*+)"', &match) {
                this.DefineProp(name, { Value: match[1] })
                return this.%name%
            }
        }
        /**
         * @description - Returns the {@link ParseXlsx.Cell} object at the indicated column.
         * @param {Integer|String} col - Either the 1-based column index of the column, or the
         * letter(s) of the column.
         * @memberof ParseXlsx.Row
         * @instance
         */
        __Item[col] => this.cell(col)
        ws => this.xlsx.GetWs(this.wsIndex)
        xlsx => ParseXlsx.Collection.Get(this.id)
    }
    class Rows extends Array {
        /**
         * @description - Returns the {@link ParseXlsx.Row} object for the index.
         * @param {Integer} rowIndex - The row index.
         * @returns {ParseXlsx.Row}
         */
        row(rowIndex) {
            return this.Has(rowIndex) ? this[rowIndex] : ''
        }
    }
    class SharedString {
        static __New() {
            this.DeleteProp('__New')
            proto := this.Prototype
            proto.value :=
            proto.attributes := ''
        }
        /**
         * @description - Returns the value, decoding "&amp;", "&gt;", and "&lt;" to "&", ">",
         * and "<", respectively.
         * @memberof ParseXlsx.SharedString
         * @instance
         */
        decoded => StrReplace(StrReplace(StrReplace(this.value, '&gt;', '>'), '&lt;', '<'), '&amp;','&')
    }
    class SharedStringCollection extends Array {
        /**
         * @class
         * @description - Parses the file xl/sharedStrings.xml, adding each string to the array. Since
         * AHK arrays are 1-based, the index of each item is offset by 1.
         * @param {ParseXlsx} xlsx - The {@link ParseXlsx} object.
         */
        __New(xlsx) {
            this.id := xlsx.id
            if FileExist(xlsx.dir '\xl\sharedStrings.xml') {
                content := FileRead(xlsx.dir '\xl\sharedStrings.xml', xlsx.encoding)
                ch := 0xFFFD
                while InStr(content, Chr(ch)) {
                    ++ch
                }
                ch := Chr(ch)
                content := StrReplace(StrReplace(SubStr(content, InStr(content, '<si><t') + 6), '</t></si><si><t', ch, , &count), '</t></si></sst>', '')
                this.Capacity := count + 1
                constructor := ParseXlsx.SharedString
                loop parse content, ch {
                    this.Push(constructor())
                    if RegExMatch(A_LoopField, 's)^([^>]+)>(.+)', &match) {
                        this[-1].value := match[2]
                        this[-1].attributes := match[1]
                    } else {
                        this[-1].value := SubStr(A_LoopField, 2)
                    }
                }
            }
        }
    }
    class Worksheet {
        __New(xlsx, name, wsIndex) {
            this.name := name
            this.wsIndex := wsIndex
            (proto_cell := {}).Base := xlsx.proto_cell
            (proto_row := []).Base := xlsx.proto_row
            (rows := this.rows := []).Base := xlsx.proto_rows
            proto_cell.wsIndex :=
            proto_row.wsIndex :=
            rows.wsIndex := wsIndex
            content := FileRead(xlsx.dir '\xl\worksheets\sheet' wsIndex '.xml', xlsx.encoding)
            ch1 := 0x200B
            while InStr(content, Chr(ch1)) {
                ++ch1
            }
            ch2 := ch1 + 1
            ch1 := Chr(ch1)
            while InStr(content, Chr(ch2)) {
                ++ch2
            }
            ch2 := Chr(ch2)
            RegExMatch(content, '\d+', &match, InStr(content, '<row r="', , , -1) + 8)
            rows.Length := match[0]
            content := RegExReplace(StrReplace(StrReplace(StrReplace(StrReplace(SubStr(content, InStr(content, '<row ') + 5), '</row>', ''), '<row ', ch1), '<c ', ch2), '</c>', ''), '</sheetData>.+', '')
            ubound := 0
            i := 0
            loop parse content, ch1 {
                (currentRow := []).Base := proto_row
                currentRow.__New()
                rowIndex := currentRow.rowIndex
                rows[rowIndex] := currentRow
                loop parse SubStr(A_LoopField, InStr(A_LoopField, ch2) + 1), ch2 {
                    (cell := {}).Base := proto_cell
                    cell.__New()
                    if cell.columnIndex > currentRow.Length {
                        currentRow.Length := cell.columnIndex
                    }
                    currentRow[cell.columnIndex] := cell
                    ubound := Max(ubound, cell.columnIndex)
                }
            }
            this.columnUbound := ubound
            this.rowUbound := rows.Length
        }
        /**
         * @description - Returns the indicated {@link ParseXlsx.Cell} object.
         * @param {Integer} rowIndex - The row index.
         * @param {Integer|String} col - Either the 1-based column index of the column, or the
         * letter(s) of the column.
         */
        cell(rowIndex, col) {
            if this.rows.Has(rowIndex) {
                row := this.rows[rowIndex]
                if !IsNumber(col) {
                    col := ParseXlsx_ColToIndex(col)
                }
                if row.Has(col) {
                    return row.Get2(col)
                }
            }
        }
        /**
         * @description - Returns an array containing the cells in a column.
         * @param {Integer|String} col - Either the 1-based column index of the column, or the
         * letter(s) of the column.
         * @param {Integer} [rowStart = 1] - The first row to include in the output.
         * @param {Integer} [rowEnd = this.rowUbound] - The last row to include in the output.
         * @param {Boolean} [includeEmptyCells = true] - If true, an empty array item is included
         * for each row that does not have a value in the cell for that column. If false, the
         * row is skipped.
         * @returns {ParseXlsx.Cell[]} - An array of {@link ParseXlsx.Cell} objects.
         */
        getColumn(col, rowStart := 1, rowEnd := this.rowUbound, includeEmptyCells := true) {
            if !IsNumber(col) {
                col := ParseXlsx_ColToIndex(col)
            }
            if col > this.columnUbound {
                return ''
            }
            column := []
            rows := this.rows
            r := rowStart - 1
            column.Capacity := rowEnd - r
            if includeEmptyCells {
                loop rowEnd - r {
                    if rows.Has(++r) && rows[r].Has(col) {
                        column.Push(rows[r].Get2(col))
                    } else {
                        column.Push(unset)
                    }
                }
            } else {
                loop rowEnd - r {
                    if rows.Has(++r) && rows[r].Has(col) {
                        column.Push(rows[r].Get2(col))
                    }
                }
                column.Capacity := column.Length
            }
            return column
        }
        /**
         * @description - Returns an array containing the cells in a range. Cells without a value
         * are skipped.
         * @param {Integer} [rowStart = 1] - The first row to include in the output.
         * @param {Integer} [rowEnd = this.rowUbound] - The last row to include in the output.
         * @param {Integer} [columnStart = 1] - The first column to include in the output.
         * @param {Integer} [columnEnd = this.columnUbound] - The last column to include in the output.
         * @returns {ParseXlsx.Cell[]} - An array of {@link ParseXlsx.Cell} objects.
         */
        getRange(rowStart := 1, rowEnd := this.rowUbound, columnStart := 1, columnEnd := this.columnUbound) {
            columnStart--
            c := columnStart
            r := rowStart - 1
            cells := []
            rows := this.Rows
            if rows.Length {
                loop {
                    if ++r > rowEnd {
                        return ''
                    } else if rows.Has(r) {
                        row := rows[r]
                        break
                    }
                }
            } else {
                return ''
            }
            loop {
                if ++c > columnEnd {
                    if ++r > rowEnd {
                        return cells
                    } else if rows.Has(r) {
                        c := columnStart
                        row := rows[r]
                    } else {
                        c := columnStart
                        loop {
                            if ++r > rowEnd {
                                return cells
                            } else if rows.Has(r) {
                                row := rows[r]
                                break
                            }
                        }
                    }
                } else if row.Has(c) {
                    cells.Push(row[c])
                }
            }
        }
        /**
         * @description - Returns an array containing the cells in a row.
         * @param {Integer} rowIndex - The 1-based row index of the row.
         * @param {Integer} [columnStart = 1] - The first column to include in the output.
         * @param {Integer} [columnEnd = this.columnUbound] - The last column to include in the output.
         * @param {Boolean} [includeEmptyCells = true] - If true, an empty array item is included
         * for each column that does not have a value in the cell for that row. If false, the
         * column is skipped.
         * @returns {ParseXlsx.Cell[]} - An array of {@link ParseXlsx.Cell} objects.
         */
        getRow(rowIndex, columnStart := 1, columnEnd := this.columnUbound, includeEmptyCells := true) {
            if rowIndex > this.rowUbound || !this.rows.Has(rowIndex) {
                return ''
            }
            row := []
            c := columnStart - 1
            row.Capacity := columnEnd - c
            subject := this.rows[rowIndex]
            if includeEmptyCells {
                loop columnEnd - c {
                    if subject.Has(++c) {
                        row.Push(subject[c])
                    } else {
                        row.Push(unset)
                    }
                }
            } else {
                loop columnEnd - c {
                    if subject.Has(++c) {
                        row.Push(subject[c])
                    }
                }
                row.Capacity := row.Length
            }
            return row
        }
        /**
         * @description - Returns the indicated {@link ParseXlsx.Row} object.
         */
        row(rowIndex) {
            return this.rows[rowIndex]
        }
        /**
         * @description - Generates a csv for the indicated range.
         * @param {Integer} [rowStart = 1] - The first row to include in the output.
         * @param {Integer} [rowEnd = this.rowUbound] - The last row to include in the output.
         * @param {Integer} [columnStart = 1] - The first column to include in the output.
         * @param {Integer} [columnEnd = this.columnUbound] - The last column to include in the output.
         * @param {String} [fieldSeparator = ","] - The string to separate each field.
         * @param {String} [recordSeparator = "`n"] - The string to separate each record.
         * @param {Boolean} [escapeFields = true] - When true, all fields are checked for characters
         * that will require the field to be enclosed in quotation marks, and escapes inner quotation
         * marks. When false, all fields are unquoted.
         * @param {Boolean} [includeEmptyRows = true] - When true, empty rows are represented in the
         * output as a series of empty fields. When false, empty rows are skipped.
         * @returns {String}
         */
        toCsv(rowStart := 1, rowEnd := this.rowUbound, columnStart := 1, columnEnd := this.columnUbound, fieldSeparator := ',', recordSeparator := '`n', escapeFields := true, includeEmptyRows := true) {
            pattern := '"|\Q' fieldSeparator '\E|\Q' recordSeparator '\E|\r|\n'
            s := ''
            VarSetStrCapacity(&s, 65536)
            rows := this.rows
            _count := columnEnd - columnStart + 1
            r := rowStart - 1
            if escapeFields {
                loop rowEnd - r {
                    if rows.Has(++r) {
                        row := rows[r]
                        c := columnStart
                        if row.Has(c) {
                            value := row[c].value
                            if RegExMatch(value, pattern) {
                                s .= '"' StrReplace(value, '"', '""') '"'
                            } else {
                                s .= value
                            }
                        }
                        loop columnEnd - c {
                            s .= fieldSeparator
                            if row.Has(++c) {
                                value := row[c].value
                                if RegExMatch(value, pattern) {
                                    s .= '"' StrReplace(value, '"', '""') '"'
                                } else {
                                    s .= value
                                }
                            }
                        }
                        s .= recordSeparator
                    } else if includeEmptyRows {
                        loop _count {
                            s .= fieldSeparator
                        }
                        s .= recordSeparator
                    }
                }
            } else {
                loop rowEnd - r {
                    if rows.Has(++r) {
                        row := rows[r]
                        c := columnStart
                        if row.Has(c) {
                            s .= row[c].value
                        }
                        loop columnEnd - c {
                            s .= fieldSeparator
                            if row.Has(++c) {
                                s .= row[c].value
                            }
                        }
                        s .= recordSeparator
                    } else if includeEmptyRows {
                        loop _count {
                            s .= fieldSeparator
                        }
                        s .= recordSeparator
                    }
                }
            }
            VarSetStrCapacity(&s, -1)
            return s
        }
        /**
         * @description - Generates a csv for the indicated range.
         * @param {*} callback - A `Func` or callable object that will receive each
         * {@link ParseXlsx.Cell} object. The function should return the string that should be
         * added to the record. The function **should not** add quotation marks;
         * {@link ParseXlsx.Worksheet.Prototype.toCsv2} will add them for you if necessary.
         * @param {Integer} [rowStart = 1] - The first row to include in the output.
         * @param {Integer} [rowEnd = this.rowUbound] - The last row to include in the output.
         * @param {Integer} [columnStart = 1] - The first column to include in the output.
         * @param {Integer} [columnEnd = this.columnUbound] - The last column to include in the output.
         * @param {String} [fieldSeparator = ","] - The string to separate each field.
         * @param {String} [recordSeparator = "`n"] - The string to separate each record.
         * @param {Boolean} [escapeFields = true] - When true, all fields are checked for characters
         * that will require the field to be enclosed in quotation marks, and escapes inner quotation
         * marks. When false, all fields are unquoted.
         * @param {Boolean} [includeEmptyRows = true] - When true, empty rows are represented in the
         * output as a series of empty fields. When false, empty rows are skipped.
         * @returns {String}
         */
        toCsv2(callback, rowStart := 1, rowEnd := this.rowUbound, columnStart := 1, columnEnd := this.columnUbound, fieldSeparator := ',', recordSeparator := '`n', escapeFields := true, includeEmptyRows := true) {
            pattern := '"|\Q' fieldSeparator '\E|\Q' recordSeparator '\E|\r|\n'
            s := ''
            VarSetStrCapacity(&s, 65536)
            rows := this.rows
            _count := columnEnd - columnStart + 1
            r := rowStart - 1
            if escapeFields {
                loop rowEnd - r {
                    if rows.Has(++r) {
                        row := rows[r]
                        c := columnStart
                        if row.Has(c) {
                            value := callback(row[c])
                            if RegExMatch(value, pattern) {
                                s .= '"' StrReplace(value, '"', '""') '"'
                            } else {
                                s .= value
                            }
                        }
                        loop columnEnd - c {
                            s .= fieldSeparator
                            if row.Has(++c) {
                                value := callback(row[c])
                                if InStr(value, '`n') {
                                    sleep 1
                                }
                                if RegExMatch(value, pattern) {
                                    s .= '"' StrReplace(value, '"', '""') '"'
                                } else {
                                    s .= value
                                }
                            }
                        }
                        s .= recordSeparator
                    } else if includeEmptyRows {
                        loop _count {
                            s .= fieldSeparator
                        }
                        s .= recordSeparator
                    }
                }
            } else {
                loop rowEnd - r {
                    if rows.Has(++r) {
                        row := rows[r]
                        c := columnStart
                        if row.Has(c) {
                            s .= callback(row[c])
                        }
                        loop columnEnd - c {
                            s .= fieldSeparator
                            if row.Has(++c) {
                                s .= callback(row[c])
                            }
                        }
                        s .= recordSeparator
                    } else if includeEmptyRows {
                        loop _count {
                            s .= fieldSeparator
                        }
                        s .= recordSeparator
                    }
                }
            }
            VarSetStrCapacity(&s, -1)
            return s
        }
        xlsx => ParseXlsx.Collection.Get(this.id)
    }
}

/**
 * @description - Returns the column index for the indicated column.
 * @param {String} col - The column's letter(s).
 * @returns {Integer}
 */
ParseXlsx_ColToIndex(col) {
    n := 0
    loop parse col {
        n := Ord(A_LoopField) - 64 + n * 26
    }
    return n
}
/**
 * @description - Decompresses an xlsx document.
 * @param {String} pathIn - The path to the xlsx document.
 * @param {String} dirOut - The directory where the xlsx contents will be decompressed. The directory
 * does not need to exist. An error is thrown if `dir` already contains at least one of the following
 * files: .\[Content_Types].xml, .\docProps\app.xml, .\xl\sharedStrings.xml, .\xl\styles.xml,
 * .\xl\workbook.xml, .\xl\worksheets\sheet1.xml.
 *
 * @throws {Error} - "The ParseXlsx output directory is already occupied."
 */
ParseXlsx_Decompress(pathIn, dirOut) {
    ; Resolve relative paths
    SplitPath(pathIn, , , , , &drive)
    if !drive && ParseXlsx_ResolveRelativePathRef(&pathIn) {
        throw Error('Failed to resolve ``path``.')
    }
    SplitPath(dirOut, , , , , &drive)
    if !drive && ParseXlsx_ResolveRelativePathRef(&dirOut) {
        throw Error('Failed to resolve ``path``.')
    }
    if DirExist(dirOut) {
        for path in [ '\[Content_Types].xml', '\docProps\app.xml', '\xl\sharedStrings.xml'
        , '\xl\styles.xml', '\xl\workbook.xml', '\xl\worksheets\sheet1.xml' ] {
            if FileExist(dirOut path) {
                throw Error('The ParseXlsx output directory is already occupied.')
            }
        }
    } else {
        DirCreate(dirOut)
    }
    if FileExist(dirOut '\wb.zip') {
        i := 1
        while FileExist(dirOut '\wb-' i '.zip') {
            ++i
        }
        temp := dirOut '\wb-' i '.zip'
    } else {
        temp := dirOut '\wb.zip'
    }
    FileCopy(pathIn, temp)
    shell := ComObject('Shell.Application')
    src := shell.NameSpace(temp)
    dst := shell.NameSpace(dirOut)
    ; https://learn.microsoft.com/en-us/windows/win32/shell/folder-copyhere
    ; This decompresses the xlsx document, exposing the internal file
    ; structure and various xml documents.
    dst.CopyHere(src.Items(), 20)
    FileDelete(temp)
}
/**
 * @description - Fixes floating point imprecision. The returned value is a string representation of
 * the number rounded to the appropriate decimal point.
 * @param {Float|String} value - The value.
 * @returns {String}
 */
ParseXlsx_FixFloatingPoint(value) {
    if InStr(value, '.') && RegExMatch(value, 'S)(?<round>(?:0{3,}|9{3,})\d)$', &match) {
        return String(Round(value, StrLen(value) - InStr(value, '.') - match.Len['round']))
    } else {
        return value
    }
}
/**
 * @description - Fixes floating point imprecision. The returned value is a string representation of
 * the number rounded to the appropriate decimal point.
 * @param {VarRef} value - A variable containing the vlaue. The variable will be modified directly.
 */
ParseXlsx_FixFloatingPoint2(&value) {
    if InStr(value, '.') && RegExMatch(value, 'S)(?<round>(?:0{3,}|9{3,})\d)$', &match) {
        value := String(Round(value, StrLen(value) - InStr(value, '.') - match.Len['round']))
    }
}
/**
 * @description - Returns the column letter(s) for the indicated column.
 * @param {String} index - The column index.
 * @returns {String}
 */
ParseXlsx_IndexToCol(index) {
    col := ''
    while index > 0 {
        q := (index - 1) / 26
        r := Mod(index - 1, 26)
        index := Floor(q)
        col := Chr(65 + r) col
    }
    return col
}
/**
 * @description - A function intended to be used as an
 * {@link https://www.autohotkey.com/docs/v2/lib/OnExit.htm OnExit} callback to delete the directory
 * on exit. This is used when parameter {@link ParseXlsx.Prototype.__New~setOnExit} is true.
 *
 * This deletes the directory.
 *
 * @param {String} dir - Bind the directory path to this parameter.
 */
ParseXlsx_OnExit_Delete(dir, *) {
    if DirExist(dir) {
        DirDelete(dir, 1)
    }
}
/**
 * @description - A function intended to be used as an
 * {@link https://www.autohotkey.com/docs/v2/lib/OnExit.htm OnExit} callback to delete the directory
 * on exit. This is used when parameter {@link ParseXlsx.Prototype.__New~setOnExit} is true.
 *
 * This recycles the directory.
 *
 * @param {String} dir - Bind the directory path to this parameter.
 */
ParseXlsx_OnExit_Recycle(dir, *) {
    if DirExist(dir) {
        FileRecycle(dir)
    }
}
/**
 * @description - Parses the xml text for the object. For each attribute of the element associated with
 * the object, defines a property with the same name and value on the object.
 * @param {ParseXlsx.Row|ParseXlsx.Cell} obj - The object.
 */
ParseXlsx_ParseAttributes(obj) {
    s := SubStr(obj.text, 1, InStr(obj.text, '>'))
    pos := 1
    while RegExMatch(s, ParseXlsx_PatternAttributes, &match, pos) {
        pos := match.Pos + match.Len
        obj.DefineProp(match[1], { Value: match[2] })
    }
}
/**
 * @description - Parses the xml text. For each attribute of the element associated with
 * the object, adds an object to an array. The object has properties { name, value }.
 * @param {String} str - The xml text. This is expected to contain the element's definition, e.g.
 * "<element attr1="val" attr2="val2">".
 * @returns {{}[]}
 */
ParseXlsx_ParseAttributes2(str) {
    result := []
    pos := 1
    while RegExMatch(str, ParseXlsx_PatternAttributes, &match, pos) {
        pos := match.Pos + match.Len
        result.Push({ name: match[1], value: match[2] })
    }
    return result
}
/**
 * @description - Parses the [Content_Types].xml document. For each <Override> element, a
 * `RegExMatchInfo` object is added to an array. The `RegExMatchInfo` objects have two subcapture
 * groups:
 * - name : Returns the value of the PartName attribute.
 * - type : Returns the value of the ContentType attribute.
 *
 * This can be used to get a list of documents associated with the decompressed workbook.
 *
 * @param {String} path - The path to the [Content_Types].xml document.
 * @param {String} [encoding = "utf-8"] - The file encoding.
 * @returns {RegExMatchInfo[]} - An array of `RegExMatchInfo` objects.
 */
ParseXlsx_ParseContentTypes(path, encoding := 'utf-8') {
    content := FileRead(path, encoding)
    list := []
    pos := 1
    while RegExMatcH(content, '<Override.+?PartName="(?<name>[^"]+)".+?ContentType="(?<type>[^"]+)', &match, pos) {
        pos := match.Pos + match.Len
        list.Push(match)
    }
    return list
}
/**
 * @description - Parses the xml text for the object. For each nested element associated with
 * the object, defines a property with the same name and value on the object.
 * @param {ParseXlsx.Cell} cell - The object.
 */
ParseXlsx_ParseElements(cell) {
    s := cell.text
    pos := 1
    while RegExMatch(s, ParseXlsx_PatternElements, &match, pos) {
        pos := match.Pos + match.Len
        cell.DefineProp(match[1], { Value: match[2] })
    }
}
/**
 * @description - Parses the xml text. For each nested element associated with the object, adds an
 * object to an array. The object has properties { name, value }. "value" is the element's inner text.
 * @param {String} str - The xml text. This is expected to contain the element's definition including
 * its entire inner text, e.g. "<element attr1="val" attr2="val2">inner text...</element>".
 * @returns {{}[]}
 */
ParseXlsx_ParseElements2(str) {
    result := []
    pos := 1
    while RegExMatch(str, ParseXlsx_PatternElements, &match, pos) {
        pos := match.Pos[1] + match.Len[1]
        result.Push({ name: match[1], value: match[2] })
    }
    return result
}
/**
 * @description - Processes a relative path with any number of ".\" or "..\" segments.
 * @param {VarRef} Path - A variable containing the relative path to evaluate as string.
 * @param {String} [RelativeTo] - The location `Path` is relative to. If unset, the working directory
 * is used. `RelativeTo` can also be relative with "..\" leading segments.
 *
 * @returns {Integer} - Returns 0 if the function is successful. Returns 1 if the input parameters
 * are invalid.
 */
ParseXlsx_ResolveRelativePathRef(&Path, RelativeTo?) {
    if IsSet(RelativeTo) && RelativeTo {
        SplitPath(RelativeTo, , , , , &Drive)
        if !Drive {
            if InStr(RelativeTo, '.\') {
                w := A_WorkingDir
                if _Process(&RelativeTo, &w) {
                    return 1
                }
            } else {
                RelativeTo := A_WorkingDir '\' RelativeTo
            }
        }
    } else {
        RelativeTo := A_WorkingDir
    }
    if InStr(Path, '.\') {
        if _Process(&Path, &RelativeTo) {
            return 1
        }
    } else {
        Path := RelativeTo '\' Path
    }
    Path := RTrim(Path, '\')

    return 0

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
                return 1
            }
        } else if relative {
            path := relative
        } else {
            return 1
        }
    }
}
/**
 * @description - Sets global constants.
 * @param {Boolean} [force = false] - If {@link ParseXlsx_SetConstants} has already been called,
 * if `force` is true, the variables are set again. If `force` is falls, returns immediately.
 */
ParseXlsx_SetConstants(force := false) {
    global
    if IsSet(ParseXlsx_constants_set) && !force {
        return
    }
    local p := ('[\w_:]|[\x{C0}-\x{D6}]|[\x{D8}-\x{F6}]|[\x{F8}-\x{2FF}]|[\x{370}-\x{37D}]|[\x{37F}-'
    '\x{1FFF}]|[\x{200C}-\x{200D}]|[\x{2070}-\x{218F}]|[\x{2C00}-\x{2FEF}]|[\x{3001}-\x{D7FF}]|[\x{F'
    '900}-\x{FDCF}]|[\x{FDF0}-\x{FFFD}]|[\x{10000}-\x{EFFFF}]')
    , name := '(?:' p ')(?:' p '|[-.\d]|\x{B7}|[\x{0300}-\x{036F}]|[\x{203F}-\x{2040}])*'
    ParseXlsx_PatternElements := 'Ss)<(' name ')[^>]*>(.+?)</\1>'
    ParseXlsx_PatternAttributes := 'S)(' name ')="(.*?(?<!")(?:"")*+)"'
    ParseXlsx_constants_set := 1
}
