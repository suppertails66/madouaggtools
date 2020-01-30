
;=====
; madoua
;=====


.define vwfMemcharIndex $1B
.define vwfNum2DigitBigIndex $1C
.define vwfNum5DigitBigIndex $1D
.define vwfNum5DigitIndex $1E
.define vwfTileBrIndex $1F
.define vwfCursorOnIndex $CC
.define vwfCursorOffIndex $88

;.define vwfDigitBaseIndex $30
; add this to a number in the old font to get the corresponding
; character index in the new one
.define vwfDigitOffsetFromOld $2E
.define vwfBigDigitOffsetFromOld $C0

.define vwfWaitIndex $FD
.define vwfFlagsIndex $FE
.define vwfBrIndex $FF
.define vwfTerminatorIndex $00
;.define tilemapBufferMaxSize $480

.define oldSpaceIndex $01

; FIXME
.define numberBufferStart $0000
.define numberBufferSize 0

.define vwfNumConversionBufferSize 5


; enum of target printing types (see vwfTargetType)
.define vwfTargetType_cutscene $00
.define vwfTargetType_rightBox $01
.define vwfTargetType_leftBox  $02

.define vwfBoxTextGrpBufferBaseAddr $C700

.define currentCutsceneScriptIndex $C8BB

;=====
; madoua routines
;=====

.define savePageRegs $1E32
.define restorePageRegs $1E3E

.define queueVdpTransfer $B47B
.define waitForPendingVdpTransfers $B4B6
.define waitForScriptInput $A0BC
.define frameAniUpdate $008E


/*.define vwfExpRamTile_startAddr $8400
.define vwfCbcBaseTextVdpAddr $71C0

;=====
; madou3 routines
;=====

;.define waitVblank $0D3D
.define waitVblank $08C3
;.define runRegion0Script $2690
.define runRegion0Script $2701
.define runRegion1Script $26FD
.define runRegion2Script $26F9
.define runRegion3Script $26F5
.define runRegion4Script $26F1

.define runScript $270A
.define runScriptNoClear $26E6

.define handleNextScriptCmd $2787

; A = tile count
; HL = srcaddr (expram)
; DE = dstaddr
;.define sendPendingExpRamTiles $321E
.define sendPendingExpRamTiles $315A

.define sendRawGrpDataToVdp $3169

.define copyCharToFrontBuffer $29D9

;=====
; madou3 ram
;=====

; TODO: check if this is right
;.define vdpTransferFlags $C011
.define vdpTransferFlags $C031

.define expRamToVdpQueueSize $C01A
.define expRamTransferDst $C01C
.define expRamTransferSrc $C01E
.define tilemapSettingsFlags $C031
.define textWindowType $c058
.define textLineBaseDst $C05A
.define pendingExpRamTileCount $c05D
.define currentTextTilesExpRamTarget $c05e
.define currentTextTilesVdpTarget $c060
.define textTilemapBackBufferPtr $c062
.define oldCbcTimer $C064
.define currentTextExpRamPos $c078
.define currentTextTileIndex $c07c
.define cutsceneSubTimer $C340
.define cutsceneMainTimer $C341

.define tilemapDirtyArray $C040

;.define numberBufferStart $C051
.define numberBufferStart $c022
.define numberBufferSize 4

.define leftBoxOrigMaxTiles 21
.define rightBoxOrigMaxTiles 21
; these tiles are a part of the nametable that isn't used during regular
; gameplay, so they can safely be used for additional text in the standard
; left/right boxes
.define leftBoxNewSpaceTileNum $1EA
.define rightBoxNewSpaceTileNum $1F1
.define leftBoxNewSpaceVdpAddr ($1EA*bytesPerTile)|$4000
.define rightBoxNewSpaceVdpAddr ($1F1*bytesPerTile)|$4000
.define leftBoxOldSpaceEndTileNum $1A3
.define rightBoxOldSpaceEndTileNum $1B8
.define leftBoxOldSpaceEndVdpAddr ($1A3*bytesPerTile)|$4000
.define rightBoxOldSpaceEndVdpAddr ($1B8*bytesPerTile)|$4000*/

 