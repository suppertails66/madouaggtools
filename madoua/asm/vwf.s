
; TODO:
;   * read VWF strings through slot 1 banking (must disable interrupts
;     if no disable flag not set)
;   * fix nametable border composition and stuff

.bank 0 slot 0
.section "tile to expram" free
  ; FIXME: is this correct?
  vwfBufferToRam:
    ; open expram
;    ld a,$08
;    ld (cartRamCtrl),a
      ; copy vwf buffer to target pos
      ld de,(vwfRamTileCurAddr)
      ld hl,vwfBuffer
      ld bc,bytesPerTile
      ldir
    ; close expram
;    xor a
;    ld (cartRamCtrl),a
    ret
  
  ; HL = VDP dstcmd
  vwfBufferToVdp:
    di
      ; set vdp dst
      ld c,vdpCtrlPort
      out (c),l
      nop
      out (c),h
      nop
      
      ld hl,vwfBuffer
      dec c
      .rept bytesPerTile
        push ix
        pop ix
        outi
      .endr
    ei
    
    ret
.ends

.slot 2
.section "vwf and friends" superfree
  ;===================================
  ; divides DE by BC
  ;
  ; BC = divisor
  ; DE = dividend
  ;
  ; returns:
  ; DE = quotient
  ; HL = remainder
  ;===================================
  divide16Bit:
    
    ld hl,$0000
    ld a,$10
    @divLoop:
      ; shift high bit of dividend into low bit of remainder
      sla e
      rl d
      rl l
      rl h
      
      ; subtract divisor
      or a
      sbc hl,bc
      jr c,+
        ; subtraction succeeded: 1 bit in result
        inc e
        
        ; result becomes new remainder
        ld h,b
        ld l,c
      +:
      
      dec a
      jr nz,@divLoop
    
    ret
  
  ;===================================
  ; converts a 16-bit value to
  ; binary-coded decimal (1 byte per
  ; digit)
  ;
  ; DE = value
  ;
  ; returns:
  ;     numberConvBuffer = BCD representation of number
  ;===================================
/*  bcdConv16Bit:
    ld bc,maxPrintingDigits
    -:
      push bc
        ; divide by 10
        ld bc,10
        call divide16Bit
        
        ; remainder = digit
        ld a,l
      pop bc
      
      dec c
      
      ; save to conversion buffer
      ld hl,numberConvBuffer
      add hl,bc
      ld (hl),a
      
      ld a,c
      or a
      jr nz,-
    ret*/
    
  ;===================================
  ; sends raw tile data to VDP
  ;
  ; B = number of tiles
  ; DE = src data pointer
  ; HL = VDP dstcmd
  ;===================================
  sendRawTilesToVdp:
    ; set vdp dst
    ld c,vdpCtrlPort
    out (c),l
    nop
    out (c),h
    nop
    ; write data to data port
    ex de,hl
    dec c
    ld a,b
    -:
      .rept bytesPerTile
        push ix
        pop ix
        outi
      .endr
      dec a
      jp nz,-
    ret
  
  ;===================================
  ; reads a 16-bit table
  ;
  ; A = index
  ; HL = table pointer
  ;
  ; returns:
  ;   HL = data
  ;===================================
  read16BitTable:
    read16BitTable_macro
    ret
  
  ;========================================
  ; A  = index
  ; HL = table pointer
  ;
  ; returns absolute pointer in HL
  ;========================================
  readOffsetTable:
    push de
      push hl
        call read16BitTable
      pop de
      add hl,de
    pop de
    
    ret
  
.ends

.slot 2
.section "vwf and friends 2" superfree APPENDTO "vwf and friends"
  ;========================================
  ; returns a free VWF expram addr in HL
  ;========================================
  allocVwfTile:
    ; FIXME: figure out next tile number
;    ld hl,(vwfExpRamTileNextAddr)
    
/*    push hl
    push de
      ld de,bytesPerTile
      add hl,de
      ld (vwfExpRamTileNextAddr),hl
      
      ; also update cbc address
      ld hl,(vwfCbcVramNextTarget)
      add hl,de
      ld (vwfCbcVramNextTarget),hl
    pop de
    pop hl*/
    
    push de
    push hl
      ld hl,(vwfRamTileCurAddr)
      ld de,bytesPerTile
      add hl,de
      ld (vwfRamTileCurAddr),hl
    pop hl
    pop de
    
    ld a,$FF
    ld (vwfAllocDoneFlag),a
    
    ret
    
  fullyResetVwf:
    call resetVwf
    
    push bc
    push hl
      ; reset pattern data putpos
      ld hl,(vwfRamTileBaseAddr)
      ; offset initial position by size of a tile so we get
      ; the right index on the initial allocation
      ; (now done by caller)
;      ld bc,bytesPerTile
;      or a
;      sbc hl,bc
      ld (vwfRamTileCurAddr),hl
      
      ; reset composition buffer pos
      ld hl,tilemapCompositionBuffer-2
      ld (vwfTilemapTargetAddr),hl
    pop hl
    pop bc
    
;    jp resetVwfRamPos
    ret
    
/*  resetVwfRamPos:
    ; FIXME?
    push hl
      ld hl,vwfExpRamTile_startAddr
      ld (vwfExpRamTileNextAddr),hl
      
      ; if a tile is already allocated, reset current address to start pos
      ; and add 32 to next address;
      ; otherwise, leave it at zero
      ld hl,vwfRamTileCurAddr+0
      ld a,(vwfRamTileCurAddr+1)
      or (hl)
      jr z,+
        ld hl,vwfExpRamTile_startAddr
        ld (vwfRamTileCurAddr),hl
        ld hl,vwfExpRamTile_startAddr+bytesPerTile
        ld (vwfExpRamTileNextAddr),hl
      +:
    pop hl
    ret*/
  
  ;========================================
  ; reset the VWF buffer
  ;========================================
  resetVwf:
    push hl
;    push de
    push bc
      xor a
      
      ; reset pixel x-pos
      ld (vwfPixelOffset),a
;      ld (vwfRamTileCurAddr+0),a
;      ld (vwfRamTileCurAddr+1),a
      ld (vwfBufferPending),a
      ld (vwfAllocDoneFlag),a
      
      ; allocation is marked as DONE.
      ; the base address is correct for the first tile.
;      dec a
;      ld (vwfAllocDoneFlag),a
      
      ; clear tile composition buffer
      ld hl,vwfBuffer
      ld b,bytesPerTile
      -:
        ld (hl),a
        inc hl
        djnz -
    pop bc
;    pop de
    pop hl
    ret
  
  sendVwfBuffer:
    push hl
    push bc
      
      ;=====
      ; allocate tile for buffer if unallocated
      ;=====
;      ld hl,vwfRamTileCurAddr+1
;      ld a,(vwfRamTileCurAddr+0)
;      or (hl)
      
      ld a,(vwfAllocDoneFlag)
      or a
      
      jr nz,+
        call allocVwfTile
;          ld (vwfRamTileCurAddr),hl
        call onTileAllocated_user
      +:
      
      ; get target tile index in HL
      ld hl,(vwfAllocArrayPointer)
      ld a,(hl)
      inc hl
      ld h,(hl)
      ld l,a
      ; probably unnecessary
      ; actually nope, it totally is! we need the priority bit
      ; set in some circumstances
      ld a,h
      and $01
      ld h,a
      
;      push hl
      
;      pop hl
      
      ; send buffer to RAM
      ;call vwfBufferToRam
      
      ; compute target tile VDP address (multiply index by 32)
      add hl,hl
      add hl,hl
      add hl,hl
      add hl,hl
      add hl,hl
      ; convert to VRAM write cmd
      ld a,h
      or $40
      ld h,a
      ; send buffer to VDP
      call vwfBufferToVdp
      
      ; increment count of pending tiles if in cbc mode
/*      ld a,(vwfCbcActiveFlag)
      or a
      jr z,+
        ld hl,pendingExpRamTileCount
        inc (hl)
      +:*/
      
      ; reset buffer pending flag
      xor a
      ld (vwfBufferPending),a
    
    pop bc
    pop hl
    ret
  
  ; DE = nametable data
  ; HL = target local coords
/*  writeVwfCharToNametable:
    ;=====
    ; if not targeting local nametable, send directly to VDP
    ;=====
;    ld a,(vwfLocalTargetFlag)
;    or a
;    jp z,writeLocalTileToNametable
    
    ;=====
    ; write to local nametable
    ;=====
    
    @localNametable:
    
    ; FIXME: make sure vwfLocalTargetCurrLineAddr gets set
    ; get current line address
    ld hl,(vwfLocalTargetCurrLineAddr)
    
    ; add x-offset * 2
    ld a,(printOffsetX)
    sla a
    add a,l
    ld l,a
    ld a,$00
    adc a,h
    ld h,a
    
    ; write
    ld (hl),e
    inc hl
    ld (hl),d
    
    ret*/
    
  
  sendVwfBufferIfPending:
    ld a,(vwfBufferPending)
    or a
    jr z,+
;      callExternal sendVwfBuffer
      call sendVwfBuffer
    +:
    ret
.ends

.bank 0 slot 0
.section "vwf data copy routines 1" free
  ;========================================
  ; B = src data bank
  ; C = AND mask for each existing byte in buffer
  ; DE = dst pointer
  ; HL = src data pointer
  ;========================================
  orToTileBuffer:
    ld a,(mapperSlot2Ctrl)
    push af
      
      ld a,b
      ld (mapperSlot2Ctrl),a
      ld b,bytesPerTile
      -:
        ld a,(de)
        and c
        or (hl)
        ld (de),a
        
        inc hl
        inc de
        djnz -
      
    pop af
    ld (mapperSlot2Ctrl),a
    ret
.ends
  
.bank 0 slot 0
.section "vwf data copy routines 2" free
  ;========================================
  ; B = src data bank
  ; DE = dst pointer
  ; HL = src data pointer
  ;========================================
  copyToTileBuffer:
    ld a,(mapperSlot2Ctrl)
    push af
      
      ld a,b
      ld (mapperSlot2Ctrl),a
      ld bc,bytesPerTile
      ldir
      
    pop af
    ld (mapperSlot2Ctrl),a
    ret
.ends

.ifexists "../out/font/font.inc"
  .include "out/font/font.inc"

  .slot 2
  .section "vwf and friends 3" superfree APPENDTO "vwf and friends"
    fontSizeTable:
      .incbin "out/font/sizetable.bin" FSIZE fontCharLimit
      .define numFontChars fontCharLimit-1

    fontRightShiftBankTbl:
      .db :font_rshift_00
      .db :font_rshift_01
      .db :font_rshift_02
      .db :font_rshift_03
      .db :font_rshift_04
      .db :font_rshift_05
      .db :font_rshift_06
      .db :font_rshift_07
    fontRightShiftPtrTbl:
      .dw font_rshift_00
      .dw font_rshift_01
      .dw font_rshift_02
      .dw font_rshift_03
      .dw font_rshift_04
      .dw font_rshift_05
      .dw font_rshift_06
      .dw font_rshift_07
    fontLeftShiftBankTbl:
      .db :font_lshift_00
      .db :font_lshift_01
      .db :font_lshift_02
      .db :font_lshift_03
      .db :font_lshift_04
      .db :font_lshift_05
      .db :font_lshift_06
      .db :font_lshift_07
    fontLeftShiftPtrTbl:
      .dw font_lshift_00
      .dw font_lshift_01
      .dw font_lshift_02
      .dw font_lshift_03
      .dw font_lshift_04
      .dw font_lshift_05
      .dw font_lshift_06
      .dw font_lshift_07
    
    charANDMasks:
      .db $00,$80,$C0,$E0,$F0,$F8,$FC,$FE,$FF
    
    
    
    ; C = target char
    printVwfChar:
      ; handle tile break
/*      ld a,c
      cp vwfTileBrIndex
      jr nz,+
        call sendVwfBufferIfPending
        call resetVwf
        ld hl,printOffsetX
        inc (hl)
        jp @done
      +: */
      
      ; vwf composition works like this:
      ; 1. OR left part of new character into composition buffer using
      ;    appropriate entry from right-shifted character tables.
      ;    (if vwfPixelOffset is zero, we can copy instead of ORing)
      ; 2. send composition buffer to VDP (allocating tile if not already done)
      ; 3. if composition buffer was filled, clear it.
      ; 4. if entire character has already been copied, we're done.
      ; 5. copy right part of new character directly to composition buffer using
      ;    appropriate entry from left-shifted character tables.
      ; 6. send composition buffer to VDP (allocating tile)
      
      ;=====
      ; look up size of target char
      ;=====
      
  ;    ld h,>fontSizeTable
  ;    ld a,c
  ;    ld l,a
      ld hl,fontSizeTable
      ld a,c
      ld e,a
      ld d,$00
      add hl,de
      
      ; get width
      ld a,(hl)
      ; if width is zero, we have nothing to do
      or a
      jp z,@done
      
      ld (vwfTransferCharSize),a
      
      ;=====
      ; transfer 1: OR left part of target char with buffer
      ;=====
      
      @transfer1:
      
      ; if char is space, no transfer needed
      ; (or it wouldn't be, except what if nothing else has been printed
      ; to the buffer yet? then the part we skipped won't get the background
      ; color)
  ;    ld a,c
  ;    cp vwfSpaceCharIndex
  ;    jr z,@transfer1Done
      
        push bc
          
          ;=====
          ; look up character data
          ;=====
          
          ; B = bank
          ld a,(vwfPixelOffset)
          ld e,a
          ld d,$00
          ld hl,fontRightShiftBankTbl
          add hl,de
          ld b,(hl)
          
          ; HL = pointer to char table base
          ld hl,fontRightShiftPtrTbl
          ; pixel offset *= 2
          sla e
  ;      rl d     ; pointless, will never shift anything in
          add hl,de
          ld e,(hl)
          inc hl
          ld d,(hl)
          ; add offset to actual char
          ld l,c
          ld h,$00
          ; * 32 for tile offset
          add hl,hl
          add hl,hl
          add hl,hl
          add hl,hl
          add hl,hl
          add hl,de
          
          ; can copy to buffer instead of ORing if pixel offset is zero
          ld a,(vwfPixelOffset)
          or a
          jr nz,+
            ld de,vwfBuffer
            call copyToTileBuffer
            jr @dataTransferred
          +:
          
          ; look up AND mask to remove low bits
          push hl
            ld hl,charANDMasks
            ld a,(vwfPixelOffset)
            ld e,a
            ld d,$00
            add hl,de
            ld c,(hl)
          pop hl
          
          ;=====
          ; OR to buffer
          ;=====
          
          ld de,vwfBuffer
          call orToTileBuffer
          
          @dataTransferred:
          
        pop bc
        
        ; check if border needs to be added to tile
;        call checkBorderTransfer
      
      @transfer1CompositionDone:
      
      ; determine right transfer shift amount
      ld a,(vwfPixelOffset)
      ld b,a
      sub $08
      neg
      ld (vwfTransferRight_leftShift),a
      
      ; advance vwfPixelOffset by transfer size
      ld a,(vwfTransferCharSize)
      add a,b
      
      cp $08
      jr nc,+
        ; if position in VWF buffer < 8, no second transfer needed
        
        ; send modified buffer if print speed nonzero (printing character-
        ; by-character); if text printing is instant, this just wastes time.
        ; also send if only printing a single character.
        push af
          call sendVwfBuffer
        pop af
        
        ld (vwfPixelOffset),a
        jr @done
      +:
      jr nz,+
        @filledBufferExactly:
        
        ; if we filled the VWF buffer exactly to capacity, then we need to
        ; send it, but don't need a right transfer or new tile allocation.
        ; instead, we reset the buffer in case more text is added.
        
        ; send modified buffer
        call sendVwfBuffer
        
        ; reset buffer
        call resetVwf
        
        jr @done
      +:
      
      ;=====
      ; buffer filled, and second transfer needed
      ;=====
      
      ; save updated pixel offset
      push af
        ; send modified buffer
        call sendVwfBuffer
        
        ; we'll add content for the second transfer, so set the
        ; buffer pending flag
        ld a,$FF
        ld (vwfBufferPending),a
      ; restore updated pixel offset
      pop af
      
      ; modulo by 8 to get new offset in next buffer (after second transfer)
      and $07
      ld (vwfPixelOffset),a
      ; new allocation needed
      xor a
;      ld (vwfRamTileCurAddr+0),a
;      ld (vwfRamTileCurAddr+1),a
      ld (vwfAllocDoneFlag),a
      ; move to next x-pos
      ld hl,printOffsetX
      inc (hl)
      
      ;=====
      ; transfer 2: copy right part of character to buffer
      ;=====
      
      @transfer2:
      
        ;=====
        ; look up character data
        ;=====
        
        ; B = bank
        ld a,(vwfTransferRight_leftShift)
        ld e,a
        ld d,$00
        ld hl,fontLeftShiftBankTbl
        add hl,de
        ld b,(hl)
        
        ; HL = pointer to char table base
        ld hl,fontLeftShiftPtrTbl
        ; pixel offset *= 2
        sla e
  ;      rl d     ; pointless, will never shift anything in
        add hl,de
        ld e,(hl)
        inc hl
        ld d,(hl)
        ; add offset to actual char
        ld l,c
        ld h,$00
        ; * 32 for tile offset
        add hl,hl
        add hl,hl
        add hl,hl
        add hl,hl
        add hl,hl
        add hl,de
        
        ;=====
        ; copy to buffer
        ;=====
        
        ld de,vwfBuffer
  ;      ld a,b
        call copyToTileBuffer
        
        ; check if border needs to be added to tile
;        call checkBorderTransfer
      
        ;=====
        ; send modified buffer
        ;=====
        
        call sendVwfBuffer
      
      @transfer2Done:
      
      ;=====
      ; finish up
      ;=====
      
      @done:
      
        ;=====
        ; update last-printed data
        ;=====
        
/*        ld a,(printOffsetX)
        ld (lastPrintOffsetX),a
        ld a,(printOffsetY)
        ld (lastPrintOffsetY),a
        
        ld a,(printBaseX)
        ld (lastPrintBaseX),a
        ld a,(printBaseY)
        ld (lastPrintBaseY),a*/
      
      ret
    
    checkBorderTransfer:
      jp checkBorderTransfer_user
  
/*  ;========================================
  ; BC = print area w/h
  ; DE = base x/y position
  ;========================================
  ; FIXME
  initVwfString:
      ; set up print position
      ld (printAreaWH),bc
      ld (printBaseXY),de
      ld (lastPrintBaseXY),de
      xor a
      ld (printOffsetX),a
      ld (printOffsetY),a
      ld (lastPrintOffsetX),a
      ld (lastPrintOffsetY),a
      
      ; reset VWF
      jp resetVwf
;      ret*/
  
/*  ;========================================
  ; A = string banknum
  ; BC = print area w/h
  ; DE = base x/y position
  ; HL = string pointer (slot 1)
  ;========================================
  ; FIXME
  startVwfString:
    push af
      call initVwfString
    pop af
    ld b,a
  ; !!! drop through
  ;========================================
  ; B = string banknum
  ; HL = string pointer (slot 1)
  ;========================================
  printVwfString:
    jp printVwfString_user
    
  printScriptNum:
    ; get target number
    ld hl,(inlinePrintNum)
    ld a,(inlinePrintDigitCount)
    ld b,a
    ld a,(inlinePrintShowLeadingZeroes)
    ld c,a
    
    call prepNumberString
    
    ; print result
    ld hl,numberPrintBuffer
    jp printVwfString
  
  numberPrintString:
    .db opInlineNumIndex
    .db terminatorIndex*/
  
  
    ;========================================
    ; convert a number to string encoding
    ; and place in numberPrintBuffer
    ;
    ; HL = number
    ; B = number of digits
    ;     0 = don't care, no space padding
    ; C = nonzero if leading zeroes
    ;     should be shown
    ;     (will be replaced with spaces if
    ;     nonzero)
    ;========================================
/*    prepNumberString:
      ; handle zero specially
      ld a,h
      or l
      jr nz,@numberIsNonzero
        @numberIsZero:
        
        ; if digit count iz zero, output string is "0"
        ld a,b
        or a
        ld a,$00+vwfDigitStartOffset
        jr nz,+
          ld (numberPrintBuffer+0),a
          ld a,terminatorIndex
          ld (numberPrintBuffer+1),a
          ret
        +:
        
        ; if digit count nonzero, fill with "0" or spaces (depending on C)
        ; to digit count
        
        ld a,c
        or a
        jr z,+
          ; C nonzero = show zeroes
          ld a,$00+vwfDigitStartOffset
          jr ++
        +:
          ; C zero = show spaces
          ld a,$00+vwfDigitSpaceOffset
        ++:
        
        ld de,numberPrintBuffer
        dec b
        jr z,+
        -:
          ld (de),a
          inc de
          djnz -
        +:
        ; final digit must be zero
        ld a,$00+vwfDigitStartOffset
        ld (de),a
        inc de
        ; write terminator
        ld a,terminatorIndex
        ld (de),a
        ret
      
      @numberIsNonzero:
      
      ;=====
      ; if number exceeds our capacity to display, show as a string of 9s
      ;=====
      
      ld a,b
      
      ; 10000
      cp $04
      jr nz,+
      push hl
        ld de,10000
        or a
        sbc hl,de
      pop hl
      jr c,++
        ld hl,9999
      ++:
      jr @overflowChecksDone
      +:
      
      ; 1000
      cp $03
      jr nz,+
      push hl
        ld de,1000
        or a
        sbc hl,de
      pop hl
      jr c,++
        ld hl,999
      ++:
      jr @overflowChecksDone
      +:
      
      ; 100
      cp $02
      jr nz,+
      push hl
        ld de,100
        or a
        sbc hl,de
      pop hl
      jr c,++
        ld hl,99
      ++:
      jr @overflowChecksDone
      +:
      
      ; 10
      cp $01
      jr nz,+
      push hl
        ld de,10
        or a
        sbc hl,de
      pop hl
      jr c,++
        ld hl,9
      ++:
;      jr @overflowChecksDone   ; not needed
      +:
      
      @overflowChecksDone:
      
      ;=====
      ; convert to BCD
      ;=====
      
      push bc
        ex de,hl
        call bcdConv16Bit
      pop bc
      
      ;=====
      ; convert raw BCD to VWF
      ;=====
      
      ; save digit setting
      push bc
        ; convert raw BCD digits to VWF encoding
        ld hl,numberConvBuffer
        ld de,numberPrintBuffer
        ld b,maxPrintingDigits
        -:
          ld a,(hl)
          add a,vwfDigitStartOffset
          ld (de),a
          inc hl
          inc de
          djnz -
      pop bc
      
      ; if digit count is zero, remove leading zeroes
      ; (since we handled zero specially, there must be at least one
      ; nonzero digit. unless the number exceeded 9999 in which case we
      ; have other problems anyway.)
      ld a,b
      or a
      jr nz,+
        ; locate first nonzero digit
        ld hl,numberPrintBuffer
        ld b,maxPrintingDigits
        -:
          ld a,(hl)
          cp $00+vwfDigitStartOffset
          jr nz,++
            inc hl
            djnz -
        ++:
        
        @removeLeadingDigits:
        
        ; copy backward
        ld de,numberPrintBuffer
        -:
          ld a,(hl)
          ld (de),a
          inc hl
          inc de
          djnz -
        
        ; add terminator
        ld a,terminatorIndex
        ld (de),a
        
        ; nothing left to do (no leading zeroes)
        ret
      +:
      
      @checkLeadingZeroes:
      ; if C zero, leading zeroes should be replaced with spaces
      ld a,c
      or a
      jr nz,+
        ld hl,numberPrintBuffer
        -:
          ld a,(hl)
          cp $00+vwfDigitStartOffset
          jr nz,++
            ld a,vwfDigitSpaceOffset
            ld (hl),a
            inc hl
            jr -
        ++:
      +:
      
      @checkDigitCount:
      
      ; if digit limit exists, shift to match
      ; if limit equal to max digit count, we're done
      ld a,b
      or a
      cp maxPrintingDigits
      jr nz,+
        ld a,terminatorIndex
        ld (numberPrintBuffer+maxPrintingDigits),a
        ret
      +:
      
      ; otherwise, get pointer to start of content we want to print
      ; in HL
      ; subtract target number of digits from max
      ld a,maxPrintingDigits
      sub b
      ; add to base buffer address
      ld hl,numberPrintBuffer
      ld e,a
      ld d,$00
      add hl,de
      jr @removeLeadingDigits
    
    .ends*/
  .endif

.ends


