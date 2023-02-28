% Python: The Minimum You Need to Know

Many network engineers and other professionals are transitioning their skills set to include programming and automation. Commonly, their previous programming experience comes from a few programming courses they attended in university a long time ago. I am one of those professionals and I created this Python guide for people like you and me.

In this guide, I explain the absolute minimum amount you need to learn about Python in order to create useful programs. Follow this guide to get a very short, but functional, overview of Python programming in less than one hour.

I omit many topics from this text that you do not need to know when you begin using Python; you can learn them later, when you need them. I don’t want you to have to unlearn misconceptions later, when you become more experienced, so I do include some Python concepts that other beginner guides might skip, such as the Python object model. This guide is “simple” but it is also “mostly correct”.

### Getting Started

In this guide, I will explore the seven fundamental topics you need to know to create useful programs almost immediately. These topics are:

* The Python object model simplified
* Defining objects
* Core types
* Statements
* Simple programs
* Modules
* User input

Of course, there is much more to learn. This guide will get you started quickly and you can build more skills as you gain experience writing Python programs that perform useful tasks.

There is no substitute for learning by doing. I recommend you also start a terminal window and run the Python interactive shell so you can type in commands as you follow this guide.

#### Install python

This guide is targeted at Linux users but is still applicable to any operating system. You can find instructions to [install Python on any operating system](https://docs.python.org/3/using/index.html) in the Python documentation.

Python is probably already installed in your Linux system. 

#### Python Interactive Prompt

There are many ways to start and run Python programs in Linux. While you are learning about Python's basic building blocks, you will use the Python Interactive Prompt to run Python statements and explore the results. Later, you will run Python programs using the Python interpreter. In both cases, you will launch Python from the Linux bash shell.

Open a new Terminal window. To start the Python interactive prompt, type `python` or `python3` at the command prompt.

    > python

You will see the interactive prompt, `>>>`.

    >>>

To quit interactive mode, type `quit()` or the *CTRL-Z* key combination.

    >>> exit()

You will find that the Python interactive prompt is a great tool for experimenting with Python concepts. It is useful for learning the basics but it is also useful for trying out complicated ideas when you get more experienced. You will use the Python interactive prompt often in your programming career.

### The Python object model simplified

Everything in Python is an object. 

Python is an *object-oriented* programming language, but you do not need to use its object-oriented features to write useful programs. You may start using Python as a *procedural programming* language, which is familiar to most people who have a little programming knowledge. While I focus on procedural programming methodologies, I will still use some terminology related to objects so that you have a good base from which you may expand your Python skills.

In Python, an object is just a thing stored in your computer's memory. Objects are created by Python statements. After objects are created, Python keeps track of them until they are deleted. An object can be something simple like an integer, a sequence of values such as a string or list, or even executable code. There are [many types of Python objects](https://docs.python.org/3/library/stdtypes.html).

Python creates some objects by default when it starts up, such as its built-in functions. Python keeps track of these objects and of any objects created by the programmer.

#### Python objects 

When you start Python, it creates a number of objects in memory that you may list using the Python *dir()* function. For example:

    > python
    >>> dir()

This will return a list the Python objects currently available in memory, which are:

    ['__annotations__', '__builtins__', '__doc__', '__loader__', '__name__', '__package__', '__spec__']

Note that this is returned as a Python *list*, as indicated by the square brackets (more about lists later).

Create a new object. Define an integer object by writing a Python statement that creates an integer object, assigns the value of *10* to it, and points to it with the variable name *a*:

    >>> a = 10

Call the integer object named by *a*. Python will return the result in the interactive prompt:

    >>> a
    10

List all objects available in memory, again. Look for the integer object *a*:

    >>> dir()
    ['__annotations__', '__builtins__', '__doc__', '__loader__', '__name__', '__package__', '__spec__','a']

See that the object *a* is added to the end of the list of Python objects. It will remain until you quit the Python interactive session.Python automatically deletes objects when they are not used by your program, in a process called Garbage Collection. Beginners don't need to know anything about that.

#### Getting help

You may use the *help()* function to see the built-in Python documentation about each object type. Call the name of the object (or the type, if you know it) and the Python help function will print the documentation. For example:

    >>> help(a)

You asked for help about object *a*. Python knows object *a* is an integer so it showed you the help information for a Python *int*, or integer, object type. You would get the same output if you had called the help function using the object type *int*.

    >>> help(int)

As you work with Python in the interactive prompt, you can use the *dir()* and *help()* functions to better understand Python

### Defining objects

In Python, statements define an object simply by assigning it to a variable or using it in an expression. 

One of the fundamental concepts in Python is that you do not need to declare the type of an object before you create it. Python infers the object type from the syntax you use to define it.

In the example below, *a* defines an integer object, *b* defines a floating-point object, *c* defines a string object, and *d* defines a list object, and in this example each element of the list is a string object.  

    >>> a = 10                  # An integer 
    >>> b = 10.0                # A floating point 
    >>> c = 'text'              # A string 
    >>> d = ['t','e','x','t']   # A list (of strings)

See how the syntax defines the object type: different objects are created if a decimal point is used, if quotes are used, if brackets are used, and depending on the type of brackets used. I will explain each of the Python object types a little bit later in this guide.

#### Comments

Note also that the syntax for comments in Python is the hash character, #. Other ways to comment and document Python programs are available but, for sake of simplicity, I skipped them from this guide. 

#### Variables point to objects

In each of the four examples above, you created an object and then pointed a variable to that object. This is fundamentally different from more traditional programming languages. The variable does not contain the value, the object does. The variable is just a name pointing to the object, so you can use the object in your program.

A variable may be re-assigned to another object, even if the object is a different type. You are not changing the value of the variable or the type of the variable because the variable has no value or type. Only the object has a value or a object type. The variable is just a name you use to point to any object. So, the following code will work in Python:

    >>> a = 10
    >>> a
    10
    >>> a = 'text'
    >>> a
    'text'

See that you can assign an integer object to variable *a* and, later, assign a string object to variable *a*. The original integer object that had a value of *10* is erased from memory after you reassign the variable *a* to a string object that has a value of *'text'*.

When you begin working with Python, I suggest you write your code to avoid mixing up object types with the same variable names, but you may see this behavior if you are working with code someone else has written.

#### Object methods

Each instance of a Python object has a value, but it also inherits functionality from the core object type. Python’s creators built methods into each of the Python core object types and you, the programmer, access this built-in functionality using *object methods*. Object methods may evaluate or manipulate the value stored in the object and allow the object to interact with other objects or create new objects. 

For example, number objects have mathematical methods built into them that support arithmetic and other numerical operations; string objects have methods to split, concatenate, or index items in the string.

The syntax for calling methods is `object.method(arguments)`, adding the name of the method, separated by a period, after the object name and ending with closed parenthesis containing arguments. 

For example, one (not recommended) way to add two integers together is to use the integer object's *\_\_add\_\_* method:

    >>> a = 8
    >>> a.__add__(2)
    10

Above, you created an integer object with a value of *8* and pointed the variable *a* to it. Then you called the integer object pointed to by variable *a* and used its *\_\_add\_\_* method to return a new object that has a value of *10*. Note that you do not normally do addition this way in Python but the Python integer object's *\_\_add\_\_* method is the underlying code used by Python's addition operator, *+*, and the *sum()* function when using them with integer objects.

Here is another example: create an integer object with a value of *100* and assign it to a variable named *c*.

    >>> c = 100
    >>> c
    100

Then look at all the methods and objects associated with the integer object by using the *dir()* function:

    >>> dir(c)

You get a long list of object methods. These were all defined by the creators of Python and are "built in" to the integer object. Other Python functions may use some of these methods to perform their tasks, but you don't need to know all the details of how Python works "under the hood". From this list, you see that one of the methods associated with the integer object *c*, is *bit_length*. Use *help()* to get more information about what this method does:

    >>> help(c.bit_length)

See it returns the minimum number of bits required to represent the number in binary. For example, the number *100* is binary *1100100*, which is seven bits. Verify this using the *bit_length* method that is built into the integer object *c*:

    >>> c.bit_length()
    7

In summary: every Python object also comes with built-in methods that are available when the object is created. You can see the methods and learn more about them using the *dir()* and *help()* functions.

### Core object types

As I mentioned previously, everything in Python is an object. You need to learn about a few basic object types to get started with Python. There are more object types than those listed below but we'll start with this list of the object types that network engineers will use most often.

* Integer objects
* Floating point objects
* String objects
* File objects
* List objects
* Program Unit objects

#### Numbers object types

Numbers objects are usually defined as integers or floating point numbers. Python also supports complex numbers and special types that allow users to define fractions with numerators and denominators, and fixed-precision decimal numbers. The following code creates two integers and adds them together: 

    >>> a = 10
    >>> b = 20
    >>> a + b
    30
    >>> c = a + b
    >>> c
    30

#### String object types

Strings objects may be text strings or byte strings. The main difference is that text strings will be automatically encoded and decoded into readable text by Python, and binary strings will be left in their raw, machine readable, form. Byte strings are usually used to store media such as pictures or sounds. 

Readable text strings are created with quotes as follows:

    >>> z = 'text'
    >>> z
    'text'

#### File object types

Files are objects created by Python's built-in *open()* function. Type `help(open)` at the interactive prompt for more information. Whether opening an existing file, or creating a new one, the *open()* function returns a file object which is assigned to a variable name, so you can reference it later in your program. For example:

    >>> myfile = open('myfile.txt', 'x')
    >>> myfile
    <_io.TextIOWrapper name='myfile.txt' mode='x' encoding='cp1252'>

Remember, you can see all the methods available for the file object you created by typing `dir(myfile)`, and you may get help about the open command and all its options by typing `help(open)`.

You may close a file using the file object's *close* method.

    >>> myfile.close()

#### List object types

When you were in school and you may have taken a course about data structures. Or, if you have experience working with computer languages like *C* or *C++*, you had to create your own data structures to manage data in your programs. You probably implemented a data structure called a *linked list*, which contained a series of elements in computer memory linked by pointers. You probably wrote code to create functions that allowed you to insert items in the list, remove items, find items by index, and more.

Well, forget all that because Python has done it for you. [Python has built-in data structure objects](https://docs.python.org/3/tutorial/datastructures.html) like lists, dictionaries, tuples, and sets. The *list* and the *dictionary* are the most commonly used data structures. I cover lists in this guide. You can read about the other data structures in the Python *help()* function or in the Python documentation.

You create a list object in Python using square brackets around a list of objected separated by commas. For example:

    >>> k = [1,3,5,7,9]

Above, you created a list of five integer objects.

Python lists are very flexible and may contain a mixture of object types. For example:

    >>> k = [1, "fun", 3.14]

Above, the list object contains three objects: an integer object, a string object, and a floating-point object. Lists can also contain other list objects, which is knows as nested lists. For example:

    >>> k = [[1,2,3],['a','b','c'],[7.15,8.26,9.33]]

Above, you created a list of three objects, each of which is a list of three other objects.

Individual items in a list can be evaluated using index numbers. For example:

    >>> k
    >>> [[1,2,3],['a','b','c'],[7.15,8.26,9.33]]
    >>> k[0]
    [1, 2, 3]
    >>> k[1]
    ['a', 'b', 'c']
    >>> k[1][0]
    'a'

Lists can be iterated over, concatenated, split, and manipulated in other ways using the [list object's built-in methods](https://docs.python.org/3/tutorial/datastructures.html) or Python's functions and operators. Lists are a useful "general purpose" data structure and, in most programs, you will use lists to gather, organize, and manipulate sequential data. Lists are often used as iterators in *for* loops.

Increase the size of a list by adding elements to the end of the list with the list object's *append* method. For example:

    >>> list = []
    >>> list.append("one")
    >>> list.append("two")
    >>> list
    ["one", "two"]

Insert an item at some indexed point in the list using the *insert* object. For example:

    >>> list.insert(1,"three")
    ['one', 'three', 'two']

Pop and item from the list data structure at any index location or, by default, at the end using the *pop* method. For example:

    >>> a = list.pop(1)
    >>> a
    'three'
    >>> list
    ['one', 'two']
    >>> list.pop()
    'two'
    >>> list
    ['one']

There are many more [list methods](https://docs.python.org/3/tutorial/datastructures.html) for manipulating the sequence of items stored in the list data structure. See the Python documentation for more details.

#### Program Unit Types

Like any programming language, Python has programming statements and syntax used to build programs. In addition to that, Python defines some object types used as building blocks to create Python programs. These program unit object types are:

* Operations
* Functions
* Modules
* Classes

##### Operations

Operations are symbols used to modify other objects according to the methods supported by each object. Python contains operators to assign values, do arithmetic, make comparisons, and do logic. There are also operators that perform bitwise operations (for binary values), identity operations, and membership operations. 

Below is a list of common operation types. Many more exist; check the Python documentation for more information.

* assignment operators include *=*, and "+="
* arithmetic operators include, *+*,*-*,*\**, and */*
* comparison operators include *>*, *>=*, *==*, and *!=*
* logic operators include "and", "or", and "not"

##### Functions

Functions are containers for blocks of code, referenced by a name, commonly used in *procedural programming*. They are a universal programming concept used by most programming languages and may also be called subroutines or procedures. Use functions in your programs to reduce redundancy and to organize you program code, so it is easier for others to maintain.

Some [functions are already built into Python](https://docs.python.org/3/library/functions.html), like the *sum()*, *dir()* and *help()* functions. Other functions may be created by programmers like you and included in programs.

The Python *def* statement defines function objects. The *def* statement syntax is: `def function_name(argument1, argument2, etc):` followed by statements that make up the function.

Here, I get ahead of myself a little bit because, to define a function, you need to show Python statements and syntax. For now, just know that Python uses leading spaces to group code into statements. Define a simple function in the Python interactive prompt:

    >>> def fun(input):
    ...     x = input + ' is fun!'
    ...     return x
    ...

Note that the interactive prompt changes from `>>>` to `...` when Python understands that you will enter *multi-line* statements. This behavior is activated by the syntax of the statement and the indentation you use after that (see Python statements and syntax, below). Press return on an empty line to finish defining the function. 

Run the *dir()* function. You can see that the object *fun* has been added to the list of objects Python is tracking:

    >>> dir()
    ['__annotations__', '__builtins__', '__doc__', '__loader__', '__name__', '__package__', '__spec__', 'fun']

Call the *fun()* function and input a string as an argument. 

    >>> fun('skiing')
    skiing is fun!  

You will see the object addressed by the variable name *fun* in the list of objects returned by the *dir()* function. If you pass the function object into the *dir()* function, you will see all the methods associated with function objects, in general.

    >>> dir(fun)
    ['__annotations__', '__call__', '__class__', '__closure__', '__code__', '__defaults__', '__delattr__', '__dict__', '__dir__', '__doc__', '__eq__', '__format__', '__ge__', '__get__', '__getattribute__', '__globals__', '__gt__', '__hash__', '__init__', '__init_subclass__', '__kwdefaults__', '__le__', '__lt__', '__module__', '__name__', '__ne__', '__new__', '__qualname__', '__reduce__', '__reduce_ex__', '__repr__', '__setattr__', '__sizeof__', '__str__', '__subclasshook__']

You can do a lot with functions and, until you get to advanced topics like object-oriented programming, functions will be the primary way you organize code in Python.

##### Modules

I will cover modules in more detail when I discuss running our Python program from saved files. A Python module is a file containing Python code that you can import into another program when you run it. Modules allow you to organize large projects into multiple files and also allow you to re-use modules created by other programmers. For example: [Python's built-in modules](https://docs.python.org/3/py-modindex.html).

When writing complex programs, Python developers usually create module files that each contain multiple related functions. Any text file whose filename ends with the `.py` extension may be imported as a module into another program.

##### Classes

Classes are objects used in *object-oriented programming*. Use classes to create new objects or to customize existing objects. I ignore Python classes in this guide. But, you will need to learn about classes and object-oriented programming if you want to work with more complex frameworks, or if you are collaborating with other coders on the same project.

#### Mutability of objects

When programming in Python you may find documents that talk about how some object types are *mutable* and other object types are *immutable*. When working with only the minimum sub-set of Python object types you need to know, you usually do not need to worry about whether objects are [mutable or immutable](https://medium.com/@meghamohan/mutable-and-immutable-side-of-python-c2145cf72747). In larger projects, where you will work with more object types and will need to know the technical details about how objects are handled when they are passed into and out of functions as arguments and results, you need to understand this concept.

Remember that the Python variables do not contain values; they simply point to exiting objects. Some object types are *immutable* and cannot be modified directly. That is, the value of the object cannot change as a result of some operation. But a new object could be created as a result of an expression that involves another object. Other object types are *mutable* and can be directly changed as the result of an operation. This can lead to some confusing behavior if you are not familiar with this concept.

It is pretty obvious that numbers are immutable, but this concept becomes important when using certain "immutable" objects like *strings*. You cannot directly assign a new value into some part of an already-created string object. For example:

    >>> string = "test'
    >>> string[2]
    s
    >>> string[2]='r'
    Traceback (most recent call last):
      File "<stdin>", line 1, in <module>
    TypeError: 'str' object does not support item assignment

Lists are mutable. They are data structures that can be directly manipulated. Think of each element in a list as a variable that references another object. Each element of the list can be re-assigned to another object in the same way variables can be reassigned. Objects may be removed from a list using one of the *list* objects methods such as *pop*. Objects may be inserted anywhere in the list. This makes the list very useful as a store for data in a program.

for example:

    >>> list = ['t','e','s','t']
    >>> list[2]
    s
    >>> list[2] = r
    >>> list
    ['t', 'e', 'r', 't']
    >>> list.pop()
    't'
    >>> list
    ['t', 'e', 'r']

In the above example a novice programmer might not expect that, when popping the last item from a list, she is not simply "reading" that item, she is actually also removing it is the same operation.

But, what if I assign a new value to an integer like *a*? Isn't that modifying the immutable integer object? No. You are creating and assigning a new integer object to the variable named *a*. Remember the relationship between variables and objects.

For example, if I add "2" to an integer object referenced by a variable named "a", the object does not change. For example:

    >>> a = 100
    >>> a + 20
    120
    >>> a
    100
    >>> a = 3000
    >>> a
    3000

See that the original integer object referenced by variable *a* is not changed by the addition operation but the variable *a* can be reassigned to a new integer object with the value of *3000*. 


### Python statements

A python program is composed of statements. Each statement contains expressions that create or modify objects. Python organizes the syntax of statements -- especially control statements like *if* statements, or *for* statements -- by indenting lines using blanks or tabs.

Python statements are grouped into the following categories:

* Assignment statements such as `a = 100`
* Call statements that call objects and object methods. For example: `fun('skiing')` or `a.bit_length()`
* Selecting statements such as `if`, `else`, and `elif`
* Iteration statements such as `for`
* Loop statements such as `while`, `break`, and `continue`
* Function statements such as `def`

The list above is a good starting point for building Pyton programs.

#### Statement syntax

Python uses white space indents to group statements into code blocks. Other languages might use brackets or semicolons to separate statements, but Python uses only blanks or tabs (Pick a side! *Fight!*) and newlines. 

For example, a Python *if* statement would look like this in the interactive prompt:

    >>> a = 10
    >>> b = 20
    >>> if a > b:
    ...     print('A is bigger')
    ... else:
    ...     print('A is NOT bigger')
    ...
    A is NOT bigger 

White space is used to define which code blocks are inside iterators, loops, functions, or selector statements. If you nest statements, you will see how the indenting using white space helps you identify the groups of expressions in each statement. For example:

    >>> a = 10
    >>> b = 20
    >>> c = 3
    >>> if a > b:
    ...     print(a)
    ...     for i in range(c):
    ...         a = a + 1
    ...     print(a)
    ... else:
    ...     print(b)
    ...     for i in range(c):
    ...         b = b + 2
    ...     print(b)
    ...
    20
    26

See how the *if* and *else* statements contain blocks of code that contain *for* statements that also contain blocks of code. The indents make it easy for you to read the code, but they also makes it hard to find errors so be careful to consistently indent your code.
   
#### Assignment statement syntax

Assignment statements create objects and name variables that point to the objects. They consist of the variable name, the *=* operator, and the value of the object to be created, written in syntax that identifies the type of object. For example:

    a = 100
    b = 3.14
    c = 'stretch'
    d = [3, 4, 'pine']

#### Call statement syntax

Call functions or object methods using call statements. The syntax consists of the function or object method name, followed by parenthesis that enclose the arguments to be passed to the function. For example: 

    fun('skiing')
    a.bit_length()
    
#### Selecting statements syntax

Selecting statement allow the programmer to define operations that occur depending on the value of specific objects. The syntax involves colons, spaces, and newlines. Start with the *if* statement and expression to be tested, followed by a colon. On the next line, indent the text (I use 4 spaces) and add in the statement to run if the condition was true. Back out one indent (or 4 spaces) if you will add in *elif* statements of an *else* statement. The *else* and *elif* statements are followed by a colon, and the code to run in each of these statement is indented. For example:

    if a == b:
        print('A is equal to B')
    elif a > b: 
        print('A is greater then B')
    elif a < b:
        print('A is less than B')
    else:
        print('all other cases')


#### Iteration statement syntax

[Iteration statements](hhttps://www.w3schools.com/python/python_iterators.asp) such as `for` require an *iterator* object such as a list through which it can iterate. The *for* statement ends with a colon and indent the code that will execute on each iteration below it. For example:

    fruit = ['berries','apples','bananas', 'oranges']
    for i in fruit:
        print(i)

The above statements would print out the following:

    berries
    apples
    bananas
    oranges

You can use the *for* statement to create loops by incorporating the *range()* function, as follows:

    a = 0   
    for i in range(100):
        a = a + 1
        print(a)

The above code prints a series of numbers from 1 to 100.

Technically, the *for* statement is not a loop, it is an iterator. In the last example above, it iterates through a list object containing 100 integers with values from 0 to 99, which was created by the *range(100)* function. Each iteration updates the value pointed to by the *i* variable until the statement iterates to the end of the list.

#### Loop statement syntax

Loop statements control how many times a section of code will run in a loop. The *while* statement ends with a colon and the next lines are indented. For example:

    kk = 1
    while kk < 100:
        print(kk)
        kk += 1

The above code prints a series of numbers from 1 to 100.

Additional control statements work with the while statement to break out of a loop if a condition is met, or continue.

#### Function statement syntax

The *def* statement creates a function object in Python. The function object may be called using a *call statement*. The syntax of the *def* statement is: `def` followed by the name of the function, followed by the arguments expected by the function in parenthesis, followed by a colon. The code in the function is indented starting on the next line. You already saw examples of creating and calling a function above, but here is another example:

    def test_func(number, string):
        x = number * string
        return x

Functions may also *return* an object when they run. If you insert the `return` statement into a function’s code, the function will terminate at that point and return the result to the calling program. The `return` statement is the main way you will send the results of functions back to the calling program or function.

The above function should return a string that is a concatenation of the input string repeated times the input number. You can test the function by calling it with input argument as shown below:

    >>> test_func(3,'go')
    'gogogo'

### Simple Python Programs

Now you can stop the interactive prompt and start writing programs. A Python program is just a text file that contains Python statements. The program file name ends with the *.py* extension.

For example, use your favorite text editor to create a file called *program.py* on your Linux PC. The contents of the file should be:

    a = 'Hello World'
    print(a)

The simplest way to run a Python program is to run it using Python. For example, open a Terminal window, and type the following:

    > python program.py
    Hello World

The above text will run the file *program.py* in the Python interpreter.

In Linux, you may also just call the program file at the command prompt. Start the program file with the following text:

    #!/usr/bin/python3  

This *[shebang](https://en.wikipedia.org/wiki/Shebang_(Unix))* line is used at the start of most interpreted program files. Linux uses it to determine which programming language interpreter it needs to start to run the program. You should just make a habit of including it, regardless which operating system you use.

### Python Modules

You can create simple, or very complex, Python programs all in one file. But, as you get more experience using Python in network engineering, you will start breaking your programs up into separate files that can be maintained and tested separately. 

To bring code from another file into your Python program at run time, use the *import* statement. Everything you import to your program is called a *module*, even though, on its own, it just looks like any other Python program. You will usually have one main program file with the basic logic of your program, and you may create other files, now called modules, that contain definitions for functions and other objects that your main program will call.

Python also comes with many built-in modules you can import to your program to access more functionality. Look at the Python [socket](https://docs.python.org/3/library/socket.html) and [requests](http://docs.python-requests.org/en/master/) modules, for example. Also, many third-party developers create modules that you can install in Python and then import into your own programs. Some of these are especially useful to network engineers. For example, look at the [napalm](https://napalm-automation.net) and [paramiko](http://www.paramiko.org) modules.

Let's experiment with creating a module. This module will simply define five objects using an example you used previously.

Open a text editor and create a Python program called *mod01.py*. Add the following text:

    #!/usr/bin/python3
    a = 10
    b = 10.0
    c = 'text'
    d = ['t','e','x','t']
    def fun(input):
        print(input + ' is fun!')

Save the file *mod01.py*.

Now, open the Python interactive prompt:

    > python

Check the objects Python tracks in memory:

    >>> dir()
    ['__annotations__', '__builtins__', '__doc__', '__loader__', '__name__', '__package__', '__spec__']

Now import the module you created:

    >>> import mod01

Now check the objects tracked by Python again:

    >>> dir()
    ['__annotations__', '__builtins__', '__doc__', '__loader__', '__name__', '__package__', '__spec__', 'mod01']

See that a new object has been created, called *mod01*. This object has *methods* that are objects contained within it; the objects you created in the *mod01.py* program. View them by running the *dir()* function:

    >>> dir(mod01)
    ['__builtins__', '__cached__', '__doc__', '__file__', '__loader__', '__name__', '__package__', '__spec__', 'a', 'b', 'c', 'd', 'fun']

See that the module *mod01* conatins the usual Python objects, plus the five objects you created. These objects were created because, when Python read the *import* statement, it ran the file *mod01.py* and the statements in that file created the objects.

To access these specific objects in the main program, call each object's method by name using the syntax for calling object methods. For example:

    >>> mod01.a
    10
    >>> mod01.d
    ['t', 'e', 'x', 't']
    >>> mod01.fun('wrestling')
    wrestling is fun!
    >>>

Of course, you need to know what each of the module's methods is so you can use it properly. If you are using a Python module or a third-party module, consult the module's documentation to learn how to use all its methods.

Importing large modules can use up a lot of memory and you may only use a few specific methods from a module. There are ways to be more efficient but, for now, just import modules and don't worry about memory usage. I am keeping this guide simple so I will not discuss importing specific objects from modules, or the concepts and issues related to Python *namespaces*. Just remember those are things you will want to learn later in your learning journey.

### If \_\_name\_\_ == '\_\_main\_\_':

If you are reading code that someone else wrote, you will probably see a code block near the end of the file that starts with a statement like the following :

    if __name__ == '__main__':    

This code tests if this file is being run in Python as the main file. It is usually found in Python modules files so those files can be tested, or run, by themselves. The code in this if block will not run of it is in an imported module. This allows Python developers to create modules that, when run by themselves, can test their own code.

The `if __name__ == '__main__':` code block will contain statements that run the functions defined in the module file (or imported from other modules). By convention, Python programmers use this text in every file that also contains function definitions, even the main program file. 

If you see this text in the main program file in a Python project, it will contain the code that starts the program. 

### Get user input

Typically, your Python program will require some input from a user. This input can be input as arguments at the command line when the python program start, or it may be gathered by the program at run time by asking for input from a user. It may even be read in from a file.

To input arguments at the command line, you would need to explore some topics like the Python *sys* and *argparse* modules, how to parse arguments, how to test arguments before using them, and more. I'm choosing not to discuss that in this simple guide, but you can find some good information about [parsing Python program command line arguments](https://docs.python.org/library/argparse.html) in the Python documentation.

You will have to learn to reading input from a file and write to a file in the near future. I skip that topic in this guide. Information about [using Python to read input from a file](https://docs.python.org/tutorial/inputoutput.html#reading-and-writing-files) is in the Python documentation.

I suggest that, while you are still learning the basics, use Python's *input()* function to request and receive user input. This lets you prompt the user for input and then reads the first line the user types in response. It reads the input as a string, so you may need to convert it to another object type if that is what you require. For example, try the following at the Python interactive prompt:

    >>> age = input('How old are you? ')
    How old are you? 51
    >>> age
    '51'
    >>> x = int(age)
    >>> newage = x + 10
    >>> print('you will be ' + str(newage) + ' in ten years')
    you will be 61 in ten years
    >>>

### Final example

Bring most of the concepts I discussed above together into one final example. Create two Python files using a text editor. One will be the main Python script and the other will be a module containing some function definitions.

The script will gather three numbers from the user, add them together, and then output the name of the new number, in English.

The first file will be a Python module containing all our functions. Save it with the filename *functions.py*. The text in the file is:

    #!/usr/bin/python3
    
    ones = ["one","two","three","four","five","six","seven","eight","nine"]
    teens = ["eleven","twelve","thirteen","fourteen","fifteen","sixteen","seventeen","eightteen","nineteen"]
    tens = ["","twenty","thirty","forty","fifty","sixty","seventy","eighty","ninty"]
    hundred = "hundred"
    
    def input_ok(input):
        if input >= 1000:
            return False
        elif input <= 0:
            return False
        else:
            return True
    
    def convert_to_text(number):
        string = str(number)
        number_length = len(string)
        if number_length == 1:
            print(ones[number-1])
        elif number_length == 2:
            low_digit = int(string[1])
            mid_digit = int(string[0])
            if mid_digit == 1:
                print(teens[low_digit-1])
            else:
                x = tens[mid_digit-1] + " " + ones[low_digit-1]
                print(x)
        elif number_length == 3:
            low_digit = int(string[2])
            mid_digit = int(string[1])
            high_digit = int(string[0])
            if mid_digit == 1:
                b = teens[low_digit-1]
            else:
                b = tens[mid_digit-1] + " " + ones[low_digit-1]
            print(ones[high_digit-1] + " " + hundred + " " + b)
        else:
            print("Error: bad input not caught")

The second file will contain the main program logic. Save it as *numtext.py*. The text in the file is:

    #!/usr/bin/python3
    
    import functions
    
    number_list = []
    i = 0
    while i != 3:
        numstr = input("Enter a number: ")
        numint = int(numstr)
        if functions.input_ok(numint):
            number_list.append(numint)
            i += 1
        else:
            print("Input must be less than one thousand and greater than zero")
    
    for j in number_list:
        functions.convert_to_text(j)

See how you imported the *functions* module? When Python encountered the *import* statement, it ran the *functions.py* file, which created the list objects and functions in memory. These functions were addressed using the module name in the code.

There are many ways this simple program can be improved. For example, you could improve the *input_ok* function so it also checks for non-numeric characters; you could improve the logic of the *convert_to_text* function so it is more concise and elegant.

Now, run the program and see the results. At the command prompt, enter the name of the main script, *numtext.py* to run it.

    > numtext.py
    Enter a number: 51
    Enter a number: 13
    Enter a number: 78
    fifty one
    thirteen
    seventy eight

Try again with numbers outside the acceptable range of 1 to 999:

    > numtext.py
    Enter a number: -34
    Input must be less than one thousand and greater than zero
    Enter a number: 0
    Input must be less than one thousand and greater than zero
    Enter a number: 5
    Enter a number: 6
    Enter a number: 30000
    Input must be less than one thousand and greater than zero
    Enter a number: 51
    five
    six
    fifty one

Now you have introduced yourself to the basic building blocks of the Python programming language. You can build programs that gather user input, perform evaluations and calculations, and output results to the terminal window. 

### Conclusion

I covered the elements of Python programming that represent the minimum knowledge a network engineer should have to get started writing useful scripts in Python. There is still more to know, such as learning about Python's built-in networking modules and modules created by third parties, learning about the application programming interfaces supported by networking equipment from various vendors, and learning about network automation best practices.

After reading this guide, I hope you feel you are ready to start learning about these other topics, while using the Python programming language to interact with those technologies. You will learn more about Python as you experiment with it to develop network automation programs.

### Resources

Sites that provide information about Python programming are listed below: 

* [https://www.python.org/](https://www.python.org/)
* [https://learnxinyminutes.com/docs/python3/](https://learnxinyminutes.com/docs/python3/)
* [https://docs.python.org/3/tutorial/](https://docs.python.org/3/tutorial/)
* [https://wiki.python.org/moin/](https://wiki.python.org/moin/)  

