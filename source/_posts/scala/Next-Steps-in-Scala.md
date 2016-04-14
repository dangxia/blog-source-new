title: Chapter3：Next Steps in Scala
date: 2015-11-21 17:24:09
tags: [Programming in Scala]
categories: [Scala]
---
### Parameterize arrays with types
**Note that when you parameterize an instance with both a type and a value, the type comes first in its square brackets, followed by the value in parentheses.**
```scala
val greetStrings = new Array[String](3)
greetStrings(0) = "Hello"
greetStrings(1) = ", "
greetStrings(2) = "world!\n"
for (i <- 0 to 2)
  print(greetStrings(i))
```
```scala In a more explicit mood
val greetStrings: Array[String] = new Array[String](3)
```
**Note that the type parameterization portion (the type names in square brackets) forms part of the type of the instance, the value parameterization part (the values in parentheses) does not**
**Note that arrays in Scala are accessed by placing the index inside parentheses, not square brackets as in Java.**

#### Scala concerning the meaning of val
When you define a variable with val, the variable can’t be reassigned, but the object to which it refers could potentially still be changed.
+ you couldn’t reassign greetStrings to a different array; greetStrings will always point to the same Array[String] instance with which it was initialized.
+ you can change the elements of that Array[String] over time
**So the array itself is mutable.**

#### Scala operation
![][operation]

#### general rule of Scala:
+ if a method takes only one parameter, you can call it without a dot or parentheses.
  ```scala
  for (i <- 0 to 2)
    print(greetStrings(i))
  ```
  The `to` in this example is actually a method that takes one `Int` argument. The code `0 to 2` is transformed into the method call `(0).to(2)`
  **Note that this syntax only works if you explicitly specify the receiver of the method call. You cannot write “println 10”, but you canwrite “Console println 10”.**

+ When you apply parentheses surrounding one or more values to a variable, Scala will transform the code into an invocation of a method named apply on that variable.
So greetStrings(i) gets transformed into greetStrings.apply(i) Thus accessing an element of an array in Scala is simply a method call like any other. This principle is not restricted to arrays: any application of an object to some arguments in parentheses will be transformed to an apply method call. Of course this will compile only if that type of object actually defines an apply method.
+ when an assignment is made to a variable to which parentheses and one or more arguments have been applied, the compiler will transform that into an invocation of an update method that takes the arguments in parentheses as well as the object to the right of the equals sign.
`greetStrings(0) = "Hello"` will be transformed into:`greetStrings.update(0, "Hello")`

#### Scala doesn’t technically have operator overloading
Scala achieves a conceptual simplicity by treating everything, from arrays to expressions, as objects with methods. You don’t have to remember special cases, such as the differences in Java between primitive and their corresponding wrapper types, or between arrays and regular objects. Moreover,this uniformity does not incur a significant performance cost. The Scala compiler uses Java arrays, primitive types, and native arithmetic where possible in the compiled code.
Scala获得了一个概念上的简单性，通过把一切（无论是数组还是表达式),都当作objects whih methods来对待。
Scala doesn’t technically have operator overloading, because it doesn’t actually have operators in the traditional sense. Instead, characters such as +, -, *, and / can be used in method names. Thus, when you typed 1 + 2 into the Scala interpreter in Step 1, you were actually invoking a method named + on the Int object 1, passing in 2 as a parameter. As illustrated in Figure 3.1, you could alternatively have written 1 + 2 using traditional method invocation syntax, (1).+(2).
#### examples
```scala
val numNames = Array("zero", "one", "two")
//val numNames2 = Array.apply("zero", "one", "two")
```

### Use lists
> One of the big ideas of the functional style of programming is that methods should not have side effects. A method’s only act should be to compute and return a value. Some benefits gained when you take this approach are that methods become less entangled, and therefore more reliable and reusable. Another benefit (in a statically typed language) is that everything that goes into and out of a method is checked by a type checker, so logic errors are more likely to manifest themselves as type errors. Applying this functional philosophy to the world of objects means making objects immutable.
+ arrays are mutable objects
+ Scala Lists are always immutable (whereas Java Lists can be mutable). Scala’s List is designed to enable a functional style of programming

```scala
// List has a method named ‘:::’ for list concatenation
val oneTwo = List(1, 2)
val threeFour = List(3, 4)
val oneTwoThreeFour = oneTwo ::: threeFour
println(oneTwo +" and "+ threeFour +" were not mutated.")
println("Thus, "+ oneTwoThreeFour +" is a new list.")
```
```bash output
#List(1, 2) and List(3, 4) were not mutated.
#Thus, List(1, 2, 3, 4) is a new list.
```
```scala
//Cons(::) prepends a new element to the beginning of an existing list,
//and returns the resulting list
val twoThree = List(2, 3)
val oneTwoThree = 1 :: twoThree
println(oneTwoThree)
//:List(1, 2, 3)
```

**NOTE:**
> In the expression “1 :: twoThree”, :: is a method of its right operand, the list, twoThree. You might suspect there’s something amiss with the associativity of the :: method, but it is actually a simple rule to remember: If a method is used in operator notation, such as a * b, the method is invoked on the left operand, as in a.*(b)—unless the method name ends in a colon. If the method name ends in a colon, the method is invoked on the right operand. Therefore, in 1 :: twoThree, the :: method is invoked on twoThree, passing in 1, like this: twoThree.::(1)

```scala
//Nil is a empty List(or List())
val oneTwoThree = 1 :: 2 :: 3 :: Nil
println(oneTwoThree)
//:List(1,2,3)
```

**Why not append to lists?**
> Class List does offer an “append” operation —it’s written :+ and isexplained in Chapter 24— but this operation is rarely used, becausethe time it takes to append to a list grows linearly with the size of thelist, whereas prepending with :: takes constant time. Your options ifyou want to build a list efficiently by appending elements is to prependthem, then when you’re done call reverse; or use a ListBuffer, amutable list that does offer an append operation, and when you’re donecall toList. ListBuffer will be described in Section 22.2.

**What it is**|**What it does**
--------------|-----------------
List() or Nil |The empty List
List("Cool", "tools", "rule")| Creates a new List[String] with the three values "Cool", "tools", and "rule" 
val thrill = "Will" :: "fill" :: "until" :: Nil |Creates a new List[String] with the three values "Will", "fill", and "until"
List("a", "b") ::: List("c", "d") |Concatenates two lists (returns a new List[String] with values "a", "b", "c", and "d")
thrill(2) |Returns the element at index 2 (zero based) of the thrill list (returns "until")
thrill.count(s => s.length == 4) |Counts the number of string elements in thrill that have length 4 (returns 2) thrill.drop(2) Returns the thrill list without its first 2 elements (returns List("until"))
thrill.dropRight(2) |Returns the thrill list without its rightmost 2 elements (returns List("Will"))
thrill.exists(s => s == "until") |Determines whether a string element exists in thrill that has the value "until" (returns true) 
thrill.filter(s => s.length == 4) |Returns a list of all elements, in order, of the thrill list that have length 4 (returns List("Will", "fill")) 
thrill.forall(s => s.endsWith("l")) |Indicates whether all elements in the thrill list end with the letter "l" (returns true)
thrill.foreach(s => print(s)) |Executes the print statement on each of the strings in the thrill list (prints "Willfilluntil")
thrill.foreach(print)| Same as the previous, but more concise (also prints "Willfilluntil") 
thrill.head |Returns the first element in the thrill list (returns "Will") 
thrill.init |Returns a list of all but the last element in the thrill list (returns List("Will", "fill"))
thrill.isEmpty |Indicates whether the thrill list is empty (returns false)
thrill.last |Returns the last element in the thrill list (returns "until")
thrill.length|Returns the number of elements in the thrill list (returns 3) 
thrill.map(s => s + "y")|Returns a list resulting from adding a "y" to each string element in the thrill list (returns List("Willy", "filly", "untily"))
thrill.mkString(", ") |Makes a string with the elements of the list (returns "Will, fill, until")
thrill.remove(s => s.length == 4) |Returns a list of all elements, in order, of the thrill list except those that have length 4 (returns List("until"))
thrill.reverse |Returns a list containing all elements of the thrill list in reverse order (returns List("until", "fill", "Will"))
thrill.sort((s, t) => s.charAt(0).toLower < t.charAt(0).toLower) |Returns a list containing all elements of the thrill list in alphabetical order of the first character lowercased (returns List("fill", "until", "Will"))
thrill.tail|Returns the thrill list minus its first element (returns List("fill", "until"))

### Use tuples

[operation]: /img/scala/operation.png  "All operations are method calls in Scala"