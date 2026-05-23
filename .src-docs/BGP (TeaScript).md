# BGP (TeaScript)

> 来源: <https://wohlsoft.ru/pgewiki/BGP_(TeaScript)>

---

BGP is a class in TeaScript.vbs that allows you to read/write values of backgrounds (background2).

  

## Using the BGP Class

To read the value of `BGP` use:

BGP(index).name

To change the value of `BGP` use:

BGP(index).name \= value

  

## Array-like Strings

For the BGP class, "array-like" strings are used. The arrays look like this:

'BGP(2) is the SMB3 Cloud background
BGP(2).splitcount \= 3 'The background is split into three sections
BGP(2).splitter \= "300, 400" 'The three sections are located in: (0-300), (300-400), and (400-700)
BGP(2).movesp \= "2, 0, -2"  'Now that the background is split, the three values are set like this

## BGP Properties

###### Splitting Properties

| Type | Name | Read/Write | Description |
| --- | --- | --- | --- |
| double | `splitcount` | \- | Decides into how many subsections the background image is split into. Changing this value changes how many values are entered into all other BGP properties. |
| string | `splitter` | \- | An "array-like" string that stands for the y position in which the background is split into. The array should only contain where the split happens and should have one less value than `splitcount`. Note, the y position is for the image file with 0 starting from the top. |

  

###### Physical Properties

| Type | Name | Read/Write | Description |
| --- | --- | --- | --- |
| string | `movesp` | \- | An "array-like" string that controls the horizontal speed of the subsection. |
| string | `offset` | \- | An "array-like" string that stands for a horizontal shift of the subsection. |
| string | `zsp` | \- | An "array-like" string that stands for a the scrolling parallax speed of the subsection. |

## Oddities and Quirks

Below is a list of certain quirks certain BGPs have that does not conform to standard behavior or simply other miscellaneous behavior.
