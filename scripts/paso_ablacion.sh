#!/usr/bin/env bash
# Validación completa + piloto corto de ia_opt para un paso de la ablación.
# Uso: scripts/paso_ablacion.sh <etiqueta>   (p. ej. 0_base, 1_sin_memset)
set -euo pipefail
cd "$(dirname "$0")/.."
et=$1; d=results/ablacion/$et
rm -rf "$d"; mkdir -p "$d"
make -s clean && make -s all

for n in 512 1024 2048 4096; do for k in 3 5 7 11; do
    bin/bench ia_opt data/images/damma_$n.pgm data/kernels/gauss_$k.txt 1 "$d/validacion.csv" 1 2 4 8 16
done; done
awk -F, 'NR>1{t++; if($7!=1)f++; if($8+0>m)m=$8+0} END{printf "validacion: %d configs, %d invalidas, err_max=%.3e\n",t,f+0,m}' \
    "$d/validacion.csv" | tee "$d/validacion_resumen.txt"

for cfg in "4096 3" "4096 11" "512 11"; do
    set -- $cfg
    bin/bench ia_opt data/images/damma_$1.pgm data/kernels/gauss_$2.txt 3 "$d/piloto.csv" 1 4 16
done
python3 - "$d/piloto.csv" <<'PY' | tee "$d/piloto_resumen.txt"
import csv, sys, statistics as st
g = {}
for r in csv.DictReader(open(sys.argv[1])):
    g.setdefault((int(r["imagen_px"]), int(r["ksize"]), int(r["hilos"])), []).append(float(r["tiempo_ms"]))
for k, v in g.items():
    print(f"{k[0]}px k={k[1]} hilos={k[2]}: {st.mean(v):.3f} ms ± {st.stdev(v):.3f}")
PY
