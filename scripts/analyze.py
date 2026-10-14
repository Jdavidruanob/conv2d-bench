"""Agrega el CSV crudo y genera tablas (CSV + Markdown) y gráficas.

Uso: .venv/bin/python scripts/analyze.py [crudo.csv] [directorio_salida]

Speedup en dos variantes:
  (a) speedup_seq  = T_seq / T_p        (principal; T_seq = media de seq, 1 hilo)
  (b) speedup_self = T_v(1 hilo) / T_p  (escalabilidad de la propia variante)
Eficiencia = speedup / p. La desviación del speedup se propaga como
  sigma_S = S * sqrt((sigma_1/T_1)^2 + (sigma_p/T_p)^2).
"""
import sys
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

crudo = Path(sys.argv[1] if len(sys.argv) > 1 else "results/crudo.csv")
salida = Path(sys.argv[2] if len(sys.argv) > 2 else "results")
(salida / "graficas").mkdir(parents=True, exist_ok=True)

df = pd.read_csv(crudo)
claves = ["variante", "imagen_px", "ksize", "hilos"]
res = (df.groupby(claves)
         .agg(n=("tiempo_ms", "size"), tiempo_ms=("tiempo_ms", "mean"),
              std_ms=("tiempo_ms", "std"), mediana_ms=("tiempo_ms", "median"), min_ms=("tiempo_ms", "min"),
              max_ms=("tiempo_ms", "max"), validas=("valido", "sum"),
              error_max=("error_max", "max"))
         .reset_index())
res["cv_pct"] = 100 * res["std_ms"] / res["tiempo_ms"]


def rel(t, s):
    return s / t


seq = res[res.variante == "seq"][["imagen_px", "ksize", "tiempo_ms", "std_ms"]] \
    .rename(columns={"tiempo_ms": "t_seq", "std_ms": "s_seq"})
uno = res[res.hilos == 1][["variante", "imagen_px", "ksize", "tiempo_ms", "std_ms"]] \
    .rename(columns={"tiempo_ms": "t_1", "std_ms": "s_1"})
res = res.merge(seq, on=["imagen_px", "ksize"], how="left") \
         .merge(uno, on=["variante", "imagen_px", "ksize"], how="left")

rp = rel(res.tiempo_ms, res.std_ms)
for nombre, t1, s1 in (("seq", "t_seq", "s_seq"), ("self", "t_1", "s_1")):
    s = res[t1] / res.tiempo_ms
    res[f"speedup_{nombre}"] = s
    res[f"std_speedup_{nombre}"] = s * np.sqrt(rel(res[t1], res[s1]) ** 2 + rp ** 2)
    res[f"eficiencia_{nombre}"] = s / res.hilos
    res[f"std_eficiencia_{nombre}"] = res[f"std_speedup_{nombre}"] / res.hilos
res = res.drop(columns=["t_seq", "s_seq", "t_1", "s_1"]) \
         .sort_values(["imagen_px", "ksize", "variante", "hilos"])

res.to_csv(salida / "resumen.csv", index=False, float_format="%.6g")
cols_md = ["variante", "imagen_px", "ksize", "hilos", "n", "tiempo_ms", "std_ms", "mediana_ms", "min_ms", "cv_pct",
           "speedup_seq", "eficiencia_seq", "speedup_self", "eficiencia_self", "validas", "error_max"]
with open(salida / "resumen.md", "w") as f:
    f.write(f"# Resumen ({crudo})\n\n")
    f.write("speedup_seq: T1 = secuencial (principal). speedup_self: T1 = misma variante con 1 hilo.\n\n")
    for (n, k), g in res.groupby(["imagen_px", "ksize"]):
        f.write(f"## {n}x{n}, kernel {k}x{k}\n\n")
        f.write(g[cols_md].to_markdown(index=False, floatfmt=".4g"))
        f.write("\n\n")

variantes = [v for v in ["seq", "ia", "ia_opt", "manual"] if v in set(res.variante)]
tamanos = sorted(res.imagen_px.unique())
kernels = sorted(res.ksize.unique())
hilos_todos = sorted(res.hilos.unique())


def grafica(col, err, titulo, archivo, ideal=None, logy=False):
    fig, axs = plt.subplots(len(tamanos), len(kernels), figsize=(4 * len(kernels), 3.2 * len(tamanos)),
                            squeeze=False, sharex=True)
    for i, n in enumerate(tamanos):
        for j, k in enumerate(kernels):
            ax = axs[i][j]
            g = res[(res.imagen_px == n) & (res.ksize == k)]
            for v in variantes:
                d = g[g.variante == v]
                if v == "seq" and col == "tiempo_ms":
                    ax.axhline(d.tiempo_ms.iloc[0], color="gray", ls=":", label="seq (1 hilo)")
                    continue
                if v == "seq" or col not in d or d[col].isna().all():
                    continue
                ax.errorbar(d.hilos, d[col], yerr=d[err], marker="o", capsize=3, label=v)
            if ideal == "speedup":
                ax.plot(hilos_todos, hilos_todos, "k--", lw=0.8, label="ideal")
            elif ideal == "eficiencia":
                ax.axhline(1.0, color="k", ls="--", lw=0.8, label="ideal")
            for nucleos in (6, 12):
                ax.axvline(nucleos, color="red", alpha=0.15, lw=1)
            ax.set_xscale("log", base=2)
            ax.set_xticks(hilos_todos, [str(h) for h in hilos_todos])
            if logy:
                ax.set_yscale("log")
            ax.set_title(f"{n}x{n}, k={k}x{k}", fontsize=9)
            if i == len(tamanos) - 1:
                ax.set_xlabel("hilos")
    axs[0][0].legend(fontsize=7)
    fig.suptitle(titulo + "\n(líneas rojas tenues: 6 núcleos físicos / 12 lógicos; 16 = sobresuscripción)",
                 fontsize=11)
    fig.tight_layout()
    fig.savefig(salida / "graficas" / archivo, dpi=130)
    plt.close(fig)


grafica("tiempo_ms", "std_ms", "Tiempo medio de convolución (ms) ± desv. estándar", "tiempo_vs_hilos.png", logy=True)
grafica("speedup_seq", "std_speedup_seq", "Speedup (a): T1 = secuencial", "speedup_seq_vs_hilos.png", ideal="speedup")
grafica("speedup_self", "std_speedup_self", "Speedup (b): T1 = misma variante con 1 hilo",
        "speedup_self_vs_hilos.png", ideal="speedup")
grafica("eficiencia_seq", "std_eficiencia_seq", "Eficiencia (a): T1 = secuencial", "eficiencia_seq_vs_hilos.png",
        ideal="eficiencia")
grafica("eficiencia_self", "std_eficiencia_self", "Eficiencia (b): T1 = misma variante con 1 hilo",
        "eficiencia_self_vs_hilos.png", ideal="eficiencia")

invalidas = int((df.valido != 1).sum())
print(f"{len(df)} ejecuciones, {len(res)} configuraciones, {invalidas} inválidas, "
      f"error máximo global {df.error_max.max():.3e}")
print(f"Tablas: {salida}/resumen.csv, {salida}/resumen.md; gráficas en {salida}/graficas/")
