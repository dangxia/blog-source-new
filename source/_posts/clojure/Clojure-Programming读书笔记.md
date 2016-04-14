title: Clojure Programming读书笔记
date: 2015-01-06 23:21:49
tags: [clojure]
category : clojure
---
##	a homoiconic language.
********************************
Clojure being a homoiconic language.
##	All Clojure code is made up of expressions
****************************************************
All Clojure code is made up of expressions, each of which evaluates to a single value. This is in contrast to many languages that rely upon valueless statements—such as `if`, `for`, and `continue`—to control program flow imperatively. Clojure’s corollaries to these statements are all expressions that evaluate to a value.

You’ve already seen a few examples of expressions in Clojure:
+	60
+	[60 80 100 400]
+	(average [60 80 100 400])
+	(+ 1 2)

<!--more-->

The rules for that evaluation are ex-traordinarily simple compared to other languages:

1. Lists (denoted by parentheses) are calls, where the first value in the list is the op-erator and the rest of the values are parameters. The first element in a list is often referred to as being in function position (as that’s where one provides the function or symbol naming the function to be called). Call expressions evaluate to the value returned by the call.
2. Symbols (such as average or +) evaluate to the named value in the current scope— which can be a function, a named local like numbers in our average function, a Java class, a macro, or a special form. We’ll learn about macros and special forms in a little bit; for now, just think of them as functions.
3. All other expressions evaluate to the literal values they describe.

**	Lists in Lisps are often called s-expressions or sexprs—short for symbolic expressions due to the significance of symbols in identifying the values to be used in calls denoted by such lists. Generally, valid s-expressions that can be successfully evaluated are often referred to as forms: e.g., (if condition then else) is an if form, [60 80 100 400] is a vector form. Not all s-expressions are forms: (1 2 3) is a valid s-expression— a list of three integers—but evaluating it will produce an error because the first value in the list is an integer, which is not callable. **