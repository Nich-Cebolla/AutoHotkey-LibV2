/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/
    Author: Nich-Cebolla
    Version: 1.2.0
    License: MIT
*/

; There are times which our code may benefit from a group of instance objects sharing some
; properties, but we don't want those properties to be on the prototype because not all instances
; should share them.

/**
@example
    ParentObj := { Name: 'SomeName', Value: 'Some value that the children need access to', Children: [] }
    ; We could assign `ParentObj` to all children...
    loop 3 {
        ParentObj.Children.Push(Child := SomeClass())
        Child.Parent := ParentObj
    }
    ; But this creates a reference cycle, which we would rather avoid.

    ; We could duplicate the values...
    loop 3 {
        Child := SomeClass()
        Child.Parent := ParentObj.Name
        Child.PValue := ParentObj.Value
    }
    ; But this consumes more memory.

    ; We could assign the values to the prototype....
    SomeClass.Prototype.Parent := ParentObj.Name
    SomeClass.Prototype.PValue := ParentObj.Value
    loop 3 {
        Child := SomeClass()
    }
    ; but now all instances will have those which we may not want. We can't keep changing the
    ; values on the prototype because the changes will be reflected across all instances of SomeClass.

    ; We could define a new class...
    class Child extends SomeClass {
        Parent := ??
        PValue := ??
    }
    ; But we don't know the actual values yet. Also, we may want any number of separate groups.

    ; So we instead dynamically define a class constructor based off an existing class, which is
    ; what this snippet does.
@
*/

/** ## Example
@example
    Base := Map()
    Base.__Names := { one: '1', two: '2', three: '3' }
    ; Override `Set`.
    Set(*) {
        msgbox('SET')
    }
    Base.DefineProp('Set', { Call: Set })

    Constructor(Base, Self, Items*) {
        if Items.Length
            Self.Set(Items*)
    }
    NewClass := ClassFactory(Base, Map.Prototype, Map, , Constructor.Bind(Base))

    z := NewClass(1, 2, 3, 4)
    z.set()
    MsgBox(z.__Names.one)

    x := NewClass('a', 'b', 'c', 'd')
    msgbox(x.__Names.one)
    try {
        msgbox(x['a'])
    } catch Error as err {
        msgbox(err.message)
    }

    ; But how do we set items to the Map object without `Set`?
    Setter := Map.Prototype.Set
    Setter(z, 'one', 1, 'two', 2)
    msgbox(z['one'])
    msgbox(z['two'])
@
*/

/**
 * @description - Constructs a new class based off an existing class and prototype.
 * @param {*} Prototype - The object to use as the new class's prototype.
 * @param {String} [Name] - The name of the new class. This gets assigned to `Prototype.__Class`.
 * @param {Function} [Constructor] - An optional constructor function that is assigned to
 * `NewClassObj.Prototype.__New`. When set, this function is called for each new instance. When
 * unset, the constructor function associated with `Prototype.__Class` is called.
 */
ClassFactory(Prototype, Name?, Constructor?) {
    Cls := Class()
    Cls.Base := GetObjectFromString(Base.__Class)
    Cls.Prototype := Prototype
    if IsSet(Name) {
        Prototype.__Class := Name
    }
    if IsSet(Constructor) {
        Cls.Prototype.DefineProp('__New', { Call: Constructor })
    }
    return Cls

    GetObjectFromString(Path) {
        Split := StrSplit(Path, '.')
        if !IsSet(%Split[1]%)
            return
        OutObj := %Split[1]%
        i := 1
        while ++i <= Split.Length {
            if !OutObj.HasOwnProp(Split[i])
                return
            OutObj := OutObj.%Split[i]%
        }
        return OutObj
    }

}
