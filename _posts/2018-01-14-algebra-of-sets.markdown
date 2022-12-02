---
layout:	post
title:	Algebra of sets
date:	2018-01-14 00:00:00 -0600
categories:	math algebra
---
A note about the algebra of sets. This note informs [Boolean Algebra Notes (Jan 4, 2018)]({% post_url 2018-01-04-boolean-algebra-notes %}). The algebra of sets is a somewhat intuitive boolean algebra and it was the study of the algebra of sets that helped me better understand boolean algebra. I was introduced to the idea in NAVEDTRA, but this development is based solely on Whitesitt (1961).

<!--more-->

created on 20180114

last modified 20180114-2008

## Select Bibliography

NAVEDTRA 14142. (1986). Mathematics - Introduction to Statistics, Number Systems, and Boolean Algebra. Pensacola, FL: Naval Education and Training Professional Development and Technology Center. 

Whitesitt, J. E. (1961). Boolean Algebra and its Applications. Reading, MA: Addison-Wesley Publishing Company, Inc.


## Undefined terms
* **element**
* **set**
* **elements** - basic objects in collections and constitute sets
* **the lower case letters a, b, c, ...** - elements
* **the upper case letters A, B, C, ...** - sets
* **E** - an undefined relation between elements and sets
* **=** - two sets are identical if they contain exactly the same elements
* **subset** - a set X is a subset of Y, if X is contained fully in Y, if Y has additional members, then the X is a proper subset Y
* **1** - unity, represents the universal set of all elements under consideration, it is also called the domain of discourse or the fundamental domain, every set is a subset of the universal set
* **0** - null set or empty set, 0 is a subset of every other set
* **{}** the unit set - since the algebra of sets is about sets, not individual members, the unit set exists to indicate individual members
* **X'** - the complement of X, all elements in the universal set that are not in X
* **0'** - 1
* **1'** - 0

## Combinations of sets

* X + Y - union, the set of all elements in either X or Y, or both X and Y
* XY - intersection, the set of all elements in both X and Y

* X + X' = 1 and XX' = 0, by the definitions of (+), (.), and (')

## Theorem 1

If m is in 1, m is in one and only one of XY, X'Y, XY', X'Y'

Proof - if m is in X, then m is not in X' and, if m is in Y, it is not in Y'
so if m is in X, then m is in either XY, or XY'
or if m is in X', then m is in either X'Y, or X'Y' QED.

## Fundamental Laws

### Commutative Laws
* 1a. XY = YX
* 1b. X + Y = Y + X

### Associative Laws
* 2a. X(YZ) = (XY)Z
* 2b. X + (Y + Z) = (X + Y) + Z

### Distributive Laws
* 3a. X(Y + Z) = XY + XZ
* 3b. X + YZ = (X + Y)(X +Z)

### Tautology
* 4a. XX = X
* 4b. X + X = X

### Absorption Laws
* 5a. X(X + Y) = X
* 5b. X + XY = X

### Complementation Laws
* 6a. XX' = 0
* 6b. X + X' = 1

### Law of Double Complementation
* 7. (X')' = X

### de Morgan's Laws
* 8a. (XY)' = X' + Y'
* 8b. (X + Y)' = X'Y'

### Operations on 0 and 1
* 9a. 0X = 0
* 9b. 1 + X = 1  
* 10a. 1X = X
* 10b. 0 + X = X
* 11a. 0' = 1
* 11b. 1' = 0

Principle of duality - exchange every (+) and (.) and every 1 and 0, in an identity and the result remains an identity.

**monomial** - a single letter representing a set with or without a prime or an indicated product of two or more symbols representing the intersection of these sets.

**polynomial** - an indicated sum of monomials, each of which is called a term of the polynomial. The polynomial represents the union of the sets.

**factor** - any set that is part of an intersection of sets.

**linear factor** - a single letter with or without a prime, or a sum of such symbols.

### factoring and expanding

Use the two forms of the distributive law and other laws to expand or factor a polynomial into simplified form.

```
Expand (X + Y)(Z' + W) into a polynomial

(X + Y)(Z' + W) = (X + Y)Z' + (X + Y)W, by (3a), X = (X + Y), (Y + Z) = (Z' + W) 
                = Z'(X + Y) + W(X + Y), by (1a)
                = Z'X + Z'Y + WX + WY,  by (3a)
```

Factor AC + AD + BC + BD into linear factors

```
AC + AD + BC + BD = A(C + D) + B(C + D), by (3a)
                  = (C + D)A + (C + D)B, by (1a), X = (C + D), Y = A, Z = B
                  = (C + D)(A + B),      by (3a)
                  = (A + B)(C +D),       by (1a)
```

Note that 3a is not sufficient in all cases, but 3b is.

Factor XY + ZW into linear factors

```
XY + ZW = (XY + Z)(XY + W),             by (3b), X = XY, YZ = ZW
        = (Z + XY)(W + XY),             by (1b)
        = (Z + X)(Z + Y)(W + X)(W + Y), by (3b)
```

### Inspection
by 3a - form all possible products of terms in the left factor by the terms in the right factor.

`(X + Y)(Z' + W) = XZ' + XW + YZ' + YW`

by 3b - form all possible sums of terms in the left factor by the terms in the right factor.

`XY + ZW = (X + Z)(X + W)(Y + Z)(Y + W)`

## Theorem 2

*  X + X'Y = X + Y

```
X + X'Y = (X + X')(X + Y), by (3b)
        = 1(X + Y),        by (6b)
        = X + Y,           by (10a)
```

**Simplest form** - that form which requires the use of the least number of symbols where each operation is a symbol, each leter representing a set is a symbol, and each pair of parenthesis is a symbol.

* `X(Y + Z')` consists of seven symbols `(X, Y, Z, ., +, ', and ())`
* `XY + YZ'` consists of eight symbols `(X, Y, Y, Z, ', ., +, and .)`

In an expression where a prime appears outside of a parenthesis or other grouping symbol, it is usually necessary to apply de Morgan's laws (which are easily extended to more than two sums or products).

```
(A + B + C)' = [(A + B) + C]'
             = (A + B)'C' = A'B'C'
             
(ABC)'       = A' + B' + C'`
```

*post added 2022-12-01 15:01:00 -0600*