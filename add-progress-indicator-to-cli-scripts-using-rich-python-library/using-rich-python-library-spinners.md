# Using the Python Rich library progress indicators

I recently added a status indicator to my [*azruntime* application](https://github.com/blinklet/azure-scripts/tree/main/azruntime). If users have a lot of VMs in their subscriptions, the *azruntime* application can take a long time to run. Users will appreciate seeing the status so they know the program is still running and is not hung up.

![](./Images/rich-logo-transparent.png)

I used the [Rich library](https://github.com/willmcgugan/rich) to implement a status indicator. I had to learn more about Python context managers to understand how the Rich library's progress bar and status indicators work. The [Rich library's documentation](https://rich.readthedocs.io/en/stable/index.html) is aimed at intermediate-to-advanced programmers and the Rich tutorials I found on the web did not cover using the Rich library's status update features.

In this post, I will share what I learned while adding a status indicator to my program and show you how to implement the same in your projects.

<!--more-->

# Rich library overview

The Rich library makes it easy to add color and style to terminal output. Rich can also render pretty tables, progress bars, markdown, syntax highlighted source code, tracebacks, and more. ((From the [Rich GitHub README](https://github.com/willmcgugan/rich) page, accessed March 2, 2021)) 

This post focuses only on creating a status indicator. To learn more about what Rich can do for you, I encourage you to read one of the excellent Rich overiews available on the Internet. I list a few below:

* [Python Rich - The BEST way to add Colors, Emojis, Tables and More (video)](https://www.youtube.com/watch?v=JrGFQp9njas)
* [Building Rich Console Interfaces in Python](https://medium.com/trabe/building-rich-console-interfaces-in-python-16338cc30eaa)

Another way to see how Rich can improve text output in your Python console applications is to run the sample code provided by the Rich package. Run the following to see most of what Rich can do:

```
(env) $ pip install rich
(env) $ python -m rich
```

This will output a sample screen, as shown below:

![](./Images/rich01.png)

## Learning from Rich sample code

The Rich project provides sample code for all its features. I found that the sample code was the best way to understand how to use each feature. 

First, I run the sample code to see what the output looks like. Then I open the file and look at the code. The Rich library modules are listed in the Rich library documentation's [Reference section](https://rich.readthedocs.io/en/stable/reference.html). 

Run the sample code by running the module. For example, I was looking for a way to create a status update. I saw the module named *rich.update* and decided to try it. I ran the command:

```
(env) $ python -m rich.status
```

I saw that the output looks like the kind of status updates I wanted. See the output below: 

![](./Images/richgif01.gif)

The console displayed spinner icon next to some text that changes as the program runs. Next, I clicked on the [rich.status module](https://rich.readthedocs.io/en/latest/reference/status.html) on the Rich documentation's References page. I saw the module documentation. To see the examples in the source code, I clicked on the source code link, as shown below:

![](./Images/rich02.png)

In the module's source code, I scrolled to the bottom to find the test code in the *if \_\_name\_\_ == "\_\_main\_\_":* block. As shown below, I can compare the code with the results I saw when I previously ran the module.

![](./Images/rich03.png)

After looking at the *rich.status* module's output, it's reference page, and its source code, I now see how I can implement a "spinner"-style status indicator for my *azruntime* application.

I need to first create a console object from the Rich Console class. Then, I create a context manager using the console object's *status* method and set an initial status message in it. Finally, each time I want to change the status message in the running context, I use the *rich.status.update* method.

# Python context managers

I am using Rich to add functionality to an existing program and, until I started using the Rich library, I had never used context managers or the *with* statement. I re-read that Exceptions chapter in the [Learning Python book](https://learning-python.com/about-lp5e.html)((Learning Python, 5th edition, Chapter 33, pp 1152-1156)) and looked at [some](https://www.youtube.com/watch?v=U2t2t_cpvoc) [online](https://alysivji.github.io/managing-resources-with-context-managers-pythonic.html) [tutorials](https://www.youtube.com/watch?v=iba-I4CrmyA). Now, I can explain more about Python context managers.

[Context managers](https://www.python.org/dev/peps/pep-0343/) are created by the *with* statement. They are an advanced Python topic but we use them all the time. Most beginner Python programmers have seen the *with* statement in examples and in tutorials. It is commonly used when [working with files](https://realpython.com/lessons/with-open-pattern/).

A typical example is shown below:

```
with open('example.txt','r') as reader:
    print(reader.read())
```

In the above example, the *with* statement calls the *open()* function and assigns the returned object, which is a file object, to a variable named *reader*. The next line prints everything returned by the file object's *read()* method. The context manager code built into the file object closes the *example.txt* file as soon as the last statement in the code block, which in this case is the *print()* function, completes. 

If you do not use the with statement, as shown below, Python will keep *example.txt* file open until the programmer tells it to do otherwise. 

```
reader = open('example.txt','r')
print(reader.read())
```

In the above example, the file object returned by the *open()* function is assigned to a variable named *reader*. The next line prints everything returned by the file object's *read()* method. In this case, the programmer must remember to explicitly close the file using the file object's *close()* method, as shown below.

```
reader.close()
```

If the programmer does not close the file, it remains open until either all remaining code in the script finishes running or the *reader* variable is assigned to another object. Python's garbage collection feature will free up the memory used by the file object and close the file. 

The programmer needs to consider what might happen if an error occurs before they close a file. They may need check for errors and close the file using [*try/finally* statements](https://docs.python.org/3/tutorial/errors.html#defining-clean-up-actions). The [*with* statement](https://preshing.com/20110920/the-python-with-statement-by-example/) also [ensures resources are closed](https://stackabuse.com/python-context-managers/) when errors occur and results in easier-to-read code.

Using the *with* statement is the "Pythonic" way to open files or other shared resources like network connections. 

Network engineers who are learning Python will usually use the *with* statement when calling a function that opens a file, a network connection, or a database connection. More advanced programmers may use the [context management protocol](https://martinheinz.dev/blog/34) to create new functions or classes that perform specific actions when a context is closed.

# How Rich uses context managers

Some features of the Rich library, such as the *rich.status* module, must be implemented using the [*with* statement](https://dbader.org/blog/python-context-managers-and-with-statement), which creates a context in which the output on the console screen is created and updated.

Create the following sample program to demonstrate how the *rich.update* module works. To test how *rich.status* will work in a loop, create an run a Python file containing the following code, or run it in the Python REPL.

```
from rich.console import Console
from time import sleep

status_list = ["First status","Second status","Third status"]
console = Console()
with console.status("Initial status") as status:
    sleep(3)  # or do some work
    for stat in status_list:
        status.update(stat)
        sleep(3)  # or do some more work
```

The program creates an object named *console* from the *Console()* class. Then, it creates a context object named *status* from the console object's status method an intitalizes it with a status of "Initial status". Then, it iterates through the *status_list* and updates the *status* object every three seconds. When the program runs you will see a "spinner" icon also gives the user some feedback that the program is running. 

The above program follows the example shown in the *rich.status* module's example code. But, why not use the *Status()* class that exists in the *rich.status* module? In fact, you are already using it. [The *Console()* class's status method imports and uses the *rich.status.Status()* class](https://rich.readthedocs.io/en/stable/_modules/rich/console.html#Console.status). The Rich developers showed an example using the *Console()* class because developers may have multiple things happening in the same console or may use multiple consoles. Using a *console* object makes it clear where the status object's output is to be displayed. 

You may [use the *rich.status.Status()* class directly](https://rich.readthedocs.io/en/stable/_modules/rich/status.html#Status), if you want. And, if you are concerned with which console to use, you may [specify which console object the *rich.status.Status()* class uses](https://rich.readthedocs.io/en/stable/reference/status.html) when you create an object with it. It will use the default console if you do not specify one. 

Below is an example the accomplishes the same status update display as the previous program, but I use the *rich.status.Status()* class directly:

```
from rich.status import Status
from time import sleep

status_list = ["First status","Second status","Third status"]
with Status("Initial status") as status:
    sleep(3)  # or do some work
    for stat in status_list:
        status.update(stat)
        sleep(3)  # or do some more work
```

The program creates a context object from the *rich.status.Status* class, named *status* that is initialized with a status of "initial status". Then it iterates through the list of statuses and displays each one on the screen form three seconds.

Either of the two methods shown above will work. You can also implement status updates using the [*rich.live.Live()*](https://rich.readthedocs.io/en/stable/reference/live.html) or [*rich.progress.SpinnerColumn()*](https://rich.readthedocs.io/en/stable/reference/progress.html#rich.progress.SpinnerColumn) classes.

# Adding Rich to *azruntime*

Showing how I added a status indicator to an existing program will help you better understand how to implement Rich library features.

I will use the *rich.console.Console()* class because it is the way the Rich developers implemented status updates in the *rich.status* module. Because the *rich.console.Console()* class must be implemented using a context manager, I need to implement it inside a function and I cannot pass a context manager to other functions. 

My [*azruntime* module](https://github.com/blinklet/azure-scripts/tree/main/azruntime#azruntime) defines a function named *build_vm_list*, which uses nested *for* loops to iterate through through generators that information about each virtual machine, per  resource group, per subscription. The *build_vm_list* returns a nested list containing the run time information about all VMs in my subscriptions. That list is rendered as a table to the console by another function. 

I opened my *azruntime* program in a text editor and made the following changes. 

First, I import the Rich modules I will use:

```
from rich.console import Console
```

In the *build_vm_list()* function, I created a new Rich console and used the *with* statement to create a *console.status* context manager named *status* before the first *for* loop:

```
console = Console()
with console.status("[green4]Getting subscriptions[/green4]") as status:
```

I indented all the nested loop code below the *with* statement so Python knows it is part of the *status* context.

Finally, in the deepest nested loop, I update the *status* context with a status message containing the subscription name, resource group name, and VM name available at that point in time.

```
status.update(
    "[grey74]Subscription: [green4]" +
    subscription_name +
    "[/green4]  Resource Group: [green4]" +
    resource_group +
    "[/green4]  VM: [green4]" +
    vm_name +
    "[/green4][/grey74]"
)
```

The new function looks like the following. I removed some code to make the example shorter. [The entire *build_vm_list()* function code is available in the *azruntime* repository on GitHub](https://github.com/blinklet/azure-scripts/blob/61e5c1d9da6498bff786214a672de9a875bfac9c/azruntime/azruntime/azruntime.py).

```
def build_vm_list(credentials):

    headers = [
        'VM name', 'Subscription', 'ResourceGroup',
        'Size', 'Location', 'Status',
        'TimeInState', 'style'
    ]

    returned_list = list()
    returned_list.append(headers)

    subscription_client = SubClient(credentials)
    subscriptions = sublist(subscription_client)

    console = Console()
    with console.status("[green]Getting subscriptions[/green]") as status:

        for subscription_id, subscription_name in subscriptions:

            resource_client = ResourceClient(credentials, subscription_id)
            compute_client = ComputeClient(credentials, subscription_id)
            monitor_client = MonitorClient(credentials, subscription_id)
            resource_groups = grouplist(resource_client)

            for resource_group in resource_groups:
                vms = vmlist(compute_client, resource_group)

                for vm_name, vm_id in vms:

                    status.update(
                        status="[grey74]Subscription: [/grey74][green4]" +
                        subscription_name +
                        "[/green4][grey74]  Resource Group: [/grey74][green4]" +
                        resource_group +
                        "[/green4][grey74]  VM: [/grey74][green4]" +
                        vm_name + "[/green4]"
                    )

                    """...other code that builds list of VM information..."""

        return returned_list
```


# Conclusion

I used the [Python Rich library](https://rich.readthedocs.io/en/stable/index.html) to implement a status display for [my *azruntime* CLI application](https://github.com/blinklet/azure-scripts/tree/main/azruntime#azruntime), using just a few lines of code.

The Rich library contains many more classes and functions in addition to the *rich.status* module. For example, I also [used the *rich.table* module to render the VM table](https://rich.readthedocs.io/en/stable/reference/table.html) output by the *azruntime* program.

If you add color to your output, [the color tags Rich uses](https://rich.readthedocs.io/en/stable/appendix/colors.html) are listed in the [Rich documentation Appendix](https://rich.readthedocs.io/en/stable/appendix.html).