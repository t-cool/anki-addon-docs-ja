# Porting Anki 2.0 add-ons

<!-- toc -->

## Python 3

Anki 2.1 requires Python 3 or later. After installing Python 3 on your
machine, you can use the 2to3 tool to automatically convert your
existing scripts to Python 3 code on a folder by folder basis, like:

    2to3-3.8 --output-dir=aqt3 -W -n aqt
    mv aqt aqt-old
    mv aqt3 aqt

Most simple code can be converted automatically, but there may be parts
of the code that you need to manually modify.

## Qt5 / PyQt5

The syntax for connecting signals and slots has changed in PyQt5. Recent
PyQt4 versions support the new syntax as well, so the same syntax can be
used for both Anki 2.0 and 2.1 add-ons.

More info is available at
<http://pyqt.sourceforge.net/Docs/PyQt4/new_style_signals_slots.html>

One add-on author reported that the following tool was useful to
automatically convert the code:
<https://github.com/rferrazz/pyqt4topyqt5>

The Qt modules are in 'PyQt5' instead of 'PyQt4'. You can do a
conditional import, but an easier way is to import from aqt.qt - eg

    from aqt.qt import *

That will import all the Qt objects like QDialog without having to
specify the Qt version.

## Single .py add-ons need their own folder

Each add-on is now stored in its own folder. If your add-on was
previously called `demo.py`, you’ll need to create a `demo` folder with
an `__init__.py` file.

If you don’t care about 2.0 compatibility, you can just rename `demo.py`
to `demo/__init__.py`.

If you plan to support 2.0 with the same file, you can copy your
original file into the folder (`demo.py` → `demo/demo.py`), and then
import it relatively by adding the following to `demo/__init__.py`:

    from . import demo

The folder needs to be zipped up when uploading to AnkiWeb. For more
info, please see [sharing add-ons](sharing.md).

## Folders are deleted when upgrading

When an add-on is upgraded, all files in the add-on folder are deleted.
The only exception is the special [user\_files folder](addon-config.md#user-files). If
your add-on requires more than simple key/value configuration, make sure
you store the associated files in the user\_files folder, or they will
be lost on upgrade.

## Supporting both 2.0 and 2.1 in one codebase

Most Python 3 code will run on Python 2 as well, so it is possible to
update your add-ons in such a way that they run on both Anki 2.0 and
2.1. Whether this is worth it depends on the changes you need to make.

Most add-ons that affect the scheduler should require only minor changes
to work on 2.1. Add-ons that alter the behaviour of the reviewer,
browser or editor may require more work.

The most difficult part is the change from the unsupported QtWebKit to
QtWebEngine. If you do any non-trivial work with webviews, some work
will be required to port your code to Anki 2.1, and you may find it
difficult to support both Anki versions in the one codebase.

If you find your add-on runs without modification, or requires only
minor changes, you may find it easiest to add some if statements to your
code and upload the same file for both 2.0.x and 2.1.x.

If your add-on requires more significant changes, you may find it easier
to stop providing updates for 2.0.x, or to maintain separate files for
the two Anki versions.

## Webview Changes

Qt 5 has dropped WebKit in favour of the Chromium-based WebEngine, so
Anki’s webviews are now using WebEngine. Of note:

-   You can now debug the webviews using an external Chrome instance, by
    setting the env var QTWEBENGINE\_REMOTE\_DEBUGGING to 8080 prior to
    starting Anki, then surfing to localhost:8080 in Chrome.

-   WebEngine uses a different method of communicating back to Python.
    AnkiWebView() is a wrapper for webviews which provides a pycmd(str)
    function in Javascript which will call the ankiwebview’s
    onBridgeCmd(str) method. Various parts of Anki’s UI like reviewer.py
    and deckbrowser.py have had to be modified to use this.

-   Javascript is evaluated asynchronously, so if you need the result of
    a JS expression you can use ankiwebview’s evalWithCallback().

-   As a result of this asynchronous behaviour, editor.saveNow() now
    requires a callback. If your add-on performs actions in the browser,
    you likely need to call editor.saveNow() first and then run the rest
    of your code in the callback. Calls to .onSearch() will need to be
    changed to .search()/.onSearchActivated() as well. See the browser’s
    .deleteNotes() for an example.

-   Various operations that were supported by WebKit like
    setScrollPosition() now need to be implemented in javascript.

-   Page actions like mw.web.triggerPageAction(QWebEnginePage.Copy) are
    also asynchronous, and need to be rewritten to use javascript or a
    delay.

-   WebEngine doesn’t provide a keyPressEvent() like WebKit did, so the
    code that catches shortcuts not attached to a menu or button has had
    to be changed. setStateShortcuts() fires a hook that can be used to
    adjust the shortcuts for a given state.

## Reviewer Changes

Anki now fades the previous card out before fading the next card in, so
the next card won’t be available in the DOM when the showQuestion hook
fires. There are some new hooks you can use to run Javascript at the
appropriate time - see [here](reviewer-javascript.md) for more.

## Add-on Configuration

Many small 2.0 add-ons relied on users editing the sourcecode to
customize them. This is no longer a good idea in 2.1, because changes
made by the user will be overwritten when they check for and download
updates. 2.1 provides a [Configuration](addon-config.md#config-json) system to work
around this. If you need to continue supporting 2.0 as well, you could
use code like the following:

```python
if getattr(getattr(mw, "addonManager", None), "getConfig", None):
    config = mw.addonManager.getConfig(__name__)
else:
    config = dict(optionA=123, optionB=456)
```
