
; To turn this into a verbose version of the script, un-comment the below code and run it.
/*
SplitPath(A_ScriptFullPath, , , &Ext, &NameNoExt)
if FileExist(Path := NameNoExt '-debug.' Ext) {
    if MsgBox('Overwrite: ' Path '?',,'YN') == 'No' {
        Exit()
    }
}
Content := RegExReplace(FileRead(A_ScriptFullPath)
, "(OutputDebug\('``n' A_LineNumber ': )('.+)\) `; ?(.*)"
, "$1Expected: $3``n' A_LineNumber ': Actual  : $2 '``n---------------')")
Content := StrReplace(SubStr(Content, InStr(Content, '#Include', , , 2)), '``PropsList`` must be an array', '````PropsList```` must be an array')
f := FileOpen(Path, 'w')
f.Write(Content)
f.Close()
Exit()
*/

#Include Inheritance.ahk

class Alpha extends Alpha.base {
    __New() {
        this.DefineProp('Prop2', { Value: '$.Prop2 property value' })
    }

    Method() {
        return 'Alpha return value'
    }

    Prop => 10000

    class base extends Array {
        method() {
            return 'Alpha.base return value'
        }

        __Prop := 'Hello!'
        Prop {
            Get => this.__Prop
            Set => this.__Prop := Value
        }
    }
}

; To work through the walkthrough, load it up in a debugger and step through it.
; If you don't want to use a debugger, use your editor's text replacement to swap these:
;    OutputDebug('`n'
; to
;    MsgBox(
; --------------------------------------------------------------------------------------------------

; === I. Accessing the objects =====================================================================

AlphaObj := Alpha()

; `PropsInfo` objects are useful when a process will iterate an object's properties, inherited and
; owned, to act on them in some way. `PropsInfo` objects are particularly useful if the action
; involves checking the kind of property and using that as a condition to direct the flow of action.

; Let's get our `PropsInfo` object.

PropsInfoObj := GetPropsInfo(AlphaObj)
OutputDebug('`n' A_LineNumber ': ' Type(PropsInfoObj)) ; PropsInfo

; The `PropsInfo` object will have one or more `PropsInfoItem` objects for each property included
; by the function call.

; We can get the `PropsInfoItem` objects by name.
InfoItem_Method := PropsInfoObj.Get('Method')
; or
InfoItem_Prop := PropsInfoObj['Prop']

; === II. The `PropsInfoItem` objects ==============================================================

; A `PropsInfoItem` object has just a few properties and methods, we can review them quickly:

; To keep it simple, I'll be referring to instances of `PropsInfoItem` as `InfoItem`,
; and I'll be using `PropsInfoObj` as the example object but the concepts apply to all
; instances of `PropsInfo`.

; --- A. `PropsInfoItem` objects - `InfoItem.Index` ------------------------------------------------

; The `InfoItem.Index` property represents the position in `AlphaObj`'s inheritance chain for
; the object which owns the property that generated the `InfoItem`.
; - An index of 0 means its owner is `AlphaObj`.
; - An index of 1 means its owner is `AlphaObj.Base`.
; - An index of 2 means its owner is `AlphaObj.Base.Base`.
; - etc.
; We see below that `Method` was inherited from `AlphaObj.Base`.
OutputDebug('`n' A_LineNumber ': ' InfoItem_Method.Index) ; 1

; --- B. `PropsInfoItem` objects - `InfoItem.Count` ------------------------------------------------

; The `InfoItem.Count` property conveys the number of objects in the inheritance chain which own
; a property with the name of the `InfoItem`.
OutputDebug('`n' A_LineNumber ': ' InfoItem_Method.Name) ; Method
OutputDebug('`n' A_LineNumber ': ' InfoItem_Method.Count) ; 2
OutputDebug('`n' A_LineNumber ': ' AlphaObj.HasOwnProp(InfoItem_Method.Name)) ; 0
OutputDebug('`n' A_LineNumber ': ' Alpha.Prototype.HasOwnProp(InfoItem_Method.Name)) ; 1
OutputDebug('`n' A_LineNumber ': ' Alpha.base.Prototype.HasOwnProp(InfoItem_Method.Name)) ; 1

; --- C. `PropsInfoItem` objects - `InfoItem.Kind` -------------------------------------------------

; When the `InfoItem` is created, it originally is the descriptor object returned from
; `Obj.GetOwnPropDesc(PropName)`.
/**
 * {@link https://www.autohotkey.com/docs/v2/lib/Object.htm#GetOwnPropDesc}
 */

; `InfoItem.Kind` tells us what kind of property it is.
OutputDebug('`n' A_LineNumber ': ' InfoItem_Method.Kind) ; Call
OutputDebug('`n' A_LineNumber ': ' InfoItem_Prop.Kind) ; Get

; --- D. `PropsInfoItem` objects - `InfoItem.GetValue()` -------------------------------------------

; We can try to get the value of a property with `InfoItem.GetValue`. If an `InfoItem` is
; associated with a property with only a `Set` accessor, or a callable property, `InfoItem.GetValue`
; does not produce a value.

; `InfoItem.GetValue` sets a `VarRef` parameter with the value instead of returning the value because
; `InfoItem.GetValue` should be expected to occasionally fail, particularly if the method requires
; additional parameters. So we should always call `InfoItem.GetValue` from a conditional statement.
; In your own code, you likely wouldn't throw an error as a result of not getting the value, because
; you would expect it and respond in some other way.
if code := InfoItem_Prop.GetValue(&Value) {
    HandleGetValueCode(code)
} else {
    OutputDebug('`n' A_LineNumber ': ' Value) ; 10000
}
HandleGetValueCode(code) {
    throw Error('Failed to get value. Code: ' code, -2)
}

; --- E. `PropsInfoItem` objects - `InfoItem.GetFunc` --------------------------------------------

; `InfoItem.GetFunc` returns the function object associated with the property for all properties
; except value properties.
InfoItem_Method_Func := InfoItem_Method.GetFunc()

; Something needs to be passed to the first parameter of the function. Normally that would be the
; object itself, i.e. the hidden `this` parameter discussed on this page:
/**
 * {@link https://www.autohotkey.com/docs/v2/Objects.htm#Custom_Classes_method}
 */
; `Object.Prototype.GetOwnPropDesc` exposes the hidden `this` parameter. An error will be thrown
; if the function is called without it. Here, we simply pass the owner object to the first parameter.
OutputDebug('`n' A_LineNumber ': ' InfoItem_Method_Func(InfoItem_Method.GetOwner())) ; Alpha return value

; Passing the owner object above was just to showcase the `PropsInfoObj.GetOwner` method and
; to contextualize `PropsInfoItem`'s design. The `Alpha.Prototype.Method` function does not refer
; to `this`, so the value passed to the first parameter can be anything.
OutputDebug('`n' A_LineNumber ': ' InfoItem_Method_Func('')) ; Alpha return value
OutputDebug('`n' A_LineNumber ': ' InfoItem_Method_Func(Error())) ; Alpha return value

; Remember that function objects also have a built-in `Name` property which can be used for various
; tasks.
OutputDebug('`n' A_LineNumber ': ' InfoItem_Method_Func.Name) ; Alpha.Prototype.Method

; The property `Method` is overridden in our example class. Both `Alpha` and `Alpha.base` have a
; `Method` property. The other `Method` item is available from the `Alt` array.
InfoItem_Method_Alt := InfoItem_Method.Alt[1]

; The second parameter of `PropsInfoObj.GetFunc` directs `GetFunc` to bind an object to the function,
; removing the need to pass something to the function's first parameter.
InfoItem_Method_Alt_Func := InfoItem_Method_Alt.GetFunc(, 1)
OutputDebug('`n' A_LineNumber ': ' InfoItem_Method_Alt_Func()) ; Alpha.base return value

; When the second parameter is set, the type of object returned by `PropsInfoObj.GetFunc` is a `BoundFunc`.
OutputDebug('`n' A_LineNumber ': ' Type(InfoItem_Method_Alt_Func)) ; BoundFunc

; `BoundFunc` objects do not have a name value.
OutputDebug('`n' A_LineNumber ': ' InfoItem_Method_Alt_Func.Name) ;

; === III. Iterating a `PropsInfo` object ==========================================================

; Our hypothetical application has a function that copies the values from one object to another object.

; Side note: If you need a real deep clone method: https://github.com/Nich-Cebolla/AutoHotkey-Object.Prototype.DeepClone/

Transplantinator(Subject, Target, PropsList?) {
    ; If `PropsList` is set
    if IsSet(PropsList) {
        if PropsList is Array or PropsList is Map {
            ; Call `PropsList`'s enumerator.
            Enum := ObjBindMethod(PropsList, '__Enum', 1)
        } else {
            throw TypeError('``PropsList`` must be an array or map.', -1)
        }
    } else {
        ; Else, call `OwnProps` on the input `Subject`.
        Enum := ObjBindMethod(Subject, 'OwnProps')
    }
    for Prop in Enum() {
        try {
            Target.DefineProp(Prop, { Value: Subject.%Prop% })
        }
    }
    return Target
}

; --- A. Iterating a `PropsInfo` object - `PropsInfoObj.StringMode` --------------------------------

; `PropsInfoObj.StringMode` changes the behavior of `PropsInfoObj.__Enum`. It also
; restricts `PropsInfoObj.__Item` and `PropsInfoObj.Get` to accept only index numbers to access
; the items, whereas normally they can accept either name or index. (Accessing items by index is
; mostly used internally and is not discussed in this walkthrough).
; When `PropsInfoObj.StringMode == 1` it basically tells the object that it should behave like an
; array of strings.
PropsInfoObj.StringMode := 1

; For example, we can enumerate it:
for prop in PropsInfoObj {
    str .= prop ', '
}
OutputDebug('`n' A_LineNumber ': ' Trim(str, ', ')) ; __Class, __Enum, __Init, __Item, __New, etc...

; If we turn `StringMode` off, we get objects.
PropsInfoObj.StringMode := 0
for InfoItem in PropsInfoObj {
    str2 .= InfoItem.Name ', '
}
OutputDebug('`n' A_LineNumber ': ' Trim(str2, ', ')) ; __Class, __Enum, __Init, __Item, __New, etc...

; Back to string mode.
PropsInfoObj.StringMode := 1

; Let's try passing it to Transplantinator.
try {
    Transplantinator(AlphaObj, {}, PropsInfoObj)
} catch Error as err {
    OutputDebug('`n' A_LineNumber ': ' err.Message) ; `PropsList` must be an array or map.
}

; `Transplantinator` has a condition `if PropsList is Array or PropsList is Map` to ensure the
; input is the expected type. We have two options we can use besides iterating `PropsInfoObj`
; in string mode and filling an array with the names.

; --- B. Iterating a `PropsInfo` object - `PropsInfoObj.GetProxy()` --------------------------------

; We can get a proxy. The benefits of using a proxy:
; - Low initialization cost
; - Low memory footprint
; - Only consumes processing time when used
PropsInfoProxy := PropsInfoObj.GetProxy(1) ; 1 = array, 2 = map

; Call the function using the proxy as the iterable `PropsList`.
AlphaClone := Transplantinator(AlphaObj, {}, PropsInfoProxy)

OutputDebug('`n' A_LineNumber ': ' AlphaClone.__Class) ; Alpha

; --- C. Iterating a `PropsInfo` object - `PropsInfoObj.ToArray()` and `PropsInfoObj.ToMap()` ------

; If a proxy isn't ideal for a task, we can get a true array or map easily.
Arr := PropsInfoObj.ToArray(true) ; `true` to get an array of names as strings.
AlphaClone2 := Transplantinator(AlphaObj, {}, Arr)
OutputDebug('`n' A_LineNumber ': ' AlphaClone2.__Class) ; Alpha

; Since the `PropsList` parameter of `Transplantinator` is called in a 1-param `for` loop, using a
; map would be equivalent to using an array of strings, albeit slightly slower.
AlphaClone3 := Transplantinator(AlphaObj, {}, PropsInfoObj.ToMap())
OutputDebug('`n' A_LineNumber ': ' AlphaClone3.__Class) ; Alpha

; === III. Filters =================================================================================

; Let's say we only want `Transplantinator` to copy properties that have a nonzero value. `PropsInfo`
; objects have a filter system to make this easy and consistent.

; There are five built-in filters. See the parameter hint for `FilterAdd` for details about those.

; To use a built-in filter, add it by index.
; `False` to the first parameter prevents activating the filter since we're adding more.
PropsInfoObj.FilterAdd(false, 1)
OutputDebug('`n' A_LineNumber ': ' PropsInfoObj.Filter.Count) ; 1

; We can use property names to exclude certain properties. This could be a comma-delimited list.
PropsInfoObj.FilterAdd(false, 'Length,Capacity')
OutputDebug('`n' A_LineNumber ': ' PropsInfoObj.Filter.Count) ; 2

; Or we can pass them as separate items.
PropsInfoObj.FilterAdd(false, '__New', '__Init')
; `Count` is still 2 because the strings were consolidated into the original string.
OutputDebug('`n' A_LineNumber ': ' PropsInfoObj.Filter.Count) ; 2

; We can also filter properties with a function. The function should accept a `PropsInfoItem` object.
MyFilterFunc(PropsInfoItemObj) {
    if PropsInfoItemObj.GetValue(&Value) {
        ; When defining a filter, the function should return a nonzero value for any properties
        ; which you want to **exclude**. This approach has the benefit of allowing us to
        ; short-circuit the process by placing functions that we know will exclude the most
        ; properties at the front of the list.
        ; Here, we are excluding any properties for which `GetValue` fails to access a value.
        return 1
    } else if !Value {
        ; And here we are excluding any properties that return a falsy value, so only properties
        ; with a nonzero value are kept.
        return 1
    }
}
; When adding one or more custom filters, `PropsInfoObj.FilterAdd` returns the index assigned to
; the first custom filter in the parameter list.
FilterIndex := PropsInfoObj.FilterAdd(false, MyFilterFunc)
OutputDebug('`n' A_LineNumber ': ' PropsInfoObj.Filter.Count) ; 3

; If you need to delete a filter, you can delete it by index. Remember, indices 0-4 are for
; the built-in filters. We added `1` earlier.
OutputDebug('`n' A_LineNumber ': ' PropsInfoObj.Filter.Has(1)) ; 1
PropsInfoObj.FilterDelete(1)
OutputDebug('`n' A_LineNumber ': ' PropsInfoObj.Filter.Has(1)) ; 0

; Saving the index is not necessary, as you can pass the function object to `FilterDelete` to
; iterate the filter items and delete the filter associated with that function.
OutputDebug('`n' A_LineNumber ': ' PropsInfoObj.Filter.Has(FilterIndex)) ; 1
; The filter object is returned upon deletion.
Filter := PropsInfoObj.FilterDelete(MyFilterFunc)
OutputDebug('`n' A_LineNumber ': ' PropsInfoObj.Filter.Has(FilterIndex)) ; 0
OutputDebug('`n' A_LineNumber ': ' (Filter.Index == FilterIndex)) ; 1
OutputDebug('`n' A_LineNumber ': ' (ObjPtr(MyFilterFunc) == ObjPtr(Filter.Function))) ; 1

; Let's actually add that one back, this time we'll let the filter activate. Before we do let's
; get a copy of the properties as a map object.
PropsInfoAsMap := PropsInfoObj.ToMap()
FilterIndex2 := PropsInfoObj.FilterAdd(true, MyFilterFunc)
OutputDebug('`n' A_LineNumber ': ' PropsInfoObj.Filter.Count) ; 2

; Note how it's a new index.
OutputDebug('`n' A_LineNumber ': ' PropsInfoObj.Filter.Has(FilterIndex)) ; 0
OutputDebug('`n' A_LineNumber ': ' PropsInfoObj.Filter.Has(FilterIndex + 1)) ; 1

; Upon activation, the filter is processed immediately and becomes active on the object.
; We're checking the map object to demonstrate the property was present before the filter.
OutputDebug('`n' A_LineNumber ': ' PropsInfoAsMap.Has('__New')) ; 1
; After filtering.
OutputDebug('`n' A_LineNumber ': ' PropsInfoObj.Has('__New')) ; 0

OutputDebug('`n' A_LineNumber ': ' PropsInfoAsMap.Has('Length')) ; 1
OutputDebug('`n' A_LineNumber ': ' PropsInfoObj.Has('Length')) ; 0

; This gives us a convenient method for systematically selecting what properties we want to use
; for whatever it is we want to use them for.

; The following methods and properties are influenced by the filter:
; __Enum, Get, GetFilteredProps (if a function object is not passed to it), Has, ToArray, ToMap,
; __Item, Capacity, Count, Length

try {
    PropsInfoObj.Get('Capacity')
    throw Error('Successfully got ``Capacity``.', -1)
} catch Error as err {
    OutputDebug('`n' A_LineNumber ': ' err.Message) ; Invalid input. While the `PropsInfo` object...
}

; Whoops! I actually made this mistake writing this but decided to leave it in because it's a good
; example. The filter activation process itself is not influenced by string mode. String mode
; and filters are compatible. But don't forget to turn off string mode if you intend to access
; `PropsInfoItem` objects instead of property names.

; Let's turn off string mode then do that again.
PropsInfoObj.StringMode := 0

try {
    PropsInfoObj.Get('Capacity')
    throw Error('Successfully got ``Capacity``.', -1)
} catch Error as err {
    OutputDebug('`n' A_LineNumber ': ' err.Message) ; Item has no value.
}
; From the map object.
OutputDebug('`n' A_LineNumber ': ' Type(PropsInfoAsMap.Get('Capacity'))) ; PropsInfoItem

; If your code needs to check whether filters are active, check the `FilterActive` property.
OutputDebug('`n' A_LineNumber ': ' PropsInfoObj.FilterActive) ; 1

; Let's see what properties were included, and their values.
s := ''
for Name, InfoItem in PropsInfoObj {
    if r := InfoItem.GetValue(&Value) {
        throw Error('Failed to get value. Code: ' r, -1)
    } else {
        s .= Name ': ' (IsObject(Value) ? '{' Type(Value) '}, ' : Value ', ')
    }
}
OutputDebug('`n' A_LineNumber ': ' Trim(s, ', ')) ; __Class: Alpha, __Prop: Hello!, Base: {Prototype}, Prop: 10000, Prop2: $.Prop2 property value

; Let's remove `Capacity` and `Length` from the filter, add something to the array, and check again.

; First let's check what's in the list.
OutputDebug('`n' A_LineNumber ': ' PropsInfoObj.Filter.Exclude) ; ,Length,Capacity,__New,__Init,
PropsInfoObj.FilterRemoveFromExclude('Capacity,Length')
OutputDebug('`n' A_LineNumber ': ' PropsInfoObj.Filter.Exclude) ; ,__New,__Init,

; Add some value.
AlphaObj.Push('Value')

; Reactivate the filter.
PropsInfoObj.FilterActivate()
if r := PropsInfoObj.Get('Capacity').GetValue(&Capacity) {
    throw Error('Failed to get value. Code: ' r, -1)
} else {
    ; Capacity is available.
    OutputDebug('`n' A_LineNumber ': ' Capacity) ; 1
}
if r := PropsInfoObj.Get('Capacity').GetValue(&Length) {
    throw Error('Failed to get value. Code: ' r, -1)
} else {
    ; Length is available.
    OutputDebug('`n' A_LineNumber ': ' Length) ; 1
}

; To cache the filter to reuse later, call `FilterCache`. You must give it a name. We'll name this
; one 'MyCacheName'.
PropsInfoObj.FilterCache('MyCacheName')
OutputDebug('`n' A_LineNumber ': ' PropsInfoObj.__FilterCache.Has('MyCacheName')) ; 1

; To delete a cached filter.
PropsInfoObj.FilterDeleteFromCache('MyCacheName')
OutputDebug('`n' A_LineNumber ': ' PropsInfoObj.__FilterCache.Has('MyCacheName')) ; 0

; You can also cache the filter in the same function call when deactivating it.
PropsInfoObj.FilterDeactivate('MyCacheName')
OutputDebug('`n' A_LineNumber ': ' PropsInfoObj.__FilterCache.Has('MyCacheName')) ; 1
OutputDebug('`n' A_LineNumber ': ' PropsInfoObj.FilterActive) ; 0

; To activate a cached filter.
PropsInfoObj.FilterActivateFromCache('MyCacheName')
OutputDebug('`n' A_LineNumber ': ' PropsInfoObj.FilterActive) ; 1

; That about covers the main methods and properties. When you're done with your `PropsInfo` object,
; it's a good idea to call `Dispose` to avoid any possible reference cycles preventing resources
; from being freed.
PropsInfoObj.Dispose()

