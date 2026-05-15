#include "../../lib/iocs/MZ25IOCS_SVC.LIB"
#include "../../lib/iocs/MZ25IOCS_FNC.LIB"

MAIN()
VAR I, J;
BYTE BT;
VAR BYTE BUF[128];
VAR BYTE FBUFA[10], BYTE FBUFB[10], BYTE FBUFC[10];
VAR FLOAT SLV[1];
{
    PRINT("TYPE: ");
    BT = INPUT();
    PRINT("TYPE = ",BT,/);
    PRINT(/);

    LOOP {
        FOR I=0 TO 9 {
            FBUFA[I] = 0;
            FBUFB[I] = 0;
            FBUFC[I] = 0;
        }
        BUF[0] = 0;
        PRINT("VALUE A:");
        LINPUT(BUF, 20);
        IF (BUF[0] == 0) EXIT;
        IOCS_C_FXAS(BUF, FBUFA, BT);

        BUF[0] = 0;
        PRINT("VALUE B:");
        LINPUT(BUF, 20);
        IF (BUF[0] == 0) EXIT;
        IOCS_C_FXAS(BUF, FBUFB, BT);

        FOR I = 0 TO 9 {
            FBUFC[I] = FBUFA[I];
        }

        IOCS_F_MUL(FBUFC, FBUFB, BT);

        BUF[0] = 0;
        IOCS_C_ASFL(FBUFC, BUF, BT);
        PRINT("A * B = ", MSX$(BUF),/);
    }
}