
class re {

    /**
     * @description - Loops the input text and returns an array of matches.
     * @param {String} Pattern - The pattern to search for.
     * @param {String} [Text] - The text to search.
     * @param {String} [Path] - The path to the file to search.
     * @returns {Array} - If one or more matches are found, an array of RegExMatchInfo objects.
     * Else, an empty string.
     */
    static Loop(Pattern, Text?, Path?) {
        if IsSet(Path)
            Text := FileRead(Path)
        Result := []
        while Pos := RegExMatch(Text, Pattern, &Match, Pos ?? 1) {
            Result.Push(Match)
            Pos := Match.Pos + Match.Len
        }
        return Result.Length ? Result : ''
    }

    /**
     * @description - Loops the input text and returns an array of matches, using a VarRef for the
     * input. This will perform better for very long strings that are already stored in a variable,
     * compared to `Re.Loop`. Does not modify the string.
     * @param {String} Pattern - The pattern to search for.
     * @param {String:VarRef} Text - The text to search. The variable's content will not be modified.
     * @returns {Array} - If one or more matches are found, an array of RegExMatchInfo objects.
     * Else, an empty string.
     */
    static LoopRef(Pattern, &Text) {
        Result := []
        while Pos := RegExMatch(Text, Pattern, &Match, Pos ?? 1) {
            Result.Push(Match)
            Pos := Match.Pos + Match.Len
        }
        return Result.Length ? Result : ''
    }

    static GetBrace(bracket) {
        switch bracket {
            case '{': return '}'
            case '[': return ']'
            case '(': return ')'
            case '}': return '{'
            case ']': return '['
            case ')': return '('
        }
    }

    /**
     * @description - Escapes the characters that need escaped within PCRE-flavored RegEx. This does
     * not account for characters within a character class ([a-zA-Z]), which do not need escaped
     * except for the closing square bracket.
     * @param {String} Text - The text to escape.
     * @return {String} - The escaped text.
     */
    static EscapeChars(Text) {
        return RegExReplace(StrReplace(Text, '\', '\\'), '(?=[.*?+[{|()^$])', '\')
    }

    static RemoveStringLiterals(&Text) {
        static pContinuationSection := (
            '(?(DEFINE)(?<singleline>\s*;.*))'
            '(?(DEFINE)(?<multiline>\s*/\*[\w\W]*?\*/))'
            '(?<=[\s=:,&(.[?])(?<quote>[`'"])'
            '(?<comment>'
                '(?&singleline)'
                '|'
                '(?&multiline)'
            ')*'
            '\s*+\('
            '(?<text>[\w\W]*?)'
            '\R[ \t]*+\).*?\g{quote}(?<tail>.*)'
        )
        , pJsdoc := ('/\*\*(?<jsdoc>[\w\W]+?)\*/\s+'
        '(?:[ \t]*+class[ \t]+(?<class>[a-zA-Z0-9_]+)(?:[ \t]*extends[ \t]+(?<super>[a-zA-Z0-9_.]+))?\s*\{|'
        '(?<static>static[ \t]+)?(?<name>[a-zA-Z0-9_]+)(?:\((*MARK:methods)|[^(](*MARK:properties)))')
        , pQuotedString := '(?<!``)(?:````)*([`"`'])(?<text>.*?)(?<!``)(?:````)*\g{-2}'
        , pLoopRemove := '(?<comment>(?<=\s|^);.*)|' pJsdoc '|' pQuotedString
        , rChar := Chr(0xFFFC)
        , Replacement := '{}_{}_{}'


        Removed := []
        ; Remove continuation sections.
        while RegExMatch(Text, pContinuationSection, &MatchContinuation, Pos ?? 1) {
            Removed.Push({ Match: MatchContinuation, Replacement: Format(Replacement, rChar, Removed.Length + 1, rChar) })
            Str := StrReplace(Str, MatchQuote[0], Removed[-1].Replacement)
            Pos := MatchContinuation.Pos + StrLen(Removed[-1].Replacement)
        }
        Pos := 1
        ; Remove other quotes and comments.
        loop {
            if !RegExMatch(Text, pLoopRemove, &MatchRemove, Pos)
                break
            Removed.Push({ Match: MatchRemove, Replacement: Format(Replacement, rChar, Removed.Length + 1, rChar) })
            Str := StrReplace(Str, MatchRemove[0], Removed[-1].Replacement)
            Pos := MatchRemove.Pos + StrLen(Removed[-1].Replacement)
        }
    }
}


