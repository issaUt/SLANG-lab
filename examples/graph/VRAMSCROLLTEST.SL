#include "../../lib/iocs/MZ25IOCS_SVC.LIB"
#include "../../lib/MZ25VRAM_GFX.LIB"

MAIN()
VAR I, KEY, PAGE;
{
    IOCS_INITSCREEN();
    IOCS_GINIT(320,200,16);
    IOCS_VIEW(0,0,319,199);

    FOR PAGE = 0 TO 3 {
        IOCS_SCREEN_INPUT_PAGE(PAGE);
        IOCS_CLS(0);
        FOR I = 0 TO 15 {
            IOCS_LINE(I*20, 0, I*20, 199, I+1);
            IOCS_LINE(0, I*12, 319, I*12, I+1);
        }
    }

    PAGE = 0;
    IOCS_SCREEN320(PAGE, PAGE);
    PRINT("VRAM SCROLL TEST",/);
    PRINT("4/6: PAGE  1/3: FULL  7/9: RECT  ESC:EXIT",/);

    KEY = 0;
    WHILE (KEY != 27) {
        KEY = INKEY(0);
        IF (KEY == '4') {
            PAGE = (PAGE + 3) MOD 4;
            IOCS_SCREEN320(PAGE, PAGE);
        }
        IF (KEY == '6') {
            PAGE = (PAGE + 1) MOD 4;
            IOCS_SCREEN320(PAGE, PAGE);
        }
        IF (KEY == '1') {
            MZ25_VRAM_SCROLL_LEFT8(PAGE);
        }
        IF (KEY == '3') {
            MZ25_VRAM_SCROLL_RIGHT8(PAGE);
        }
        IF (KEY == '7') {
            MZ25_VRAM_SCROLL_RECT_LEFT8(PAGE, 5, 50, 30, 100);
        }
        IF (KEY == '9') {
            MZ25_VRAM_SCROLL_RECT_RIGHT8(PAGE, 5, 50, 30, 100);
        }
    }
}