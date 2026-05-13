/*
 * 固定小数点回転のグラフィックデモ。
 * GRAPHF.LIB(MAGIC) の @LINEC を使って、回転する長方形を描く。
 */

CONST  _PLOTSW=0,_THREE=0,_FLOAT=0,_SINCOS=0,_TILESW=1,_GHIN=$FFFF,_KPRINTF=0,_COLOR=1;

#INCLUDE GRAPHF.LIB
#include "../../lib/fixedpoint/FIXEDPOINT.LIB"

ARRAY ROT_RESULT[1];
VAR ROT_PTR[];

VAR X0, Y0, X1, Y1, X2, Y2, X3, Y3;


// 短い待ち時間を作る。
DELAY(WORD N)
VAR I, J;
{
    I = 0;
    WHILE (I < N) {
        J = 0;
        WHILE (J < 150) {
            J = J + 1;
        }
        I = I + 1;
    }
}


// 1 点を中心 (320,100) のまわりに回転し、RP[0], RP[1] に入れる。
ROT_POINT(WORD X, WORD Y, WORD A)
{
    ROTATE_CENTER(ROT_PTR, X, Y, 320, 100, A);
}


// 幅 W、高さ H の長方形を回転し、四隅を X0/Y0..X3/Y3 に作る。
MAKE_BOX(WORD W, WORD H, WORD A)
VAR HX, HY;
{
    HX = W / 2;
    HY = H / 2;

    ROT_POINT(320 - HX, 100 - HY, A);
    X0 = ROT_RESULT[0];
    Y0 = ROT_RESULT[1];

    ROT_POINT(320 + HX, 100 - HY, A);
    X1 = ROT_RESULT[0];
    Y1 = ROT_RESULT[1];

    ROT_POINT(320 + HX, 100 + HY, A);
    X2 = ROT_RESULT[0];
    Y2 = ROT_RESULT[1];

    ROT_POINT(320 - HX, 100 + HY, A);
    X3 = ROT_RESULT[0];
    Y3 = ROT_RESULT[1];
}


// 現在の四角形を指定色で描く。
DRAW_BOX(BYTE C)
{
    @LINEC(X0, Y0, X1, Y1, C);
    @LINEC(X1, Y1, X2, Y2, C);
    @LINEC(X2, Y2, X3, Y3, C);
    @LINEC(X3, Y3, X0, Y0, C);
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


// 1つの長方形を作って描く。
DRAW_ROT_BOX(WORD W, WORD H, WORD A, BYTE C)
{
    MAKE_BOX(W, H, A);
    DRAW_BOX(C);
}


MAIN()
VAR A, A2, A3, A4, A5, KEY;
BEGIN
    ROT_PTR = &ROT_RESULT[0];

    PRINT(" FIXED POINT GRAPH DEMO\n ");
    @INIT();

    A = 0;
    KEY = 0;

    WHILE (KEY != 27) {
        KEY = INKEY(0);

        A2 = NORMALIZE360(A * 2);
        A3 = NORMALIZE360(A * 3);
        A4 = NORMALIZE360(A * 4);
        A5 = NORMALIZE360(A * 5);

        GCLS();
        DRAW_ROT_BOX(200, 100, A,  7);
        DRAW_ROT_BOX(160,  80, A2, 6);
        DRAW_ROT_BOX(120,  60, A3, 5);
        DRAW_ROT_BOX( 80,  40, A4, 3);
        DRAW_ROT_BOX( 40,  20, A5, 2);

        DELAY(4);
        A = NORMALIZE360(A + 3);
    }

    GCLS();
    PRINT("\C");
    PRINT("DONE\n");
END;
