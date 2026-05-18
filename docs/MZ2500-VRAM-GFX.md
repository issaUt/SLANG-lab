# MZ-2500 VRAM直接操作グラフィックメモ

MZ-2500 の 320x200x16色グラフィックを、IOCS の描画コールではなく VRAM へ直接アクセスして扱うための試作メモです。

対象コードは `lib/MZ25VRAM_GFX.LIB` と `examples/graph/` 以下のサンプルです。

## 前提

- 主対象は 320x200x16色モードです。
- VRAM は 8KB ブロック `$20` から `$2F` に割り当てられている想定です。
- 多くの処理はメモリマップレジスタ1を使い、`2000H-3FFFH` に VRAM 1ブロックを一時的に割り当てて処理します。
- ページ間コピーなど一部の処理ではメモリマップレジスタ1/2を使い、`2000H-3FFFH` と `4000H-5FFFH` に読み元/書き先の2ブロックを同時に割り当てます。
- 処理中は `DI` し、終了時にメモリマップを復帰して `EI` します。

## VRAMブロック配置

320x200x16色では、1ページは 4プレーン x 8000バイトです。

確認したブロック配置は、0/1ページ組、2/3ページ組の中で色プレーンごとにページが交互に並ぶ形です。

```text
page0: B=$20 R=$22 G=$24 I=$26
page1: B=$21 R=$23 G=$25 I=$27
page2: B=$28 R=$2A G=$2C I=$2E
page3: B=$29 R=$2B G=$2D I=$2F
```

各プレーン内は `1ライン40バイト x 200ライン` の連続配置です。

プレーンの意味は MZ-2500 の 16色グラフィックとして、次の順で扱います。

```text
B, R, G, I
```

つまり色番号のビット対応は次の通りです。

```text
bit0 = B
bit1 = R
bit2 = G
bit3 = I
```

この配置は `VRAMPLANETEST.SL` と `VRAMPAGETEST.SL` で確認しました。

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

## 4ドット単位スクロール

`examples/graph/VRAMMAPSHIFT4.SL` は、8x8タイルマップを4ドット単位で上下左右へ移動するサンプルです。

横方向はVRAM上のビットシフト、縦方向は4ライン単位の移動を使います。空いた端は、タイルデータから4x4ドット分だけを補充します。

`VRAMMAPSHIFT4_2P.SL` は、同じ処理を B/R の2プレーンだけに限定した高速版です。4プレーン版より表現力は落ちますが、処理量を減らせます。

## ページ切り替え版MAPSHIFT

`VRAMMAPSHIFT4_DB.SL` と `VRAMMAPSHIFT4_2P_DB.SL` は、ページ切り替えを使って描画中の作業を見せないようにした版です。

処理の流れは次の通りです。

```text
1. 表示中ページのマップ矩形を作業ページへコピー
2. 作業ページ上で4ドットスクロール
3. 空いた端だけタイルで補充
4. 作業ページを表示ページへ切り替え
```

ページ間コピーには `MZ25_VRAM_COPY_RECT` / `MZ25_VRAM_COPY_RECT_2P` を使います。これらはメモリマップレジスタ1を読み元、メモリマップレジスタ2を書き先として、2つのVRAMブロックを同時にZ80アドレス空間へ見せる前提で実装しています。

```text
2000H-3FFFH: 読み元VRAMブロック
4000H-5FFFH: 書き先VRAMブロック
```

これにより、ページ間の矩形コピーを `LDIR` ベースで行えます。

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

- `VRAMSHIFT4TEST.SL`
  - 4ドット単位の横シフト確認用です。

- `VRAMPLANETEST.SL`
  - BRGIプレーン順の確認用です。

- `VRAMPAGETEST.SL`
  - 0..3ページのVRAMブロック配置確認用です。

- `VRAMMAPSHIFT4.SL`
  - 4プレーンで4ドット単位タイルマップスクロールを行うサンプルです。

- `VRAMMAPSHIFT4_2P.SL`
  - B/Rの2プレーンだけで4ドット単位タイルマップスクロールを行う高速版です。

- `VRAMMAPSHIFT4_DB.SL`
  - ページ切り替えとVRAM矩形コピーを使った4プレーンMAPSHIFTです。

- `VRAMMAPSHIFT4_2P_DB.SL`
  - ページ切り替えとVRAM矩形コピーを使った2プレーンMAPSHIFTです。

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
- 直接VRAMをメモリマップして処理するため、他の処理と同時に `2000H-3FFFH` を使う場合は注意が必要です。ページ間コピー系の処理では `4000H-5FFFH` も一時的に使います。
- このライブラリは MZ-2500 専用の試作コードです。IOCSコール互換の汎用描画ライブラリではありません。
