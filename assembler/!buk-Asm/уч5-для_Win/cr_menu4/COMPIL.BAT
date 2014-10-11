tasm32  /ml cr_menu4.asm
brcc32 mn.rc
tlink32 /Tpe /aa /c /o C:\TASM\LIB\import32.lib cr_menu4.obj,cr_menu4.exe,,,,mn.res
