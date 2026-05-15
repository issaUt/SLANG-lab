/*
 MZ-2500 IOCS HAT 3D DEMO
 古典的なBASIC版HAT3DをSLANG + IOCS描画へ移植したもの。
 演算はSLANGのFLOATを使い、描画はMAGICではなくMZ-2500 IOCSを直接呼ぶ。
 */

#include "../../lib/iocs/MZ25IOCS_SVC.LIB"

CONST DEG2RAD = 3.1415926 / 180.0;

// 4096色パレットのグラデーション。
// IOCS_COLOR4096 は [PaletteID, G, R, B] の4バイトで1色を指定する。
VAR BYTE PALDATA[64] = {
     0,  0,  0,  0,
     1,  0,  0, 15,
     2,  0,  3, 12,
     3,  0,  7,  8,
     4,  0, 12,  4,
     5,  4, 15,  0,
     6,  8, 12,  0,
     7, 11,  9,  0,
     8, 14,  6,  0,
     9, 15,  0,  0,
    10, 15,  0,  4,
    11, 15,  0,  8,
    12, 15,  0, 12,
    13, 15,  4, 15,
    14, 15,  8, 15,
    15, 15, 12, 15
};

// 各画面X位置について、すでに描いた上端/下端のYを覚える。
// 隠面っぽく見せるための簡易的な上下輪郭バッファ。
ARRAY D[2][640];

MAIN()
VAR X,Y,L,DX,SX,SY;
VAR GW, GH;
VAR FLOAT R, Z;
BEGIN
    PRINT(" HAT3D START\n ")

    GW = 640;
    GH = 400;

    IOCS_INITSCREEN();
    IOCS_GINIT(GW, GH, 16);
    // IOCS_CRTI2(1);
    IOCS_VIEW(0, 0, GW-1, GH-1);
    IOCS_CLS(0);

    // 16色モード上で4096色パレットを差し替える。
    IOCS_COLOR4096(16,PALDATA);

    // 未描画位置を -1 で初期化する。
    FOR L=0 TO 512 {
        D[0][L] = -1;
        D[1][L] = -1;
    }

    FOR Y=0 TO 180 {

        VAR FLOAT FY;
        FY = Y * 2.0 - 180.0;

        FOR X=0 TO 180 {

            VAR FLOAT FX;
            FX = X * 2.0 - 180.0;

            R = FSQRT(FX*FX + FY*FY) * DEG2RAD;
            Z = 100.0 * FCOS(R) - 30.0 * FCOS(3.0 * R) + 1.0;

            DX = FTOI((116.0 + FX/2.0 + (16.0 - FY/2.0)/2.0 + 12.0) * 1.8);
            SY = FTOI(((130.0 - FY/2.0 - Z)/2.0) * 1.8);
            SX = DX + 80;
            SY = SY + 50;

            IF (DX < 0) CONTINUE;
            IF (DX > 512) CONTINUE;

            IF D[0][DX] == -1 {
                IF DX == 0 {
                    D[0][DX] = SY;
                    D[1][DX] = SY;
                    PLOT_POINT(SX,SY,Z);
                    CONTINUE;
                }

                IF DX == 512 {
                    D[0][DX] = SY;
                    D[1][DX] = SY;
                    PLOT_POINT(SX,SY,Z);
                    CONTINUE;
                }

                IF D[0][DX-1] == -1 {
                    PLOT_POINT(SX,SY,Z);
                    D[0][DX] = SY;
                    IF D[1][DX] == -1 {
                        D[1][DX] = SY;
                    }
                    CONTINUE;
                }

                IF D[0][DX+1] == -1 {
                    PLOT_POINT(SX,SY,Z);
                    D[0][DX] = SY;
                    IF D[1][DX] == -1 {
                        D[1][DX] = SY;
                    }
                    CONTINUE;
                }

                D[0][DX] = (D[0][DX-1] + D[0][DX+1]) ./. 2;
                D[1][DX] = (D[1][DX-1] + D[1][DX+1]) ./. 2;
                PLOT_POINT(SX,SY,Z);
                CONTINUE;
            }

            IF SY <= D[0][DX] {
                PLOT_POINT(SX,SY,Z);
                D[0][DX]=SY;
                IF D[1][DX] == -1 {
                    D[1][DX] = SY;
                }
                CONTINUE;
            }

            IF SY >= D[1][DX] {
                PLOT_POINT(SX,SY,Z);
                D[1][DX]=SY;
                IF D[0][DX] == -1 {
                    D[0][DX] = SY;
                }
                CONTINUE;
            }
        }
    }
END;


PLOT_POINT(WORD SX, WORD SY, FLOAT Z)
VAR C;
{

    //C = FTOI((Z + 92.0) / 26.0) + 9;
    //IF C<9 THEN C=9;
    //IF C>15 THEN C=15;
    C = FTOI((Z + 92.0) / 13.0) + 1;

    //PRINT("SX,SY,C=");PRINT(SX);PRINT(", ");PRINT(SY);PRINT(", ");PRINT(C);PRINT("/n");
    // 640x400ではIOCS_PSETが描画されないケースがあるため、
    // 現状は同一始終点のLINEを点描画として使う。
    IOCS_LINE(SX,SY,SX,SY,C);
    //IOCS_PSET(SX,SY,C);
};
