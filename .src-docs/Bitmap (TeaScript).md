# Bitmap (TeaScript)

> 来源: <https://wohlsoft.ru/pgewiki/Bitmap_(TeaScript)>

---

Bitmap is a class in TeaScript.vbs that allows you to read/write values of bitmaps.

# Creating a Bitmap

To create a bitmap you can use the `BmpCreate`

call bmpcreate(index, picid, useScreenCoords, isVisible, sx, sy, sw, sh, destx, desty, stretchx, stretchy, centerx, centery, angle, color)

For more information visit the [BmpCreate](https://wohlsoft.ru/pgewiki/Functions_(TeaScript)#BmpCreate) documentation.

# Using the Bitmap Class

To read the value of `Bitmap` use:

Bitmap(index).name

To change the value of `Bitmap` use:

Bitmap(index).name \= value

Where index is an unique identifier defined when creating the bitmap object.

# Bitmap Properties

##### Physical Properties

| Type | Name | Read/Write | Description |
| --- | --- | --- | --- |
| double | `destx` | \- | The x position of the bitmap. |
| double | `desty` | \- | The y position of the bitmap. |
| double | `scalex` | \- | The horizontal stretch ration. (e.g. 1: default size, 2:double size, 0.5: half size |
| double | `scaley` | \- | The horizontal stretch ration. (e.g. 1: default size, 2:double size, 0.5: half size |
| double | `rotatang` | \- | Rotates the bitmap in counter-clockwise in radians. |

##### Behavioral Properties

| Type | Name | Read/Write | Description |
| --- | --- | --- | --- |
| double | `attscreen` | \- | Determines if the bitmap uses scene or screen coordinates (0:scene, 1: screen). |
| double | `scrx` | \- | Determines the top left x position in the source image. |
| double | `scry` | \- | Determines the top left y position in the source image. |
| double | `scrwidth` | \- | Determines the width loaded in the source image. |
| double | `scrheight` | \- | Determines the height loaded in the source image. |
| double | `rotatx` | \- | The x position of the anchor used for scaling and rotating. |
| double | `rotaty` | \- | The y position of the anchor used for scaling and rotating. |

##### Graphical Properties

| Type | Name | Read/Write | Description |
| --- | --- | --- | --- |
| double | `hide` | \- | Determines if the bitmap is rendered (0: show, 1:hide) |
| double | `scrid` | \- | Determines the ID of the NPC used as the texture source. |
| double | `zpos` | \- | The priority of the bitmap. Foreground is 0 and background is 1. |
| double | `blendmode` | \- | Determines the blendmode of the bitmap. \[Values listed below\] |
| double | `forecolor` | \- | An overlay hue added to the bitmap. Setting this value to 0 makes the player invisible, setting it to -1 returns it to default. Use the `rgba(red, green, blue, alpha)` function to choose a specific hue. |
| double | `forecolor_r` | \- | The red value of the hue described in 'forecolor'. Should be a value between 0 to 255. Use this value to read and get only the red component. |
| double | `forecolor_g` | \- | The green value of the hue described in 'forecolor'. Should be a value between 0 to 255. Use this value to read and get only the green component. |
| double | `forecolor_b` | \- | The blue value of the hue described in 'forecolor'. Should be a value between 0 to 255. Use this value to read and get only the blue component. |
| double | `forecolor_a` | \- | The alpha value of the hue described in 'forecolor'. Should be a value between 0 to 255. Use this value to read and get only the alpha component. |

# Constants

Here are a list of constants used by the Bitmap class

<table class="wikitable"><caption>Blendmode Values</caption><tbody><tr><th>ID</th><th>Description</th></tr><tr><td>1</td><td>Black</td></tr><tr><td>3</td><td>Reddish</td></tr><tr><td>4</td><td>Negative Colors</td></tr><tr><td>9</td><td>Blue Cyan</td></tr><tr><td>10</td><td>Orange/Red</td></tr><tr><td>1289</td><td>Brighter Color</td></tr><tr><td>66050</td><td>Additive</td></tr><tr><td>66053</td><td>Additive + Alpha</td></tr><tr><td>197122</td><td>Subtractive</td></tr><tr><td>197125</td><td>Subtractive + Alpha</td></tr></tbody></table>

# Oddities and Quirks

Below is a list of certain quirks bitmaps have that does not conform to standard behavior or simply other miscellaneous behavior.
