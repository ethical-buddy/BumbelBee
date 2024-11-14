#include "efi.h"


// EFI Image Entry Point
EFI_STATUS EFIAPI efi_main(EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable) {
    (void)ImageHandle;

    SystemTable->ConOut->SetAttribute(SystemTable->ConOut,
            EFI_TEXT_ATTR(EFI_YELLOW,EFI_GREEN));


    SystemTable->ConOut->ClearScreen(SystemTable->ConOut);

    SystemTable->ConOut->OutputString(SystemTable->ConOut, u"Hello, World!\r\n\r\n");

    SystemTable->ConOut->SetAttribute(SystemTable->ConOut,
            EFI_TEXT_ATTR(EFI_RED,EFI_BLACK));

    SystemTable->ConOut->OutputString(SystemTable->ConOut,
            u"Press any key to shutdown...");

    EFI_INPUT_KEY key;
    while (SystemTable->ConIn->ReadKeyStroke(SystemTable->ConIn, &key) != EFI_SUCCESS)
        ;

    SystemTable->RuntimeServices->ResetSystem(EfiResetShutdown, EFI_SUCCESS, 0, NULL);

    return EFI_SUCCESS;
}
