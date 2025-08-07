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
     *    , ColumnPadding: '`s`s'       ; Adds two space characters on the left and right side of each column (default)
     *    , MaxWidths: ''               ; No maximum widths (default)
     *    , InputRowSeparator: '\R'     ; Rows are separated by line break characters (default)
     *    , InputColumnSeparator: '`t'  ; Columns are separated by tab characters in the input text (default)
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
     *    , ColumnPadding: '`s`s'       ; Adds two space characters on the left and right side of each column (default)
     *    , MaxWidths: ''               ; No maximum widths (default)
     *    , InputRowSeparator: '\R'     ; Rows are separated by line break characters (default)
     *    , InputColumnSeparator: '`t'  ; Columns are separated by tab characters in the input text (default)
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
     * @param {Integer[]} [Options.MaxWidths = ""] - If in use, `Options.MaxWidths` is an array of
     * integers which define the maximum allowable width per column. If the text in a cell exceeds the
     * maximum, `MakeTable` breaks the text into multiple lines.
     * @param {String} [Options.OutputColumnSeparator = ""] - The literal string that is used to
     * separate cells.
     * @param {String} [Options.OutputRowSeparator = "`n"] - The literal string that is used to
     * separate rows.
     * @param {String} [Options.TrimCharacters = "`s"] - The value passed to the third parameter
     * of `StrSplit` when breaking the input text into the individual cells.
     * {@link https://www.autohotkey.com/docs/v2/lib/StrSplit.htm}
     *
     * @param {VarRef} [OutRowLines] - A variable that will receive an array of integers that
     * represent the number of lines each row occupies. This only has significance when
     * `Options.MaxWidths` is used.
     *
     * @param {VarRef} [OutWidths] - A variable that will receive an array of integers that represent
     * the actual width of each column.
     *
     * @returns {String}
     *
     * @class
     */
    static Call(Str?, Options?, &OutRowLines?, &OutWidths?) {
        Options := this.Options(Options ?? {})
        if !IsSet(Str) {
            Str := A_Clipboard
        }
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
        OutWidths := []
        OutWidths.Default := 0
        OutRowLines := []
        OutRowLines.Default := 1
        rows := []
        rows.Capacity := lines.Length
        maxWidths := Options.MaxWidths
        if maxWidths {
            Measure := _Measure1
        } else {
            Measure := _Measure2
        }
        r := 0
        padLen := StrLen(Options.ColumnPadding)
        loop lines.Length {
            ++r
            OutRowLines.Push(1)
            rows.Push(StrSplit(lines[r], inputColumnSeparator, Options.TrimCharacters))
            OutWidths.Length := Max(OutWidths.Length, rows[r].Length)
            c := 0
            loop rows[r].Length {
                ++c
                Measure()
            }
        }
        r := 0
        prefix := Options.LinePrefix
        pad := Options.ColumnPadding
        sep := Options.OutputColumnSeparator
        le := Options.OutputRowSeparator
        suffix := Options.LineSuffix
        table := ''
        loop rows.Length {
            ++r
            if r == 2 && Options.AddHeaderSeparator {
                filler := FillStr('-')
                table .= prefix
                for width in OutWidths {
                    if A_Index > 1 {
                        table .= filler[padLen]
                    }
                    table .= filler[width]
                    if A_Index < OutWidths.Length {
                        table .= filler[padLen] sep
                    }
                }
                table .= suffix le
            }
            k := 0
            loop OutRowLines[r] {
                ++k
                table .= prefix
                c := 0
                loop rows[r].Length {
                    ++c
                    if c > 1 {
                        table .= pad
                    }
                    if rows[r][c].Length >= k {
                        table .= rows[r][c][k]
                        diff := OutWidths[c] - StrLen(rows[r][c][k])
                        if diff > 0 {
                            table .= FillStr[diff]
                        }
                    } else {
                        table .= FillStr[OutWidths[c]]
                    }
                    if c == rows[r].Length {
                        table .= suffix le
                    } else {
                        table .= pad sep
                    }
                }
            }
        }

        return SubStr(table, 1, -StrLen(le))

        _Measure1() {
            maxWidth := maxWidths[c] - (c > 1 ? padLen * 2 : padLen)
            if r == 13 && c == 3 {
                sleep 1
            }
            if StrLen(rows[r][c]) > maxWidth {
                p := 1
                items := []
                loop {
                    if pos := InStr(s1 := SubStr(rows[r][c], p, maxWidth), ' ', , , -1) {
                        items.Push(s2 := SubStr(rows[r][c], p, pos - 1))
                        p += pos
                    } else {
                        items.Push(SubStr(rows[r][c], p, maxWidth))
                        p += maxWidth
                    }
                    if p + maxWidth >= StrLen(rows[r][c]) {
                        items.Push(SubStr(rows[r][c], p))
                        break
                    }
                }
                OutRowLines[r] := Max(OutRowLines[r], items.Length)
                rows[r][c] := items
                OutWidths[c] := maxWidth
            } else {
                rows[r][c] := [rows[r][c]]
                OutWidths[c] := Max(StrLen(rows[r][c][1]), OutWidths[c])
            }
        }
        _Measure2() {
            rows[r][c] := [rows[r][c]]
            OutWidths[c] := Max(StrLen(rows[r][c][1]), OutWidths[c])
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
          , OutputColumnSeparator: ''
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
