# アドオンの共有

<!-- toc -->

## AnkiWeb による共有

アドオンを配布するためにパッケージ化するには、zip 圧縮して .ankiaddon で終わる名前をつけます。

トップレベルフォルダは zip ファイルに含めないでください。例えば、次のようなモジュールがあるとします:

    addons21/myaddon/__init__.py
    addons21/myaddon/my.data

ZIPファイルの中身は以下の通りです:

    __init__.py
    my.data

以下のように zip にフォルダ名を含めると、AnkiWeb は zip ファイルを受け付けません。:

    myaddon/__init__.py
    myaddon/my.data

Unix ベースのマシンでは、次のコマンドで正しい形式のファイルを作成することができます。:

    $ cd myaddon && zip -r ../myaddon.ankiaddon *

Python はアドオン実行時に自動的に `pycache` フォルダを作成します。AnkiWeb は `pycache` フォルダを含む zip ファイルを受け付けないため、zip ファイルを作成する前にこれらを削除しておいてください。

.ankiaddon ファイルを作成したら、<https://ankiweb.net/shared/addons/> にある Upload ボタンを使ってアドオンを他の人と共有することができます。

## AnkiWeb 以外での共有

.ankiaddon ファイルを AnkiWeb 以外で配布する場合、アドオンフォルダに manifest.json ファイルが含まれている必要があります。このファイルには、少なくとも2つのキーを含める必要があります。 package はアドオンが格納されるフォルダ名を指定し、nameはユーザーに表示される名前を指定します。オプションで、アドオンと競合する他のパッケージのリストである conflicts キーと、アドオンがいつ更新されたかを指定する mod キーを含めることができます。

Anki が AnkiWeb からアドオンをダウンロードする場合、マニフェストから conflicts キーのみが使用されます。
