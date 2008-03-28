Rem
_______________________________
Project isoblox
This is a BlitzMax source file
Author is Tyler W.R. Cole
Started on September 30th, 2006
_______________________________
EndRem

Strict

Import "globals.bmx"
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
	
	Function Create:iso_block( initial_isotype, initial_offset:iso_coord, initial_red, initial_green, initial_blue, initial_alpha# )
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
		Return Create( isotype, offset, red, green, blue, alpha )
	EndMethod
	
	Method clone( source:iso_block )
		offset = source.offset.copy()
		isotype = source.isotype
		red = source.red
		green = source.green
		blue = source.blue
		alpha = source.alpha
	EndMethod
	
	Method compare( other:Object )
		Return offset.compare( iso_block( other ).offset )
	EndMethod
	
	Function invalid:iso_block()
		Return Create( -1, iso_coord.invalid(), -1, -1, -1, -1.000 )
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
	
	Method str$()
		Return "[iso_block] isotype("+isotype+");offset"+offset.str()+";rgba("+red+","+green+","+blue+","+alpha+")"
	EndMethod
	
EndType

Type iso_face
	
	Field face             'selector; face on the unit cube
	Field facetype         'type of face unit on the face
	Field offset:iso_coord 'offset from local origin
	
	'TODO
	'OPTIMIZE THIS:
	'one piece for each of the four corners of each side     (24)
	'plus one piece for each of the four edges of each sides (24) = (48 total)
	'this will require more "face types" and such
	'and a more complex "resize" algorithm and block_to_face_compare algorithm
	'but draw function will be the same
	
	Method New()
		offset = New iso_coord
	EndMethod
	
	Function Create:iso_face( initial_face, initial_facetype, initial_offset:iso_coord )
		Local new_face:iso_face = New iso_face
		new_face.facetype = initial_facetype
		new_face.offset = initial_offset.copy()
		
		Return new_face
	EndFunction
	
	Method copy:iso_face()
		Return Create( face, facetype, offset.copy() )
	EndMethod
	
	Method compare( target:Object )
		'type casting is unfortunately necessary, since the function calling this one
		'has no knowledge of the iso_face class, and must pass the default Object type.
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
	
	Local layer_difference = block_A.offset.value() - face_B.offset.value()
	
	If layer_difference <> 0 'different layer, easiest and most common
		
		Return layer_difference
		
	Else 'same layer
		'The order of these checks is important, and is based on a graphical kludge that resulted
		'from the particular style of isometric pixel art I used in my block sprites.
		
		'different Y-component?
		If block_A.offset.y > face_B.offset.y
			Return 1
		ElseIf block_A.offset.y < face_B.offset.y
			Return -1
		EndIf
		
		'different X-component?
		If block_A.offset.x > face_B.offset.x
			Return 1
		ElseIf block_A.offset.x < face_B.offset.x
			Return -1
		EndIf
		
		'different Z-component?
		If block_A.offset.z > face_B.offset.z
			Return 1
		ElseIf block_A.offset.z < face_B.offset.z
			Return -1
		EndIf
		
		'face is behind the block, or in front of it?
		If face_B.facetype < (COUNT_FACES / 2)
			Return 1
		Else 'face_B.facetype >= (COUNT_FACES / 2)
			Return -1
		EndIf
		
	EndIf
	
EndFunction
