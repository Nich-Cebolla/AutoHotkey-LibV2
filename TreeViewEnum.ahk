﻿
/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/TreeViewEnumDescendents.ahk
    Author: Nich-Cebolla
    License: MIT
*/


/**
 * @description - Recursively enumerates TreeView nodes. This can be called in 1-param or
 * 2-param mode. In 1-param mode, the variable receives the node id. In 2-param mode, the
 * first variable receives the node id and the second variable receives the parent node id.
 *
 * @example
 *  ; Assume an object MyTreeView already was defined
 *  for id, parent in TreeViewEnumDescendents(MyTreeView, MyTreeView.GetSelection(), 1, 0) {
 *      if InStr(MyTreeView.GetText(id), 'Some phrase') {
 *          MsgBox('Found the phrase.')
 *      }
 *  }
 * @
 *
 * @param {Gui.TreeView} TreeViewObj - The TreeView object.
 * @param {Integer} [ItemId = 0] - The node to start enumerating from. Neither this node nor its
 * siblings are included in the enumeration; only descendents.
 * @param {Boolean} [ExpandedOnly = false] - When true, only nodes that are expanded have their
 * children enumerated. When false, a node's expanded state has no effect on the enumeration.
 * @param {Boolean} [NonParentsOnly = false] - When true, parents are skipped. Their children are
 * still enumerated, but the caller never receives the parent. When false, parent nodes are included.
 */
TreeViewEnumDescendents(TreeViewObj, ItemId := 0, ExpandedOnly := false, NonParentsOnly := false, *) {
    Stack := [ItemId]
    flag_first := true
    if ExpandedOnly {
        if NonParentsOnly {
            Enum := _EnumExpandedAndNonParentsOnly
        } else {
            Enum := _EnumExpandedOnly
        }
    } else if NonParentsOnly {
        Enum := _EnumNonParentsOnly
    } else {
        Enum := _Enum
    }
    ObjSetBase(Enum, Enumerator.Prototype)
    Enum.Stack := Stack
    return Enum

    _Enum(&Id, &parent?) {
        if Id := TreeViewObj.GetChild(stack[-1]) {
            parent := stack[-1]
            stack.Push(Id)
            return 1
        } else if stack.Length > 1 {
            loop {
                if Id := TreeViewObj.GetNext(stack[-1]) {
                    stack[-1] := Id
                    parent := stack[-2]
                    return 1
                } else {
                    stack.Pop()
                    if stack.Length <= 1 {
                        return 0
                    }
                }
            }
        } else {
            return 0
        }
    }
    _EnumExpandedOnly(&Id, &parent?) {
        if flag_first {
            if Id := TreeViewObj.GetChild(stack[-1]) {
                parent := 0
                stack.Push(Id)
                flag_first := false
                return 1
            } else {
                return 0
            }
        }
        if TreeViewObj.Get(stack[-1], 'E') {
            Id := TreeViewObj.GetChild(stack[-1])
            parent := stack[-1]
            stack.Push(Id)
            return 1
        } else if stack.Length > 1 {
            loop {
                if Id := TreeViewObj.GetNext(stack[-1]) {
                    stack[-1] := Id
                    parent := stack[-2]
                    return 1
                } else {
                    stack.Pop()
                    if stack.Length <= 1 {
                        return 0
                    }
                }
            }
        } else {
            return 0
        }
    }
    _EnumNonParentsOnly(&Id, &parent?) {
        if flag_first {
            while child := TreeViewObj.GetChild(stack[-1]) {
                stack.Push(child)
            }
            if stack.Length > 1 {
                flag_first := false
                Id := stack[-1]
                Parent := stack[-2]
                return 1
            } else {
                return 0
            }
        }
        if Id := TreeViewObj.GetNext(stack[-1]) {
            stack[-1] := Id
            while child := TreeViewObj.GetChild(stack[-1]) {
                stack.Push(child)
            }
            parent := stack[-2]
            Id := stack[-1]
            return 1
        } else if stack.Length > 1 {
            stack.Pop()
            loop {
                if Id := TreeViewObj.GetNext(stack[-1]) {
                    stack[-1] := Id
                    while child := TreeViewObj.GetChild(stack[-1]) {
                        stack.Push(child)
                    }
                    parent := stack[-2]
                    Id := stack[-1]
                    return 1
                } else {
                    stack.Pop()
                    if stack.Length <= 1 {
                        return 0
                    }
                }
            }
        } else {
            return 0
        }
    }
    _EnumExpandedAndNonParentsOnly(&Id, &parent?) {
        if flag_first {
            if child := TreeViewObj.GetChild(stack[-1]) {
                stack.Push(child)
                flag_first := false
            } else {
                return 0
            }
            if _Skip() {
                return 0
            }
            Id := stack[-1]
            Parent := stack[-2]
            return 1
        }
        if Id := TreeViewObj.GetNext(stack[-1]) {
            stack[-1] := Id
            if _Skip() {
                return 0
            }
            parent := stack[-2]
            Id := stack[-1]
            return 1
        } else if stack.Length > 1 {
            stack.Pop()
            loop {
                if Id := TreeViewObj.GetNext(stack[-1]) {
                    stack[-1] := Id
                    if _Skip() {
                        return 0
                    }
                    parent := stack[-2]
                    Id := stack[-1]
                    return 1
                } else {
                    stack.Pop()
                    if stack.Length <= 1 {
                        return 0
                    }
                }
            }
        } else {
            return 0
        }

        _Skip() {
            loop {
                while TreeViewObj.Get(stack[-1], 'E') {
                    stack.Push(TreeViewObj.GetChild(stack[-1]))
                }
                if Id := TreeViewObj.GetChild(stack[-1]) {
                    if Id := TreeViewObj.GetNext(stack[-1]) {
                        stack[-1] := Id
                    } else if stack.Length > 1 {
                        loop {
                            stack.Pop()
                            if Id := TreeViewObj.GetNext(stack[-1]) {
                                stack[-1] := Id
                                break
                            }
                            if stack.Length <= 1 {
                                return 1
                            }
                        }
                    } else {
                        return 1
                    }
                } else {
                    return
                }
            }
        }
    }
}


TreeViewEnumAll(TreeViewObj, ItemId := 0, *) {
    _id := TreeViewObj.GetNext(ItemId, 'F')
    return Enum

    Enum(&Id) {
        if _id {
            Id := _id
            _id := TreeViewObj.GetNext(Id, 'F')
            return 1
        } else {
            return 0
        }
    }
}

TreeViewEnumChecked(TreeViewObj, ItemId := 0, *) {
    _id := TreeViewObj.Get(ItemId, 'C')
    if !_id {
        _id := TreeViewObj.GetNext(ItemId, 'C')
    }
    return Enum

    Enum(&Id) {
        if _id {
            Id := _id
            _id := TreeViewObj.GetNext(Id, 'C')
            return 1
        } else {
            return 0
        }
    }
}

TreeViewEnumChildren(TreeViewObj, ItemId := 0, *) {
    child := TreeViewObj.GetChild(ItemId)
    return Enum

    Enum(&Id) {
        if child {
            Id := child
            child := TreeViewObj.GetNext(Id)
            return 1
        } else {
            return 0
        }
    }
}
