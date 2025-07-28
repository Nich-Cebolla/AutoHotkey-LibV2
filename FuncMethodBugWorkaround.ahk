
/*
    As of 7/28/2025, there is a bug that causes `Func.Prototype.IsOptional` and
    `Func.Prototype.IsByRef` to return incorrect values for built-in class instance methods
    if the method has one or more optional / by ref parameters.

    I outlined the bug here: https://www.autohotkey.com/boards/viewtopic.php?f=14&t=138381&p=607618#p607618

    This code is a workaround, manually correcting the error.
*/

global FuncIsOptional, FuncIsByRef

InitializeFuncMethodWorkaround() {
    ; Check to see if the bug has been fixed
    fn := Gui.Control.Prototype.GetPos
    if fn.IsOptional(fn.MaxParams) && fn.IsByRef(fn.MaxParams) {
        OutputDebug('The bug affecting ``Func.Prototype.IsByRef`` and ``Func.Prototype.IsOptional`` appears to have been fixed.`n')
        return 1
    }
    proto := Func.Prototype
    global FuncIsOptional := proto.IsOptional
    , FuncIsByRef := proto.IsByRef
    proto.DefineProp('IsByRef', { Call: FuncIsByRefOverride })
    proto.DefineProp('IsOptional', { Call: FuncIsOptionalOverride })
}

FuncIsOptionalOverride(Self, ParamIndex?) {
    ; Calling the method without an input index returns nonzero if the function has at least one optional parameter.
    if FuncIsOptional(Self) {
        if !IsSet(ParamIndex) {
            return 1
        }
        if Self.IsBuiltIn && InStr(Self.Name, '.Prototype') {
            if ParamIndex = 1 {
                ; The first parameter is the hidden "this" parameter, which is required for all built-in class methods.
                return 0
            } else {
                ; The bug shifts the effective index of each parameter down by one.
                return FuncIsOptional(Self, ParamIndex - 1)
            }
        } else {
            ; The bug does not affect user-defined classes or standard `Func` objects.
            return FuncIsOptional(Self, ParamIndex)
        }
    } else {
        return 0
    }
}

FuncIsByRefOverride(Self, ParamIndex?) {
    ; Calling the method without an input index returns nonzero if the function has at least one by ref parameter.
    if FuncIsByRef(Self) {
        if !IsSet(ParamIndex) {
            return 1
        }
        if Self.IsBuiltIn && InStr(Self.Name, '.Prototype') {
            if ParamIndex = 1 {
                ; The first parameter is the hidden "this" parameter, which is not by ref.
                return 0
            } else {
                ; The bug shifts the effective index of each parameter down by one.
                return FuncIsByRef(Self, ParamIndex - 1)
            }
        } else {
            ; The bug does not affect user-defined classes or standard `Func` objects.
            return FuncIsByRef(Self, ParamIndex)
        }
    } else {
        return 0
    }
}
