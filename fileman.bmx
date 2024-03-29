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
 - shorten up the reported paths and make them relative to the executable instead of absolute
 - make an in-house file chooser with preview window for choosing files using my gui system
EndRem

Strict

Import BRL.Blitz
Import BRL.PNGLoader
Import BRL.WAVLoader
Import BAH.LibXML

Import "globals.bmx"
Import "coord.bmx"
Import "iso_block.bmx"
Import "iso_grid.bmx"

'_________________________________________________________________________
Function fileman_load_art()
	
	spritelib_blocks_map = LoadPixmapPNG( "incbin::art/spritelib_blocks.png" )
	AutoImageFlags( FILTEREDIMAGE | MIPMAPPEDIMAGE )
	
	For Local library = 0 To (COUNT_LIBS - 1)
		For Local isotype = 0 To (COUNT_BLOCKS - 1)
			
			spritelib_blocks[ library, isotype ] = LoadImage( spritelib_blocks_map.Window( isotype * 23, library * 23, 23, 23 ))
			SetImageHandle( spritelib_blocks[ library, isotype ], 11, 11 )
			
		Next
	Next
	
	spritelib_faces_map = LoadPixmapPNG( "incbin::art/spritelib_faces.png" )
	For Local face_library = 0 To (COUNT_FACE_LIBS - 1)
		For Local facetype = 0 To (COUNT_FACES - 1)
			
			spritelib_faces[ face_library, facetype ] = LoadImage( spritelib_faces_map.Window( facetype * 23, face_library * 23, 23, 23 ))
			SetImageHandle( spritelib_faces[ face_library, facetype ], 11, 11 )
			
		Next
	Next
	
	font_consolas = LoadImageFont( "incbin::art/consolas.ttf", 10 )
	SetImageFont( font_consolas )
	CHAR_HEIGHT = TextHeight( "a" ) - 4
	CHAR_WIDTH = TextWidth( "a" ) - 2
	
	Rem
	spritelib_font_map = LoadPixmapPNG( "incbin::art/spritelib_font.png" )
	For Local index = 0 To 95
		
		spritelib_font[ index ] = LoadImage( spritelib_font_map.Window( index * 8, 0, 8, 8 ))
		SetImageHandle( spritelib_font[ index ], 0, 0 )
		
	Next
	EndRem
		
EndFunction

'_________________________________________________________________________
Function fileman_load_sound()
	
	high_click = LoadSound( "incbin::sound/high_click.wav" )
	low_click = LoadSound( "incbin::sound/low_click.wav" )
	
EndFunction

'_________________________________________________________________________
Function fileman_load_cfg_auto()
	
	Local file_in:TStream = ReadFile( CONFIG_FILENAME )
	If Not file_in
	
		If Not fileman_save_cfg_auto()
			Return False
		
		Else 'fileman_save_cfg_auto() completed successfully
			'report load completion due to the fact that the variables written to disk
			'will be the same as the ones already loaded into memory from hard-coded values
			Return True
			
		EndIf
	EndIf
	
	Local found_title = False
	
	Local line_number = 0
	Local line$
	
	While Not Eof( file_in )
	
		line_number :+ 1
		line = ReadLine( file_in ).Trim()
		
		If line.length = 0 Or line[0..1] = ";"
			
			Continue
		
		ElseIf line[0..1] = "["
			
			If line.find( "config" ) >= 0 And Not found_title
				
				found_title = True
				Continue
				
			Else
				
				CloseStream( file_in )
				Return False
				
			EndIf
		
		Else
			
			Local name$ = line[..line.find( "=" )].Trim()
			Local value$ = line[(line.find( "=" ) + 1)..].Trim()
			
			Select name
			
				Case "SCREEN_WIDTH"
					SCREEN_WIDTH = value.ToInt()
					ORIGIN_X = SCREEN_WIDTH / 2
				Case "SCREEN_HEIGHT"
					SCREEN_HEIGHT = value.ToInt()
					ORIGIN_Y = SCREEN_HEIGHT / 2
				Case "GRID_X"
					GRID_X = value.ToInt()
				Case "GRID_Y"
					GRID_Y = value.ToInt()
				Case "GRID_Z"
					GRID_Z = value.ToInt()
				
				Default
					
					CloseStream( file_in )
					Return False
						
			EndSelect
			
		EndIf
		
	EndWhile
	
EndFunction

'_________________________________________________________________________
Function fileman_save_cfg_auto()
	
	If Not CreateFile( CONFIG_FILENAME ) Then Return False
	
	Local file_out:TStream = WriteStream( CONFIG_FILENAME )
	
	WriteLine( file_out, ";isoblox "+PROJECT_VERSION )
	WriteLine( file_out, "; data format:" )
	WriteLine( file_out, ";  var_name = <var_value>" )
	WriteLine( file_out, "" )
	WriteLine( file_out, "[config]" )
	WriteLine( file_out, "SCREEN_WIDTH  = "+SCREEN_WIDTH )
	WriteLine( file_out, "SCREEN_HEIGHT = "+SCREEN_HEIGHT )
	WriteLine( file_out, "GRID_X        = "+GRID_X )
	WriteLine( file_out, "GRID_Y        = "+GRID_Y )
	WriteLine( file_out, "GRID_Z        = "+GRID_Z )
	
	CloseStream( file_out )
	
	Return True
		
EndFunction

'_________________________________________________________________________
Function fileman_grid_save_system$( grid:iso_grid )
	
	'stub
	
EndFunction

'_________________________________________________________________________
Function fileman_grid_save_auto$( grid:iso_grid )
	
	Local file_format$ = "isoblox_grid_"
	
	CreateDir( "user" )
	Local dir$[] = LoadDir( "./user/" )
	
	'find the highest unused file number
	Local high = 1
	For Local file$ = EachIn dir
		If file.Find( file_format ) >= 0
			Local current = StripAll(file)[(file_format.length)..].ToInt()
			If high <= current Then high = current + 1
		EndIf
	Next

	Local file$ = "./user/"+file_format+high+".dat"
	
	If Not fileman_grid_save_explicit( file, grid )
		Return "ERROR"
	Else
		Return file
	EndIf
	
EndFunction

'_________________________________________________________________________
Function fileman_grid_save_explicit( file$, grid:iso_grid )
	
	If Not CreateFile( file ) Then Return False
	
	Local file_out:TStream = WriteStream( file )
	
	WriteLine( file_out, ";isoblox "+PROJECT_VERSION )
	WriteLine( file_out, "; data format:" )
	WriteLine( file_out, ";  size = <x> <y> <z>" )
	WriteLine( file_out, ";         |grid dims|" )
	WriteLine( file_out, ";  iso_block = <isotype>,<x> <y> <z>,<red> <green> <blue>" )
	WriteLine( file_out, ";              |index__|,|position_|,|color components__|" )
	WriteLine( file_out, "" )
	WriteLine( file_out, "[iso_grid]" )
	WriteLine( file_out, " size = "+grid.size.x+" "+grid.size.y+" "+grid.size.z )
	For Local iter:iso_block = EachIn grid.renderlist
		WriteLine( file_out, "  iso_block = "+iter.isotype+","+iter.offset.x+" "+iter.offset.y+" "+iter.offset.z+","+iter.red+" "+iter.green+" "+iter.blue )
	Next
	
	CloseStream( file_out )
	
	Return True
	
EndFunction

'_________________________________________________________________________
Function fileman_grid_load_system$( grid:iso_grid )
	
	CreateDir( "user" )
	Local file_string$ = ..
		RequestFile( ..
			"Select an existing isoblox grid data file to load", ..
			"isoblox grid data file (*.dat):dat;All files:*", ..
			False, ..
			CurrentDir()+"/user/" )
	Local file:TStream = ReadFile( file_string )
	If file
		grid = fileman_grid_load_explicit( file_string )
		Return file_string
	Else
		Return "ERROR"
	EndIf
	
EndFunction

'_________________________________________________________________________
Function fileman_grid_load_explicit:iso_grid( file_string$ )
	
	Local doc:TxmlDoc = TxmlDoc.parseFile( file_string )
	Local node:TxmlNode = doc.GetRootElement()
	Local nodeList:TList = node.GetChildren()
	For node = EachIn nodeList
		
	Next
	
EndFunction

'_________________________________________________________________________
Function fileman_screenshot_auto$()
	
	Local file_format$ = "isoblox_screenshot_"
	
	CreateDir( "user" )
	Local dir$[] = LoadDir( "./user/" )
	
	'find the highest unused screenshot number
	Local high = 1
	For Local file$ = EachIn dir
		If file.Find( file_format ) >= 0
			Local current = StripAll(file)[(file_format.length)..].ToInt()
			If high <= current Then high = current + 1
		EndIf
	Next

	Local file$ = "./user/"+file_format+high+".png"
	
	If Not fileman_screenshot_explicit( file )
		Return "ERROR"
	Else	
		Return file
	EndIf
	
EndFunction

'_________________________________________________________________________
Function fileman_screenshot_explicit( file$ )
	
	Return SavePixmapPNG( ..
		GrabPixmap( 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT ), ..
		file, ..
		5 )
		
EndFunction

