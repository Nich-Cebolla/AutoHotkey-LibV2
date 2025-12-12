
#include ..\QuickStringify.ahk
#include ..\QuickStringifyProps.ahk
#include ..\MaxStringify.ahk
#include ..\PrettyStringify.ahk
#include ..\PrettyStringifyProps.ahk
#include ..\QuickStringify2.ahk
#include ..\QuickStringifyProps2.ahk
#include ..\MaxStringify2.ahk
#include ..\PrettyStringify2.ahk
#include ..\PrettyStringifyProps2.ahk
#include ..\..\QuickParse.ahk

test()

class test {
    static Call() {
        ProcessSetPriority('High')
        list := []
        obj := {
            AA: [
                [
                    [ 'AAA' ],
                    Map( 'AAM', 'AAM' ),
                    { AAO: 'AAO' }
                ],
                Map( 'AM1A', [ 'AMA' ],
                     'AM2M', Map('AMM', 'AMM'),
                     'AM3O', {AMO: 'AMO'}
                ),
                {
                    AO1A: ['AOA', true],
                    AO2M: Map(
                        'AOM1', 'AOM',
                        'AOM2', false
                    ),
                    AO3O: {
                        AOO1: 'AOO',
                        AOO2: ''
                    }
                }
            ],
            MM: Map(
                'M1A', [['MAA'], Map('MAM', 'MAM'), {MAO: 'MAO'}]
              , 'M2M', Map('MM1A', ['MMA'], 'MM2M', Map('MMM', 'MMM'), 'MM3O', {MMO: 'MMO'})
              , 'M3O', {MO1A: ['MOA'], MO2M: Map('MOM', 'MOM'), MO3O: {MOO: 'MOO'}}
            ),
            OO: {
                O1A: [['OAA'], Map('OAM', 'OAM'), {OAO: 'OAO'}]
              , O2M: Map('OM1A', ['OMA'], 'OM2M', Map('OMM', 'OMM'), 'OM3O', {OMO: 'OMO'})
              , O3O: {OO1A: ['OOA'], OO2M: Map('OOM', 'OOM'), OO3O: {OOO: 'OOO'}}
            }
        }
        list.Push(obj)

        o1 := MaxStringify()
        o1(list, &str)
        OutputDebug(str '`n`n')

        o2 := MaxStringify2()
        o2(list, &str)
        OutputDebug(str '`n`n')

        o3 := PrettyStringify()
        o3(list, &str)
        OutputDebug(str '`n`n')

        o4 := PrettyStringify2()
        o4(list, &str)
        OutputDebug(str '`n`n')

        o5 := PrettyStringifyProps()
        o5(list, &str)
        OutputDebug(str '`n`n')

        o6 := PrettyStringifyProps2()
        o6(list, &str)
        OutputDebug(str '`n`n')

        o7 := QuickStringify()
        o7(list, &str)
        OutputDebug(str '`n`n')

        o8 := QuickStringify2()
        o8(list, &str)
        OutputDebug(str '`n`n')

        o9 := QuickStringifyProps()
        o9(list, &str)
        OutputDebug(str '`n`n')

        o10 := QuickStringifyProps2()
        o10(list, &str)
        OutputDebug(str '`n`n')
        OutputDebug(A_ScriptName ': done`n')
    }
}
