/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/JsonToAhk.ahk
    Author: Nich-Cebolla
    License: MIT
*/

; https://github.com/Nich-Cebolla/AutoHotkey-LibV2/tree/main/stringify
#include <PrettyStringifyProps4>
; https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/QuickParse.ahk
#include <QuickParse>

/**
 * @description - Converts a Json string to an AutoHotKey string. Only one of `Json` or `Path` are
 * needed. If both are unset, the clipboard's contents is used.
 * @param {String} [Json] - The json string to convert.
 * @param {String} [Path] - If `Json` is unset, the path to the file containing the json string
 * to convert.
 * @param {String} [Encoding] - If set, and if `Json` is unset, the encoding of the file at `PathInput`.
 * @param {String} [VariableName] - If set, the retun value is prefixed with `VariableName " := "`.
 * @param {String} [Quote = "`""] - The quote character to use with quoted strings.
 * @param {String} [Eol = "`n"] - The end of line character(s).
 * @param {*} [CallbackProps] - A `Func` or callable object to set as `Options.CallbackProps`
 * of {@link PrettyStringifyProps4.Prototype.__New}.
 * @param {Integer} [InitialIndent = 0] - The initial indentation level. All lines except the
 * first line (the opening brace) will minimally have this indentation level. The reason the first
 * line does not is to make it easier to use the output as a value in another string.
 * @param {Integer} [ApproxGreatestDepth = 10] - `ApproxGreatestDepth` is used to approximate
 * the size of each substring to avoid needing to frequently expand the string.
 * @returns {String}
 */
JsonToAhk(Json?, Path?, Encoding?, VariableName?, Quote := '"', Eol := '`n', CallbackProps?, InitialIndent := 0, ApproxGreatestDepth := 10) {
    PrettyStringifyProps4({ Quote: Quote, Eol: Eol, CallbackProps: CallbackProps ?? unset })(QuickParse(Json ?? unset, Path ?? unset, Encoding ?? unset), &Str, InitialIndent, ApproxGreatestDepth)
    if IsSet(VariableName) {
        return VariableName ' := ' Str
    } else {
        return Str
    }
}
