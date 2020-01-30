
;===============================================
; macros
;===============================================

.macro callExternal
  ld a,(mapperSlot2Ctrl)
  push af
  
    ld a,:\1
    ld (mapperSlot2Ctrl),a
    call \1
  
  pop af
  ld (mapperSlot2Ctrl),a
.endm

.macro callExternalHardcoded
  ld a,(mapperSlot2Ctrl)
  push af
  
    ld a,\1
    ld (mapperSlot2Ctrl),a
    call \2
  
  pop af
  ld (mapperSlot2Ctrl),a
.endm

; 14 bytes total
.macro doBankedCallSlot2
  ld (bankedCallA),a
  ld (bankedCallHL),hl
  ld a,:\1
  ld hl,\1
  call bankedCallSlot2
.endm

; 14 bytes total
.macro doBankedJumpSlot2
  ld (bankedCallA),a
  ld (bankedCallHL),hl
  ld a,:\1
  ld hl,\1
  jp bankedCallSlot2
.endm

; 8 bytes total
.macro doBankedCallSlot2NoParams
  ld a,:\1
  ld hl,\1
  call bankedCallSlot2
.endm

; 8 bytes total
.macro doBankedJumpSlot2NoParams
  ld a,:\1
  ld hl,\1
  jp bankedCallSlot2
.endm

; 14 bytes total
.macro doBankedCallSlot1
  ld (bankedCallA),a
  ld (bankedCallHL),hl
  ld a,:\1
  ld hl,\1
  call bankedCallSlot1
.endm

; 14 bytes total
.macro doBankedJumpSlot1
  ld (bankedCallA),a
  ld (bankedCallHL),hl
  ld a,:\1
  ld hl,\1
  jp bankedCallSlot1
.endm

; 8 bytes total
.macro doBankedCallNoParamsSlot1
  ld a,:\1
  ld hl,\1
  call bankedCallSlot1
.endm

; 8 bytes total
.macro doBankedJumpNoParamsSlot1
  ld a,:\1
  ld hl,\1
  jp bankedCallSlot1
.endm

; 8 bytes total
.macro doBankedJumpNoParamsSlot2
  ld a,:\1
  ld hl,\1
  jp bankedCallSlot2
.endm

; TODO: reimplement
;.macro read8BitTable
;  rst $20
;.endm

.macro read16BitTable_macro
;  rst $28
  push de
    ld e,a
    ld d,$00
    add hl,de
    add hl,de
    ld a,(hl)
    inc hl
    ld h,(hl)
    ld l,a
  pop de
.endm

.macro startLocalPrint ARGS baseAddr, nametableW, nametableH, x, y
  ld hl,baseAddr
  ld (vwfLocalTargetBaseAddr),hl
  
  ld hl,baseAddr+(nametableW*2*y)+(2*x)
  ld (vwfLocalTargetCurrLineAddr),hl
  
  ld a,nametableW
  ld (vwfLocalTargetW),a
  
  ld a,nametableH
  ld (vwfLocalTargetH),a
  
  ld a,$FF
  ld (vwfLocalTargetFlag),a
.endm

.macro startLocalHalfPrint ARGS baseAddr, nametableW, nametableH, x, y
  startLocalPrint baseAddr nametableW nametableH x y
  ld (vwfLocalHalfPrintFlag),a
.endm

.macro startLocalPrintNonFixed ARGS nametableW, nametableH, x, y
  ld (vwfLocalTargetBaseAddr),hl
  
  ld de,(nametableW*2*y)+(2*x)
  add hl,de
  ld (vwfLocalTargetCurrLineAddr),hl
  
  ld a,nametableW
  ld (vwfLocalTargetW),a
  
  ld a,nametableH
  ld (vwfLocalTargetH),a
  
  ld a,$FF
  ld (vwfLocalTargetFlag),a
.endm

.macro startLocalHalfPrintNonFixed ARGS nametableW, nametableH, x, y
  startLocalPrintNonFixed nametableW nametableH x y
  ld (vwfLocalHalfPrintFlag),a
.endm

.macro moveLocalPrint ARGS baseAddr, nametableW, nametableH, x, y
  ld hl,baseAddr+(nametableW*2*y)+(2*x)
  ld (vwfLocalTargetCurrLineAddr),hl
.endm

.macro endLocalPrint
  xor a
  ld (vwfLocalTargetFlag),a
.endm

.macro endLocalHalfPrint
  endLocalPrint
  ld (vwfLocalHalfPrintFlag),a
.endm

; set up a value for inline script printing
; HL = value
.macro setUpNumberPrint ARGS digits, showLeadingZeroes
;  ld hl,value
;  ld hl,(valueAddr)
  ld (inlinePrintNum),hl
  
  ld a,digits
  ld (inlinePrintDigitCount),a
  
  ld a,showLeadingZeroes
  ld (inlinePrintShowLeadingZeroes),a
.endm

.macro openTempBankSlot2
  ld a,(mapperSlot2Ctrl)
  push af
    ld a,\1
    ld (mapperSlot2Ctrl),a
.endm

.macro openTempBankSlot2_B
  ld a,(mapperSlot2Ctrl)
  push af
    ld a,b
    ld (mapperSlot2Ctrl),a
.endm

.macro closeTempBankSlot2
  pop af
  ld (mapperSlot2Ctrl),a
.endm

;.macro orig_read16BitTable
;  rst $20
;.endm

; B = tile count
; DE = srcptr
; HL = dstcmd
.macro rawTilesToVdp_macro
  ; set vdp dst
  ld c,vdpCtrlPort
  out (c),l
  out (c),h
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
.endm

; B = tile count
; DE = srcptr
; HL = dstcmd
.macro rawTilesToVdp_macro_safe
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
.endm

; B = tile count
; DE = srcptr
; HL = srccmd
.macro rawTilesFromVdp_macro
  ; set vdp src
  ld c,vdpCtrlPort
  out (c),l
  nop
  out (c),h
  nop
  ; read data from data port
  ex de,hl
  dec c
  ld a,b
  -:
    .rept bytesPerTile
      push ix
      pop ix
      ini
    .endr
    dec a
    jp nz,-
.endm

; BC = tile count
; DE = srcptr
; HL = dstcmd
.macro rawTilesToVdp_big_macro
  push bc
    ; set vdp dst
    ld c,vdpCtrlPort
    out (c),l
    nop
    out (c),h
    nop
  pop bc
  ; write data to data port
  ex de,hl
  -:
    push bc
      ld c,vdpDataPort
      .rept bytesPerTile
        push ix
        pop ix
        outi
      .endr
    pop bc
    
    dec bc
    ld a,b
    or c
    jr nz,-
.endm

;.macro old_read16BitTable
;  rst $28
;.endm

;===============================================
; code
;===============================================

.bank 0 slot 0
.section "bankedCall 1" free
  ; makes a call to a slot 2 bank
  ;
  ; A = banknum
  ; HL = call target
  bankedCallSlot2:
    ; save banknum
    ld (scratchLo),a
    
    ; save old banknum
    ld a,(mapperSlot2Ctrl)
    push af
      ; switch to new bank
      ld a,(scratchLo)
      ld (mapperSlot2Ctrl),a
      
      call bankedCallCommon
    ; restore old bank
    pop af
    ld (mapperSlot2Ctrl),a
    
    @done:
    ; restore carry flag
    ld a,(scratchHi)
    or a        ; test A and reset carry
    jr z,+
      ccf
    +:
    ; restore A
    ld a,(scratchLo)
    
    ret
  
  ; makes a call to a slot 1 bank
  ;
  ; A = banknum
  ; HL = call target
  bankedCallSlot1:
    ; save banknum
    ld (scratchLo),a
    
    ; save old banknum
    ld a,(mapperSlot1Ctrl)
    push af
      ; switch to new bank
      ld a,(scratchLo)
      ld (mapperSlot1Ctrl),a
      
      call bankedCallCommon
    ; restore old bank
    pop af
    ld (mapperSlot1Ctrl),a
    jr bankedCallSlot2@done
.ends

.bank 0 slot 0
.section "bankedCall 2" free
  bankedCallCommon:
    ; save target routine address
    ld (scratch),hl
    
    ; push our return address
    ld hl,@retAddr
    push hl
    
    ; jump to target routine
    
    ; push target to stack so we can ret into it
    ld hl,(scratch)
    push hl
    ; load parameters
    ld a,(bankedCallA)
    ld hl,(bankedCallHL)
    ; ret into target
    ret
    
    @retAddr:
    
    ; preserve value returned in A
    ld (scratchLo),a
    ; preserve carry
    ld a,$00
    jr nc,+
      dec a
    +:
    ld (scratchHi),a
    
    ret
.ends

/*.bank 0 slot 0
.section "getPointerBank" free
  ;========================================
  ; returns in A the bank a given pointer
  ; corresponds to (for the currently
  ; loaded slot configuration).
  ; may also return special codes:
  ; * ramBankIdentifier (FE) if pointer
  ;   is in RAM
  ;
  ; HL = pointer
  ;
  ; returns:
  ;   C = bank or return code
  ;========================================
  getPointerBank:
    ;=====
    ; determine which bank we're targeting
    ; based on srcptr in HL
    ;=====
    ld a,h
    
    ; C000-FFFF = RAM
    cp $C0
    jr nc,@targetRam
    
    ; 8000-BFFF = slot 2
    ; FIXME: if expansion RAM is in use, you're on your own!
    cp $80
    jr nc,@targetSlot2
    
    ; 4000-7FFF = slot 1
    cp $40
    jr nc,@targetSlot1
    
      @targetSlot0:
        ld a,(mapperSlot0Ctrl)
        jr @done
      
      @targetSlot1:
        ld a,(mapperSlot1Ctrl)
        jr @done
      
      @targetSlot2:
        ld a,(mapperSlot2Ctrl)
        jr @done
    
      @targetRam:
        ld a,ramBankIdentifier
    
    @done:
    ld c,a
    ret
.ends */

.bank 0 slot 0
.section "bankedFetch" free
  ;========================================
  ; returns in A the byte at (B:HL)
  ;
  ; B = bank
  ; HL = slot 2 pointer
  ;
  ; returns:
  ;   A = read byte
  ;========================================
  bankedFetch:
    push bc
      ld a,(mapperSlot2Ctrl)
      push af
        ld a,b
        ld (mapperSlot2Ctrl),a
        ld a,(hl)
        ld b,a
      pop af
      ld (mapperSlot2Ctrl),a
      ld a,b
    pop bc
    ret
.ends


