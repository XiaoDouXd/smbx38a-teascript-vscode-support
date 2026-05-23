# Sysval (TeaScript)

> 来源: <https://wohlsoft.ru/pgewiki/Sysval_(TeaScript)>

---

Sysval is a special function in TeaScript that allows you to read and write system variables.

# Using the Sysval Class

To read the value of `sysval` use:

sysval(name)

To change the value of `sysval` use:

sysval(name) \= value

<table class="wikitable notice-note" cellpadding="10"><tbody><tr><td><span typeof="mw:File"><span title="Notice"><img alt="Notice" src="/wiki/images/a/a4/22px-Appunti_architetto_franc_01.png" decoding="async" width="22" height="28" class="mw-file-element"></span></span> <b>Note:</b> You cannot self-add (+=) nor self-subtract (-=) with system variables in 1.4.5!</td></tr></tbody></table>

  

# Sysval Variables

###### Events

<table class="wikitable"><caption></caption><tbody><tr><th>Event</th><th>Object</th><th>param1</th><th>param2</th><th>param3</th></tr><tr><td>Death</td><td>Block</td><td>The ID of the source object that destroyed the block.</td><td>How the object destroyed the block.</td><td>The ID of the block that was destroyed.</td></tr><tr><td>Hit</td><td>Block</td><td>The ID of the NPC or player who hit the block.</td><td>The ID of the block that was hit.</td><td>If a player hit the block, this value is 1, and if an NPC hits the block, the value is set to -1. The absolute value is how the block was hit.</td></tr><tr><td>No More Objects In Layer</td><td>Block</td><td>The ID of the source object.</td><td>How the object destroyed the block.</td><td>Always returns 0.</td></tr><tr><td>On Screen</td><td>Block</td><td><p>The ID of the block.</p></td><td>Always returns 0.</td><td>Always returns 0.</td></tr><tr><td>Touch</td><td>Liquid</td><td>The first parameter passed during a script call. Only works with liquid types 10, 11, and 17.</td><td>The second parameter passed during a script call. Only works with liquid types 10, 11, and 17.</td><td>Always returns 0</td></tr><tr><td>Death</td><td>NPC</td><td>The ID of the NPC.</td><td>The ID of the player who destroyed the NPC.</td><td>Always returns 0.</td></tr><tr><td>Active</td><td>NPC</td><td>The ID of the NPC.</td><td>Always returns 0.</td><td>Returns 1 if the NPC was spawned from a generator.</td></tr><tr><td>Talk</td><td>NPC</td><td>The ID of the NPC.</td><td>The ID of the player who initiated the talk event.</td><td>Always returns 0.</td></tr><tr><td>Grab</td><td>NPC</td><td>The ID of the NPC.</td><td>The ID of the player who grabbed the NPC.</td><td>Returns 1 if the NPC was grabbed from above.</td></tr><tr><td>No More Objects In Layer</td><td>NPC</td><td>The ID of the NPC.</td><td>Always returns 0.</td><td>Always returns 0.</td></tr><tr><td>Next Frame</td><td>NPC</td><td>The ID of the NPC.</td><td>Always returns 0.</td><td>Always returns 0.</td></tr><tr><td>Touch</td><td>NPC</td><td>The ID of the NPC.</td><td>The ID of the player who touched the NPC.</td><td>The value returned depends on which side of the NPC was touched.<p>0 = wasn't touched</p><p>1 = touched from above</p><p>2 = touched from below</p><p>3 = touched from the left side</p><p>4 = touched from the right side</p><p>5 = touched from center</p></td></tr><tr><td>Enter</td><td>Warp</td><td>The ID of the player who triggered the event.</td><td>The ID of the warp that was used.</td><td>Always returns 0.</td></tr></tbody></table>

  

###### Object Count

| Type | Name | Read/Write | Description |
| --- | --- | --- | --- |
| double | `ncount` | Read Only | The number of NPCs in the level |
| double | `bcount` | Read Only | The number of blocks in the level |
| double | `bgocount` | Read Only | The number of BGOs in the level |
| double | `wcount` | Read Only | The number of warps in the level |
| double | `lcount` | Read Only | The number of liquids in the level |
| double | `ecount` | Read Only | The number of effects in the level |
| double | `actncount` | Read Only | The number of active NPCs in the screen |
| double | `actbcount` | Read Only | The number of active blocks in the screen |

###### Game Data

| Type | Name | Read/Write | Description |
| --- | --- | --- | --- |
| double | `gamemode` | Read Only | Returns if the game is currently singleplayer or multiplayer (0: singleplayer, 1: multiplayer, 2: battle mode) |
| double | `playerhealth` | \- | The current number of 1-Ups collected |
| double | `lvltimer` | Read Only | The current game timer. |
| double | `score` | \- | The current scores |
| double | `coincount` | \- | The current number of coins |
| double | `starcoincount` | Read Only | The current number of star coins collected |
| double | `starcount` | Read Only | The current number of stars collected |
| double | `wldinvcount` | Read Only | The current number of items in the world map inventory |

###### Camera

| Type | Name | Read/Write | Description |
| --- | --- | --- | --- |
| double | `scrsplitstyle` | Read Only | Current splitscreen configuration. (player1/player2; 0: off, 1: top/bottom, 2:bottom/top, 3: left/right, 4: right/left.) |
| double | `player1scrx` | Read Only | Player 1 camera top left x position. |
| double | `player1scry` | Read Only | Player 1 camera top left y position. |
| double | `player2scrx` | Read Only | Player 2 camera top left x position. |
| double | `player2scry` | Read Only | Player 2 camera top left y position. |

###### Player Abilities

| Type | Name | Read/Write | Description |
| --- | --- | --- | --- |
| double | `playerbasestatus` | \- | The starting status of the player given after losing a life. |
| double | `enablewalljump` | \- | Enables the wall jump ability. |
| double | `spinjumpfloating` | \- | Enables the spin jump floating ability. |
| double | `yoshiflyable` | \- | Enables Yoshi's flutter jump. |
| double | `disablejump` | \- | Disables the player's ability to jump if set to 1. |
| double | `disablespinjump` | \- | Disables the player's ability to spin jump if set to 1. |
| double | `disableduck` | \- | Disables the player's ability to crouch/duck if set to 1. (Penguin Suit sliding hitboxes are buggy, and Link's downward stab will also disabled.) |
| double | `disableclimbing` | \- | Disables the ability to climb on climbable backgrounds. |
| double | `disablegrabtop` | \- | Disables the ability to grab NPCs from above regardless of NPC text code settings. |
| double | `disablegrabside` | \- | Disables the ability to grab NPCs from the side regardless of NPC text code settings. |
| double | `disablehammershield` | \- | Disables the player's Hammer Suit shield when ducking if set to 1. |
| double | `disablepenguindash` | \- | Disables the ability to slide on belly when the player has a penguin suit. |
| double | `disableshelldash` | \- | Disables the player's ability to use the shell suit dash if set to 1. |
| double | `disablelinksword` | \- | Disables Link's sword attack if set to 1. (Animations will still play) |
| double | `disablelinkshield` | \- | Disables Link's shield if set to 1. |
| double | `bplayer1health` | \- | The current number of 1-ups for player 1 in battle mode. |
| double | `bplayer2health` | \- | The current number of 1-ups for player 2 in battle mode. |
| double | `invtimewhenhurt` | \- | How many frames the player's temporary invincibility lasts when taking damage/powering up. Default value is 150. |
| double | `fluddrestorespeed` | \- | Determines how much your F.L.U.D.D. tank fills up by every second the player is in water. Default value is 200, which maxes out the tank capacity. |
| double | `disablesharedfludd` | \- | If set to -1, each F.L.U.D.D. nozzle type will have separate water capacities. |
| double | `enableinertiafornpc` | \- | Enables momentum when jumping off standable NPCs. |

  

###### Game Mechanics

| Type | Name | Read/Write | Description |
| --- | --- | --- | --- |
| double | `enablelighting` | \- | Enables the lighting system if set to 1. Doing so automatically changes it to -1, interestingly. Value must be set to -1 for it to be read. |
| double | `enablesmb3statussys` | \- | Enables the SMB3/Modern power-up system. |
| double | `coinsforextralife` | \- | The limit of coins the player can store. Minimum value is 1. |
| double | `shellcanhitblockside` | \- | Enables shells to hit invisible blocks. |
| double | `npcstyle` | \- | Disables suit power-up NPCs from changing into pendants when playing as Link. This also disables coins from turning into rupees when playing as Link. Does not work in multiplayer mode. |
| double | `showhud` | \- | Hides the HUD if set to 1. |
| double | `enablepause` | \- | Disables the player's ability to pause if set to 1. |
| double | `disablesave` | \- | Disables the player's ability to save if set to 1. |

  

###### Time

<table class="wikitable notice-warning" cellpadding="10"><tbody><tr><td><span class="mw-default-size" typeof="mw:File"><a href="/pgewiki/File:OOjs_UI_icon_notice-destructive.svg" class="mw-file-description"><img src="https://upload.wikimedia.org/wikipedia/commons/thumb/b/bf/OOjs_UI_icon_notice-destructive.svg/20px-OOjs_UI_icon_notice-destructive.svg.png" decoding="async" width="20" height="20" class="mw-file-element" srcset="https://upload.wikimedia.org/wikipedia/commons/thumb/b/bf/OOjs_UI_icon_notice-destructive.svg/40px-OOjs_UI_icon_notice-destructive.svg.png 1.5x"></a></span> <b>WARNING:</b> Computer's timer values do not work in replays</td></tr></tbody></table>

| Type | Name | Read/Write | Description |
| --- | --- | --- | --- |
| double | `gametime` | Read Only | The total amount of frames the level has been running. |
| double | `systime` | Read Only | Seems related to System Time although the format displayed is unknown. |
| double | `year` | Read Only | The year counter of the user's computer calendar |
| double | `month` | Read Only | The months counter of the user's computer calendar |
| double | `day` | Read Only | The days counter of the user's computer calendar |
| double | `hour` | Read Only | The hours counter of the user's computer timer in the 24-hour time format |
| double | `minute` | Read Only | The minutes counter of the user's computer timer |
| double | `second` | Read Only | The seconds counter of the user's computer timer |

###### System

| Type | Name | Read/Write | Description |
| --- | --- | --- | --- |
| string | `gametitle` | Write Only | Sets the window's game title. |
| double | `syslang` | Read Only | The value of the computer's current language configuration. [Values can be found here.](https://www.science.co.il/language/Locale-codes.php) |

###### Other

| Type | Name | Read/Write | Description |
| --- | --- | --- | --- |
| double | `param1` | \- | A parameter passed by the event that called the script. \[PUT LINK TO MORE INFO HERE\] |
| double | `param2` | \- | Check `param1` for info. |
| double | `param3` | \- | Check `param1` for info. |
| double | `levelscript` | \- | Can store the maximum number of scripts the level has. |
| double | `worldscript` | \- | Can store the maximum number of scripts the world map has. |

###### Unknown

| Type | Name | Read/Write | Description |
| --- | --- | --- | --- |
| unknown | `disablesysconstreset` | \- | Unknown |
| unknown | `machinecode` | Read Only | Unknown |

###### Unusable

| Type | Name | Read/Write | Description |
| --- | --- | --- | --- |
| unknown | `grabshellinsmb3way` | \- | Unusable in 1.4.5. In past version, it was to check to allowed the player to grab a shell while falling into it. |
