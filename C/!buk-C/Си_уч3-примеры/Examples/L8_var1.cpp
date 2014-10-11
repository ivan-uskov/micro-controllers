#include <iostream.h>
int sum(int a, int b)
{
    int c = a + b; return c;
}
main()
{
    int a, b , res;
    cout << "a = ";
    cin >> a;
    cout << "b = "; 
    cin >> b; 
    res = sum(a, b);
    cout << "summa: " << res << endl;
}

    
