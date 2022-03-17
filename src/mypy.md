# MyPy

## MyPy の利用

[PyCharmのセットアップ](./editor-setup.md) の際にインストールした型ヒントは、MyPy というツールを使って、コードが正しいかどうかを確認することもできます。MyPy は、Anki の関数を誤って呼び出した場合、例えば関数名を間違って入力した場合や、整数を想定していたのに文字列を渡してしまった場合などに、その誤りを発見してくれます。

PyCharm で左下の Terminal をクリックし、'mypy myaddon' と入力してください。いくつかの処理の後、成功が表示されるか、またはあなたが犯したミスを教えてくれます。例えば、フックを間違って指定した場合を見てみましょう。

```python
from aqt import gui_hooks

def myfunc() -> None:
  print("myfunc")

gui_hooks.reviewer_did_show_answer.append(myfunc)
```

すると mypy は次のように報告します:

    myaddon/__init__.py:5: error: Argument 1 to "append" of "list" has incompatible type "Callable[[], Any]"; expected "Callable[[Card], None]"
    Found 1 error in 1 file (checked 1 source file)

これは、フックが最初の引数としてカードを受け取る関数を期待していることを伝えています。

```python
from anki.cards import Card

def myfunc(card: Card) -> None:
  print("myfunc")
```

## 既存のアドオンの確認

Mypy には "check_untyped_defs" オプションがあり、自分のコードに型ヒントがない場合でもある程度の型チェックを行うことができますが、これを最大限に活用するには、自分のコードに型ヒントを追加する必要があります。これは初期に時間がかかるかもしれませんが、長期的に見ると、自分のコードをナビゲートするのが容易になり、自分では定期的に実行しないようなコードの部分のエラーをキャッチすることができるようになるため有益です。また、新しい Anki バージョンに更新したときに発生した問題を簡単にチェックすることもできます。

既存の大規模なアドオンがある場合は、コードに自動的に型を追加する monkeytype のようなツールを検討するのもよいでしょう。

<details>
<summary>Monkeytype</summary>
monkeytypeを test というアドオンで使うには、次のような方法があります。

```shell
% /usr/local/bin/python3.8 -m venv pyenv
% cd pyenv && . bin/activate
(pyenv) % pip install aqt monkeytype
(pyenv) % monkeytype run bin/anki
```

その後、アドオン内をクリックしてランタイムタイプの情報を収集し、終了したら Anki を閉じます。

この後、トップレベルのアクション（関数外のメニューを変更するコードなど）は monkeytype がトリップしてしまうので、コメントアウトする必要があります。最後に、修正したファイルを次のように生成します:

```shell
(pyenv) % PYTHONPATH=~/Library/Application\ Support/Anki2/addons21 monkeytype apply test
```

</details>

以下は、タイプヒントを使用するアドオンの例です:

<https://github.com/ankitects/anki-addons/blob/master/demos/>
