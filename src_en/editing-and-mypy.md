# Editing and MyPy

## Editor/IDE setup

The free community edition of PyCharm has good out of the box support
for Python: <https://www.jetbrains.com/pycharm/>. You can also use other
editors like Visual Studio Code, but the instructions in this section
will cover PyCharm.

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
be using a 64 bit version of Python, version 3.8 or 3.9, or the commands below
will fail**. To install Anki via PyCharm, click on Python Console in the bottom
left and type the following in:

```python
import subprocess

subprocess.check_call(["pip3", "install", "--upgrade", "pip"])
subprocess.check_call(["pip3", "install", "mypy", "aqt"])
```

Hit enter and wait. Once it completes, you should now have code completion.

If you get an error, you are probably not using a 64 bit version of Python,
or your Python version is not 3.8 or 3.9. Try running the commands above
with "-vvv" to get more info.

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
covered in the next section.

You can use mypy to type-check your code, which will catch some cases
where you’ve called Anki functions incorrectly. Click on Terminal in the
bottom left, and type 'mypy myaddon'. After some processing, it will show
a success or tell you any mistakes you’ve made. For example, if you
specified a hook incorrectly:

```python
from aqt import gui_hooks

def myfunc() -> None:
  print("myfunc")

gui_hooks.reviewer_did_show_answer.append(myfunc)
```

Then mypy will report:

    myaddon/__init__.py:5: error: Argument 1 to "append" of "list" has incompatible type "Callable[[], Any]"; expected "Callable[[Card], None]"
    Found 1 error in 1 file (checked 1 source file)

Which is telling you that the hook expects a function which takes a card as
the first argument, eg

```python
from anki.cards import Card

def myfunc(card: Card) -> None:
  print("myfunc")
```

Mypy has a "check_untyped_defs" option that will give you some type checking
even if your own code lacks type hints, but to get the most out of it, you will
need to add type hints to your own code. This can take some initial time, but
pays off in the long term, as it becomes easier to navigate your own code, and
allows you to catch errors in parts of the code you might not regularly exercise
yourself. It is also makes it easier to check for any problems caused by updating
to a newer Anki version.

If you have a large existing add-on, you may wish to look into tools like monkeytype
to automatically add types to your code.

<details>
<summary>Monkeytype</summary>
To use monkeytype with an add-on called 'test', you could do something like the following:

```shell
% /usr/local/bin/python3.8 -m venv pyenv
% cd pyenv && . bin/activate
(pyenv) % pip install aqt monkeytype
(pyenv) % monkeytype run bin/anki
```

Then click around in your add-on to gather the runtime type information, and close
Anki when you're done.

After doing so, you'll need to comment out any top-level actions (such as code modifying
menus outside of a function), as that will trip up monkeytype. Finally, you can
generate the modified files with:

```shell
(pyenv) % PYTHONPATH=~/Library/Application\ Support/Anki2/addons21 monkeytype apply test
```

</details>

Here are some example add-ons that use type hints:

<https://github.com/ankitects/anki-addons/blob/master/demos/>
