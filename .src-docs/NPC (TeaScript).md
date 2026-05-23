# NPC (TeaScript)

> 来源: <https://wohlsoft.ru/pgewiki/NPC_(TeaScript)>

---

NPC is a class in TeaScript.vbs that allows you to read/write values of NPCs.

  

## Spawning an NPC

To spawn an NPC you can use the `NCreate` function.

call NCreate(ID, X, Y, Xsp, Ysp, Advance, CreationData)

'If you want the permanent id of the spawned NPC, do:
dim NPCpermID as integer \= NCreate(ID, X, Y, Xsp, Ysp, Advset, CreationData)

'If you want the index of the NPC, do:
dim NPCIndex as integer \= getID(NPCpermID) ' Note that even though the function is called 'getID' it actually gets the index

For more information visit the [NCreate](https://wohlsoft.ru/pgewiki/Functions_(TeaScript)#NCreate) or [NCreateGroup](https://wohlsoft.ru/pgewiki/Functions_(TeaScript)#NCreateGroup) documentation

  

## Using the NPC Class

To read the value of `NPC` use:

NPC(index).name

To change the value of `NPC` use:

NPC(index).name \= value

  

## NPC Properties

###### Physical Properties

| Type | Name | Read/Write | Description |
| --- | --- | --- | --- |
| double | `id` | \- | The ID is used to decide and tie in its graphics, behavior, and NPC flags. You can change this value to change the NPC into another |
| double | `permid` | Read Only | A special number that can be used to uniquely identify the NPC. No two NPCs will have the same permID. |
| double | `x` | \- | The x position of the NPC in scene coordinates. |
| double | `y` | \- | The y position of the NPC in scene coordinates. |
| double | `width` | \- | The width of the NPC's hitbox. This value will also affect the GFX's width is autoscale is enabled for the NPC. |
| double | `height` | \- | The height of the NPC's hitbox. This value will also affect the GFX's height is autoscale is enabled for the NPC. |
| double | `xsp` | \- | The horizontal speed of the NPC. This value may not affect the NPC if the NPC flag 'parallel execution' is enabled. Negative values cause leftwards movement, positive values cause rightwards movement. |
| double | `ysp` | \- | The vertical speed of the NPC. This value may not affect the NPC if the NPC flag 'parallel execution' is enabled. Negative values cause upwards movement, positive values cause downwards movement. Note, if the NPC has gravity enabled, the speed of the gravity is calculated after a script. Default NPC gravity is 0.2599 |
| double | `prx` | \- | The x coordinate for the NPC's respawn point. This value is initialized to the coordinate in which it spawned. Layer movement will affect this value. |
| double | `pry` | \- | The y coordinate for the NPC's respawn point. This value is initialized to the coordinate in which it spawned. Layer movement will affect this value. |
| double | `addvx` | \- | The horizontal speed of the layer it is on. |
| double | `addvy` | \- | The vertical speed of the layer it is on. |
| double | `bkupx` | \- | The x coordinate in which the NPC spawned in. |
| double | `bkupy` | \- | The y coordinate in which the NPC spawned in. |

  

###### Graphical Properties

| Type | Name | Read/Write | Description |
| --- | --- | --- | --- |
| double | `curframe` | \- | The current frame of the NPC. The frame list begins counting at 1. Setting this value to 0 will make the NPC invisible. |
| double | `curtimer` | \- | The built-in timer used for delaying the next animation frame. The timer will increment every frame. If the value reaches the NPC flag 'framespeed' then the timer resets to 1 and the 'curframe' property is incremented. Setting this value to 0 disables the NPC from animating. Doesn't affect NPCs with a complex animation system. |
| double | `zpos` | \- | The priority value of the NPC. Must be a number between 0 and 1, where 0 is foreground and 1 is background. |
| double | `extx` | \- | Will only affect the NPC if the NPC flag 'GFXSplitHeight' is enabled. This values chooses the alternative GFX x position starting from 0. Setting this value to -1 makes the NPC invisible. |
| double | `exty` | \- | Will only affect the NPC if the NPC flag 'GFXSplitHeight' is enabled. This values chooses the alternative GFX y position starting from 0. Setting this value to -1 makes the NPC invisible. |
| double | `forecolor` | \- | An overlay hue added to the NPC. Setting this value to 0 makes the NPC invisible, setting it to -1 returns it to default. Use the `rgba(red, green, blue, alpha)` function to choose a specific hue. |
| double | `forecolor_r` | \- | The red value of the hue described in 'forecolor'. Should be a value between 0 to 255. Use this value to read and get only the red component. |
| double | `forecolor_g` | \- | The green value of the hue described in 'forecolor'. Should be a value between 0 to 255. Use this value to read and get only the green component. |
| double | `forecolor_b` | \- | The blue value of the hue described in 'forecolor'. Should be a value between 0 to 255. Use this value to read and get only the blue component. |
| double | `forecolor_a` | \- | The alpha value of the hue described in 'forecolor'. Should be a value between 0 to 255. Use this value to read and get only the alpha component. |

###### Behavior Properties

| Type | Name | Read/Write | Description |
| --- | --- | --- | --- |
| double | `facing` | \- | The direction the NPC is facing (0: right, 1:left). You can use this value to force the NPC to face a certain direction. NPCs that use alternative directions (Firebars, Roto-Discs, SMW platforms, etc.) instead use their respective behavior. |
| double | `friendly` | \- | When an NPC is friendly, it can't be interacted with and no longer hurts the player. Disables spawning behavior on NPCs that spawn other NPCs (hammer bros, rinka blocks). NPCs that explode still hurt the player upon explosion. |
| double | `nomove` | \- | When enabled, the NPC no longer moves on the horizontal axis. Can still be moved by external forces such as moving blocks, other NPCs, and liquids. |
| double | `health` | \- | The amount of health the NPC has remaining. Make sure to edit the 'resistance' NPC flags to control how much damage an NPC takes when taking damage. This value can bypass its maximum value defined in the NPC flags. |
| double | `alive` | \- | If the NPC is alive. Setting this value to 0 may kill the NPC with varying results. |
| double | `extset` | \- | The contained NPC ID used by container NPCs (such as SMW Lakitu, Bubbles, SMW Block, and buried grass. |
| double | `advset` | \- | The advset value of the NPC. Different NPCs use this value to change aspects of their behavior. You can find these in the editor in the advanced section of NPC settings. Not all NPCs use advset. An example that uses advset are: Koopas-Paratroopas, Thwomps, and Venus Fire Traps. Some NPCs (primarily projectiles) still use advset even if the editor says 'Advanced Value of this NPC: 0'. |
| double | `haswing` | \- | The type of wing behavior. [Here is a list of different wing behaviors.](#Wing_Behavior) |
| double | `target` | \- | The player the NPC is targeting. Return 1 for player 1, returns 2 for player 2. If player 1 is dead, player 2 is considered player 1 until player 2 respanws. The supermario# clone cheats don't have an effect on this value. Setting this value has varying results, but typically does not have any major effects. |
| double | `ivala`
`ivalb`

`ivalc`

 | \- | Individual values for each NPC. These values allow you to read/write specific aspects of their behavior. [More info here.](https://wohlsoft.ru/forum/viewtopic.php?f=66&t=3191) |
| double | `stand` | \- | Whether the NPC is standing. This includes blocks, slopes and standing in other NPCs. Setting this to -1 forces the NPC to behave as if it's on the ground, even if the NPC is in the air. Forcing it to 0 has some varying effects. |
| double | `inwater` | Read Only | Whether the NPC is colliding with a water liquid. This does not detect other liquids such as quicksand. |
| double | `scount` | Read Only | This property counts how many NPCs are colliding with the current one, only if it has the same id type.

<table class="wikitable notice-warning" cellpadding="10"><tbody><tr><td><span class="mw-default-size" typeof="mw:File"><a href="/pgewiki/File:OOjs_UI_icon_notice-destructive.svg" class="mw-file-description"><img src="https://upload.wikimedia.org/wikipedia/commons/thumb/b/bf/OOjs_UI_icon_notice-destructive.svg/20px-OOjs_UI_icon_notice-destructive.svg.png" decoding="async" width="20" height="20" class="mw-file-element" srcset="https://upload.wikimedia.org/wikipedia/commons/thumb/b/bf/OOjs_UI_icon_notice-destructive.svg/40px-OOjs_UI_icon_notice-destructive.svg.png 1.5x"></a></span> <b>WARNING:</b> No longer works in 1.4.5.</td></tr></tbody></table>

 |

###### NPC Events

| Type | Name | Read/Write | Description |
| --- | --- | --- | --- |
| string | `deathevent` | \- | When the NPC dies, it will call the event/script defined. |
| string | `activeevent` | \- | When the NPC appears on-screen for the first time, or only after respawning, it will call the event/script defined. |
| string | `talkevent` | \- | When a player talks to the NPC, it will call the event/script defined. |
| string | `grabedevent` | \- | When a player grabs the NPC, it will call the event/script defined.
<table class="wikitable notice-note" cellpadding="10"><tbody><tr><td><span typeof="mw:File"><span title="Notice"><img alt="Notice" src="/wiki/images/a/a4/22px-Appunti_architetto_franc_01.png" decoding="async" width="22" height="28" class="mw-file-element"></span></span> <b>Note:</b> The name grabedevent is not a typo</td></tr></tbody></table>

 |
| string | `layerclearedevent` | \- | When the NPC dies while being the last object in the later, it will trigger the event/script defined. |
| string | `nextframeevent` | \- | The NPC will trigger the event/script defined every frame the NPC is active. |
| string | `touchevent` | \- | When a player touches the NPC, it will call the event/script defined. The event/script is called every frame the NPC is touched. |

  

###### Other

| Type | Name | Read/Write | Description |
| --- | --- | --- | --- |
| string | `name` | \- | An arbritary string you can attach to the NPC. Can be used in conjuction with `getIDByName()` function. |
| double | `hide` | \- | If the NPC is in a hidden layer. Setting this value will hide the NPC making it invisible and intangible. Will no longer run its NPC script when hidden. |
| double | `dtcself` | \- | If enabled, the NPC will no longer collide with any other NPCs. |
| double | `dtcplayer` | \- | If enabled, the player can now passthrough the NPCs. Only has a noticable effect if the NPC has the NPC flags 'PlayerBlock' or 'PlayerBlockTop' enabled. The NPC still behaves the same and can still hurt the player. |
| double | `dtcliquid` | \- | If enabled, the NPC will no longer interact with liquids. The NPC will behave like normal and ignore any acceleration and effect from any liquid. |
| double | `stimer` | \- | If set to a positive number, it will count down every frame until it reaches 0. Has no effect on the NPC itself. You may use this variable to create timers within the NPC. |

###### Unknown

| Type | Name | Read/Write | Description |
| --- | --- | --- | --- |
| double | `langle` | \- | Unknown |

## Constants

Here are a list of constants used by the NPC class.

###### Direction

| ID | Facing |
| --- | --- |
| 0 | Right |
| 1 | Left |

  

###### Wing Behavior

| ID | Behavior |
| --- | --- |
| 0 | None |
| 1 | Jump |
| 2 | Hover Left/Right |
| 3 | Hover Up/Down |
| 4 | Chase |
| 5 | Hover Forward |
| 6 | Lakitu's AI |
| 7 | Controlled by NPC-308 |
| 8 | SMW Lines |

  

## Oddities and Quirks

Below is a list of certain quirks certain NPCs have that does not conform to standard behavior or simply other miscellaneous behavior.

-   Dry Bones and Bony Beetles will not run scripts when knocked over.
-   Wart, Mouser, Boom Boom, and Mother Brain gets stuck in their hit states when damaged if Parallel Execution is disabled.
-   Positions of plant based enemies that come out of the ground cannot be altered with x and y and instead must be altered with prx and pry.
-   Enemies that come out of the ground/wall/ceiling (i.e. Piranha Plants and Sumo Bros. fire) won't come out of the ground with Parallel Execution disabled due to their position coming out of the ground being dependent on the ivals.
-   Birdo and Larry cycle through all of their animation frames if Parallel Execution is disabled.
-   Wart, Mouser, Ludwig, and Bros. Enemies (excluding Sumo Bros.) always face the player even with Parallel Execution disabled.
-   Ludwig is stuck on his first fire breathing frame when Parallel Execution is disabled.
-   Bubbles still pop when colliding with objects and won't animate if Parallel Execution is disabled.
