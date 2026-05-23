# Custom Extra Scripts (TeaScript)

> 来源: <https://wohlsoft.ru/pgewiki/Custom_Extra_Scripts_(TeaScript)>

---

This is a list of useful custom scripts made for the TeaScript language. Feel free to use any of the scripts you find here, and contribute any script that you may find useful!

For an explanation on how to create a custom script, check [here](https://wohlsoft.ru/pgewiki/TeaScript_Syntax#Scripts).

  

## Adding Your Own Script

This is a template so you can add your own functions to this list.

### Name of Script

Created by: user

Requisites: optional

  
Here is an explanation or notes of the function. Make sure to underline number values, and italicize string values.

`returnval = funcname(number, *string)*`

script funcname(a as double, b as string, return double)
end script

  

## Conversions

### rad2deg

Created by: SetaYoshi

Requisites: None

  
Converts a radian value to degrees

`degrees = rad2deg(radians*)*`

script rad2deg(r as double, return double)
	return r\*180/pi
end script

### deg2rad

Created by: SetaYoshi

Requisites: None

  
Converts a degree value to radians

`radians = deg2rad(degrees*)*`

script deg2rad(r as double, return double)
	return r\*pi/180
end script

  

### rec2polr

Created by: SetaYoshi

Requisites: None

  
Returns the magnitude in polar form of rectangular numbers

`r = rec2polr(x, y*)*`

script rec2polr(x as double, y as double, return double)
	return sqr(x^2 + y^2)
end script

### rec2pola

Created by: SetaYoshi

Requisites: None

  
Returns the angle in polar form of rectangular numbers

`a = rec2pola(x, y*)*`

script rec2pola(x as double, y as double, return double)
	return 2\*pi\*getangle(x, y)
end script

### rec2polad

Created by: SetaYoshi

Requisites: None

  
Returns the angle in degrees in polar form of rectangular numbers

`a = rec2polad(x, y*)*`

script rec2polad(x as double, y as double, return double)
	return 360\*getangle(x, y)
end script

### pol2recx

Created by: SetaYoshi

Requisites: None

  
Returns the x component in rectangular form from polar numbers

`x = pol2recx(r, a*)*`

script pol2recx(r as double, a as double, return double)
	return r\*cos(a)
end script

### pol2recy

Created by: SetaYoshi

Requisites: None

  
Returns the x component in rectangular form from polar numbers

`y = pol2recy(r, a*)*`

script pol2recy(r as double, a as double, return double)
	return r\*sin(a)
end script

### podl2recx

Created by: SetaYoshi

Requisites: None

  
Returns the x component in rectangular form from polar numbers in degrees

`x = pold2recx(r, a*)*`

script pold2recx(r as double, a as double, return double)
	return r\*cos(a\*180/pi)
end script

### pold2recy

Created by: SetaYoshi

Requisites: None

  
Returns the x component in rectangular form from polar numbers

`y = pold2recy(r, a*)*`

script pol2recy(r as double, a as double, return double)
	return r\*sin(a\*180/pi)
end script

### tolowercase

Created by: SetaYoshi

Requisites: An user-variable called *tmp*

  
Converts all letters to lower case.

*lowertext* `= tolowercase(*text)*`

script toLowerCase(inp as string, return string)
  str(tmp) \= ""
  dim i as integer
  for i \= 1 to len(inp) step 1
    if asc(mid(inp, i, 1)) \>= 65 and asc(mid(inp, i, 1)) <= 90 then
      str(tmp) \= str(tmp) & chr(asc(mid(inp, i, 1)) + 32)
    else
      str(tmp) \= str(tmp) & mid(inp, i, 1)
    end if
  next
  return str(tmp)  
end script

### touppercase

Created by: SetaYoshi

Requisites: An user-variable called *tmp*

  
Converts all letters to uppercase.

*uppertext* `= touppercase(*text)*`

script toUpperCase(inp as string, return string)
  str(tmp) \= ""
  dim i as integer
  for i \= 1 to len(inp) step 1
    if asc(mid(inp, i, 1)) \>= 97 and asc(mid(inp, i, 1)) <= 122 then
      str(tmp) \= str(tmp) & chr(asc(mid(inp, i, 1)) \- 32)
    else
      str(tmp) \= str(tmp) & mid(inp, i, 1)
    end if
  next
  return str(tmp)
end script

  

### getColorC

Created by: SetaYoshi

Requisites: none

  
Converts a SMBX Color and returns a component.

For component type use:

-   1: alpha value
-   2: red value
-   3: green value
-   4: blue value

component`= getColorC(SMBX Color, component type*)*`

script getColorC(n as double, t as double, return double)
    return int(n/(256^(4 \- t)) \- 256\*int(n/(256^(4 \- t + 1))))
end script

### name2key

Created by: SetaYoshi

Requisites: none

  
Converts the name of a key to a number to be used by the `keypress` function . Use the player value to choose what player (1: player 1, 2:player 2)

keypressvalue =`name2key(*name*, player*)*`

script name2key(x as string, p as double, return double)
  select case x
    case "pause" return \-10 \- 10\*(p \- 1)
    case "right" return \-11 \- 10\*(p \- 1)
    case "left" return \-12 \- 10\*(p \- 1)
    case "down" return \-13 \- 10\*(p \- 1)
    case "up" return \-14 \- 10\*(p \- 1)
    case "altjump" return \-15 \- 10\*(p \- 1)
    case "jump" return \-16 \- 10\*(p \- 1)
    case "run" return \-17 \- 10\*(p \- 1)
    case "altrun" return \-18 \- 10\*(p \- 1)
    case "select" return \-19 \- 10\*(p \- 1)
  end select
end script

### convertify

Created by: \_FyreNova

Requisites: none

Converts units. If you use `"convert"`, it will convert **from** frames **to** the unit. If you use `"deconvert"`, it will convert **from** the unit **to** frames. Units can be seconds, milliseconds, and minutes.

secondtimer = `convertify(3,"seconds","convert")`

script convertify(a as double,b as string,c as string,return double)
    select case c
    case "convert"
        select case b
        case "seconds"
            return round(a\*65,0)
        case "minutes"
            return round(a\*65\*60,0)
        case "milliseconds"
            return round(a\*65\*.001,0)
        end select
    case "deconvert"
        select case b
        case "seconds"
            return round(a/65,0)
        case "minutes"
            return round(a/65/60,0)
        case "milliseconds"
            return round(a/65/.001,0)
        end select
    end select
end script

## Math Functions

### logn

Created by: SetaYoshi

Requisites: None

  
Does a log operation at any base

`y = logn(x, base*)*`

script logn(x as double, b as double, return double)
   return log(x)/log(b)
end script

### sqrn

Created by: SetaYoshi

Requisites: None

  
Does a root at any base

`y = sqrn(x, base*)*`

script sqrn(x as double, n as double, return double)
	return x^(1/n)
end script

  

### factorial

Created by: SetaYoshi

Requisites: None

  
Performs a factorial operation

`y = factorial(x*)*`

script factorial(x as double, return double)
	dim i as integer
	dim v as double \= 1
	for i \= 1 to x
		v \= v\*i
	next
	return v
end script

  

### modul

Created by: SetaYoshi

Requisites: None

  
A more accurate modulus operator

`y = modul(x, n*)*`

script modul(x as double, n as double, return double)
	if n \= 0 then return 0
	if n \> 0 and x \> 0 then return x \- n\*fix(x/n)
	if n \> 0 then return n \- abs(x \- n\*fix(x/n))
	if x \> 0 then return x + n\*(fix(x/abs(n)) + 1)
	return	abs(n\*fix(x/n)) + x	
end script

### lin\_interp

Created by: SetaYoshi

Requisites: None

  
Performs a linear interpolation. Given 2 pairs of points, it will find a missing y with a given x

`yn = lin_interp(x1, y1, x2, y2, xn*)*`

script lin\_interp(x1 as double, y1 as double, x2 as double, y2 as double, x as double, return double)

return y1 + (x \- x1)\*(y2 \- y1)/(x2 \- x1)

end script

  

### distance

Created by: SetaYoshi

Requisites: None

  
Finds the distance between 2 given points

`r = distance(x1, y1, x2, y2*)*`

script distance(x1 as double, y1 as double, x2 as double, y2 as double, return double)

  return sqr((x1 \- x2)^2 + (y1 \- y2)^2)

end script

  

### min

Created by: SetaYoshi

Requisites: None

  
Returns the smaller number

`y = min(a, b*)*`

script min(a as double, b as double, return double)
  if a < b then return a
  return b
end script

  

### max

Created by: SetaYoshi

Requisites: None

  
Returns the larger number

`y = max(a, b*)*`

script max(a as double, b as double, return double)
  if a \> b then return a
  return b
end script

### midd

Created by: SetaYoshi

Requisites: None

  
Returns the middle number

`y = midd(a, b, c*)*`

script midd(a as double, b as double, c as double, return double)
	if (a \> b and b \> c) or (c \> b and b \> a) then return b
	if (a \> c and c \> b) or (b \> c and c \> a) then return c
    return a
end script

  

### isInteger

Created by: SetaYoshi

Requisites: None

  
Returns the middle number

`y = midd(a, b, c*)*`

script midd(a as double, b as double, c as double, return double)
	if (a \> b and b \> c) or (c \> b and b \> a) then return b
	if (a \> c and c \> b) or (b \> c and c \> a) then return c
    return a
end script

## RNG Functions

### rand

Created by: SetaYoshi

Requisites: None

  
Returns a random number between 2 numbers

`x = rand(min, max*)*`

script rand(min as double, max as double, return double)
  return rnd\*(max \- min) + min
end script

### randInt

Created by: SetaYoshi

Requisites: None

  
Returns a random integer between 2 numbers

`x = randInt(min, max*)*`

script randInt(min as double, max as double, return double)
  return round(rnd\*(max \- min) + min, 0)
end script

### randSub

Created by: SetaYoshi

Requisites: None

  
Returns a random character in a string

*char* `= randSub(*text)*`

script randSub(inp as string, return string)
  return mid(inp, randInt(1, len(inp)), 1)
end script

### randBool

Created by: SetaYoshi

Requisites: None

  
Randomly returns -1 or 0

*char* `= randBool(*text)*`

script randBool(return string)
  return rnd <= 0.5
end script

## Range Functions

### coil

Created by: SetaYoshi

Requisites: None

  
Forces a number to loop between a range

`y = coil(min, max, n*)*`

script coil(a as double, b as double, n as double, return double)
    return ((a \- b) mod (n \- b + a)) + b
end script

### wrap

Created by: SetaYoshi

Requisites: None

  
A modified version of coil that is more practical for counting

`y = coil(min, max, n*)*`

script coil(a as double, b as double, n as double, return double)
    return ((a \- b \- 1) mod (n \- b + a)) + b
end script

### tie

Created by: SetaYoshi

Requisites: None

  
A less flexible form of coil

`y = tie(min, max, n*)*`

script tie(a as double, b as double, n as double, return double)
	if n < a then return b \- (a \- n)
	if n \> b then return a \- (b \- n)
	return n
end script

### knot

Created by: SetaYoshi

Requisites: None

  
An alternate form of tie that is more practical for counting.

`y = knot(min, max, n*)*`

script knot(a as double, b as double, n as double, return double)
	if n < a then return b \- (a \- n \- 1)
	if n \> b then return a \- (b \- n + 1)
	return n
end script

### brace

Created by: SetaYoshi

Requisites: None

  
When the number overflows, it will snap to the opposite boundary

`y = brace(min, max, n*)*`

script brace(a as double, b as double, n as double, return double)
	if n < a then return b
	if n \> b then return a
	return n
end script

### clamp

Created by: SetaYoshi

Requisites: None

  
When the number overflows, it will snap to the current boundary

`y = clamp(min, max, n*)*`

script clamp(a as double, b as double, n as double, return double)
	if n < a then return a
	if n \> b then return b
	return n
end script

### tween

Created by: \_FyreNova

Requisites: None

  
Returns the tweened number between `x` and `y`, using `z` as its percentage.

`value = tween(number1,number2,decimal)`

script tween(x as double, y as double, z as double, return double)
    if x < y
		return ((y\-x)\*z)+x
    else
		return ((x\-y)\*z)+y
    end if
end script

  

  

## Trig

### Basic

#### c\_sin

Created by: SetaYoshi

Requisites: **modul, factorial**

  
Using taylor expansion to calculate sin

`y = c_sin(x*)*`

script c\_sin(x as double, return double)
	dim n as integer
	dim v as double
	dim z as double \= modul(x, 2\*pi)
	for n \= 0 to 10
		v \= v + (\-1)^n/factorial(2\*n + 1)\*z^(2\*n + 1)
	next
	return v
end script

#### c\_cos

Created by: SetaYoshi

Requisites: **modul, factorial**

  
Using taylor expansion to calculate cos

`y = c_cos(x*)*`

script c\_cos(x as double, return double)
	dim n as integer
	dim v as double
	dim z as double \= modul(x, 2\*pi)
	for n \= 0 to 10
		v \= v + (\-1)^n/factorial(2\*n)\*z^(2\*n)
	next
	return v
end script

#### c\_cos

Created by: SetaYoshi

Requisites: **modul, factorial**

  
Using taylor expansion to calculate cos

`y = c_cos(x*)*`

script c\_cos(x as double, return double)
	dim n as integer
	dim v as double
	dim z as double \= modul(x, 2\*pi)
	for n \= 0 to 10
		v \= v + (\-1)^n/factorial(2\*n)\*z^(2\*n)
	next
	return v
end script

#### c\_tan

Created by: SetaYoshi

Requisites: **modul, factorial**

  
Using taylor expansion to calculate tan

`y = c_tan(x*)*`

script c\_tan(x as double, return double)
	dim n as integer
	dim z as double \= modul(x, 2\*pi)	
	dim c as double
	dim s as double
	for n \= 0 to 10
		c \= c + (\-1)^n/factorial(2\*n)\*z^(2\*n)
	next
	if c \= 0 then return 0	
	for n \= 0 to 10
		s \= s + (\-1)^n/factorial(2\*n + 1)\*z^(2\*n + 1)
	next
	return s/c
end script

#### c\_csc

Created by: SetaYoshi

Requisites: **modul, factorial**

  
Using taylor expansion to calculate csc

`y = c_csc(x*)*`

script c\_csc(x as double, return double)
	dim n as integer
	dim v as double
	dim z as double \= modul(x, 2\*pi)
	for n \= 0 to 10
		v \= v + (\-1)^n/factorial(2\*n + 1)\*z^(2\*n + 1)
	next
	if v \= 0 then return 0
	return 1/v
end script

#### c\_sec

Created by: SetaYoshi

Requisites: **modul, factorial**

  
Using taylor expansion to calculate sec

`y = c_sec(x*)*`

script c\_sec(x as double, return double)
	dim n as integer
	dim v as double
	dim z as double \= modul(x, 2\*pi)
	for n \= 0 to 10
		v \= v + (\-1)^n/factorial(2\*n)\*z^(2\*n)
	next
	if v \= 0 then return 0
	return 1/v
end script

#### c\_cot

Created by: SetaYoshi

Requisites: **modul, factorial**

  
Using taylor expansion to calculate sec

`y = c_cot(x*)*`

script c\_cot(x as double, return double)
	dim n as integer
	dim z as double \= modul(x, 2\*pi)	
	dim c as double
	dim s as double
	for n \= 0 to 10
		s \= s + (\-1)^n/factorial(2\*n + 1)\*z^(2\*n + 1)
	next
	if s \= 0 then return 0
	for n \= 0 to 10
		c \= c + (\-1)^n/factorial(2\*n)\*z^(2\*n)
	next
	return c/s
end script

### Inverse Trig

#### arcsin

Created by: SetaYoshi

Requisites: **factorial**

  
Using taylor expansion to calculate arcsin

`y = arcsin(x*)*`

script c\_arcsin(x as double, return double)
	dim n as integer
	dim v as double
	if abs(x) \> 1 then return 0
	for n \= 0 to 10
		v \= v + factorial(2\*n)/(4^n\*factorial(n)^2\*(2\*n + 1))\*x^(2\*n + 1)
	next
	return v
end script

#### arccos

Created by: SetaYoshi

Requisites: **factorial**

  
Using taylor expansion to calculate sec

`y = arccos(x*)*`

script c\_arccos(x as double, return double)
	dim n as integer
	dim v as double
	if abs(x) \> 1 then return 0
	for n \= 0 to 10
		v \= v + factorial(2\*n)/(4^n\*factorial(n)^2\*(2\*n + 1))\*x^(2\*n + 1)
	next
	return pi/2 \- v
end script

  

#### arctan

Created by: SetaYoshi

Requisites: **factorial**

  
Using taylor expansion to calculate sec

`y = arctan(x*)*`

script arctan(x as double, return double)
	dim n as integer
	dim v as double
	dim z as double \= modul(x, 2\*pi)
	for n \= 0 to 10
		v \= v + (\-1)^n/(2\*n + 1)\*z^(2\*n + 1)
	next
	return v
end script

#### arccsc

Created by: SetaYoshi

Requisites: **factorial**

  
Using taylor expansion to calculate sec

`y = arccsc(x*)*`

script c\_arccsc(x as double, return double)
	dim n as integer
	dim v as double
	if abs(x) \> 1 then return 0
	dim z as double \= 1/x
	for n \= 0 to 10
		v \= v + factorial(2\*n)/(4^n\*factorial(n)^2\*(2\*n + 1))\*z^(2\*n + 1)
	next
	return v
end script

#### arcsec

Created by: SetaYoshi

Requisites: **factorial**

  
Using taylor expansion to calculate sec

`y = arcsec(x*)*`

script arcsec(x as double, return double)
	dim n as integer
	dim v as double
	if abs(x) \> 1 then return 0
	dim z as double \= 1/x
	for n \= 0 to 10
		v \= v + factorial(2\*n)/(4^n\*factorial(n)^2\*(2\*n + 1))\*z^(2\*n + 1)
	next
	return v
end script

#### arccot

Created by: SetaYoshi

Requisites: **factorial**

  
Using taylor expansion to calculate sec

`y = arccot(x*)*`

script arccot(x as double, return double)
	dim n as integer
	dim v as double
	dim z as double \= modul(x, 2\*pi)
	for n \= 0 to 10
		v \= v + (\-1)^n/(2\*n + 1)\*z^(2\*n + 1)
	next
	return pi/2 \- v
end script

### Hyperbolic

  

#### sinh

Created by: SetaYoshi

Requisites: none

  
The hyperbolic form of sin

`y = sinh(x*)*`

script c\_sinh(x as double, return double)
	return 0.5\*(exp(x) \- exp(\-x))
end script

#### cosh

Created by: SetaYoshi

Requisites: none

  
The hyperbolic form of cos

`y = cosh(x*)*`

script cosh(x as double, return double)
	return 0.5\*(exp(x) + exp(\-x))
end script

#### tanh

Created by: SetaYoshi

Requisites: none

  
The hyperbolic form of tan

`y = tan(x*)*`

script tanh(x as double, return double)
	return (exp(x) \- exp(\-x))/(exp(x) \- exp(\-x))
end script

#### csch

Created by: SetaYoshi

Requisites: none

  
The hyperbolic form of csc

`y = csc(x*)*`

script csch(x as double, return double)
	return 2/(exp(x) \- exp(\-x))
end script

#### sech

Created by: SetaYoshi

Requisites: none

  
The hyperbolic form of sec

`y = sech(x*)*`

script sech(x as double, return double)
	return 2/(exp(x) + exp(\-x))
end script

#### coth

Created by: SetaYoshi

Requisites: none

  
The hyperbolic form of sec

`y = coth(x*)*`

script coth(x as double, return double)
	return (exp(x) \- exp(\-x))/(exp(x) \- exp(\-x))
end script

### Hyperbolic Inverse

#### arcsinh

Created by: SetaYoshi

Requisites: none

  
The hyperbolic inverse form of sin

`y = arcsinh(x*)*`

script arcsinh(x as double, return double)
    return log(x + sqr(x^2 + 1))
end script

#### arccosh

Created by: SetaYoshi

Requisites: none

  
The hyperbolic inverse form of cos

`y = arccosh(x*)*`

script arccosh(x as double, return double)
    return log(x + sqr(x^2 \- 1))
end script

#### arctanh

Created by: SetaYoshi

Requisites: none

  
The hyperbolic inverse form of tan

`y = arctanh(x*)*`

script arctanh(x as double, return double)
    return 0.5\*log((1 + x)/(1 \- x))
end script

#### arccsch

Created by: SetaYoshi

Requisites: none

  
The hyperbolic inverse form of csc

`y = arcscsh(x*)*`

script arccsch(x as double, return double)
    if x \= 0 then return 0
    return log((1 + sqr(1 + x^2))/x)
end script

#### arcsech

Created by: SetaYoshi

Requisites: none

  
The hyperbolic inverse form of sec

`y = arcsech(x*)*`

script c\_arcsech(x as double, return double)
    if x \= 0 then return 0
    return log((1 + sqr(1 \- x^2))/x)
end script

#### arccoth

Created by: SetaYoshi

Requisites: none

  
The hyperbolic inverse form of cot

`y = arccoth(x*)*`

script c\_arccoth(x as double, return double)
    if x \>= \-1 and x <= 1 then return 0
    return 0.5\*log((x + 1)/(x \- 1))
end script

## Detectors

### onscreen

Created by: YvajekK  
Based on SetaYoshi's script

Requisites: None

  
Detects if the object is on the screen. Returns:

-   0: when the object isn't visible
-   1: when the object is visible and the screen isn't splitted
-   2: when the object is visible on the second player's screen

`isvisible = onscreen(x, y, width, height)`

script onscreen(x as double, y as double, w as double, h as double, return integer)
    dim scrw as integer
    dim scrh as integer
    if sysval(scrsplitstyle) \= 0 then
        scrw \= 800
        scrh \= 600
    elseif sysval(scrsplitstyle) \= 1 or sysval(scrsplitstyle) \= 2 then
        scrw \= 800
        scrh \= 300
    else
        scrw \= 400
        scrh \= 600
    end if
    if x <= sysval(player1scrx) + scrw and x + w \>= sysval(player1scrx) and y <= sysval(player1scry) + scrh and y + h \>= sysval(player1scry) then
        return 1
    elseif x <= sysval(player2scrx) + scrw and x + w \>= sysval(player2scrx) and y <= sysval(player2scry) + scrh and y + h \>= sysval(player2scry) then
        return 2
    end if
    return 0
end script
