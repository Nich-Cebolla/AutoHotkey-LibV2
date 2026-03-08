
class GetIncludedFile {
    static __New() {
        this.DeleteProp('__New')
        proto := this.Prototype
        proto.encoding := proto.notFound := ''
        proto.patternCountLines := 'S)(?:[\r\n]+|^)(?:[ \t]*;.*|[ \t]*/\*[\w\W]*?\*/|[ \t]+)'
    }
    /**
     * @description - Processes a relative path with any number of ".\" or "..\" segments.
     * @param {VarRef} Path - A variable containing the relative path to evaluate as string.
     * @param {String} [RelativeTo] - The location `Path` is relative to. If unset, the working directory
     * is used. `RelativeTo` can also be relative with "..\" leading segments.
     */
    static ResolveRelativePathRef(&Path, RelativeTo?) {
        if IsSet(RelativeTo) && RelativeTo {
            SplitPath(RelativeTo, , , , , &Drive)
            if !Drive {
                if InStr(RelativeTo, '.\') {
                    w := A_WorkingDir
                    _Process(&RelativeTo, &w)
                } else {
                    RelativeTo := A_WorkingDir '\' RelativeTo
                }
            }
        } else {
            RelativeTo := A_WorkingDir
        }
        if InStr(Path, '.\') {
            _Process(&Path, &RelativeTo)
        } else {
            Path := RelativeTo '\' Path
        }

        _Process(&path, &relative) {
            split := StrSplit(path, '\')
            segments := []
            segments.capacity := split.length
            path := ''
            i := 0
            for s in split {
                if s == '.' {
                    continue
                } else if s == '..' {
                    if Segments.length {
                        segments.RemoveAt(-1)
                    } else {
                        relative := SubStr(relative, 1, InStr(relative, '\', , , -1) - 1)
                    }
                } else {
                    segments.Push(A_Index)
                }
            }
            if segments.length {
                for i in segments {
                    path .= '\' split[i]
                }
                if relative {
                    path := relative path
                } else {
                    _Throw()
                }
            } else if relative {
                path := relative
            } else {
                _Throw()
            }
        }
        _Throw() {
            throw ValueError('Invalid input parameters.', -2)
        }
    }

    /**
     * @desc - Reads a file and identifies each #include or #IncludeAgain statement. Resolves the path to
     * each included file.
     *
     * Use this to get the file paths associated with all of the #include or #IncludeAgain statements
     * in a script, optionally recursing into the included files.
     *
     * There are a few properties of interest:
     * - {@link GetIncludedFile#result} - An array of {@link GetIncludedFile.File} objects, one for
     *   each #include or #IncludeAgain statement encountered during processing and that was associated with a
     *   file path for which `FileExist` returned zero.
     * - {@link GetIncludedFile#notFound} - An array of {@link GetIncludedFile.File} objects, one for
     *   each #include or #IncludeAgain statement encountered during processing and that was associated
     *   with a file path for which `FileExist` returned zero.
     * - {@link GetIncludedFile.Prototype.Unique} - Call this to get a map where each key is a full file
     *   path and each value is an array of {@link GetIncludedFile.File} objects, each representing
     *   an #include or #IncludeAgain statement that resolved to the same file path.
     * - {@link GetIncludedFile.Prototype.CountLines} - Returns the number of lines of code in a project.
     *
     * One {@link GetIncludedFile.File} is created for each #include or #IncludeAgain statement, but
     * each individual file is only read a maximum of one time.
     *
     * {@link GetIncludedFile.File} has the following properties:
     * - Children - An array of {@link GetIncludedFile.File} objects representing #include or #IncludeAgain statements in the file.
     * - FullPath - The full path to the file.
     * - Ignore - Returns 1 if the #include or #IncludeAgain statement had the *i option. Returns 0 otherwise.
     * - IsAgain - Returns 1 if it was an #IncludeAgain statement. Returns 0 if it was an #include statement.
     * - Line - The line number on which the #include or #IncludeAgain statement was encountered.
     * - Match - The `RegExMatchInfo` object generated during processing.
     * - Name - The file name without extension of the file.
     * - Parent - The full path of the script that contained the #include or #IncludeAgain statement.
     * - Path - The unmodified path string from the script's content.
     *
     * The first item in the {@link GetIncludedFile#result} array will not have all of the properties
     * because it will be an item created from the path passed to the `Path` parameter.
     *
     * @class
     *
     * @param {String} Path - The path to the file to analyze. If a relative path is provided, it
     * is assumed to be relative to the current working directory.
     *
     * @param {Boolean} [Recursive = true] - If true, recursively processes all included files.
     * If a file is encountered more than once, a {@link GetIncludedFile.File} object is generated
     * for that encounter but the file does not get processed again.
     *
     * @param {String} [ScriptDir = ""] - The path to the local library as described in the
     * {@link https://www.autohotkey.com/docs/v2/Scripts.htm#lib documentation}. This would be
     * the equivalent of `A_ScriptDir "\lib"` when the script is actually running. Since this function
     * is likely to be used outside of the script's context, the local library must be provided if it
     * is to be included in the search.
     *
     * @param {String} [AhkExeDir = ""] - The path to the standard library as described in the
     * {@link https://www.autohotkey.com/docs/v2/Scripts.htm#lib documentation}. This would be the
     * equivalent of `A_AhkPath "\lib"` when the script is actually running. Since this function is
     * likely to be used outside of the script's context, the standard library must be provided if it
     * is to be included in the search.
     *
     * @param {String} [encoding] - The file encoding to use when reading the files.
     */
    __New(Path, Recursive := true, ScriptDir := '', AhkExeDir := '', encoding?) {
        if !FileExist(Path) {
            throw Error('File not found.', , Path)
        }
        /**
         * @desc - A map where the key is a full file path representing a path that was subject of
         * an `#include` or `#IncludeAgain` statement and the value is an array of
         * {@link GetIncludedFile.File} objects in the order that they were created. The first
         * {@link GetIncludedFile.File} object will be the only object with a property
         * {@link GetIncludedFile.File#children "children"} because each file gets processed only
         * once.
         *
         * Only items representing files that exist are added to this map.
         *
         * @memberof GetIncludedFile
         * @instance
         * @type {Map}
         */
        this.unique := Map()
        unique := this.unique
        unique.caseSense := false
        If IsSet(encoding) {
            this.encoding := encoding
        }
        constructor := GetIncludedFile.ItemConstructor(this)
        ResolveRelativePath := ObjBindMethod(GetIncludedFile, 'ResolveRelativePathRef')
        SplitPath(Path, , , , , &drive)
        if !drive {
            ResolveRelativePath(&Path)
        }
        active := constructor('', Path, '', 0, true)
        /**
         * @desc - An array of {@link GetIncludedFile.File} objects, one for each `#include` or
         * `#IncludeAgain` statement encountered during processing and that was associated with a
         * file path for which `FileExist` returned nonzero. If `FileExist` returned zero, the item
         * was added to {@link GetIncludedFile#notFound}.
         * @memberof GetIncludedFile
         * @instance
         * @type {GetIncludedFile.File[]}
         */
        this.result := [ active ]
        unique.Set(Path, [ active ])
        result := this.result
        notFound := ''
        unique.capacity := result.capacity := Recursive ? 32 : 64
        libDirs := [ A_MyDocuments '\AutoHotkey\lib' ]
        if ScriptDir {
            libDirs.Push(ScriptDir)
        }
        if AhkExeDir {
            libDirs.Push(AhkExeDir)
        }
        if Recursive {
            pending := [  ]
            pending.capacity := result.capacity
            loop {
                SplitPath(active.fullPath, , &cwd)
                ct := 0
                f := FileOpen(active.fullPath, 'r', encoding ?? unset)
                loop {
                    if f.AtEoF {
                        f.Close()
                        break
                    }
                    ct++
                    if RegExMatch(f.ReadLine(), 'iS)^[ \t]*\K#include(?<again>again)?[ \t]+(?<i>\*i[ \t]+)?(?:<(?<lib>[^>]+)>|(?<path>.+))', &match) {
                        _Proc()
                    }
                }
                if pending.length {
                    active := pending.Pop()
                } else {
                    break
                }
            }
        } else {
            SplitPath(active.fullPath, , &cwd)
            ct := 0
            f := FileOpen(active.fullPath, 'r', encoding ?? unset)
            loop {
                if f.AtEoF {
                    f.Close()
                    break
                }
                ct++
                if RegExMatch(f.ReadLine(), 'iS)^[ \t]*\K#include(?<again>again)?[ \t]+(?<i>\*i[ \t]+)?(?:<(?<lib>[^>]+)>|(?<path>.+))', &match) {
                    _Proc()
                }
            }
        }

        return

        _Add(fullPath) {
            if FileExist(fullPath) {
                if unique.Has(fullPath) {
                    item := constructor(match, fullPath, active, ct, true, true)
                    unique.Get(fullPath).Push(item)
                } else {
                    item := constructor(match, fullPath, active, ct, true, false)
                    unique.Set(fullPath, [ item ])
                    if Recursive {
                        pending.Push(item)
                    }
                }
                active.children.Push(item)
                result.Push(item)
            } else {
                item := constructor(match, fullPath, active, ct, false, true)
                active.children.Push(item)
                if notFound {
                    notFound.Push(item)
                } else {
                    /**
                     * @desc - An array of {@link GetIncludedFile.File} objects, one for each `#include` or
                     * `#IncludeAgain` statement encountered during processing and that was associated with a
                     * file path for which `FileExist` returned zero. If `FileExist` returned nonzero, the item
                     * was added to {@link GetIncludedFile#result}.
                     * @memberof GetIncludedFile
                     * @instance
                     * @type {GetIncludedFile.File[]}
                     */
                    this.notFound := [ item ]
                    notFound := this.notFound
                }
            }
        }
        _LibNotFound() {
            item := constructor(match, '', active, ct, false, true)
            active.children.Push(item)
            if notFound {
                notFound.Push(item)
            } else {
                notFound := this.notFound := [ item ]
            }
        }
        _Proc() {
            if _path := match['path'] {
                _path := Trim(StrReplace(_path, '``;', ';'), '"')
                if RegExMatch(_path, '[ \t]+;.*', &match_comment) {
                    _path := StrReplace(_path, match_comment[0], '')
                }
                while RegExMatch(_path, 'iS)%(A_\w+)%', &match_a) {
                    _path := StrReplace(_path, match_a[0], %match_a[1]%)
                }
                SplitPath(_path, , , &ext, , &drive)
                if !drive {
                    ResolveRelativePath(&_path, cwd)
                }
                ; If it is a file path
                if ext {
                    _Add(_path)
                } else {
                    ; change the current working directory
                    cwd := _path
                    active.workingDirectories.Push(match)
                }
            } else {
                lib := match['lib']
                for dir in libDirs {
                    if FileExist(dir '\' lib '.ahk') {
                        _Add(dir '\' lib '.ahk')
                        return
                    }
                }
                lib := SubStr(lib, 1, InStr(lib, '_') - 1)
                for dir in libDirs {
                    if FileExist(dir '\' lib '.ahk') {
                        _Add(dir '\' lib '.ahk')
                        return
                    }
                }
                _LibNotFound()
            }
        }
    }

    /**
     * @desc - Counts the lines of code in the project. Consecutive line breaks are replaced with
     * a single line break before counting. Each individual file is only processed once.
     *
     * @param {Boolean} [CodeLinesOnly = true] - If true, lines that only have a comment are not
     * included in the count.
     *
     * @returns {Integer} - The number of lines.
     */
    CountLines(CodeLinesOnly := true) {
        ct := 0
        if CodeLinesOnly {
            pattern := this.patternCountLines
            if encoding := this.encoding {
                for path in this.GetUnique() {
                    StrReplace(RegExReplace(RegExReplace(FileRead(path, encoding), pattern, '`n'), '\R+', '`n'), '`n', , , &n)
                    ct += n + 1
                }
            } else {
                for path in this.GetUnique() {
                    StrReplace(RegExReplace(RegExReplace(FileRead(path), pattern, '`n'), '\R+', '`n'), '`n', , , &n)
                    ct += n + 1
                }
            }
        } else {
            if encoding := this.encoding {
                for path in this.GetUnique() {
                    StrReplace(RegExReplace(FileRead(path, encoding), '\R+', '`n'), '`n', , , &n)
                    ct += n + 1
                }
            } else {
                for path in this.GetUnique() {
                    StrReplace(RegExReplace(FileRead(path), '\R+', '`n'), '`n', , , &n)
                    ct += n + 1
                }
            }
        }
        return ct
    }

    /**
     * @desc - Returns a `Map` object where each key is a full file path and each value is an array of
     * {@link GetIncludedFile.File} objects, each representing an `#include` or `#IncludeAgain`
     * statement that resolved to the same file path. Only the objects in the
     * {@link GetIncludedFile#result} array are included.
     *
     * @returns {Map}
     */
    GetUnique() {
        return this.unique
    }
    /**
     * @desc - Constructs a string of the contents of the file passed to the parameter `Path`, recursively
     * replacing each `#include` and `#IncludeAgain` statement with the content from the appropriate file.
     * The created string is set to property {@link GetIncludedFile#content}. Only files that
     * were found are represented in the output string. This iterates the files that were not
     * found ({@link GetIncludedFile#notFound}) and, for any of the items that include the **ignore**
     * parameter ("*i"), the `#include` or `#IncludeAgain` statement is replaced with an empty string.
     * For the remainder of the items, the `#include` / `#IncludeAgain` statement is left in the output
     * string and the item is added to the array set to the `outNotFound` variable.
     *
     * @param {VarRef} [outNotFound] - A variable that will receive an array of
     * {@link GetIncludedFile.File} objects as described by this method's description. If all files
     * were accounted for, this variable is set with an empty string.
     *
     * @returns {String} - The combined content.
     */
    Build(&outNotFound?) {
        outNotFound := ''
        if this.result.Length {
            this.result[1].base.stack := []
            if this.notFound {
                s := this.result[1].Build()
                for item in this.notFound {
                    if item.ignore {
                        s := RegExReplace(s, '(?<=[\r\n]|^)\Q' item.match[0] '\E(?=[\r\n]|$)', '', , 1)
                    } else if outNotFound {
                        outNotFound.Push(item)
                    } else {
                        outNotFound := [ item ]
                    }
                }
            } else {
                return this.content := this.result[1].Build()
            }
        } else {
            return this.content := ''
        }
    }

    class File {
        static __New() {
            this.DeleteProp('__New')
            this.collection := Map()
            this.collection.default := ''
            proto := this.Prototype
            proto.children := proto.encoding := proto.unique := ''
        }
        __New(match, fullPath, parent, line, exists, skipped := false) {
            loop 100 {
                id := Random(1, 4294967295)
                if !GetIncludedFile.File.collection.Has(id) {
                    this.id := id
                    GetIncludedFile.File.collection.Set(id, this)
                    ObjRelease(ObjPtr(this))
                    break
                }
            }
            if !this.HasOwnProp('id') {
                throw Error('Failed to produce a unique id.')
            }
            this.match := match
            this.fullPath := fullPath
            SplitPath(fullPath, , , , &name)
            this.name := name
            this.line := line
            this.skipped := skipped
            if parent {
                this.idParent := parent.id
            } else {
                this.idParent := ''
            }
            this.exists := exists
            if exists && !skipped {
                this.children := []
            }
        }
        /**
         * Constructs a string of the file's contents, recursively replacing each #include and
         * #IncludeAgain statement with the content from the appropriate file. The created string
         * is set to property {@link GetIncludedFile.File#content}.
         *
         * @returns {String} - The combined content.
         */
        Build() {
            if this.HasOwnProp('content') {
                return this.content
            }
            this.stack.Push(this)
            s := FileRead(this.fullPath, this.encoding || unset)
            for item in this.children {
                if item.exists {
                    if item.skipped {
                        if item.isAgain {
                            _item := this.unique.Get(item.fullPath)[1]
                            if _item.HasOwnProp('content') {
                                s := RegExReplace(s, '(?<=[\r\n]|^)\Q' item.match[0] '\E(?=[\r\n]|$)', _item.content, , 1)
                            } else {
                                for __item in this.stack {
                                    if item.fullPath = __item.fullPath {
                                        throw Error('Two scripts cannot be mutual dependents with one another.', , '1: ' item.fullPath '; 2: ' __item.fullPath)
                                    }
                                }
                                s := RegExReplace(s, '(?<=[\r\n]|^)\Q' item.match[0] '\E(?=[\r\n]|$)', _item.Build(), , 1)
                            }
                        } else {
                            s := RegExReplace(s, '(?<=[\r\n]|^)\Q' item.match[0] '\E(?=[\r\n]|$)', '', , 1)
                        }
                    } else if item.HasOwnProp('content') {
                        s := RegExReplace(s, '(?<=[\r\n]|^)\Q' item.match[0] '\E(?=[\r\n]|$)', item.content, , 1)
                    } else {
                        for __item in this.stack {
                            if item.fullPath = __item.fullPath {
                                throw Error('Two scripts cannot be mutual dependents with one another.', , '1: ' item.fullPath '; 2: ' __item.fullPath)
                            }
                        }
                        s := RegExReplace(s, '(?<=[\r\n]|^)\Q' item.match[0] '\E(?=[\r\n]|$)', item.Build(), , 1)
                    }
                }
            }
            if this.HasOwnProp('workingDirectories') {
                for match in this.workingDirectories {
                    s := RegExReplace(s, '(?<=[\r\n]|^)\Q' match[0] '\E(?=[\r\n]|$)', '', , 1)
                }
            }
            this.stack.Pop()
            ; This adds a terminator to any multi-line comments at the end of a file that don't have a terminator
            if RegExMatch(s, 'S)(/\*(?:[^*]|\*(?!/))++)$') {
                s .= '*/'
            }
            return this.content := s
        }
        __Delete() {
            ObjPtrAddRef(this)
            if GetIncludedFile.File.collection.Has(this.id) {
                GetIncludedFile.File.collection.Delete(this.id)
            }
        }

        ignore => this.match ? this.match['i'] ? 1 : 0 : 0
        isAgain => this.match ? this.match['again'] ? 1 : 0 : 0
        path => this.match ? this.match['path'] : ''
        parent => GetIncludedFile.File.collection.Get(this.idParent)
        parentFullPath => GetIncludedFile.File.collection.Has(this.idParent) ? GetIncludedFile.File.collection.Get(this.idParent).fullPath : ''
        /**
         * @desc - An array of `RegExMatchInfo` objects where each object is an `#include` or
         * `#IncludeAgain` statement which had a first parameter of a directory (not a file).
         * The purpose of this array is to retain a list of these statements so when
         * {@link GetIncludedFile.File.Prototype.Build} is called, those lines can be removed
         * from the output string.
         * @memberof GetIncludedFile
         * @instance
         * @type {RegExMatchInfo[]}
         */
        workingDirectories {
            Get {
                this.DefineProp('workingDirectories', { Value: [] })
                return this.workingDirectories
            }
        }
    }

    class ItemConstructor extends Class {
        __New(_getIncludedFile) {
            this.Prototype := {
                __Class: GetIncludedFile.File.Prototype.__Class,
                encoding: _getIncludedFile.encoding,
                unique: _getIncludedFile.unique
            }
            this.Prototype.base := GetIncludedFile.File.Prototype
        }
        Call(match, fullPath, parent, line, exists, skipped := false) {
            item := {}
            item.base := this.Prototype
            item.__New(match, fullPath, parent, line, exists, skipped)
            return item
        }
    }
}
