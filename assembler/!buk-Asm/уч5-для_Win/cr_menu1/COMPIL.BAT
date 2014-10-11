tasm32  /ml cr_menu1.asm
brcc32 menu.rc
tlink32 /Tpe /aa /c /o C:\TASM\LIB\import32.lib cr_menu1.obj,cr_menu1.exe,,,,menu.res
