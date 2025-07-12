/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/DirectoryContent.ahk
    Author: Nich-Cebolla
    Version: 1.0.0
    License: MIT
*/

; Needed only if using the `RelativeTo` parameter.
; https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/GetRelativePath.ahk
#include *i <GetRelativePath>

/**
 * @classdesc - Recursively iterates the files and directories within the input directory, creating
 * an object for each file and directory.
 */
class DirectoryContent {
    static DirectoryProperties := ('Name,Path,FullPath,ShortPath,ShortName,Name,Dir,TimeModified'
    ',TimeCreated,TimeAccessed,Attrib,Size,SizeKB,SizeMB')
    static FileProperties := this.DirectoryProperties ',Ext'

    /**
     * The parameters `FileProperties` and `DirectoryProperties` are both comma-delimited, case-insensitive
     * lists of properties to include for each item. The substrings should each correspond to one of
     * the `A_LoopFile<name>` variables available within a `loop Files` loop, and should not have the
     * "A_LoopFile" prefix. If either is unset, the associated static property on the `DirectoryContent`
     * class is used. By default, `DirectoryContent.DirectoryProperties` contains all of the names
     * except "Ext", and `DirectoryContent.FileProperties` contains all of the names.
     * @class
     * @param {String} PathDirectory - A path to the directory for which to retrieve the contents.
     * @param {String} [FileProperties] - A comma-delimited, case-insensitive list of properties to
     * include for each file.
     * @param {String} [DirectoryProperties] - A comma-delimited, case-insensitive list of properties
     * to include for each directory.
     * {@link https://www.autohotkey.com/docs/v2/lib/LoopFiles.htm}.
     * @param {String} [RelativeTo] - The purpose of this parameter is to evaluate each item's path
     * as relative to a parent directory. If set:
     * - The function `GetRelativePath` must be loaded. The value returned by the function
     *  `GetRelativePath` is set to the property "Relative" on each item.
     * - The "keys" within the `DirectoryContent.DirectoryCollection` objects are the relative paths.
     * - If `RelativeTo` is relative, it is assumed to be relative to the current working directory.
     * - `RelativeTo` does not need to exist in the file system. However, if `PathDirectory` does
     * not evaluate as a child of `RelativeTo`,
     * - `RelativeTo` is assumed to be a directory.
     */
    __New(PathDirectory, FileProperties?, DirectoryProperties?, RelativeTo?) {
        this.Path := PathDirectory
        directories := this.Directories := DirectoryContent.DirectoryCollection()
        files := this.Files := DirectoryContent.FileList()
        FileProperties := StrSplit(FileProperties ?? DirectoryContent.FileProperties, ',', '`s`t')
        DirectoryProperties := StrSplit(DirectoryProperties ?? DirectoryContent.DirectoryProperties, ',', '`s`t')
        if IsSet(RelativeTo) {
            GetObj := _GetObjRelative
            SetDirectory := '_SetDirectoryRelative'
            SplitPath(RelativeTo, , , , , &Drive)
            if !Drive {
                ResolveRelativePathRef(&RelativeTo)
            }
        } else {
            GetObj := _GetObj
            SetDirectory := '_SetDirectory'
        }
        SplitPath(PathDirectory, , , , , &Drive)
        if Drive {
            _Recurse(PathDirectory)
        } else {
            _Recurse(A_WorkingDir '\' PathDirectory)
        }

        return

        _Recurse(path) {
            items := DirectoryContent.DirectoryItemCollection()
            %SetDirectory%()
            itemsFiles := items.Files
            itemsDirectories := items.Directories
            loop Files path '\*', 'F' {
                itemsFiles.Push(_GetProperties(FileProperties))
                files.Push(itemsFiles[-1])
            }
            loop Files path '\*', 'D' {
                itemsDirectories.Push(_GetProperties(DirectoryProperties))
                _Recurse(A_LoopFileFullPath)
            }

            return

            _GetProperties(Properties) {
                obj := GetObj()
                for property in Properties {
                    if property {
                        obj.%property% := %'A_LoopFile' property%
                    }
                }
                return obj
            }
            _SetDirectory() {
                directories.Set(path, items)
            }
            _SetDirectoryRelative() {
                directories.Set(GetRelativePath(path, RelativeTo), items)
            }
        }
        _GetObj(*) {
            return {}
        }
        _GetObjRelative() {
            return { Relative: GetRelativePath(A_LoopFileFullPath, RelativeTo) }
        }
    }

    class DirectoryCollection extends Map {
        __New() {
            this.CaseSense := false
        }
    }
    class DirectoryItemCollection {
        __New() {
            this.Directories := DirectoryContent.DirectoryList()
            this.Files := DirectoryContent.FileList()
        }
    }
    class DirectoryList extends Array {
    }
    class FileList extends Array {
    }
}
