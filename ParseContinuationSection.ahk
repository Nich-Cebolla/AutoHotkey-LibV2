/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/ParseContinuationSection.ahk
    Author: Nich-Cebolla
    Version: 1.1.0
    License: MIT
*/

/**
 * @description - `ParseContinuationSection` is a parsing function for use with AHK code.
 * `ParseContinuationSection` will analyze the input text, and if the lines are joined by a
 * continuation operator or bracket, `ParseContinuationSection` will concatenate the related lines
 * into a single string.
 * - **Note** that, in this description and in the code, "Body" refers to the text content that follows
 * the operator, including the entire continuation section.
 * - **Limitations**:
 *   - If any quoted strings or comments contain one or more brackets that doesn't have an opposing
 * match, the string may need to be removed prior to calling `ParseContinuationSection`.
 *   - `ParseContinuationSection` is not designed to handle string continuation sections as described
 * here: {@link https://www.autohotkey.com/docs/v2/Scripts.htm#continuation-section}. If you need
 * to handle string continuation sections, there's a pattern in
 * {@link https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/re/Pattern.ahk}
 * that will match with valid string continuation sections.
 *
 * See test-files\test-ParseContinuationSection.ahk for a usage example.
 *
 * @param {VarRef} Text - The text to search. `Text` is expected to be AHK code. `Text` should contain
 * a statement with an operator that might be followed by a continuation section.
 * When `OutPosEnd` is calculated, it is relative to `Text`.
 * @param {Integer} Pos - The character position within `Text` where the left side of the statement
 * begins.
 * @param {String} Operator - The operator within the statement that might be followed by a
 * continuation section.
 * @param {VarRef} [OutPosEnd] - A variable that will receive the ending position of `OutBody`
 * relative to `Text`.
 * @param {VarRef} [OutBody] - A variable that will receive the portion of text that occurs after the
 * initial operator and ending at the end of the statement.
 * @param {VarRef} [OutLenBody] - A variable that will receive the length of `OutBody`.
 * @param {VarRef} [OutFullStatement] - A variable that will receive `OutBody` concatenated with
 * the left side of the statement (left of the operator).
 * @param {VarRef} [OutLenFullStatement] - A variable that will receive the length of `OutFullStatement`.
 *
 * @returns {String} - The complete statement.
 */
ParseContinuationSection(&Text, Pos, Operator?, &OutPosEnd?, &OutBody?, &OutLenBody?, &OutFullStatement?, &OutLenFullStatement?) {
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
    if !RegExMatch(Text, '[\w\W]*?' Operator '(.*)', &Match, Pos) {
        throw ValueError('Failed to find the operator within the input content.', -1)
    }
    OutBody := Match[1]
    Pos := Match.Pos[1]
    loop 100 {
        ; Every time one function adds a line, we have to check the other function again.
        if _LoopBrackets() {
            if _LoopExpressionOperators() {
                break
            }
        } else {
            _LoopExpressionOperators()
        }
    }
    OutLenBody := StrLen(OutBody)
    OutPosEnd := InStr(Text, OutBody) + OutLenBody
    Split := StrSplit(Match[0], Operator)
    OutFullStatement := Split[1] Operator SubStr(OutBody, InStr(OutBody, Split[2]))
    OutLenFullStatement := StrLen(OutFullStatement)

    _LoopExpressionOperators() {
        local Len := StrLen(OutBody)
        ; `Body` contains what we've captured of the body this far. We begin
        ; searching `Text` from the start of the last line of `Body`. The extra context helps to
        ; ensure that the content that is matched belongs to this code block.
        _Pos := Max(InStr(OutBody, '`r', , , -1), InStr(OutBody, '`n', , , -1))
        if !RegExMatch(Text, PatternContinuation, &MatchOperator, _Pos + Pos)
        ; A match can be probable depending on how much text is covered by `Text`, but not every
        ; match is valid. We validate the match by comparing the position.
        || MatchOperator.Pos !== _Pos + Pos {
            return Len == StrLen(OutBody)
        }
        OutBody := SubStr(OutBody, 1, _Pos) MatchOperator[0]
    }

    _LoopBrackets() {
        local Len := StrLen(OutBody)
        ; This loop checks if there is an unequal number of open and close brackets, which
        ; would indicate the expression continues on the next line.
        loop 3 {
            StrReplace(OutBody, Br := brackets[A_Index * 2 - 1],,, &CountOpen)
            StrReplace(OutBody, Brackets[A_Index * 2],,, &CountClose)
            if CountOpen == CountClose {
                continue
            }
            ; Construct the pattern using the current brackets.
            P := Format('(?<body>\{1}([^\{1}\{2}]++|(?&body))*\{2})(?<tail>.*)', Br, Brackets[A_Index * 2])
            ; This is handling cases when multiple instances of the open bracket character are present
            ; in the body string. We iterate the open brackets and find the one that does not match.
            if CountOpen > 1 {
                loop CountOpen {
                    ; If we do get a match, we test the position relative to PosBr. If they aren't
                    ; the same, we know that's the correct bracket. If we don't get any match, then
                    ; that also indicates it is the correct bracket.
                    PosBr := InStr(OutBody, Br, , , A_Index)
                    if !RegExMatch(OutBody, P, &MatchBracketPos, PosBr) || MatchBracketPos.Pos !== PosBr {
                        OutPosEnd := PosBr + Pos - 1 ; Offset the position so it is correct relative to `Text`.
                        break
                    }
                }
            } else {
                OutPosEnd := InStr(OutBody, Br) + Pos - 1
            }
            if !RegExMatch(Text, P, &MatchBracket, OutPosEnd) || MatchBracket.Pos !== OutPosEnd {
                throw Error('There is likely a syntax error around position: ' Match.Pos, -1)
            }
            OutBody := SubStr(OutBody, 1, (PosBr ?? InStr(OutBody, Br)) - 1) MatchBracket[0]
            OutPosEnd := MatchBracket.Pos + MatchBracket.Len
            PosBr := unset
        }
        return Len == StrLen(OutBody)
    }
}
