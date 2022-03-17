# Monkey Patching and Method Wrapping

If you want to modify a function that doesn’t already have a hook, it’s
possible to overwrite that function with a custom version instead. This
is sometimes referred to as 'monkey patching'.

Monkey patching is useful in the testing stage, and while waiting for
new hooks to be integrated into Anki. But please don’t rely on it long
term, as monkey patching is very fragile, and will tend to break as Anki
is updated in the future.

The only exception to the above is if you’re making extensive changes to
Anki where adding new hooks would be impractical. In that case, you may
unfortunately need to modify your add-on periodically as Anki is
updated.

In aqt/editor.py there is a function setupButtons() which creates the
buttons like bold, italics and so on that you see in the editor. Let’s
imagine you want to add another button in your add-on.

Anki 2.1 no longer uses setupButtons(). The code below is still useful
to understand how monkey patching works, but for adding buttons to the
editor please see the setupEditorButtons hook described in the previous
section.

The simplest way is to copy and paste the function from the Anki source
code, add your text to the bottom, and then overwrite the original, like
so:

```python
from aqt.editor import Editor

def mySetupButtons(self):
    <copy & pasted code from original>
    <custom add-on code>

Editor.setupButtons = mySetupButtons
```

This approach is fragile however, as if the original code is updated in
a future version of Anki, you would also have to update your add-on. A
better approach would be to save the original, and call it in our custom
version:

```python
from aqt.editor import Editor

def mySetupButtons(self):
    origSetupButtons(self)
    <custom add-on code>

origSetupButtons = Editor.setupButtons
Editor.setupButtons = mySetupButtons
```

Because this is a common operation, Anki provides a function called
wrap() which makes this a little more convenient. A real example:

```python
from anki.hooks import wrap
from aqt.editor import Editor
from aqt.utils import showInfo

def buttonPressed(self):
    showInfo("pressed " + `self`)

def mySetupButtons(self):
    # - size=False tells Anki not to use a small button
    # - the lambda is necessary to pass the editor instance to the
    #   callback, as we're passing in a function rather than a bound
    #   method
    self._addButton("mybutton", lambda s=self: buttonPressed(self),
                    text="PressMe", size=False)

Editor.setupButtons = wrap(Editor.setupButtons, mySetupButtons)
```

By default, wrap() runs your custom code after the original code. You
can pass a third argument, "before", to reverse this. If you need to run
code both before and after the original version, you can do so like so:

```python
from anki.hooks import wrap
from aqt.editor import Editor

def mySetupButtons(self, _old):
    <before code>
    ret = _old(self)
    <after code>
    return ret

Editor.setupButtons = wrap(Editor.setupButtons, mySetupButtons, "around")
```
