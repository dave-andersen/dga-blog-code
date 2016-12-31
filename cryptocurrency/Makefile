CXXFLAGS=-O4
CFLAGS=-O3 -std=c99
ISPC=ispc
ISPC_FLAGS=--cpu=core-avx2 --arch=x86-64 --target=avx2-i64x4
#AVX2OBJ="intel/sha512_avx2.o"  # kill for Mac
AVX2OBJ=""

all: sha512_driver

sha512_driver: sha512_all.o sha512_driver.o ../obj/sha512.o
	$(CXX) $(CXXFLAGS) sha512_all.o $(AVX2OBJ) intel/sha512_sse4.o intel/sha512_avx.o intel/sha512.o sha512_driver.o -o sha512_driver

sha512_all.o: sha512_all.ispc
	$(ISPC) $(ISPC_FLAGS) -o sha512_all.o -h sha512_all.h sha512_all.ispc

clean:
	/bin/rm -f *.o sha512_driver
