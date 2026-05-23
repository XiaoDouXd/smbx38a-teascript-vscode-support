# Effect (TeaScript)

> 来源: <https://wohlsoft.ru/pgewiki/Effect_(TeaScript)>

---

Effect is a class in TeaScript.vbs that allows you to read/write values of Effects.

# Spawning an Effect

To spawn an effect you can use the `FXCreate` function.

call FXCreate(ID, X, Y, Xsp, Ysp, Frames, AnimationSpeed, Const, Gravity, Advanced)

For more information visit the [FXCreate](https://wohlsoft.ru/pgewiki/Functions_(TeaScript)#FXCreate) documentation

# Using the Effect Class

To read the value of `Effect` use:

effect(index).name

To change the value of `Effect` use:

effect(index).name \= value

  

# Effect Properties

##### Physical Properties

| Type | Name | Read/Write | Description |
| --- | --- | --- | --- |
| double | `id` | \- | The ID is used to decide and tie in its graphics, behavior, and effect flags. You can change this value to change the effect into another |
| double | `x` | \- | The x position of the effect in scene coordinates. |
| double | `y` | \- | The y position of the effect in scene coordinates. |
| double | `xsp` | \- | The horizontal speed of the effect. Negative values cause leftwards movement, positive values cause rightwards movement. |
| double | `ysp` | \- | The vertical speed of the effect. Negative values cause upwards movement, positive values cause downwards movement. |

##### Graphical Properties

| Type | Name | Read/Write | Description |
| --- | --- | --- | --- |
| double | `extx` | \- | Will only affect the effect if the effect flag 'GFXSplitWidth' is enabled. This values chooses the alternative GFX x position starting from 0. Setting this -1 makes the effect invisible. |
| double | `exty` | \- | Will only affect the effect if the effect flag 'GFXSplitHeight' is enabled. This values chooses the alternative GFX y position starting from 0. Setting this -1 makes the effect invisible. |
| double | `zpos` | \- | The priority value of the effect. Must be a number between 0 and 1, where 0 is foreground and 1 is background. |

# Oddities and Quirks

Below is a list of certain quirks certain effects have that does not conform to standard behavior or simply other miscellaneous behavior.
