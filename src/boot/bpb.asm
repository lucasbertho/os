; bpb.asm
; author: Lucas Bertho
; date: 10/21/2022

; create a BIOS parameter block (BPB) to emulate a DOS 4.0 EBPB 1.44MB floppy.
; this data block is necessary on real hardware when booting from USB devices
; that use Floppy Drive Emulation (FDD).

[bits 16]
bpb:
    times 3-($-$$)      db 0x90
    OEMname:            db "mkfs.fat"   ; create a BIOS parameter block (BPB) to emulate a DOS 4.0 EBPB 1.44MB floppy.
    bytesPerSector:     dw 512          ; this data block is necessary on real hardware when booting from USB devices
    sectPerCluster:     db 1            ; that use Floppy Drive Emulation (FDD).
    reservedSectors:    dw 1
    numFAT:             db 2
    numRootDirEntries:  dw 224
    numSectors:         dw 2880
    mediaType:          db 0xf0
    numFATsectors:      dw 9
    sectorsPerTrack:    dw 18
    numHeads:           dw 2
    numHiddenSectors:   dd 0
    numSectorsHuge:     dd 0
    driveNum:           db 0
    reserved:           db 0
    signature:          db 0x29
    volumeID:           dd 0x2d7e5a1a
    volumeLabel:        db "DRIVE      "
    fileSysType:        db "FAT12   "