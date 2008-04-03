Rem
_______________________________
Project isoblox
This is a BlitzMax source file
Author is Tyler W.R. Cole
Started on September 30th, 2006
_______________________________
EndRem

Strict


Function iso_to_scr:scr_coord( iso:iso_coord )
	
	Return scr_coord.create(..
		8 * (iso.x - iso.y),..
		(4 * (iso.x + iso.y)) - (8 * iso.z) )
	
EndFunction

'since this function could theoretically return a line,
' I choose to return the "closest" position in a 3D isometric volume of a given size that lies on that line.
Function scr_to_iso:iso_coord( scr:scr_coord, size:iso_coord )
	
	'stubbed for now
	Return New iso_coord
	
EndFunction



Type scr_coord
	
	Field x, y
	
	Method New()
		x = 0; y = 0
	EndMethod
	
	Function create:scr_coord( nx, ny )
		Local v:scr_coord = New scr_coord
		v.x = nx; v.y = ny
		Return v
	EndFunction
	
	Method set( nx, ny )
		x = nx; y = ny
	EndMethod
	
	Method copy:scr_coord()
		Return create( x, y )
	EndMethod
	
	Method add:scr_coord( v:scr_coord )
		Return create( x + v.x, y + v.y )
	EndMethod
	
	Method sub:scr_coord( v:scr_coord )
		Return create( x - v.x, y - v.y )
	EndMethod
	
	Method equal( v:scr_coord )
		Return x = v.x And y = v.y
	EndMethod
	
	Method str$()
		Return "[scr_coord] (" + x + "," + y + ")"
	EndMethod
		
EndType



Type iso_coord
	
	Field x, y, z
	
	Method value()
		Return x + y + z
	EndMethod
	
	Method New()
		x = 0; y = 0; z = 0
	EndMethod
	
	Function create:iso_coord( nx, ny, nz )
		Local v:iso_coord = New iso_coord
		v.x = nx; v.y = ny; v.z = nz
		Return v
	EndFunction
	
	Method compare( other_obj:Object )
		Local other:iso_coord = iso_coord( other_obj )
		'difference of the offset layer
		Local result = value() - other.value()
		'tiebreaker (only matters when in the same layer)
		If result = 0
			'y component tiebreaker (supercedes x and z components)
			If y > other.y
				result :+ 4
			ElseIf y < other.y
				result :- 4
			EndIf
			'x component tiebreaker (supercedes z component)
			If x > other.x
				result :+ 2
			ElseIf x < other.x
				result :- 2
			EndIf
			'z component tiebreaker (lowest priority)
			If z > other.z
				result :+ 1
			ElseIf z < other.z
				result :- 1
			EndIf
		EndIf
		Return result
	EndMethod
	
	Method set( nx, ny, nz )
		x = nx; y = ny; z = nz
	EndMethod
	
	Method copy:iso_coord()
		Return create( x, y, z )
	EndMethod
	
	Method add:iso_coord( v:iso_coord )
		Return create( x + v.x, y + v.y, z + v.z )
	EndMethod
	
	Method sub:iso_coord( v:iso_coord )
		Return create( x - v.x, y - v.y, z - v.z )
	EndMethod
	
	Method equal( v:iso_coord )
		Return x = v.x And y = v.y And z = v.z
	EndMethod
	
	Method str$()
		Return "[iso_coord] (" + x + "," + y + "," + z + ")"
	EndMethod
	
	Function invalid:iso_coord()
		Return create( -1, -1, -1 )
	EndFunction
	
	Method is_invalid()
		Return x < 0 Or y < 0 Or z < 0
	EndMethod
		
	Method in_bounds( size:iso_coord )
		Return ..
			x >= 0 And ..
			y >= 0 And ..
			z >= 0 And ..
			x < size.x And ..
			y < size.y And ..
			z < size.z
	EndMethod
	
EndType

