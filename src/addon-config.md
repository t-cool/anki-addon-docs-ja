# Add-on Config

## Config JSON

If you include a config.json file with a JSON dictionary in it, Anki
will allow users to edit it from the add-on manager.

A simple example: in config.json:

    {"myvar": 5}

In config.md:

    This is documentation for this add-on's configuration, in *markdown* format.

In your add-on’s code:

```python
from aqt import mw
config = mw.addonManager.getConfig(__name__)
print("var is", config['myvar'])
```

When updating your add-on, you can make changes to config.json. Any
newly added keys will be merged with the existing configuration.

If you change the value of existing keys in config.json, users who have
customized their configuration will continue to see the old values
unless they use the "restore defaults" button.

If you need to programmatically modify the config, you can save your
changes with:

```python
mw.addonManager.writeConfig(__name__, config)
```

If no config.json file exists, getConfig() will return None - even if
you have called writeConfig().

Add-ons that manage options in their own GUI can have that GUI displayed
when the config button is clicked:

```python
mw.addonManager.setConfigAction(__name__, myOptionsFunc)
```

Avoid key names starting with an underscore - they are reserved for
future use by Anki.

## User Files

When your add-on needs configuration data other than simple keys and
values, it can use a special folder called user_files in the root of
your add-on’s folder. Any files placed in this folder will be preserved
when the add-on is upgraded. All other files in the add-on folder are
removed on upgrade.

To ensure the user_files folder is created for the user, you can put a
README.txt or similar file inside it before zipping up your add-on.

When Anki upgrades an add-on, it will ignore any files in the .zip that
already exist in the user_files folder.
