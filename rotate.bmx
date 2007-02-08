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
	
	Select operation
		
		Case ROTATE_X_MINUS
			
			
			
		Case ROTATE_Y_MINUS
			
			
			
		Case ROTATE_Z_MINUS
			
			
			
		Case ROTATE_X_PLUS
			
			
			
		Case ROTATE_Y_PLUS
			
			
			
		Case ROTATE_Z_PLUS
			
			
		
	EndSelect
	
EndFunction

Function rotate%( operation, isotype )
	
	Return rotation_map[ operation, isotype ]
	
EndFunction

Function rotate_calc_plus_rotations()
	
	'this function's purpose:
	'cuts the number of literal definitions in half by using the principle that 
	'rotating 90 degrees on an axis is the same as rotating 270 degrees, and therefore
	'calculating the _MINUS rotation operations based on the existing literal ones
	For Local operation = 3 To 5
		For Local isotype = 0 To COUNT_BLOCKS
			
			rotation_map[ operation, isotype ] = ..
				rotation_map[ operation-3, ..
					rotation_map[ operation-3, ..
						rotation_map[ operation-3, isotype ]]]
			
		Next
	Next
	
EndFunction

Function rotate_init()
	
'________________________________________
	rotation_map[ ROTATE_X_MINUS,  0 ] =  0
	rotation_map[ ROTATE_Y_MINUS,  0 ] =  0
	rotation_map[ ROTATE_Z_MINUS,  0 ] =  0
	
'________________________________________
	rotation_map[ ROTATE_X_MINUS,  1 ] =  0
	rotation_map[ ROTATE_Y_MINUS,  1 ] =  0
	rotation_map[ ROTATE_Z_MINUS,  1 ] =  0
	
	rotation_map[ ROTATE_X_MINUS,  2 ] =  0
	rotation_map[ ROTATE_Y_MINUS,  2 ] =  0
	rotation_map[ ROTATE_Z_MINUS,  2 ] =  0
	
	rotation_map[ ROTATE_X_MINUS,  3 ] =  0
	rotation_map[ ROTATE_Y_MINUS,  3 ] =  0
	rotation_map[ ROTATE_Z_MINUS,  3 ] =  0
	
	rotation_map[ ROTATE_X_MINUS,  4 ] =  0
	rotation_map[ ROTATE_Y_MINUS,  4 ] =  0
	rotation_map[ ROTATE_Z_MINUS,  4 ] =  0
	
	rotation_map[ ROTATE_X_MINUS,  5 ] =  0
	rotation_map[ ROTATE_Y_MINUS,  5 ] =  0
	rotation_map[ ROTATE_Z_MINUS,  5 ] =  0
	
	rotation_map[ ROTATE_X_MINUS,  6 ] =  0
	rotation_map[ ROTATE_Y_MINUS,  6 ] =  0
	rotation_map[ ROTATE_Z_MINUS,  6 ] =  0
	
	rotation_map[ ROTATE_X_MINUS,  7 ] =  0
	rotation_map[ ROTATE_Y_MINUS,  7 ] =  0
	rotation_map[ ROTATE_Z_MINUS,  7 ] =  0
	
	rotation_map[ ROTATE_X_MINUS,  8 ] =  0
	rotation_map[ ROTATE_Y_MINUS,  8 ] =  0
	rotation_map[ ROTATE_Z_MINUS,  8 ] =  0
	
	rotation_map[ ROTATE_X_MINUS,  9 ] =  0
	rotation_map[ ROTATE_Y_MINUS,  9 ] =  0
	rotation_map[ ROTATE_Z_MINUS,  9 ] =  0
	
	rotation_map[ ROTATE_X_MINUS, 10 ] =  0
	rotation_map[ ROTATE_Y_MINUS, 10 ] =  0
	rotation_map[ ROTATE_Z_MINUS, 10 ] =  0
	
	rotation_map[ ROTATE_X_MINUS, 11 ] =  0
	rotation_map[ ROTATE_Y_MINUS, 11 ] =  0
	rotation_map[ ROTATE_Z_MINUS, 11 ] =  0
	
	rotation_map[ ROTATE_X_MINUS, 12 ] =  0
	rotation_map[ ROTATE_Y_MINUS, 12 ] =  0
	rotation_map[ ROTATE_Z_MINUS, 12 ] =  0
	
'________________________________________
	rotation_map[ ROTATE_X_MINUS, 13 ] =  0
	rotation_map[ ROTATE_Y_MINUS, 13 ] =  0
	rotation_map[ ROTATE_Z_MINUS, 13 ] =  0
	
	rotation_map[ ROTATE_X_MINUS, 14 ] =  0
	rotation_map[ ROTATE_Y_MINUS, 14 ] =  0
	rotation_map[ ROTATE_Z_MINUS, 14 ] =  0
	
	rotation_map[ ROTATE_X_MINUS, 15 ] =  0
	rotation_map[ ROTATE_Y_MINUS, 15 ] =  0
	rotation_map[ ROTATE_Z_MINUS, 15 ] =  0
	
	rotation_map[ ROTATE_X_MINUS, 16 ] =  0
	rotation_map[ ROTATE_Y_MINUS, 16 ] =  0
	rotation_map[ ROTATE_Z_MINUS, 16 ] =  0
	
	rotation_map[ ROTATE_X_MINUS, 17 ] =  0
	rotation_map[ ROTATE_Y_MINUS, 17 ] =  0
	rotation_map[ ROTATE_Z_MINUS, 17 ] =  0
	
	rotation_map[ ROTATE_X_MINUS, 18 ] =  0
	rotation_map[ ROTATE_Y_MINUS, 18 ] =  0
	rotation_map[ ROTATE_Z_MINUS, 18 ] =  0
	
	rotation_map[ ROTATE_X_MINUS, 19 ] =  0
	rotation_map[ ROTATE_Y_MINUS, 19 ] =  0
	rotation_map[ ROTATE_Z_MINUS, 19 ] =  0
	
	rotation_map[ ROTATE_X_MINUS, 20 ] =  0
	rotation_map[ ROTATE_Y_MINUS, 20 ] =  0
	rotation_map[ ROTATE_Z_MINUS, 20 ] =  0
	
	rotation_map[ ROTATE_X_MINUS, 21 ] =  0
	rotation_map[ ROTATE_Y_MINUS, 21 ] =  0
	rotation_map[ ROTATE_Z_MINUS, 21 ] =  0
	
	rotation_map[ ROTATE_X_MINUS, 22 ] =  0
	rotation_map[ ROTATE_Y_MINUS, 22 ] =  0
	rotation_map[ ROTATE_Z_MINUS, 22 ] =  0
	
	rotation_map[ ROTATE_X_MINUS, 23 ] =  0
	rotation_map[ ROTATE_Y_MINUS, 23 ] =  0
	rotation_map[ ROTATE_Z_MINUS, 23 ] =  0
	
	rotation_map[ ROTATE_X_MINUS, 24 ] =  0
	rotation_map[ ROTATE_Y_MINUS, 24 ] =  0
	rotation_map[ ROTATE_Z_MINUS, 24 ] =  0
	
	rotation_map[ ROTATE_X_MINUS, 25 ] =  0
	rotation_map[ ROTATE_Y_MINUS, 25 ] =  0
	rotation_map[ ROTATE_Z_MINUS, 25 ] =  0
	
	rotation_map[ ROTATE_X_MINUS, 26 ] =  0
	rotation_map[ ROTATE_Y_MINUS, 26 ] =  0
	rotation_map[ ROTATE_Z_MINUS, 26 ] =  0
	
	rotation_map[ ROTATE_X_MINUS, 27 ] =  0
	rotation_map[ ROTATE_Y_MINUS, 27 ] =  0
	rotation_map[ ROTATE_Z_MINUS, 27 ] =  0
	
	rotation_map[ ROTATE_X_MINUS, 28 ] =  0
	rotation_map[ ROTATE_Y_MINUS, 28 ] =  0
	rotation_map[ ROTATE_Z_MINUS, 28 ] =  0
	
	rotation_map[ ROTATE_X_MINUS, 29 ] =  0
	rotation_map[ ROTATE_Y_MINUS, 29 ] =  0
	rotation_map[ ROTATE_Z_MINUS, 29 ] =  0
	
	rotation_map[ ROTATE_X_MINUS, 30 ] =  0
	rotation_map[ ROTATE_Y_MINUS, 30 ] =  0
	rotation_map[ ROTATE_Z_MINUS, 30 ] =  0
	
	rotation_map[ ROTATE_X_MINUS, 31 ] =  0
	rotation_map[ ROTATE_Y_MINUS, 31 ] =  0
	rotation_map[ ROTATE_Z_MINUS, 31 ] =  0
	
	rotation_map[ ROTATE_X_MINUS, 32 ] =  0
	rotation_map[ ROTATE_Y_MINUS, 32 ] =  0
	rotation_map[ ROTATE_Z_MINUS, 32 ] =  0
	
	rotation_map[ ROTATE_X_MINUS, 33 ] =  0
	rotation_map[ ROTATE_Y_MINUS, 33 ] =  0
	rotation_map[ ROTATE_Z_MINUS, 33 ] =  0
	
	rotation_map[ ROTATE_X_MINUS, 34 ] =  0
	rotation_map[ ROTATE_Y_MINUS, 34 ] =  0
	rotation_map[ ROTATE_Z_MINUS, 34 ] =  0
	
	rotation_map[ ROTATE_X_MINUS, 35 ] =  0
	rotation_map[ ROTATE_Y_MINUS, 35 ] =  0
	rotation_map[ ROTATE_Z_MINUS, 35 ] =  0
	
	rotation_map[ ROTATE_X_MINUS, 36 ] =  0
	rotation_map[ ROTATE_Y_MINUS, 36 ] =  0
	rotation_map[ ROTATE_Z_MINUS, 36 ] =  0
	
	rotation_map[ ROTATE_X_MINUS, 37 ] =  0
	rotation_map[ ROTATE_Y_MINUS, 37 ] =  0
	rotation_map[ ROTATE_Z_MINUS, 37 ] =  0
	
	rotation_map[ ROTATE_X_MINUS, 38 ] =  0
	rotation_map[ ROTATE_Y_MINUS, 38 ] =  0
	rotation_map[ ROTATE_Z_MINUS, 38 ] =  0
	
	rotation_map[ ROTATE_X_MINUS, 39 ] =  0
	rotation_map[ ROTATE_Y_MINUS, 39 ] =  0
	rotation_map[ ROTATE_Z_MINUS, 39 ] =  0
	
	rotation_map[ ROTATE_X_MINUS, 40 ] =  0
	rotation_map[ ROTATE_Y_MINUS, 40 ] =  0
	rotation_map[ ROTATE_Z_MINUS, 40 ] =  0
	
	rotation_map[ ROTATE_X_MINUS, 41 ] =  0
	rotation_map[ ROTATE_Y_MINUS, 41 ] =  0
	rotation_map[ ROTATE_Z_MINUS, 41 ] =  0
	
	rotation_map[ ROTATE_X_MINUS, 42 ] =  0
	rotation_map[ ROTATE_Y_MINUS, 42 ] =  0
	rotation_map[ ROTATE_Z_MINUS, 42 ] =  0
	
	rotation_map[ ROTATE_X_MINUS, 43 ] =  0
	rotation_map[ ROTATE_Y_MINUS, 43 ] =  0
	rotation_map[ ROTATE_Z_MINUS, 43 ] =  0
	
	rotation_map[ ROTATE_X_MINUS, 44 ] =  0
	rotation_map[ ROTATE_Y_MINUS, 44 ] =  0
	rotation_map[ ROTATE_Z_MINUS, 44 ] =  0
	
	rotation_map[ ROTATE_X_MINUS, 45 ] =  0
	rotation_map[ ROTATE_Y_MINUS, 45 ] =  0
	rotation_map[ ROTATE_Z_MINUS, 45 ] =  0
	
	rotation_map[ ROTATE_X_MINUS, 46 ] =  0
	rotation_map[ ROTATE_Y_MINUS, 46 ] =  0
	rotation_map[ ROTATE_Z_MINUS, 46 ] =  0
	
	rotation_map[ ROTATE_X_MINUS, 47 ] =  0
	rotation_map[ ROTATE_Y_MINUS, 47 ] =  0
	rotation_map[ ROTATE_Z_MINUS, 47 ] =  0
	
	rotation_map[ ROTATE_X_MINUS, 48 ] =  0
	rotation_map[ ROTATE_Y_MINUS, 48 ] =  0
	rotation_map[ ROTATE_Z_MINUS, 48 ] =  0
	
'________________________________________
	
	
	rotate_calc_plus_rotations()
	
EndFunction

