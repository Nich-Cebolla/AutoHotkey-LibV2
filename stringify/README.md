# Stringify

This folder contains various stringify functions (functions which serialize an object's properties and/or
items). These are much faster than [StringifyAll](https://github.com/Nich-Cebolla/StringifyAll), but
have less features.

The following is the result from each function processing the same object 10 times. The object produced
a 4,454 KB (4560003 characters) string.
- `QuickStringify` - 5.063 seconds
- `PrettyStringify` - 6.187 seconds
- `QuickStringifyProps` - 5.094 seconds
- `PrettyStringifyProps` - 6.953 seconds
- `MaxStringify` - 6.09 seconds
- [JSON.stringify](https://github.com/thqby/ahk2_lib/blob/master/JSON.ahk) - 9.297 seconds
- `StringifyAll` - 855 seconds

The functions are implemented as classes. You pass the class constructor an options object (or use
the default options), and you receive a function object that reuses the same options.
