# Iterators

> 来源: <https://wohlsoft.ru/pgewiki/Iterators>

---

Iterators are a powerful tool that lets you iterate with any object that satisfies certain condition. Below is a tutorial explaining how to use an iterator. Please read closely and follow the examples as you read the tutorial. Iterators are a **extremely** **powerful** tool

  

## Index vs ID

[![](/wiki/images/thumb/0/0f/Annotation_2020-08-16_174153.png/300px-Annotation_2020-08-16_174153.png)](https://wohlsoft.ru/pgewiki/File:Annotation_2020-08-16_174153.png)

A very common confusion users have when using TeaScript is understanding what an index is. Users mistakenly assume it means ID, but these are not the same thing.

So what is an index? An index is the position of an NPC in the NPC array. Look at it this way, imagine you have made this level below. the NPCs were placed from left to right. [Here is a gif](https://i.imgur.com/XCGbd3p.gif) that illustrates how index show up and changes in-game. The index changes during runtime and is affected by other NPCs that die or get spawned. This means that storing an index across frames is not effective and unreliable.

  

  

  

  

  

## Setting Up Your First Iterator

Now that you know how index behave, we can explain what an iterator is. An iterator is a function that will allow you to iterate over a group of NPCs indexes. This means that you can define an area and you can affect all objects in that area with custom behavior.

  

This is the entire process normally used for an iterator and you may use it as a template when creating one. It will be explained below how it works.

dim itID as integer
dim itIX as integer
itID \= itrCreate(TYPE, ID, X, Y, WIDTH, HEIGHT)
do
  itIX \= itrNext(itID)
  if itIX \= 0 then exit do
    with NPC(itIX)
      ' Custom Behavior
    end with
loop
call BErase(0, itID)

  

First you must create an iterator using itrCreate. When you create an iterator, you must define a type, an ID filter, and a rectangular box. SMBX will store your created iterator and return an ID to access it.

iteratorID \= itrCreate(TYPE, ID, X, Y, WIDTH, HEIGHT)
' The created iterator is stored inside of SMBX
' iteratorID is a key that will be used later to access your created iterator.

  

Once you create an iterator, you will be given a key to access that iterator. You give this key to itrCreate in order to access your iterator.

iteratorIndex \= itrNext(iteratorID)

' We are giving the key to iteratorID, allowing us to access the iterator
' iteratorIndex is returned and will be used later

Remember how we looked into what an index is at the beginning of the tutorial, this is where that information comes into play. The iteratorIndex is the object's index. This is very important, once we have an index we can access that object right away like this:

' Assuming the created iterator scanned NPCs

with NPC(index)
  ' here you can access your NPC!
  ' for example: 
  .forecolor \= rgba(255, 0, 0, 255)
end with

' This also works
NPC(index).forecolor \= rgba(255, 0, 0, 255)

Lets return to itrNext. Calling this function returns the first index of you group. Calling it a second time returns the second index of your group. It keeps repeating this pattern until it has succesfully iterated all objects in your group. When its finished, this function returns 0.

' A group is created of all the objects that meet the type, id, and rectangle area requirements
iteratorID \= itrCreate(TYPE, ID, X, Y, WIDTH, HEIGHT)
' This loop is to guarantee we iterate over all the NPCs in the created group
do
    ' We get the index of the object
    iteratorIndex \= itrNext(iteratorID)
    ' If the index is 0, then we are finished iterating and we can end the loop
    if iteratorIndex \= 0 then exit do
    ' Here you can define the custom behavior for the object and access the object safely
loop
' This code will run when the iterator is finished
' Erase the iterator once we are finished using it
 call BErase(0, iteratorID)

  
We are almost finished, there is one last thing we have to do. When you create an iterator you have to make sure to erase it when you are finished with it. If you create too many iterators without erasing them, the game will stop working. **If you ever create an iterator and the iterators suddenly stopped working, that means you forgot to erase an iterator.** You use the function BErase() to erase an iterator.  

## Reference

Documentation to:

[itrCreate](https://wohlsoft.ru/pgewiki/Functions_(TeaScript)#ItrCreate)

[itrNext](https://wohlsoft.ru/pgewiki/Functions_(TeaScript)#ItrNext)

[Berase](https://wohlsoft.ru/pgewiki/Functions_(TeaScript)#BErase)  

| Name | Description |
| --- | --- |
| `Type` | The type of objects the iterator will iterate. It can be one of the following:
1: Blocks

2: NPCs

3: Background Objects

4: Liquids

5: Warps

6: Effects

11: Blocks (On-screen)

12: NPCs (Active)

 |
| `ID` | The ID filter of the iterator. Set this to 0 to disable ID filtering. Set any other number to enable it.  

If `Type` is `Blocks`, `NPCs`, `Effects` or `Background Objects`, this value stands for the same image-file ID (E.g: use `10` for `block-10`)  

If `Type` is `Liquids`, it stands for any value of the [Liquids](https://wohlsoft.ru/pgewiki/Liquid_(TeaScript)#Types_of_liquids) table.  

If `Type` is `Warps`, it stands for the type of warps (1: Instant Warp, 2: Pipe, 3: Door, 4: Loop)

 |

  

## Legacy

The iterator **returns the ID** of the found object within its rectangular region, so you can check the presence of an object and interact according it.

ItrCreate(type, id, x, y, w, h)

Use these IDs if you are using a Liquid iterator.

| ID | Type |
| --- | --- |
| `1` | Water |
| `2` | Quicksand |
| `3` | Custom Water |
| `4` | Gravitational Field |
| `5` | Event Once (Player) |
| `6` | Event Always (Player) |
| `7` | Event Once (Player/NPC) |
| `8` | Event Always (Player/NPC) |
| `9` | Click Event |
| `10` | Collision Script |
| `11` | Click Script |
| `12` | Collision Event |
| `13` | Air |
| `14` | Event Once (NPC) |
| `15` | Event Always (NPC) |
| `16` | NPC Hurting Field |
| `17` | Sub Area |

| Name | Description |
| --- | --- |
| `Type` | The type of objects the iterator will iterate. It can be one of the following:
1: Blocks

2: NPCs

3: Background Objects

4: Liquids

5: Warps

6: Effects

11: Blocks (On-screen)

12: NPCs (Active)

 |
| `ID` | The ID filter of the iterator. Set this to 0 to disable ID filtering. Set any other number to enable it.  

If `Type` is `Blocks`, `NPCs`, `Effects` or `Background Objects`, this value stands for the same image-file ID (E.g: use `10` for `block-10`)  

If `Type` is `Liquids`, it stands for any value of the [Liquids](https://wohlsoft.ru/pgewiki/Liquid_(TeaScript)#Types_of_liquids) table.  

If `Type` is `Warps`, it stands for the type of warps (1: Instant Warp, 2: Pipe, 3: Door, 4: Loop)

 |
| `X` | Stands for the x-position of the iterator. |
| `Y` | Stands for the y-position of the iterator. |
| `W` | Stands for the width of the iterator. The iterator only will iterate through objects within the given rectangular region |
| `W` | Stands for the height of the iterator. The iterator only will iterate through objects within the given rectangular region |

ItrNext(ItrID)

To get the next object of the iterator. Returns the object ID. If the object does not exist, the return value will be 0 and the iterator will be destroyed.

| Name | Description |
| --- | --- |
| `ItrID` | ID of the iterator. If the iterator does not exist or the iteration has been ended, the function will return 0. |

  

### Getting started with Iterators

Before to get into iterators, make sure you can dominate the \[[Structure in TeaScript](https://wohlsoft.ru/pgewiki/TeaScript_Syntax#Loops%7CLoop)\], otherwise this may get really confusing.

To use an iterator you need at least two variables. The first one will store the iterator, and the second one will store the ID of the found object. Here's a basic syntax of an iterator. In this example, we will create an iterator around the player's body.

dim i as integer
dim j as integer
do
    i \= itrcreate(11, 0, char(1).x\-1, char(1).y\-1, char(1).pwidth+2, char(1).pheight+2)    'The iterator is slightly bigger than the player hitbox
    do
        j \= itrnext(i)    
        if j \> 0 then    'If an object was found (in this case, a block). Since \`j\` returns the ID of the object, it will be greater than 0.
            call showmsg("The player is touching a block! ")
        else
            exit do      'However if any object was found, we'll end the loop and try again the next frame
        end if
    loop
    call berase(0, i)    'This destroys the iterator on every frame
    call sleep(1)
loop

This may seem a bit hard to understand at first, but don't worry! We'll get into each line. First you may be wondering, why is there **nested loop**? It is because the first loop **runs the code every frame**, while the second loop assures our iterator can iterate with **various objects** at the same frame. The second loop is optional, but if we don't include it the iterator will process **one** object per frame (which may be convenient or not, depending of what we want to do). Don't worry, we'll get into this later.

Now let's look at line 5, `itrcreate`. The first parameter is 11 because we want it to iterate with **blocks** on the current screen (we could have also use 1 and it would produce the same result). The reason why the iterator is slightly bigger than the player hitbox is because we also wanted to check if the player is near to a block, not only if he's overlapping one.

In line 14, with `berase` we're **destroying** the iterator on every frame. This is **really important** because if we don't destroy the iterator, after 255 frames it will **stop working** until you restart the game. If you think your code is right but for some reason the iterator is not working, you may need to restart the game.

### Iterator that only detect an object per frame

There may be some cases where you want the iterator only process a object per frame. For example, if you're coding a fireball you need it to kill it only one enemy at the same time. In this scenario you don't need to use a loop (nested loop) for the iterator. In this example the iterator will show a message with the ID of the found BGO. Try overlapping two BGOs and make the player touch both of them, you'll notice how the iterator only returns the ID of the nearer BGO.

dim i as integer
dim j as integer
do
    i \= itrcreate(3, 0, char(1).x, char(1).y, char(1).pwidth, char(1).pheight)
    j \= itrnext(i)
    if j \> 0 then
        call showmsg("BGO detected!\\nID: " & cstr(j) )
    end if
    call berase(0, i)
    call sleep(1)
loop

In contrast with out previous example that used a nested loop, it would have shown two or more messages at the same time (The amount of messages depends on how many objects are overlapping), while in this example it only processes only one per frame (the nearer object).

### Using iterators

In real scenarios, you need iterators do more than just detecting the presence of a single object, you want interact with it. In this example, the player will become transparent every time it touches a block.

dim i as integer
dim j as integer
dim playerTurnTransparent as integer    'We will use this variable to let the game know the player can become transparent
do 
    'Our well known iterator code
    with char(1)
        i \= itrcreate(11, 0, .x\-1, .y\-1, .pwidth+2, .pheight+2)    'The iterator is slightly bigger than the player to detect near blocks
    end with     
    do
        j \= itrnext(i)
        if j \> 0 then
            playerTurnTransparent \= 2    
        else
            exit do
        end if
    loop
    call berase(0, i)
    
    'Makes player transparent
    if playerTurnTransparent \> 0 then
        char(1).forecolor\_a \= 125    'This stands for the alpha channel. Remember it's a number between 0 and 255
        playerTurnTransparent \= playerTurnTransparent \- 1
    else
        char(1).forecolor\_a \= \-1     'This is the default value, which is the same as if it was 255
    end if
    call sleep(1)
loop
