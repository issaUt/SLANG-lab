// Generated from PCGCAR.BSD
// 8x8 PCG data format: B plane 8 bytes, R plane 8 bytes, G plane 8 bytes.
// Use with MZ25IOCSLIB.SL: IOCS_SPCG8(char_code, select_no, data_array);

// 1 record = 1-byte character code + 24-byte PCG data.
VAR BYTE PCG_DATA[150] = {
    $41,
    $00,$01,$03,$3B,$3F,$3B,$03,$03,    // B plane
    $00,$00,$00,$20,$20,$00,$00,$01,    // R plane
    $00,$00,$00,$38,$38,$38,$00,$01,    // G plane

    $42,
    $00,$80,$C0,$DC,$FC,$DC,$C0,$C0,    // B plane
    $00,$00,$00,$10,$00,$00,$00,$80,    // R plane
    $00,$00,$00,$1C,$1C,$1C,$00,$80,    // G plane

    $43,
    $07,$77,$7F,$7F,$7E,$76,$00,$00,    // B plane
    $01,$41,$41,$40,$01,$00,$06,$00,    // R plane
    $01,$71,$71,$70,$70,$70,$00,$00,    // G plane

    $44,
    $E0,$EE,$FE,$FE,$7E,$6E,$00,$00,    // B plane
    $80,$88,$88,$08,$80,$00,$60,$00,    // R plane
    $80,$8E,$8E,$0E,$0E,$0E,$00,$00,    // G plane

    $45,
    $C0,$FD,$41,$41,$41,$41,$01,$7F,    // B plane
    $C0,$80,$00,$00,$00,$00,$00,$00,    // R plane
    $FE,$82,$82,$82,$82,$82,$FE,$00,    // G plane

    $46,
    $EE,$55,$AA,$77,$AA,$55,$BB,$55,    // B plane
    $AA,$55,$AA,$55,$AA,$55,$AA,$55,    // R plane
    $EE,$55,$AA,$77,$AA,$55,$BB,$55     // G plane
};

INIT_PCG()
{
    IOCS_SPCG8(PCG_DATA[0], 0, &PCG_DATA[1]);
    IOCS_SPCG8(PCG_DATA[25], 0, &PCG_DATA[26]);
    IOCS_SPCG8(PCG_DATA[50], 0, &PCG_DATA[51]);
    IOCS_SPCG8(PCG_DATA[75], 0, &PCG_DATA[76]);
    IOCS_SPCG8(PCG_DATA[100], 0, &PCG_DATA[101]);
    IOCS_SPCG8(PCG_DATA[125], 0, &PCG_DATA[126]);
}
