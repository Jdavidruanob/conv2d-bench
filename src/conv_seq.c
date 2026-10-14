#include "conv.h"

/* Secuencial de referencia: recorre la salida por filas (acceso contiguo) y,
 * en lugar de un if por vecino, recorta los rangos del kernel en los bordes
 * (equivale a relleno de ceros). */
void convolve_seq(const float *in, float *out, int width, int height,
                  const float *kernel, int ksize, int nthreads) {
    (void)nthreads;
    const int c = ksize / 2;
    for (int y = 0; y < height; y++) {
        const int j0 = (y - c < 0) ? c - y : 0;
        const int j1 = (y + c >= height) ? c + (height - 1 - y) : 2 * c;
        for (int x = 0; x < width; x++) {
            const int i0 = (x - c < 0) ? c - x : 0;
            const int i1 = (x + c >= width) ? c + (width - 1 - x) : 2 * c;
            float acc = 0.0f;
            for (int j = j0; j <= j1; j++) {
                const long base = (long)(y + j - c) * width + (x - c);
                /* kernel volteado: el vecino (dy,dx) usa k[c-dy][c-dx] */
                const int kbase = (2 * c - j) * ksize + 2 * c;
                for (int i = i0; i <= i1; i++)
                    acc += kernel[kbase - i] * in[base + i];
            }
            out[(long)y * width + x] += acc;
        }
    }
}
