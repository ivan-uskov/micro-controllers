#include <iostream.h>

const char QUESTION[] = "What is your name: ";  //объ€вл€ем константу
const char HELLO[] = "Hello: ";       //объ€вл€ем константу

void print_name(char* name)           //объ€вл€ем функцию
{
     cout << HELLO << name << endl;    //печать приветстви€
}

int main()
{
     char name[20];         //объ€влени€ массива
     cout << QUESTION;      //печатаем вопрос
     cin >> name;           //считываем данные в массив name
     print_name(name);      //вызываем функцию print_name
                                                         //дл€ печати приветстви€
     return 0;
}
