Rem
__________________________________________________________________________
Project isoblox
This is a BlitzMax source file
Author is Tyler W.R. Cole
Started on September 30th, 2006
__________________________________________________________________________
EndRem

Strict

?win32
Import "art/icon.o"
Import pub.win32
Const ICON_BIG = 1
Extern "win32"
	Function FindWindowA(lpClassName$z, lpWindowName$z)
EndExtern
Global hWnd
Function set_window(GWLStyleFlags=0)	
	If TGLMax2DDriver(_max2ddriver)
		hWnd = FindWindowA("BlitzMax GLGraphics", AppTitle$)
	Else
		hWnd = FindWindowA("BBDX7Device Window Class", AppTitle$)
	EndIf	
	SetWindowLongA(hWnd, GWL_STYLE, GetWindowLongA(hWnd, GWL_STYLE) | GWLStyleFlags)
	SendMessageA(hWnd, WM_SETICON, ICON_BIG, LoadIconA(GetModuleHandleA(Null), Byte Ptr(101)))
EndFunction
Function close_message()
	Local msg:Byte Ptr
	GetMessageA( msg,hWnd,WM_CLOSE,WM_CLOSE )
	If msg[0] = WM_CLOSE Then Return True Else Return False
EndFunction
?
