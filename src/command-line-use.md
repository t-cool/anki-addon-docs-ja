# Command-Line Use

The `anki` module can be used separately from Anki's GUI. It is strongly recommended you use it instead of attempting to read or write a .anki2 file directly.

Install it with pip:

```shell
$ pip install anki
```

Then you create use it in a .py file, like so:

```python
from anki.collection import Collection
col = Collection("/path/to/collection.anki2")
print(col.sched.deck_due_tree())
col.close()
```

See [the Anki module](./the-anki-module.md) for more.
