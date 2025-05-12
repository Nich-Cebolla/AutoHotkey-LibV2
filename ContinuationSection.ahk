/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/ContinuationSection.ahk
    Author: Nich-Cebolla
    Version: 1.0.0
    License: MIT
*/

/**
 * @description - `ContinuationSection` implements the same logic as `ParseContinuationSection`.
 *
 * `ContinuationSection` is a parsing function for use with AHK code.
 * `ContinuationSection` will analyze the input text, and if the lines are joined by a
 * continuation operator or bracket, `ContinuationSection` will concatenate the related lines
 * into a single string.
 * - **Note** that, in this description and in the code, "Body" refers to the text content that follows
 * the operator, including the entire continuation section.
 * - **Limitations**:
 *   - If any quoted strings or comments contain one or more brackets that doesn't have an opposing
 * match, the string may need to be removed prior to calling `ParseContinuationSection`.
 *   - `ContinuationSection` is not designed to handle string continuation sections as described
 * here: {@link https://www.autohotkey.com/docs/v2/Scripts.htm#continuation-section}. If you need
 * to handle string continuation sections, there's a pattern in
 * {@link https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/re/Pattern.ahk}
 * that will match with valid string continuation sections.
 *
 * See test-files\test-ContinuationSection.ahk for a usage example.
 *
 * @param {VarRef} StringPtr - The pointer to the string to parse. `ContinuationSection` will make
 * a copy of the string beginning at `Pos` and leave the buffer unchanged. The string is expected to
 * be AHK code. The string should contain a statement with an operator that might be followed by a
 * continuation section.
 * @param {Integer} Pos - The character position within `Text` where the left side of the statement
 * begins. This position becomes the beginning of `ContinuationSectionObj.Text` and is set to
 * `ContinuationSectionObj.Pos["Text"]` to mirror a `RegExMatchInfo` object.
 * @param {String} Operator - The operator within the statement that might be followed by a
 * continuation section.
 * @returns {ContinuationSection} -
 * The available properties are:
 * @property ContinuationSectionObj.Text - The full text starting from `Pos` to the end of the statement.
 * @property ContinuationSectionObj.Body - the text beginning after the operator and ending at the end
 * of the statement.
 * @property ContinuationSectionObj.Len - This property takes one parameter, which should either be
 * "Text", or "Body". It is designed this way to mirror a `RegExMatchInfo` object. So to get either
 * length, you use `ContinuationSectionObj.Len["Text"]` or `ContinuationSectionObj.Len["Body"]`.
 * @property ContinuationSectionObj.Pos - Similar to the above, use either
 * `ContinuationSectionObj.Pos["Text"]` or `ContinuationSectionObj.Pos["Body"]`. Accessing `Pos` without
 * a parameter returns the character position of the start of the line.
 * @property ContinuationSectionObj.PosEnd - Returns `this.Pos['Body'] + StrLen(this.Body)`, which
 * is the end position of the statement relative to the input text.
 * @property ContinuationSectionObj.__Item - Also to mirror a `RegExMatchInfo` object. Accessing
 * `ContinuationSectionObj["Text"]` returns `ContinuationSectionObj.Text`, and likewise for "Body".
 */
class ContinuationSection {
    __New(StringPtr, Pos, Operator) {
        static Brackets := ['[', ']', '(', ')', '{', '}']
        static PatternBrackets := [
            '(?<body>\[([^[\]]++|(?&body))*\])(?<tail>.*)'
          , '(?<body>\(([^()]++|(?&body))*\))(?<tail>.*)'
          , '(?<body>\{([^{}]++|(?&body))*\})(?<tail>.*)'
        ]
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
            ; We need the text leading up to the end of the line to be included so we can compare the position with the this.Body text.
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
        this.Text := StrGet(StringPtr + (Pos - 1) * 2)
        if !RegExMatch(this.Text, '[\w\W]*?' Operator '(.*)', &Match) {
            throw ValueError('Failed to find the operator within the input content.', -1)
        }
        this.Body := Match[1]
        this.PosStart := Pos
        this.PosBody := Match.Pos[1] + Pos
        this.PosLineStart := RegExMatch(StrGet(StringPtr, Pos - 1), '.*$')
        Pos := Match.Pos[1]
        loop 90000 { ; 90000 is arbitrary and is just to prevent an infinite loop
            ; Every time one function adds a line, we have to check the other function again.
            if _LoopBrackets() {
                if _LoopExpressionOperators() {
                    break
                }
            } else {
                _LoopExpressionOperators()
            }
        }
        this.Text := SubStr(this.Text, 1, InStr(this.Text, this.Body) + StrLen(this.Body) - 1)

        _LoopExpressionOperators() {
            ; `Body` contains what we've captured of the body this far. We begin
            ; searching `Text` from the start of the last line of `Body`. The extra context helps to
            ; ensure that the content that is matched belongs to this code block.
            _Pos := Max(InStr(this.Body, '`r', , , -1), InStr(this.Body, '`n', , , -1))
            if !RegExMatch(this.Text, PatternContinuation, &Match, _Pos + Pos)
            ; A match can be probable depending on how much text is covered by `Text`, but not every
            ; match is valid. We validate the match by comparing the position.
            || Match.Pos !== _Pos + Pos {
                return 1
            }
            this.Body := SubStr(this.Body, 1, _Pos) Match[0]
        }

        _LoopBrackets() {
            local Len := StrLen(this.Body)
            ; This loop checks if there is an unequal number of open and close brackets, which
            ; would indicate the expression continues on the next line.
            loop 3 {
                StrReplace(this.Body, Br := Brackets[A_Index * 2 - 1],,, &CountOpen)
                StrReplace(this.Body, Brackets[A_Index * 2],,, &CountClose)
                if CountOpen == CountClose {
                    continue
                }
                ; This is handling cases when multiple instances of the open bracket character are present
                ; in the body string. We iterate the open brackets and find the one that does not match.
                if CountOpen > 1 {
                    loop CountOpen {
                        ; If we do get a match, we test the position relative to PosBr. If they aren't
                        ; the same, we know that's the correct bracket. If we don't get any match, then
                        ; that also indicates it is the correct bracket.
                        PosBr := InStr(this.Body, Br, , , A_Index)
                        if !RegExMatch(this.Body, PatternBrackets[A_Index], &Match, PosBr) || Match.Pos !== PosBr {
                            OutPosEnd := PosBr + Pos - 1 ; Offset the position so it is correct relative to `Text`.
                            break
                        }
                    }
                } else {
                    OutPosEnd := InStr(this.Body, Br) + Pos - 1
                }
                if !RegExMatch(this.Text, PatternBrackets[A_Index], &Match, OutPosEnd) || Match.Pos !== OutPosEnd {
                    throw Error('There is likely a syntax error around position: ' Match.Pos, -1)
                }
                this.Body := SubStr(this.Body, 1, (PosBr ?? InStr(this.Body, Br)) - 1) Match[0]
                OutPosEnd := Match.Pos + Match.Len
                PosBr := unset
            }
            return Len == StrLen(this.Body)
        }
    }

    Len[Name] => StrLen(this.%Name%)
    Pos[Name?] {
        Get {
            if !IsSet(Name) {
                return this.PosLineStart
            }
            if Name = 'Text' {
                return this.PosStart
            }
            if Name = 'Body' {
                return this.PosBody
            }
        }
    }
    PosEnd => this.Pos['Body'] + StrLen(this.Body)
    __Item[Name] => this.%Name%
}
