# Sharing Add-ons

<!-- toc -->

## Sharing via AnkiWeb

You can package up an add-on for distribution by zipping it up, and
giving it a name ending in .ankiaddon.

The top level folder should not be included in the zip file. For
example, if you have a module like the following:

    addons21/myaddon/__init__.py
    addons21/myaddon/my.data

Then the zip file contents should be:

    __init__.py
    my.data

If you include the folder name in the zip like the following, AnkiWeb
will not accept the zip file:

    myaddon/__init__.py
    myaddon/my.data

On Unix-based machines, you can create a properly-formed file with the
following command:

    $ cd myaddon && zip -r ../myaddon.ankiaddon *

Python automatically creates `pycache` folders when your add-on is run.
Please make sure you delete these prior to creating the zip file, as
AnkiWeb can not accept zip files that contain `pycache` folders.

Once you’ve created a .ankiaddon file, you can use the Upload button on
<https://ankiweb.net/shared/addons/> to share the add-on with others.

## Sharing outside AnkiWeb

If you wish to distribute .ankiaddon files outside of AnkiWeb, your
add-on folder needs to contain a 'manifest.json' file. The file should
contain at least two keys: 'package' specifies the folder name the
add-on will be stored in, and 'name' specifies the name that will be
shown to the user. You can optionally include a 'conflicts' key which is
a list of other packages that conflict with the add-on, and a 'mod' key
which specifies when the add-on was updated.

When Anki downloads add-ons from AnkiWeb, only the conflicts key is used
from the manifest.
