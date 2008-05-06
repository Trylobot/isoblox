'iso_selection.bmx

Rem
TODO:

* Modify the iso_cursor to use a single position iso_coord object and a single size iso_coord object.
	It will instantiate a single such object as a field of iso_cursor. Then, when another field uses a
	position or size object, that other field's object will be set to the already-instantiated cursor object.
	In this way, knowledge of the cursor's size and position will be automatically shared/updated regardless
	of cursor mode or what piece of code modifies it.

* Move the constants from this file to globals.bmx

EndRem

'____________________
'display register bit masks (necessary?)

'adjacency array constants (negative/even, positive/odd)
Const DIRECTION_X_NEG = 0
Const DIRECTION_X_POS = 1
Const DIRECTION_Y_NEG = 2
Const DIRECTION_Y_POS = 3
Const DIRECTION_Z_NEG = 4
Const DIRECTION_Z_POS = 5
'anchor array constants
Const ANCHOR_X0_Y0_Z0 = 0
Const ANCHOR_X1_Y0_Z0 = 1
Const ANCHOR_X0_Y1_Z0 = 2
Const ANCHOR_X0_Y0_Z1 = 3
Const ANCHOR_X1_Y1_Z0 = 4
Const ANCHOR_X0_Y1_Z1 = 5
Const ANCHOR_X1_Y0_Z1 = 6
Const ANCHOR_X1_Y1_Z1 = 7
'____________________


Strict
Import "globals.bmx"
Import "coord.bmx"


Function flip_direction%( direction% )
	If direction Mod 2 = 0
		'negative; return positive (+1)
		Return direction + 1
	Else
		'positive; return negative (-1)
		Return direction - 1
	EndIf
EndFunction

Type iso_selection_node
	Field display% 'flag register indicating which iso_selection frame bitmaps to display (I believe there are 24)
	Field adjacency[6]:iso_selection_node 'directional, named adjacency list. can have as few as zero or as many as six
	
	Method New()
		display = 0
		For Local index = 0 To 5
			adjacency[index] = Null
		Next
	EndMethod
	
	Method Create:iso_selection_node( ? )
	
	EndMethod
EndType

Type iso_selection
	Field position:iso_coord 'position in discrete pseudo-3D isometric space
	Field size:iso_coord 'size as measured in discrete pseudo-3D isometric units
	Field anchor[8]:iso_selection_node 'points to the 8 corner nodes. can overlap for small selection volume sizes
	
	Method New()
		position = New iso_coord
		size = New iso_coord
		For Local index = 0 To 7
			anchor[index] = Null
		Next
	EndMethod
	
	Method Create:iso_selection( ? )
	EndMethod
	
	Method resize( new_size:iso_coord )
		resize( size.sub( new_size ))
	EndMethod
	
	Method resize_by( delta:iso_coord )
		Local new_size:iso_coord = size.sub( delta )
		Local counter
		Local anchor_node:iso_selection_node
		
		If delta.x < 0
			If new_size.x > 1
				delete_from_anchor_in_direction( (-delta.x), anchor[ANCHOR_X1_Y0_Z0], DIRECTION_X_NEG )
				delete_from_anchor_in_direction( (-delta.x), anchor[ANCHOR_X1_Y1_Z0], DIRECTION_X_NEG )
				delete_from_anchor_in_direction( (-delta.x), anchor[ANCHOR_X1_Y0_Z1], DIRECTION_X_NEG )
				delete_from_anchor_in_direction( (-delta.x), anchor[ANCHOR_X1_Y1_Z1], DIRECTION_X_NEG )
			ElseIf new_size.x = 1
				
			ElseIf new_size.x = 0
				
			Else 'new_size.x < 0
				
			EndIf
		ElseIf delta.x = 0
			'do nothing
		ElseIf delta.x > 0
			
		EndIf
		If delta.y < 0
			If new_size.y > 1
				delete_from_anchor_in_direction( (-delta.y), anchor[ANCHOR_X0_Y1_Z0], DIRECTION_Y_NEG )
				delete_from_anchor_in_direction( (-delta.y), anchor[ANCHOR_X1_Y1_Z0], DIRECTION_Y_NEG )
				delete_from_anchor_in_direction( (-delta.y), anchor[ANCHOR_X0_Y1_Z1], DIRECTION_Y_NEG )
				delete_from_anchor_in_direction( (-delta.y), anchor[ANCHOR_X1_Y1_Z1], DIRECTION_Y_NEG )
			ElseIf new_size.y = 1
				
			ElseIf new_size.y = 0
				
			Else 'new_size.y < 0
				
			EndIf
		ElseIf delta.y = 0
			'do nothing
		ElseIf delta.y > 0
			
		EndIf
		If delta.z < 0
			If new_size.z > 1
				delete_from_anchor_in_direction( (-delta.z), anchor[ANCHOR_X0_Y0_Z1], DIRECTION_Z_NEG )
				delete_from_anchor_in_direction( (-delta.z), anchor[ANCHOR_X1_Y0_Z1], DIRECTION_Z_NEG )
				delete_from_anchor_in_direction( (-delta.z), anchor[ANCHOR_X0_Y1_Z1], DIRECTION_Z_NEG )
				delete_from_anchor_in_direction( (-delta.z), anchor[ANCHOR_X1_Y1_Z1], DIRECTION_Z_NEG )
			ElseIf new_size.z = 1
				
			ElseIf new_size.z = 0
				
			Else 'new_size.z < 0
				
			EndIf
		ElseIf delta.z = 0
			'do nothing
		ElseIf delta.z > 0
			
		EndIf
	EndMethod
	
	Method delete_from_anchor_in_direction( count, anchor_node:iso_selection_node, direction% )
		If count < 1
			Return
		EndIf
		Local opposite_direction = flip_direction( direction )
		Local doomed_node:iso_selection_node
		Local happy_node:iso_selection_node
		For Local counter = 1 to count
			doomed_node = anchor_node.adjacency[direction]
			happy_node = doomed_node.adjacency[direction]
			'this _should_ leave the current "doomed_node" out in the cold, to be deleted by automatic garbage collection, since nothing points to it
			anchor_node.adjacency[direction] = happy_node
			happy_node.adjacency[opposite_direction] = anchor_node
		Next
	EndMethod
EndType
