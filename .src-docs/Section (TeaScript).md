# Section (TeaScript)

> 来源: <https://wohlsoft.ru/pgewiki/Section_(TeaScript)>

---

Section is a class in TeaScript.vbs that allows you to read/write values of level sections.

# Using the Section Class

To read the value of `Section` use:

 Section(index).name

  
To change the value of `Section` use:

 Section(index).name \= value

Where index is the section ID as shown in the editor.

  

# Section Properties

##### Physical Properties

| Type | Name | Read/Write | Description |
| --- | --- | --- | --- |
| double | `x` | \- | The top left x position of the section in scene coordinates. |
| double | `y` | \- | The top left y position of the section in scene coordinates. |
| double | `width` | \- | The current width |
| double | `height` | \- | The current height |

##### Unknown

| Type | Name | Read/Write | Description |
| --- | --- | --- | --- |
| double | `forcewidth` | \- | Returns the forced width size of the given section |
| double | `forceheight` | \- | Returns the forced height size of the given section |
| double | `forced` | \- | Returns 1 if the section's boundary has been edited via events |
| double | `forcexsp` | \-
 | Returns the auto-scrolling X-speed |
| double | `forceysp` | \-

 | Returns the auto-scrolling Y speed |
| double | `forcex` | \-

 | The X coordinates of the beginning of the section |
| double | `forcey` | \-

 | The Y coordinates of the beginning of the section |

# Oddities and Quirks

Below is a list of certain quirks sections have that does not conform to standard behavior or simply other miscellaneous behavior.
