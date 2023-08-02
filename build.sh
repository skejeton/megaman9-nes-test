set -e
mkdir -p output
ca65 megaman9/main.s -o output/megaman9.o
ld65 output/megaman9.o -o output/megaman9.nes -t nes
