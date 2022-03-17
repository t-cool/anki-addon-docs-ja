# Background Operations

If your add-on performs a long-running operation directly, the user interface will freeze
until the operation completes - no progress window will be shown, and the app will look as
if it's stuck. This is annoying for users, so care should be taken to avoid it happening.

The reason it happens is because the user interface runs on the "main thread". When your add-on
performs a long-running operation directly, it also runs on the main thread, and it prevents
the UI code from running again until your operation completes. The solution is to run your add-on
code in a background thread, so that the UI can continue to function.

A complicating factor is that any code you write that interacts with the UI also needs to be
run on the main thread. If your add-on only ran in the background, and it attempted to access the
UI, it would cause Anki to crash. So selectivity is required - UI operations should be run on
the main thread, and long-running operations like collection and network access should be run in
the background. Anki provides some tools to make this easier.

## Read-Only/Non-Undoable Operations

For long-running operations like gathering a group of notes, or things like network access, 
`QueryOp` is recommended.

In the following example, my_ui_action() will return quickly, and the operation
will continue to run in the background until it completes. If it finishes
successfully, on_success will be called.

```python
from anki.collection import Collection
from aqt.operations import QueryOp
from aqt.utils import showInfo
from aqt import mw

def my_background_op(col: Collection, note_ids: list[int]) -> int:
    # some long-running op, eg
    for id in note_ids:
        note = col.get_note(note_id)
        # ...

    return 123

def on_success(count: int) -> None:
    showInfo(f"my_background_op() returned {count}")

def my_ui_action(note_ids: list[int]):
    op = QueryOp(
        # the active window (main window in this case)
        parent=mw,
        # the operation is passed the collection for convenience; you can
        # ignore it if you wish
        op=lambda col: my_background_operation(col, note_ids),
        # this function will be called if op completes successfully,
        # and it is given the return value of the op
        success=on_success,
    )

    # if with_progress() is not called, no progress window will be shown.
    # note: QueryOp.with_progress() was broken until Anki 2.1.50
    op.with_progress().run_in_background()
```

**Be careful not to directly call any Qt/UI routines inside the background operation!**

- If you need to modify the UI after an operation completes (eg show a tooltip),
  you should do it from the success function.
- If the operation needs data from the UI (eg a combo box value), that data should be gathered
prior to executing the operation.
- If you need to update the UI during the background operation (eg to update the text of the
progress window), your operation needs to perform that update on the main thread. For example,
in a loop:

```python
if time.time() - last_progress >= 0.1:
    aqt.mw.taskman.run_on_main(
        lambda: aqt.mw.progress.update(
            label=f"Remaining: {remaining}",
            value=total - remaining,
            max=total,
        )
    )
    last_progress = time.time()
```

## Collection Operations

A separate `CollectionOp` is provided for undoable operations that modify
the collection. It functions similarly to QueryOp, but will also update the
UI as changes are made (eg refresh the Browse screen if any notes are changed).

Many undoable ops already have a `CollectionOp` defined in aqt/operations/*.py.
You can often use one of them directly rather than having to create your own.
For example:

```python
from aqt.operations.note import remove_notes

def my_ui_action(note_ids: list[int]) -> None:
    remove_notes(parent=mw, note_ids=note_ids).run_in_background()
```

By default that routine will show a tooltip on success. You can call .success()
or .failure() on it to provide an alternative routine.

For more information on undo handling, including combining multiple operations
into a single undo step, please see [this forum
page](https://forums.ankiweb.net/t/add-on-porting-notes-for-anki-2-1-45/11212#undoredo-4).
