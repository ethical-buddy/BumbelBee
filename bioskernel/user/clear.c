#include "user.h"
#include "types.h"

int 
main(int argc, char** argv) {
    // Use printf to output ANSI escape codes for clearing the screen
    printf(1, "\033[2J"); // Clear the screen
    printf(1, "\033[H");  // Move the cursor to the top-left corner
    exit();
}

