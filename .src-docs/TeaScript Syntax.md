# TeaScript Syntax

> 来源: <https://wohlsoft.ru/pgewiki/TeaScript_Syntax>

---

## Data Types and Variables

### User Variables

User variables can be access in the variable menu or by pressing ctrl+i. All of these variables must be created using this interface.

#### Doubles & Strings

By clicking the `Add` button in the variable interface you create a user variable.

You may also select if the variable is a local or global `user variable`. Local `user variables` can only exist in a single level and the value is reset every time the level begins. Global variables save the value per level and remembers the value even after quitting the game.

**Variable Naming Standard**

-   Names are not case sensitive.
-   Names must not contain spaces.
-   Names must be made using a combination of letters and numbers only.
-   Names must start with a letter

`User variables` work in an unusual way compared to other scripting languages. A `user variable` has two sides, a `double` and a `string`. There are different methods to access each side

' By creating a variable called "myVar" in the interface you can...
' === Access doubles
'Local
val(myVar) or v(myVar)

'Global
gval(myVar) or gv(myVar)

'Local Concatenation in TXTCreate and Event Messages
&val(myVar)

'Global Concatenation in TXTCreate and Event Messages
&gval(myVar)

' === Access strings
'Local
str(myVar)

'Global
gstr(myVar)

'Local Concatenation in TXTCreate and Event Messages
$val(myVar)

'Global Concatenation in TXTCreate and Event Messages
$gvl(myVar)

  

' === Example
v(myVar) \= 5
str(myVar) \= "Hello"
v(myVar) \= v(myVar) + 2
str(myVar) \=  str(myVar) & " World"
' v(myVar) now has the value of 7
' str(myVar) now has the value of "Hello World"
' Notice how a user variable simultaneously hold a double and a string at the same time. The double side does not interfere with the string side and vice versa.

Note how a `user variable` simultaneously can hold a `double` and a `string`.

### Arrays

By clicking `Add` while holding shift in the variable interface you create a `user array`. Currently, `user arrays` can only contain `double` values. `User arrays` must first be initialized using the redim `function` before usage.

' By creating an array called "myArr" in the interface you can... 
' Initialize the array using redim 
' Read documentation on redim for more information
call redim(0, myArr, ARRAY\_LENGHT) 
' Access value of an array at an index 
array(myArr(index)) \= value

'Arrays do accept strings too, using the next method
strarray(myArr(index)) \= "string"

' === Example
call redim(0, myArr, 3) 
array(myArr(1)) \= 5 
array(myArr(2)) \= 7 
array(myArr(3)) \= array(myArr(1)) + array(myArr(2)) 
' The array now has the following values of \[5, 7, 12\]

### Dim Variables

`Dim variables` are a different way of creating and interacting with variables compared to user variables. A `dim variable` can only have a single type of data that must be defined on creation. Variable naming standards are the same as `user variables`, except you may not use the same name of other existing `functions` and `keywords`. If a `dim variable` is initialized without a value, it defaults to 0 or "" depending on the type.

' You can initialize a variable 
dim varName as type

' You can initialize a variable with a defined value
dim varName as type \= value

'Once initialized you just write the variable name to access it
varName

' === Example
dim myDbl as double \= 5
dim myStr as string \= "Hello"
myDbl\= myDbl\*5
myStr \= myStr & " World"
'myDbl has the value of 25
'myStr has the value of "Hello World"

  
Here is a list of all the different types of dim variables. While TeaScript offers all these types, it is recommended to stick with integer `integer`, `double`, and `string`.

' === List of types ===
dim a as byte    ' Allows from -128 to 127 (integers only)
dim b as integer ' Allows from -32768 to 32767 (integers only)
dim c as long    ' Allows from -2147483648 to 2147483647 (integers only)
dim d as single  ' Allows from -3.402823E39 to 3.402823E38 (single precision floating point)
dim e as double  ' Allows from -1.79769313486233E308 to 1.79769313486232E308 (double precision floating point)
dim f as string  ' Stores string

## Expressions

An expression is a line of code that evaluates to an answer. Something as simple as `1 + 1` is an expression. Teascript offers different tools to create diverse expressions that suit what you specifically need.

### Operators

#### Mathematical Operators

| Mathematical Symbols |
| --- |
| Symbol | Name | Example |
| + | Addition | 
12 + 2 + 3 'returns 17

 |
| \- | Subtraction | 

12 \- 2 \- 3 'returns 7

 |
| \* | Multiplication | 

12\*2\*5 'returns 120

 |
| / | Division | 

'Note that division by 0 will crash SMBX 
12/2/5 'returns 1.2

 |
| \\ | Division with no remainder | 

'Note that division by 0 will crash SMBX
12\\2\\5 'returns 1

 |
| ^ | Power | 

'Note that 0^0 will return 1
12^2 'returns 144

 |
| mod | Modulus | 

'Note that modulating by 0 will crash SMBX
12 mod 5 'returns 2

 |
| & | Concatenation | 

"ABC" & ";" & "123" 'returns "ABC;123"

 |
| ( ) | Parenthesis | 

12\*(2 + 5) 'returns 84

 |
| << | Shift left | 

32 << 1 'returns 64

 |
| \>> | Shift right | 

32 \>> 1 'returns 16

 |

#### Comparing Operators

Note that all `comparative operators` require both sides use the same data type. You can compare numbers with other numbers and strings with other strings, but you cannot compare numbers with strings.

| Comparitive Operators |
| --- |
| Symbol | Name | Description |
| \= | Equal | **Numbers** Returns -1 if both sides are equal, otherwise 0 |
| **Strings** Returns -1 if both sides are equal, otherwise 0 |
| <> | Not equal | **Numbers** Returns -1 if both sides are not equal, otherwise 0 |
| **Strings** Returns -1 if both sides are not equal, otherwise 0 |
| \> | Grater than | **Numbers** Returns -1 if the value on the left is larger, otherwise 0 |
| **Strings** Unknown pattern |
| < | Less than | **Numbers** Returns -1 if the value on the left is smaller, otherwise 0 |
| **Strings** Unknown pattern |
| \>= | Greater than or equal | **Numbers** Returns -1 if the value on the left is larger or equal, otherwise 0 |
| **Strings** Unknown pattern |
| <= | Less than or equal | **Numbers** Returns -1 if the value on the left is smaller or equal, otherwise 0 |
| **Strings** Unknown pattern |
| like | Like | **Numbers** Not compatible, crashes the game |
| **Strings** [https://docs.microsoft.com/en-us/dotnet/visual-basic/language-reference/operators/like-operator](https://docs.microsoft.com/en-us/dotnet/visual-basic/language-reference/operators/like-operator) |

#### Logical Operators

`Logical operators` only work on numbers. They are commonly used with -1 and 0 to represent true and false respectively. Other numbers can be used but it may yield different patterns.

| Logical Operators |
| --- |
| P | Q |  | not P | P and Q | P or Q | P xor Q | P eqv Q | P imp Q |
| 0 | 0 |  | \-1 | 0 | 0 | 0 | \-1 | \-1 |
| 0 | \-1 |  | \-1 | 0 | \-1 | \-1 | 0 | \-1 |
| \-1 | 0 |  | 0 | 0 | \-1 | \-1 | 0 | 0 |
| \-1 | \-1 |  | 0 | \-1 | \-1 | 0 | \-1 | \-1 |

  

### Special Values

These special values behave like numbers.

| Special Values |
| --- |
| Name | Value |
| pi | 3.141592654 |
| e | 2.71828182 |
| rnd | A random number between 0 and 1. The value changes every time the variable is accessed. |

### Built-in Functions

`Functions` are powerful tools that allow you to simplify and expand the flexibility of your scripts. To access a `function`, you write the function name and in parenthesis write the parameters separated by commas. You can put `functions` inside an `expression` just as it were a regular number or string.

For a list of `custom functions` created by the community check [here](https://wohlsoft.ru/pgewiki/Custom_Extra_Scripts_(TeaScript)).

myFunc(param1, param2, ..., paramN)

' === Example
dim x as integer \= \-5
dim y as integer
y \= abs(x) + 1  
' x returns -5; y returns 6
' Note how the abs() function is used

These are the the mathematical `functions` provided in TeaScript.

Parameters can be numbers, *strings*, and **arrays**.

| Functions |
| --- |
| Name and Parameters | Return Type | Description and Example |
| **abs**(x) | Number | Returns the absolute value of a number
abs(\-3) 'returns 3

 |
| **exp**(x) | Number | Returns the number to the power of the *e* constant

exp(5) 'returns e^5

 |
| **log**(x) | Number | Returns the log of the number with a base of *e*

log(e) 'returns 1

 |
| **sgn**(x) | Number | Returns the sign of the number (1, -1, or 0)

sgn(10)  'returns 1
sgn(0)   'returns 0
sgn(\-10) 'returns -1

 |
| **int**(x) | Number | Returns the number rounded down. Similar to the common floor function

int(2.2) 'returns 2
int(\-2.2) ' returns -3

 |
| **fix**(x) | Number | Removes the decimal portion of the number. Not to be confused with the `int()` function,

fix(2.2) 'returns 2
fix(\-2.2) ' returns -2

 |
| **sqr**(x) | Number | Returns the square root of a number

sqr(9) 'returns 3

 |
| **sin**(x) | Number | Returns the sine of the number. Uses radians

sin(pi) 'returns 0

 |
| **cos**(x) | Number | Returns the cosine of the number. Uses radians

cos(pi) 'returns 1

 |
| **tan**(x) | Number | Returns the tangent of the number Uses radians

tan(pi/4) 'returns 1

 |
| **atn**(x) | Number | Returns the inverse tangent of the number. Uses radians

atn(1) 'returns pi/4

 |
| **getangle**(x, y) | Number | Returns the angle (from 0 to 1) formed between the triangle. Similar to the common atan2 function.

getangle(1, 0)  'returns 0
getangle(1, 1)  'returns .125
getangle(0, 1)  'returns .25
getangle(\-1, 0) 'returns 0.5
getangle(0, \-1) 'returns 0.75

 |
| **rgba**(red, green, blue, alpha) | Number | Returns an SMBX color value. Parameters must be between 0 and 255

rgba(255, 255, 255, 255) 'returns -1

 |
| **round**(x, decimal place) | Number | Returns the number rounded

round(1.3456, 2) 'returns 1.35

 |
| **len**(*txt*) | Number | Returns the length of the text

len("ABC") 'returns 3
len(123) 'returns 3

 |
| **left**(*txt*, len) | String | Returns the text cropped from the string inputted. The crop begins from the start and ends with the length specified.

left("Hello", 2) ' Returns "He"

 |
| **right**(*txt*, len) | String | Returns the text cropped from the string inputted. The crop ends from the end and begins with the length specified.

right("Hello", 3) ' Returns "llo"

 |
| **mid**(*txt*, start, len) | String | Returns the text cropped at the specified start and has the specified length provided.

mid("Hello", 2, 3) ' Returns "ell"

 |
| **asc**(*char*) | Number | Returns the ANSI code. It will use the first character if more than one is passed

asc("A")  ' Returns 65

 |
| **chr**(code) | String | Returns a string using the ANSI code. Accepts 0-255

chr(65)  ' Returns "A"

 |
| **ascw**(*char*) | Number | Returns the unicode code. It will use the first character if more than one is passed

ascw("A")  ' Returns 65

 |
| **chrw**(code) | String | Returns a string using the unicode code. Accepts 0-65535

chrw(65) ' Returns "A"

 |
| **cstr**(num) | String | Converts the number to a string

cstr(1)  ' Returns "1"

 |
| **cdbl**(text) | String | Converts the string to a number

cdbl("1")  ' Returns 1

 |
| **uCase**(*text*) | String | Returns a string in uppercase

uCase("hi!")  ' Returns "HI!"

 |
| **lCase**(*text*) | String | Returns a string in lowercase

lCase("HI!")  ' Returns "hi!"

 |
| **instr**(start, *txt*, *search*) | Number | To return the point of the first appearance of a given string in another string.

  
**start** To specify the start point of the search  
**txt** The original string

  
**search** The string to be searched

instr(1, "abcde", "b") ' Returns 2

 |
| **Format**(*format*, value) | String | To return the value as a string in a specific format.

**format** can be :  
\- "%Xz" to return the value with a certain number of figures.

format("%6z", 143) ' Returns 000143

\- "%h" to convert the decimal value into a hexadecimal value.

format("%h", 255) ' Returns FF

 |
| **ubound**(**array**) | Number | Returns the length of the array

call redim(0, myArr, 3)
ubound(myArr) ' Returns 3

  
 |

## Control Flow

When a `script` is run in TeaScript it will start reading the `script` from top to bottom, left to right. It will read and execute the code in that order. the following is a list of ways to customize and manipulate what code gets executed in your `scripts`.

### Declarations

A `declaration` is when you set a value to a variable. This applies to `user variables`, `dim variables`, and other values.

' Basic form of a declaration
' The variable is written in the left
' The value you want set is written in the right
variable \= value

' === Examples
v(myVar) \= 5
dim x as integer
dim y as double \= 10
sysval(score) \= 0
x \= v(myVar) + 10
NPC(1).xsp \= 0

### Conditions

`Conditions` represent true and false. In Teascript, -1 and 0 represents true and false. Any number that is not 0 may also represent true, but use -1 and 0 for consistency reasons.

' === Examples
\-1  ' Represents True
0   ' Represents False
5   ' Represents True (because non-zero numbers represent true)
dim w as integer \= \-1
dim x as integer \= 5
dim y as integer \= 5
dim z as integer \= 0
w    ' Represents True (because w has the value of -1)
x    ' Represents True (because x has a value of a non-zero number)
y    ' Represents True (because y has a value of a non-zero number)
z    ' Represents False (because z has a value of 0)
z \- 1    ' Represent True (because 0 - 1 = -1)
w + 1    ' Represent False (because -1 + 1 = 0)
' Using logical operators 
not w          ' Represent False
not (y and z)  ' Represents True
w or z         ' Represents True

### If Statements

The `if statement` is a basic but useful statement. It has one parameter being a `condition`.

' Basic if statement
if conditon then
  statement
end if

' Shortcut if statement
if condition then statement

' If statement using one elseif and an else statement
if conditon then
  statement
elseif condition then
  statement
...    ' You can have as many elseif as you want 
else
  statement
end if

When TeaScript reads an `if statement` it will check each `condition` from top to bottom until it reaches a `condition` that is true. When it reaches a `condition` that is true, it will execute the `statements` inside and continue the code after the entire `if statement`. This means that `conditions` written on the top will have priority over those `conditions` in the bottom.

The `else` is special since it does not require any `conditions`. An `else` must be written in the bottom after all other `elseif` statements (if there are any). The code inside the `else` will only run if every other `condition` in the `if` and `elseif` statements evaluated to false.

' === Example
dim x as integer \= 0
dim y as integer \= \-1
dim z as integer \= \-1
' Since (x and y) evaluates to 0, this statement is not run.
if x and y then z \= 0
' Since (x and z) evaluates to 0, this statement is not run.
if x and z then
  y \= 0
' Since (y) evaluates to -1, this statement is run.
elseif y then
  x \= \-1
' Since the previous elseif has priority and only one statement can be run, this statement is not run
else
  z \= \-1
end if

### Select Case Statements

`Select Case` lets you easily organize the control flow based on a value. It has one parameter being a value.

select case value
  case \-1
    statement ' Will run if value is exactly -1
  case 0 to 1
    statement ' Will run if value is between (inclusive) 0 and 1
  case is < \-1
    statement ' Will run if value is less than negative one
  case 2, 3, 4
    statement ' Will run if value is exactly 2, 3 or 4
  case "example"
    statement ' Will run if value is exactly "example".
  case else
    statement ' Will run if value does not match any of the other conditions
end select

`Select case` at its core is similar to various `if statements` and behaves similarly to the common "switch" statement in other languages. It will read the value that is passed and executes the first code in which the value matches. It will read the cases from top to bottom giving priority to cases at the top.

The `to` keyword can be used when checking for a case.

-   **Numbers** Will be true if the value is between (inclusive) the two numbers provided.
-   **Strings** Unknown pattern

The `is` keyword can be used to make comparisons to the value. It can be used with the `<, >, <=,` or `>=` logical operators.

You can use commas to check for multiple cases at once. The commas behave similarly to an `or` logical operator. The case will go through if it matches with any of the cases.

### With Statements

`With statements` are useful to read or write on multiple properties of an object. An object can be for example an NPC, Block, or BGO. Check the classes section for more information on SMBX Objects. You can acess all of the properties by typing a `.` followed by the property name.

with object
  .property\_name
end with

  

' === Example
with NPC(1)
  .x \= 12345
  .y \= 54321
  .forecolor \= rgba(10, 60, 60, 255)
  v(myVar) \= .ysp
end with

' This is equivalent to:
  NPC(1).x \= 12345
  NPC(1).y \= 54321
  NPC(1).forecolor \= rgba(10, 60, 60, 255)
  v(myVar) \= NPC(1).ysp

### Goto

Using `goto` will force the script to jump to a specific line to a specific label. The label name must be followed by `:`. `Goto` does not work inside `with statements`.

Example:

goto Example

  

### GoSub

Using `gosub` will force the script to jump to a specific line to a specific label. Teascript will remember where the jump happened and can be returned by using `return`.The label name must be followed by `:`. `Gosub` does not work inside `with statements`.

Example:

gosub Example
return  ' When it reaches this line, it will return back to the first line

' === Example
gosub Example
call showMsg("b")

Example:
call showMsg("a")
return 
' Take note of the order the messages are shown

## Loops

A loop allows you to run a piece of code multiple times. Teascript is very flexible in the type of loops you can create.

It is important to note that you should avoid an infinite loop. Creating an infinite loop will freeze the game. Make sure to either have a [`sleep`](https://wohlsoft.ru/pgewiki/Functions_(TeaScript)#Sleep) function (if the script was called by an event) or an `exit`.

### Pure Loops

A `pure loop` is a very simple and basic form of a loop. It will run indefinitely.

'Pure loop:
do
  statement
loop

' === Example
' Calling this script once will run the code every tick
do
  statement
  call sleep(1)
loop

### While Loops

A `while loop` will continue the loop while the `condition` is `true`. You can set up a `while loop` in 2 different ways. The difference is by when the loop checks its condition. If you place the `while` at the bottom, you guarantee then code will be run at least once.

do while condition
  statement
loop

do
  statement
loop while condition

' === Example
dim x as integer
x \= 0
do while x < 5
  x \= x + 1
loop
x \= 0
do 
  x \= x + 1
loop while x < 5
' Both loops ran 5 times

### Until Loops

An `until loop` will continue the loop until the `condition` is `true`. You can set up an `until loop` in 2 different ways. The difference is by when the loop checks its condition. If you place the `until` at the bottom, you guarantee then code will be run at least once.

do until condition
  statement
loop

do
  statement
loop until condition

' === Example
dim x as integer
x \= 0
do until x \= 5
  x \= x + 1
loop
x \= 0
do 
  x \= x + 1
loop until x \= 5
' Both loops ran 5 times

### For Loops

A `for loop` will run for a set amount of times. You declare a variable then will count the current iteration it is on. A `for loop` has 3 parameters and they are: `initial value`, `final value`, and `step value`.

A `for loop` will continue to loop as long as your counter is less or equal to the `ending value`. The `for loop` will also stop if your counter is less than your `initial value`. For every iteration, your counter will increase by the `step value`.

for i \= (initial value) to (ending value) step (step value)
    statement
next

'step value is optional and defaults to 1 when omitted
for i \= (initial value) to (ending value)
  statement
next

  

' === Example
dim i as integer
for i \= 0 to 8 step 2
  call showMsg(i)
next
' The messages displayed are: 0, 2, 4, 6, and 8

  

### Continue

A `continue` statement will immediately begin the next iteration of a loop.

dim i as integer

for i \= 1 to 10 
  ' If the number is even then immideatly finish the loop and continue at the next iteration
  if i % 2 \= 0 then
	continue
  end if

  ' Only odd numbers will be shown
  call showMsg(i)
next

### Exit

An `exit` statement will terminate a loop of a script prematurely.

'This works inside a pure, while, or until loop
exit do

'This works inside a for loop
exit for

'This will force the game to stop immediately executing the script
exit script

## Scripts

Teascript allows you to create `custom script` function inside your scripts. This allows you to simplify your code and build tools to expand your script in a more organized manner. There are two types of `custom scripts` that both work very similarly.

When setting up a `custom function` or `custom procedure`, all `scripts` and `parameters` names must follow **variable naming standards** with one exception. Script names must not contain numbers anywhere.

#### Function

A `custom function` allows you to create your own custom functions that behave similarly to the `built-in functions` shown above. You can add your own `custom functions` to simplify code or add your very own mathematical functions. You can have as many `parameters` as you want. You must define the type of data and the return type as shown below. If no `return` is found, then by default it will return 0 or "" depending on the return type. A `custom function` must be defined at the bottom of the script.

' type must be double or string
script functionName(param1 as type, param2 as type, ..., return type)
  ' to access a parameter, just type the name
  return value
end script

' === Example

dim x as integer \= 5
dim y as integer \= 10
dim z as integer

z \= max(5, 10)
' z returns 10

' This script returns the larger parameter
script max(a as double, b as double, return double)
  if a \> b then return a
  return b
end script

  

#### Procedure

A `custom procedure` are similar to `custom functions` except they do not have a return value. Use custom procedures to create instructions that you want to repeat together. You can have as many `parameters` as you want. You must define the type of data as shown below. A `custom procedure` must be defined at the bottom of the script.

' type must be double or string
script procedureName(param1 as type, param2 as type, ...)

end script

' === Example
' This disables both types of jumps
call setJumps(\-1)
' This enables both types of jumps
call setJumps(0)
script setJumps(x as double)
  sysval(disablejump) \= x
  sysval(disablespinjump) \= x
end script

  

### Export

`Export` allows you to export `custom functions` and `custom procedures` and make them global. Exported scripts can be accessed in any other script normally.

' This function can now be accessed in any script
export script procedureName(param1 as type, param2 as type, ...)

end script

## Oddities and Quirks

The following is a list of oddities that you may experience when using TeaScript

#### **Scriptptr**

`Scriptptr` allows modifying the parameters of an existing script. It is likely that this function is in development, since it always returns an error.

call showmsg(hello("a"))

script hello(t as double, return double)
return 0 
scriptptr hello(t as string, return double)
return \-1
end

  
**Negatives to a Non-Integer Power**

`sqr(x)` is equivalent to `x^(0.5)`. Therefore `(-1)^(0.5)` results in a complex number with a imaginary component. Teascript does not offer complex numbers in its data types.

dim x as integer \= \-1
dim y as integer

y \= (\-1)^(0.5) ' This returns an error when run.
y \= x^(0.5)    ' This does not error but will evaluate to 0

**Writing Double Quotation Marks**  

Since double quotation marks are reserved for defining string, you must use chr or chrW to write a double quotation mark inside a string.

str(myVar1) \= chrW(34) '34 is the ID of the double quotation marks. (ID 34 works too in chr() too)

'You can define a variable as a quotation mark or call the quotation mark directly, both work the same
str(myVar2) \= "These are some "&str(myVar1)&"special"&chrW(34)&" marks"

'str(myVar2) is "These are some "special" marks"

**Using dim variables on global scripts**  
For some reason, using `long`, `single` or `double` types in global scripts will return an error when playing in start game mode.  
However, `byte` and `integer` types work fine.  

**\> THESE PROBLEMS ARE FIXED in 1.4.5 <**

**Dim Variables in If Statements \[fixed in patch 31!\]**

If you initialize a dim variable inside an if statement, it will have a buggy effect. This is a bug in Teascript's side.

' This is a bug
if \-1 \= \-1 then
    dim i as double \= 1
    call sysshowmsg(i,0,0)
    dim j as double \= i \- 2
    dim k as double \= j + i
    call sysshowmsg(i,0,0)
    call sysshowmsg(j,0,0)
    call sysshowmsg(k,0,0)
end if

**Writing Decimal Numbers**  
When writing decimal number, you must include a number before the decimal point.

'Wrong
v(myVar) \= .1

'Correct
v(myVar) \= 0.1

  
**Writing negative numbers**  
When writing a negative number, make sure there are no other symbols beforehand (except parenthesis).

'Wrong (Teascript errors due to seeing \* and - next to each other)
v(myVar) \= 5\*-4

'Correct
v(myVar) \= 5\*(\-4)
v(myVar) \= \-4\*5
