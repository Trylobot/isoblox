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

Function draw_gui()
	
	'push origin
	Local Ox#, Oy#
	GetOrigin( Ox, Oy )
	SetOrigin( 0, 0 )
	
	'mock_window

	If KeyDown( Key_F1 )
		
		SetColor( 255, 255, 255 )
		SetAlpha( 0.750 )
		DrawRect( 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT )
				
		SetColor( 128, 128, 128 )
		SetAlpha( 1.000 )
		Local line, indent
		SetOrigin( 5, 5 )
		SetAlpha( 0.88 ); line = 0; indent = 0
		DrawText( "ISOBLOX (c) 2006 Tyler W.R. Cole", 0, line * LINE_HEIGHT ); line :+ 1
		SetAlpha( 0.75 ); line :+ 1; indent = 8
		DrawText( "NUMPAD{0-9}:move cursor up/down/horizontal", indent, line * LINE_HEIGHT ); line :+ 1
		DrawText( "RIGHTMOUSE+DRAG:drag viewport with mouse", indent, line * LINE_HEIGHT); line :+ 1
		DrawText( "{SPACE,ENTER,INSERT}:insert {D,DELETE}:remove E:extract", indent, line * LINE_HEIGHT ); line :+ 1
		DrawText( "F+{B:blocks,C:cursor,L:gridlines,S:shadows,O:outlines,W:wireframes}", indent, line * LINE_HEIGHT ); line :+ 1
		DrawText( "{Left,Right}:block index increment/decrement", indent, line * LINE_HEIGHT ); line :+ 1
		DrawText( "{R,G,B}+{NUM+,NUM-}:color value increase/decrease", indent, line * LINE_HEIGHT ); line :+ 1
		DrawText( "A+{NUM+,NUM-}:alpha increase/decrease", indent, line * LINE_HEIGHT ); line :+ 1
		DrawText( "{X,Y,Z}+{NUM+,NUM-}:grid size increase/decrease", indent, line * LINE_HEIGHT ); line :+ 1
		
	Else
		
		SetColor( 0, 0, 0 )
		SetAlpha( 0.250 )
		DrawText( "F1 for help", 0, 0 )
		
	EndIf
	
	'pop origin
	SetOrigin( Ox, Oy )
	
EndFunction

Function mock_window()

	'mock window object proof-of-concept
	Local position:scr_coord = scr_coord.create( 100, 100 )
	Local size:scr_coord = scr_coord.create( 200, 150 )
	Local name$ = "ABCabctkygjiKLZPqs"
	'draw the pane
	SetColor( 0, 0, 0 )
	SetAlpha( 0.333 )
	DrawRect( position.x, position.y, size.x, size.y )
	'draw title bar
	DrawRect( position.x+2, position.y+2, size.x-4, 15 )
	'draw name
	SetColor( 255, 255, 255 )
	SetAlpha( 1.000 )
	DrawText( name, position.x+3, position.y+2 )

EndFunction

Type gui_object

	Field position:scr_coord
	Field size:scr_coord
	
	Field name$
	
	Method New()
		position = scr_coord.create( 0, 0 )
		size = scr_coord.create( 0, 0 )
		name = ""
	EndMethod
	
	Function create:gui_object( init_pos:scr_coord, init_size:scr_coord, init_name$ )
		Local obj:gui_object = New gui_object
		obj.position = init_pos.dupe()
		obj.size = init_size.dupe()
		obj.name = init_name
		Return obj
	EndFunction
	
	Method draw()
	EndMethod

EndType

Type window Extends gui_object
	
	Field children:TList
	
	Method New()
		position = scr_coord.create( 0, 0 )
		size = scr_coord.create( 0, 0 )
		name = ""
		children = CreateList()
	EndMethod
	
	Function create:window( init_pos:scr_coord, init_size:scr_coord, init_name$ )
		Local win:window = New window
		win = window( gui_object.create( init_pos, init_size, init_name ))
		Return win
	EndFunction
	
	Method add_child( child:gui_object )
	EndMethod
	
	Method draw()
		'draw the pane
		SetColor( 0, 0, 0 )
		SetAlpha( 0.333 )
		DrawRect( position.x, position.y, size.x, size.y )
		'draw title bar
		DrawRect( position.x+1, position.y+1, size.x-1, 12 )
		'draw name
		SetColor( 255, 255, 255 )
		SetAlpha( 1.000 )
		DrawText( name, position.x+3, position.y+3 )
		
		'draw the children
		
	EndMethod
	
EndType
