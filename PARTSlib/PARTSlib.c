/*
 * Author: Hans Liljestrand <hans@liljestrand.dev>
 * Copyright: Secure Systems Group, Aalto University, https://ssg.aalto.fi
 *
 * This code is released under Apache 2.0 license
 */
#include <elf.h>

void __pauth_pac_main_args(int argc, char **argv, uintptr_t type_id)
{
    for (int i = 0; i < argc; i++) {
        asm(""
                "pacda %[ptr], %[mod];"
                "str %[out], [%[ptr]];"
                :
                : [ptr] "r" (argv[i]),
                  [mod] "r" (type_id),
                  [out] "r" (&argv[i])
                : );
    }
}
