#include <iostream.h> 

struct stack
{
  char s[1000];
  int top;
}; 

void reset(stack* st)
{
  st->top = -1;
} 

void push(stack* st, char s)
{
  ++st->top;
  st->s[st->top] = s;
} 

char pop(stack* st)
{
  --st->top;
  return st->s[st->top];
} 

main()
{
  char str[] = "My name is Gena";
  int count = sizeof(str);
  stack My_stack;
  reset(&My_stack);
  for(int i = 0; i < count; i++)
  {
     push(&My_stack, str[i]);
  }
     while(My_stack.top != -1)
  {
     cout << pop(&My_stack);
  }
  cout << endl;
}

