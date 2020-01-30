
.include "sys/sms_arch.s"

.rombankmap
  bankstotal 64
  banksize $4000
  banks 64
.endro

.emptyfill $FF

.background "madoua.gg"

.unbackground $80000 $FFFFF

;======================
; free unused space
;======================

; end-of-banks
;.unbackground $7F6B $7FEF
.unbackground $37A0 $3FFF
.unbackground $7EC0 $7FEF
.unbackground $1B730 $1BFFF
.unbackground $1FE70 $1FFFF
.unbackground $3BF10 $3BFFF
.unbackground $3F3B0 $3FFFF

.include "vwf_consts.inc"
.include "ram.inc"
.include "util.s"
.include "vwf.s"
.include "vwf_user.s"

;===============================================
; Update header after building
;===============================================
.smstag

;========================================
; local defines
;========================================

.define numScriptRegions 11

;========================================
; vwf settings
;========================================

;  ld a,vwfTileSize_main
;  ld b,vwfScrollZeroFlag_main
;  ld c,vwfNametableHighMask_main
;  ld hl,vwfTileBase_main
;  doBankedCall setUpVwfTileAlloc

;.bank $01 slot 1
;.section "extra startup code" free
;  newStartup:
;    ; init vwf
;    ld a,vwfTileSize_main
;    ld b,vwfScrollZeroFlag_main
;    ld c,vwfNametableHighMask_main
;    ld hl,vwfTileBase_main
;    doBankedCallSlot1 setUpVwfTileAlloc
;    
;    ret
;.ends

;========================================
; script
;========================================

; each script region is assigned one bank starting from this bank
.define scriptBaseBank $20

.define scriptBaseOffset $0

; some semi-magical values the game expects to find at the start of a
; resource table.
; for our purposes, only the first byte probably matters; if bit 5
; is set, the table is an offset table instead of a pointer table.
; other bits' meanings are unknown.
.define scriptBankTableData $42,$30,$37,$07
.define scriptBankTableDataFillerSize $0A

.bank scriptBaseBank+0 slot 1
.org scriptBaseOffset
.section "script region 0" force
  .db scriptBankTableData
  .dw scriptRegion0
  .rept scriptBankTableDataFillerSize
    .db $FF
  .endr
  scriptRegion0:
    .incbin "out/script/region0.bin"
.ends

.bank scriptBaseBank+1 slot 1
.org scriptBaseOffset
.section "script region 1" force
  .db scriptBankTableData
  .dw scriptRegion1
  .rept scriptBankTableDataFillerSize
    .db $FF
  .endr
  scriptRegion1:
    .incbin "out/script/region1.bin"
.ends

.bank scriptBaseBank+2 slot 1
.org scriptBaseOffset
.section "script region 2" force
  .db scriptBankTableData
  .dw scriptRegion2
  .rept scriptBankTableDataFillerSize
    .db $FF
  .endr
  scriptRegion2:
    .incbin "out/script/region2.bin"
.ends

.bank scriptBaseBank+3 slot 1
.org scriptBaseOffset
.section "script region 3" force
  .db scriptBankTableData
  .dw scriptRegion3
  .rept scriptBankTableDataFillerSize
    .db $FF
  .endr
  scriptRegion3:
    .incbin "out/script/region3.bin"
.ends

.bank scriptBaseBank+4 slot 1
.org scriptBaseOffset
.section "script region 4" force
  .db scriptBankTableData
  .dw scriptRegion4
  .rept scriptBankTableDataFillerSize
    .db $FF
  .endr
  scriptRegion4:
    .incbin "out/script/region4.bin"
.ends

.bank scriptBaseBank+5 slot 1
.org scriptBaseOffset
.section "script region 5" force
  .db scriptBankTableData
  .dw scriptRegion5
  .rept scriptBankTableDataFillerSize
    .db $FF
  .endr
  scriptRegion5:
    .incbin "out/script/region5.bin"
.ends

.bank scriptBaseBank+6 slot 1
.org scriptBaseOffset
.section "script region 6" force
  .db scriptBankTableData
  .dw scriptRegion6
  .rept scriptBankTableDataFillerSize
    .db $FF
  .endr
  scriptRegion6:
    .incbin "out/script/region6.bin"
.ends

.bank scriptBaseBank+7 slot 1
.org scriptBaseOffset
.section "script region 7" force
  .db scriptBankTableData
  .dw scriptRegion7
  .rept scriptBankTableDataFillerSize
    .db $FF
  .endr
  scriptRegion7:
    .incbin "out/script/region7.bin"
.ends

.bank scriptBaseBank+8 slot 1
.org scriptBaseOffset
.section "script region 8" force
  .db scriptBankTableData
  .dw scriptRegion8
  .rept scriptBankTableDataFillerSize
    .db $FF
  .endr
  scriptRegion8:
    .incbin "out/script/region8.bin"
.ends

.bank scriptBaseBank+9 slot 1
.org scriptBaseOffset
.section "script region 9" force
  .db scriptBankTableData
  .dw scriptRegion9
  .rept scriptBankTableDataFillerSize
    .db $FF
  .endr
  scriptRegion9:
    .incbin "out/script/region9.bin"
.ends

.bank scriptBaseBank+10 slot 1
.org scriptBaseOffset
.section "script region 10" force
  .db scriptBankTableData
  .dw scriptRegion10
  .rept scriptBankTableDataFillerSize
    .db $FF
  .endr
  scriptRegion10:
    .incbin "out/script/region10.bin"
.ends

;========================================
; use new script
;========================================

.bank $6 slot 2
.org $2069
.section "region mapping table" overwrite
  .db $00,:scriptRegion0
  .db $00,:scriptRegion1
  .db $00,:scriptRegion2
  .db $00,:scriptRegion3
  .db $00,:scriptRegion4
  .db $00,:scriptRegion5
  .db $00,:scriptRegion6
  .db $00,:scriptRegion7
  .db $00,:scriptRegion8
  .db $00,:scriptRegion9
  .db $00,:scriptRegion10
.ends

;========================================
; VWF tile allocation arrays
;========================================

; these arrays identify, in order, the tiles which
; will be allocated to VWF text as it is printed.
; order varies depending on which box text is being
; printed to.
; these are configured such that each box is guaranteed
; to be able to hold 4 full lines simultaneously.
; it's possible to have up to 5 lines situationally
; if one of the boxes is known to always be less than
; full for some particular messages.

.bank 0 slot 0
.section "vwf tilemap allocation arrays" free
  ; note: priority bit needs to be set!
  ; the game expects sprites that go behind the "letterboxing" to get
  ; covered up.
  vwfAllocArray_cutscene:
    .dw $10E8,$10E9,$10EA,$10EB,$10EC,$10ED,$10EE,$10EF,$10F0,$10F1,$10F2,$10F3,$10F4,$10F5,$10F6,$10F7,$10F8,$10F9
    .dw $10FA,$10FB,$10FC,$10FD,$10FE,$10FF,$11C0,$11C1,$11C2,$11C3,$11EC,$11ED,$11EF,$11F0,$11F1,$11F2,$11F3,$11F4
  
  vwfAllocArray_rightBox:
/*    .dw $0017,$0018,$0019,$001a,$001b,$001c,$001d
    .dw $001e,$001f,$0020,$0021,$0022,$0023,$0024
    .dw $0025,$0026,$0027,$0028,$0029,$002a,$002b
    .dw $0015,$0016,$01c0,$01c1,$01c2,$01c3,$01ff
    .dw $009f,$009e,$009d,$009c,$009b,$009a,$0099*/
    .dw $0017,$0018,$0019,$001a,$001b,$001c,$001d
    .dw $001e,$001f,$0020,$0021,$0022,$0023,$0024
    .dw $0025,$0026,$0027,$0028,$0029,$002a,$002b
    .dw $0015,$0016,$00fc,$00fd,$00fe,$00ff,$01f7
    .dw $009f,$009e,$009d,$009c,$009b,$009a,$0099
  
  vwfAllocArray_leftBox:
/*    .dw $002c,$002d,$002e,$002f,$0030,$0031,$0032
    .dw $0033,$0034,$0035,$0036,$0037,$0038,$0039
    .dw $003a,$003b,$003c,$003d,$003e,$003f,$0040
    .dw $0099,$009a,$009b,$009c,$009d,$009e,$009f
    .dw $01ff,$01c3,$01c2,$01c1,$01c0,$0016,$0015*/
    .dw $002c,$002d,$002e,$002f,$0030,$0031,$0032
    .dw $0033,$0034,$0035,$0036,$0037,$0038,$0039
    .dw $003a,$003b,$003c,$003d,$003e,$003f,$0040
    .dw $0099,$009a,$009b,$009c,$009d,$009e,$009f
    .dw $01f7,$00ff,$00fe,$00fd,$00fc,$0016,$0015
.ends

;========================================
; vwf printing
;========================================

.define scriptTextCharsPerFrameBreak 10

;.bank 6 slot 2
;.org $18E0
;.section "script printing" overwrite SIZE $15E
;.ends

.bank 6 slot 2
.org $190D
.section "script printing init" overwrite
  jp scriptPrintingInit
.ends

.bank 6 slot 2
.org $191A
.section "script printing right tilemap start" overwrite
;  ld de,$02E0
  ld de,$3BA2
.ends

.bank 6 slot 2
.org $194C
.section "script printing left tilemap start" overwrite
;  ld de,$0580
  ld de,$3B90
.ends

.bank 6 slot 2
.org $1951
.section "script printing box clear" overwrite
  jp scriptPrintingBoxClear
.ends

/*.bank 6 slot 2
.org $190D
.section "script printing line end" overwrite
  jp scriptPrintingLineEnd
.ends*/

; created purely so we have a label to jump to
.bank 9 slot 2
.org $19BA
.section "bcd conv label" overwrite
  numToText5Digit:
    ; cannot be empty, otherwise label will be thrown out
    ex de,hl
.ends

; jump target
.bank 6 slot 2
.org $18E0
.section "runScript" overwrite
  runScript:
    ld a,($C8DF)
.ends

; jump target
.bank 6 slot 2
.org $0BEC
.section "numToText2Digit" overwrite
  numToText2Digit:
    ld b,$02
.ends

.bank 6 slot 2
.org $1979
.section "script printing loop" SIZE $C5 overwrite
  scriptPrintingLoop:
    ld a,scriptTextCharsPerFrameBreak
    @lineLoop:
      
      @charLoop:
      push af
        ; fetch next char
        ld a,(de)
        
        ; linebreak?
        cp vwfBrIndex
        jr nz,+
          call sendLineToVdp
          inc de
          jr @charLoopEnd
        +:
        ; terminator?
        cp vwfTerminatorIndex
        jr nz,+
          call sendLineToVdp
          pop af
          jp sendNametableBufferToVdp
;          ret
        +:
        ; wait?
        cp vwfWaitIndex
        jr nz,+
          call sendLineToVdp
          call sendNametableBufferToVdp
          call doScriptInputWait
          inc de
          
          ; stop immediately if a terminator follows
          ; (original game does this; we don't because we
          ; want to allow the processing loop to clear the box
          ; at the end of the sequence)
;          ld a,(de)
;          cp vwfTerminatorIndex
;          ret z
          
          pop af
          jp $9911
        +:
        ; flags?
        cp vwfFlagsIndex
        jr nz,+
          ld a,c
          and $F0
          ld c,a
          inc de
          ld a,(de)
          inc de
          or c
          ld c,a
          
          jr @charLoopEnd
        +:
        ; number conversion?
        cp vwfNum5DigitIndex
        jr nz,+
          inc de
          call printVwfNum5Digit
          jr @charLoopEnd
        +:
        ; number conversion?
        cp vwfNum5DigitBigIndex
        jr nz,+
          inc de
          call printVwfNum5DigitBig
          jr @charLoopEnd
        +:
        ; number conversion?
        cp vwfNum2DigitBigIndex
        jr nz,+
          inc de
          call printVwfNum2DigitBig
          jr @charLoopEnd
        +:
        ; 
        cp vwfMemcharIndex
        jr nz,+
          inc de
;          call printVwfMemchar
          call fetchVwfMemchar
          ; decrement because this will be auto-incremented
          ; in the literal handler
          dec de
          ; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
          ; !!!!!!!!!! DROP THROUGH !!!!!!!!!!
          ; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;          jr @charLiteral
        +:
        
        ; literal
        @charLiteral:
        doBankedCallSlot2 printVwfChar_user
        inc de
        
        @charLoopEnd:
          pop af
          dec a
          or a
          call z,scriptLagWait
          
          jr @charLoop
        
      
    ret
  
  sendLineToVdp:
/*    exx
    
      ; graphics are sent as they're produced,
      ; so we send only the tilemap
    
      ; do nothing if no tiles
      ld a,(vwfPendingTileCounter)
      or a
      jr nz,+
        push de
        pop hl
        jr @advanceTilemapRow
      +:
      
        ; HL = src
        ld hl,tilemapCompositionBuffer
        
        ; BC = size of transfer
        ld a,(vwfPendingTileCounter)
        sla a
        ld c,a
        xor a
        ld b,a
        ; reset pending tile counter
        ld (vwfPendingTileCounter),a
        
        ; DE = dst, which we already prepared in the shadow registers
        
        push de
          call queueVdpTransfer
          call frameAniUpdate
          call waitForPendingVdpTransfers
        pop hl
      
      ; advance to next tilemap row
      @advanceTilemapRow:
      ld bc,$0040
      add hl,bc
      ex de,hl
      
      ; reset VWF state
      doBankedCallSlot2 fullyResetVwf
    
    exx */
    
    exx
    
      ; change in functionality:
      ; instead of sending a line at a time to the vdp,
      ; we compose an entire message and send it all at once.
      
      ; do nothing if no tiles
      ld a,(vwfPendingTileCounter)
      or a
      jr nz,+
        push de
        pop hl
        jr @advanceTilemapRow
      +:
      
      ld hl,(vwfTilemapTargetAddr)
      ; preincrement
      inc hl
      inc hl
      
      ; write target vdp address to tilemap buffer
      ld a,e
      ld (hl),a
      inc hl
      ld a,d
      ld (hl),a
      inc hl
      
      ; write size to tilemap buffer
      ld a,(vwfPendingTileCounter)
      ld (hl),a
      
      ; clear pending tile counter
      xor a
      ld (vwfPendingTileCounter),a
      
      ; do not increment hl -- it will be preincremented
      ; by the next tilemap write
;      inc hl
;      inc hl
      dec hl
      ld (vwfTilemapTargetAddr),hl
      
      @advanceTilemapRow:
      ex de,hl
      ld bc,$0040
      add hl,bc
      ex de,hl
      
      doBankedCallSlot2 resetVwf
      
;      call frameAniUpdate
    exx
    ret
  
.ends

.bank 6 slot 2
.section "script printing" free
  doScriptInputWait:
    ; if we don't do these two frame delays, a sprite gets dropped
    ; for a frame when the prompt cursor appears.
    ; probably caused by the extra VDP transfers we queue somehow --
    ; i guess they aren't all processed in one vblank?
    call frameAniUpdate
    call frameAniUpdate
    
    push de
    push bc
      ; turn on prompt cursor
      set 0,(iy+$1B)
      ld (iy+$11),$15
      
      call waitForScriptInput
      
      ; turn off prompt cursor
      res 0,(iy+$1B)
    pop bc
    pop de
      
    exx
      call setUpNewPrint
    exx
    
    ret
    
  scriptLagWait:
    call frameAniUpdate
    ld a,scriptTextCharsPerFrameBreak
    ret
  
;  scriptAniUpdate:
;    call frameAniUpdate
;    ret

  sendNametableBufferToVdp:
    exx
      
      ld hl,(vwfTilemapTargetAddr)
      ; preincrement
      inc hl
      
      @nametableQueueLoop:
        ld a,(hl)
        
        ; check for terminator
        cp $FF
        jr z,@done
        
        ; BC = byte count
        sla a
        ld c,a
        ld b,$00
        
        ; DE = vdp dst
        dec hl
        ld a,(hl)
        ld d,a
        dec hl
        ld a,(hl)
        ld e,a
        
        ; HL = src
        or a
        sbc hl,bc
        
        push hl
          call queueVdpTransfer
        pop hl
        
        dec hl
        jr @nametableQueueLoop
    
    @done:
    call frameAniUpdate
    call waitForPendingVdpTransfers
    
    ld a,(vwfNoAutoResetFlag)
    or a
    jr nz,+
      doBankedCallSlot2 fullyResetVwf
    +:
    
    ; write terminator to vwfTilemapTargetAddr
    ld hl,(vwfTilemapTargetAddr)
    ; preincrement shenanigans
    inc hl
    inc hl
    ld a,$FF
    ld (hl),a
    dec hl
    ld (vwfTilemapTargetAddr),hl
    
    exx
    ret

  scriptPrintingInit:
    ; make up work
    ld (iy+$13),h
    
    call setUpNewPrint
    
    jp $9910
  
  setUpNewPrint:
    ; at this point:
    ; C' = print flags
    ; DE' = scriptptr
    
    push hl
      
      ld hl,vwfBoxTextGrpBufferBaseAddr-bytesPerTile
      ld (vwfRamTileBaseAddr),hl
      ld (vwfRamTileCurAddr),hl
    
      ; reset all vwf stuff
      ld a,(vwfNoAutoResetFlag)
      or a
      jr nz,+
        doBankedCallSlot2 fullyResetVwf
    
        ; check which box we are printing to (bit 7 of print flags)
        exx
          bit 7,c
        exx
        
        jr nz,@leftBox
        @rightBox:
          ld a,vwfTargetType_rightBox
          ld (vwfTargetType),a
          
          ld hl,vwfAllocArray_rightBox-2
          ld (vwfAllocArrayPointer),hl
          
          jr @boxInitDone
        @leftBox:
          ld a,vwfTargetType_leftBox
          ld (vwfTargetType),a
          
          ld hl,vwfAllocArray_leftBox-2
          ld (vwfAllocArrayPointer),hl
          
        @boxInitDone:
      +:
      
      ; tilemap data to RAM buffer
;      ld hl,tilemapCompositionBuffer-2
;      ld (vwfTilemapTargetAddr),hl
      
      ; write terminator to vwfTilemapTargetAddr
      ld hl,(vwfTilemapTargetAddr)
      ; preincrement shenanigans
      inc hl
      inc hl
      ld a,$FF
      ld (hl),a
      dec hl
      ld (vwfTilemapTargetAddr),hl
    
    pop hl
    
    ret
  
  scriptPrintingBoxClear:
    ld a,(vwfNoPreClearFlag)
    or a
    jr nz,@skip
    
      ; number of rows to clear
      ld b,$03+2
      push de
        bit 7,c
        jr nz,@leftBox
        @rightBox:
          ; base VDP address
          ld de,$3B62+$0040
          jr @boxCheckDone
        @leftBox:
          ld de,$3B50+$0040
        @boxCheckDone:
        
        @loop:
          push bc
            push de
              ; address of tilemap that is sent to row to clear it
  ;            ld hl,$9A7E
              ld hl,boxRowClearTilemap
              ; size of tilemap
              ld bc,$000E
              call queueVdpTransfer
            pop hl
            ; spacing between cleared lines
            ld bc,$0080-$0040
            add hl,bc
            ex de,hl
          pop bc
          djnz @loop
      pop de
      
      ; wait for transfers we queued to go through.
      ; not strictly necessary, but if we are printing over an existing
      ; "stale" message, this will prevent garbage from being displayed.
      call waitForPendingVdpTransfers
    
    @skip:
    
    jp $9975
  
  clearRightBox:
    ; number of rows to clear
    ld b,$03+2
    push de
      ld de,$3B62+$0040
      
      @loop:
        push bc
          push de
            ; address of tilemap that is sent to row to clear it
;            ld hl,$9A7E
            ld hl,boxRowClearTilemap
            ; size of tilemap
            ld bc,$000E
            call queueVdpTransfer
          pop hl
          ; spacing between cleared lines
          ld bc,$0080-$0040
          add hl,bc
          ex de,hl
        pop bc
        djnz @loop
    pop de
    
    ; wait for transfers we queued to go through.
    ; not strictly necessary, but if we are printing over an existing
    ; "stale" message, this will prevent garbage from being displayed.
    call waitForPendingVdpTransfers
    
    ret
  
  setUpVwfNum5Digit:
    push bc
    push hl
      ; read parameter: source address
      ld a,(de)
      ld h,a
      inc de
      ld a,(de)
      ld l,a
      inc de
      
      push de
        ; read value from address
        ld a,(hl)
        inc hl
        ld h,(hl)
        ld l,a
        
        ; bcd conv routine expects to be able to trash shadow regs
        exx
        push bc
        push de
        push hl
        exx
          ; convert to buffer
          ld de,vwfNumConversionBuffer
          doBankedCallSlot2 numToText5Digit
        ; no exx here; bcd routine returns shadow regs
        pop hl
        pop de
        pop bc
        exx
      pop de
    pop hl
    pop bc
    
    ret
  
  setUpVwfNum2Digit:
    push bc
    push hl
      ; read parameter: source address
      ld a,(de)
      ld h,a
      inc de
      ld a,(de)
      ld l,a
      inc de
      
      push de
        ; read value from address
        ld a,(hl)
        
        ; convert to buffer
        ld de,vwfNumConversionBuffer+1
        doBankedCallSlot2 numToText2Digit
      pop de
    pop hl
    pop bc
    
    ret
  
  printVwfNum5Digit:
    call setUpVwfNum5Digit
    doBankedJumpSlot2 printNumConversionBuffer
  
  printVwfNum5DigitBig:
    call setUpVwfNum5Digit
    doBankedJumpSlot2 printNumConversionBufferBig
  
  printVwfNum2DigitBig:
    call setUpVwfNum2Digit
    doBankedJumpSlot2 printNumConversionBuffer2DigitBig
  
  fetchVwfMemchar:
    push hl
      ld a,(de)
      ld h,a
      inc de
      
      ld a,(de)
      ld l,a
      inc de
      
      ld a,(hl)
    pop hl
    ret
.ends

.bank 0 slot 0
.section "script line clear tilemap" free
  ; moved out of slot 2 so we can let the vblank handler
  ; safely transfer these while we call our new routines
  ; out of a different bank
  boxRowClearTilemap:
    .rept 7
      .dw $0001
    .endr
.ends

;========================================
; new cutscene text printing
;========================================

.define cutsceneTextW 18-4
.define cutsceneTextBaseVdpPos $3C4E+4
; if this many characters are printed before the end of the
; cutscene text is encountered, stop and let the animations play
; for a frame to avoid lag
.define cutsceneTextCharsPerFrameBreak 4

.bank 0 slot 0
.section "cutscene line clear tilemap" free
  cutsceneRowClearTilemap:
    ; priority bit needs to be set
    .rept cutsceneTextW
      .dw $1000
    .endr
.ends

.slot 1
.section "cutscene text" superfree
  cutsceneStringTable:
    .incbin "out/script/cutscenes.bin"
.ends

.bank 6 slot 2
.org $254E
.section "cutscene runner" SIZE $A9 overwrite
  ; set VDP putpos
;  ld de,$1D00
  ld de,cutsceneTextBaseVdpPos
  exx
  
  ; load cutscene text bank
  ld a,(mapperSlot1Ctrl)
  push af
    
    ;========================================
    ; look up string
    ;========================================
    
    ld a,:cutsceneStringTable
    ld (mapperSlot1Ctrl),a
  
    ; A = target string index
    ld a,($C8BB)
    push af
      ; look up offset from table
      ld l,a
      ld h,$00
      add hl,hl
      
      ld de,cutsceneStringTable
      add hl,de
      ld a,(hl)
      inc hl
      ld h,(hl)
      ld l,a
      
      ; add table base address to derive pointer
      add hl,de
      ; DE = srcptr
      ex de,hl
    pop af
    
    ; increment target string index
    inc a
    ld ($C8BB),a
    
    ;========================================
    ; set up vwf
    ;========================================
    
    ld hl,vwfBoxTextGrpBufferBaseAddr-bytesPerTile
    ld (vwfRamTileBaseAddr),hl
    ld (vwfRamTileCurAddr),hl
    
    push de
      ; reset all vwf stuff
      doBankedCallSlot2 fullyResetVwf
    pop de
      
    ; write terminator to vwfTilemapTargetAddr
    ld hl,(vwfTilemapTargetAddr)
    ; preincrement shenanigans
    inc hl
    inc hl
    ld a,$FF
    ld (hl),a
    dec hl
    ld (vwfTilemapTargetAddr),hl
    
    ld a,vwfTargetType_cutscene
    ld (vwfTargetType),a
    
    ld hl,vwfAllocArray_cutscene-2
    ld (vwfAllocArrayPointer),hl
    
    ; clear old message
    call cleanUpOldCutsceneText
    
    ;========================================
    ; print loop
    ;========================================
    
    ld a,cutsceneTextCharsPerFrameBreak
    
    @charLoop:
      
      push af
        ; fetch next char
        ld a,(de)
        
        ; linebreak?
        cp vwfBrIndex
        jr nz,+
          call cutsceneSendLineToVdp
          
          ; reset lag break timer
          pop af
          ld a,cutsceneTextCharsPerFrameBreak
          push af
          
          inc de
          jr @charDone
        +:
        ; terminator?
        cp vwfTerminatorIndex
        jr nz,+
          call cutsceneSendLineToVdp
          call cutsceneSendNametableBufferToVdp
          pop af
          jr @printDone
        +:
        
        ; literal
        doBankedCallSlot2 printVwfChar_user
        inc de
      
    @charDone:
      pop af
      
      ; check if break needed
      dec a
      or a
      call z,cutsceneLagWait
      jr @charLoop
  
  @printDone:
  
  pop af
  ld (mapperSlot1Ctrl),a
  ret
    
.ends

.bank 6 slot 2
.section "cutscene runner 2" free
  cleanUpOldCutsceneText:
    push de
/*      ld de,$3C16
      ld hl,$A639
      ld bc,$0014
      call queueVdpTransfer
      ld de,$3C96
      ld hl,$A639
      ld bc,$0014
      call queueVdpTransfer*/
      
      ; row 1
      ld de,cutsceneTextBaseVdpPos
      ld hl,cutsceneRowClearTilemap
      ld bc,cutsceneTextW*2
      call queueVdpTransfer
      
      ; row 2
;      ld de,cutsceneTextBaseVdpPos+$0040
;      ld hl,boxRowClearTilemap
;      ld bc,cutsceneTextW*2
;      call queueVdpTransfer
      
      ; row 3
      ld de,cutsceneTextBaseVdpPos+$0080
      ld hl,cutsceneRowClearTilemap
      ld bc,cutsceneTextW*2
      call queueVdpTransfer
      
    pop de
    
    call frameAniUpdate
    call waitForPendingVdpTransfers
    ret
  
  cutsceneLagWait:
    call cutsceneAniUpdate
    ld a,cutsceneTextCharsPerFrameBreak
    ret
  
  cutsceneAniUpdate:
;    call queueVdpTransfer
    call frameAniUpdate
;    call waitForPendingVdpTransfers
    ret
  
  cutsceneSendLineToVdp:
    call sendLineToVdp
    
    ; sendLineToVdp only moves down one line.
    ; move down another one
    exx
      ld hl,$0040
      add hl,de
      ex de,hl
    exx
    ret
  
  cutsceneSendNametableBufferToVdp:
    jp sendNametableBufferToVdp
.ends

.bank 6 slot 2
.org $2528
.section "cutscene text clear" overwrite
  call cleanUpOldCutsceneText
  jp $A547
.ends


;========================================
; 1-line linebreaks
;========================================

/*.bank 0 slot 0
;.org $28A0
.org $2910
.section "linebreak height" overwrite
  ; bytes in virtual tilemap to skip
  ld de,$0050/2
.ends */

;========================================
; reset vwf on linebreak
;========================================

/*.bank 0 slot 0
;.org $28A9
.org $2919
.section "linebreak 1" overwrite
  ; done
  jp linebreakVwfReset
.ends

.bank 0 slot 0
.section "linebreak 2" free
  linebreakVwfReset:
    doBankedCallSlot2 resetVwf
    jp scriptIncrementAndContinue
.ends */

;========================================
; do not auto-bitmap text windows
;========================================

; the original game hardcodes the correspondence between the
; three non-diacritical lines of each text window and the
; tiles that contain the bitmapped text.
; we do not want this behavior; we want to assign tiles to the
; window as we draw the text.

  ;========================================
  ; blank right window's base tilemap
  ;========================================
  
  .bank 6 slot 2
  .org $0874
  .section "right window base tilemap" overwrite
;    .db $01,$01,$01,$01,$01,$01,$01
;    .db $17,$18,$19,$1A,$1B,$1C,$1D
;    .db $01,$01,$01,$01,$01,$01,$01
;    .db $1E,$1F,$20,$21,$22,$23,$24
;    .db $01,$01,$01,$01,$01,$01,$01
;    .db $25,$26,$27,$28,$29,$2A,$2B
    
    .db $01,$01,$01,$01,$01,$01,$01
    .db $01,$01,$01,$01,$01,$01,$01
    .db $01,$01,$01,$01,$01,$01,$01
    .db $01,$01,$01,$01,$01,$01,$01
    .db $01,$01,$01,$01,$01,$01,$01
    .db $01,$01,$01,$01,$01,$01,$01
  .ends

  ;========================================
  ; fix left window
  ;========================================
  
  ; bizarrely, the left window does not have its own dedicated
  ; tilemap; when the game wants to draw it, it reads back the
  ; right window's tilemap from the VDP, modifies it as needed,
  ; and ultimately draws that.
  
  .bank 6 slot 2
  .org $183D
  .section "left window tilemap draw" overwrite
;    add a,$15
    ; low byte of tile number for bitmapped portion of left window.
    ; normally, the game adds $15 to the tile number of the corresponding
    ; tile in the right window.
    ; we want an initially blank window, so we use tile 1.
    ld a,$01
  .ends

;========================================
; print gold amount on main menu
;========================================

.bank 0 slot 0
.section "gold main menu 1" free
  goldMainMenuScript:
    .incbin "out/script/gold_main.bin"
  
  ; c = flags
  ; de = pointer to script (slot already loaded)
  runRightboxScript:
    ; make up work we miss by not going through the old script runner
    ld hl,$C881
    set 5,(hl)
    
      exx
      doBankedCallSlot2 runScript
    
    ld hl,$C881
    res 5,(hl)
  
    ret
.ends

.bank 9 slot 2
.org $1E02
.section "gold main menu 2" SIZE $22 overwrite
  ; ?
  xor a
  ld ($C8C8),a
  
  ld de,goldMainMenuScript
  ld c,$0F
  jp runRightboxScript
.ends

;========================================
; use new shop dialogue
;========================================

; unbackground old shop text + table
.unbackground $25BB7 $25CE6
.unbackground $27fea $27fff

.bank 9 slot 2
.section "shop prompt table" free
  shopPromptTable:
    .dw shopPrompt00
    .db :shopPrompt00
    
    
    .dw shopPrompt01
    .db :shopPrompt01
    
    
    .dw shopPrompt02
    .db :shopPrompt02
    
    
    .dw shopPrompt03
    .db :shopPrompt03
    
    
    .dw shopPrompt04
    .db :shopPrompt04
    
    
    .dw shopPrompt05
    .db :shopPrompt05
    
    
    .dw shopPrompt06
    .db :shopPrompt06
    
    
    .dw shopPrompt07
    .db :shopPrompt07
    
    
    .dw shopPrompt08
    .db :shopPrompt08
    
    
    .dw shopPrompt09
    .db :shopPrompt09
    
    
    .dw shopPrompt10
    .db :shopPrompt10
    
    
    .dw shopPrompt11
    .db :shopPrompt11
    
.ends

.slot 1
.section "shop prompts" superfree
  shopPrompt00: .incbin "out/script/shop_00.bin"
  shopPrompt01: .incbin "out/script/shop_01.bin"
  shopPrompt02: .incbin "out/script/shop_02.bin"
  shopPrompt03: .incbin "out/script/shop_03.bin"
  shopPrompt04: .incbin "out/script/shop_04.bin"
  shopPrompt05: .incbin "out/script/shop_05.bin"
  shopPrompt06: .incbin "out/script/shop_06.bin"
  shopPrompt07: .incbin "out/script/shop_07.bin"
  shopPrompt08: .incbin "out/script/shop_08.bin"
  shopPrompt09: .incbin "out/script/shop_09.bin"
  shopPrompt10: .incbin "out/script/shop_10.bin"
  shopPrompt11: .incbin "out/script/shop_11.bin"
.ends

.bank 9 slot 2
.org $1956
.section "new shop prompt lookup" SIZE $53 overwrite
  call savePageRegs
    ld a,c
    and $7F
    ld ($C8D7),a
    ; A = shop type?
    ld a,($C8BE)
    and $03

    ; multiply shop type by 9
    ld c,a
    sla a
    sla a
    sla a
    add a,c
    ld c,a
    
    ; multiply subindex by 3
    ld a,($C8D7)
    ld b,a
    sla a
    add a,b
    
    ; BC = table offset
    add a,c
    ld c,a
    ld b,$00
    
    ; do lookup
    ld hl,shopPromptTable
    add hl,bc
    
    ; script pointer
    ld e,(hl)
    inc hl
    ld d,(hl)
    inc hl
  
    ; script bank
    ld a,(hl)
    ld (mapperSlot1Ctrl),a
    
    ld c,$0F
    call runRightboxScript
  call restorePageRegs
  ret
  
.ends

;========================================
; use new sound test script
;========================================

.bank 6 slot 2
.org $0BBA
.section "sound test 1" overwrite
  jp soundTestPreDraw
.ends

.bank 6 slot 2
.org $0AE2
.section "sound test init" overwrite
  jp initSoundTest
.ends


.bank 6 slot 2
.section "sound test 2" free
  soundTestScript:
    .incbin "out/script/soundtest.bin"
    
  soundTestPreDraw:
    ld a,(ix+$1E)
    or a
    jr z,+
    ; if option 1 selected
      ld a,vwfCursorOffIndex
      ld b,vwfCursorOnIndex
      jr @done
    ; if option 2 selected
    +:
      ld b,vwfCursorOffIndex
      ld a,vwfCursorOnIndex
    @done:
    
    ; update tilemap for cursor
    ld ($C8BF),a
    ld a,b
    ld ($C8C6),a
    
    ; run script
    ld a,$FF
    ld (vwfNoPreClearFlag),a
    ld (vwfNoAutoResetFlag),a
      call drawSoundTest
    xor a
    ld (vwfNoPreClearFlag),a
    ld (vwfNoAutoResetFlag),a
    
    ; reset tile allocation every other time we run
    ld a,(soundTestFlipCounter)
    inc a
    ld (soundTestFlipCounter),a
    bit 0,a
    jr nz,+
      doBankedCallSlot2 fullyResetVwf
      
      ld hl,vwfAllocArray_rightBox-2
      ld (vwfAllocArrayPointer),hl
    +:
    ret
  
  drawSoundTest:
    ld de,soundTestScript
    ld c,$0F
    jp runRightboxScript
  
  initSoundTest:
    call clearRightBox
    
    xor a
    ld (soundTestFlipCounter),a
    
    ld a,vwfTargetType_rightBox
    ld (vwfTargetType),a
    
    ld hl,vwfAllocArray_rightBox-2
    ld (vwfAllocArrayPointer),hl
    
;    doBankedCallSlot2 fullyResetVwf
    
    ; make up work
    ld hl,$8C13
    jp $8AE5
    
.ends

; reverse left and right so that pressing right increases the selected
; sound index and left decreases it

.bank 6 slot 2
.org $0B0A
.section "sound test reverse control 1" overwrite
;  bit 2,a
  bit 3,a
.ends

.bank 6 slot 2
.org $0B0F
.section "sound test reverse control 2" overwrite
;  bit 3,a
  bit 2,a
.ends



;========================================
; new graphics
;========================================
  
  .slot 2
  .section "new graphics" superfree
    compass_grp: .incbin "out/grp/compass.bin" FSIZE compass_grp_size
    .define compass_grp_numTiles compass_grp_size/bytesPerTile
    
    buttons_map: .incbin "out/grp/buttons_map.bin" FSIZE buttons_map_size
    .define buttons_map_numTiles buttons_map_size/bytesPerTile
    buttons_magic_item: .incbin "out/grp/buttons_magic_item.bin" FSIZE buttons_magic_item_size
    .define buttons_magic_item_numTiles buttons_magic_item_size/bytesPerTile
    buttons_save: .incbin "out/grp/buttons_save.bin" FSIZE buttons_save_size
    .define buttons_save_numTiles buttons_save_size/bytesPerTile
    
    buttons_flee_lipemco: .incbin "out/grp/buttons_flee_lipemco.bin" FSIZE buttons_flee_lipemco_size
    .define buttons_flee_lipemco_numTiles buttons_flee_lipemco_size/bytesPerTile
    
    buttons_file: .incbin "out/grp/buttons_file.bin" FSIZE buttons_file_size
    .define buttons_file_numTiles buttons_file_size/bytesPerTile
    
    buttons_yes_no: .incbin "out/grp/buttons_yes_no.bin" FSIZE buttons_yes_no_size
    .define buttons_yes_no_numTiles buttons_yes_no_size/bytesPerTile
    
    buttons_buy_sell_leave: .incbin "out/grp/buttons_buy_sell_leave.bin" FSIZE buttons_buy_sell_leave_size
    .define buttons_buy_sell_leave_numTiles buttons_buy_sell_leave_size/bytesPerTile
    
    buttons_title: .incbin "out/grp/buttons_title.bin" FSIZE buttons_title_size
    .define buttons_title_numTiles buttons_title_size/bytesPerTile
    
    sendUncompressedNewTilesToVdp:
      di
      rawTilesToVdp_macro_safe
      
      ; check if vdp reg 1 bit 6 set (display enabled)
      ld a,($C581)
      and $40
      jr z,+
        ; if display enabled, wait for scanline counter to reach 0xC0
        call $1EBF
      +:
      
      ei
      ret
    
    loadCompassGrp:
      ld b,compass_grp_numTiles
      ld de,compass_grp
      ld hl,$2080|$4000
      jp sendUncompressedNewTilesToVdp
    
    loadMainMenuButtons:
      ld b,buttons_map_numTiles
      ld de,buttons_map
      ld hl,$0580|$4000
      call sendUncompressedNewTilesToVdp
      
      ld b,buttons_magic_item_numTiles
      ld de,buttons_magic_item
      ld hl,$0640|$4000
      call sendUncompressedNewTilesToVdp
      
      ld b,buttons_save_numTiles
      ld de,buttons_save
      ld hl,$07C0|$4000
      jp sendUncompressedNewTilesToVdp
    
    loadBattleButtons:
      ld b,buttons_magic_item_numTiles
      ld de,buttons_magic_item
      ld hl,$0580|$4000
      call sendUncompressedNewTilesToVdp
      
      ld b,buttons_flee_lipemco_numTiles
      ld de,buttons_flee_lipemco
      ld hl,$0700|$4000
      jp sendUncompressedNewTilesToVdp
    
    loadFileButtons:
      ld b,buttons_file_numTiles
      ld de,buttons_file
      ld hl,$0580|$4000
      jp sendUncompressedNewTilesToVdp
    
    loadYesNoButtons:
      ld b,buttons_yes_no_numTiles
      ld de,buttons_yes_no
      ld hl,$0580|$4000
      jp sendUncompressedNewTilesToVdp
    
    loadBuySellLeaveButtons:
      ld b,buttons_buy_sell_leave_numTiles
      ld de,buttons_buy_sell_leave
      ld hl,$0580|$4000
      jp sendUncompressedNewTilesToVdp
    
    loadTitleButtons:
      ld b,buttons_file_numTiles
      ld de,buttons_file
      ld hl,$22C0|$4000
      call sendUncompressedNewTilesToVdp
      
      ld b,buttons_title_numTiles
      ld de,buttons_title
      ld hl,$2140|$4000
      jp sendUncompressedNewTilesToVdp
  .ends

  ;========================================
  ; buttons
  ;========================================

  .bank 6 slot 2
  .org $22E6
  .section "main menu buttons" overwrite
    doBankedCallSlot2 loadMainMenuButtons
    jp $A2FB
  .ends

  .bank 6 slot 2
  .org $2335
  .section "battle buttons" overwrite
    doBankedCallSlot2 loadBattleButtons
    nop
  .ends

  .bank 6 slot 2
  .org $223C
  .section "file buttons 1" overwrite
    jp loadFileButtonsExt
  .ends

  .bank 6 slot 2
  .section "file buttons 2" free
    loadFileButtonsExt:
      doBankedCallSlot2 loadFileButtons
      jp $A245
  .ends

  .bank 6 slot 2
  .org $2192
  .section "yes/no buttons 1" overwrite
    jp loadYesNoButtonsExt
  .ends

  .bank 6 slot 2
  .section "yes/no buttons 2" free
    loadYesNoButtonsExt:
      doBankedCallSlot2 loadYesNoButtons
      jp $A198
  .ends

  .bank 9 slot 2
  .org $1543
  .section "buy/sell/leave buttons 1" overwrite
    jp loadBuySellLeaveButtonsExt
  .ends

  .bank 9 slot 2
  .section "buy/sell/leave buttons 2" free
    loadBuySellLeaveButtonsExt:
      doBankedCallSlot2 loadBuySellLeaveButtons
      jp $9549
  .ends

  .bank $E slot 2
  .org $10CE
  .section "title buttons" overwrite
    doBankedCallSlot2 loadTitleButtons
    nop
  .ends
  
  ;========================================
  ; compass
  ;========================================

  .bank $F slot 1
  .org $2CDF
  .section "load compass 1" overwrite
    jp loadCompass
  .ends

  .bank $F slot 1
  .section "load compass 2" free
    loadCompass:
      doBankedCallSlot2 loadCompassGrp
      jp $6CE5
  .ends
  
  ;========================================
  ; title screen
  ;========================================
  
  .slot 2
  .section "new graphics title" superfree
    title_logo_grp: .incbin "out/grp/title_logo.bin" FSIZE title_logo_grp_size
    .define title_logo_grp_numTiles title_logo_grp_size/bytesPerTile
    title_logo_map: .incbin "out/maps/title_logo.bin"
    .define title_logo_map_w 20
    .define title_logo_map_h 7+3
    
    ending1_explosion3_grp: .incbin "out/grp/ending1_explosion3.bin" FSIZE ending1_explosion3_grp_size
    .define ending1_explosion3_grp_numTiles ending1_explosion3_grp_size/bytesPerTile
    ending1_explosion3_map: .incbin "out/maps/ending1_explosion3.bin"
    .define ending1_explosion3_map_w 20
    .define ending1_explosion3_map_h 10
    
    compile_logo2_grp: .incbin "out/grp/compile_logo2.bin" FSIZE compile_logo2_grp_size
    .define compile_logo2_grp_numTiles compile_logo2_grp_size/bytesPerTile
    compile_logo2_map: .incbin "out/maps/compile_logo2.bin"
    .define compile_logo2_map_w 20
    .define compile_logo2_map_h 18
    
    sendUncompressedNewTilesToVdp_bankE:
      di
      rawTilesToVdp_macro_safe
      
      ; check if vdp reg 1 bit 6 set (display enabled)
      ld a,($C581)
      and $40
      jr z,+
        ; if display enabled, wait for scanline counter to reach 0xC0
        call $1EBF
      +:
      
      ei
      ret
    
    ; b = w
    ; c = h
    ; de = vdp dst
    ; hl = src
    tilemapToVdp_bankE:
      ex de,hl
      ; loop
      --:
        push bc
        push hl
        ; loop
        -:
          ; set up vdp write
          di 
            ld a,l
            out ($BF),a
            ld a,h
            or $40
            out ($BF),a
            inc hl
            inc hl
            ld a,(de)
            inc de
            out ($BE),a
            ld a,(de)
            inc de
            out ($BE),a
          ei 
          djnz -
        pop hl
        ld bc,$0040
        add hl,bc
        pop bc
        dec c
        jp nz,--
      ret 
    
    loadTitleGrpExt:
      ld b,title_logo_grp_numTiles
      ld de,title_logo_grp
      ld hl,$0000|$4000
      jp sendUncompressedNewTilesToVdp_bankE
    
    loadTitleMapExt:
/*      ; clear upper part of nametable
      ld hl,$3800|$4000
      ld c,vdpCtrlPort
      di
        ; set vdp dst
        out (c),l
        nop
        out (c),h
        nop
        xor a
        -:
          .rept $C0
            push ix
            pop ix
            out (c),a
          .endr
      ei*/
      
      ; load map
      ld bc,(title_logo_map_w<<8)|title_logo_map_h
      ld de,$380C
      ld hl,title_logo_map
      jp tilemapToVdp_bankE
    
    loadEndingGrpExt:
      ld b,ending1_explosion3_grp_numTiles
      ld de,ending1_explosion3_grp
#      ld hl,$1420|$4000
      ld hl,$2620|$4000
      jp sendUncompressedNewTilesToVdp_bankE
    
    loadEndingMapExt:
      ; load map
      ld bc,(ending1_explosion3_map_w<<8)|ending1_explosion3_map_h
      ld de,$394C
      ld hl,ending1_explosion3_map
      jp tilemapToVdp_bankE
    
    loadCompileLogo2Ext:
      ld b,compile_logo2_grp_numTiles
      ld de,compile_logo2_grp
;      ld hl,$1420|$4000
      ld hl,$0000|$4000
      call sendUncompressedNewTilesToVdp_bankE
      
      ; load map
      ld bc,(compile_logo2_map_w<<8)|compile_logo2_map_h
      ld de,$38CC
      ld hl,compile_logo2_map
      jp tilemapToVdp_bankE
    
  .ends

  .bank $0 slot 0
  .org $02F0
  .section "load compile logo 2" overwrite
    doBankedCallSlot2 loadCompileLogo2Ext
    jp $0305
  .ends

  .bank $E slot 2
  .org $1011
  .section "load title grp 1" overwrite
    jp loadTitleGrp
  .ends

  .bank $E slot 2
  .section "load title grp 2" free
    loadTitleGrp:
      doBankedCallSlot2 loadTitleGrpExt
      jp $9017
  .ends

  .bank $E slot 2
  .org $105C
  .section "load title map 1" overwrite
    jp loadTitleMap
  .ends

  .bank $E slot 2
  .section "load title map 2" free
    loadTitleMap:
/*      ; lower tilemap high bytes
      ld hl,$C600
      ld de,$3A8D
      ld bc,$140B
      call $BE81
      
      ; lower tilemap low bytes
      ld hl,$B246
      ld de,$3A8C
      ld bc,$140B
      call $BE81*/
      
      ; make up work
      call $BE81
      
      ; new upper map
      doBankedCallSlot2 loadTitleMapExt
      jp $905F
  .ends
  
  ;========================================
  ; ending
  ;========================================

/*  .bank $7 slot 1
  .org $3B92
  .section "temp" overwrite
    jp temp
  .ends */

  .bank $7 slot 1
  .org $3949
  .section "load ending grp 1" overwrite
    jp loadEndingGrp
  .ends

  .bank $7 slot 1
  .section "load ending grp 2" free
/*    temp:
      ld (iy+$1C),$17
      call $7C67
      
      ld (iy+$1C),$17
      ld bc,$0400
      call $008B
      
      jp $7B99 */
    
    loadEndingGrp:
      ; make up work
      call $7C54
      
      ; new graphics
      doBankedCallSlot2 loadEndingGrpExt
      
      jp $794C
  .ends

  .bank $7 slot 1
  .org $39F7
  .section "load ending map 1" overwrite
    jp loadEndingMap
  .ends

  .bank $7 slot 1
  .section "load ending map 2" free
    loadEndingMap:
      ; new map
      doBankedCallSlot2 loadEndingMapExt
      
      jp $79FD
  .ends

;========================================
; credits
;========================================

.define finalCreditsNumEntries 3
.define initialCreditsNumEntries $37-finalCreditsNumEntries
.define newCreditsNumEntries 7

.bank 7 slot 1
.org $3BA3
.section "credits 1" overwrite
  ; number of initial credits entries to run
  ld b,initialCreditsNumEntries
  call extendedCredits
  
.ends

.bank 7 slot 1
.section "credits 2" free
  extendedCredits:
    ; run credits
    call $7C69
    
    ;================================
    ; run extra translation credits
    ;================================
    
    ; push current target index
    ld a,(currentCutsceneScriptIndex)
    push af
    
      ; start of new cutscene content
      ld a,$A8
      ld (currentCutsceneScriptIndex),a
      
      ; length of new credits
      ld b,newCreditsNumEntries
      
      ; run new credits
      call $7C69
    
    ; pop target index for end of original credits
    pop af
    ld (currentCutsceneScriptIndex),a
    
    ; run end of original credits
    ld b,finalCreditsNumEntries
    jp $7C69
    
    
    
.ends

;========================================
; just before starting the game (new,
; loaded, after cutscene),
; save the background for
; the left window area to the offscreen
; buffer.
; this fixes an issue where reloading
; a save file in front of an event that
; automatically triggers (such as the
; toad statue) would restore the
; background even though it had never
; been saved, blanking out that area
; of the screen.
;========================================

.bank 6 slot 2
.org $0869
.section "tile reload fix 1" overwrite
  call tileReloadFix
.ends

.bank 6 slot 2
.section "tile reload fix 2" free
  tileReloadFix:
    ; make up work
    call $0091
    
    ; save left window
    jp $97BD
  
.ends

;========================================
; when removing key items from
; inventory, check *all* slots.
; the original game accidentally
; checks one slot too few, causing
; items to get "stuck" in the last slot.
;========================================

.bank 5 slot 1
.org $0174
.section "inventory removal fix" overwrite
  ld b,$1A+1
.ends

