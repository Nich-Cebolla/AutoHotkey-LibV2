
class Pattern {

    /**
     * @property {String} BracketCurly
     * @property {String} BracketRound
     * @property {String} BracketSquare
     * Matches a string of text enclosed by brackets, including any number of nested bracketed
     * substrings. This pattern is provided in the pcre.org manual as an example of recursive
     * patterns. If you are interested in learning more about RegEx, the user manual was immensely
     * helpful for improving my skillset, and I recommend reading it. If you are limited on time,
     * I recommend reading the section beginning from "Repetition" which you can find by searching
     * for "Repetition is specified by quantifiers" within the manual
     * at {@link https://www.pcre.org/pcre.txt}.
     * For just the section on recursive patterns, search for "RECURSIVE PATTERNS".
     * There's two subcapture group available:
     * - full - The bracketed text, including open and close brackets.
     * - inner - The bracketed text, without the open and close brackets.
     * @example
     *  Text := '
     *  (
     *      Arr := [
     *          1,
     *          { Prop: 'Val' },
     *          [ 1, 2, [3, 4, 5], 6 ],
     *          (1 + 2 + 3 + 4)
     *      ]
     *  )'
     *  RegExMatch(Text, '(?<var>\w+) := ' Re.Pattern.BracketSquare, &Match)
     *  MsgBox(Match['var']) ; Arr
     *  MsgBox(Match['full']) ; [`n    1,`n    { Prop: 'Val' },`n    [ 1, 2, [3, 4, 5], 6 ],`n    (1 + 2 + 3 + 4)`n]
     *  MsgBox(Match[0]) ; Arr := [`n    1,`n    { Prop: 'Val' },`n    [ 1, 2, [3, 4, 5], 6 ],`n    (1 + 2 + 3 + 4)`n]
     * @
     * One creative way to use this pattern is to include a callout next to the open bracket or
     * close bracket, or both, so that every time an open bracket or close bracket is encountered,
     * your function can react. Run the example file "Example-bracket-callouts.ahk" to see
     * what this looks like.
     */
    static BracketCurly := '(\{(?:[^}{]++|(?-1))*\})'
    ; Using named backreference: '(?<bracket>\{(?:[^}{]++|(?&bracket))*\})'
    static BracketRound := '(\((?:[^)(]++|(?-1))*\))'
    static BracketSquare := '(\[(?:[^\][]++|(?-1))*\])'

    /**
     * @property {String} ContinuationSectionAhk - Matches any syntactically correct
     * continuation section.  Refers to this kind of continuation section
     * {@link https://www.autohotkey.com/docs/v2/Scripts.htm#continuation-section}
     * There's four subcapture groups available:
     * - comment - This will contain the last comment that occurs before the opening parenthesis at
     * the start of the continuation section, if one exists.
     * - quote - The quote character used by the continuation section.
     * - text - The text content between the start and end quote characters, but not including
     * the quote characters.
     * - tail - The text that occurs after the closing quotation mark on the same line, if any.
     */
    static ContinuationSectionAhk := (
        '(?(DEFINE)(?<singleline>\s*;.*))'
        '(?(DEFINE)(?<multiline>\s*/\*[\w\W]*?\*/))'
        '(?<=[\r\n]).*?'
        '(?<text>'
            '(?<=[\s=:,&(.[?]|^)'
            '(?<quote>[`'"])'
            '(?<comment>'
                '(?&singleline)'
            '|'
                '(?&multiline)'
            ')*'
            '\s*+\('
            '(?<body>[\w\W]*?)'
            '\R[ \t]*+\).*?\g{quote}'
            '(*MARK:SPC_STRING)'
        ')'
        '(?<tail>.*)'
    )

    /**
     * @property {String} ContinuationSectionJs - Matches a basic Javascript continuation section
     * using the backtick. There's one subcapture groups available:
     * - content - The content of the continuation section.
     * For the example, assume a Kapital.js file:
     *  const dasKapital = `The wealth of those societies in which the capitalist mode of
     *  production prevails, presents itself as “an immense accumulation of commodities,”[1] its
     *  unit being a single commodity. Our investigation must therefore begin with the analysis
     *  of a commodity.`
     * @example
     *  RegExMatch(FileRead('Kapital.js'), Pattern.ContinuationSectionJs, &Match)
     *  MsgBox(Match['content']) ; The wealth of those societies... analysis of a commodity.
     * @
     */
    static ContinuationSectionJs := 's)(?<!\\)(?:\\\\)*+``(?<content>.*?)(?<!\\)(?:\\\\)*+``'


    /**
     * @property {String} RootPath - Matches a standard Windows root path. There are four
     * subcapture groups available:
     * - dir - The directory path. Note the directory does not the trailing '\' at the end.
     * - drive - The drive letter.
     * - file - The file name.
     * - ext - The file extension.
     * @example
     *  RegExMatch(A_LineFile, Re.Pattern.RootPath, &Match)
     *  MsgBox(Match['drive']) ; C
     *  MsgBox(Match['dir']) ; C:\Users\MyName\My Documents\AutoHotkey\Lib\re
     *  MsgBox(Match['file']) ; Pattern
     *  MsgBox(Match['ext']) ; ahk
     *  MsgBox(Match[0]) ; C:\Users\MyName\My Documents\AutoHotkey\Lib\re\Pattern.ahk
     * @
     */
    static RootPath := '(?<dir>(?:(?<drive>[a-zA-Z]):\\)?(?:[^\r\n\\/:*?"<>|]++\\?)+)\\(?<file>[^\r\n\\/:*?"<>|]+?)\.(?<ext>\w+)\b'

    /**
     * @description - Matches with a root path or relative path that begins with "..\".
     *
     * This won't match correctly with a relative path that begins with a directory or file name.
     * Needs more work for that.
     */
    static RootOrRelativePath := (
        'J)'
        '(?<dir>'
            '(?:'
                '(?<drive>[a-zA-Z])'
                ':'
            '|'
                '\.\.'
            '|'
                '(?:[^ \r\n\\/:*?"<>|]++\\?)+'
            ')'
            '\\'
            '(?:[^\r\n\\/:*?"<>|]++\\?)+'
        ')'
        '\\'
        '(?<file>[^\r\n\\/:*?"<>|]+?)'
        '\.'
        '(?<ext>\w+)'
        '\b'
    )

    /**
     * @description - Constructs one of the Bracket patterns dynamically using an input character.
     * @param {String} BracketChar - The open bracket character.
     * @returns {String} - The regular expression pattern.
     */
    static GetBracketPattern(BracketChar) {
        return Format('(?<full>\{1}(?<inner>(?:[^{1}{2}]++|(?-2))*)\{3})', BracketChar
        , BracketChar == '[' ? '\]' : Pattern.GetMatchingBrace(BracketChar)
        , Pattern.GetMatchingBrace(BracketChar))
    }

    /**
     * Matches a quoted string, skipping any properly escaped quote characters.
     */
    static QuotedString := '(?<!``)(?:````)*([`"`'])(?<text>.*?)(?<!``)(?:````)*\g{-2}'

    /**
     * @description - Matches a complete quoted string. This differentiates between quote chars
     * that have an even or odd number of escape characters behind it, allowing certainty that
     * the closing quote character is the correct closing character, and not an escaped character.
     * There is one subcapture group available:
     * - text - The content of the quoted string.
     * @example
     *  Pattern := Re.Pattern.GetQuotedString('\', '"', false)
     *  Text := 'Variable := "Some Json field with \"escaped quotes\""'
     *  RegExMatch(Text, Pattern, &Match)
     *  MsgBox(Match['text']) ; Some Json field with "escaped quotes"
     *  MsgBox(Match[0]) ; "Some Json field with \"escaped quotes\""
     * @
     * @param {String} [EscapeChar='``'] - The escape character.
     * @param {String} [QuoteChars='"`''] - The quote characters. If the strings will only
     * be quoted by one type of character, you can slightly improve performance by setting this
     * to just that character.
     * @param {Boolean} [Options] - The RegEx options to include at the start of the pattern.
     * {@link https://www.autohotkey.com/docs/v2/misc/RegEx-QuickRef.htm#Options}
     * The option "Dot-All" is a primary consideration with this pattern.
     * @returns {String} - The regular expression pattern.
     */
    static GetQuotePattern(EscapeChar := '``', QuoteChars := '"`'', Options?) {
        if InStr(EscapeChar, '\') && StrLen(EscapeChar) == 1
            EscapeChar .= EscapeChar
        Options := IsSet(Options) ? StrReplace(Options, ')', '') ')' : ''
        return Format('{2}(?<!{1})(?:{1}{1})*+({3})(?<text>.*?)'
        '(?<!{1})(?:{1}{1})*+\g{-2}', EscapeChar, Options
        , '[' StrReplace(StrReplace(QuoteChars, '"', '``"'), "'", "``'") ']')
    }

    /**
     * @description - This function will return a pattern that allows a match to occur only when
     * zero or an even number of escape characters are present behind text that matches with the input
     * `Pattern`. If an odd number of escape characters are behind the text, the pattern does not match.
     * There are two subcapture groups available:
     * - escape - If the string is preceded by an even number of escape characters, you can
     * access them with this subcapture group.
     * - str - The character or substring without preceding escape characters.
     * @example
     *  Text := 'Some text with\nbackslash escapes like\n\\n and \\t.'
     *  RegExMatch(Text, Re.Pattern.GetUnescapedStr('n', '\\'), &Match)
     *  MsgBox(Match['escape']) ; \\
     *  MsgBox(Match['str']) ; n
     *  MsgBox(Match.Pos) ; 41
     *  MsgBox(Match[0]) ; \\n
     * @
     * @param {String} Pattern - Pattern to match.
     * @param {String} [EscapeChar='``'] - The escape character.
     * @returns {String} - The regular expression pattern.
     */
    static GetUnescapedStr(Pattern, EscapeChar := '``') {
        if EscapeChar == '\'
            EscapeChar .= EscapeChar
        return Format('(?<escape>(?<!{1})(?:{1}{1})*+)(?<str>{2})', EscapeChar, Pattern)
    }

    static GetEscapedStr(Pattern, EscapeChar := '``') {
        if EscapeChar == '\'
            EscapeChar .= EscapeChar
        return Format('(?<escape>(?<!{1})(?:{1}{1})*+{1})(?<str>{2})', EscapeChar, Pattern)
    }

    static Escape[EscapeChar := '``'] => Format('(?<!{1})(?:{1}{1})*+{1}', EscapeChar == '\' ? EscapeChar EscapeChar : EscapeChar)

    /**
     * @description - Matches a singleline comment. This assumes that the comment character is
     * expected to follow a newline, whitespace character, or is at the beginning of the string.
     * There is one subcapture group available:
     * - comment - The comment text.
     * @example
     *  Text := 'Some text before the comment. // This is a comment.'
     *  RegExMatch(Text, Re.Pattern.GetSinglelineComment('//'), &Match)
     *  MsgBox(Match['comment']) ; This is a comment.
     *  MsgBox(Match[0]) ; // This is a comment.
     * @param {String} CommentChar - The character that indicates the beginning of a comment.
     * @returns {String} - The regular expression pattern.
     */
    static GetSinglelineComment(CommentChar) {
        return Format('(?<=\s|^){1}[ \t]*(?<comment>.*)', CommentChar)
    }

    /**
     * @description - Matches text between any two substrings. There is one subcapture group
     * available:
     * - content - The text between the two substrings.
     * @param {String} OpenSubstring - The opening substring.
     * @param {String} CloseSubstring - The closing substring.
     */
    static GetTextBetweenSubstrings(OpenSubstring, CloseSubstring) {
        return Format('s){1}(?<content>.*?){2}', OpenSubstring, CloseSubstring)
    }

    /**
     * @property {String} Pattern.Parentheses - Attempts to match a string enclosed by parentheses
     * while also allowing for any number of nested escaped parentheses which do not affect the match,
     * and requires an even number of not-escaped parentheses for the match to succeed.
     *
     * This pattern does not accomplish this all the time, but sometimes it works.
     *
     * @example
     *  Str := '[a-z]+(?<somegroup>.+\(.+?\))'
     *  p := Pattern.Parentheses
     *  RegExMatch(Str, p, &Match1)
     *  MsgBox(Match1[0]) ; [a-z]+(?<somegroup>.+\(.+?\))
     *  ; Escape the last character so now there's an odd number of unescaped parentheses
     *  Str := '[a-z]+(?<somegroup>.+\(.+?\)\)'
     *  RegExMatch(Str, p, &Match2)
     *  MsgBox(Match2 ? Match2[0] : '') ; ''
     *  ; Escape the first
     *  Str := '[a-z]+\(?<somegroup>.+\(.+?\))'
     *  RegExMatch(Str, p, &Match3)
     *  MsgBox(Match3 ? Match3[0] : '') ; ''
     * @
     *
     */
    static Parentheses :=  (
        '(?<full>'
            '(?<!\\)(?:\\\\)*\('
            '(?:'
                '[^()]+'
                '|'
                '(?<escape>(?<!\\)(?:\\\\)*\\[^\\])'
                '|'
                '(?&full)'
            ')*'
            '(?<!\\)(?:\\\\)*\)'
        ')'
    )

    /**
     * @property {String} Pattern.NamedSubcaptureGroup - Matches a named subcapture group in a
     * regex pattern.
     */
    static NamedSubcaptureGroup := '(?<!\\)(?:\\\\)*\(\?[<`'p]{1,2}(?<name>[_\p{L}][_\p{L}\p{Nd}]*)>'

    /**
     * @property {String} Pattern.Mark - Matches a named control verb in a regex pattern.
     */
    static Mark := (
        '(?<!\\)(?:\\\\)*'
        '\(\*'
        '(?:MARK|COMMIT|ACCEPT|FAIL|SKIP|PRUNE|THEN|\*)'
        ':'
        '(?<name>'
            '(?:'
                '(?<!\\)(?:\\\\)*\\Q[\w\W]+?(?<!\\)(?:\\\\)*\\E'
                '|'
                '[^(\\)]+'
                '|'
                '(?<escape>(?<!\\)(?:\\\\)*\\[^\\])'
            ')*'
        ')'
        '(?<!\\)(?:\\\\)*\)'
    )

    /**
     * Matches a callout in a regex pattern.
     */
    static Callout := (
        'J)(?<!\\)(?:\\\\)*'
        '\(\?C'
        '(?:'
            '(?<o>[```'"^%#$])'
            '(?<name>.*?)\g{o}\)'
            '|'
            '\{(?<name>.*?)\}\)'
        ')'
    )

    /**
     * Valid characters for Ahk variables and properties.
     * @memberof Pattern
     */
    static AhkAllowedSymbolChars := '(?:[\p{L}_0-9]|[^\x00-\x7F\x80-\x9F])'
    /**
     * Valid characters for Ahk variables and properties excluding digits (the first character
     * of a variable symbol cannot be a digit).
     * @memberof Pattern
     */
    static AhkAllowedSymbolCharsNoDigits := '(?:[\p{L}_]|[^\x00-\x7F\x80-\x9F])'
    /**
     * This pattern will match with property:value pairs within AHK object literal definitions.
     * If used in a loop matching against a string that is an AHK object literal definition beginning
     * after the open brace and ending before the close brace, this will match will all of the
     * property:value pairs. This does not recurse into nested objects, but for any properties with
     * values that are object literals, the "value" subcapture group will be the substring beginning
     * and ending at the open and close brackets; defining a recursive function to go along with this
     * is straightforward.
     */
    static AhkObjectPropertyValuePair := (
        '\s*'
        '(?<property>' this.AhkAllowedSymbolCharsNoDigits this.AhkAllowedSymbolChars '*?)'
        '\s*:\s*'
        '(?<value>'
            '(?:'
                '(?:'
                    '".*?(?<!``)(?:````)*+"'
                '|'
                    '(?<bracket1>\((?:[^)(]++|(?&bracket1))*\))'
                '|'
                    '(?<bracket2>\[(?:[^\][]++|(?&bracket2))*\])'
                '|'
                    '(?<bracket3>\{(?:[^}{]++|(?&bracket3))*\})'
                ')?'
                '[^,]*?'
            ')+?'
        ')'
        '\s*(?:,|$)'
    )

    /**
     * Invalid characters for Ahk variables and properties.
     * @memberof Pattern
     */
    static AhkInvalidSymbolChars := '[^\p{L}0-9_\x{00A0}-\x{10FFFF}]'

    static JsonPropertyValuePair := (
        '(?<=\s|^)"(?<name>.+)(?<!\\)(?:\\\\)*+":\s*'
        '(?<value>'
                '"(?<string>.*?)(?<!\\)(?:\\\\)*+"(*MARK:string)'
            '|'
                '(?<object>\{(?:[^}{]++|(?&object))*\})(*MARK:object)'
            '|'
                '(?<array>\[(?:[^\][]++|(?&array))*\])(*MARK:array)'
            '|'
                'false(*MARK:false)|true(*MARK:true)|null(*MARK:null)'
            '|'
                '(?<n>-?\d++(*MARK:number)(?:\.\d++)?)(?<e>[eE][+-]?\d++)?'
        ')'
    )

    static Hexadecimal := '(?<hexadecimal>\b0[xX][0-9A-Fa-f]+\b)'

    /**
     * This pattern matches a pair of open and close parentheses with any number of nested pairs.
     * It also skips over quoted strings so even if a quoted string contains an unpaired parenthesis,
     * it doesn't disrupt the match.
     */
    static BracketEx := '(?(DEFINE)(?<quote>(?<!``)(?:````)*+(["`']).*?(?<!``)(?:````)*+\g{-2}))(?<body>\(((?&quote)|[^"`')(]++|(?&body))*\))'

    /**
     * This is the JSON-specific version of the above pattern, using curly braces.
     */
    static BracketsExJson := '(?(DEFINE)(?<quote>(?<=[,:[{\s])".*?(?<!\\)(?:\\\\)*+"))(?<body>\{((?&quote)|[^"}{]++|(?&body))*\})'

    /**
     * This pattern utilizes the above `BracketEx`
     */
    static JsonPropertyValuePairEx := (
        '(?<=\s|^)"(?<name>.+)(?<!\\)(?:\\\\)*+":\s*'
        '(?<value>'
                '"(?<string>.*?)(?<!\\)(?:\\\\)*+"(*MARK:string)'
            '|'
                '(?<object>\{(?:[^}{]++|(?&object))*\})(*MARK:object)'
            '|'
                '(?<array>\[(?:[^\][]++|(?&array))*\])(*MARK:array)'
            '|'
                'false(*MARK:false)|true(*MARK:true)|null(*MARK:null)'
            '|'
                '(?<n>-?\d++(*MARK:number)(?:\.\d++)?)(?<e>[eE][+-]?\d++)?'
        ')'
    )

    /**
     * I wrote this to correct floating point precision problems
     * @example
     *  Val := 0.1 + 0.2
     *  if InStr(Val, '.') && RegExMatch(Val, Pattern.FloatingPointPrecision, &match) {
     *      Val := Round(Val, StrLen(Val) - InStr(Val, '.') - match.Len)
     *  }
     * @
     */
    static FloatingPointPrecision := 'S)(?:0{3,}|9{3,})\d$'

    static GetMatchingBrace(bracket) {
        switch bracket {
            case '{': return '}'
            case '[': return ']'
            case '(': return ')'
            case '}': return '{'
            case ']': return '['
            case ')': return '('
        }
    }
}


; if A_LineFile == A_ScriptFullpath {
;     A_Clipboard := Pattern.GetEscapedStr('[rn"]', '\')
;     MsgBox('done')
; }

