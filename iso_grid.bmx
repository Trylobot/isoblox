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
 - make resize more efficient, by analyzing previous size and changing a minimal amount of data
 - fix boundary checks
 - reconstruct the select_ghost resizing and initializing; it's fuxx0red
EndRem

Strict

Import "globals.bmx"
Import "coord.bmx"
Import "iso_block.bmx"

Rem
	March 26th, 2008
	I've decided to use a different internal data structure setup. Instead of using a list to hold
	the important data, I will instead use a 3D array. A list will still be maintained for efficient
	rendering. The following operations will be affected:
	Insert - linear with the total number of blocks (but would like it to be constant time)
	Delete - linear with the total number of blocks (but would like it to be constant time)
	Merge grids (paste) - linear with the total number of blocks (between both the grids)
	Resize - linear with the total number of blocks
	Rendering - linear with the total number of blocks
EndRem
Type iso_grid
	
	Field size:iso_coord     'dimensions of grid
	'NEW FIELDS
	Field space:iso_block[,,] '3D array of [iso_block] objects
	Field filled:Int[,,]     'one flag for each position of the grid, indicating its fill status
	Field renderlist:TList   'list of all [iso_block] objects from grid in render-order
	Field backref:TLink[,,]  '3D array of references to renderlist items. Starts with all NULL references.
	Field block_count        'total number of filled positions in the grid
	'OLD FIELDS
	'Field blocklist:TList    'list of [iso_block] objects
	'Field bounds:scr_coord[] 'array of screen coordinates, rendering kludge
	
	Method New()
		'reserve smallest amount of memory possible for a new iso_grid object
		size = iso_coord.create( 1, 1, 1 )
		filled = New Int[ 1, 1, 1 ]
		space = New iso_block[ 1, 1, 1 ]
		renderlist = New TList
		backref = New TLink[ 1, 1, 1 ]
		block_count = 0
	EndMethod
	
	Function create:iso_grid( initial_size:iso_coord )
		'return a new, blank iso_grid of given initial size
		Local new_space:iso_grid = New iso_grid
		new_space.resize( initial_size )
		Return new_space
	EndFunction
	
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
		
	Rem
		Resize
		since this operation is now quadratic with the block count instead of constant,
		I've decided to disable auto-incremental-resize. Instead, the user will
		manually resize the grid, much like with 2D paint programs.
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
		1. Should this method have a selector for over-write (will assume over-write for now)
		Only inserts blocks with valid locations; locations may be valid in the subgrid, but when added to the
		provided offset they could become invalid. So it is necessary to check each one.
	EndRem
	Method insert_subgrid( offset:iso_coord, subgrid:iso_grid )
		
		
		
	EndMethod
	
	Rem
	Method set( new_size:iso_coord, new_list:TList )
		
		If new_list.isEmpty()
			
			resize( new_size )
			
		ElseIf new_size.x > 0 And new_size.y > 0 And new_size.z > 0
			
			size = new_size.copy()
			blocklist = new_list
			blocklist.Sort()
			maintain_data_structures()
			
		EndIf
		
	EndMethod
	
	Method reduce_to_contents()
		
		Local new_offset:iso_coord = iso_coord.invalid()
		Local new_size:iso_coord = iso_coord.invalid()
		Local iter:iso_block
		
		For iter = EachIn blocklist
			If new_offset.x = -1 Or new_offset.x > iter.offset.x Then new_offset.x = iter.offset.x
			If new_offset.y = -1 Or new_offset.y > iter.offset.y Then new_offset.y = iter.offset.y
			If new_offset.z = -1 Or new_offset.z > iter.offset.z Then new_offset.z = iter.offset.z
		Next
		For iter = EachIn blocklist
			iter.offset = iter.offset.sub( new_offset )
		Next
		
		For iter = EachIn blocklist
			If new_size.x <= iter.offset.x Then new_size.x = iter.offset.x + 1
			If new_size.y <= iter.offset.y Then new_size.y = iter.offset.y + 1
			If new_size.z <= iter.offset.z Then new_size.z = iter.offset.z + 1
		Next
		resize( new_size )
		
	EndMethod
	
	Method expand_for_subvolume( sub_offset:iso_coord, sub_size:iso_coord )

		Local new_size:iso_coord = sub_size.copy()
		
		If sub_offset.x + sub_size.x > size.x Then ..
			new_size.x :+ sub_offset.x + sub_size.x - size.x
		If sub_offset.y + sub_size.y > size.y Then ..
			new_size.y :+ sub_offset.y + sub_size.y - size.y
		If sub_offset.z + sub_size.z > size.z Then ..
			new_size.z :+ sub_offset.z + sub_size.z - size.z
		
		If Not new_size.equal( sub_size )
			resize( new_size )
			Return True
		Else
			Return False
		EndIf
		
	EndMethod

	Method empty()
		
		Return blocklist.isEmpty()
		
	EndMethod
	
	Method is_filled( target:iso_coord )
		
		Return in_bounds( target ) And filled[ target.x, target.y, target.z ]
		
	EndMethod
	
	Method fill_target( target:iso_coord )
		
		If in_bounds( target ) Then filled[ target.x, target.y, target.z ] = True
		
	EndMethod
	
	Method clear_target( target:iso_coord )
		
		If in_bounds( target ) Then filled[ target.x,target.y, target.z ] = False
		
	EndMethod
	
	Method erase_at_offset( target:iso_coord )
		
		If in_bounds( target) And is_filled( target )
			
			Local iter_link:TLink = blocklist.FirstLink()
			While iter_link <> Null
				
				'if this iso_block has the target offset
				If iso_block(iter_link.Value()).offset.equal(target)
					
					iter_link.Remove()
					clear_target( target )
					Return
				
				EndIf
				
				iter_link = iter_link.NextLink()
			
			EndWhile
			
		EndIf
		
	EndMethod
	
	Method insert_new_block( new_block:iso_block )
		
		If is_filled( new_block.offset ) Then erase_at_offset( new_block.offset )
		fill_target( new_block.offset )
		blocklist.AddFirst( new_block.copy() )
		blocklist.Sort()
		
	EndMethod
	
	Method search_by_offset:iso_block( target:iso_coord )
		
		For Local iter:iso_block = EachIn blocklist
			
			If target.equal( iter.offset )
				Return iter
			EndIf
			
		Next
		
		Return iso_block.invalid()
		
	EndMethod
	
	Method intersection_with_ghost:TList( ghost_offset:iso_coord, ghost_grid:iso_ghost_grid )
		
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
		
	EndMethod
	
	Method str$()
		
		Local s$ = "[iso_grid]~n"
		Local num = 0
		For Local iter:iso_block = EachIn blocklist
			
			s :+ " "+num+" "+iter.str()+"~n"			
			num :+ 1
			
		Next
		
		Return s
		
	EndMethod
	
	Method maintain_data_structures()
		
		calculate_bounds()

		filled = New Int[ size.x, size.y, size.z ]
		
		Local iter:iso_block
		For iter = EachIn blocklist
			
			If (Not in_bounds( iter.offset )) Or is_filled( iter.offset )					
				erase_at_offset( iter.offset )					
			Else
				fill_target( iter.offset )
			EndIf
			
		Next
		
	EndMethod
	
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
			
			Rem
			
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
			
			EndRem
			
		EndIf
		
	EndMethod
	
EndType
