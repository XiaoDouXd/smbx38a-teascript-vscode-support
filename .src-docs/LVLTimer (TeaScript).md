# LVLTimer (TeaScript)

> 来源: <https://wohlsoft.ru/pgewiki/LVLTimer_(TeaScript)>

---

LVLTimer is a special function in TeaScript that allows you to read and write system variables regarding the level timer.

# Activating the Level Timer

[![](/wiki/images/thumb/3/31/AKtrUC6.png/300px-AKtrUC6.png)](https://wohlsoft.ru/pgewiki/File:AKtrUC6.png)

The "Game Timer" settings as shown in the events menu.

To activate the level timer, use the `Game Timer` event settings in the `Other` category.

The timer must be enabled, set to a count and interval timer higher than zero. If these options are not set, the game timer will not work, even if those settings are manually changed with code.

# Using the LVLTimer Class

To read the value of `LVLTimer` use:

LVLTimer(name)

To change the value of `LVLTimer` use:

LVLTimer(name) \= value

  

# LVLTimer Properties

##### Physical Properties

| Type | Name | Read/Write | Description |
| --- | --- | --- | --- |
| double | `x` | \- | The top left x position of the timer in the HUD in screen coordinates. |
| double | `y` | \- | The top left y position of the timer in the HUD in screen coordinates. |

##### Behavioral Properties

| Type | Name | Read/Write | Description |
| --- | --- | --- | --- |
| double | `count` | \- | The current value of the timer. |
| double | `intv` | \- | The delay in frames it takes to update the timer. (e.g. An interval of 65 means the timer counts every 65 frames.) |
| double | `type` | \- | Determines if the timer counts up or down. (0: down, -1: up) |

##### Graphical Properties

| Type | Name | Read/Write | Description |
| --- | --- | --- | --- |
| double | `show` | \- | Determines if the timer visible. The timer still counts even when the timer is hidden. (0: hide, -1: show) |
| double | `color` | \- | An overlay hue added to the text. Setting this value to 0 makes the text invisible, setting it to -1 returns it to default. Use the `rgba(red, green, blue, alpha)` function to choose a specific hue. |

# Oddities and Quirks

Below is a list of certain quirks the timer have that does not conform to standard behavior or simply other miscellaneous behavior.

-   Setting the interval to zero appears to disable the timer completely. Even after setting it back to another value, the timer will not appear nor update. The only way to re-enable the timer is to call an event setting the interval back to a non-zero value.

-   When the timer counts down, setting `count` to zero does not kill all players. The game only kills the player when the game updates the timer into zero. Setting `count` and `intv` to 1 will instead kill all players (with a one-frame delay).

-   Since the timer uses screen coordinates for its position, its position is unaffected by split-screen.
