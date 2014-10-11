tasm32  /ml cr_icon.asm
brcc32 icon.rc
tlink32 /Tpe /aa /c /o C:\TASM\LIB\import32.lib cr_icon.obj,cr_icon.exe,,,,icon.res
