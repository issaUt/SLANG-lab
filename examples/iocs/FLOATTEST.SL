#include "../../lib/iocs/MZ25IOCS_SVC.LIB"
#include "../../lib/iocs/MZ25IOCS_FNC.LIB"

MAIN()
VAR I, J;
BYTE BT;
VAR BYTE BUF[128], BYTE FBUF[10], BYTE T[], BYTE SLBUF[];
VAR FLOAT SLV[1];
{
    PRINT("TYPE: ");
    BT = INPUT();
    PRINT("TYPE = ",BT,/);
    PRINT(/);

    /*
    LOOP {
        FOR I=0 TO 9 {
            FBUF[I] = 0;
        }
        BUF[0] = 0;
        PRINT("VALUE:");
        LINPUT(BUF, 20);
        IF (BUF[0] == 0) EXIT;

        IOCS_C_FXAS(BUF, FBUF, BT);
        FOR I = 0 to 9 {
            PRINT(HEX2$(FBUF[I]),",");
        }
        PRINT(/);

        SLBUF = &SLV[0];
        IOCS_MZF2SF(FBUF, SLBUF);
        PRINT("MZF->SLF: ", FL$(SLV[0]),/);
    }
    */

    PRINT(/,"SQR",/);
    LOOP {
        FOR I=0 TO 9 {
            FBUF[I] = 0;
        }
        BUF[0] = 0;
        PRINT("VALUE:");
        LINPUT(BUF, 20);
        IF (BUF[0] == 0) EXIT;

        IOCS_C_FXAS(BUF, FBUF, BT); // TEXT -> MZ FLOAT
        IOCS_F_SQR(FBUF, BT);       // SQRT

        BUF[0] = 0;
        IOCS_C_NMFL(FBUF, BUF, BT);
        PRINT("MZ FLOAT MNFL: ", MSX$(BUF),/);

        BUF[0] = 0;
        IOCS_C_ASFL(FBUF, BUF, BT);
        PRINT("MZ FLOAT ASFL: ", MSX$(BUF),/);

        BUF[0] = 0;
        IOCS_F_USING(FBUF, "+##.#####", BUF, BT);
        PRINT("MZ FLOAT USING: ", MSX$(BUF),/);

        SLBUF = &SLV[0];
        IOCS_MZF2SF(FBUF, SLBUF);   // MZ FLOAT -> SLANG FLOAT
        PRINT("SLANG FLOAT: ", FL$(SLV[0]), /);
    }
}