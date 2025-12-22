Bug fix VMM.VXD from Windows 98(SE) & ME on handling >4GiB addresses
and description of problems with resource manager on newer BIOSes.

Contents:
VMM_4GRes_Fix.exe - VMM.VXD bug fix
EXAMPLES\ - Examples of BIOSes causing problems with resource manager

For your information, logs of Int 15h Fn E820h "Memory Map" in EXAMPLES\
directory are obtained by EXTINFO.EXE utility from BURNMEM package:
https://github.com/LordOfMice/Tools/blob/master/burnmem.zip

Installation:
1. Extract VMM.VXD
either from the current Windows instance %WINDIR%\SYSTEM\VMM32\VMM.VXD
(save it somewhere)
or from the installation package if VMM.VXD is not in
%WINDIR%\SYSTEM\VMM32\ (note that there it is called VMM32.VXD
and you need to rename it to VMM.VXD).
2. Patch it
VMM_4GRes_Fix.exe VMM.VXD VMM.VXD
in case of success the result will be:

Pattern Found @xxxxxxxxx, Patched
Trying to Save "VMM.VXD"... Success

where xxxxxxxxxx is the real address for your version of VMM.VXD
3. Copy the patched version to %WINDIR%\SYSTEM\VMM32\

Uninstall:
1. If you saved %WINDIR%\SYSTEM\VMM32\VMM.VXD then restore it.
2. If you extracted VMM.VXD from the installation package then remove
%WINDIR%\SYSTEM\VMM32\VMM.VXD

If you will install any update (QFE) changing
VMM.VXD you need to repeat the installation procedure!

Problem description:

Problem 1 in Windows (solved by this patch)
-------------------------------------------
Examples - EXAMPLES\B460BIOS.TXT, B75_BIOS.TXT

Due to a bug in VMM.VXD (early loop exit when processing
BIOS Int 15h Fn E820h “Memory Map” function instead of skipping
the corresponding line), the Resource Manager does not accept lines
of memory ranges <4GiB that are located after a memory range >4GiB
(EXAMPLES\B460BIOS.TXT):

...
0000000100000000 - 000000085F800000 : 000000075F800000 1 (Available), 29G 504M
000000009A000000 - 000000009F800000 : 0000000005800000 2 (Reserved), 88M
...

However, this address range is really NOT free, and when a resource manager
tries to use it (for example, when rebalancing device resources), a classic
resource conflict occurs.

When this problem was discovered in 2020, a workaround was written to sort
return addresses in ascending order (EXAMPLES\B460SORT.TXT),
so that the bug stops appearing. See the BURNMEM package.
However, this solution is not ideal because it consumes DOS memory
and it is necessary to be aware that the problem exists on a particular
system and remember that it must be explicitly bypassed.

This patch eliminates both the problem itself and the need to use
additional software to bypass it.

JFYI, information about occupied resources is usually returned as well by
BIOS PnP or ACPI, so there might not be a problem, but on systems
with these BIOSes BIOS PnP is usually not present at all, and ACPI does
not work satisfactorily, so without them the only source of
occupied memory is Int 15h Fn E820h "Memory Map".

Problem 2 in BIOS
-----------------
Examples - EXAMPLES\B75_BIOS.TXT, H77_BIOS.TXT, B460BIOS.TXT, P45_BIOS.TXT
(and apparently most UEFI BIOSes in general).
If you study the full list (it is convenient to do it on the sorted
version, EXAMPLES\B460BIOS.TXT is taken as an example), you may note
that there are skipped memory areas (RAM) both at the end of the range
of RAM addresses <4GiB (Top Of Mem) and >4GiB (Top Of Mem 2):
000000009F800000 - 00000000A0000000
000000085F800000 - 0000000860000000
Probably these are areas used by Intel ME and SMM (in these examples).
Addresses >4GiB are not a problem for Windows 9x, but an occupied,
but skipped <4GiB address causes the problem already described above
- resource conflict.
Especially unpleasant is the fact that this address is just the lowest
of the "free" and the probability of an attempt to use it by the system
is maximum.

This problem cannot be resolved automatically, but
can be manually solved using the standard Windows 9x feature
as Reserve Resources in Device Manager.

JFYI, this bug really exists not only in Int 15h Fn E820h "Memory Map",
but also in results of description of occupied resources in ACPI for example,
so the bug is potentially subject to modern NT-like systems too. But the bug
has much lower probability to appear there because of difference in behavior
of resource managers of Windows 9x and Windows NT. The latter tries to use
the initial (obtained at boot) resources of the device for as long
as possible without conflict with other devices, even after the device is
turned off and then turned on.

Note that this problem exists not only in BIOS
for B460, but also in BIOSes for P45, B75 and H77.
I.e. this BIOS bug has not been fixed for decades!

--- SweetLow ---
