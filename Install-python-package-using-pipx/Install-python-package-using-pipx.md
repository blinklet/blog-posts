# Install <em>azruntime</em> as a CLI program using <em>pipx</em>

*[azruntime](https://github.com/blinklet/azure-scripts/tree/main/azruntime#azruntime)* is more convenient to use if it can be run as a command from the Linux prompt, instead of as a Python program in its virtual environment. You can install Python prackages as command-line-programs using *[pipx](https://github.com/pipxproject/pipx#pipx--install-and-run-python-applications-in-isolated-environments)*. 

However, to make *azruntime* work with a *pipx* install, I had to organize the project into a proper folder structure, add an [entry point](https://python-packaging.readthedocs.io/en/latest/command-line-scripts.html#the-console-scripts-entry-point) in the *setup.py* file, and change the authentation class *azruntime* uses.

This post describes what I learned about *pipx* and [Python packaging](https://github.com/pypa/packaging.python.org#python-packaging-user-guide) to enable me to install *azruntime* as a CLI application.

<!--more-->

# Changing the package directory structure

I originally structured the *azruntime* package all in one folder. The Python modules and the setup.py file were all in the same directory. This worked when I installed the package using pip, but it did not work for pipx.

The correct structure for a package is

# Entry Point in setup.py file

# Azure CLI authentication and pipx

pipx seems to run as differenrt user? clicredentials does not work??

added defaultcredentials, now logs in every time

# Using pipx

```
sudo apt install python3-venv
sudo apt install python3-pip
```
```
python3 -m pip install pipx
python3 -m pipx ensurepath
```
```
pipx install "git+https://github.com/blinklet/azure-scripts.git#egg=azruntime&subdirectory=azruntime"
```


