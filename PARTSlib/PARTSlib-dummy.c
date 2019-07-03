/*
 * Author: Hans Liljestrand <hans@liljestrand.dev>
 * Copyright: Secure Systems Group, Aalto University, https://ssg.aalto.fi
 *
 * This code is released under Apache 2.0 license
 */

#include <stdio.h>
#include <elf.h>

/* #define DEBUG_PRINTF(...) printf(__VA_ARGS__) */
#define DEBUG_PRINTF(...)

#define pauth_sign(type, key, addr, mod) \
	pauth_common(addr, mod)

void *pauth_common(void *pointer_to_pac, void *pointer_type_id) {
    uintptr_t __addr = (uintptr_t)pointer_to_pac;
    uintptr_t __mod = (uintptr_t)pointer_type_id;

    DEBUG_PRINTF("using modifier %lx\n", __mod);
    DEBUG_PRINTF("applying modifier on %lx -> %lx (mod: %lx)\n", __addr, *(uintptr_t*)__addr, __mod);

    uintptr_t retval = __addr;

    retval = retval ^ 0x3ffff0003ffff;
    retval = retval ^ 0x3f003f003f003f;
    retval = retval ^ 0x8001800180018001;
    retval = retval ^ __mod;

    DEBUG_PRINTF("                 got %lx\n", retval);
    return (void*)retval;
}

void __pauth_pac_main_args(int argc, char **argv, uintptr_t type_id)
{
    for (int i = 0; i < argc; i++) {
        argv[i] = pauth_sign(d, a, argv[i], (void*)type_id);
    }
}
