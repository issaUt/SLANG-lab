
#include "../../lib/iocs/MZ25IOCS_TEXT.LIB"

MAIN()
VAR BYTE BUF[];
VAR I,X,Y;
VAR BYTE XY[2];
{
    BUF = "IOCS TEST\n";
    ^DE = &BUF[0];

    #ASM
    LD DE,(_DE)
    SVC SVC_CRTMS
    #END

    IOCS_LOCATE(20,10);
    PRINT("*");
    IOCS_GETCURSOR(XY);
    PRINT("X=", XY[0], ": Y=", XY[1],/);

    FOR I=0 TO 50 {
        //LOCATE(RND(80),RND(24));
        IOCS_LOCATE(RND(80),RND(24));
        PRINT("*");
    }


}
