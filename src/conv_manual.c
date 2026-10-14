#include "conv.h"

#include <omp.h>

/* Definida en third_party/Optimized-2D-Image-Convolution-master/extra.c
 * (Vineet Jain, 2013). Se usa sin modificar. */
int conv2D(float *in, float *out, const int data_size_X, const int data_size_Y,
           float *kernel, const int kernel_x, const int kernel_y);

void convolve_manual(const float *in, float *out, int width, int height,
                     const float *kernel, int ksize, int nthreads) {
    omp_set_num_threads(nthreads);
    /* conv2D no declara const pero no escribe in ni kernel. */
    conv2D((float *)in, out, width, height, (float *)kernel, ksize, ksize);
}
