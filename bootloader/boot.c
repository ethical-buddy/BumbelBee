#include "efi.h"
#include "efilib.h"
#include "efiapi.h"

EFI_SYSTEM_TABLE *SystemTable;
EFI_GRAPHICS_OUTPUT_PROTOCOL *Gop;

// Timer countdown
volatile UINTN Countdown = 5;

// Function to draw a rectangle (basic UI element)
void DrawRectangle(UINT32 x, UINT32 y, UINT32 width, UINT32 height, UINT32 color) {
    for (UINT32 py = y; py < y + height; py++) {
        for (UINT32 px = x; px < x + width; px++) {
            Gop->Blt(Gop, (EFI_GRAPHICS_OUTPUT_BLT_PIXEL *)&color, EfiBltVideoFill, 0, 0, px, py, 1, 1, 0);
        }
    }
}

// Function to load an image as the background
EFI_STATUS LoadBackgroundImage(EFI_FILE_PROTOCOL *RootDir, CHAR16 *ImagePath) {
    EFI_FILE_PROTOCOL *ImageFile;
    EFI_STATUS Status = RootDir->Open(RootDir, &ImageFile, ImagePath, EFI_FILE_MODE_READ, 0);
    if (EFI_ERROR(Status)) {
        SystemTable->ConOut->OutputString(SystemTable->ConOut, u"Error: Unable to open image file.\r\n");
        return Status;
    }

    // Simple placeholder: In a real-world scenario, you'd decode the image and display it.
    // For now, just draw a color background.
    UINT32 BackgroundColor = 0x0000FF; // Blue
    DrawRectangle(0, 0, Gop->Mode->Info->HorizontalResolution, Gop->Mode->Info->VerticalResolution, BackgroundColor);

    ImageFile->Close(ImageFile);
    return EFI_SUCCESS;
}

// Function to load the kernel
EFI_STATUS LoadKernel(EFI_FILE_PROTOCOL *RootDir, CHAR16 *KernelPath, void **KernelBuffer, UINTN *KernelSize) {
    EFI_FILE_PROTOCOL *KernelFile;
    EFI_STATUS Status = RootDir->Open(RootDir, &KernelFile, KernelPath, EFI_FILE_MODE_READ, 0);
    if (EFI_ERROR(Status)) {
        SystemTable->ConOut->OutputString(SystemTable->ConOut, u"Error: Unable to open kernel file.\r\n");
        return Status;
    }

    // Get the file size
    EFI_FILE_INFO *FileInfo;
    UINTN FileInfoSize = 0;
    KernelFile->GetInfo(KernelFile, &gEfiFileInfoGuid, &FileInfoSize, NULL);
    SystemTable->BootServices->AllocatePool(EfiLoaderData, FileInfoSize, (void **)&FileInfo);
    KernelFile->GetInfo(KernelFile, &gEfiFileInfoGuid, &FileInfoSize, FileInfo);

    *KernelSize = FileInfo->FileSize;
    SystemTable->BootServices->FreePool(FileInfo);

    // Allocate memory for the kernel
    SystemTable->BootServices->AllocatePool(EfiLoaderData, *KernelSize, KernelBuffer);
    Status = KernelFile->Read(KernelFile, KernelSize, *KernelBuffer);
    if (EFI_ERROR(Status)) {
        SystemTable->ConOut->OutputString(SystemTable->ConOut, u"Error: Unable to read kernel file.\r\n");
        return Status;
    }

    KernelFile->Close(KernelFile);
    return EFI_SUCCESS;
}

// Timer interrupt handler
VOID EFIAPI TimerCallback(EFI_EVENT Event, VOID *Context) {
    if (Countdown > 0) {
        Countdown--;
    }
}

// EFI Image Entry Point
EFI_STATUS EFIAPI efi_main(EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *ST) {
    SystemTable = ST;

    // Initialize console and graphics
    SystemTable->ConOut->ClearScreen(SystemTable->ConOut);
    SystemTable->ConOut->OutputString(SystemTable->ConOut, u"Initializing Bootloader...\r\n");

    EFI_GUID GopGuid = EFI_GRAPHICS_OUTPUT_PROTOCOL_GUID;
    EFI_STATUS Status = SystemTable->BootServices->LocateProtocol(&GopGuid, NULL, (void **)&Gop);
    if (EFI_ERROR(Status)) {
        SystemTable->ConOut->OutputString(SystemTable->ConOut, u"Error: Unable to locate Graphics Output Protocol.\r\n");
        return Status;
    }

    // Set graphical mode
    Gop->SetMode(Gop, Gop->Mode->Mode);

    // Set up the file system
    EFI_LOADED_IMAGE_PROTOCOL *LoadedImage;
    EFI_SIMPLE_FILE_SYSTEM_PROTOCOL *FileSystem;
    EFI_FILE_PROTOCOL *RootDir;

    SystemTable->BootServices->HandleProtocol(ImageHandle, &gEfiLoadedImageProtocolGuid, (void **)&LoadedImage);
    SystemTable->BootServices->HandleProtocol(LoadedImage->DeviceHandle, &gEfiSimpleFileSystemProtocolGuid, (void **)&FileSystem);
    FileSystem->OpenVolume(FileSystem, &RootDir);

    // Load background image
    LoadBackgroundImage(RootDir, L"\\background.bmp");

    // Display boot options
    SystemTable->ConOut->OutputString(SystemTable->ConOut, u"\r\nBoot Options:\r\n");
    SystemTable->ConOut->OutputString(SystemTable->ConOut, u"1. Boot Kernel\r\n");
    SystemTable->ConOut->OutputString(SystemTable->ConOut, u"2. Change Background Image\r\n");

    // Timer setup
    EFI_EVENT TimerEvent;
    SystemTable->BootServices->CreateEvent(EVT_TIMER | EVT_NOTIFY_SIGNAL, TPL_CALLBACK, TimerCallback, NULL, &TimerEvent);
    SystemTable->BootServices->SetTimer(TimerEvent, TimerPeriodic, 10000000); // 1-second timer

    // Wait for user input or timer expiration
    EFI_INPUT_KEY Key;
    while (Countdown > 0 && SystemTable->ConIn->ReadKeyStroke(SystemTable->ConIn, &Key) != EFI_SUCCESS) {
        SystemTable->ConOut->OutputString(SystemTable->ConOut, u".");
        SystemTable->BootServices->Stall(1000000); // 1 second
    }

    // Cancel the timer
    SystemTable->BootServices->CloseEvent(TimerEvent);

    // Default to boot kernel if timer expires
    if (Countdown == 0 || Key.UnicodeChar == '1') {
        SystemTable->ConOut->OutputString(SystemTable->ConOut, u"\r\nBooting kernel...\r\n");

        // Load and boot the kernel
        void *KernelBuffer;
        UINTN KernelSize;
        Status = LoadKernel(RootDir, L"\\kernel.bin", &KernelBuffer, &KernelSize);
        if (EFI_ERROR(Status)) {
            SystemTable->ConOut->OutputString(SystemTable->ConOut, u"Error: Kernel loading failed.\r\n");
            while (1)
                ;
        }

        UINTN MapSize = 0, MapKey, DescriptorSize;
        UINT32 DescriptorVersion;
        SystemTable->BootServices->GetMemoryMap(&MapSize, NULL, &MapKey, &DescriptorSize, &DescriptorVersion);
        SystemTable->BootServices->ExitBootServices(ImageHandle, MapKey);

        void (*KernelEntry)(void) = ((void (*)(void))KernelBuffer);
        KernelEntry();
    } else if (Key.UnicodeChar == '2') {
        SystemTable->ConOut->OutputString(SystemTable->ConOut, u"\r\nChange background feature coming soon...\r\n");
    }

    return EFI_SUCCESS;
}

