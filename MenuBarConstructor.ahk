/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/MenuBarConstructor.ahk
    Author: Nich-Cebolla
    Version: 1.0.1
    License: MIT
*/

class MenuBarConstructor {

    /** ### Description - MenuBarConstructor()
     * This class is used to create a menu Bar with the specified Menus.
     * @param {Array} Menus - An array of arrays. For each nested array, the first Item in the
     * array represents the display name for the menu. Each subsequent Item in the array contains
     * alternating menu Item names and callbacks for the previous menu Item. The alternating Items
     * begins with a Item name, the next is the first Item's callback, and so on.
     * @param {VarRef} [MenuObjects] - A variable that will receive a Map object. The keys are the
     * menu names from the input `Menus` array, and the values are the Menu objects created for each
     * nested array.
     * @returns {MenuBar} - A MenuBar object with the specified Menus.
     */
    static Call(Menus, &MenuObjects?) {
        MenuObjects := Map()
        Bar := MenuBar()
        for Item in Menus {
            MenuObjects.Set(MenuName := Item.RemoveAt(1), M := Menu())
            Loop Item.length / 2
                M.Add(Item[A_Index * 2 - 1], Item[A_Index * 2])
            Bar.Add(MenuName, M)
        }
        return Bar
    }
}
