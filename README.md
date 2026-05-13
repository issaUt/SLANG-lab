# SLANG Lab

SLANG Lab は、8bit パソコン向け言語 SLANG の自作サンプル、実験コード、VSCode 用設定をまとめるためのリポジトリです。

このリポジトリでは、原典マニュアル本文の転載ではなく、動作確認したサンプルコードと開発メモを中心に管理します。

## 構成

- `docs/`
  自作のサンプル集や開発メモ。`docs/SLANG-compiler-pr-workflow.md` に SLANG-compiler への PR 作業手順を記録しています。

- `samples/`
  SLANG の実用サンプル。機種依存や必要ライブラリがある場合は各サンプル配下の README に記載します。

- `vscode/`
  VSCode 用の構文定義、スニペット、拡張パッケージ作成用ファイル。

## ライブラリ配置

- `lib/iocs/`
  MZ-2500 IOCS 向けの試作ライブラリです。`MZ25IOCS_TEXT.LIB` はテキスト/PCG 周り、`MZ25IOCS_GFX.LIB` はグラフィック周りを置いています。内部で `iocs_mz2500.inc` をアセンブラ include します。

- `lib/fixedpoint/`
  16bit 符号付き固定小数点ライブラリです。2D/3D の回転、三角関数、簡易 `atan2` などを含みます。

## examples 配置

- `examples/iocs/`
  MZ-2500 IOCS ライブラリの動作確認サンプルです。

- `examples/draw3d/`
  固定小数点と IOCS グラフィックを使った 3D 描画サンプルです。

- `examples/hat/`
  HAT3D を IOCS 描画へ移植したサンプルです。浮動小数点演算は SLANG の `FLOAT` を使います。

- `examples/fixedpoint/`
  固定小数点ライブラリ単体、および固定小数点を使ったデモです。

## include パスについて

このリポジトリ内のサンプルは、基本的に各 `examples/*/` ディレクトリでビルドする前提で、`../../lib/...` を直接 `#include` しています。

`MZ25IOCS_*.LIB` 内の `iocs_mz2500.inc` は AILZ80ASM 側の `include` です。SLANG コンパイラの `-I` はこのアセンブラ include パスには渡らないため、ファイル配置を変えた場合は `MZ25IOCS_*.LIB` 内の include パスも合わせて変更してください。

VSCode で `.LIB` を SLANG として開きたい場合は、ワークスペースの `.vscode/settings.json` に次のように追加できます。

```json
{
  "files.associations": {
    "MZ25IOCS_*.LIB": "slang",
    "FIXEDPOINT.LIB": "slang"
  }
}
```

## 現在のサンプル

- `samples/fixedpoint/`
  16bit 符号付き固定小数点の三角関数、回転、移動、`atan2` のサンプルです。テキスト画面デモと MAGIC/GRAPHF を使うグラフィックデモを含みます。

- `samples/hat/`
  MAGIC/GRAPHF を使ったグラフィックサンプルです。

## MAGIC/GRAPHF サンプルについて

`FIXEDPOINT_GFXDEMO.SL` や `samples/hat/HAT3D.SL` は、MZ-2500 向けの MAGIC/GRAPHF 環境を前提にしています。

特に MZ-2500 用の MAGIC ライブラリは、現時点では未発表のローカル実装を使って動作確認しています。そのため、公開済みの SLANG クロスコンパイラ一式だけでは、そのままビルド・実行できない場合があります。

MAGIC/GRAPHF を使わないサンプルは、各ファイルや各 README の説明に従ってください。

## コミット方針

原則として、ソースと説明文をコミットします。

生成物はコミットしません。

- `*.ASM`
- `*.LST`
- `*.SYM`
- `*.bin`
- `*.D88`
- `*.vsix`

## 注意

SLANG の仕様や実装は、原典仕様とクロスコンパイラ版拡張が混在します。サンプルは確認した環境での実用例として扱い、対象機種やランタイムに応じて調整してください。
