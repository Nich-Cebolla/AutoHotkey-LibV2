/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/ParseObjectPath.ahk
    Author: Nich-Cebolla
    License: MIT
*/

/**
 * @description - Parses a string object path and returns the value.
 * @param {String} Str - The object path.
 * @param {*} [InitialObj] - If set, the object path will be parsed as a property / item of this object.
 * @returns {*} - The value.
 *
 * @example
 * #include <ParseObjectPath>
 * ; Basic usage
 * obj := {
 *     prop1: [1, 2, Map(
 *             "key1", "value1",
 *             "key2", {prop2: 2, prop3: [3, 4]}
 *         )
 *     ]
 * }
 * Path := "obj.prop1[3][`"key2`"].prop3"
 * Obj := ParseObjectPath(Path)
 * OutputDebug(Obj[2] "`n") ; 4
 *
 * ; Usage with classes
 * class test {
 *     static obj := {
 *         prop: Map(
 *             'arr', [ { prop: [ 10, Map('key', { 😊: 'emoji' }) ] } ]
 *         )
 *     }
 * }
 * val := GetObjectFromString("test.obj.prop[`"arr`"][1].prop[2][`"key`"].😊")
 * OutputDebug(val) ; emoji
 *
 * ; Usage with an input object
 * Obj := {
 *     Prop1: [1, 2, Map(
 *             "key1", "value1",
 *             "key2", {prop2: 2, prop3: [3, 4]}
 *         )
 *     ]
 * }
 * Path := "[3][`"key2`"].prop3"
 * Arr := Obj.Prop1
 * InnerArr := ParseObjectPath(Path, Arr)
 * OutputDebug(InnerArr[2] "`n") ; 4
 * @
 *
 */
ParseObjectPath(Str, InitialObj?) {
    if IsSet(InitialObj) {
        NewObj := InitialObj
        Pos := 1
    } else {
        RegExMatch(Str, '^(?:[\p{L}_0-9]|[^\x00-\x7F\x80-\x9F])+', &InitialSegment)
        Pos := InitialSegment.Pos + InitialSegment.Len
        NewObj := %InitialSegment[0]%
    }
    RegExMatch(
        Str
      , '(?:'
            '(?:\.|^)'
            '\K'
            '(?:'
                '[\p{L}_0-9]'
            '|'
                '[^\x00-\x7F\x80-\x9F]'
            ')+'
            '(?COnProp)'
        '|'
            '\[[ \t]*'
            '(?<quote>[`'"])'
            '(?<quoted>.*?)'
            '(?<!``)'
            '(?:````)*'
            '\g{quote}'
            '(?COnQuoted)'
            '\]'
        '|'
            '\[[ \t]*'
            '(?<key>.+?)'
            '[ \t]*\]'
            '(?COnKey)'
        ')+'
      ,
      , Pos
    )

    return NewObj

    OnProp(Match, *) {
        NewObj := NewObj.%Match[0]%
    }
    OnKey(Match, *) {
        NewObj := NewObj[Match['key']]
    }
    OnQuoted(Match, *) {
        NewObj := NewObj[Match['quoted']]
    }
}
