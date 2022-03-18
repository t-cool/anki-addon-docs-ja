# モンキーパッチングとメソッドラッピング

フックを持たない関数を変更したい場合、その関数をカスタムバージョンで上書きすることが可能です。これは「モンキーパッチ」と呼ばれることもあります。

モンキーパッチは、テスト段階や、Anki に新しいフックが統合されるのを待っている間などに便利です。しかし、モンキーパッチは非常に壊れやすく、将来 Anki が更新されたときに壊れる可能性があるため、長期的に依存しないようにしてください。

上記の唯一の例外は、新しいフックを追加することが現実的でないような大規模な変更を Anki に加えている場合です。その場合、残念ながら、Anki の更新に合わせて定期的にアドオンを修正する必要があるかもしれません。

aqt/editor.py には setupButtons() という関数があり、エディタに表示される太字や斜体のようなボタンを作成することができます。アドオンで別のボタンを追加したい場合を考えてみましょう。

Anki 2.1 では setupButtons() を使用しなくなりました。以下のコードは、モンキーパッチの仕組みを理解するのにまだ役立ちますが、エディタにボタンを追加するには、前のセクションで説明した setupEditorButtons フックを参照してください。

最も簡単な方法は、Anki ソースコードから関数をコピー＆ペーストして、テキストを一番下に追加し、元のコードを上書きすることです:

```python
from aqt.editor import Editor

def mySetupButtons(self):
    <copy & pasted code from original>
    <custom add-on code>

Editor.setupButtons = mySetupButtons
```

しかし、この方法はもろいもので、Anki の将来のバージョンでオリジナルのコードが更新された場合、あなたのアドオンも更新する必要があります。より良い方法は、オリジナルを保存し、カスタムバージョンでそれを呼び出すことです:

```python
from aqt.editor import Editor

def mySetupButtons(self):
    origSetupButtons(self)
    <custom add-on code>

origSetupButtons = Editor.setupButtons
Editor.setupButtons = mySetupButtons
```

これはよくある操作なので、Anki は wrap() という関数を用意して、これを少し便利にしています。実際の例は、次の通りです:

```python
from anki.hooks import wrap
from aqt.editor import Editor
from aqt.utils import showInfo

def buttonPressed(self):
    showInfo("pressed " + `self`)

def mySetupButtons(self):
    # - size=False は、Anki が小さなボタンを使用しないように指示します
    # - バインドメソッドではなく関数を渡しているので、lambda はコールバックにエディタインスタンスを渡すために必要です
    self._addButton("mybutton", lambda s=self: buttonPressed(self),
                    text="PressMe", size=False)

Editor.setupButtons = wrap(Editor.setupButtons, mySetupButtons)
```

デフォルトでは、wrap() は元のコードの後にカスタムコードを実行します。これを逆転させるために、第3引数 "before" を渡すことができます。元のバージョンの前と後の両方でコードを実行する必要がある場合、次のようにします:

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
