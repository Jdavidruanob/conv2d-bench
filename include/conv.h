#ifndef CONV_H
#define CONV_H

/* Interfaz común de las 4 variantes.
 * in/out: imagen W x H en float [0,1], fila mayor (out[y*width + x]).
 * kernel: ksize x ksize, ksize impar, ya normalizado.
 * Convolución verdadera (kernel volteado), bordes con relleno de ceros.
 * out llega en ceros (lo garantiza el arnés). */
void convolve_seq(const float *in, float *out, int width, int height,
                  const float *kernel, int ksize, int nthreads);
void convolve_ia(const float *in, float *out, int width, int height,
                 const float *kernel, int ksize, int nthreads);
void convolve_ia_opt(const float *in, float *out, int width, int height,
                     const float *kernel, int ksize, int nthreads);
void convolve_manual(const float *in, float *out, int width, int height,
                     const float *kernel, int ksize, int nthreads);

#endif
