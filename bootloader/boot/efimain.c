#include "efi.h"
#include "efilibs.h"

// Global variables
EFI_SYSTEM_TABLE *SystemTable;
EFI_HANDLE ImageHandle;

// Function to wait for a specified number of seconds
void WaitForSeconds(UINTN seconds) {
    for (UINTN i = 0; i < seconds; i++) {
        SystemTable->BootServices->Stall(1000000); // Stall for 1 second
    }
}

// Custom string formatter
void SimpleFormat(CHAR16 *buffer, UINTN bufferSize, CHAR16 *format, int value) {
    UINTN index = 0;
    while (*format && index < bufferSize - 1) {
        if (*format == L'%' && *(format + 1) == L'd') {
            CHAR16 temp[20];
            UINTN len = 0;
            int tempValue = value;
            do {
                temp[len++] = (CHAR16)(L'0' + tempValue % 10);
                tempValue /= 10;
            } while (tempValue > 0 && len < sizeof(temp) / sizeof(CHAR16));

            while (len-- > 0 && index < bufferSize - 1) {
                buffer[index++] = temp[len];
            }
            format += 2; // Skip "%d"
        } else {
            buffer[index++] = *format++;
        }
    }
    buffer[index] = L'\0'; // Null-terminate
}

// Entry point for the UEFI application
EFI_STATUS efi_main(EFI_HANDLE IH, EFI_SYSTEM_TABLE *ST) {
    // Set global variables for the image handle and system table
    ImageHandle = IH;
    SystemTable = ST;

    InitializeSystem();
    SetColor(EFI_WHITE);
    SetTextPosition(10, 1);

    // Display boot menu
    Print(L"UEFI Bootloader\r\n");
    Print(L"1. Boot ThatOS64\r\n");
    Print(L"2. Exit Bootloader\r\n");
    Print(L"Select an option within 10 seconds, or default to Boot OS:\r\n");

    // Initialize variables for input and timeout
    EFI_INPUT_KEY Key;
    int selectedOption = 1; // Default option
    int timeout = 10;

    // Countdown timer loop
    for (int i = timeout; i > 0; i--) {
        // Display remaining time
        CHAR16 buffer[50];
        SimpleFormat(buffer, sizeof(buffer) / sizeof(CHAR16), L"Time remaining: %d seconds\r\n", i);
        SetTextPosition(10, 5);
        Print(buffer);

        // Wait for 1 second
        SystemTable->BootServices->Stall(1000000);

        // Check for user input
        if (SystemTable->ConIn->ReadKeyStroke(SystemTable->ConIn, &Key) == EFI_SUCCESS) {
            if (Key.UnicodeChar == L'1') {
                selectedOption = 1;
                break;
            } else if (Key.UnicodeChar == L'2') {
                selectedOption = 2;
                break;
            }
        }
    }

    // Handle selected option
    if (selectedOption == 2) {
        Print(L"Exiting the bootloader...\r\n");
        return EFI_SUCCESS;
    }

    Print(L"Loading ThatOS64...\r\n\r\n");

    // Attempt to read the kernel binary
    readFile(u"ThatOS64\\loader.bin");

    UINT8 *loader = (UINT8 *)OSBuffer_Handle;

    if (loader == NULL) {
        Print(L"Kernel binary not loaded into memory\r\n");
        return EFI_LOAD_ERROR;
    }

    // Setup and grab the address of the memory map
    UINTN MemoryMapSize = 0;
    EFI_MEMORY_DESCRIPTOR *MemoryMap = NULL;
    UINTN MapKey;
    UINTN DescriptorSize;
    UINT32 DescriptorVersion;

    // Get memory map size
    EFI_STATUS Status = SystemTable->BootServices->GetMemoryMap(&MemoryMapSize, MemoryMap, &MapKey, &DescriptorSize, &DescriptorVersion);
    if (Status != EFI_BUFFER_TOO_SMALL) {
        Print(L"Failed to get initial memory map size\r\n");
        return Status;
    }

    // Allocate memory for the memory map
    MemoryMapSize += 2 * DescriptorSize;
    Status = SystemTable->BootServices->AllocatePool(EfiLoaderData, MemoryMapSize, (void **)&MemoryMap);
    if (Status != EFI_SUCCESS) {
        Print(L"Failed to allocate memory for memory map\r\n");
        return Status;
    }

    // Retrieve the memory map
    Status = SystemTable->BootServices->GetMemoryMap(&MemoryMapSize, MemoryMap, &MapKey, &DescriptorSize, &DescriptorVersion);
    if (Status != EFI_SUCCESS) {
        Print(L"Failed to retrieve memory map\r\n");
        return Status;
    }

    // Exit boot services
    Status = SystemTable->BootServices->ExitBootServices(ImageHandle, MapKey);
    if (Status != EFI_SUCCESS) {
        Print(L"Failed to exit boot services\r\n");
        return Status;
    }

    // Call the kernel entry point
    void (*KernelBinFile)(int, BLOCKINFO *) = ((__attribute__((ms_abi)) void (*)(int, BLOCKINFO *)) &loader[262]);
    Print(L"Transferring control to kernel...\r\n");
    KernelBinFile(0, &bi);

    // We should not reach this point
    Print(L"Kernel did not take control\r\n");
    return EFI_SUCCESS;
}

