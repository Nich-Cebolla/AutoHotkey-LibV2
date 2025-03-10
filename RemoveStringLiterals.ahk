/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/RemoveStringLiterals.ahk
    Author: Nich-Cebolla
    Version: 1.0.0
    License: MIT
*/

/**
 * @description - `RemoveStringLiterals` removes quoted strings and comments from the input
 * text, which is expected to be AHK code. The function returns arrays of objects that contain
 * the matched content and a replacement string. The replacement string is a unique string that
 * is used to replace the matched content in the input text. This is done so the text can be
 * added back at a later time, if needed.
 *
 * All pairs of unescaped consecutive quote characters are removed first, and share the same
 * replacement strings. This is to speed up the process for large inputs.
 *
 * The match objects have additional subcapture groups which you can use to analyze the content
 * that was removed. All matches have the following:
 * - **removed**: The text that was removed from the input string.
 *
 * Continuation sections:
 * - **comment**: The last comment between the open quote character and the open bracket character,
 * if any are present.
 * - **quote**: The open quote character.
 * - **text**: The text content between the open bracket and the close bracket, i.e. the continuation
 * section's string value.
 * - **tail**: Any code that is on the same line as the close bracket, after the close quote character.
 *
 * Single line comments:
 * - **comment**: The content of the comment without the semicolon character and without leading
 * whitespace.
 *
 * Multi-line comments:
 * - **comment**: The content of the comment without the the open and closing operators
 * (/ * and * /) and without the surrounding whitespace.
 *
 * Jsdoc comments:
 * - **comment**: The content of the comment without the open and closing operators (/ * * and * /)
 * and without the surrounding whitespace.
 * - **line**: The next line following the comment, included so the comment can be paired with
 * whatever it is describing. If the next line of text is a class definition, these subgroups
 * are used:
 *   - **class**: The class name. This will always be present.
 *   - **super**: If the class has the `extends` keyword, this subgroup will contain the name of
 * the superclass.
 * If the next line of text is a class method, property, or function definition, these subgroups
 * are used:
 *   - **name**: The name of the method, property, or function. This will always be present.
 *   - **static**: The `static` keyword, if present.
 *   - **func**: If it is a function definition, then this subgroup will contain the open
 * parentheses. This is mostly to indicate whether its a function or property, but you can also
 * use the position of the character for some tasks.
 *   - **prop**: If it is a property definition, then this subgroup will contain the first character
 * following the property name.
 *
 * Quoted strings:
 * - **text**: The text content of the quoted string, without the encompassing quote characters.
 * @param {VarRef} Text - The text to search. `Text` is expected to be AHK code.
 * @returns {Object} - An object with properties `{ Comment, Continuation, Jsdoc, String }`, each
 * an array of objects. Each object contains two properties:
 * - **Match**: The `RegExMatchInfo` object.
 * - **Replacement**: The replacement string.
 */
RemoveStringLiterals(&Text) {
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
    Text := RegExReplace(Text, '(?<!``)(?:````)*`'`'', r := Format(Replacement, 1), &Count)
    if Count
        Removed.String.Push({ Match: Map(0, "''"), Replacement: r })
    Text := RegExReplace(Text, '(?<!``)(?:````)*""', r := Format(Replacement, Removed.String.Length + 1), &Count)
    if Count
        Removed.String.Push({ Match: Map(0, '""'), Replacement: r })
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
            Text := StrReplace(Text, MatchRemove['removed'], Arr[-1].Replacement)
            Pos := MatchRemove.Pos + StrLen(Arr[-1].Replacement)
        }
    }
}
