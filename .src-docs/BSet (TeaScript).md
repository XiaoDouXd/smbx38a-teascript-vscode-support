# BSet (TeaScript)

> 来源: <https://wohlsoft.ru/pgewiki/BSet_(TeaScript)>

---

<table class="wikitable notice-warning" cellpadding="10"><tbody><tr><td><span class="mw-default-size" typeof="mw:File"><a href="/pgewiki/File:OOjs_UI_icon_notice-destructive.svg" class="mw-file-description"><img src="https://upload.wikimedia.org/wikipedia/commons/thumb/b/bf/OOjs_UI_icon_notice-destructive.svg/20px-OOjs_UI_icon_notice-destructive.svg.png" decoding="async" width="20" height="20" class="mw-file-element" srcset="https://upload.wikimedia.org/wikipedia/commons/thumb/b/bf/OOjs_UI_icon_notice-destructive.svg/40px-OOjs_UI_icon_notice-destructive.svg.png 1.5x"></a></span> <b>WARNING:</b> <i>This page can still be updated if new things are discovered related to this function.</i></td></tr></tbody></table>

**BSet** is a function in TeaScript that allows for flags of object classes to be modified. At the moment, only a few flags of the NPC class can be altered.

**Syntax:**

call bset(type, ID, FLAG\_ID, Param1, Param2, Param3)

<table class="wikitable"><caption>Parameters</caption><tbody><tr><th>Parameter</th><th>Description</th></tr><tr><td>Type</td><td>The object class</td></tr><tr><td>ID</td><td>The ID of the object in the class</td></tr><tr><td>FlagID</td><td>The flag of the object to be altered</td></tr><tr><td>Param1</td><td>The first parameter of FlagID</td></tr><tr><td>Param2</td><td>The second parameter of FlagID</td></tr><tr><td>Param3</td><td>The third parameter of FlagID</td></tr></tbody></table>

<table class="wikitable"><caption>"Type" Parameter</caption><tbody><tr><th>ID</th><th>Description</th></tr><tr><td>0</td><td>Unknown</td></tr><tr><td>1</td><td>Unknown</td></tr><tr><td>2</td><td>NPC Property Settings (General)</td></tr><tr><td>138</td><td>Block Collision Detection [Player/NPC]</td></tr></tbody></table>

## "Flag ID" Parameters

###### **Type = 2 | NPC Property Settings (General)**

| FlagID | FlagID Desc. | Description | Param1 | Param2 | Param3 |
| --- | --- | --- | --- | --- | --- |
| 1 | Blend Mode | Blend Mode of the NPC | 
-   1 - Black
-   3 - Reddish
-   4 - Negative Colors
-   9 - Blue Cyan
-   10 - Orange/Red
-   13 - Invisible
-   66050 - Additive
-   66053 - Additive + Alpha
-   197122 - Subtractive
-   197125 - Subtractive + Alpha

 | 0 | 0 |
| 2 | Brightness | Radius(pixels) of it's illuminating range. | NPC Light Size. | 0 | 0 |
| 3 | Health | Default Health Point of this NPC

<table class="wikitable notice-warning" cellpadding="10"><tbody><tr><td><span class="mw-default-size" typeof="mw:File"><a href="/pgewiki/File:OOjs_UI_icon_notice-destructive.svg" class="mw-file-description"><img src="https://upload.wikimedia.org/wikipedia/commons/thumb/b/bf/OOjs_UI_icon_notice-destructive.svg/20px-OOjs_UI_icon_notice-destructive.svg.png" decoding="async" width="20" height="20" class="mw-file-element" srcset="https://upload.wikimedia.org/wikipedia/commons/thumb/b/bf/OOjs_UI_icon_notice-destructive.svg/40px-OOjs_UI_icon_notice-destructive.svg.png 1.5x"></a></span> <b>WARNING:</b> No longer works in 1.4.5.</td></tr></tbody></table>

 | NPC Health Amount. | 0 | 0 |
| 4 | FireBallDmg | The damage it will take when it was hit by fireball. | Amount of damage you will receive from the fireball. | 0 | 0 |
| 5 | JumpDmg | The damage it will take when it was hit by player's jump. | Amount of damage you will receive from the Jump. | 0 | 0 |
| 6 | HammerDmg | The damage it will take when it was hit by Hammer. | Amount of damage you will receive from the Hammer. | 0 | 0 |
| 7 | LavaDmg | The damage it will take when it was fall into Lava. | Amount of damage you will receive from the Lava. | 0 | 0 |
| 8 | ShellDmg | The damage it will take when it was hit by Shell. | Amount of damage you will receive from the Shell. | 0 | 0 |
| 9 | ExplosionDmg | The damage it will take when it was bombed. | Amount of damage you will receive from the Explosion. | 0 | 0 |
| 10 | BlockHitDmg | The damage it will take when it was hit by Block. | Amount of damage you will receive from the Block. | 0 | 0 |
| 11 | TailSpinDmg | The damage it will take when it was hit by player's tail spin. | Amount of damage you will receive from the Tail Tanooki/Leaf. | 0 | 0 |
| 12 | Score | How many points the NPC should give you upon its death/collection. | 

-   0 - No Score
-   1 - 10 points
-   2 - 100 points
-   3 - 200 points
-   4 - 400 points
-   5 - 800 points
-   6 - 1000 points
-   7 - 2000 points
-   8 - 4000 points
-   9 - 8000 points
-   10 - 1-up
-   11 - 2-up
-   12 - 3-up
-   13 - 5-up

 | 0 | 0 |
| 14 | Frozen Timer | How many frames can it be frozen. | Determine NPC freeze time:

-   \-1 - It cannot be frozen.
-   0 - Infinitely frozen.
-   (> 0) - Greater than zero, determines the NPC freeze time.

 | 0 | 0 |
| 16 | NoBlockCollision | Whether this NPC can pass through blocks. | Determines whether the NPC will collide with blocks:

-   0 - Yes
-   1 - No

 | 0 | 0 |
| 1438 | NPC ID 339 Properties for other NPCs | Makes an NPC of your choice have the same properties as NPC ID 339. Use .advset to adjust the stretched length of the NPC. Use .ivala to adjust the rotation angle of the NPC. Only works when Parallel Execution is disabled. | 38 | 0 | 0 |
| 5438 | CollisionType | Determines the collision type of the NPC. (Disables collision with blocks if used, Enable npc sprite and hitbox rotation using .ivala with a 360 degrees system (45000 = 45°)) | NPC type of collision:

-   1 - Full Square or Rectangular Collision
-   2 - Only on the Top of NPC
-   3 - Round
-   4 or more - None

 | 0 | 0 |

###### Type = 138 | Block Collision Detection \[Player/NPC\]

<table class="wikitable"><caption></caption><tbody><tr><th>FlagID</th><th>FlagID Desc.</th><th>Param 1</th><th>Param 2</th><th>Param 3</th></tr><tr><td>19</td><td>Slop Plataform (Upper Left)</td><td>0</td><td>0</td><td>0</td></tr><tr><td>20</td><td>Slop Plataform (Upper Right)</td><td>0</td><td>0</td><td>0</td></tr><tr><td>21</td><td>Slop Plataform (Bottom Left)</td><td>0</td><td>0</td><td>0</td></tr><tr><td>22</td><td>Slop Plataform (Bottom Right)</td><td>0</td><td>0</td><td>0</td></tr><tr><td>23</td><td>Plataform (Down)</td><td>1</td><td>0</td><td>0</td></tr><tr><td>24</td><td>Plataform (Left)</td><td>1</td><td>0</td><td>0</td></tr><tr><td>25</td><td>Plataform (Right)</td><td>1</td><td>0</td><td>0</td></tr></tbody></table>

## Oddities and Quirks

Below is a list of certain quirks players have that does not conform to standard behavior or simply other miscellaneous behavior.

-   BSet values do not apply to NPC ID 357.
