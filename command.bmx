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

Function command_move_cursor( status:message_nanny, grid:iso_grid, cursor:iso_cursor, delta:iso_coord )
		
	If Not cursor.offset.add( delta ).is_invalid()
		cursor.offset = cursor.offset.add( delta )
		command_expand_grid_for_cursor( grid, cursor )
	Else
		
	EndIf
	
EndFunction

Function command_insert( status:message_nanny, grid:iso_grid, cursor:iso_cursor )

	If SOUND Then PlaySound( high_click )
	
	Select cursor.mode
	
		Case CURSOR_BASIC
	
			Local new_block:iso_block = cursor.basic_block.copy()
			new_block.offset = cursor.offset.copy()
			grid.insert_new_block( new_block )
			
		Case CURSOR_BRUSH
			
			Local new_block:iso_block
			Local iter:iso_block
			
			For iter = EachIn cursor.brush_grid.blocklist
				new_block = iter.copy()
				new_block.offset = cursor.offset.add( iter.offset )
				grid.insert_new_block( new_block )
			Next
			
	EndSelect

EndFunction

Function command_delete( grid:iso_grid, cursor:iso_cursor )
	
	If SOUND Then PlaySound( low_click )
	
	Select cursor.mode
	
		Case CURSOR_BASIC
			grid.erase_at_offset( cursor.offset )
			
		Case CURSOR_BRUSH
			For Local iter:iso_block = EachIn cursor.brush_grid.blocklist
				grid.erase_at_offset( cursor.offset.add( iter.offset ))
			Next
			
		Case CURSOR_SELECT
			Local hit_list:TList = grid.intersection_with_ghost( cursor.offset, cursor.select_ghost )
			For Local iter:iso_block = EachIn hit_list
				grid.erase_at_offset( iter.offset )
			Next
			
	EndSelect
	
EndFunction

Function command_expand_grid_for_cursor( grid:iso_grid, cursor:iso_cursor )
	
	Select cursor.mode
		Case CURSOR_BASIC
			grid.expand_for_subvolume( cursor.offset, iso_coord.create( 1, 1, 1 ))
			
		Case CURSOR_BRUSH
			grid.expand_for_subvolume( cursor.offset, cursor.brush_grid.size )
			
		Case CURSOR_SELECT
			grid.expand_for_subvolume( cursor.offset, cursor.select_ghost.size )
			
	EndSelect
	
EndFunction

Function command_grid_save( status:message_nanny, grid:iso_grid )

	status.append( "saving iso_grid ..." )
	Local filename$ = ..
		fileman_grid_save_auto( grid )
	status.append( "iso_grid $gsaved $Dto [$B"+filename+"$D]" )

EndFunction

Function command_brush_load( status:message_nanny, grid:iso_grid, cursor:iso_cursor )

	status.append( "$prequesting filename" )
	Local filename$ = fileman_grid_load_system( cursor.brush_grid )
	If filename <> "ERROR"
		
		status.append( "loading $Biso_grid $Das $Bbrush $Dfrom [$B" + filename + "$D] ..." )
		cursor.mode = CURSOR_BRUSH
		cursor.brush_grid.reduce_to_contents()
		command_expand_grid_for_cursor( grid, cursor )
		status.append( "cursor brush $gloaded successfully" )
		
	Else 'filename = "ERROR"
		status.append( "$rerror encountered! $ynothing loaded" )
	EndIf

EndFunction

Function command_grid_load( status:message_nanny, grid:iso_grid, cursor:iso_cursor )
		
	status.append( "$prequesting $Bfilename" )
	Local filename$ = fileman_grid_load_system( grid )
	If filename <> "ERROR"
		
		status.append( "loading $Biso_grid $Dfrom [$B" + filename + "$D] ..." )
		command_expand_grid_for_cursor( grid, cursor )
		status.append( "iso_grid $gloaded successfully" )
		
	Else 'filename = "ERROR"
		status.append( "$rerror encountered! $ynothing loaded" )
	EndIf
	
EndFunction

Function command_copy( status:message_nanny, grid:iso_grid, cursor:iso_cursor )
			
	status.append( "copying selected blocks to brush" )
	Local size:iso_coord = cursor.select_ghost.size
	Local intersect_list:TList = ..
		grid.intersection_with_ghost( ..
			cursor.offset, ..
			cursor.select_ghost )
	
	If Not intersect_list.isEmpty()
	
		cursor.brush_grid.set( size, intersect_list )
		cursor.brush_grid.reduce_to_contents()
		cursor.mode = CURSOR_BRUSH
		status.append( "selection $gcopied $Dto brush" )
	
	Else 'intersect_list.isEmpty()
	
		status.append( "$bnothing to copy" )
		
	EndIf
			
EndFunction

Function command_select_all( status:message_nanny, grid:iso_grid, cursor:iso_cursor )
	
	cursor.mode = CURSOR_SELECT
	cursor.offset.set( 0, 0, 0 )
	cursor.select_ghost.resize( grid.size )
	
EndFunction

