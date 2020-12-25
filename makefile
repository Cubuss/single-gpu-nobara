all: clean
	gcc main.c linuxapilayer.c -o single-gpu-setup.sh
	gcc startup.c linuxapilayer.c -o vfio-startup.sh
	gcc teardown.c linuxapilayer.c -o vfio-teardown.sh

clean:
	rm -f single-gpu-setup.sh
	rm -f vfio-startup.sh
	rm -f vfio-teardown.sh
