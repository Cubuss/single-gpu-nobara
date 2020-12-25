#include <stdbool.h> 

#ifndef LINUXAPILAYER_H
#define LINUXAPILAYER_H

bool is_module_in_use(char[]);
bool file_exists(char[]);
bool efifb_disabled();

#endif
