
/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/MapEx/MapEx_V1-0-0.ahk
    Author: Nich-Cebolla
    Version: 1.0.0
    License: MIT
*/

class MapEx extends Map {

    /**
     * @description - The class instance constructor.
     * @param {Boolean} [CaseSense=true] - Whether the map is case sensitive.
     * @param {Any} [Default] - The default value.
     * @param {Any[]} [Items] - The items to add to the map.
     * @example
        M := MapEx(true, 'Not found!', 'Foo', 'Bar')
        OutputDebug(M.Get('foo')) ; Not found!
     */
    __New(CaseSense := true, Default?, Items*) {
        this.CaseSense := CaseSense
        if IsSet(Default)
            this.Default := Default
        if Items.Length {
            if Mod(Items.Length, 2)
                throw Error('The number of items must be even.', -1)
            loop Items.Length / 2
                this.Set(Items[A_Index * 2 - 1], Items[A_Index * 2])
        }
    }

    /**
     * @description - Creates a nested MapEx object with the given key if one does not exist for
     * that key, then adds the Name-Value pair to the nested object.
     * @param {String} Key - The key that accesses the nested MapEx object.
     * @param {String} Name - The name of the item to add.
     * @param {*} Value - The value of the item to add.
     * @return {MapEx} - Returns the nested MapEx object.
     * @example
        M := MapEx()
        M.AddToCategory('Foo', 'Bar', 'Baz')
        OutputDebug(M.Get('Foo').Get('Bar')) ; Baz
     */
    AddToCategory(Key, Name, Value) {
        if !this.Has(Key)
            this.Set(Key, MapEx())
        this.Get(Key).Set(Name, Value)
        return this.Get(Key)
    }

    /**
     * @description - Creates a nested Array object with the given key if one does not exist for
     * that key, then adds the item to the nested object.
     * @param {String} Key - The key that accesses the nested Array object.
     * @param {*} Value - The item to add.
     * @return {Array} - Returns the nested Array object.
     */
    AddToList(Key, Value) {
        if !this.Has(Key)
            this.Set(Key, [])
        this.Get(Key).Push(Value)
        return this.Get(Key)
    }

    GetCategoryIf(Key) {
        if !this.Has(Key)
            this.Set(Key, MapEx())
        return this.Get(Key)
    }

    /**
     * @description - If a key exists, assigns the value to `OutValue` then deletes the item. Else, does nothing.
     * @param {String|Number} Key - The item key.
     * @param {VarRef} [OutValue] - The variable to receive the value.
     * @return {Boolean} - Returns 1 if the item was found and deleted, else returns an empty string.
     */
    DeleteIf(Key, &OutValue?) {
        if this.Has(Key) {
            OutValue := this.Get(Key)
            this.Delete(Key)
            return 1
        }
    }

    /**
     * @description - Gets a value if it exists and returns 1. If the item does not exist and the default
     * is set, gets the default and returns 2. Else returns empty string.
     * @example
        M := MapEx()
        M.Set('Foo', 'Bar')
        if M.GetIf('foo', &Value)
            OutputDebug(Value)
        else
            OutputDebug('Not found') ; Because of CaseSense, this is what we would see.
     * @
     * @param {String|Number} Key - The item key.
     * @param {VarRef} [OutValue] - The variable to receive the value.
     * @return {Integer} - Returns 1 if the item was found, returns 2 if the default was provided,
     * else returns an empty string.
     */
    GetIf(Key, &OutValue?) {
        if this.Has(Key) {
            OutValue := this.Get(Key)
            return 1
        } else if this.HasOwnProp('Default') {
            OutValue := this.Default
            return 2
        }
    }
}
