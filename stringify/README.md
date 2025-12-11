# Stringify

This folder contains various stringify functions (functions which serialize an object's properties and/or
items). These are much faster than [StringifyAll](https://github.com/Nich-Cebolla/StringifyAll), but
have less features.

The functions that end in "2" output map objects as { "Key": "val" }. The functions that do not end
in "2" output map objects as [ [ "key", "val" ] ].

The following is the result from each function processing the same object 10 times. The object produced
a 4,454 KB (4560003 characters) string. You can recreate the test with stringify\test\test-performance.ahk.
- `QuickStringify`: 5.641
- `QuickStringifyProps`: 5.703
- `QuickStringifyProps2`: 5.703
- `QuickStringify2`: 5.734
- `MaxStringify2`: 5.953
- `PrettyStringify`: 6.407
- `PrettyStringify2`: 6.546
- `MaxStringify`: 6.562
- `PrettyStringifyProps2`: 7.031
- `PrettyStringifyProps`: 7.157
- [JSON.stringify](https://github.com/thqby/ahk2_lib/blob/master/JSON.ahk): 9.406
- `StringifyAll` - 855 seconds

The functions are implemented as classes. You pass the class constructor an options object (or use
the default options), and you receive a function object that reuses the same options.
