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
- map 2D screen coordinates to 3D rays originating at the "camera" (which is infinitely far away,
  but since the screen is orthoganal, no distortion is present) by narrowing down each coordinate
  individually (i.e., find the set of possible X & Y by dividing up the screen into columns, each
  as wide as a single sprite, and then taking what's left and narrowing further using the other axes).
- when adding or deleting blocks or bunches of blocks at once, play one sound and
  only on confirmed success of the entire operation, using a return code from iso_grid methods
- allow the "hold down & place constantly" operation again
- create a method using the mouse that a rectangular area can be defined, as a copy of a single block,
  and then created all at once (simcity style, in other words)
- cache the background line grid and only redraw on resize
- cleanup the keyboard_input function. it is currently creating status messages
  and executing commands, but it should only be calling commands in the command
  module based on keyboard input. status messages should be reserved for the command module.
- fix the boundary checks so that when blocks are moved past a boundary, the isogrid is resized accordingly
- fix the iso_face class so selecting the entire grid isn't so slow!
- redesign the system for modifying the RGBA values for the basic block.
EndRem

Strict

Import "globals.bmx"
Import "fileman.bmx"
Import "coord.bmx"
Import "iso_block.bmx"
Import "iso_grid.bmx"
Import "iso_cursor.bmx"
'Import "rotate.bmx"       'this source file has been split up and distributed to globals, iso_block and iso_grid
Import "draw.bmx"
Import "command.bmx"
Import "message_nanny.bmx"

Type controller
	
	Field seconds:TTimer       'timer
	Field last_tick            'last count of ticks
	Field intro_messages$[]    'splash messages
	Field mouse:scr_coord      'last recorded mouse coordinates
	
	Field canvas:iso_grid      'root-level isometric grid
	Field cursor:iso_cursor    'root-level isometric cursor
	Field status:message_nanny 'status message handler
	
	Field SHOW_SHADOWS         'drawing layer flag
	Field SHOW_GRIDLINES       'drawing layer flag
	Field SHOW_BLOCKS          'drawing layer flag
	Field SHOW_CURSOR          'drawing layer flag
	'Field SHOW_OUTLINES        'drawing layer flag
	Field SHOW_STATUS_MESSAGES 'drawing layer flag
	Field SHOW_HELP            'drawing layer flag

	Field REDRAW_BG            'background validity indicator
	Field bg_cache:TImage      'background image cached texture
	
	Field hover_block_offset:iso_coord
	Field HOVER_FLAG
	

	'_________________________________________________________________________
	Method New()
		
		seconds = CreateTimer( 1 )
		last_tick = -1
		
		intro_messages = [ ..
			"welcome to $Bisoblox$D!", ..
			"programming and art by $BTyler W.R. Cole", ..
			"first time? $bpress F1 for help", ..
			"edit app $cconfiguration $Dwith [$Bisoblox.cfg$D]" ]
		
		mouse = scr_coord.Create( MouseX(), MouseY() )
		canvas = iso_grid.Create( iso_coord.Create( GRID_X, GRID_Y, GRID_Z ))
		
		cursor = New iso_cursor
		cursor.block.offset = iso_coord.Create( canvas.size.x / 2, canvas.size.y / 2, 0 )
		cursor.size = iso_coord.Create( 1, 1, 1 )
		
		status = New message_nanny
		
		SHOW_SHADOWS         = True
		SHOW_GRIDLINES       = True
		SHOW_BLOCKS          = True
		SHOW_CURSOR          = True
		'SHOW_OUTLINES        = 1
		SHOW_STATUS_MESSAGES = True
		SHOW_HELP            = False
		
		REDRAW_BG = True
		HOVER_FLAG = False
		
	EndMethod
	
	'_________________________________________________________________________
	Method load_assets()
		
		status.append( "loading assets .." )
		fileman_load_art()
		fileman_load_sound()
		initialize_rotation_map()
		
		status.append( "$gloaded" )
		
	EndMethod
	
	'_________________________________________________________________________
	Method chug()
		
		'rename get_input() to update()
		get_input()
		draw()
		
		'move to get_input()/update()
		If seconds.Ticks() < intro_messages.length And last_tick < seconds.Ticks()
			last_tick = seconds.Ticks()
			status.append( intro_messages[ last_tick ])
		EndIf
		
		'move to get_input()/update()
		If KeyHit( Key_F12 )
			status.append( "capturing screenshot ..." )
			Local filename$ = fileman_screenshot_auto()
			status.append( "screenshot $gsaved $Dto [$B" + filename + "$D]" )
		EndIf
				
	EndMethod
	
	'_________________________________________________________________________
	Method draw()

		SetOrigin( ORIGIN_X, ORIGIN_Y )
		
		'This chunk has been disabled while I figure out what I'm going to do about selecting and its blink-pattern
		Rem
		Local t = cursor_blink_timer.Ticks()
		For Local phase_index = 0 To 5
			COLOR_CYCLE[phase_index] = Sin( x - ( phase_index * ( 2 * ( Pi / 6 ))))
		Next
		EndRem
		
		'Draw shadows
		If SHOW_SHADOWS And SHOW_BLOCKS
			draw_block_shadows( canvas )
			If SHOW_CURSOR
				draw_cursor_shadows( cursor )
			EndIf
		EndIf
		
		'Draw background gridlines
		If SHOW_GRIDLINES
			If Not REDRAW_BG
				SetColor( 255, 255, 255 )
				SetAlpha( 1.000 )
				DrawImage( bg_cache, 0, 0 )
			Else
				draw_bg( canvas )
				bg_cache = LoadImage( GrabPixmap( 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT ))
				SetImageHandle( bg_cache, SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2 )
				REDRAW_BG = False
			EndIf
		EndIf
		
		'This chunk has been disabled, probably permanently
		'Draw block outlines
		Rem
		If SHOW_OUTLINES
			draw_outlines( canvas, cursor )
		EndIf
		EndRem
		
		'Draw blocks
		If SHOW_BLOCKS
			If Not SHOW_CURSOR
				draw_blocks( canvas )
			Else 'SHOW_CURSOR
				If Not canvas.is_empty()
					draw_blocks_with_cursor( canvas, cursor )
				Else 'canvas.is_empty()
					draw_cursor( cursor )
				EndIf
				draw_cursor_wireframe( cursor )
			EndIf
			'Draw the special "mouse hover cursor"
			If HOVER_FLAG
				draw_hover_block( canvas, hover_block_offset )
			EndIf
		EndIf
		
		'Draw status console messages
		If SHOW_STATUS_MESSAGES
			status.draw()
		EndIf
		
		'Draw help screen
		If SHOW_HELP
			draw_help()
		EndIf
		
	EndMethod
	
	'rename to update()
	'_________________________________________________________________________
	Method get_input()
		
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
		
		'________________________________
		'HOVERING WITH MOUSE OVER A BLOCK
		hover_block_offset = scr_to_iso_HACK( mouse, canvas.renderlist )
		HOVER_FLAG = hover_block_offset.is_valid()
		
		'__________________________
		'SAVING ENTIRE GRID TO FILE
		If KeyHit( Key_F2 )
			command_grid_save( status, canvas )

		'______________________________
		'LOADING CURSOR BRUSH FROM FILE
		ElseIf KeyHit( Key_F3 )
			command_brush_load( status, canvas, cursor )
			
		'_____________________________
		'LOADING ENTIRE GRID FROM FILE
		ElseIf KeyHit( Key_F4 )
			command_grid_load( status, canvas, cursor )
			
		'_______________________
		'COPY SELECTION TO BRUSH (only while select tool is active)
		ElseIf KeyHit( Key_F5 ) And cursor.mode = CURSOR_SELECT
			command_copy( status, canvas, cursor )
		
		Rem
		'_____________________
		'SELECTING ENTIRE GRID
		ElseIf KeyHit( Key_F8 )
			command_select_all( status, canvas, cursor )			
		EndRem
		
		EndIf
		
		'______________________________
		'CYCLE CURSOR BASIC BLOCK GROUP
		If KeyHit( Key_Tab )
			cursor.group :+ 1
			If cursor.group >= COUNT_GROUPS Then cursor.group = 0
			cursor.block.isotype = cursor.group_isotype[cursor.group]
		EndIf
		
		'_________________________
		'INSERTING CURSOR CONTENTS
		If KeyHit( Key_Space )
			command_insert( status, canvas, cursor )
		EndIf
			
		'________________________
		'DELETING CURSOR CONTENTS
		If KeyHit( Key_Tilde )
			command_delete( canvas, cursor )
		EndIf
		
		If patience 
		
		'_________________
		'MOVING THE CURSOR
			If Not ..
				(KeyDown( Key_LShift ) Or KeyDown( Key_RShift ) Or KeyDown( Key_LControl ) Or KeyDown( Key_RControl )) ..
				And ..
				(KeyDown( Key_A ) Or KeyDown( Key_D ) Or KeyDown( Key_W ) Or KeyDown( Key_S ) Or KeyDown( Key_E ) Or KeyDown( Key_Q ))
				command_move_cursor( status, canvas, cursor, 	iso_coord.Create( ..
					-KeyDown( Key_A )+KeyDown( Key_D ), ..
					-KeyDown( Key_W )+KeyDown( Key_S ), ..
					-KeyDown( Key_E )+KeyDown( Key_Q )))
			EndIf
			
		'____________________
		'ROTATING BASIC BLOCK
			If KeyDown( Key_F ) Or KeyDown( Key_G ) Or KeyDown( Key_H ) And cursor.mode = CURSOR_BASIC
				
				Local operation
				
				If KeyDown( Key_LControl ) Or KeyDown( Key_RControl )
				
					If KeyDown( Key_F )
						operation = ROTATE_X_PLUS
					ElseIf KeyDown( Key_G )
						operation = ROTATE_Y_PLUS
					ElseIf KeyDown( Key_H )
						operation = ROTATE_Z_PLUS
					EndIf
						
				Else 'not keydown( ctrl )
				
					If KeyDown( Key_F )
						operation = ROTATE_X_MINUS
					ElseIf KeyDown( Key_G )
						operation = ROTATE_Y_MINUS
					ElseIf KeyDown( Key_H )
						operation = ROTATE_Z_MINUS
					EndIf
						
				EndIf
				
				cursor.block.rotate( operation )
				cursor.group_isotype[cursor.group] = cursor.block.isotype
				
			EndIf
			
		'__________________________________________
		'CHANGING CURSOR BASIC BLOCK R,G,B,A VALUES
			If KeyDown( Key_R ) Or KeyDown( Key_T ) Or KeyDown( Key_Y ) Or KeyDown( Key_U ) And cursor.mode = CURSOR_BASIC
				
				If KeyDown( Key_LControl ) Or KeyDown( Key_RControl )
					
					If KeyDown( Key_R ) And cursor.block.red   < 255   Then cursor.block.red   :+ 5
					If KeyDown( Key_T ) And cursor.block.green < 255   Then cursor.block.green :+ 5
					If KeyDown( Key_Y ) And cursor.block.blue  < 255   Then cursor.block.blue  :+ 5
					'If KeyDown( Key_U ) And cursor.block.alpha < 1.000 Then cursor.block.alpha :+ 0.050
					
				Else 'KeyDown( L/RControl )
					
					If KeyDown( Key_R ) And cursor.block.red   >  5     Then cursor.block.red   :- 5
					If KeyDown( Key_T ) And cursor.block.green >  5     Then cursor.block.green :- 5
					If KeyDown( Key_Y ) And cursor.block.blue  >  5     Then cursor.block.blue  :- 5
					'If KeyDown( Key_U ) And cursor.block.alpha >  0.050 Then cursor.block.alpha :- 0.050
					
				EndIf
			EndIf
		
		'_____________________________
		'RESIZING THE CURSOR SELECTION
			If cursor.mode = CURSOR_SELECT And (KeyDown( Key_LShift ) Or KeyDown( Key_RShift ))
				
				Local delta:iso_coord = New iso_coord
				If KeyDown( Key_A ) Then delta.x :- 1
				If KeyDown( Key_D ) Then delta.x :+ 1
				If KeyDown( Key_W ) Then delta.y :- 1
				If KeyDown( Key_S ) Then delta.y :+ 1
				If KeyDown( Key_Q ) Then delta.z :- 1
				If KeyDown( Key_E ) Then delta.z :+ 1
				cursor.change_size( delta )
		
			EndIf
			
			'Resizing incrementally of the main grid has been disabled due to massive cost of the operation
			Rem
		'_________________
		'RESIZING THE GRID
			If KeyDown( Key_LControl ) Or KeyDown( Key_RControl )
				
				Local new_size:iso_coord = canvas.size.copy()
				
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
				
				If Not new_size.equal( canvas.size )
					canvas.resize( new_size )
					command_expand_grid_for_cursor( canvas, cursor )
					REDRAW_BG = True
				EndIf
		
			EndIf
			EndRem
					
		EndIf
		
		'________________________
		'CHANGING THE CURSOR MODE
		If KeyHit( Key_Z )
			cursor.mode = CURSOR_BASIC
			'command_expand_grid_for_cursor( canvas, cursor )
		ElseIf KeyHit( Key_X )
			If cursor.brush.is_empty()
				status.append( "$ywarning; cannot use brush tool $D(must load a brush first)" )
			Else	
				cursor.mode = CURSOR_BRUSH
				'command_expand_grid_for_cursor( canvas, cursor )
			EndIf
		ElseIf KeyHit( Key_C )
			cursor.mode = CURSOR_SELECT
			'command_expand_grid_for_cursor( canvas, cursor )
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
		'This layer has been disabled, probably permanently
		Rem
		If KeyHit( Key_5 )
			If Not SHOW_OUTLINES
				SHOW_OUTLINES = True
				status.append( "$Boutline $Dlayer $genabled" )
			Else
				SHOW_OUTLINES = False
				status.append( "$Boutline $Dlayer $ydisabled" )
			EndIf
		EndIf
		EndRem
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
			'SHOW_OUTLINES = 1
			SHOW_STATUS_MESSAGES = True
			status.append( "$Ball layers $Dnormal" )
		EndIf
			
	EndMethod

	'_________________________________________________________________________
	Function draw_help()
		
		SetOrigin( 0, 0 )
		SetColor( 255, 255, 255 )
		SetAlpha( 0.750 )
		DrawRect( 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT )
		
		Local scr:scr_coord = scr_coord.Create( 1, 1 )
		
		draw_big_msg( ..
			"$Bisoblox $bhelp~n"+..
			"~n"+..
			"show/hide this text   $BF1~n"+..
			"$Bbasic $Dblock tool      $BZ~n"+..
			"$Bbrush $Dtool            $BX~n"+..
			"$Bselection $Dtool        $BC~n"+..
			"$bmove $Dcursor           $BW$D,$BA$D,$BS$D,$BD$D,$BQ$D,$BE~n"+..
			"$pinsert $Dblock(s)       $Bspacebar~n"+..
			"$ccycle $Dbasic blocks    $Btab~n"+..
			"$yrotate $Dblock(s)       $BF$D,$BG$D,$BH $D($b+ $Bctrl$D)~n"+..
			"change $Bselection size$D $Bshift $b+ $BW$D,$BA$D,$BS$D,$BD$D,$BQ$D,$BE~n"+..
			"change $Bgrid size$D      $Bctrl $b+ $BW$D,$BA$D,$BS$D,$BD$D,$BQ$D,$BE~n"+..
			"select $Ball$D            F8 (disabled)~n"+..
			"$gcopy $Dselection        $BF5~n"+..
			"change basic $rR$gG$bB$BA$D     $rR$D,$gT$D,$bY,$BU $D($b+ $Bctrl$D)~n"+..
			"$rdelete $Dselected       $Btilde~n"+..
			"$bsave grid $Dto file     $BF2~n"+..
			"$gload brush $Dfrom file  $BF3~n"+..
			"$gload grid $Dfrom file   $BF4~n"+..
			"layers $gon$D/$yoff         $B1$D,$B2$D,$B3$D,$B4$D,$B5$D,$B6$D,$B7~n"+..
			"take $bscreenshot$D       $BF12~n"+..
			"drag $Bviewport$D         $Bmouse_2~n"+..
			"", scr )
		
	EndFunction

EndType

