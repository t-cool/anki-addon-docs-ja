# Qt と PyQt

概要で述べたように、Ank iは UI の多くに PyQt を使用しており、Qt のドキュメントと[PyQt documentation](https://www.riverbankcomputing.com/static/Docs/PyQt6/sip-classes.html) は、さまざまな GUI ウィジェットを表示する方法を学ぶのに非常に有益です。

## Qt のバージョン

Anki 2.1.50 からは、PyQt5 と PyQt6 用に別々のビルドが提供されます。一般的には、Qt6 で動作するコードを書き、Qtのクラスを PyQt6 から直接ではなく、aqt.qt からインポートするようにすれば、あなたのコードは Qt5 でも動くはずです。

## デザイナー向けファイル

Anki の UI の一部は、`qt/aqt/forms` にある .ui ファイルで定義されています。Anki のビルドプロセスは、それらを .py ファイルに変換します。同様の方法でアドオンの UI を構築したい場合は、Python をインストールし、Qt Designer (macOS では Designer.app) と呼ばれるプログラムをインストールする必要があります。Linuxでは、ディストロのパッケージで利用できるかもしれません。WindowsとMacでは、[Qt install](https://download.qt.io/) の一部としてインストールする必要があります。一度インストールしたら、pyqt6 pip パッケージで提供されるプログラムを使って、.ui ファイルをコンパイルする必要があります。

PyQt6 用に生成された Python ファイルはPyQt5 では動作しませんし、その逆も同様です。したがって、両方のバージョンをサポートしたい場合は、.ui ファイルを2回ビルドする必要があります。

## ガベージコレクション

特に注意しなければならないのは、Python ではオブジェクトはガベージコレクションされるので、次のようなことをすると、ガベージコレクションされます:

```python
def myfunc():
    widget = QWidget()
    widget.show()
```

その場合、関数が終了すると同時にウィジェットは消えてしまいます。これを防ぐには、トップレベルのウィジェットを、以下のように既存のオブジェクトに割り当ててください:

```python
def myfunc():
    mw.myWidget = widget = QWidget()
    widget.show()
```

Qt オブジェクトを作成し、既存のオブジェクトを親として与えた場合、親がオブジェクトへの参照を保持するため、これはしばしば必要ではありません。
