# Char (TeaScript)

> 来源: <https://wohlsoft.ru/pgewiki/Char_(TeaScript)>

---

Char is a class in TeaScript.vbs that allows you to read/write values for the player.

  

# Using the Char Class

To read the value of `Char` use:

Char(index).name

To change the value of `Char` use:

Char(index).name \= value

`index` stands for the player (1: player 1; 2: player 2). Cloned characters by cheat codes aren't indexed.

# Char Properties

###### Physical Properties

| Type | Name | Read/Write | Description |
| --- | --- | --- | --- |
| byte | `id` | \- | The ID is used to decide and tie in its graphics, behavior, and other player properties. You can change this value to change the character |
| double | `x` | \- | The x coordinate of the player in scene coordinates. |
| double | `y` | \- | The y coordinate of the player in scene coordinates. |
| double | `pwidth` | \- | The width of the player's hitbox. |
| double | `pheight` | \- | The height of the player's hitbox. |
| single | `xsp` | \- | The horizontal speed of the player. Negative values cause leftwards movement, positive values cause rightwards movement. |
| single | `ysp` | \- | The vertical speed of the player. Negative values cause upwards movement, positive values cause downwards movement. Note, the player's gravity is 0.4 (0.36 for Luigi). |

###### Graphical Properties

| Type | Name | Read/Write | Description |
| --- | --- | --- | --- |
| integer | `brightness` | \- | The radius in pixels of light made when the lighting system is enabled. Setting this to 0 or less will cause the player to not emit light. This also represents the radius of visibility around the player when inside the boundaries of a block with NSMB Fake Wall enabled, which works with both the lighting system enabled or disabled. |
| long | `forecolor` | \- | An overlay hue added to the player. Setting this value to 0 makes the player invisible, setting it to -1 returns it to default. Use the `rgba(red, green, blue, alpha)` function to choose a specific hue. |
| byte | `forecolor_r` | \- | The red value of the hue described in 'forecolor'. Should be a value between 0 to 255. Use this value to read and get only the red component. |
| byte | `forecolor_g` | \- | The green value of the hue described in 'forecolor'. Should be a value between 0 to 255. Use this value to read and get only the green component. |
| byte | `forecolor_b` | \- | The blue value of the hue described in 'forecolor'. Should be a value between 0 to 255. Use this value to read and get only the blue component. |
| byte | `forecolor_a` | \- | The alpha value of the hue described in 'forecolor'. Should be a value between 0 to 255. Use this value to read and get only the alpha component. |

###### Behavioral Properties

| Type | Name | Read/Write | Description |
| --- | --- | --- | --- |
| byte | `facing` | \- | The direction the player is facing (1: Left; 0: Right). Note: can be temporarily overridden using a spin jump. |
| byte | `alive` | \- | Determines whether the player is alive or not. Forcing this value to 1 will kill the player. |
| byte | `nomove` | \- | Disables player controls if set to 1. Works differently from the keyboard lock in events. |
| byte | `stand` | Read Only | Determines if the player is standing (1: yes, 0: no). |
| byte | `sjumping` | Read Only | Determines whether the player is spin jumping (1: yes, 0: no). |
| byte | `sliding` | Read Only | Determines whether the player is sliding (1: yes, 0: no). |
| byte | `pulling` | Read Only | Determines whether the player is grabbing an NPC from above/grabbing diggable block (1: yes, 0: no). |
| byte | `climbing` | Read Only | Determines if the player is climbing (1: yes, 0: no). |
| byte | `walljumptimer` | Read Only | Determines whether the player is sliding against a wall, if wall jumping is enabled (1: yes, 0: no). |
| byte | `warping` | Read Only | Determines if the player is in the warp animation (1: yes, 0: no). |
| byte | `inwater` | Read Only | Determines if the player is in water swimming (1: yes, 0: no). |
| integer | `grabbing` | Read Only | Returns the NPC PermID the player is holding. |
| integer | `icetimer` | Read Only | The timer that determines how long the player is frozen for. |

###### Powerup/HUD Properties

| Type | Name | Read/Write | Description |
| --- | --- | --- | --- |
| byte | `status` | \- | The current power-up of the player. List of constants are [here](#Status) |
| integer | `itemslot` | \- | The current mount or transformation of the player. List of constants are [here](#Item_Slot) |
| integer | `itemrsrv` | \- | This is the value of the NPC ID in the player's reserve box. Use 0 to empty the reserve box. Unused with Toad, Peach, and Link. Setting an invalid ID crashed the game. |
| integer | `hitpoint` | \- | The amount of hearts the player has. Only used with Toad, Peach, and Link. Note: if you set the amount of hearts more than 3 or less than 0, the game will still remember that value, and setting this less than 0 does not kill the player. |
| integer | `bombcnt` | \- | The number of bombs the player has stored from Link's sword attack. Can be used to force the counter to show up for the other players, but only Link can use the bombs. If set to a negative number, the game will save that number and the player needs to collect more bombs until it reaches 0. |
| integer | `keycnt` | \- | The number of keys the player currently has stored. If set to a negative number, Link cannot collect a key through a sword attack anymore. (NOTE: Number of keys are not displayed in the default HUD, as Link can only store a single key with his sword attack. Having more than one key stored is still possible, however, and any player can use a stored key. |
| integer | `fluddcap` | \- | The total amount of liquid F.L.U.D.D. has. Max is 1001 and minimum is 1. If set to anything less than 0, it is automatically sets to 0. If set to anything larger than 1000, it caps at 10000. 500 units are used per max F.L.U.D.D. use. |
| integer | `flytime` | \- | The flight timer for raccoon leaf, tanooki suit, and Yoshi's wings. This value is always forced to a high value if a P-Wing was used before entering the stage. |
| long | `invtime` | \- | The invincibility timer for a star. When the value is larger than 0, it decreases by one every frame, until it reaches 0. The timer will not move if set to a negative number. Note: collecting an invincibility star sets this value to 800. |
| integer | `weapon` | \- | The NPC ID that the player shoots as Fire, Hammer, Ice, and Penguin states. -1 is for no NPC, and 0 is for the default NPC. |
| integer | `ynpcid` | \- | Stands for the ID of the NPC that Yoshi has in its mouth. |

###### Other

| Type | Name | Read/Write | Description |
| --- | --- | --- | --- |
| byte | `section` | Read Only | Returns the section the player is on. |
| integer | `jmpchance` | \- | When the player is on the ground and releases both the jump and alt-jump keys, this value becomes 1. Otherwise, it remains at 0.
Furthermore, every time the player jumps out of a vehicle, it subtracts 1. Forcing this value to be higher than 2 enables the player to switch between a regular jump and a spin-jump (provided that the corresponding keys were pressed).

 |

###### Unusable

| Type | Name | Read/Write | Description |
| --- | --- | --- | --- |
| unusable | `scriptid` | ? | Unknown effect. Returns a "Too few/many arguments for function." script error. |

# Constants

Here is a list of constants used by the char class.

###### Direction

| ID | Facing |
| --- | --- |
| 0 | Right |
| 1 | Left |

###### Character

| ID | Character |
| --- | --- |
| 0 | Mario |
| 1 | Luigi |
| 2 | Peach |
| 3 | Toad |
| 4 | Link |

###### Status

| ID | Powerup |
| --- | --- |
| 1 | Small |
| 2 | Mushroom |
| 3 | Fire Flower |
| 4 | Leaf |
| 5 | Tanooki Suit |
| 6 | Hammer Suit |
| 7 | Ice Flower |
| 8 | Frog Suit |
| 9 | Blue Shell |
| 10 | Propeller Suit |
| 11 | Mini Mushroom |
| 12 | Penguin Suit |

###### Item Slot

| ID | Type |
| --- | --- |
| \-150 | Fairy |
| \-103 | Propeller Link Flying (Fairy) |
| \-102 | Link Shell Sliding (Fairy) |
| \-100 | Link Climbing (Fairy) |
| \-20 | Coin Box |
| \-19 | Cannon Box |
| \-18 | Propeller Box |
| \-17 | Spiny Helmet |
| \-16 | Goomba Hat |
| \-15 | Buzzy Helmet |
| \-14 | Invisible Mask |
| \-13 | Rocket F.L.U.D.D. |
| \-12 | Turbo F.L.U.D.D. |
| \-11 | Hover F.L.U.D.D. |
| \-10 to -6 | Makes the player invisible |
| \-5 | Mega Mushroom |
| \-4 | Clown Car |
| \-3 | Lakitu's Shoe |
| \-2 | Fire's Shoe |
| \-1 | Kuribo's Shoe |
| 0 | None |
| 1 | Green Yoshi |
| 2 | Blue Yoshi |
| 3 | Yellow Yoshi |
| 4 | Red Yoshi |
| 5 | Black Yoshi |
| 6 | Purple Yoshi |
| 7 | Pink Yoshi |
| 8 | Cyan Yoshi |

<table class="wikitable notice-warning" cellpadding="10"><tbody><tr><td><span class="mw-default-size" typeof="mw:File"><a href="/pgewiki/File:OOjs_UI_icon_notice-destructive.svg" class="mw-file-description"><img src="https://upload.wikimedia.org/wikipedia/commons/thumb/b/bf/OOjs_UI_icon_notice-destructive.svg/20px-OOjs_UI_icon_notice-destructive.svg.png" decoding="async" width="20" height="20" class="mw-file-element" srcset="https://upload.wikimedia.org/wikipedia/commons/thumb/b/bf/OOjs_UI_icon_notice-destructive.svg/40px-OOjs_UI_icon_notice-destructive.svg.png 1.5x"></a></span> <b>WARNING:</b> Setting an invalid number may crash the game.</td></tr></tbody></table>

# Oddities and Quirks

Below is a list of certain quirks players have that does not conform to standard behavior or simply other miscellaneous behavior.

-   If the brightness of a player is set to a negative number, the lighting will be in the top-left corner of the screen and will remain there when the screen is scrolling. The purpose is still unknown.
