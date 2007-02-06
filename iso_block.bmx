Rem
_______________________________
Project isoblox
This is a BlitzMax source file
Author is Tyler W.R. Cole
Started on September 30th, 2006
_______________________________
EndRem

Strict
Import "coord.bmx"

Type iso_block
	
	Field isotype          'isometric block type (image array index)
	Field offset:iso_coord 'offset from local origin
	Field red              'color
	Field green            'color
	Field blue             'color
	Field alpha#           'alpha
	
	Method New()
		
		'defaults: offset is far back corner, cube block, white, and opaque
		offset = New iso_coord
		isotype = 0
		red = 255
		green = 255
		blue = 255
		alpha = 1.000
		
	EndMethod
	
	Function create:iso_block( initial_isotype, initial_offset:iso_coord, initial_red, initial_green, initial_blue, initial_alpha# )
		
		Local new_block:iso_block = New iso_block
		new_block.offset = initial_offset.copy()
		new_block.isotype = initial_isotype
		new_block.red = initial_red
		new_block.green = initial_green
		new_block.blue = initial_blue
		new_block.alpha = initial_alpha
		
		Return new_block
		
	EndFunction
	
	Method copy:iso_block()
		
		Return create( isotype, offset, red, green, blue, alpha )
		
	EndMethod
	
	Method compare( target:Object )
		
		Local other:iso_block = iso_block( target )
		
		'difference of the offset layer
		Local result = offset.value() - other.offset.value()
		
		'tiebreaker (only matters when in the same layer)
		If result = 0
			
			'y component tiebreaker (supercedes x and z components)
			If offset.y > other.offset.y
				result :+ 4
			ElseIf offset.y < other.offset.y
				result :- 4
			EndIf
			
			'x component tiebreaker (supercedes z component)
			If offset.x > other.offset.x
				result :+ 2
			ElseIf offset.x < other.offset.x
				result :- 2
			EndIf
			
			'z component tiebreaker (lowest priority)
			If offset.z > other.offset.z
				result :+ 1
			ElseIf offset.z < other.offset.z
				result :- 1
			EndIf
			
		EndIf
		
		Return result
		
	EndMethod
	
	Method str$()
		
		Return "[iso_block] isotype("+isotype+");offset"+offset.str()+";rgba("+red+","+green+","+blue+","+alpha+")"
		
	EndMethod
	
	Function invalid:iso_block()
		
		Return create( -1, iso_coord.invalid(), -1, -1, -1, -1.000 )
		
	EndFunction
	
	Method is_invalid()
		
		Return ..
			isotype < 0 Or ..
			offset.is_invalid() Or ..
			red < 0 Or red > 255 Or ..
			green < 0 Or green > 255 Or ..
			blue < 0 Or blue > 255 Or ..
			alpha < 0.000 Or alpha > 1.000
		
	EndMethod
	
EndType

Type iso_face
	
	Field facetype         'isometric block face type (faces on a cube, 1 of 6)
	Field offset:iso_coord 'offset from local origin
	
	'TODO
	'OPTIMIZE THIS:
	'instead of a glass box, imagine a glass wireframe!
	'will be faster, but take more sprites.
	'one piece for each of the four corners of each side     (24)
	'plus one piece for each of the four edges of each sides (24) = (48 total)
	'this will require more "face types" and such
	'and a more complex "resize" algorithm and block_to_face_compare algorithm
	'but draw function will be the same
	
	Method New()
		
		offset = New iso_coord
		
	EndMethod
	
	Function create:iso_face( initial_facetype, initial_offset:iso_coord )
		
		Local new_face:iso_face = New iso_face
		new_face.facetype = initial_facetype
		new_face.offset = initial_offset.copy()
		
		Return new_face
		
	EndFunction
	
	Method copy:iso_face()
		
		Return create( facetype, offset.copy() )
		
	EndMethod
	
	Method compare( target:Object )
		
		Local other:iso_face = iso_face( target )
		
		'difference of the offset layer
		Local result = offset.value() - other.offset.value()
		
		'tiebreaker (only matters when in the exact same location)
		If result = 0 And offset.x = other.offset.x And offset.y = other.offset.y And offset.z = other.offset.z
			
			result = facetype - other.facetype
			
		EndIf
		
		Return result
		
	EndMethod
	
EndType

Function block_to_face_compare( block_A:iso_block, face_B:iso_face )
	
	'difference of the offset layer
	Local result = block_A.offset.value() - face_B.offset.value()
	
	'tiebreaker (only matters when in the same layer)
	If result = 0
		
		'y component tiebreaker (supercedes x and z components)
		If block_A.offset.y > face_B.offset.y
			result :+ 8
		ElseIf block_A.offset.y < face_B.offset.y
			result :- 8
		EndIf
		
		'x component tiebreaker (supercedes z component)
		If block_A.offset.x > face_B.offset.x
			result :+ 4
		ElseIf block_A.offset.x < face_B.offset.x
			result :- 4
		EndIf
		
		'z component tiebreaker (lowest priority)
		If block_A.offset.z > face_B.offset.z
			result :+ 2
		ElseIf block_A.offset.z < face_B.offset.z
			result :- 2
		EndIf
		
		'facetype tiebreaker (supercedes any other component)
		If face_B.facetype > 2 'facetype IN FRONT
			result :+ 1
		Else 'facetype BEHIND
			result :- 1
		EndIf
		
	EndIf
	
	Return result
		
EndFunction
