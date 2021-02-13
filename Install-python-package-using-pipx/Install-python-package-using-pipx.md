#


pipx seems to run as differenrt user? clicredentials does not work??

added defaultcredentials, now logs in every time

Test in VM. What if I install pipx glbally?

    python3 -m pip install --user pipx
    python3 -m pipx ensurepath
    az login

Do I see the same permissions issue?

Also made changes to setup.py and folder structure to match the way pipx and setup.py expect to see an entrty point


publish to PyPI? https://python-packaging.readthedocs.io/en/latest/minimal.html

(add minifest file so png file is available for readme in PyPI???) https://python-packaging.readthedocs.io/en/latest/everything.html

