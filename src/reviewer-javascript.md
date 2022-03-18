# reviewer の Javascript

カードレビューに特化しない一般的な解決策については、[webview セクション](hooks-and-filters.md) を参照してください。

Anki は、レビュー画面、プレビューダイアログ、カードレイアウト画面に表示される前に、質問と回答の HTML を修正するフックを提供します。これは、カードに Javascript を追加するのに便利です。

例は、以下の通りです。

```python
from aqt import gui_hooks
def prepare(html, card, context):
    return html + """
<script>
document.body.style.background = "blue";
</script>"""
gui_hooks.card_will_show.append(prepare)
```

このフックは 3 つの引数を取ります: 質問または回答の HTML 、現在のカードオブジェクト（例えばアドオンを特定のノートタイプに制限できる）、フックが実行されているコンテキストを表す文字列です。

修正された HTML を返すことを確認してください。

コンテキストは以下のいずれかです。contextは、"reviewQuestion", "reviewAnswer", "clayoutQuestion", "clayoutAnswer", "previewQuestion", "previewAnswer "のうちの1つです。

カードレイアウト画面での回答プレビュー、および「両面表示」に設定されたプレビューアでは、「回答」コンテキストのみが使用されます。つまり、カードの裏側に追加するJavascript は、表側だけに追加されるJavascript に依存しないようにする必要があります。

Anki は新しいテキストを表示する前に前のテキストをフェードアウトさせるため、正しいタイミングでスクロールなどのアクションを実行するには、Javascript のフックが必要です。以下のように使用します:

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

- onUpdateHook は、新しいカードが DOM に配置された後、表示される前に起動されます。

- onShownHook は、カードがフェードインした後に発生します。

フックは、質問と回答が表示されるたびにリセットされます。
