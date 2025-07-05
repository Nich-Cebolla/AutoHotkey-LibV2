
/**
 * See {@link https://learn.microsoft.com/en-us/windows/win32/api/stringapiset/nf-stringapiset-comparestringex}.
 * @param {String} Ptr1 - The pointer to the first string to compare.
 * @param {String} Str2 - The pointer to the second string to compare.
 * @param {Integer} [Len1 = -1] - The number of characters of the first string to use during
 * comparison. A negative number directs `CompareStringEx` to determine the length automatically.
 * @param {Integer} [Len2 = -1] - The number of characters of the second string to use during
 * comparison. A negative number directs `CompareStringEx` to determine the length automatically.
 * @param {String|Integer} [LocaleName = ""] - The locale name as string, or one of the following
 * values:
 * - LOCALE_NAME_INVARIANT - ""
 * - LOCALE_NAME_USER_DEFAULT - 0
 * - LOCALE_NAME_SYSTEM_DEFAULT - "!x-sys-default-locale"
 * @param {Integer} [Flags = 0] - A combination of any of the following values:
 * - LINGUISTIC_IGNORECASE - 0x00000010 - Ignore case, as linguistically appropriate.
 * - LINGUISTIC_IGNOREDIACRITIC - 0x00000020 - Ignore nonspacing characters, as linguistically
 * appropriate.
 * - NORM_IGNORECASE - 0x00000001 - Ignore case. For many scripts (notably Latin scripts),
 * NORM_IGNORECASE coincides with LINGUISTIC_IGNORECASE.
 * - NORM_IGNOREKANATYPE - 0x00010000 - Do not differentiate between hiragana and katakana characters.
 * Corresponding hiragana and katakana characters compare as equal.
 * - NORM_IGNORENONSPACE - 0x00000002 - Ignore nonspacing characters. For many scripts (notably
 * Latin scripts), NORM_IGNORENONSPACE coincides with LINGUISTIC_IGNOREDIACRITIC.
 * - NORM_IGNORESYMBOLS - 0x00000004 - Ignore symbols and punctuation.
 * - NORM_IGNOREWIDTH - 0x00020000 - Ignore the difference between half-width and full-width characters,
 * for example, C a t == cat. The full-width form is a formatting distinction used in Chinese and
 * Japanese scripts.
 * - NORM_LINGUISTIC_CASING - 0x08000000 - Use the default linguistic rules for casing, instead of
 * file system rules. Note that most scenarios for CompareStringEx use this flag. This flag does not
 * have to be used when your application calls `CompareStringOrdinal`.
 * - SORT_DIGITSASNUMBERS - 0x00000008 - Treat digits as numbers during sorting, for example, sort
 * "2" before "10".
 * - SORT_STRINGSORT - 0x00001000 - Treat punctuation the same as symbols.
 * @param {Buffer} [NLSVersionInfo = 0] - Pointer to an `NLSVERSIONINFOEX` structure that contains
 * the version information about the relevant NLS capability; usually retrieved from `GetNLSVersionEx`.
 * {@link https://learn.microsoft.com/en-us/windows/desktop/api/winnls/nf-winnls-getnlsversionex}.
 * @returns {Integer} - One of the following values:
 * - CSTR_LESS_THAN - 1
 * - CSTR_EQUAL - 2
 * - CSTR_GREATER_THAN - 3
 * @throws {OSError} - If the function fails.
 */
StrComparePtr(Ptr1, Ptr2, Len1 := -1, Len2 := -1, LocaleName := '', Flags := 0, NLSVersionInfo := 0) {
    if IsNumber(LocaleName) {
        if result := DllCall(
            'Kernel32.dll\CompareStringEx'
          , 'ptr', LocaleName
          , 'uint', Flags
          , 'ptr', Ptr1
          , 'int', Len1
          , 'ptr', Ptr2
          , 'int', Len2
          , 'ptr', NLSVersionInfo
          , 'ptr', 0
          , 'ptr', 0
          , 'int'
        ) {
            return result
        } else {
            throw OSError(A_LastError)
        }
    } else {
        if LocaleName {
            if result := DllCall(
                'Kernel32.dll\CompareStringEx'
              , 'ptr', StrPtr(LocaleName)
              , 'uint', Flags
              , 'ptr', Ptr1
              , 'int', Len1
              , 'ptr', Ptr2
              , 'int', Len2
              , 'ptr', NLSVersionInfo
              , 'ptr', 0
              , 'ptr', 0
              , 'int'
            ) {
                return result
            } else {
                throw OSError(A_LastError)
            }
        } else {
            if result := DllCall(
                'Kernel32.dll\CompareStringEx'
              , 'wstr', LocaleName
              , 'uint', Flags
              , 'ptr', Ptr1
              , 'int', Len1
              , 'ptr', Ptr2
              , 'int', Len2
              , 'ptr', NLSVersionInfo
              , 'ptr', 0
              , 'ptr', 0
              , 'int'
            ) {
                return result
            } else {
                throw OSError(A_LastError)
            }
        }
    }
}
