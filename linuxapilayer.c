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

bool efifb_disabled(){
	FILE * cmdline;
	char singleLine[5000];
	cmdline = popen("cat /proc/cmdline", "r");
	while (!feof(cmdline)){
		fgets(singleLine, 5000, cmdline);
		if (strstr(singleLine, "video=efifb:off") != NULL){
				return true;
			}
	}
	pclose(cmdline);
	return false;
}

void add_grub_param(char param[]){
	// Code to add a grub_parameter
	
}

void add_systemdboot_param(char param[]){
	char command[100];
	strcat(command, "sudo kernelstub --add-options \"");
	strcat(command, param);
	strcat(command,"\"");
	system(command);
}

bool is_amd(){
	char vendor_id[]="AuthenticAMD";
	FILE * lscpu;
	char singleLine[150];
	lscpu = popen("lscpu", "r");
	while (!feof(lscpu)){
		fgets(singleLine, 150, lscpu);
		if (strstr(singleLine, vendor_id) != NULL){
				return true;
			}
	}
	pclose(lscpu);
	return false;
}


bool is_intel(){
	char vendor_id[]="GenuineIntel";
	FILE * lscpu;
	char singleLine[150];
	lscpu = popen("lscpu", "r");
	while (!feof(lscpu)){
		fgets(singleLine, 150, lscpu);
		if (strstr(singleLine, vendor_id) != NULL){
				return true;
			}
	}
	pclose(lscpu);
	return false;
}
