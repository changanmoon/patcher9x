;/*
; ==============================================================================
; Patch originally created by SweetLow (https://github.com/LordOfMice/Tools/)
; ==============================================================================
;   Bug fix VMM.VXD from Windows 98(SE) & ME on handling >4GiB addresses
;   and description of problems with resource manager on newer BIOSes.
; 
;   Due to a bug in VMM.VXD (early loop exit when processing
;   BIOS Int 15h Fn E820h “Memory Map” function instead of skipping
;   the corresponding line), the Resource Manager does not accept lines
;   of memory ranges <4GiB that are located after a memory range >4GiB
;   (EXAMPLES\B460BIOS.TXT):
;   
;   ...
;   0000000100000000 - 000000085F800000 : 000000075F800000 1 (Available), 29G 504M
;   000000009A000000 - 000000009F800000 : 0000000005800000 2 (Reserved), 88M
;   ...
;   
;   However, this address range is really NOT free, and when a resource manager
;   tries to use it (for example, when rebalancing device resources), a classic
;   resource conflict occurs.
;   
;   When this problem was discovered in 2020, a workaround was written to sort
;   return addresses in ascending order (EXAMPLES\B460SORT.TXT),
;   so that the bug stops appearing. See the BURNMEM package.
;   However, this solution is not ideal because it consumes DOS memory
;   and it is necessary to be aware that the problem exists on a particular
;   system and remember that it must be explicitly bypassed.
;   
;   This patch eliminates both the problem itself and the need to use
;   additional software to bypass it.
;   
;   JFYI, information about occupied resources is usually returned as well by
;   BIOS PnP or ACPI, so there might not be a problem, but on systems
;   with these BIOSes BIOS PnP is usually not present at all, and ACPI does
;   not work satisfactorily, so without them the only source of
;   occupied memory is Int 15h Fn E820h "Memory Map".
;
;   Note: patched procedure name is "AddACPIRegions" and it's taken from
;   Me's 'vmm.sym' debug file
;*/

use32
#ifndef ME
org 0xC004AFA8
#else
org 0xC0025D60
#endif

#if defined(relocate) && !defined(nofuncrelocate)
  #define dcode(_ptr) not _ptr
#else
  #define dcode(_ptr) _ptr
#endif

AddACPIRegions:                                 ;
    push    0                                   ;6A00
    push    14h                                 ;6A14
    db 0xCD,0x20,0xA9,0x00,0x01,0x00            ;CD20A9000100 - VMMcall _Allocate_Temp_V86_Data_Area
    add     esp,8                               ;83C408
    or      eax,eax                             ;0BC0
    je      loc_0004B079                        ;0F84BC000000
    mov     esi,eax                             ;8BF0
    shr     eax,4                               ;C1E804
    mov     edi,eax                             ;8BF8
    db 0xCD,0x20,0x03,0x00,0x01,0x00            ;CD2003000100 - VMMcall Get_Sys_VM_Handle
    mov     ebp,[ebx+8]                         ;8B6B08
    sub     esp,6Ch                             ;83EC6C
    push    edi                                 ;57
    lea     edi,[esp+4]                         ;8D7C2404
    db 0xCD,0x20,0x8D,0x00,0x01,0x00            ;CD208D000100 - VMMcall Save_Client_State
    pop     edi                                 ;5F
    db 0xCD,0x20,0x82,0x00,0x01,0x00            ;CD2082000100 - VMMcall Begin_Nest_V86_Exec
    mov     dword [ebp+10h],0                   ;C7451000000000
loc_0004AFE9:                                   ;
    mov     [ebp+38h],di                        ;66897D38
    mov     dword [ebp],0                       ;C7450000000000
    mov     dword [ebp+18h],14h                 ;C7451814000000
    mov     dword [ebp+14h],534D4150h           ;C7451450414D53
    mov     dword [ebp+1Ch],0E820h              ;C7451C20E80000
    mov     eax,15h                             ;B815000000
    db 0xCD,0x20,0x84,0x00,0x01,0x00            ;CD2084000100 - VMMcall Exec_Int 
    test    dword [ebp+2Ch],1                   ;F7452C01000000
    jnz     loc_0004B05E                        ;7541
    cmp     dword [ebp+1Ch],534D4150h           ;817D1C50414D53
    jnz     loc_0004B05E                        ;7538
    cmp     dword [ebp+18h],14h                 ;837D1814
    jb      loc_0004B05E                        ;7232
    xor     eax,eax                             ;33C0
    cmp     [esi+4],eax                         ;394604
#ifdef originalcode
    jnz     loc_0004B05E                        ;752B
#else
    jnz     loc_0004B058
#endif    
    cmp     [esi+0Ch],eax                       ;39460C
#ifdef originalcode
    jnz     loc_0004B05E                        ;7526
#else
    jnz     loc_0004B058
#endif
    cmp     [esi+8],eax                         ;394608
#ifdef originalcode
    jz      loc_0004B05E                        ;7421
#else
    jz      loc_0004B058
#endif
    mov     eax,[esi]                           ;8B06
    mov     edx,[esi+8]                         ;8B5608
    dec     edx                                 ;4A
#ifndef ME
    add     edx,eax                             ;03D0
    push    0                                   ;6A00
    push    dword [dcode(0x000033AC)]           ;FF35AC930300
    push    edx                                 ;52
    push    eax                                 ;50
    db 0xCD,0x20,0x25,0x00,0x33,0x00            ;CD2025003300 - VxDcall _CONFIGMG_Add_Range
    add     esp,10h                             ;83C410
#else
    mov     ecx,[esi+10h]                       ;8B4E10
    add     edx,eax                             ;03D0
    push    ecx                                 ;51
    push    edx                                 ;52
    push    eax                                 ;50
    call    dcode(0xC002619D)                   ;E895030000 - call _ProcessE820Range
    add     esp,0Ch                             ;83C40C
#endif
loc_0004B058:
    cmp     dword [ebp+10h],0                   ;837D1000
    jnz     loc_0004AFE9                        ;758B
loc_0004B05E:                                   ;
    db 0xCD,0x20,0x86,0x00,0x01,0x00            ;CD2086000100 - VMMcall End_Nest_Exec
    push    esi                                 ;56
    lea     esi,[esp+4]                         ;8D742404
    db 0xCD,0x20,0x8E,0x00,0x01,0x00            ;CD208E000100 - VMMcall Restore_Client_State
    pop     esi                                 ;5E
    add     esp,6Ch                             ;83C46C
    db 0xCD,0x20,0xAA,0x00,0x01,0x00            ;CD20AA000100 - VMMcall _Free_Temp_V86_Data_Area
loc_0004B079:                                   ;
    ret                                         ;C3
