#include "../../lib/iocs/MZ25IOCS_SVC.LIB"
#include "../../lib/MZ25VRAM_TFX.LIB"
#include "../../lib/MZ25VRAM_GFX.LIB"

// 写真の市街地マップをPCGタイルで簡略化したデモ。
// 背景はTEXT/PCGページ1、車はGRAPHICページ0へ重ねて描画する。

// PCGDATA.SLから取り込んだ地図/車データ。
// $41-$44: 16x16車の元PCG(表示上は左右が逆になるため組み替え)
// $45: 建物ブロック, $46: 道路ブロック

VAR BYTE TILE_ROAD[24] = {
    $EE,$55,$AA,$77,$AA,$55,$BB,$55,
    $AA,$55,$AA,$55,$AA,$55,$AA,$55,
    $EE,$55,$AA,$77,$AA,$55,$BB,$55
};

VAR BYTE TILE_BUILDING[24] = {
    $C0,$FD,$41,$41,$41,$41,$01,$7F,
    $C0,$80,$00,$00,$00,$00,$00,$00,
    $FE,$82,$82,$82,$82,$82,$FE,$00
};

VAR BYTE TILE_BUILDING2[24] = {
    $C0,$FD,$41,$41,$41,$41,$01,$7F,
    $C0,$80,$00,$00,$00,$00,$00,$00,
    $FE,$82,$82,$82,$82,$82,$FE,$00
};

VAR BYTE TILE_PARK[24] = {
    $00,$00,$00,$00,$00,$00,$00,$00,    // B plane
    $00,$00,$00,$00,$00,$00,$00,$00,    // R plane
    $18,$3C,$7E,$18,$18,$7E,$3C,$18     // G plane
};

VAR BYTE TILE_BORDER[24] = {
    $FF,$81,$81,$81,$81,$81,$81,$FF,    // B plane
    $FF,$81,$81,$81,$81,$81,$81,$FF,    // R plane
    $FF,$81,$81,$81,$81,$81,$81,$FF     // G plane
};

VAR BYTE TILE_FLAG[24] = {
    $18,$18,$18,$18,$18,$18,$18,$18,    // B plane
    $7E,$42,$42,$7E,$18,$18,$18,$18,    // R plane
    $7E,$42,$42,$7E,$18,$18,$18,$18     // G plane
};

VAR BYTE TILE_BLANK[24] = {
    $00,$00,$00,$00,$00,$00,$00,$00,    // B plane
    $00,$00,$00,$00,$00,$00,$00,$00,    // R plane
    $00,$00,$00,$00,$00,$00,$00,$00     // G plane
};

VAR BYTE CAR_UP[128] = {
    $00,$00,$80,$01,$C0,$03,$DC,$3B,$FC,$3F,$DC,$3B,$C0,$03,$C0,$03,
    $E0,$07,$EE,$77,$FE,$7F,$FE,$7F,$7E,$7E,$6E,$76,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$10,$20,$00,$20,$00,$00,$00,$00,$80,$01,
    $80,$01,$88,$41,$88,$41,$08,$40,$80,$01,$00,$00,$60,$06,$00,$00,
    $00,$00,$00,$00,$00,$00,$1C,$38,$1C,$38,$1C,$38,$00,$00,$80,$01,
    $80,$01,$8E,$71,$8E,$71,$0E,$70,$0E,$70,$0E,$70,$00,$00,$00,$00,
    $00,$00,$80,$01,$C0,$03,$DC,$3B,$FC,$3F,$DC,$3B,$C0,$03,$C0,$03,
    $E0,$07,$EE,$77,$FE,$7F,$FE,$7F,$FE,$7F,$6E,$76,$60,$06,$00,$00
};

VAR BYTE CAR_UP_MASK[32] = {
    $FF,$FF,$7F,$FE,$3F,$FC,$23,$C4,$03,$C0,$23,$C4,$3F,$FC,$3F,$FC,
    $1F,$F8,$11,$88,$01,$80,$01,$80,$01,$80,$91,$89,$9F,$F9,$FF,$FF
};

VAR BYTE CAR_RIGHT[128] = {
    $00,$00,$7C,$00,$7C,$1C,$7C,$1C,$38,$1C,$FC,$08,$FC,$3F,$F0,$7F,
    $F0,$7F,$FC,$3F,$FC,$08,$38,$1C,$7C,$1C,$7C,$1C,$7C,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$70,$00,$00,$10,$02,$00,$02,$00,$E8,$01,
    $E8,$01,$02,$00,$02,$00,$00,$00,$00,$00,$00,$18,$70,$00,$00,$00,
    $00,$00,$7C,$00,$7C,$1C,$7C,$1C,$00,$1C,$00,$00,$00,$00,$E0,$01,
    $E0,$01,$00,$00,$00,$00,$00,$1C,$7C,$1C,$7C,$1C,$7C,$00,$00,$00,
    $00,$00,$7C,$00,$7C,$1C,$7C,$1C,$38,$1C,$FE,$08,$FE,$3F,$F8,$7F,
    $F8,$7F,$FE,$3F,$FE,$08,$38,$1C,$7C,$1C,$7C,$1C,$7C,$00,$00,$00
};

VAR BYTE CAR_RIGHT_MASK[32] = {
    $FF,$FF,$83,$FF,$83,$E3,$83,$E3,$C7,$E3,$01,$F7,$01,$C0,$07,$80,
    $07,$80,$01,$C0,$01,$F7,$C7,$E3,$83,$E3,$83,$E3,$83,$FF,$FF,$FF
};

VAR BYTE CAR_DOWN[128] = {
    $00,$00,$00,$00,$6E,$76,$7E,$7E,$FE,$7F,$FE,$7F,$EE,$77,$E0,$07,
    $C0,$03,$C0,$03,$DC,$3B,$FC,$3F,$DC,$3B,$C0,$03,$80,$01,$00,$00,
    $00,$00,$60,$06,$00,$00,$80,$01,$02,$10,$82,$11,$82,$11,$80,$01,
    $80,$01,$00,$00,$00,$00,$04,$00,$04,$08,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$0E,$70,$0E,$70,$0E,$70,$8E,$71,$8E,$71,$80,$01,
    $80,$01,$00,$00,$1C,$38,$1C,$38,$1C,$38,$00,$00,$00,$00,$00,$00,
    $00,$00,$60,$06,$6E,$76,$FE,$7F,$FE,$7F,$FE,$7F,$EE,$77,$E0,$07,
    $C0,$03,$C0,$03,$DC,$3B,$FC,$3F,$DC,$3B,$C0,$03,$80,$01,$00,$00
};

VAR BYTE CAR_DOWN_MASK[32] = {
    $FF,$FF,$9F,$F9,$91,$89,$01,$80,$01,$80,$01,$80,$11,$88,$1F,$F8,
    $3F,$FC,$3F,$FC,$23,$C4,$03,$C0,$23,$C4,$3F,$FC,$7F,$FE,$FF,$FF
};

VAR BYTE CAR_LEFT[128] = {
    $00,$00,$00,$3E,$38,$3E,$38,$3E,$38,$1C,$10,$3F,$FC,$3F,$FE,$0F,
    $FE,$0F,$FC,$3F,$10,$3F,$38,$1C,$38,$3E,$38,$3E,$00,$3E,$00,$00,
    $00,$00,$00,$0E,$18,$00,$00,$00,$00,$00,$00,$40,$00,$40,$80,$17,
    $80,$17,$00,$40,$00,$40,$08,$00,$00,$0E,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$3E,$38,$3E,$38,$3E,$38,$00,$00,$00,$00,$00,$80,$07,
    $80,$07,$00,$00,$00,$00,$38,$00,$38,$3E,$38,$3E,$00,$3E,$00,$00,
    $00,$00,$00,$3E,$38,$3E,$38,$3E,$38,$1C,$10,$7F,$FC,$7F,$FE,$1F,
    $FE,$1F,$FC,$7F,$10,$7F,$38,$1C,$38,$3E,$38,$3E,$00,$3E,$00,$00
};

VAR BYTE CAR_LEFT_MASK[32] = {
    $FF,$FF,$FF,$C1,$C7,$C1,$C7,$C1,$C7,$E3,$EF,$80,$03,$80,$01,$E0,
    $01,$E0,$03,$80,$EF,$80,$C7,$E3,$C7,$C1,$C7,$C1,$FF,$C1,$FF,$FF
};

VAR BYTE CAMX, CAMY, CAR_DIR;

INIT_PCG()
{
    MZ25_PCG_SET8_DATA($40, TILE_ROAD);
    MZ25_PCG_SET8_DATA($41, TILE_BUILDING);
    MZ25_PCG_SET8_DATA($42, TILE_BUILDING2);
    MZ25_PCG_SET8_DATA($43, TILE_PARK);
    MZ25_PCG_SET8_DATA($44, TILE_BORDER);
    MZ25_PCG_SET8_DATA($45, TILE_FLAG);
}

IS_VROAD(WORD X)
{
    IF (X == 4)  { RETURN 1; }
    IF (X == 5)  { RETURN 1; }
    IF (X == 14) { RETURN 1; }
    IF (X == 15) { RETURN 1; }
    IF (X == 24) { RETURN 1; }
    IF (X == 25) { RETURN 1; }
    IF (X == 36) { RETURN 1; }
    IF (X == 37) { RETURN 1; }
    IF (X == 50) { RETURN 1; }
    IF (X == 51) { RETURN 1; }
    IF (X == 63) { RETURN 1; }
    IF (X == 64) { RETURN 1; }
    IF (X == 76) { RETURN 1; }
    IF (X == 77) { RETURN 1; }
    RETURN 0;
}

IS_HROAD(WORD Y)
{
    IF (Y == 4)  { RETURN 1; }
    IF (Y == 5)  { RETURN 1; }
    IF (Y == 13) { RETURN 1; }
    IF (Y == 14) { RETURN 1; }
    IF (Y == 22) { RETURN 1; }
    IF (Y == 23) { RETURN 1; }
    IF (Y == 33) { RETURN 1; }
    IF (Y == 34) { RETURN 1; }
    IF (Y == 45) { RETURN 1; }
    IF (Y == 46) { RETURN 1; }
    IF (Y == 55) { RETURN 1; }
    IF (Y == 56) { RETURN 1; }
    RETURN 0;
}

GET_CITY_TILE(WORD X, WORD Y)
VAR BYTE T;
{
    IF (X == 0)  { RETURN $44; }
    IF (Y == 0)  { RETURN $44; }
    IF (X == 95) { RETURN $44; }
    IF (Y == 63) { RETURN $44; }

    IF (IS_VROAD(X) != 0) { RETURN $40; }
    IF (IS_HROAD(Y) != 0) { RETURN $40; }

    // 一部だけ公園/目印を混ぜ、写真の市街地図らしい変化を付ける。
    IF (X > 8) {
        IF (X < 13) {
            IF (Y > 37) {
                IF (Y < 43) { RETURN $43; }
            }
        }
    }
    IF (X == 30) {
        IF (Y == 18) { RETURN $45; }
    }
    IF (X == 57) {
        IF (Y == 29) { RETURN $45; }
    }
    IF (X == 82) {
        IF (Y == 8) { RETURN $45; }
    }

    T = X + Y;
    IF ((T AND 3) == 0) { RETURN $42; }
    RETURN $41;
}

DRAW_CITY_MAP()
VAR BYTE X,Y,T;
VAR WX,WY;
{
    FOR Y = 0 TO 22 {
        WY = CAMY + Y;
        FOR X = 0 TO 29 {
            WX = CAMX + X;
            T = GET_CITY_TILE(WX, WY);
            MZ25_TEXT_PUT40(1, X, Y + 2, T, $1F);
        }
    }
}

DRAW_STATUS()
{
    MZ25_TEXT_CLEAR_RECT40(0, 0, 0, 40, 2, ' ', $07);
    MZ25_TEXT_PRINT40(0, 0, 0, "2/4/6/8:MOVE  ESC:EXIT", $07);
    MZ25_TEXT_PRINT40(0, 0, 1, "MAP PAGE1 30X23 LEFT ALIGN", $07);
}

ERASE_CAR()
{
    // 中央の車だけをグラフィックVRAMから消す。背景PCGは別ページなので消えない。
    MZ25_VRAM_CLEAR_RECT(0, 13, 96, 5, 32);
}

DRAW_CAR()
{
    IF (CAR_DIR == 0) {
        MZ25_VRAM_MASK_PATTERN16(0, 14, 104, &CAR_UP, &CAR_UP_MASK);
    }
    IF (CAR_DIR == 1) {
        MZ25_VRAM_MASK_PATTERN16(0, 14, 104, &CAR_RIGHT, &CAR_RIGHT_MASK);
    }
    IF (CAR_DIR == 2) {
        MZ25_VRAM_MASK_PATTERN16(0, 14, 104, &CAR_DOWN, &CAR_DOWN_MASK);
    }
    IF (CAR_DIR == 3) {
        MZ25_VRAM_MASK_PATTERN16(0, 14, 104, &CAR_LEFT, &CAR_LEFT_MASK);
    }
}

FILL_RIGHT_EDGE()
VAR BYTE Y,T;
VAR WX,WY;
{
    WX = CAMX + 29;
    FOR Y = 0 TO 22 {
        WY = CAMY + Y;
        T = GET_CITY_TILE(WX, WY);
        MZ25_TEXT_PUT40(1, 29, Y + 2, T, $1F);
    }
}

FILL_LEFT_EDGE()
VAR BYTE Y,T;
VAR WX,WY;
{
    WX = CAMX;
    FOR Y = 0 TO 22 {
        WY = CAMY + Y;
        T = GET_CITY_TILE(WX, WY);
        MZ25_TEXT_PUT40(1, 0, Y + 2, T, $1F);
    }
}

FILL_BOTTOM_EDGE()
VAR BYTE X,T;
VAR WX,WY;
{
    WY = CAMY + 22;
    FOR X = 0 TO 29 {
        WX = CAMX + X;
        T = GET_CITY_TILE(WX, WY);
        MZ25_TEXT_PUT40(1, X, 24, T, $1F);
    }
}

FILL_TOP_EDGE()
VAR BYTE X,T;
VAR WX,WY;
{
    WY = CAMY;
    FOR X = 0 TO 29 {
        WX = CAMX + X;
        T = GET_CITY_TILE(WX, WY);
        MZ25_TEXT_PUT40(1, X, 2, T, $1F);
    }
}

MOVE_MAP(BYTE DIR)
{
    IF (DIR == 0) {
        IF (CAMY > 0) {
            CAMY = CAMY - 1;
            MZ25_TEXT_SCROLL_DOWN40_FAST_NOATTR(1, 0, 2, 30, 23, $40);
            FILL_TOP_EDGE();
        }
        CAR_DIR = 0;
    }
    IF (DIR == 1) {
        IF (CAMX < 66) {
            CAMX = CAMX + 1;
            MZ25_TEXT_SCROLL_LEFT40_FAST_NOATTR(1, 0, 2, 30, 23, $40);
            FILL_RIGHT_EDGE();
        }
        CAR_DIR = 1;
    }
    IF (DIR == 2) {
        IF (CAMY < 41) {
            CAMY = CAMY + 1;
            MZ25_TEXT_SCROLL_UP40_FAST_NOATTR(1, 0, 2, 30, 23, $40);
            FILL_BOTTOM_EDGE();
        }
        CAR_DIR = 2;
    }
    IF (DIR == 3) {
        IF (CAMX > 0) {
            CAMX = CAMX - 1;
            MZ25_TEXT_SCROLL_RIGHT40_FAST_NOATTR(1, 0, 2, 30, 23, $40);
            FILL_LEFT_EDGE();
        }
        CAR_DIR = 3;
    }

    ERASE_CAR();
    DRAW_CAR();
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
    IOCS_SCREEN320_GROUP(0,0);

    IOCS_TINIT(0, 1);
    IOCS_TMOD(1, 0);
    IOCS_TWID(1);
    IOCS_TCLR();
    IOCS_TSCREEN(0,0);
    IOCS_PRIORITY($FFFE);

    INIT_PCG();
    MZ25_TEXT_CLEAR40(0, ' ', $07);
    MZ25_TEXT_CLEAR40(1, ' ', $1F);

    CAMX = 20;
    CAMY = 20;
    CAR_DIR = 0;

    DRAW_STATUS();
    IOCS_TSCREEN(1,2);
    DRAW_CITY_MAP();
    DRAW_CAR();

    KEY = 0;
    WHILE (KEY != 27) {
        KEY = INKEY(0);
        IF (KEY == '8') { MOVE_MAP(0); }
        IF (KEY == '6') { MOVE_MAP(1); }
        IF (KEY == '2') { MOVE_MAP(2); }
        IF (KEY == '4') { MOVE_MAP(3); }
    }
    IOCS_TSCREEN(0,0);
}
