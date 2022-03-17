# Reviewer Javascript

For a general solution not specific to card review, see [the webview section](hooks-and-filters.md#webview).

Anki provides a hook to modify the question and answer HTML before it is displayed in the review screen, preview dialog, and card layout screen. This can be useful for adding Javascript to the card.

An example:

```python
from aqt import gui_hooks
def prepare(html, card, context):
    return html + """
<script>
document.body.style.background = "blue";
</script>"""
gui_hooks.card_will_show.append(prepare)
```

The hook takes three arguments: the HTML of the question or answer, the current card object (so you can limit your add-on to specific note types for example), and a string representing the context the hook is running in.

Make sure you return the modified HTML.

Context is one of: "reviewQuestion", "reviewAnswer", "clayoutQuestion", "clayoutAnswer", "previewQuestion" or "previewAnswer".

The answer preview in the card layout screen, and the previewer set to "show both sides" will only use the "Answer" context. This means Javascript you append on the back side of the card should not depend on Javascript that is only added on the front.

Because Anki fades the previous text out before revealing the new text, Javascript hooks are required to perform actions like scrolling at the correct time. You can use them like so:

```python
from aqt import gui_hooks
def prepare(html, card, context):
    return html + """
<script>
onUpdateHook.push(function () {
    window.scrollTo(0, 2000);
})
</script>"""
gui_hooks.card_will_show.append(prepare)
```

- onUpdateHook fires after the new card has been placed in the DOM, but before it is shown.

- onShownHook fires after the card has faded in.

The hooks are reset each time the question or answer is shown.
