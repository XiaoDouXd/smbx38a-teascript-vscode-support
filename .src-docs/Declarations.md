# Declarations

> 来源: <https://wohlsoft.ru/pgewiki/Declarations>

---

Before you get into this tutorial, you should first have at least a basic understanding of the existence of Control Declarations. If you don’t, click [this conveniently placed link](https://wohlsoft.ru/pgewiki/TeaScript_Syntax#Control_Flow), which tells you all you need to know.

If you've read past that knowledge checkpoint, I will assume that you do, at least, somewhat understand how Control Declarations work, even if it is on a very basic level. Given that liberty, I will introduce you to

## Declarations

A `declaration` is a line of code that, when ran, makes itself true. An example of a declaration would be:

.x += 64

This `declaration` would, upon being ran, add 64 to the specified object's `x-axis` value. `Declarations` are the fundamental working grounds of all languages, and thus are very simple in nature.

### Examples

.y \= 64

char(1).id \= 1

char(1).ysp \= \-5

1.  Makes the specified object's `y-axis` value equal to 64.
2.  Makes player one Luigi.
3.  Makes player one's `y-axis` speed equal to negative five (so, moving upwards).

Now that you know how to `declare`, I bring you one of the very building blocks of all coding languages;

## If Statements

The `if` statement is a very common statement; one that you can find in a vast majority of coding languages, and Teascript is no different. `If` statements are formatted as such:

if 'condition
   'declaration
end if

This is a basic if statement, with one `condition` and one `declaration`. A `condition` is what's being checked, and a `declaration` is what will be done if the condition is met. Using this alone, you can make scripts that control players, npcs, and more.

if sysval(coincount) \> 50
   sysval(coincount) \-= 50
end if

Here's an example of a functioning `if` statement. Line 1, `if sysval(coincount) > 50` first tells Teascript that you are using an `if` statement, via the use of `if`, then *asks* if the player's coin count is greater than 50. Next, if the `condition` is met, the language goes on to make the `declaration` true (in this case, it subtracts fifty coins from poor Mario). Whenever writing an `if` statement, you must *first* write the `condition` next to the `if`, and not the `statement`.

### Examples

if gv(wind)\=1
   char(1).x \-= 1
end if

if .health \= 1
   char(1).xsp \= char(1).xsp\*-1
   .health \= 2
end if

if .ivala \= 1
   .ivalb += 1
end if

1.  Checks if the global variable `wind` is 1, and if so, makes player one move backwards a pixel.
2.  Checks if the specified object's `health` is one, and if so, forces player one to move backwards and sets `health` to two.
3.  Checks if `ivala` is 1, and if so, adds one to `ivalb`.

This is, on a basic level, how most scripters do things in Teascript. And given how you've just learned how to do it; welcome to the world of Teascripting.
