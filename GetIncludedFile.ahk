
/**
 * Use this to get the file paths associated with all of the #include or #IncludeAgain statements
 * in a script, optionally recursing into the included files.
 *
 * There are a few properties of interest:
 * - {@link GetIncludedFile#Result} - An array of {@link GetIncludedFile.File} objects, one for each
 * #include or #IncludeAgain statement encountered during processing and that was associated with a
 * file path for which `FileExist` returned zero.
 * - {@link GetIncludedFile#NotFound} - An array of {@link GetIncludedFile.File} objects, one for
 * each #include or #IncludeAgain statement encountered during processing and that was associated
 * with a file path for which `FileExist` returned zero.
 * - {@link GetIncludedFile.Prototype.Unique} - Call this to get a map where each key is a full file
 * path and each value is an array of {@link GetIncludedFile.File} objects, each representing an
 * #include or #IncludeAgain statement that resolved to the same file path.
 *
 * One {@link GetIncludedFile.File} is created for each #include or #IncludeAgain statement, but
 * each individual file is only read a maximum of one time.
 *
 * {@link GetIncludedFile.File} has the following properties:
 * - Match - The `RegExMatchInfo` object generated during processing.
 * - FullPath - The full path to the file.
 * - Name - The file name without extension of the file.
 * - Line - The line number on which the #include or #IncludeAgain statement was encountered.
 * - Parent - The full path of the script that contained the #include or #IncludeAgain statement.
 * - Children - An array of {@link GetIncludedFile.File} objects representing #include or #IncludeAgain
 *   statements in the file.
 * - IsAgain - Returns 1 if it was an #IncludeAgain statement. Returns 0 if it was an #include statement.
 * - Path - The unmodified path string from the script's content.
 *
 * The first item in the {@link GetIncludedFile#Result} array will not have all of the properties
 * because it will be an item created from the path passed to the `Path` parameter.
 */
class GetIncludedFile {
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
            segments.Capacity := split.Length
            path := ''
            i := 0
            for s in split {
                if s == '.' {
                    continue
                } else if s == '..' {
                    if Segments.Length {
                        segments.RemoveAt(-1)
                    } else {
                        relative := SubStr(relative, 1, InStr(relative, '\', , , -1) - 1)
                    }
                } else {
                    segments.Push(A_Index)
                }
            }
            if segments.Length {
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
     * Reads a file and identifies each #include or #IncludeAgain statement. Resolves the path to
     * each included file.
     * @param {String} Path - The path to the file to analyze. If a relative path is provided, it
     * is assumed to be relative to the current working directory.
     * @param {Boolean} [Recursive = true] - If true, recursively processes all included files.
     * If a file is encountered more than once, a {@link GetIncludedFile.File} object is generated
     * for that encounter but the file does not get processed again.
     * @param {String} [ScriptDir = ""] - The path to the local library as described in the
     * {@link https://www.autohotkey.com/docs/v2/Scripts.htm#lib documentation}. This would be
     * the equivalent of `A_ScriptDir "\lib"` when the script is actually running. Since this function
     * is likely to be used outside of the script's context, the local library must be provided if it
     * is to be included in the search.
     * @param {String} [AhkExeDir = ""] - The path to the standard library as described in the
     * {@link https://www.autohotkey.com/docs/v2/Scripts.htm#lib documentation}. This would be the
     * equivalent of `A_AhkPath "\lib"` when the script is actually running. Since this function is
     * likely to be used outside of the script's context, the standard library must be provided if it
     * is to be included in the search.
     * @param {String} [Encoding] - The file encoding to use when reading the files.
     * @returns {GetIncludedFile}
     */
    __New(Path, Recursive := true, ScriptDir := '', AhkExeDir := '', Encoding?) {
        if !FileExist(Path) {
            throw Error('File not found.', , Path)
        }
        constructor := GetIncludedFile.File
        ResolveRelativePath := ObjBindMethod(GetIncludedFile, 'ResolveRelativePathRef')
        /**
         * An array of {@link GetIncludedFile.File} objects, one for each #include or #IncludeAgain
         * statement encountered during processing and that was associated with a file path for
         * which `FileExist` returned nonzero. If `FileExist` returned zero, the item was added to
         * {@link GetIncludedFile#NotFound}.
         * @memberof GetIncludedFile
         * @instance
         * @type {GetIncludedFile.File[]}
         */
        this.Result := []
        /**
         * An array of {@link GetIncludedFile.File} objects, one for each #include or #IncludeAgain
         * statement encountered during processing and that was associated with a file path for
         * which `FileExist` returned zero. If `FileExist` returned nonzero, the item was added to
         * {@link GetIncludedFile#NotFound}.
         * @memberof GetIncludedFile
         * @instance
         * @type {GetIncludedFile.File[]}
         */
        this.NotFound := []
        result := this.Result
        notFound := this.NotFound
        read := Map()
        read.CaseSense := false
        SplitPath(Path, , , , , &drive)
        if !drive {
            path := ResolveRelativePath(&Path)
        }
        pending := [ constructor('', path, '', 0) ]
        result.Push(pending[-1])
        result.Capacity := pending.Capacity := notFound.Capacity := Recursive ? 32 : 64
        if ScriptDir {
            libDirs := [ ScriptDir ]
        } else {
            libDirs := [ ]
        }
        libDirs.Push(A_MyDocuments '\AutoHotkey\lib')
        if AhkExeDir {
            libDirs.Push(AhkExeDir)
        }
        if Recursive {
            loop {
                if !pending.Length {
                    break
                }
                active := pending.Pop()
                SplitPath(active.FullPath, , &cwd)
                read.Set(active.FullPath, 1)
                ct := 0
                f := FileOpen(active.FullPath, 'r', Encoding ?? unset)
                loop {
                    if f.AtEoF {
                        f.Close()
                        break
                    }
                    ct++
                    line := f.ReadLine()
                    if RegExMatch(line, 'iS)^[ \t]*\K#include(?<again>again)?[ \t]+(?:<(?<lib>[^>]+)>|(?<path>.+))', &match) {
                        if _path := match['path'] {
                            _path := Trim(StrReplace(_path, '``;', ';'), '"')
                            if RegExMatch(_path, '[ \t]+;.*', &match_comment) {
                                _path := StrReplace(_path, match_comment[0], '')
                            }
                            while RegExMatch(_path, 'iS)%(A_(?:AhkPath|AppData|AppDataCommon|'
                            'ComputerName|ComSpec|Desktop|DesktopCommon|IsCompiled|LineFile|MyDocuments|'
                            'ProgramFiles|Programs|ProgramsCommon|ScriptDir|ScriptFullPath|ScriptName|'
                            'Space|StartMenu|StartMenuCommon|Startup|StartupCommon|Tab|Temp|UserName|'
                            'WinDir))%', &match_a) {
                                _path := StrReplace(match_a[0], %match_a[1]%)
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
                            }
                        } else {
                            lib := match['lib']
                            loop 2 {
                                for dir in libDirs {
                                    if FileExist(dir '\' lib '.ahk') {
                                        _Add(dir '\' lib '.ahk')
                                        continue 3
                                    }
                                }
                                lib := SubStr(lib, 1, InStr(lib, '_') - 1)
                            }
                        }
                    }
                }
            }
        } else {
            active := pending.Pop()
            SplitPath(active.FullPath, , &cwd)
            ct := 0
            f := FileOpen(active.FullPath, 'r', Encoding ?? unset)
            loop {
                if f.AtEoF {
                    f.Close()
                    break
                }
                ct++
                line := f.ReadLine()
                if RegExMatch(line, 'iS)^[ \t]*\K#include(?<again>again)?[ \t]+(?:<(?<lib>[^>]+)>|(?<path>.+))', &match) {
                    if _path := match['path'] {
                        _path := Trim(StrReplace(_path, '``;', ';'), '"')
                        if RegExMatch(_path, '[ \t]+;.*', &match_comment) {
                            _path := StrReplace(_path, match_comment[0], '')
                        }
                        while RegExMatch(_path, 'iS)%(A_(?:AhkPath|AppData|AppDataCommon|'
                        'ComputerName|ComSpec|Desktop|DesktopCommon|IsCompiled|LineFile|MyDocuments|'
                        'ProgramFiles|Programs|ProgramsCommon|ScriptDir|ScriptFullPath|ScriptName|'
                        'Space|StartMenu|StartMenuCommon|Startup|StartupCommon|Tab|Temp|UserName|'
                        'WinDir))%', &match_a) {
                            _path := StrReplace(match_a[0], %match_a[1]%)
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
                        }
                    } else {
                        lib := match['lib']
                        loop 2 {
                            for dir in libDirs {
                                if FileExist(dir '\' lib '.ahk') {
                                    _Add(dir '\' lib '.ahk')
                                    continue 3
                                }
                            }
                            lib := SubStr(lib, InStr(lib, '_') + 1)
                        }
                    }
                }
            }
            f.Close()
        }

        return

        _Add(fullPath) {
            item := constructor(match, fullPath, active.FullPath, ct)
            active.Children.Push(item)
            if FileExist(fullPath) {
                result.Push(item)
                if !read.Has(fullPath) {
                    pending.Push(item)
                }
            } else {
                notFound.Push(item)
            }
        }
    }

    GetUnique() {
        if !this.HasOwnProp('Unique') {
        /**
         * A map where each key is a full file path and each value is an array of {@link GetIncludedFile.File}
         * objects, each representing an #include or #IncludeAgain statement that resolved to the
         * same file path.
         * @memberof GetIncludedFile
         * @instance
         * @type {Map}
         */
            this.Unique := Map()
            unique := this.Unique
            unique.CaseSense := false
            for item in this.Result {
                if unique.Has(item.FullPath) {
                    unique.Get(item.FullPath).Push(item)
                } else {
                    unique.Set(item.FullPath, [ item ])
                }
            }
        }
        return this.Unique
    }

    class File {
        __New(match, fullPath, parent, line) {
            this.Match := match
            this.FullPath := fullPath
            SplitPath(fullPath, , , , &name)
            this.Name := name
            this.Line := line
            this.Parent := parent
            this.Children := []
        }
        IsAgain => this.Match ? this.Match['again'] ? 1 : 0 : 0
        Path => this.Match ? this.Match['path'] : ''
    }
}
