#include <stdio.h>
#include <math.h>
#include <conio.h>
#include <string.h>
#include <stdlib.h>

int main(void)
{
    const len = 10;
    char *p;
    char isSort = 1;
    int i;
    p = (char*) calloc(len, sizeof(char)); 		
    for (i = 0; i < len; i++)
        p[i] = getch();
    while (isSort)
    {
        isSort = 0;
        for (i = 0; i < len - 1; i++)
        {
            if (p[i + 1] < p[i])
            {
                 isSort = p[i];
                 p[i] = p[i + 1];
                 p[i + 1] = isSort;
            }
        }           
    }
    for (i = 0; i < len; i++)
    {
        printf("%c ", p[i]);
    }   
    free(p);
    return 0;
}