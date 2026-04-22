#ifndef MANUAL_H
#define MANUAL_H

const char *manual_command_list(void);
int manual_print(const char *topic, void (*emit)(const char *text));

#endif
