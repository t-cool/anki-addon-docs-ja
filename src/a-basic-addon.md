# A Basic Add-on

アドオンフォルダ内の `my_first_addon/__init__.py` に以下を追加してください。

```python
# aqt からメインウィンドウオブジェクト (mw) をインポートする
from aqt import mw
# utils.py から "show info" ツールをインポートする
from aqt.utils import showInfo, qconnect
# Qt GUI ライブラリをすべてインポートする
from aqt.qt import *

# 下にメニュー項目を追加していきます。まず、メニュー項目がアクティブになったときに呼び出される関数を作成したいと思います。

def testFunction() -> None:
    # メインウィンドウに格納されている現在のコレクション内のカード枚数を取得します。
    cardCount = mw.col.cardCount()
    # メッセージボックスを表示する
    showInfo("Card count: %d" % cardCount)

# 新しいメニュー項目 "test "を作成する
action = QAction("test", mw)
# クリックされたときに testFunction を呼び出すように設定する
qconnect(action.triggered, testFunction)
# そしてツールメニューに追加する
mw.form.menuTools.addAction(action)
```

Anki を再起動すると、ツールメニューに「テスト」項目が表示されるはずです。
これを実行すると、カード枚数を示すダイアログが表示されます。

プラグインの入力に間違いがあった場合、起動時にエラーメッセージが表示され、問題の場所が示されます。 
