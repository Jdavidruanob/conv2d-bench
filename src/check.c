/* Verificación cruzada de corrección (no mide tiempos):
 *  1. seq vs reference() de ref.c del repo (recorrido por columnas, sin tocar).
 *  2. conv2D del repo (vía convolve_manual) vs seq, con 1/2/4/8/16 hilos.
 * Uso: check <kernel.txt> <imagen.pgm> [imagen.pgm ...] */
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "conv.h"
#include "io.h"

int reference(float *in, float *out, int data_size_X, int data_size_Y,
              float *kernel, int kernel_x, int kernel_y);

static double error_max(const float *a, const float *b, size_t n, size_t *pos) {
    double e = 0.0;
    *pos = 0;
    for (size_t i = 0; i < n; i++) {
        double d = fabs((double)a[i] - (double)b[i]);
        if (isnan(d)) d = INFINITY;
        if (d > e) { e = d; *pos = i; }
    }
    return e;
}

int main(int argc, char **argv) {
    if (argc < 3) {
        fprintf(stderr, "Uso: %s <kernel.txt> <imagen.pgm> [imagen.pgm ...]\n", argv[0]);
        return 1;
    }
    int ks;
    float *kernel = kernel_read(argv[1], &ks);
    if (!kernel) return 1;
    const int hilos[] = {1, 2, 4, 8, 16};
    int fallos = 0;

    for (int a = 2; a < argc; a++) {
        int w, h;
        float *in = pgm_read_float(argv[a], &w, &h);
        if (!in) return 1;
        size_t n = (size_t)w * h, pos;
        float *seq = calloc(n, sizeof(float));
        float *otro = malloc(n * sizeof(float));
        convolve_seq(in, seq, w, h, kernel, ks, 1);

        memset(otro, 0, n * sizeof(float));
        reference(in, otro, w, h, kernel, ks, ks);
        double e = error_max(seq, otro, n, &pos);
        printf("%-10s %5dx%-5d k=%-2d seq vs ref.c          err_max=%.3e %s\n",
               "ref.c", w, h, ks, e, e <= 1e-4 ? "OK" : "FALLA");
        fallos += e > 1e-4;

        for (size_t t = 0; t < sizeof hilos / sizeof hilos[0]; t++) {
            memset(otro, 0, n * sizeof(float));
            convolve_manual(in, otro, w, h, kernel, ks, hilos[t]);
            e = error_max(otro, seq, n, &pos);
            printf("%-10s %5dx%-5d k=%-2d hilos=%-2d vs seq     err_max=%.3e %s",
                   "manual", w, h, ks, hilos[t], e, e <= 1e-4 ? "OK" : "FALLA");
            if (e > 1e-4)
                printf("  (primer peor pixel x=%zu y=%zu: esperado %.6f, obtenido %.6f)",
                       pos % w, pos / w, seq[pos], otro[pos]);
            printf("\n");
            fallos += e > 1e-4;
        }
        free(in); free(seq); free(otro);
    }
    free(kernel);
    return fallos ? 2 : 0;
}
