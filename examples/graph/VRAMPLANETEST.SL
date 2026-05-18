#include "../../lib/iocs/MZ25IOCS_SVC.LIB"
#include "../../lib/MZ25VRAM_GFX.LIB"

VAR BYTE TILE_P0[32] = {
    $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,    // plane0
    $00,$00,$00,$00,$00,$00,$00,$00,    // plane1
    $00,$00,$00,$00,$00,$00,$00,$00,    // plane2
    $00,$00,$00,$00,$00,$00,$00,$00     // plane3
};

VAR BYTE TILE_P1[32] = {
    $00,$00,$00,$00,$00,$00,$00,$00,    // plane0
    $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,    // plane1
    $00,$00,$00,$00,$00,$00,$00,$00,    // plane2
    $00,$00,$00,$00,$00,$00,$00,$00     // plane3
};

VAR BYTE TILE_P2[32] = {
    $00,$00,$00,$00,$00,$00,$00,$00,    // plane0
    $00,$00,$00,$00,$00,$00,$00,$00,    // plane1
    $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,    // plane2
    $00,$00,$00,$00,$00,$00,$00,$00     // plane3
};

VAR BYTE TILE_P3[32] = {
    $00,$00,$00,$00,$00,$00,$00,$00,    // plane0
    $00,$00,$00,$00,$00,$00,$00,$00,    // plane1
    $00,$00,$00,$00,$00,$00,$00,$00,    // plane2
    $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF     // plane3
};

MAIN()
{
    IOCS_INITSCREEN();
    IOCS_GINIT(320,200,16);
    IOCS_VIEW(0,0,319,199);
    IOCS_SCREEN_INPUT_PAGE(0);
    IOCS_CLS(0);
    IOCS_SCREEN320_GROUP(0,0);

    PRINT("VRAM PLANE TEST",/);
    PRINT("P0 P1 P2 P3",/);

    MZ25_VRAM_PUT_TILE8(0, 5, 40, &TILE_P0);
    MZ25_VRAM_PUT_TILE8(0, 8, 40, &TILE_P1);
    MZ25_VRAM_PUT_TILE8(0, 11, 40, &TILE_P2);
    MZ25_VRAM_PUT_TILE8(0, 14, 40, &TILE_P3);

    WHILE (INKEY(0) != 27) {
    }
}
