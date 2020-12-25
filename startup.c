#include <stdio.h>
#include <stdlib.h>
#include "linuxapilayer.h"
int main(){
	if (efifb_disabled()){
		printf ("Video efifb is disabled. Libvirt will take care of the rest. \n");
		exit(0);
	}
	return 0;
}
