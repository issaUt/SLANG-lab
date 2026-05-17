# MZ-2500 VRAM直接操作グラフィックメモ

MZ-2500 の 320x200x16色グラフィックを、IOCS の描画コールではなく VRAM へ直接アクセスして扱うための試作メモです。

対象コードは `lib/MZ25VRAM_GFX.LIB` と `examples/graph/` 以下のサンプルです。

## 前提

- 主対象は 320x200x16色モードです。
- VRAM は 8KB ブロック `$20` から `$2F` に割り当てられている想定です。
- ライブラリはメモリマップレジスタ1を使い、`2000H-3FFFH` に VRAM 1ブロックを一時的に割り当てて処理します。
- 処理中は `DI` し、終了時にメモリマップを復帰して `EI` します。

## VRAMブロック配置

320x200x16色では、1ページは 4プレーン x 8000バイトです。

現在の実装では、ブロック配置を次のように扱います。

```text
plane0: page0=$20 page1=$21 page2=$22 page3=$23
plane1: page0=$24 page1=$25 page2=$26 page3=$27
plane2: page0=$28 page1=$29 page2=$2A page3=$2B
plane3: page0=$2C page1=$2D page2=$2E page3=$2F
```

各プレーン内は `1ライン40バイト x 200ライン` の連続配置です。

プレーンの意味は MZ-2500 の 16色グラフィックとして、次の順で扱います。

```text
plane0 = B
plane1 = R
plane2 = G
plane3 = I
```

つまり色番号のビット対応は次の通りです。

```text
bit0 = B
bit1 = R
bit2 = G
bit3 = I
```

## 8x8タイル形式

`MZ25_VRAM_PUT_TILE8` は、8x8ドットの4プレーンタイルを描画します。

タイルデータは 32バイトです。

```text
plane0(B): 8バイト
plane1(R): 8バイト
plane2(G): 8バイト
plane3(I): 8バイト
```

呼び出し例です。

```slang
MZ25_VRAM_PUT_TILE8(0, XBYTE, Y, &TILE_FRAME);
```

- `PAGE` は 0..3 の書き込みページです。
- `XBYTE` は X座標を8ドット単位で指定します。
- `Y` はドット単位のY座標です。
- `TADR` はタイルデータ先頭アドレスです。

## スクロールとシフト

ライブラリでは、端を回す処理と回さない処理を分けています。

### SCROLL

`SCROLL` は端の1バイトを反対側へ回すループスクロールです。

```slang
MZ25_VRAM_SCROLL_RECT_LEFT8(PAGE, XBYTE, Y, WBYTE, H);
MZ25_VRAM_SCROLL_RECT_RIGHT8(PAGE, XBYTE, Y, WBYTE, H);
MZ25_VRAM_SCROLL_RECT_UP8(PAGE, XBYTE, Y, WBYTE, H);
MZ25_VRAM_SCROLL_RECT_DOWN8(PAGE, XBYTE, Y, WBYTE, H);
```

横ループ背景やデモ用途に向きます。

### SHIFT

`SHIFT` は端を回さない非ループシフトです。

```slang
MZ25_VRAM_SHIFT_RECT_LEFT8(PAGE, XBYTE, Y, WBYTE, H);
MZ25_VRAM_SHIFT_RECT_RIGHT8(PAGE, XBYTE, Y, WBYTE, H);
MZ25_VRAM_SHIFT_RECT_UP8(PAGE, XBYTE, Y, WBYTE, H);
MZ25_VRAM_SHIFT_RECT_DOWN8(PAGE, XBYTE, Y, WBYTE, H);
```

タイルマップ移動ではこちらを使います。空いた端は直後に新しいタイル列または行で上書きします。

## タイルマップ移動

`examples/graph/VRAMMAPMOVE.SL` は、広いマップから表示範囲だけを切り出して表示するサンプルです。

- 内部マップは `32 x 24` タイルです。
- 表示窓は `20 x 12` タイルです。
- `2/4/6/8` キーで上下左右に1タイルずつ移動します。

初期表示は `DRAW_MAP_VIEW_FAST` で一括描画します。移動時は全体再描画せず、次の処理だけを行います。

```text
1. 表示矩形を SHIFT_RECT_*8 で8ドット移動
2. 新しく見えた1列または1行だけ PUT_TILE8 で描画
```

このため、移動時の描画量は大きく減ります。

```text
全体再描画: 20 x 12 = 240タイル
左右移動: 12タイル + 矩形シフト
上下移動: 20タイル + 矩形シフト
```

## サンプル

`examples/graph/` には次のサンプルがあります。

- `VRAMSCROLLTEST.SL`
  - 全画面スクロール、矩形スクロール、ページ切り替えの確認用です。

- `VRAMTILETEST.SL`
  - 8x8タイル描画の基本確認用です。

- `VRAMMAPTEST.SL`
  - 固定タイルマップを表示するサンプルです。

- `VRAMMAPMOVE.SL`
  - 広いマップから表示範囲を切り出し、上下左右へ8ドット単位で移動するサンプルです。

## ビルド例

`examples/graph/` でビルドする例です。

```sh
slangbuild VRAMMAPMOVE.SL -I ../.. \
  --slangc slangc \
  --asm AILZ80ASM \
  -o VRAMMAPMOVE --keep-asm
```

## 注意

- 8ドット単位の処理です。任意ドット単位の横スクロールではありません。
- 直接VRAMをメモリマップして処理するため、他の処理と同時に `2000H-3FFFH` を使う場合は注意が必要です。
- このライブラリは MZ-2500 専用の試作コードです。IOCSコール互換の汎用描画ライブラリではありません。