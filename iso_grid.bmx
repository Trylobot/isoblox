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
Import "iso_block.bmx"

'_________________________________________________________________________
Type iso_grid
	
	Field size:iso_coord      'dimensions of grid
	Field space:iso_block[,,] '3D array of [iso_block] objects
	Field filled:Int[,,]      'one flag for each position of the grid, indicating its fill status
	Field renderlist:TList    'list of all [iso_block] objects from grid in render-order
	Field backref:TLink[,,]   '3D array of references to renderlist items. Starts with all NULL references.
	Field block_count         'total number of filled positions in the grid
	Field bg_img:TPixmap      'background isometric wireframe grid image
	
  '_________________________________________________________________________
	Method New()
		'reserve smallest amount of memory possible for a new iso_grid object
		size = iso_coord.create( 1, 1, 1 )
		filled = New Int[ 1, 1, 1 ]
		space = New iso_block[ 1, 1, 1 ]
		renderlist = New TList
		backref = New TLink[ 1, 1, 1 ]
		block_count = 0
	EndMethod
	
  '_________________________________________________________________________
	Function create:iso_grid( initial_size:iso_coord )
		'return a new, blank iso_grid of given initial size
		Local new_space:iso_grid = New iso_grid
		new_space.resize( initial_size )
		Return new_space
	EndFunction
	
  '_________________________________________________________________________
	Method empty()
		Return renderlist.isEmpty()
	EndMethod
	
  '_________________________________________________________________________
	'retrieval methods (specific to this object)
	Method space_at:iso_block( v:iso_coord )
		Return space[ v.x, v.y, v.z ]
	EndMethod
	Method filled_at:Int( v:iso_coord )
		Return filled[ v.x, v.y, v.z ]
	EndMethod
	Method backref_at:TLink( v:iso_coord )
		Return backref[ v.x, v.y, v.z ]
	EndMethod
	
  '_________________________________________________________________________
	'retrieval functions (generalized)
	Function space_at_in:iso_block( space:iso_block[,,], v:iso_coord )
		Return space[ v.x, v.y, v.z ]
	EndFunction 
	Function filled_at_in:Int( filled:Int[,,], v:iso_coord )
		Return filled[ v.x, v.y, v.z ]
	EndFunction 
	Function backref_at_in:TLink( backref:TLink[,,], v:iso_coord )
		Return backref[ v.x, v.y, v.z ]
	EndFunction 
		
  '_________________________________________________________________________
	Rem
		Insert
		1. Should this method have a selector for over-write?
		will insert a new block at a location, or over-write existing.
		the location is provided inside the object.
	EndRem
	Method insert( new_block:iso_block )
		
		If new_block.offset.in_bounds( size )
			
			If Not filled_at( new_block.offset )
				block_count :+ 1
			EndIf
			
			filled_at( new_block.offset ) = True
			space_at( new_block.offset ) = new_block.copy()
			backref_at( new_block.offset ) = renderlist_insert( space_at( location ))
			
		EndIf
		
	EndMethod
	Rem
		Insert_SubGrid
		Should this method have an option for over-write?
		  (will assume no option, and default to over-write for now)
		Will only insert blocks with valid locations.
			Locations are given as the offset of the subgrid origin added to the local offset of the block in question
		This method is going to be heavily re-worked and optimized, so it may not be pretty.
	EndRem
	Method insert_subgrid( offset:iso_coord, subgrid:iso_grid )
		
		Rem
		Local main_enum:TListEnum = renderlist.ObjectEnumerator()
		Local main_block:iso_block = iso_block( main_enum.NextObject() )		
		Local sub_enum:TListEnum = subgrid.renderlist.ObjectEnumerator()
		Local sub_block:iso_block = iso_block( sub_enum.NextObject() )		
		While ???			
			'Have to insert stuff... Enums aren't going to be enough. I need to use TLinks.
			'I also need to figure out how Enums work and replicate that behavior here so I can
			'  directly insert.			
			'Looking at the enumeration method in TList will illuminate just how exactly to tell
			'  when you're at the end of a cyclic list (checking for NULL obviously wouldn't work)
		EndWhile
		EndRem
		
		Local main_cursor:TLink = renderlist.FirstLink()
		Local sub_cursor:TLink = subgrid.renderlist.FirstLink()
		
		'IF the sub list is empty
			'exit.
		'IF the main list is empty
			'dupe the entire subgrid into the main, then exit.
		
		'WHILE the sub's value is LESS THAN the main's ...
			'IF the sub's location is valid for inserting into the main grid
				'insert the sub BEFORE the main.
			'IF there are more blocks in the sub list
				'increment the sub cursor.
			'ELSE
				'exit.
		'END WHILE
		
		'IF there are more blocks in main
			'increment the main cursor.
		
		While ???
			
			'WHILE the sub's value is GREATER THAN the main's ...
				'IF the sub's location is valid for inserting into the main grid
					'insert the sub AFTER the main, AND increment the main (to compensate for the insertion) 
					'UNLESS OF COURSE the sub's location over-writes a main
						'in that case over-write it.
				
				'IF there are more blocks in the sub list
					'increment the sub cursor.
				'ELSE
					'exit.
			'END WHILE
					
			'IF there are more blocks in main
				'increment the main cursor.
			'ELSE
				'exit.
			
		EndWhile
		
	EndMethod
	Rem
		RenderList_Insert
		this is really an "upsert" in that it can either insert a new value,
		or update (replace) an old value with the same key.
		also maintains the sort-order of the renderlist
	EndRem
	Method renderlist_insert:TLink( new_block:iso_block )
		
		'trivial, empty list case
		If renderlist.IsEmpty()
			Return renderlist.AddFirst( new_block )
		EndIf		
		
		'check in case the value should be inserted at the head of the list
		Local cursor:TLink = renderlist.FirstLink()
		Local cmp = 0
		cmp = cursor.compare( new_block )
		If cmp < 0
			'even if the list has only one element, this logic works.
			'TList is a cyclic doubly-linked list; thus, <TList>._head._pred == <TList>._head
			Return renderlist.InsertBeforeLink( new_block, cursor )
		EndIf
		
		'loop through the whole renderlist
		For counter = 0 to block_count - 1
			If cmp > 0
				'if the value to be inserted should come "on top of"/after the cursor link, insert it there
				Return renderlist.InsertAfterLink( new_block, cursor )
			ElseIf cmp = 0
				'or, if the value to be inserted has the same location as the cursor, update (replace) it
				cursor.value.clone( value )
				Return cursor
			EndIf
			'advance the cursor
			cursor = cursor.NextLink()
			cmp = cursor.compare( new_block )
		Next
		
	EndMethod
	
  '_________________________________________________________________________
	Rem
		Delete
		These should now be constant-time operations, using the backref array. No search has to be performed,
		not on the space array, nor on the renderlist. Backref provides all the info needed.
		the computational cost of maintaining the backref array is nil. Memory is the cost of this improvement;
		specifically, the cost of storing extra per-position data, but not much. Just a pointer array.
	EndRem
	Method delete( target:iso_coord )
		'This method is similar to a "quick format" for a hard drive. The renderlist is like a file table.
		'I simply stop keeping track of a block; later on, if a new block comes to take up that space, I simply
		'replace it.
		If target.in_bounds( size ) And filled_at( target )
			backref_at( target ).Remove()
			'space_at( target ) = ? (old block data retained)
			filled_at( target ) = False
			block_count :- 1
		EndIf
	EndMethod
	'Delete Space
	'applies Delete to a volume
	Method delete_space( target:iso_coord, target_size:iso_coord )
		
		'constrain volume to only "in_bounds" targets (for efficiency)
		Local constrained_target:iso_coord = target.copy()
		Local constrained_target_size:iso_coord = target_size.copy()
		If constrained_target.x < 0 Then constrained_target.x = 0
		If constrained_target.y < 0 Then constrained_target.y = 0
		If constrained_target.z < 0 Then constrained_target.z = 0
		If constrained_target.x + constrained_target_size.x > size.x Then constrained_target_size.x = size.x - constrained_target.x
		If constrained_target.y + constrained_target_size.y > size.y Then constrained_target_size.y = size.y - constrained_target.y
		If constrained_target.z + constrained_target_size.z > size.z Then constrained_target_size.z = size.z - constrained_target.z
		
		'loop through the constrained volume, deleting everything in your path! buah-hahahaha! >:D
		For cursor.z = constrained_target.z To constrained_target_size.z - 1
			For cursor.y = constrained_target.y To constrained_target_size.y - 1
				For cursor.x = constrained_target.x To constrained_target_size.x - 1
					If filled_at( target )
						backref_at( target ).Remove()
						'space_at( target ) = ? (old block data retained)
						filled_at( target ) = False
						block_count :- 1
					EndIf
				Next
			Next
		Next
		
	EndMethod
	
  '_________________________________________________________________________
	Rem
		Resize
		since this operation is now quadratic with the block count instead of constant,
		I've decided to disable auto-incremental-resize. Instead, the user will
		manually resize the grid, much like with paint programs.
		it is now too costly of an operation to be performed in real time, I believe.
		I hope I won't come to regret this change, as the spontaneous resize was rather cool.
	EndRem
	Method resize( new_size:iso_coord )
		If Not new_size.is_invalid()
			
			'reserve space for new data
			size = new_size.copy()
			Local new_filled:Int[,,] = New Int[ size.x, size.y, size.z ]
			Local new_space:iso_block[,,] = New iso_block[ size.x, size.y, size.z ]
			Local new_renderlist:TList = New TList
			Local new_backref:TLink[,,] = New TLink[ size.x, size.y, size.z ]
			
			'make one pass through the old renderlist
			For Local iter:iso_block = EachIn renderlist
				If iter.offset.in_bounds( size )
					'this item should be kept; stick it in the new data
					filled_at_in( new_filled, iter.offset ) = True
					space_at_in( new_space, iter.offset ) = space_at( iter.offset )
					backref_at_in( new_backref, iter.offset ) = ..
						new_renderlist.AddLast( iter )
				Else
					'block falls outside the new boundary; equivalent to being deleted
					block_count :- 1
				EndIf
			Next
			
			'point to the new data
			filled = new_filled
			space = new_space
			renderlist = new_renderlist
			backref = new_backref
			
		EndIf
	EndMethod
	
  '_________________________________________________________________________
	Method copy_to_brush:iso_grid( target:iso_coord, target_size:iso_coord )
		
		Local brush:iso_grid = New iso_grid
		
		
		
		Rem
		Local new_block:iso_block
		Local result:TList = CreateList()
		
		For Local iter:iso_block = EachIn blocklist
			
			Local far_offset:iso_coord = ghost_offset.add( ghost_grid.size )	
			If ..
				iter.offset.x >= ghost_offset.x And ..
				iter.offset.y >= ghost_offset.y And ..
				iter.offset.z >= ghost_offset.z And ..
				iter.offset.x < far_offset.x And ..
				iter.offset.y < far_offset.y And ..
				iter.offset.z < far_offset.z
				
				new_block = iter.copy()
				new_block.offset = iter.offset.sub( ghost_offset )
				result.AddLast( new_block )
				
			EndIf
			
		Next
		
		Return result
		EndRem
		
		Return brush
		
	EndMethod
	
  '_________________________________________________________________________
	Method str$()
		Local s$ = "[iso_grid]~n"
		Local num = 0
		For Local iter:iso_block = EachIn blocklist
			s :+ " "+num+" "+iter.str()+"~n"			
			num :+ 1
		Next
		
		Return s
	EndMethod

	Rem
	Method calculate_bounds()
		
		bounds = New scr_coord[14]
		
		bounds[ 0] = scr_coord.Create( -8*size.y, 4*size.y )
		bounds[ 1] = scr_coord.Create( 1, 0 )
		bounds[ 2] = scr_coord.Create( 8, 4 )
		bounds[ 3] = scr_coord.Create( -8*size.y+8*size.x, 4*size.x+4*size.y )
		bounds[ 4] = scr_coord.Create( 8, -4 )
		bounds[ 5] = scr_coord.Create( -8*size.y, -8*size.z+4*size.y )
		bounds[ 6] = scr_coord.Create( 1, -8*size.z )
		bounds[ 7] = scr_coord.Create( 0, 8 )
		bounds[ 8] = scr_coord.Create( 0, -8*size.z )
		bounds[ 9] = scr_coord.Create( 0, 0 )
		'bounds[10] = scr_coord.create( 8*size.x, 4*size.x-8*size.z )
		bounds[10] = scr_coord.Create( 8*size.x+1, 4*size.x-8*size.z )
		bounds[11] = scr_coord.Create( 8*size.x+1, 4*size.x )
		bounds[12] = scr_coord.Create( -8*size.y+8*size.x+1, 4*size.x+4*size.y )
		'bounds[13] = scr_coord.create( -8*size.y+1, -8*size.z+4*size.y )
		bounds[13] = scr_coord.Create( -8*size.y, -8*size.z+4*size.y )
		
	EndMethod
	EndRem
	
EndType

Rem
'After consideration, I've decided that this class is extraneous. Instead of storing the selection grid
'in memory, I will draw the selection procedurally from the minimum amount of data
'(specifically, the offset of the cursor, and the size of the selection grid)
'this will be slightly more computationally expensive to draw, but resizing the selection will be a
'constant-time operation, which was my goal. Hopefully with the new insert_subgrid method, I will see
'fewer slowdowns when selecting, copying and pasting.
Type iso_ghost_grid
	
	Field size:iso_coord      'dimensions of grid
	Field facelist:TList      'list of [iso_face] objects
	Field agents:iso_coord[6] 'agents for procedural facelist generation
	
	Method New()
		
		size = New iso_coord
		facelist = CreateList()
		
	EndMethod
	
	Function Create:iso_ghost_grid( initial_size:iso_coord )
		
		Local new_ghost:iso_ghost_grid = New iso_ghost_grid
		new_ghost.resize( initial_size )
		
		Return new_ghost
		
	EndFunction
	
	Method resize( new_size:iso_coord )
		
		'ensure new_size is nonzero for all dimensions
		If (new_size.x > 0) And (new_size.y > 0) And (new_size.z > 0)
			
			size = new_size.copy()			
			facelist.Clear()
			
			Local iso:iso_coord = New iso_coord
			
			iso.z = 0
			For iso.x = 0 To (size.x - 1)
				For iso.y = 0 To (size.y - 1)				
					facelist.AddLast( iso_face.Create( FACE_XY_MINUS, iso ))
				Next
			Next
			iso.x = 0
			For iso.y = 0 To (size.y - 1)
				For iso.z = 0 To (size.z - 1)				
					facelist.AddLast( iso_face.Create( FACE_YZ_MINUS, iso ))
				Next
			Next
			iso.y = 0
			For iso.x = 0 To (size.x - 1)
				For iso.z = 0 To (size.z - 1)				
					facelist.AddLast( iso_face.Create( FACE_XZ_MINUS, iso ))
				Next
			Next
			
			iso.z = (size.z - 1)
			For iso.x = 0 To (size.x - 1)
				For iso.y = 0 To (size.y - 1)				
					facelist.AddLast( iso_face.Create( FACE_XY_PLUS, iso ))
				Next
			Next
			iso.x = (size.x - 1)
			For iso.y = 0 To (size.y - 1)
				For iso.z = 0 To (size.z - 1)				
					facelist.AddLast( iso_face.Create( FACE_YZ_PLUS, iso ))
				Next
			Next
			iso.y = (size.y - 1)
			For iso.x = 0 To (size.x - 1)
				For iso.z = 0 To (size.z - 1)				
					facelist.AddLast( iso_face.Create( FACE_XZ_PLUS, iso ))
				Next
			Next
			
			facelist.Sort()
			
		EndIf
		
	EndMethod
	
EndType
EndRem

