#include "../../lib/iocs/MZ25IOCS_SVC.LIB"
#include "../../lib/iocs/MZ25IOCS_FNC.LIB"

GETTEXT(BYTE T)
VAR BUF[];
{
    T = T MOD 6;
    CASE T OF {
        0: BUF = "FX-9000P";
        1: BUF = "MZ-1500";
        2: BUF = "MZ-2521";
        3: BUF = "X1turboZIII";
        4: BUF = "X68000";
        5: BUF = "X68030";
    }
    RETURN BUF;
}

// 256文字までの文字列の長さを取得する
GETLENGTH(BYTE BUF[])
VAR I, MX, RESULT;
{
    MX = 255;
    RESULT = 0;
    FOR I = 0 TO MX {
        IF (BUF[I] == 0) {
            RESULT = I;
            EXIT;
        }
    }
    IF (I == MX) RESULT = MX;
    RETURN RESULT;
}

TONEXTSESSION()
VAR KEY;
{
    LOCATE(0,0);
    KEY = 0;
    PRINT("HIT ESC KEY");
    WHILE( KEY != 27 ) KEY=INKEY(0);

    LOCATE(0,0);
    PRINT("           ");
}

MAIN()
VAR BYTE S[];
VAR I, J, K, L, R, KEY, COL;
VAR WX[3], WY[3], WXC, WYC;
VAR WORD GW, GH;
VAR BYTE BC[1];
VAR BYTE PLT[30];
VAR FLOAT SA, FLOAT EA, FLOAT AR, FLOAT FT, FLOAT FM;
VAR BYTE BUFSA[8], BYTE BUFEA[8], BYTE BUFAR[8], BYTE BUFM[8];
VAR BYTE SB[10];
VAR BYTE MX, MY, AG, BL;
VAR WORD SCY;
{
    GW = 640;
    GH = 400;
    IOCS_INITSCREEN();
    IOCS_SCREEN(0,0);
    IOCS_GINIT(GW,GH,16);
    IOCS_VIEW(0,0,GW-1,GH-1);

    IOCS_CLS(0);
    FOR I=1 TO 2000 {
        // IOCS_PSET_RAW(RND(GW),RND(GH),RND(15)+1);
        IOCS_PSET_RAW400(RND(GW),RND(GH),RND(15)+1);
    }
    TONEXTSESSION();

    IOCS_CLS(0);
    FOR I=1 TO 500 {
        IOCS_LINE(RND(GW),RND(GH),RND(GW),RND(GH),RND(15)+1);
    }
    TONEXTSESSION();

    IOCS_CLS(0);
    FOR I=0 TO 40 {
        COL = (I MOD 15) + 1;
        IOCS_BOX(I*5,I*5,GW-1-I*5,GH-1-I*5,COL,0);
    }
    TONEXTSESSION();

    IOCS_CLS(0);
    FOR K = 0 TO 1 {
        FOR I=1 TO 15 {
            WXC=0;
            WYC=0;
            FOR J=0 TO 2 {
                WX[J] = RND(GW);
                WY[J] = RND(GH);
                WXC += WX[J];
                WYC += WY[J];
            }
            WXC=WXC/3;
            WYC=WYC/3;
            FOR J=0 TO 2 {
                IF (J < 2) {
                    IOCS_LINE(WX[J],WY[J], WX[J+1], WY[J+1], I);
                } ELSE {
                    IOCS_LINE(WX[J],WY[J], WX[0], WY[0], I);            }
            }
            BC[0] = I;
            IOCS_PAINT(WXC, WYC, &BC[0], 1, I);
        }
    }
    TONEXTSESSION();

    IOCS_CLS(0);
    FOR I=0 TO 100 {
        COL = (I MOD 15) + 1;
        IOCS_CIRCLE(100+RND(GW-200),100+RND(GH-200),10+RND(90),COL);
    }
    TONEXTSESSION();

    IOCS_CLS(0);
    FOR K=0 TO 3 {
        FOR I=1 TO 15 {
            WXC = RND(GW-200)+100;
            WYC = RND(GH-200)+100;
            R   = RND(90) + 10;
            IOCS_CIRCLE(WXC, WYC, R, I);
            BC[0] = I;
            IOCS_PAINT(WXC, WYC, &BC[0], 1, I);
        }
    }
    TONEXTSESSION();

    IOCS_CLS(0);
    KEY=0;
    AR = UTOF(1);
    IOCS_SF2MZD2(AR, BUFAR);
    FM = UTOF(1000);
    IOCS_SF2MZD2(FM, BUFM);
    FOR I=0 TO 100 {
        SA = UTOF(RND(6238));  // PI*2*1000
        EA = UTOF(RND(6238));  // PI*2*1000
        IF (SA > EA) {
            FT = SA;
            SA = EA;
            EA = FT;
        }
        IOCS_SF2MZD2(SA, BUFSA);
        IOCS_F_DIV(BUFSA, BUFM, 5); // PI*2*1000/1000
        IOCS_SF2MZD2(EA, BUFEA);
        IOCS_F_DIV(BUFEA, BUFM, 5); // PI*2*1000/1000
        COL = (I MOD 15) + 1;
        IOCS_FANSHAPE(100+RND(GW-200),100+RND(GH-200),10+RND(90),COL, 3, BUFSA, BUFEA, BUFAR);
    }
    TONEXTSESSION();

    IOCS_CLS(0);
    FOR I = 0 TO 1 {
        FOR J = 0 TO 14 {
            COL = J+1;
            MX = RND(10)+1;
            MY = RND(10)+1;
            AG = RND(4);
            S = GETTEXT(RND(6));
            L = GETLENGTH(S);
            BL = L AND $FF;
            //PRINT("LEN:",BL, " TEXT:", MSX$(S),/);
            IOCS_POSSV_SET(RND(GW-1), RND(GH-1));
            // IOCS_SVMBLS, BL, COL, 0, MX, MY, AG, 0);
            IOCS_SVMBL400(S, BL, COL, 0, MX, MY, AG, 0);
        }
    }
    TONEXTSESSION();

    IOCS_CLS(0);
    FOR I=0 TO 25 {
        COL = (I MOD 15) + 1;
        IOCS_BOX(I*8,I*8,639-I*8,399-I*8,COL,2);
    }
    TONEXTSESSION();

    KEY=0;
    I=0;
    SCY = $FFFF;
    LOCATE(0,0);
    PRINT("HIT ESC KEY");
    WHILE( KEY !=27 ) {
        FOR J=0 TO 14 {
            PLT[J*2] = J+1
            PLT[J*2+1] = ((I + J) MOD 15) + 1
        }
        IOCS_COLOR(15, PLT);
        KEY=INKEY(0);
        I=I+1;

        IF (SCY == $FFFF) {
            IF (KEY == 27) {
                KEY = 0;
                SCY = 0;
            }
        }
        IF (SCY != $FFFF) {
            IOCS_HROLL(0, 399-SCY);
            SCY = (SCY + 2) MOD 400;
        }
    }
    LOCATE(0,0);
    PRINT("             ");
    IOCS_HROLL(1, 0);
    IOCS_INITCOLOR();
}
