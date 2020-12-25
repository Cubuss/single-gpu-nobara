#include "linuxapilayer.h"
#include <stdio.h>

int main(){
	if (is_module_in_use("amdgpu")){
		printf("amdgpu is in use \n");
	}

	if (!is_module_in_use("nvidia")){
		printf("nvidia is not in use \n");
	}

	if (!is_module_in_use("noveau")){
		printf("noveau is not in use \n");
	}

	if (is_module_in_use("drm")){
		printf("drm is in use \n");
	}
	return 0;
}
