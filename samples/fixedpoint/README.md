# Fixed Point Samples

SLANG 向けの固定小数点ライブラリとデモです。

## ファイル

- `FIXEDPOINTLIB.SL`  
  16bit 符号付き固定小数点の基本関数、三角関数、回転、移動、`atan2` を含むライブラリです。

- `FIXEDPOINTTEST.SL`  
  `SIN_F`、`COS_F`、`TAN_F`、旧 `ATAN2_I` と高速版 `ATAN2_I_FAST`、中心指定回転の確認用テストです。

- `FIXEDPOINT_TEXTDEMO.SL`  
  `LOCATE` と `PRINT(!("*"))` を使うテキスト画面の回転デモです。

- `FIXEDPOINT_GFXDEMO.SL`  
  `GRAPHF.LIB` / MAGIC の `@LINEC` を使うグラフィック回転デモです。サイズと角速度の異なる 5 つの長方形を描きます。

- `FIXEDPOINT_WIREFRAMEDEMO.SL`
  固定小数点の三角関数と乗算を使って、Pico 2 の `WireFrameTest` と同じ正八面体モデルをリアルタイムに回転描画する MAGIC/GRAPHF デモです。描画には単色版の `@LINE` を使います。

- `FIXEDPOINT_MAGIC3DDEMO.SL`
  同じ正八面体モデルを、MAGIC ライブラリ内蔵の 3D 変換・ワイヤーフレーム描画機能で表示する比較用デモです。

## MAGIC/GRAPHF デモについて

`FIXEDPOINT_GFXDEMO.SL`、`FIXEDPOINT_WIREFRAMEDEMO.SL`、`FIXEDPOINT_MAGIC3DDEMO.SL` は、MZ-2500 向けの MAGIC/GRAPHF 環境を前提にしています。

このデモの動作確認には、現時点では未発表の MZ-2500 用 MAGIC ライブラリを使っています。そのため、公開済みの SLANG クロスコンパイラ一式だけでは、そのままビルド・実行できない場合があります。

固定小数点ライブラリ本体、`FIXEDPOINTTEST.SL`、`FIXEDPOINT_TEXTDEMO.SL` は MAGIC に依存しません。

## 固定小数点のスケール

小数部は 8bit で、基本的には `256 = 1.0` として扱います。

ただし `SIN_TBL` は `BYTE` に収めるため、最大値を `255` に丸めています。このため `SIN_F(90)` は厳密な `1.0` ではなく、ほぼ `1.0` です。

## メモ

SLANG の多引数関数呼び出しでは、配列要素を直接渡すと環境によって挙動が怪しい場合があります。安全のため、複雑な添字式は一度変数に受けるか、単純な引数として渡す形にしています。

1 文字だけ描画する場合は、既存サンプルに合わせて `PRINT(!("*"))` のように `BYTE` 指定を使っています。
