#include ..\QuickParse.ahk

test()

test() {
    result := QuickParse(, 'example.json')
    for prop in ['__Test', 'A_Array', 'A_Condense', 'M_Map', 'O_Object', 'String', 'Number1'
    , 'Number2', 'Number3', 'Number4', 'Number5', 'Number6', 'Number7', 'False', 'Null', 'True'
    , 'Object1', 'Object2', 'Object3', 'Object4', 'Object5', 'Array1', 'Array2', 'Array3', 'Array4'
    , 'Array5'] {
        if !result.HasOwnProp(prop) {
            throw Error('Missing property.', -1, prop)
        }
    }
    root := Map()
    result := QuickParse(, 'example.json', , root, true)
    for prop in ['__Test', 'A_Array', 'A_Condense', 'M_Map', 'O_Object', 'String', 'Number1'
    , 'Number2', 'Number3', 'Number4', 'Number5', 'Number6', 'Number7', 'False', 'Null', 'True'
    , 'Object1', 'Object2', 'Object3', 'Object4', 'Object5', 'Array1', 'Array2', 'Array3', 'Array4'
    , 'Array5'] {
        if !result.Has(prop) {
            throw Error('Missing property.', -1, prop)
        }
    }
    if ObjPtr(result) != ObjPtr(root) {
        throw Error('Different objects.', -1)
    }
    sleep 1
}
