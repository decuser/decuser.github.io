---
layout:	post
title:	Schemes, LISPs, and Lambda
date:	2023-07-24 12:05:00 -0600
categories:	LISP
---
This note sets up a series of related notes pertaining to my explorations in LISP and Scheme. I began to be interested in functional programming a few years ago and started looking around to find resources to learn it... in my limited spare time. After finding some resources, I would study it, set it aside as too esoteric, pick it up again thinking - this is it, I'm going to master this one way or another, only to set it aside as frustratingly difficult to understand and lacking in applicability. Lately though, I have found some standout resources and worked through enough of them to begin to actually get my mind wrapped around functional programming. Below you will find a brief, informal annotated bibliography of sorts and an explanation of what's coming in the further explorations into implementations.

<!--more-->

## Select Functional Programming Bibliography

* **An Introduction to Functional Programming Through Lambda Calculus**, by Greg Michaelson, Dover, 2011 (reprint of Addison-Wesley 1989 edition).

This text describes functional programming as it is realized in Church's Lambda Calculus. In order to "run" the programs, you need a language capable of working with lambda notation such as Standard ML (SML) [https://www.smlnj.org/](https://www.smlnj.org/). This is a very well articulated work that walks the reader through a series of discussions and exercises to illustrate the general nature of functional programming as a paradigm.

* **Common LISP: An Interactive Approach**, by Stuart C. Shapiro, Computer Science Press, 1992.

This book is a very easy read that teaches programming in common lisp using a set of question and answer dialogs between the author and reader. It starts off with an assumption that the reader knows nothing much more than how to start common lisp and takes the reader on a tour of the most important language features. If you want to put common lisp to use in solving problems, this is a fantastic book. It isn't really focused on teaching functional programming although its examples are functional in nature. Probably great if you are a learn by example reader.

* **LISP: A Gentle Introduction to Symbolic Computation**, by David S. Touretzky, Harper & Row Publishers, 1984.

This is a book targeting readers without prior programming experience. Its claims are modest, but it over delivers. The author clearly explains the basics of LISP and covers the language essentials quite completely.

* **The Little Schemer**, 4th ed., by Daniel P. Friedman and Matthias Felleisen, MIT Press, 1996.

This is an interesting text that could come across as cutesy and turn off the more serious minded reader. However, I enjoyed it. At first, I was annoyed that the premise being explored was not stated explicitly and up front, but after reading it more carefully, I decided that the approach was solid. Several key concepts are revealed to the reader through simple (seeming) here is some information, based on what you "know", what is the answer? here is the answer and why it is correct style dialogs that heavily leverage progressive disclosure. When you reflect on a section, you realize that you have learned an important piece of the language.

* **Scheme and the Art of Programming**, by George Springer and Daniel P. Friedman, MIT Press, 1989.

Daniel P. Friedman was a gifted explainer. This book is a very good explanation of how sheme works and how to put it to use. It is more traditionally presented than the Little Schemer and goes into considerably more depth.

* **Simply Scheme: Introducing Computer Science**, 2nd ed., by Brian Harvey and Matthew Wright, MIT Press 1999.

Harvey's book is one of my favorites. In it, the author teaches a number of Big Ideas, progressively. He starts off very simple and builds up to much more sophisticated constructions. The author chooses to use his own language, built on top of scheme and this is jarring, at first. But, if you spend any time with Scheme, you realize that all schemes are languages built on top of scheme's foundation and that this use of it is completely in line with scheme's vibe. Once you get past the language is not quite canonical scheme bit, it's actually genius how he abstracts the teaching of scheme away from the language itself and gets into the big ideas of computation as realized by the language.

* **Structure and Interpretation of Computer Programs**, 2nd ed., by Harold Abelson, Gerald Jay Sussman, with Julie Sussman, MIT Press, 1996.

This is a great book particularly when it is married to the author's video lectures from 1986 [https://www.youtube.com/watch?v=2Op3QLzMgSY](https://www.youtube.com/watch?v=2Op3QLzMgSY) Combined, this is top 10 CS course material. The lesson that sticks with me the most is how they distilled language down to providing three capabilities:

1. Primitives
2. Means of combinations
3. Means of abstraction

Just a great book, all around, but difficult in many ways. Which leads me to the point of all this discussion . Which is to say that reading books is one thing, working through them 20-30 years later, is quite another. I am a hands on learner. I get much more out of typing in programs and dealing with the errors that arise, than I do out of just reading page after page of description.

All of the books above are available today, most are available as pdfs.

## Exploring Implementations

One cannot help but notice that the list of books above are Scheme or LISP books with the sole exception of the Lambda Calculus book. The question that immediately arises is, which Scheme or which LISP? As it turns out, this question is a tricky one. After having tried out every version of scheme and lisp I could get my hands on, I have come to the conclusion that Scheme and LISP are idealizations of Lambda Calculus facilitating languages - there is no true Scheme or LISP. 

There are so many variations, it is flat out ridiculous. That said, each of the books above used historically extant versions. Unfortunately, the authors of these books were not good about specificity. They usually claimed that their code would work with pretty much any reasonably complete (as of then) environment and gave appendices with their customizations that you could "port" to your environment. The good news is that folks have used these books over the decades and give us some hints as to current workable environments.

I started exploring the environments with the intention of setting up specific environments for my work in these books, but after a bit, the exploration of environments became an interest in itself. Where did the Schemes and LISPS come from, what did those environments look like and how did they function?

There'll be a lot less talk in the environment explorations and they will be set up as howtos.

Thx - Will

*post added 2023-07-24 19:28:00 -0600*
