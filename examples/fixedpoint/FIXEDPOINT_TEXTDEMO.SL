#include "../../lib/fixedpoint/FIXEDPOINT.LIB"

ARRAY ROT_RESULT[1];
VAR ROT_PTR[];
ARRAY OLD_X[19];
ARRAY OLD_Y[19];

DELAY(WORD N)
VAR I, J;
{
    I = 0;
    WHILE (I < N) {
        J = 0;
        WHILE (J < 120) {
            J = J + 1;
        }
        I = I + 1;
    }
}


INIT_OLD()
VAR I;
{
    I = 0;
    WHILE (I < 20) {
        OLD_X[I] = 65535;
        OLD_Y[I] = 65535;
        I = I + 1;
    }
}


IN_SCREEN(WORD X, WORD Y)
{
    IF (X .<. 0) RETURN 0;
    IF (Y .<. 0) RETURN 0;
    IF (X >= 40) RETURN 0;
    IF (Y >= 24) RETURN 0;
    RETURN 1;
}


DRAWP(WORD I, WORD X, WORD Y, WORD A)
VAR RX, RY;
{
    IF (IN_SCREEN(OLD_X[I], OLD_Y[I]) != 0) {
        LOCATE(OLD_X[I], OLD_Y[I]);
        PRINT(!(" "));
    }

    ROTATE_CENTER(ROT_PTR, X, Y, 20, 12, A);
    RX = ROT_RESULT[0];
    RY = ROT_RESULT[1];

    OLD_X[I] = RX;
    OLD_Y[I] = RY;

    IF (IN_SCREEN(RX, RY) != 0) {
        LOCATE(RX, RY);
        PRINT(!("*"));
    }
}


DRAW_FRAME(WORD A)
{
    LOCATE(0, 0);
    PRINT("FIXED POINT ROTATE DEMO  A=");
    PRINT(A);
    PRINT("   ");

    DRAWP( 0, 12,  8, A);
    DRAWP( 1, 14,  8, A);
    DRAWP( 2, 16,  8, A);
    DRAWP( 3, 18,  8, A);
    DRAWP( 4, 20,  8, A);
    DRAWP( 5, 22,  8, A);
    DRAWP( 6, 24,  8, A);
    DRAWP( 7, 26,  8, A);
    DRAWP( 8, 28,  8, A);
    DRAWP( 9, 12, 16, A);
    DRAWP(10, 14, 16, A);
    DRAWP(11, 16, 16, A);
    DRAWP(12, 18, 16, A);
    DRAWP(13, 20, 16, A);
    DRAWP(14, 22, 16, A);
    DRAWP(15, 24, 16, A);
    DRAWP(16, 26, 16, A);
    DRAWP(17, 28, 16, A);
    DRAWP(18, 12, 12, A);
    DRAWP(19, 28, 12, A);
}


MAIN()
VAR A, KEY;
BEGIN
    WIDTH(40);
    ROT_PTR = &ROT_RESULT[0];
    INIT_OLD();
    PRINT("\C");

    A = 0;
    KEY = 0;
    WHILE (KEY != 27) {
        KEY = INKEY(0);
        DRAW_FRAME(A);
        DELAY(8);
        A = NORMALIZE360(A + 3);
    }

    LOCATE(0, 23);
    PRINT("DONE\n");
END;
