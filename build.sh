cc -o resource/dsbize/dsbize resource/dsbize/dsbize.c
c++ -o resource/r4denc/r4denc resource/r4denc/r4denc.cpp
mkdir -p data
make -C bootloader LOADBIN=$PWD/data/load.bin NO_SDMMC=1
make dist
