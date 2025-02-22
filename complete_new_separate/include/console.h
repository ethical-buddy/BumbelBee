#ifndef CONSOLE_H
#define CONSOLE_H

#define LINES 25
#define COLUMNS_IN_LINE 80
#define BYTES_FOR_EACH_ELEMENT 2
#define SCREENSIZE BYTES_FOR_EACH_ELEMENT*COLUMNS_IN_LINE*LINES

extern void cls();
extern void putch(unsigned char c);
extern void puts(unsigned char *str);
extern void settextcolor(unsigned char forecolor, unsigned char backcolor);
extern void init_video();
void print_hex(int val, char *buffer);


#endif //CONSOLE_H
