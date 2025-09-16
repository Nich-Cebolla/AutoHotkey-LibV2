
/**
 * `ConfigLibrary` is a snippet intended to be copy-pasted into a file in your
 * {@link https://www.autohotkey.com/docs/v2/Scripts.htm#lib lib folder}. This allows that script
 * to be accessible from any other script using `#include <FileName>` notation.
 *
 * Many of my libraries take an options object as a parameter. I found that, when developing something
 * new that makes use of one of my libraries, I would go to another script that also made use of the
 * same library and copy-paste the options object into the new file.
 *
 * Using `ConfigLibrary` will help keep those configurations in one place and make them accessible
 * programmatically.
 *
 * Example:
 *
 * {@link https://github.com/Nich-Cebolla/AutoHotkey-Tracer Tracer} can be used to trace code execution
 * for debugging purposes. I typically add it to code when I'm having trouble debugging something,
 * and then remove it from the code when finished. `ConfigLibrary` helps facilitate this process.
 *
 * 1. Copy-paste the `ConfigLibrary` contents into a file in your lib folder, e.g.
 *    C:\Users\you\Documents\AutoHotkey\lib\tracer-config.ahk
 * 2. Rename the class to avoid a scenario where you use two versions of `ConfigLibrary` for separate
 *    purposes in the same code, e.g. `Tracer_ConfigLibrary` or even shorthand (if it will later
 *    be removed from the code) `tcl`.
 * 3. Add in your options objects in the body of the static method `ConfigLibary.__New`.
 * 4. In your script that will be making use of `ConfigLibrary`, add an `#include <ScriptName>`
 *    statement, e.g. `#include <tracer-config>`.
 * 5. Access the options object by name, e.g. `options := Tracer_ConfigLibrary('debug')` or
 *    `opt := tcl('debug')`.
 *
 * This approach helps during testing and development, but for shared code or production code
 * you may want to define the options objects in the code itself.
 *
 * Example `ConfigLibrary` file
 *
 * @example
 *  class tcl {
 *      static __New() {
 *          this.DeleteProp('__New')
 *          this.DefineProp('__Item', { Value: Map() })
 *          this.__Item.CaseSense := false
 *
 *          ; Define config items
 *
 *          this.__Item.Set(
 *              'debug', {
 *                  LogFile: {
 *                      Dir: A_Temp '\debug-projectname'
 *                    , Name: 'log'
 *                    , Ext: 'json'
 *                    , MaxFiles: 30
 *                    , MaxSize: 100000
 *                  }
 *                , Log: {
 *                      ToJson: true
 *                  }
 *                , Out: {
 *                      ToJson: false
 *                  }
 *                , Tracer: {
 *                      HistoryActive: true
 *                  }
 *                , TracerGroup: {
 *                      GroupName: 'debug'
 *                    , HistoryActive: true
 *                  }
 *              }
 *          )
 *      }
 *
 *      static Call(Key) => this.__Item.Get(Key)
 *      static __Get(Name, Params) {
 *          if Params.Length {
 *              return this.__Item.%Name%[Params*]
 *          } else {
 *              return this.__Item.%Name%
 *          }
 *      }
 *      static __Call(Name, Params) {
 *          return this.__Item.%Name%(Params*)
 *      }
 *      static __Set(Name, Params, Value) {
 *          if Params.Length {
 *              return this.__Item.%Name%[Params*] := Value
 *          } else {
 *              return this.__Item.%Name% := Value
 *          }
 *      }
 *  }
 * @
 *
 * Example using the above file. Assume the file is saved to the user library, e.g.
 * C:\Users\me\Documents\AutoHotkey\lib\tracer-config.ahk
 *
 * @example
 *  #include <Tracer>
 *  #include <tracer-config>
 *
 *  global t_opt := TracerOptions(tcl('debug'))
 *  , t_group := TracerGroup(t_opt, true)
 *  , t := t_group()
 * @
 *
 */
class ConfigLibrary {

    static __New() {
        this.DeleteProp('__New')
        this.DefineProp('__Item', { Value: Map() })
        this.__Item.CaseSense := false

        ; Define config items

    }

    static Call(Key) => this.__Item.Get(Key)
    static __Get(Name, Params) {
        if Params.Length {
            return this.__Item.%Name%[Params*]
        } else {
            return this.__Item.%Name%
        }
    }
    static __Call(Name, Params) {
        return this.__Item.%Name%(Params*)
    }
    static __Set(Name, Params, Value) {
        if Params.Length {
            return this.__Item.%Name%[Params*] := Value
        } else {
            return this.__Item.%Name% := Value
        }
    }
}
