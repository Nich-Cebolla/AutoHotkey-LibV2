#include <StringifyAll>

/**
 * @description - This function is modeled after the WinUser.H file on my computer, which was presumably
 * created when Visual Studio was installed. It does a good job with that particular file. It will
 * likely do a decent job with many C++ header files. However, it will not be perfect.
 *
 * How to use
 *
 * This gets all of the symbols and values that begin with "DT_". Note the file may not exist
 * at that location on your computer. Download Visual Studio to get the header files.
 * @example
 *  result := ParseWinuserHeaderFile('C:\Program Files (x86)\Windows Kits\10\Include\10.0.26100.0\um\WinUser.h')
 *  str := ''
 *  for obj in result.Values {
 *      if RegExMatch(obj['symbol'], '^DT_') {
 *          str .= obj['symbol'] ' := ' obj['value'] '`n'
 *      }
 *  }
 *  A_Clipboard := Str
 * @
 */
ParseWinuserHeaderFile(path) {
    content := RegExReplace(FileRead(path, 'utf-8'), '/\*[\w\W]+?\*/|//.*', '')
    patternFunction := '(?<=[\r\n])(?<symbol>\w+)(?<bracket>\((?<params>(?:[^)(]++|(?&bracket))*)\));'
    patternValue := '(?<=[\r\n])#define[ \t]+(?<symbol>\w+)[ \t]+(?<value>(?<index>\(-\d+\))|(?<hex>0x\d+)|(?<decimal>\d+)|(?<mask>\([^-][^)]+\)))'
    patternStruct := '(?<=[\r\n])typedef[ \t]+struct[ \t]+(?<symbol>\w+)\s+(?<bracket>\{(?<members>(?:[^}{]++|(?&bracket))*)\})[ \t]*(?<alias>.*);'
    functions := _GetAll(patternFunction, [])
    values := _GetAll(patternValue, [])
    structs := _GetAll(patternStruct, [])
    pointerTypes := Map()
    n := 0
    loop functions.Length {
        match := functions[A_Index - n]
        if InStr(match[0], '`n') {
            functions[A_Index - n] := FunctionDefinition(match)
        } else {
            functions.RemoveAt(A_Index - n)
            n++
        }
    }
    for match in structs {
        if InStr(match[0], 'tagRawMouse') {
            sleep 1
        }
        structs[A_Index] := StructDefinition(match)
    }

    return { Functions: functions, Structs: structs, Values: values }


    _GetAll(pattern, arr) {
        pos := 1
        arr.Capacity := 256
        while RegExMatch(content, pattern, &Match, pos) {
            pos := Match.Pos + Match.Len
            arr.Push(Match)
        }
        return arr
    }
}


class FunctionDefinition {
    __New(Match) {
        this.Match := Match
        this.Params := FunctionDefinition.Params(Match)
    }
    Symbol => this.Match['symbol']
    Variadic => InStr(this.Match['params'], '...)')

    class Params extends Array {
        __New(Match) {
            for line in StrSplit(Match['params'], '`n', '`r`s`t') {
                if line && line !== '...' {
                    this.Push(FunctionDefinition.Param(StrSplit(line, ' ')))
                }
            }
        }
    }

    class Param extends Array {
        static __New() {
            this.DeleteProp('__New')
            Proto := this.Prototype
            Proto.AnnotationIndex := Proto.TypeIndex := Proto.SymbolIndex := Proto.Const := 0
        }
        static Call(splitLine) {
            if splitLine.Length == 1 {
                splitLine.AnnotationIndex := 1
            } else if splitLine.Length == 2 {
                if SubStr(splitLine[1], 1, 1) = '_' {
                    splitLine.AnnotationIndex := 1
                    splitLine.TypeIndex := 2
                } else {
                    splitLine.TypeIndex := 1
                    splitLine.SymbolIndex := 2
                }
            } else if splitLine.Length == 3 {
                splitLine.AnnotationIndex := 1
                splitLine.TypeIndex := 2
                splitLine.SymbolIndex := 3
            } else if splitLine.Length > 3 {
                newSplitLine := []
                k := 0
                loop splitLine.Length {
                    if ++k > splitLine.Length {
                        break
                    }
                    str := splitLine[k]
                    if InStr(str, 'const') {
                        newSplitLine.Const := 1
                    } else if str == '*' {
                        newSplitLine[-1] .= '*'
                    } else if InStr(str, '(') && !InStr(str, ')') {
                        newSplitLine.Push(str)
                        loop {
                            if ++k > splitLine.Length {
                                break 2
                            }
                            newSplitLine[-1] .= ' ' splitLine[k]
                            if InStr(splitLine[k], ')') {
                                break
                            }
                        }
                    } else {
                        newSplitLine.Push(str)
                    }
                }
                splitLine := newSplitLine
                splitLine.AnnotationIndex := 1
                splitLine.TypeIndex := 2
                splitLine.SymbolIndex := 3
            }
            ObjSetBase(splitLine, FunctionDefinition.Param.Prototype)
            return splitLine
        }
        Annotation => Trim(this.AnnotationIndex ? this[this.AnnotationIndex] : '', ',;')
        Type => Trim(this.TypeIndex ? this[this.TypeIndex] : '', ',')
        Symbol => Trim(this.SymbolIndex ? this[this.SymbolIndex] : '', ',')
        Optional => InStr(this.Annotation, 'opt')
        Pointer => InStr(this.Annotation this.Symbol this.Type, '*')
        MaybeNull => InStr(this.Annotation, 'maybenull')
        Input => InStr(this.Annotation, 'in')
        Out => InStr(this.Annotation, 'out')
        Reserved => InStr(this.Annotation, 'reserved')
        Reads => InStr(this.Annotation, 'reads')
        Writes => InStr(this.Annotation, 'writes')
        ReadsBytes => this.Reads && InStr(this.Annotation, 'bytes')
        WritesBytes => this.Writes && InStr(this.Annotation, 'bytes')
        ReadsWhat => this.Reads ? SubStr(this.Annotation, InStr(this.Annotation, '(') + 1, InStr(this.Annotation, ')') - InStr(this.Annotation, '(') - 1) : 0
        WritesWhat => this.Writes ? SubStr(this.Annotation, InStr(this.Annotation, '(') + 1, InStr(this.Annotation, ')') - InStr(this.Annotation, '(') - 1) : 0
    }
}

class StructDefinition {
    __New(Match) {
        this.Match := Match
        members := StrSplit(RegExReplace(Match['members'], ' +', ' '), '`n', '`r`s`t')
        members.RemoveAt(1)
        if members[1] == '{' {
            members.RemoveAt(1)
        }
        index := 0
        this.Members := StructDefinition.Members(&index, members, [])
    }
    Symbol => this.Match['symbol']

    class Members extends Array {
        static __New() {
            this.DeleteProp('__New')
            this.Prototype.Symbols := ''
        }
        static Call(&index, splitLines, container) {
            flag_no_mac := flag_windows := flag_windows_else := false
            loop {
                if ++index > splitLines.Length {
                    ObjSetBase(container, StructDefinition.Members.Prototype)
                    return container
                }
                if member := splitLines[index] {
                    if SubStr(member, 1, 1) == '#' {
                        if InStr(member, '#else') {
                            if flag_no_mac {
                                flag_no_mac := false
                                loop {
                                    if InStr(splitLines[++index], '#endif') {
                                        continue 2
                                    }
                                }
                            } else if flag_windows {
                                flag_windows_else := true
                            } else {
                                sleep 1
                            }
                        } else if InStr(member, '#endif') {
                            flag_no_mac := flag_windows := false
                        } else if InStr(member, '#ifdef _MAC') {
                            loop {
                                line := splitLines[++index]
                                if InStr(line, '#else') || InStr(line, '#endif') {
                                    continue 2
                                }
                            }
                        } else if InStr(member, '#ifndef _MAC') {
                            flag_no_mac := true
                        } else if RegExMatch(member, '#if\(WINVER (?<inequality>\S+) (?<version>\w+)', &MatchWindows) {
                            flag_windows := MatchWindows
                        }
                        continue
                    }
                    if index !== splitLines.Length && (InStr(member, '{') || RegExMatch(member, '\b(?:struct|union)\b')) {
                        if InStr(member, 'union') {
                            t := 'union'
                        } else if InStr(member, 'struct') {
                            t := 'struct'
                        } else {
                            sleep 1
                        }
                        if InStr(splitLines[index + 1], '{') {
                            ++index
                        }
                        container.Push(StructDefinition.Members(&index, splitLines, []))
                        if IsSet(t) {
                            container[-1].DefineProp('Type', { Value: t })
                            t := unset
                        }
                    } else if InStr(member, '{') {
                        sleep 1
                    } else if InStr(member, '}') {
                        container.Symbols := StrSplit(SubStr(member, 3), ' ', '`t;,')
                        ObjSetBase(container, StructDefinition.Members.Prototype)
                        return container
                    } else if RegExMatch(member, '\w+\[[^\]]+\]', &MatchBracket) {
                        member := StrSplit(StrReplace(member, MatchBracket[0], '$$'), ' ', ';,')
                        for item in member {
                            if item = '$$' {
                                member[A_Index] := MatchBracket[0]
                                break
                            }
                            container.Push(StructDefinition.Member(member))
                        }
                    } else {
                        container.Push(StructDefinition.Member(StrSplit(member, ' ', '`s`t;,')))
                    }
                    container[-1].FlagWindows := flag_windows
                    container[-1].FlagWindowsElse := flag_windows_else
                }
            }
        }
        Symbol => this.Symbols ? this.Symbols[1] : ''
    }
    class Member extends Array {
        static __New() {
            this.DeleteProp('__New')
            Proto := this.Prototype
            Proto.TypeIndex := Proto.SymbolIndex := Proto.SizeIndex := Proto.Constant := 0
        }
        static Call(splitMember) {
            if splitMember.Length == 3 {
                if splitMember[1] = 'struct' {
                    splitMember.TypeIndex := 2
                    splitMember.SymbolIndex := 3
                } else if SubStr(splitMember[1], 1, 1) = '_' {
                    splitMember.SizeIndex := 1
                    splitMember.TypeIndex := 2
                    splitMember.SymbolIndex := 3
                } else if splitMember[1] = 'CONST' {
                    splitMember.Constant := true
                    splitMember.TypeIndex := 1
                    splitMember.SymbolIndex := 2
                }
            } else if splitMember.Length == 2 {
                splitMember.TypeIndex := 1
                splitMember.SymbolIndex := 2
            } else if splitMember.Length > 3 {
                splitMember.DefineProp('Type', { Value: splitMember.RemoveAt(1) })
            } else {
                sleep 1
            }
            ObjSetBase(splitMember, this.Prototype)
            return splitMember
        }
        Type => this.TypeIndex ? this[this.TypeIndex] : ''
        Symbol => this.SymbolIndex ? this[this.SymbolIndex] : ''
        SizeOf => this.SizeIndex ? this[this.SizeIndex] : ''
        UnknownType => InStr(this.Type, 'void')
        Pointer => InStr(this.Type this.Symbol, '*')
        Struct => InStr(this[1], 'struct')
    }
    class Union {
        __New(Symbol, Lines) {
            this.Symbol := Trim(Symbol, ';')
            this.Members := []
            for member in Lines {
                if member {
                    this.Members.Push(StructDefinition.Member(StrSplit(member, ' ', '`s`t;')))
                }
            }
        }
    }
}
