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
 - fix command_expand_grid_for_cursor, it's broken
 - migrate the actual command actions into here. some of them still remain in controller.
EndRem

Strict

Import BRL.FreeAudioAudio

Import "globals.bmx"
Import "coord.bmx"
Import "iso_block.bmx"
Import "iso_grid.bmx"
Import "iso_cursor.bmx"
Import "fileman.bmx"
Import "message_nanny.bmx"

'Move Cursor_______________________________________________________________________________________
Function command_move_cursor( status:message_nanny, grid:iso_grid, cursor:iso_cursor, delta:iso_coord )
	cursor.block.offset = cursor.block.offset.add( delta )
EndFunction

'Insert__________________________________________________________________________________________________
Function command_insert( status:message_nanny, grid:iso_grid, cursor:iso_cursor )
	Local success = False
	Select cursor.mode
		Case CURSOR_BASIC
			success = grid.insert_block( cursor.block )
		Case CURSOR_BRUSH
			success = grid.insert_brush( cursor.block.offset, cursor.brush )
	EndSelect
	If SOUND And success Then PlaySound( high_click )
EndFunction

'Delete__________________________________________________________________________________________________
Function command_delete( grid:iso_grid, cursor:iso_cursor )
	If SOUND Then PlaySound( low_click )
	Select cursor.mode
		Case CURSOR_BASIC
			grid.delete_block( cursor.block.offset )
		Case CURSOR_BRUSH 'deleting with the brush doesn't really make sense...
			'grid.delete_volume( cursor.block.offset, cursor.size )
		Case CURSOR_SELECT
			cursor.brush = grid.copy_volume( cursor.block.offset, cursor.size )
	EndSelect
EndFunction

'This function has been disabled, because I don't want to use it any more.
Rem
'Expand Grid for Cursor_____________________________________________________________________________
Function command_expand_grid_for_cursor( grid:iso_grid, cursor:iso_cursor )
	Select cursor.mode
		Case CURSOR_BASIC
			grid.expand_for_subvolume( cursor.offset, iso_coord.Create( 1, 1, 1 ))
		Case CURSOR_BRUSH
			grid.expand_for_subvolume( cursor.offset, cursor.brush_grid.size )
		Case CURSOR_SELECT
			grid.expand_for_subvolume( cursor.offset, cursor.select_ghost.size )
	EndSelect
EndFunction
EndRem

'Save__________________________________________________________________________________________________
Function command_grid_save( status:message_nanny, grid:iso_grid )

	status.append( "saving iso_grid ..." )
	Local filename$ = ..
		fileman_grid_save_auto( grid )
	status.append( "iso_grid $gsaved $Dto [$B"+filename+"$D]" )

EndFunction

'Load to Brush________________________________________________________________________________________
Function command_brush_load( status:message_nanny, grid:iso_grid, cursor:iso_cursor )

	status.append( "$prequesting filename" )
	Local filename$ = fileman_grid_load_system( cursor.brush )
	If filename <> "ERROR"
		
		status.append( "loading $Biso_grid $Das $Bbrush $Dfrom [$B" + filename + "$D] ..." )
		cursor.mode = CURSOR_BRUSH
		'cursor.brush_grid.reduce_to_contents()
		'command_expand_grid_for_cursor( grid, cursor )
		status.append( "cursor brush $gloaded successfully" )
		
	Else 'filename = "ERROR"
		status.append( "$rerror encountered! $ynothing loaded" )
	EndIf

EndFunction

'Load to Canvas_______________________________________________________________________________________
Function command_grid_load( status:message_nanny, grid:iso_grid, cursor:iso_cursor )
		
	status.append( "$prequesting $Bfilename" )
	Local filename$ = fileman_grid_load_system( grid )
	If filename <> "ERROR"
		
		status.append( "loading $Biso_grid $Dfrom [$B" + filename + "$D] ..." )
		'command_expand_grid_for_cursor( grid, cursor )
		status.append( "iso_grid $gloaded successfully" )
		
	Else 'filename = "ERROR"
		status.append( "$rerror encountered! $ynothing loaded" )
	EndIf
	
EndFunction

'Copy_________________________________________________________________________________________________
Function command_copy( status:message_nanny, grid:iso_grid, cursor:iso_cursor )
			
	cursor.add_brush( grid.copy_volume( cursor.block.offset, cursor.size ))
			
EndFunction

'Select All________________________________________________________________________________________
Function command_select_all( status:message_nanny, grid:iso_grid, cursor:iso_cursor )
	
	cursor.mode = CURSOR_SELECT
	cursor.block.offset.set( 0, 0, 0 )
	cursor.size = grid.size
	
EndFunction

