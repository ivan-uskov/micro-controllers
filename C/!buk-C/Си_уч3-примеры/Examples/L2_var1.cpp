#include <iostream.h>

const char QUESTION[] = "What is your name: ";  //��������� ���������
const char HELLO[] = "Hello: ";       //��������� ���������

void print_name(char* name)           //��������� �������
{
     cout << HELLO << name << endl;    //������ �����������
}

int main()
{
     char name[20];         //���������� �������
     cout << QUESTION;      //�������� ������
     cin >> name;           //��������� ������ � ������ name
     print_name(name);      //�������� ������� print_name
                                                         //��� ������ �����������
     return 0;
}
