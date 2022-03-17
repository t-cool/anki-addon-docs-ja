# Editor Setup

While you can write an add-on with a basic text editor such as Notepad,
setting up a proper Python editor/development environment (IDE) will make
your life considerably easier.

## PyCharm setup

The free community edition of PyCharm has good out of the box support
for Python: <https://www.jetbrains.com/pycharm/>. You can also use other
editors like Visual Studio Code, but we find PyCharm gives the best results.

Over the last year, Anki’s codebase has been updated to add type hints to almost
all of the code. These type hints make development easier, by providing better
code completion, and by catching errors using tools like mypy. As an add-on
author, you can take advantage of this type hinting as well.

To get started with your first add-on:

- Open PyCharm and create a new project.

- Right click/ctrl+click on your project on the left and create a new
  Python package called "myaddon"

Now you’ll need to fetch Anki’s bundled source code so you can get type
completion. As of Anki 2.1.24, these are available on PyPI. **You will need to
be using a 64 bit version of Python, and your Python version must match a
version the Anki version you are fetching supports.**. To install Anki via
PyCharm, click on Python Console in the bottom left and type the following in:

```python
import subprocess

subprocess.check_call(["pip3", "install", "--upgrade", "pip"])
subprocess.check_call(["pip3", "install", "mypy", "aqt"])
```

Hit enter and wait. Once it completes, you should now have code completion.

If you get an error, you are probably not using a 64 bit version of Python, or
your Python version is not one the latest Anki version supports. Try running the
commands above with "-vvv" to get more info.

After installing, try out the code completion by double clicking on the
`__init__.py` file. If you see a spinner down the bottom, wait for it to
complete. Then type in:

```python
from anki import hooks
hooks.
```

and you should see completions pop up.

**Please note that you can not run your add-on from within PyCharm - you
will get errors.** Add-ons need to be run from within Anki, which is
covered in the [A Basic Add-on](a-basic-addon.md) section.
