# SLANG VSCode 拡張 引き継ぎプロンプト

SLANG 言語用の VSCode 拡張を作成・調整しています。
このチャットでは、既存の定義状況を前提に、追加修正や改善を進めたいです。

## 作業フォルダ

VSCode 拡張のリポジトリ候補フォルダ:

```text
\\wsl.localhost\Ubuntu\home\utsu\work\SLANG\SLANG-lab\vscode\slang-vscode
```

配布用 VSIX:

```text
\\wsl.localhost\Ubuntu\home\utsu\work\SLANG\SLANG-lab\vscode\slang-language-0.1.0.vsix
```

## 目的

昔の 8bit パソコン向け言語 **SLANG** 用に、VSCode で以下を提供する拡張を作っています。

- `.SL` / `.sl` ファイルの自動認識
- 予約語・型・演算子・数値・文字列などのシンタックスハイライト
- `BEGIN ... END` や `{ ... }` の基本インデント
- `#ASM ... #END` の簡易 Z80 アセンブラ風ハイライト
- 基本スニペット
- VSIX 配布

## 参照資料

SLANG 言語仕様ページ:

```text
http://retropc.net/ohishi/s-os/slang2.htm
```

ローカル仕様整理ドキュメント:

```text
\\wsl.localhost\Ubuntu\home\utsu\work\SLANG\SLANG-compiler\docs\SLANG-spec.md
```

最初に見た実ソース:

```text
\\wsl.localhost\Ubuntu\home\utsu\work\SLANG\projects\fixedpointlib\FIXEDPOINTLIB.SL
```

追加で確認した examples:

```text
\\wsl.localhost\Ubuntu\home\utsu\work\SLANG\SLANG-compiler-mz2500-local\examples
```

## 現在の主要ファイル

```text
package.json
language-configuration.json
syntaxes/slang.tmLanguage.json
snippets/slang.json
README.md
README.en.md
CHANGELOG.md
LICENSE
.gitignore
.vscodeignore
install-windows.ps1
install-wsl.sh
```

## 現在の package.json 概要

- extension name: `slang-language`
- displayName: `SLANG Language Support`
- publisher: `local`
- version: `0.1.0`
- language id: `slang`
- aliases: `SLANG`, `slang`
- extensions: `.SL`, `.sl`
- grammar: `source.slang`
- grammar file: `syntaxes/slang.tmLanguage.json`
- language configuration: `language-configuration.json`
- snippets: `snippets/slang.json`
- license: `MIT`

## 現在対応しているコメント

```slang
// line comment

/* block comment */

(* block comment *)
```

## 現在対応しているプリプロセッサ

```slang
#INCLUDE
#include
#CHAIN
#IF
#ELSE
#ENDIF
#MODULE
#ASM
#END
```

`#ASM ... #END` は、範囲内を簡易 Z80 アセンブラ風に色分けする定義になっています。

## 現在対応している主な制御語

```text
BEGIN
CASE
CONTINUE
DO
DOWNTO
EF
ELIF
ELSE
ELSEIF
END
ENDIF
EXIT
FOR
GOTO
IF
LOOP
NEXT
OF
OTHERS
REPEAT
RETURN
THEN
TO
UNTIL
WEND
WHILE
```

## 現在対応している宣言・型

宣言:

```text
ARRAY
CONST
DIM
MACHINE
OFFSET
ORG
VAR
WORK
```

型:

```text
BYTE
WORD
FLOAT
!
%
%%
```

## 現在対応している定数・登録済み変数

```text
TRUE
FALSE
ENV_TYPE
OS_TYPE
$
```

レジスタ/登録済み変数:

```text
^A
^AF
^BC
^DE
^HL
^IX
^IY
^SP
^CARRY
^CY
^ZERO
@KBUFF
```

## 現在対応しているシステム配列

```text
MEM[]
MEMW[]
PORT[]
PORTW[]
SOS[]
SOSW[]
```

## 現在対応している主な組み込み関数

```text
ABS
BEEP
BIT
CALL
CHR$
CR$
DECI$
FL$
FORM$
FTOI
GETL
GETLIN
GETREG
HEX2$
HEX4$
INKEY
INPUT
LINPUT
LOCATE
LOW
MSG$
MSX$
PN$
PRINT
PRMODE
RESET
RND
SCREEN
SET
SEX
SGN
SPC$
STOP
STR$
TAB$
VTOS
WIDTH

f24add
f24sub
f24mul
f24div
f24cmp
f24neg
i16tof24
```

## 現在対応している数値リテラル

```slang
1234
$ABCD
12ABH
0FFFFH
111011001010B
00011100b
1.23
2.0
```

## 現在対応している演算子

```text
+ - * / =
== <> != <= >= < >
<< >>
++ --
&& ||
& ? : ,
AND OR XOR
MOD
NOT
CPL
HIGH LOW
.*. ./. .MOD. .<<. .>>. .<=. .>=. .<. .>.
```

## language-configuration.json の現状

- lineComment: `//`
- blockComment: `/* ... */`
- brackets:
  - `{ }`
  - `[ ]`
  - `( )`
  - `BEGIN END`
- autoClosingPairs:
  - `{ }`
  - `[ ]`
  - `( )`
  - `" "`
  - `' '`
- indentationRules:
  - `{`, `BEGIN`, `THEN`, `DO`, `OF`, `ELSE`, `ELSEIF`, `ELIF`, `EF`, `LOOP` で増加
  - `}`, `END`, `ELSE`, `ELSEIF`, `ELIF`, `EF`, `WEND`, `NEXT`, `UNTIL`, `ENDIF` で減少

## snippets/slang.json の現状

以下のスニペットがあります。

- `main`: `MAIN() ... END;`
- `func`: 関数
- `funcvar`: `VAR` 付き関数
- `if`: `{}` 付き IF
- `while`: `{}` 付き WHILE
- `array`: `ARRAY` 宣言
- `var`: `VAR` 宣言

## README の状態

現在は以下の構成です。

- `README.md`: 日本語
- `README.en.md`: 英語

README には以下を記載済みです。

- 機能一覧
- VSIX からのインストール方法
- `vsce package` による VSIX 作成方法
- ローカル開発用インストール方法
- 注意事項
- MIT ライセンス

## 配布・インストールの経緯

最初は手動コピーで VSCode 拡張フォルダに入れようとしたが、VSCode が認識しませんでした。
その後、VSIX 形式にして以下で正式インストールしたところ認識されました。

```sh
code --install-extension slang-language-0.1.0.vsix
```

VSCode 右下の言語モードが `SLANG` になり、 `.SL` ファイルに色分けが反映されました。

## 注意点・今後見たいところ

実ファイルで使いながら、以下を確認したいです。

- `.SL` / `.sl` の両方が自動認識されるか
- `BEGIN/END` と `{}` が混在したときのインデント
- `#ASM ... #END` が意図しない範囲まで ASM 扱いにならないか
- ライブラリ関数や `$` 付き関数の色分け漏れ
- 予約語として色が付きすぎる語がないか
- VSIX 作成・配布の手順が README だけで再現できるか

## 新チャットでお願いしたいこと

上記の現状を前提に、必要に応じて以下を手伝ってください。

- `syntaxes/slang.tmLanguage.json` の改善
- `language-configuration.json` の調整
- スニペット追加
- README / CHANGELOG の改善
- VSIX 再作成
- GitHub 公開前の整理
- 実ソースを見ながらハイライト漏れや誤判定の修正
