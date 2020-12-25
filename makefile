all: clean
	gcc main.c linuxapilayer.c -o single-gpu-setup
	gcc startup.c linuxapilayer.c -o vfio-startup
	gcc teardown.c linuxapilayer.c -o vfio-teardown

clean:
	rm -f single-gpu-setup
	rm -f vfio-startup
	rm -f vfio-teardown
