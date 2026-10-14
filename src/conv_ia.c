/* CONV_STUB: variante "ia" pendiente (se pegará la versión generada por IA).
 * run_all.sh omite cualquier variante cuyo archivo contenga la marca CONV_STUB;
 * bórrela al reemplazar el cuerpo. */
#include "conv.h"

#include <stdio.h>
#include <stdlib.h>

void convolve_ia(const float *in, float *out, int width, int height,
                 const float *kernel, int ksize, int nthreads) {
    (void)in; (void)out; (void)width; (void)height;
    (void)kernel; (void)ksize; (void)nthreads;
    fprintf(stderr, "convolve_ia: variante no implementada todavía\n");
    abort();
}
