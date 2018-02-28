# chartest
[Main](knr.md)

A simple driver to test ascii upper-case, lower-case shenanigans. Given that 'A' is ascii 65 in decimal and 'a' is 97 and consecutive letters of the alphabet are coded consecutively, that there is a gap of 32 between lower and upper cases, with the lower case being the higher number. To switch cases, you can add 32 to the upper case letters or subtract 32 from lower case letter. 32 can be obtained by doing character subtraction - to change a lower case letter to an upper case letter, take 'i', 'i' + ('A' - 'a'), is really 'i', which is 105, plus 'A' (65) - 'a' (97), which is -32, so 105 - 32 = 73, or 'I'. to lower the case of a letter, the corrolary 'I' + ('i' - 'I') becomes 73 + 32, or 105, 'i'.

```
vi chartest.c

chartest.c 
#include <stdio.h>

int main()
{
	printf("A %d\n", 'A');
	printf("a %d\n", 'a');
	printf("A - a %d\n", 'A' - 'a');
	printf("a - A %d\n", 'a' - 'A');
	printf("I + 1 %c %d\n", 'I' + 1, 'I' + 1);
	printf("i + 1 %c %d\n", 'i' + 1, 'i' + 1);
	printf("i + (A - a) %d\n", 'i' + ('A' - 'a'));
	printf("I + (a - A) %d\n", 'I' + ('a' - 'A'));
	return 0;
}


cc chartest.c 
./a.out 
A 65
a 97
A - a -32
a - A 32
I + 1 J 74
i + 1 j 106
i + (A - a) 73
I + (a - A) 105

```

