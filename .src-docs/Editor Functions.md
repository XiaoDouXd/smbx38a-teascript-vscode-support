# Editor Functions

> 来源: <https://wohlsoft.ru/pgewiki/Editor_Functions>

---

Functions that work only in edit mode are used through Script Editor (Editor).

## ObjectCreate

Returns the PermID of Object.

<table class="wikitable"><caption></caption><tbody><tr><th>Parameters</th><th>Description</th></tr><tr><td rowspan="3">Type</td><td rowspan="3">The Type of Object<table class="wikitable"><caption></caption><tbody><tr><th>Type</th><th>Name</th></tr><tr><td>1</td><td>Blocks</td></tr><tr><td>2</td><td>Backgrounds</td></tr><tr><td>3</td><td>NPCs</td></tr><tr><td>4</td><td>Liquids</td></tr></tbody></table></td></tr></tbody></table>

dim PermID as integer = objectcreate(Type)

## ObjectRemove

Remove the object get called.

<table class="wikitable"><caption></caption><tbody><tr><th>Parameters</th><th>Description</th></tr><tr><td>Type</td><td>The Type of Object<table class="wikitable"><tbody><tr><th>ID</th><th>Name</th></tr><tr><td>1</td><td>Blocks</td></tr><tr><td>2</td><td>Backgrounds</td></tr><tr><td>3</td><td>NPCs</td></tr><tr><td>4</td><td>Warps</td></tr><tr><td>5</td><td>Liquids</td></tr></tbody></table></td></tr><tr><td rowspan="3">PermID</td><td rowspan="3">PermID of Object</td></tr><tr><td></td></tr></tbody></table>

call objectremove(Type, PermID)

**Additional Information**

-   All objects and (most of) properties can be manipulated within the Script Editor (Editor), through their PermID.
