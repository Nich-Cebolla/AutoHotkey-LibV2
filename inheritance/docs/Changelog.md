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
