
.slot 2
.section "vwf user-implemented code" superfree APPENDTO "vwf and friends"
  ; A = target character
  ; B = current script bank (need not preserve)
  ; HL = next script srcaddr (must preserve!)
/*  handleVwfOp:
    cp vwfNumberWithZeroIndex
    jr nz,+
      push hl
        ; print pending buffer number with trailing zero
        call printBcdBuf
        ; print trailing zero
        ld c,vwfDigitBaseIndex
      
        call printVwfChar
      pop hl
      ret
    +:
    
    cp vwfNumberOpIndex
    jr nz,+
      push hl
        ; print pending buffer number
        call printBcdBuf
      pop hl
      ret
    +:
    
    cp vwfNumberOp1DigitIndex
    jr nz,+
      @op1digit:
      ; retrieve the target address
      ; high byte
      call bankedFetch
      ld d,a
      inc hl
      ; low byte
      call bankedFetch
      ld e,a
      inc hl
      
      ; fetch target digit byte
      ld a,(de)
      
      add a,vwfDigitBaseIndex
      ld c,a
      push hl
        call printVwfChar
      pop hl
      ret
    +:
    
    ; literal
    push hl
      ld c,a
      call printVwfChar
    pop hl
    ret
  
  printBcdBuf:
    ld hl,numberBufferStart
    ld b,numberBufferSize
    
    ; skip leading zeroes
    @leadingZeroCheckLoop:
      ld a,(hl)
      or a
      jr nz,@leadingZeroCheckDone
      inc hl
      djnz @leadingZeroCheckLoop
    @leadingZeroCheckDone:
    
    ; if number is zero, print one zero and ret
    ld a,b
    or a
    jr nz,+
      ld c,vwfDigitBaseIndex
      jp printVwfChar
    +:
    
    @digitPrintLoop:
      ; fetch byte
      ld a,(hl)
      inc hl
      ; add vwf digit base index
      add a,vwfDigitBaseIndex
      
      ; print the target character
      ld c,a
      
      push hl
      push bc
        call printVwfChar
      pop bc
      pop hl
      
      djnz @digitPrintLoop
      
    ret */
  
  ; FIXME
  ; HL = allocated tile ram addr
  onTileAllocated_user:
    ; increment count of tiles to be transferred
    ld hl,vwfPendingTileCounter
    inc (hl)
    
    ; assign new tile to pending tile offset
    ld de,(vwfTilemapTargetAddr)
    ld hl,(vwfAllocArrayPointer)
    
    ; preincrement for initialization-related reasons
    inc hl
    inc hl
    inc de
    inc de
    ld (vwfAllocArrayPointer),hl
    ld (vwfTilemapTargetAddr),de
    
    ;=====
    ; write new tile id to tilemap buffer
    ;=====
    
    ; low byte
    ld a,(hl)
    inc hl
    ld (de),a
    inc de
    
    ; high byte
    ld a,(hl)
    inc hl
    ld (de),a
    inc de
    
    ;=====
    ; save updated tilemap pos
    ;=====
    
;    ld (vwfTilemapTargetAddr),de
;    ld (vwfAllocArrayPointer),hl
    
    
/*      ; increment count of tiles to be transferred if not doing
      ; cbc printing
      ld a,(vwfCbcActiveFlag)
      or a
      jr nz,+
        ld hl,pendingExpRamTileCount
        inc (hl)
      +:
      
      ; assign new tile to pending tile offset
      ld de,(vwfTilemapTargetAddr)
      ld hl,currentTextTileIndex
      ld a,(hl)
      inc (hl)
      
      ; save tile to C
      ld c,a
      
      ;=====
      ; check if we need to start assigning to new tile area
      ;=====
      
      ld a,(textWindowType)
      or a
      cp 1
      jr z,@leftWindow
      cp 2
      jr z,@bottomWindow
      
      @rightWindow:
        ld a,c
        
        ; check if already in new area
        cp <rightBoxNewSpaceTileNum
        jr nc,@newAreaCheckDone
        
        ; check if at end of old area
        cp (<rightBoxOldSpaceEndTileNum)-1
        jr c,@newAreaCheckDone
        
        ld a,<rightBoxNewSpaceTileNum
        ld (hl),a
        
        jr @newAreaCheckDone
        
      @leftWindow:
        ld a,c
        
        ; check if already in new area
        cp <leftBoxNewSpaceTileNum
        jr nc,@newAreaCheckDone
        
        ; check if at end of old area
        cp (<leftBoxOldSpaceEndTileNum)-1
        jr c,@newAreaCheckDone
        
        ld a,<leftBoxNewSpaceTileNum
        ld (hl),a
        
        jr @newAreaCheckDone
      
      @bottomWindow:
        ; do nothing
      
      @newAreaCheckDone:
      
      ;=====
      ; write new tile id to tilemap buffer
      ;=====
      
      ; retrieve tilenum
      ld a,c
      
      ; low byte
      ld (de),a
      inc de
      ; high byte
      ld a,$01
      ld (de),a
      inc de
      
      ;=====
      ; save updated tilemap pos
      ;=====
      
      ld (vwfTilemapTargetAddr),de
      
      ;=====
      ; if cbc mode on, also copy to front buffer
      ;=====
      
      ld a,(vwfCbcActiveFlag)
      or a
      jr z,+
        ; HL = backbuffer pos + 0x480 to get frontbuffer pos
        dec de
        dec de
        ld hl,tilemapBufferMaxSize
        add hl,de
        ex de,hl
        
        ; write to frontbuffer
        ld a,c
        ld (de),a
        inc de
        ld a,$01
        ld (de),a
      +:*/
    
    ret

  ;================================
  ; if any VWF tiles are in use
  ; somewhere in the program,
  ; but are not currently used in
  ; the VDP nametable, flag them
  ; as allocated
  ;================================
  markHiddenVwfTilesAllocated_user:
    ret
  
  ;=====
  ; check if we printed into the tile containing the right border
  ; of the window. if so, we need to draw the border onto the
  ; tile.
  ; (done primarily to allow us to "cheat" so we can squeeze
  ; seven-character party member names into what was supposed to be
  ; a four-tile space)
  ;=====
  checkBorderTransfer_user:
    ret
  
  ;================================
  ; check for special printing
  ; sequences.
  ;
  ; A = character index
  ; HL = pointer to data immediately following character
  ;================================
  ; FIXME?
  printVwfChar_user:
/*    ; check for linebreak
    cp vwfBrIndex
    jr nz,+
      call sendVwfBufferIfPending
      
      ; reset VWF
      call fullyResetVwf
      
      @vdpLinebreak:
      ; reset X
      xor a
      ld (printOffsetX),a
      
      ; Y++
      ld a,(printOffsetY)
;          add a,$02
      inc a
      ld (printOffsetY),a
      
      ld a,(vwfLocalTargetFlag)
      or a
      jr z,++
        @localLinebreak:
        push hl
          ld hl,(vwfLocalTargetCurrLineAddr)
          
          ; add nametable tile width * 2 to current line address to
          ; get next line's address
          ld a,(vwfLocalTargetW)
          sla a
          ld e,a
          ld d,$00
          add hl,de
          
          ld (vwfLocalTargetCurrLineAddr),hl
        pop hl
        jr @done
      ++:
      
/*      ; if printing to VDP and we exceeded the height of the printing area,
      ; we have to shift the bottom rows up
      ld a,(printAreaH)
      ld e,a
      ld a,(printOffsetY)
      cp e
      jr c,@done
        call doLineBreakLineShift
        jr @done
    +:*/
    
    ; check for box clear
/*    cp vwfBoxClearIndex
    jr nz,+
      @boxClear:
      
      ; deallocate box area
      ld hl,(printBaseXY)
      ld bc,(printAreaWH)
      call deallocVwfTileArea
      
      ; clear box (fill with tile 0101)
      push hl
        ld bc,(printAreaWH)
        ld de,vwfClearTile
        ld hl,(printBaseXY)
        call clearNametableArea
        
        ; reset print offset
        ld hl,$0000
        ld (printOffsetXY),hl
      pop hl
      
      jr @done
    +: */
    
    ; check for new inline number print op
/*    cp opInlineNumIndex
    jr nz,+
      @newNumOp:
      push hl
        call printScriptNum
      pop hl
      jr @done
    +:*/
    
    push bc
    push de
    push hl
      ld c,a
      call printVwfChar
    pop hl
    pop de
    pop bc
    
    @done:
    ret
  
  ;================================
  ; print the number conversion
  ; buffer
  ;================================
  printNumConversionBuffer:
    
    push bc
    push de
    push hl
      
      ld hl,vwfNumConversionBuffer
      ld b,vwfNumConversionBufferSize
      -:
        ld a,(hl)
        inc hl
        
        ; don't print leading zeroes
        cp oldSpaceIndex
        jr z,+
          add a,vwfDigitOffsetFromOld
          ld c,a
          
          push bc
          push hl
            call printVwfChar
          pop hl
          pop bc
        +:
        
        djnz -
      
    pop hl
    pop de
    pop bc
    
    ret
  
  ;================================
  ; print the number conversion
  ; buffer with 8px digits and
  ; leading spaces
  ;================================
  printNumConversionBufferBig:
    
    push bc
    push de
    push hl
      
      ld hl,vwfNumConversionBuffer
      ld b,vwfNumConversionBufferSize
      -:
        ld a,(hl)
        inc hl
        
        add a,vwfBigDigitOffsetFromOld
        ld c,a
        
        push bc
        push hl
          call printVwfChar
        pop hl
        pop bc
        
        djnz -
      
    pop hl
    pop de
    pop bc
    
    ret
  
  ; FIXME?
  ; B = string bank
  ; HL = string pointer
  printVwfString_user:
    ret
  
  ;================================
  ; print the number conversion
  ; buffer with 8px digits and
  ; leading spaces
  ;================================
  printNumConversionBuffer2DigitBig:
    
    push bc
    push de
    push hl
      
      ld hl,vwfNumConversionBuffer
      ld b,2
      -:
        ld a,(hl)
        inc hl
        
        add a,vwfBigDigitOffsetFromOld
        ld c,a
        
        push bc
        push hl
          call printVwfChar
        pop hl
        pop bc
        
        djnz -
      
    pop hl
    pop de
    pop bc
    
    ret
  
.ends
