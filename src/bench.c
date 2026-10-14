/* Arnés: bench <variante> <imagen.pgm> <kernel.txt> <repeticiones> <csv> <hilos...>
 * Carga/convierte imagen y kernel, calcula la referencia con convolve_seq y,
 * por cada número de hilos: 1 calentamiento descartado + N repeticiones
 * medidas. Solo se cronometra la llamada a convolve_* (omp_get_wtime). */
#include <math.h>
#include <omp.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "conv.h"
#include "io.h"

#define TOLERANCIA 1e-4

typedef void (*conv_fn)(const float *, float *, int, int, const float *, int, int);

static const struct { const char *nombre; conv_fn fn; } VARIANTES[] = {
    {"seq", convolve_seq},
    {"ia", convolve_ia},
    {"ia_opt", convolve_ia_opt},
    {"manual", convolve_manual},
};

static double error_max(const float *a, const float *b, size_t n) {
    double e = 0.0;
    for (size_t i = 0; i < n; i++) {
        double d = fabs((double)a[i] - (double)b[i]);
        if (isnan(d)) return INFINITY;
        if (d > e) e = d;
    }
    return e;
}

int main(int argc, char **argv) {
    if (argc < 7) {
        fprintf(stderr, "Uso: %s <seq|ia|ia_opt|manual> <imagen.pgm> <kernel.txt> "
                        "<repeticiones> <salida.csv> <hilos> [hilos...]\n", argv[0]);
        return 1;
    }
    conv_fn fn = NULL;
    for (size_t v = 0; v < sizeof VARIANTES / sizeof VARIANTES[0]; v++)
        if (strcmp(argv[1], VARIANTES[v].nombre) == 0) fn = VARIANTES[v].fn;
    if (!fn) { fprintf(stderr, "variante desconocida: %s\n", argv[1]); return 1; }

    int w, h, ks;
    float *in = pgm_read_float(argv[2], &w, &h);
    float *kernel = kernel_read(argv[3], &ks);
    int reps = atoi(argv[4]);
    if (!in || !kernel || reps < 1) return 1;

    size_t n = (size_t)w * h;
    float *ref = calloc(n, sizeof(float));
    float *out = malloc(n * sizeof(float));
    convolve_seq(in, ref, w, h, kernel, ks, 1);

    FILE *csv = fopen(argv[5], "a");
    if (!csv) { perror(argv[5]); return 1; }
    fseek(csv, 0, SEEK_END);
    if (ftell(csv) == 0)
        fprintf(csv, "variante,imagen_px,ksize,hilos,repeticion,tiempo_ms,valido,error_max\n");

    int invalidos = 0;
    for (int a = 6; a < argc; a++) {
        int hilos = atoi(argv[a]);
        for (int r = 0; r <= reps; r++) { /* r == 0: calentamiento, se descarta */
            memset(out, 0, n * sizeof(float));
            double t0 = omp_get_wtime();
            fn(in, out, w, h, kernel, ks, hilos);
            double t1 = omp_get_wtime();
            double e = error_max(out, ref, n);
            int valido = e <= TOLERANCIA;
            if (r == 0) continue;
            if (!valido) invalidos++;
            fprintf(csv, "%s,%d,%d,%d,%d,%.6f,%d,%.3e\n", argv[1], w, ks, hilos, r,
                    (t1 - t0) * 1e3, valido, e);
        }
        fflush(csv);
    }
    fclose(csv);
    free(in); free(kernel); free(ref); free(out);
    if (invalidos)
        fprintf(stderr, "AVISO: %s %dpx k=%d: %d repeticiones fuera de tolerancia\n",
                argv[1], w, ks, invalidos);
    return 0;
}
