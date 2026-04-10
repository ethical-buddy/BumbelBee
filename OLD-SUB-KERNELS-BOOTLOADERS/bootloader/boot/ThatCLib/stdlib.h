// UEFI From Scratch - ThatOSDev ( 2021 - 2022 )
// https://codeberg.org/ThatOSDev/UEFI-Tuts

#ifndef STDLIB_H
#define STDLIB_H

void itoa(unsigned long int n, unsigned short int* buffer, int basenumber)
{
	unsigned long int hold;
	int i, j;
	hold = n;
	i = 0;
	
	do{
		hold = n % basenumber;
		buffer[i++] = (hold < 10) ? (hold + '0') : (hold + 'a' - 10);
	} while(n /= basenumber);
	buffer[i--] = 0;
	
	for(j = 0; j < i; j++, i--)
	{
		hold = buffer[j];
		buffer[j] = buffer[i];
		buffer[i] = hold;
	}
}

#endif // STDLIB_H
