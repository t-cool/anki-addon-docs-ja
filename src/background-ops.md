# バックグラウンドの操作

アドオンが長時間実行される操作を直接行った場合、操作が完了するまでユーザーインターフェースがフリーズし、進行状況ウィンドウが表示されず、アプリが停止しているように見えます。これはユーザーにとって迷惑なことなので、このようなことが起こらないように注意する必要があります。

この現象が起こる理由は、ユーザーインターフェイスが「メインスレッド」上で動作しているからです。アドオンが長時間実行される操作を直接行うと、それもメインスレッド上で実行され、操作が完了するまでUIコードが再び実行されないようにします。解決策は、アドオンのコードをバックグラウンドスレッドで実行し、UIが引き続き機能するようにすることです。

複雑なのは、UIとやりとりするコードもメインスレッドで実行する必要があることです。アドオンがバックグラウンドでのみ実行され、UIにアクセスしようとすると、Ankiがクラッシュする原因となります。つまり、UI操作はメインスレッドで実行し、コレクションやネットワークアクセスなどの長時間実行される操作はバックグラウンドで実行するという選択性が必要です。Anki には、これを容易にするツールがいくつか用意されています。

## 読み取り専用操作と読み取り専用でない操作

ノートのグループを集めたり、ネットワークアクセスのような長時間実行される操作には、 `QueryOp` が推奨されます。

次の例では、my_ui_action() はすぐに戻り、操作は完了するまでバックグラウンドで実行され続けます。正常に終了すると、on_success が呼び出されます。

```python
from anki.collection import Collection
from aqt.operations import QueryOp
from aqt.utils import showInfo
from aqt import mw

def my_background_op(col: Collection, note_ids: list[int]) -> int:
    # 長い時間がかかる操作の例
    for id in note_ids:
        note = col.get_note(note_id)
        # ...

    return 123

def on_success(count: int) -> None:
    showInfo(f"my_background_op() returned {count}")

def my_ui_action(note_ids: list[int]):
    op = QueryOp(
        # アクティブウィンドウ(ここではメインウィンドウ)
        parent=mw,
        # 操作には便宜上コレクションが渡されますが、無視してもかまいません
        op=lambda col: my_background_operation(col, note_ids),
        # この関数は、op が正常に終了したときに呼び出され、op の戻り値が渡されます
        success=on_success,
    )

    # with_progress()が呼ばれない場合、プログレスウィンドウは表示されません
    # QueryOp.with_progress() は、Anki 2.1.50 までは壊れていました
    op.with_progress().run_in_background()
```

**バックグラウンド操作の内部でQt/UI ルーチンを直接呼び出さないように注意してください!**

- 操作完了後に UI を変更する必要がある場合（例：ツールチップを表示する）、成功関数から行う必要があります。
- 操作に UI のデータが必要な場合（例：コンボボックスの値）、そのデータは操作の実行前に収集しておく必要があります。
- バックグラウンドでの操作中にUIを更新する必要がある場合（例：プログレスウィンドウのテキストを更新する）、操作はメインスレッドでその更新を実行する必要があります。例えば、ループ内での操作を見てみましょう:

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

## コレクションの操作

コレクションを修正する取り消し可能な操作のために、別の `CollectionOp` が提供されています。これは QueryOp と同様に機能しますが、変更が行われると UI も更新されます (例えば、ノートが変更されたら Browse 画面をリフレッシュします)。

多くの元に戻せない操作は、すでに aqt/operations/*.py で `CollectionOp` を定義しています。多くの場合、自分で作成するよりも、それらのいずれかを直接使用することができます:

```python
from aqt.operations.note import remove_notes

def my_ui_action(note_ids: list[int]) -> None:
    remove_notes(parent=mw, note_ids=note_ids).run_in_background()
```

デフォルトでは、このルーチンは成功時にツールチップを表示します。.success()または .failure() を呼び出すことで、別のルーチンを提供することができます。

複数の操作を1つの取り消し(undo)のステップにまとめるなど、取り消しの処理に関するより詳しい情報は、[このフォーラムのページ](https://forums.ankiweb.net/t/add-on-porting-notes-for-anki-2-1-45/11212#undoredo-4) を参照してください。
