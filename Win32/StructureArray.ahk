/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/Win32/StructureArray.ahk
    Author: Nich-Cebolla
    License: MIT
*/

/*
    This is a template to use when creating a class that is an array of structures. It has all the
    major math worked out. To use it, copy it to a separate file and modify it.
*/

class StructureArray {
    __New(Params?) {
        this.Buffer := Buffer(this.cbSize * Params.Length, 0)
        this.Map := Map()
        this.List := []
        if IsSet(Params) {
            for obj in Params {
                this.__Make(obj, A_Index)
            }
        }
    }
    Add(Params) {
        cbSize := this.cbSize
        if not Params is Array {
            Params := [ Params ]
        }
        if this.Size + cbSize * Params.Length > this.MaxSize {
            buf := Buffer(this.Size + cbSize * Params.Length)
            if buf.Size < this.Size {
                throw Error('Invalid size.', -1)
            }
            DllCall(
                'msvcrt.dll\memmove'
              , 'ptr', buf
              , 'ptr', this
              , 'int', this.Size
              , 'ptr'
            )
            this.Buffer := buf
        }
        i := this.List.Length := this.Map.Count
        for obj in Params {
            this.__Make(obj, ++i)
        }
    }
    Delete(Index, Count := 1) {
        m := this.Map
        if Index < 1 || Index > m.Count {
            throw IndexError('Index out of range.', -1)
        }
        cbSize := this.cbSize
        if cbSize < 1 {
            throw Error('Invalid size.', -1)
        }
        ptr := this.Buffer.Ptr
        list := this.List
        if bytes := (m.Count - Index - Count + 1) * cbSize {
            if bytes < cbSize {
                throw Error('Invalid byte count.', -1)
            }
            offset := cbSize * (Index - 1)
            DllCall(
                'msvcrt.dll\memmove'
              , 'ptr', ptr + offset
              , 'ptr', ptr + offset + cbSize * Count
              , 'int', bytes
              , 'ptr'
            )
        }
        end := Index + Count - 1
        del := []
        bufSize := this.Buffer.Size
        for key, i in m {
            if i >= Index {
                if i <= end {
                    del.Push(key)
                } else {
                    item := list[i]
                    i -= Count
                    item.Ptr := Ptr + (i - 1) * cbSize
                    list[i] := item
                    m.Set(key, i)
                }
            }
        }
        for key in del {
            m.Delete(key)
        }
        list.Length := m.Count
    }
    DeleteKey(Key) {
        return this.Delete(this.Map.Get(Key), 1)
    }
    Get(Index) {
        return this.List[Index]
    }
    GetKey(Key) {
        return this.List[this.Map.Get(Key)]
    }
    GetIndex(Key) {
        return this.Map.Get(Key)
    }
    __Make(Obj, Index) {
        ; this must be overridden
    }
    Ptr => this.Buffer.Ptr
    Size => this.Map.Count * this.cbSize
    MaxSize => this.Buffer.Size
}
