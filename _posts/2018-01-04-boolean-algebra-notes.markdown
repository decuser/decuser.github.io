---
layout:	post
title:	Boolean Algebra Notes
date:	2018-01-04 00:00:00 -0600
categories:	math algebra boolean
---
This set of notes is a synthesis of many sources. I was having a very difficult time understanding some of the simplifications that were being done in videos and texts on digital logic, so I dug a little deeper until I had enough of a grasp to appreciate the elegance of the boolean logic system.

<!--more-->

Originally created 20171213

Last modified 20180104-2008

## Overview

The set of notes is comprised in three parts:

The first is what I eventually came to after the struggle and is based on the work of Whitesitt, who based his development on Huntington's 1904 postulates. 

The second is based on the work of Claude Shannon, who used Huntington's 1933 postulates, among others. 

The third is an amalgam of others, but is inspired by Roychoudhury's lecture on youtube - her delivery is somewhat monotonous, but the content is excellent. 

Each note was constructed separately and are combined here for convenience of reference only. They aren't complete, consistent, or without duplication, but I found the process of creating them helpful to my own understanding - YMMV.

## Select Bibliography

Wikipedia. (2017). Boolean Algebra. Retrieved December 1, 2017, from [https://en.wikipedia.org/wiki/Boolean_algebra](https://en.wikipedia.org/wiki/Boolean_algebra)

Crowe, J., Hayes-Gill, B. (1998). Introduction to Digital Electronics. Oxford: Newnes.

Gregg, J. (1998). Ones and Zeros: Understanding Boolean Algebra, Digital Circuits, and the Logic of Sets. Hoboken, NJ: John Wiley & Sons.

Huntington, E. V. (1904). Sets of Independent Postulates for the Algebra of Logic. Transactions of the American Mathematical Society, 5(3), 288-309. Retrieved from [http://www.jstor.org/stable/1986459](http://www.jstor.org/stable/1986459).

Huntington, E. V. (1933). New Sets of Independent Postulates for the Algebra of Logic, with Special Reference to Whitehead and Russell's Principia Mathematica. Transactions of the American Mathematical Society, 35(1933), 274-304.

Levitz, K., & Levitz, H. (1979). Logic and Boolean Algebra. Woodbury, NY: Barron's Educational Series, Inc.

NAVEDTRA 14142. (1986). Mathematics - Introduction to Statistics, Number Systems, and Boolean Algebra. Pensacola, FL: Naval Education and Training Professional Development and Technology Center. 

Roychoudhury, D. (2008) Lecture 6 - Boolean Algebra. Kharagpur: NPTEL. Video available at [https://www.youtube.com/watch?time_continue=1274&v=K73N9ES_8nI](https://www.youtube.com/watch?time_continue=1274&v=K73N9ES_8nI) 

Shannon, C. E. (1936). A Symbolic Analysis of Relay and Switching Circuits. Master's Thesis: University of Michigan.

Whitesitt, J. E. (1961). Boolean Algebra and its Applications. Reading, MA: Addison-Wesley Publishing Company, Inc.

## First Note

This is a somewhat rigorous development of Boolean Algebra based on Whitesitt (1961), who based his development on Huntington (1904).

### Definitions

1. A binary operation * on a set M is a rule which assigns to each ordered pair (a,b) of elements of M a unique element c = a * b in M.
2. A binary operation * on a set of elements M is associative if and only if for every a, b, and c in M, a * (b * c) = (a * b) * c
3. A binary operation * on a set M is commutative if and only if for every a and b in M, a * b = b * a
4. if * and % are two binary operations on the same set M, * is distributive over % if and only if for every a, b, and c in M, a * (b % c) = (a * b) % (a * c)
5. An element e in a class M is an identity for the binary operation * if and only if a * e = e * a = a for every element a in M.

#### Huntington's Postulates

##### Definition

A class of elements B together with two binary operations (+) and (.) (where a . b will be written ab) is a Boolean algebra if and only if the following postulates hold:

* P1. The operations (+) and (.) are commutative.
* P2. There exist in B distinct identity elements 0 and 1 relative to the operations (+) and (.) respectively.
* P3. Each operation is distributive over the other.
* P4. For every a in B there exists an element a' in B such that a + a' = 1 and aa' = 0

##### Theorems

* T1. Every statement or algebraic identity deducible from the postulates of Boolean algebra remains valid if the operations (+) and (.), and the identity elements 0 and 1 are interchanged throughout. (This theorem is known as the principle of duality).

    Proof. The proof of this theorem follows at once from the symmetry of the posulates with respect fo the two operations and the two identities. That is, if one statement or algebraic expression is obtained from another by a single application of the principle of duality, the second is said to be the dual of the first. Thus, it is clear that the first is also the dual of the second.

* T2. For every element a in a Boolean algebra B, a + a = a and aa = a

    Proof. 
    
    ```
   a = a + 0           by P2
	  = a + aa'         by P4
	  = (a + a)(a + a') by P3
	  = (a + a)(1)      by P4
	  = a + a.          by P2
```

    Similarly,

    ```
	a = a(1).        by P2
	  = a . (a + a') by P4
	  = aa + aa'     by P3
	  = aa + 0       by P4
	  = aa.          by P2
```

    Note that the second proof is the dual of the first, as aa is the dual of a + a. This is the nature of duality and will hold for all theorems. Thus it is only necessary to prove one of each pair of theorems below.

* T3. For each element a in a Boolean algebra B, a + 1 = 1 and a . 0 = 0

    Proof.

    ```
    1 = a + a'          by P4
	  = a + a'(1)       by P2
	  = (a + a')(a + 1) by P3
	  = 1(a + 1)        by P4
	  = a + 1.          by P2
```

TODO add the rest of the proofs.

## Second Note

This note is primarily based on the development of boolean algebra developed in Claude Shannon's master's thesis.

## Definitions

The circuit between any two terminals is either open, having infinite impedence, or closed, having zero impedence.

* Let X take on one of two values (see note for differences in this interpretation and Shannon's):
 * X = 0 when the circuit is open and there is no potential for current to flow
 * X = 1 when the circuit is closed and there is a possibility of current flowing

* Let . represent the series connection of two circuits (see figure 1)
* Let + represent the parallel connection of two circuits (see figure 2)
* Let ' represent the negation of a circuit

### Figure 1. ASCII X AND Y - Series Circuit

```
X . Y

X .--o o-o o--.  Y
```

### Figure 2. ASCII X OR Y - Parallel Circuit

```
X + Y

   /-o X o-\
o-+    +   +-o
   \-o Y o-/
```

Addition and Multiplication (+ and .) are dual operations with respect to 0 and 1, that is, given any expression, a dual exists that can be developed by exchanging every . with +, + with ., 0 with 1, and 1 with 0.

### Postulates

The postulates are shown in pairs to highlight their duality.

* 1a\. 1 + 1 = 1, a closed circuit in parallel with a closed circuit is a closed circuit.
* 1b\. 0 . 0 = 0, an open circuit in series with an open circuit is an open circuit.

* 2a\. 0 . 1 = 1 . 0 = 0, an open circuit in series with a closed circuit in either order is an oepen circuit.
* 2b\. 1 + 0 = 0 + 1 = 1, a closed circuit in parallel with an open circuit in either order is a closed circuit.

* 3a\. 1 . 1 = 1, a closed circuit in series with a closed circuit is a closed circuit.
* 3b\. 0 + 0 = 0, an open circuit in parallel with an open circuit is an open circuit.
* 4\. At any given time, X = 0, or X = 1, exclusively.
* 5\. The negation of a circuit is an inversion of the circuit operation, it will be open if the circuit is originally closed and open if the circuit is originally closed.

The above postulates are sufficient to develop all of the theorems below.

### Theorems

Any theorem in boolean algebra can be proved using perfect induction (verification of all possible cases) or using an algebraic proof built from the definitions, postulates, and other previously proven theorems.

* t1a. x . y = y . x
* t1b. x + y = y + x
* t2a. x . (y . z) = (x . y) . z
* t2b. x + (y + z) = (x + y) + z
* t3a. x + (y . z) = (x + y) . (x + z)
* t3a. x . (y + z) = (x . y) + (x . z)
* t4a. 0 + x = x
* t4b. 1 . x = x
* t5a. 0 . x = 0
* t5b. 1 + x = 1
* t6a. x . x' = 0
* t6b. x + x' = 1
* t7a. 1' = 0
* t7b. 0' = 1
* t8.  (x')' = x 
* t9a. (X . Y . ...)' = X' + Y' + ...
* t9b. (X + Y + ...)' = X' . Y' . ...
* t10a. f(x1, x2, ..., xn) = x1 + f(1, x2, ..., xn) . x'1 ... 

### A Representative Algebraic Proof

t4a. 0 + x = x

```
 x is either 0 or 1; p4
 if x = 0 then 0 + 0 = 0; p3b
 if x = 1 then 0 + 1 = 1; p2b

 therefore 0 + x = x
```

### Discussion
There is a perfect analogy between two value propositional calculus and that given above if the terms represent propositions that can be true (1) or false (0). Shannon works from E. V. Huntington's postulates of symbolic logic:

1. The class K contains at least two distinct elements.
2. If a and b are in the class K then a + b is in the class K.
3. a + b = b + a
4. (a + b) + c = a + (b + c)
5. a + a = a
6. ab + ab' = a

#### Table 1. Symbol interpretation in circuits vs calculus

Symbols | Circuit | Calculus
--- | --- | ---
x | The circuit x | The proposition x
0 | The circuit is open | The proposition is false
1 | The circuit is closed | The proposition is true
x + y | The parallel connection of x, y | The proposition which is true if either x or y is true
x . y | The series connection of x, y | The proposition which is true if both x and y is true
x' | The circuit open when x is closed | The contradictory of proposition x closed, and closed when x is open
= | The circuits open and close | Each proposition implies the other simultaneously

Note: My read of his work seems to indicate that a modern interpretation requires that where Shannon used 0 we should use 1 and where he used plus, we should use multiplication (he looked at things from a hinderance perspective - 0, means no hindrance, which is a closed circuit, and 1, or unity, means complete hindrance, which is an open circuit, and he also saw addition as a series circuit and multiplication as a parallel circuit). 

## Third note

There are several different possible algebra's, the one discussed below was helpful to my understanding.

### Concise Rules

* 1 = True, Present, Universe, On
* 0 = False, Absent, Empty set, Off


* Reflexive Property: 0 = 0; 1 = 1
* NOT: 0' = 1; 1' = 0; 0'' = 0; 1'' = 1; negation, complementation, inversion
* OR:  0 + 0 = 0; 0 + 1 = 1 + 0 = 1; 1 + 1 = 1; disjunction, union, any input is 1, output will be 1
* AND: 0 . 0 = 0; 0 . 1 = 1 . 0 = 0; 1 . 1 = 1; conjunction, intersection - all inputs 1, output will be 1
* The principle of duality: Any expression can be converted from one operation to another changing AND to OR, OR to AND, 1 to 0, and 0 to 1
* Identity laws - operations the identity
 * p1. A . 1 = A; 1 is the multiplicative identity
 * p2. A + 0 = A; 0 is the addition identity
* Inverse laws - operations on the complement
 * p3. A + A' = 1; tautology; true
 * p4. A . A' = 0; contradition; false
* Distributive properties of multiplication and addition
 * p5. A . (B + C) = (A . B) + (A . C)
 * p6. A + (B . C) = (A + B) . (A + C)

### The Boolean Algebra

Boolean algebra may be defined by with:

I.   a set of elements

II.  a set of operators

III. a set of laws

#### I. Set of Elements

Sets in boolean algebra contain any number of elements that are capable of taking on either of two possible values:

`S = {A, B, C, ... N}` where each element can be 1 or 0, high or low, true or false, etc.

#### II. Operators

There are five basic operators that can be combined in an infinite number of secondary operations through composition.

1. NOT, also known as negation, complement, or inverse and signified by ', overbar, or ~

2. AND, also known as conjunction, intersection, or multiplication and signified by ., *, x, or ^

3. OR, also known as disjunction, union, addition, or inclusive or, and signified by +, or v

4. Implication, also known as if-then, or if-only, and signified by ->

5. Bi-implication, also known as if-and-only-if, or iff, and signified by <->

These operations (and any others) are expressible in the form of truth tables, through the process of perfect induction, enumerating all possible outcomes


A | B | A AND B | A OR B | A -> B | A <-> B | A | NOT A
:---: | :---: | :---: | :---: | :---: | :---: | :---: | :---:
0 | 0 | 0 | 0 | 1 | 1 | 0 | 1
0 | 1 | 0 | 1 | 1 | 0 | 0 | 1
1 | 0 | 0 | 1 | 0 | 0 | 1 | 0
1 | 1 | 1 | 1 | 1 | 1 | 1 | 0



NOT, AND, and OR may also be expressed with arithmetic and min/max functions:

* NOT A = A' = 1 - A
* A AND B = A . B = min(A, B)
* A OR  B = A + B = max(A, B)

Given NOT and one of AND or OR, the other operation, AND or OR, can be derived:

* A AND B = (A' OR  B')'
* A OR  B = (A' AND B')'

#### III. Laws of Boolean Algebra

A law is an identity between two boolean terms. Laws are used to define the boolean model.

Duality Principle - every algebraic expression is deducible if the operands and the identity elements are interchanged:

```
A + 0 = A                       => A * 1 = A
A + A' = 1                      => A . A' = 0
A + B = B + A                   => A . B = B . A
A . (B + C) = (A . B) + (A . C) => A + (B . C) = (A + B) . (A + C)
```

Closure Property - a set is closed with respect to an operator, when any result obtained by operating on the members of the set is also be a member of the set.

```
S = {A, B, C, ..., N}
A * B = x; where x is in S
```

##### Idempotent Laws

operations on the variable with itself

* t1. Idempotent (+)
 * A + A = A

 ```
 A + A = (A + A) . 1;    p1. identity	
          = (A + A) . (A + A'); p3. complement
          = A + (A . A');       p6. distributive
          = A + 0;              p3. complement
          = A;                  p2. identity

 therefore A + A = A
 ```

* t2. Idempotent (.)
 * A . A = A

 ```
A . A = (A . A) + 0;    p2. identity
      = (A . A) + (A . A'); p4. complement
      = A . (A + A');       p5. distributive
      = A . 1;              p3. complement
      = A;                  p1. identity

 therefore A . A = A
 ```

##### Annihilator (Domination) laws

operations on the annihilator

* t3. Domination (+ 1)
 * A + 1 = 1

 ```
 ; OR operation - if either input is one, the output will be one
 A = 0, A + 1 = 1
 A = 1, A + 1 = 1;			

 therefore A + 1 = 1

 A + 1 = (A + 1) . 1;        p1. identity
          = (A + 1) . (A + A'); p3. complement
          = A + (1 . A');       p6. distributive
          = A + A';             p1. identity
          = 1;                  p3. complement

 therefore A + 1 = 1
```

* t4. Domination (. 0)
 * A . 0 = 0

 ```
 ; AND operation - if either input is zero, the output will be zero
 A = 0, A . 0 = 0
 A = 1, A . 0 = 0;

 therefore A . 0 = 0

 A + 1 = 1; t3. domination
 A . 0 = 0; duality

 therefore A . 0 = 0
```

##### Involution law

the complement of the complement

* t5. Involution - aka double not
 * A'' = A

 ```
 A = 0, A'' = 0; because 0' = 1 and 1' = 0
 A = 1, A'' = 1; because 1' = 0 and 0' = 1;

 therefore A'' = A
```

##### Absorption laws

* t6. Absorption (A + AX)
 * A + AB = A

 ```
 A + AB = (A . 1) + AB; p1. identity		
           = A . (1 + B);  p5. distributive
           = A . 1;        t3. domination
           = A             p1. identity

 therefore A + AB = A
```

* t7. Absorption (A . (A + X))
 * A (A + B) = A

 ```
 A (A + B) = (A + A)(A + B);    t1. idempotent
              = A + (A . B);       p6. distributive
              = (A . 1) + (A . B); p1. identity
              = A . (1 + B);       p5. distributive
              = A . 1;             t3. domination
              = A;                 p1. identity
	     
 therefore A . (A + B) = A
 ```
 
* t8. Additional Theorem I
 * A + (A' . B) = A + B

 ```
 A + (A' . B)	= (A + AB) + (A' . B); t6. absorption, set A = A + AB
                   = A + (B . (A + A'));  p5. distributive
                   = A + (B . 1);	      p3. complement
                   = A + B;               p1. identity

 therefore A + (A' . B) = A + B
 ```
 
* t9. Additional Theorem II
 * A . (A' + B) = A . B

 ```
 A . (A' + B)	= (A + AB) . (A' + B);   t6. absorption
                   = AA' + AB + ABA' + ABB; p6. distributive
                   = 0 + AB + 0 + ABB;      p4. complement
                   = AB + ABB;              p2. identity
                   = AB + AB;               t2. idempotent
                   = AB;                    t1. idempotent

 therefore A . (A' + B) = A . B
 ```

##### Commutative laws

variables can be reordered in any order under . or +

```
A . B = B . A
A + B = B + A
```

##### Associative laws

variables can be (re)grouped in any order under . or +

```
(A . B) . C = A . B . C = A . (B . C)
(A + B) + C = A + B + C = A + (B + C)
```

##### de Morgan's laws

convert between forms of logic and types of gates

```
(A + B)' = A' . B' => (A + B + C + ... + N) = A' . B' . C' ... . N'
(A . B)' = A' + B' => (A . B . C . ... . N) = A' + B' + C' ... + N'
```

##### Arrow law

`A -> B = A' + B`

##### Contraposition law

`A -> B = A' -> B'`

##### Double Arrow Law

`A <-> B = (A -> B) . (B -> A)`


*post added 2022-12-01 14:35:00 -0600*