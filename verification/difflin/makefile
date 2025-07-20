# Makefile for CompCorr.c

CC = gcc
CFLAGS = -O3 -lm
SRC = CompCorr.c
OUT = compcorr

ROTSRC=rotateCorr.c
ROT_OUT=rotateCorr

all: $(OUT)

$(OUT): $(SRC)
	$(CC) $(SRC) -o $(OUT) $(CFLAGS)

$(ROT_OUT): $(ROTSRC)
	$(CC) $(ROTSRC) -o $(ROT_OUT) $(CFLAGS)	

run: $(OUT)
	./$(OUT)

run_rotate: $(ROT_OUT)
	./$(ROT_OUT)

clean:
	rm -f $(OUT)
	rm -f $(ROT_OUT)
