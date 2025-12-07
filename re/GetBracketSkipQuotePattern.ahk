
/**
 * @description - Returns a pattern that matches with a bracket pair containing any number of
 * nested bracket pairs, skipping over quoted strings to quoted brackets don't disrupt the match.
 */
GetBracketSkipQuotePattern(openBracket, quote := "`"", escapeChar := "\") {
    return Format(
        ; Defines a callable subpattern named "quote"
        "(?(DEFINE)(?<quote>(?<!{2})(?:{2}{2})*+{1}.*?(?<!{2})(?:{2}{2})*+{1}))"
        ; A variation of the bracket pattern that uses "quote" to skip over quoted substrings
        "(?<body>\{3}((?&quote)|[^{1}{3}{4}]++|(?&body))*\{5})"
      , quote
      , escapeChar == "\" ? "\\" : escapeChar
      , openBracket
      , openBracket == "[" ? "\]" : GetMatchingBrace(openBracket)
      , GetMatchingBrace(openBracket)
    )
}

/**
 * @description - Returns a pattern that matches with a bracket pair containing any number of
 * nested bracket pairs, skipping over quoted strings to quoted brackets don't disrupt the match.
 * This version matches with both single and double quotes.
 */
GetBracketSkipQuotePattern2(openBracket, escapeChar := "\") {
    return Format(
        "(?(DEFINE)(?<quote>(?<!{1})(?:{1}{1})*+(?<skip>[`"']).*?(?<!{1})(?:{1}{1})*+\g{skip}))"
        "(?<body>\{2}((?&quote)|[^{2}{3}`"']++|(?&body))*\{4})"
      , escapeChar == "\" ? "\\" : escapeChar
      , openBracket
      , openBracket == "[" ? "\]" : GetMatchingBrace(openBracket)
      , GetMatchingBrace(openBracket)
    )
}

GetMatchingBrace(bracket) {
    switch bracket {
        case "{": return "}"
        case "[": return "]"
        case "(": return ")"
        case "}": return "{"
        case "]": return "["
        case ")": return "("
    }
}
