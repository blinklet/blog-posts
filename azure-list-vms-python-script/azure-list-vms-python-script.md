% Manage Azure Infrastructure with Python

Authenticate Python applications on your local computer that can manage Azure resources. This enables you to create scripts that help you manage your Azure cloud resources. 

Authenticating applications seems complicated because the Azure Python SDK documentation is targeted at developers writing applications that access Azure services like storage accounts and databases. They use concepts like [Application Registrtion](https://docs.microsoft.com/en-us/azure/active-directory/develop/quickstart-register-app) and [Service Principals](https://docs.microsoft.com/en-us/azure/active-directory/develop/app-objects-and-service-principals). 

Engineers who just want to run applications on their local computer that gather and organize information about their deployed resources may [re-use their own Azure command-line interface login credentials](https://docs.microsoft.com/en-us/azure/developer/python/azure-sdk-authenticate?tabs=cmd).



# Azure Python package versions

At the time I write this post, Microsoft's recommended application authentication methods are not compatible with older versions of its Azure resource management libraries so developers need to be careful about which Python packages they install, or must use other authentication methods if they use older libraries.

For example, the *azure-cli* meta-package installs older versions of Azure resource management libraries that are not compatible with the new Azure application authentication labraries.

If you want to use the newer authentication methods available in the *azure.identity* library, you must install the latest version of the *azure.mgmt.resources* library. You can do this by installing the *azure-mgmt-resources* Python package.

# Install Azure CLI and avoid conflicts with package versions

But, you need to install the *azure-cli* package somewhere on your computer so you can use the *az login* command to login to Azure. Either install it using your system's normal package manager, like *apt* or install it in its own Python virtual environment and run it from there.

[Install Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli). 

Open a new terminal window and install Azure CLI on your Ubuntu Linux system using the *apt* package manager:

```
$ sudo apt-get update
$ sudo apt-get install ca-certificates curl apt-transport-https lsb-release gnupg
$ curl -sL https://packages.microsoft.com/keys/microsoft.asc |
    gpg --dearmor |
    sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null
$ AZ_REPO=$(lsb_release -cs)
$ echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" |
    sudo tee /etc/apt/sources.list.d/azure-cli.list
$ sudo apt update
$ sudo apt install azure-cli
$ 
```

I prefer to install Azure CLI using the native Linux package manager, like *apt*. This way I can use the *az* command in any terminal and any virtual environment and the *azure-cli* Python package is not loaded in any new virtual environment I create.

# Create your development environment

As always, start by creating a new folder, a new Python virtual environment, and a Git repository. Copy a pre-configured Python *.gitignore* file from [GitHub’s collection of .gitignore file templates](https://github.com/github/gitignore). I am using the vscode editor so I also added the vscode file extensiions to the .gitignore file. Finally, activate the Python virtual environment.

```
$ mkdir azure-scripts
$ cd azure-scripts
$ python -m venv env
$ git init
$ curl https://raw.githubusercontent.com/github/gitignore/master/Python.gitignore --output .gitignore
$ echo -e '.vscode\n*.code-workspace\n' >> .gitignore
$ git add .gitignore
$ git commit -m "Created gitignore file"
$ source env/bin/activate
(env) $ pip install wheel
(env) $
```

Install the Azure Python library packages that provide authentication and resource management. 

```
(env) $ pip install azure-identity azure-mgmt-resource
```



```

Installing all of the *azure-cli* Python meta-package may be overkill, but I find it is works on every system. Installing a minimum set of more focused Azure meta-packages like *azure-common*, *azure-mgmt-resource*, etc. does not consistently work.

# Authenticate

There are multiple ways to [authenticate a Python script](https://docs.microsoft.com/en-us/azure/developer/python/azure-sdk-authenticate?tabs=cmd) so it can manage infrastructure and other resources in Azure. Microsoft recommends Azure application authentication methods like [Service Principles](https://docs.microsoft.com/en-us/azure/active-directory/develop/app-objects-and-service-principals) that enable you to define permissions to the application itself. For example, if you write an application that gathers facts about Azure resources, you may wish to only allow that app only read access. However, application authentication is a topic in itself and requires a lot of steps and administrative overhead.

For Linux users, the simplest way to authenticate a Python script is to use the same authentication provided by the [Azure command-line interface (CLI)](https://docs.microsoft.com/en-us/cli/azure/). The script inherits the user's Azure access permissions. While this is simpler, it does have risks. Any app that inherits a user's permissions may have more access than it really needs, such as write access. User, beware.

To establish your Azure credentials, open a terminal window and log into your Azure account using Azure CLI.

```
(env) $ az login
```

Follow the instructions that pop up and complete the login process. Now that you are logged into Azure via the Azure CLI, any script that uses the authentication scheme described below should work.

## Problems with the *azure.identity* module

The [Azure Python SDK documentation suggests](https://docs.microsoft.com/en-us/azure/developer/python/azure-sdk-authenticate?tabs=cmd) that developers use the [DefaultAzureCredential class from the azure-identity package](https://docs.microsoft.com/en-us/python/api/azure-identity/azure.identity.defaultazurecredential?view=azure-python) to authenticate Python applications that run locally on a developer's PC. The DefaultAzureCredential class documentation suggests that it can authorize an application based on the user's Azure CLI profile if they are currently logged in but I found this did not work. When I used the credential generated by the DefaultAzureCredential class, Python raised an exception: *AttributeError: 'DefaultAzureCredential' object has no attribute 'signed_session'*. 

Another class from the azure-identity package is *AzureCliCredential*. It should work for users logged into the Azure CLI but it also raises the same error described above. 

My investigation suggests that [Microsoft recently changed their azure.identity API and broke Azure CLI authentication](https://github.com/Azure/azure-sdk-for-python/issues/9310) for modules that [have not been updated to use the *azure.core* library](https://docs.microsoft.com/en-us/azure/developer/python/azure-sdk-authenticate?view=azure-python&tabs=cmd#defaultazurecredential-object-has-no-attribute-signed-session). The *azure.mgmt.resource* library, which is used to gather information about subscriptions and resource groups, is one of the affected libraries.

## Use the *azure.common.credentials* module

The working solution is to use the [*get_azure_cli_credentials* function](https://docs.microsoft.com/en-us/python/api/azure-common/azure.common.credentials?view=azure-python) from the *azure.common.credentials* module. I think Microsoft does not want developers to know about the azure.common.credentials.get_azure_cli_credentials function ((A former colleague of mine, [Ewan Wai](https://www.linkedin.com/in/ewan-wai-7a3905193/), solved the problem and I learned about the *azure.common.credentials* module from looking at his code. Most of the code in this post comes from Ewan's scripts. I am just figuring out how it works and explaining it to myself so I have a resource I can refer to in the future.)) because they do not mention the *azure.common.credentials* module in any Microsoft documents about application authentication and they list it under "Other" in the Azure SDK documents. 

The get_azure_cli_credentials function returns a tuple containing an Azure credentials object and the subscription ID of your default subscription or optionally returns a triple tuple that includes the tenant ID. The credentials it returns work when used in a Python script running on a developer's local computer.

The following Python script will get your Azure credentials from the Azure CLI and print the results.

```
from azure.common.credentials import get_azure_cli_credentials
credentials, subscription_id, tenant_id = get_azure_cli_credentials(with_tenant=True)
print(credentials)
print(subscription_id)
print(tenant_id)
```

You don't really need to get the Tenant ID, using the *with_tenant=True* parameter, but it solves a spurious warning, "unbalanced tuple packing", raised by the vscode editor's Python linter.

Save the script as *list-running-vms.py* and run the script:

```
(env) $ python list-running-vms.py
```

You should see output similar to the following:

```
<azure.common.credentials._CliCredentials object at 0x2f96a5e17640>
f2a7kced-5f8a-k1e2-f114-a0k3edba3f57
1fda0kbe-f9a7-4k3e-93fd-a3k7ee1e5028
```

The get_azure_cli_credentials function returned a triple tuple consisting of an Azure *_CliCredentials* object, the subscription ID of my default Azure subscription, and my tenant ID ((All values are fake, for security reasons.)). If you have access to more than one subscription, only your default subscription appears in the tuple.

To test that the credentials work, we need to use them to access some information from Azure. Let's list all resource groups visible to you in Azure. Get a set of all subscriptions because, in theory, you might have more than one. Then, get a set of all resource groups in each subscription. According to the Azure Python SDK documentation, the [*azure.mgmt.resource* library module](https://docs.microsoft.com/en-us/python/api/azure-mgmt-resource/azure.mgmt.resource?view=azure-python) contains the classes that manage subsriptions and resoure groups: SubscriptionClient and See the [Azure Python Management sample code](https://github.com/Azure-Samples/azure-samples-python-management/tree/master/samples/resources) for ideas about how to search for and manage other resources.




https://docs.microsoft.com/en-us/azure/developer/python/azure-sdk-example-list-resource-groups



Get hardware profile:
https://stackoverflow.com/questions/54897836/get-azure-vm-hardware-profile-via-azure-python-sdk




