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
Import "command.bmx"
Import "message_nanny.bmx"

Type controller
	
	Field seconds:TTimer       'timer
	Field last_tick            'last count of ticks
	Field intro_messages$[]    'splash messages
	Field mouse:scr_coord      'last recorded mouse coordinates
	
	Field grid:iso_grid        'root-level isometric grid
	Field cursor:iso_cursor    'root-level isometric cursor
	Field status:message_nanny 'status message handler
	
	Field SHOW_SHADOWS         'drawing layer flag
	Field SHOW_GRIDLINES       'drawing layer flag
	Field SHOW_BLOCKS          'drawing layer flag
	Field SHOW_CURSOR          'drawing layer flag
	Field OUTLINE_WIDTH        'drawing layer flag
	Field SHOW_STATUS_MESSAGES 'drawing layer flag
	Field SHOW_HELP            'drawing layer flag

'_________________________________________________________________________
	Method New()
		
		seconds = CreateTimer( 1 )
		last_tick = -1
		intro_messages = [ ..
			"welcome to $Bisoblox$D!", ..
			"programming and art by $BTyler W.R. Cole", ..
			"first time? $bpress F1 for help", ..
			"edit app $cconfiguration $Dwith [$Bisoblox.cfg$D]" ]
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
		
		If seconds.Ticks() < intro_messages.length And last_tick < seconds.Ticks()
			last_tick = seconds.Ticks()
			status.append( intro_messages[ last_tick ])
		EndIf
		
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
			draw_outlines( grid, cursor )
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
			"show/hide this text   $BF1~n"+..
			"exit app              $Besc~n"+..
			"$Bbasic $Dblock tool      $BZ~n"+..
			"$Bbrush $Dtool            $BX~n"+..
			"$Bselection $Dtool        $BC~n"+..
			"$bmove $Dcursor           $BW$D,$BA$D,$BS$D,$BD$D,$BQ$D,$BE~n"+..
			"$pinsert $Dblock(s)       $Bspacebar~n"+..
			"$ccycle $Dbasic blocks    $Btab~n"+..
			"$yrotate $Dblock(s)       $BR$D,$BF$D,$BV $D($b+ $Bctrl$D)~n"+..
			"change $Bselection size$D $Bshift $b+ $BW$D,$BA$D,$BS$D,$BD$D,$BQ$D,$BE~n"+..
			"change $Bgrid size$D      $Bctrl $b+ $BW$D,$BA$D,$BS$D,$BD$D,$BQ$D,$BE~n"+..
			"select $Ball$D            F8 (disabled)~n"+..
			"$gcopy $Dselection        $BF5~n"+..
			"change basic $rR$gG$bB$BA$D     $rT$D,$gY$D,$bU,$BI $D($b+ $Bctrl$D)~n"+..
			"$rdelete $Dselected       $Btilde~n"+..
			"$bsave grid $Dto file     $BF2~n"+..
			"$gload brush $Dfrom file  $BF3~n"+..
			"$gload grid $Dfrom file   $BF4~n"+..
			"layers $gon$D/$yoff         $B1$D,$B2$D,$B3$D,$B4$D,$B5$D,$B6$D,$B7~n"+..
			"take $bscreenshot$D       $BF12~n"+..
			"drag $Bviewport$D         $Bmouse_2~n"+..
			"", scr )
		
	EndFunction

'_________________________________________________________________________
	Method load_assets()
		
		status.append( "loading assets .." )
		fileman_load_art()
		fileman_load_sound()
		rotate_init()
		
		status.append( "$gloaded" )
		
	EndMethod
	
'_________________________________________________________________________
	Method keyboard_input()
		
		If KeyDown( Key_Escape ) Then End
		
		Local patience = False
		If program_timer_ticks < program_timer.Ticks()
			program_timer_ticks = program_timer.Ticks()
			patience = True
		EndIf
		
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
			command_grid_save( status, grid )

		'______________________________
		'LOADING CURSOR BRUSH FROM FILE
		ElseIf KeyHit( Key_F3 )
			command_brush_load( status, grid, cursor )
			
		'_____________________________
		'LOADING ENTIRE GRID FROM FILE
		ElseIf KeyHit( Key_F4 )
			command_grid_load( status, grid, cursor )
			
		'_______________________
		'COPY SELECTION TO BRUSH (only while select tool is active)
		ElseIf KeyHit( Key_F5 ) And cursor.mode = CURSOR_SELECT
			command_copy( status, grid, cursor )
		
		'TODO
		'fix the iso_face class so this isn't so slow!		
		Rem
		'_____________________
		'SELECTING ENTIRE GRID
		ElseIf KeyHit( Key_F8 )
			command_select_all( status, grid, cursor )			
		EndRem
			
		EndIf
			
		If patience 
		
		'_________________
		'MOVING THE CURSOR
			If Not ..
			(KeyDown( Key_LShift ) Or KeyDown( Key_RShift ) Or ..
			KeyDown( Key_LControl ) Or KeyDown( Key_RControl ))
				command_move_cursor( status, grid, cursor, ..
					iso_coord.create( ..
						-KeyDown( Key_A )+KeyDown( Key_D ), ..
						-KeyDown( Key_W )+KeyDown( Key_S ), ..
						-KeyDown( Key_E )+KeyDown( Key_Q )))
			EndIf
			
		'_________________________
		'INSERTING CURSOR CONTENTS
			If KeyDown( Key_Space )
				command_insert( status, grid, cursor )
			EndIf
				
		'TODO
		'finish the algorithm for rotation about an anchor so it can be used here!

		'________________________________________
		'ROTATING BASIC BLOCK OR ENTIRE SELECTION
			Local operation = -1
			
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
			
		'TODO
		'find a good system for modifying the RGBA values for the basic block.
		
		'__________________________________________
		'CHANGING CURSOR BASIC BLOCK R,G,B,A VALUES
			If KeyDown( Key_T ) Or KeyDown( Key_Y ) Or KeyDown( Key_U ) Or KeyDown( Key_I ) And cursor.mode = CURSOR_BASIC
				
				If KeyDown( Key_LControl ) Or KeyDown( Key_RControl )
					
					If KeyDown( Key_T ) And cursor.basic_block.red   < 255   Then cursor.basic_block.red   :+ 5
					If KeyDown( Key_Y ) And cursor.basic_block.green < 255   Then cursor.basic_block.green :+ 5
					If KeyDown( Key_U ) And cursor.basic_block.blue  < 255   Then cursor.basic_block.blue  :+ 5
					If KeyDown( Key_I ) And cursor.basic_block.alpha < 1.000 Then cursor.basic_block.alpha :+ 0.050
					
				Else 'KeyDown( L/RControl )
					
					If KeyDown( Key_T ) And cursor.basic_block.red   >  5     Then cursor.basic_block.red   :- 5
					If KeyDown( Key_Y ) And cursor.basic_block.green >  5     Then cursor.basic_block.green :- 5
					If KeyDown( Key_U ) And cursor.basic_block.blue  >  5     Then cursor.basic_block.blue  :- 5
					If KeyDown( Key_I ) And cursor.basic_block.alpha >  0.050 Then cursor.basic_block.alpha :- 0.050
					
				EndIf
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
					expand_grid_for_cursor( grid, cursor )
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
					expand_grid_for_cursor( grid, cursor )
				EndIf
		
			EndIf
		
		'________________________
		'DELETING CURSOR CONTENTS
			If KeyDown( Key_Tilde )
			
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
			
		EndIf
		
		'________________________
		'CHANGING THE CURSOR MODE
		If KeyHit( Key_Z )
			cursor.mode = CURSOR_BASIC
			expand_grid_for_cursor( grid, cursor )
		ElseIf KeyHit( Key_X )
			If cursor.brush_grid.empty()
				status.append( "$ywarning; cannot use brush tool $D(must load a brush first)" )
			Else	
				cursor.mode = CURSOR_BRUSH
				expand_grid_for_cursor( grid, cursor )
			EndIf
		ElseIf KeyHit( Key_C )
			cursor.mode = CURSOR_SELECT
			expand_grid_for_cursor( grid, cursor )
		EndIf
		
		'_________________
		'TOGGLING SWITCHES
		If KeyHit( Key_F1 )
			SHOW_HELP = Not SHOW_HELP
		EndIf
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
			status.append( "$Ball layers $Dnormal" )
		EndIf
		
		'______________________________
		'CYCLE CURSOR BASIC BLOCK GROUP
		If KeyHit( Key_Tab )
			cursor.group :+ 1
			If cursor.group >= COUNT_GROUPS Then cursor.group = 0
			cursor.basic_block.isotype = cursor.group_isotype[cursor.group]
		EndIf
		
	EndMethod
	
EndType

