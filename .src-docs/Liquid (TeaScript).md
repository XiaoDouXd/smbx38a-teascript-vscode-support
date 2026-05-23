# Liquid (TeaScript)

> 来源: <https://wohlsoft.ru/pgewiki/Liquid_(TeaScript)>

---

Liquid is a class in TeaScript.vbs that allows you to read/write values of liquid boxes and zones.

# Using the Liquid Class

To read the value of `Liquid` use:

Liquid(index).name

To change the value of a `Liquid` use:

Liquid(index).name \= value

# Liquid Properties

##### Physical Properties

| Type | Name | Read/Write | Description |
| --- | --- | --- | --- |
| double | `x` | \- | The top left x position of the liquid in scene coordinates. In circular mode, this is the center of the liquid. |
| double | `y` | \- | The top left y position of the liquid in scene coordinates. In circular mode, this is the center of the liquid. |
| double | `width` | \- | The width of the liquid. In circular mode, this represents the radius. |
| double | `height` | \- | The height of the liquid. In circular mode, this value is -1. |
| double | `xsp` | \- | The horizontal speed of the liquid. Negative values cause leftwards movement, positive values cause rightwards movement. |
| double | `ysp` | \- | The vertical speed of the liquid. Negative values cause upwards movement, positive values cause downwards movement. |
| double | `hide` | \- | Whether the liquid is hidden or not. |

##### Behavioral Properties

| Type | Name | Read/Write | Description |
| --- | --- | --- | --- |
| double | `fdir` | \- | The direction of the force field. |
| double | `fval` | \- | The acceleration of the force field. |
| double | `fmax` | \- | The max speed of the force field. |
| double | `wconst` | \- | The resistance of the force field. |

###### Liquid Events

| Type | Name | Read/Write | Description |
| --- | --- | --- | --- |
| string | `touchevent` | \- | When a player enters a liquid boundary, it will call the event/script defined. The event/script is called every frame the player is inside the liquid boundary. |

###### Unknown

| Type | Name | Read/Write | Description |
| --- | --- | --- | --- |
| double | `prx` | \- | Unknown |
| double | `pry` | \- | Unknown |

  

## Oddities and Quirks

Below is a list of certain quirks players have that does not conform to standard behavior or simply other miscellaneous behavior.

-   Liquids can either be rectangular or circular. This is entirely decided by setting height to -1 (for circular mode) or a positive value (for rectangular mode). You can set this value to -1 to force the liquid into circular mode or vice-versa. In circular mode, x and y instead define the center of the liquid and width defines the radius.
