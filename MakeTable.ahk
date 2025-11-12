/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/Win32/MakeTable.ahk
    Author: Nich-Cebolla
    License: MIT
*/

; See file test-files\test-MakeTable2.ahk for output examples using various options.

class MakeTable extends Array {
    /**
     * Converts a string into a string formatted like a table. Also can output a markdown-style table.
     *
     * `MakeTable` supports maximum widths on a per-column basis. If the text in a cell exceeds the
     * maximum, it breaks the text into multiple lines. Understand that markdown-style tables do not
     * support hard line breaks. You can add line breaks using <br>, but I did not implement that kind
     * of logic in this function.
     *
     * Here's an example of the options needed to convert text into a markdown-style table:
     *
     * @example
     *  Options := {
     *      LinePrefix: "|  "           ; Adds a pipe and two spaces before every line
     *    , LineSuffix: "  |"           ; Adds two spaces and a pipe after every line
     *    , OutputColumnSeparator: "|"  ; Adds a pipe in-between every column
     *    , AddHeaderSeparator: true    ; Adds the markdown-style header separator
     *    , ColumnPadding: "`s`s"       ; Adds two space characters on the left and right side of each column (default)
     *    , MaxWidths: ""               ; No maximum widths (default)
     *    , InputRowSeparator: "\R"     ; Rows are separated by line break characters (default)
     *    , InputColumnSeparator: "`t"  ; Columns are separated by tab characters in the input text (default)
     *  }
     * @
     *
     * The above options will output a string like the below table, which is is recognized by the
     * markdown rendering engine used by VS Code (different rendering engines may have have
     * varying requirements to render a table):
     *
     * <pre>
     * |  Hook Name           |  ID  |  Proc Type             |  lParam Points To       |  Use Case                                         |
     * |  --------------------|------|------------------------|-------------------------|-------------------------------------------------  |
     * |  WH_CALLWNDPROC      |  4   |  CallWndProc           |  CWPSTRUCT              |  Monitor before a message is processed            |
     * |  WH_CALLWNDPROCRET   |  12  |  CallWndRetProc        |  CWPRETSTRUCT           |  Monitor after a message is processed             |
     * |  WH_CBT              |  5   |  CBTProc               |  Varies by nCode        |  Window activation, creation, move, resize, etc.  |
     * |  WH_DEBUG            |  9   |  DebugProc             |  DEBUGHOOKINFO          |  Debugging other hook procedures                  |
     * |  WH_FOREGROUNDIDLE   |  11  |  ForegroundIdleProc    |  lParam unused          |  Detect idle foreground thread                    |
     * |  WH_GETMESSAGE       |  3   |  GetMsgProc            |  MSG                    |  Intercept message queue on removal               |
     * |  WH_JOURNALPLAYBACK  |  1   |  JournalPlaybackProc   |  EVENTMSG               |  Replay input events (obsolete)                   |
     * |  WH_JOURNALRECORD    |  0   |  JournalRecordProc     |  EVENTMSG               |  Record input events (obsolete)                   |
     * |  WH_KEYBOARD         |  2   |  KeyboardProc          |  lParam = packed flags  |  Keyboard input (per-thread)                      |
     * |  WH_KEYBOARD_LL      |  13  |  LowLevelKeyboardProc  |  KBDLLHOOKSTRUCT        |  Global keyboard input                            |
     * |  WH_MOUSE            |  7   |  MouseProc             |  MOUSEHOOKSTRUCT        |  Mouse events (per-thread)                        |
     * |  WH_MOUSE_LL         |  14  |  LowLevelMouseProc     |  MSLLHOOKSTRUCT         |  Global mouse input                               |
     * |  WH_MSGFILTER        |  -1  |  MessageProc           |  MSG                    |  Pre-translate messages in modal loops            |
     * |  WH_SHELL            |  10  |  ShellProc             |  Varies by nCode        |  Shell events (task switch, window create, etc.)  |
     * |  WH_SYSMSGFILTER     |  6   |  MessageProc           |  MSG                    |  Like WH_MSGFILTER, but system-wide               |
     * </pre>
     *
     * Here's an example using maximum widths:
     *
     * @example
     *  Options := {
     *      MaxWidths: [20,20,22,20,25] ; Defines the maximum widths for each column
     *    , AddHeaderSeparator: true    ; Adds the markdown-style header separator (default)
     *    , ColumnPadding: "`s`s"       ; Adds two space characters on the left and right side of each column (default)
     *    , InputRowSeparator: "\R"     ; Rows are separated by line break characters (default)
     *    , InputColumnSeparator: "`t"  ; Columns are separated by tab characters in the input text (default)
     *  }
     * @
     *
     * The above options will output a string like the below table:
     *
     * <pre>
     * Hook Name             ID    Proc Type             lParam Points To    Use Case
     * -------------------------------------------------------------------------------------------
     * WH_CALLWNDPROC        4     CallWndProc           CWPSTRUCT           Monitor before a
     *                                                                       message is processed
     * WH_CALLWNDPROCRET     12    CallWndRetProc        CWPRETSTRUCT        Monitor after a
     *                                                                       message is processed
     * WH_CBT                5     CBTProc               Varies by nCode     Window activation,
     *                                                                       creation, move,
     *                                                                       resize, etc.
     * WH_DEBUG              9     DebugProc             DEBUGHOOKINFO       Debugging other hook
     *                                                                       procedures
     * WH_FOREGROUNDIDLE     11    ForegroundIdleProc    lParam unused       Detect idle
     *                                                                       foreground thread
     * WH_GETMESSAGE         3     GetMsgProc            MSG                 Intercept message
     *                                                                       queue on removal
     * WH_JOURNALPLAYBACK    1     JournalPlaybackPro    EVENTMSG            Replay input events
     *                             c                                         (obsolete)
     * WH_JOURNALRECORD      0     JournalRecordProc     EVENTMSG            Record input events
     *                                                                       (obsolete)
     * WH_KEYBOARD           2     KeyboardProc          lParam = packed     Keyboard input
     *                                                   flags               (per-thread)
     * WH_KEYBOARD_LL        13    LowLevelKeyboardPr    KBDLLHOOKSTRUCT     Global keyboard input
     *                             oc
     * WH_MOUSE              7     MouseProc             MOUSEHOOKSTRUCT     Mouse events
     *                                                                       (per-thread)
     * WH_MOUSE_LL           14    LowLevelMouseProc     MSLLHOOKSTRUCT      Global mouse input
     * WH_MSGFILTER          -1    MessageProc           MSG                 Pre-translate
     *                                                                       messages in modal
     *                                                                       loops
     * WH_SHELL              10    ShellProc             Varies by nCode     Shell events (task
     *                                                                       switch, window
     *                                                                       create, etc.)
     * WH_SYSMSGFILTER       6     MessageProc           MSG                 Like WH_MSGFILTER,
     *                                                                       but system-wide
     * </pre>
     *
     * The examples are based off this input text:
     *
     * <pre>
     * Hook Name	ID	Proc Type	lParam Points To	Use Case
     * WH_CALLWNDPROC	4	CallWndProc	CWPSTRUCT	Monitor before a message is processed
     * WH_CALLWNDPROCRET	12	CallWndRetProc	CWPRETSTRUCT	Monitor after a message is processed
     * WH_CBT	5	CBTProc	Varies by nCode	Window activation, creation, move, resize, etc.
     * WH_DEBUG	9	DebugProc	DEBUGHOOKINFO	Debugging other hook procedures
     * WH_FOREGROUNDIDLE	11	ForegroundIdleProc	lParam unused	Detect idle foreground thread
     * WH_GETMESSAGE	3	GetMsgProc	MSG	Intercept message queue on removal
     * WH_JOURNALPLAYBACK	1	JournalPlaybackProc	EVENTMSG	Replay input events (obsolete)
     * WH_JOURNALRECORD	0	JournalRecordProc	EVENTMSG	Record input events (obsolete)
     * WH_KEYBOARD	2	KeyboardProc	lParam = packed flags	Keyboard input (per-thread)
     * WH_KEYBOARD_LL	13	LowLevelKeyboardProc	KBDLLHOOKSTRUCT	Global keyboard input
     * WH_MOUSE	7	MouseProc	MOUSEHOOKSTRUCT	Mouse events (per-thread)
     * WH_MOUSE_LL	14	LowLevelMouseProc	MSLLHOOKSTRUCT	Global mouse input
     * WH_MSGFILTER	-1	MessageProc	MSG	Pre-translate messages in modal loops
     * WH_SHELL	10	ShellProc	Varies by nCode	Shell events (task switch, window create, etc.)
     * WH_SYSMSGFILTER	6	MessageProc	MSG	Like WH_MSGFILTER, but system-wide
     * </pre>
     *
     * @param {String} [Str] - The input string. If unset, the text on the clipboard is used.
     *
     * @param {Object} [Options] - An object with zero or more options as property:value pairs.
     *
     * @param {Boolean} [Options.AddHeaderSeparator = true] - If true, adds a separator between
     * the first row and second row.
     *
     * @param {String} [Options.ColumnPadding = "`s`s"] - The literal string that is added to the
     * left and right side of every column, EXCEPT the left side of the first column and the right
     * side of the last column. Use `Options.LinePrefix` and `Options.LineSuffix` to adjust the
     * left side of the first column and the right side of the last column.
     *
     * @param {String} [Options.InputColumnSeparator = "`t"] - A RegEx pattern that identifies the
     * boundary between columns.
     *
     * @param {String} [Options.InputRowSeparator = "\R"] - A RegEx pattern that identifies the
     * boundary between rows.
     *
     * @param {String} [Options.LinePrefix = ""] - The literal string that is added before every line.
     *
     * @param {String} [Options.LineSuffix = ""] - The literal string that is added after every line.
     *
     * @param {Integer|Integer[]} [Options.MaxWidths = ""] - If in use, `Options.MaxWidths` is an array of
     * integers which define the maximum allowable width per column. If the text in a cell exceeds the
     * maximum, `MakeTable` breaks the text into multiple lines. If `Options.MaxWidths` is an integer,
     * that value is applied as the max width of all columns.
     *
     * @param {String[]} [Options.OutputColumnPrefix = ""] - Used to specify strings that prefixe
     * columns. The difference between `Options.OutputColumnPrefix` and `Options.OutputColumnSeparator`
     * is that `Options.OutputColumnSeparator` is applied to all columns, whereas
     * `Options.OutputColumnPrefix` is used to prefix every line of a specific column with a specific
     * string. The value of this option, if used, should be an array of strings. The indices of the
     * array are associated with the column index that is to be prefixed by the string at that index.
     * For example, if I have a table that is three columns, and I want to prefix each line of the
     * third column with "; ", then I would set `Options.ColumnPrefix := ["", "", "; "]`. I added
     * this option with the intent of using it to comment out portions of text when using `MakeTable`
     * to generate pretty-formatted code.
     *
     * @param {Boolean} [Options.OutputColumnPrefixSkipFirstRow = false] - If true, the first
     * line is not affected by `Options.OutputColumnPrefix`.
     *
     * @param {String} [Options.OutputColumnSeparator = ""] - The literal string that is used to
     * separate cells.
     *
     * @param {Boolean} [Options.OutputLineBetweenRows = false] - If true, there will be an extra line
     * separating the rows. The line will look just like the header separator seen in the above
     * examples.
     *
     * @param {String} [Options.OutputRowSeparator = "`n"] - The literal string that is used to
     * separate rows.
     *
     * @param {String} [Options.TrimCharacters = "`s"] - The value passed to the third parameter
     * of `StrSplit` when breaking the input text into rows and cells. `Options.TrimCharactersRow`
     * and `Options.TrimCharactersCell` supercede `Options.TrimCharacters`. For example, if
     * you set `Options.TrimCharacters := "`s"` and `Options.TrimCharactersRow := "$"`, the characters
     * trimmed from the left and right side of each line is "$" and the characters trimmed from the
     * left and right side of each cell is "`s" (space).
     * {@link https://www.autohotkey.com/docs/v2/lib/StrSplit.htm}
     *
     * @param {String} [Options.TrimCharactersRow = ""] - The value passed to the third parameter
     * of `StrSplit` when breaking the input text into lines. `Options.TrimCharactersRow`
     * and `Options.TrimCharactersCell` supercede `Options.TrimCharacters`. For example, if
     * you set `Options.TrimCharacters := "`s"` and `Options.TrimCharactersRow := "$"`, the characters
     * trimmed from the left and right side of each line is "$" and the characters trimmed from the
     * left and right side of each cell is "`s" (space).
     * {@link https://www.autohotkey.com/docs/v2/lib/StrSplit.htm}
     *
     * @param {String} [Options.TrimCharactersCell = ""] - The value passed to the third parameter
     * of `StrSplit` when breaking the text lines into individual cells. `Options.TrimCharactersRow`
     * and `Options.TrimCharactersCell` supercede `Options.TrimCharacters`. For example, if
     * you set `Options.TrimCharacters := "`s"` and `Options.TrimCharactersRow := "$"`, the characters
     * trimmed from the left and right side of each line is "$" and the characters trimmed from the
     * left and right side of each cell is "`s" (space).
     * {@link https://www.autohotkey.com/docs/v2/lib/StrSplit.htm}
     *
     * @returns {MakeTable} - An array of arrays of arrays of strings.
     *
     * Each item of the {@link MakeTable} array is a {@link MakeTable_Row} representing a row in the table.
     *
     * Each item of the {@link MakeTable_Row} arrays is a {@link MakeTable_Cell} object representing
     * a cell in the table. {@link MakeTable_Cell} objects are arrays of strings, where each item
     * represent a line of text for that cell. If you call the object, i.e.
     * {@link MakeTable_Cell.Prototype.Call}, it will return the full text within the cell.
     *
     * If `Options.MaxWidths` is not in use, then the length of the line-arrays is always 1 (no cells
     * are broken into multiple lines). If `Options.MaxWidths` is in use, then the length of the array
     * is the number of lines that the text was broken into for that cell. The property
     * {@link MakeTable#RowLines} is an array of integers representing the number of lines each
     * row occupies, which is the greatest number of lines into which the text within any cell in that
     * row was split.
     *
     * The entire formatted table string is set to property {@link MakeTable#Value}.
     *
     * Accessing a string value in the array looks like this:
     * @example
     * ; Assume `inputStr` and `options` are appropriately defined.
     * tbl := MakeTable(inputStr, options)
     * r := 1 ; row index
     * c := 1 ; column index
     * k := 1 ; line index
     * text := tbl[r][c][k]
     * @
     *
     * Accessing the text in a cell looks like this:
     * @example
     * ; Assume `inputStr` and `options` are appropriately defined.
     * tbl := MakeTable(inputStr, options)
     * r := 1 ; row index
     * c := 1 ; column index
     * cell := tbl[r][c]
     * text := cell() ; call the cell object to get the entire cell's text content
     * @
     *
     * @class
     */
    __New(Str?, Options?) {
        Options := this.Options := MakeTable.Options(Options ?? unset)
        if !IsSet(Str) {
            Str := A_Clipboard
        }
        ; `MakeTable` allows regex patterns for `Options.InputRowSeparator` and
        ; `Options.InputColumnSeparator`. To use the patterns with `StrSplit`, we must first use
        ; `RegExReplace` with a single character. This block searches the input string for two
        ; characters that do not exist in the string, then replaces the patterns with the characters,
        ; then calls `StrSplit`.
        n := 0xFFFC
        while InStr(Str, Chr(n)) {
            n++
        }
        n2 := n + 1
        while InStr(Str, Chr(n2)) {
            n2++
        }
        tcr := tcc := Options.TrimCharacters
        if Options.TrimCharactersRow {
            tcr := Options.TrimCharactersRow
        }
        if Options.TrimCharactersCell {
            tcc := Options.TrimCharactersCell
        }
        inputColumnSeparator := Chr(n2)
        Str := RegExReplace(RegExReplace(Str, Options.InputColumnSeparator, inputColumnSeparator), Options.InputRowSeparator, Chr(n))
        lines := StrSplit(Str, Chr(n), tcr)

        ; Prepare column linePrefix
        columnPrefixSkipFirstLine := Options.OutputColumnPrefixSkipFirstRow
        if columnPrefix := Options.OutputColumnPrefix {
            columnPrefixLen := []
            for str in columnPrefix {
                columnPrefixLen.Push(StrLen(str))
            }
            columnPrefix.Default := ''
            columnPrefixLen.Default := 0
        } else {
            columnPrefix := MakeTable_ValueHelper('')
            columnPrefixLen := MakeTable_ValueHelper(0)
        }

        columnPadding := Options.ColumnPadding
        columnPaddingLen := StrLen(columnPadding)
        maxWidths := Options.MaxWidths
        if IsNumber(maxWidths) {
            maxWidths := MakeTable_ValueHelper(maxWidths)
        }
        if maxWidths {
            Measure := _Measure1
        } else {
            Measure := _Measure2
        }

        columnWidths := []
        columnWidths.Default := 0
        rowLines := this.RowLines := []
        rowLines.Default := 1
        this.Capacity := lines.Length
        rowProto := MakeTable_Row.Prototype
        r := 0
        loop lines.Length {
            ++r
            rowLines.Push(1)
            this.Push(StrSplit(lines[r], inputColumnSeparator, tcc))
            ObjSetBase(this[-1], rowProto)

            ; Ensures the length of the arrays are equal to the number of columns in the table
            if this[r].Length > columnWidths.Length {
                columnWidths.Length := this[r].Length
            }
            if columnPrefix is Array {
                columnPrefix.Length := columnPrefixLen.Length := columnWidths.Length
            }

            c := 0
            loop this[r].Length {
                ++c
                Measure()
            }
        }
        r := 0
        loop lines.Length {
            ++r
            if this[r].Length < columnWidths.Length {
                loop columnWidths.Length - this[r].Length {
                    this[r].Push([''])
                }
            }
        }
        r := 0
        linePrefix := Options.LinePrefix
        columnSeparator := Options.OutputColumnSeparator
        le := Options.OutputRowSeparator
        lineSuffix := Options.LineSuffix
        filler := MakeTable_FillStr('-')
        lineBetweenRows := linePrefix
        for width in columnWidths {
            if A_Index > 1 {
                lineBetweenRows .= filler[columnPaddingLen]
            }
            lineBetweenRows .= filler[width + columnPrefixLen[A_Index]]
            if A_Index < columnWidths.Length {
                lineBetweenRows .= filler[columnPaddingLen] columnSeparator
            }
        }
        lineBetweenRows .= lineSuffix le
        outputLineBetweenRows := Options.OutputLineBetweenRows
        addHeaderSeparator := Options.AddHeaderSeparator
        table := ''
        loop this.Length {
            ++r
            if (outputLineBetweenRows && r > 1) || (r == 2 && addHeaderSeparator) {
                table .= lineBetweenRows
            }
            k := 0
            loop rowLines[r] {
                ++k
                table .= linePrefix
                c := 0
                loop this[r].Length {
                    ++c
                    if c > 1 {
                        table .= columnPadding
                    }
                    if this[r][c].Length >= k {
                        if !columnPrefixSkipFirstLine || r > 1 {
                            table .= columnPrefix[c]
                            table .= this[r][c][k]
                            diff := columnWidths[c] - StrLen(this[r][c][k])
                            if diff > 0 {
                                table .= MakeTable_FillStr[diff]
                            }
                        } else {
                            table .= this[r][c][k]
                            diff := columnWidths[c] - StrLen(this[r][c][k]) + columnPrefixLen[c]
                            if diff > 0 {
                                table .= MakeTable_FillStr[diff]
                            }
                        }
                    } else {
                        table .= MakeTable_FillStr[columnWidths[c] + columnPrefixLen[c]]
                    }
                    if c == this[r].Length {
                        table .= lineSuffix le
                    } else {
                        table .= columnPadding columnSeparator
                    }
                }
            }
        }
        this.Value := SubStr(table, 1, -StrLen(le))

        return

        _Measure1() {
            if !columnPrefixSkipFirstLine || r > 1 {
                maxWidth := maxWidths[c] - (c > 1 ? columnPaddingLen * 2 : columnPaddingLen) - columnPrefixLen[c]
            } else {
                maxWidth := maxWidths[c] - (c > 1 ? columnPaddingLen * 2 : columnPaddingLen)
            }
            if StrLen(this[r][c]) > maxWidth {
                p := 1
                items := MakeTable_Cell()
                loop {
                    if pos := InStr(s1 := SubStr(this[r][c], p, maxWidth), ' ', , , -1) {
                        items.Push(s2 := SubStr(this[r][c], p, pos - 1))
                        p += pos
                    } else {
                        items.Push(SubStr(this[r][c], p, maxWidth))
                        p += maxWidth
                    }
                    if p + maxWidth >= StrLen(this[r][c]) {
                        items.Push(SubStr(this[r][c], p))
                        break
                    }
                }
                rowLines[r] := Max(rowLines[r], items.Length)
                this[r][c] := items
                columnWidths[c] := maxWidth
            } else {
                this[r][c] := MakeTable_Cell(this[r][c])
                columnWidths[c] := Max(StrLen(this[r][c][1]), columnWidths[c])
            }
        }
        _Measure2() {
            this[r][c] := MakeTable_Cell(this[r][c])
            columnWidths[c] := Max(StrLen(this[r][c][1]), columnWidths[c])
        }
    }

    /**
     * Returns an html table.
     *
     * @param {Object} [Options] - An object with zero or more options as property : value pairs.
     *
     * @param {String} [Options.IndentChar = "`s"] - The character that is used for indentation.
     *
     * @param {Integer} [Options.IndentLen = 2] - The number of `Options.IndentChar` that is used
     * for one level of indentation.
     *
     * @param {Integer} [Options.InitialIndent = 0] - The initial indentation level of the output
     * string.
     *
     * @param {String} [Options.InnerLineSeparator = ""] - The value passed to the parameters
     * {@link MakeTable_Cell.Prototype.Call~Separator} which is used to separate each line of text
     * within a cell when {@link MakeTable.Prototype.__New~Options.MaxWidths} is used. For example,
     * if your cells contain very long strings that would look better broken up into multiple lines,
     * you can set the "MaxWidths" property of the options object that you pass to
     * {@link MakeTable.Prototype.__New}. This will break up the text into multiple lines for cells
     * that exceed the maximum. Then, when you call {@link MakeTable.Prototype.GetHtml}, you can
     * set `Options.InnerLineSeparator` with a substring to separate those lines. A good option
     * is "<br>". An empty string is also an appropriate option.
     *
     * @param {String} [Options.LineSeparator = "`n"] - The literal string that separates each line
     * in the output string.
     *
     * @param {String} [Options.TableAttribute = ""] - Any attributes you want included with the
     * <table> element, e.g. "class=`"tbl-class`" border=`"1`"". Separate each individual attribute
     * with a space character.
     *
     * @param {String} [Options.TableStyle = ""] - The style attribute value that will be
     * included with the <table> elements. Only include the value that goes between the quotation
     * marks of the style attribute, e.g. "color:red;".
     *
     * @param {String|String[]|String[][]} [Options.TdAttribute = ""] - If a string, the attribute
     * that will be included with all <td> elements.
     *
     * If an array of strings, each index in the array corresponds to a row in the table (not
     * including headers) and that string is applied as the attributes for each cell in the row.
     * For example, index 1 is the first row after the headers.
     *
     * If an array of arrays of strings, each index of the outer array corresponds with a row in the
     * table (not including headers). For example, index 1 is the first row after the headers. Each
     * index of the inner array corresponds with a cell in that row. For example, index 1 is the
     * first cell in the row. The items of the inner array are strings that wil be applied as the
     * attributes for the corresponding cell.
     *
     * The arrays must have the correct number of items for the table content. If there are too few
     * items, an IndexError will occur.
     *
     * Separate each individual attribute with a space character.
     *
     * For example, these are each valid, assuming the table has 3 data rows and 3 columns:
     * @example
     * options := { TdAttribute: "class=`"td-class`"" }
     * options := { TdAttribute: [ "class=`"td-class-1`"", "class=`"td-class-2`"", "class=`"td-class-3`"" ] }
     * options := { TdAttribute: [
     *     [ "class=`"td-class-1-1`"", "class=`"td-class-1-2`"", "class=`"td-class-1-3`"" ]
     *   , [ "class=`"td-class-2-1`"", "class=`"td-class-2-2`"", "class=`"td-class-2-3`"" ]
     *   , [ "class=`"td-class-3-1`"", "class=`"td-class-3-2`"", "class=`"td-class-3-3`"" ]
     * ]}
     * @
     *
     * @param {String} [Options.TdStyle = ""] - If a string, the style attribute value that will be
     * included with all <td> elements. Only include the value that goes between the quotation marks
     * of the style attribute, e.g. "color:red;".
     *
     * If an array of strings, each index in the array corresponds to a row in the table (not
     * including headers) and that string is applied as the attributes for each cell in the row.
     * For example, index 1 is the first row after the headers.
     *
     * If an array of arrays of strings, each index of the outer array corresponds with a row in the
     * table (not including headers). For example, index 1 is the first row after the headers. Each
     * index of the inner array corresponds with a cell in that row. For example, index 1 is the
     * first cell in the row. The items of the inner array are strings that wil be used as the style
     * attribute value for the corresponding cell.
     *
     * The arrays must have the correct number of items for the table content. If there are too few
     * items, an IndexError will occur.
     *
     * For example, these are each valid, assuming the table has 3 data rows and 3 columns:
     * @example
     * options := { TdStyle: "color:red;" }
     * options := { TdStyle: [ "color:red;", "color:green;", "color:blue;" ] }
     * options := { TdStyle: [
     *     [ "color:red;", "color:green;", "color:blue;" ]
     *   , [ "color:blue;", "color:red;", "color:green;" ]
     *   , [ "color:green;", "color:blue;", "color:red;" ]
     * ]}
     * @
     *
     * @param {String|String[]} [Options.ThAttribute = ""] - If a string, the attribute
     * that will be included with all <th> elements.
     *
     * If an array of strings, each index in the array corresponds to an individual header.
     *
     * The arrays must have the correct number of items for the table content. If there are too few
     * items, an IndexError will occur.
     *
     * Separate each individual attribute with a space character.
     *
     * For example, these are each valid, assuming the table has a header row with 3 headers.
     * @example
     * options := { ThAttribute: "class=`"th-class`"" }
     * options := { ThAttribute: [ "class=`"th-class-1`"", "class=`"th-class-2`"", "class=`"th-class-3`"" ] }
     * @
     *
     * @param {String} [Options.ThStyle = ""] - If a string, the style attribute value that will be
     * included with all <th> elements. Only include the value that goes between the quotation marks
     * of the style attribute, e.g. "color:red;".
     *
     * If an array of strings, each index in the array corresponds to a row in the table (not including
     * headers).
     *
     * The arrays must have the correct number of items for the table content. If there are too few
     * items, an IndexError will occur.
     *
     * For example, these are each valid, assuming the table has a header row with 3 headers.
     * @example
     * options := { ThStyle: "color:red;" }
     * options := { ThStyle: [ "color:red;", "color:green;", "color:blue;" ] }
     * @
     *
     * @param {String} [Options.TrAttribute = ""] - If a string, the attribute
     * that will be included with all <tr> elements.
     *
     * If an array of strings, each index in the array corresponds to a row in the table (not including
     * headers).
     *
     * The arrays must have the correct number of items for the table content. If there are too few
     * items, an IndexError will occur.
     *
     * Separate each individual attribute with a space character.
     *
     * For example, these are each valid, assuming the table has 3 rows.
     * @example
     * options := { TrAttribute: "class=`"tr-class`"" }
     * options := { TrAttribute: [ "class=`"tr-class-1`"", "class=`"tr-class-2`"", "class=`"tr-class-3`"" ] }
     * @
     *
     * @param {String} [Options.TrStyle = ""] - If a string, the style attribute value that will be
     * included with all <tr> elements. Only include the value that goes between the quotation marks
     * of the style attribute, e.g. "color:red;".
     *
     * If an array of strings, each index in the array corresponds to a row in the table (not including
     * headers).
     *
     * The arrays must have the correct number of items for the table content. If there are too few
     * items, an IndexError will occur.
     *
     * For example, these are each valid, assuming the table has 3 rows.
     * @example
     * options := { TrStyle: "color:red;" }
     * options := { TrStyle: [ "color:red;", "color:green;", "color:blue;" ] }
     * @
     */
    GetHtml(Options?) {
        return MakeTable.GetHtml(this, Options ?? unset)
    }

    GetMarkdown(lineSeparator := '`n', innerLineSeparator := '') {
        headers := this[1]
        h := _ := ''
        VarSetStrCapacity(&h, 1024)
        VarSetStrCapacity(&_, 1024)
        h .= '|'
        _ .= '|'
        for cell in headers {
            h .= cell(innerLineSeparator) '|'
            _ .= '-|'
        }
        s := ''
        VarSetStrCapacity(&s, 1024 * this.Length)
        s .= h lineSeparator _
        i := 1
        loop this.Length - 1 {
            s .= lineSeparator '|'
            for cell in this[++i] {
                s .= cell(innerLineSeparator) '|'
            }
        }
        return s
    }

    /**
     * @classdesc - Handles the input options.
     */
    class Options {
        static __New() {
            this.DeleteProp('__New')
            proto := this.Prototype
            proto.AddHeaderSeparator := true
            proto.ColumnPadding := '`s`s'
            proto.InputColumnSeparator := '`t'
            proto.InputRowSeparator := '\R'
            proto.LinePrefix := ''
            proto.LineSuffix := ''
            proto.MaxWidths := ''
            proto.OutputColumnPrefix := ''
            proto.OutputColumnPrefixSkipFirstRow := false
            proto.OutputColumnSeparator := ''
            proto.OutputLineBetweenRows := false
            proto.OutputRowSeparator := '`n'
            proto.TrimCharacters := '`s'
            proto.TrimCharactersRow := ''
            proto.TrimCharactersCell := ''
        }

        __New(Options?) {
            if IsSet(options) {
                if IsSet(MakeTableConfig) {
                    for prop in MakeTable.Options.Prototype.OwnProps() {
                        if HasProp(options, prop) {
                            this.%prop% := options.%prop%
                        } else if HasProp(MakeTableConfig, prop) {
                            this.%prop% := MakeTableConfig.%prop%
                        }
                    }
                } else {
                    for prop in MakeTable.Options.Prototype.OwnProps() {
                        if HasProp(options, prop) {
                            this.%prop% := options.%prop%
                        }
                    }
                }
            } else if IsSet(MakeTableConfig) {
                for prop in MakeTable.Options.Prototype.OwnProps() {
                    if HasProp(MakeTableConfig, prop) {
                        this.%prop% := MakeTableConfig.%prop%
                    }
                }
            }
            if this.HasOwnProp('__Class') {
                this.DeleteProp('__Class')
            }
        }
    }

    class GetHtml {
        class Options {
            static __New() {
                this.DeleteProp('__New')
                proto := this.Prototype
                proto.IndentChar := '`s'
                proto.IndentLen := 2
                proto.InitialIndent := 0
                proto.InnerLineSeparator := ''
                proto.LineSeparator := '`n'
                proto.TableAttribute :=
                proto.TableStyle :=
                proto.TdAttribute :=
                proto.TdStyle :=
                proto.ThAttribute :=
                proto.ThStyle :=
                proto.TrAttribute :=
                proto.TrStyle :=
                ''
            }

            __New(Options?) {
                if IsSet(options) {
                    if IsSet(GetHtmlConfig) {
                        for prop in MakeTable.GetHtml.Options.Prototype.OwnProps() {
                            if HasProp(options, prop) {
                                this.%prop% := options.%prop%
                            } else if HasProp(GetHtmlConfig, prop) {
                                this.%prop% := GetHtmlConfig.%prop%
                            }
                        }
                    } else {
                        for prop in MakeTable.GetHtml.Options.Prototype.OwnProps() {
                            if HasProp(options, prop) {
                                this.%prop% := options.%prop%
                            }
                        }
                    }
                } else if IsSet(GetHtmlConfig) {
                    for prop in MakeTable.GetHtml.Options.Prototype.OwnProps() {
                        if HasProp(GetHtmlConfig, prop) {
                            this.%prop% := GetHtmlConfig.%prop%
                        }
                    }
                }
                if this.HasOwnProp('__Class') {
                    this.DeleteProp('__Class')
                }
            }
        }

        static Call(MakeTableObj, Options?) {
            options := MakeTable.GetHtml.Options(Options ?? unset)
            innerLineSeparator := options.InnerLineSeparator
            ; style tags
            if options.TrStyle && not options.TrStyle is Array {
                trStyle := MakeTable_ValueHelper(options.TrStyle)
            } else {
                trStyle := options.TrStyle
            }
            if options.ThStyle && not options.ThStyle is Array {
                thStyle := MakeTable_ValueHelper(options.ThStyle)
            } else {
                thStyle := options.ThStyle
            }
            if options.TdStyle {
                if options.TdStyle is Array {
                    tdStyle := []
                    loop tdStyle.Capacity := options.TdStyle.Length {
                        if options.TdStyle[A_Index] is Array {
                            tdStyle.Push(options.TdStyle[A_Index])
                        } else {
                            tdStyle.Push(MakeTable_ValueHelper(options.TdStyle[A_Index]))
                        }
                    }
                } else {
                    tdStyle := MakeTable_ValueHelper(MakeTable_ValueHelper(options.TdStyle))
                }
            } else {
                tdStyle := ''
            }
            ; Attribute html
            trAttribute := _ProcessOption(options.TrAttribute)
            thAttribute := _ProcessOption(options.ThAttribute)
            if options.TdAttribute {
                if options.TdAttribute is Array {
                    tdAttribute := []
                    loop tdAttribute.Capacity := options.TdAttribute.Length {
                        tdAttribute.Push(_ProcessOption(options.TdAttribute[A_Index]))
                    }
                } else {
                    tdAttribute := MakeTable_ValueHelper(MakeTable_ValueHelper(' ' options.TdAttribute))
                }
            } else {
                tdAttribute := MakeTable_ValueHelper(MakeTable_ValueHelper(''))
            }
            r := 0
            ind := MakeTable_IndentHelper(options.IndentLen, options.IndentChar)
            s := ''
            VarSetStrCapacity(&s, 2048 * MakeTableObj.Length)
            headers := MakeTableObj[1]
            indent := options.InitialIndent
            le := options.LineSeparator
            if options.TableStyle {
                if trStyle {
                    s .= ind[indent] '<table' (options.TableAttribute ? ' ' options.TableAttribute : '') ' style="' options.TableStyle '">' le ind[++indent] '<tr' trAttribute[1] ' style="' trStyle[++r] '">'
                } else {
                    s .= ind[indent] '<table' (options.TableAttribute ? ' ' options.TableAttribute : '') ' style="' options.TableStyle '">' le ind[++indent] '<tr' trAttribute[1] '>'
                }
            } else if trStyle {
                s .= ind[indent] '<table' (options.TableAttribute ? ' ' options.TableAttribute : '') '>' le ind[++indent] '<tr' trAttribute[1] ' style="' trStyle[++r] '">'
            } else {
                s .= ind[indent] '<table' (options.TableAttribute ? ' ' options.TableAttribute : '') '>' le ind[++indent] '<tr' trAttribute[1] '>'
            }
            ++indent
            if thStyle {
                for cell in headers {
                    s .= le ind[indent] '<th' thAttribute[A_Index] ' style="' thStyle[A_Index] '">' cell(innerLineSeparator) '</th>'
                }
            } else {
                for cell in headers {
                    s .= le ind[indent] '<th' thAttribute[A_Index] '>' cell(innerLineSeparator) '</th>'
                }
            }
            s .= le ind[--indent] '</tr>'
            i := 1
            if trStyle {
                if tdStyle {
                    loop MakeTableObj.Length - 1 {
                        s .= le ind[indent] '<tr' trAttribute[++r] ' style="' trStyle[r] '">'
                        c := 0
                        ++indent
                        for cell in MakeTableObj[++i] {
                            s .= le ind[indent] '<td' tdAttribute[r][++c] ' style="' tdStyle[r][c] '">' cell(innerLineSeparator) '</td>'
                        }
                        s .= le ind[--indent] '</tr>'
                    }
                } else {
                    loop MakeTableObj.Length - 1 {
                        s .= le ind[indent] '<tr' trAttribute[++r] ' style="' trStyle[r] '">'
                        c := 0
                        ++indent
                        for cell in MakeTableObj[++i] {
                            s .= le ind[indent] '<td' tdAttribute[r][++c] '>' cell(innerLineSeparator) '</td>'
                        }
                        s .= le ind[--indent] '</tr>'
                    }
                }
            } else if tdStyle {
                loop MakeTableObj.Length - 1 {
                    s .= le ind[indent] '<tr' trAttribute[++r] '>'
                    c := 0
                    ++indent
                    for cell in MakeTableObj[++i] {
                        s .= le ind[indent] '<td' tdAttribute[r][++c] ' style="' tdStyle[r][c] '">' cell(innerLineSeparator) '</td>'
                    }
                    s .= le ind[--indent] '</tr>'
                }
            } else {
                loop MakeTableObj.Length - 1 {
                    s .= le ind[indent] '<tr' trAttribute[++r] '>'
                    c := 0
                    ++indent
                    for cell in MakeTableObj[++i] {
                        s .= le ind[indent] '<td' tdAttribute[r][++c] '>' cell(innerLineSeparator) '</td>'
                    }
                    s .= le ind[--indent] '</tr>'
                }
            }
            s .= le ind[--indent] '</table>'
            return s

            _ProcessOption(value) {
                if value {
                    if value is Array {
                        result := []
                        loop result.Capacity := value.Length {
                            result.Push(' ' value[A_Index])
                        }
                        return result
                    } else {
                        return MakeTable_ValueHelper(' ' value)
                    }
                } else {
                    return MakeTable_ValueHelper('')
                }
            }
        }
    }
}

class MakeTable_ValueHelper {
    __New(Value) {
        this.Value := Value
    }
    __Item[*] {
        Get => this.Value
    }
}

class MakeTable_Row extends Array {
}

class MakeTable_Cell extends Array {
    Call(Separator := '') {
        s := ''
        if separator {
            for text in this {
                s .= text separator
            }
            return SubStr(s, 1, -StrLen(separator))
        } else {
            for text in this {
                s .= text
            }
            return s
        }
    }
}

/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/FillStr.ahk
    Author: Nich-Cebolla
    Version: 1.0.1
    License: MIT
*/

/**
 * @class
 * In this documentation an instance of `MakeTable_FillStr` is referred to as `Filler`.
 * MakeTable_FillStr constructs strings of the requested length out of the provided filler string. Multiple
 * `Filler` objects can be active at any time. It would technically be possible to use a single
 * `Filler` object and swap out the substrings on the property `Filler.Str`, but this is not
 * recommended because MakeTable_FillStr caches some substrings for efficiency, so you may not get the expected
 * result after swapping out the `Str` property.
 *
 * Internally, MakeTable_FillStr works by deconstructing the input integer into its base 10 components. It
 * constructs then caches the strings for components that are divisible by 10, then adds on the
 * remainder. This offers a balance between efficiency, flexibility, and memory usage.
 *
 * Since this is expected to be most frequently used to pad strings with surrounding whitespace,
 * the `MakeTable_FillStr` object is instantiated with an instance of itself using a single space character
 * as the filler string. This is available on the property `MakeTable_FillStr.S`, and can also be utilized using
 * `MakeTable_FillStr[Qty]` to output a string of Qty space characters.
 */
class MakeTable_FillStr {
    static __New() {
        this.S := MakeTable_FillStr(' ')
    }
    static __Item[Qty] {
        Get => Qty ? this.S[Qty] : ''
        Set => this.S.Cache.Set(Qty, value)
    }

    /**
     * @description - Constructs the offset string according to the input parameters.
     * @param {Integer} Len - The length of the output string.
     * @param {Integer} TruncateAction - Controls how the filler string `Filler.Str` is truncated when
     * `Len` is not evenly divisible by `Filler.Len`. The options are:
     * - 0: Does not truncate the filler string, and allows the width of the output string to exceed
     * `Len`.
     * - 1: Does not truncate the filler string, and does not allow the width of the output string to
     * exceed `Len`, sometimes resulting in the width being less than `Len`.
     * - 2: Does not truncate the filler string, and does not allow the width of the output string to
     * exceed `Len`, and adds space characters to fill the remaining space. The space characters are
     * added to the left side of the output string.
     * - 3: Does not truncate the filler string, and does not allow the width of the output string to
     * exceed `Len`, and adds space characters to fill the remaining space. The space characters are
     * added to the right side of the output string.
     * - 4: Truncates the filler string, and the truncated portion is on the left side of the output
     * string.
     * - 5: Truncates the filler string, and the truncated portion is on the right side of the output
     * string.
     */
    static GetOffsetStr(Len, TruncateAction, self) {
        Out := self[Floor(Len / self.Len)]
        if R := Mod(Len, self.Len) {
            switch TruncateAction {
                case 0: Out .= self[1]
                case 2: Out := MakeTable_FillStr[R] Out
                case 3: Out .= MakeTable_FillStr[R]
                case 4: Out := SubStr(self[1], self.Len - R + 1) Out
                case 5: Out .= SubStr(self[1], 1, R)
            }
        }
        return Out
    }

    /**
     * @description - Creates a new MakeTable_FillStr object, referred to as `Filler` in this documentation.
     * Use the MakeTable_FillStr instance to generate strings of repeating characters. For general usage,
     * see {@link MakeTable_FillStr#__Item}.
     * @param {String} Str - The string to repeat.
     * @example
        Filler := MakeTable_FillStr('-')
        Filler[10]                                  ; ----------
        Filler.LeftAlign('Hello, world!', 26)       ; Hello, world!-------------
        Filler.LeftAlign('Hello, world!', 26, 5)    ; -----Hello, world!--------
        Filler.CenterAlign('Hello, world!', 26)     ; -------Hello, world!------
        Filler.CenterAlign('Hello, world!', 26, 1)  ; -------Hello, world!------
        Filler.CenterAlign('Hello, world!', 26, 2)  ; ------Hello, world!-------
        Filler.CenterAlign('Hello, world!', 26, 3)  ; -------Hello, world!-------
        Filler.RightAlign('Hello, world!', 26)      ; -------------Hello, world!
        Filler.RightAlign('Hello, world!', 26, 5)   ; --------Hello, world!-----
     * @
     * @returns {MakeTable_FillStr} - A new MakeTable_FillStr object.
     */
    __New(Str) {
        this.Str := Str
        this.Cache := Map()
        Loop 10 {
            Out .= Str
        }
        this[10] := Out
        this.Len := StrLen(Str)
    }
    __Item[Qty] {
        /**
         * @description - Returns the string of the specified number of repetitions. The `Qty`
         * represents number of repetitions of `Filler.Str`.
         * @param {Integer} Qty - The number of repetitions.
         * @returns {String} - The string of the specified number of repetitions.
         */
        Get {
            if !Qty {
                return ''
            }
            cache := this.Cache
            s := this.Str
            Out := ''
            VarSetStrCapacity(&Out, Qty * this.Len)
            if cache.Has(Number(Qty)) {
                return cache[Number(Qty)]
            }
            r := Mod(Qty, 10)
            Loop r {
                Out .= s
            }
            Qty -= r
            if Qty {
                for n in StrSplit(Qty) {
                    if n = 0 {
                        continue
                    }
                    Tens := 1
                    Loop StrLen(Qty) - A_Index {
                        Tens *= 10
                    }
                    if cache.Has(Tens) {
                        Loop n {
                            Out .= cache.Get(Tens)
                        }
                    } else {
                        Loop n {
                            Out .= _Process(Tens)
                        }
                    }
                }
            }
            return Out

            _Process(Qty) {
                local Out
                Tenth := Integer(Qty / 10)
                if cache.Has(Tenth) {
                    Loop 10 {
                        Out .= cache.Get(Tenth)
                    }
                } else {
                    Out := _Process(Tenth)
                }
                cache.Set(Number(Qty), Out)
                return Out
            }
        }
        /**
         * @description - Sets the cache value of the indicated `Qty`. This can be useful in a
         * situation where you know you will be using a string of X length often, but X is not
         * divisible by 10. `MakeTable_FillStr` instances do not cache lengths unless they are divisible by
         * 10 to avoid memory bloat, but will still return a cached value if the input Qty exists in
         * the cache.
         */
        Set {
            this.Cache.Set(Number(Qty), value)
        }
    }

    /**
     * @description - Center aligns the string within a specified width. This method is compatible
     * with filler strings of any length.
     * @param {String} Str - The string to center align.
     * @param {Integer} Width - The width of the output string in number of characters.
     * @param {Number} [RemainderAction=1] - The action to take when the difference between the width
     * and the string length is not evenly divisible by 2.
     * - 0: Exclude the remainder.
     * - 1: Add the remainder to the left side.
     * - 2: Add the remainder to the right side.
     * - 3: Add the remainder to both sides.
     * @param {String} [Padding=' '] - The `Padding` value is added to the left and right side of
     * `Str` to create space between the string and the filler characters. To not use padding, set
     * it to an empty string.
     * @param {Integer} [TruncateActionLeft=1] - This parameter controls how the filler string
     * `Filler.Str` is truncated when the LeftOffset is not evenly divisible by the length of
     * `Filler.Str`. For a full explanation, see {@link MakeTable_FillStr.GetOffsetStr}.
     * @param {Integer} [TruncateActionRight=2] - This parameter controls how the filler string
     * `Filler.Str` is truncated when the remaining character count on the right side of the output
     * string is not evenly divisible by the length of `Filler.Str`. For a full explanation, see
     * {@link MakeTable_FillStr.GetOffsetStr}.
     */
    CenterAlignEx(Str, Width, RemainderAction := 1, Padding := ' ', TruncateActionLeft := 1, TruncateActionRight := 2) {
        Space := Width - StrLen(Str) - (LenPadding := StrLen(Padding) * 2)
        if Space < 1
            return Str
        Split := Floor(Space / 2)
        if R := Mod(Space, 2) {
            switch RemainderAction {
                case 0: LeftOffset := RightOffset := Split
                case 1: LeftOffset := Split + R, RightOffset := Split
                case 2: LeftOffset := Split, RightOffset := Split + R
                case 3: LeftOffset := RightOffset := Split + R
                default:
                    throw MethodError('Invalid RemainderAction.', -1, 'RemainderAction: ' RemainderAction)
            }
        } else
            LeftOffset := RightOffset := Split
        return MakeTable_FillStr.GetOffsetStr(LeftOffset, TruncateActionLeft, this) Padding Str Padding MakeTable_FillStr.GetOffsetStr(RightOffset, TruncateActionRight, this)
    }

    /**
     * @description - Center aligns a string within a specified width. This method is only compatible
     * with filler strings that are 1 character in length.
     * @param {String} Str - The string to center align.
     * @param {Number} Width - The width of the output string.
     * @param {Number} [RemainderAction=1] - The action to take when the difference between the width
     * and the string length is not evenly divisible by 2.
     * - 0: Exclude the remainder.
     * - 1: Add the remainder to the left side.
     * - 2: Add the remainder to the right side.
     * - 3: Add the remainder to both sides.
     * @returns {String} - The center aligned string.
     */
    CenterAlign(Str, Width, RemainderAction := 1) {
        Space := Width - StrLen(Str)
        r := Mod(Space, 2)
        Split := (Space - r) / 2
        switch RemainderAction {
            case 0: return this[Split] Str this[Split]
            case 1: return this[Split + r] Str this[Split]
            case 2: return this[Split] Str this[Split + r]
            case 3: return this[Split + r] Str this[Split + r]
            default:
                throw MethodError('Invalid RemainderAction.', -1, 'RemainderAction: ' RemainderAction)
        }
    }

    /** @description - Clears the cache. */
    ClearCache() => this.Cache.Clear()

    /**
     * @description - Left aligns a string within a specified width. This method is compatible with
     * filler strings of any length.
     * @param {String} Str - The string to left align.
     * @param {Integer} Width - The width of the output string in number of characters.
     * @param {Integer} [LeftOffset=0] - The offset from the left side in number of characters. The
     * offset is constructed by using the filler string (`Filler.Str`) value and repeating
     * it until the offset length is reached.
     * @param {String} [Padding=' '] - The `Padding` value is added to the left and right side of
     * `Str` to create space between the string and the filler characters. To not use padding, set
     * it to an empty string.
     * @param {Integer} [TruncateActionLeft=1] - This parameter controls how the filler string
     * `Filler.Str` is truncated when the LeftOffset is not evenly divisible by the length of
     * `Filler.Str`. For a full explanation, see {@link MakeTable_FillStr.GetOffsetStr}.
     * @param {Integer} [TruncateActionRight=2] - This parameter controls how the filler string
     * `Filler.Str` is truncated when the remaining character count on the right side of the output
     * string is not evenly divisible by the length of `Filler.Str`. For a full explanation, see
     * {@link MakeTable_FillStr.GetOffsetStr}.
     */
    LeftAlignEx(Str, Width, LeftOffset := 0, Padding := ' ', TruncateActionLeft := 1, TruncateActionRight := 2) {
        if LeftOffset + (LenStr := StrLen(Str)) + (LenPadding := StrLen(Padding) * 2) > Width
            LeftOffset := Width - LenStr - LenPadding
        if LeftOffset > 0
            Out .= MakeTable_FillStr.GetOffsetStr(LeftOffset, TruncateActionLeft, this)
        Out .= Padding Str Padding
        if (Remainder := Width - StrLen(Out))
            Out .= MakeTable_FillStr.GetOffsetStr(Remainder, TruncateActionRight, this)
        return Out
    }

    /**
     * @description - Left aligns a string within a specified width. This method is only compatible
     * with filler strings that are 1 character in length.
     * @param {String} Str - The string to left align.
     * @param {Number} Width - The width of the output string.
     * @param {Number} [LeftOffset=0] - The offset from the left side.
     * @returns {String} - The left aligned string.
     */
    LeftAlign(Str, Width, LeftOffset := 0) {
        if LeftOffset {
            if LeftOffset + StrLen(Str) > Width
                LeftOffset := Width - StrLen(Str)
            return this[LeftOffset] Str this[Width - StrLen(Str) - LeftOffset]
        }
        return Str this[Width - StrLen(Str)]
    }

    /**
     * @description - Right aligns a string within a specified width. This method is only compatible
     * with filler strings that are 1 character in length.
     * @param {String} Str - The string to right align.
     * @param {Number} Width - The width of the output string.
     * @param {Number} [RightOffset=0] - The offset from the right side.
     * @returns {String} - The right aligned string.
     */
    RightAlign(Str, Width, RightOffset := 0) {
        if RightOffset {
            if RightOffset + StrLen(Str) > Width
                RightOffset := Width - StrLen(Str)
            return this[Width - StrLen(Str) - RightOffset] Str this[RightOffset]
        }
        return this[Width - StrLen(Str)] Str
    }

    /**
     * @description - Right aligns a string within a specified width. This method is compatible with
     * filler strings of any length.
     * @param {String} Str - The string to right align.
     * @param {Integer} Width - The width of the output string in number of characters.
     * @param {Integer} [RightOffset=0] - The offset from the right side in number of characters. The
     * offset is constructed by using the filler string (`Filler.Str`) value and repeating
     * it until the offset length is reached.
     * @param {String} [Padding=' '] - The `Padding` value is added to the left and right side of
     * `Str` to create space between the string and the filler characters. To not use padding, set
     * it to an empty string.
     * @param {Integer} [TruncateActionLeft=1] - This parameter controls how the filler string
     * `Filler.Str` is truncated when the remaining character count on the left side of the output
     * string is not evenly divisible by the length of `Filler.Str`. For a full explanation, see
     * {@link MakeTable_FillStr.GetOffsetStr}.
     * @param {Integer} [TruncateActionRight=2] - This parameter controls how the filler string
     * `Filler.Str` is truncated when the RightOffset is not evenly divisible by the length of
     * `Filler.Str`. For a full explanation, see {@link MakeTable_FillStr.GetOffsetStr}.
     * @returns {String} - The right aligned string.
     */
    RightAlignEx(Str, Width, RightOffset := 0, Padding := ' ', TruncateActionLeft := 1, TruncateActionRight := 2) {
        if RightOffset + (LenStr := StrLen(Str)) + (LenPadding := StrLen(Padding) * 2) > Width
            RightOffset := Width - LenStr - LenPadding
        Out := Padding Str Padding
        if (Remainder := Width - StrLen(Out) - RightOffset)
            Out := MakeTable_FillStr.GetOffsetStr(Remainder, TruncateActionRight, this) Out
        if RightOffset > 0
            Out := MakeTable_FillStr.GetOffsetStr(RightOffset, TruncateActionLeft, this) Out
        return Out
    }
}


/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/IndentHelper.ahk
    Author: Nich-Cebolla
    Version: 1.0.0
    License: MIT
*/

class MakeTable_IndentHelper extends Array {
    static __New() {
        this.DeleteProp('__New')
        proto := this.Prototype
        proto.__IndentLen := ''
        proto.DefineProp('ItemHelper', { Call: Array.Prototype.GetOwnPropDesc('__Item').Get })
    }
    __New(IndentLen, IndentChar := '`s') {
        this.__IndentChar := IndentChar
        this.SetIndentLen(IndentLen)
    }
    Expand(Index) {
        s := this[1]
        loop Index - this.Length {
            this.Push(this[-1] s)
        }
    }
    Initialize() {
        c := this.__IndentChar
        this.Length := 1
        s := ''
        loop this.__IndentLen {
            s .= c
        }
        this[1] := s
        this.Expand(4)
    }
    SetIndentChar(IndentChar) {
        this.__IndentChar := IndentChar
        this.Initialize()
    }
    SetIndentLen(IndentLen) {
        this.__IndentLen := IndentLen
        this.Initialize()
    }

    __Item[Index] {
        Get {
            if Index {
                if Abs(Index) > this.Length {
                    this.Expand(Abs(Index))
                }
                return this.ItemHelper(Index)
            } else {
                return ''
            }
        }
    }
    IndentChar {
        Get => this.__IndentChar
        Set => this.SetIndentChar(Value)
    }
    IndentLen {
        Get => this.__IndentLen
        Set => this.SetIndentLen(Value)
    }
}
