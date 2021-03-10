# Cancelled

The azure API implements some async methods that start with the "begin_" suffix. But the list and list_all methods do not support the async protocol. So I cannot speed up this program using asyncio.




Async Generators:
https://www.python.org/dev/peps/pep-0525/

https://docs.python.org/3/library/asyncio.html

https://realpython.com/python-async-features/
https://realpython.com/async-io-python/

asyncronous FOR loops
https://quentin.pradet.me/blog/using-asynchronous-for-loops-in-python.html
https://stackoverflow.com/questions/50241696/how-to-iterate-over-an-asynchronous-iterator-with-a-timeout
https://medium.com/educative/python-concurrency-making-sense-of-asyncio-ebf18d722341

Azure async
https://docs.microsoft.com/en-us/azure/developer/python/azure-sdk-library-usage-patterns#asynchronous-operations






Look at existing program, *azruntime*:

Azure API: waiting for response to requests
Good opportunity to try async features of Python


First, evaluate the code to find the areas where you may gain the most benefit from using Python's *asyncio* library. Check the timing of functions,classes, and loops. There are many ways to [test Python code performance](https://therenegadecoder.com/code/how-to-performance-test-python-code/) but, because my *azruntime* program is mostly waiting for I/O from the Azure API, I think the simple "brute force" method is the most appropriate way to test its performance.

Read the system time just before the code you want to test, then read the time immediately after the code and display the difference between the two timestamps. Insert the following code around each block you want to measure:

```
start_time = time.perf_counter()

...code block to test

elapsed = time.perf_counter() - start_time
print(f"Operation x completed in {elapsed:0.2f} seconds.")
```

Run the program and see the print statement ouput in the console. Look for functions or code blocks that take a longer time to run. For example, in the source code for *azruntime v0.6*, which does not have any asyncronous Python code, I found the following potential improvements:

* The *sublist()* function takes about 1.5 seconds to iterate through the Azure subscriptions API client
* The *grouplist()* function takes between 1.5 and 2 seconds to iterate through the Azure resource groups API client, for each subscription. 
* The *vmlist()* functions takes between 0.3 and 2 seconds to iterate through the Azure virtual machines API client for each resource group, for each subscription. 
* In the deepest nested loop in the *build_vm_list()* function, I sequentially request the VM status, VM size, and VM location from the Azure API by calling the *vmlist()*, *vmsize()*, and *vmlocation()* functions. The three operations in sequence take up to one second for each VM, in each resource group, in each subscription.
* The *get_vm_time()* function takes up to 0.5 seconds to run for each VM, in each resource group, in each subscription.

I can improve performnce for the first four items from the above list if I can convert the code in each function to run asyncronously. The last item on the list probably cannot be run asyncronously because the *get_vm_time()* function iterates sequentially through a VM's activity logs to find the *first* instance of a status value. I do not think it's possible to find the first item in a sequence  in an asyncronous manner. So, I can't speed up the *get_vm_time()* function using *asyncio* alone.

Looking at the *azruntime* *v0.6* code, I see that the six functions mentioned in the first four bullet points in the above list make calls to the Azure API.

```
def sublist(client):
    return [(sub.subscription_id, sub.display_name) for sub in client.subscriptions.list()]
```
```
def grouplist(client):
    return [group.name for group in client.resource_groups.list()]
```
```
def vmlist(client, group):
    return [(vm.name, vm.id) for vm in client.virtual_machines.list(group)]
```
```
def vmsize(client, group, vm):
    return client.virtual_machines.get(group, vm).hardware_profile.vm_size
```
```
def vmlocation(client, group, vm):
    return client.virtual_machines.get(group, vm).location
```
```
def vmstatus(client, group, vm):
    return client.virtual_machines.instance_view(group, vm).statuses[1].code.split('/')[1]
```

The Azure API documentation explains that the Azure API clients all support asyncronous operation.
   
```
subscriptions = sublist(subscription_client)
```

Currently, the sublist() function returns a list comprehension as shown below.

```
def sublist(client):
    return [(sub.subscription_id, sub.display_name) for sub in client.subscriptions.list()]
```

Maybe if I refactor the *sublist()* function so each call to *client.subscriptions.list()* starts an asyncronous coroutine, the *sublist()* function will complete faster, especially in the case where there are many subscriptions.

Similar to the *sublist()* function above, the *grouplist()* and *vmlist()* functions take between 1.5 and 2 seconds to iterate through the resource groups client to build list of resource group IDs for each subscription. 

```
def grouplist(client):
    return [group.name for group in client.resource_groups.list()]


def vmlist(client, group):
    return [(vm.name, vm.id) for vm in client.virtual_machines.list(group)]
```

If we have many VMs in many resource groups in many subscriptions, you can see how this will compound the performance problem.

In the deepest nested loop, it takes up to one second to sequentially get the VM status, VM size, and VM location from the Azure API. Maybe I can refactor the following code block so each of the three API calls run in parallel. This could speed up the execution of the code block by a factor of three.

```
vm_status = vmstatus(compute_client, resource_group, vm_name)
vm_size = vmsize(compute_client, resource_group, vm_name)
vm_location = vmlocation(compute_client, resource_group, vm_name)
```

Also in the deepest nested loop, the *get_vm_time()* function takes around 0.5 seconds to execute. 
