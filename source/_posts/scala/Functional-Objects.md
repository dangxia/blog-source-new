title: Chapter6：Functional Objects
date: 2015-12-06 15:44:29
tags: [Programming in Scala]
categories: [Scala]
---
### Constructing a Rational
```scala
class Rational(n: Int, d: Int)
```
this line of code is that if a class doesn’t have a body, you don’t need to specify empty curly braces (though you could, of course, if you wanted to).

**primary constructor**
>**Immutable object trade-offs**
Immutable objects offer several advantages over mutable objects, and one potential disadvantage. First, immutable objects are often easier to reason about than mutable ones, because they do not have complex state spaces that change over time. Second, you can pass immutable objects around quite freely, whereas you may need to make defensive copies of mutable objects before passing them to other code. Third, there is no way for two threads concurrently accessing an immutable to corrupt its state once it has been properly constructed, because no thread can change the state of an immutable. Fourth, immutable objects make safe hash table keys. If a mutable object is mutated after it is placed into a HashSet, for example, that object may not be found the next time you look into the HashSet. 
The main disadvantage of immutable objects is that they sometimes require that a large object graph be copied where otherwise an update could be done in place. In some cases this can be awkward to express and might also cause a performance bottleneck. As a result, it is not uncommon for libraries to provide mutable alternatives to immutable classes. For example, class StringBuilder is a mutable alternative to the immutable String. We’ll give you more information on designing mutable objects in Scala in Chapter 18.

>**NOTE:**
This initial Rational example highlights a difference between Java and Scala. In Java, classes have constructors, which can take parameters, whereas in Scala, classes can take parameters directly. The Scala notation is more concise—class parameters can be used directly in the body of the class; there’s no need to define fields and write assignments that copy constructor parameters into fields. This can yield substantial savings in boilerplate code, especially for small classes.

```scala
class Rational(n: Int, d: Int) {
	println("Created "+ n +"/"+ d)
}
```
The Scala compiler will compile any code you place in the class body, which isn’t part of a field or a method definition, into the primary constructor

### Reimplementing the toString method
```scala
class Rational(n: Int, d: Int) {
	override def toString = n +"/"+ d
}
```
The override modifier in front of a method definition signals that a previous method definition is overridden

### Checking preconditions
A precondition is a constraint on values passed into a method or constructor, a requirement which callers must fulfill
```scala
class Rational(n: Int, d: Int) {
	require(d != 0)
	override def toString = n +"/"+ d
}
```

### Adding fields
```scala
class Rational(n: Int, d: Int) { // This won’t compile
	require(d != 0)
	override def toString = n +"/"+ d
	def add(that: Rational): Rational = new Rational(n * that.d + that.n * d, d * that.d)
}
```
Although class parameters n and d are in scope in the code of your add method, you can only access their value on the object on which add was invoked. Thus, when you say n or d in add’s implementation, the compiler is happy to provide you with the values for these class parameters. But it won’t let you say that.n or that.d, because that does not refer to the Rational object on which add was invoked
```scala
class Rational(n: Int, d: Int) {
	require(d != 0)
	val numer: Int = n
	val denom: Int = d
	override def toString = numer +"/"+ denom
	def add(that: Rational): Rational =
		new Rational(
			numer * that.denom + that.numer * denom,
			denom * that.denom
		)
}
```

### Self references
The keyword `this` refers to the object instance on which the currently executing method was invoked, or if used in a constructor, the object instance being constructed


### Auxiliary constructors
Auxiliary constructors in Scala start with def this(...).
```scala
class Rational(n: Int, d: Int) {
	require(d != 0)
	val numer: Int = n
	val denom: Int = d
	def this(n: Int) = this(n, 1) // auxiliary constructor
...
}
```
>**The primary constructor is thus the single point of entry of a class.**
In Scala, every auxiliary constructor must invoke another constructor of the same class as its first action. In other words, the first statement in every auxiliary constructor in every Scala class will have the form “this(. . . )”. The invoked constructor is either the primary constructor (as in the Rational example), or another auxiliary constructor that comes textually before the calling constructor. The net effect of this rule is that every constructor invocation in Scala will end up eventually calling the primary constructor of the class.

>**NOTE**
If you’re familiar with Java, you may wonder why Scala’s rules for constructors are a bit more restrictive than Java’s. In Java, a constructor must either invoke another constructor of the same class, or directly invoke a constructor of the superclass, as its first action. In a Scala class, only the primary constructor can invoke a superclass constructor. The increased restriction in Scala is really a design trade-off that needed to be paid in exchange for the greater conciseness and simplicity of Scala’s constructors compared to Java’s.

### Private fields and methods
make a field or method private you simply place the private keyword in front of its definition.

### Defining operators
The first step is to replace add by the usual mathematical symbol
```scala
class Rational(n: Int, d: Int) {
	require(d != 0)
	private val g = gcd(n.abs, d.abs)
	val numer = n / g
	val denom = d / g
	def this(n: Int) = this(n, 1)
	def + (that: Rational): Rational =
		new Rational(
			numer * that.denom + that.numer * denom,
			denom * that.denom
		)
	def * (that: Rational): Rational =
	new Rational(numer * that.numer, denom * that.denom)
	override def toString = numer +"/"+ denom
	private def gcd(a: Int, b: Int): Int =
	if (b == 0) a else gcd(b, a % b)
}
```

### Identifiers in Scala

#### alphanumeric identifier

**An alphanumeric identifier starts with a letter or underscore, which can be followed by further letters, digits, or underscores.** The ‘$’ character also counts as a letter, however it is reserved for identifiers generated by the Scala compiler. Identifiers in user programs should not contain ‘$’ characters, even though it will compile; if they do this might lead to name clashes with identifiers generated by the Scala compiler
Scala follows Java’s convention of using camel-case identifiers.Although underscores are legal in identifiers, they are not used that often in Scala programs, in part to be consistent with Java,but also because underscores have many other non-identifier uses in Scala code. As a result, **it is best to avoid identifiers like to\_string, \_\_init\_\_, or name\_.**

>**Note**
One consequence of using a trailing underscore in an identifier is that if you attempt, for example, to write a declaration like this, “val name_: Int = 1”, you’ll get a compiler error. The compiler will think you are trying to declare a val named “name_:”. To get this to compile, you would need to insert an extra space before the colon, as in: “val name_ : Int = 1”.

**One way in which Scala’s conventions depart from Java’s involves constant names.**
In Java, the convention is to give constants names that are all upper case, with underscores separating the words, such as MAX\_VALUE or PI.
In Scala, the convention is merely that the first character should be upper case. 
Thus, constants named in the Java style, such as X\_OFFSET, will work as Scala constants, but the Scala convention is to use camel case for constants, such as XOffset.

#### operator identifier

An operator identifier consists of one or more operator characters. Operator characters are printable ASCII characters such as `+, :, ?, ~ or #`. Here are some examples of operator identifiers:`+ ++ ::: <?> :->`
The Scala compiler will internally “mangle” operator identifiers to turn them into legal Java identifiers with embedded $ characters. For instance, the identifier :-> would be represented internally as $colon$minus$greater.
**Because operator identifiers in Scala can become arbitrarily long, there is a small difference between Java and Scala**
In Java, the input x<-y would be parsed as four lexical symbols, so it would be equivalent to x < - y. In Scala, <- would be parsed as a single identifier, giving x <- y. If you want the first interpretation, you need to separate the < and the - characters by a space.

#### mixed identifier

A mixed identifier consists of an alphanumeric identifier, which is followed by an underscore and an operator identifier. For example, unary\_+ used as a method name defines a unary + operator. Or, myvar\_= used as method name defines an assignment operator.

#### literal identifier
A literal identifier is an arbitrary string enclosed in back ticks (` . . . `). Some examples of literal identifiers are:
		\`x\` \`<clinit>\` \`yield\`
The idea is that you can put any string that’s accepted by the runtime as an identifier between back ticks. The result is always a Scala identifier. This works even if the name contained in the back ticks would be a Scala reserved word.

### Method overloading

>**Note:**
Scala’s process of overloaded method resolution is very similar to Java’s. In every case, the chosen overloaded version is the one that best matches the static types of the arguments. Sometimes there is no unique best matching version; in that case the compiler will give you an “ambiguous reference” error.

### Implicit conversions

You can create an implicit conversion that automatically converts integers to rational numbers when needed. Try adding this line in the interpreter:
```scala
implicit def intToRational(x: Int) = new Rational(x)
```
Note that for an implicit conversion to work, it needs to be in scope. If you place the implicit method definition inside class Rational, it won’t be in scope in the interpreter. For now, you’ll need to define it directly in the interpreter.

### A word of caution
As this chapter has demonstrated, creating methods with operator names and defining implicit conversions can help you design libraries for which client code is concise and easy to understand. Scala gives you a great deal of power to design such easy-to-use libraries, but please bear in mind that with power comes responsibility
If used unartfully, both operator methods and implicit conversions can give rise to client code that is hard to read and understand. Because implicit conversions are applied implicitly by the compiler, not explicitly written down in the source code, it can be non-obvious to client programmers what implicit conversions are being applied. And although operator methods will usually make client code more concise, they will only make it more readable to the extent client programmers will be able to recognize and remember the meaning of each operator.
The goal you should keep in mind as you design libraries is not merely enabling concise client code, but readable, understandable client code. Conciseness will often be a big part of that readability, but you can take conciseness too far. By designing libraries that enable tastefully concise and at the same time understandable client code, you can help those client programmers work productively.
