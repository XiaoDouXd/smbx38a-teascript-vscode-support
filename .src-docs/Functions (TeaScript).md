# Functions (TeaScript)

> 来源: <https://wohlsoft.ru/pgewiki/Functions_(TeaScript)>

---

The following page contains all TeaScript functions. [Click here](https://wohlsoft.ru/pgewiki/Category:TeaScript.vbs) to return to the [Category: Teascript](https://wohlsoft.ru/pgewiki/Category:TeaScript.vbs) page.

## AudioSet

This function allows you to play sound effects, or play/stop music. This function can be called through both level scripts and global/map scripts.

  
To load a sound effect:

call AudioSet(1, ID, Advanced, Filepath)

| Parameters | Description |
| --- | --- |
| ID | Sound effect ID can range from 0 to 1024.
IDs from 1 to 92 replace default sound effects.

 |
| Advanced | Whether only one 'copy' of this sound effect can be played in the same time. |
| Filepath | The filename of the sound file. The sound file must be in the world map folder. |

  
To play a sound effect:

call AudioSet(2, ID, Loop, "")

| Parameters | Description |
| --- | --- |
| ID | Sound effect ID can range from 0 to 1024.
<table class="wikitable notice-note" cellpadding="10"><tbody><tr><td><span typeof="mw:File"><span title="Notice"><img alt="Notice" src="/wiki/images/a/a4/22px-Appunti_architetto_franc_01.png" decoding="async" width="22" height="28" class="mw-file-element"></span></span> <b>Note:</b> Custom sound effects must be loaded using the first function of Audioset.</td></tr></tbody></table>

 |
| Loop | Whether the sound loops or not. |

  
To stop a sound effect:

call AudioSet(3, ID, 0, "")

| Parameters | Description |
| --- | --- |
| ID | The ID of the sound effect. Can be between 0-1024. |

  

To Change a specific sound volume:

call AudioSet(5, ID, Volume, "")

| Parameters | Description |
| --- | --- |
| ID | The ID of the sound effect. Can be between 0-1024 |
| Volume | Can be between 0-100. |

  
To play music:

call AudioSet(11, FadeIn, 0, Filepath)

| Parameters | Description |
| --- | --- |
| FadeIn | The duration of the fade-in effect in milliseconds. |
| FilePath | The filename of the music file. The sound file must be in the world map folder. |

  
To stop music:

call AudioSet(12, FadeOut, 0, "")

| Parameters | Description |
| --- | --- |
| FadeOut | The duration of the fade-out effect in milliseconds. |

  

## BErase

Erases a bitmap, iterator, or text object when called.

**Note: If you only want to temporarily hide the object, modify the object's hide property instead of using this function.**

call BErase(type, id)

<table class="wikitable"><caption></caption><tbody><tr><th>Parameters</th><th>Description</th></tr><tr><td>type</td><td>The object type to be erased.<p>0 = Iterator</p><p>1 = Text</p><p>2 = Bitmap</p><p>3 = Block</p></td></tr><tr><td>ID</td><td>The ID of the object to be destroyed. The function will do nothing if the object is not found.</td></tr></tbody></table>

  

## BmpCreate

This function can create a highly customizable bitmap object, but needs an NPC as the bitmap's source.

**Use this function with caution! Performance issues may occur if too many bitmaps are created at once, and the game may crash if sx, sy, sw, and/or sh, are invalid.**

call bmpcreate(id, picid, useScreenCoords, isVisible, sx, sy, sw, sh, destx, desty, stretchx, stretchy, centerx, centery, angle, color)

<table class="wikitable"><caption></caption><tbody><tr><th>Parameters</th><th>Description</th></tr><tr><td>ID</td><td>The ID slot to be used for the bitmap being created. If another bitmap is reserved for the ID specified, nothing will happen.</td></tr><tr><td>picID</td><td>The ID of the NPC to use as the bitmap source.</td></tr><tr><td>useScreenCoords</td><td>Determines how the bitmap will be oriented.<p>0 = Bitmap's coordinates will be relevant to the level's coordinate system.</p><p>1 = Bitmap's coordinates will be relevant to the top left corner of the screen, and will move accordingly with the screen.</p></td></tr><tr><td>isVisible</td><td>If set to 0, the bitmap will be hidden upon creation. If set to 1, it will be visible.</td></tr><tr><td>sx</td><td>The x coordinate of the top-left point of the sprite in the bitmap's source file.</td></tr><tr><td>sy</td><td>The y coordinate of the top-left point of the sprite in the bitmap's source file.</td></tr><tr><td>sw</td><td>The width of the cropped bitmap.</td></tr><tr><td>sh</td><td>The height of the cropped bitmap.</td></tr><tr><td>destx</td><td>The x coordinate of where the bitmap will be drawn.</td></tr><tr><td>desty</td><td>The y coordinate of where the bitmap will be drawn.</td></tr><tr><td>stretchx</td><td>The bitmap's x-axis stretch ratio. Set to 1 for no stretching.</td></tr><tr><td>stretchy</td><td>The bitmap's y-axis stretch ratio. Set to 1 for no stretching.</td></tr><tr><td>centerx</td><td>The x coordinate of the bitmap's hotspot/centerpoint used for stretching and rotation.</td></tr><tr><td>centery</td><td>The y coordinate of the bitmap's hotspot/centerpoint used for stretching and rotation.</td></tr><tr><td>angle</td><td>The rotation angle of the bitmap in degrees.</td></tr><tr><td>color</td><td>The forecolor of the object. Set to -1 if you don't want to use forecolor.</td></tr></tbody></table>

## BSet

This function is used to modify object configuration flags. The usage of this function is so complex it needs its own page, [BSet (TeaScript)](https://wohlsoft.ru/pgewiki/BSet_(TeaScript)).

## EXEScript

This function is used to execute a script. When this function is called, the given script will immediately be executed and the original script will be halted until the execution of the given script completes. This can be used to call world map/global scripts. This function can be called through both level scripts and global/map scripts.

call EXEScript(ScriptName)

| Parameters | Description |
| --- | --- |
| ScriptName | The script that should be executed. |

  

## Debug

This function will output a string to the debug box. It will only work in the editor, and will not do anything in game mode. It is recommended to delete these functions after debugging for better performance. You can find the debug box by opening the debug menu and double clicking the object count.

call Debug(String)

| Parameters | Description |
| --- | --- |
| String | The string that should be outputted. |

  

## FXCreate

This function is used to create an effect.

call FXCreate(ID, X, Y, Xsp, Ysp, Frames, AnimationSpeed, Const, Gravity, Advanced)

| Parameters | Description |
| --- | --- |
| ID | The effect-ID of the effect to create. |
| X | The X-scene coordinate where the effect will be created. |
| Y | The Y-scene coordinate where the effect will be created. |
| Xsp | The X-speed of the effect. |
| Ysp | The Y-speed of the effect. |
| Frames | The number of frames the effect should last. |
| AnimationSpeed | The number of frames each animation frame will last. |
| Const | The sprite set to use (i.e. setting value to 1 for effect-77 uses Luigi's fireball colors) |
| Gravity | Should the effect be affected by gravity?
-   0: Yes
-   1: No

 |
| Advanced | Advanced value for the effect. Used in effect-77 (fireball's particles) and effect-79 (score). |

  

## HUDSet

This function allows you to draw your own HUD. The function serves different purposes with the first parameter. Remember the HUD must must be initialized before adding any text or bitmaps.

  
To erase previous HUD data and initialize the HUD system:

call HUDSet("initialize", 0, 0, 0, 0, 0, 0, 0, 0, 0)

To disable the custom HUD system and erase all the previous custom HUD data.

call HUDSet("destroy", 0, 0, 0, 0, 0, 0, 0, 0, 0)

To add a bitmap to the HUD:

call HUDSet("bitmap", ID, XSource, YSource, Width, Heigth, X, Y, Advanced, Color)

The image source must be in a file called 'scflash.png'.

| Parameters | Description |
| --- | --- |
| ID | The ID used to identify the HUD bitmap (shares ID with non-HUD bitmaps). |
| XSource | The X-position of the top-left point of the object in scflash.png. |
| YSource | The Y-position of the top-left point of the object in scflash.png. |
| Width | The width of the cropped bitmap. |
| Height | The height of the cropped bitmap. |
| X | The X-scene coordinate where the bitmap will be created. |
| Y | The Y-scene coordinate where the bitmap will be created. |
| Advanced | The advanced settings of the HUD bitmap.
-   1000+(the number of chosen NPC) shows the chosen NPC graphic.
-   5001 shows the NPC in player 1's item box.
-   5002 shows the NPC in player 2's item box.
-   6000 to 6002 shows the bitmap if the starcoin with that ID is acquired.

 |
| Color | A certain color. The default value is -1 and type 0 to make the bitmap completely transparent. |

  
To add text to the HUD:

call HUDSet("text", ID, X, Y, StartASCII, EndASCII, RowASCII, NPCID, Color, \-1)

| Parameters | Description |
| --- | --- |
| ID | The ID of the text. The function will create a new text if the ID is unused, otherwise it will overwrite the existing text. |
| X | The x position of the text. |
| Y | The y position of the text. |
| StartASCII | The starting character code of the font. |
| EndASCII | The last character code of the font. |
| RowASCII | The number of characters in a row of the font image. |
| NPCID | The ID of the NPC ID that contains the font used. |
| Color | A certain color. The default value is -1 and type 0 to make the text completely transparent. |

## ItrCreate

Creates an iterator. This iterator can let you cycle between objects in a given rectangular area.

dim ItrID as integer \= itrCreate(type, ID, x, y, w, h)

| Parameters | Description |
| --- | --- |
| type | 
-   1: Blocks
-   2: NPCs
-   3: BGOs
-   4: Liquids
-   5: Warps
-   6: Effects
-   11: Blocks (onscreen only)
-   12: NPCs (active only)

 |
| ID | The ID filter of the iterator. Set this to 0 to disable ID filtering.

If `Type` is `Liquids`, then use the [Liquids](https://wohlsoft.ru/pgewiki/Liquid_(TeaScript)#Types_of_liquids) table to filter a type.

If `Type` is `Warps`, then use the [Warps](https://wohlsoft.ru/pgewiki/Warp_(TeaScript)#Types_of_warps) table to filter a type.

For all other types, this value stands for the image-file ID (E.g: use `10` for `block-10`)  

 |
| `X` | Stands for the x-position of the top left corner of the iterator. The iterator only will iterate through objects within the defined rectangular region |
| `Y` | Stands for the y-position of the top left corner of the of the iterator. |
| `W` | Stands for the width of the iterator. |
| `H` | Stands for the height of the iterator. |

  

## ItrNext

Continues through an iterator that was created prior. Returns the index (permanent ID) of the found object. Use this index in classes, for example `NPC(index)` or `Block(index)`. If the iterator is finished, this function returns 0.

**You must destroy the iterator with BErase(0, ITERATOR\_ID) or else the iterators won't work anymore until you restart the game.**

If the game does not crash but iterators stop working, it means you have an iterator leak because you forgot to berase an iterator after its usage (it occurs when more than 128 iterators exists simultaneously)

dim index as integer \= itrNext(ID)

' Assuming the iterator in a block iterator
with block(index)
  call Debug(.id) 'You can apply code to every object in the iterator like this!
end with

' How to cycle through all objects
dim iD as integer
dim iN as integer

iD \= itrCreate(type, ID, x, y, w, h)
do
  iN \= itrNext(iD)
  if iN \= 0 then exit do
  ' Here you can execute code to every object
loop
call BErase(0, iD) ' Dont forget to BErase, its very important

| Parameters | Description |
| --- | --- |
| ID | The ID of the iterator. This is given to you via `ItrCreate` |

  

## KeyPress

This function returns the user input data. This can be used to check a keyboard key, mouse cursor, and player keys being held.

if KeyPress(ID) then

Example of using 'keypress' to detect a single key press, which triggers only on the initial key press and resets when the player releases the key:

dim upKey as integer  ' Stores the key state of the 'Up' key
do
  if upKey \= 0 and keypress(\-14) then
    call showmsg("Up pressed!")
  end 
  upKey \= keypress(\-14)
  call sleep(1)
loop

| Parameters | Description |
| --- | --- |
| ID | The ID of the input.
[Check this chart for a list of IDs](https://i.imgur.com/VQ0kyjC.png)

 |

## LMove

This function is used to move layers.

call LMove(LayerName, Xsp, Ysp, Type)

| Parameters | Description |
| --- | --- |
| LayerName | The name of the layer that you want to move. |
| Xsp | The X-distance speed the layer should move. (Xsp is difference between original and destination (i.e. value is 32, layer is moved 32 pixels from original coordinate) coordinates if shift movement was used) |
| Ysp | The Y-distance speed the layer should move. (Ysp is difference between original and destination (i.e. value is 32, layer is moved 32 pixels from original coordinate) coordinates if shift movement was used) |
| Type | The type of movement that the layer should use.
-   0: Use speed movement. (The layer will move with the given direction)
-   1: Use shift movement. (The layer will warp with the given direction)

 |

  

## LSet

This function is used to change the visibility of a layer. This function can be called through both level scripts and global/map scripts.

  
To Show/Hide/Toggle a layer:

call LSet(LayerName, Type, Smoke)

| Parameters | Description |
| --- | --- |
| LayerName | The name of the layer that you want to change. |
| Type | The type of layer visibility.
-   1: Show
-   2: Hide
-   3: Toggle

 |
| Smoke | Should there be smoke?

-   0: Yes
-   1: No

 |

  
To change the alpha value of a layer:

call LSet(LayerName, 38, AlphaValue)

| Parameters | Description |
| --- | --- |
| LayerName | The name of the layer that you want to change. |
| Alpha Value | The alpha value of the layer. This value must be between 0-255. |

## LSpin

This function is used to rotate layers. This function only affect NPCs and Blocks. This function can be called through both level scripts and global/map scripts.

call LSpin(LayerName, Xcenter, Ycenter, Speed)

| Parameters | Description |
| --- | --- |
| LayerName | The name of the layer that you want to spin. |
| Xcenter | The X-scene coordinate of the center of the circle. |
| Ycenter | The Y-scene coordinate of the center of the circle. |
| Speed | The spin speed. Positive values spin counterclockwise and negative values spin clockwise. |

  

## NCreate

This function is used to spawn an NPC. The function returns the permanent id of the spawned NPC.

call NCreate(ID, X, Y, Xsp, Ysp, Advset, CreationData)

'If you want the permanent id of the spawned NPC, do:
dim NPCpermID as integer \= NCreate(ID, X, Y, Xsp, Ysp, Advset, CreationData)

Note that the spawned NPC becomes active until the next frame.

| Parameters | Description |
| --- | --- |
| ID | The NPC-ID that should be spawned. |
| X | The X-coordinate of the spawned NPC. |
| Y | The Y-coordinate of the spawned NPC. |
| Xsp | The X-Speed of the spawned NPC. |
| Ysp | The Y-Speed of the spawned NPC. |
| Advset | The "advset" field of the spawned NPC. |
| CreationData | The way the NPC will be created:
-   1 = Projectile, Angle 270 🡹
-   2 = Projectile, Angle 180 🡸
-   3 = Projectile, Angle 90 🡻
-   4 = Projectile, Angle 0 🡺
-   5 = Warp, Angle 270 🡹
-   6 = Warp, Angle 180 🡸
-   7 = Warp, Angle 90 🡻
-   8 = Warp, Angle 0 🡺
-   9 = Projectile, Angle 225 🡼
-   10 = Projectile, Angle 135 🡿
-   11 = Projectile, Angle 45 🡾
-   12 = Projectile, Angle 315 🡽
-   17 = Projectile, Angle 270 🡹, No smoke
-   18 = Projectile, Angle 180 🡸, No smoke
-   19 = Projectile, Angle 90 🡻, No smoke
-   20 = Projectile, Angle 0 🡺, No smoke
-   25 = Projectile, Angle 225 🡼, No smoke
-   26 = Projectile, Angle 135 🡿, No smoke
-   27 = Projectile, Angle 45 🡾, No smoke
-   28 = Projectile, Angle 315 🡽, No smoke
-   41, 43 = Right direction
-   44, 50, 7000, 7001 = Default (Layer)
-   45 = Default (Layer) & Facing (Right)
-   51 = Friendly mode
-   7002 = Destroyed Blocks (Layer)
-   7004 = None / New Layer (Layer)
-   9999 = Item Storage (Drop)

 |

  

## NCreateGroup

This function can create a group of NPCs when called. It works similarly to the NPC's HoldGenerator.

call ncreategroup(ID, X, Y, XOffset, YOffset, NPCcount, Angle, Range, Speed, Advanced)

| Parameters | Description |
| --- | --- |
| ID | The ID of the NPC to be created. |
| X | The X position of the spawn point. |
| Y | The Y position of the spawn point. |
| Xoffset | "The X-Offset of the generator this npc attached." |
| Yoffset | "The Y-Offset of the generator this npc attached." |
| NPCcount | The number of NPCs to be created. |
| Angle | The angle that the NPC will be created from. |
| Range | Distance between the group of NPCs. |
| Speed | Speed that the NPC will have, when created. |
| Advanced | The advanced value of each NPC. |

  

## NKill

This function will destroy an NPC when called if all parameters are met.

call NKill(index, rx, ry, rw, rh, id, effect, score)

<table class="wikitable"><caption></caption><tbody><tr><th>Parameters</th><th>Description</th></tr><tr><td>index</td><td>How the NPC is to be destroyed. If the value is greater than 0, the value will stand for the NPC's ID to be used.<p>0 = The function will delete the specified NPC.</p><p>-1 = The function will delete all NPCs touching a rectangular box.</p><p>-2 = The function will delete all NPCs that are completely enclosed in a rectangular box.</p></td></tr><tr><td>rx</td><td>The x-position of the rectangular box. If "index" is 0, use 0 here.</td></tr><tr><td>ry</td><td>The y-position of the rectangular box. If "index" is 0, use 0 here.</td></tr><tr><td>rw</td><td>The width of the rectangular box. If "index" is 0, use 0 here.</td></tr><tr><td>rh</td><td>The height of the rectangular box. If "index" is 0, use 0 here.</td></tr><tr><td>id</td><td>If "index" is -1 or -2, this parameter will stand for the ID of the NPCs to delete. Set this to 0 to delete all NPCs. If "index" is 0, use 0 here.</td></tr><tr><td>effect</td><td>Determines whether the NPC's death effect is used upon being destroyed. Set to 0 to disable effects, set to any other value to enable effects.</td></tr><tr><td>score</td><td>Determines whether the NPC's defined score is rewarded to the player. Set to 0 to disable scoring, set to any other value to enable scoring.</td></tr></tbody></table>

  

## PlayNote

This function is used to play midi notes.

call PlayNote(Command)

The first time this command is used, the game stutters for a few frames. It is recommended to use call `playNote(139)` at the beginning of the level to avoid any stutters.

| Parameters | Description |
| --- | --- |
| Command | The command can be:
-   To play a note
    -   Volume\*65536 + Flip\*256 + 192 + Channel
-   To stop a note
    -   Volume\*65536 + Flip\*256 +128 + Channel
-   To change the instrument
    -   Patch\*256 + 192 + Channel

Patch = ID of the instrument (0-127)

Volume = The volume of the note (0-100)

Flip = The pitch of the note (0-255)

Channel = The channel of the note (0-15) Default:0

 |

  

Here is a simplified way to play a note. [Use this chart to identify your instruments.](https://en.wikipedia.org/wiki/General_MIDI#Percussive)

dim instrument as integer \= 55  ' You must subtract 1 to the ID found in the wiki (For example, in the wiki orchestra hit is 56, but here you must use 55)
dim volume as integer \= 100
dim pitch as integer \= 50
dim channel as integer \= 1  ' MUST NOT BE 9
call playNote(instrument\*256 + 192 + channel)  ' This switches the instrument
call playNote(volume\*65536 + pitch\*256 + 144 + channel) ' This starts the note. NOTE: the note does not automatically stop. You must stop it manually.
call playNote(128 + channel) ' This stops the note.

  

Here is a simplified way to play a percussion note. [Use this chart to identify your instruments.](https://en.wikipedia.org/wiki/General_MIDI#Program_change_events)

dim instrument as integer \= 56 ' This is the ID as found in the wiki page. No need to modify the ID
dim volume as integer \= 100
call playNote(volume\*65536 + instrument \*256 + 144 + channel) ' NOTE: You cannot stop the note manually, this one stops automatically after its finished playing.

  

## Redim

This Function is used to initialize a local array.

Call Redim(type,name,size)

| Parameters | Description |
| --- | --- |
| Type | 0 = All Memory allocated to the array will be cleared. (Default)
1 = Resize array.

 |
| Name | Name of the local array to be started. |
| Size | Size of local array |

## ScriptID

Returns the Script ID.

val(a) \= scriptid(name)

| Parameters | Description |
| --- | --- |
| Name | The script that should return your ID. |

## SCSet

This function allows you to change or check the starcoin acquisition status.

  

To get a starcoin:

call SCSet(levelname, scID, 0)

<table class="wikitable"><caption></caption><tbody><tr><th>Parameters</th><th>Description</th></tr><tr><td>levelname</td><td>The filename of the level.</td></tr><tr><td>scID</td><td>The starcoin ID. The value is the same as Star Coin IDN in the advanced tab.</td></tr></tbody></table>

  

To check a starcoin acquisition status:

value \= SCSet(levelname, scID, 1)

<table class="wikitable"><caption></caption><tbody><tr><th>Parameters</th><th>Description</th></tr><tr><td>levelname</td><td>The filename of the level.</td></tr><tr><td>scID</td><td>The starcoin ID. The value is the same as Star Coin IDN in the advanced tab.</td></tr></tbody></table>

  

To clear a starcoin status:

call SCSet(levelname, scID, 4)

<table class="wikitable"><caption></caption><tbody><tr><th>Parameters</th><th>Description</th></tr><tr><td>levelname</td><td>The filename of the level.</td></tr><tr><td>scID</td><td>The starcoin ID. The value is the same as Star Coin IDN in the advanced tab.</td></tr></tbody></table>

  

To clear all starcoins status in a certain level:

call SCSet(levelname, 0, 5)

<table class="wikitable"><caption></caption><tbody><tr><th>Parameters</th><th>Description</th></tr><tr><td>levelname</td><td>The filename of the level.</td></tr></tbody></table>

## ShowMsg

This function shows a message using a message box. RGB, quake, break, and alpha message formats are supported. This function can be called through both level scripts and global/map scripts.

call ShowMsg(Message)

' How to use text markup:
' == Color ==
call showMsg("\\cHEXtext") ' \\cHEX changes the color of all the text afterward with HEX being the color wanted. \\cFF0000 will make the text red. You can have multiple colors per message like this: 
call showMsg("\\cFF0000RED! \\c00FF00 GREEN! \\c0000FF Blue!") 

' == Fade==
call showMsg("\\alphaTEXT") '\\alpha will make the all the text afterward fade in. You can make only a part of the text fade in by ending it with another '\\alpha'. Try this example to see how it works:
call showMsg("\\alphaHello, I am fading!\\alphaHello, I do not fade!\\alphaI will fade as a second group!")

' == Break ==
call showMsg("TEXT\\nTEXT")  '\\n it will break the line and the following text will continue to the next line like this:
call showMsg("Line 1\\nLine 2\\nLine 3")

' == Quake ==
call showMag("\\quakeTEXT") '\\quake will make all the text afterwards a "shake" effect. You can make only a group of text shake by ending it with another '\\quake' like this:
call showMsg("\\quakeHello, I am shaking\\quakeI am not shaking")

' How to concatenate strings:
dim player as string \= "Mario"
call showmsg("Hey there " & player & ", I hope you're having a fantastic day!)

| Parameters | Description |
| --- | --- |
| Message | The message that will be shown. It must be a string. |

  

## Sleep

This function is used to pause the script for a number of frames.

**Sleep only be used in scripts called through an event.**

call sleep(Delay)

| Parameters | Description |
| --- | --- |
| Delay | The number of frames the script should be paused. |

## SpEvent

This function is used to trigger special events.

call SpEvent(ID)

| Parameters | Description |
| --- | --- |
| ID | The ID of the special event. Can be seen by right clicking the special event menu.
| ID | Name |
| --- | --- |
| 0 | None |
| 1 | Hurts the player. |
| 2 | Kills the player. |
| 3 | Hides the HUD. |
| 4 | Shows the HUD. |
| 5 | Hurts player 1 in battle mode. |
| 6 | Hurts player 2 in battle mode. |
| 7 | Adds a Mushroom to the map inventory. |
| 8 | Adds a Fire Flower to the map inventory. |
| 9 | Adds a Super Leaf to the map inventory. |
| 10 | Adds a Tanooki Suit to the map inventory. |
| 11 | Adds a Hammer Suit to the map inventory. |
| 12 | Adds an Ice Flower to the map inventory. |
| 13 | Adds a Frog Suit to the map inventory. |
| 14 | Adds a Starman to the map inventory. |
| 15 | Adds a P-Wing to the map inventory. |
| 16 | Adds a Hammer to the map inventory. |
| 17 | Adds a Cloud to the map inventory. |
| 18 | Adds a Shell Suit to the map inventory. |
| 19 | Adds a Propeller Mushroom to the map inventory. |
| 20 | Adds a Mini Mushroom to the map inventory. |
| 21 | Adds a Penguin Suit to the map inventory. |
| 22 | Disables the player's reserve. |
| 23 | Enables the player's reserve. |
| 24 | Adds a Music Box to the map inventory. |
| 25 | Adds a Warp Whistle to the map inventory. |
| 26 | Adds an Anchor to the map inventory. |
| 27 | Enables Wall Jumping for every player. |
| 28 | Disables Wall Jumping for every player. |
| 29 | Switches the power up system to modern style. (Revert to Super if hit) |
| 30 | Switches the power up system to classic/SMB1 style. (Revert to small if hit) |
| 31 | Adds a Green Yoshi to the map inventory. |
| 32 | Adds a Blue Yoshi to the map inventory. |
| 33 | Adds a Yellow Yoshi to the map inventory. |
| 34 | Adds a Red Yoshi to the map inventory. |
| 35 | Adds a Black Yoshi to the map inventory. |
| 36 | Adds a Purple Yoshi to the map inventory. |
| 37 | Adds a Pink Yoshi to the map inventory. |
| 38 | Adds a Cyan Yoshi to the map inventory. |
| 39 | Creates a POW Block shake effect. |
| 40 | Creates a Sledge Bro. shake effect. |
| 41 | Enables freezing objects when powering up/down. |
| 42 | Disables freezing objects when powering up/down. |
| 43 | Enables the ability to fall slower in midair if the spinjump button is held. |
| 44 | Disables the ability to fall slower in midair if the spinjump button is held. |
| 45 | Enables Yoshi's flutter jump. |
| 46 | Disables Yoshi's flutter jump. |
| 47 | Enables Ground Pound for Mario/Luigi. |
| 48 | Disables Ground Pound for Mario/Luigi. |
| 49 | Flips the screen horizontally. |
| 50 | Reverts the horizontal screen flip. |
| 51 | Flips the screen vertically. |
| 52 | Reverts the vertical screen flip. |
| 53 | Enables transparent fading in the lighting system. |
| 54 | Disables transparent fading in the lighting system. |
| 55 | Creates a Thwomp shake effect. |
| 1045 | Toggles the Yellow Switch Blocks. |
| 1057 | Toggles the Blue Switch Blocks. |
| 1069 | Toggles the Green Switch Blocks. |
| 1073 | Toggles the Red Switch Blocks. |
| 1082 | Toggles Black Switch Block behavior. |
| 1089 | Starts Stopwatch effects. |
| 1090 | Ends Stopwatch effects. |
| 1095 | Starts P-Switch effects. |
| 1102 | Ends P-Switch effects. |
| 1115 | Starts player invincibility effect. |
| 1119 | Ends player invincibility effect. |
| 1126 | Removes F.L.U.D.D from the player. |
| 1135 | Sets the F.L.U.D.D usage timer to 0. |
| 1141 | Clears the player's reserve box. |
| 1148 | Reverts the player back to small/normal. |
| 2589 | Clears all onscreen enemies as if the player finished a level. |

 |

  

<table class="wikitable notice-note" cellpadding="10"><tbody><tr><td><span typeof="mw:File"><span title="Notice"><img alt="Notice" src="/wiki/images/a/a4/22px-Appunti_architetto_franc_01.png" decoding="async" width="22" height="28" class="mw-file-element"></span></span> <b>Note:</b> ID at 1045+ shows [DATA EXPUNGED] in the editor.</td></tr></tbody></table>

  

## SysShowInput

Will show a message box that has a text box. This textbox can be read and stored

call SysShowInput(Message, Title)

'If you want the written text, do:
dim input as string \= SysShowInput(Message, Title)

| Parameters | Description |
| --- | --- |
| Message | The message that is shown in the message. Must be a string |
| Title | The title that is shown in the message. Must be a string |

## SysShowMsg

Will show a message box with default options.

call SysShowMsg(Message, Type, Title)

'If you want the selected option, do:
dim optionID as integer \= SysShowMsg(Message, Type, Title)

| Parameters | Description |
| --- | --- |
| Message | The message that is shown in the message. Must be a string |
| Type | You can use this expression: `` `base+16*type` `` .
The base of the message box.

| Base | Options Available |
| --- | --- |
| 0 | "OK" |
| 1 | "OK" and "Cancel" |
| 2 | "Abort", "Retry", and "Cancel" |
| 3 | "Yes", "No", and "Cancel" |
| 4 | "Yes" and "No" |
| 5 | "Retry" and "Cancel" |
| 6 | "Cancel" , "Try Again", and "Continue" |

The type of the message box styles.

| Type | Options Available |
| --- | --- |
| 0 | None |
| 1 | Error Icon |
| 2 | Question Icon |
| 3 | Warning Icon |
| 4 | Information Icon |
| 5~7 | None, But have sound effects. |
| 8 | None, But window type is similar 1~4, and no any icons. |

This is the returned values when user pressed the buttons.

| Name | Value |
| --- | --- |
| OK | 1 |
| Cancel | 2 |
| Abort | 3 |
| Retry | 4 |
| Ignore | 5 |
| Yes | 6 |
| No | 7 |
| Try Again | 10 |
| Continue | 11 |

 |
| Title | The title that is shown in the message |

## TClear

This function clears and deletes timers, such as timers done for events.

call TClear(Type, EventName)

| Parameters | Description |
| --- | --- |
| Type | 
-   0: To clear a specific timer.
-   1: To clear all timers.

 |
| EventName | If type is 0, then set this to the name of the event to be cleared as a string. Otherwise, set this to 0. |

  

## TCreate

This function is used to call an event/create an event timer. This function can be called through both level scripts and global/map scripts.

call TCreate(EventName, Delay)

| Parameters | Description |
| --- | --- |
| EventName | The event that should be called as a string. |
| Delay | The number of frames until the event is called. |

  

## TCreateEx

This function is used to execute a script after the set delay and pass parameters to the said script.

call TCreateEx(ScriptName, Delay, Param1, Param2, Param3)

| Parameters | Description |
| --- | --- |
| ScriptName | The script that should be executed. |
| Delay | The number of frames until the script is executed. |
| Param1 | The value that should be passed to Sysval(Param1). |
| Param2 | The value that should be passed to Sysval(Param2). |
| Param3 | The value that should be passed to Sysval(Param3). |

  

## TxtCreate

This function is used to create a text object.

call TxtCreate(id, x, y, sasc, easc, cdata, lnum, fontid, flag, text)

| Parameters | Description |
| --- | --- |
| id | The unique identifier of the text. |
| x | x-position of the text. |
| y | y-position of the text. |
| sasc | the beginning ASCII code of the NPC image font. |
| easc | the last ASCII code of the NPC image font. |
| cdata | reserved.Type 0. |
| lnum | the number of characters of a single row in the NPC image file. |
| fontid | ID of the NPC used as the font.Use the numbers in the NPC image filename as the ID. |
| flag | 0: coordinates will be oriented to the scene. 1: coordinates will be oriented to the screen. |
| text | The text shown. |
