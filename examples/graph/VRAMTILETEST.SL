#include "../../lib/iocs/MZ25IOCS_SVC.LIB"
#include "../../lib/MZ25VRAM_GFX.LIB"

VAR BYTE TILE_SOLID[32] = {
    $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,
    $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,
    $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,
    $00,$00,$00,$00,$00,$00,$00,$00
};

VAR BYTE TILE_CHECK[32] = {
    $AA,$55,$AA,$55,$AA,$55,$AA,$55,
    $55,$AA,$55,$AA,$55,$AA,$55,$AA,
    $00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00
};

VAR BYTE TILE_DIAG[32] = {
    $80,$40,$20,$10,$08,$04,$02,$01,
    $01,$02,$04,$08,$10,$20,$40,$80,
    $81,$42,$24,$18,$18,$24,$42,$81,
    $00,$00,$00,$00,$00,$00,$00,$00
};

VAR BYTE TILE_FRAME[32] = {
    $FF,$81,$81,$81,$81,$81,$81,$FF,
    $00,$7E,$42,$42,$42,$42,$7E,$00,
    $00,$00,$3C,$24,$24,$3C,$00,$00,
    $00,$00,$00,$18,$18,$00,$00,$00
};

MAIN()
VAR X, Y, KEY;
{
    IOCS_INITSCREEN();
    IOCS_GINIT(320,200,16);
    IOCS_VIEW(0,0,319,199);
    IOCS_SCREEN_INPUT_PAGE(0);
    IOCS_CLS(0);
    IOCS_SCREEN320(0,0);

    PRINT("VRAM TILE TEST",/);
    PRINT("ESC:EXIT",/);

    FOR Y = 0 TO 7 {
        FOR X = 0 TO 15 {
            IF ((X + Y) MOD 4 == 0) {
                MZ25_VRAM_PUT_TILE8(0, X + 4, Y * 8 + 32, &TILE_SOLID);
            }
            IF ((X + Y) MOD 4 == 1) {
                MZ25_VRAM_PUT_TILE8(0, X + 4, Y * 8 + 32, &TILE_CHECK);
            }
            IF ((X + Y) MOD 4 == 2) {
                MZ25_VRAM_PUT_TILE8(0, X + 4, Y * 8 + 32, &TILE_DIAG);
            }
            IF ((X + Y) MOD 4 == 3) {
                MZ25_VRAM_PUT_TILE8(0, X + 4, Y * 8 + 32, &TILE_FRAME);
            }
        }
    }

    KEY = 0;
    WHILE (KEY != 27) {
        KEY = INKEY(0);
    }
}