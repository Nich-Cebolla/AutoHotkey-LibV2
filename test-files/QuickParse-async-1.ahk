
#include <Array_Join>
#include ..\QuickParse.ahk

class test_async_1 {
    static Call() {

    }
}

class CLSID extends Buffer {
    __New(CLSID_Str) {
        this.Str := CLSID_Str
        this.Size := 16
        if HRESULT := DllCall('ole32\CLSIDFromString', 'wstr', CLSID_Str, 'ptr', this, 'uint') {
            throw OSError('The CLSID was formatted incorrectly.', -1)
        }
    }
}



class ActiveObject {
    static __New() {
        this.DeleteProp('__New')
        Proto := this.Prototype
        Proto.Handle := Proto.Obj := Proto.CLSID := Proto.CLSID_Str := 0
    }
    __New(Obj, CLSID_Str, DeferRegistration := false) {
        this.CLSID_Str := CLSID_Str
        this.CLSID := CLSID(CLSID_Str)
        this.Obj := Obj
        if HRESULT := DllCall('oleaut32\RegisterActiveObject', 'ptr', ObjPtr(Obj), 'ptr', this.CLSID, 'uint', 0, 'uint*', &Handle := 0, 'uint') {
            throw OSError('``RegisterActiveObject`` failed.', -1, 'HRESULT: ' HRESULT)
        }
        this.Handle := Handle
    }
    Dispose() {
        if this.Handle {
            this.Revoke()
        }
        this.Obj := this.CLSID := this.CLSID_Str := 0
    }
    /**
     * @description - Calls `RevokeActiveObject`.
     * @throws {OSError} - `RevokeActiveObject` failed.
     */
    Revoke() {
        if !this.Handle {
            throw Error('The object is not currently registered as an Active Object.', -1)
        }
        if HRESULT := DllCall('oleaut32\RevokeActiveObject', 'uint', this.Handle, 'ptr', 0, 'uint') {
            throw OSError('``RevokeActiveObject`` failed.', -1, 'HRESULT: ' HRESULT)
        }
        this.Handle := 0
    }
    __Delete() {
        this.Dispose()
    }
}

/**
 * @classdesc - The `ActiveObjectCollection` class exists to help manage the lifecycle of registered
 * objects.
 *
 * When the process that registered the object terminates, COM automatically removes the registered
 * object from the running objects table. Any references to the object owned by other processes
 * also become invalid. This is in contrast to calling `RevokeActiveObject` from the parent process.
 * Calling `RevokeActiveObject` does **not** invalidate references to the object owned by other
 * processes until the reference count drops to 0 or the parent process terminates.
 *
 * Like most things, the goals related to managing the lifecycle of registered objects depend on
 * the project. `ActiveObjectCollection` can help simplify this task.
 *
 * The static methods help you read and write the details of active objects to file. This might be
 * helpful for sharing a pool of service workers across a number of hosts.
 *
 * The instance object is a simple map object with a `Dispose` method. Calling
 * `ActiveObjectCollection.Prototype.Dispose` iterates the objects in the collection and calls
 * their `Dispose` method. If you group together related objects in a collection, then cleaning
 * them up is as simple as calling `Dispose` on the collection object.
 */
class ActiveObjectCollection extends Map {
    static __New() {
        this.DeleteProp('__New')
        this.LineEnding := '`r`n'
        this.Indent := '`s`s`s`s'
    }
    /**
     * @description - Adds a new item to the JSON string. The optional parameters aren't used directly
     * by any functions in this library. Their use would be defined by your application.
     * @param {String} Path - The path to the file that contains the JSON string.
     * @param {String} Id - An application-defined id that will be the key to access the item from
     * the object.
     * @param {String} CLSID_Str - The CLSID associated with the object. The JSON property associated
     * with this value is "CLSID".
     * @param {Integer} Handle - The value assigned to the `pdwRegister` parameter of
     * `RegisterActiveObject`. This is the value that gets passed to `RevokeActiveObject`.
     * The JSON property associated with this value is "Handle".
     * @param {Integer[]|Integer} [HwndList = ""] - Either a window handle, or an array of window handles,
     * where each window handle is associated with an AHK process that has notified the host that it
     * owns a reference to the object. The JSON property associated with this value is "ActiveConsumers".
     * @param {String} [Description = ""] - An optional description to include in the JSON. The JSON
     * property associated with this value is "Description".
     * @param {String} [OwnerId = ""] - An optional Id to associate the object with the process
     * which created it. The JSON property associated with this value is "OwnerId".
     * @param {Object|String} [AdditionalDetails] - An optional object or string to include in
     * the JSON. If an object, the own properties will be iterated and included in the JSON along with
     * their values. The values of the properties must not be objects. For example, you may want to
     * include the handle to a mutex or semaphore if one is associated with the object. The JSON
     * property associated with this value is "AdditionalDetails".
     * @param {String} [Encoding = "utf-8"] - The encoding of the file.
     */
    static Add(Path, Id, CLSID_Str, Handle, HwndList := '', Description := '', OwnerId := '', AdditionalDetails := '', Encoding := 'utf-8') {
        le := this.LineEnding
        i := this.Indent
        f := FileOpen(Path, 'rw', Encoding)
        if f.Length > StrPut(le '{}', Encoding) {
            f.Pos := f.Length
            while f.Read(1) !== '}' {
                f.Pos -= 2
            }
            f.Pos -= StrPut(le, Encoding)
            if f.Length < 20 { ; 20 is arbitrary.
                f.Write(_Get())
            } else {
                f.Write(',' le _Get())
            }
        } else {
            f.Write('{' le _Get())
        }
        f.Close()

        _Get() {
            if AdditionalDetails {
                if IsObject(AdditionalDetails) {
                    a := '{'
                    for Prop, Val in AdditionalDetails.OwnProps() {
                        if A_Index == 1 {
                            a .= le i i i '"' Prop '": "' (Val ? _Escape(&Val) : '') '"'
                        } else {
                            a .= ',' le i i i '"' Prop '": "' (Val ? _Escape(&Val) : '') '"'
                        }
                    }
                    a .= le i i '}'
                } else {
                    a := '"' _Escape(&AdditionalDetails) '"'
                }
            } else {
                a := '""'
            }
            return (
                i '"' Id '": {' le
                i i '"ActiveConsumers": [' (HwndList is Array ? HwndList.Join() : HwndList) '],' le
                i i '"CLSID": "{' Trim(CLSID_Str, '`s{}"') '}",' le
                i i '"Handle": "' Handle '",' le
                i i '"Description": "' (Description ? _Escape(&Description) : '') '",' le
                i i '"OwnerId": "' (OwnerId ? _Escape(&OwnerId) : '') '",' le
                i i '"AdditionalDetails": ' a le
                i '}' le
                '}'
            )
            _Escape(&Str) {
                return StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(Str, '\', '\\'), '`n', '\n'), '`r', '\r'), '"', '\"'), '`t', '\t')
            }
        }
    }
    static AddWorker(Path, Id, Hwnd, Encoding := 'utf-8') {
        Content := FileRead(Path, Encoding)
        if !RegExMatch(Content, 'i)"' Id '": \{[^"{]+"ActiveConsumers": \[[^\]\r\n]*', &Match) {
            if InStr(Content, Id) {
                throw Error('Failed to find the current list of active consumers. The file may have been corrupted.', -1)
            } else {
                throw Error('The ID is not found in the JSON.', -1, Id)
            }
        }
        f := FileOpen(Path, 'w', Encoding)
        f.Write(StrReplace(Content, Match[0], Match[0] ', ' Hwnd))
        f.Close()
    }
    static Delete(Path, Id, Encoding := 'utf-8') {
        if Content := FileRead(Path, Encoding) {
            if !RegExMatch(Content, 'i)(?(DEFINE)(?<quote>(?<=[,:[{\s])".*?(?<!\\)(?:\\\\)*+"))(?<=[\r\n]) +"' Id '": (?<body>\{((?&quote)|[^"}{]++|(?&body))*\}),?\R', &Match) {
                if InStr(Content, Id) {
                    throw Error('Failed to parse the item`'s text content. The file may have been corrupted.', -1)
                } else {
                    throw Error('The ID is not found in the JSON.', -1, Id)
                }
            }
            f := FileOpen(Path, 'w', Encoding)
            f.Write(StrReplace(Content, Match[0], ''))
            f.Close()
        } else {
            throw Error('The file at the input path is empty.', -1, Path)
        }
    }
    static DeleteWorker(Path, Id, Hwnd, Encoding := 'utf-8') {
        Content := FileRead(Path, Encoding)
        if !RegExMatch(Content, 'i)("' Id '": \{[^"{]+"ActiveConsumers": \[[^\]\r\n]*?)(?<c1>, )?(?<hwnd>' Hwnd ')(?<c2>, )?', &Match) {
            if InStr(Content, Id) {
                if RegExMatch(Content, '\b' Hwnd '\b') {
                    throw Error('Failed to delete the window handle from the list associated with the input ID. The file may have been corrupted or the handle may not be an item in the list.', -1, Hwnd)
                } else {
                    throw Error('The window handle is not in the JSON.', -1, Hwnd)
                }
            } else {
                throw Error('The ID is not in the JSON.', -1, Id)
            }
        }
        f := FileOpen(Path, 'w', Encoding)
        if Match['c1'] {
            f.Write(StrReplace(Content, Match[0], Match[1] Match['c2']))
        } else {
            f.Write(StrReplace(Content, Match[0], Match[1]))
        }
    }
    static Read(Path, Encoding := 'utf-8') {
        if Content := FileRead(Path, Encoding) {
            return QuickParse(Content, , Encoding, , true)
        } else {
            throw Error('The file at the input path exists but is empty.', -1, Path)
        }
    }
    static Revoke(Path, IdList, Encoding := 'utf-8') {
        Items := this.Read(Path, Encoding)
        if not IdList is Array {
            IdList := [ IdList ]
        }
        for id in IdList {
            item := Items.Get(id)
            if HRESULT := DllCall('oleaut32\RevokeActiveObject', 'uint', item.Get('Handle'), 'ptr', 0, 'uint') {
                throw OSError(HRESULT, -1)
            }
        }
    }
    static RevokeAll(Path, Encoding := 'utf-8') {
        for id, item in this.Read(Path, Encoding) {
            if HRESULT := DllCall('oleaut32\RevokeActiveObject', 'uint', item.Get('Handle'), 'ptr', 0, 'uint') {
                throw OSError(HRESULT, -1)
            }
        }
    }

    Dispose(*) {
        if this.Count {
            for Handle, ActiveObj in this {
                ActiveObj.Dispose()
            }
            this.Clear()
        }
    }

    __Delete() {
        this.Dispose()
    }
}

class ServiceHost extends ServiceBase {
    static GetTestCLSID() {
        if ServiceHost.__TestCLSID.Length {
            return ServiceHost.__TestCLSID.RemoveAt(1)
        } else {
            throw IndexError('No test CLSIDs remaining.', -1)
        }
    }
    /**
     * @description - These are intended to be used for testing.
     */
    static __TestCLSID := [
        '{E9550F57-325D-4AC4-877C-844AEBB2D570}'
      , '{9E9A8166-9619-4D3D-9B82-B599FEC4D879}'
      , '{C3BF5057-9B47-427B-A2FE-5D3EACE0007A}'
      , '{D7DF899F-AFC9-4BC1-8349-2487E29E887A}'
      , '{59179728-668B-4FF1-B1B0-AE242EB749E4}'
    ]

    __New(Config?) {
        this.Config := ServiceHost.Options(Config ?? {})
        this.ActiveObjects := ActiveObjectCollection(false)
        this.OnExitCallbacks := ServiceHost.OnExitCallbackCollection()
        OnExit(ObjBindMethod(this, 'OnExit'), 1)
        this.OnExitCallbacks.Push(ObjBindMethod(this.ActiveObjects, 'Dispose'))
        this.WaitObjects := ServiceHost.WaitObjectCollection(false)
        this.OnExitCallbacks.Push(ObjBindMethod(this.WaitObjects, 'Dispose'))
        this.Constructors := ServiceHost.ConstructorCollection(false)
        ObjSetBase(ActiveObjProto := { Collection: this.ActiveObjects, ServiceHost: this }, ActiveObject.Prototype)
        this.Constructors.Set(ActiveObjProto.__Class, ClassFactory(ActiveObjProto))
        ObjSetBase(MutexObjProto := { Collection: this.WaitObjects, ServiceHost: this }, Mutex.Prototype)
        this.Constructors.Set(MutexObjProto.__Class, ClassFactory(MutexObjProto))
    }

    /**
     * @classdesc - Handles the input config.
     */
    class Options {
        static __New() {
            this.DeleteProp('__New')
            proto := this.Prototype
        }

        __New(options?) {
            if IsSet(options) {
                if IsSet(ServiceHostConfig) {
                    for prop in ServiceHost.Options.Prototype.OwnProps() {
                        if HasProp(options, prop) {
                            this.%prop% := options.%prop%
                        } else if HasProp(ServiceHostConfig, prop) {
                            this.%prop% := ServiceHostConfig.%prop%
                        }
                    }
                } else {
                    for prop in ServiceHost.Options.Prototype.OwnProps() {
                        if HasProp(options, prop) {
                            this.%prop% := options.%prop%
                        }
                    }
                }
            } else if IsSet(ServiceHostConfig) {
                for prop in ServiceHost.Options.Prototype.OwnProps() {
                    if HasProp(ServiceHostConfig, prop) {
                        this.%prop% := ServiceHostConfig.%prop%
                    }
                }
            }
        }
    }

    class MessageReceiver {

    }

    class MessageSender {

    }

    class ServiceHostProxy {
        __New() {

        }
    }
}

class ServiceBase {

    CreateActiveObject(Obj, CLSID_Str) {
        static ClassName := ActiveObject.Prototype.__Class
        return this.Constructors.Get(ClassName)(Obj, CLSID_Str)
    }

    CreateMutex(
        Obj?
      , Name := 0
      , InitialOwner := false
      , SecurityAttributes?
      , AccessRights := 0x1F0001
      , Timeout := 0
      , Alertable := false
      , WaitFunc := 1
      , UseHistory := false
    ) {
        static ClassName := Mutex.Prototype.__Class
        return this.Constructors.Get(ClassName)(Obj ?? unset, Name, InitialOwner, SecurityAttributes ?? unset, AccessRights, Timeout, Alertable, WaitFunc, UseHistory)
    }

    OnExit(ExitReason, ExitCode) {
        for cb in this.OnExitCallbacks {
            if cb(ExitReason, ExitCode, this) {
                return 1
            }
        }
    }

    class ConstructorCollection extends MapEx {

        Dispose() {
            if this.Count {
                for Name, Constructor in this {
                    Proto := Constructor.Prototype
                    Proto.DeleteProp('Collection')
                    Proto.DeleteProp('ServiceWorker')
                    Constructor.DeleteProp('Prototype')
                }
                this.Clear()
            }
        }

        __Delete() {
            this.Dispose()
        }
    }

    class CreateNewServiceWorkerArgs {
        static Call(Args) {
            ObjSetBase(Args, this.Prototype)
            return Args
        }
        static __New() {
            this.DeleteProp('__New')
            Proto := this.Prototype
            Proto.Kind := ''
        }
    }

    class OnExitCallbackCollection extends Array {

    }

    class ServiceWorkerProxyCollection extends Map {

        Dispose() {
            if this.Count {
                for Name, ServiceWorker in this {
                    ServiceWorker.Dispose()
                }
                this.Clear()
            }
        }

        __Delete() {
            this.Dispose()
        }
    }

    class WaitObjectCollection extends MapEx {
        Dispose() {
            if this.Count {
                for Name, Mutex in this {
                    Mutex.Dispose()
                }
                this.Clear()
            }
        }

        __Delete() {
            this.Dispose()
        }
    }
}
