# エディターの設定

メモ帳などの基本的なテキストエディタでアドオンを書くこともできますが、適切な Python エディタ/開発環境（IDE）をセットアップすることで、かなり楽になります。

## PyCharm のセットアップ

PyCharm の無償コミュニティ版では、Python のサポートが充実しています: <https://www.jetbrains.com/Pycharm/>。Visual Studio Code のような他のエディタも使えますが、PyCharm が最も良い結果を出すことが分かっています。

昨年、Anki のコードベースは更新され、ほぼすべてのコードにタイプヒントが追加されました。これらの型ヒントは、より良いコード補完を提供し、mypy などのツールを使用してエラーを検出することで、開発を容易にします。アドオン作者として、あなたもこのタイプヒントを活用することができます。

最初のアドオンを始めるには、以下の流れで進めます：

- PyCharm を起動し、新規プロジェクトを作成します。

- 左側のプロジェクトを右クリック/ctrl+クリックし、"myaddon " という Python パッケージを新規に作成します。

ここで、Anki にバンドルされているソースコードを取得し、型式補完ができるようにする必要があります。Anki 2.1.24 は現在、PyPI で入手可能です。**Python の 64 ビット版を使用する必要があり、Python のバージョンは取得する Anki のバージョンがサポートするバージョンと一致する必要があります。** Anki を PyCharm 経由でインストールするには、左下の Python Console をクリックし、次のように入力します。

```python
import subprocess

subprocess.check_call(["pip3", "install", "--upgrade", "pip"])
subprocess.check_call(["pip3", "install", "mypy", "aqt"])
```

エンターキーを押して待ちます。完了したら、コード補完ができるはずです。

エラーが出る場合は、Pythonの64ビット版を使用していないか、Python のバージョンがAnki の最新版でサポートされていない可能性があります。上記のコマンドを「-vvv」付きで実行すると、より詳細な情報が得られます。

インストール後、`__init__.py` ファイルをダブルクリックして、コード補完を試してみてください。下の方にスピナーが表示されたら、完了するまで待ちます。その後、入力します。

```python
from anki import hooks
hooks.
```

すると、補完がポップアップ表示されるはずです。

**PyCharm 内からアドオンを実行することはできませんのでご注意ください。エラーが発生します。**

アドオンは Anki 内から実行する必要があります。これは [基本的なアドオン](a-basic-addon.md) のセクションで説明します。
