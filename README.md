# SLANG Lab

SLANG Lab は、8bit パソコン向け言語 SLANG の自作サンプル、実験コード、VSCode 用設定をまとめるためのリポジトリです。

このリポジトリでは、原典マニュアル本文の転載ではなく、動作確認したサンプルコードと開発メモを中心に管理します。

## 構成

- `docs/`
  自作のサンプル集や開発メモ。`docs/SLANG-compiler-pr-workflow.md` に SLANG-compiler への PR 作業手順、`docs/MZ2500-IOCS-FLOAT.md` に MZ-2500 IOCS 浮動小数点調査メモ、`docs/MZ2500-IOCS-GFX.md` に MZ-2500 IOCS グラフィック調査メモを記録しています。

- `examples/`
  SLANG の実用サンプル。機種依存や必要ライブラリがある場合は README やソース内コメントに記載します。

- `lib/`
  サンプルから共通利用する SLANG ライブラリやアセンブラ include ファイル。

- `vscode/`
  VSCode 用の構文定義、スニペット、拡張パッケージ作成用ファイル。

## ライブラリ配置

- `lib/iocs/`
  MZ-2500 IOCS 向けの試作ライブラリです。`MZ25IOCS_SVC.LIB` は画面初期化、グラフィック、テキスト/PCG など SVC 系コール、`MZ25IOCS_FNC.LIB` は数値変換/浮動小数点など FNC 系コールを置いています。内部で `iocs_mz2500_svc.inc`、`iocs_mz2500_fnc.inc` をアセンブラ include します。

- `lib/fixedpoint/`
  16bit 符号付き固定小数点ライブラリです。2D/3D の回転、三角関数、簡易 `atan2` などを含みます。

## examples 配置

- `examples/iocs/`
  MZ-2500 IOCS ライブラリの動作確認サンプルです。`GTEST.SL` は 640x400 グラフィック、PSET/SYMBOL、ハードウェアスクロールの確認、浮動小数点/FNC 系の確認コードも `examples/iocs/` に置いています。

- `examples/draw3d/`
  固定小数点と IOCS グラフィックを使った 3D 描画サンプルです。

- `examples/hat/`
  HAT3D を IOCS 描画へ移植したサンプルです。浮動小数点演算は SLANG の `FLOAT` を使います。

- `examples/fixedpoint/`
  固定小数点ライブラリ単体、および固定小数点を使ったデモです。

## include パスについて

このリポジトリ内のサンプルは、基本的に各 `examples/*/` ディレクトリでビルドする前提で、`../../lib/...` を直接 `#include` しています。

`MZ25IOCS_*.LIB` 内の `iocs_mz2500_svc.inc`、`iocs_mz2500_fnc.inc` は AILZ80ASM 側の `include` です。SLANG コンパイラの `-I` はこのアセンブラ include パスには渡らないため、ファイル配置を変えた場合は `MZ25IOCS_*.LIB` 内の include パスも合わせて変更してください。

VSCode で `.LIB` を SLANG として開きたい場合は、ワークスペースの `.vscode/settings.json` に次のように追加できます。

```json
{
  "files.associations": {
    "MZ25IOCS_*.LIB": "slang",
    "FIXEDPOINT.LIB": "slang"
  }
}
```

## MAGIC/GRAPHF サンプルについて

MAGIC/GRAPHF を使うサンプルは、MZ-2500 用 MAGIC ライブラリを公開できる段階で `examples/` 以下へ整理して追加する予定です。

現在の `examples/` は、主に IOCS 版と固定小数点ライブラリのサンプルを置いています。

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
