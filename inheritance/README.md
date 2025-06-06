
# Inheritance - v1.4.0

## Table of Contents

<ol type="I">
  <a href="#introduction"><li>Introduction</li></a>
  <a href="#getpropsinfo"><li>GetPropsInfo</li></a>
  <a href="#propsinfo-class"><li>PropsInfo class</li></a>
  <ol type="A">
    <a href="#propsinfo---instance-methods"><li>PropsInfo - instance methods</li></a>
    <a href="#propsinfo---instance-properties"><li>PropsInfo - instance properties</li></a>
    <a href="#propsinfo---accessing-items-by-index"><li>PropsInfo - accessing items by index</li></a>
    <a href="#propsinfofilter"><li>PropsInfo.Filter</li></a>
    <a href="#propsinfofiltergroup"><li>PropsInfo.FilterGroup</li></a>
    <a href="#propsinfoproxy_array"><li>PropsInfo.Proxy_Array</li></a>
    <a href="#propsinfoproxy_map"><li>PropsInfo.Proxy_Map</li></a>
  </ol>
  <a href="#propsinfoitem-class"><li>PropsInfoItem class</li></a>
  <ol type="A">
    <a href="#propsinfoitem---instance-methods"><li>PropsInfoItem - instance methods</li></a>
    <a href="#propsinfoitem---instance-properties"><li>PropsInfoItem - instance properties</li></a>
  </ol>
  <a href="#classfactory"><li>ClassFactory</li></a>
  <a href="#getbaseobjects"><li>GetBaseObjects</li></a>
  <a href="#getpropdesc"><li>GetPropDesc</li></a>
  <a href="#for-learners"><li>For Learners</li></a>
  <a href="#included-files"><li>Included Files</li></a>
  <a href="#changelog"><li>Changelog</li></a>
</ol>

## Introduction

Inheritance is a library containing four functions to aid working with AHK's object inheritance model.

AHK forum post: https://www.autohotkey.com/boards/viewtopic.php?f=83&t=137065&p=603092#p603092

- GetPropsInfo - The most robust function of the library, `GetPropsInfo` returns a `PropsInfo` object exposing various details about the input object's own and inherited properties.
- ClassFactory - `ClassFactory` is a short function that creates a class constructor out of some input object. There are occasions when it is beneficial to create a class constructor dynamically. That's what this function does.
- GetBaseObjects - A simple function that returns an array containing references to base objects in an object's inheritance chain, up to a given stopping point.
- GetPropDesc - Returns the property descriptor object from the first object in the input object's inheritance chain that owns a given property.

## GetPropsInfo

Constructs a `PropsInfo` object, which is a flexible solution for cases when a project would benefit from being able to quickly obtain a list of all of an object's properties, and/or filter those properties.

In this documentation, an instance of `PropsInfo` is referred to as either "a `PropsInfo` object" or `PropsInfoObj`. An instance of `PropsInfoItem` is referred to as either "a `PropsInfoItem` object" or `InfoItem`.

See example-Inheritance.ahk for a walkthrough on how to use the class.

`PropsInfo` objects are designed to be a flexible solution for accessing and/or analyzing an object's properties, including inherited properties. Whereas `OwnProps` only iterates an objects' own properties, `PropsInfo` objects can perform these functions for both inherited and own properties:

- Produce an array of property names.
- Produce a `Map` where the key is the property name and the object is a `PropsInfoItem` object for each property.
- Produce an array of `PropsInfoItem` objects.
- Be passed to a function that expects an iterable object like any of the three above bullet points.
- Filter the properties according to one or more conditions.
- Get the function objects associated with the properties.
- Get the values associated with the properties.

`PropsInfoItem` objects are modified descriptor objects. After getting the descriptor object, `GetPropsInfo` changes the descriptor object's base exposing additional properties. See the parameter hints above each property for details. See https://www.autohotkey.com/docs/v2/lib/Object.htm#GetOwnPropDesc.

### Parameters

- {*} Obj - The object from which to get the properties.
- {Integer|String} [StopAt=GPI_STOP_AT_DEFAULT ?? '-Object'] - If an integer, the number of base objects to traverse up the inheritance chain. If a string, the name of the class to stop at. You can define a global variable `GPI_STOP_AT_DEFAULT` to change the default value. If GPI_STOP_AT_DEFAULT is unset, the default value is '-Object', which directs `GetPropsInfo` to include properties owned by objects up to but not including `Object.Prototype`. See the parameter hint above `GetBaseObjects` within the code file "GetBaseObjects.ahk" for full details about this parameter.
- {String} [Exclude=''] - A comma-delimited, case-insensitive list of properties to exclude. For example: "Length,Capacity,__Item".
- {Boolean} [IncludeBaseProp=true] - If true, the object's `Base` property is included. If false, `Base` is excluded.
- {VarRef} [OutBaseObjList] - A variable that will receive a reference to the array of base objects that is generated during the function call.
- {Boolean} [ExcludeMethods=false] - If true, callable properties are excluded. (Added in 1.3.1).

### Returns

Returns an instance of `PropsInfo`.

## PropsInfo class

This is a list and brief description of the properties and methods available from the `PropsInfo` class. For parameters and further details, see the inline documentation within the code file "GetPropsInfo.ahk".

Each `PropsInfo` object is a container for one or more `PropsInfoItem` object references. It is through the `PropsInfo` object that our code can access the details about any specific property. See the example file "example-Inheritance.ahk" for a walkthrough of what `PropsInfo` objects can be used for.

### PropsInfo - instance methods

- __New - The class constructor. This is not intended to be called directly, and instead instances should be created by calling the function `GetPropsInfo`.
- __Enum - The enumerator. When calling a `PropsInfo` object from a `for` loop, `PropsInfoObj.__Enum`'s behavior varies depending on the `PropsInfoObj.StringMode` and `PropsInfoObj.FilterActive` property values.
- Add - Updates the `PropsInfoItem` objects associated with the property names passed to the function, adding any items if currently absent from the collection. (Added in 1.4.0)
- Delete - Removes the `PropsInfoItem` object associated with each name passed to the function. (Added in 1.4.0)
- Dispose - Call this every time your code is finished using a `PropsInfo` object. If you do not, you risk a reference cycle preventing some resources from being freed.
- FilterActivate - Activates the current filter on the object. The following is a brief description of filters in general. `PropsInfo` objects have a built-in filter system that allows us to exclude certain properties from being accessed via the object. This is useful for situations when our code must respond to or interact with some properties but not others.
- FilterActivateFromCache - Activates a cached filter.
- FilterAdd - Adds a function to the filter.
- FilterCache - Caches the current filter.
- FilterClear - Clears the current filter (does not change cached filters).
- FilterClearCache - Clears the cached filters (does not change the current filter).
- FilterDeactivate - Deactivates the currently active filter. When called, all properties that were previously excluded by the filter become available again.
- FilterDelete - Deletes a filter object from the currently active filter.
- FilterDeleteFromCache - Deletes a cached filter.
- FilterGetList - Returns a comma-delimited list of property names that were filtered out by the currently active filter. (Added in 1.4.0)
- FilterRemoveFromExclude - Removes a property name from the string list of properties to exclude.
- FilterSet - Sets the `PropsInfoObj.Filter` property with the input `PropsInfo.FilterGroup` object.
- Get - Returns a `PropsInfoItem` object using a string name or integer index as the key. Note that the object's current value of `PropsInfoObj.StringMode` infleunces this method's behavior. See the section below "Accessing items by index".
- GetIndex - Accepts a property name as string as input and returns the index value of the associated `PropsInfoItem` object.
- GetProxy - Returns a proxy that can be passed to a function that expects an array or map.
- GetFilteredProps - Returns a container object that has been populated with references to `PropsInfoItem` objects that have been processed through a filter.
- Has - Returns nonzero if an item exists in the `PropsInfo` object's internal collection.
- Refresh - Updates all `PropsInfoItem` objects within the collection to reflect the current state of the root object and the base objects. (Added in 1.4.0)
- ToArray - Returns an array of property names as string, or `PropsInfoItem` objects.
- ToMap - Returns a map with keys that are property names and values that are `PropsInfoItem` objects.

### PropsInfo - instance properties

- Excluded - A comma-delimited list of properties that are not exposed by the `PropsInfo` object. This does not included properties that are excluded by the active filter. (Added in 1.4.0)
- Filter - A `Map` object where the key is an index as integer and the value is the `PropsInfo.Filter` object created by calling `PropsInfoObj.FilterAdd`.
- FilterActive - Initially `0`. If you set `PropsInfoObj.FilterActive := <nonzero value>` it will call `PropsInfoObj.FilterActivate`. If you set `PropsInfoObj.FilterActive := <falsy value>`, it will call `PropsInfoObj.FilterDeactivate`.
- StringMode - Initially `0`. If you set `PropsInfoObj.StringMode := <nonzero value>`, "string mode" becomes active on the `PropsInfo` object. While `PropsInfoObj.StringMode == 1`, the `PropsInfo` object behaves like an array of property names as string. The following are influenced by string mode: `__Enum`, `Get`, `__Item`. By extension, the proxies are also influenced by string mode, though not directly.

The following properties are read-only, and are included to prevent an error when passing a `PropsInfo` object to a function that expects an array or map.

- Capacity, Count, Length - Returns the current item count of one of the `PropsInfo` object's internal containers. `PropsInfo` objects contain multiple internal containers, and so `PropsInfoObj.Capacity` should not be interpreted in terms of memory usage. `PropsInfoObj.Capacity`, `PropsInfoObj.Count`, and `PropsInfoObj.Length` will always be the same value.
- CaseSense - Returns `PropsInfoObj.__InfoIndex.CaseSense`, which will always be "Off".
- Default - Returns `PropsInfoObj.__InfoIndex.Default`, which will always be "0".

### PropsInfo - accessing items by index

Accessing items by index is mostly used internally, but I exposed the functionality to prevent errors when passing a `PropsInfo` object to a function that expects an array. In general you probably won't need this information, and I include it for completeness:

- When `GetPropsInfo` iterates an object's properties and the object's base objects' properties, an item is added to a `Map` object for each unique property name. That `Map` object is passed to the `PropsInfo` constructor, which then iterates the `Map` object, constructing the `PropsInfo` object's internal containers. This carries the consequence of the containers being ordered alphabetically according to the sorting used by the `Map` object's enumerator. Since it is unlikely that any given code is going to have prepared a function to calculate the index values from this approach, you will likely never directly access an item by index. While you can get an item's index value by calling `PropsInfoObj.GetIndex(name)`, there is no reason to do this because your code already has the name, and can get an item that way, except if `PropsInfoObj.StringMode == 1`.
- When `PropsInfoObj.StringMode == 1`, your code loses the ability to access items by calling `PropsInfoObj.Get(name)` or accessing `PropsInfoObj[name]`. When using string mode the object is supposed to emulate the behavior of an array of strings. Accessing an item by name is invalid in this context; throwing an error if the code attempts to access an item by name while using string mode will aid in debugging. Your code can, however, access specific items by index by calling `PropsInfoObj.Get(index)` or accessing `PropsInfoObj[index]`.
- While `PropsInfoObj.FilterActive == 1`, the indices that are associated with a specific `PropsInfoItem` object are correctly shifted to be true to the filtered list. Valid index values begin at 1 and increment by 1 for each item included in the filtered list, though any item's actual position in the `PropsInfo` object's internal container may not be the same.
- Writing the class with the characteristics described in this section was all to enable passing a `PropsInfo` object to a function that expects an array. `GetPropsInfo` should be completely backward-compatible in this respect; old code should not have a problem working with `PropsInfo` objects.

### PropsInfo.Filter

When a function is added to the filter, it gets added as a `PropsInfo.Filter` object. `PropsInfo.Filter` objects have the following properties:

- Name - Returns the function's built-in name, "the function" meaning the function object that was added to `PropsInfoObj.Filter` by calling `PropsInfoObj.FilterAdd`.
- Index - The index associated with the `PropsInfo.Filter` object. The built-in filters have indices 0-4. When one or more custom filters are added using `PropsInfoObj.FilterAdd`, `PropsInfoObj.FilterAdd` returns the index of the first `PropsInfo.Filter` object added to `PropsInfoObj.Filter`; your code would need to calculate the rest (by adding 1 for each additional custom filter added). Saving the index is not necessary because you can simply pass the function object to `PropsInfoObj.FilterDelete` to delete its associated `PropsInfo.Filter` object.
- Function - A reference to the function object.

### PropsInfo.FilterGroup

Added in v1.3.0.

`PropsInfo.FilterGroup` objects inherit from `Map`. The purpose of separating the filter collection object into its own class is to allow us to define a set of filters independently from a `PropsInfo` object. It was always possible to take a `PropsInfoObj.Filter` object and set it onto another `PropsInfo` object's `Filter` property, but the library's design did not give the impression that this would work or was intended. It also required an existing `PropsInfo` object. Now, we can create a filter collection by calling `PropsInfo.FilterGroup()`, add functions to it, and reuse it across any number of `PropsInfo` objects by calling `PropsInfo.Prototype.FilterSet`.

In addition to the methods inherited from `Map`, `PropsInfo.FilterGroup` objects have:

- Add: Adds a function to the filter.
- Delete: Deletes a function from the filter.
- RemoveFromExclude: Removes a property name from the string list of properties to exclude.

In addition to the properties inherited from `Map`, `PropsInfo.FilterGroup` objects have:

- Exclude: A string list of property names to exclude.

### PropsInfo.Proxy_Array

When calling `PropsInfoObj.GetProxy(1)`, the return value is a `PropsInfo.Proxy_Array` object. The `PropsInfo.Proxy_Array` object forwards all property accessors and method calls to the `PropsInfo` object. A `PropsInfo.Proxy_Array` object has these characteristics:

```ahk
proxy_array := PropsInfoObj.GetProxy(1)
MsgBox(Type(proxy_array)) ; Array
MsgBox(proxy_array is Array) ; 1
MsgBox(proxy_array.__Class) ; Array
```

### PropsInfo.Proxy_Map

When calling `PropsInfoObj.GetProxy(2)`, the return value is a `PropsInfo.Proxy_Map` object. The `PropsInfo.Proxy_Map` object forwards all property accessors and method calls to the `PropsInfo` object. A `PropsInfo.Proxy_Map` object has these characteristics:

```ahk
proxy_map := PropsInfoObj.GetProxy(2)
MsgBox(Type(proxy_map)) ; Map
MsgBox(proxy_map is Map) ; 1
MsgBox(proxy_map.__Class) ; Map
```

## PropsInfoItem class

This is a list and brief description of the properties and methods available from the `PropsInfoItem` class. For parameters and further details, see the inline documentation within the code file "GetPropsInfo.ahk".

A `PropsInfoItem` object is a modified descriptor object, exposing additional properties.

### PropsInfoItem - instance methods

In these descriptions, the phrase "the property" means "the object's property that was used to create this `PropsInfoItem` object."

- __New - The class constructor. This is not intended to be called directly. When `GetPropsInfo` is called, the process calls `PropsInfoItem.Prototype.__New` only once. The object returned from that call is then used as the base object for all of the other `PropsInfoItem` objects added to the `PropsInfo` object's internal containers.
- GetFunc - Returns the function object associated with the property.
- GetOwner - Returns the object that owns the property.
- GetValue - Attempts to access the value associated with the property. If successful, the value is assigned to a `VarRef` parameter and the function returns 0. If the property is not a value property nor does it have a `Get` accessor, the function returns 1 and the `VarRef` parameter remains unchanged. If unsuccessful, the error object is assigned to the `VarRef` parameter and the function returns 2.
- Refresh - Calls `GetOwnPropDesc` from the object that owns the property, updating the `PropsInfoItem` object's own properties according to the return value. Said in another way, it updates the cached values to reflect any changes to the original object since the time the `PropsInfoItem` object was created or the last time `Refresh` was called.

### PropsInfoItem - instance properties

In these descriptions, the phrase "the property" means "the object's property that was used to create this `PropsInfoItem` object."

- Alt - For properties that share a name with other properties in an inheritance chain, the `PropsInfoItem` object directly accessible from the `PropsInfo` object will have an `Alt` property. The `Alt` property will return an array containing references to the other `PropsInfoitem` objects. I find this concept challenging to convey using words, and so if this is confusing, the section "E. \`PropsInfoItem\` objects - \`InfoItem.GetFunc\`" within the file "example-Inheritance.ahk" contains code that illustrates what I am trying to convey here. The "Alt" property is only available if the following are both true:
  - The `PropsInfoItem` object's `Count` property is greater than 1 (see below).
  - One of the following are true:
    - The `PropsInfoItem` object is associated with an own property of the object that was passed to `GetPropsInfo`.
    - The `PropsInfoItem` object is associated with an inherited property of the object that was passed to `GetPropsInfo`.
- Count - Returns the number of objects that own a property by the same name within the inheritance chain of the object that was passed to `GetPropsInfo` that produced the `PropsInfoItem` object.
- Index - An integer representing the index position of the object that owns the property relative to the input object's inheritance chain. A value of `0` indicates the property is an own property of the input object. A value of `1` indicates the property is an own property of `InputObj.Base`. A value of `2` indicates the property is an own property of `InputObj.Base.Base` ...
- Kind - Returns a string representation of the kind of property. These are the values:
  - "Call"
  - "Get"
  - "Get_Set"
  - "Set"
  - "Value"
- KindIndex - Returns an integer that specifies the kind of property. These are the values:
  - 1: Callable property (what we call a "method")
  - 2: Dynamic property with only a getter
  - 3: Dynamic property with both a getter and setter
  - 4: Dynamic property with only a setter
  - 5: Value property
- Name - Returns the name of the property.
- Owner - Returns the value returned by `PropsInfoItem.Prototype.GetOwner`.

## ClassFactory

`ClassFactory` returns an instance of `Class` that is created using the input values. The purpose of `ClassFactory` is to handle the boilerplate part of creating a class constructor. Your code needs only to provide the Prototype object. Optionally you can provide a class name and/or a constructor function.

Example using just a base object:
```ahk
; Assume we have a parent object that we want to be accessible from a number of other objects that will not always share the same scope.
MyBaseObj := { Parent: { Id: 1 } }
MyClassFactory := ClassFactory(MyBaseObj)

NewObj := MyClassFactory()
MsgBox(NewObj.Parent.Id) ; 1
```

Example using a constructor function:
```ahk
MyBaseObj := { Type: 'mach 1', specs: GetSpecsFromUser() }
Constructor(obj) {
    if obj.specs == '1200hp' {
        obj.decal := 'purple-trim'
    } else if obj.specs == '1350hp' {
        obj.decal := 'red-trim'
    }
}
Mach1Factory := ClassFactory(MyBaseObj, 'Mach1', Constructor)

NewMach1 := Mach1Factory()

MsgBox(Type(NewMach1)) ; Mach1
MsgBox(NewMach1.specs) ; 1200hp
MsgBox(NewMach1.decal) ; purple-trim

GetSpecsFromuser() {
    return '1200hp'
}
```

Example using an object that inherits from something other than `Object`:
```ahk
class MapEx extends Map {
    instanceproperty {
        get => this.__containerproperty
        set => this.__containerproperty := value
    }

    instancemethod() {
        return 'some value'
    }
}
MyMapEx := MapEx()
; Say I have some other function that I want only accessible to a subset of `MapEx` objects,
; but I don't know which function to use until I get some input from the user.
HelperFunc1(*) {
    return 'do something'
}
HelperFunc2(*) {
    return 'don`'t do something'
}
if GetUserInput() == 1 {
    MyMapEx.DefineProp('Helper', { Call: HelperFunc1 })
} else {
    MyMapEx.DefineProp('Helper', { Call: HelperFunc2 })
}
MapExHelperConstructor := ClassFactory(MyMapEx, 'MapExHelper')
newMapExHelper := MapExHelperConstructor()
MsgBox(newMapExHelper.Helper()) ; do something
newMapEx := MapEx()
MsgBox(newMapEx.Helper()) ; Error: This value of type "MapEx" has no method named "Helper".

GetUserInput() => 1
```

This is how I typically use `ClassFactory`.
```ahk
class Parent {
    __New() {
        this.Value := 'Parent'
        B := this.__ChildBase := { Parent: this }
        ObjSetBase(B, Child.Prototype)
        this.ChildConstructor := ClassFactory(B)
        this.__Item := []
    }
    AddChild(Params) {
        Constructor := this.ChildConstructor
        this.__Item.Push(Constructor(Params))
        return this.__Item[-1]
    }
    Dispose() {
        ; To break the reference cycle, we only need to delete the `Parent` property from the
        ; base object. Much better than keeping track of all of the child objects and breaking
        ; the reference cycle for each one individually.
        this.__ChildBase.DeleteProp('Parent')
        ; Deleting these to force an error if they are accessed since they are no longer valid.
        this.DeleteProp('__ChildBase')
        this.DeleteProp('ChildConstructor')
        this.DeleteProp('__Item')
    }
}

class Child {
    __New(Params) {
        for Prop, Val in Params.OwnProps() {
            this.Prop := Val
        }
    }
    ; Some class definition
}

_parent := Parent()
_child := _parent.AddChild({ Prop: 'Val' })
MsgBox(_child.Prop) ; Val
MsgBox(_child.Parent.Value) ; Parent
_parent.Dispose()
MsgBox(_child.Parent.Value) ; Error: This value of type "Child" has no property named "Parent".
```

### Parameters

- {*} Prototype - The object to use as the new class's prototype.
- {String} [Name] - The name of the new class. This gets assigned to `Prototype.__Class`.
- {Function} [Constructor] - An optional constructor function that is assigned to `NewClassObj.Prototype.__New`. When set, this function is called for each new instance. When unset, the constructor function associated with `Prototype.__Class` is called.

### Returns

{Class} - The new class object. The object will have a `Prototype` property. Instances of the class can be created by calling the object.

## GetBaseObjects

`GetBaseObjects` returns an array of references to objects in the input object's inheritance chain.

### Parameters

- {Object} Obj - The object from which to get the base objects.
- {+Integer|String} [StopAt=GBO_STOP_AT_DEFAULT ?? '-Any'] - If an integer, the number of base objects to traverse up the inheritance chain. If a string, the case-insensitive name of the class to stop at. If falsy, the function will traverse the entire inheritance chain up to but not including `Any`.
<br><br>
If you define global variable `GBO_STOP_AT_DEFAULT` with a value somewhere in your code, that value will be used as the default for the function call. Otherwise, '-Any' is used.
<br><br>
There are two ways to modify the function's interpretation of this value:
  - Stop before or after the class: The default is to stop after the class, such that the base object associated with the class is included in the result array. To change this, include a hyphen "-" anywhere in the value and `GetBaseObjects` will not include the last iterated object in the result array.
  - The type of object which will be stopped at: This only applies to `StopAt` values which are strings. In the code snippets below, `b` is the object being evaluated.
    - Stop at a prototype object (default): `GetBaseObjects` will stop at the first prototype object with a `__Class` property equal to `StopAt`. This is the literal condition used: `Type(b) == 'Prototype' && (b.__Class = 'Any' || b.__Class = StopAt)`.
    - Stop at a class object: To direct `GetBaseObjects` to stop at a class object tby he name `StopAt`, include ":C" at the end of `StopAt`, e.g. `StopAt := "MyClass:C"`. This is the literal condition used: `Type(b) == 'Class' && ObjHasOwnProp(b, 'Prototype') && b.Prototype.__Class = StopAt`.
    - Stop at an instance object: To direct `GetBaseObjects` to stop at an instance object of type `StopAt`, incluide ":I" at the end of `StopAt`, e.g. `StopAt := "MyClass:I"`. This is the literal condition used: `Type(b) = StopAt`.

## GetPropDesc

`GetPropDesc` returns the descriptor object from the first object in the input object's inheritance chain that owns a given property.

### Parameters

- {Object} Obj - The object from which to get the property descriptor.
- {String} Prop - The name of the property.
- {VarRef} [OutObj] - A variable that will receive a reference to the object which owns the property.
- {VarRef} [OutIndex] - A variable that will receive the index position of the object which owns the property in the inheritance chain.

### Returns

{Object} - If the property exists, the property descriptor object. Else, an empty string.

## For Learners

AutoHotkey attracts a lot of new and amateur programmers, and learning how to work with classes and object inheritance is one the things I found most challenging when I was getting started. With this in mind, I wrote the inline documentation to be descriptive and explanatory in the hopes that it may help others grow in this area. The file "example-Inheritance.ahk" is a walkthrough that will take you step by step through the primary methods available from a `PropsInfo` object and its child `PropsInfoItem` objects.

That said, I do not explain fundamental concepts that one might need to know to understand or contextualize some of the explanations. If your goal is to learn, you should have at least skimmed the following pages to know what is available there before getting started, so you can refer back to them later if something is not making sense:

- https://www.autohotkey.com/docs/v2/Concepts.htm#objects
- https://www.autohotkey.com/docs/v2/Concepts.htm#object-protocol
- https://www.autohotkey.com/docs/v2/lib/Object.htm
- https://www.autohotkey.com/docs/v2/Objects.htm

These are the general concepts that `Inheritance` builds from:

- What is an object, a property, and a method
- What is a function object (`Func`)
- How to access and change a base object
- The difference between an own and inherited property
- How overriding a property works
- What is a `class` in AHK's object model

## Included files

- ClassFactory.ahk - Contains `ClassFactory`.
- example-Inheritance.ahk - Contains a walkthrough demonstrating the usage of `GetPropsInfo` and a `PropsInfo` object.
- GetBaseObjects.ahk - Contains `GetBaseObjects`.
- GetPropDesc.ahk - Contains `GetPropDesc`.
- GetPropsInfo-info.md - Contains some ramblings about why I wrote `GetPropsInfo` and other details.
- GetPropsInfo.ahk - Contains `GetPropsInfo`, `PropsInfo`, and `PropsInfoitem`.
- Inheritance_Shared.ahk - Contains one line of code that is needed by most of the functions: `ObjGetOwnPropDesc := Object.Prototype.GetOwnPropDesc`
- Inheritance.ahk - A short script that calls `#include` for each of "ClassFactory.ahk", "GetBaseObjects.ahk" , "GetPropDesc.ahk", "GetPropsInfo.ahk", and "Inheritance_Shared.ahk".

## Changelog

2025-06-01 - 1.3.3
- Fixed an error causing the setter function not to be returned when calling `InfoItem.Prototype.GetFunc`.

2025-05-26 - 1.3.2
- Fixed an issue where `PropsInfo.Prototype.Dispose` would call `PropsInfoObj.Filter.Clear`, resulting in the filter being invalidated. This no longer occurs.

2025-05-25 - 1.3.1
- Added parameter `ExcludeMethods=false` to `GetPropsInfo`.

2025-05-24 - 1.3.0
- Added `PropsInfo.FilterGroup`.
- Added `PropsInfo.Prototype.FilterSet`.
- Adjusted `PropsInfo.Prototype.FilterAdd` and `PropsInfo.Prototype.FilterDelete` to call their `PropsInfo.FilterGroup.Prototype` counterpart.
- Adjusted `PropsInfo.Prototype.FilterCache` and `PropsInfo.Prototype.FilterActivateFromCache` to also cache / restore the `PropsInfo.FilterGroup` object.
- Removed `PropsInfoObj._FilterIndex`.

2025-05-05
- Fixed an issue with `PropsInfoItem.Prototype.GetOwner`. Previously, it was possible for the method to return an incorrect value. While it is still possible for the method to return a value that is different from the original owner of the property, this is much less likely and less of a concern than previous. See the parameter hint above the method for details about the limitations of the method.

2025-05-03
- Finalized some details and uploaded to the AutoHotkey forums.
