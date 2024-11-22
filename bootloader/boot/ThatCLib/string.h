// UEFI From Scratch - ThatOSDev ( 2021 - 2022 )
// https://codeberg.org/ThatOSDev/UEFI-Tuts

#ifndef STRING_H
#define STRING_H

unsigned long long strlen(const char* str)
{
	const char* strCount = str;

	while (*strCount++);
	return strCount - str - 1;
}

void* memcpy(void* dst, const void* src, unsigned long long size)
{
    for ( unsigned long long i = 0; i < size; i++ )
        ((unsigned char*) dst)[i] = ((const unsigned char*) src)[i];
    return dst;
}

int memcmp(const void* src1, const void* src2, unsigned long long numberOfBytes)
{
  unsigned char const* str1 = src1;
  unsigned char const* str2 = src2;

  while (numberOfBytes--) {
    if (*str1 != *str2)
      return (int)*str1 - (int)*str2;
    str1++;
    str2++;
  }

  return 0;
}

void *memset(void* str, int chr, unsigned long long numberOfBytes)
{
  unsigned char* dest = str;

  while (numberOfBytes--)
    *dest++ = (unsigned char)chr;

  return str;
}

void* memmove(void* destination, const void* source, unsigned long long numberOfBytes)
{
  unsigned char* dest = destination;
  unsigned char const* src = source;

  if (dest < src) {
    while (numberOfBytes--)
      *dest++ = *src++;
  } else {
    dest += numberOfBytes;
    src += numberOfBytes;
    while (numberOfBytes--)
      *--dest = *--src;
  }

  return destination;
}

void* memchr(const void* string, int chr, unsigned long long numberOfBytes)
{
	unsigned long long   i = 0;
	unsigned char*       str       = (unsigned char*)string;
	unsigned char        asciiChar = (unsigned char)chr;
	while (i < numberOfBytes)
	{
		if (*str == asciiChar)
		{
			return (str);
		}
		str++;
		i++;
	}
	return (NULL);
}

#endif // STRING_H
