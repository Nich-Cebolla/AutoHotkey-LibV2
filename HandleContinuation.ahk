/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/HandleContinuation.ahk
    Author: Nich-Cebolla
    Version: 1.0.0
    License: MIT
*/

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
 *  PatternStatement := (
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
HandleContinuation(&Text, Match, Operator?, SubGroup := 'body', &OutPosEnd?, &OutLen?, &OutBody?, &OutLenBody?) {
    static Brackets := ['[', ']', '(', ')', '{', '}']
    static PatternContinuation := (
        'm)'
        /**
         * {@link https://www.pcre.org/pcre.txt} search for "Defining subpatterns for use by reference only"
         */
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
