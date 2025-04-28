
#Include Inheritance.ahk

class Alpha extends Alpha.base {
    __New() {
        this.DefineProp('Prop2', { Value: '$.Prop2 property value' })
    }

    static Method3(Param) {
        return Param * 10
    }

    static __ValueProp := 0
    static Prop3 {
        Get {
            return this.__ValueProp
        }
        Set {
            if IsNumber(Value) {
                this.__ValueProp := Value
            } else {
                throw TypeError('Value must be a number.', -1)
            }
        }
    }

    Method2() {
        return 'Alpha_return_value'
    }

    Prop3 {
        Get {
            return this.__ValueProp
        }
        Set {
            if IsNumber(Value) {
                this.__ValueProp := Value
            } else {
                throw TypeError('Value must be a number.', -1)
            }
        }
    }

    PropA => 1997
    PropB => ''

    class base extends Array {
        method() {
            return 'Alpha.base_return_value'
        }
        method2() {
            return 'Alpha.base_return_value'
        }

        Prop {
            Get => 'Hello!'
            Set => 'Just kidding, this returns a value'
        }

        Prop2 {
            Get => 'Goodbye!'
            Set => this.__OtherValueProp := Value
        }
    }
}

; To work through the walkthrough, load it up in a debugger and step through it.
; If you don't want to use a debugger, use text replace to replace
; OutputDebug('`n'
; with
; MsgBox(

; First let's make our `PropsInfo` object

AlphaObj := Alpha()
AlphaPropsInfo := GetPropsInfo(AlphaObj, , , , &BaseObjectsList)

    ; Accessing the objects

; The top-level `InfoItemObj` (the item directly accessible from the `PropsInfo` object) is
; always produced by the object's own property, or the base object from which it inherited the
; property.

; We can get the `PropsInfoItem` object by name.
AlphaObj_Method2Info := AlphaPropsInfo.Get('Method2')

; The `PropsInfoItem` objects are also associated with indices. This is to enable the object
; to emulate the behavior of an array. If you need to find out the index of a specific property,
; you can call `GetIndex`. Generally I don't expect this to be necessary.
OutputDebug('`n' A_LineNumber ': ' AlphaPropsInfo.GetIndex('Method2')) ; 16

; The item index is different than the `Index` property as read on the object itself.
; The `Index` property represents the position in the inheritance chance of the base object from
; which the property was inherited.
; The index is 1 because this is the `InfoItemObj` associated with the first base object.
OutputDebug('`n' A_LineNumber ': ' AlphaObj_Method2Info.Index) ; 1

; We can get the actual function object by calling `GetFunc`
AlphaObj_Method2Func := AlphaObj_Method2Info.GetFunc()

; As we see, though `Alpha.base` also has a `Method2`, `Method2` from `Alpha` is returned.
OutputDebug('`n' A_LineNumber ': ' AlphaObj_Method2Func('')) ; Alpha_return_value

; The other `Method2` is available on the `Alt` array.
AlphaBaseMethod2Info := AlphaObj_Method2Info.Alt[1]
AlphaBaseMethod2Func := AlphaBaseMethod2Info.GetFunc()
OutputDebug('`n' A_LineNumber ': ' AlphaBaseMethod2Func('')) ; Alpha.base_return_value

    ; Function names

; You can also check this way. The `Name` property is a built-in property of all
; function objects.
OutputDebug('`n' A_LineNumber ': ' AlphaObj_Method2Func.Name) ; Alpha.Prototype.method2
OutputDebug('`n' A_LineNumber ': ' AlphaBaseMethod2Func.Name) ; Alpha.base.Prototype.method2

; Incidentally, the `PropsInfoItem` objects also have a `Name` property, but
; these are separate values.
OutputDebug('`n' A_LineNumber ': ' AlphaObj_Method2Info.Name) ; Method2
OutputDebug('`n' A_LineNumber ': ' AlphaBaseMethod2Info.Name) ; Method2

; But let's say we did this
SomeFunc(this, Param) {
    return Param * 45
}
; `Method2` is now an own property relative to `AlphaObj`.
AlphaObj.DefineProp('Method2', { Call: SomeFunc })

; We must get a new object to see the change
NewAlphaPropsInfo := GetPropsInfo(AlphaObj)

; Get the `PropsInfoItem` object
NewAlphaObj_Method2Info := NewAlphaPropsInfo.Get('Method2')

; The index is 0 because the `PropsInfoItem` object was produced from `AlphaObj`'s own property.
OutputDebug('`n' A_LineNumber ': ' NewAlphaObj_Method2Info.Index) ; 0
AlphaObj_Method2Func := NewAlphaObj_Method2Info.GetFunc()
OutputDebug('`n' A_LineNumber ': ' AlphaObj_Method2Func('', 10)) ; 450

; The name stays "SomeFunc"
OutputDebug('`n' A_LineNumber ': ' AlphaObj_Method2Func.Name) ; SomeFunc

; More on AHK and function names...
; Even if we took a method from a class object and transplanted it onto our object,
; the name wouldn't change.
AlphaObj.DefineProp('ExampleMethod', Alpha.Prototype.GetOwnPropDesc('Method2'))
OutputDebug('`n' A_LineNumber ': ' AlphaObj.ExampleMethod.Name) ; Alpha.Prototype.method2
; Anonymous functions have the name "" (empty string, no quotes).
OutputDebug('`n' A_LineNumber ': ' (()=>'').Name) ;
; Also anonymous functions like this
AlphaObj.DefineProp('ExampleMethod2', { Call: (*) => '' })
OutputDebug('`n' A_LineNumber ': ' AlphaObj.ExampleMethod2.Name) ;

    ; BaseObjectsList

; Back when we called `GetPropsInfo`, we included the `&BaseObjectsList` parameter.
; That variable is now an array containing the base objects for `AlphaObj` up to
; and not including `Object.Prototype`.
; To get an object associated with a `PropsInfoItem` object, use the index property.
AlphaPrototype := BaseObjectsList[AlphaObj_Method2Info.Index]
OutputDebug('`n' A_LineNumber ': ' AlphaPrototype.__Class) ; Alpha
OutputDebug('`n' A_LineNumber ': ' AlphaPrototype.Method2.Name) ; Alpha.Prototype.Method2
AlphaBasePrototype := BaseObjectsList[AlphaBaseMethod2Info.Index]
OutputDebug('`n' A_LineNumber ': ' AlphaBasePrototype.__Class) ; Alpha.base

; There's more we can do with a `PropsInfo` object than check function names. For example, let's
; say I have a function that accepts an array of property names to perform some function. Perhaps
; it copies the property values from one object to another.

Transplantinator(Subject, Target, PropsList?) {
    ; If `PropsList` is set
    if IsSet(PropsList) {
        if Type(PropsList) !== 'Array' {
            throw TypeError('PropsList must be an array.', -1)
        }
        ; Call `PropsList`'s enumerator
        Enum := ObjBindMethod(PropsList, '__Enum', 1)
    } else {
        ; Else, call `OwnProps` on the input `Subject`.
        Enum := ObjBindMethod(Subject, 'OwnProps')
    }
    for Prop in Enum() {
        if HasProp(Subject, Prop) {
            try {
                Target.DefineProp(Prop, { Value: Subject.%Prop% })
            }
        }
    }
    return Target
}

    ; Uses of `PropsInfo` class

; To get a list of property names, we first turn on `StringMode`.
AlphaPropsInfo.StringMode := 1

; `StringMode` modifies the behavior of `__Enum`, `Get`, and `__Item` of the `PropsInfo` object.
; `StringMode` tells the object that it should behave like an array of strings.

; For example, we can enumerate it:
for prop in AlphaPropsInfo {
    str .= prop ', '
}
OutputDebug('`n' A_LineNumber ': ' Trim(str, ', ')) ; __Class, __Enum, __Init, __Item, __New, __OtherValueProp, etc...

; If we turn `StringMode` off, we get objects
AlphaPropsInfo.StringMode := 0
for InfoItemObj in AlphaPropsInfo {
    str2 .= InfoItemObj.Name ', '
}
OutputDebug('`n' A_LineNumber ': ' Trim(str2, ', ')) ; __Class, __Enum, __Init, __Item, __New, __OtherValueProp, etc...

; Back to string mode
AlphaPropsInfo.StringMode := 1

; Let's try passing it to Transplantinator
try {
    Transplantinator(AlphaObj, {}, AlphaPropsInfo)
} catch Error as err {
    OutputDebug('`n' A_LineNumber ': ' err.Message) ; TypeError: PropsList must be an array.
}

; Sometimes functions check a parameter's type before proceeding to prevent unhandled errors.
; We have three approaches to handle this.
; We can enumerate the strings like we did above and fill an array that way, but there's no need to
; do that.

; We can get a proxy.
AlphaProxy := AlphaPropsInfo.GetProxy(1) ; 1 = array, 2 = map

; This won't be a 1:1 clone for various reasons.
AlphaClone := Transplantinator(AlphaObj, {}, AlphaProxy)
; If you need a DeepClone method: https://github.com/Nich-Cebolla/AutoHotkey-Object.Prototype.DeepClone/

OutputDebug('`n' A_LineNumber ': ' AlphaClone.__Class) ; Alpha

; Note the proxy fails this type of check
OutputDebug('`n' A_LineNumber ': ' (AlphaProxy is Array)) ; 0

; But that's okay because we can just get an array
; `true` to get an array of property names, otherwise it returns an array of objects
Arr := AlphaPropsInfo.ToArray(true)
AlphaClone2 := Transplantinator(AlphaObj, {}, Arr)
OutputDebug('`n' A_LineNumber ': ' AlphaClone2.__Class) ; Alpha

    ; Filters

; Let's say we only want properties that have a value that isn't zero or an empty string to be
; added to the target object. `PropsInfo` objects have a built-in filter system to make this
; easy and consistent.

; There are five built-in filters. See the function's parameter hint for details.

; To use a built-in filter, add it by index.
; `False` to the first parameter to prevent activating the filter since we're adding more.
FilterIndex := AlphaPropsInfo.FilterAdd(false, 1)
OutputDebug('`n' A_LineNumber ': ' AlphaPropsInfo.Filter.Count) ; 1
; More on `FilterIndex` in a bit.

; 1-4 are associated with functions located within the `FilterAdd` function definition. The fifth
; filter allows you to exclude properties by name.
; A comma-delimited list works.
FilterIndex2 := AlphaPropsInfo.FilterAdd(false, 'Length,Capacity')
OutputDebug('`n' A_LineNumber ': ' AlphaPropsInfo.Filter.Count) ; 2

; Or you could separate them into separate items.
FilterIndex3 := AlphaPropsInfo.FilterAdd(false, '__New', '__Init')
; This is still 2 because the strings were consolidated into the original string.
OutputDebug('`n' A_LineNumber ': ' AlphaPropsInfo.Filter.Count) ; 2

; You can also filter properties with a function. The function should accept a `PropsInfoItem` object.
MyFilterFunc(PropsInfoObj) {
    if PropsInfoObj.Index {
        if !PropsInfoObj.GetValue(&Value, BaseObjectsList[PropsInfoObj.Index]) {
            ; When defining a filter, the function should return a nonzero value for any properties which
            ; you want to **exclude**. This approach has the benefit of allowing us to short-circuit
            ; the process by placing functions that we know will exclude the most properties at the
            ; front of the list.
            return 1
        }
    } else {
        if !PropsInfoObj.GetValue(&Value, BaseObjectsList.Root) {
            return 1
        }
    }
}
FilterIndex4 := AlphaPropsInfo.FilterAdd(false, MyFilterFunc)
OutputDebug('`n' A_LineNumber ': ' AlphaPropsInfo.Filter.Count) ; 3

; If we later do not need a particular filter, we can remove it. This is where the `FilterIndex`
; variables come in. When a filter is added, a `PropsInfo.Filter` object is created and added to
; the `PropsInfoObj.Filter` property, which is a map object. The keys of the map object are all
; integers, beginning with 0, which is the filter which excludes properties by name, 1-4 for the
; other built-in filters, then incrementing from 5 onward each time a new filter is added.
; `FilterAdd` never backtracks to a used index, even if the associated item is deleted from the
; map object. The index returned by `FilterAdd` is the starting index, that is, the index associated
; with the first item in the list of parameters within the function call. Your code does not
; necessarily need to keep track of this, but it may be helpful to.

; If you need to delete a filter, you can delete it by index:
OutputDebug('`n' A_LineNumber ': ' AlphaPropsInfo.Filter.Has(FilterIndex)) ; 1
AlphaPropsInfo.FilterDelete(FilterIndex)
OutputDebug('`n' A_LineNumber ': ' AlphaPropsInfo.Filter.Has(FilterIndex)) ; 0

; Or you can iterate the filters and identify one by name, as we saw earlier all functions
; except anonymous functions have a name.
OutputDebug('`n' A_LineNumber ': ' AlphaPropsInfo.Filter.Has(FilterIndex4)) ; 1
for Index, FilterObj in AlphaPropsInfo.Filter {
    if FilterObj.Name == 'MyFilterFunc' {
        AlphaPropsInfo.FilterDelete(FilterObj.Index)
    }
}
OutputDebug('`n' A_LineNumber ': ' AlphaPropsInfo.Filter.Has(FilterIndex4)) ; 0

; Let's actually add that one back, this time we'll let the filter activate. Before we do let's
; get a copy of the properties as a map object.
AlphaPropsAsMap := AlphaPropsInfo.ToMap()
AlphaPropsInfo.FilterAdd(true, MyFilterFunc)
OutputDebug('`n' A_LineNumber ': ' AlphaPropsInfo.Filter.Count) ; 3

; It's a new index
OutputDebug('`n' A_LineNumber ': ' AlphaPropsInfo.Filter.Has(FilterIndex4)) ; 0
OutputDebug('`n' A_LineNumber ': ' AlphaPropsInfo.Filter.Has(FilterIndex4 + 1)) ; 1

; Upon activation, the filter is processed immediately and becomes active on the object.
; Let's try it out
; Map object containing props from before the filter
OutputDebug('`n' A_LineNumber ': ' AlphaPropsAsMap.Has('__New')) ; 1
; After filtering
OutputDebug('`n' A_LineNumber ': ' AlphaPropsInfo.Has('__New')) ; 0

OutputDebug('`n' A_LineNumber ': ' AlphaPropsAsMap.Has('__Init')) ; 1
OutputDebug('`n' A_LineNumber ': ' AlphaPropsInfo.Has('__Init')) ; 0

OutputDebug('`n' A_LineNumber ': ' AlphaPropsAsMap.Has('Length')) ; 1
OutputDebug('`n' A_LineNumber ': ' AlphaPropsInfo.Has('Length')) ; 0

; This gives us a convenient method for systematically selecting what properties we want to use
; for whatever it is we want to use them for.

; Most methods are influenced by the filter.
try {
    AlphaPropsInfo.Get('Capacity')
} catch Error as err {
    OutputDebug('`n' A_LineNumber ': ' err.Message) ; Invalid input. While the `PropsInfo` object is in string mode, items can only be accessed using numeric indices.
}

; Whoops! I actually made this mistake writing this but decided to leave it in because it's a good
; example. The filter activation process itself is not influenced by string mode, and string mode
; and filters are compatible. But don't forget to turn off string mode if you intend to access
; `PropsInfoItem` objects instead of property names.

; Let's turn off string mode then do that again.
AlphaPropsInfo.StringMode := 0

try {
    AlphaPropsInfo.Get('Capacity')
} catch Error as err {
    OutputDebug('`n' A_LineNumber ': ' err.Message) ; Item has no value.
}
; From the map object
OutputDebug('`n' A_LineNumber ': ' Type(AlphaPropsAsMap.Get('Capacity'))) ; PropsInfoItem

; If your code needs to check whether filters are active, check the `FilterActive` property.
OutputDebug('`n' A_LineNumber ': ' AlphaPropsInfo.FilterActive) ; 1

; To cache the filter to reuse later, call `FilterCache`. You must give it a name. We'll name this
; one an integer `1` value.
AlphaPropsInfo.FilterCache(1)
OutputDebug('`n' A_LineNumber ': ' AlphaPropsInfo.__FilterCache.Has(1)) ; 1

; To delete a cached filter
AlphaPropsInfo.FilterDeleteFromCache(1)
OutputDebug('`n' A_LineNumber ': ' AlphaPropsInfo.__FilterCache.Has(1)) ; 0

; You can also cache the filter in the same function call when deactivating it
AlphaPropsInfo.FilterDeactivate(1)
OutputDebug('`n' A_LineNumber ': ' AlphaPropsInfo.__FilterCache.Has(1)) ; 1

; To activate a cached filter
AlphaPropsInfo.FilterActivateFromCache(1)
OutputDebug('`n' A_LineNumber ': ' AlphaPropsInfo.FilterActive) ; 1

; To remove an excluded property from the list
AlphaPropsInfo.FilterRemoveFromExclude('Capacity')
OutputDebug('`n' A_LineNumber ': ' AlphaPropsInfo.Filter.Exclude) ; ,Length,__New,__Init,

; Okay let's deactivate it one more time
AlphaPropsInfo.FilterDeactivate()
OutputDebug('`n' A_LineNumber ': ' AlphaPropsInfo.FilterActive) ; 0

    ; A couple final topics to touch on

; Earlier we defined a filter function that uses the `GetValue` method. You may have noticed the
; second parameter of the method was passed an object from the `BaseObjectsList` array.
; When calling the `GetValue` method, if we do not know what object the method is
; being called on, or if we know the object is associated with a dynamic property, then we must pass
; something to the second parameter. This would typically be the object which owns the property,
; though it doesn't have to be. This is because any dynamic properties will require the object to
; call the function. For value properties, the associated `PropInfoObj.GetValue()` can be called
; without the object.

; In the case of our `MyFilterFunc` function, since we can assume that `PropsInfoItem` objects
; associated with dynamic properties will be passed to this function, we must define the function to
; pass the object to the `GetValue` method call. Luckily, this is easy, as seen in the definition.
; Here's another example of how to get a base object from an `PropsInfoItem` object
InfoItemObj := AlphaPropsInfo.Get('Prop')
PropOwnerObj := BaseObjectsList[InfoItemObj.Index]
OutputDebug('`n' A_LineNumber ': ' PropOwnerObj.__Class) ; Alpha.base

; Items can be accessed using `Obj[]` notation.
InfoItemObj := AlphaPropsInfo['Prop2']

; `Prop2` is an own property, so the object associated with it (`AlphaObj`) is not within the
; `BaseObjectsList` array. If in whatever scope you're working in does not have a reference
; to the object originally passed to `GetPropsInfo`, you can get the reference from the `Root`
; property of `BaseObjectsList` array. My tests determined this does not create a reference cycle,
; and letting `BaseObjectsList` go out of scope, expire, or become unset, will decrement the reference
; count for the base objects and the root object.
OutputDebug('`n' A_LineNumber ': ' BaseObjectsList.Root.__Class) ; Alpha
OutputDebug('`n' A_LineNumber ': ' AlphaPropsInfo.Get('Prop2').Index) ; 0

; That about covers the main stuff. If you encounter an unexpected error please submit a
; issue in the repository.
