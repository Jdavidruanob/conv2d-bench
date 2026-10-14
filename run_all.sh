#!/usr/bin/env bash
# Compila todo con los mismos flags y corre el benchmark completo.
#   ./run_all.sh                    -> todas las variantes disponibles, 30 repeticiones
#   REPS=3 VARIANTES="seq manual" OUT=results/pilot/crudo.csv ./run_all.sh   -> piloto
# Una variante se omite si su archivo src/conv_<v>.c contiene la marca CONV_STUB.
set -euo pipefail
cd "$(dirname "$0")"

REPS=${REPS:-30}
VARIANTES=${VARIANTES:-"seq ia ia_opt manual"}
OUT=${OUT:-results/crudo.csv}
TAMANOS=${TAMANOS:-"512 1024 2048 4096"}
KERNELS=${KERNELS:-"3 5 7 11"}
HILOS=${HILOS:-"1 2 4 8 16"}

make -s clean && make -s all
[ -f data/images/damma_4096.pgm ] || scripts/gen_data.sh

mkdir -p env "$(dirname "$OUT")"
{
    echo "== fecha";      date -Iseconds
    echo "== uname -a";   uname -a
    echo "== gcc --version"; gcc --version
    echo "== flags";      grep '^CFLAGS' Makefile
    echo "== lscpu";      lscpu
    echo "== OMP_*";      env | grep '^OMP_' || echo "(ninguna)"
} > env/entorno.txt

rm -f "$OUT"
inicio=$(date +%s)
for v in $VARIANTES; do
    if grep -q CONV_STUB "src/conv_$v.c"; then
        echo "omitiendo $v (stub)"; continue
    fi
    hilos=$HILOS
    [ "$v" = seq ] && hilos=1
    for n in $TAMANOS; do
        for k in $KERNELS; do
            t0=$(date +%s.%N)
            bin/bench "$v" "data/images/damma_${n}.pgm" "data/kernels/gauss_${k}.txt" \
                "$REPS" "$OUT" $hilos
            printf "%-7s %5spx k=%-2s hilos=[%s]  %.1f s\n" "$v" "$n" "$k" "$hilos" \
                "$(echo "$(date +%s.%N) - $t0" | bc)"
        done
    done
done
echo "Total: $(( $(date +%s) - inicio )) s -> $OUT"
