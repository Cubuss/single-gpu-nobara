#include <stdio.h>
#include <stdlib.h>
#include "linuxapilayer.h"

/* ERROR CODE      MEANING
 *     12       NO DEDICATED GPU DETECTED.
 * */

int main(){
	bool amdgpu = is_module_in_use("amdgpu");
	bool nvidia = is_module_in_use("nvidia");
	bool noveau = is_module_in_use("noveau");
	bool amdgpu_pro = is_module_in_use("amdgpu-pro");

	if (!amdgpu && !nvidia && !noveau && !amdgpu_pro){
		printf("ERROR 12: \n NO DEDICATED GPU DRIVER DETECTED. \n EXITING...\n IF THIS IS AN ERROR, PLEASE FILE A BUG REPORT. \n");
		exit(12);
	}
	bool grub = file_exists("/etc/default/grub");
	bool systemdboot = file_exists("/usr/bin/kernelstub");

	bool intel = is_intel();
	bool amd = is_amd();
	
	if (grub) {
		
	}

	if (systemdboot){
		
	}
}

