#ifndef __VMM95_V1__PATCH_INCLUDED__
#define __VMM95_V1__PATCH_INCLUDED__

#include <patch.h>

const spatch_data_t vmm95_v1_data[] = {
	{0x00000124, 3, "\x50\xED\x00", "\xC0\x3C\x02"},
	{0x00005DED, 2, "\x00\x8B", "\x60\xED"},
	{0x00005E41, 2, "\x0D\x8B", "\x6D\xED"},
	{0x00029465, 2, "\xE8\x03", "\x90\x0E"},
	{0x0002946C, 2, "\xE8\x03", "\x90\x0E"},
	{0x000295AB, 2, "\xD8\x27", "\xD0\x91"},
	{0x000295B3, 2, "\xD8\x27", "\xD0\x91"},
	{0x000295D0, 1, "\x68", "\xB8"},
	{0x000295D5, 3, "\xE8\x66\x0E", "\xE9\x76\xB7"},
	{0x00029938, 1, "\x03", "\x0A"},
	{0x0002995D, 1, "\x30", "\xA0"},
	{0x00034D50, 3, "\x00\x00\x00", "\x05\x0C\xED"},
	{0x00034D55, 11, "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00", "\x50\xE8\xE5\x56\xFF\xFF\xE9\x7A\x48\xFF\xFF"},
	{0, 0, NULL, NULL}
};

const spatch_t vmm95_v1_sp = {328188, vmm95_v1_data};

#endif /*__VMM95_V1__PATCH_INCLUDED__*/
