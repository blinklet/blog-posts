% Manage Azure Infrastructure with Python

# Create your development environment

As always, start by creating a new folder, a new Python virtual environment, and a Git repository. Copy a pre-configured Python *.gitignore* file from [GitHub’s collection of .gitignore file templates](https://github.com/github/gitignore). I am using the vscode editor so I also added the vscode file extensiions to the .gitignore file. Finally, activate the Python virtual environment and install the *azure-cli* Python package.

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
(env) $ pip install wheel azure-cli
(env) $
```

# Authenticate

There are multiple ways to [authenticate a Python script](https://docs.microsoft.com/en-us/azure/developer/python/azure-sdk-authenticate?tabs=cmd) so it can manage infrastructure and other resources in Azure. Microsoft recommends Azure application authentication methods like [Service Principles](https://docs.microsoft.com/en-us/azure/active-directory/develop/app-objects-and-service-principals) that enable you to define permissions to the application itself. For example, if you write an application that gathers facts about Azure resources, you may wish to only allow that app only read access. However, application authentication is a topic in itself and requires a lot of steps and administrative overhead.

For Linux users, the simplest way to authenticate a Python script is to use the same authentication provided by the [Azure command-line interface (CLI)](https://docs.microsoft.com/en-us/cli/azure/). The script inherits the user's Azure access permissions. While this is simpler, it does have risks. Any app that inherits a user's permissions may have more access than it really needs, such as write access. User, beware.

To establish your Azure credentials, open a terminal window and log into your Azure account using Azure CLI.

```
$ az login
```

Follow the instructions that pop up and complete the login process. Now, you may access your Azure CLI credentials from a Python script using the [*get_azure_cli_credentials* function](https://docs.microsoft.com/en-us/python/api/azure-common/azure.common.credentials?view=azure-python) from the *azure.common.credentials* module. returns a tuple containing a Azure credentials object and the subscription ID of your default subscription.

This first script will simply get your Azure credentials from the Azure CLI and print the results.

```
from azure.common.credentials import get_azure_cli_credentials

credentials = get_azure_cli_credentials()
print(credentials)
```

Save the script as *list-running-vms.py* and run the script:

```
$ python list-running-vms.py
```

You should see the following output.

```
(<azure.common.credentials._CliCredentials object at 0x7f2355fdf7f0>, 'c2e82cad-408b-41f3-a994-d0728dbaaf51')
```

The get_azure_cli_credentials() function returned tuple consisting of an Azure CliCredentials object and the subscription ID of my default subscription. If you have access to more than one subscription, only your default subscription appears in the tuple returened by the get_azure_cli_credentials() function.