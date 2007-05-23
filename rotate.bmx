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

Import BRL.StandardIO

Import "globals.bmx"
Import "iso_block.bmx"

'TODO
'1. finish the rotation_map matrix
'2. finish the rotate_about_anchor algorithm

Function rotate_init()
	
	map_set_literal_definitions()
	map_copy_duplicate_sets()
	map_calc_plus_rotations()

	PRINT_DEBUG()
	
EndFunction

Function PRINT_DEBUG()
	
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
	
EndFunction

Function rotate%( operation, isotype )
	
	Return rotation_map[ operation, isotype ]
	
EndFunction

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

Function map_copy_duplicate_sets()
	
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
	
EndFunction

Function map_calc_plus_rotations()
	
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
	
EndFunction

Function map_set_literal_definitions()
	
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
	
EndFunction

