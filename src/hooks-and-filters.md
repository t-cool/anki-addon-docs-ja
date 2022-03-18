# フックとフィルター

<!-- toc -->

フックは、アドオンコードを Anki に接続するための方法です。変更したい関数にまだフックがない場合は、以下の新しいフックの追加に関するセクションを参照してください。

フックには2つの種類があります。

- 通常のフックは、何も返さない関数です。これらは副作用のために実行され、時にはリストに余分な項目を挿入するなど、渡されたオブジェクトを変更することがあります。

- フィルタは、最初の引数を変更した後にそれを返す関数です。例えば、カードの表示中にフィールドのテキストを受け取り、それを変更したものを返すようなフィルタです。

Python のデータ型には、直接変更できるものと、変更したコピーを作成することでしか変更できないもの（文字列など）があるので、この区別は必要です。

## 新しいスタイルのフック

Anki 2.1.20 では、新しいスタイルのフックが追加されました。

レビュー画面でカードの表側が表示されるたびにメッセージを表示したい場合を想像してください。reviewer.py のソースコードを見て、showQuestion() 関数の中に次のような行があるのを確認したとします。

```python
gui_hooks.reviewer_did_show_question(card)
```

このフックが実行されたときに呼び出される関数を登録するには、アドオンで次のようにします:

```python
from aqt import gui_hooks

def myfunc(card):
  print("question shown, card question is:", card.q())

gui_hooks.reviewer_did_show_question.append(myfunc)
```

複数のアドオンが同じフックやフィルターに登録することができ、それらは順番に呼び出されます。

フックを削除するには、次のようなコードを使用します。:

```
gui_hooks.reviewer_did_show_question.remove(myfunc)
```

:warning: フックにアタッチする関数は、実行中にフックを変更してはいけません:

```
def myfunc(card):
  # こんなことしちゃダメ!
  gui_hooks.reviewer_did_show_question.remove(myfunc)

gui_hooks.reviewer_did_show_question.append(myfunc)
```

すべてのフックを一目で見る簡単な方法は、pylib/tools/genhooks.py と qt/tools/genhooks_gui.py を見てみることです。

以前のセクションで説明したように、型補完を設定している場合は、IDE でフックを確認することもできます:

<video controls autoplay loop muted>
 <source src="./img/autocomplete.mp4" type="video/mp4">
</video>

上のビデオでは、command/ctrl キーを押しながらホバーすると、引数やドキュメントが存在する場合はそれを含むツールチップが表示されます。コールバックの引数名と型は、下の方に表示されています。
の行をご覧ください。

新しいフックの使用例については、以下を参照してください
<https://github.com/ankitects/anki-addons/blob/master/demos/>

新スタイルのフックのほとんどはレガシーフック (後述) も呼び出すので、古いアドオンも今のところ動作し続けますが、アドオン作者は新しいスタイルに更新することをお勧めします。

## 注目のフック

フックの完全なリストとそのドキュメントは、以下を参照してください。

- [GUI hooks](https://github.com/ankitects/anki/blob/master/qt/tools/genhooks_gui.py)
- [pylib hooks](https://github.com/ankitects/anki/blob/master/pylib/tools/genhooks.py)

### Webview

Anki の多くの画面は、1 つ以上の webview で構築されており、その使用を妨害するために使用できるフックがいくつか存在します。

Anki 2.1.22 の場合- `gui_hooks.webview_will_set_content()` は、様々なスクリーンがウェブビューに送信する HTML を変更することができます。これは特定のスクリーンに独自の HTML/CSS/Javascript を追加するために使うことができます。これは外部ページには使えません。次の Anki 2.1.36 のセクションを参照してください。

- `gui_hooks.webview_did_receive_js_message()` は、Javascript から送信されたメッセージを傍受することができます。Anki は Javascript に `pycmd(string)` 関数を用意しており、Python にメッセージを返し、reviewer.py などの様々な画面がそのメッセージに応答します。このフックを使うことで、自分自身のメッセージにも応答することができます:


Anki 2.1.36 の場合:

- webview_did_inject_style_into_page()` は load_ts_page() でロードされるグラフ画面やお祝いページなどの外部ページにスタイルやコンテンツを注入する機会を提供します。

## レガシーフック対応

旧バージョンのAnkiでは、runHook()、addHook()、runFilter()関数を使用した、異なるフックシステムを使用していました。

例えば、スケジューラ(anki/sched.py) がリーチを発見すると、呼び出されます。

```python
runHook("leech", card)
```

もし、リーチが発見されたときに、カードを「難しい」デッキに移動させるなど、特別な操作を行いたい場合は、次のようなコードで実現することができます。:

```python
from anki.hooks import addHook
from aqt import mw

def onLeech(card):
    # スケジューラが処理してくれるので、.flush() を使わなくても変更可能です 
    card.did = mw.col.decks.id("Difficult")
    # もしカードが cram デッキに入っていたなら、元の期限と元のデッキに戻さなければならない
    card.odid = 0
    if card.odue:
        card.due = card.odue
        card.odue = 0

addHook("leech", onLeech)
```

フィルタの例として、aqt/editor.pyがあります。エディタは、フィールドがフォーカスを失うたびに "editFocusLost" フィルタを呼び出すので、アドオンはノートに変更を適用することができます。:

```python
if runFilter(
    "editFocusLost", False, self.note, self.currentField):
    # 何かがノートを更新しました;スケジュール再読み込み
    def onUpdate():
        self.loadNote()
        self.checkValid()
    self.mw.progress.timer(100, onUpdate, False)
```

この例の各フィルタは、修正フラグ、ノート、カレントフィールドの3つの引数を受け取ります。もしフィルターが何も変更しなければ、変更フラグを受け取ったときと同じものを返し、もし変更を加えれば、True を返します。この方法では、いずれかのアドオンが変更を加えた場合、UI はノートを再読み込みして更新を表示します。

日本語サポートアドオンでは、このフックを使って、あるフィールドから別のフィールドを自動生成しています。少し単純化したものを以下に示します:

```python
def onFocusLost(flag, n, fidx):
    from aqt import mw
    # 日本語の model?
    if "japanese" not in n.model()['name'].lower():
        return flag
    #  srcとdstのフィールドがあるか
    for c, name in enumerate(mw.col.models.fieldNames(n.model())):
        for f in srcFields:
            if name == f:
                src = f
                srcIdx = c
        for f in dstFields:
            if name == f:
                dst = f
    if not src or not dst:
        return flag
    # dstフィールドがすでに埋まっているか
    if n[dst]:
        return flag
    # イベントが src フィールドから来るか
    if fidx != srcIdx:
        return flag
    # ソーステキストの補足
    srcTxt = mw.col.media.strip(n[src])
    if not srcTxt:
        return flag
    # フィールドを更新する
    try:
        n[dst] = mecab.reading(srcTxt)
    except Exception, e:
        mecab = None
        raise
    return True

addHook('editFocusLost', onFocusLost)
```

フィルタの第一引数は、返されるべき引数である。
フォーカスロスト・フィルタでは、これはフラグであるが、他のケースでは他のオブジェクトである場合もある。例えば、杏樹/collection.pyでは、"mungeQA "フィルターを呼び出し、カードの表と裏のHTMLを生成して格納します。

Anki 2.1 では、エディタにボタンを追加するためのフックが追加されました。これは次のように使用します。:

```python
from aqt.utils import showInfo
from anki.hooks import addHook

# 選択中のテキストを消去する
def onStrike(editor):
    editor.web.eval("wrap('<del>', '</del>');")

def addMyButton(buttons, editor):
    editor._links['strike'] = onStrike
    return buttons + [editor._addButton(
        "iconname", # "/full/path/to/icon.png",
        "strike", # link の名前
        "tooltip")]

addHook("setupEditorButtons", addMyButton)
```

## フックの追加

もし、まだフックがない関数を修正したい場合は、必要なフックを追加するプルリクエストを提出してください。

フックの定義は `pylib/tools/genhooks.py` と `qt/tools/genhooks_gui.py` に置かれています。Anki のビルド時に、ビルドスクリプトが自動的にフックファイルを更新し、そこに記載されている定義が適用されます。

詳細については、ソースツリーの docs/ フォルダを参照してください。
