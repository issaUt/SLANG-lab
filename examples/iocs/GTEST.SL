#include "../../lib/iocs/MZ25IOCS_SVC.LIB"

MAIN()
VAR BYTE S[];
VAR I, J, K, KEY, COL;
VAR WORD GW, GH;
VAR BYTE PLT[30];
{
    GW = 640;
    GH = 400;
    IOCS_INITSCREEN();
    IOCS_SCREEN(0,0);
    IOCS_GINIT(GW,GH,16);
    IOCS_VIEW(0,0,GW-1,GH-1);

    IOCS_CLS(0);
    FOR I=1 TO 100 {
        IOCS_LINE(RND(GW),RND(GH),RND(GW),RND(GH),RND(15)+1);
    }
    WHILE( KEY != 27 ) KEY=INKEY(0);

    IOCS_CLS(0);
    KEY=0;
    FOR I=0 TO 40 {
        COL = (I MOD 15) + 1;
        IOCS_BOX(I*5,I*5,639-I*5,399-I*5,COL,0);
    }
    WHILE( KEY != 27 ) KEY=INKEY(0);

    IOCS_CLS(0);
    KEY=0;
    FOR I=0 TO 100 {
        COL = (I MOD 15) + 1;
        IOCS_CIRCLE(100+RND(GW-200),100+RND(GH-200),10+RND(90),COL);
    }
    WHILE( KEY != 27 ) KEY=INKEY(0);

    IOCS_CLS(0);
    KEY=0;
    FOR I=0 TO 23 {
        COL = (I MOD 15) + 1;
        IOCS_BOX(I*8,I*8,639-I*8,399-I*8,COL,2);
    }
    WHILE( KEY != 27 ) KEY=INKEY(0);

    KEY=0;
    I=0;
    WHILE( KEY !=27 ) {
        FOR J=0 TO 14 {
            PLT[J*2] = J+1
            PLT[J*2+1] = ((I + J) MOD 15) + 1
        }
        IOCS_COLOR(15, PLT);
        KEY=INKEY(0);
        I=I+1;
    }

    IOCS_INITCOLOR();
}