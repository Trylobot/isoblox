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
Import "windows32.bmx"
?
Import "globals.bmx"
Import "controller.bmx"
Incbin "art/spritelib_blocks.png"
Incbin "art/spritelib_faces.png"
Incbin "art/spritelib_font.png"

'initialization
If Not fileman_load_cfg_auto() Then fileman_save_cfg_auto()
AppTitle = "isoblox " + PROJECT_VERSION
Graphics( SCREEN_WIDTH, SCREEN_HEIGHT )
SetClsColor( 255, 255, 255 )
SetBlend( ALPHABLEND )
?win32
set_window( WS_MINIMIZEBOX )' | WS_SIZEBOX )
?

Local isoblox:controller = New controller
isoblox.load_assets()
isoblox.status.append( "welcome to $Bisoblox$D!" )
isoblox.status.append( "programming and art by $BTyler W.R. Cole" )
isoblox.status.append( "first time? $bpress F1 for help" )

'main program loop
Repeat	
	
	Cls            'clear screen
	isoblox.chug() 'process one frame of input and drawing
	Flip(1)        'flip backbuffer to screen, waiting for vertical sync
	
Until KeyDown( Key_Escape )
