
/**
 * @class
 * @description - A simple class that builds an index of names and items. Names /
 * items can be retrieved by index, and indices can be retrieved by name / item.
 * I wrote this for cases where I need to assign indices to a list of values, and
 * need other parts of the code to be able to associate a name to the index without
 * having a direct reference to the object which is associated with the name.
 */
class Indexer extends Map {
    /**
     * @description - The constructor.
     * @param {Integer} [ApproxCount] - The approximate number of items to be added to the
     * indexer. This is used to set the initial capacity of the indexer.
     * @param {Function} [NameCallback] - A function that takes an item and returns a name.
     * This is used to set the name of the item in the indexer. If unset, the item is used as
     * the name.
     * @returns {Indexer} - The indexer object.
     */
    __New(ApproxCount?, NameCallback?) {
        this.List := []
        if IsSet(ApproxCount) {
            this.List.Capacity := ApproxCount
            this.Capacity := ApproxCount
        }
        this.DefineProp('__MapDelete', Map.Prototype.GetOwnPropDesc('Delete'))
        this.NameCallback := NameCallback ?? ''
    }

    /**
     * @description - The main function of the indexer. `Call` adds the item to the array if not
     * present, and returns the item's index.
     * @param {*} Item - The item to add to the indexer.
     * @param {Function} [NameCallback=this.NameCallback] - A function that takes an item and
     * returns a name.
     * @returns {Integer} - The index of the item in the indexer.
     */
    Call(Item, NameCallback := this.NameCallback) {
        if !this.Has(Name := NameCallback ? NameCallback(Item) : Item) {
            this.List.Push(Item)
            this.Set(Name, this.List.Length)
        }
        return this.Get(Name)
    }
    AddItem(Item, NameCallback := this.NameCallback) {
        if !this.Has(Name := NameCallback(Item)) {
            this.List.Push(Item)
            this.Set(Name, this.List.Length)
        }
        return this.Get(Name)
    }
    AddString(Item) {
        if !this.Has(Item) {
            this.List.Push(Item)
            this.Set(Item, this.List.Length)
        }
        return this.Get(Item)
    }

    IndexToName(Index, NameCallback := this.NameCallback) => NameCallback ? NameCallback(this.List[Index]) : this.List[Index]
    IndexToItem(Index) => this.List[Index]
    NameToIndex(Name) => this.Get(Name)
    NameToItem(Name) => this.List[this.Get(Name)]
    ItemToIndex(Item, NameCallback := this.NameCallback) => this.Get(NameCallback ? NameCallback(Item) : Item)
    DeleteIndex(Index, NameCallback := this.NameCallback) {
        this.__MapDelete(NameCallback ? NameCallback(this.List[Index]) : this.List[Index])
        this.List.Delete(Index)
    }
    DeleteName(Name) {
        this.List.Delete(this.Get(Name))
        this.__MapDelete(Name)
    }
    DeleteItem(Item, NameCallback := this.NameCallback) {
        this.List.Delete(this.Get(NameCallback ? (Item := NameCallback(Item)) : Item))
        this.__MapDelete(Item)
    }

    Dispose() {
        this.List.Capacity := 0
        this.Capacity := 0
        this.DeleteProp('NameCallback')
        this.DeleteProp('__MapDelete')
        this.DeleteProp('List')
    }
}
