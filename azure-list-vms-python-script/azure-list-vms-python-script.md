% Manage Azure Infrastructure with Python

# Authenticate

Log into your Azure account using Azure CLI.

$ az login

Follow the instructions that pop up.

The [*azure.common.credentials.get_azure_cli_credentials* module](https://docs.microsoft.com/en-us/python/api/azure-common/azure.common.credentials?view=azure-python) returns a tuple containing a Azure credentials object and the subscription ID of your default subscription.

This first script will simply get your Azure credentials from the Azure CLI and print the results.

```
from azure.common.credentials import get_azure_cli_credentials

credentials = get_azure_cli_credentials()[0]
print(credentials)
```

Save the script as *list-running-vms.py* and run the script:

```
$ python3 list-running-vms.py
```

You should see the following output.

```

```