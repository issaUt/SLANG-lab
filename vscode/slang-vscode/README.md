# SLANG Language Support for VSCode

VSCode で **SLANG** のソースファイルを扱うための言語サポート拡張です。

SLANG は、S-OS 環境などで使われた 8bit パソコン向けの C 風プログラミング言語です。この拡張は `.SL` / `.sl` ファイルに対して、シンタックスハイライト、コメント設定、括弧対応、簡易インデント、スニペットを提供します。

English README: [README.en.md](README.en.md)

## 主な機能

- `.SL` / `.sl` ファイルを `SLANG` 言語モードとして認識
- コメントの色分け
  - `// ...`
  - `/* ... */`
  - `(* ... *)`
- プリプロセッサ指令の色分け
  - `#INCLUDE`, `#include`
  - `#CHAIN`
  - `#IF`, `#ELSE`, `#ENDIF`
  - `#MODULE`
  - `#ASM`, `#END`
- 宣言、型、制御構文、定数、システム配列、レジスタ、関数、演算子、数値、文字列、文字定数の色分け
- `#ASM ... #END` ブロック内の簡易 Z80 アセンブラ風ハイライト
- `{ ... }`, `BEGIN ... END`, `FOR`, `IF`, `ELSE`, `ELIF`, `WHILE`, `LOOP` などに対する基本的なインデント
- `MAIN()`, 関数、`IF`, `WHILE`, `VAR`, `ARRAY` などの簡易スニペット

## VSIX からインストール

Release などから `.vsix` ファイルを入手し、次のどちらかの方法でインストールします。

コマンドラインから:

```sh
code --install-extension slang-language-0.1.0.vsix
```

VSCode の画面から:

1. Extensions を開く
2. 右上の `...` を選ぶ
3. `Install from VSIX...` を選ぶ
4. `slang-language-0.1.0.vsix` を選ぶ
5. `Developer: Reload Window` を実行する

Reload 後に `.SL` または `.sl` ファイルを開いてください。画面右下の言語モードが `SLANG` になっていれば有効です。

## VSIX の作成

VSCode 拡張のパッケージ作成ツールをインストールします。

```sh
npm install -g @vscode/vsce
```

このフォルダでパッケージを作成します。

```sh
cd slang-vscode
vsce package
```

次のような VSIX ファイルが生成されます。

```text
slang-language-0.1.0.vsix
```

## ローカル開発用インストール

開発中に手元の VSCode へ直接配置して試す場合は、以下のスクリプトを使えます。

Windows 版 VSCode:

```powershell
.\install-windows.ps1
```

VSCode Remote - WSL:

```sh
sh ./install-wsl.sh
```

手動で配置する場合の主な場所:

```text
Windows: %USERPROFILE%\.vscode\extensions\local.slang-language-0.1.0
WSL Remote: ~/.vscode-server/extensions/local.slang-language-0.1.0
```

通常の配布には、手動コピーではなく VSIX 形式の利用をおすすめします。

## 注意事項

この拡張は TextMate grammar によるシンタックスハイライト拡張です。SLANG のコンパイル、シンボル解決、型チェック、構文エラー検出などは行いません。

ハイライト定義は、公開されている SLANG 言語仕様と既存の SLANG ソース例をもとに作成しています。

## ライセンス

MIT
