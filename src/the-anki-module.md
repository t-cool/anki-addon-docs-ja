# 'anki' モジュール

コレクションや関連メディアへのアクセスは、Anki のソースレポジトリの `pylib/anki` にある `anki` という Python モジュールを通して行われます。

## コレクション

コレクションファイルに対するすべての操作は `Collection` オブジェクトを介してアクセスされます。現在開いているコレクションは、グローバルな `mw.col` を介してアクセスできます。ここで `mw` は `main window` の略です。Anki の外部で `anki` モジュールを使用する場合は、独自のコレクションオブジェクトを作成する必要があります。

以下に、いくつかの基本的な例を示します。これらは [testFunction()](./a-basic-addon.md) のような場所に記述する必要があることに注意してください。アドオンは Anki 起動時に、コレクションやプロファイルが読み込まれる前に初期化されるため、アドオンで直接実行することはできません。

また、コレクションに直接アクセスすると、操作が迅速に完了しない場合、UI が一時的にフリーズする可能性があることに注意してください。

**期限のカードを取得する:**

```python
card = mw.col.sched.getCard()
if not card:
    # current deck is finished
```

**カードに答える:**

```python
mw.col.sched.answerCard(card, ease)
```

**ノートを編集する（各フィールドの末尾に new を付ける）:**

```python
note = card.note()
for (name, value) in note.items():
    note[name] = value + " new"
mw.col.update_note(note)
```

**タグ x を持つノートのカードの ID を取得する:**

```python
ids = mw.col.find_cards("tag:x")
```

**それぞれの ID に対応する質問と回答を取得する:**

```python
for id in ids:
    card = mw.col.get_card(id)
    question = card.question()
    answer = card.answer()
```

**レビューの期限を明日にする**

```python
ids = mw.col.find_cards("is:due")
mw.col.sched.set_due_date(ids, "1")
```

**テキストファイルをコレクションにインポートする**

このAPIは混乱していて、近々更新される予定です。

```python
from anki.importing import TextImporter
file = u"/path/to/text.txt"
# デッキを選択する
deck_id = mw.col.decks.id("ImportDeck")
mw.col.decks.select(deck_id)
# ankiは選択されたデッキで最後に使用されたノートタイプをデフォルトとします
notetype = mw.col.models.by_name("Basic")
deck = mw.col.decks.get(deck_id)
deck['mid'] = notetype['id']
mw.col.decks.save(deck)
# ノートタイプで最後に使用したデッキにカードを入れる
mw.col.set_aux_notetype_config(
    notetype["id"], "lastDeck", deck_id
)
mw.col.models.save(m)
# コレクションに取り込む
ti = TextImporter(mw.col, file)
ti.initMapping()
ti.run()
```

ほぼすべてのGUI操作には Anki と関連する関数があり、Anki が利用可能な操作はすべてアドオンでも呼び出すことができます。


## オブジェクトの読み取り/書き込み

Anki のほとんどのオブジェクトは、pylib のメソッドで読み書きが可能です。

```python
card = col.get_card(card_id)
card.ivl += 1
col.update_card(card)
```

```python
note = col.get_note(note_id)
note["Front"] += " hello"
col.update_note(note)
```

```python
deck = col.decks.get(deck_id)
deck["name"] += " hello"
col.decks.save(deck)

deck = col.decks.by_name("Default hello")
...
```

```python
config = col.decks.get_config(config_id)
config["new"]["perDay"] = 20
col.decks.save(config)
```

```python
notetype = col.models.get(notetype_id)
notetype["css"] += "\nbody { background: grey; }\n"
col.models.save(note)

notetype = col.models.by_name("Basic")
...
```

データベースに直接アクセスするよりも、これらのメソッドを使用した方が、同期が必要な項目をマークしたり、無効なデータがデータベースに書き込まれるのを防いだりすることができるからです。

特定のカードやノートを探すには、 col.find_cards() と col.find_notes() が便利です。

## データベース

:warning: データベースに直接書き込むと、簡単に問題を起こすことができます。可能な限り、代わりに上記のようなメソッドを使用してください。

Anki の DB オブジェクトは、以下の機能をサポートしています。

**scalar() は単一の項目を返します:**

```python
showInfo("card count: %d" % mw.col.db.scalar("select count() from cards"))
```

**list() は、各行の最初の列のリストを返します:**

```python
ids = mw.col.db.list("select id from cards limit 3")
```

**all() は、行のリストを返します:**

```python
ids_and_ivl = mw.col.db.all("select id, ivl from cards")
```

**execute() は、中間リストを作成せずに結果セットを反復処理するために使用することもできます：**

```python
for id, ivl in mw.col.db.execute("select id, ivl from cards limit 3"):
    showInfo("card id %d has ivl %d" % (id, ivl))
```

**execute() を使用すると、挿入や更新の操作を実行することができます。名前付き引数を使用するには ? を使います:**

```python
mw.col.db.execute("update cards set ivl = ? where id = ?", newIvl, cardId)
```

なお、これらの変更は、前のセクションで説明した機能を使用した場合のように、同期されることはありません。

**executemany() を使用すると、更新や挿入の操作を一括して行うことができます。大きな更新を行う場合は、データポイントごとに execute() をコールするよりもずっと高速になります:**

```python
data = [[newIvl1, cardId1], [newIvl2, cardId2]]
mw.col.db.executemany(same_sql_as_above, data)
```

上記のように、これらの変更は同期されません。

アドオンによって既存のテーブルのスキーマが変更されると、Anki の将来のバージョンで問題が発生する可能性があるため、絶対に変更しないでください。

アドオン固有のデータを保存する必要がある場合は、Anki の [Configuration](addon-config.md#config-json) サポートの利用を検討してください。

デバイス間でデータを同期する必要がある場合、小さなオプションは mw.col.conf 内に保存することができます。現在、同期ごとに送信されるため、大量のデータをそこに保存しないようにしてください。
