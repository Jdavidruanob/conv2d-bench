#!/usr/bin/env bash
# Genera las imágenes de prueba (PGM P5) y los kernels gaussianos.
# Fuente: data/source/damma.pgm (1000x1278, del MP2). Se recorta el cuadrado
# central de 1000x1000 y se reescala (Lanczos) a 512/1024/2048/4096.
set -euo pipefail
cd "$(dirname "$0")/.."

SRC=data/source/damma.pgm
for n in 512 1024 2048 4096; do
    magick "$SRC" -colorspace Gray -gravity center -crop 1000x1000+0+0 +repage \
        -filter Lanczos -resize "${n}x${n}!" -depth 8 "pgm:data/images/damma_${n}.pgm"
done

python3 - <<'EOF'
import math
# Gaussiano con sigma por defecto de OpenCV para tamaño k:
# sigma = 0.3*((k-1)*0.5 - 1) + 0.8. Se guarda ya normalizado (suma 1).
for k in (3, 5, 7, 11):
    s = 0.3 * ((k - 1) * 0.5 - 1) + 0.8
    c = k // 2
    g = [[math.exp(-((x - c) ** 2 + (y - c) ** 2) / (2 * s * s)) for x in range(k)] for y in range(k)]
    tot = sum(map(sum, g))
    with open(f"data/kernels/gauss_{k}.txt", "w") as f:
        f.write(f"{k}\n")
        for row in g:
            f.write(" ".join(f"{v / tot:.9e}" for v in row) + "\n")
EOF
ls -l data/images data/kernels
