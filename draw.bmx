Rem
_______________________________
Project isoblox
This is a BlitzMax source file
Author is Tyler W.R. Cole
Started on September 30th, 2006

 isometric axes layout (x,y,z)

   Z              screen axes layout (x,y)
   |      
   o              o__X
  / \             |  
 Y   X            Y
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

'_________________________________________________________________________
Function draw_hover_block( offset:iso_coord )
	
	Local scr:scr_coord
	Local iter:iso_block
	SetColor( 0, 0, 0 )
	SetAlpha( 1.000 )
	
	scr = iso_to_scr( iter.offset )
	DrawImage( spritelib_blocks[ LIB_OUTLINES, iter.isotype ], scr.x, scr.y )
	
	SetColor( iter.red, iter.green, iter.blue )
	DrawImage( spritelib_blocks[ LIB_BLOCKS, iter.isotype ], scr.x, scr.y )
	
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
'optimize this, and use links (not an enumerator)
Function draw_blocks_with_cursor( grid:iso_grid, cursor:iso_cursor )
	
	Local g_enum:TListEnum
	Local g_block:iso_block
	
	Local c_enum:TListEnum
	Local c_block:iso_block
	'Local c_face:iso_face
	
	Local scr:scr_coord
	Local drawn_basic_block
	
	SetAlpha( 1.000 )
	
	Select cursor.mode
	
		Case CURSOR_BASIC
			
			g_enum = grid.renderlist.ObjectEnumerator()
			g_block = iso_block( g_enum.NextObject() )
			c_block = cursor.basic_block
			drawn_basic_block = False
			
			While g_block <> Null Or Not drawn_basic_block
				
				If Not drawn_basic_block And (c_block.offset.value() - g_block.offset.value()) < 0
					
					SetColor( c_block.red, c_block.green, c_block.blue )
					SetAlpha( COLOR_CYCLE[0] )
					scr = iso_to_scr( cursor.offset.add( c_block.offset ))
					
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
			c_enum = cursor.brush_grid.blocklist.ObjectEnumerator()
			
			If c_enum.HasNext()
				
				c_block = iso_block( c_enum.NextObject() )
				
				While g_block <> Null Or c_block <> Null
					
					'If a cursor block is to be drawn
					If ..
						(c_block <> Null And g_block = Null) Or ..
						(c_block <> Null And g_block <> Null And ..
						(c_block.offset.value() - g_block.offset.value()) < 0)
								
						SetColor( c_block.red, c_block.green, c_block.blue )
						SetAlpha( COLOR_CYCLE[0] )
						scr = iso_to_scr( cursor.offset.add( c_block.offset ))
						
						DrawImage( spritelib_blocks[ LIB_BLOCKS, c_block.isotype ], scr.x, scr.y )
						
						If c_enum.HasNext()
							c_block = iso_block( c_enum.NextObject() )
						Else
							c_block = Null
						EndIf
						
					'Else, a grid block is to be drawn
					Else
						
						SetColor( g_block.red, g_block.green, g_block.blue )
						'SetAlpha( g_block.alpha )
						scr = iso_to_scr( g_block.offset )
						
						DrawImage( spritelib_blocks[ LIB_BLOCKS, g_block.isotype ], scr.x, scr.y )
						
						If g_enum.HasNext()
							g_block = iso_block( g_enum.NextObject() )
						Else
							g_block = Null
						EndIf
						
					EndIf
					
				EndWhile
				
			Else
			
				draw_blocks( grid )
			
			EndIf
			
		Case CURSOR_SELECT
			
			Rem
			
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
			c_iter = cursor.basic_block
			scr = iso_to_scr( cursor.offset.add( c_iter.offset ))
			DrawImage( spritelib_blocks[ LIB_WIREFRAMES, c_iter.isotype ], scr.x, scr.y )
			
		Case CURSOR_BRUSH
			For c_iter = EachIn cursor.brush_grid.blocklist
				scr = iso_to_scr( cursor.offset.add( c_iter.offset ))
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
	
	For Local iter:iso_block = EachIn subgrid.blocklist
		
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
	
	For Local position = 0 To (message.length - 1)
		
		DrawImage( ..
			spritelib_font[message[position] - 32], ..
			scr.x + (position * CHAR_WIDTH), ..
			scr.y )
		
	Next
	
EndFunction

'_________________________________________________________________________
Function draw_gridlines( grid:iso_grid )

	SetColor( 0, 0, 0 )
	SetAlpha( 0.090 )
	
	SetLineWidth( 1 )
	
	draw_lines( ..
		grid.bounds[ 0], ..
		grid.bounds[ 1], ..
		grid.bounds[ 2], ..
		grid.size.x+1 )
		
	draw_lines( ..
		grid.bounds[ 0], ..
		grid.bounds[ 3], ..
		grid.bounds[ 4], ..
		grid.size.y+1 )
		
	draw_lines( ..
		grid.bounds[ 5], ..
		grid.bounds[ 0], ..
		grid.bounds[ 4], ..
		grid.size.y+1 )
		
	draw_lines( ..
		grid.bounds[ 5], ..
		grid.bounds[ 6], ..
		grid.bounds[ 7], ..
		grid.size.z+1 )
		
	draw_lines( ..
		grid.bounds[ 8], ..
		grid.bounds[ 9], ..
		grid.bounds[ 2], ..
		grid.size.x+1 )
		
	draw_lines( ..
		grid.bounds[ 8], ..
		grid.bounds[10], ..
		grid.bounds[ 7], ..
		grid.size.z+1 )
	
	SetLineWidth( 2 )
	
	draw_heavy_lines( ..
		grid.bounds[ 6], ..
		grid.bounds[10], ..
		grid.bounds[11], ..
		grid.bounds[12], ..
		grid.bounds[ 0], ..
		grid.bounds[13] )
	
EndFunction

'_________________________________________________________________________
Function draw_lines( u:scr_coord, v:scr_coord, delta:scr_coord, count )
	
	For Local iteration = 1 To count
		
		DrawLine( u.x, u.y, v.x, v.y )
		u = u.add(delta)
		v = v.add(delta)
		
	Next
	
EndFunction

'_________________________________________________________________________
Function draw_heavy_lines( p1:scr_coord, p2:scr_coord, p3:scr_coord, p4:scr_coord, p5:scr_coord, p6:scr_coord )
	
	'axes
	SetAlpha( 0.065 )
	DrawLine( p1.x, p1.y, 1, 0 )
	DrawLine( p5.x, p5.y, 1, 0 )
	DrawLine( 1, 0, p3.x, p3.y )
	
	'borders
	SetAlpha( 0.160 )
	DrawLine( p1.x, p1.y, p2.x, p2.y )
	DrawLine( p2.x, p2.y, p3.x, p3.y )
	DrawLine( p3.x, p3.y, p4.x, p4.y )
	DrawLine( p4.x, p4.y, p5.x, p5.y )
	DrawLine( p5.x, p5.y, p6.x, p6.y )
	DrawLine( p6.x, p6.y, p1.x, p1.y )
	
EndFunction
