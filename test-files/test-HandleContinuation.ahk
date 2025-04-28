
#Include <HandleContinuation>
Process()

Test(&Text) {
    static PatternStatement := (
        'iJm)'
        '^(?<indent>[ \t]*)'
        '(?<static>static\s+)?'
        '(?<name>[a-zA-Z0-9_]+)'
        '(?:'
            '(?<params>\(([^()]++|(?&params))*\))(*MARK:func)'
            '|'
            '(?<params>\[(?:[^\][]++|(?&params))*\])?'
        ')'
        '\s*'
        '(?<arrow>=>)'
        '(?<body>.+)'
    )
    List := []
    while RegExMatch(Text, PatternStatement, &MatchStatement, Pos ?? 1) {
        List.Push(HandleContinuation(&Text, MatchStatement, '=>', , &Pos, &Len, &Body, &LenBody))
    }
    return List
}

Process() {
    V := Validation()
    Text := FileRead('test_content_HandleContinuation.ahk')
    List := Test(&Text)
    Str := FormatTime(A_Now, 'yyyy-MM-dd HH:mm:ss')
    for l in List {
        if V[A_Index] !== l {
            msgbox(A_Index '`r`n`r`n' l)
        }
        ; Str .= '`r`n`r`n`r`n' l
    }

    ; f := fileopen('_test4.txt', 'w')
    ; f.write(Str)
    ; f.close()
    msgbox('done')
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
