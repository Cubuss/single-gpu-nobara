#include <stdbool.h> 

#ifndef LINUXAPILAYER_H
#define LINUXAPILAYER_H

bool is_module_in_use(char[]);
bool file_exists(char[]);
bool efifb_disabled();
bool is_amd();
bool is_intel();

void add_systemdboot_param(char[]);
void add_grub_param(char[]);
void update_bootloaders();

#endif
