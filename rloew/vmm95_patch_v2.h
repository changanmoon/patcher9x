#ifndef __VMM95_V2__PATCH_INCLUDED__
#define __VMM95_V2__PATCH_INCLUDED__

#include <patch.h>

const spatch_data_t vmm95_v2_data[] = {
	{0x00000124, 3, "\x18\xEE\x00", "\x88\x3D\x02"},
	{0x00005E92, 2, "\xC9\x8B", "\x35\xEE"},
	{0x0000614E, 2, "\xBC\x8B", "\x28\xEE"},
	{0x000294F5, 2, "\xE8\x03", "\x90\x0E"},
	{0x000294FC, 2, "\xE8\x03", "\x90\x0E"},
	{0x0002963B, 2, "\xD8\x27", "\xD0\x91"},
	{0x00029643, 2, "\xD8\x27", "\xD0\x91"},
	{0x00029660, 1, "\x68", "\xB8"},
	{0x00029665, 3, "\xE8\x66\x0E", "\xE9\xAE\xB7"},
	{0x000299C8, 1, "\x03", "\x0A"},
	{0x000299ED, 1, "\x30", "\xA0"},
	{0x00034E18, 3, "\x00\x00\x00", "\x05\x18\xED"},
	{0x00034E1D, 11, "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00", "\x50\xE8\xAD\x56\xFF\xFF\xE9\x42\x48\xFF\xFF"},
	{0, 0, NULL, NULL}
};

const spatch_t vmm95_v2_sp = {328188, vmm95_v2_data};

#endif /*__VMM95_V2__PATCH_INCLUDED__*/
