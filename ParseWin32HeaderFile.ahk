/*
    Github: https://github.com/Nich-Cebolla/ParseCsv-AutoHotkey/blob/main/ParseWin32HeaderFile.ahk
    Author: Nich-Cebolla
    License: MIT
*/

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
ParseWinuserHeaderFile(Str?, Path?, Encoding := 'utf-8') {
    if !IsSet(Str) {
        if IsSet(Path) {
            str := FileRead(Path, Encoding)
        } else {
            str := A_Clipboard
        }
    }
    content := RegExReplace(str, '/\*[\w\W]+?\*/|//.*', '') ; remove comments
    patternFunction := '(?<=[\r\n]|^)(?<symbol>\w+)(?<bracket>\((?<params>(?:[^)(]++|(?&bracket))*)\));'
    patternValue := '(?<=[\r\n]|^)#define[ \t]+(?<symbol>\w+)[ \t]+(?<value>(?<index>\(-\d+\))|(?<hex>0x\d+)|(?<decimal>\d+)|(?<mask>\([^-][^)]+\)))'
    patternStruct := '(?<=[\r\n]|^)typedef[ \t]+struct[ \t]+(?<symbol>\w+)\s+(?<bracket>\{(?<members>(?:[^}{]++|(?&bracket))*)\})[ \t]*(?<alias>.*);'
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
    static __New() {
        this.DeleteProp('__New')
        this.Prototype.NoOffsets := 0
    }
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
    /**
     * This is not fully tested. It is intended to be a helper for programmatically converting
     * windows header content into AHK code, and the output should be inspected visually if used.
     *
     * Attempts to calculate the members' offsets and alignment padding. If performing the
     * calculation is currently not possible (due to missing information internally) then
     * the property "NoOffsets" is set with 1 and `StructDefinition.Prototype.CalculateOffsets` returns
     * 1.
     * @returns {Integer} - If calculating the offsets is currently not possible, returns 1. Else,
     * returns 0.
     */
    CalculateOffsets() {
        flag_no_offsets := greatestSize := 0
        members := this.Members
        for member in members {
            if member.Size == -1 {
                return this.NoOffsets := 1
            } else {
                if greatestSize == 'A_PtrSize' {
                    if member.Size == '16' || member.Size == '8' {
                        greatestSize := member.Size
                    }
                } else {
                    switch member.Size {
                        case 'A_PtrSize':
                            if greatestSize <= 4 {
                                greatestSize := member.Size
                            }
                        default:
                            if greatestSize < member.Size {
                                greatestSize := member.Size
                            }
                    }
                }
            }
        }
        A_PtrSize_count := offset := 0
        loop members.Length - 1 {
            member := members[A_Index]
            next := members[A_Index + 1]
            ; handle alignment padding
            _Proc(member, next.Size)
            if member.EffectiveSize == 'A_PtrSize' {
                A_PtrSize_count++
            } else if IsNumber(member.EffectiveSize) {
                offset += member.EffectiveSize
            } else {
                throw Error('There is a logical error in the script.', -1)
            }
        }
        _Proc(members[-1], greatestSize)
        if members[-1].EffectiveSize == 'A_PtrSize' {
            A_PtrSize_count++
        } else if IsNumber(members[-1].EffectiveSize) {
            offset += members[-1].EffectiveSize
        } else {
            throw Error('There is a logical error in the script.', -1)
        }
        this.cbSize := _GetOffset()

        return 0

        _GetOffset() {
            return A_PtrSize_Count ? offset ' + A_PtrSize * ' A_PtrSize_Count : offset
        }
        _Proc(member, alignment) {
            switch alignment {
                case 'A_PtrSize':
                    r4 := Mod(offset + A_PtrSize_count * 4 + (member.Size == 'A_PtrSize' ? 4 : member.Size), 4)
                    r8 := Mod(offset + A_PtrSize_count * 8 + (member.Size == 'A_PtrSize' ? 8 : member.Size), 8)
                    if r4 || r8 {
                        if member.Size == '4' {
                            ; Padding can be represented by using "A_PtrSize"
                            member.SetCalculatedValues(_GetOffset(), 'A_PtrSize', '+4 on x64 only')
                        } else if member.Size == '2' || member.Size == '1' {
                            ; Padding varies between architectures
                            member.SetCalculatedValues(_GetOffset(), member.Size ' + A_PtrSize - ' member.Size, '+ variable padding')
                        } else {
                            ; Only size values of 4, 2 or 1 should be passed through this block
                            throw Error('A logical error exists in the script.', -1)
                        }
                    } else {
                        member.SetCalculatedValues(_GetOffset())
                    }
                case '8':
                    r4 := Mod(offset + A_PtrSize_count * 4 + (member.Size == 'A_PtrSize' ? 4 : member.Size), alignment)
                    r8 := Mod(offset + A_PtrSize_count * 8 + (member.Size == 'A_PtrSize' ? 8 : member.Size), alignment)
                    if r4 || r8 {
                        ; Padding varies between architectures
                        member.SetCalculatedValues(_GetOffset(), member.Size ' + (A_PtrSize == 8 ? ' r8 ' : ' r4 ')', '+ variable padding')
                    } else {
                        member.SetCalculatedValues(_GetOffset())
                    }
                case '4', '2':
                    ; Preceding A_PtrSize members won't impact the need for / value of padding
                    if r := Mod(offset + (member.Size == 'A_PtrSize' ? 0 : member.Size), alignment) {
                        member.SetCalculatedValues(_GetOffset(), member.Size ' + ' r, '+ ' r)
                    } else {
                        member.SetCalculatedValues(_GetOffset())
                    }
            }
        }
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
            this.Sizes := Map()
            this.Sizes.CaseSense := false
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
        /**
         * Called by `StructDefinition.Prototype.CalculateOffsets`.
         * @param {String} Offset - A string representing the byte offset.
         * @param {String} [EffectiveSize] - A string representing the size + alignment padding.
         * If unset, the property "EffectiveSize" is defined with a function that returns the
         * value of the property "Size".
         * @param {String} [Padding = ""] - A string describing the padding that is added to the
         * size.
         */
        SetCalculatedValues(Offset, EffectiveSize?, Padding := '') {
            this.Offset := Offset
            if IsSet(EffectiveSize) {
                this.EffectiveSize := EffectiveSize
            } else {
                this.DefineProp('EffectiveSize', { Get: _EffectiveSize })
            }
            this.Padding := Padding

            return

            _EffectiveSize(Self) {
                return Self.Size
            }
        }
        AhkType {
            Get {
                switch this.Size {
                    case 'A_PtrSize': return 'ptr'
                    case '8': return InStr(this.Type, 'int') ? 'int64' : 'double'
                    case '4': return this.Type = 'int' ? 'int' : 'uint'
                    case '2': return this.Type = 'word' || this.Type = 'ushort' ? 'ushort' : 'short'
                    case '1': return this.Type = 'byte' || this.Type = 'uchar' ? 'uchar' : 'char'
                }
            }
        }
        Pointer => InStr(this.Type this.Symbol, '*')
        ; Currently supports only winuser.h types and basic types
        Size => this.TypeIndex ? Win32StructGetMemberSize(this.Type) : ''
        SizeOf => this.SizeIndex ? this[this.SizeIndex] : ''
        Struct => InStr(this[1], 'struct')
        Symbol => this.SymbolIndex ? this[this.SymbolIndex] : ''
        Type => this.TypeIndex ? this[this.TypeIndex] : ''
        UnknownType => InStr(this.Type, 'void')
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

class Win32StructGetMemberSize {
    static __New() {
        this.DeleteProp('__New')
        this.Types := Map()
        this.Types.CaseSense := false
        this.Types.Default := -1
        this.Types.Set(
            'ATOM', '2'
          , 'BOOL', '4'
          , 'BYTE', '1'
          , 'CHAR', '1'
          , 'COLORREF', '4'
          , 'DWORD', '4'
          , 'DWORD_PTR', 'A_PtrSize'
          , 'HANDLE', 'A_PtrSize'
          , 'HBITMAP', 'A_PtrSize'
          , 'HBRUSH', 'A_PtrSize'
          , 'HCURSOR', 'A_PtrSize'
          , 'HDC', 'A_PtrSize'
          , 'HICON', 'A_PtrSize'
          , 'HINSTANCE', 'A_PtrSize'
          , 'HMENU', 'A_PtrSize'
          , 'HMONITOR', 'A_PtrSize'
          , 'HTREEITEM', 'A_PtrSize'
          , 'HWND', 'A_PtrSize'
          , 'INT32', '4'
          , 'LCID', '4'
          , 'LOGFONTA', 'A_PtrSize'
          , 'LOGFONTW', 'A_PtrSize'
          , 'LONG', '4'
          , 'LPARAM', 'A_PtrSize'
          , 'LPCSTR', 'A_PtrSize'
          , 'LPCWSTR', 'A_PtrSize'
          , 'LPSTR', 'A_PtrSize'
          , 'LPVOID', 'A_PtrSize'
          , 'LPWSTR', 'A_PtrSize'
          , 'LRESULT', 'A_PtrSize'
          , 'MONITORINFO', '40'
        ;   , 'MOUSEHOOKSTRUCT', '8 + A_PtrSize * 3'
          , 'MSGBOXCALLBACK', 'A_PtrSize'
          , 'PEN_FLAGS', '4'
          , 'PEN_MASK', '4'
          , 'PFNTVCOMPARE', 'A_PtrSize'
          , 'POINT', '8'
          , 'POINTER_BUTTON_CHANGE_TYPE', '4'
          , 'POINTER_DEVICE_CURSOR_TYPE', '4'
          , 'POINTER_DEVICE_TYPE', '4'
          , 'POINTER_FLAGS', '4'
        ;   , 'POINTER_INFO', '72 + A_PtrSize * 2'
          , 'POINTER_INPUT_TYPE', '4'
          , 'POINTS', '4'
          , 'PVOID', 'A_PtrSize'
          , 'PWINDOWPOS', 'A_PtrSize'
        ;   , 'RAWINPUTHEADER', '8 + A_PtrSize * 2'
        ;   , 'RECT', '16'
          , 'TOUCH_FLAGS', '4'
          , 'TOUCH_MASK', '4'
          , 'UINT', '4'
          , 'UINT16', '2'
          , 'UINT32', '4'
          , 'UINT64', '8'
          , 'UINT_PTR', 'A_PtrSize'
          , 'ULONG', '4'
          , 'ULONGLONG', '8'
          , 'ULONG_PTR', 'A_PtrSize'
          , 'USHORT', '2'
          , 'WCHAR', '1'
          , 'WNDPROC', 'A_PtrSize'
          , 'WORD', '2'
          , 'WPARAM', 'A_PtrSize'
          , 'const', -1
          , 'float', '4'
          , 'int', '4'
          , 'struct', -1
          , 'union', -1
        )
    }
    static Call(typeStr) {
        return this.Types.Get(typeStr)
    }
}


GetMemberTypes(parsedHeader) {
    unique := Map()
    for struct in parsedHeader.Structs {
        for member in struct.Members {
            if !unique.Has(member.Type) {
                unique.Set(member.Type, Map())
            }
            u := unique.Get(member.Type)
            if !u.Has(struct.Symbol) {
                u.Set(struct.Symbol, 1)
            }
        }
    }
    s := ''
    for t, u in unique {
        s .= t ' :: '
        for n in u {
            if A_Index == 1 {
                s .= n
            } else {
                s .= '; ' n
            }
        }
        s .= '`n'
    }
    return s
}
