#ifndef IO_H
#define IO_H

/* Lee PGM binario (P5, maxval <= 255) y devuelve float en [0,1] (pixel/255). */
float *pgm_read_float(const char *path, int *width, int *height);

/* Lee kernel: primera línea ksize, luego ksize*ksize valores. Lo normaliza
 * (divide entre la suma si la suma != 0). */
float *kernel_read(const char *path, int *ksize);

#endif
