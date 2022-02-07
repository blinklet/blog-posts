# 0 Prepare

Windows terminal
----------------
open new tab
make new tab screen a different color (ctrl-shift-P "color")
change tab colors
rename tabs
increase font size (ctrl +) once

change prompt 
-------------
function prompt {
  $p = Split-Path -leaf -path (Get-Location)
  "$p> "
}

Panes
-----------
split windows
alt + shift + +/=

close splits
ctrl - shift - W

alt - arrow to move between panes
shift-alt-arrow to resize panes

Create alias
------------
New-Alias -Name ed -Value "..\micro-2.0.10\micro.exe"

ls -n  (for smaller listing)

=================================================




# 1  The Minimum You Need to Know About Python

Some of you might like to add the Python programming language to your toolkit. I created a Python guide a few years ago and converted it into this presentation. I hope you enjoy it.  

# 2  Who is this presentation for?

This presentation assumes you already have some experience programming in another language, even if that was 20 years ago in college. I assume you already know about `if` statements, loops, and functions. 

I will not teach programming in this presentation. I will show you how to relate Python to the things you already know.

# 3  Why Python?

Python is a very popular programming language and it has a huge library of add-on packages that are useful to data scientists and analysts.

You need to know very little about Python to get started writing simple programs that you can use in your daily work. But, Python is a real programming language so when you need to do more complex things, Python can support them. For example, Reddit and Instagram run on Python.

# 4  Simple, and mostly correct

I don’t want you to have to unlearn misconceptions later, when you become more experienced, so I do include some Python concepts that other beginner guides might skip, such as the Python object model. 

But, I do not cover all the basic Python statements and syntax rules because we have limited time and they are easy for you to learn when you need them.

# 5  Get set up

If you have already installed Windows Terminal and Python, you can follow along. If not, you can use the links on this slide to get set up later.

# 6  Minimal Python

In this presentation, I will cover a basic overview of the Python object model and then describe the core object types that Python can create.

Then I will talk about how you can use code written by other people in your own programs. This is something Python programmers do a lot.

Then I'll cover the basic Python statements you can use to write your own programs

## demo

At this point, we should start running Python. Python has several ways to use it. One way is to just run an interactive Python session. Open up Windows Terminal and type `python`:

```
python
```

The triple chevron tells you that you are running Python. 

The interactive prompt is a great way to experiment with Python. I often use it to quickly test if an expression will work.

# 7  Objects in Python
 
Python is based on objects but it is not purely an object-oriented programming language. You do not need to use its object-oriented features to write useful programs. You accomplish a lot while using Python as a procedural programming language, which is familiar to most people who have a little programming knowledge. 

While I focus on procedural programming methods in this presentation, I will still use terms related to objects so that you have a good base from which you may expand your Python skills.

In Python, an object is just a thing stored in your computer’s memory. For example, integers are objects. So are data structures like lists, and pieces of executable code like functions.

# 8  Objects in Python

Objects are created by Python statements. After objects are created, Python keeps track of them until they are deleted. An object can be something simple like an integer, a sequence of values such as a string or list, or even executable code. There are many types of Python objects.

Python creates some objects by default when it starts up, such as its built-in functions. Python keeps track of these objects and of any objects created by the programmer.

## demo

When you start Python, it creates a number of objects in memory that you may list using the Python `dir()` function, which shows you the attributes of objects. For example:

```python
dir()
['__annotations__', '__builtins__', '__doc__', '__loader__', '__name__', '__package__', '__spec__']
```

If I create new object such as a variable named "a" that points to an integer object:

```python
a = 100
dir()
['__annotations__', '__builtins__', '__doc__', '__loader__', '__name__', '__package__', '__spec__', a]
```

We see that Python is now keeping track of a new object named "a".

The point I am making is that everything in Python is an object. 

And you can find out an object's type using Python's `type()` function

```python
type(a)
<class 'int'>
```

You can also find out more about an object using Python's `help()` function, which is a great way to learn more about Python:

```python
help(a)
```

Since variable `a` points to an integer object, `help(a)` returns the built-in documentation for an integer.

# 9  Defining Python Objects

In Python, statements define an object simply by assigning it to a variable or using it in an expression.

You do not need to declare the type of an object before you create it. Python infers the object type from the syntax you use to define it. This is called "duck typing". If it quacks, it's a duck.

## demo

In this example, `a` defines an integer object, `b` defines a floating-point object, `c` defines a string object, and `d` defines a list object, and in this example each element of the list is a string object.

```
>>> a = 10                  # An integer 
>>> b = 10.0                # A floating point 
>>> c = 'text'              # A string 
>>> d = ['t','e','x','t']   # A list (of strings)
```

See how the syntax defines the object type: different objects are created if a decimal point is used, if quotes are used, if brackets are used, and depending on the type of brackets used. 

I will explain each of the Python object types a little bit later in this guide.

# 11  Object methods

Each instance of a Python object has a value (or values), but it also inherits functionality from the core object type which includes built in functions and executable code. Python’s creators built functions, which they call *methods* into each of the Python core object types. You access this built-in functionality using object methods.

For example, number objects have mathematical methods built into them that support arithmetic and other numerical operations; string objects have methods to split, concatenate, or index items in the string.

The syntax for calling methods involves adding the name of the method, separated by a period, after the object name and ending with closed parenthesis containing arguments.

## demo

Look at all the methods and objects associated with the integer object by using the dir() function:

```python
a = 100
dir(a)
```

You get a long list of object methods. These were all defined by the creators of Python and are “built in” to the integer object. From this list, you see that one of the methods associated with the integer object `a`, is `bit_length`. Use `help()` to get more information about what this method does:

```python
help(a.bit_length)
```

See it returns the minimum number of bits required to represent the number in binary. 

```python
a.bit_length()
7
```

Every Python object also comes with built-in methods that are available when the object is created. 

# 12 Core Object Types

The most commonly-used Python object types are:

* Integers
* Floating point objects
* File objects
* String objects
* List objects
* Tuples
* Dictionary objects
* Program Unit objects

## demo

### integers

We've already seen Integer types. 

### floating point numbers

Floating point objects support numbers with fractional parts, like `1.5`

```python
f = 1.5
type(f)
```

### Files

Files are objects created by Python’s built-in `open()` function which will create a new file or open an existing one. The `open()` function returns a file object which is assigned to a variable name, so you can reference it later in your program. For example:

(r = read only, w = write, r+ = read/write, a=append, a+ = append and read, x = exclusive)

```python
myfile = open('myfile.txt', 'w')
myfile
```

Remember, you can see all the methods available for the file object you created by typing `dir(myfile)`.

```python
dir(myfile)
```

For example, write to the file using the file object's `write` method:

```python
myfile.write("this is one line\n")
myfile.write("this is more text\n")
myfile.write("can\nadd\nmultiple\nlines\n")
txt = "this is the last line\n"
myfile.write(txt)
```

You may close a file using the file object’s close method.

```python
myfile.close()
```

```
type myfile.txt
```

```python
myfile = open('myfile.txt', 'r')
data = myfile.readlines()
data
```

The file object's readlines method returns a list that contains strings; each string is one line from the file.

### Strings

Strings objects may be text strings or byte strings.

Readable text strings are created with quotes as follows:

```python
>>> z = 'text'
>>> z
'text'
```

Strings can be iterated over in a `for` loop but cannot be changed in place like lists can (they are immutable -- more on this later).

### Lists

Python has built-in data structure objects like lists, dictionaries, tuples, and sets. The list and the dictionary are the most commonly used data structures.

You create a list object in Python using square brackets around a list of objects separated by commas. For example:

```python
k = [1,3,5,7,9]
```

I created a list of five integer objects.

Python lists are very flexible and may contain a mixture of object types. For example:

```python
v = [1, "fun", 3.14]
```

This list object contains three objects: an integer object, a string object, and a floating-point object. Lists can also contain other lists, which is knows as nested lists. For example:

```python
u = [k,v]
u
[[1,3,5,7,9],[1, "fun", 3.14]]
```

I created a list of two objects, each of which is a list of other objects.

Individual items in a list can be evaluated using index numbers. For example:

```python
u
[[1,3,5,7,9],[1, "fun", 3.14]]
u[0]
[1,3,5,7,9]
u[1]
[1, "fun", 3.14]
u[1][0]
1
```

Lists are a useful “general purpose” data structure and, in most programs, you will use lists to gather, organize, and manipulate sequential data. Lists are often used as iterators in `for` loops.

There are many list object methods for manipulating the sequence of items stored in the list data structure. See the Python documentation for more details.

### Dictionaries

Dictionaries are used to store data values in key:value pairs. They are a very useful data structure and you will use them a lot.

Dictionaries are created using curly brackets and colons to separate the key value pairs.

```python
d2 = {'car':'Audi','color':'blue','wheels':4,'driver':'Brian'}
d2
type(d2)
```

You index items by key

```python
d2['car']
```

### Program Unit Objects

Like any programming language, Python has programming statements and syntax used to build programs. In addition to that, Python defines some object types used as building blocks to create Python programs. These program unit object types are:

* Operations
* Functions
* Modules
* Classes

#### Operations

Python contains operators to assign values, do arithmetic, make comparisons, and do logic. I cover operators like `=`, `+`, `>`, `==`, `or`, and `and` later.

### Functions

Functions are containers for blocks of code, referenced by a name. They are a universal programming concept used by most programming languages and may also be called subroutines or procedures. 

Some functions are already built into Python, like the `sum()`, `dir()` and `help()` functions. See the Python documentation for a list of all built in functions.

The Python `def` statement defines function objects. The def statement syntax is: `def function_name(argument1, argument2, etc):` followed by statements that make up the function.

Python uses leading spaces to group code into statements. 

```python
def fun(input):
    x = input + ' is fun!'
    return x
```

Press return on an empty line to finish defining the function.

Python created a function object named `fun`. Run the `dir()` function. You can see that the object named `fun` has been added to the list of objects Python is tracking:

```python
dir()
```

Call the function by typing its names and including a string as an input parameter:

```python
fun('skiing')
```

You can do a lot with functions and, until you get to advanced topics like object-oriented programming, functions will be the primary way you organize code in Python.

### Modules

A Python module is a file containing Python code that you can import into another program. Modules allow you to organize large projects into multiple files and also allow you to re-use code created by other programmers. 

You can see all Python's built-in modules by typing `help('modules')`. I will cover modules in more detail when I discuss running our Python program from saved files.  

### Classes

Classes are used in object-oriented programming. I ignore Python classes in this guide. You will eventually need to learn about classes and basic object-oriented programming if you want to work with certain Python libraries and frameworks.

# 13  Object Mutability

You usually do not need to worry about whether objects are mutable (like lists and dictionaries) or immutable (like integers and strings).

As you work on more complex projects, where you will work with more object types, or you will be copying objects, you need to understand this concept. 

Again, you can learn about this when you need to know it.

# 14  Statements

A python program is composed of statements. Each statement contains expressions that create or modify objects. 

Python statements are grouped into the following categories:

* Assignment statements such as `a = 100`
* Call statements that call objects and object methods. For example: `fun('skiing')` or `a.bit_length()`
* Selecting statements such as `if`, `else`, and `elif`
* Iteration statements such as `for`
* Loop statements such as `while`, `break`, and `continue`
* Function statements such as `def`

That list is a good starting point for building Python programs.

# Operators

Here's a list of the most important operators used in Python statements.

* assignment operators like `=`
* arithmetic operators like `+`,`–`,`*`, and `/`
* comparison operators like `>`, `>=`, `==`, and `!=`
* logic operators like `and`, `or`, `is`, and `not`

# 16  Syntax

Python organizes the syntax of statements — especially control statements like `if` statements, or `for` statements — by indenting lines using blanks or tabs. 

Most people use blanks. Just pick one and use it consistently.

# 17 f-strings

f-strings are the new way of formatting strings. You just put a `f` in front of the string and then you can use the f-string rules for formatting, which are easier to use than older methods.

Many Python books and online guides still cover the old way of formatting strings. If you are reading a Python book and they start talking about `str.format()` or using the `%` sign everywhere, skip that section and look up a guide on f-strings on the Internet.

That should save you some time.

# 18 Simple Python Programs

Now you can stop the interactive prompt and start writing programs. 

A Python program is just a text file that contains Python statements. The program file name ends with the .py extension.

## demo 

For example, use your favorite text editor to create a file called `program.py` on your PC. The contents of the file should be:

```python
a = 'Hello World'
print(a)
```

The simplest way to run a Python program is to run it using Python. For example, open a Terminal window, and type the following:

```
> python program.py
Hello World
```

to run the file `program.py` in Python.

There are other ways to launch Python programs. But, when getting started, just use the `python` command to run Python programs.

Let's do a bit more. Let's print the contents of the file *myfile.txt* to the console.

Add the following text to the `program.py` filr:

```python
myfile = open('myfile.txt', 'r')
data = myfile.readlines()
print(data)
```

We see it prints out the contents of the file as a Python list. To make the output look better, we need to iterate through the list and print each list item on a new line.

Replace the last print statement with a for loop that will iterate through the list.

```python
for line in data:
    print(line)
```

Oops, that looks bad. The print function adds a newline to each line it prints, so each line gets printed with two newlines, one from the file and one added by the print function.

There is a keyword argument in the print function that allows me to specify the type of character that it adds to the end of the line. I changed the added character to "nothing" so the only newlines are the ones stored in the file.

```python
for line in data:
    print(line, end='')
```

# 19  Modules

You can create very complex Python programs all in one file. But, as you get more experience using Python, you will start breaking your programs up into separate files, called modules, that can be maintained and tested separately.

To bring code from a module file into your Python program at run time, use the `import` statement. 

Python also comes with many built-in modules you can import to your program to access more functionality. Also, many third-party developers create modules that you can install from Python packages and then import into your own programs. Some of these are especially useful to data scientists and analysts. For example, look at the `pandas` module.

## demo

Let’s experiment with creating a module. This module will simply define five objects.

Open a text editor and create a Python program called mod01.py. Add the following text:

```python
a = 10
b = 10.0
c = 'text'
d = ['t','e','x','t']
def fun(stuff):
    print(stuff + ' is fun!')
```python

Save the file as `mod01.py`.

Now, write a main program that imports the module and uses its functions:

```python
print(dir())  # Check the objects Python tracks in memory
print()

import mod01  # Import the module you created

print(dir())  # See that object has been created:
print()

print(dir(mod01))  # See the objects created by importing mod01

print(mod01.a)  # Use the objects in module mod01.
print(mod01.c)       # Call each object’s method by name 
for x in mod01.d:    # using the syntax for calling 
    print(x))        # object methods.
    z = 'wrestling'
    y = mod01.fun(z)
    print(y)
```

Save the file as `prog01.py`. Then run it.

```
python prog01.py
```

Oops. We see an error message! Python has pretty good error messages. 

We see that this error occurred on line 6 in the `mod01.py` file. I have an extra parenthesis. The traceback lists the most recent line last so you have to work from the bottom up if you want to see what else was happening. In this example, we see that the error occurred when the module `mod01` was imported on line 4 of the `prog01.py` file. Remember that importing a module runs all the code in the module file at the moment the import happens.

Fix the error and run again.

(open the prog01.py file in editor for next step)

```
python prog01.py
```
See how list of objects returned by the `dir()` function is different from before and after we imported module `mod01`. Python added module `mod01` to the list of objects it tracks.

We also see that the objects contained in module `mod01`.

Oops. We see a logic error cause by syntax. We see the `fun` function got called four times. That's because it is inside the `for` block. Fix that by removing the indentation so the `fun` function gets called in the main code block.

(remove spaces)

Run the file again and see the correct output

```
python prog01.py
```

See that the module `mod01` contains the usual Python objects, plus the five objects we created in the module. When Python read the import statement, it **ran** all the code in the file `mod01.py` and the statements in that file created the objects.

Of course, you need to know what each of the module’s methods is so you can use it properly. If you are using a Python module or a third-party module, consult the module’s documentation to learn how to use all its methods.

# 20  If __name__ == ‘__main__’:

If you are reading code that someone else wrote, you will probably see a code block near the end of the file that starts with a statement like the following.

```python
if __name__ == '__main__':    
```

The code in this `if` block will not run when the module is imported. But it will run when the module file is run by itself. This allows Python developers to create modules that, when run by themselves, can test their own code.

This code block will contain statements that run the functions defined in the module.

If you see this in the main program file in a Python project, it will contain the code that starts the program.

## demo

First run the module directly and see what happens

```
python mod01.py
```

Nothing! The file added objects to memory, then deleted them when Python finished running the file.

Let's add some test code to our `mod01` module:

```python
if __name__ == '__main__':
    print(a, b, c, sep='   ')
    print(d)
    fun('testing')
```

See the test code run by running the module.

```
python mod01.py
```

Now someone who maintains this file can test it without having to run the main program file.

# 21  Installing packages

There are over 300,000 packages in the Python package index (PyPI) at https://pypi.org

Install Python Packages using the `pip` command

```
pip install wheel
```

Import modules from the package into your programs or your modules. You need to read the package documentation to learn which modules are in the package and which functions or methods are available in each module.

Because there are so many packages, there is a good chance that anything complex you need to do - from parsing CSV files to complex calculus - can be made easier by using an existing package.

# 22  Python Virtual Environments

The main purpose of Python virtual environments is to create an isolated environment for Python projects. Learn about them when you need to.

If you plan to install a lot of packages, or if one project needs a special version of a package, best to start using virtual environments.

## demo

```
python -m venv env
./env/Scripts/activate
pip freeze
deactivate
```

# 23 Basic User Input

Typically, your Python program will require some input from a user. This input can be arguments entered at the command line when you start the python program, or it may be gathered by the program during run time by asking for input from a user. It may also be read in from a file.

You can find some good information about parsing Python program command line arguments in the Python documentation.

I suggest that, while you are still learning the basics, use Python’s `input()` function to request and receive user input. This lets you prompt the user for input and then reads the first line the user types in response.  

## demo

For example, create a program named `age.py`.

```python
age = input('How old are you? ')
a = int(age)
b = a + 1
print(f'Next year you will be {b} years old')
```

Run the program

```
python age.py
```

# 24  Program Example

# demo

Let's bring most of the concepts I discussed above together into one final example. Create two Python files using a text editor. One will be the main Python script and the other will be a module containing some function definitions.

The script will gather three numbers from the user, add them together, and then output the name of the new number, in English.

The first file will be a Python module containing all our functions. Save it with the filename `functions.py`. The text in the file is:

```python
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
```

The second file will contain the main program logic. Save it as `ntext.py`. The text in the file is:

```python
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
```

See how I imported the functions module? When Python encountered the import statement, it ran the `functions.py` file, which created objects and functions in memory. These functions were addressed using the module name in the code.

Now, run the program and see the results. At the command prompt, enter the name of the main script, numtext.py to run it.

```
python ntext.py
```

There are many ways this simple program can be improved. For example, you could improve the `input_ok` function so it also checks for non-numeric characters; you could improve the logic of the `convert_to_text` function so it is more concise and elegant.

Or, you could replace the `convert_to_text` function with a function imported from the `numtext` package.

https://pypi.org/project/numtext/

```
pip install numtext
```

Then change `ntext.py` program so it imports and uses the numtext module. Also no longer need to validate input number is between 0 and 1000 because numtext supports numbers up to 999 Duotrigintillion, which is 10 to the power of 99 (and I was not checking for other invalid inputs, anyway).

```python
import numtext

number_list = []
i = 0
while i < 3:
    num = input("Enter a number: ")
    number_list.append(num)
    i += 1

k = 0
print("The numbers you entered were:")
for j in number_list:
    print(numtext.convert(j))
    k = k + int(j)

l = numtext.convert(k)
print(f"They add up to: {l}")
```

# 25  Learn More

At this point, you've learned enough to do useful work. The best way to learn more is to start a Python project of your own and learn what you need to learn as you work through it.

I wrote a Python guide that includes all the information in this presentation. It is available at the Nokia Python User Community on Yammer. I also included a few additional links on this slide to information you might want to check out to take the next steps using Python.

Thanks.