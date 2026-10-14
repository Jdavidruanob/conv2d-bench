#include "io.h"

#include <stdio.h>
#include <stdlib.h>

static int read_header_int(FILE *f, int *v) {
    int c = fgetc(f);
    while (c == '#' || c == ' ' || c == '\t' || c == '\n' || c == '\r') {
        if (c == '#')
            while (c != '\n' && c != EOF) c = fgetc(f);
        c = fgetc(f);
    }
    if (c == EOF) return 0;
    ungetc(c, f);
    return fscanf(f, "%d", v) == 1;
}

float *pgm_read_float(const char *path, int *width, int *height) {
    FILE *f = fopen(path, "rb");
    if (!f) { perror(path); return NULL; }
    char magic[3] = {0};
    int maxval;
    if (fread(magic, 1, 2, f) != 2 || magic[0] != 'P' || magic[1] != '5' ||
        !read_header_int(f, width) || !read_header_int(f, height) ||
        !read_header_int(f, &maxval) || maxval <= 0 || maxval > 255) {
        fprintf(stderr, "%s: no es un PGM P5 de 8 bits\n", path);
        fclose(f);
        return NULL;
    }
    fgetc(f); /* un único espacio en blanco tras maxval */
    size_t n = (size_t)(*width) * (size_t)(*height);
    unsigned char *raw = malloc(n);
    float *img = malloc(n * sizeof(float));
    if (!raw || !img || fread(raw, 1, n, f) != n) {
        fprintf(stderr, "%s: datos incompletos\n", path);
        free(raw); free(img); fclose(f);
        return NULL;
    }
    fclose(f);
    for (size_t i = 0; i < n; i++) img[i] = (float)raw[i] / 255.0f;
    free(raw);
    return img;
}

float *kernel_read(const char *path, int *ksize) {
    FILE *f = fopen(path, "r");
    if (!f) { perror(path); return NULL; }
    if (fscanf(f, "%d", ksize) != 1 || *ksize < 1 || *ksize % 2 == 0) {
        fprintf(stderr, "%s: ksize inválido (debe ser impar)\n", path);
        fclose(f);
        return NULL;
    }
    int n = (*ksize) * (*ksize);
    float *k = malloc((size_t)n * sizeof(float));
    double sum = 0.0;
    for (int i = 0; i < n; i++) {
        if (fscanf(f, "%f", &k[i]) != 1) {
            fprintf(stderr, "%s: faltan coeficientes\n", path);
            free(k); fclose(f);
            return NULL;
        }
        sum += k[i];
    }
    fclose(f);
    /* Como normalize() del repo, pero sumando en double: el original suma en
     * int y truncaría kernels con coeficientes fraccionarios. */
    if (sum != 0.0)
        for (int i = 0; i < n; i++) k[i] = (float)(k[i] / sum);
    return k;
}
