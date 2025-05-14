
#Include ..\ContinuationSection.ahk

PathOut := A_MyDocuments '\test-output-ContinuationSection.json'
Text := FileRead('test-content-ParseContinuationSection.ahk')

Process()

Test() {
    PatternStatement := (
        'iJm)'
        '^(?<indent>[ \t]*)'
        '(?<text>'
            '(?<static>static\s+)?'
            '(?<name>[a-zA-Z0-9_]+)'
            '(?:'
                '(?<params>\((?<inner>([^()]++|(?&params))*)\))'
                '(*MARK:func)'
            '|'
                '(?<params>\[(?<inner>(?:[^\][]++|(?&params))*)\])?'
            ')'
            '\s*'
            '(?:'
                '(?<body>\{([^{}]++|(?&body))*\})'
            '|'
                '(?:'
                    '(?<assign>:=)'
                '|'
                    '(?<arrow>=>)'
                ')'
                '(?<body>.+)'
            ')'
        ')'
    )
    List := []
    while RegExMatch(Text, PatternStatement, &Match, Pos ?? 1) {
        List.Push(ContinuationSection(StrPtr(Text), Match.Pos['indent'], Match['arrow'] ? '=>' : ':='))
        Pos := Match.Pos + Match.Len
    }
    return List
}

Process() {
    V := Validation()
    List := Test()
    Problems := []
    for cs in List {
        if V[A_Index] !== cs.Text {
            Problems.Push(
                '`nIndex: ' A_Index
                '`nExpected=================`n'
                '`n' V[A_Index]
                '`nResult-------------------`n'
                '`n' cs.Text
                '`nExpected len: ' StrLen(V[A_Index]) '; Result len: ' cs.Len['Text']
                '`nDiff: ' (StrLen(V[A_Index]) - cs.Len['Text'])
            )
            OutputDebug(Problems[-1])
        } else {
            OutputDebug('`nExpected----------------------`n' V[A_Index] '`nResult========================`n' cs.Text)
        }
    }
    OutputDebug('`n`nDone. Problems: ' Problems.Length)
    s := ''
    for P in Problems {
        s .= P '`n`n'
    }
    f := FileOpen(PathOut, 'w')
    f.Write(s)
    f.Close()
}

Validation() => [
    ; 1
    '
( LTrim0 Rtrim0
    static ArrowMethod1() => Var1 * Var2 - SomeMap.Get('key').CallableProperty({
        Prop1: 'val1', Prop2: Map(
        `)
        , Prop3: 'val3'

        , prop4: FunctionCall(Param1, param2, ParamWithDefault := 'value'
        , param?)

    })
)',
    ; 2
    '
( LTrim0 Rtrim0
    instanceArrowMethod(WithParam1) => (
        ' string continuation section'
        '``r``nstring continuation section' variable concatenation
        '``r``nmore string continuation '  mymap.Get('otherkey') FunctionCall('GetString')
        '``r``nstring continuation section'
    `)

    .

    'Just a little more string'
)',
    ; 3
    '    instanceArrowMethod2(Param1, param2, param3) =>  ComCall(p, p2, p3, p4)',

    ; 4
    '
( LTrim0 Rtrim0
    instanceArrowMethod3(WithParam1) => (
        ' string continuation section'
        '``r``nstring continuation section' variable concatenation
        '``r``nmore string continuation '  mymap.Get('otherkey') FunctionCall('GetString')
        '``r``nstring continuation section'
    `) .

    'Just a little more string'
)',

    ; 5
    '    instancearrowprop1 => GetValueFunc(this.prop1, this.prop2, globalval)',

    ; 6
    '
( LTrim0 Rtrim0
    instancearrowprop2[param1] => assignmenttovariable :=

            IsValidDownHere * OtherMap[key] + AnotherFuncCall(this.prop1,
            , param2
            , param3
            `) / param1
)',
    ; 7
    '
( LTrim0 Rtrim0
    instancearrowprop3[param1
    , param2
    , param3
    ] => AssignmentOverHere /=
    5 + 10 - 20
)',
    ; 8
    '
( LTrim0 Rtrim0
    static arrowProp => FuncCall(Param1
    ,param2,param3, param4)
)',

    ; 9

    '
( LTrim0 Rtrim0
    static Arrowprop2 => [lets, make, an, array_, [with, nested, array_, 5, 7]

    , , , empty, slots ].join(', ')
)',

    ; 10

    '
( LTrim0 Rtrim0
    static ArrowProp3[params?] => FuncCall(Param1, param2, param3?, param4 := 'default'

    ,


    param5)
)'
]
