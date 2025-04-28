#Include ..\Inheritance\Inheritance.ahk
; https://github.com/Nich-Cebolla/Stringify-ahk/blob/main/Stringify.ahk
#Include <Stringify>


test_Inheritance()

class test_Inheritance {
    static PathOut := A_MyDocuments '\test-output_Inheritance.json'
    , PathEditor := 'code' ; change to your preferred text editing program. Enclose in quotes if path has spaces
    , Functions :=  ['GetBaseObjects', 'GetPropsInfo']
    , Result := []

    static __New() {
        if this.Prototype.__Class == 'test_Inheritance' {

            this.Obj_A := A()
            A.Prototype.Index_A := 1
            A.base.Prototype.Index_A := 2
            Array.Prototype.Index_A := 3
            Object.Prototype.Index_A := 4
            Any.Prototype.Index_A := 5

            M2.Prototype.Index_M := 1
            M.Prototype.Index_M := 2
            Map.Prototype.Index_M := 3
            Object.Prototype.Index_M := 4
            Any.Prototype.Index_M := 5

            ObjSetBase(this.Obj_M2_C := {}, M2)
            M2.Index_C := 1
            M.Index_C := 2
            Map.Index_C := 3
            Object.Index_C := 4
            Any.Index_C := 5
            Class.Prototype.Index_C := 6
            Object.Prototype.Index_C := 7
            Any.Prototype.Index_C := 8

            ; this.Obj_M2_I will inherit `Method2` and `prop2` from this.Obj_M2_I_b1
            ObjSetBase(this.Obj_M2_I := Map(), this.Obj_M2_I_b1 := M2())
            ; this.Obj_M2_I_b2 also has  `Method2` and `prop2`, so this should be counted as one override for each
            ObjSetBase(this.Obj_M2_I_b1, this.Obj_M2_I_b2 := M())
            ; The base to this.Obj_M2_I_b2 is M.Prototype, which is what provides this.Obj_M2_I_b2
            ; with `method2` and `prop2`. For `GetPropsInfo` to differentiate between a method that is
            ; overridden and a method that is inheritedd it can check the function name, which, if
            ; inherited, should have the same name as the function on the prototype. See the notes
            ; at the bottom of the page for more details.
            this.Obj_M2_I_b1.Index_I := 1
            this.Obj_M2_I_b2.Index_I := 2
            M.Prototype.Index_I := 3
            Object.Prototype.Index_I := 4
            Any.Prototype.Index_I := 5

            for Name in ['Obj_A', 'Obj_M2_C', 'Obj_M2_I', 'Obj_M2_I_b1', 'Obj_M2_I_b1', 'Obj_M2_I_b2'] {
                this.%Name%.Name := Name
            }
        }
    }

    static Call(OpenEditor := false) {
        this.GetBaseObjects()
        this.GetPropsInfo()
        Results := []
        for Obj in this.Result {
            if Obj.Result.Length {
                Results.Push(Obj)
            }
        }
        this.WriteOut(Results.Length ? Results : 'No problems')
        if OpenEditor {
            this.OpenEditor()
        }
        return Results.Length
    }

    static GetBaseObjects() {
        this.Result.Push({ Test: A_ThisFunc, Result: Result := [] })
        ; Validates `StopAt` parameter stops where expected, and validates the index assigned to the
        ; output objects is correct.
        _CheckCount(_CheckList(GetBaseObjects(this.Obj_A, &count), A_LineNumber, 'A'), 4, count, A_LineNumber)
        _CheckCount(_CheckList(GetBaseObjects(this.Obj_A, &count, 'Any'), A_LineNumber, 'A'), 5, count, A_LineNumber)
        _CheckCount(_CheckList(GetBaseObjects(this.Obj_A, &count, 'Object-'), A_LineNumber, 'A'), 3, count, A_LineNumber)
        ; This should result in an error
        try {
            BaseObjects := GetBaseObjects(this.Obj_A, &count, 'Array:I')
            Result.Push({ Id: 1, Line: A_LineNumber, List: BaseObjects })
        } catch Error as err {
            if err.Message !== '``GetBaseObjects`` did not encounter an object that matched the ``StopAt`` value.' {
                Result.Push({ Id: 2, Line: A_LineNumber, err: err })
            }
        }
        _CheckCount(_CheckList(GetBaseObjects(this.Obj_M2_C, &count, 'Object:C-'), A_LineNumber, 'C'), 3, count, A_LineNumber)
        _CheckCount(_CheckList(GetBaseObjects(this.Obj_M2_C, &count, 'Object:C'), A_LineNumber, 'C'), 4, count, A_LineNumber)
        ; When we set `b1.base := b2`, b1 is no longer considered an `M2` object because it no longer
        ; has `M2.Prototype` as its base. It is then considered an `M` object, so there are two
        ; `M` objects in the inheritance chain, not including `M.Prototype`.
        _CheckCount(_CheckList(GetBaseObjects(this.Obj_M2_I, &count, 'M:I-'), A_LineNumber, 'I'), 0, count, A_LineNumber)
        _CheckCount(_CheckList(GetBaseObjects(this.Obj_M2_I, &count, 'M:I'), A_LineNumber, 'I'), 1, count, A_LineNumber)

        return Result.Length ? Result : ''

        _CheckList(List, Line, Which) {
            for o in List {
                if A_Index !== o.Index_%Which% {
                    Result.Push({ Id: 3, Line: Line, List: List })
                    break
                }
            }
            return List
        }
        _CheckCount(List, Expected, Actual, Line) {
            if Expected !== Actual {
                Result.Push({ Id: 4, Expected: Expected, Actual: Actual, Line: Line, List: List })
            }
        }
    }

    static GetPropsInfo() {
        this.GetProps_1()
        this.GetProps_2()
        this.GetProps_3()
        this.GetProps_4()
        if this.GetProps_5() {
            return
        }
        this.GetProps_6()
        this.GetProps_7()
    }

    /**
     * @description - Calls `GetPropsInfo` and constructs the test items
     */
    static GetProps_1() {
        this.GetPropsResult := [
            { Subject: this.Obj_A, Exclude: 'Prop2', Props: GetPropsInfo(this.Obj_A, , 'Prop2', , &BaseObjList), BaseObj: BaseObjList, Expected: { BaseObjCount: 4 } }
          , { Subject: this.Obj_M2_C, Props: GetPropsInfo(this.Obj_M2_C, , , , &BaseObjList), BaseObj: BaseObjList, Expected: { BaseObjCount: 7 } }
          , { Subject: this.Obj_M2_I, Props: GetPropsInfo(this.Obj_M2_I, , , , &BaseObjList), BaseObj: BaseObjList, Expected: { BaseObjCount: 5 } }
          , { Subject: this.Obj_M2_I_b1, Props: GetPropsInfo(this.Obj_M2_I_b1, , , , &BaseObjList), BaseObj: BaseObjList, Expected: { BaseObjCount: 4 } }
          , { Subject: this.Obj_M2_I_b2, Props: GetPropsInfo(this.Obj_M2_I_b2, , , , &BaseObjList), BaseObj: BaseObjList, Expected: { BaseObjCount: 3 } }
        ]
    }

    /**
     * @description - Verifies the base objects are iterated correctly.
     */
    static GetProps_2() {
        this.Result.Push({ Test: A_ThisFunc, Result: Result := [] })
        GetPropsResult := this.GetPropsResult
        i := 0
        for Obj in GetPropsResult {
            i++
            ; Verify the base objects are collected correctly
            if Obj.BaseObj.Length !== Obj.Expected.BaseObjCount {
                Result.Push({ LoopIndex: i, Id: 5, Expected: Obj.Expected.BaseObjCount, Actual: Obj.BaseObj.Length, Line: A_LineNumber, List: Obj.BaseObj })
            }
            B2 := Obj.Subject
            for B1 in Obj.BaseObj {
                if ObjPtr(B1) !== ObjPtr(B2 := B2.Base) {
                    Result.Push({ LoopIndex: i, BaseIndex: A_Index, Id: 6, Line: A_LineNumber, B1Ptr: ObjPtr(B1), B2Ptr: ObjPtr(B2), List: Obj.BaseObj })
                    break
                }
            }
        }
    }

    /**
     * @description - Validates the following for StringMode = false
     * - The properties returned by the function are correct (no extras, none missing, `Exclude` works as expected)
     * - The containers (__InfoIndex and __InfoItems) are equal size
     * - The Enumerator works in both 1- and 2-paramater modes
     * - `PropsInfo.Prototype.Get` and `PropsInfo.Prototype.__Item` return the correct object
     */
    static GetProps_3() {
        this.Result.Push({ Test: A_ThisFunc, Result: Result := [] })
        i := 0
        for Obj in this.GetPropsResult {
            i++
            /** @var _PropsInfo - The result `PropsInfo` object. */
            _PropsInfo := Obj.Props
            ; These two containers should be the same size
            if _PropsInfo.__InfoIndex.Count !== _PropsInfo.__InfoItems.Length {
                Result.Push({ LoopIndex: i,  Id: 7, Line: A_LineNumber, MapCount: _PropsInfo.__InfoIndex.Count, ArrLength: _PropsInfo.__InfoItems.Length })
            }
            ; Ensure excluded properties are excluded
            for s in StrSplit(Obj.HasOwnProp('Exclude') ? Obj.Exclude : '', ',') {
                if _PropsInfo.Has(s) {
                    Result.Push({ LoopIndex: i, ExcludeIndex: A_Index, Id: 8, Line: A_LineNumber, Name: s })
                    break
                }
            }
            ; Verify the result is not missing any properties.
            ; First get list of properties
            Master := this.GetProps_Master(A_Index)
            ; Validate 1-parameter mode enumerator, check props, and validate getters
            List1 := Master.Clone()
            List2 := Map()
            List2.CaseSense := false
            for Item in _PropsInfo {
                ; Validate property names
                if _CheckList(Item, A_Index, A_LineNumber)
                ; Ensure the PropsInfoItem object returned by the getter is the same returned by the enumerator
                || _Compare(Item, A_Index) {
                    break
                }
            }
            if i == 1 {
                List1.Delete('Prop2')
            } else {
                if List1.Has('Prototype') {
                    List1.Delete('Prototype')
                }
            }
            ; If List1 is not empty then a property was missed
            if List1.Count {
                Result.Push({ LoopIndex: i, Id: 9, Line: A_LineNumber, List1: List1, List2: List2 })
            }

            ; Validate 2-parameter mode enumerator, check props, and validate getters

            List1 := Master.Clone()
            List2 := Map()
            List2.CaseSense := false
            for Prop, Item in _PropsInfo {
                ; Ensure the items in the separate containers are aligned
                if Prop !== Item.Name {
                    Result.Push({ LoopIndex: i, Id: 10, Line: A_LineNumber, Item: Item, List1: List1, List2: List2 })
                    break
                }
                ; Validate property names
                if _CheckList(Item, A_Index, A_LineNumber)
                ; Ensure the PropsInfoItem object returned by the getter is the same returned by the enumerator
                || _Compare(Item, A_Index) {
                    break
                }
            }
            if i == 1 {
                List1.Delete('Prop2')
            } else {
                if List1.Has('Prototype') {
                    List1.Delete('Prototype')
                }
            }
            ; If List1 is not empty then a property was missed
            if List1.Count {
                Result.Push({ LoopIndex: i, Id: 11, Line: A_LineNumber, List1: List1, List2: List2 })
            }
        }

        _Compare(Item, Index) {
            ptr := ObjPtr(Item)
            if _Proc(ObjPtr(_PropsInfo.Get(Item.Name)), A_LineNumber)
            || _Proc(ObjPtr(_PropsInfo.Get(A_Index)), A_LineNumber)
            || _Proc(ObjPtr(_PropsInfo[Item.Name]), A_LineNumber)
            || _Proc(ObjPtr(_PropsInfo[A_Index]), A_LineNumber) {
                return 1
            }
            _Proc(GetPtr, Line) {
                if ptr !== GetPtr {
                    Result.Push({ LoopIndex: i, Id: 12, Line: Line, ResultPtr: ptr, GetPtr: GetPtr })
                    return 1
                }
            }
        }

        _CheckList(Item, Index, Line) {
            if List1.Has(Item.Name) {
                List2.Set(Item.Name, Index)
                List1.Delete(Item.Name)
            } else {
                Result.Push({ LoopIndex: i, PropIndex: Index, Line: Line, Id: 13, Item: Item, List1: List1, List2: List2 })
                return 1
            }
        }
    }

    /**
     * @description - Validates the following for StringMode = true
     * - `PropsInfo.Prototype.Get`
     * - `PropsInfo.Prototype.__Item`
     * - `PropsInfo.Prototype.__Enum`
     */
    static GetProps_4() {
        this.Result.Push({ Test: A_ThisFunc, Result: Result := [] })
        i := 0
        for Obj in this.GetPropsResult {
            i++
            /** @var _PropsInfo - The result `PropsInfo` object. */
            _PropsInfo := Obj.Props
            ; Verify the enumerator and getters work while in string mode
            ; First get list of properties
            Master := this.GetProps_Master(A_Index)
            ; Turn it into an array so we can evaluate the order. This works because the `PropsInfoItem`
            ; objects are ordered using the map objects' built-in sorting as well.
            List := []
            List.Capacity := Master.Count
            Exclude := Obj.HasOwnProp('Exclude') ? ',' Obj.Exclude ',': ',__Class,Prototype,'
            for Name in Master {
                if !InStr(Exclude, ',' Name ',') {
                    List.Push(Name)
                }
            }
            ; Validate 1-parameter mode enumerator and validate getters
            _PropsInfo.StringMode := 1
            for Item in _PropsInfo {
                ; Validate the names
                if Item !== List[A_Index] {
                    Result.Push({ LoopIndex: i, Id: 14, Line: A_LineNumber, Item: Item, List: List, ItemIndex: A_Index })
                    break
                }
                if _PropsInfo.Get(A_Index) !== List[A_Index] || _PropsInfo[A_Index] !== List[A_Index] {
                    Result.Push({ LoopIndex: i, Id: 15, Line: A_LineNumber, Item: Item, List: List, ItemIndex: A_Index })
                    break
                }
            }

            ; Validate 2-parameter mode enumerator

            for Index, Item in _PropsInfo {
                ; Validate index
                if A_Index !== Index {
                    Result.Push({ LoopIndex: i, Id: 16, Line: A_LineNumber, Item: Item, List: List, ExpectedIndex: A_Index, ActualIndex: Index })
                    break
                }
                ; Validate the names
                if Item !== List[A_Index] {
                    Result.Push({ LoopIndex: i, Id: 17, Line: A_LineNumber, Item: Item, List: List, ItemIndex: A_Index })
                    break
                }
                if _PropsInfo.Get(A_Index) !== List[A_Index] || _PropsInfo[A_Index] !== List[A_Index] {
                    Result.Push({ LoopIndex: i, Id: 18, Line: A_LineNumber, Item: Item, List: List, ItemIndex: A_Index })
                    break
                }
            }

            _PropsInfo.StringMode := 0
        }
    }

    /**
     * @description - Validates:
     * - FilterAdd
     * - FilterCache
     * - FilterClear
     * - FilterClearCache
     * - FilterDelete
     */
    static GetProps_5() {
        this.Result.Push({ Test: A_ThisFunc, Result: Result := [] })
        _PropsInfo := this.GetPropsResult[1].Props
        _PropsInfo.FilterAdd(false, 1)
        _PropsInfo.FilterAdd(false, 2)
        _PropsInfo.FilterAdd(false, 3)
        _PropsInfo.FilterAdd(false, 4)
        _PropsInfo.FilterAdd(false, 'prop2')
        _PropsInfo.FilterAdd(false, _FilterCustom)
        if _PropsInfo.Filter.Count !== 6 {
            Result.Push({ Line: A_LineNumber, Id: 19, Filter: _PropsInfo.Filter })
            return 1
        }
        if ObjPtr(_PropsInfo.Filter.Get(6).Function) !== ObjPtr(_FilterCustom) {
            Result.Push({ Line: A_LineNumber, Id: 20, Filter: _PropsInfo.Filter })
        }
        _PropsInfo.FilterDelete(1)
        if _PropsInfo.Filter.Has(1) {
            Result.Push({ Line: A_LineNumber, Id: 21, Filter: _PropsInfo.Filter })
        }
        _PropsInfo.FilterCache('Test')
        if !_PropsInfo.HasOwnProp('__FilterCache') || !_PropsInfo.__FilterCache.Has('Test') {
            Result.Push({ Line: A_LineNumber, Id: 22, Filter: _PropsInfo.Filter })
        }
        _PropsInfo.FilterClear()
        if _PropsInfo.Filter.Count {
            Result.Push({ Line: A_LineNumber, Id: 23, Filter: _PropsInfo.Filter })
        }
        _PropsInfo.FilterClearCache()
        if _PropsInfo.__FilterCache.Count {
            Result.Push({ Line: A_LineNumber, Id: 24, Filter: _PropsInfo.Filter })
        }
        _FilterCustom(*) => ''
    }

    /**
     * @description - Validates:
     * - FilterActivate
     * - FilterActivateFromCache
     * - FilterDeactivate
     * - GetFilteredProps
     */
    static GetProps_6() {
        this.Result.Push({ Test: A_ThisFunc, Result: Result := [] })
        i := 0
        for Obj in this.GetPropsResult {
            i++
            /** @var _PropsInfo - The result `PropsInfo` object. */
            _PropsInfo := Obj.Props

            ; Get ptrs to test FilterDeactivate
            PtrItems1 := ObjPtr(_PropsInfo.__InfoItems)
            PtrIndex1 := ObjPtr(_PropsInfo.__InfoIndex)

            _PropsInfo.FilterAdd(true, 'method1', _Filter_1)
            ; These two containers should be the same size
            if _PropsInfo.__InfoIndex.Count !== _PropsInfo.__InfoItems.Length {
                Result.Push({ LoopIndex: i,  Id: 25, Line: A_LineNumber, MapCount: _PropsInfo.__InfoIndex.Count, ArrLength: _PropsInfo.__InfoItems.Length })
            }

            ; Ensure excluded properties are excluded
            if HasProp(Obj.Subject, 'method1') {
                ; Because `_Filter_1` filters out all properties on base objects past index 2
                B := Obj
                loop 3 {
                    if B.HasOwnProp('method1') {
                        if _PropsInfo.Has('method1') {
                            Result.Push({ LoopIndex: i, Id: 26, Line: A_LineNumber, BaseIndex: A_Index })
                        }
                        break
                    }
                    B := B.Base
                }
            }
            ; Ensure no properties from objects past index 2 are present
            for InfoItem in _PropsInfo.__InfoItems {
                if InfoItem.Index > 2 {
                    Result.Push({ LoopIndex: i, Id: 27, Line: A_LineNumber, PropsInfo: _PropsInfo })
                }
            }
            ; Get object ptrs to test FilterActivateFromCache
            PtrItems2 := ObjPtr(_PropsInfo.__InfoItems)
            PtrIndex2 := ObjPtr(_PropsInfo.__InfoIndex)
            _PropsInfo.FilterCache('Test')
            Cache := _PropsInfo.__FilterCache.Get('Test')
            if ObjPtr(Cache.Items) !== PtrItems2 || ObjPtr(Cache.Index) !== PtrIndex2 {
                Result.Push({ LoopIndex: i, Id: 28, Line: A_LineNumber, PropsInfo: _PropsInfo })
            }
            _PropsInfo.FilterDeactivate()
            if ObjPtr(_PropsInfo.__InfoItems) !== PtrItems1 || ObjPtr(_PropsInfo.__InfoIndex) !== PtrIndex1 {
                Result.Push({ LoopIndex: i, Id: 29, Line: A_LineNumber, PropsInfo: _PropsInfo })
            }
            _PropsInfo.FilterActivateFromCache('Test')
            if ObjPtr(_PropsInfo.__InfoItems) !== PtrItems2 || ObjPtr(_PropsInfo.__InfoIndex) !== PtrIndex2 {
                Result.Push({ LoopIndex: i, Id: 30, Line: A_LineNumber, PropsInfo: _PropsInfo })
            }
            TestArray := _PropsInfo.ToArray()
            TestMap := _PropsInfo.ToMap()
            _PropsInfo.FilterDeactivate()

            ; GetFilteredProps
            NewPropsInfo := _PropsInfo.GetFilteredProps(, _Filter_1)
            TestMapCopy := TestMap.Clone()
            for Name, InfoItem in NewPropsInfo {
                if ObjPtr(TestArray[A_Index]) !== ObjPtr(InfoItem) || ObjPtr(TestMap.Get(Name)) !== ObjPtr(InfoItem) {
                    Result.Push({ LoopIndex: i, Id: 31, Line: A_LineNumber, PropsInfo: _PropsInfo, TestMap: TestMap, TestArray: TestArray, TestMapCopy: TestMapCopy })
                    break
                }
                TestMapCopy.Delete(Name)
            }
            if TestMapCopy.Count {
                Result.Push({ LoopIndex: i, Id: 32, Line: A_LineNumber, PropsInfo: _PropsInfo, TestMap: TestMap, TestArray: TestArray, TestMapCopy: TestMapCopy })
            }
            NewMap := Map()
            NewMap.CaseSense := false
            for Name, InfoItem in _PropsInfo.GetFilteredProps(NewMap, _Filter_1) {
                if ObjPtr(InfoItem) !== ObjPtr(TestMap.Get(Name)) {
                    Result.Push({ LoopIndex: i, Id: 33, Line: A_LineNumber, PropsInfo: _PropsInfo, TestMap: TestMap, TestArray: TestArray })
                    break
                }
            }
            for Item in _PropsInfo.GetFilteredProps(Array(), _Filter_1) {
                if ObjPtr(Item) !== ObjPtr(TestArray[A_Index]) {
                    Result.Push({ LoopIndex: i, Id: 34, Line: A_LineNumber, PropsInfo: _PropsInfo, TestMap: TestMap, TestArray: TestArray })
                    break
                }
            }
        }

        _Filter_1(InfoItem) {
            if InfoItem.Index > 2 || InfoItem.Name = 'method1' {
                return 1
            }
        }
    }

    /**
     * @description - Validates object types.
     */
    static GetProps_7() {
        this.Result.Push({ Test: A_ThisFunc, Result: Result := [] })
        if Type(_PropsInfo := this.GetPropsResult[1].Props) !== 'PropsInfo' {
            Result.Push({ Line: A_LineNumber, Id: 35, Type: Type(this.GetPropsResult[1].Props) })
        }
        if Type(p := _PropsInfo.GetProxy(1)) !== 'Array' {
            Result.Push({ Line: A_LineNumber, Id: 36, Type: Type(p) })
        }
        if Type(p := _PropsInfo.GetProxy(2)) !== 'Map' {
            Result.Push({ Line: A_LineNumber, Id: 37, Type: Type(p) })
        }
        if Type(Item := _PropsInfo.__InfoItems[1]) !== 'PropsInfoItem' {
            Result.Push({ Line: A_LineNumber, Id: 38, Type: Type(Item) })
        }
    }

    static GetProps_Master(n) {
        if !this.HasOwnProp('__GetProps_Master') {
            this.__GetProps_Master := []
            for Obj in this.GetPropsResult {
                i := 0
                this.__GetProps_Master.Push(Master := Map())
                Master.CaseSense := false
                O := Obj.Subject
                loop Obj.Expected.BaseObjCount + 1 {
                    for Prop in O.OwnProps() {
                        if !Master.Has(Prop) {
                            Master.Set(Prop, ++i)
                        }
                    }
                    O := O.Base
                }
            }
        }
        return this.__GetProps_Master[n]
    }

    static ResultArray() {
        if !this.HasOwnProp('Result') {
            this.Result := []
        }
        return this.Result
    }

    static OpenEditor() {
        Run(A_ComSpec ' /C ' this.PathEditor ' ' this.Pathout)
    }

    static WriteOut(Results) {
        f := FileOpen(this.PathOut, 'w')
        f.Write(Results is String ? Results : Stringify(Results))
        f.Close()
    }
}

;@region classes
class A extends A.base {

    Prop2 := '$.Prop2' ; "$" is to indicate that its a value property on the instance object, and not an accessor on the prototype

    Method2() {
        return 'A.Prototype.method2'
    }

    class base extends Array {
        method() {
            return 'A.base.Prototype.method'
        }
        method2() {
            return 'A.base.Prototype.method2'
        }

        Prop {
            Get => 'A.base.Prototype.Prop.Get'
            Set => 'A.base.Prototype.Prop.Set'
        }

        Prop2 {
            Get => 'A.base.Prototype.Prop2.Get'
            Set => 'A.base.Prototype.Prop2.Set'
        }
    }
}


class m extends map {

    static method() {
        return 'm.method'
    }

    static method2() {
        return 'm.method2'
    }

    static prop {
        get => 'm.prop.get'
        set => 'm.prop.set'
    }

    static prop2 {
        get => 'm.prop2.get'
        set => 'm.prop2.set'
    }

    method() {
        return 'm.Prototype.method'
    }
    method2() {
        return 'm.Prototype.method2'
    }

    Prop {
        Get => 'm.Prototype.Prop.Get'
        Set => 'm.Prototype.Prop.Set'
    }

    Prop2 {
        Get => 'm.Prototype.Prop2.Get'
        Set => 'm.Prototype.Prop2.Set'
    }
}

class m2 extends m {
    static prop2 {
        get => 'm2.prop2.get'
        set => 'm2.prop2.set'
    }
    static method2() {
        return 'm2.method2'
    }

    Prop2 := '$.Prop2'

    Method2() {
        return 'm2.Prototype.Method2'
    }
}
;@endregion
