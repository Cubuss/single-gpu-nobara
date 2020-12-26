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
	FILE * grub_config = fopen("grub-sample","r");
	FILE * grub_temp = fopen("grub-temp","w");

	char singleLine [5000];
	while (!feof(grub_config)){
		fgets(singleLine, 5000, grub_config);
		if (strstr(singleLine, "GRUB_CMDLINE_LINUX_DEFAULT=") != NULL){

		}
		else
			{
			// code to write this line to grub_temp
		}
	}
	
	printf("GRUB support is currently in development and is not ready for use. \n");
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

void update_bootloaders(){
	if (file_exists("/usr/bin/bootclt")){
		system("sudo bootctl update");
	}
	if (file_exists("/usr/bin/update-grub")){
		system("sudo update-grub");
	}	
	if (file_exists("/usr/bin/grub-update")){
		system("sudo grub-update");
	}
	if (file_exists("/usr/bin/grub-mkconfig")){
		system("sudo grub-mkconfig -o /boot/grub/grub.cfg");
	}
	if (file_exists("/usr/bin/grub2-mkconfig")){
		system("sudo grub2-mkconfig -o \"$(readlink -e /etc/grub2.conf)\"");
	}
}
