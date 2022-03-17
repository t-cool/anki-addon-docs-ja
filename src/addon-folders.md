# Add-on Folders

You can access the top level add-ons folder by going to the Tools.
Add-ons menu item in the main Anki window. Click on the View Files button, and a folder will pop up. If you had no add-ons installed, the top level add-ons folder will be shown. If you had an add-on selected, the add-on’s module folder will be shown, and you will need to go up one level.

The add-ons folder is named "addons21", corresponding to Anki 2.1. If you have an "addons" folder, it is because you have previously used Anki 2.0.x.

Each add-on uses one folder inside the add-on folder. Anki looks for a file called `__init__.py` file inside the folder, eg:

    addons21/myaddon/__init__.py

If `__init__.py` does not exist, Anki will ignore the folder.

When choosing a folder name, it is recommended to stick to a-z and 0-9 characters to avoid problems with Python’s module system.

While you can use whatever folder name you wish for folders you create yourself, when you download an add-on from AnkiWeb, Anki will use the item's ID as the folder name, such as:

    addons21/48927303923/__init__.py

Anki will also place a meta.json file in the folder, which keeps track of the original add-on name, when it was downloaded, and whether it’s enabled or not.

You should not store user data in the add-on folder, as it’s [deleted when the user upgrades an add-on](addon-config.md#config-json).

If you followed the steps in the [editor setup](editor-setup.md) section, you can either copy your myaddon folder into Anki’s add-on folder to test it, or on Mac or Linux, create a symlink from the folder’s original location into your add-ons folder.
