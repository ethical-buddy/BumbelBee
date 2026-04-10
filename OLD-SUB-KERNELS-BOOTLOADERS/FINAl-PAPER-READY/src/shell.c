#include <kern/console.h>
#include <kern/kb.h>
#include <kern/memory.h>
#include <kern/shell.h>

#define MAX_COMMAND_LEN 256

void exec_command(char *cmd, struct initrd_header **files, int num_files) {
  if (cmd[0] == '\0') {
    return;
  }

  if (strcmp(cmd, "help") == 0) {
    settextcolor(10, 0); // light green
    puts((unsigned char *)"Ynix Shell Commands:\n");
    settextcolor(15, 0); // white
    puts((unsigned char *)"  help  - Display this message\n");
    puts((unsigned char *)"  clear - Clear the screen\n");
    puts(
        (unsigned char
             *)"  ls    - List files in the initial ramdisk (VFS prototype)\n");
    puts((unsigned char *)"  cat   - Show contents of a file (e.g., cat "
                          "Docs/honest_review.md)\n");
  } else if (strcmp(cmd, "clear") == 0) {
    cls();
  } else if (strcmp(cmd, "ls") == 0) {
    for (int i = 0; i < num_files; i++) {
      if (files[i] == 0)
        break;
      puts((unsigned char *)files[i]->name);
      puts((unsigned char *)"    [Size: ");

      // basic print int size
      int size = get_filesize(files[i]->size);
      char buf[12];
      int j = 0;
      if (size == 0) {
        buf[j++] = '0';
      } else {
        int temp = size;
        while (temp > 0) {
          temp /= 10;
          j++;
        }
        temp = size;
        buf[j] = '\0';
        for (int k = j - 1; k >= 0; k--) {
          buf[k] = (temp % 10) + '0';
          temp /= 10;
        }
      }
      puts((unsigned char *)buf);
      puts((unsigned char *)" bytes]\n");
    }
  } else if (strncmp(cmd, "cat ", 4) == 0) {
    char *filename = cmd + 4;
    int found = 0;
    for (int i = 0; i < num_files; i++) {
      if (files[i] == 0)
        break;

      if (strcmp(files[i]->name, filename) == 0) {
        found = 1;
        uint32_t size = get_filesize(files[i]->size);
        char *content =
            (char *)files[i] + 512; // TAR content comes after 512 byte header

        for (uint32_t k = 0; k < size; k++) {
          putch(content[k]);
        }
        puts("\n");
        break;
      }
    }
    if (!found) {
      settextcolor(12, 0); // red
      puts((unsigned char *)"cat: ");
      puts((unsigned char *)filename);
      puts((unsigned char *)": No such file or directory\n");
      settextcolor(15, 0); // white back to normal
    }
  } else {
    settextcolor(12, 0); // light red
    puts((unsigned char *)"Command not found: ");
    puts((unsigned char *)cmd);
    puts((unsigned char *)"\n");
    settextcolor(15, 0); // white default
  }
}

void run_shell(struct initrd_header **files, int num_files) {
  char cmd_buffer[MAX_COMMAND_LEN];
  int cmd_idx = 0;

  puts((unsigned char *)"\nStarting OS Shell...\n");
  puts((unsigned char *)"Type 'help' for a list of commands.\n\n");

  while (1) {
    settextcolor(9, 0); // light blue
    puts((unsigned char *)"ynix> ");
    settextcolor(15, 0); // white text for user typing

    cmd_idx = 0;
    while (1) {
      char c = kb_get_char();

      if (c == '\n') {
        cmd_buffer[cmd_idx] = '\0';
        putch('\n'); // echo newline
        exec_command(cmd_buffer, files, num_files);
        break;
      } else if (c == '\b') { // backspace
        if (cmd_idx > 0) {
          cmd_idx--;
          // backspace visually
          putch('\b');
          putch(' ');
          putch('\b');
        }
      } else {
        if (cmd_idx < MAX_COMMAND_LEN - 1) {
          cmd_buffer[cmd_idx++] = c;
          putch(c); // echo typed char
        }
      }
    }
  }
}
