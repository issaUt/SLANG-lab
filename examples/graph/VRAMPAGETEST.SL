#include "../../lib/iocs/MZ25IOCS_SVC.LIB"
#include "../../lib/MZ25VRAM_GFX.LIB"

VAR BYTE TILE_P0[32] = {
    $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,    // B/plane0
    $00,$00,$00,$00,$00,$00,$00,$00,    // R/plane1
    $00,$00,$00,$00,$00,$00,$00,$00,    // G/plane2
    $00,$00,$00,$00,$00,$00,$00,$00     // I/plane3
};

VAR BYTE TILE_P1[32] = {
    $00,$00,$00,$00,$00,$00,$00,$00,    // B/plane0
    $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,    // R/plane1
    $00,$00,$00,$00,$00,$00,$00,$00,    // G/plane2
    $00,$00,$00,$00,$00,$00,$00,$00     // I/plane3
};

VAR BYTE TILE_P2[32] = {
    $00,$00,$00,$00,$00,$00,$00,$00,    // B/plane0
    $00,$00,$00,$00,$00,$00,$00,$00,    // R/plane1
    $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,    // G/plane2
    $00,$00,$00,$00,$00,$00,$00,$00     // I/plane3
};

VAR BYTE TILE_P3[32] = {
    $00,$00,$00,$00,$00,$00,$00,$00,    // B/plane0
    $00,$00,$00,$00,$00,$00,$00,$00,    // R/plane1
    $00,$00,$00,$00,$00,$00,$00,$00,    // G/plane2
    $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF     // I/plane3
};

DRAW_PLANE_TILES(BYTE PAGE, BYTE XBYTE, BYTE Y)
{
    MZ25_VRAM_PUT_TILE8(PAGE, XBYTE,     Y, &TILE_P0);
    MZ25_VRAM_PUT_TILE8(PAGE, XBYTE + 3, Y, &TILE_P1);
    MZ25_VRAM_PUT_TILE8(PAGE, XBYTE + 6, Y, &TILE_P2);
    MZ25_VRAM_PUT_TILE8(PAGE, XBYTE + 9, Y, &TILE_P3);
}

MAIN()
VAR KEY;
{
    IOCS_INITSCREEN();
    IOCS_GINIT(320,200,16);
    IOCS_VIEW(0,0,319,199);

    IOCS_SCREEN_INPUT_PAGE(0);
    IOCS_CLS(0);
    IOCS_SCREEN_INPUT_PAGE(1);
    IOCS_CLS(0);
    IOCS_SCREEN_INPUT_PAGE(2);
    IOCS_CLS(0);
    IOCS_SCREEN_INPUT_PAGE(3);
    IOCS_CLS(0);

    DRAW_PLANE_TILES(0, 5, 40);
    DRAW_PLANE_TILES(1, 5, 70);
    DRAW_PLANE_TILES(2, 5, 100);
    DRAW_PLANE_TILES(3, 5, 130);

    IOCS_SCREEN320_GROUP(0,0);
    PRINT("VRAM PAGE TEST",/);
    PRINT("1:GROUP0 2:GROUP1 ESC:EXIT",/);

    KEY = 0;
    WHILE (KEY != 27) {
        KEY = INKEY(0);
        IF (KEY == '1') {
            IOCS_SCREEN320_GROUP(0,0);
        }
        IF (KEY == '2') {
            IOCS_SCREEN320_GROUP(2,1);
        }

        IF (KEY == '4') {
            IOCS_SCREEN_OUTPUT_PAGE320(0);
        }
        IF (KEY == '5') {
            IOCS_SCREEN_OUTPUT_PAGE320(1);
        }
        IF (KEY == '6') {
            IOCS_SCREEN_OUTPUT_PAGE320(2);
        }
        IF (KEY == '7') {
            IOCS_SCREEN_OUTPUT_PAGE320(3);
        }

    }
}
