# Qt and PyQt

As mentioned in the overview, Anki uses PyQt for a lot of its UI, and the Qt documentation and [PyQt documentation](https://www.riverbankcomputing.com/static/Docs/PyQt6/sip-classes.html) are invaluable for learning how to display different GUI widgets.

## Qt Versions

From Anki 2.1.50, separate builds are provided for PyQt5 and PyQt6. Generally speaking, if you write code that works in Qt6, and make sure to import any Qt classes from aqt.qt instead of directly from PyQt6, your code should also work in Qt5.

## Designer Files

Parts of Anki's UI are defined in .ui files, located in `qt/aqt/forms`. Anki's build process converts them into .py files. If you wish to build your add-on's UI in a similar way, you will need to install Python, and install a program called Qt Designer (Designer.app on macOS). On Linux, it may be available in your distro's packages; on Windows and Mac, you'll need to install it as part of a [Qt install](https://download.qt.io/). Once installed, you will need to use a program provided in the pyqt6 pip package to compile the .ui files.

Generated Python files for PyQt6 won't work with PyQt5 and vice versa, so if you wish to support both versions, you will need to build the .ui files twice, once with pyuic5, and once with pyuic6.

## Garbage Collection

One particular thing to bear in mind is that objects are garbage collected in Python, so if you do something like:

```python
def myfunc():
    widget = QWidget()
    widget.show()
```

…​then the widget will disappear as soon as the function exits. To prevent this, assign top level widgets to an existing object, like:

```python
def myfunc():
    mw.myWidget = widget = QWidget()
    widget.show()
```

This is often not required when you create a Qt object and give it an existing object as the parent, as the parent will keep a reference to the object.
