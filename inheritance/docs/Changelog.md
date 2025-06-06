
2025-06-06 - 1.4.0
- Added `PropsInfo.Prototype.Delete`.
- Added `PropsInfo.Prototype.FilterGetList`.
- Added `PropsInfo.Prototype.Refresh`.
- Added `PropsInfo.Prototype.RefreshProp`.
- Added `PropsInfoObj.Excluded`, which is a comma-delimited list of properties that are not exposed by the `PropsInfo` object. For each of `GetPropsInfo`, `PropsInfo.Prototype.Delete`, `PropsInfo.Prototype.Refresh`, and `PropsInfo.Prototype.RefreshProp`, the `PropsInfoObj.Excluded` property is updated to reflect any changes made.
- Added `PropsInfoObj.InheritanceDepth` and `InfoItem.InheritanceDepth`, which is an integer value set by `GetPropsInfo` originally, and updated by  `PropsInfo.Prototype.Refresh` and `PropsInfo.Prototype.RefreshProp`. The value is the number of base objects from the root object that have properties included in the collection. In other words, it is the length of the array returned by `GetBaseObjects`.
- Added "test-files\test-Inheritance-1.4.0.ahk".
- `PropsInfo.Prototype.__New` now has an additional parameter `Excluded`.
- `PropsInfoItem.Prototype.GetOwner` no longer throws an error if the object does not own the property, it returns 0 instead.
- `PropsInfoItem.Prototype.Refresh` returns 0 if the object no longer owns the property.
- If `PropsInfo.Prototype.GetFilteredProps` returns a `PropsInfo` object, the `PropsInfo` object's `Excluded` property is set as the combined property names from the original object's `Excluded` property + the property names that were just excluded by the filter.
- Fixed an error in `GetPropsInfo` that caused `PropsInfoItem` objects associated with the `Base` property to always be the base object of the root object.

2025-06-01 - 1.3.3
- Fixed an error causing the setter function not to be returned when calling `InfoItem.Prototype.GetFunc`.

2025-05-26 - 1.3.2
- Fixed an issue where `PropsInfo.Prototype.Dispose` would call `PropsInfoObj.Filter.Clear`, resulting in the filter being invalidated. This no longer occurs.

2025-05-25 - 1.3.1
- Added parameter `ExcludeMethods=false` to `GetPropsInfo`.

2025-05-24 - 1.3.0
- Added `PropsInfo.FilterGroup`.
- Added `PropsInfo.Prototype.FilterSet`.
- Adjusted `PropsInfo.Prototype.FilterAdd` and `PropsInfo.Prototype.FilterDelete` to call their `PropsInfo.FilterGroup.Prototype` counterpart.
- Adjusted `PropsInfo.Prototype.FilterCache` and `PropsInfo.Prototype.FilterActivateFromCache` to also cache / restore the `PropsInfo.FilterGroup` object.
- Removed `PropsInfoObj._FilterIndex`.

2025-05-05
- Fixed an issue with `PropsInfoItem.Prototype.GetOwner`. Previously, it was possible for the method to return an incorrect value. While it is still possible for the method to return a value that is different from the original owner of the property, this is much less likely and less of a concern than previous. See the parameter hint above the method for details about the limitations of the method.

2025-05-03
- Finalized some details and uploaded to the AutoHotkey forums.
