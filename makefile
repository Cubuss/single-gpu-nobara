all: clean
	gcc main.c linuxapilayer.c -o single-gpu-setup.sh

clean:
	rm -f single-gpu-setup.sh
