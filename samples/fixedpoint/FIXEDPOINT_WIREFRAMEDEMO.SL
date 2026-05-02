/*
 * 固定小数点ワイヤーフレーム正八面体デモ。
 * FIXEDPOINTLIB.SL の三角関数と固定小数点乗算で 3D 回転し、
 * GRAPHF.LIB(MAGIC) の単色 @LINE で線を描く。
 */

CONST  _PLOTSW=0,_THREE=0,_FLOAT=0,_SINCOS=0,_TILESW=1,_GHIN=$FFFF,_KPRINTF=0,_COLOR=1;

#INCLUDE GRAPHF.LIB
#include "FIXEDPOINTLIB.SL"

VAR PROJ_X, PROJ_Y;
VAR X0, Y0, X1, Y1, X2, Y2, X3, Y3, X4, Y4, X5, Y5;


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


// 3D 点 (X,Y,Z) を Y 軸、X 軸の順に回転し、画面座標 PROJ_X/PROJ_Y に入れる。
PROJECT_POINT(X, Y, Z, AY, AX)
VAR CY, SY, CX, SX, RX, RY, RZ;
{
    CY = COS_F(AY);
    SY = SIN_F(AY);
    CX = COS_F(AX);
    SX = SIN_F(AX);

    RX = FIXMUL_I(X, CY) + FIXMUL_I(Z, SY);
    RZ = -FIXMUL_I(X, SY) + FIXMUL_I(Z, CY);

    RY = FIXMUL_I(Y, CX) - FIXMUL_I(RZ, SX);

    PROJ_X = 320 + RX;
    PROJ_Y = 100 - RY;
}


// Pico 2 の WireFrameTest と同じ正八面体の 6 頂点を画面座標へ変換する。
MAKE_MODEL(AY, AX)
{
    PROJECT_POINT( 95,   0,   0, AY, AX);
    X0 = PROJ_X;
    Y0 = PROJ_Y;

    PROJECT_POINT(-95,   0,   0, AY, AX);
    X1 = PROJ_X;
    Y1 = PROJ_Y;

    PROJECT_POINT(  0,  95,   0, AY, AX);
    X2 = PROJ_X;
    Y2 = PROJ_Y;

    PROJECT_POINT(  0, -95,   0, AY, AX);
    X3 = PROJ_X;
    Y3 = PROJ_Y;

    PROJECT_POINT(  0,   0,  95, AY, AX);
    X4 = PROJ_X;
    Y4 = PROJ_Y;

    PROJECT_POINT(  0,   0, -95, AY, AX);
    X5 = PROJ_X;
    Y5 = PROJ_Y;
}


// 現在の正八面体を単色ワイヤーフレームで描く。
DRAW_MODEL()
{
    @LINE(X4, Y4, X0, Y0);
    @LINE(X4, Y4, X1, Y1);
    @LINE(X4, Y4, X2, Y2);
    @LINE(X4, Y4, X3, Y3);

    @LINE(X5, Y5, X0, Y0);
    @LINE(X5, Y5, X1, Y1);
    @LINE(X5, Y5, X2, Y2);
    @LINE(X5, Y5, X3, Y3);

    @LINE(X0, Y0, X2, Y2);
    @LINE(X2, Y2, X1, Y1);
    @LINE(X1, Y1, X3, Y3);
    @LINE(X3, Y3, X0, Y0);
}


MAIN()
VAR AY, AX, KEY;
BEGIN
    PRINT(" FIXED POINT WIREFRAME DEMO\n ");
    @INIT();

    AY = 0;
    KEY = 0;

    WHILE (KEY != 27) {
        KEY = INKEY(0);
        AX = NORMALIZE360(AY / 2 + 25);

        GCLS();
        MAKE_MODEL(AY, AX);
        DRAW_MODEL();

        DELAY(3);
        AY = NORMALIZE360(AY + 4);
    }

    GCLS();
    PRINT("\C");
    PRINT("DONE\n");
END;
