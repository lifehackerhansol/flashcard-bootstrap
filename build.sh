clang -o resource/dsbize/dsbize resource/dsbize/dsbize.c
clang++ -o resource/r4denc/r4denc resource/r4denc/r4denc.cpp
mkdir -p data
make -C bootloader LOADBIN=$PWD/data/load.bin
make -C libnds32 arm9 -j`nproc`
make dist
