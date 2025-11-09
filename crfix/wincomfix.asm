; ==============================================================================
; MIT No Attribution
;
; Copyright 2025 Jaroslav Hensl <emulator@emulace.cz>
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
; THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
; IN THE SOFTWARE.
;
; ==============================================================================
;
org 100h

; Address with free space to insert patched code
patch_pos  = 04500h
; jump address from original win.com to continue execiting
return_pos = 01073h

jmp cr_cleanup ; 3 bytes

rb (patch_pos-03h)

db "PATCH",1   ; reserve 6 bytes (revision 1)
cr_cleanup:
mov     di,di ; 2b nop (hot patch)
push    eax
push    ecx
push    edx
push    ebx

; when we're in V86 don't clean
smsw    ax                     ; return first 16 bits of CR0, but by unprivileged instruction
and     eax,1                  ; bit 0 = protected mode
jnz     skip_clean             ; 1 - in PM, skip cleaning

; check CPUID support
pushfd                         ; push eflags on the stack
pop     eax                    ; pop them into eax
mov     ebx, eax               ; save to ebx for restoring afterwards
xor     eax, 0200000h          ; toggle bit 21
push    eax                    ; push the toggled eflags
popfd                          ; pop them back into eflags
pushfd                         ; push eflags
pop     eax                    ; pop them back into eax
cmp     eax, ebx               ; see if bit 21 was reset
jz      skip_clean             ; if no then skip all

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; The cleanup
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  mov     eax, cr0
  and     eax, 0E005003Fh      ; clear reserved flags (eg. on i486 reserved) on CR0
  mov     cr0, eax

  xor     eax, eax
  mov     cr2, eax             ; clear CR2
  mov     cr3, eax             ; clear CR3

  mov     eax, cr4
  and     eax, 040207h         ; clear in CR4 all except VME PVI TSD + OSFXSR OSXSAVE (SIMD95)
  mov     cr4, eax

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MSR cleanup
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; check if cpuid returns some useful informations
  xor     eax, eax
  cpuid
  cmp     eax, 02h
  jl      ship_efer

  ; call CPUID and check for MSR support
  mov     eax,1
  cpuid
  test    edx, 020h            ; 5th bit - MSR
  jz      ship_efer

  ; check if CPU support Long Mode, eg. has EFER MSR
  mov     eax, 080000001h      ; Extended processor signature and feature bits
  cpuid
  test    edx, 020000000h      ; 29th bit - Long Mode
  jz      ship_efer

    ; clear IA32_EFER
    xor   eax, eax
    xor   edx, edx
    mov   ecx, 0C0000080h
    wrmsr

    ; update info string
    call  near @f
    @@:
    pop   bx
    add   bx, (msg_more - @b)
    mov   [cs:bx],   byte ' '
    mov   [cs:bx+1], byte '+'
    mov   [cs:bx+2], byte ' '

  ship_efer:

  ; same as 'mov dx,msg' but position independent
  call near @f
  @@:
  pop    dx
  add    dx, (msg - @b)

        ; DOS print
  mov     ah,09h
  int     21h

skip_clean:

pop ebx
pop edx
pop eax
pop eax
jmp code_end

msg:      db "win.com: reset CR0-CR4"
msg_more: db 0Dh,0Ah,"$MSR",0Dh,0Ah,'$'

rb 3 ; pad code block to 16 bytes

code_end:
  jmp return_pos
