/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/LibraryManager.ahk
    Author: Nich-Cebolla
    License: MIT
*/

/**
 * @classdesc -
 * The purpose of {@link LibraryManager} is to improve application performance by obtaining procedure
 * addresses and storing the addresses in a global variable so any subsystem that calls that procedure
 * can have access to the direct address.
 *
 * The optimal storage method for storing a procedure address that will be used repeatedly is to
 * store the address in a global variable. Each subsystem should refer to the same variable when
 * calling the procedure. {@link LibraryManager} facilitates this process.
 *
 * # Usage
 *
 * Using {@link LibraryManager} is easy, but requires a bit of preparation. See the test file
 * "test-files\test-LibraryManager.ahk" for a working example.
 *
 * ## Initialize global variables for procedure addresses
 *
 * The global variables used to store procedure addresses must be initialized. The structure of the
 * variable name is:
 *
 * <prefix>_<library name>_<procedure name>
 *
 * By default, the <prefix> is "g_proc". The value of the prefix is defined by the global variable
 * `LIBRARYMANAGER_VAR_PREFIX` which is initialized within {@link LibraryManager.__New} (unless
 * `LIBRARYMANAGER_VAR_PREFIX` has already been set). Your code can overwrite `LIBRARYMANAGER_VAR_PREFIX`
 * and use a different prefix if necessary, but this should be avoided so open source code does not
 * need to navigate various prefixes among shared libraries. If you do need to redefine
 * `LIBRARYMANAGER_VAR_PREFIX`, note that the variables used internally by {@link LibraryManager}
 * are always `g_proc_kernel32_GetProcAddress`, `g_proc_kernel32_LoadLibraryW`, and
 * `g_proc_kernel32_FreeLibrary`.
 *
 * <library name> is the literal name of the dll without the ".dll" extension.
 *
 * <procedure name> is the literal name of the procedure from which the address will be assigned
 * to the variable.
 *
 * Any characters which are invalid for use within variable names are removed from the name when used
 * to refer to a variable. The variable name is not case sensitive, but the values passed to
 * {@link LibraryManager.Call} are case sensitive.
 *
 * Internally, the variable names are dereferenced with this logic:
 *
 * @example
 *  hMod := DllCall(g_proc_kernel32_LoadLibraryW, 'wstr', dllName, 'ptr')
 *  address := DllCall(g_proc_kernel32_GetProcAddress, 'ptr', hMod, 'astr', procedureName, 'ptr')
 *  dllName := RegExReplace(StrReplace(dllName, '.dll', ''), LibraryManager.InvalidCharPattern, '')
 *  procedureName := RegExReplace(procedureName, LibraryManager.InvalidCharPattern, '')
 *  %LIBRARYMANAGER_VAR_PREFIX%_%dllName%_%procedureName% := address
 * @
 *
 * The default value of {@link LibraryManager.InvalidCharPattern} is "[^\p{L}0-9_\x{00A0}-\x{10FFFF}]",
 * which should correctly encapsulate AutoHotkey's requirements.
 *
 * Here are a few effective approaches to accomplish initializing the variables:
 *
 * - Use a single file which initializes the variables.
 *
 * @example
 *  global g_proc_lib_Procedure1,
 *  g_proc_lib_Procedure2,
 *  g_proc_lib_Procedure3,
 *  ; ...
 *  g_proc_lib_ProcedureN
 * @
 *
 * Then #include the file in your code. The auto-execute portion of the script must reach the
 * #included file before {@link LibraryManager} is used.
 *
 * - Use multiple files which initialize the variables. If a variable is already initialized,
 * re-initializing the variable with a `global VarName` statement has no effect and is valid.
 * For example, this is acceptable and causes no issues:
 *
 * script1.ahk:
 * @example
 *  global g_proc_lib_Procedure1, g_proc_lib_Procedure2
 * @
 *
 * script2.ahk:
 * @example
 *  global g_proc_lib_Procedure1, g_proc_lib_Procedure3
 * @
 *
 * script3.ahk:
 * @example
 *  #include script1.ahk
 *  token1 := LibraryManager(Map('lib', ['Procedure1', 'Procedure2']))
 *  DllCall(g_proc_lib_Procedure1, 'int', 0, 'int', 0)
 *
 *  ; Re-initializing the variables does not cause issues
 *  ; even though `g_proc_lib_Procedure1` has already been
 *  ; set with a value.
 *  #include script2.ahk
 *  token2 := LibraryManager(Map('lib', ['Procedure1', 'Procedure3']))
 *  DllCall(g_proc_lib_Procedure1, 'int', 0, 'int', 0)
 * @
 *
 * Using this approach, each library can initialize the variables it needs. However, depending
 * on the structure of the code, it is possible that "script2.ahk" is not reached prior to attempting
 * to read the value of `g_proc_lib_Procedure1` or `g_proc_lib_Procedure3`, resulting in a `VarUnset`
 * error, even if the code is correctly written. One of the following approaches can be used to avoid
 * this eventuality.
 *
 * - If a custom class will rely on a set of procedures, initialize them in the static "__New" method.
 * Check if the variable is set before initializing the value with `0`.
 *
 * @example
 *  class MyClass {
 *      static __New() {
 *          global
 *          this.DeleteProp('__New')
 *          if !IsSet(g_proc_lib_Precedure1) {
 *              g_proc_lib_Procedure1 := 0
 *          }
 *          if !IsSet(g_proc_lib_Procedure2) {
 *              g_proc_lib_Procedure2 := 0
 *          }
 *          ; ...
 *      }
 *  }
 * @
 *
 * If the static method "__New" uses local variables which you do not want to be global, you can do
 * either of the following:
 *
 * Define a separate static method to handle the variables.
 *
 * @example
 *  class MyClass {
 *      static __New() {
 *          this.DeleteProp('__New')
 *          this.__InitializeProcedureVars()
 *      }
 *      static __InitializeProcedureVars() {
 *          global
 *          if !IsSet(g_proc_lib_Precedure1) {
 *              g_proc_lib_Procedure1 := 0
 *          }
 *          if !IsSet(g_proc_lib_Procedure2) {
 *              g_proc_lib_Procedure2 := 0
 *          }
 *          ; ...
 *      }
 *  }
 * @
 *
 * Reference the global variables explicitly.
 *
 * @example
 *  class MyClass {
 *      static __New() {
 *          global g_proc_lib_Precedure1, g_proc_lib_Procedure2
 *          this.DeleteProp('__New')
 *          if !IsSet(g_proc_lib_Precedure1) {
 *              g_proc_lib_Procedure1 := 0
 *          }
 *          if !IsSet(g_proc_lib_Procedure2) {
 *              g_proc_lib_Procedure2 := 0
 *          }
 *      }
 *  }
 * @
 *
 * - Use a helper function.
 *
 * @example
 *  InitializeProcedureVars() {
 *      global
 *      if !IsSet(g_proc_lib_Procedure1) {
 *          g_proc_lib_Procedure1 := 0
 *      }
 *      if !IsSet(g_proc_lib_Procedure2) {
 *          g_proc_lib_Procedure2 := 0
 *      }
 *      ; ...
 *  }
 * @
 *
 * ## Call LibraryManager.Call
 *
 * Each subsystem calls {@link LibraryManager.Call} with a `Map` object, where the keys are dll
 * file names and the values are an array of procedure names as string. {@link LibraryManager.Call}
 * then calls `LoadLibraryW` for the dlls, and calls `GetProcAddress` for the procedures.
 *
 * @example
 *  global g_proc_somedll_Procedure1,
 *  g_proc_somedll_Procedure2,
 *  g_proc_somedll_Procedure3
 *
 *  procedures := Map('somedll', ['Procedure1', 'Procedure2', 'Procedure3'])
 *  token := LibraryManager(procedures)
 *
 *  ; do work
 *
 *  ; If the libraries are no longer needed
 *  token.Free()
 * @
 *
 * ## Call LibraryManagerToken.Prototype.Free
 *
 * If a subsystem no longer requires the libraries associated with one of its tokens, or if a
 * subsystem is no longer needed altogether, call {@link LibraryManagerToken.Prototype.Free} to
 * decrement the Windows API's reference count for the libraries.
 *
 * # A brief note about `LoadLibrary` and `FreeLibrary`
 *
 * The system uses reference counts to manage calls to `LoadLibrary` and `FreeLibrary`. When
 * `LoadLibrary` is called, if the library has already been loaded, the reference count is increased
 * and the same handle is returned. When `FreeLibrary` is called, the reference count is decreased.
 * If the reference count reaches 0 then the library is unloaded and the handle associated with the
 * library is no longer valid. {@link LibraryManager} handles this internally; your code is only
 * responsible for managing the token it receives from {@link LibraryManager}.
 *
 * # Persistent global variable values
 *
 * When the reference count for a library managed by {@link LibraryManager} reaches 0, any variables
 * associated with that dll do not get changed in any way; if the variable was set with a value, the
 * variable will maintain the value even after the reference count reaches 0.
 *
 * This decision was made because keeping track of which variables are in use would require
 * significant additional memory. {@link LibraryManager} would need to track what variables are
 * associated with what dlls, requiring another stored string for each variable. There is little
 * benefit to doing this, and {@link LibraryManager} works without doing it.
 */
class LibraryManager {
    static __New() {
        this.DeleteProp('__New')
        this.Tokens := LibraryManagerTokenCollection()
        this.InvalidCharPattern := '[^\p{L}0-9_\x{00A0}-\x{10FFFF}]'
        this.__InitializeProcedureVars()
    }
    static Free(Token) {
        if this.Tokens.Has(Token.Id) {
            for hMod in Token.Libraries {
                DllCall(g_proc_kernel32_FreeLibrary, 'ptr', hMod)
            }
            this.Tokens.Delete(Token.Id)
        } else {
            throw UnsetItemError('Token not found.', -1, Token.Id)
        }
    }
    static Call(Procedures) {
        pattern := this.InvalidCharPattern
        token := LibraryManagerToken()
        this.Tokens.Set(token.Id, token)
        for dllName, procedureList in Procedures {
            if !(hMod := DllCall(g_proc_kernel32_LoadLibraryW, 'wstr', dllName, 'ptr')) {
                throw Error('Failed to load the dll.', -1, dllName)
            }
            this.__Load(&dllName, RegExReplace(StrReplace(dllName, '.dll', ''), pattern, ''), hMod, procedureList, &pattern)
            token.Add(hMod)
        }
        return token
    }
    static __Load(&DllName, ModifiedDllName, hMod, procedureList, &pattern) {
        global
        loop procedureList.Length {
            if !(%LIBRARYMANAGER_VAR_PREFIX%_%ModifiedDllName%_%RegExReplace(procedureList[A_Index], pattern, '')%
            := DllCall(g_proc_kernel32_GetProcAddress, 'ptr', hMod, 'astr', procedureList[A_Index], 'ptr')) {
                throw Error('Failed to look up the procedure address.', -1, DllName ':' procedureList[A_Index])
            }
        }
    }
    static __InitializeProcedureVars() {
        global LIBRARYMANAGER_VAR_PREFIX, g_proc_kernel32_GetProcAddress
        , g_proc_kernel32_LoadLibraryW, g_proc_kernel32_FreeLibrary
        if !IsSet(LIBRARYMANAGER_VAR_PREFIX) {
            LIBRARYMANAGER_VAR_PREFIX := 'g_proc'
        }
        hMod := DllCall('GetModuleHandleW', 'wstr', 'kernel32', 'ptr')
        if !IsSet(g_proc_kernel32_GetProcAddress) {
            g_proc_kernel32_GetProcAddress := DllCall('GetProcAddress', 'ptr', hMod, 'astr', 'GetProcAddress', 'ptr')
        }
        if !IsSet(g_proc_kernel32_LoadLibraryW) {
            g_proc_kernel32_LoadLibraryW := DllCall(g_proc_kernel32_GetProcAddress, 'ptr', hMod, 'astr', 'LoadLibraryW', 'ptr')
        }
        if !IsSet(g_proc_kernel32_FreeLibrary) {
            g_proc_kernel32_FreeLibrary := DllCall(g_proc_kernel32_GetProcAddress, 'ptr', hMod, 'astr', 'FreeLibrary', 'ptr')
        }
    }
}

class LibraryManagerToken {
    __New() {
        this.Libraries := LibraryManagerLibraryCollection()
        loop {
            id := Random(0, 4294967295)
            if LibraryManager.Tokens.Has(id) {
                OutputDebug('Congratulations, you should buy a lottery ticket today.`n')
                continue
            }
            this.Id := id
            return
        }
    }
    Add(hMod) {
        this.Libraries.Push(hMod)
    }
    Free() {
        LibraryManager.Free(this)
        this.Id := this.Libraries := 0
    }
}

class LibraryManagerTokenCollection extends Map {
}
class LibraryManagerLibraryCollection extends Array {
}
