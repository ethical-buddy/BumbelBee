// UEFI From Scratch - ThatOSDev ( 2021 - 2022 )
// https://codeberg.org/ThatOSDev/UEFI-Tuts

#ifndef EFILIBS_H
#define EFILIBS_H

#define NULL (void*)0

EFI_HANDLE ImageHandle;
EFI_SYSTEM_TABLE* SystemTable;
EFI_GRAPHICS_OUTPUT_PROTOCOL* gop;
EFI_SIMPLE_FILE_SYSTEM_PROTOCOL *Volume;
EFI_FILE_PROTOCOL* RootFS;
void* OSBuffer_Handle;

unsigned long long strlen(const char* str)
{
	const char* strCount = str;

	while (*strCount++);
	return strCount - str - 1;
}

void SetTextPosition(UINT32 Col, UINT32 Row)
{
    // Sets the Column and Row of the text screen cursor position.
    SystemTable->ConOut->SetCursorPosition(SystemTable->ConOut, Col, Row);
}

void ResetScreen()
{
    // This resets the whole console ( A.K.A. your display screen ) interface.
    SystemTable->ConOut->Reset(SystemTable->ConOut, 1);
}

void ClearScreen()
{
    // This clears the screen buffer, but does not reset it.
    SystemTable->ConOut->ClearScreen(SystemTable->ConOut);
}

void SetColor(UINTN Attribute)
{
    // We set the color for the text output.
    SystemTable->ConOut->SetAttribute(SystemTable->ConOut, Attribute);
}

void Print(CHAR16* str)
{
    // Text Output  ( A.K.A. ConOut is Console Out )
    SystemTable->ConOut->OutputString(SystemTable->ConOut, str);
}

typedef struct BLOCKINFO
{
	int                  MagicNumber;
    unsigned long long*  BaseAddress;
    unsigned long long   BufferSize;
    unsigned int         ScreenWidth;
    unsigned int         ScreenHeight;
    unsigned int         PixelsPerScanLine;
} BLOCKINFO;

BLOCKINFO bi;

void InitializeFILESYSTEM()
{
    // To load a file, you must have a file system. EFI takes advantage of the FAT32 file system.
    EFI_LOADED_IMAGE_PROTOCOL *LoadedImage;
	EFI_DEVICE_PATH_PROTOCOL *DevicePath;
	
    if((SystemTable->BootServices->HandleProtocol(ImageHandle, &EFI_LOADED_IMAGE_PROTOCOL_GUID, (void**)&LoadedImage)) == EFI_SUCCESS)
	{
		if((SystemTable->BootServices->HandleProtocol(LoadedImage->DeviceHandle, &EFI_DEVICE_PATH_PROTOCOL_GUID, (void**)&DevicePath)) == EFI_SUCCESS)
		{
			if((SystemTable->BootServices->HandleProtocol(LoadedImage->DeviceHandle, &EFI_SIMPLE_FILE_SYSTEM_PROTOCOL_GUID, (void**)&Volume)) == EFI_SUCCESS)
			{
				if((Volume->OpenVolume(Volume, &RootFS)) != EFI_SUCCESS)
				{
					Print(L"Loading Root File System FAILED!");
				}
			} else {
		        Print(L"Volume Handle FAILED!");
	        }
		} else {
		    Print(L"DevicePath FAILED!");
	    }
	} else {
		Print(L"LoadedImage FAILED!");
	}
}

EFI_FILE_PROTOCOL* getFile(CHAR16* FileName)
{
    // This opens a file from the EFI FAT32 file system volume.
    // It loads from root, so you must supply full path if the file is not in the root.
    // Example : "somefolder//myfile"  <--- Notice the double forward slash.
    EFI_FILE_PROTOCOL* FileHandle = NULL;
    if((RootFS->Open(RootFS, &FileHandle, FileName, EFI_FILE_MODE_READ | EFI_FILE_MODE_WRITE, 0)) == EFI_NOT_FOUND)
	{
		SetColor(EFI_CYAN);
		Print(L"\r\nWARNING : Unable to find File.\r\n\r\n");
	}
    
    return FileHandle;
}

EFI_FILE_PROTOCOL* getDir(CHAR16* DirName)
{
    EFI_FILE_PROTOCOL* FileHandle = NULL;
    if((RootFS->Open(RootFS, &FileHandle, DirName, EFI_FILE_MODE_READ | EFI_FILE_MODE_WRITE, EFI_FILE_DIRECTORY)) == EFI_NOT_FOUND)
	{
		SetColor(EFI_CYAN);
		Print(L"\r\nWARNING : Unable to find Directory.\r\n\r\n");
	}
    
    return FileHandle;
}

void closeFile(EFI_FILE_PROTOCOL* FileHandle)
{
    if((FileHandle->Close(FileHandle)) != EFI_SUCCESS)
	{
        SetColor(EFI_BROWN);
        Print(L"Closing File Handle FAILED\r\n");
	}
}

void closeDir(EFI_FILE_PROTOCOL* FileHandle)
{
    if((FileHandle->Close(FileHandle)) != EFI_SUCCESS)
	{
		SetColor(EFI_BROWN);
		Print(L"Closing Directory Handle FAILED\r\n");
	}
}

EFI_FILE_PROTOCOL* createFile(CHAR16* FileName)
{
    EFI_FILE_PROTOCOL* FileHandle = NULL;
    if((RootFS->Open(RootFS, &FileHandle, FileName, EFI_FILE_MODE_CREATE | EFI_FILE_MODE_READ | EFI_FILE_MODE_WRITE, 0)) == EFI_NOT_FOUND)
	{
		SetColor(EFI_CYAN);
		Print(L"\r\nWARNING : Unable to create file. Please check your path.\r\n\r\n");
	}
    
    return FileHandle;
}

UINTN* GetFileSize (EFI_FILE_PROTOCOL* FileName)
{
    UINTN* Size = 0;
    FileName->SetPosition(FileName, 0xFFFFFFFFFFFFFFFFULL);
    FileName->GetPosition(FileName, Size);
	FileName->SetPosition(FileName, 0);
    return Size;
}

void readFile(CHAR16* FileName)
{
	// We get the file size, allocate memory for it,
    // read the file into the buffer, then we close the file.
    EFI_FILE_PROTOCOL* FileHandle = getFile(FileName);
    if(FileHandle != NULL)
    {
		UINT64* FileSize = (UINT64*)GetFileSize(FileHandle);
		if((SystemTable->BootServices->AllocatePool(EfiLoaderData, *FileSize, (void**)&OSBuffer_Handle)) != EFI_SUCCESS)
		{
			SetColor(EFI_BROWN);
			Print(L"Allocating Pool FAILED\r\n");
		}

        if((FileHandle->Read(FileHandle, FileSize, OSBuffer_Handle)) != EFI_SUCCESS)
		{
			SetColor(EFI_BROWN);
			Print(L"Reading File FAILED\r\n");
		}

        closeFile(FileHandle);
    }
}

void removeDir(CHAR16* dirName)
{
	EFI_FILE_PROTOCOL* FileHandle = getDir(dirName);
	if(FileHandle != NULL)
	{
		if((FileHandle->Delete(FileHandle)) != EFI_SUCCESS)
		{
			SetColor(EFI_BROWN);
		    Print(L"Deleting Directory FAILED\r\n");
		}
	}
}

void makeDir(CHAR16* dirName)
{
    EFI_FILE_PROTOCOL* FileHandle = NULL;
	
    if((RootFS->Open(RootFS, &FileHandle, dirName, EFI_FILE_MODE_CREATE | EFI_FILE_MODE_READ | EFI_FILE_MODE_WRITE, EFI_FILE_DIRECTORY)) != EFI_SUCCESS)
	{
		SetColor(EFI_BROWN);
		Print(L"Creating Directory FAILED\r\n");
	}
	closeDir(FileHandle);
}

void deleteFile(CHAR16* FileName)
{
	EFI_FILE_PROTOCOL* FileHandle = getFile(FileName);
	if(FileHandle != NULL)
	{
		if((FileHandle->Delete(FileHandle)) != EFI_SUCCESS)
		SetColor(EFI_BROWN);
		Print(L"Deleting File FAILED\r\n");
	}
}

void WriteToFile(char* buf, CHAR16* FileName)
{
	UINT64 fileSize = strlen(buf);
	EFI_FILE_PROTOCOL* writefilehandle = createFile(FileName);
	if(writefilehandle != NULL)
	{
		if((writefilehandle->Write(writefilehandle, &fileSize, buf)) != EFI_SUCCESS)
		{
			SetColor(EFI_BROWN);
			Print(L"Writing to File FAILED\r\n");
		}
		closeFile(writefilehandle);
	}
}

void InitializeGOP()
{
    // We initialize the Graphics Output Protocol.
    // This is used instead of the VGA interface.
    SystemTable->BootServices->LocateProtocol(&EFI_GRAPHICS_OUTPUT_PROTOCOL_GUID, 0, (void**)&gop);
	
	bi.MagicNumber        = 31337;
    bi.BaseAddress        = (void*)gop->Mode->FrameBufferBase;
    bi.BufferSize         = gop->Mode->FrameBufferSize;
    bi.ScreenWidth        = gop->Mode->Info->HorizontalResolution;
    bi.ScreenHeight       = gop->Mode->Info->VerticalResolution;
    bi.PixelsPerScanLine  = gop->Mode->Info->PixelsPerScanLine;
}

void InitializeSystem()
{
    ResetScreen();
    InitializeGOP();
	InitializeFILESYSTEM();
}

#endif // EFILIBS_H
