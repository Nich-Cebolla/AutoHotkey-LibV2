/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/Get.ahk
    Author: Nich-Cebolla
    Version: 1.0.0
    License: MIT
*/

/**
 * @class
 * @description - A namespace for functions that retrieve values from objects, arrays, or other data
 * structures.
 */
class Get {

    /**
     * @class
     * @description - A namespace for functions that retrieve values from object properties.
     */
    class Prop {

        /**
         * @descrition - Gets a property's value if it exists, else returns an empty string.
         * @param {Object} Obj - The object from which to get the value.
         * @param {String} Prop - The name of the property to access.
         * @returns {*} - The value of the property if it exists, else an empty string.
         */
        static Call(Obj, Prop) => HasProp(Obj, Prop) ? Obj.%Prop% : ''

        /**
         * @descrition - If the property exists, the value is assigned to the `OutValue` parameter
         * and the function returns 1. Else, the function returns an empty string.
         * @param {Object} Obj - The object from which to get the value.
         * @param {String} Prop - The name of the property to access.
         * @param {VarRef} [OutValue] - A variable that will receive the value of the property if it
         * exists.
         * @returns {Boolean} - If the property exists, the function returns 1. Else, an empty string.
         */
        static If(Obj, Prop, &OutValue?) => HasProp(Obj, Prop) ? (OutValue := Obj.%Prop% || 1) : ''

        /**
         * @description - If the property exists, returns the value. Else, returns the default value.
         * @param {Object} Obj - The object from which to get the value.
         * @param {String} Prop - The name of the property to access.
         * @param {*} Default - The default value to return if the property does not exist.
         * @returns {*} - The value of the property if it exists, else the default value.
         */
        static Or(Obj, Prop, Default) => HasProp(Obj, Prop) ? Obj.%Prop% : Default

        /**
         * @description - Iterates a list of property names until a property exists on the input
         * object, then returns that value. If none of the properties exist, and the `Default` parameter
         * is set, this returns the `Default` value. Else, throws an error.
         * @param {Object} Obj - The object from which to get the value.
         * @param {String[]} Props - A list of property names to check for on the input object.
         * @param {*} [Default] - The default value to return if none of the properties exist.
         * @param {VarRef} [OutProp] - A variable that will receive the name of the property that was
         * found on the object.
         */
        static First(Obj, Props, Default?, &OutProp?) {
            for Prop in Props {
                if HasProp(Obj, Prop) {
                    OutProp := Prop
                    return Obj.%Prop%
                }
            }
            if IsSet(Default)
                return Default
            throw UnsetItemError('The object does not have a property from the list.', -1)
        }
    }

    /**
     * @class
     * @description - A namespace for functions that retrieve values from array objects.
     */
    class Index {

        /**
         * @description - Gets an index's value if it exists, else returns an empty string.
         * @param {Array} Arr - The array from which to get the value.
         * @param {Integer} Index - The index to access.
         * @returns {*} - The value of the index if it exists, else an empty string.
         */
        static Call(Arr, Index) => Arr.Has(Index) ? Arr[Index] : ''

        /**
         * @description - If the index exists, the value is assigned to the `OutValue` parameter
         * and the function returns 1. Else, the function returns an empty string.
         * @param {Array} Arr - The array from which to get the value.
         * @param {Integer} Index - The index to access.
         * @param {VarRef} [OutValue] - A variable that will receive the value of the index if it
         * exists.
         * @returns {Boolean} - If the index exists, the function returns 1. Else, an empty string.
         */
        static If(Arr, Index, &OutValue?) => Arr.Has(Index) ? (OutValue := Arr[Index] || 1) : ''

        /**
         * @description - If the index exists, returns the value. Else, returns the default value.
         * @param {Array} Arr - The array from which to get the value.
         * @param {Integer} Index - The index to access.
         * @param {*} Default - The default value to return if the index does not exist.
         * @returns {*} - The value of the index if it exists, else the default value.
         */
        static Or(Arr, Index, Default) => Arr.Has(Index) ? Arr[Index] : Default

        /**
         * @description - Iterates a list of index values until the function accesses an index that
         * contains a value, then returns that value. If none of the indices have a value, and the
         * `Default` parameter is set, the function returns the `Default` value. Else, throws an error.
         * @param {Array} Arr - The array from which to get the value.
         * @param {Integer[]} Indices - A list of index values to check for in the input array.
         * @param {*} [Default] - The default value to return if none of the indices have a value.
         * @param {VarRef} [OutIndex] - A variable that will receive the index that was found in the
         * array.
         */
        static First(Arr, Indices, Default?, &OutIndex?) {
            for Index in Indices {
                if Arr.Has(Index) {
                    OutIndex := Index
                    return Arr[Index]
                }
            }
            if IsSet(Default)
                return Default
            throw UnsetItemError('The array does not have an item at any index from the list.', -1)
        }

        /**
         * @description - Iterates a range of indices until the function accesses an index that
         * contains a value, then returns that value. If no index in the range has a value, and the
         * `Default` parameter is set, this returns the `Default` value. Else, throws an error.
         * @param {Array} Arr - The array from which to get the value.
         * @param {Integer} [Start=1] - The index to begin searching from.
         * @param {Integer} [End] - The index to stop the search at. If unset, the search continues
         * until reaching the beginning or end of the array.
         * @param {Integer} [Step=1] - The amount to increment the index by after each iteration.
         * @param {*} [Default] - The default value to return if none of the indices have a value.
         * @param {VarRef} [OutIndex] - A variable that will receive the index that was found in the
         * array.
         */
        static Range(Arr, Start := 1, Length?, Step := 1, Default?, &OutIndex?) {
            if Step > 0 {
                if !IsSet(End)
                    End := Arr.Length
                Condition := () => i >= End
            } else if Step < 0 {
                if !IsSet(End)
                    End := 1
                Condition := () => i <= End
            } else {
                throw ValueError('``Step`` cannot be 0.', -1)
            }
            i := Start += Step * -1
            while !Condition() {
                i += Step
                if Arr.Has(i) {
                    OutIndex := i
                    return Arr[i]
                }
            }
            if IsSet(Default)
                return Default
            throw UnsetItemError('The array does not have an item at any index from the list.', -1)
        }
    }

    /**
     * @class
     * @description - A namespace for functions that retrieve values from map objects.
     */
    class Key {

        /**
         * @description - Gets a key's value if it exists, else returns an empty string.
         * @param {Map} Obj - The map from which to get the value.
         * @param {String} Key - The key to access.
         * @returns {*} - The value of the key if it exists, else an empty string.
         */
        static Call(Obj, Key) => Obj.Has(Key) ? Obj.Get(Key) : ''

        /**
         * @description - If the key exists, the value is assigned to the `OutValue` parameter
         * and the function returns 1. Else, the function returns an empty string.
         * @param {Map} Obj - The map from which to get the value.
         * @param {String} Key - The key to access.
         * @param {VarRef} [OutValue] - A variable that will receive the value of the key if it
         * exists.
         * @returns {Boolean} - If the key exists, the function returns 1. Else, an empty string.
         */
        static If(Obj, Key, &OutValue?) => Obj.Has(Key) ? (OutValue := Obj.Get(Key) || 1) : ''

        /**
         * @description - If the key exists, returns the value. Else, returns the default value.
         * @param {Map} Obj - The map from which to get the value.
         * @param {String} Key - The key to access.
         * @param {*} Default - The default value to return if the key does not exist.
         * @returns {*} - The value of the key if it exists, else the default value.
         */
        static Or(Obj, Key, Default) => Obj.Has(Key) ? Obj.Get(Key) : Default

        /**
         * @description - Iterates a list of key names until a key exists on the input map, then
         * returns that value. If none of the keys exist, and the `Default` parameter is set, this
         * returns the `Default` value. Else, throws an error.
         * @param {Map} Obj - The map from which to get the value.
         * @param {String[]} Keys - A list of key names to check for on the input map.
         * @param {*} [Default] - The default value to return if none of the keys exist.
         * @param {VarRef} [OutKey] - A variable that will receive the name of the key that was found
         * on the map.
         */
        static First(Obj, Keys, Default?, &OutKey?) {
            for Key in Keys {
                if Obj.Has(Key) {
                    OutKey := Key
                    return Obj.Get(Key)
                }
            }
            if IsSet(Default)
                return Default
            throw UnsetItemError('The object does not have a key from the list.', -1)
        }
    }
}
