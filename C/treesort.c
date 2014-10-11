#include <stdio.h>
#include <math.h>
#include <conio.h>
#include <string.h>
#include <stdlib.h>

#define null 0

typedef struct tree
{
    char key;
    struct tree *left,  *right;
} *treePtr;       

treePtr insert(treePtr *ptr, char data)
{
    if (*ptr == null)
    {
        *ptr = malloc(sizeof(struct tree));
        *ptr->key = data;
        *ptr->left = null;
        *ptr->right = null;
    }
    else
    {
        if (ptr->key > data)
        {
            insert(&ptr->left, data);
        }                                                                      
        else
        {
            insert(&ptr->right, data);
        }
    }
    return ptr;
}

void printTree(struct tree *ptr)
{
    if (ptr != null)
    {
        printTree(ptr->left);
        printf("%c", ptr->key);
        printTree(ptr->right);
    }
}

int main(void)
{
    char ch;
    struct tree *root;
    int i, len = 10;
    root = null;
    for (i = 0; i < len; i++)
    {
        insert(&root, getch());
    }
    printTree(root);
    return 0;	
}