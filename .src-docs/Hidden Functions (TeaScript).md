# Hidden Functions (TeaScript)

> 来源: <https://wohlsoft.ru/pgewiki/Hidden_Functions_(TeaScript)>

---

This is a list of possible functions or other attributes to TeaScript that are currently unknown. All known info must be documented here. If something has gone from unknown to documented, please move the attribute to the correct wiki page and remove it from here.

## Unknown Keywords

**Void** - UNKNOWN

**import** - UNKNOWN

**~Export~** - [FOUND](https://wohlsoft.ru/pgewiki/TeaScript_Syntax#Export)

**struct** - UNKNOWN

**~scriptptr~** - [FOUND](https://wohlsoft.ru/pgewiki/TeaScript_Syntax#Scriptptr)

**Newarray** - UNKNOWN

## Editor Scripts

It basically works like a swap object(ie as a search and replace function) not ingame.

Objects can be created/removed via Editor Functions, more [information](https://wohlsoft.ru/pgewiki/Editor_Functions).

Part of game object properties can be used in this editor to manipulate them using their PermID.

Sysval is inaccessible in editor script, use itrcreate/itrnext instead, but without Berase Function. (it only works for Blocks)

Every time you start the editor there are no scripts or they are deleted.

## systemObjs

-   Possible functions for editor scripts.
-   Every class object has a sys form. Possible config method for objects?
-   systemEffect was added in patch 31 alongside effect class.

## 1.4.4 leftovers

-   Upon dumping the strings list in 1.4.5, the names of various shader-related functions have been carried over from version 1.4.4, but do not work when called as functions.
-   Strings referencing the Player GFX Offset Editor, custom fonts, and various other 1.4.4 exclusive features can also be found if the user opens various windows and then proceeds to open the language configuration.

Perhaps there's a way to enable these again through hacking?

## NPC hidden parameters

Approximately 4 seconds (260 frames) after the NPC leaves the player's screen, it will "disappear" at its current location.

-   (not truly disappearing, but hidden through special means without any activity).

When the player's screen of vision returns to the NPC's original position, the NPC will reappear at the original location and resume its activities.

Is there a hidden parameter in the NPC Class that controls this behavior?

## Unidentified names for classes

There are currently plenty of identifiers in a few classes that either have no effect or have an effect that is yet to be discovered.

-   BGO class
    -   prx
    -   pry
-   Block class
    -   prx
    -   pry
    -   stimer
-   Char class
    -   scriptid
-   Liquid class
    -   prx
    -   pry
-   NPC class
    -   langle
    -   stimer
-   Sysval class
    -   npcstyle
    -   disablesysconstreset
    -   machinecode

## Unidentified functions

There are currently plenty of functions that either have no effect or have an effect that is yet to be discovered.

### ActNGroup

| Parameters | Description |
| --- | --- |
| Double | Unknown |

### Replace

| Parameters | Description |
| --- | --- |
| String | Unknown |
| String | Unknown |
| String | Unknown |
| Double | Unknown |
| Double | Unknown |
