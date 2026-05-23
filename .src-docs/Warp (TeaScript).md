# Warp (TeaScript)

> 来源: <https://wohlsoft.ru/pgewiki/Warp_(TeaScript)>

---

Warp is a class in TeaScript.vbs that allows you to read/write values for warps.

# Using the Warp Class

To read the value of `Warp` use:

Warp(index).name

To change the value of `Warp` use:

Warp(index).name \= value

Where index is the index as shown in the editor.

# Warp Properties

##### Physical Properties

| Type | Name | Read/Write | Description |
| --- | --- | --- | --- |
| double | `x` | \- | The top left x position of the entrance in scene coordinates |
| double | `y` | \- | The top left y position of the entrance in scene coordinates |
| double | `ex` | \- | The top left x position of the exit in scene coordinates |
| double | `ey` | \- | The top left y position of the exit in scene coordinates |
| double | `xsp` | \- | The horizontal speed of the warp. Negative values cause leftwards movement, positive values cause rightwards movement. This affects both the entrance and exit warp, and any effects spawned by the warp animation (such as doors). |
| double | `ysp` | \- | The vertical speed of the warp. Negative values cause upwards movement, positive values cause downwards movement. This affects both the entrance and exit warp, and any effects spawned by the warp animation (such as doors). |
| double | `hide` | \- | Whether the warp is hidden or not. |

##### Behavioral Properties

| Type | Name | Read/Write | Description |
| --- | --- | --- | --- |
| double | `twoside` | \- | Determines if the exit also warps to the entrance (0: Disabled, 1: Enabled). |
| double | `cannon` | \- | The flight duration of the pipe cannon. Use 0 to disable the cannon. |
| double | `locked` | \- | Determines if the warp is locked and requires a key? (0: No, 1: Yes) |
| double | `bomb` | \- | Determines if the warp needs to be hit by an explosion? (0: No, 1: Yes) |
| double | `mini` | \- | Determines if the warp can only be accessed in mini form? (0: No, 1: Yes) |
| double | `noyoshi` | \- | Prevents yoshi from passing through the warp. Removes the yoshi if the player attempts to. (0: Allow Yoshi, 1: Disable Yoshi) |
| double | `canpick` | \- | Allows NPCs the player is holding to pass through the warp. If the player is holding an item, the item is dropped at the entarnce. If the player is wearing a helmet, the helmet is removed. If the item is in yoshi's mouth, yoshi spits the item. (0: Disables NPCs, 1: Allows NPCs) |
| double | `starcnt` | \- | The number of stars needed to enter the warp. |
| string | `starmsg` | \- | The message shown when the player doesn't have enough stars. |

##### Level Warp Properties

| Type | Name | Read/Write | Description |
| --- | --- | --- | --- |
| string | `levelname` | \- | The filename of the level the warp will send the player to. Will automatically force the Level Exit warp type in game. |
| double | `levelwarp` | \- | The ID of the warp the player exits to if the warp sends the player to another level. Use 0 for regular entrance. |
| double | `worldx` | \- | The x positon of the world map that the player will be sent to when the player exits the level. |
| double | `worldy` | \- | The y positon of the world map that the player will be sent to when the player exits the level. |

##### Warp Events

| Type | Name | Read/Write | Description |
| --- | --- | --- | --- |
| string | `warpevent` | \- | The event/script that should be called when entering the warp. |

  

# Oddities and Quirks

Below is a list of certain quirks warps have that does not conform to standard behavior or simply other miscellaneous behavior.
