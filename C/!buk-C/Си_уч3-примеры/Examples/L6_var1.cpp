#include <iostream.h>

int main()
{
    char fio[3][25];
    cout << "Your surname: ";
    cin >> fio[0];
    cout << "\nYour name: ";
    cin >> fio[1];
    cout << "\nYour patronymic name: ";
    cin >> fio[2];
    cout << "\n" << fio[0] << " " << fio[1] << " " << fio[2] << endl;
    return 0;
}
