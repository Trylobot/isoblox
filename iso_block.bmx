Rem
_______________________________
Project isoblox
This is a BlitzMax source file
Author is Tyler W.R. Cole
Started on September 30th, 2006
_______________________________
EndRem

Strict

Import "globals.bmx" 'for rotation_map[]
Import "coord.bmx"   'for {iso_coord} and {scr_coord}

Type iso_block
	
	Field isotype              'index into master sprite array; thus implies BOTH (psuedo)geometry and rotation
	Field offset:iso_coord     'offset in units of 3D iso-space from the iso-origin
	Field draw_coord:scr_coord 'offset in screen pixels from screen origin
	Field red                  'color component
	Field green                'color component
	Field blue                 'color component
	'Field alpha#               'alpha component
	
	'New_________________________________________________________________________________________________
	Method New()
		'defaults: offset is farthest corner, isotype is block 0 (cube), colored white, and 100% opaque
		offset = New iso_coord
		draw_coord = New scr_coord
		isotype = 0
		red = 255
		green = 255
		blue = 255
		'alpha = 1.000
	EndMethod
	
	'Create___________________________________________________________________________________________
	Function create:iso_block( initial_isotype, initial_offset:iso_coord, initial_red, initial_green, initial_blue ) ', initial_alpha# )
		Local new_block:iso_block = New iso_block
		new_block.offset = initial_offset.copy()
		new_block.draw_coord = iso_to_scr( new_block.offset )
		new_block.isotype = initial_isotype
		new_block.red = initial_red
		new_block.green = initial_green
		new_block.blue = initial_blue
		'new_block.alpha = initial_alpha
		Return new_block
	EndFunction
	
	'Copy_____________________________________________________________________________________________
	Method copy:iso_block()
		Return Create( isotype, offset, red, green, blue ) ', alpha )
	EndMethod
	
	'Clone____________________________________________________________________________________________
	'important note: this method is "by value"
	Method clone( source:iso_block )
		offset = source.offset.copy()
		draw_coord = source.draw_coord.copy()
		isotype = source.isotype
		red = source.red
		green = source.green
		blue = source.blue
		'alpha = source.alpha
	EndMethod
	
	'Rotate___________________________________________________________________________________________
	Method rotate( operation )
		isotype = rotation_map[ operation, isotype ]
	EndMethod

	'Compare__________________________________________________________________________________________
	Method compare( other:Object )
		Return offset.compare( iso_block( other ).offset )
	EndMethod
	
	'Is Invalid_______________________________________________________________________________________
	Method is_invalid()
		Return ..
			isotype < 0 Or ..
			offset.is_invalid() Or ..
			red < 0 Or red > 255 Or ..
			green < 0 Or green > 255 Or ..
			blue < 0 Or blue > 255 ' Or ..
			'alpha < 0.000 Or alpha > 1.000
	EndMethod
	
	'To String________________________________________________________________________________________
	Method str$()
		Return "[iso_block] isotype("+isotype+");offset"+offset.str()+";rgba("+red+","+green+","+blue+")" '","+alpha+")"
	EndMethod
	
EndType

