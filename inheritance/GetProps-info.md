# GetPropsInfo

This introduction is intended to help illustrate what use cases this version of `GetPropsInfo` can be useful for. For information about a method or property, go to the `GetPropsInfo.ahk` file and see the parameter hint above the method or the property description above the property.

When I wrote the first version of `GetPropsInfo`, it was the solution to a problem I had with my `Stringify` function.

When I first wrote `Stringify`, I envisioned a version of `Stringify` that also encodes additional information that would allow its associated `Parse` function to reconstruct a 1:1 true-to-original object from the JSON string. This idea is partly implemented using the `PrintTypeTag` option, but I ceased working on it in favor of other projects. This updated version of `GetPropsInfo` is a necessary stepping stone to a function that saves an object state as string, and that can parse it back into memory later.

I wanted the function to be compatible with the release version of AHK, so `Object.Prototype.Props` is unavailable. Version 1 of `GetPropsInfo` was a quick implementation of the same role, emphasis on "quick".

The vision for `GetPropsInfo` v2 is for it to be the complete solution for programmatically selecting what object properties are to be stringified, and making available the information that will be needed to later reconstruct the object from string. To accomplish this, I reasoned that `GetPropsInfo` and `PropsInfo` must meet the below objectives.

### Creates / returns an iterable object that can be passed to `Stringify` to specify which properties to stringify.

Status: Complete

`PropsInfo` is flexible. It can be used to emulate the behavior of an array or a map, depending on the value of its `StringMode` property. I called it `StringMode` because in that mode it acts like an array of strings (specifically, a list of property names).

While `PropsInfoObj.StringMode == 1`, calling `PropsInfoObj` in a `for` loop returns an enumerator that mimics `Array.Prototype.__Enum`. If called in 1-param mode, the variable receives the property name. If called in 2-param mode, the first variable receives the index and the second the property name. Also, `PropsInfo.Prototype.Get(Index)` and `PropsInfo.Prototype.__Item[Index]` both return a property name as string.

While `PropsInfoObj.StringMode == 0`, calling `PropsInfoObj` in a `for` loop returns an enumerator that mimics `Map.Prototype.__Enum`. If called in 1-param mode, the variable receives the property name. If called in 2-param mode, the first variable receives the property name and the second the `PropsInfoItem` object associated with that property. `PropsInfo.Prototype.Get(Key)` and `PropsInfo.Prototype.__Item(Key)` accept a name as string to return the `PropsInfoItem` object. They both also accept an index, which map objects natively do not, but this functionality was trivial to add and does not interfere with anything so I figured why not.

`PropsInfo` itself inherits from `Object`, and consequently would fail a type check if a function were to validate its type before calling `__Enum`. So to make it usable with such functions, `PropsInfo.Prototype.GetProxy` returns a `PropsInfo.Proxy_Array` or `PropsInfo.Proxy_Map` object that can be passed to the function instead. Be mindful to unambiguously label these objects as proxies; their class name is overwritten on the `Prototype.__Class` property so they will pass any `if Type(Obj) !== 'Array'` or `if Type(Obj) !== 'Map'` conditions. Do future you a favor and make it explicit that they are not instances of `Map` or `Array`, and don't even inherit from either.

The proxies work by simply forwarding a number of methods / properties to the `PropsInfo` object. Some methods and properties were intentionally left out of the available set, and so if a function attempts to use one of the excluded properties AHK will throw an error. Your code would need to work around this limitation, probably by defining the property on the proxy to do some inert or otherwise necessary action.

Filtering which properties to include / exclude is implemented in a way that is consistent and systematic. Filtering first occurs with the `GetPropsInfo` function call, defined by the `Exclude` parameter. This exclusion is absolute; if your code later needs access to an excluded property, it would need to call `GetPropsInfo` again or get the information in some other way. In addition to `Exclude`, `PropsInfo` objects have a number of methods for dynamically defining which properties to exclude. `PropsInfo.Prototype.AddFilter` is your entry-point to the feature. See the parameter hints for details.

### Makes available the property descriptor object from `Object.Prototype.GetOwnPropDesc` so it can be encoded in the JSON if it's an own property, and if it's a value / dynamic / callable property.

Status: Complete

Every `PropsInfoItem` object is created by modifying a descriptor object.

### For inherited properties, specifies from which object the property was inherited.

Status: Complete

For properties that have been overridden one or more times up the inheritance chain, we need to be able to identify which object owns the property from which the root object inherits. This is straightforward. If its an own property, then the `Index` property on the `PropsInfoItem` object is 0. Additionally, the top-level `PropsInfoItem` object will always be associated with the object from which the root object inherits that property, because the base objects are iterated in descending order. The `PropsInfoItem` objects on the `Alt` property array are all overridden, because they are from objects lower in the inheritance chain.

### Reveals the object inheritance chain

Status: Complete

The function `GetBaseObjects` performs this task, and the value returned from `GetBaseObjects` is made accessible when calling `GetPropsInfo`.

### Conclusion

`GetPropsInfo` v2 and the associated `PropsInfo` object can be used in cases where handling an object's inherited properties is needed. I believe it's a convenient tool for programmatically analyzing and responding to objects and properties in an object's inheritance chain.

# Implementation details

This section describes the details about how `PropsInfo` implements these functions. This is intended for people who are interested in modifying the class, or who are otherwise interested in what the code does.

### Memory and processing time

In the spirit of the class's objectives, `PropsInfo` makes use of AHK's object model to minimize repeated values, and to balance memory usage with performance overhead. For example, consider the `PropsInfoItem` class. Each instance has a `Type` property that returns what type of property the object is associated with. `Type` will return one of "Call", "Get", "Get_Set", "Set", "Value". This is hardly a convenience in many cases, because if we're programmatically responding to the object, then there's little difference between checking `if desc.HasOwnProp('Call')` and `if PropsInfoItemObj.Type == 'Call'`. But  there is value to be gained from the property. For example, we can now use a switch function:

```ahk
switch PropsInfoItemObj.Type {
    case 'Call':
    case 'Get':
    case 'Get_Set':
    case 'Set':
    case 'Value':
}
```

The above function is a bit easier to read at a glance, and easier to write, compared to checking `HasOwnProp` multiple times. For better performance, skip the string altogether; if you write your code knowing the index values, you can use the indices. Just include comments specifying what the indices are.

```ahk
switch PropsInfoItemObj.TypeIndex {
    case 1: return DoSomething1() ; Call
    case 2: return DoSomething2() ; Get
    case 3: return DoSomething3() ; Get_Set
    case 4: return DoSomething4() ; Set
    case 5: return DoSomething5() ; Value
}
```

It would have been an expensive inclusion if, for each `PropsInfoItem` object, the `Type` property was set with the string value as a value property. That would have required significant memory and processing time. Instead, `PropsInfoItem.Prototype.__TypeNames` is an array of strings, so each of "Call", "Get", etc. are associated with an index number. When `PropsInfoItemObj.Type` is accessed the first time, it performs the same calculations that our external code would need to do to identify what type of descriptor object our code is working with, then caches the index on the `PropsInfoItemObj.TypeIndex` property so the calculation only needs to be performed once. In this way, the processing time is only consumed if the property is accessed, and instead of caching the string, it caches an integer, minimizing memory usage.

I used a similar approach with the property names as well. For any property which is defined on multiple base objects, the `PropsInfoItem` objects all share a base object on which the `Name` property is defined, so there's no repeated strings. I also wanted to see if it were possible to do the same thing but with the `Index` property shared by the `PropsInfoItem` objects associated with a single base object. I concluded that it is not possible to do both in a single-inheritance object model. Either the `Index` property is defined on every object, allowing the `Name` property to be defined on the base, or vise-versa. I chose to delegate the name to the base, a decision made by guessing which approach requires less memory; I don't plan on spending the time to actually calculate it.

I could have dynamically constructed an array of names and assigned indexes for the name, like how I did with `PropsInfoItem.Prototype.__TypeNames`. But... nah.

### Filters

The most expensive feature included is the filter. I see some opportunity to reduce processing time using features available only in Alpha, but with the tools available to the class in AHK's release version, I decided to keep it simple and implement the functionality as a linear process. This is how I reasoned through the decision:

- For convenience to the programmer, it would be helpful to have some built-in filters available that implement functionality that (I think) would be needed most often. I included five built-in filters. Using built-in filters necessarily increases processing time because filtering occurs as a piecemeal process. AHK has an enter and exit routine for every function call; performing 5 actions in 5 function calls is more expensive than performing the same actions in 1 function call. It should not be required to use any built-in filters; so as long as the class exposes a way for the programmer to define a single filter function and use that, then the choice to use built-ins can be left up to the programmer based on the needs of their application. Generally, performance costs at this level are only noticeable across tens of thousands or hundreds of thousands of iterations in my experiments.

The only other way I can think of that could optimize this (using only AHK code) is to define multiple functions, each with some combination of the same built-in functions, so that the actions taken by the built-in functions are called in a single function call. That code would be convoluted and hard to maintain, so the decision is quickly -> no. If performance is that much of a priority, AHK probably isn't the right language anyways. But even with AHK, the programmer can just copy the function blocks into their own function definition to put them all in a single function, or just rewrite them.

- I needed to decide whether the filters should be purely dynamic, or if some information should be cached. In this bullet point assume `PropsInfoObj.FilterActive == 1` in our hypothetical considerations. I could have written the class to call the filter every time an object is accessed using `Get`, `__Item`, or the enumerator. The benefit of this approach is that processing time is only used when needed, and the additional memory consumed is only from the additional code needed to write the functionality because nothing is cached. The drawback is that the calculations would be performed more than once if any single `PropsInfoItem` object is accessed multiple times. Furthermore, the challenge with this approach is that it makes it hard to emulate a map or array object's behavior. Regarding an array, we need the items to be accessible from consecutive indices between 1 and the number of filtered properties. This means that at each index we would need to know the offset from which to start testing values. Here's an illustration:

```ahk
class Example {
    __Item := [
        { Val: 1 }  ; 1
      , { Val: 1 }  ; 2
      , { Val: 0 }  ; 3
      , { Val: 0 }  ; 4
      , { Val: 1 }  ; 5
      , { Val: 0 }  ; 6
      , { Val: 1 }  ; 7
    ]
    Get(Index) {
        while !this.__Item[Index].Val {
            Index++
        }
        return this.__Item[Index]
    }
}
```

The above example class would actually return the wrong value for any index greater than 3. At input index 3, the object in the array index 5 gets returned. At input index 4, the correct object is array index 7, but we would still get the object at array index 4. To stick with this approach, we would have to iterate the entire array up to the correct value every time, or we would need to cache the starting offsets. But at this point, there's no value gained by using offsets; we could just cache the object references themselves. Since object references are essentially pointers, the memory consumed is much less than caching something like a string. Since filters are only created by external code, presumably if one is needed, there's no added overhead if a filter does not get used.

Conclusion: It is better to cache the filtered objects than to define the accessors to process objects through the filter when accessed.

The decision becomes how to expose the functionality. There's not much to consider here, the object just needs to do the things that need to occur in order for an array of filtered objects to be returned.

  1. External code defines filter functions.
  2. When filter is activated, items are processed through the filter, adding valid objects to an array / map.
  3. Give external code access to new array / map.

I left the decision up to the programmer whether to use the `PropsInfo` object's ability to emulate array / map behavior, or to just get a new array / map by calling `ProcessFilter` and work with that. It's perfectly valid, and in some ways easier to understand from the point of view of someone reading the code, to get a filtered array / map and work with that. But I decided to also include `ActivateFilter` (which activates the emulation behavior) because I can envision circumstances when working with a single object can simplify code, compared to managing various filters and the objects created by the filters.
