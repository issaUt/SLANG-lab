/*
 * 固定小数点ワイヤーフレーム透視投影デモ。
 * 共通視点がモデルの周囲を回る、Z距離スケーリング付きの簡易透視投影を試す。
 */

CONST  _PLOTSW=0,_THREE=0,_FLOAT=0,_SINCOS=0,_TILESW=1,_GHIN=$FFFF,_KPRINTF=0,_COLOR=1;

#INCLUDE GRAPHF.LIB
#include "FIXEDPOINTLIB.SL"

VAR PROJ_X, PROJ_Y, PROJ_OK;
VAR VIEW_AY, VIEW_AX, VIEW_DIST, VIEW_NEAR, VIEW_FOCAL;
VAR CAM_X, CAM_Y, CAM_Z;
ARRAY SX[7], SY[7];
ARRAY BYTE VOK[7];
ARRAY OCTA_OX[7], OCTA_OY[7];
ARRAY CUBE_OX[7], CUBE_OY[7];
ARRAY BYTE OCTA_OOK[7], CUBE_OOK[7];
VAR CUR_VX[], CUR_VY[], CUR_VZ[];
VAR BYTE CUR_EA[], BYTE CUR_EB[];
VAR CUR_OX[], CUR_OY[];
VAR BYTE CUR_OOK[];
VAR CUR_VMAX, CUR_EMAX, CUR_MX, CUR_MY, CUR_MZ;

// WORD配列の初期値に負数を含めるとバイト列として出力されるため、
// 座標は INIT_*_DATA() で実行時に設定する。
ARRAY OCTA_X[5], OCTA_Y[5], OCTA_Z[5];
ARRAY BYTE OCTA_EA[11] = [ 4, 4, 4, 4, 5, 5, 5, 5, 0, 2, 1, 3 ];
ARRAY BYTE OCTA_EB[11] = [ 0, 1, 2, 3, 0, 1, 2, 3, 2, 1, 3, 0 ];

ARRAY CUBE_X[7], CUBE_Y[7], CUBE_Z[7];
ARRAY BYTE CUBE_EA[11] = [ 0, 1, 2, 3, 4, 5, 6, 7, 0, 1, 2, 3 ];
ARRAY BYTE CUBE_EB[11] = [ 1, 2, 3, 0, 5, 6, 7, 4, 4, 5, 6, 7 ];


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


// 透視投影用の共通視点パラメータを設定する。
INIT_VIEW()
{
    VIEW_AY = 0;
    VIEW_AX = 0;
    VIEW_DIST = 130;
    VIEW_NEAR = 30;
    VIEW_FOCAL = 80;
}


// 大きめの整数座標に固定小数点を掛ける。先に1/4へ縮めて16bit乗算のあふれを避ける。
FIXMUL_I_SAFE(X, F)
VAR Q, T, R;
{
    Q = X ./. 4;
    T = Q .*. F;
    R = FIXSHIFT8_S(T);
    RETURN R + R + R + R;
}


// 共通カメラ位置を、シーン中心の周囲を回る軌道上に置く。
SET_CAMERA_ANGLE(A)
VAR S, C;
{
    VIEW_AY = A;
    S = SIN_F(A);
    C = COS_F(A);
    CAM_X = FIXMUL_I_SAFE(VIEW_DIST, S);
    CAM_Y = 45;
    CAM_Z = -FIXMUL_I_SAFE(VIEW_DIST, C);
}


// 正八面体モデルの頂点座標をWORD配列へ設定する。
INIT_OCTA_DATA(S)
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
INIT_CUBE_DATA(S)
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
    CUR_OOK = OCTA_OOK;
    CUR_VMAX = 5;
    CUR_EMAX = 11;
    CUR_MX = -55;
    CUR_MY = 0;
    CUR_MZ = 0;
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
    CUR_OOK = CUBE_OOK;
    CUR_VMAX = 7;
    CUR_EMAX = 11;
    CUR_MX = 55;
    CUR_MY = 0;
    CUR_MZ = 0;
}


// 3D 点をモデル回転、ワールド配置、カメラ視点変換、透視投影の順で画面座標へ変換する。
// このデモではモデル回転を 0 にして、カメラ位置をシーン中心の周囲で回す。
PROJECT_POINT(X, Y, Z, MAY, MAX)
VAR MCY, MSY, MCX, MSX, VCY, VSY, VCX, VSX;
VAR RX, RY, RZ, WX, WY, WZ, DX, DY, DZ, TX, TY, TZ, VX, VY, VZ, DEPTH, TMP, PX, PY;
{
    MCY = COS_F(MAY);
    MSY = SIN_F(MAY);
    MCX = COS_F(MAX);
    MSX = SIN_F(MAX);

    RX = FIXMUL_I_SAFE(X, MCY) + FIXMUL_I_SAFE(Z, MSY);
    RZ = -FIXMUL_I_SAFE(X, MSY) + FIXMUL_I_SAFE(Z, MCY);
    RY = FIXMUL_I_SAFE(Y, MCX) - FIXMUL_I_SAFE(RZ, MSX);
    RZ = FIXMUL_I_SAFE(Y, MSX) + FIXMUL_I_SAFE(RZ, MCX);

    WX = CUR_MX + RX;
    WY = CUR_MY + RY;
    WZ = CUR_MZ + RZ;

    DX = WX - CAM_X;
    DY = WY - CAM_Y;
    DZ = WZ - CAM_Z;

    VCY = COS_F(VIEW_AY);
    VSY = SIN_F(VIEW_AY);
    VCX = COS_F(VIEW_AX);
    VSX = SIN_F(VIEW_AX);
    TX = FIXMUL_I_SAFE(DX, VCY) + FIXMUL_I_SAFE(DZ, VSY);
    TZ = -FIXMUL_I_SAFE(DX, VSY) + FIXMUL_I_SAFE(DZ, VCY);
    TY = FIXMUL_I_SAFE(DY, VCX) - FIXMUL_I_SAFE(TZ, VSX);
    VZ = FIXMUL_I_SAFE(DY, VSX) + FIXMUL_I_SAFE(TZ, VCX);
    VX = TX;
    VY = TY;

    DEPTH = VZ;
    IF (DEPTH .<. VIEW_NEAR) {
        PROJ_OK = 0;
    } ELSE {
        TMP = VX * VIEW_FOCAL;
        PX = TMP ./. DEPTH;
        PROJ_X = 320 + PX;
        TMP = VY * VIEW_FOCAL;
        PY = TMP ./. DEPTH;
        PROJ_Y = 100 - PY;
        PROJ_OK = 1;
    }
}


// 頂点 I の 3D 座標を投影して、現在フレームの画面座標配列へ入れる。
SET_POINT(I, X, Y, Z, MAY, MAX)
{
    PROJECT_POINT(X, Y, Z, MAY, MAX);
    SX[I] = PROJ_X;
    SY[I] = PROJ_Y;
    VOK[I] = PROJ_OK;
}


// 登録済みモデルの頂点配列を画面座標へ変換する。
MAKE_MODEL(MAY, MAX)
VAR I, X, Y, Z;
{
    FOR I = 0 TO CUR_VMAX {
        X = CUR_VX[I];
        Y = CUR_VY[I];
        Z = CUR_VZ[I];
        SET_POINT(I, X, Y, Z, MAY, MAX);
    }
}


// 現在フレームの頂点 A-B を描く。どちらかが近接面の手前なら描かない。
DRAW_EDGE(A, B)
VAR X1, Y1, X2, Y2;
{
    IF (VOK[A] != 0) {
        IF (VOK[B] != 0) {
            X1 = SX[A];
            Y1 = SY[A];
            X2 = SX[B];
            Y2 = SY[B];
            @LINE(X1, Y1, X2, Y2);
        }
    }
}


// 前フレームの頂点 A-B を描く。消去モードで呼び出す。
DRAW_OLD_EDGE(A, B)
VAR X1, Y1, X2, Y2;
{
    IF (CUR_OOK[A] != 0) {
        IF (CUR_OOK[B] != 0) {
            X1 = CUR_OX[A];
            Y1 = CUR_OY[A];
            X2 = CUR_OX[B];
            Y2 = CUR_OY[B];
            @LINE(X1, Y1, X2, Y2);
        }
    }
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


// 現在の座標と有効フラグを次フレームの消去用に保存する。
SAVE_MODEL()
VAR I;
{
    FOR I = 0 TO CUR_VMAX {
        CUR_OX[I] = SX[I];
        CUR_OY[I] = SY[I];
        CUR_OOK[I] = VOK[I];
    }
}


// 登録済みモデルの前フレームを消す。
ERASE_FRAME(FIRST)
{
    IF (FIRST == 0) {
        @MODE(0, 0);
        DRAW_OLD_MODEL();
    }
}


// 登録済みモデルを 1 フレーム分回転・描画し、次回消去用に保存する。
DRAW_FRAME(MAY, MAX)
{
    MAKE_MODEL(MAY, MAX);

    @MODE(2, 0);
    DRAW_MODEL();
    SAVE_MODEL();
}


MAIN()
VAR AY, AX, KEY, FIRST;
BEGIN
    PRINT(" FIXED POINT PERSPECTIVE DEMO\n ");
    @INIT();
    @PALET(0,7,2,3,4,5,6,7);
    GCLS();
    INIT_VIEW();
    INIT_OCTA_DATA(35);
    INIT_CUBE_DATA(28);

    AY = 0;
    KEY = 0;
    FIRST = 1;

    WHILE (KEY != 27) {
        KEY = INKEY(0);
        AX = 0;
        SET_CAMERA_ANGLE(AY);
        VIEW_AX = -12;

        SET_OCTA_MODEL();
        ERASE_FRAME(FIRST);

        SET_CUBE_MODEL();
        ERASE_FRAME(FIRST);

        SET_OCTA_MODEL();
        DRAW_FRAME(0, AX);

        SET_CUBE_MODEL();
        DRAW_FRAME(0, AX);

        FIRST = 0;

        DELAY(5);
        AY = NORMALIZE360(AY + 4);
    }

    GCLS();
    PRINT("\C");
    PRINT("DONE\n");
END;
