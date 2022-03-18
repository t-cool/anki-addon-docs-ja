# デバッグ

コードが例外をスローした場合、Anki の標準的な例外ハンドラでキャッチされます（標準エラー出力に書き込まれたものはすべて捕捉されます）。デバッグのために情報を表示する必要がある場合は、aqt.utils.showInfo を使用するか、sys.stderr.write("text\n") で stderr に情報を書き込むことができます。

## Webviews

Anki を起動する前に環境変数の QTWEBENGINE_REMOTE_DEBUGGING を 8080 に設定すると、Chrome で http://localhost:8080 にサーフィンして、見えるウェブページをデバッグすることができるようになります。

## デバッグ用コンソール

Ankiには REPL も搭載されています。プログラム内から[ショートカットキー](https://docs.ankiweb.net/misc.html#debug-console)を押すと、ウィンドウが表示されます。上の領域に式や文を入力し、ctrl+return/command+return を押すと、その式や文を評価することができます。
セッションの例を以下に示します:

    >>> mw
    <no output>

    >>> print(mw)
    <aqt.main.AnkiQt object at 0x10c0ddc20>

    >>> invalidName
    Traceback (most recent call last):
      File "/Users/dae/Lib/anki/qt/aqt/main.py", line 933, in onDebugRet
        exec text
      File "<string>", line 1, in <module>
    NameError: name 'invalidName' is not defined

    >>> a = [a for a in dir(mw.form) if a.startswith("action")]
    ... print(a)
    ... print()
    ... pp(a)
    ['actionAbout', 'actionCheckMediaDatabase', ...]

    ['actionAbout',
     'actionCheckMediaDatabase',
     'actionDocumentation',
     'actionDonate',
     ...]

    >>> pp(mw.reviewer.card)
    <anki.cards.Card object at 0x112181150>

    >>> pp(card()) # shortcut for mw.reviewer.card.__dict__
    {'_note': <anki.notes.Note object at 0x11221da90>,
     '_qa': [...]
     'col': <anki.collection._Collection object at 0x1122415d0>,
     'data': u'',
     'did': 1,
     'due': -1,
     'factor': 2350,
     'flags': 0,
     'id': 1307820012852L,
     [...]
    }

    >>> pp(bcard()) # shortcut for selected card in browser
    <as above>

評価結果を見るためには、明示的に式を表示する必要があることに注意してください。Anki は pp() (pretty print) をスコープにエクスポートして、オブジェクトの詳細を簡単にダンプできるようにしています。ショートカットの ctrl+shift+return は、上部の領域にある現在のテキストを pp() でラップして、その結果を実行するものです。

## PDB

Linux またはソースから Anki を実行している場合、pdb を使用してスクリプトをデバッグすることも可能です。次の行をコードのどこかに記述すると、Anki がその行に到達したときに、ターミナルのデバッガが起動されます。:

```python
    from aqt.qt import debug; debug()
```

また、シェルで DEBUG=1 を指定しておけば、キャッチできない例外が発生したときにデバッガが起動します。