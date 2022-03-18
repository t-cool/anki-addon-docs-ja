# アドオンの設定

## 設定用の JSON

JSON 形式の config.json ファイルを含めると、Anki はユーザーがアドオンマネージャーから編集できるようになります。

簡単な config.json の例:

    {"myvar": 5}

config.md の例:

    これは、このアドオンの設定に関するドキュメントで、*markdown* 形式で書かれています。

アドオンのコードは以下の通りです:

```python
from aqt import mw
config = mw.addonManager.getConfig(__name__)
print("var is", config['myvar'])
```

アドオンをアップデートする際、config.json を変更することができます。新しく追加されたキーは、既存の設定にマージされます。

config.json で既存のキーの値を変更した場合、設定をカスタマイズしているユーザーは、「restore defaults」ボタンを使用しない限り、古い値を表示し続けることになります。

プログラム的に設定を変更する必要がある場合、変更内容を保存するには次のようにします:

```python
mw.addonManager.writeConfig(__name__, config)
```

config.json ファイルが存在しない場合、たとえ writeConfig() を呼び出したとしても、getConfig() は None を返します。

独自の GUI でオプションを管理するアドオンでは、config ボタンをクリックするとその GUI が表示されます:

```python
mw.addonManager.setConfigAction(__name__, myOptionsFunc)
```

アンダースコアで始まるキー名は避けてください。これらは Anki が将来使用するために予約されています。

## ユーザーファイル

アドオンが単純なキーと値以外の設定データを必要とする場合、アドオンのフォルダのルートにある user_files という特別なフォルダを使用することができます。このフォルダに配置されたファイルは、アドオンがアップグレードされても保存されます。アドオンフォルダ内の他のファイルはすべて
アップグレード時に削除されます。

user_files フォルダが確実にユーザー用に作成されるようにするには、アドオンを圧縮する前に README.txt などのファイルをその中に入れておくとよいでしょう。

Anki がアドオンをアップグレードするとき、user_files フォルダに既に存在する .zip 内のファイルは無視されます。
