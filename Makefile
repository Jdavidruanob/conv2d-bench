CC      = gcc
# Mismos flags para todas las variantes (incluido el código del repo).
CFLAGS  = -O2 -fopenmp -std=c11 -msse4
WARN    = -Wall -Wextra
LDLIBS  = -lm

TP      = third_party/Optimized-2D-Image-Convolution-master
OBJ     = build/io.o build/conv_seq.o build/conv_ia.o build/conv_ia_opt.o \
          build/conv_manual.o build/extra.o

all: bin/bench bin/check

bin/bench: build/bench.o $(OBJ) | bin
	$(CC) $(CFLAGS) -o $@ $^ $(LDLIBS)

bin/check: build/check.o $(OBJ) build/ref.o | bin
	$(CC) $(CFLAGS) -o $@ $^ $(LDLIBS)

build/%.o: src/%.c include/*.h | build
	$(CC) $(CFLAGS) $(WARN) -Iinclude -c -o $@ $<

# Código de terceros: mismos flags de compilación, sin -Wall (no es nuestro).
build/extra.o: $(TP)/extra.c | build
	$(CC) $(CFLAGS) -c -o $@ $<
build/ref.o: $(TP)/ref.c | build
	$(CC) $(CFLAGS) -c -o $@ $<

bin build:
	mkdir -p $@

clean:
	rm -rf bin build

.PHONY: all clean
