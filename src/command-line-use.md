# コマンドラインの使用

`anki` モジュールは、Anki の GUI とは別に使用することができます。.anki2 ファイルを直接読み書きする代わりに、このモジュールを使用することを強くお勧めします。

pipでインストールします。


```shell
$ pip install anki
```

.py ファイルの中で次のように作成します:

```python
from anki.collection import Collection
col = Collection("/path/to/collection.anki2")
print(col.sched.deck_due_tree())
col.close()
```

詳しくは [Ankiモジュール](./the-anki-module.md) をご覧ください。
