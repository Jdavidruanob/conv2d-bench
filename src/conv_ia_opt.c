#include <omp.h>
#include <string.h>

#define XBLOCK 1024

void convolve_ia_opt(const float *in, float *out, int width, int height,
                 const float *kernel, int ksize, int nthreads)
{
    const int c = ksize / 2;

    #pragma omp parallel for num_threads(nthreads) proc_bind(spread) schedule(static)
    for (int y = 0; y < height; y++) {
        float *orow = out + (size_t)y * width;
        int dy_lo = (y - c < 0) ? -y : -c;
        int dy_hi = (y + c >= height) ? height - 1 - y : c;

        for (int x0 = 0; x0 < width; x0 += XBLOCK) {
            int x1 = x0 + XBLOCK < width ? x0 + XBLOCK : width;

            for (int dy = dy_lo; dy <= dy_hi; dy++) {
                const float *irow = in + (size_t)(y + dy) * width;
                const float *krow = kernel + (c - dy) * ksize;
                for (int dx = -c; dx <= c; dx++) {
                    const float w = krow[c - dx];
                    int xs = x0 > -dx ? x0 : -dx;
                    int xe = x1 < width - dx ? x1 : width - dx;
                    const float *src = irow + dx;
                    #pragma omp simd
                    for (int x = xs; x < xe; x++)
                        orow[x] += w * src[x];
                }
            }
        }
    }
}
