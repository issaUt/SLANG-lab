#include "../../lib/iocs/MZ25IOCS_SVC.LIB"
#include "../../lib/iocs/MZ25IOCS_FNC.LIB"

MAIN()
VAR I, J, RESULT;
VAR WORD RT[];
VAR BYTE BT;
VAR BYTE BUF[128];
VAR BYTE FBUFA[10], BYTE FBUFB[10], BYTE FBUFC[10];
VAR FLOAT SLV[1];
{
    PRINT("TYPE: ");
    BT = INPUT();
    PRINT("TYPE = ",BT,/);
    PRINT(/);

    PRINT("CMP",/);
    LOOP {
        FOR I=0 TO 9 {
            FBUFA[I] = 0;
            FBUFB[I] = 0;
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

        RESULT=IOCS_F_CMP(FBUFA, FBUFB, BT);
        PRINT("CMP = ", RESULT,/);
    }

    PRINT("INT0 SIGNED INT",/);
    LOOP {
        FOR I=0 TO 9 {
            FBUFA[I] = 0;
        }

        BUF[0] = 0;
        PRINT("VALUE A:");
        LINPUT(BUF, 20);
        IF (BUF[0] == 0) EXIT;
        IOCS_C_FXAS(BUF, FBUFA, BT);

        RESULT=IOCS_F_INT0(FBUFA, BT);
        PRINT("INT0 = ", PN$(RESULT),/);
    }

    PRINT("INT2 UNSIGNED INT",/);
    LOOP {
        FOR I=0 TO 9 {
            FBUFA[I] = 0;
        }

        BUF[0] = 0;
        PRINT("VALUE A:");
        LINPUT(BUF, 20);
        IF (BUF[0] == 0) EXIT;
        IOCS_C_FXAS(BUF, FBUFA, BT);

        RESULT=IOCS_F_INT2(FBUFA, BT);
        PRINT("INT2 = ", RESULT,/);
    }

    PRINT("FLT0",/);
    LOOP {
        FOR I=0 TO 9 {
            FBUFA[I] = 0;
            FBUFB[I] = 0;
        }

        BUF[0] = 0;
        PRINT("VALUE A:");
        LINPUT(BUF, 20);
        IF (BUF[0] == 0) EXIT;
        IOCS_C_FXAS(BUF, FBUFA, 2);
        RT = &FBUFA[0];
        PRINT("RT: ", HEX4$(RT[0]),/);

        IOCS_F_FLT0(RT[0], FBUFB, BT);
        PRINT("CHECK:");
        FOR I = 0 to 9 {
            PRINT(HEX2$(FBUFB[I]),",");
        }
        PRINT(/);

        IOCS_C_NMFL(FBUFB, BUF, BT);
        PRINT("FLT0: ", MSX$(BUF),/);
    }
}