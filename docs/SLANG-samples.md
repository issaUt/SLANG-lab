# SLANG サンプル集

このファイルは、SLANG の短い実用例を集めたものです。仕様の詳しい説明は `SLANG-manual.md` を参照してください。

サンプルは、なるべく小さく、何を確認するコードかが分かる形にしています。環境依存のライブラリを使う例では、必要な `#include` や前提を明記しています。

## 1. 最小プログラム

`MAIN()` から実行が始まります。

```slang
MAIN()
{
    PRINT("HELLO SLANG", /);
}
```

`BEGIN ... END;` で書いても同じです。

```slang
MAIN()
BEGIN
    PRINT("HELLO SLANG", /);
END;
```

## 2. 変数・配列・CONST

型を省略した変数は `WORD` です。`ARRAY` の添字は「指定値 + 1 個」確保される点に注意します。

```slang
CONST SCREEN = $4000;

VAR I, ADR;
ARRAY BYTE BUF[15];  // BUF[0] .. BUF[15]

MAIN()
{
    ADR = SCREEN;

    FOR I = 0 TO 15
    {
        BUF[I] = I;
        PRINT(HEX2$(BUF[I]), " ");
    }
    PRINT(/);
}
```

## 3. 間接変数

`[]` 付きの `VAR` は間接変数です。変数の値をアドレスとして、その先を配列のようにアクセスします。

```slang
VAR BYTE BPTR[];
VAR BYTE BVAL = 30;

MAIN()
{
    BPTR = $3000;
    BPTR[1] = 100;     // $3001 に 100 を書く

    BPTR = &BVAL;
    PRINT(BPTR[0], /); // 30

    BPTR[0] = 50;
    PRINT(BVAL, /);    // 50
}
```

`WORD` 間接変数は 2 バイト単位、`FLOAT` 間接変数は 3 バイト単位でアクセスします。

```slang
VAR WORD WPTR[];
ARRAY WORD WBUF[3];

MAIN()
{
    WPTR = &WBUF[0];
    WPTR[0] = $1234;
    WPTR[1] = $ABCD;

    PRINT(HEX4$(WBUF[0]), " ", HEX4$(WBUF[1]), /);
}
```

文字列リテラルは `$00` 終端文字列のアドレス値として扱えます。関数へ文字列を渡す場合は、引数として受け取ったアドレスを `VAR BYTE P[]` のような間接変数に入れると、1 バイトずつ参照できます。

```slang
PRINTSTR(S)
{
    VAR BYTE P[];

    P = S;
    PRINT(!(P), /);
}

MAIN()
{
    PRINTSTR("HELLO");
}
```

`VAR BYTE S[10]` のような配列は、文字列アドレスを保持する変数ではなく、10 バイトの領域そのものです。そのため `S = "ABC";` は C 言語の `strcpy` のような文字列コピーにはなりません。配列バッファへ文字列を入れる場合は、要素へ明示的に書き込みます。

```slang
MAIN()
VAR BYTE S[10];
{
    S[0] = 'A';
    S[1] = 'B';
    S[2] = 'C';
    S[3] = 0;

    PRINT(!(S), /);
}
```

一方、文字列リテラルのアドレスを保持したい場合は、間接変数を使います。

```slang
MAIN()
VAR BYTE S[];
{
    S = "ABC";
    PRINT(!(S), /);
}
```

登録済みレジスタ変数と `#ASM` を組み合わせる場合にも注意が必要です。`^DE = S;` は内部ワーク変数 `_DE` へ値を保存しますが、直後の `#ASM` の物理 `DE` レジスタへ即時ロードされるとは限りません。IOCS などで `DE` にアドレスを入れてから呼び出す場合は、`#ASM` 側で `_DE` から物理レジスタへ戻します。

```slang
IOCS_CRTMS(S)
{
    ^DE = S;

    #ASM
    LD DE,(_DE)
    SVC SVC_CRTMS
    #END
}
```

符号付き演算子 `.*.` や `./.` は使えますが、左辺に複合式や括弧式を直接置くとコンパイラが受け付けない場合があります。固定小数点演算などでは、いったん中間変数に受ける書き方が安定します。

```slang
FIXMUL_S(A, B)
VAR T;
{
    T = A .*. B;
    RETURN T ./. 256;
}
```

次のような書き方は、環境によって `./.` の位置でエラーになることがあります。

```slang
FIXMUL_S(A, B)
{
    RETURN (A .*. B) ./. 256;
}
```

## 4. FLOAT 基本

`FLOAT` はクロスコンパイラ版の拡張です。表示には `FL$()` を使います。

```slang
VAR FLOAT X, Y, Z;

MAIN()
{
    X = 1.23;
    Y = 2.34;
    Z = X * Y;

    PRINT("Z=", FL$(Z), /);
}
```

整数から `FLOAT` への変換は自動で入る場合があります。

```slang
VAR FLOAT X;

MAIN()
{
    X = 10;             // 10.0 として扱われる
    X = X / 4.0;
    PRINT(FL$(X), /);
}
```

`FLOAT` から整数へ戻す場合は `FTOI()` を使います。

```slang
VAR FLOAT X;
VAR I;

MAIN()
{
    X = 12.75;
    I = FTOI(X);
    PRINT(I, /);
}
```

## 5. FLOAT 関数

`FSIN`、`FCOS`、`FSQRT`、`FPOW` などは `FLOAT` を返すランタイム関数です。

```slang
VAR FLOAT X, Y;

MAIN()
{
    X = 0.5;

    Y = FSIN(X);
    PRINT("sin=", FL$(Y), /);

    Y = FCOS(X);
    PRINT("cos=", FL$(Y), /);

    Y = FSQRT(2.0);
    PRINT("sqrt=", FL$(Y), /);

    Y = FPOW(2.0, 8.0);
    PRINT("pow=", FL$(Y), /);
}
```

ユーザー定義関数も `FLOAT` 引数・戻り値を指定できます。

```slang
SQR:FLOAT(FLOAT X)
{
    RETURN X * X;
}

VAR FLOAT R;

MAIN()
{
    R = SQR(2.5);
    PRINT(FL$(R), /);
}
```

## 6. FLOAT 配列と FLOAT 間接変数

`ARRAY FLOAT` は 1 要素 3 バイトです。間接変数 `VAR FLOAT FP[];` を使うと、外部メモリや配列を `FLOAT` 配列として扱えます。

```slang
ARRAY FLOAT BUF[3];
VAR FLOAT FP[];

MAIN()
{
    FP = &BUF[0];

    FP[0] = 1.5;
    FP[1] = 2.5;
    FP[2] = FP[0] + FP[1];

    PRINT(FL$(BUF[2]), /);
}
```

## 7. SOROBAN 実数演算

`SOROBAN.LIB` は `FLOAT` 型とは別系統の実数演算ライブラリです。実数値を `ARRAY BYTE` の領域に入れて、結果格納先を第 1 引数に渡します。

```slang
#INCLUDE SOROBAN.LIB

ARRAY BYTE X[@DBL], Y[@DBL], Z[@DBL];

MAIN()
{
    @CVSTF(X, "1.5");
    @CVSTF(Y, "2.0");

    @ADD(Z, X, Y);

    PRINT(MSX$(@CVFTS(Z)), /);
}
```

三角関数も同じ形です。

```slang
#INCLUDE SOROBAN.LIB

ARRAY BYTE X[@DBL], Y[@DBL];

MAIN()
{
    @CVSTF(X, "0.5");
    @SIN(Y, X);
    PRINT(MSX$(@CVFTS(Y)), /);
}
```

## 8. 外部ライブラリ化

短い関数を別ファイルに分け、`#include` で読み込めます。

`mylib.sl`:

```slang
ADD2(A, B)
{
    RETURN A + B;
}

PRINT_HEX4(X)
{
    PRINT(HEX4$(X), /);
}
```

呼び出し側:

```slang
#include "mylib.sl"

MAIN()
{
    PRINT(ADD2(10, 20), /);
    PRINT_HEX4($ABCD);
}
```

`#include` の探索パスは、ソースのあるディレクトリ、`-I` オプション、`$SLANG_HOME/include` などの設定に依存します。

## 9. `#ASM` の取り込み

関数内に Z80 アセンブラを埋め込めます。

```slang
OUT_BEEP()
{
    #ASM
    ld bc,$1F00
    ld a,$10
    out (c),a
    #END
}

MAIN()
{
    OUT_BEEP();
}
```

`#ASM ... #END` は、パレット設定、I/O ポート操作、短い高速処理などに使えます。機種依存のコードになるため、対象環境の I/O 仕様を確認してください。

## 10. MACHINE 宣言

既存の機械語ルーチンを SLANG の関数のように呼ぶには `MACHINE` を使います。`MACHINE` は「このアドレスにある機械語を、SLANG から関数呼び出しの形で呼ぶ」ための宣言です。

```slang
MACHINE MONCALL(1):$1F8E;

MAIN()
{
    MONCALL($0000);
}
```

この例では `$1F8E` にある機械語ルーチンを `MONCALL()` という名前で呼び出します。`(1)` は引数を 1 個取るという意味です。

`MACHINE` の引数は、個数によって渡される場所が変わります。

```slang
MACHINE SUB0(0):$C000;  // CALL のみ
MACHINE SUB1(1):$C010;  // HL
MACHINE SUB2(2):$C020;  // HL, DE
MACHINE SUB3(3):$C030;  // HL, DE, BC
```

戻り値は、呼び出し先の機械語ルーチンが `HL` に残した値です。つまり、`HL` を結果レジスタとして使う小さな Z80 ルーチンなら、SLANG の関数のように扱えます。

次の例は、RAM 上の `$C000` に `ADD HL,DE; RET` という 2 バイトの機械語を置き、2 つの数値を足す `ADDW()` として呼び出します。

```slang
MACHINE ADDW(2):$C000;

MAIN()
VAR R;
{
    /* $C000: ADD HL,DE */
    /* $C001: RET       */
    MEM[$C000] = $19;
    MEM[$C001] = $C9;

    R = ADDW(1000, 234);
    PRINT(R, /);          // 1234
}
```

`ADDW(1000, 234)` を呼ぶと、第 1 引数 `1000` が `HL`、第 2 引数 `234` が `DE` に入ります。ルーチン側で `ADD HL,DE` を実行して `RET` すると、`HL` に残った `1234` が `ADDW()` の戻り値になります。

1 引数の例です。`INC HL; RET` を置いて、引数を 1 増やす関数にします。

```slang
MACHINE INCW(1):$C010;

MAIN()
{
    /* $C010: INC HL */
    /* $C011: RET    */
    MEM[$C010] = $23;
    MEM[$C011] = $C9;

    PRINT(INCW(99), /);   // 100
}
```

3 引数の場合は `HL`, `DE`, `BC` に入ります。次の例は `A + B + C` を返します。

```slang
MACHINE SUM3(3):$C020;

MAIN()
{
    /* $C020: ADD HL,DE */
    /* $C021: ADD HL,BC */
    /* $C022: RET       */
    MEM[$C020] = $19;
    MEM[$C021] = $09;
    MEM[$C022] = $C9;

    PRINT(SUM3(100, 20, 3), /);  // 123
}
```

引数なしの例です。`LD HL,$1234; RET` を置くと、固定値を返す関数になります。

```slang
MACHINE GETVAL(0):$C030;

MAIN()
{
    /* $C030: LD HL,$1234 */
    /* $C033: RET         */
    MEM[$C030] = $21;
    MEM[$C031] = $34;     // low byte
    MEM[$C032] = $12;     // high byte
    MEM[$C033] = $C9;

    PRINT(HEX4$(GETVAL()), /);   // 1234
}
```

`CALL()` と登録済みレジスタを使っても似たことはできます。

```slang
MAIN()
{
    MEM[$C000] = $19;     // ADD HL,DE
    MEM[$C001] = $C9;     // RET

    ^HL = 1000;
    ^DE = 234;
    CALL($C000);

    PRINT(^HL, /);        // 1234
}
```

`CALL()` は `^HL` や `^DE` などのレジスタを明示的に扱いたい場合に向いています。一方、`MACHINE` は「決まった引数を渡して、`HL` の結果を受け取る」処理を関数風に書きたい場合に便利です。

引数数を省略した `MACHINE FOO();` は、スタック渡しで `HL` に引数数を入れる形式です。可変個数引数を受け取る機械語側ルーチンを用意している場合に使います。通常の固定引数ルーチンでは、`MACHINE NAME(2):$C000;` のように引数数を書いておく方が読みやすく安全です。

ここで使っている `$C000` 以降のアドレスは例です。実際には、対象機種や実行環境で安全に使える RAM 領域を選んでください。

## 11. メモリアクセス

`MEM[]` は 1 バイト、`MEMW[]` は 2 バイト単位でメモリを読み書きします。

```slang
VAR ADR, I;

MAIN()
{
    ADR = $4000;

    FOR I = 0 TO 15
    {
        MEM[ADR + I] = I;
    }

    MEMW[$5000] = $1234;
    PRINT(HEX4$(MEMW[$5000]), /);
}
```

画面メモリやワーク領域に直接書く場合は、対象環境のメモリマップに合わせてアドレスを決めます。

## 12. `#IF` による環境分岐

クロスコンパイラ版では、`ENV_TYPE` や `OS_TYPE` を `#IF` で使えます。

```slang
MAIN()
{
#IF (ENV_TYPE <= 1)
    PRINT("LSX/X1 like env", /);
#ELSE
    PRINT("OTHER env", /);
#ENDIF
}
```

環境ごとに include するライブラリや初期化処理を変えたいときに使います。

## 13. MAGIC / GRAPHF 最小例

MAGIC / GRAPH 系は機種依存のグラフィックライブラリです。`GRAPHF.LIB` は色付き描画と `FLOAT` 対応を含む拡張版です。

```slang
CONST _PLOTSW = 0,
      _THREE  = 0,
      _FLOAT  = 0,
      _SINCOS = 1,
      _TILESW = 1,
      _GHIN   = $FFFF,
      _KPRINTF = 0,
      _COLOR  = 1;

#INCLUDE GRAPHF.LIB

MAIN()
VAR I, COL;
{
    @INIT();

    FOR I = 0 TO 16
    {
        COL = I MOD 8;
        @BOXC(I*10, I*4, 639-I*10, 199-I*4, COL);
    }

    INPUT();
}
```

線を引くだけなら、さらに短くできます。

```slang
CONST _PLOTSW = 0,
      _THREE  = 0,
      _FLOAT  = 0,
      _SINCOS = 0,
      _TILESW = 0,
      _GHIN   = $FFFF,
      _KPRINTF = 0,
      _COLOR  = 1;

#INCLUDE GRAPHF.LIB

MAIN()
{
    @INIT();
    @LINEC(0, 0, 639, 199, 7);
    INPUT();
}
```

## 14. 小さな分割例

メイン側を薄くして、処理をライブラリ風に分ける例です。

`drawlib.sl`:

```slang
DRAW_FRAME()
VAR I;
{
    FOR I = 0 TO 10
    {
        @BOXC(I*8, I*4, 639-I*8, 199-I*4, I MOD 8);
    }
}
```

`main.sl`:

```slang
CONST _PLOTSW = 0,
      _THREE  = 0,
      _FLOAT  = 0,
      _SINCOS = 1,
      _TILESW = 1,
      _GHIN   = $FFFF,
      _KPRINTF = 0,
      _COLOR  = 1;

#INCLUDE GRAPHF.LIB
#include "drawlib.sl"

MAIN()
{
    @INIT();
    DRAW_FRAME();
    INPUT();
}
```

外部ファイル化するときは、ライブラリ側がどのグローバル変数や include 済み関数に依存しているかを意識します。この例では `DRAW_FRAME()` が `@BOXC()` に依存するため、呼び出し側で先に `GRAPHF.LIB` を include しています。
