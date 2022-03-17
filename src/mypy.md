# MyPy

## Using MyPy

The type hints you installed when [setting up PyCharm](./editor-setup.md) can also be used to check your code is correct, using a tool called MyPy. My Py will catch some cases where you’ve called Anki functions incorrectly, such as when you've typed a function name in incorrectly, or passed a string when an integer was expected.

In PyCharm, click on Terminal in the bottom left, and type 'mypy myaddon'. After some processing, it will show a success or tell you any mistakes you’ve made. For example, if you specified a hook incorrectly:

```python
from aqt import gui_hooks

def myfunc() -> None:
  print("myfunc")

gui_hooks.reviewer_did_show_answer.append(myfunc)
```

Then mypy will report:

    myaddon/__init__.py:5: error: Argument 1 to "append" of "list" has incompatible type "Callable[[], Any]"; expected "Callable[[Card], None]"
    Found 1 error in 1 file (checked 1 source file)

..which is telling you that the hook expects a function which takes a card as the first argument, eg

```python
from anki.cards import Card

def myfunc(card: Card) -> None:
  print("myfunc")
```

## Checking Existing Add-Ons

Mypy has a "check_untyped_defs" option that will give you some type checking even if your own code lacks type hints, but to get the most out of it, you will need to add type hints to your own code. This can take some initial time, but pays off in the long term, as it becomes easier to navigate your own code, and allows you to catch errors in parts of the code you might not regularly exercise yourself. It is also makes it easier to check for any problems caused by updating to a newer Anki version.

If you have a large existing add-on, you may wish to look into tools like monkeytype to automatically add types to your code.

<details>
<summary>Monkeytype</summary>
To use monkeytype with an add-on called 'test', you could do something like the following:

```shell
% /usr/local/bin/python3.8 -m venv pyenv
% cd pyenv && . bin/activate
(pyenv) % pip install aqt monkeytype
(pyenv) % monkeytype run bin/anki
```

Then click around in your add-on to gather the runtime type information, and close Anki when you're done.

After doing so, you'll need to comment out any top-level actions (such as code modifying menus outside of a function), as that will trip up monkeytype. Finally, you can generate the modified files with:

```shell
(pyenv) % PYTHONPATH=~/Library/Application\ Support/Anki2/addons21 monkeytype apply test
```

</details>

Here are some example add-ons that use type hints:

<https://github.com/ankitects/anki-addons/blob/master/demos/>
