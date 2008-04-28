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

'adjacency array constants
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


Type iso_selection_node
	Field display% 'flag register indicating which iso_selection frame bitmaps to display (I believe there are 24)
	Field adjacency[6]:iso_selection_node 'directional, named adjacency list. can have as few as zero or as many as six
	
	Method New()
		display = 0
		For Local index = 0 to 5
			adjacency[index] = NULL
		Next
	EndMethod
	
	Method create:iso_selection_node( ? )
	
	EndMethod
EndType

Type iso_selection
	Field position:iso_coord 'position in discrete pseudo-3D isometric space
	Field size:iso_coord 'size as measured in discrete pseudo-3D isometric units
	Field anchor[8]:iso_selection_node 'points to the 8 corner nodes. can overlap for small selection volume sizes
	
	Method New()
		position = New iso_coord
		size = New iso_coord
		For Local index = 0 to 7
			anchor[index] = NULL
		Next
	EndMethod
	
	Method create:iso_selection( ? )
		
	EndMethod
	
	Method resize( ? )
		
	EndMethod
EndType
