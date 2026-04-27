#include "FIXEDPOINTLIB.SL"

ARRAY ROT_RESULT[1];
VAR ROT_PTR[];

TEST_ATAN2(Y, X)
VAR A1, A2;
{
    A1 = ATAN2_I(Y, X);
    A2 = ATAN2_I_FAST(Y, X);

    PRINT("ATAN2 Y=");
    PRINTS(Y);
    PRINT(" X=");
    PRINTS(X);
    PRINT(" OLD=");
    PRINT(A1);
    PRINT(" FAST=");
    PRINT(A2);
    PRINT(" DIFF=");
    PRINTS(A2 - A1);
    PRINT("\n");
}


MAIN()
VAR A,X,Y,PX,PY,ANG,RX,RY;
BEGIN
    PRINT("=== FIXED TRIG TEST ===\n");

    A = 30;
    PRINT("SIN_F(30)=");
    PRINTFIX(SIN_F(A));
    PRINT("\n");

    PRINT("COS_F(30)=");
    PRINTFIX(COS_F(A));
    PRINT("\n");

    PRINT("TAN_F(45)=");
    PRINTFIX(TAN_F(45));
    PRINT("\n");

    X = 10;
    Y = 5;
    TEST_ATAN2(Y, X);
    TEST_ATAN2(10, 5);
    TEST_ATAN2(5, -10);
    TEST_ATAN2(-5, -10);
    TEST_ATAN2(-5, 10);
    TEST_ATAN2(0, -10);
    TEST_ATAN2(-10, 0);

    PX = 100;
    PY = 50;
    ANG = 30;

    RX = ROTATE_X(PX, PY, ANG);
    RY = ROTATE_Y(PX, PY, ANG);

    PRINT("ROTATE_X=");
    PRINTS(RX);
    PRINT(" ROTATE_Y=");
    PRINTS(RY);
    PRINT("\n");

    ROT_PTR = &ROT_RESULT[0];
    ROTATE_CENTER(ROT_PTR, 120, 50, 100, 50, 90);
    PRINT("ROTATE_CENTER X=");
    PRINTS(ROT_RESULT[0]);
    PRINT(" Y=");
    PRINTS(ROT_RESULT[1]);
    PRINT("\n");
END;
