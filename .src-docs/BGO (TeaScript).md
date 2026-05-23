# BGO (TeaScript)

> 来源: <https://wohlsoft.ru/pgewiki/BGO_(TeaScript)>

---

BGO is a class in TeaScript.vbs that allows you to read/write values for background objects.

## Using the BGO Class

To read the value of `BGO` use:

BGO(id).name

`id` stands for the BGO's permanent ID. To change the value of `BGO` use:

BGO(id).name \= value

## BGO Properties

###### Physical Properties

| Type | Name | Read/Write | Description |
| --- | --- | --- | --- |
| double | `id` | \- | The ID is used to decide and tie in its graphics, BGO flags. You can change this value to change the BGO into another |
| double | `x` | \- | The x coordinate of the BGO in scene coordinates. |
| double | `y` | \- | The y coordinate of the BGO in scene coordinates. |
| double | `xsp` | \- | Horizontal Speed (Moves right if set to a positive number, moves left if set to a negative number) |
| double | `ysp` | \- | Vertical Speed (Moves down if set to a positive number, moves up if set to a negative number) |
| double | `hide` | \- | Whether the BGO is hidden or not. |

###### Graphical Properties

| Type | Name | Read/Write | Description |
| --- | --- | --- | --- |
| double | `zpos` | \- | The priority value of the BGO. Must be a number between 0 and 1, where 0 is foreground and 1 is background. |
| double | `extx` | \- | This values chooses the alternative GFX x position starting from 0. Setting this value to -1 makes the NPC invisible. A BGO automatically has an extx if the texture width is larger than the BGO width. |
| double | `exty` | \- | This values chooses the alternative GFX y position starting from 0. Setting this value to -1 makes the NPC invisible. A BGO automatically has an exty if the texture height is larger than the BGO height. |
| double | `forecolor` | \- | An overlay hue added to the BGO. Setting this value to 0 makes the BGO invisible, setting it to -1 returns it to default. Use the rgba(red, green, blue, alpha) function to choose a specific hue. |
| double | `forecolor_r` | \- | The red value of the hue described in 'forecolor'. Should be a value between 0 to 255. Use this value to read and get only the red component. |
| double | `forecolor_g` | \- | The green value of the hue described in 'forecolor'. Should be a value between 0 to 255. Use this value to read and get only the green component. |
| double | `forecolor_b` | \- | The blue value of the hue described in 'forecolor'. Should be a value between 0 to 255. Use this value to read and get only the blue component. |
| double | `forecolor_a` | \- | The alpha value of the hue described in 'forecolor'. Should be a value between 0 to 255. Use this value to read and get only the alpha component. |

###### Unknown

| Type | Name | Read/Write | Description |
| --- | --- | --- | --- |
| double | `prx` | \- | Unknown |
| double | `pry` | \- | Unknown |
