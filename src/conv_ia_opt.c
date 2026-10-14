/* CONV_STUB: variante "ia_opt" pendiente (versión ia + ajustes manuales).
 * run_all.sh omite cualquier variante cuyo archivo contenga la marca CONV_STUB;
 * bórrela al reemplazar el cuerpo. */
#include "conv.h"

#include <stdio.h>
#include <stdlib.h>

void convolve_ia_opt(const float *in, float *out, int width, int height,
                     const float *kernel, int ksize, int nthreads) {
    (void)in; (void)out; (void)width; (void)height;
    (void)kernel; (void)ksize; (void)nthreads;
    fprintf(stderr, "convolve_ia_opt: variante no implementada todavía\n");
    abort();
}
