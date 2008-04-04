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
- optimize copy_volume() using backref+renderlist to skip the empty parts of the selected volume,
  and to dump out early when blocks start appearing outside the selected volume.
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
	
  'New______________________________________________________________________
	Method New()
		'reserve smallest amount of memory possible for a new iso_grid object
		size = iso_coord.create( 1, 1, 1 )
		filled = New Int[ 1, 1, 1 ]
		space = New iso_block[ 1, 1, 1 ]
		renderlist = New TList
		backref = New TLink[ 1, 1, 1 ]
		block_count = 0
	EndMethod
	
  'Create___________________________________________________________________
	Function create:iso_grid( initial_size:iso_coord )
		'return a new, blank iso_grid of given initial size
		Local new_space:iso_grid = New iso_grid
		new_space.resize( initial_size )
		Return new_space
	EndFunction
	
  'Is Empty_________________________________________________________________
	Method is_empty()
		Return block_count
	EndMethod
	
  'Internal Retrieval (set of 3)____________________________________________
	Method space_at:iso_block( v:iso_coord )
		Return space[ v.x, v.y, v.z ]
	EndMethod
	Method filled_at:Int( v:iso_coord )
		Return filled[ v.x, v.y, v.z ]
	EndMethod
	Method backref_at:TLink( v:iso_coord )
		Return backref[ v.x, v.y, v.z ]
	EndMethod
	
  'Generalized Retrieval (set of 3)_______________________________________
	Function space_at_in:iso_block( space:iso_block[,,], v:iso_coord )
		Return space[ v.x, v.y, v.z ]
	EndFunction 
	Function filled_at_in:Int( filled:Int[,,], v:iso_coord )
		Return filled[ v.x, v.y, v.z ]
	EndFunction 
	Function backref_at_in:TLink( backref:TLink[,,], v:iso_coord )
		Return backref[ v.x, v.y, v.z ]
	EndFunction 
		
  'Insert___________________________________________________________________
	'Should this method have a selector for over-write?
	'for now it will insert a new block at a location, or over-write existing.
	'the location for the insert must be provided inside the object's [offset] field
	Method insert( new_block_raw:iso_block )
		If new_block_raw.offset.in_bounds( size )
			
			Local new_block:iso_block = new_block_raw.copy()
			
			'trivial, empty list case
			If renderlist.IsEmpty()
				Return renderlist.AddFirst( new_block )
			EndIf		
			
			Local main_cursor:TLink = renderlist.FirstLink()
			Local main_block:iso_block
			Local cmp
			
			'traverse the renderlist and insert the new block wherever it's supposed to go
			While main_cursor <> Null
				main_block = iso_block( main_cursor.Value() )
				
				cmp = main_block.compare( new_block )
				
				If cmp < 0
					
					If Not filled_at( new_block.offset )
						block_count :+ 1
					EndIf
					
					filled_at( new_block.offset ) = True
					space_at( new_block.offset ) = new_block
					backref_at( new_block.offset ) = renderlist.InsertBeforeLink( new_block, main_cursor )
					
					Return
					
				ElseIf cmp = 0
					
					main_block.clone( new_block )
					
				EndIf
				
				main_cursor = main_cursor.NextLink()
			EndWhile
			
			'just insert the block at the end
			If Not filled_at( new_block.offset )
				block_count :+ 1
			EndIf
			'insert
			filled_at( new_block.offset ) = True
			space_at( new_block.offset ) = new_block
			backref_at( new_block.offset ) = renderlist.AddLast( new_block )
			
		EndIf
	EndMethod
	
	'Insert Brush_____________________________________________________________
	'Should this method have an option for over-write?
	' (will assume no option, and default to over-write for now)
	'Will only insert blocks with valid locations.
	' Locations are given as the offset of the subgrid origin added to the local offset of the block in question
	'This method is going to be heavily re-worked and optimized, so it may not be pretty.
	Method insert_brush( target:iso_coord, brush:iso_grid )
		
		If brush.is_empty() Then Return
		
		If is_empty()
			'copy the entire brush into this iso_grid
			
			Return
		EndIf
		
		Local new_block:iso_block
		Local main_cursor:TLink = renderlist.FirstLink()
		Local brush_cursor:TLink = brush.renderlist.FirstLink()
		Local main_block:iso_block = iso_block( main_cursor.Value() )
		Local brush_block:iso_block = iso_block( brush_cursor.Value() )
		
		Local cmp = main_block.compare( brush_block )
		
		While main_cursor <> Null
			main_block = iso_block( main_cursor.Value() )
			
			'perform any necessary insertions from the brush
			While brush_cursor <> Null
				brush_block = iso_block( brush_cursor.Value() )
				
				new_block = brush_block.copy()
				new_block.offset = brush_block.offset.add( target )
				
				If new_block.offset.in_bounds( size )
					
					cmp = main_block.compare( new_block )
					
					If cmp < 0
						
						If Not filled_at( new_block.offset )
							block_count :+ 1
						EndIf
						
						filled_at( new_block.offset ) = True
						space_at( new_block.offset ) = new_block
						backref_at( new_block.offset ) = renderlist.InsertBeforeLink( new_block, main_cursor )
						
					ElseIf cmp = 0
						
						space_at( new_offset ).clone( new_block )
						
					Else
						
						Exit While
						
					EndIf
					
				EndIf
				
				brush_cursor = brush_cursor.NextLink()
			EndWhile
			
			main_cursor = main_cursor.NextLink()
		EndWhile
		
		'perform any tail-end insertions
		While brush_cursor <> Null
			brush_block = iso_block( brush_cursor.Value() )
				
				new_block = brush_block.copy()
				new_block.offset = brush_block.offset.add( target )
				
				If new_block.offset.in_bounds( size )
					
					block_count :+ 1
					filled_at( new_block.offset ) = True
					space_at( new_block.offset ) = new_block
					backref_at( new_block.offset ) = renderlist.AddLast( new_block )
					
				EndIf
				
			brush_cursor = brush_cursor.NextLink()
		EndWhile
		
	EndMethod
	
  'Delete___________________________________________________________________
	'These should now be constant-time operations, using the backref array. No search has to be performed,
	'not on the space array, nor on the renderlist. Backref provides all the info needed.
	'the computational cost of maintaining the backref array is nil. Memory is the cost of this improvement;
	'specifically, the cost of storing extra per-position data, but not much. Just a pointer array.
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
	
	'Delete Volume____________________________________________________________
	Method delete_volume( target:iso_coord, target_size:iso_coord )
		
		Local cursor:iso_coord = New iso_coord
		
		'constrain volume to only "in_bounds" targets (for efficiency)
		Local constrained_target:iso_coord = target.copy()
		Local constrained_target_size:iso_coord = target_size.copy()
		If constrained_target.x < 0 Then ..
			constrained_target.x = 0
		If constrained_target.y < 0 Then ..
			constrained_target.y = 0
		If constrained_target.z < 0 Then ..
			constrained_target.z = 0
		If constrained_target.x + constrained_target_size.x > size.x Then ..
			constrained_target_size.x = size.x - constrained_target.x
		If constrained_target.y + constrained_target_size.y > size.y Then ..
			constrained_target_size.y = size.y - constrained_target.y
		If constrained_target.z + constrained_target_size.z > size.z Then ..
			constrained_target_size.z = size.z - constrained_target.z
		
		'loop through the constrained volume, deleting everything in your path! buah-hahahaha! >:D
		For cursor.z = constrained_target.z To constrained_target_size.z - 1
			For cursor.y = constrained_target.y To constrained_target_size.y - 1
				For cursor.x = constrained_target.x To constrained_target_size.x - 1
					If filled_at( cursor )
						backref_at( cursor ).Remove()
						'space_at( cursor ) = ? (old block data retained)
						filled_at( cursor ) = False
						block_count :- 1
					EndIf
				Next
			Next
		Next
		
	EndMethod
	
  'Resize________________________________________________________________
	'Resize
	'since this operation is now quadratic with the block count instead of constant,
	'I've decided to disable auto-incremental-resize. Instead, the user will
	'manually resize the grid, much like with paint programs.
	'it is now too costly of an operation to be performed in real time, I believe.
	'I hope I won't come to regret this change, as the spontaneous resize was rather cool.
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
	
  'Copy Volume______________________________________________________________
	'This method could be optimized a tad, using backref
	Method copy_volume:iso_grid( target:iso_coord, target_size:iso_coord )
		
		Local brush:iso_grid = New iso_grid
		brush.resize( target_size )
		Local cursor:iso_coord = New iso_coord
		Local brush_offset:iso_coord = New iso_coord
		
		'constrain volume to only "in_bounds" targets (for efficiency)
		Local constrained_target:iso_coord = target.copy()
		Local constrained_target_size:iso_coord = target_size.copy()
		If constrained_target.x < 0 Then ..
			constrained_target.x = 0
		If constrained_target.y < 0 Then ..
			constrained_target.y = 0
		If constrained_target.z < 0 Then ..
			constrained_target.z = 0
		If constrained_target.x + constrained_target_size.x > size.x Then ..
			constrained_target_size.x = size.x - constrained_target.x
		If constrained_target.y + constrained_target_size.y > size.y Then ..
			constrained_target_size.y = size.y - constrained_target.y
		If constrained_target.z + constrained_target_size.z > size.z Then ..
			constrained_target_size.z = size.z - constrained_target.z
		
		'loop through the constrained volume, copying blocks into the brush
		For cursor.z = constrained_target.z To constrained_target_size.z - 1
			For cursor.y = constrained_target.y To constrained_target_size.y - 1
				For cursor.x = constrained_target.x To constrained_target_size.x - 1
					'if this grid contains a block
					If filled_at( cursor )
						'translate the cursor offset into local brush space
						brush_offset = cursor.sub( constrained_target )
						'insert a copy of this block into the brush grid
						brush.block_count :+ 1
						brush.filled_at( brush_offset ) = True
						brush.space_at( brush_offset ) = space_at( cursor ).copy()
						brush.space_at( brush_offset ).offset = brush_offset
						brush.backref_at( brush_offset ) = brush.renderlist_insert( brush.space_at( brush_offset ))
					EndIf
				Next
			Next
		Next
		
		'return the new subgrid
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


