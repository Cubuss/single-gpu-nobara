#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h> 
#include <string.h>
#include <unistd.h>

bool is_module_in_use(char module[]){
	FILE * lsmod;
	char singleLine[150];
	lsmod = popen("lsmod", "r");
	while (!feof(lsmod)){
		fgets(singleLine, 150, lsmod);
		if (strstr(singleLine, module) != NULL){
				return true;
			}
	}
	pclose(lsmod);
	return false;
}

bool file_exists(char path[]){
	if (access(path, F_OK) == 0){
		return true;
	}
	return false;
}
