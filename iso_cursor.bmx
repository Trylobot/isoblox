Rem
_______________________________
Project isoblox
This is a BlitzMax source file
Author is Tyler W.R. Cole
Started on September 30th, 2006
_______________________________
EndRem

Rem
TODO
 - flush out the scr_to_iso_HACK function
EndRem

Strict

Import "globals.bmx"
Import "coord.bmx"
Import "iso_block.bmx"
Import "iso_grid.bmx"

Type iso_cursor

	Field mode            'selector (basic|brush|select)
	Field time:TTimer     'cursor animation timer
	Field block:iso_block 'basic mode block; also contains global cursor offset
	Field group_isotype[] 'rotation selector
	Field group           'geometry selector
	Field brush:iso_grid  'brush data (like a clipboard)
	Field size:iso_coord  'selection extents
	
	Method New()
		mode = CURSOR_BASIC
		time = CreateTimer( 8 )
		block = New iso_block
		group_isotype = group_starting_index[..]
		group = 0
		brush = New iso_grid
		size = New iso_coord
	EndMethod
	
EndType

'temporary function, quickly hacked together and inefficient, but functional;
'also, belongs in [coord], not here
Function scr_to_iso_HACK:iso_coord( mouse:scr_coord, renderlist:TList )
	
	'if there's nothing to scan, return an invalid location, indicating that nothing's under the cursor
	If renderlist.IsEmpty() Then Return iso_coord.invalid()
	
	'scan the renderlist in reverse
	Local iter:TLink = renderlist.LastLink()
	Local screen_offset:scr_coord
	Local block_offset:iso_coord
	
	While iter <> Null
		block_offset = iso_block( iter.Value() ).offset
		screen_offset = iso_to_scr( block_offset )
		
		If Abs( mouse.x - screen_offset.x ) < 11 And Abs( mouse.y - screen_offset.y ) < 11
			Return block_offset
		EndIf
		
		iter = iter.PrevLink()
	EndWhile
	
	'Return an invalid location, because the mouse isn't hovering over anything
	Return iso_coord.invalid()
	
EndFunction

