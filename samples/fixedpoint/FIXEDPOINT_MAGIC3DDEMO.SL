/*
 * MAGIC 3D 変換を使うワイヤーフレーム正八面体デモ。
 * FIXEDPOINT_WIREFRAMEDEMO.SL との比較用に、回転・投影・線分描画を
 * MAGIC ライブラリ側の @MAGIC(0) / @MAGIC(1) に任せる。
 */

CONST  _PLOTSW=0,_THREE=1,_FLOAT=0,_SINCOS=0,_TILESW=1,_GHIN=$FFFF,_KPRINTF=0,_COLOR=1;

#INCLUDE GRAPHF.LIB

ARRAY MODEL_OBJ[5][2] = [
     95,   0,   0,
    -95,   0,   0,
      0,  95,   0,
      0, -95,   0,
      0,   0,  95,
      0,   0, -95
];

ARRAY BYTE MODEL_WIRE[11][1] = [
    4, 0,  4, 1,  4, 2,  4, 3,
    5, 0,  5, 1,  5, 2,  5, 3,
    0, 2,  2, 1,  1, 3,  3, 0
];


// 短い待ち時間を作る。
DELAY(N)
VAR I, J;
{
    I = 0;
    WHILE (I < N) {
        J = 0;
        WHILE (J < 110) {
            J = J + 1;
        }
        I = I + 1;
    }
}


// グラフィック画面を消去する。
GCLS()
{
    @MODE(2, 2);
    @CLS();
    @MODE(2, 1);
    @CLS();
    @MODE(2, 0);
    @CLS();
}


// MAGIC の 3D 用オブジェクト座標とワイヤー定義を登録する。
INIT_MODEL()
{
    @SETOD(&MODEL_OBJ, 5);
    @SETWD(&MODEL_WIRE, 11);
}


// MAGIC の 3D パラメータを設定する。
SET_MAGIC_3D(HEAD, PITCH, BANK)
{
    _PAR[0] = 0;
    _PAR[1] = 0;
    _PAR[2] = 420;
    _PAR[3] = 0;
    _PAR[4] = 0;
    _PAR[5] = 0;
    _PAR[_HEAD] = HEAD;
    _PAR[_PITCH] = PITCH;
    _PAR[_BANK] = BANK;
}


MAIN()
VAR A, P, KEY;
BEGIN
    PRINT(" MAGIC 3D WIREFRAME DEMO\n ");
    @INIT();
    INIT_MODEL();

    A = 0;
    KEY = 0;

    WHILE (KEY != 27) {
        KEY = INKEY(0);
        P = A / 2 + 25;

        GCLS();
        SET_MAGIC_3D(A, P, 0);
        @MODE(2, 0);
        @MAGIC(0);
        @MAGIC(1);

        DELAY(3);
        A = A + 4;
        IF (A >= 360) A = A - 360;
    }

    GCLS();
    PRINT("\C");
    PRINT("DONE\n");
END;
