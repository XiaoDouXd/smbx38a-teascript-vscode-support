# Text (TeaScript)

> 来源: <https://wohlsoft.ru/pgewiki/Text_(TeaScript)>

---

Text is a class in TeaScript.vbs that allows you to read/write values for text.

# Creating a Text

To create a text object use the `TxtCreate` function.

call TxtCreate(index, x, y, sasc, easc, cdata, lnum, fontid, flag, text)

For more information visit the [TxtCreate](https://wohlsoft.ru/pgewiki/Functions_(TeaScript)#TxtCreate) documentation.

  

# Using the Text Class

To read the value of `Text` do:

Text(index).name

To change the value of `Text` do:

Text(index).name \= value

  
Where index is an unique identifier defined when creating the text object.

  

# Text Properties

##### Physical Properties

| Type | Name | Read/Write | Description |
| --- | --- | --- | --- |
| string | `text` | \- | The text shown. |
| double | `x` | \- | The x coordinate. It uses screen or scene coordinates based on its flag in TxtCreate. |
| double | `y` | \- | The y coordinate. It uses screen or scene coordinates based on its flag in TxtCreate. |

##### Graphical Properties

| Type | Name | Read/Write | Description |
| --- | --- | --- | --- |
| double | `zpos` | \- | The priority of the text. Foreground is 0 and background is 1. |
| double | `hide` | \- | Determines if the text is hidden.(0: Show text; 1: Hide text) |
| double | `forecolor` | \- | An overlay hue added to the text. Setting this value to 0 makes the player invisible, setting it to -1 returns it to default. Use the `rgba(red, green, blue, alpha)` function to choose a specific hue. |
| double | `forecolor_r` | \- | The red value of the hue described in 'forecolor'. Should be a value between 0 to 255. Use this value to read and get only the red component. |
| double | `forecolor_g` | \- | The green value of the hue described in 'forecolor'. Should be a value between 0 to 255. Use this value to read and get only the green component. |
| double | `forecolor_b` | \- | The blue value of the hue described in 'forecolor'. Should be a value between 0 to 255. Use this value to read and get only the blue component. |
| double | `forecolor_a` | \- | The alpha value of the hue described in 'forecolor'. Should be a value between 0 to 255. Use this value to read and get only the alpha component. |

##### Other

| Type | Name | Read/Write | Description |
| --- | --- | --- | --- |
| double | `width` | \- | The number of characters of a single row in the NPC image file. |
| double | `foreground` | \- | Set this to 0 and the text created will be hidden. Set this to 1 and the text will be visible. |

##### Unknown

| Type | Name | Read/Write | Description |
| --- | --- | --- | --- |
| double | `height` | \- | Unknown |

# Oddities and Quirks

Below is a list of certain quirks text have that does not conform to standard behavior or simply other miscellaneous behavior.
