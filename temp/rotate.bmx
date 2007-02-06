Rem
_______________________________
Project isoblox
This is a BlitzMax source file
Author is Tyler W.R. Cole
Started on September 30th, 2006

isometric rotation layout

     + -  
      Z     CCW +
      |     CW  -
      o       
     / \     
  - Y   X +
  +       -
	
geometry groupings by first occurence of geometry in isotype reference
	
  0
  1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12
 13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35
 36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58
 59,60,61,62,63,64,65,66

_______________________________
EndRem

Strict
Import "globals.bmx"
Import "iso_block.bmx"

'TODO
'1. finish the rotation_map matrix
'2. finish the rotate_about_anchor algorithm

Function rotate_about_anchor( operation, anchor:iso_coord, blocklist:TList )
	
	'stub
	
EndFunction

Function rotate( operation, isotype )
	
	Return rotation_map[ operation, isotype ]
	
EndFunction

Function rotate_init()
	
	rotation_map[ ROTATE_X_PLUS ,  0 ] =  0
	rotation_map[ ROTATE_X_MINUS,  0 ] =  0
	rotation_map[ ROTATE_Y_PLUS ,  0 ] =  0
	rotation_map[ ROTATE_Y_MINUS,  0 ] =  0
	rotation_map[ ROTATE_Z_PLUS ,  0 ] =  0
	rotation_map[ ROTATE_Z_MINUS,  0 ] =  0
	
	rotation_map[ ROTATE_X_PLUS ,  1 ] =  9
	rotation_map[ ROTATE_X_MINUS,  1 ] = 11
	rotation_map[ ROTATE_Y_PLUS ,  1 ] =  3
	rotation_map[ ROTATE_Y_MINUS,  1 ] =  4
	rotation_map[ ROTATE_Z_PLUS ,  1 ] =  7
	rotation_map[ ROTATE_Z_MINUS,  1 ] =  5
	
	rotation_map[ ROTATE_X_PLUS ,  2 ] = 10
	rotation_map[ ROTATE_X_MINUS,  2 ] = 12
	rotation_map[ ROTATE_Y_PLUS ,  2 ] =  4
	rotation_map[ ROTATE_Y_MINUS,  2 ] =  3
	rotation_map[ ROTATE_Z_PLUS ,  2 ] =  8
	rotation_map[ ROTATE_Z_MINUS,  2 ] =  6
	
	rotation_map[ ROTATE_X_PLUS ,  3 ] = 12
	rotation_map[ ROTATE_X_MINUS,  3 ] = 10
	rotation_map[ ROTATE_Y_PLUS ,  3 ] =  2
	rotation_map[ ROTATE_Y_MINUS,  3 ] =  1
	rotation_map[ ROTATE_Z_PLUS ,  3 ] =  5
	rotation_map[ ROTATE_Z_MINUS,  3 ] =  7
	
	rotation_map[ ROTATE_X_PLUS ,  4 ] = 11
	rotation_map[ ROTATE_X_MINUS,  4 ] =  9
	rotation_map[ ROTATE_Y_PLUS ,  4 ] =  1
	rotation_map[ ROTATE_Y_MINUS,  4 ] =  2
	rotation_map[ ROTATE_Z_PLUS ,  4 ] =  6
	rotation_map[ ROTATE_Z_MINUS,  4 ] =  8
	
	rotation_map[ ROTATE_X_PLUS ,  5 ] =  8
	rotation_map[ ROTATE_X_MINUS,  5 ] =  7
	rotation_map[ ROTATE_Y_PLUS ,  5 ] = 12
	rotation_map[ ROTATE_Y_MINUS,  5 ] =  9
	rotation_map[ ROTATE_Z_PLUS ,  5 ] =  1
	rotation_map[ ROTATE_Z_MINUS,  5 ] =  3
	
	rotation_map[ ROTATE_X_PLUS ,  6 ] =  7
	rotation_map[ ROTATE_X_MINUS,  6 ] =  8
	rotation_map[ ROTATE_Y_PLUS ,  6 ] = 11
	rotation_map[ ROTATE_Y_MINUS,  6 ] = 10
	rotation_map[ ROTATE_Z_PLUS ,  6 ] =  2
	rotation_map[ ROTATE_Z_MINUS,  6 ] =  4
	
	rotation_map[ ROTATE_X_PLUS ,  7 ] =  5
	rotation_map[ ROTATE_X_MINUS,  7 ] =  6
	rotation_map[ ROTATE_Y_PLUS ,  7 ] = 10
	rotation_map[ ROTATE_Y_MINUS,  7 ] = 11
	rotation_map[ ROTATE_Z_PLUS ,  7 ] =  3
	rotation_map[ ROTATE_Z_MINUS,  7 ] =  1
	
	rotation_map[ ROTATE_X_PLUS ,  8 ] =  6
	rotation_map[ ROTATE_X_MINUS,  8 ] =  5
	rotation_map[ ROTATE_Y_PLUS ,  8 ] =  9
	rotation_map[ ROTATE_Y_MINUS,  8 ] = 12
	rotation_map[ ROTATE_Z_PLUS ,  8 ] =  4
	rotation_map[ ROTATE_Z_MINUS,  8 ] =  2
	
	rotation_map[ ROTATE_X_PLUS ,  9 ] =  4
	rotation_map[ ROTATE_X_MINUS,  9 ] =  1
	rotation_map[ ROTATE_Y_PLUS ,  9 ] =  5
	rotation_map[ ROTATE_Y_MINUS,  9 ] =  8
	rotation_map[ ROTATE_Z_PLUS ,  9 ] = 11
	rotation_map[ ROTATE_Z_MINUS,  9 ] = 12
	
	rotation_map[ ROTATE_X_PLUS , 10 ] =  3
	rotation_map[ ROTATE_X_MINUS, 10 ] =  2
	rotation_map[ ROTATE_Y_PLUS , 10 ] =  6
	rotation_map[ ROTATE_Y_MINUS, 10 ] =  7
	rotation_map[ ROTATE_Z_PLUS , 10 ] = 12
	rotation_map[ ROTATE_Z_MINUS, 10 ] = 11
	
	rotation_map[ ROTATE_X_PLUS , 11 ] =  1
	rotation_map[ ROTATE_X_MINUS, 11 ] =  4
	rotation_map[ ROTATE_Y_PLUS , 11 ] =  7
	rotation_map[ ROTATE_Y_MINUS, 11 ] =  6
	rotation_map[ ROTATE_Z_PLUS , 11 ] = 10
	rotation_map[ ROTATE_Z_MINUS, 11 ] =  9
	
	rotation_map[ ROTATE_X_PLUS , 12 ] =  2
	rotation_map[ ROTATE_X_MINUS, 12 ] =  3
	rotation_map[ ROTATE_Y_PLUS , 12 ] =  8
	rotation_map[ ROTATE_Y_MINUS, 12 ] =  5
	rotation_map[ ROTATE_Z_PLUS , 12 ] =  9
	rotation_map[ ROTATE_Z_MINUS, 12 ] = 10
	
	
	
EndFunction

