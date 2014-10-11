tasm32  /ml cr_menu2.asm
brcc32 menu.rc
tlink32 /Tpe /aa /c /o C:\TASM\LIB\import32.lib cr_menu2.obj,cr_menu2.exe,,,,menu.res
