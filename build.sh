set -e
cc -o resource/dsbize/dsbize resource/dsbize/dsbize.c
make -C libnds32 arm9
make dist
