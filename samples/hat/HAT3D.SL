/*
 GRAPH.LIB( MAGIC ) TEST
 */

CONST  _PLOTSW=0,_THREE=0,_FLOAT=0,_SINCOS=1,_TILESW=1,_GHIN=$FFFF,_KPRINTF=0,_COLOR=1;

#INCLUDE GRAPHF.LIB

CONST DEG2RAD = 3.1415926 / 180.0;

ARRAY D[1][512];

MAIN()
VAR X,Y,L,DX,SX,SY;
VAR FLOAT R, Z;
BEGIN
    PRINT(" HAT3D START\n ")

    @INIT();

    FOR L=0 TO 512 {
        D[0][L] = 65535;
        D[1][L] = 65535;
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
            SX = DX + 80;
            SY = FTOI(((130.0 - FY/2.0 - Z)/2.0) * 0.9 + 25.0);
           
            IF D[0][DX]==65535 {
                D[0][DX]=SY;
                D[1][DX]=SY;
                PLOT_POINT(SX,SY,Z);
                CONTINUE;
            }

            IF SY < D[0][DX] {
                PLOT_POINT(SX,SY,Z);
                D[0][DX]=SY;
                CONTINUE;
            }

            IF SY > D[1][DX] {
                PLOT_POINT(SX,SY,Z);
                D[1][DX]=SY;
                CONTINUE;
            }
        }
    }
END;


PLOT_POINT(SX,SY,Z)
VAR FLOAT Z;
VAR SX,SY,C;
BEGIN
    C = FTOI((Z + 96.0) / 30.0) + 1;

    IF C<1 THEN C=1;
    IF C>7 THEN C=7;

    // @CIRCLEC(SX,SY,1,4);
    // PRINT("X,Y=");PRINT(SX);PRINT(", ");PRINT(SY);
    // PRINT(", ");PRINT(C);PRINT("\n");    
    @LINEC(SX,SY,SX,SY,C);

END;