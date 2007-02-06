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
Import "fileman.bmx"
Import "coord.bmx"
Import "iso_block.bmx"
Import "iso_grid.bmx"
Import "iso_cursor.bmx"
Import "rotate.bmx"
Import "draw.bmx"
Import "message_nanny.bmx"

Type controller
	
	Field mouse:scr_coord
	Field grid:iso_grid
	Field cursor:iso_cursor
	Field status:message_nanny
	
	Field SHOW_SHADOWS
	Field SHOW_GRIDLINES
	Field SHOW_BLOCKS
	Field SHOW_CURSOR
	Field OUTLINE_WIDTH
	Field SHOW_STATUS_MESSAGES
	Field SHOW_HELP

'_________________________________________________________________________
	Method New()
		
		mouse = scr_coord.create( MouseX(), MouseY() )
		grid = iso_grid.create(..
			iso_coord.create( GRID_X, GRID_Y, GRID_Z ))
		cursor = New iso_cursor
		cursor.offset = iso_coord.create( grid.size.x / 2, grid.size.y / 2, 0 )
		cursor.select_ghost.resize( iso_coord.create( 1, 1, 1 ))
		cursor.select_ghost.red   = 180
		cursor.select_ghost.green = 180
		cursor.select_ghost.blue  = 240
		cursor.select_ghost.alpha = 0.450
		status = New message_nanny
		
		SHOW_SHADOWS         = True
		SHOW_GRIDLINES       = True
		SHOW_BLOCKS          = True
		SHOW_CURSOR          = True
		OUTLINE_WIDTH        = 1
		SHOW_STATUS_MESSAGES = True
		SHOW_HELP            = False
		
	EndMethod
	
'_________________________________________________________________________
	Method chug()
		
		keyboard_input()
		draw()
		
		If KeyHit( Key_F12 )
			status.append( "capturing screenshot ..." )
			Local filename$ = fileman_screenshot_auto()
			status.append( "screenshot $gsaved $Dto [$B" + filename + "$D]" )
		EndIf
				
	EndMethod
	
'_________________________________________________________________________
	Method draw()

		SetOrigin( ORIGIN_X, ORIGIN_Y )
		ALPHA_BLINK_1 = 0.750 + 0.250 * Sin( cursor_blink_timer.Ticks() )
		ALPHA_BLINK_2 = 0.500 - 0.250 * Sin( cursor_blink_timer.Ticks() )
		
		If SHOW_SHADOWS And SHOW_BLOCKS
			draw_block_shadows( grid )
			If SHOW_CURSOR
				draw_cursor_shadows( cursor )
			EndIf
		EndIf
		
		If SHOW_GRIDLINES
			draw_gridlines( grid )
		EndIf
		
		If OUTLINE_WIDTH > 0
			draw_outlines( grid, cursor, OUTLINE_WIDTH )
		EndIf
		
		If SHOW_BLOCKS
			
			If Not SHOW_CURSOR
				draw_blocks( grid )
			Else 'SHOW_CURSOR
				If Not grid.empty()
					draw_blocks_with_cursor( grid, cursor )
				Else 'grid.empty()
					draw_cursor( cursor )
				EndIf
				draw_cursor_wireframe( cursor )
			EndIf
			
		EndIf
		
		If SHOW_STATUS_MESSAGES
			status.draw()
		EndIf
		
		If KeyHit( Key_F1 )
			SHOW_HELP = Not SHOW_HELP
		EndIf
		If SHOW_HELP
			draw_help()
		EndIf
		
	EndMethod
	
'_________________________________________________________________________
Function draw_help()
	
	SetOrigin( 0, 0 )
	SetColor( 255, 255, 255 )
	SetAlpha( 0.750 )
	DrawRect( 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT )
	
	Local scr:scr_coord = scr_coord.create( 1, 1 )
	
	draw_big_msg( ..
		"$Bisoblox $bhelp~n"+..
		"~n"+..
		"$Bbasic $Dblock tool      {$BZ$D}~n"+..
		"$Bbrush $Dtool            {$BX$D}~n"+..
		"$Bselection $Dtool        {$BC$D}~n"+..
		"$bmove $Dcursor           {$BW$D,$BA$D,$BS$D,$BD$D,$BQ$D,$BE$D}~n"+..
		"$pinsert $Dblock(s)       {$Bspacebar$D}~n"+..
		"$ccycle $Dbasic blocks    {$Btab$D}~n"+..
		"$yrotate $Dblock(s)       {$BR$D,$BT$D},{$BF$D,$BG$D},{$BV$D,$BB$D}~n"+..
		"change $Bselection size$D {$Bshift$D}+{$BW$D,$BA$D,$BS$D,$BD$D,$BQ$D,$BE$D}~n"+..
		"change $Bgrid size$D      {$Bctrl$D}+{$BW$D,$BA$D,$BS$D,$BD$D,$BQ$D,$BE$D}~n"+..
		"change basic $rR$gG$bB$BA$D     disabled~n"+..
		"$rdelete $Dselected       {$Btilde$D}~n"+..
		"$bsave grid $Dto file     {$BF2$D}~n"+..
		"$gload brush $Dfrom file  {$BF3$D}~n"+..
		"$gload grid $Dfrom file   {$BF4$D}~n"+..
		"$gcopy $Dselection        {$BF5$D}~n"+..
		"take $bscreenshot$D       {$BF12$D}~n"+..
		"layers $gon$D/$yoff         {$B1$D,$B2$D,$B3$D,$B4$D,$B5$D,$B6$D,$B7$D}~n"+..
		"select $Ball$D            disabled~n"+..
		"drag $Bviewport$D         {$Bmouse 2$D}~n"+..
		"", scr )
	
EndFunction

'_________________________________________________________________________
	Method load_assets()
		
		status.append( "loading assets .." )
		fileman_load_image_libraries()
		rotate_init()
		
		status.append( "$gloaded" )
		
	EndMethod
	
'_________________________________________________________________________
	Method keyboard_input()
		
		Local patience = False
		If program_timer_ticks < program_timer.Ticks()
			program_timer_ticks = program_timer.Ticks()
			patience = True
		EndIf
		
		Local new_offset:iso_coord = cursor.offset.copy()
		Local operation = -1
			
		'____________________________
		'DRAGGING VIEWPORT WITH MOUSE
		If MouseDown( 2 )
			ORIGIN_X :+ MouseX() - mouse.x
			ORIGIN_Y :+ MouseY() - mouse.y
		EndIf
		mouse.x = MouseX()
		mouse.y = MouseY()
		
		'__________________________
		'SAVING ENTIRE GRID TO FILE
		If KeyHit( Key_F2 )
			
			status.append( "saving iso_grid ..." )
			Local filename$ = fileman_grid_save_auto( grid )
			status.append( "iso_grid $gsaved $Dto [$B" + filename + "$D]" )
			
		'______________________________
		'LOADING CURSOR BRUSH FROM FILE
		ElseIf KeyHit( Key_F3 )
			
			status.append( "$prequesting filename" )
			Local filename$ = fileman_grid_load_system( cursor.brush_grid )
			If filename <> "ERROR"
				
				status.append( "loading $Biso_grid $Das $Bbrush $Dfrom [$B" + filename + "$D] ..." )
				cursor.mode = CURSOR_BRUSH
				cursor.brush_grid.reduce_to_contents()
				expand_grid_for_cursor()
				status.append( "cursor brush $gloaded successfully" )
				
			Else 'filename = "ERROR"
				status.append( "$rerror encountered! $ynothing loaded" )
			EndIf
			
		'_____________________________
		'LOADING ENTIRE GRID FROM FILE
		ElseIf KeyHit( Key_F4 )
			
			status.append( "$prequesting $Bfilename" )
			Local filename$ = fileman_grid_load_system( grid )
			If filename <> "ERROR"
				
				status.append( "loading $Biso_grid $Dfrom [$B" + filename + "$D] ..." )
				expand_grid_for_cursor()
				status.append( "iso_grid $gloaded successfully" )
				
			Else 'filename = "ERROR"
				status.append( "$rerror encountered! $ynothing loaded" )
			EndIf
			
		'__________________________________________________________
		'COPY SELECTION TO BRUSH (only while select tool is active)
		ElseIf KeyHit( Key_F5 ) And cursor.mode = CURSOR_SELECT
			
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
			
			Else 'Not intersect_list.isEmpty()
			
				status.append( "$bnothing to copy" )
				
			EndIf
		
		'TODO
		'fix the iso_face type so that this isn't so damn slow!
		
		Rem
		'_____________________
		'SELECTING ENTIRE GRID
		ElseIf KeyHit( Key_Y )
			
			cursor.mode = CURSOR_SELECT
			cursor.offset.set( 0, 0, 0 )
			cursor.select_ghost.resize( grid.size )
		EndRem
			
		EndIf
			
		If patience 
		
		'_________________
		'MOVING THE CURSOR
			If Not ..
			(KeyDown( Key_LShift ) Or KeyDown( Key_RShift ) Or ..
			KeyDown( Key_LControl ) Or KeyDown( Key_RControl ))
		
				If KeyDown( Key_A ) And new_offset.x > 0
					new_offset.x :- 1
				ElseIf KeyDown( Key_D )
					new_offset.x :+ 1
				EndIf
				
				If KeyDown( Key_W ) And new_offset.y > 0
					new_offset.y :- 1
				ElseIf KeyDown( Key_S )
					new_offset.y :+ 1
				EndIf
				
				If KeyDown( Key_E ) And new_offset.z > 0
					new_offset.z :- 1
				ElseIf KeyDown( Key_Q )
					new_offset.z :+ 1
				EndIf
				
				If Not new_offset.equal( cursor.offset )			
					cursor.offset = new_offset
					expand_grid_for_cursor()				
				EndIf
				
			EndIf
			
		'_________________________
		'INSERTING CURSOR CONTENTS
			If KeyDown( Key_Space )
				
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
				
			EndIf
				
		'TODO
		'finish the algorithm for rotation about an anchor so it can be used here!

		'________________________________________
		'ROTATING BASIC BLOCK OR ENTIRE SELECTION
			If KeyDown( Key_R )
				operation = ROTATE_Z_PLUS
			ElseIf KeyDown( Key_T )
				operation = ROTATE_Z_MINUS
			ElseIf KeyDown( Key_F )
				operation = ROTATE_Y_PLUS
			ElseIf KeyDown( Key_G )
				operation = ROTATE_Y_MINUS
			ElseIf KeyDown( Key_V )
				operation = ROTATE_X_PLUS
			ElseIf KeyDown( Key_B )
				operation = ROTATE_X_MINUS
			EndIf
			
			If operation <> -1
				
				Select cursor.mode
					
					Case CURSOR_BASIC
						cursor.basic_block.isotype = rotate( operation, cursor.basic_block.isotype )
						cursor.group_isotype[cursor.group] = cursor.basic_block.isotype
						
					Case CURSOR_BRUSH
						
						'stub
						
					Case CURSOR_SELECT
						
						'stub
					
				EndSelect
				
			EndIf	
			
		'_____________________________
		'RESIZING THE CURSOR SELECTION
			If cursor.mode = CURSOR_SELECT And (KeyDown( Key_LShift ) Or KeyDown( Key_RShift ))
				
				Local new_size:iso_coord = cursor.select_ghost.size.copy()
				
				If KeyDown( Key_A ) And new_size.x > 0
					new_size.x :- 1
				ElseIf KeyDown( Key_D )
					new_size.x :+ 1
				EndIf
				
				If KeyDown( Key_W ) And new_size.y > 0
					new_size.y :- 1
				ElseIf KeyDown( Key_S )
					new_size.y :+ 1
				EndIf
				
				If KeyDown( Key_E ) And new_size.z > 0
					new_size.z :- 1
				ElseIf KeyDown( Key_Q )
					new_size.z :+ 1
				EndIf
				
				If Not new_size.equal( cursor.select_ghost.size )
					cursor.select_ghost.resize( new_size )
					expand_grid_for_cursor()
				EndIf
		
			EndIf
			
		'_________________
		'RESIZING THE GRID
			If KeyDown( Key_LControl ) Or KeyDown( Key_RControl )
				
				Local new_size:iso_coord = grid.size.copy()
				
				If KeyDown( Key_A ) And new_size.x > 0
					new_size.x :- 1
				ElseIf KeyDown( Key_D )
					new_size.x :+ 1
				EndIf
				
				If KeyDown( Key_W ) And new_size.y > 0
					new_size.y :- 1
				ElseIf KeyDown( Key_S )
					new_size.y :+ 1
				EndIf
				
				If KeyDown( Key_E ) And new_size.z > 0
					new_size.z :- 1
				ElseIf KeyDown( Key_Q )
					new_size.z :+ 1
				EndIf
				
				If Not new_size.equal( grid.size )
					grid.resize( new_size )
					expand_grid_for_cursor()
				EndIf
		
			EndIf
		
		EndIf
		
		'________________________
		'CHANGING THE CURSOR MODE
		If KeyHit( Key_Z )
			cursor.mode = CURSOR_BASIC
			expand_grid_for_cursor()
		ElseIf KeyHit( Key_X )
			If cursor.brush_grid.empty()
				status.append( "$ywarning; cannot use brush tool $D(must load a brush first)" )
			Else	
				cursor.mode = CURSOR_BRUSH
				expand_grid_for_cursor()
			EndIf
		ElseIf KeyHit( Key_C )
			cursor.mode = CURSOR_SELECT
			expand_grid_for_cursor()
		EndIf
		
		'TODO
		'find a good system for modifying the RGBA values for the basic block.
		
		Rem
		'__________________________________________
		'CHANGING CURSOR BASIC BLOCK R,G,B,A VALUES
		If KeyDown( Key_7 ) Or KeyDown( Key_8 ) Or KeyDown( Key_9 ) Or KeyDown( Key_0 ) And cursor.mode = CURSOR_BASIC
			
			If KeyHit( Key_Equals )
				
				If KeyDown( Key_7 ) And cursor.basic_block.red   < 255   Then cursor.basic_block.red   :+ 20
				If KeyDown( Key_8 ) And cursor.basic_block.green < 255   Then cursor.basic_block.green :+ 20
				If KeyDown( Key_9 ) And cursor.basic_block.blue  < 255   Then cursor.basic_block.blue  :+ 20
				If KeyDown( Key_0 ) And cursor.basic_block.alpha < 1.000 Then cursor.basic_block.alpha :+ 0.100
				
			ElseIf KeyHit( Key_Minus )
				
				If KeyDown( Key_7 ) And cursor.basic_block.red   >  35     Then cursor.basic_block.red   :- 20
				If KeyDown( Key_8 ) And cursor.basic_block.green >  35     Then cursor.basic_block.green :- 20
				If KeyDown( Key_9 ) And cursor.basic_block.blue  >  35     Then cursor.basic_block.blue  :- 20
				If KeyDown( Key_0 ) And cursor.basic_block.alpha >  0.1000 Then cursor.basic_block.alpha :- 0.100
				
			EndIf
		EndIf
		EndRem	
		
		'_________________
		'TOGGLING SWITCHES
		If KeyHit( Key_1 )
			If Not SHOW_SHADOWS
				SHOW_SHADOWS = True
				status.append( "$Bshadows $Dlayer $genabled" )
			Else
				SHOW_SHADOWS = False
				status.append( "$Bshadows $Dlayer $ydisabled" )
			EndIf
		EndIf
		If KeyHit( Key_2 )
			If Not SHOW_GRIDLINES
				SHOW_GRIDLINES = True
				status.append( "$Bgrid $Dlayer $genabled" )
			Else
				SHOW_GRIDLINES = False
				status.append( "$Bgrid $Dlayer $ydisabled" )
			EndIf
		EndIf
		If KeyHit( Key_3 )
			If Not SHOW_BLOCKS
				SHOW_BLOCKS = True
				status.append( "$Bblocks $Dlayer $genabled" )
			Else
				SHOW_BLOCKS = False
				status.append( "$Bblocks $Dlayer $ydisabled" )
			EndIf
		EndIf
		If KeyHit( Key_4 )
			If Not SHOW_CURSOR
				SHOW_CURSOR = True
				status.append( "$Bcursor $Dlayer $genabled" )
			Else
				SHOW_CURSOR = False
				status.append( "$Bcursor $Dlayer $ydisabled" )
			EndIf
		EndIf
		If KeyHit( Key_5 )
			If OUTLINE_WIDTH < 3
				OUTLINE_WIDTH :+ 1
				status.append( "$Boutline $Dlayer set to $g"+OUTLINE_WIDTH+" $Dpixels" )
			Else
				OUTLINE_WIDTH = 0
				status.append( "$Boutline $Dlayer $ydisabled" )
			EndIf
		EndIf
		If KeyHit( Key_6 )
			If Not SHOW_STATUS_MESSAGES
				SHOW_STATUS_MESSAGES = True
				status.append( "$Bstatus message $Dlayer $genabled" )
			Else
				SHOW_STATUS_MESSAGES = False
				status.append( "$Bstatus message $Dlayer $ydisabled" )
			EndIf
		EndIf
		If KeyHit( Key_7 )
			SHOW_SHADOWS = True
			SHOW_GRIDLINES = True
			SHOW_BLOCKS = True
			SHOW_CURSOR = True
			OUTLINE_WIDTH = 1
			SHOW_STATUS_MESSAGES = True
			SHOW_HELP = False
			status.append( "$Ball layers $Dnormal" )
		EndIf
		
		'______________________________
		'CYCLE CURSOR BASIC BLOCK GROUP
		If KeyHit( Key_Tab )
			cursor.group :+ 1
			If cursor.group >= COUNT_GROUPS Then cursor.group = 0
			cursor.basic_block.isotype = cursor.group_isotype[cursor.group]
		EndIf
		
		'________________________
		'DELETING CURSOR CONTENTS
		If KeyHit( Key_Tilde )
		
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
			
		EndIf
		
	EndMethod
	
'_________________________________________________________________________
	Method expand_grid_for_cursor()

		Local new_size:iso_coord = grid.size.copy()
		
		Select cursor.mode
			
			Case CURSOR_BASIC
				If cursor.offset.x >= grid.size.x
					new_size.x :+ 1 + cursor.offset.x - grid.size.x
				EndIf
				If cursor.offset.y >= grid.size.y
					new_size.y :+ 1 + cursor.offset.y - grid.size.y
				EndIf
				If cursor.offset.z >= grid.size.z
					new_size.z :+ 1 + cursor.offset.z - grid.size.z
				EndIf
				
			Case CURSOR_BRUSH
				If cursor.offset.x + cursor.brush_grid.size.x > grid.size.x
					new_size.x :+ cursor.offset.x + cursor.brush_grid.size.x - grid.size.x
				EndIf
				If cursor.offset.y + cursor.brush_grid.size.y > grid.size.y
					new_size.y :+ cursor.offset.y + cursor.brush_grid.size.y - grid.size.y
				EndIf
				If cursor.offset.z + cursor.brush_grid.size.z > grid.size.z
					new_size.z :+ cursor.offset.z + cursor.brush_grid.size.z - grid.size.z
				EndIf
				
			Case CURSOR_SELECT
				If cursor.offset.x + cursor.select_ghost.size.x > grid.size.x
					new_size.x :+ cursor.offset.x + cursor.select_ghost.size.x - grid.size.x
				EndIf
				If cursor.offset.y + cursor.select_ghost.size.y > grid.size.y
					new_size.y :+ cursor.offset.y + cursor.select_ghost.size.y - grid.size.y
				EndIf
				If cursor.offset.z + cursor.select_ghost.size.z > grid.size.z
					new_size.z :+ cursor.offset.z + cursor.select_ghost.size.z - grid.size.z
				EndIf
				
		EndSelect
		
		If Not new_size.equal( grid.size )
			grid.resize( new_size )
			Return True
		Else
			Return False
		EndIf
		
	EndMethod

EndType

