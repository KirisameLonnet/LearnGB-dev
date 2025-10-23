INCLUDE "hardware.inc"

SECTION "Header", ROM0[$100]

    jp EntryPoint

    ds $150 - @, 0 ; Make room for the header

EntryPoint:

WaitVBlank
    ld a, [rLY]
    cp 144
    jp c, WaitVBlank