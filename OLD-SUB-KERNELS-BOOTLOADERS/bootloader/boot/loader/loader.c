// UEFI From Scratch - ThatOSDev ( 2021 - 2022 )
// https://codeberg.org/ThatOSDev/UEFI-Tuts

#include "stdint.h"

             // ARGB             
#define ORANGE 0xffffa500
#define CYAN   0xff00ffff
#define RED    0xffff0000
#define GREEN  0xff00ff00
#define BLUE   0xff0000ff
#define GRAY   0xff888888
#define WHITE  0xffffffff
#define BLACK  0xff000000

typedef struct GRAPHICS_COLOR_PIXEL
{
    uint8_t   Blue;
    uint8_t   Green;
    uint8_t   Red;
    uint8_t   Alpha;
} GRAPHICS_COLOR_PIXEL;

typedef struct BLOCKINFO
{
	int32_t    MagicNumber;
    uint64_t*  BaseAddress;
    uint64_t   BufferSize;
    uint32_t   ScreenWidth;
    uint32_t   ScreenHeight;
    uint32_t   PixelsPerScanLine;
} BLOCKINFO;

GRAPHICS_COLOR_PIXEL* SetGraphicsColor(uint32_t color);
void CreateBufferFilledBox(uint32_t xPos, uint32_t yPos, uint32_t w, uint32_t h, GRAPHICS_COLOR_PIXEL* gc, BLOCKINFO* bli);

void main(int32_t argc, BLOCKINFO* bi)
{
	BLOCKINFO* biStruct = bi;
	
	if(biStruct->MagicNumber == 31337)
	{
		GRAPHICS_COLOR_PIXEL* GraphicsColor = SetGraphicsColor(ORANGE);
		CreateBufferFilledBox(1, 1, 150, 150, GraphicsColor, biStruct);
	} else {
		GRAPHICS_COLOR_PIXEL* GraphicsColor = SetGraphicsColor(GREEN);
		CreateBufferFilledBox(1, 1, 150, 150, GraphicsColor, biStruct);
	}
	
	while(1){__asm__ ("hlt");}
}

GRAPHICS_COLOR_PIXEL* SetGraphicsColor(uint32_t color)
{
    GRAPHICS_COLOR_PIXEL* GColor = ((void*)0);
    GColor->Alpha    = color >> 24;
    GColor->Red      = color >> 16;
    GColor->Green    = color >> 8;
    GColor->Blue     = color;
    return GColor;
}

void CreateBufferFilledBox(uint32_t xPos, uint32_t yPos, uint32_t w, uint32_t h, GRAPHICS_COLOR_PIXEL* gc, BLOCKINFO* bli)
{
    uint32_t x;
    uint32_t y      = yPos;
    uint32_t width  = xPos + w;
    uint32_t height = yPos + h;

    for(y = yPos; y <= height; y++)
    {
        for(x = xPos; x <= width; x++)
        {
            *(x + (y * bli->PixelsPerScanLine) + (uint32_t*)(bli->BaseAddress)) = *(uint32_t*)gc;
        }
    }
}

