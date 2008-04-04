Rem
_______________________________
Project isoblox
This is a BlitzMax source file
Author is Tyler W.R. Cole
Started on September 30th, 2006
_______________________________
EndRem

Rem
isometric rotation layout

     + -  
      Z     CCW +
      |     CW  -
      o       
     / \     
  - Y   X +
  +       -
	
geometry groupings
 (excerpt from documentation file "isotype_reference.png")
	
  0
  1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12
 13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36
 37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60
 61,62,63,64,65,66,67,68
 69,70,71,72,73,74,75,76
_______________________________
EndRem

Strict

Import BRL.Timer
Import BRL.Audio

'Global VARIABLES

Const PROJECT_VERSION$ = "alpha 4"
Const CONFIG_FILENAME$ = "isoblox.cfg"

Global SCREEN_WIDTH  = 350
Global SCREEN_HEIGHT = 350
Global GRID_X = 16
Global GRID_Y = 16
Global GRID_Z = 16
Global SOUND = True
Global GRID_MAJOR_INTERVAL = 8
Global ORIGIN_X = SCREEN_WIDTH / 2
Global ORIGIN_Y = SCREEN_HEIGHT / 2

Global program_timer:TTimer = CreateTimer( 10 )
Global program_timer_ticks

Global MOUSE_LAST_X = 0
Global MOUSE_LAST_Y = 0

Global cursor_blink_timer:TTimer = CreateTimer( 300 )
Global COLOR_CYCLE[6]

Const COUNT_LIBS   = 6
Const COUNT_BLOCKS = 77
Global spritelib_blocks:TImage[ COUNT_LIBS, COUNT_BLOCKS ]
Global spritelib_blocks_map:TPixmap
Const COUNT_GROUPS = 6
Global group_starting_index[] = [ 0, 1, 13, 37, 61, 69 ]

Const COUNT_FACE_LIBS = 6
Const COUNT_FACES     = 8
Global spritelib_faces:TImage[ COUNT_FACE_LIBS, COUNT_FACES ]
Global spritelib_faces_map:TPixmap

Const LIB_BLOCKS     = 0
Const LIB_WIREFRAMES = 1
Const LIB_OUTLINES   = 2
Const LIB_SHADOWS_XY = 3
Const LIB_SHADOWS_YZ = 4
Const LIB_SHADOWS_XZ = 5

Const FACE_XY_MINUS = 0
Const FACE_YZ_MINUS = 1
Const FACE_XZ_MINUS = 2
Const FACE_XY_PLUS  = 3
Const FACE_YZ_PLUS  = 4
Const FACE_XZ_PLUS  = 5

Const CURSOR_BASIC  = 0
Const CURSOR_BRUSH  = 1
Const CURSOR_SELECT = 2

Const ROTATE_X_MINUS = 0
Const ROTATE_Y_MINUS = 1
Const ROTATE_Z_MINUS = 2
Const ROTATE_X_PLUS  = 3
Const ROTATE_Y_PLUS  = 4
Const ROTATE_Z_PLUS  = 5
Global rotation_map[ 6, COUNT_BLOCKS ]

Const CHAR_HEIGHT = 9
Const CHAR_WIDTH  = 8
Const MAX_STATUS_MESSAGE_COUNT = 8
Const TOKEN_DARKGRAY$ = "$D"
Const TOKEN_BLACK$    = "$B"
Const TOKEN_RED$      = "$r"
Const TOKEN_GREEN$    = "$g"
Const TOKEN_BLUE$     = "$b"
Const TOKEN_YELLOW$   = "$y"
Const TOKEN_CYAN$     = "$c"
Const TOKEN_PURPLE$   = "$p"
Global spritelib_font:TImage[ 128 ]
Global spritelib_font_map:TPixmap
Const test_str$ = "$B !~q#$%'()*+$D,-./01234567$r89:;<=>?@ABC$gDEFGHIJKLMNO$bPQRSTUVWXYZ[$y\]^_`abcdefg$chijklmnopqrs$ptuvwxyz{|}~~"

Global high_click:TSound
Global low_click:TSound


'Global FUNCTIONS

'Rotate Init_______________________________________________________________________________________
Function initialize_rotation_map()
	
	rotation_map = New Int[ 6, COUNT_BLOCKS ]
	
	rotation_map[ ROTATE_X_MINUS,  0 ] =  0
	rotation_map[ ROTATE_Y_MINUS,  0 ] =  0
	rotation_map[ ROTATE_Z_MINUS,  0 ] =  0
	rotation_map[ ROTATE_X_PLUS ,  0 ] =  0
	rotation_map[ ROTATE_Y_PLUS ,  0 ] =  0
	rotation_map[ ROTATE_Z_PLUS ,  0 ] =  0
	
	rotation_map[ ROTATE_X_MINUS,  1 ] =  9
	rotation_map[ ROTATE_Y_MINUS,  1 ] =  8
	rotation_map[ ROTATE_Z_MINUS,  1 ] =  4
	
	rotation_map[ ROTATE_X_MINUS,  2 ] = 10
	rotation_map[ ROTATE_Y_MINUS,  2 ] =  7
	rotation_map[ ROTATE_Z_MINUS,  2 ] =  3
	
	rotation_map[ ROTATE_X_MINUS,  3 ] = 12
	rotation_map[ ROTATE_Y_MINUS,  3 ] =  6
	rotation_map[ ROTATE_Z_MINUS,  3 ] =  1
	
	rotation_map[ ROTATE_X_MINUS,  4 ] = 11
	rotation_map[ ROTATE_Y_MINUS,  4 ] =  5
	rotation_map[ ROTATE_Z_MINUS,  4 ] =  2
	
	rotation_map[ ROTATE_X_MINUS,  5 ] =  7
	rotation_map[ ROTATE_Y_MINUS,  5 ] =  1
	rotation_map[ ROTATE_Z_MINUS,  5 ] = 11
	
	rotation_map[ ROTATE_X_MINUS,  6 ] =  8
	rotation_map[ ROTATE_Y_MINUS,  6 ] =  2
	rotation_map[ ROTATE_Z_MINUS,  6 ] = 12
	
	rotation_map[ ROTATE_X_MINUS,  7 ] =  6
	rotation_map[ ROTATE_Y_MINUS,  7 ] =  3
	rotation_map[ ROTATE_Z_MINUS,  7 ] =  9
	
	rotation_map[ ROTATE_X_MINUS,  8 ] =  5
	rotation_map[ ROTATE_Y_MINUS,  8 ] =  4
	rotation_map[ ROTATE_Z_MINUS,  8 ] = 10
	
	rotation_map[ ROTATE_X_MINUS,  9 ] =  3
	rotation_map[ ROTATE_Y_MINUS,  9 ] = 12
	rotation_map[ ROTATE_Z_MINUS,  9 ] =  5
	
	rotation_map[ ROTATE_X_MINUS, 10 ] =  4
	rotation_map[ ROTATE_Y_MINUS, 10 ] = 11
	rotation_map[ ROTATE_Z_MINUS, 10 ] =  6
	
	rotation_map[ ROTATE_X_MINUS, 11 ] =  2
	rotation_map[ ROTATE_Y_MINUS, 11 ] =  9
	rotation_map[ ROTATE_Z_MINUS, 11 ] =  7
	
	rotation_map[ ROTATE_X_MINUS, 12 ] =  1
	rotation_map[ ROTATE_Y_MINUS, 12 ] = 10
	rotation_map[ ROTATE_Z_MINUS, 12 ] =  8
	
	rotation_map[ ROTATE_X_MINUS, 13 ] = 29
	rotation_map[ ROTATE_Y_MINUS, 13 ] = 27
	rotation_map[ ROTATE_Z_MINUS, 13 ] = 20
	
	rotation_map[ ROTATE_X_MINUS, 14 ] = 30
	rotation_map[ ROTATE_Y_MINUS, 14 ] = 28
	rotation_map[ ROTATE_Z_MINUS, 14 ] = 19
	
	rotation_map[ ROTATE_X_MINUS, 15 ] = 33
	rotation_map[ ROTATE_Y_MINUS, 15 ] = 22
	rotation_map[ ROTATE_Z_MINUS, 15 ] = 17
	
	rotation_map[ ROTATE_X_MINUS, 16 ] = 34
	rotation_map[ ROTATE_Y_MINUS, 16 ] = 21
	rotation_map[ ROTATE_Z_MINUS, 16 ] = 18
	
	rotation_map[ ROTATE_X_MINUS, 17 ] = 31
	rotation_map[ ROTATE_Y_MINUS, 17 ] = 25
	rotation_map[ ROTATE_Z_MINUS, 17 ] = 16
	
	rotation_map[ ROTATE_X_MINUS, 18 ] = 32
	rotation_map[ ROTATE_Y_MINUS, 18 ] = 26
	rotation_map[ ROTATE_Z_MINUS, 18 ] = 15
	
	rotation_map[ ROTATE_X_MINUS, 19 ] = 36
	rotation_map[ ROTATE_Y_MINUS, 19 ] = 24
	rotation_map[ ROTATE_Z_MINUS, 19 ] = 13
	
	rotation_map[ ROTATE_X_MINUS, 20 ] = 35
	rotation_map[ ROTATE_Y_MINUS, 20 ] = 23
	rotation_map[ ROTATE_Z_MINUS, 20 ] = 14
	
	rotation_map[ ROTATE_X_MINUS, 21 ] = 26
	rotation_map[ ROTATE_Y_MINUS, 21 ] = 19
	rotation_map[ ROTATE_Z_MINUS, 21 ] = 29
	
	rotation_map[ ROTATE_X_MINUS, 22 ] = 25
	rotation_map[ ROTATE_Y_MINUS, 22 ] = 20
	rotation_map[ ROTATE_Z_MINUS, 22 ] = 30
	
	rotation_map[ ROTATE_X_MINUS, 23 ] = 28
	rotation_map[ ROTATE_Y_MINUS, 23 ] = 15
	rotation_map[ ROTATE_Z_MINUS, 23 ] = 31
	
	rotation_map[ ROTATE_X_MINUS, 24 ] = 27
	rotation_map[ ROTATE_Y_MINUS, 24 ] = 16
	rotation_map[ ROTATE_Z_MINUS, 24 ] = 32
	
	rotation_map[ ROTATE_X_MINUS, 25 ] = 21
	rotation_map[ ROTATE_Y_MINUS, 25 ] = 13
	rotation_map[ ROTATE_Z_MINUS, 25 ] = 35
	
	rotation_map[ ROTATE_X_MINUS, 26 ] = 22
	rotation_map[ ROTATE_Y_MINUS, 26 ] = 14
	rotation_map[ ROTATE_Z_MINUS, 26 ] = 36
	
	rotation_map[ ROTATE_X_MINUS, 27 ] = 23
	rotation_map[ ROTATE_Y_MINUS, 27 ] = 17
	rotation_map[ ROTATE_Z_MINUS, 27 ] = 34
	
	rotation_map[ ROTATE_X_MINUS, 28 ] = 24
	rotation_map[ ROTATE_Y_MINUS, 28 ] = 18
	rotation_map[ ROTATE_Z_MINUS, 28 ] = 33
	
	rotation_map[ ROTATE_X_MINUS, 29 ] = 18
	rotation_map[ ROTATE_Y_MINUS, 29 ] = 36
	rotation_map[ ROTATE_Z_MINUS, 29 ] = 23
	
	rotation_map[ ROTATE_X_MINUS, 30 ] = 17
	rotation_map[ ROTATE_Y_MINUS, 30 ] = 35
	rotation_map[ ROTATE_Z_MINUS, 30 ] = 24
	
	rotation_map[ ROTATE_X_MINUS, 31 ] = 14
	rotation_map[ ROTATE_Y_MINUS, 31 ] = 33
	rotation_map[ ROTATE_Z_MINUS, 31 ] = 21
	
	rotation_map[ ROTATE_X_MINUS, 32 ] = 13
	rotation_map[ ROTATE_Y_MINUS, 32 ] = 34
	rotation_map[ ROTATE_Z_MINUS, 32 ] = 22
	
	rotation_map[ ROTATE_X_MINUS, 33 ] = 19
	rotation_map[ ROTATE_Y_MINUS, 33 ] = 32
	rotation_map[ ROTATE_Z_MINUS, 33 ] = 25
	
	rotation_map[ ROTATE_X_MINUS, 34 ] = 20
	rotation_map[ ROTATE_Y_MINUS, 34 ] = 31
	rotation_map[ ROTATE_Z_MINUS, 34 ] = 26
	
	rotation_map[ ROTATE_X_MINUS, 35 ] = 16
	rotation_map[ ROTATE_Y_MINUS, 35 ] = 29
	rotation_map[ ROTATE_Z_MINUS, 35 ] = 28
	
	rotation_map[ ROTATE_X_MINUS, 36 ] = 15
	rotation_map[ ROTATE_Y_MINUS, 36 ] = 30
	rotation_map[ ROTATE_Z_MINUS, 36 ] = 27
	
	rotation_map[ ROTATE_X_MINUS, 61 ] = 63
	rotation_map[ ROTATE_Y_MINUS, 61 ] = 65
	rotation_map[ ROTATE_Z_MINUS, 61 ] = 64
	
	rotation_map[ ROTATE_X_MINUS, 62 ] = 66
	rotation_map[ ROTATE_Y_MINUS, 62 ] = 63
	rotation_map[ ROTATE_Z_MINUS, 62 ] = 63
	
	rotation_map[ ROTATE_X_MINUS, 63 ] = 67
	rotation_map[ ROTATE_Y_MINUS, 63 ] = 67
	rotation_map[ ROTATE_Z_MINUS, 63 ] = 61
	
	rotation_map[ ROTATE_X_MINUS, 64 ] = 62
	rotation_map[ ROTATE_Y_MINUS, 64 ] = 61
	rotation_map[ ROTATE_Z_MINUS, 64 ] = 62
	
	rotation_map[ ROTATE_X_MINUS, 65 ] = 61
	rotation_map[ ROTATE_Y_MINUS, 65 ] = 68
	rotation_map[ ROTATE_Z_MINUS, 65 ] = 68
	
	rotation_map[ ROTATE_X_MINUS, 66 ] = 68
	rotation_map[ ROTATE_Y_MINUS, 66 ] = 62
	rotation_map[ ROTATE_Z_MINUS, 66 ] = 67
	
	rotation_map[ ROTATE_X_MINUS, 67 ] = 65
	rotation_map[ ROTATE_Y_MINUS, 67 ] = 66
	rotation_map[ ROTATE_Z_MINUS, 67 ] = 65
	
	rotation_map[ ROTATE_X_MINUS, 68 ] = 64
	rotation_map[ ROTATE_Y_MINUS, 68 ] = 64
	rotation_map[ ROTATE_Z_MINUS, 68 ] = 66
	
	'Copy Duplicate Sets
	'eliminates the need to explicitly define every literal definition using
	'the ordering technique for matched-set blocks. this simply means that blocks
	'that follow a previously-established rotation graph copy that graph plus some offset.
	For Local isotype = 37 To 60
		For Local operation = 0 To 5
		
			rotation_map[ operation, isotype ] = 24 + rotation_map[ operation, isotype - 24 ]
			
		Next
	Next
	For Local isotype = 69 To 76
		For Local operation = 0 To 5
			
			rotation_map[ operation, isotype ] = 8 + rotation_map[ operation, isotype - 8 ]
			
		Next
	Next
	
	'Calculate Positive Rotations
	'cuts the number of required literal definitions by 50% using the principle that 
	'rotating 90 degrees on an axis is the same as rotating 270 degrees, and therefore
	'calculating the _PLUS rotation operations based on the existing literal _MINUS operations
	For Local operation = 3 To 5
		For Local isotype = 0 To COUNT_BLOCKS - 1
		
			Local inverse_operation = operation - 3
			
			rotation_map[ operation, isotype ] = ..
				rotate( inverse_operation, ..
				rotate( inverse_operation, ..
				rotate( inverse_operation, isotype )))
			
		Next
	Next
	
	'Print Debug
	Rem
	'a type of development sanity check against manual entry errors
	'prints the total number of times each isotype is referenced
	Local checksum[] = New Int[ COUNT_BLOCKS ]
	For Local operation = 0 To 5
		For Local isotype = 0 To COUNT_BLOCKS - 1
			
			checksum[ rotation_map[ operation, isotype ]] :+ 1
			
		Next
	Next
	
	Print "___________________________________________________________";
	For Local isotype = 0 To COUNT_BLOCKS - 1
		
		Print "checksum[ " + isotype + " ] = " + checksum[ isotype ]
		
	Next
	
	Print "___________________________________________________________";
	For Local isotype = 0 To COUNT_BLOCKS - 1
		
		Print "rotation_map[ X, " + isotype + " ] = { " + ..
			rotation_map[ 0, isotype ] + ", " + ..
			rotation_map[ 1, isotype ] + ", " + ..
			rotation_map[ 2, isotype ] + ", " + ..
			rotation_map[ 3, isotype ] + ", " + ..
			rotation_map[ 4, isotype ] + ", " + ..
			rotation_map[ 5, isotype ] + " }"
		
	Next
	EndRem
	
EndFunction


