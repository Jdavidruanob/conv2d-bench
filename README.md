# conv2d-bench — Benchmark de convolución 2D paralela en C

Parcial de Programación Paralela (300CIP013), PUJ Cali. Mide el impacto de
la paralelización de una convolución 2D comparando 4 variantes en C:

| Variante | Archivo | Origen |
|---|---|---|
| `seq` | `src/conv_seq.c` | Secuencial de referencia (1 hilo), recorrido por filas |
| `ia` | `src/conv_ia.c` | Paralela generada por IA — **pendiente (stub)** |
| `ia_opt` | `src/conv_ia_opt.c` | `ia` + ajustes manuales — **pendiente (stub)** |
| `manual` | `src/conv_manual.c` → `third_party/.../extra.c` | `conv2D` de [vinee109/Optimized-2D-Image-Convolution](https://github.com/vinee109/Optimized-2D-Image-Convolution) (Vineet Jain, 2013; OpenMP + SSE), copiado intacto; solo hay un wrapper |

## Especificación común

- Imagen gris de 1 canal, `float` en [0,1] (`pixel/255`), convertida fuera de la medición.
- Kernel cuadrado impar `float`, normalizado (dividido entre su suma si ≠ 0).
- Convolución verdadera (kernel volteado), bordes con relleno de ceros.
- Interfaz: `void convolve_<v>(const float *in, float *out, int width, int height, const float *kernel, int ksize, int nthreads);`
- `out` se pone en ceros antes de cada llamada, fuera de la medición.
- Validación: error absoluto máximo por píxel vs `seq` ≤ 1e-4.

## Datos

- Imágenes: `data/source/damma.pgm` (1000x1278, del MP2) → recorte central
  1000x1000 → reescalado Lanczos a 512, 1024, 2048 y 4096 px, PGM P5
  (`scripts/gen_data.sh`). 2048 y 4096 son ampliaciones: el contenido es
  más suave, pero el costo de la convolución depende solo de W·H·k².
- Kernels: gaussianos 3x3, 5x5, 7x7, 11x11 con el sigma por defecto de
  OpenCV para cada tamaño, `σ = 0.3·((k−1)/2 − 1) + 0.8` (`data/kernels/gauss_k.txt`).
  Se eligió gaussiano porque es el filtro de suavizado estándar, todos sus
  coeficientes son positivos (suma ≠ 0, la normalización está bien definida
  y la salida queda en [0,1]) y es denso: los k² coeficientes son no nulos,
  así que el trabajo crece como k² en todas las variantes.

## Reproducción

Requisitos: gcc con OpenMP, CPU con SSE4.1, ImageMagick (`magick`), Python 3.

```bash
scripts/gen_data.sh                       # imágenes y kernels
make                                      # bin/bench y bin/check (flags: -O2 -fopenmp -std=c11 -msse4)
for k in 3 5 7 11; do bin/check data/kernels/gauss_$k.txt data/images/damma_*.pgm; done   # corrección

./run_all.sh                              # corrida completa (30 reps) -> results/crudo.csv, env/entorno.txt
REPS=3 VARIANTES="seq manual" OUT=results/pilot/crudo_piloto.csv ./run_all.sh   # piloto

python3 -m venv .venv && .venv/bin/pip install pandas matplotlib tabulate
.venv/bin/python scripts/analyze.py results/crudo.csv results     # tablas y gráficas
```

`run_all.sh` omite las variantes cuyo `.c` contiene la marca `CONV_STUB`.
Al pegar la versión `ia` (o `ia_opt`), borre esa marca.

## Arnés (`src/bench.c`)

`bin/bench <variante> <imagen.pgm> <kernel.txt> <reps> <salida.csv> <hilos...>`

Por cada número de hilos: 1 ejecución de calentamiento descartada + `reps`
medidas. Solo se cronometra la llamada a `convolve_*` con `omp_get_wtime()`.
Tras cada ejecución se compara con `seq` (calculada una vez por proceso).
CSV crudo: `variante,imagen_px,ksize,hilos,repeticion,tiempo_ms,valido,error_max`.

Configuraciones: 4 imágenes × 4 kernels × hilos {1,2,4,8,16} por variante
paralela; `seq` solo con 1 hilo. 16 hilos sobresuscribe la máquina
(6 núcleos / 12 lógicos) a propósito.

## Análisis (`scripts/analyze.py`)

Por configuración: media, desviación estándar, CV, speedup y eficiencia de
dos formas: **(a)** `T1 = seq` (principal, archivos `*_seq_*`) y **(b)**
`T1 = misma variante con 1 hilo` (archivos `*_self_*`). La desviación del
speedup se propaga como `σS = S·√((σ1/T1)² + (σp/Tp)²)`.
Salidas: `resumen.csv`, `resumen.md`, `graficas/{tiempo,speedup_seq,speedup_self,eficiencia_seq,eficiencia_self}_vs_hilos.png`.

## Ajustes de `ia_opt` (ablación incremental sobre `ia`)

Aplicados, en este orden: (2) quitar el `memset` interno: el arnés y el
contrato garantizan que `out` llega en ceros, así que ese `memset` era una
escritura redundante de toda la imagen dentro del tiempo medido; (3) `proc_bind(spread)` en el pragma (solo ahí, sin variables de entorno
globales), para fijar los hilos a núcleos distintos y reducir migraciones y
variabilidad; con 16 hilos (sobresuscripción) se espera que pueda empeorar, corrección
del comportamiento indefinido del puntero `irow + dx` fuera del arreglo, y
(1) acumulación en registros. Cada paso tiene su commit, validación completa
y piloto (`results/ablacion/`).

Descartados:
- **Procesar 2 filas de salida a la vez:** beneficio marginal frente al
  riesgo de errores en los bordes.
- **Convolución separable:** cambia el algoritmo (solo sirve para kernels
  separables) y rompe la equivalencia con `manual` y con la especificación
  común de kernel general k×k.

Evidencia de la versión `ia` (prompt, resumen del agente, archivo original y
metadatos): `evidencia/ia/`.

## Observaciones sobre el código del repo `manual`

- Su `benchmark.c` valida con `temp*temp > 0.0001`: la tolerancia absoluta
  real es 1e-2, no 1e-4. Aquí se usa 1e-4 absoluto (más estricto).
- Su `normalize()` suma en `int`, lo que truncaría kernels fraccionarios;
  aquí se suma en `double` (equivalente para kernels enteros).
- Su `Makefile` (rutas de Berkeley, GotoBLAS) no se usa.
- `conv2D` acumula sobre `out` (`+=`), por eso `out` debe llegar en ceros.

## Estructura

```
include/  conv.h (interfaz), io.h
src/      conv_seq.c conv_ia.c conv_ia_opt.c conv_manual.c io.c bench.c check.c
third_party/Optimized-2D-Image-Convolution-master/   (intacto)
scripts/  gen_data.sh analyze.py
data/     source/ images/ (generadas) kernels/
results/  verificacion_correccion.txt, pilot/
env/      entorno.txt (lscpu, gcc --version, uname -a)
```
