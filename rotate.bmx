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

Function rotate_copy_duplicate_sets()
	
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
			rotation_map[ operation, isotype ] = 24 + rotation_map[ operation, isotype - 24 ]
		Next
	Next
	
EndFunction

Function rotate_calc_plus_rotations()
	
	Return	
	
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
	
	rotation_map = New Int[ 6, COUNT_BLOCKS ]
	
	rotation_map[ ROTATE_X_MINUS,  0 ] =  0
	rotation_map[ ROTATE_Y_MINUS,  0 ] =  0
	rotation_map[ ROTATE_Z_MINUS,  0 ] =  0
	
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
	
	rotation_map[ ROTATE_X_MINUS, 61 ] =  0
	rotation_map[ ROTATE_Y_MINUS, 61 ] =  0
	rotation_map[ ROTATE_Z_MINUS, 61 ] =  0
	
	rotation_map[ ROTATE_X_MINUS, 62 ] =  0
	rotation_map[ ROTATE_Y_MINUS, 62 ] =  0
	rotation_map[ ROTATE_Z_MINUS, 62 ] =  0
	
	rotation_map[ ROTATE_X_MINUS, 63 ] =  0
	rotation_map[ ROTATE_Y_MINUS, 63 ] =  0
	rotation_map[ ROTATE_Z_MINUS, 63 ] =  0
	
	rotation_map[ ROTATE_X_MINUS, 64 ] =  0
	rotation_map[ ROTATE_Y_MINUS, 64 ] =  0
	rotation_map[ ROTATE_Z_MINUS, 64 ] =  0
	
	rotation_map[ ROTATE_X_MINUS, 65 ] =  0
	rotation_map[ ROTATE_Y_MINUS, 65 ] =  0
	rotation_map[ ROTATE_Z_MINUS, 65 ] =  0
	
	rotation_map[ ROTATE_X_MINUS, 66 ] =  0
	rotation_map[ ROTATE_Y_MINUS, 66 ] =  0
	rotation_map[ ROTATE_Z_MINUS, 66 ] =  0
	
	rotation_map[ ROTATE_X_MINUS, 67 ] =  0
	rotation_map[ ROTATE_Y_MINUS, 67 ] =  0
	rotation_map[ ROTATE_Z_MINUS, 67 ] =  0
	
	rotation_map[ ROTATE_X_MINUS, 68 ] =  0
	rotation_map[ ROTATE_Y_MINUS, 68 ] =  0
	rotation_map[ ROTATE_Z_MINUS, 68 ] =  0
	
	rotate_copy_duplicate_sets()
	
	rotate_calc_plus_rotations()
	
EndFunction

