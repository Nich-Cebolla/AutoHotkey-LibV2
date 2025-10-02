

class ScreamingSnakeToPascal extends Array {
    /**
     * Converts SCREAMING_SNAKE_CASE to PascalCase. This is accomplished using RegExReplace, where
     * the pattern to match is built by starting with the prefix and adding additional parts to
     * it for `maxSegments` number of parts. For example, the pattern for matching with one segment
     * is similar to the following:
     * @example
     * pattern := "\b" prefix "_([" characterClass "])([" characterClass "]*)\b"
     * replacement := replacementPrefix "$1$L2"
     * @
     * The pattern for matching with two segments is similar to the following:
     * @example
     * pattern := "\b" prefix "_([" characterClass "])([" characterClass "]*)_([" characterClass "])([" characterClass "]*)\b"
     * replacement := replacementPrefix "$1$L2$3$L4"
     * @
     *
     * Here's an example using `calculateOnly` to get a list of symbols:
     *
     * @example
     * result := ScreamingSnakeToPascal(
     *     {
     *         input: { in: "C:\users\me\documents\AutoHotkey\lib\MyScript.ahk", out: A_Temp "\MyScript.ahk" }
     *       , maxSegments: 4
     *       , calculateOnly: true
     *       , prefix: "GUICONTROL"
     *     }
     * )
     * A_Clipboard := result.GetSymbols(true, false)
     * @
     *
     * Here's an example using the `Options.wordReplacements` to generate the output.
     *
     * @example
     * ; The return value is not needed unless one's code will inspect it.
     * ScreamingSnakeToPascal(
     *     {
     *         input: { in: "C:\users\me\documents\AutoHotkey\lib\MyScript.ahk", out: A_Temp "\MyScript.ahk" }
     *       , maxSegments: 4
     *       , wordReplacements: Map("GUICONTROL", "GuiControl", "TYPEINDEX", "TypeIndex")
     *     }
     * )
     * @
     *
     * For an example, see file test-files\test-ScreamingSnakeToPascal.ahk
     *
     * @param {Object} Options - An object with options as property : value pairs. `Options.input`
     * and `Options.maxSegments` are required.
     *
     * @param {Object|Object[]} Options.input - An input object, or an array of input objects, with the
     * following properties:
     * - in: The input path.
     * - out: The output path.
     * - prefix: (Optional) Include a "prefix" property to specify different prefixes than the
     *   parameter `prefix`. If the "prefix" property is present, that value is used instead of the
     *   `prefix` parameter. See the `prefix` parameter details for more info.
     *
     * @param {Integer} Options.maxSegments - The greatest number of segments in a symbol. A "segment"
     * is a substring containing only non-underscore characters, e.g. "SCREAMING", "SNAKE", "CASE"
     * in SCREAMING_SNAKE_CASE.
     *
     * @param {String|String[]|Object|Object[]} [Options.prefix = ""] -
     * - If a string: The substring that prefixes the symbols which are going to be modified.
     * - If an array of strings: An array of substrings that prefix the symbols which are going to be
     *   modified.
     * - If an object: An object with the following properties:
     *   - prefix: The substring that prefixes the symbols which are going to be modified.
     *   - replacement: The string that will replace the prefix substring.
     *
     * When `prefix` or the "prefix" property of an `input` object are strings, the prefix is modified
     * so only the first character is capitalized. For prefixes that consist of more than one whole
     * word, you may want to specify the replacement string because {@link ScreamingSnakeToPascal}
     * won't recognize the words; only the first letter will be capitalized. For example, if my
     * prefix is "GUICONTROL", {@link ScreamingSnakeToPascal} will modify that to "Guicontrol".
     * Instead of passing "GUICONTROL' to `prefix` as a string, I would pass an object
     * {prefix:"GUICONTROL",replacement:"GuiControl"} to specify the replacement string.
     *
     * @param {Map} [Options.wordReplacements = ""] - A Map object where each key is a string word that might
     * be used within the symbols that will be modified, and the value is the string that those
     * words will be replaced with. `wordReplacements` serves the same purpose as passing an object
     * to `prefix` - some segments might contain multiple words, but {@link ScreamingSnakeToPascal}
     * will always only capitalize the first letter of the segment and the rest will be uncapitalized.
     * For each word in `wordReplacements`, {@link ScreamingSnakeToPascal} will replace it with
     * the corresponding replacement, allowing the caller to specify the replacement. For example,
     * if my code has a symbol GUICONTROL_TYPEINDEX, I could pass
     * `Map("GUICONTROL", "GuiControl", "TYPEINDEX", "TypeIndex")` to `wordReplacements` to direct
     * {@link ScreamingSnakeToPascal} how to modify those words.
     *
     * The `wordReplacement` keys must be an entire segment. Using the GUICONTROL_TYPEINDEX example,
     * I could **not** use `Map("GUI", "Gui", "CONTROL", "Control", "TYPE", "Type", "INDEX", "Index")`.
     * Only `Map("GUICONTROL", "GuiControl", "TYPEINDEX", "TypeIndex")` would be effective for that
     * symbol. This was a necessary design choice to avoid incorrectly modifying words that exist
     * inside of other words.
     *
     * @param {Boolean} [Options.overwrite = false] - If true, overwrites files at the out paths. If false,
     * throws an error if a file exists at an out path. This is ignored if `calculateOnly` is
     * true.
     *
     * @param {Boolean} [Options.calculateOnly = false] - If true, {@link ScreamingSnakeToPascal} does
     * not create the output files; it only performs the calculations.
     *
     * I included this option to help the developer get a list of symbols that will be replaced
     * to make it easier to define a map object to pass to `wordReplacements` so any muilti-word
     * segments can be handled as needed.
     *
     * @param {String} [Options.encoding = ""] - The file encoding. If unset, the default encoding
     * is used.
     *
     * @param {String} [Options.characterClass = "\p{Lu}"] - The character class containing characters
     * that are used in a segment (i.e. non-underscore characters). {@link ScreamingSnakeToPascal}
     * restricts its matches by **not** using the "i" (case-insensitive) option and by matching only
     * with the characters in `characterClass`.
     *
     * The default is unicode property upper case letter.
     *
     * @returns {ScreamingSnakeToPascal} - {@link ScreamingSnakeToPascal} is an array of
     * {@link ScreamingSnakeToPascal.Result} objects, each having the following properties:
     * - in: The input path associated with that object.
     * - out: The output path associated with that object.
     * - symbols: A {@link ScreamingSnakeToPascal.Symbols} object. {@link ScreamingSnakeToPascal.Symbols}
     *   inherits from `Map` and has one additional method,
     *   {@link ScreamingSnakeToPascal.Symbols.Prototype.GetSymbols}.
     * - content: The entire modified content for the file at the input path.
     *
     * The returned {@link ScreamingSnakeToPascal} object has one additional property, "symbols",
     * which is a {@link ScreamingSnakeToPascal.Symbols} object containing all the symbols that were
     * replaced across all the files.
     */
    __New(Options) {
        options := ScreamingSnakeToPascal.Options(Options)
        calculateOnly := options.calculateOnly
        characterClass := options.characterClass
        encoding := options.encoding
        input := options.input
        maxSegments := options.maxSegments
        overwrite := options.overwrite
        prefix := options.prefix
        wordReplacements := options.wordReplacements
        patternBase := '\b{1}\b'
        part := '(_[{2}])([{2}]*)'
        if prefix && not prefix is Array {
            prefix := [ prefix ]
        }
        if not input is Array {
            input := [ input ]
        }
        symbols := this.symbols := ScreamingSnakeToPascal.Symbols()
        for obj in input {
            if !overwrite && !calculateOnly && FileExist(obj.out) {
                throw Error('A file exists at the output path.', , obj.out)
            }
            content := FileRead(obj.in, encoding ?? unset)
            _result := ScreamingSnakeToPascal.Result(obj)
            this.Push(_result)
            _patternBase := patternBase
            if HasProp(obj, 'prefix') {
                if obj.prefix is Array {
                    prefixList := obj.prefix
                } else {
                    prefixList := [ obj.prefix ]
                }
            } else if prefix {
                prefixList := prefix
            } else {
                throw Error('An object does not have a "prefix" property, and the ``prefix`` parameter is not set.')
            }
            for _prefix in prefixList {
                if !IsObject(_prefix) {
                    if StrLen(_prefix) > 1 {
                        prefixList[A_Index] := { prefix: _prefix, replacement: SubStr(_prefix, 1, 1) StrLower(SubStr(_prefix, 2)) }
                    } else {
                        prefixList[A_Index] := { prefix: _prefix, replacement: _prefix }
                    }
                }
            }
            replacementBase := ''
            i := 0
            loop maxSegments {
                i++
                _patternBase := SubStr(_patternBase, 1, -2) part '\b'
                replacementBase .= '$' (i * 2 - 1) '$L' (i * 2)
                for prefixObj in prefixList {
                    pattern := Format(_patternBase, prefixObj.prefix, characterClass)
                    pos := 1
                    while RegExMatch(content, pattern, &match, pos) {
                        pos := match.Pos
                        if wordReplacements {
                            _replacement := RegExReplace(match[0], pattern, prefixObj.replacement replacementBase)
                            for key, val in wordReplacements {
                                if InStr(_replacement, key) {
                                    _replacement := RegExReplace(_replacement,'i)(?<=_|^)' key '(?=_|$)', val)
                                }
                            }
                            _replacement := StrReplace(_replacement, '_', '')
                        } else {
                            _replacement := StrReplace(RegExReplace(match[0], pattern, prefixObj.replacement replacementBase), '_', '')
                        }
                        content := RegExReplace(content, '\b' match[0] '\b', _replacement)
                        symbols.Set(match[0], _replacement)
                        _result.symbols.Set(match[0], _replacement)
                    }
                }
            }
            _result.content := content
            if !calculateOnly {
                f := FileOpen(obj.out, 'w', Encoding ?? unset)
                f.Write(content)
                f.Close()
            }
        }
    }
    GetSymbols(keys := true, values := true) {
        return this.symbols.GetSymbols(keys, values)
    }

    class Options {
        static Default := {
            calculateOnly: false
          , characterClass: '\p{Lu}'
          , encoding: ''
          , input: ''
          , maxSegments: ''
          , overwrite: false
          , prefix: ''
          , wordReplacements: ''
        }
        static Required := [ 'input', 'maxSegments' ]
        static Call(Options) {
            for prop in this.Required {
                if !HasProp(Options, prop) {
                    throw PropertyError('The input options must include property "input" and "maxSegments".')
                }
            }
            o := {}
            d := this.Default
            for prop in d.OwnProps() {
                o.%prop% := HasProp(Options, prop) ? Options.%prop% : d.%prop%
            }
            return o
        }
    }

    class Result {
        __New(input) {
            this.in := input.in
            this.out := input.out
            this.symbols := ScreamingSnakeToPascal.Symbols()
            this.content := ''
        }
        GetSymbols(keys := true, values := true) {
            return this.symbols.GetSymbols(keys, values)
        }
    }
    class Symbols extends Map {
        GetSymbols(keys, values) {
            s := ''
            if keys {
                if values {
                    for key, val in this {
                        s .= key '`t' val '`n'
                    }
                } else {
                    for key in this {
                        s .= key '`n'
                    }
                }
            } else if values {
                for key, val in this {
                    s .= val '`n'
                }
            }
            return s
        }
    }
}

/*

Quick usage template
_____

#include <ScreamingSnakeToPascal>

go()

go() {
    options := {
        calculateOnly: false
      , characterClass: unset
      , encoding: unset
      , input: [
            { in: '', out: A_Temp '\' }
        ]
      , maxSegments: 4
      , overwrite: unset
      , prefix: unset
      , wordReplacements: unset
    }
    result := ScreamingSnakeToPascal(options)
    if options.calculateOnly {
        A_Clipboard := result.GetSymbols(true, false)
    }
    ShowTooltip('done')
}

ShowTooltip(Str) {
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
