# MZ-2500 TEXT/PCG VRAM直接操作メモ

MZ-2500 のテキスト画面、アトリビュートVRAM、PCG を、IOCS の文字出力だけに頼らず VRAM へ直接アクセスして扱うための調査メモです。

対象コードは `lib/MZ25VRAM_TFX.LIB` と `examples/pcg/` 以下のサンプルです。

## 前提

- 主対象は 40x25 文字、8x8ドットキャラクタ表示です。
- テキスト画面は 2ページを持ち、40x25 モードではページ0/ページ1を重ね合わせ表示できます。
- 文字表示は単純な ASCII コードを TEXTVRAM に書くだけではありません。
- 通常文字と PCG 表示は、TEXTVRAM1/TEXTVRAM2 とアトリビュートVRAMの組み合わせで決まります。
- PCG定義は IOCS の `SPCG` 系でも可能ですが、現在の試作では PCG VRAM を直接メモリマップして書き込む方法を採っています。

## メモリマップ

テキストVRAMはメモリブロック `$38` を `2000H-3FFFH` に割り当てて操作します。

```text
block $38 mapped at 2000H-3FFFH

+0000H-07FFH: TEXTVRAM1
+0800H-0FFFH: attribute VRAM
+1000H-17FFH: TEXTVRAM2
```

40x25 は1画面1000バイトですが、ページ境界は `$0400` 単位で扱います。

```text
page 0 offset = 0 * $0400 + Y * 40 + X
page 1 offset = 1 * $0400 + Y * 40 + X
```

PCG VRAM はメモリブロック `$39` を `2000H-3FFFH` に割り当てて操作します。

```text
block $39 mapped at 2000H-3FFFH

+0800H-0FFFH: PCG1 / B plane
+1000H-17FFH: PCG2 / R plane
+1800H-1FFFH: PCG3 / G plane
```

現在確認しているカラーPCGのプレーン順は次の通りです。

```text
PCG1 = B
PCG2 = R
PCG3 = G
```

## アトリビュートVRAM

アトリビュートVRAMの1バイトは、概ね次のように扱います。

```text
b7    blink
b6    reverse
b5-b4 PCG/通常表示関連
b3    RGBカラーPCGモード
b2-b0 色指定
```

調査中に重要だった点は、カラーPCG表示では `b3=1` が必要だったことです。

```text
ATTR b3=1: カラーPCGとして表示
ATTR b3=0: 通常文字/通常属性表示
```

`b3=1` の場合、`b5-b4` よりもカラーPCG指定が優先されるように見えます。通常の文字色指定としては `b2-b0` が使われ、PCG用途では `$1F` のように `b3` と色ビットを立てた値を使っています。

例です。

```slang
// $40 のPCGをカラーPCG属性で表示
MZ25_TEXT_PUT40(1, X, Y, $40, $1F);
```

## TEXTVRAM1/2 と文字コード

MZ-2500 のテキストVRAMは、ASCIIコードをそのまま格納する方式ではありません。

通常文字では、TEXTVRAM1/TEXTVRAM2 の2バイトでROM文字パターンのアドレスを指定しているようです。IOCS の `SVC_CRT1C` 相当処理から、1バイト文字は次の変換で実用上の表示ができることを確認しました。

```text
文字コード C から、TEXTVRAM1/2 用の値を作る

H = $23
A = C
SLA A, RL H
SLA A, RL H
L = A
SET 1,L

TEXTVRAM1 = L
TEXTVRAM2 = H
```

`MZ25_TEXT_ROM_DE` / `MZ25_TEXT_PUT40` / `MZ25_TEXT_GET_CODE40` は、この変換に合わせています。

PCG表示の場合は、カラーPCG属性 `b3=1` を立て、TEXTVRAM1 に PCGコードをそのまま入れ、TEXTVRAM2 は 0 にします。

```text
PCGセル:
  TEXTVRAM1 = PCG code
  TEXTVRAM2 = 0
  ATTR      = b3を含む属性値
```

## PCGデータ形式

カラーPCG 8x8 は B/R/G の3面、それぞれ8バイトで構成します。

`MZ25_PCG_SET8_DATA` では、24バイト連結データを使います。

```text
DATA[0..7]   = B plane
DATA[8..15]  = R plane
DATA[16..23] = G plane
```

SLANG上の定義例です。

```slang
VAR BYTE TILE_ROAD[24] = {
    $EE,$55,$AA,$77,$AA,$55,$BB,$55,    // B plane
    $AA,$55,$AA,$55,$AA,$55,$AA,$55,    // R plane
    $EE,$55,$AA,$77,$AA,$55,$BB,$55     // G plane
};

MZ25_PCG_SET8_DATA($40, TILE_ROAD);
```

以前のPCGエディタ出力由来データでは、先頭にIDを持つ形式もありました。その場合は、実際に `MZ25_PCG_SET8_DATA` へ渡す24バイト本体だけを取り出して使います。

## 主なAPI

### PCG定義

```slang
MZ25_PCG_SET8_PLANE(BYTE C, BYTE SEL, BYTE DATA[])
MZ25_PCG_SET8(BYTE C, BYTE BDATA[], BYTE RDATA[], BYTE GDATA[])
MZ25_PCG_SET8_DATA(BYTE C, BYTE DATA[])
MZ25_PCG_READ8(BYTE C, BYTE SEL, BYTE OUT[])
```

`SEL` は次の通りです。

```text
1 = B plane
2 = R plane
3 = G plane
```

通常は `MZ25_PCG_SET8_DATA` を使うと、24バイト連結データをそのまま登録できるので扱いやすいです。

### 文字/属性出力

```slang
MZ25_TEXT_PUT40(BYTE PAGE, BYTE X, BYTE Y, BYTE C, BYTE ATTR)
MZ25_TEXT_PUT40_NOATTR(BYTE PAGE, BYTE X, BYTE Y, BYTE C)
MZ25_TEXT_PRINT40(BYTE PAGE, BYTE X, BYTE Y, BYTE S[], BYTE ATTR)
MZ25_TEXT_PRINT40_NOATTR(BYTE PAGE, BYTE X, BYTE Y, BYTE S[])
MZ25_TEXT_ATTR_RECT40(BYTE PAGE, BYTE X, BYTE Y, BYTE W, BYTE H, BYTE ATTR)
```

`MZ25_TEXT_PUT40` は、`ATTR b3=1` なら PCGコードとして、`ATTR b3=0` なら通常文字として扱います。

### 読み出し

```slang
MZ25_TEXT_READ_CELL40(BYTE PAGE, BYTE X, BYTE Y, BYTE OUT[])
MZ25_TEXT_WRITE_CELL40(BYTE PAGE, BYTE X, BYTE Y, BYTE DATA[])
MZ25_TEXT_GET_ATTR40(BYTE PAGE, BYTE X, BYTE Y)
MZ25_TEXT_GET_CODE40(BYTE PAGE, BYTE X, BYTE Y)
```

`MZ25_TEXT_READ_CELL40` の出力は次の3バイトです。

```text
OUT[0] = TEXTVRAM1
OUT[1] = TEXTVRAM2
OUT[2] = ATTR
```

`MZ25_TEXT_GET_CODE40` は、カラーPCGセルでは TEXTVRAM1 をそのまま返し、通常文字では TEXTVRAM1/2 からASCII相当コードへ戻します。

### クリア

```slang
MZ25_TEXT_CLEAR40(BYTE PAGE, BYTE C, BYTE ATTR)
MZ25_TEXT_CLEAR_RECT40(BYTE PAGE, BYTE X, BYTE Y, BYTE W, BYTE H, BYTE C, BYTE ATTR)
```

### スクロール

属性込み、属性なし、ループあり、ループなしの関数を分けています。

低速版はセル単位に読み書きするため見通しは良いですが、広い領域では遅くなります。

```slang
MZ25_TEXT_SCROLL_LEFT40(...)
MZ25_TEXT_SCROLL_RIGHT40(...)
MZ25_TEXT_SCROLL_UP40(...)
MZ25_TEXT_SCROLL_DOWN40(...)

MZ25_TEXT_SCROLL_LEFT40_NOATTR(...)
MZ25_TEXT_SCROLL_RIGHT40_NOATTR(...)
MZ25_TEXT_SCROLL_UP40_NOATTR(...)
MZ25_TEXT_SCROLL_DOWN40_NOATTR(...)
```

ループスクロール版です。

```slang
MZ25_TEXT_SCROLL_LEFT40_LOOP(...)
MZ25_TEXT_SCROLL_RIGHT40_LOOP(...)
MZ25_TEXT_SCROLL_UP40_LOOP(...)
MZ25_TEXT_SCROLL_DOWN40_LOOP(...)

MZ25_TEXT_SCROLL_LEFT40_LOOP_NOATTR(...)
MZ25_TEXT_SCROLL_RIGHT40_LOOP_NOATTR(...)
MZ25_TEXT_SCROLL_UP40_LOOP_NOATTR(...)
MZ25_TEXT_SCROLL_DOWN40_LOOP_NOATTR(...)
```

高速版は TEXTVRAM1/2 を直接 `LDIR` / `LDDR` 相当で動かします。PCGマップの移動では、属性を固定したまま文字コードだけ動かす `FAST_NOATTR` 系が有効でした。

```slang
MZ25_TEXT_SCROLL_LEFT40_FAST_NOATTR(...)
MZ25_TEXT_SCROLL_RIGHT40_FAST_NOATTR(...)
MZ25_TEXT_SCROLL_UP40_FAST_NOATTR(...)
MZ25_TEXT_SCROLL_DOWN40_FAST_NOATTR(...)
```

### PCGマップ一括描画

```slang
MZ25_TEXT_DRAW_PCGMAP40(BYTE PAGE, BYTE X, BYTE Y, BYTE W, BYTE H, BYTE MAP[], BYTE ATTR)
```

RAM上のPCG文字コードマップを、40x25 テキストVRAMへ一括描画します。

`MAP[]` には `$40` などのPCGコードをそのまま入れます。`ATTR` はカラーPCG用途なら `$1F` のように `b3=1` を含めます。

## ページと重ね合わせ

40x25 テキストモードでは、ページ0とページ1を重ね合わせて表示できます。サンプルでは次のように使っています。重ね合わせる場合、ページ0が前、ページ1が後ろでこの順は固定です。

```text
page 0: 固定テキスト、UI表示
page 1: PCGマップ背景
```

`CARMAPTEST.SL` では、背景マップを page 1 に描き、説明テキストを page 0 に固定表示しています。車はグラフィックVRAM側に描き、テキスト/PCG背景と重ねています。

```slang
IOCS_TSCREEN(1,2);
```

このように、テキストページを分けることで、固定UIとスクロールするPCG背景を分離できます。

## CARMAPTEST の構成

`examples/pcg/CARMAPTEST.SL` は、写真の市街地マップをPCGタイルで簡略化したデモです。

```text
背景: TEXT/PCG page 1
UI:   TEXT page 0
車:   GRAPHIC page 0
```

処理の流れです。

```text
1. 40x25 / 8x8文字モードを初期化
2. PCGタイルを $40 以降へ定義
3. page 1 に 30x23 のPCGマップを描画
4. グラフィックページへ16x16車スプライトを描画
5. テンキー 2/4/6/8 でPCGマップを1セルずつスクロール
6. 空いた端だけ新しいPCGタイルで補充
```

車は元PCGデータを16x16グラフィックスプライトへ組み替えたものです。向きごとに 0/90/180/270 度回転したパターンを持ち、背景とは別にグラフィックVRAMへマスク付きで描画しています。

## 調査で分かった注意点

- 通常文字は ASCII コードをTEXTVRAMに直接書くだけでは正しく出ません。
- 通常文字では TEXTVRAM1/TEXTVRAM2 にROM文字パターンのアドレス指定値を書きます。
- カラーPCGでは `ATTR b3=1` が必要です。
- カラーPCGでは TEXTVRAM1 にPCGコード、TEXTVRAM2 に 0 を書きます。
- PCG定義は `B/R/G` の3面構成です。
- PCGは8色表現です。16色グラフィックのようなIプレーンはありません。
- 40x25 は1ページ1000バイトですが、ページ境界は `$0400` 単位として扱うのが実装上自然です。
- セル単位のスクロールは分かりやすい一方、広い領域では遅くなります。マップ用途では `FAST_NOATTR` 系が有効です。
- テキストPCGは横方向のドット単位スクロールには向きませんが、8ドット単位のタイルマップ移動にはかなり実用的です。

## ビルド例

`examples/pcg/` でビルドする例です。

```sh
slangbuild CARMAPTEST.SL -I ../.. \
  --slangc slangc \
  --asm AILZ80ASM \
  -o CARMAPTEST --keep-asm
```

## 今後の候補

- 40x25以外の文字モードでのページ配置確認
- モノクロPCGを使った1024パターン相当の扱い
- PCGマップ生成ツールの整備
- グラフィックVRAMスプライトとの優先順位/表示順の整理
- スクロール領域の境界外を空白扱いするマップ表示
