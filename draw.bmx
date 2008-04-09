Rem
_______________________________
Project isoblox
This is a BlitzMax source file
Author is Tyler W.R. Cole
Started on September 30th, 2006

 isometric axes layout (x,y,z)

   Z     screen axes layout (x,y)
   |     
   o       o__X
  / \      |  
 Y   X     Y
_______________________________
EndRem

Rem
TODO
- optimize draw_blocks_with_cursor; use TLink instead of the enumerators
- eliminate the outlines layer; I will use that sprite set for mouse-hovering
- finish/fix the CURSOR_SELECT Case for draw functions:
  draw_cursor_shadows, draw_cursor, draw_blocks_with_cursor
EndRem

Strict

Import "globals.bmx"
Import "coord.bmx"
Import "iso_block.bmx"
Import "iso_grid.bmx"
Import "iso_cursor.bmx"

'Draw Block________________________________________________________________________________________
Function draw_block( source:iso_block, position:scr_coord, sprite_library% )
	Select sprite_library
		Case LIB_BLOCKS
			SetColor( source.red, source.green, source.blue )
		Case LIB_WIREFRAMES
			SetColor( 0, 0, 0 )
		Case LIB_OUTLINES
			SetColor( 0, 0, 0 )
		Case LIB_SHADOWS_XY
			SetColor( 200, 200, 200 )
		Case LIB_SHADOWS_YZ
			SetColor( 200, 200, 200 )
		Case LIB_SHADOWS_XZ
			SetColor( 200, 200, 200 )
	EndSelect
	DrawImage( spritelib_blocks[ sprite_library, source.isotype ], position.x, position.y )
EndFunction

'Draw Hover Block__________________________________________________________________________________
Function draw_hover_block( grid:iso_grid, offset:iso_coord )
	Local position:scr_coord = iso_to_scr( offset )
	draw_block( grid.get_space( offset ), position, LIB_OUTLINES )
	draw_block( grid.get_space( offset ), position, LIB_BLOCKS )
EndFunction

'Draw BG___________________________________________________________________________________________
Function draw_bg( grid:iso_grid )
	Local bold_freq = 10 'sets frequency of major grid lines
	Local x = grid.size.x, y = grid.size.y, z = grid.size.z
	Local w = GRID_SPACING_X, h = GRID_SPACING_Y
	draw_lines( 0,0, x*w,x*h, -w,h, y+1, True  )     'x axis moves along y
	draw_lines( 0,0, x*w,x*h, 0,-2*h, z+1, False )  'x axis moves along z
	draw_lines( 0,0, -y*w,y*h, w,h, x+1, True )     'y axis moves along x
	draw_lines( 0,0, -y*w,y*h, 0,-2*h, z+1, False ) 'y axis moves along z
	draw_lines( 0,0, 0,-2*z*h, w,h, x+1, True )     'z axis moves along x
	draw_lines( 0,0, 0,-2*z*h, -w,h, y+1, False )   'z axis moves along y
EndFunction

'Draw Lines________________________________________________________________________________________
Function draw_lines( x1,y1, x2,y2, dx,dy, count, bold_0 = False )
	SetColor( 0, 0, 0 )
	For Local iter = 0 To count - 1
		If (iter = 0 And bold_0) ..
		Or (iter <> 0 And iter Mod BOLD_LINE_FREQUENCY = 0 ) ..
		Or (iter = count - 1)
			'Bold line
			SetLineWidth( 2 )
			SetAlpha( 0.060 )
		Else
			'Normal line
			SetLineWidth( 1 )
			SetAlpha( 0.050 )
		EndIf
		DrawLine( x1,y1, x2,y2 )
		x1 :+ dx; y1 :+ dy
		x2 :+ dx; y2 :+ dy
	Next
EndFunction

'Draw Blocks With Cursor___________________________________________________________________________
Function draw_blocks_with_cursor( grid:iso_grid, cursor:iso_cursor )
	
	Local main_cursor:TLink
	Local main_block:iso_block
	Local brush_cursor:TLink
	Local brush_block:iso_block
	Local comparison%
	
	Select cursor.mode
		
		'__________________________________________________________
		Case CURSOR_BASIC
			
			'trivial, empty grid case
			If grid.is_empty()
				'draw the cursor block and then return
				draw_block( cursor.block, iso_to_scr( cursor.block.offset ), LIB_BLOCKS )
				Return
			EndIf
			
			'draw blocks BEHIND the cursor
			main_cursor = grid.renderlist.FirstLink()
			While main_cursor <> Null
				main_block = iso_block( main_cursor.Value() )
				comparison = main_block.compare( cursor.block )
				If comparison < 0
					draw_block( main_block, iso_to_scr( main_block.offset ), LIB_BLOCKS )
				Else 'comparison >= 0
					Exit 'done with the loop
				EndIf
				main_cursor = main_cursor.NextLink()
			EndWhile
			'draw the cursor
			draw_block( cursor.block, iso_to_scr( cursor.block.offset ), LIB_BLOCKS )
			'draw blocks IN FRONT OF the cursor
			While main_cursor <> Null
				main_block = iso_block( main_cursor.Value() )
				comparison = main_block.compare( cursor.block )
				If comparison > 0
					draw_block( main_block, iso_to_scr( main_block.offset ), LIB_BLOCKS )
				Else 'comparison <= 0
					Exit 'done with the loop, and this function
				EndIf
				main_cursor = main_cursor.NextLink()
			EndWhile
			'done
			Return
					
		'__________________________________________________________
		Case CURSOR_BRUSH
			If cursor.brush <> Null Then brush_cursor = cursor.brush.renderlist.FirstLink()
			
			
			
		'__________________________________________________________
		Case CURSOR_SELECT
			
			
	EndSelect
	
	'This code needs a refresh, so I'm just dumping it and starting over
	Rem
	Local g_enum:TListEnum
	Local g_block:iso_block
	
	Local c_enum:TListEnum
	Local c_block:iso_block
	'Local c_face:iso_face
	
	Local scr:scr_coord
	Local drawn_basic_block
	
	'SetAlpha( 1.000 )
	
	Select cursor.mode
	
		Case CURSOR_BASIC
			
			g_enum = grid.renderlist.ObjectEnumerator()
			g_block = iso_block( g_enum.NextObject() )
			c_block = cursor.block
			drawn_basic_block = False
			
			While g_block <> Null Or Not drawn_basic_block
				
				If Not drawn_basic_block And c_block.compare( g_block ) < 0
					
					SetColor( c_block.red, c_block.green, c_block.blue )
					SetAlpha( COLOR_CYCLE[0] )
					scr = iso_to_scr( c_block.offset )
					
					DrawImage( spritelib_blocks[ LIB_BLOCKS, c_block.isotype ], scr.x, scr.y )
					
					drawn_basic_block = True
					
				Else
					
					SetColor( g_block.red, g_block.green, g_block.blue )
					'SetAlpha( g_block.alpha )
					scr = iso_to_scr( g_block.offset )
					
					DrawImage( spritelib_blocks[ LIB_BLOCKS, g_block.isotype ], scr.x, scr.y )
					
					If g_enum.HasNext()
						g_block = iso_block( g_enum.NextObject() )
					Else
						Exit
					EndIf
						
				EndIf
				
			EndWhile
		
		Case CURSOR_BRUSH
			
			g_enum = grid.renderlist.ObjectEnumerator()
			g_block = iso_block( g_enum.NextObject() )
			c_enum = cursor.brush.renderlist.ObjectEnumerator()
			
			If c_enum.HasNext()
				
				c_block = iso_block( c_enum.NextObject() )
				
				While g_block <> Null Or c_block <> Null
					
					'If a cursor block is to be drawn
					If (c_block <> Null And g_block = Null) Or ..
					   (c_block <> Null And g_block <> Null And c_block.compare( g_block ) < 0)
								
						SetColor( c_block.red, c_block.green, c_block.blue )
						SetAlpha( COLOR_CYCLE[0] )
						scr = iso_to_scr( cursor.block.offset.add( c_block.offset ))
						
						DrawImage( spritelib_blocks[ LIB_BLOCKS, c_block.isotype ], scr.x, scr.y )
						
						c_block = iso_block( c_enum.NextObject() )
						
					'Else, a grid block is to be drawn
					Else
						
						SetColor( g_block.red, g_block.green, g_block.blue )
						'SetAlpha( g_block.alpha )
						scr = iso_to_scr( g_block.offset )
						
						DrawImage( spritelib_blocks[ LIB_BLOCKS, g_block.isotype ], scr.x, scr.y )
						
						g_block = iso_block( g_enum.NextObject() )
						
					EndIf
					
				EndWhile
				
			Else
			
				draw_blocks( grid )
			
			EndIf
			
		Case CURSOR_SELECT
			
			g_enum = grid.blocklist.ObjectEnumerator()
			g_block = iso_block( g_enum.NextObject() )
			c_enum = cursor.select_ghost.facelist.ObjectEnumerator()
			c_face = iso_face( c_enum.NextObject() )
			
			cursor.calculate_frame()
				
			While g_block <> Null Or c_face <> Null
				
				'If a cursor block is to be drawn
				If ..
					(c_face <> Null And g_block = Null) Or ..
					(c_face <> Null And g_block <> Null And ..
					block_to_face_compare( g_block, c_face ) > 0)
							
					SetColor( cursor.select_ghost.red, cursor.select_ghost.green, cursor.select_ghost.blue )
					SetAlpha( cursor.select_ghost.alpha )
					scr = iso_to_scr( cursor.offset.add( c_face.offset ))
					
					DrawImage( spritelib_faces[ c_face.facetype, cursor.frame ], scr.x, scr.y )
					
					If c_enum.HasNext()
						c_face = iso_face( c_enum.NextObject() )
					Else
						c_face = Null
					EndIf
					
				'Else, a grid block is to be drawn
				Else
					
					SetColor( g_block.red, g_block.green, g_block.blue )
					SetAlpha( g_block.alpha )
					scr = iso_to_scr( g_block.offset )
					
					DrawImage( spritelib_blocks[ LIB_BLOCKS, g_block.isotype ], scr.x, scr.y )
					
					If g_enum.HasNext()
						g_block = iso_block( g_enum.NextObject() )
					Else
						g_block = Null
					EndIf
					
				EndIf
				
			EndWhile
			
	EndSelect
	EndRem
	
EndFunction

'_________________________________________________________________________
Function draw_block_shadows( grid:iso_grid )
	
	
	
	Local scr_xy:scr_coord
	Local scr_yz:scr_coord
	Local scr_xz:scr_coord
	Local iter:iso_block
	SetColor( 222, 222, 222 )
	SetAlpha( 1.000 )
	
	For iter = EachIn grid.renderlist
		
		scr_xy = iso_to_scr( iso_coord.Create( iter.offset.x, iter.offset.y, 0 ))
		scr_yz = iso_to_scr( iso_coord.Create( 0, iter.offset.y, iter.offset.z ))
		scr_xz = iso_to_scr( iso_coord.Create( iter.offset.x, 0, iter.offset.z ))
		
		DrawImage( spritelib_blocks[ LIB_SHADOWS_XY, iter.isotype ], scr_xy.x, scr_xy.y )
		DrawImage( spritelib_blocks[ LIB_SHADOWS_YZ, iter.isotype ], scr_yz.x, scr_yz.y )
		DrawImage( spritelib_blocks[ LIB_SHADOWS_XZ, iter.isotype ], scr_xz.x, scr_xz.y )
		
	Next
		
EndFunction

'_________________________________________________________________________
Function draw_cursor_shadows( cursor:iso_cursor )
	
	Local scr_xy:scr_coord
	Local scr_yz:scr_coord
	Local scr_xz:scr_coord
	Local scr:scr_coord, iso:iso_coord
	Local iter:iso_block
	'Local f_iter:iso_face
	Local color
	
	SetAlpha( 1.000 )
	
	Select cursor.mode
		
		Case CURSOR_BASIC
			
			scr_xy = iso_to_scr( iso_coord.Create( cursor.block.offset.x, cursor.block.offset.y, 0 ))
			scr_yz = iso_to_scr( iso_coord.Create( 0, cursor.block.offset.y, cursor.block.offset.z ))
			scr_xz = iso_to_scr( iso_coord.Create( cursor.block.offset.x, 0, cursor.block.offset.z ))
			
			SetColor( COLOR_CYCLE[0], COLOR_CYCLE[0], COLOR_CYCLE[0] )
			
			DrawImage( spritelib_blocks[ LIB_SHADOWS_XY, cursor.block.isotype ], scr_xy.x, scr_xy.y )
			DrawImage( spritelib_blocks[ LIB_SHADOWS_YZ, cursor.block.isotype ], scr_yz.x, scr_yz.y )
			DrawImage( spritelib_blocks[ LIB_SHADOWS_XZ, cursor.block.isotype ], scr_xz.x, scr_xz.y )
		
		Case CURSOR_BRUSH
			
			For iter = EachIn cursor.brush.renderlist
				
				scr_xy = iso_to_scr( iso_coord.Create( cursor.block.offset.x+iter.offset.x, cursor.block.offset.y+iter.offset.y, 0 ))
				scr_yz = iso_to_scr( iso_coord.Create( 0, cursor.block.offset.y+iter.offset.y, cursor.block.offset.z+iter.offset.z ))
				scr_xz = iso_to_scr( iso_coord.Create( cursor.block.offset.x+iter.offset.x, 0, cursor.block.offset.z+iter.offset.z ))
				
				SetColor( COLOR_CYCLE[0], COLOR_CYCLE[0], COLOR_CYCLE[0] )
				
				DrawImage( spritelib_blocks[ LIB_SHADOWS_XY, iter.isotype ], scr_xy.x, scr_xy.y )
				DrawImage( spritelib_blocks[ LIB_SHADOWS_YZ, iter.isotype ], scr_yz.x, scr_yz.y )
				DrawImage( spritelib_blocks[ LIB_SHADOWS_XZ, iter.isotype ], scr_xz.x, scr_xz.y )
				
			Next
			
		Case CURSOR_SELECT
			
			Rem
		
			iso = New iso_coord
			
			SetAlpha( Float( 0.200 ) * ALPHA_BLINK_1 )
			
			iso.z = 0
			For iso.x = cursor.offset.x To (cursor.offset.x + cursor.select_ghost.size.x - 1)
				For iso.y = cursor.offset.y To (cursor.offset.y + cursor.select_ghost.size.y - 1)
					scr = iso_to_scr( iso )
					DrawImage( spritelib_faces[ FACE_XY_MINUS, 0 ], scr.x, scr.y )
				Next
			Next
			iso.x = 0
			For iso.y = cursor.offset.y To (cursor.offset.y + cursor.select_ghost.size.y - 1)
				For iso.z = cursor.offset.z To (cursor.offset.z + cursor.select_ghost.size.z - 1)
					scr = iso_to_scr( iso )
					DrawImage( spritelib_faces[ FACE_YZ_MINUS, 0 ], scr.x, scr.y )
				Next
			Next
			iso.y = 0
			For iso.x = cursor.offset.x To (cursor.offset.x + cursor.select_ghost.size.x - 1)
				For iso.z = cursor.offset.z To (cursor.offset.z + cursor.select_ghost.size.z - 1)
					scr = iso_to_scr( iso )
					DrawImage( spritelib_faces[ FACE_XZ_MINUS, 0 ], scr.x, scr.y )
				Next
			Next
			
			EndRem
			
	EndSelect
	
EndFunction

Rem
'This function has been removed, because I decided outlines just don't look like I envisioned.
'_________________________________________________________________________
Function draw_outlines( grid:iso_grid, cursor:iso_cursor )
	
	Local scr:scr_coord
	Local iter:iso_block
	SetColor( 0, 0, 0 )
	SetAlpha( 1.000 )
	
	'draw grid
	For iter = EachIn grid.renderlist
		
		scr = iso_to_scr( iter.offset )
		DrawImage( spritelib_blocks[ LIB_OUTLINES, iter.isotype ], scr.x, scr.y )
		
	Next
	
EndFunction
EndRem

'_________________________________________________________________________
Function draw_blocks( grid:iso_grid )
	
	Local scr:scr_coord
	Local iter:iso_block
	
	For iter = EachIn grid.renderlist
		
		SetColor( iter.red, iter.green, iter.blue )
		'SetAlpha( iter.alpha )
		scr = iso_to_scr( iter.offset )
		
		DrawImage( spritelib_blocks[ LIB_BLOCKS, iter.isotype ], scr.x, scr.y )
		
	Next
	
EndFunction

'_________________________________________________________________________
Function draw_cursor( cursor:iso_cursor )
	
	Local scr:scr_coord
	Local iter:iso_block
	'Local f_iter:iso_face
	
	Select cursor.mode
	
		Case CURSOR_BASIC
			
			iter = cursor.block
			
			SetColor( iter.red, iter.green, iter.blue )
			SetAlpha( COLOR_CYCLE[0] )
			scr = iso_to_scr( iter.offset )
			
			DrawImage( spritelib_blocks[ LIB_BLOCKS, iter.isotype ], scr.x, scr.y )
		
		Case CURSOR_BRUSH
			
			For iter = EachIn cursor.brush.renderlist
				
				SetColor( iter.red, iter.green, iter.blue )
				SetAlpha( COLOR_CYCLE[0] )
				scr = iso_to_scr( cursor.block.offset.add( iter.offset ))
				
				DrawImage( spritelib_blocks[ LIB_BLOCKS, iter.isotype ], scr.x, scr.y )
				
			Next
		
		Case CURSOR_SELECT
			
			Rem
			
			cursor.calculate_frame()
			
			For f_iter = EachIn cursor.select_ghost.facelist
				
				SetColor( cursor.select_ghost.red, cursor.select_ghost.green, cursor.select_ghost.blue )
				SetAlpha( cursor.select_ghost.alpha )
				scr = iso_to_scr( cursor.offset.add( f_iter.offset ))
				
				DrawImage( spritelib_faces[ f_iter.facetype, cursor.frame ], scr.x, scr.y )
				
			Next
			
			EndRem
		
	EndSelect
	
EndFunction

'_________________________________________________________________________
Function draw_cursor_wireframe( cursor:iso_cursor )
	
	Local scr:scr_coord
	Local c_iter:iso_block
	
	SetAlpha( COLOR_CYCLE[0] )
	SetColor( 0, 0, 0 )
	
	Select cursor.mode
	
		Case CURSOR_BASIC
			c_iter = cursor.block
			scr = iso_to_scr( c_iter.offset )
			DrawImage( spritelib_blocks[ LIB_WIREFRAMES, c_iter.isotype ], scr.x, scr.y )
			
		Case CURSOR_BRUSH
			For c_iter = EachIn cursor.brush.renderlist
				scr = iso_to_scr( cursor.block.offset.add( c_iter.offset ))
				DrawImage( spritelib_blocks[ LIB_WIREFRAMES, c_iter.isotype ], scr.x, scr.y )
			Next
			
	EndSelect
	
EndFunction

'_________________________________________________________________________
Function draw_subgrid( subgrid:iso_grid, position:scr_coord, scale# )
	
	Local scr:scr_coord
	Local final_x#
	Local final_y#
	
	SetScale( scale, scale )
	SetAlpha( 1.000 )
	
	For Local iter:iso_block = EachIn subgrid.renderlist
		
		SetColor( iter.red, iter.green, iter.blue )
		'SetAlpha( iter.alpha )
		scr = iso_to_scr( iter.offset )
		final_x = scale * Float( scr.x ) + Float( position.x )
		final_y = scale * Float( scr.y ) + Float( position.y )
		
		DrawImage( spritelib_blocks[ LIB_BLOCKS, iter.isotype ], final_x, final_y )
		
	Next
	
	SetScale( 1.000, 1.000 )
	
EndFunction

'_________________________________________________________________________
Function draw_big_msg( message$, topleft:scr_coord )
	
	Local scr:scr_coord = topleft.copy()
	Local next_line = -1
	While 1
		
		next_line = message.Find( "~n" )
		
		If next_line < 0
			'newline not found
			
			draw_msg( message, scr )
			Exit
			
		ElseIf next_line = 0
			'newline found at beginning of string
			
			message = message[1..]
			
		Else 'next_line > 0
			'newline found far away
			
			draw_msg( message[..next_line], scr )
			message = message[(next_line + 1)..]
			
		EndIf
		
		scr.y :+ CHAR_HEIGHT
		scr.x = topleft.x
		
	EndWhile
	
EndFunction

'_________________________________________________________________________
Function draw_msg( message$, scr:scr_coord )
	
	SetColor( 127, 127, 127 )
	
	Local next_token = -1
	scr.x = 2
	
	While 1
		
		next_token = message.Find( "$" )
		Local recognized_token = True
		
		If next_token < 0
			draw_string_literal( message, scr )
			Exit						
		ElseIf next_token > 0 'length > 0
			draw_string_literal( message[..next_token], scr )
		EndIf					
		scr.x :+ CHAR_WIDTH * next_token
		
		Select message[next_token..(next_token + 2)]
			Case TOKEN_DARKGRAY
				SetColor( 127, 127, 127 )
			Case TOKEN_BLACK
				SetColor(  38,  38,  38 )
			Case TOKEN_RED
				SetColor( 127,  38,  38 )
			Case TOKEN_GREEN
				SetColor(  38, 127,  38 )
			Case TOKEN_BLUE
				SetColor(  38,  38, 127 )
			Case TOKEN_YELLOW
				SetColor( 127, 127,  38 )
			Case TOKEN_CYAN
				SetColor(  38, 127, 127 )
			Case TOKEN_PURPLE
				SetColor( 127,  38, 127 )
			Default
				recognized_token = False
				draw_string_literal( "$", scr )
				scr.x :+ CHAR_WIDTH
				message = message[(next_token + 1)..]
		EndSelect
		
		If recognized_token
			message = message[(next_token + 2)..]
		EndIf
		
	EndWhile
	
EndFunction

'_________________________________________________________________________
Function draw_string_literal( message$, scr:scr_coord )
	'This uses a font from Windows Vista, which is smoothed
	DrawText( message, scr.x, scr.y )
EndFunction

