# MZ-2500 IOCS 浮動小数点メモ

このメモは、MZ-2500 IOCS の FNC 系浮動小数点処理を SLANG から呼び出すための調査メモです。
現時点では実機/エミュレータ上で動作確認した範囲を優先してまとめています。

## ファイル

- `lib/iocs/MZ25IOCS_FNC.LIB`
  IOCS FNC 系の数値変換、浮動小数点演算、SLANG FLOAT との相互変換をまとめた試作ライブラリです。

- `lib/iocs/iocs_mz2500_fnc.inc`
  `FNC_C_FXAS` などの IOCS FNC 番号定義です。

- `examples/iocs/FLOATTEST.SL`
  文字列から MZ 浮動小数点へ変換し、`SQR`、`NMFL`、`ASFL`、`USING`、SLANG FLOAT 変換を確認するサンプルです。

- `examples/iocs/FCALCTEST.SL`
  二項演算の簡単な確認用です。現在は乗算を試しています。

- `examples/iocs/FCALCETCTEST.SL`
  `CMP`、`INT0`、`INT2`、`FLT0` など周辺コールの確認用です。

## 型番号

IOCS の数値変換・浮動小数点演算では、主に次の型番号を使います。

```text
2 : 整数
5 : 単精度浮動小数点
8 : 倍精度浮動小数点
```

`IOCS_C_FLAS` は文字列から数値へ自動変換し、IOCS が判定した型番号を返します。
一方、テストやライブラリ用途では型を明示したいことが多いため、`IOCS_C_FXAS` で型番号を指定して変換するほうが扱いやすいです。

## MZ 浮動小数点形式

調査した範囲では、MZ-2500 IOCS の浮動小数点形式は次のように扱えます。

```text
MZ 単精度 5バイト:
  [0] 指数。bias は 129
  [1] bit7 が符号、bit6..0 が仮数上位
  [2] 仮数
  [3] 仮数
  [4] 仮数下位

MZ 倍精度 8バイト:
  [0] 指数。bias は 129
  [1] bit7 が符号、bit6..0 が仮数上位
  [2]..[7] 仮数
```

既知の例です。

```text
 1.0  -> 81,00,00,00,00
-1.0  -> 81,80,00,00,00
 2.0  -> 82,00,00,00,00
 0.5  -> 80,00,00,00,00
 10   -> 84,20,00,00,00
 100  -> 87,48,00,00,00
```

SLANG の `FLOAT` は 3バイト形式です。`MZ25IOCS_FNC.LIB` では、MZ 単精度/倍精度と SLANG FLOAT の相互変換を用意しています。精度縮小時は丸めではなく切り捨てです。

## 文字列変換の注意

MZ 浮動小数点バイナリを文字列へ戻す場合、通常表示には `IOCS_C_NMFL` を使うのが安定しています。

`IOCS_C_ASFL` でも変換できますが、負数の MZ 浮動小数点を渡した場合に overflow error になるケースを確認しています。たとえば `-12` 相当の `84,C0,00,00,00,...` は `IOCS_C_NMFL` では表示できましたが、`IOCS_C_ASFL` では overflow error になりました。

このため、サンプルでは結果表示の基本を `IOCS_C_NMFL` に寄せています。`ASFL` は挙動確認用として扱います。

## 入力の注意

SLANG ランタイムの `INPUT()` は、現状では負の10進数入力を扱えません。
負数や小数を試す場合は、`LINPUT()` で文字列として受け取り、`IOCS_C_FXAS` で MZ 数値形式へ変換する流れが扱いやすいです。

```slang
VAR BYTE BUF[128], BYTE FBUF[10];

LINPUT(BUF, 20);
IOCS_C_FXAS(BUF, FBUF, 5);
```

整数値を MZ 浮動小数点へ変換する場合は `IOCS_F_FLT0` を使います。変換後の表示は `IOCS_C_NMFL` を使うと負数も確認しやすいです。

## 二項演算の扱い

`IOCS_F_ADD`、`IOCS_F_SUB`、`IOCS_F_MUL`、`IOCS_F_DIV` などは、左辺バッファを結果保存先として使います。

```slang
IOCS_C_FXAS("12.5", A, 5);
IOCS_C_FXAS("8.0",  B, 5);

IOCS_F_MUL(A, B, 5);       // A = A * B
IOCS_C_NMFL(A, BUF, 5);
PRINT(MSX$(BUF), /);
```

元の左辺値を残したい場合は、演算前に別バッファへコピーしてください。

## 現時点の未確定・注意点

- `IOCS_C_ASFL` は負数表示で overflow するケースがあるため、通常表示では `IOCS_C_NMFL` 推奨です。
- `IOCS_C_FLAS` の自動型判定は便利ですが、テストでは整数/単精度/倍精度の違いが混ざりやすいです。
- MZ 倍精度から SLANG FLOAT への変換では、SLANG 側の精度に合わせて仮数下位を切り捨てます。
- IOCS FNC 呼び出しは、現状では RAM 上での実行を前提に一部自己書き換えを使っています。
