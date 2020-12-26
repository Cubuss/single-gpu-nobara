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
	FILE * grub_config = fopen("/etc/default/grub","r");
	FILE * grub_temp = fopen("grub-temp","w");

	char singleLine [5000];
	while (!feof(grub_config)){
		fgets(singleLine, 5000, grub_config);
		if (strstr(singleLine, "GRUB_CMDLINE_LINUX_DEFAULT=") != NULL){
			if (!strstr(singleLine, param)){
				// I can use a boolean that gets trigerred in the first occurance of "
				// In the second appearance of " , we can replace it with the text
				char ending[10]="";
				char newLine[6000];
				char text[350]=" ";
				strcat(text, param);
				char textToAdd[400];
				strcpy(textToAdd, text);
				strcat(textToAdd, ending);

				int counter = 0;
				bool first_occurence = false;
				while ((singleLine[counter] != '\"') || (!first_occurence)){
					newLine[counter] = singleLine[counter];
					if (singleLine[counter] == '\"'){
						first_occurence = true;
					}
					counter ++;
				}

				strcat(newLine, textToAdd);
				fputs(newLine, grub_temp);
			} else {
				fputs(singleLine, grub_temp);
			}
		}
		else
			{
				fputs(singleLine, grub_temp);
		}
	}
	fclose(grub_config);
	fclose(grub_temp);
	system("sudo mv grub-temp /etc/default/grub");
	printf("GRUB config file successfully generated. \n");
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

bool command_exists(char command[]){
	char command1[350]="/usr/bin/";
	char command2[350]="/usr/local/sbin/";
	char command3[350]="/usr/local/bin/";
	char command4[350]="/usr/lib/jvm/default/bin/";

	strcat(command1, command);
	strcat(command2, command);
	strcat(command3, command);
	strcat(command4, command);
	if((file_exists(command1)) ||
	   (file_exists(command2)) ||
	   (file_exists(command3)) ||
	   (file_exists(command4))) {return true;}
	return false;
}


void update_bootloaders(){
	if (command_exists("bootclt")){
		system("sudo bootctl update");
	}
	if (command_exists("update-grub")){
		system("sudo update-grub");
	}
	if (command_exists("grub-update")){
		system("sudo grub-update");
	}
	if (command_exists("grub-mkconfig")){
		system("sudo grub-mkconfig -o /boot/grub/grub.cfg");
	}
	if (command_exists("grub2-mkconfig")){
		system("sudo grub2-mkconfig -o \"$(readlink -e /etc/grub2.conf)\"");
	}
}
