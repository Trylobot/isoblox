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
Import "iso_block.bmx"
Import "iso_grid.bmx"

Type iso_cursor

	Field mode                        'basic/brush/select/delete selector
	Field time:TTimer                 'cursor animation timer
	Field frame                       'animation frame
	Field offset:iso_coord            'cursor anchor point (shared)
	Field basic_block:iso_block       'basic mode block
	Field group                       'geometry group selector
	Field group_isotype[]             'multiple offset memory (1 per group)
	Field brush_grid:iso_grid         'brush mode content
	Field select_ghost:iso_ghost_grid 'select mode content
	
	Method New()
		
		mode = CURSOR_BASIC
		time = CreateTimer( 8 )
		frame = 0
		offset = New iso_coord
		basic_block = New iso_block
		group = 0
		group_isotype = group_starting_index[..]
		brush_grid = New iso_grid
		select_ghost = New iso_ghost_grid
		
	EndMethod
	
	Method calculate_frame()
		
		frame = time.Ticks() Mod COUNT_GHOST_FRAMES
		
	EndMethod
	
EndType
