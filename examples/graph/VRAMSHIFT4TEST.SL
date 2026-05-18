#include "../../lib/iocs/MZ25IOCS_SVC.LIB"
#include "../../lib/MZ25VRAM_GFX.LIB"

// 4dotシフト確認用。左右非対称の縦線・斜線・マーカーだけで構成する。
// plane0=B, plane1=R, plane2=G, plane3=I。
VAR BYTE TILE_LEFT_MARK[32] = {
    $F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,
    $80,$80,$80,$80,$80,$80,$80,$80,
    $80,$C0,$E0,$F0,$F8,$FC,$FE,$FF,
    $00,$00,$00,$00,$00,$00,$00,$00
};

VAR BYTE TILE_CENTER_LINE[32] = {
    $18,$18,$18,$18,$18,$18,$18,$18,
    $00,$18,$00,$18,$00,$18,$00,$18,
    $00,$00,$18,$18,$18,$18,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00
};

VAR BYTE TILE_RIGHT_MARK[32] = {
    $0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,
    $01,$01,$01,$01,$01,$01,$01,$01,
    $FF,$7F,$3F,$1F,$0F,$07,$03,$01,
    $00,$00,$00,$00,$00,$00,$00,$00
};

VAR BYTE TILE_SLASH[32] = {
    $80,$40,$20,$10,$08,$04,$02,$01,
    $00,$00,$00,$00,$00,$00,$00,$00,
    $01,$02,$04,$08,$10,$20,$40,$80,
    $00,$00,$00,$00,$00,$00,$00,$00
};

VAR BYTE TILE_EMPTY[32] = {
    $00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00
};

PUT_TEST_TILE(BYTE PAGE, BYTE XBYTE, BYTE Y, BYTE T)
{
    IF (T == 0) {
        MZ25_VRAM_PUT_TILE8(PAGE, XBYTE, Y, &TILE_EMPTY);
    }
    IF (T == 1) {
        MZ25_VRAM_PUT_TILE8(PAGE, XBYTE, Y, &TILE_LEFT_MARK);
    }
    IF (T == 2) {
        MZ25_VRAM_PUT_TILE8(PAGE, XBYTE, Y, &TILE_CENTER_LINE);
    }
    IF (T == 3) {
        MZ25_VRAM_PUT_TILE8(PAGE, XBYTE, Y, &TILE_RIGHT_MARK);
    }
    IF (T == 4) {
        MZ25_VRAM_PUT_TILE8(PAGE, XBYTE, Y, &TILE_SLASH);
    }
}

DRAW_TEST_PATTERN(BYTE PAGE)
VAR X,Y,T;
{
    FOR Y = 0 TO 11 {
        FOR X = 0 TO 23 {
            T = 0;
            IF (X == 0) { T = 1; }
            IF (X == 23) { T = 3; }
            IF (X == 4) { T = 2; }
            IF (X == 8) { T = 2; }
            IF (X == 12) { T = 2; }
            IF (X == 16) { T = 2; }
            IF (X == 20) { T = 2; }
            IF ((X + Y) MOD 7 == 0) { T = 4; }
            PUT_TEST_TILE(PAGE, X + 8, Y * 8 + 40, T);
        }
    }
}

MAIN()
VAR KEY;
{
    IOCS_INITSCREEN();
    IOCS_GINIT(320,200,16);
    IOCS_VIEW(0,0,319,199);
    IOCS_SCREEN_INPUT_PAGE(0);
    IOCS_CLS(0);
    IOCS_SCREEN320(0,0);

    PRINT("VRAM SHIFT4 MARKER TEST",/);
    PRINT("4:RIGHT  6:LEFT  0:RESET  ESC:EXIT",/);

    DRAW_TEST_PATTERN(0);

    KEY = 0;
    WHILE (KEY != 27) {
        KEY = INKEY(0);
        IF (KEY == '0') {
            IOCS_SCREEN_INPUT_PAGE(0);
            IOCS_CLS(0);
            DRAW_TEST_PATTERN(0);
        }
        IF (KEY == '4') {
            MZ25_VRAM_SHIFT_RECT_RIGHT4(0, 8, 40, 24, 96);
        }
        IF (KEY == '6') {
            MZ25_VRAM_SHIFT_RECT_LEFT4(0, 8, 40, 24, 96);
        }
    }
}