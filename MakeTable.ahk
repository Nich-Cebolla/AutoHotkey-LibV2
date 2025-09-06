/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/Win32/MakeTable.ahk
    Author: Nich-Cebolla
    License: MIT
*/

; https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/FillStr.ahk
#include <FillStr>

class MakeTable {
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
     * @param {Boolean} [Options.AddHeaderSeparator = true] - If true, adds a separator between
     * the first row and second row.
     * @param {String} [Options.ColumnPadding = "`s`s"] - The literal string that is added to the
     * left and right sight of every column, EXCEPT the left side of the first column and the right
     * side of the last column.
     * @param {String} [Options.InputColumnSeparator = "`t"] - A RegEx pattern that identifies the
     * boundary between columns.
     * @param {String} [Options.InputRowSeparator = "\R"] - A RegEx pattern that identifies the
     * boundary between rows.
     * @param {String} [Options.LinePrefix = ""] - The literal string that is added before every line.
     * @param {String} [Options.LineSuffix = ""] - The literal string that is added after every line.
     * @param {Integer|Integer[]} [Options.MaxWidths = ""] - If in use, `Options.MaxWidths` is an array of
     * integers which define the maximum allowable width per column. If the text in a cell exceeds the
     * maximum, `MakeTable` breaks the text into multiple lines. If `Options.MaxWidths` is an integer,
     * that value is applied as the max width of all columns.
     * @param {String[]} [Options.OutputColumnPrefix = ""] - Used to specify strings that prefixe
     * columns. The difference between `Options.OutputColumnPrefix` and `Options.OutputColumnSeparator`
     * is that `Options.OutputColumnSeparator` is applied to all columns, whereas
     * `Options.OutputColumnPrefix` is used to linePrefix every line of a specific column with a specific
     * string. The value of this option, if used, should be an array of strings. The indices of the
     * array are associated with the column index that is to be prefixed by the string at that index.
     * For example, if I have a table that is three columns, and I want to linePrefix each line of the
     * third column with "; ", then I would set `Options.ColumnPrefix := ["", "", "; "]`. I added
     * this option with the intent of using it to comment out portions of text when using `MakeTable`
     * to generate pretty-formatted code.
     * @param {Boolean} [Options.OutputColumnPrefixSkipFirstRow = false] - If true, the first
     * line is not affected by `Options.OutputColumnPrefix`.
     * @param {String} [Options.OutputColumnSeparator = ""] - The literal string that is used to
     * separate cells.
     * @param {Boolean} [Options.OutputLineBetweenRows = false] - If true, there will be an extra line
     * separating the rows. The line will look just like the header separator seen in the above
     * examples.
     * @param {String} [Options.OutputRowSeparator = "`n"] - The literal string that is used to
     * separate rows.
     * @param {String} [Options.TrimCharacters = "`s"] - The value passed to the third parameter
     * of `StrSplit` when breaking the input text into the individual cells.
     * {@link https://www.autohotkey.com/docs/v2/lib/StrSplit.htm}
     *
     * @param {VarRef} [OutTable] - A variable that will receive an array of arrays of arrays of
     * strings. Each item of the external array represents a row in the table. Each item of the
     * row-arrays represents a column in the table. Each item of the column-arrays represent a line
     * of text for that column for that row. If `Options.MaxWidths` is not in use, then the length
     * of the text-arrays is always 1 (no cells are broken into multiple lines). Accessing a string
     * value in the array looks like this:
     * @example
     *  ; Assume `inputStr` and `options` are appropriately defined.
     *  str := MakeTable(inputStr, options, &tbl)
     *  r := 1 ; row index
     *  c := 1 ; column index
     *  k := 1 ; text index
     *  text := tbl[r][c][k]
     * @
     *
     * @param {VarRef} [OutRowLines] - A variable that will receive an array of integers that
     * represent the number of lines each row occupies. This only has significance when
     * `Options.MaxWidths` is used.
     *
     * @returns {String}
     *
     * @class
     */
    static Call(Str?, Options?, &OutTable?, &OutRowLines?) {
        Options := this.Options(Options ?? {})
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
        inputColumnSeparator := Chr(n2)
        Str := RegExReplace(RegExReplace(Str, Options.InputColumnSeparator, inputColumnSeparator), Options.InputRowSeparator, Chr(n))
        lines := StrSplit(Str, Chr(n), Options.TrimCharacters)

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
            columnPrefix := MakeTableValueHelper('')
            columnPrefixLen := MakeTableValueHelper(0)
        }

        columnPadding := Options.ColumnPadding
        columnPaddingLen := StrLen(columnPadding)
        maxWidths := Options.MaxWidths
        if IsNumber(maxWidths) {
            maxWidths := MakeTableValueHelper(maxWidths)
        }
        if maxWidths {
            Measure := _Measure1
        } else {
            Measure := _Measure2
        }

        columnWidths := []
        columnWidths.Default := 0
        OutRowLines := []
        OutRowLines.Default := 1
        OutTable := []
        OutTable.Capacity := lines.Length
        r := 0
        loop lines.Length {
            ++r
            OutRowLines.Push(1)
            OutTable.Push(StrSplit(lines[r], inputColumnSeparator, Options.TrimCharacters))

            ; Ensures the length of the arrays are equal to the number of columns in the table
            if OutTable[r].Length > columnWidths.Length {
                columnWidths.Length := OutTable[r].Length
            }
            if columnPrefix is Array {
                columnPrefix.Length := columnPrefixLen.Length := columnWidths.Length
            }

            c := 0
            loop OutTable[r].Length {
                ++c
                Measure()
            }
        }
        r := 0
        loop lines.Length {
            ++r
            if OutTable[r].Length < columnWidths.Length {
                loop columnWidths.Length - OutTable[r].Length {
                    OutTable[r].Push([''])
                }
            }
        }
        r := 0
        linePrefix := Options.LinePrefix
        columnSeparator := Options.OutputColumnSeparator
        le := Options.OutputRowSeparator
        lineSuffix := Options.LineSuffix
        filler := FillStr('-')
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
        loop OutTable.Length {
            ++r
            if (outputLineBetweenRows && r > 1) || (r == 2 && addHeaderSeparator) {
                table .= lineBetweenRows
            }
            k := 0
            loop OutRowLines[r] {
                ++k
                table .= linePrefix
                c := 0
                loop OutTable[r].Length {
                    ++c
                    if c > 1 {
                        table .= columnPadding
                    }
                    if OutTable[r][c].Length >= k {
                        if !columnPrefixSkipFirstLine || r > 1 {
                            table .= columnPrefix[c]
                            table .= OutTable[r][c][k]
                            diff := columnWidths[c] - StrLen(OutTable[r][c][k])
                            if diff > 0 {
                                table .= FillStr[diff]
                            }
                        } else {
                            table .= OutTable[r][c][k]
                            diff := columnWidths[c] - StrLen(OutTable[r][c][k]) + columnPrefixLen[c]
                            if diff > 0 {
                                table .= FillStr[diff]
                            }
                        }
                    } else {
                        table .= FillStr[columnWidths[c] + columnPrefixLen[c]]
                    }
                    if c == OutTable[r].Length {
                        table .= lineSuffix le
                    } else {
                        table .= columnPadding columnSeparator
                    }
                }
            }
        }

        return SubStr(table, 1, -StrLen(le))

        _Measure1() {
            if !columnPrefixSkipFirstLine || r > 1 {
                maxWidth := maxWidths[c] - (c > 1 ? columnPaddingLen * 2 : columnPaddingLen) - columnPrefixLen[c]
            } else {
                maxWidth := maxWidths[c] - (c > 1 ? columnPaddingLen * 2 : columnPaddingLen)
            }
            if StrLen(OutTable[r][c]) > maxWidth {
                p := 1
                items := []
                loop {
                    if pos := InStr(s1 := SubStr(OutTable[r][c], p, maxWidth), ' ', , , -1) {
                        items.Push(s2 := SubStr(OutTable[r][c], p, pos - 1))
                        p += pos
                    } else {
                        items.Push(SubStr(OutTable[r][c], p, maxWidth))
                        p += maxWidth
                    }
                    if p + maxWidth >= StrLen(OutTable[r][c]) {
                        items.Push(SubStr(OutTable[r][c], p))
                        break
                    }
                }
                OutRowLines[r] := Max(OutRowLines[r], items.Length)
                OutTable[r][c] := items
                columnWidths[c] := maxWidth
            } else {
                OutTable[r][c] := [OutTable[r][c]]
                columnWidths[c] := Max(StrLen(OutTable[r][c][1]), columnWidths[c])
            }
        }
        _Measure2() {
            OutTable[r][c] := [OutTable[r][c]]
            columnWidths[c] := Max(StrLen(OutTable[r][c][1]), columnWidths[c])
        }
    }
    /**
     * @classdesc - Handles the input options.
     */
    class Options {
        static Default := {
            AddHeaderSeparator: true
            , ColumnPadding: '`s`s'
            , InputColumnSeparator: '`t'
            , InputRowSeparator: '\R'
            , LinePrefix: ''
            , LineSuffix: ''
            , MaxWidths: ''
            , OutputColumnPrefix: ''
            , OutputColumnPrefixSkipFirstRow: false
            , OutputColumnSeparator: ''
            , OutputLineBetweenRows: false
            , OutputRowSeparator: '`n'
            , TrimCharacters: '`s'
        }

        /**
         * @description - Sets the base object such that the values are used in this priority order:
         * - 1: The input object.
         * - 2: The configuration object (if present).
         * - 3: The default object.
         * @param {Object} Options - The input object.
         * @return {Object} - The same input object.
         */
        static Call(Options) {
            if IsSet(MakeTableConfig) {
                ObjSetBase(MakeTableConfig, MakeTable.Options.Default)
                ObjSetBase(Options, MakeTableConfig)
            } else {
                ObjSetBase(Options, MakeTable.Options.Default)
            }
            return Options
        }
    }
}

class MakeTableValueHelper {
    __New(Value) {
        this.Value := Value
    }
    __Item[index] {
        Get => this.Value
    }
}
