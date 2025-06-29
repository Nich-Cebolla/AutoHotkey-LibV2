
/**
 * @description - Recursively compares the own properties and items of the input objects. If the
 * two objects or any nested objects are not the same as its counterpart, an error is thrown. If
 * the function returns successfully, the values associated with each object are the same. This
 * does not address inheriter properties. Objects with custom enumerators may not work.
 * @param {*} obj1 - Any object.
 * @param {*} obj2 - Any object.
 * @returns {String} - An empty string.
 */
CompareObjects(obj1, obj2) {
    ptrs := Map()
    _Recurse(obj1, obj2, ptrs)

    _Recurse(obj1, obj2, ptrs) {
        ptrs.Set(ObjPtr(obj1), 1)
        ptrs.Set(ObjPtr(obj2), 1)
        list := Map()
        list.CaseSense := false
        for prop in obj1.OwnProps() {
            if obj2.HasOwnProp(prop) {
                list.Set(prop, 1)
            } else {
                throw Error('``obj2`` does not have a property.', -1, prop)
            }
        }
        for prop in obj2.OwnProps() {
            if !list.Has(prop) {
                throw Error('``obj1`` does not have a property.', -1, prop)
            }
        }
        for item in list {
            val1 := obj1.%item%
            val2 := obj2.%item%
            _CompareVal(&val1, &val2)
        }
        if HasMethod(obj1, '__Enum') {
            if HasMethod(obj2, '__Enum') {
                list1 := Map()
                list2 := Map()
                list1.CaseSense := list2.CaseSense := false
                for key, val in obj1 {
                    list1.Set(key, val)
                }
                for key, val in obj2 {
                    list2.Set(key, val)
                }
                if list1.Count !== list2.Count {
                    throw Error('Inequal number of items.', -1)
                }
                for name, val1 in list1 {
                    if list2.Has(name) {
                        val2 := list2.Get(name)
                        list2.Delete(name)
                        _CompareVal(&val1, &val2)
                    } else {
                        throw Error('Missing item key.', -1, name)
                    }
                }
            } else {
                throw Error('``obj2`` is missing the "__Enum" method.', -1)
            }
        } else if HasMethod(obj2, '__Enum') {
            throw Error('``obj1`` is missing the "__Enum" method.', -1)
        }
    }
    _CompareVal(&Val1, &Val2) {
        if Type(val1) != Type(val2) {
            throw Error('``obj1`` and ``obj2`` are different types.', -1)
        }
        if IsObject(val1) {
            if ptrs.Has(ObjPtr(val1)) {
                if !ptrs.Has(ObjPtr(val2)) {
                    throw Error('A ptr is missing.', -1, ObjPtr(val2))
                }
            } else if ptrs.Has(ObjPtr(val2)) {
                throw Error('A ptr is missing.', -1, ObjPtr(val1))
            } else {
                _Recurse(val1, val2, ptrs)
            }
        } else {
            if val1 != val2 {
                throw Error('``val1 !== val2``.', -1, 'val1: ' val1 '; val2: ' val2)
            }
        }
    }
}
