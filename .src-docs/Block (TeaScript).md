# Block (TeaScript)

> 来源: <https://wohlsoft.ru/pgewiki/Block_(TeaScript)>

---

Block is a class in TeaScript.vbs that allows you to read/write values for blocks.

# Using the Block Class

To read the value of `Block` use:

Block(index).name

To change the value of `Block` use:

Block(index).name \= value

# Block Properties

###### Physical Properties

| Type | Name | Read/Write | Description |
| --- | --- | --- | --- |
| double | `id` | \- | The ID is used to decide and tie in its graphics, behavior, and behaviour flags. You can change this value to change the block into another |
| double | `x` | \- | The x coordinate of the NPC in scene coordinates. |
| double | `y` | \- | The y coordinate of the NPC in scene coordinates. |
| double | `width` | \- | The width of the block's hitbox. |
| double | `height` | \- | The height of the block's hitbox. |
| double | `xsp` | \- | The horizontal speed of the block. Negative values cause leftwards movement, positive values cause rightwards movement. |
| double | `ysp` | \- | The vertical speed of the NPC. Negative values cause upwards movement, positive values cause downwards movement. |
| double | `state` | \- | The current state of the block. Setting this to 1 will hit the block; anything else will break it.
<table class="wikitable notice-note" cellpadding="10"><tbody><tr><td><span typeof="mw:File"><span title="Notice"><img alt="Notice" src="/wiki/images/a/a4/22px-Appunti_architetto_franc_01.png" decoding="async" width="22" height="28" class="mw-file-element"></span></span> <b>Note:</b> Breaking the block, whether through normal means or by code, does not affect the hide variable.</td></tr></tbody></table>

 |
| double | `hide` | \- | Whether the block is hidden or not.

<table class="wikitable notice-note" cellpadding="10"><tbody><tr><td><span typeof="mw:File"><span title="Notice"><img alt="Notice" src="/wiki/images/a/a4/22px-Appunti_architetto_franc_01.png" decoding="async" width="22" height="28" class="mw-file-element"></span></span> <b>Note:</b> This does not function the same way as destroying blocks.</td></tr></tbody></table>

 |
| double | `pcollision` | Read Only | The type of collision a player will have with the block, determined by block settings. |
| double | `ncollision` | Read Only | The type of collision an NPC will have with the block, determined by block settings. |

###### Graphical Properties

| Type | Name | Read/Write | Description |
| --- | --- | --- | --- |
| double | `extx` | \- | This values chooses the alternative GFX x position starting from 0. Setting this value to -1 makes the block invisible. |
| double | `exty` | \- | This values chooses the alternative GFX y position starting from 0. Setting this value to -1 makes the block invisible. |
| double | `forecolor` | \- | An overlay hue added to the block. Setting this value to 0 makes the NPC invisible, setting it to -1 returns it to default. Use the `rgba(red, green, blue, alpha)` function to choose a specific hue. |
| double | `forecolor_r` | \- | The red value of the hue described in 'forecolor'. Should be a value between 0 to 255. Use this value to read and get only the red component. |
| double | `forecolor_g` | \- | The green value of the hue described in 'forecolor'. Should be a value between 0 to 255. Use this value to read and get only the green component. |
| double | `forecolor_b` | \- | The blue value of the hue described in 'forecolor'. Should be a value between 0 to 255. Use this value to read and get only the bluecomponent. |
| double | `forecolor_a` | \- | The alpha value of the hue described in 'forecolor'. Should be a value between 0 to 255. Use this value to read and get only the alpha component. |

###### Behavioral Properties

| Type | Name | Read/Write | Description |
| --- | --- | --- | --- |
| double | `advset` | \- | The contents of the block. [Here is a list of block contents.](#Block_Contents) |
| double | `haswing` | \- | A set of values pertaining to what kind of wings the block has. [Here is a list of different wing behaviors.](#Wing_Behavior) |

###### Block Events

| Type | Name | Read/Write | Description |
| --- | --- | --- | --- |
| string | `deathevent` | \- | The block will trigger the event/script when the block is destroyed. |
| string | `hitevent` | \- | The block will trigger the event/script every time the block is hit. |
| string | `onscreenevent` | \- | The block will trigger the event/script every frame the block is onscreen. |
| string | `layerclearedevent` | \- | When the block gets destroyed while being the last object in the layer, it will trigger the event/script defined. |

###### Other

| Type | Name | Read/Write | Description |
| --- | --- | --- | --- |
| string | `name` | \- | An arbitrary string you can attach to the block. |

###### Unknown

| Type | Name | Read/Write | Description |
| --- | --- | --- | --- |
| double | `prx` | \- | Unknown |
| double | `pry` | \- | Unknown |
| double | `stimer` | \- | Unknown |

###### Unusable

| Type | Name | Read/Write | Description |
| --- | --- | --- | --- |
| unusable | `scriptid` | ? | Unknown effect. Returns a "Too few/many arguments for function." script error. |

# Constants

Here is a list of constants used by the block class.

###### Block Contents

| ID | Behavior |
| --- | --- |
| 0 | Empty |
| 1 to 99 | Coins (i.e. 15 will contain 15 coins) |
| \-1 to -302 | Contains varying number of coins |
| under -302 | Empty (will transform on hit) |
| 1XXX | NPC ID contained in the block. (i.e. 1031 contains NPC ID 31 (a key.) |

  

###### Wing Behavior

| ID | Behavior |
| --- | --- |
| 0 | None |
| 1 | Hover Left/Right |
| 2 | Hover Up/Down |
| 3 | Hover Forward |
| 4 | Controlled by NPC-308 |
| 5 | SMW Lines |

  

# Oddities and Quirks

Below is a list of certain quirks certain blocks have that does not conform to standard behavior or simply other miscellaneous behavior.
