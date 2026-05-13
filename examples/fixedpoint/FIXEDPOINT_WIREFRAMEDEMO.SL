/*
 * 固定小数点ワイヤーフレーム正八面体デモ。
 * ../../lib/fixedpoint/FIXEDPOINT.LIB の三角関数と固定小数点乗算で 3D 回転し、
 * GRAPHF.LIB(MAGIC) の単色 @LINE で線を描く。
 */

CONST  _PLOTSW=0,_THREE=0,_FLOAT=0,_SINCOS=0,_TILESW=1,_GHIN=$FFFF,_KPRINTF=0,_COLOR=1;

#INCLUDE GRAPHF.LIB
#include "../../lib/fixedpoint/FIXEDPOINT.LIB"

VAR PROJ_X, PROJ_Y;
ARRAY SX[7], SY[7];
ARRAY OCTA_OX[7], OCTA_OY[7];
ARRAY CUBE_OX[7], CUBE_OY[7];
VAR CUR_VX[], CUR_VY[], CUR_VZ[];
VAR BYTE CUR_EA[], BYTE CUR_EB[];
VAR CUR_OX[], CUR_OY[];
VAR CUR_VMAX, CUR_EMAX, CUR_CX, CUR_CY;

// Pico 2 の WireFrameTest と同じ正八面体モデル。
// WORD配列の初期値に負数を含めるとバイト列として出力されるため、
// 座標は INIT_OCTA_DATA() で実行時に設定する。
ARRAY OCTA_X[5], OCTA_Y[5], OCTA_Z[5];
ARRAY BYTE OCTA_EA[11] = [ 4, 4, 4, 4, 5, 5, 5, 5, 0, 2, 1, 3 ];
ARRAY BYTE OCTA_EB[11] = [ 0, 1, 2, 3, 0, 1, 2, 3, 2, 1, 3, 0 ];

// 差し替え確認用の立方体モデル。
ARRAY CUBE_X[7], CUBE_Y[7], CUBE_Z[7];
ARRAY BYTE CUBE_EA[11] = [ 0, 1, 2, 3, 4, 5, 6, 7, 0, 1, 2, 3 ];
ARRAY BYTE CUBE_EB[11] = [ 1, 2, 3, 0, 5, 6, 7, 4, 4, 5, 6, 7 ];


// 短い待ち時間を作る。
DELAY(WORD N)
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


// 正八面体モデルの頂点座標をWORD配列へ設定する。
INIT_OCTA_DATA(WORD S)
VAR M;
{
    M = -S;

    OCTA_X[0] =  S; OCTA_Y[0] =  0; OCTA_Z[0] =  0;
    OCTA_X[1] =  M; OCTA_Y[1] =  0; OCTA_Z[1] =  0;
    OCTA_X[2] =  0; OCTA_Y[2] =  S; OCTA_Z[2] =  0;
    OCTA_X[3] =  0; OCTA_Y[3] =  M; OCTA_Z[3] =  0;
    OCTA_X[4] =  0; OCTA_Y[4] =  0; OCTA_Z[4] =  S;
    OCTA_X[5] =  0; OCTA_Y[5] =  0; OCTA_Z[5] =  M;
}


// 立方体モデルの頂点座標をWORD配列へ設定する。
INIT_CUBE_DATA(WORD S)
VAR M;
{
    M = -S;

    CUBE_X[0] =  M; CUBE_Y[0] =  M; CUBE_Z[0] =  M;
    CUBE_X[1] =  S; CUBE_Y[1] =  M; CUBE_Z[1] =  M;
    CUBE_X[2] =  S; CUBE_Y[2] =  S; CUBE_Z[2] =  M;
    CUBE_X[3] =  M; CUBE_Y[3] =  S; CUBE_Z[3] =  M;
    CUBE_X[4] =  M; CUBE_Y[4] =  M; CUBE_Z[4] =  S;
    CUBE_X[5] =  S; CUBE_Y[5] =  M; CUBE_Z[5] =  S;
    CUBE_X[6] =  S; CUBE_Y[6] =  S; CUBE_Z[6] =  S;
    CUBE_X[7] =  M; CUBE_Y[7] =  S; CUBE_Z[7] =  S;
}


// 正八面体モデルを描画対象として登録する。
SET_OCTA_MODEL()
{
    CUR_VX = OCTA_X;
    CUR_VY = OCTA_Y;
    CUR_VZ = OCTA_Z;
    CUR_EA = OCTA_EA;
    CUR_EB = OCTA_EB;
    CUR_OX = OCTA_OX;
    CUR_OY = OCTA_OY;
    CUR_VMAX = 5;
    CUR_EMAX = 11;
    CUR_CX = 220;
    CUR_CY = 100;
}


// 立方体モデルを描画対象として登録する。
SET_CUBE_MODEL()
{
    CUR_VX = CUBE_X;
    CUR_VY = CUBE_Y;
    CUR_VZ = CUBE_Z;
    CUR_EA = CUBE_EA;
    CUR_EB = CUBE_EB;
    CUR_OX = CUBE_OX;
    CUR_OY = CUBE_OY;
    CUR_VMAX = 7;
    CUR_EMAX = 11;
    CUR_CX = 420;
    CUR_CY = 100;
}


// 3D 点 (X,Y,Z) を Y 軸、X 軸の順に回転し、画面座標 PROJ_X/PROJ_Y に入れる。
PROJECT_POINT(WORD X, WORD Y, WORD Z, WORD AY, WORD AX)
VAR CY, SY, CX, SX, RX, RY, RZ;
{
    CY = COS_F(AY);
    SY = SIN_F(AY);
    CX = COS_F(AX);
    SX = SIN_F(AX);

    RX = FIXMUL_I(X, CY) + FIXMUL_I(Z, SY);
    RZ = -FIXMUL_I(X, SY) + FIXMUL_I(Z, CY);

    RY = FIXMUL_I(Y, CX) - FIXMUL_I(RZ, SX);

    PROJ_X = CUR_CX + RX;
    PROJ_Y = CUR_CY - RY;
}


// 頂点 I の 3D 座標を回転して、現在フレームの画面座標配列へ入れる。
SET_POINT(WORD I, WORD X, WORD Y, WORD Z, WORD AY, WORD AX)
{
    PROJECT_POINT(X, Y, Z, AY, AX);
    SX[I] = PROJ_X;
    SY[I] = PROJ_Y;
}


// 登録済みモデルの頂点配列を画面座標へ変換する。
MAKE_MODEL(WORD AY, WORD AX)
VAR I, X, Y, Z;
{
    FOR I = 0 TO CUR_VMAX {
        X = CUR_VX[I];
        Y = CUR_VY[I];
        Z = CUR_VZ[I];
        SET_POINT(I, X, Y, Z, AY, AX);
    }
}


// 現在フレームの頂点 A-B を描く。
DRAW_EDGE(BYTE A, BYTE B)
VAR X1, Y1, X2, Y2;
{
    X1 = SX[A];
    Y1 = SY[A];
    X2 = SX[B];
    Y2 = SY[B];
    @LINE(X1, Y1, X2, Y2);
}


// 前フレームの頂点 A-B を描く。消去モードで呼び出す。
DRAW_OLD_EDGE(BYTE A, BYTE B)
VAR X1, Y1, X2, Y2;
{
    X1 = CUR_OX[A];
    Y1 = CUR_OY[A];
    X2 = CUR_OX[B];
    Y2 = CUR_OY[B];
    @LINE(X1, Y1, X2, Y2);
}


// 登録済みモデルの辺配列を使って現在フレームを描く。
DRAW_MODEL()
VAR I, A, B;
{
    FOR I = 0 TO CUR_EMAX {
        A = CUR_EA[I];
        B = CUR_EB[I];
        DRAW_EDGE(A, B);
    }
}


// 登録済みモデルの辺配列を使って前フレームを描く。消去モードで呼び出す。
DRAW_OLD_MODEL()
VAR I, A, B;
{
    FOR I = 0 TO CUR_EMAX {
        A = CUR_EA[I];
        B = CUR_EB[I];
        DRAW_OLD_EDGE(A, B);
    }
}


// 現在の座標を次フレームの消去用に保存する。
SAVE_MODEL()
VAR I;
{
    FOR I = 0 TO CUR_VMAX {
        CUR_OX[I] = SX[I];
        CUR_OY[I] = SY[I];
    }
}


// 登録済みモデルの前フレームを消す。
ERASE_FRAME(BYTE FIRST)
{
    IF (FIRST == 0) {
        @MODE(0, 0);
        DRAW_OLD_MODEL();
    }
}


// 登録済みモデルを 1 フレーム分回転・描画し、次回消去用に保存する。
DRAW_FRAME(WORD AY, WORD AX)
{
    MAKE_MODEL(AY, AX);

    @MODE(2, 0);
    DRAW_MODEL();
    SAVE_MODEL();
}


MAIN()
VAR AY, AX, KEY, FIRST;
BEGIN
    PRINT(" FIXED POINT WIREFRAME DEMO\n ");
    @INIT();
    GCLS();
    INIT_OCTA_DATA(55);   // 95
    INIT_CUBE_DATA(40);   // 80

    AY = 0;
    KEY = 0;
    FIRST = 1;

    WHILE (KEY != 27) {
        KEY = INKEY(0);
        AX = NORMALIZE360(AY / 2 + 25);

        SET_OCTA_MODEL();
        ERASE_FRAME(FIRST);

        SET_CUBE_MODEL();
        ERASE_FRAME(FIRST);

        SET_OCTA_MODEL();
        DRAW_FRAME(AY, AX);

        SET_CUBE_MODEL();
        DRAW_FRAME(NORMALIZE360(AY + 45), NORMALIZE360(AX + 30));

        FIRST = 0;

        DELAY(3);
        AY = NORMALIZE360(AY + 4);
    }

    GCLS();
    PRINT("\C");
    PRINT("DONE\n");
END;
