#ifndef SHELL_H
#define SHELL_H

#include <kern/initrd.h>

void run_shell(struct initrd_header** files, int num_files);

#endif // SHELL_H
