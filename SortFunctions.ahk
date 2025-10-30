/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/SortFunctions.ahk
    Author: Nich-Cebolla
    Version: 1.0.3
    License: MIT
*/
#SingleInstance force
#Include *i %A_AppData%\SortFunctions\SortFunctionsConfig.ahk
#Include *i %A_WorkingDir%\SortFunctionsConfig.ahk
#Include *i <GuiResizer_V1.0.0>
; https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/GuiResizer.ahk
#Include <MenuBarConstructor>
; https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/MenuBarConstructor.ahk

if A_ScriptFullpath == A_LineFile && !A_IsCompiled {
    SortFunctions()
}

/**
 * @class
 * @description - `SortFunctions` is a class that sorts function and property definition statements
 * into order. By default, they are sorted into alphabetical order, but you can provide a callback
 * function to use to perform custom sorting. The content that is sorted is split into four groups:
 * - Properties
 * - Static properties
 * - Functions
 * - Static functions
 *
 * Each group is sorted individually. The class also provides a GUI for sorting text, and the GUI
 * has options to save the configuration to the working directory or to the AppData directory.
 *
 * Limitations:
 * - If a comment exists between function / property definitions, it is lost when sorting and would
 * need to be added back afterward. Comments are only preserved in these contexts:
 *   - If the comment is within the body of a statement, it is preserved.
 *   - If the comment is a Jsdoc-style comment directly above a statement, it is preserved.
 */
class SortFunctions {
    /**
     * @class
     * @description - The default values to use when a configuration file is not in use.
     */
    class Default {
        static AddToClipboard := true
        , CR := false
        , Hotkey := ''
        , LinesBetween := 1
        , LF := true
        , Path := ''
        , SaveWorking := false
        , SaveAppData := false
        , SaveOnExit := false
        , SortOptions := ''
        , SortOrder := 'SF SP F P'
        , SortStyle := 1
    }

    /**
     * @property {String} rChar - The "Object Replacement Character". Used as the indicator
     * for replacement strings.
     */
    static rChar := Chr(0xFFFC)

    /**
     * @description - Constructs the Gui window.
     * @param {Object} [Config] - A configuration object. The object can have the following properties:
     * - **AddToClipboard**: A boolean value indicating whether the sorted text should be added to
     * the clipboard.
     * - **CR**: A boolean value indicating whether the carriage return character should be included
     * in the copied text.
     * - **Hotkey**: A string containing the hotkey to use for sorting.
     * - **LF**: A boolean value indicating whether the line feed character should be included in the
     * copied text.
     * - **Path**: A string containing the path to the file to sort.
     * - **SaveWorking**: A boolean value indicating whether the configuration should be saved to the
     * working directory.
     * - **SaveAppData**: A boolean value indicating whether the configuration should be saved to the
     * AppData directory.
     * - **SaveOnExit**: A boolean value indicating whether the configuration should be saved on exit.
     * - **SortOptions**: A string containing the options to use for sorting.
     * - **SortOrder**: A string containing the order in which to sort the properties. The string
     * should contain the following abbreviations:
     *   - **SF**: Static functions
     *   - **SP**: Static properties
     *   - **F**: Functions
     *   - **P**: Properties
     * - **SortStyle**: An integer value indicating the style of sorting to use. The default is 1.
     * @param {Func} [Callback] - The callback function for custom sorting. The callback function
     * will receive two parameters:
     * - The `Containers` object which has four properties
     * { Functions, StaticFunctions, Properties, StaticProperties }. Each property is a map object,
     * where the key is the function or property name, and the value is a string containing
     * the content of that statement. If a Jsdoc comment was above the statement, the Jsdoc's
     * replacement string is included in the content.
     * - The `Removed` object, which also has four properties
     * { Comment, Continuation, Jsdoc, String }. Each property is an array of objects. Each object
     * contains two properties:
     *  - **Match**: The `RegExMatchInfo` object.
     * - **Replacement**: The replacement string.
     *
     * The callback function does not need to return a value. It is expected the callback function
     * will construct its own string, and so no further processing would be needed from the built-in
     * process. To replace the removed strings with their original text, you can call `ReplaceStrings`.
     */
    static Call(Config?, Callback?) {
        Config := this.Config := Config ?? SortFunctions_Config_AppData ?? SortFunctions_Config_Working ?? {}
        ObjSetBase(Config, SortFunctions.Default)
        G := this.G := Gui('+Resize')
        G.Add('Button', 'Section vCopy', 'Copy').OnEvent('Click', _Copy)
        G.Add('Checkbox', 'ys vCR', 'CR')
        G.Add('Checkbox', 'ys vLF', 'LF')
        G.Add('Button', 'ys vSort', 'Sort').OnEvent('Click', _Sort)
        G.Add('Checkbox', 'ys vAddToClipboard', 'Add to Clipboard')
        G.Add('Text', 'ys vTxtHotkey', 'Hotkey: ')
        G.Add('Edit', 'ys w30 vHotkey')
        G.Add('Button', 'ys vApplyHotkey', 'Apply Hotkey').OnEvent('Click', _ApplyHotkey)
        G.Add('Text', 'ys vTxtSortStyle', 'Sort style: ')
        G.Add('Edit', 'ys w30 vSortStyle')
        G.Add('Text', 'ys vTxtSortOptions', 'Sort options: ')
        G.Add('Edit', 'ys w50 vSortOptions')
        G.Add('Text', 'ys vTxtLinesBetween', 'Lines between: ')
        G.Add('Edit', 'ys w50 vLinesBetween')
        G.Add('Text', 'xs Section vTxtPath', 'Input Path: ')
        G.Add('Edit', 'ys w500 vPath')
        G.Add('Button', 'ys vChoose', 'Choose')
        G.Add('Text', 'ys vTxtSortOrder', 'Sort order: ')
        G.Add('Edit', 'ys w100 vSortOrder')
        G.Add('Edit', 'xs w1000 r30 -wrap +Hscroll vDisplay')
        Menus := [
            ['File', 'Exit', (*) => ExitApp()],
            ['Options'
                , 'Save to working directory', _MenuOptions
                , 'Save to AppData', _MenuOptions
                , 'Save on exit', _MenuOptions
                , 'Save config now', _MenuSaveNow
                , 'Open config directory', _MenuOpenConfigDir
            ]
            ; ['Help', 'About', _MenuAbout, 'Help info', _MenuHelp]
        ]
        G.MenuBar := MenuBarConstructor(Menus, &MenuObjects)
        this.Menus := MenuObjects
        mOptions := MenuObjects.Get('Options')
        if Config.SaveAppData {
            mOptions.Check('Save to AppData')
        }
        if Config.SaveWorking {
            mOptions.Check('Save to working directory')
        }
        if Config.SaveOnExit {
            mOptions.Check('Save on exit')
            this.SaveOnExit(true)
        }

        if IsSet(GuiResizer) {
            G['Display'].Resizer := { W: 1, H: 1 }
            GuiResizer(G)
        }

        G['Copy'].GetPos(, &cy1, , &ch)
        Mid1 := cy1 + ch * 0.5
        G['Path'].GetPos(, &cy2, , &ch)
        Mid2 := cy2 + ch * 0.5
        for Ctrl in G {
            if Ctrl.Type == 'CheckBox' {
                _Align(Ctrl)
                Ctrl.Value := Config.%Ctrl.Name%
            } if Ctrl.Type == 'Text' {
                _Align(Ctrl)
            }
        }
        G['Hotkey'].Text := Config.Hotkey
        G['LinesBetween'].Text := Config.LinesBetween
        G['Path'].Text := Config.Path
        G['SortOptions'].Text := Config.SortOptions
        G['SortOrder'].Text := Config.SortOrder
        G['SortStyle'].Text := Config.SortStyle
        if !this.HasOwnProp('Hotkey') {
            this.Hotkey := Config.Hotkey
            if G['Hotkey'].Text
                _ApplyHotkey(G['Hotkey'])
        }
        this.Callback := Callback ?? ''

        G.Show()
        return

        _Align(Ctrl) {
            Ctrl.GetPos(, &cy, , &ch)
            if cy == cy1 {
                Ctrl.Move(, cy + Mid1 - (cy + ch * 0.5))
            } else if cy == cy2 {
                Ctrl.Move(, cy + Mid2 - (cy + ch * 0.5))
            } else {
                throw ValueError('Unexpected ``cy`` value.', -1, cy)
            }
        }
        _ApplyHotkey(Ctrl, *) {
            G := Ctrl.Gui
            if this.Hotkey {
                Previous := this.Hotkey
                Hotkey(this.Hotkey, _Sort, 'Off')
            }
            this.Hotkey := G['Hotkey'].Text
            if this.Hotkey {
                try
                    Hotkey(this.Hotkey, _Sort, 'On')
                catch
                    MsgBox('Invalid hotkey: ' this.Hotkey)
                this.ShowTooltip('Hotkey "' this.Hotkey '" applied!')
            } else {
                if IsSet(Previous)
                    this.ShowTooltip('Hotkey "' Previous '" removed!')
            }
        }
        _Choose(Ctrl, *) {
            Ctrl.Gui['Path'].Text := FileSelect()
        }
        _Copy(*) {
            this.Copy()
            this.ShowTooltip('Copied!')
        }
        _MenuOpenConfigDir(ItemName, ItemPos, MenuObj) {
            Flag := 0
            if Config.SaveWorking {
                this.OpenConfigDir('Working')
                Flag := 1
            }
            if Config.SaveAppData {
                if Flag {
                    sleep 500
                }
                this.OpenConfigDir('AppData')
                Flag := 1
            }
            this.ShowTooltip(Flag ? 'Opening!' : 'Please check one of the boxes!')
        }
        _MenuOptions(ItemName, ItemPos, MenuObj) {
            static MenuItems := Map('Save to working directory', 'SaveWorking'
            , 'Save to AppData', 'SaveAppData', 'Save on exit', 'SaveOnExit')
            mOptions := this.Menus.Get('Options')
            Prop := MenuItems.Get(ItemName)
            Config.%Prop% := !Config.%Prop%
            if Config.%Prop% {
                mOptions.Check(ItemName)
            } else {
                mOptions.Uncheck(ItemName)
                if Prop == 'SaveWorking' && FileExist(A_WorkingDir '\SortFunctionsConfig.ahk') {
                    if MsgBox('Delete current file? Path: ' A_WorkingDir '\SortFunctionsConfig.ahk', 'Delete?', 'YN') == 'Yes'
                        FileDelete(A_WorkingDir '\SortFunctionsConfig.ahk')
                } else if Prop == 'SaveAppData' && DirExist(A_AppData '\SortFunctions') {
                    if MsgBox('Delete folder? Path: ' A_AppData '\SortFunctions', 'Delete?', 'YN') == 'Yes'
                        DirDelete(A_AppData '\SortFunctions', 1)
                }
            }
            if ItemName == 'Save on exit' {
                this.SaveOnExit(Config.SaveOnExit)
            }
        }
        _MenuSaveNow(ItemName, ItemPos, MenuObj) {
            Flag := 0
            if Config.SaveWorking {
                this.WriteConfig('Working')
                Flag := 1
            }
            if Config.SaveAppData {
                this.WriteConfig('AppData')
                Flag := 1
            }
            this.ShowTooltip(Flag ? 'Saved!' : 'Please check one of the boxes!')
        }
        _SaveOnExit(Ctrl, *) {
            this.SaveOnExit(Ctrl.Value)
            this.ShowTooltip('Save on exit ' (Ctrl.Value ? 'enabled!' : 'disabled!'))
        }
        _Sort(Ctrl, *) {
            G := Ctrl.Gui
            this.Sort(, G['Path'].Text || unset, G['SortStyle'].Text || unset
            , G['SortOptions'].Text || unset, G['SortOrder'].Text || unset, , G['LinesBetween'].Text)
        }
    }

    /**
     * @description - Adds the content of the `Display` edit control to the clipboard, replaceing
     * the line endings with the indicated characters.
     */
    static Copy() {
        G := this.G
        le := ''
        if G['CR'].Value {
            le .= '`r'
        }
        if G['LF'].Value {
            le .= '`n'
        }
        A_Clipboard := SubStr(RegExReplace(G['Display'].Text, '\R', le), 1, -StrLen(le))
    }

    /**
     * @description - Returns an array of property names in the indicated order.
     * @returns {Array} - An array of property names.
     */
    static GetSortOrder(SortOrder) {
        Props := Map('SF', 'StaticFunctions', 'SP', 'StaticProperties'
        , 'F', 'Functions', 'P', 'Properties')
        Order := []
        Order.Capacity := 4
        for Str in StrSplit(this.G['SortOrder'].Text, ' ') {
            Order.Push(Props[Str])
            Props.Delete(Str)
        }
        if Props.Count {
            for Abbr, Prop in Props {
                Order.Push(Prop)
            }
        }
        return Order
    }

    /**
     * @description - `HandleContinuation` is a parsing function for use with AHK code. It takes a
     * a string input which is expected to be AHK code, and also a `RegExMatchInfo` object that
     * has a subcapture group consisting of just the text following the assignment / arrow operator
     * of a function or property definition statement. `HandleContinuation` will analyze the subcapture
     * group along with subsequent lines. If the lines are joined by a continuation operator or bracket,
     * this function will concatenate the related lines into a single string.
     * - **Note** that, in this description and in the code, "Body" refers to the text content that follows
     * the arrow function operator or assignment operator, including the entire continuation section.
     * - **Limitations**:
     *   - If any quoted strings or comments contain a bracket that does not have its closing pair nearby,
     * the string may need to be removed prior to calling `HandleContinuation`.
     *   - The function is not designed to handle string continuation sections as described here:
     * {@link https://www.autohotkey.com/docs/v2/Scripts.htm#continuation-section}.
     * @param {VarRef} Text - The text to search. `Text` is expected to be AHK code. `Text` can be
     * the entire code source / script that is being analyzed, but if that content is particularly large,
     * you can narrow the input by following these guidelines:
     * - The beginning of `Text` can be the same as the beginning of the `Match` object (second parameter).
     * - The end of `Text` should encompass enough lines of code to be certain that, if a continuation
     * section is present at the position of `Match.Pos[Subgroup]`, the entire continuation section
     * is included in `Text`.
     * @param {RegExInfo} Match - The RegEx match object. Minimally, the match object needs to have
     * these characteristics:
     * - The object has a subcapture group that contains a single line of code.
     * - The subcapture group is a property or function definition statement that has an assignment
     * operator or arrow function operator. This function does not work with definition statements
     * that are bracketed; getting that content is comparatively much easier.
     *
     * If you aren't sure where to begin drafting a pattern that will work with this function, the
     * below pattern will match with any function definition or property definition statement which
     * use an arrow function operator. Both statements will include several subcapture groups:
     * - **indent**: The indent prior to the statement, if any.
     * - **static**: The `static` keyword, if present.
     * - **name**: The name of the function or property.
     * - **params**: The parameters of the function or property, if present. The encompassing brackets
     * are included in the subcapture group.
     * - **arrow**: The arrow function operator (=>).
     * - **body**: The line of code following the arrow function operator. This is the subgroup that is
     * expected to be passed to this function.
     *
     * Also included is a `Mark` which you can use to determine if a property was matched or if a
     * class method / function was matched. Example: `if Match.Mark == 'func'`.
     * @example
     * PatternStatement := (
     *      'iJm)'
     *      '^(?<indent>[ \t]*)'
     *      '(?<static>static\s+)?'
     *      '(?<name>[a-zA-Z0-9_]+)'
     *      '(?:'
     *          '(?<params>\(([^()]++|(?&params))*\))(*MARK:func)'
     *          '|'
     *          '(?<params>\[(?:[^\][]++|(?&params))*\])?'
     *      ')'
     *      '\s*'
     *      '(?<arrow>=>)'
     *      '(?<body>.+)'
     *  )
     * @
     * @param {String} [Operator] - The initial operator used, i.e. an assignment operator or an arrow
     * function operator (=>). When provided, this allows the function to combine the body text with
     * the preceding text included in the input match. When not provided, the function only returns
     * the body text, in which case `OutBody` is the same as the return value, and `OutLen` receives
     * the same value as `OutLenBody`.
     * @param {String} [Subgroup='body'] - The name of the subgroup that captures the line of text with
     * the continuation operator, as described in the description and in the parameter hint for `Match`.
     * @param {VarRef} [OutPosEnd] - A variable that will receive the ending position of the match
     * relative to Text.
     * @param {VarRef} [OutLen] - If `Operator` is defined, this will receive the length of the entire
     * content string including input match and the result of this function. If `Operator` is not defined,
     * this will receive the length of the result of this function, which will be the same as `OutLenBody`.
     * @param {VarRef} [OutBody] - A variable that will receive the portion of text that occurs
     * after the initial operator, beginning with the text contained in the input match's subgroup.
     * If `Operator` is not defined, this is the same as the return value.
     * @param {VarRef} [OutLenBody] - A variable that will receive the length of `OutBody`.
     * @returns {String} - The complete statement.
     */
    static HandleContinuation(&Text, Match, Operator?, SubGroup := 'body', &OutPosEnd?, &OutLen?, &OutBody?, &OutLenBody?) {
        static Brackets := ['[', ']', '(', ')', '{', '}']
        static PatternContinuation := (
            'm)'
            /** {@link https://www.pcre.org/pcre.txt} search for "Defining subpatterns for use by reference only" */
            '(?(DEFINE)'
                '(?<operator>'
                    '(?://|>>|<<|>>>|\?\?|[:+*/.|&^-])='
                    '|!==' '|>>>' '|&&' '|\|\|' '|\?\?' '|//' '|\*\*' '|=>' '|!=' '|==' '|<<' '|>>' '|~=' '|>=' '|<='
                    '|(?:\s(?:is|in|contains|not|and|or)\s)'
                    '|[(<>=+?:!~&*/,.%^|-]'
                ')'
            ')'
            ; We need the text leading up to the end of the line to be included so we can compare the position with the OutBody text.
            '(?<lead>.+?)'
            '(?:'
            ; This is split up because the pattern must be restricted to cases that have a line break
            ; within the white space between the end of the content and the operator, or between the operator
            ; and the continued expression, but it's not required to have both, hence it being split into
            ; two possible matches. Without this detail, this pattern matches too broadly.
                '[ \t]*+[\r\n]++(*COMMIT)\s*+'
                '(?&operator)'
                '\s*+'
                '|'
                '[ \t]*+'
                '(?&operator)'
                '[ \t]*+[\r\n]++(*COMMIT)\s*+'
            ')'
            '(?<tail>.*)$'
        )

        OutBody := Match[Subgroup]
        OutPosEnd := Match.Pos[Subgroup] - 1
        loop {
            ; Every time one function adds a line, we have to check the other function again.
            ResultBrackets := _LoopBrackets()
            ResultExpressions := _LoopExpressionOperators()
            ; If neither adds anything, then the process is complete.
            if ResultBrackets && ResultExpressions
                break
            if A_Index  > 100
                _ThrowLoopError(A_ThisFunc, A_LineNumber, OutPosEnd)
        }
        OutLenBody := StrLen(OutBody)
        OutPosEnd := Match.Pos[Subgroup] + OutLenBody - 1
        if IsSet(Operator) {
            Split := StrSplit(Match[0], Operator)
            FullText := Split[1] Operator SubStr(OutBody, InStr(OutBody, Split[2]))
            OutLen := StrLen(FullText)
            return FullText
        } else {
            OutLen := OutLenBody
            return OutBody
        }

        _LoopExpressionOperators() {
            local Len := StrLen(OutBody)
            ; `Body` contains what we've captured of the body this far. We begin
            ; searching `Text` from the start of the last line of `Body`. The extra context helps to
            ; ensure that the content that is matched belongs to this code block.
            PosCr := InStr(OutBody, '`r', , , -1)
            PosLf := InStr(OutBody, '`n', , , -1)
            _Pos := Max(PosCr, PosLf)
            PosBody := Match.Pos[Subgroup]
            _PosTest := _Pos + Match.Pos[Subgroup]
            if !RegExMatch(Text, PatternContinuation, &MatchOperator, _Pos + Match.Pos[Subgroup])
            ; A match can be probable depending on how much text is covered by `Text`, but not every
            ; match is valid. We validate the match by comparing the position.
            || MatchOperator.Pos !== _Pos + Match.Pos[Subgroup] {
                return Len == StrLen(OutBody)
            }
            OutBody := SubStr(OutBody, 1, _Pos) MatchOperator[0]
            OutPosEnd := MatchOperator.Pos + MatchOperator.Len
        }

        _LoopBrackets() {
            local Len := StrLen(OutBody)
            ; This loop checks if there is an unequal number of open and close brackets, which
            ; would indicate the expression continues on the next line.
            loop 3 {
                Br := brackets[A_Index*2-1]
                StrReplace(OutBody, Br,,, &CountOpen)
                StrReplace(OutBody, Brackets[A_Index*2],,, &CountClose)
                if CountOpen == CountClose
                    continue
                ; Construct the pattern using the current brackets.
                P := Format('(?<body>\{1}([^\{1}\{2}]++|(?&body))*\{2})(?<tail>.*)', Br, Brackets[A_Index*2])
                ; This is handling cases when multiple instances of the open bracket character are present
                ; in the body string. We iterate the open brackets and find the one that does not match.
                if CountOpen > 1 {
                    loop CountOpen {
                        ; If we do get a match, we test the position relative to PosBr. If they aren't
                        ; the same, we know that's the correct bracket. If we don't get any match, then
                        ; that also indicates it is the correct bracket.
                        PosBr := InStr(OutBody, Br, , , A_Index)
                        if !RegExMatch(OutBody, P, &MatchBracketPos, PosBr) || MatchBracketPos.Pos !== PosBr {
                            OutPosEnd := PosBr + Match.Pos[Subgroup] - 1 ; Offset the position so it is correct relative to `Text`.
                            break
                        }
                    }
                } else {
                    OutPosEnd := InStr(OutBody, Br) + Match.Pos[Subgroup] - 1
                }
                if !RegExMatch(Text, P, &MatchBracket, OutPosEnd) || MatchBracket.Pos !== OutPosEnd
                    throw Error('There is likely a syntax error around position: ' Match.Pos, -1)
                OutBody := SubStr(OutBody, 1, (PosBr ?? InStr(OutBody, Br)) - 1) MatchBracket[0]
                OutPosEnd := MatchBracket.Pos + MatchBracket.Len
                PosBr := unset
                if A_Index > 100
                    _ThrowLoopError(A_ThisFunc, A_LineNumber, MatchBracket.Pos)
            }
            return Len == StrLen(OutBody)
        }

        _ThrowLoopError(Fn, Ln, Pos) {
            err := Error('Loop exceeded 100 iterations, indicating a logical error in the function implementation.')
            err.What := Fn
            err.Line := Ln
            err.Extra := 'Text position being analyzed: ' Pos
            Left := Pos - 150 < 1 ? 1 : Pos - 150
            Right := Pos + 150 > StrLen(Text) ? StrLen(Text) : Pos + 150
            Context := SubStr(Text, Left, Right - Left)
            OutputDebug('`nThe function loop exceeded 100 iterations. Additional context:`n'
            'Function: ' Fn '`tLine: ' Ln '`tApproximate position: ' Pos
            '`nContext (pos ' Left ' - ' Right '):`n' Context)
            throw err
        }
    }

    /**
     * @description - Opens the configuration file's directory in Explorer.
     * @param {String} Location - The location to open. Can be either 'Working' or 'AppData'.
     */
    static OpenConfigDir(Location) {
        switch Location, 0 {
            case 'Working':
                Run('Explorer.exe "' A_WorkingDir '"')
            case 'AppData':
                Run('Explorer.exe "' A_AppData '"')
        }
    }

    /**
     * @description - `RemoveStringLiterals` removes quoted strings and comments from the input
     * text, which is expected to be AHK code. The function returns arrays of objects that contain
     * the matched content and a replacement string. The replacement string is a unique string that
     * is used to replace the matched content in the input text. This is done so the text can be
     * added back at a later time, if needed.
     *
     * All pairs of unescaped consecutive quote characters are removed first, and share the same
     * replacement strings (`Chr(0xFFFC)_String-1_Chr(0xFFFC)` for single quote chararacters and
     * `Chr(0xFFFC)_String-n_Chr(0xFFFC)` for double quote char, `n` 1 or 2 depending on if any
     * pairs of single quote chararacters were removed). This is to speed up the process for large
     * inputs.
     *
     * The integer in the replacement string is the item's index in its respective array.
     *
     * The match objects have additional subcapture groups which you can use to analyze the content
     * that was removed.
     * - All matches have the following:
     *   - **removed**: The text that was removed from the input string.
     * - Continuation sections:
     *   - **comment**: The last comment between the open quote character and the open bracket character,
     * if any are present.
     *   - **quote**: The open quote character.
     *   - **text**: The text content between the open bracket and the close bracket, i.e. the continuation
     * section's string value.
     *   - **tail**: Any code that is on the same line as the close bracket, after the close quote character.
     * - Single line comments:
     *   - **comment**: The content of the comment without the semicolon character and without leading
     * whitespace.
     * - Multi-line comments:
     *   - **comment**: The content of the comment without the the open and closing operators
     * (/ * and * /) and without the surrounding whitespace.
     * - Jsdoc comments:
     *   - **comment**: The content of the comment without the open and closing operators (/ * * and * /)
     * and without the surrounding whitespace.
     *   - **line**: The next line following the comment, included so the comment can be paired with
     * whatever it is describing. If the next line of text is a class definition, these subgroups
     * are used:
     *     - **class**: The class name. This will always be present.
     *     - **super**: If the class has the `extends` keyword, this subgroup will contain the name of
     * the superclass.
     *   - If the next line of text is a class method, property, or function definition, these subgroups
     * are used:
     *     - **name**: The name of the method, property, or function. This will always be present.
     *     - **static**: The `static` keyword, if present.
     *     - **func**: If it is a function definition, then this subgroup will contain the open
     * parentheses. This is mostly to indicate whether its a function or property, but you can also
     * use the position of the character for some tasks.
     *     - **prop**: If it is a property definition, then this subgroup will contain the first character
     * following the property name.
     * - Quoted strings:
     *   - **text**: The text content of the quoted string, without the encompassing quote characters.
     * @param {VarRef} Text - The text to search. `Text` is expected to be AHK code.
     * @returns {Object} - An object with properties `{ Comment, Continuation, Jsdoc, String }`, each
     * an array of objects. Each object contains two properties:
     * - **Match**: The `RegExMatchInfo` object.
     * - **Replacement**: The replacement string.
     */
    static RemoveStringLiterals(&Text) {
        static pContinuationSection := (
            '(?(DEFINE)(?<singleline>\s*;.*))'
            '(?(DEFINE)(?<multiline>\s*/\*[\w\W]*?\*/))'
            '(?<removed>(?<=[\s=:,&(.[?])(?<quote>[`'"])(*MARK:Continuation)'
            '(?<comment>'
                '(?&singleline)'
                '|'
                '(?&multiline)'
            ')*'
            '\s*+\('
            '(?<text>[\w\W]*?)'
            '\R[ \t]*+\).*?\g{quote})(?<tail>.*)'
        )
        , pSingleline := '(?<removed>(?<=\s|^);[ \t]*(?<comment>.*))(*MARK:Comment)'
        , pMultiline := ('(?<removed>/\*\s*(?<comment>[\w\W]+?)\s*\*/)(*MARK:Comment)')
        , pJsDoc := (
            '(?<removed>/\*\*(?<comment>[\w\W]+?)\*/)(*MARK:jsdoc)\s*'
            '(?<line>'
                'class[ \t]+'
                '(?<class>[a-zA-Z0-9_]+)'
                '(?:'
                    '[ \t]*extends[ \t]+(?<super>[a-zA-Z0-9_.]+)'
                ')?'
                '\s*\{'
                '|'
                '(?<static>static[ \t]+)?(?<name>[\w\d_]+)(?:(?<func>\()|(?<prop>[^(])).+'
                '|'
                '.+'
            ')'
        )
        , pQuotedString := '(?<removed>(?<!``)(?:````)*([`"`'])(?<text>.*?)(?<!``)(?:````)*\g{-2})(*MARK:String)'
        , pLoopRemove := (
            'J)'
            pSingleline
            '|' pJsdoc
            '|' pMultiline
            '|' pQuotedString
        )
        , rChar := this.rChar
        , Replacement := rChar '_{}-{}_' rChar

        Removed := {
            Comment: []
          , Continuation: []
          , Jsdoc: []
          , String: []
        }
        Text := RegExReplace(Text, "(?<!``)(?:````)*''", r := Format(Replacement, 1), &Count)
        if Count
            Removed.String.Push({ Match: Map('removed', "''"), Replacement: r })
        Text := RegExReplace(Text, '(?<!``)(?:````)*""', r := Format(Replacement, Removed.String.Length + 1), &Count)
        if Count
            Removed.String.Push({ Match: Map('removed', '""'), Replacement: r })
        Pos := 1
        ; Remove continuation sections.
        _Process(&pContinuationSection)
        Pos := 1
        ; Remove other quotes and comments.
        _Process(&pLoopRemove)
        return Removed

        _Process(&Pattern) {
            while RegExMatch(Text, Pattern, &MatchRemove, Pos) {
                Arr := Removed.%MatchRemove.Mark%
                Arr.Push({ Match: MatchRemove, Replacement: Format(Replacement, MatchRemove.Mark, Arr.Length + 1) })
                Text := StrReplace(Text, MatchRemove['removed'], Arr[-1].Replacement, , , 1)
                Pos := MatchRemove.Pos + StrLen(Arr[-1].Replacement)
            }
        }
    }

    /**
     * @description - Replaced the removed strings.
     * @param {VarRef} Text - The text to search. `Text` is expected to be AHK code.
     * @param {Object} Removed - The object returned by `RemoveStringLiterals`.
     */
    static ReplaceStrings(&Text, Removed) {
        for Prop, Arr in Removed.OwnProps() {
            for Item in Arr {
                Text := StrReplace(Text, Item.Replacement, Item.Match['removed'])
            }
        }
    }

    /**
     * @description - Toggles the `OnExit` save function.
     * @param {Boolean} Value - If nonzero, the save on exit function is enabled. Else, it is disabled.
     */
    static SaveOnExit(Value) {
        OnExit(_Save, Value ? 1 : 0)

        _Save(*) {
            if this.Config.SaveWorking
                this.WriteConfig('Working')
            if this.Config.SaveAppData
                this.WriteConfig('AppData')
        }
    }

    /**
     * @description - Shows a tooltip by the mouse pointer.
     * @param {String} Str - The text to display in the tooltip.
     */
    static ShowTooltip(Str) {
        static N := [1,2,3,4,5,6,7]
        Z := N.Pop()
        OM := CoordMode('Mouse', 'Screen')
        OT := CoordMode('Tooltip', 'Screen')
        MouseGetPos(&x, &y)
        Tooltip(Str, x, y, Z)
        SetTimer(_End.Bind(Z), -2000)
        CoordMode('Mouse', OM)
        CoordMode('Tooltip', OT)

        _End(Z) {
            ToolTip(,,,Z)
            N.Push(Z)
        }
    }

    /**
     * @description - Sorts the code alphabetically or passes the objects to a callback function
     * to sort. If a path is provided, the function will read the file and sort the content therein.
     * The file cannot be a typical code file, because it will probably confuse this function. The
     * file should contain only the code that is intended to be sorted. If neither a string input nor
     * path are provided, the function sorts the clipboard. If a callback function is not provided,
     * `Sort` relies on AHK's internal sorting that occurs when iterating a `Map` object's contents.
     * <br>
     * `Sort` divides the code into four groups:
     * - Static properties
     * - Properties
     * - Static functions
     * - Functions
     * <br>
     * In terms of `Sort`'s process, global functions and class instance Functions are equivalent and
     * would be grouped together if both are present in the input content. Each group is sorted
     * individually.
     * @param {String} [Text] - The code to sort. If neither `Text` nor `Path` are set, the
     * contents of the clipboard is sorted.
     * @param {String} [Path] - The path to a file containing the code to sort.
     * @param {Integer} [SortStyle=1] - An integer representing one of the available built-in sort
     * styles. Currently there are three options:
     * - 0: The functions are sorted according to AutoHotkey's internal sorting method for Map objects.
     * This places capitalized letters before lowercase letters, regardless of the letter. For example,
     * "Myfunc" would occur after "MyMethod".
     * - 1: The functions / properties are sorted using the built-in `Sort` function. Each name
     * is combined into a string, then `Sort` is called (per group). Names that begin with "__"
     * are moved to the end of the group.
     * - 2: The same as 1 except names that begin with "__" are not moved to the end of the group.
     * @param {String} [SortOptions=''] - The options to use when sorting. This parameter is only
     * used when `SortStyle` is set to 1. The options are passed directly to `Sort`.
     * @param {String} [SortOrder='SF SP F P'] - A space-delimited list specifying the order to
     * construct the string after sorting the functions / properties. The groups are:
     * - SF: Static Functions
     * - SP: Static properties
     * - F: Functions
     * - P: Properties
     * @param {Func} [Callback] - The callback function for custom sorting. The callback function
     * will receive two parameters:
     * - The `Containers` object which has four properties
     * { Functions, StaticFunctions, Properties, StaticProperties }. Each property is a map object,
     * where the key is the function or property name, and the value is a string containing
     * the content of that statement. If a Jsdoc comment was above the statement, the Jsdoc's
     * replacement string is included in the content.
     * - The `Removed` object, which also has four properties
     * { Comment, Continuation, Jsdoc, String }. Each property is an array of objects. Each object
     * contains two properties:
     * - **Match**: The `RegExMatchInfo` object.
     * - **Replacement**: The replacement string.
     * The callback function does not need to return a value. It is expected the callback function
     * will construct its own string, and so no further processing would be needed from the built-in
     * process. To replace the removed strings with their original text, you can call `ReplaceStrings`.
     * @param {Integer} [LinesBetween=1] - The number of blank lines between each item.
     * @returns {String} - The sorted text.
     */
    static Sort(Text?, Path?, SortStyle := 1, SortOptions := '', SortOrder := 'SF SP F P', Callback?
    , LinesBetween := 0) {
        static pBracket := '(?<bracket>\{(?:[^}{]++|(?&bracket))*\})'
        , rChar := this.rChar
        , pStatement := (
            'mJi)^'
            '(?<jsdoc>[ \t]*+' rChar '_jsdoc-(?<n>\d+)_' rChar '\s*+)?'
            '[ \t]*' '(?<static>static[ \t]+)?'
            '(?<name>[\w\d_]+)'
            '(?:'
                '(?<func>(?<params>\(([^()]++|(?&params))*\))\s*(?:(?<operator>=>)(?<body>.+)|(?<call>\{)))'
                '|'
                '(?<prop>(?<params>\[(?:[^\][]++|(?&params))*\])?.*?'
                    '(?:'
                        '(?<operator>=>)(?<body>.+)'
                        '|'
                        '(?<operator>:=)(*MARK:assign)(?<body>.+)'
                        '|'
                        '(?<call>\{)'
                    ')'
                ')'
            ')'
        )
        local Match, Pos, MatchBody, cb
        if IsSet(Path)
            Text := FileRead(Path)
        else if !IsSet(Text)
            Text := A_Clipboard
        BlankLines := ''
        loop LinesBetween {
            BlankLines .= '`r`n'
        }
        ; This function relies on a pattern that requires every open bracket to have a matching close bracket
        ; to work as expected. If a string literal has one bracket but not the other, the function wouldn't
        ; process correctly. So we need to remove string literals before processing just in case.
        Removed := this.RemoveStringliterals(&Text)
        Containers := {
            Functions: Map()
          , StaticFunctions: Map()
          , Properties: Map()
          , StaticProperties: Map()
        }
        ; OutputDebug('`n' Text)
        while RegExMatch(Text, pStatement, &Match, Pos ?? 1) {
            Containers.%Trim(Match['static'], '`s`t`r`n') (Match['func'] ? 'Functions' : 'Properties')%.Set(
                Match['name']
              , Match.Len['body']
                ? this.HandleContinuation(&Text, Match, Match['operator'], 'body', &Pos)
                : SubStr(Match[0], 1, Match.Len - Match.Len['call']) _MatchBrackets()[0]
            )
            ; OutputDebug('`n' Match[0])
            ; OutputDebug('`n' Match['jsdoc'])
            ; OutputDebug('`n' Containers.%Trim(Match['static'], '`s`t`r`n') (Match['func'] ? 'Functions' : 'Properties')%.Get(Match['name']))
        }
        if !IsSet(Callback) {
            if this.Callback
                Callback := this.Callback
        }
        if IsSet(Callback) {
            Callback(Containers, Removed)
            return
        }
        _Sort%SortStyle%()
        this.ReplaceStrings(&SortedText, Removed)
        if this.HasOwnProp('G') && HasProp(this.G, 'Hwnd') && IsNumber(this.G.Hwnd) {
            this.G['Display'].Text := RegExReplace(SortedText, '\R', '`r`n')
            if this.G['AddToClipboard'].Value {
                this.Copy()
                this.ShowTooltip('Sorted text added to clipboard!')
            } else {
                this.ShowTooltip('Sorted text!')
            }
        }
        return SortedText

        _MatchBrackets() {
            if !RegExMatch(Text, pBracket, &MatchBody, Match.Pos + Match.Len - 1)
            || MatchBody.Pos !== Match.Pos + Match.Len - 1
                throw Error('Failed to match with the function brackets.')
            Pos := MatchBody.Pos + MatchBody.Len
            return MatchBody
        }
        _Sort0() {
            for Prop in this.GetSortOrder(SortOrder) {
                Container := Containers.%Prop%
                if !Container.Count {
                    continue
                }
                for Name, Statement in Container {
                    SortedText .= Statement '`r`n' BlankLines
                }
            }
        }
        _Sort1() {
            for Prop in this.GetSortOrder(SortOrder) {
                Container := Containers.%Prop%
                if !Container.Count {
                    continue
                }
                Names := ''
                for Name in Container {
                    Names .= Name '`n'
                }
                DoubleUnderscore := []
                DoubleUnderscore.Capacity := Container.Count
                for Name in StrSplit(Sort(Trim(Names, '`n'), SortOptions), '`n') {
                    if SubStr(Name, 1, 2) == '__' {
                        DoubleUnderscore.Push(Name)
                        continue
                    }
                    SortedText .= Container[Name] '`r`n' BlankLines
                }
                for Name in DoubleUnderscore {
                    SortedText .= Container[Name] '`r`n' BlankLines
                }
            }
        }
        _Sort2() {
            for Prop in this.GetSortOrder(SortOrder) {
                Container := Containers.%Prop%
                if !Container.Count {
                    continue
                }
                Names := ''
                for Name in Container {
                    Names .= Name '`n'
                }
                for Name in StrSplit(Sort(Trim(Names, '`n'), SortOptions), '`n') {
                    SortedText .= Container[Name] '`r`n' BlankLines
                }
            }
        }
    }

    /**
     * @description - Writes the configuration to a file.
     * @param {String} Location - The location to write the configuration file. Either 'Working' or
     * 'AppData'.
     */
    static WriteConfig(Location) {
        static ConfigStr := '
        (
            class SortFunctions_Config_{1} {
                static AddToClipboard := {2}
              , CR := {3}
              , Hotkey := {4}
              , LinesBetween := {5}
              , LF := {6}
              , Path := {7}
              , SaveAppData := {8}
              , SaveOnExit := {9}
              , SaveWorking := {10}
              , SortOptions := {11}
              , SortOrder := {12}
              , SortStyle := {13}
            }

        )'
        G := this.G
        Config := this.Config
        if Location == 'Working' {
            Path := A_WorkingDir
        } else if Location == 'AppData' {
            if !DirExist(A_AppData '\SortFunctions') {
                try {
                    DirCreate(A_AppData '\SortFunctions')
                } catch {
                    MsgBox('Failed to create directory: ' A_AppData '\SortFunctions')
                    return
                }
            }
            Path := A_AppData '\SortFunctions'
        } else {
            throw ValueError('Unexpected ``Location``.', -1, Location)
        }
        f := FileOpen(Path '\SortFunctionsConfig.ahk', 'w')
        f.Write(Format(ConfigStr
            , Location
            , G['AddToClipboard'].Value ? 'true' : 'false'
            , G['CR'].Value ? 'true' : 'false'
            , '"' G['Hotkey'].Text '"'
            , G['LinesBetween'].Text
            , G['LF'].Value ? 'true' : 'false'
            , '"' G['Path'].Text '"'
            , Config.SaveAppData ? 'true' : 'false'
            , Config.SaveOnExit ? 'true' : 'false'
            , Config.SaveWorking ? 'true' : 'false'
            , '"' G['SortOptions'].Text '"'
            , '"' G['SortOrder'].Text '"'
            , IsNumber(G['SortStyle'].Text) ? G['SortStyle'].Text : '"' G['SortStyle'].Text '"'
        ))
        f.Close()
    }
}
