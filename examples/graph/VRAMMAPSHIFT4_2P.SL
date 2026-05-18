#include "../../lib/iocs/MZ25IOCS_SVC.LIB"
#include "../../lib/MZ25VRAM_GFX.LIB"

// 2プレーン版は BRGI の先頭2プレーン、つまり B/R のみを描画する高速版。
// G/I プレーンを使う色は省略されるため、色味は4プレーン版と完全には一致しない。

VAR BYTE TILE_GRASS[16] = {
    $55,$22,$55,$22,$55,$22,$55,$22,    // B plane
    $00,$00,$00,$00,$00,$00,$00,$00     // R plane
};

VAR BYTE TILE_WATER[16] = {
    $18,$24,$42,$81,$18,$24,$42,$81,    // B plane
    $00,$00,$00,$00,$00,$00,$00,$00     // R plane
};

VAR BYTE TILE_WALL[16] = {
    $FF,$81,$81,$FF,$FF,$81,$81,$FF,    // B plane
    $00,$7E,$42,$00,$00,$7E,$42,$00     // R plane
};

VAR BYTE TILE_ROAD[16] = {
    $00,$18,$18,$00,$00,$18,$18,$00,    // B plane
    $00,$18,$18,$00,$00,$18,$18,$00     // R plane
};

VAR BYTE TILE_GOAL[16] = {
    $81,$42,$24,$18,$18,$24,$42,$81,    // B plane
    $18,$24,$42,$81,$81,$42,$24,$18     // R plane
};

VAR BYTE MAP_DATA[768] = {
    2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,
    2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,
    2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,
    2,0,0,4,0,0,2,0,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,2,0,0,0,4,0,2,
    2,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,2,0,0,0,0,0,2,
    2,0,0,3,3,3,2,3,3,3,3,3,3,3,3,3,3,3,2,3,3,3,3,3,3,2,3,3,3,0,0,2,
    2,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,2,0,0,0,0,0,2,
    2,0,0,0,0,0,2,0,0,1,1,1,1,1,1,0,0,0,2,0,0,0,0,0,0,2,0,0,0,0,0,2,
    2,0,0,0,0,0,2,0,0,1,1,1,1,1,1,0,0,0,2,0,0,0,0,0,0,2,0,0,0,0,0,2,
    2,0,0,0,0,0,2,0,0,1,1,1,1,1,1,0,0,0,2,0,0,0,0,0,0,2,0,0,0,0,0,2,
    2,0,0,0,0,0,2,0,0,1,1,1,1,1,1,0,0,0,2,0,0,0,0,0,0,2,0,0,0,0,0,2,
    2,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,2,0,0,0,0,0,2,
    2,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,2,0,0,0,0,0,2,
    2,0,0,3,3,3,2,3,3,3,3,3,3,3,3,3,3,3,2,3,3,3,3,3,3,2,3,3,3,0,0,2,
    2,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,2,0,0,0,0,0,2,
    2,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,2,0,1,1,1,1,1,2,1,1,0,0,0,2,
    2,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,2,0,1,1,1,1,1,2,1,1,0,0,0,2,
    2,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,2,0,1,1,1,1,1,2,1,1,0,0,0,2,
    2,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,2,0,1,1,1,1,1,2,1,1,0,0,0,2,
    2,0,0,3,3,3,2,3,3,3,3,3,3,3,3,3,3,3,2,3,3,3,3,3,3,2,3,3,3,0,0,2,
    2,0,0,4,0,0,2,0,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,2,0,0,0,4,0,2,
    2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,
    2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,
    2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
};

VAR WORD TILE_TABLE[10];
VAR WORD DRAW_PARAM[11];

INIT_TILE_TABLE()
{
    TILE_TABLE[0] = &TILE_GRASS;
    TILE_TABLE[1] = &TILE_WATER;
    TILE_TABLE[2] = &TILE_WALL;
    TILE_TABLE[3] = &TILE_ROAD;
    TILE_TABLE[4] = &TILE_GOAL;

    TILE_TABLE[5] = &TILE_GRASS + 8;
    TILE_TABLE[6] = &TILE_WATER + 8;
    TILE_TABLE[7] = &TILE_WALL + 8;
    TILE_TABLE[8] = &TILE_ROAD + 8;
    TILE_TABLE[9] = &TILE_GOAL + 8;
}

SET_DRAW_VIEW(BYTE VIEW_X, BYTE VIEW_Y)
{
    DRAW_PARAM[5] = VIEW_X;
    DRAW_PARAM[6] = VIEW_Y;
}

DRAW_MAP_VIEW_FAST(BYTE VIEW_X, BYTE VIEW_Y)
{
    DRAW_PARAM[0] = &MAP_DATA;
    DRAW_PARAM[1] = &TILE_TABLE;
    DRAW_PARAM[2] = 0;
    DRAW_PARAM[3] = 10;
    DRAW_PARAM[4] = 40;
    DRAW_PARAM[5] = VIEW_X;
    DRAW_PARAM[6] = VIEW_Y;
    DRAW_PARAM[7] = 32;
    DRAW_PARAM[8] = 20;
    DRAW_PARAM[9] = 12;
    DRAW_PARAM[10] = 5;
    MZ25_VRAM_DRAW_TILEMAP8_2P_PARAM(&DRAW_PARAM);
}
MAIN()
VAR KEY, VIEW_X, VIEW_Y, HALF, OLD_HALF, HALF_Y, OLD_HALF_Y;
{
    IOCS_INITSCREEN();
    IOCS_GINIT(320,200,16);
    IOCS_VIEW(0,0,319,199);
    IOCS_SCREEN_INPUT_PAGE(0);
    IOCS_CLS(0);
    IOCS_SCREEN320(0,0);

    PRINT("VRAM MAP SHIFT4 2P",/);
    PRINT("2/4/6/8:MOVE 0:RESET ESC:EXIT",/);

    VIEW_X = 0;
    VIEW_Y = 0;
    HALF = 0;
    HALF_Y = 0;
    KEY = 0;

    INIT_TILE_TABLE();
    DRAW_MAP_VIEW_FAST(VIEW_X, VIEW_Y);

    WHILE (KEY != 27) {
        KEY = INKEY(0);
        IF (KEY == '0') {
            VIEW_X = 0;
            VIEW_Y = 0;
            HALF = 0;
            HALF_Y = 0;
            IOCS_CLS(0);
            PRINT("VRAM MAP SHIFT4 2P",/);
            PRINT("2/4/6/8:MOVE 0:RESET ESC:EXIT",/);
            DRAW_MAP_VIEW_FAST(VIEW_X, VIEW_Y);
        }
        IF (KEY == '6') {
            IF (VIEW_X < 12) {
                OLD_HALF = HALF;
                MZ25_VRAM_SHIFT_RECT_RIGHT4_2P(0, 10, 40, 20, 96);
                IF (OLD_HALF == 0) {
                    IF (HALF_Y == 0) {
                        MZ25_VRAM_DRAW_MAP_HALF_COL_2P_PARAM(&DRAW_PARAM, VIEW_X + 20, 19, 1);
                    }
                    IF (HALF_Y != 0) {
                        MZ25_VRAM_DRAW_MAP_HALF_COL_YSHIFT_2P_PARAM(&DRAW_PARAM, VIEW_X + 20, 19, 1);
                    }
                    HALF = 1;
                }
                IF (OLD_HALF == 1) {
                    VIEW_X = VIEW_X + 1;
                    SET_DRAW_VIEW(VIEW_X, VIEW_Y);
                    IF (HALF_Y == 0) {
                        MZ25_VRAM_DRAW_MAP_HALF_COL_2P_PARAM(&DRAW_PARAM, VIEW_X + 19, 19, 3);
                    }
                    IF (HALF_Y != 0) {
                        MZ25_VRAM_DRAW_MAP_HALF_COL_YSHIFT_2P_PARAM(&DRAW_PARAM, VIEW_X + 19, 19, 3);
                    }
                    HALF = 0;
                }
            }
        }
        IF (KEY == '4') {
            OLD_HALF = HALF;
            IF (OLD_HALF == 1) {
                MZ25_VRAM_SHIFT_RECT_LEFT4_2P(0, 10, 40, 20, 96);
                IF (HALF_Y == 0) {
                    MZ25_VRAM_DRAW_MAP_HALF_COL_2P_PARAM(&DRAW_PARAM, VIEW_X, 0, 0);
                }
                IF (HALF_Y != 0) {
                    MZ25_VRAM_DRAW_MAP_HALF_COL_YSHIFT_2P_PARAM(&DRAW_PARAM, VIEW_X, 0, 0);
                }
                HALF = 0;
            }
            IF (OLD_HALF == 0) {
                IF (VIEW_X > 0) {
                    VIEW_X = VIEW_X - 1;
                    SET_DRAW_VIEW(VIEW_X, VIEW_Y);
                    MZ25_VRAM_SHIFT_RECT_LEFT4_2P(0, 10, 40, 20, 96);
                    IF (HALF_Y == 0) {
                        MZ25_VRAM_DRAW_MAP_HALF_COL_2P_PARAM(&DRAW_PARAM, VIEW_X, 0, 2);
                    }
                    IF (HALF_Y != 0) {
                        MZ25_VRAM_DRAW_MAP_HALF_COL_YSHIFT_2P_PARAM(&DRAW_PARAM, VIEW_X, 0, 2);
                    }
                    HALF = 1;
                }
            }
        }
        IF (KEY == '2') {
            IF (VIEW_Y < 12) {
                OLD_HALF_Y = HALF_Y;
                MZ25_VRAM_SHIFT_RECT_UP4_2P(0, 10, 40, 20, 96);
                IF (OLD_HALF_Y == 0) {
                    IF (HALF == 0) {
                        MZ25_VRAM_DRAW_MAP_HALF_ROW_2P_PARAM(&DRAW_PARAM, VIEW_Y + 12, 92, 0);
                    }
                    IF (HALF != 0) {
                        MZ25_VRAM_DRAW_MAP_HALF_ROW_XSHIFT_2P_PARAM(&DRAW_PARAM, VIEW_Y + 12, 92, 0);
                    }
                    HALF_Y = 1;
                }
                IF (OLD_HALF_Y == 1) {
                    VIEW_Y = VIEW_Y + 1;
                    SET_DRAW_VIEW(VIEW_X, VIEW_Y);
                    IF (HALF == 0) {
                        MZ25_VRAM_DRAW_MAP_HALF_ROW_2P_PARAM(&DRAW_PARAM, VIEW_Y + 11, 92, 1);
                    }
                    IF (HALF != 0) {
                        MZ25_VRAM_DRAW_MAP_HALF_ROW_XSHIFT_2P_PARAM(&DRAW_PARAM, VIEW_Y + 11, 92, 1);
                    }
                    HALF_Y = 0;
                }
            }
        }
        IF (KEY == '8') {
            OLD_HALF_Y = HALF_Y;
            IF (OLD_HALF_Y == 1) {
                MZ25_VRAM_SHIFT_RECT_DOWN4_2P(0, 10, 40, 20, 96);
                IF (HALF == 0) {
                    MZ25_VRAM_DRAW_MAP_HALF_ROW_2P_PARAM(&DRAW_PARAM, VIEW_Y, 0, 0);
                }
                IF (HALF != 0) {
                    MZ25_VRAM_DRAW_MAP_HALF_ROW_XSHIFT_2P_PARAM(&DRAW_PARAM, VIEW_Y, 0, 0);
                }
                HALF_Y = 0;
            }
            IF (OLD_HALF_Y == 0) {
                IF (VIEW_Y > 0) {
                    VIEW_Y = VIEW_Y - 1;
                    SET_DRAW_VIEW(VIEW_X, VIEW_Y);
                    MZ25_VRAM_SHIFT_RECT_DOWN4_2P(0, 10, 40, 20, 96);
                    IF (HALF == 0) {
                        MZ25_VRAM_DRAW_MAP_HALF_ROW_2P_PARAM(&DRAW_PARAM, VIEW_Y, 0, 1);
                    }
                    IF (HALF != 0) {
                        MZ25_VRAM_DRAW_MAP_HALF_ROW_XSHIFT_2P_PARAM(&DRAW_PARAM, VIEW_Y, 0, 1);
                    }
                    HALF_Y = 1;
                }
            }
        }
    }
}