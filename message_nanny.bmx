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
Import "draw.bmx"

Type message_nanny
	
	Field message_list:TList
	Field max_messages
	
	Method New()		
		message_list = CreateList()
		max_messages = MAX_STATUS_MESSAGE_COUNT		
	EndMethod
	
	Method append( message$ )		
		message_list.AddFirst( message )		
	EndMethod
	
	Method draw()
		
		SetOrigin( 0, 0 )
	
		If Not message_list.isEmpty()
			
			While message_list.Count() > max_messages
				message_list.LastLink().Remove()
			EndWhile			
			
			Local scr:scr_coord = scr_coord.create( 1, (SCREEN_HEIGHT - CHAR_HEIGHT - 1) )
			Local message$			
			Local message_number = 0			
			
			For message = EachIn message_list				
				SetAlpha( 1.000 - (Float(message_number) / Float(max_messages)) )				
				
				draw_msg( message, scr )				
				
				scr.y :- CHAR_HEIGHT
				message_number :+ 1				
			Next
		
		EndIf
		
		SetOrigin( ORIGIN_X, ORIGIN_Y )
		
	EndMethod
	
EndType

