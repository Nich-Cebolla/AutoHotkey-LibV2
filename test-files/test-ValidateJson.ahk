#include ..\ValidateJson.ahk

test()

test() {
    for Content in [
        FileRead('example.json')
      , FileRead('test-content-QuickParse.json')
      , '{"Prop1":"Val1","Prop2":{"Prop1":"Val1,"Prop2":[,"String"]}}'
      , '{"Prop"":"Val"}'
      , '{""Prop":"Val"}'
      , '{"Prop":"Val""}'
      , '{"Prop":""Val"}'
      , '{"Prop":--0.10}'
      , '{"Prop":Null}'
      , '{"Prop":True}'
      , '{"Prop":infinity}'
      , '{"Prop":"Val\\\"}'
      , '[,"String"]'
      , '["Val""]'
      , '[""Val"]'
      , '[--0.10]'
      , '[Null]'
      , '[True]'
      , '[infinity]'
      , '["Val\\\"]'
      , '[value]'
    ] {
        if A_Index <= 2 {
            if err := ValidateJson(Content) {
                throw err
            }
        } else {
            err := ValidateJson(Content)
            if !err {
                throw Error('Expected error.', -1, A_Index ': ' Content)
            }
        }
    }
}
