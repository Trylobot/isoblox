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
- the above optimization would also allow me to forgo the Sort() at the bottom, just before the return.
- also optimize delete_volume() in the same way
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
	
  'New______________________________________________________________________
	Method New()
		'this method really shouldn't be called directly, as it does not return a grid ready for use.
		size = iso_coord.create( -1, -1, -1 )
		block_count = -1
	EndMethod
	
  'Create___________________________________________________________________
	Function create:iso_grid( initial_size:iso_coord )
		Local new_grid:iso_grid = New iso_grid
		new_grid.size = initial_size.copy()
		new_grid.space = New iso_block[ new_grid.size.x, new_grid.size.y, new_grid.size.z ]
		new_grid.filled = New Int[ new_grid.size.x, new_grid.size.y, new_grid.size.z ]
		new_grid.renderlist = CreateList()
		new_grid.backref = New TLink[ new_grid.size.x, new_grid.size.y, new_grid.size.z ]
		new_grid.block_count = 0
		Return new_grid
	EndFunction
	
	'Assign___________________________________________________________________
	'important note: this method assigns "by reference"
	Method assign( source:iso_grid )
		size = source.size
		space = source.space
		filled = source.filled
		renderlist = source.renderlist
		backref = source.backref
		block_count = source.block_count
	EndMethod
	
  'Is Empty_________________________________________________________________
	Method is_empty()
		Return block_count
	EndMethod
	
  'Internal Retrieval (set of 3)____________________________________________
	Method get_space:iso_block( v:iso_coord )
		Return space[ v.x, v.y, v.z ]
	EndMethod
	Method get_filled:Int( v:iso_coord )
		Return filled[ v.x, v.y, v.z ]
	EndMethod
	Method get_backref:TLink( v:iso_coord )
		Return backref[ v.x, v.y, v.z ]
	EndMethod
	
	'Internal Assignment (set of 3)__________________________________________
	Method set_space( v:iso_coord, new_block:iso_block )
		space[ v.x, v.y, v.z ] = new_block
	EndMethod
	Method set_filled( v:iso_coord, new_fill_value% )
		filled[ v.x, v.y, v.z ] = new_fill_value
	EndMethod
	Method set_backref( v:iso_coord, new_link:TLink )
		backref[ v.x, v.y, v.z ] = new_link
	EndMethod
	
  'Insert Block_____________________________________________________________
	'Should this method have a selector for over-write?
	'for now it will insert a new block at a location, or over-write existing.
	'the location for the insert must be provided inside the object's [offset] field
	Method insert_block%( new_block_raw:iso_block )
		If new_block_raw.offset.in_bounds( size )
			Local new_block:iso_block = new_block_raw.copy()
			
			'trivial, empty grid case
			If is_empty()
				'insert the block immediately and return
				block_count :+ 1
				set_filled( new_block.offset, True )
				set_space( new_block.offset, new_block )
				set_backref( new_block.offset, renderlist.AddFirst( new_block ))
				Return 1
			EndIf		
			
			Local main_cursor:TLink = renderlist.FirstLink()
			Local main_block:iso_block
			Local cmp
			
			'traverse the renderlist and insert the new block wherever it's supposed to go
			While main_cursor <> Null
				main_block = iso_block( main_cursor.Value() )
				cmp = main_block.compare( new_block )
				If cmp < 0
					If Not get_filled( new_block.offset )
						block_count :+ 1
					EndIf
					set_filled( new_block.offset, True )
					set_space( new_block.offset, new_block )
					set_backref( new_block.offset, renderlist.InsertBeforeLink( new_block, main_cursor ))
					Return 1
				ElseIf cmp = 0
					main_block.clone( new_block )
				EndIf
				main_cursor = main_cursor.NextLink()
			EndWhile
			
			'just insert the block at the end
			If Not get_filled( new_block.offset )
				block_count :+ 1
			EndIf
			'insert
			set_filled( new_block.offset, True )
			set_space( new_block.offset, new_block )
			set_backref( new_block.offset, renderlist.AddLast( new_block ))
			Return 1
		Else
			Return 0
		EndIf
	EndMethod
	
	'Insert Brush_____________________________________________________________
	'Should this method have an option for over-write?
	' (will assume no option, and default to over-write for now)
	'Will only insert blocks with valid locations.
	' Locations are given as the offset of the subgrid origin added to the local offset of the block in question
	'This method is going to be heavily re-worked and optimized, so it may not be pretty.
	Method insert_brush%( target:iso_coord, brush:iso_grid )
		
		Local new_block:iso_block
		Local insertions = 0
		
		If brush.is_empty()
			Return insertions
		ElseIf is_empty()
			'copy the entire brush into this iso_grid
			'iterate in reverse through the brush's renderlist
			Local cursor:TLink = brush.renderlist.LastLink()
			While cursor <> Null
				new_block = iso_block( cursor.Value() ).copy()
				new_block.offset = new_block.offset.add( target )
				If new_block.offset.in_bounds( size )
					insert_block( new_block )
					insertions :+ 1
				EndIf
				cursor = cursor.PrevLink()
			EndWhile
			Return insertions
		EndIf
		
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
						If Not get_filled( new_block.offset )
							block_count :+ 1
						EndIf
						set_filled( new_block.offset, True )
						set_space( new_block.offset, new_block )
						set_backref( new_block.offset, renderlist.InsertBeforeLink( new_block, main_cursor ))
						insertions :+ 1
					ElseIf cmp = 0
						get_space( new_block.offset ).clone( new_block )
						insertions :+ 1
					Else
						'dump out early for efficiency
						Exit
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
					set_filled( new_block.offset, True )
					set_space( new_block.offset, new_block )
					set_backref( new_block.offset, renderlist.AddLast( new_block ))
					insertions :+ 1
				EndIf
				
			brush_cursor = brush_cursor.NextLink()
		EndWhile
		
		Return insertions
		
	EndMethod
	
  'Delete Block_____________________________________________________________
	'These should now be constant-time operations, using the backref array. No search has to be performed,
	'not on the space array, nor on the renderlist. Backref provides all the info needed.
	'the computational cost of maintaining the backref array is nil. Memory is the cost of this improvement;
	'specifically, the cost of storing extra per-position data, but not much. Just a pointer array.
	Method delete_block( target:iso_coord )
		'This method is similar to a "quick format" for a hard drive. The renderlist is like a file table.
		'I simply stop keeping track of a block; later on, if a new block comes to take up that space, I simply
		'replace it.
		If target.in_bounds( size ) And get_filled( target )
			get_backref( target ).Remove()
			'set_space( target, ? )
			set_filled( target, False )
			block_count :- 1
		EndIf
	EndMethod
	
	'Delete Volume____________________________________________________________
	'this method could be optimized, using backref (to skip the whitespaces)
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
					If get_filled( cursor )
						get_backref( cursor ).Remove()
						'set_space( cursor, ? )
						set_filled( cursor, False )
						block_count :- 1
					EndIf
				Next
			Next
		Next
		
	EndMethod
	
  'Copy Volume______________________________________________________________
	'This method can be further optimized, using backref; would allow skipping of whitespace
	Method copy_volume:iso_grid( target:iso_coord, target_size:iso_coord )
		
		Local brush:iso_grid = New iso_grid
		brush.resize( target_size )
		Local cursor:iso_coord = New iso_coord
		Local new_block:iso_block
		
		'constrain volume to only "in_bounds" targets (for loop efficiency)
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
		'note; if I could do this in the correct order, I wouldn't need to Sort() afterward!
		For cursor.z = constrained_target.z To constrained_target_size.z - 1
			For cursor.y = constrained_target.y To constrained_target_size.y - 1
				For cursor.x = constrained_target.x To constrained_target_size.x - 1
					'if this grid contains a block
					If get_filled( cursor )
						'make a copy
						new_block = get_space( cursor ).copy()
						'translate the cursor offset into local brush space
						new_block.offset = cursor.sub( constrained_target )
						'insert a copy of this block into the brush grid
						brush.block_count :+ 1
						brush.set_filled( new_block.offset, True )
						brush.set_space( new_block.offset, new_block )
						brush.set_backref( new_block.offset, brush.renderlist.AddLast( new_block ))
					EndIf
				Next
			Next
		Next
		
		'unfortunately, I necessitated the following Sort() with my above Tom-foolery.
		brush.renderlist.Sort()
		
		'return the new subgrid
		Return brush
		
	EndMethod
	
  'Resize________________________________________________________________
	'since this operation is now quadratic with the block count instead of constant,
	'I've decided to disable auto-incremental-resize. Instead, the user will
	'manually resize the grid, much like with paint programs.
	'it is now too costly of an operation to be performed in real time, I believe.
	'I hope I won't come to regret this change, as the spontaneous resize was rather cool.
	Method resize( new_size:iso_coord )
		If Not new_size.is_invalid()
			
			'reserve space for new data
			Local new_grid:iso_grid = create( new_size.copy() )
			
			'make one pass through the old renderlist
			For Local iter:iso_block = EachIn renderlist
				If iter.offset.in_bounds( size )
					'this item should be kept; stick it in the new_grid
					new_grid.set_filled( iter.offset, True )
					new_grid.set_space( iter.offset, get_space( iter.offset ))
					new_grid.set_backref( iter.offset, new_grid.renderlist.AddLast( iter ))
					new_grid.block_count :+ 1
				EndIf
			Next
			
			'point to the new data
			assign( new_grid )
			
		EndIf
	EndMethod
	
  'Rotate____________________________________________________________________________________________
	'the contents of this {iso_grid} are rotated 90 degrees in the direction specified by {operation}
	' around the center of this {iso_grid}
	'Because of my sweeping changes to the structure of iso_grid, this function will also have
	' to be completely re-worked.
	'This method could be possibly the most complicated method to date. I anticipate only the optimized
	' version of scr_to_iso being more complex.
	Method rotate( operation )
		
		'determine new size, and the translation vector to be applied at the end of the operation
		Local new_size:iso_coord = New iso_coord
		Select operation
			Case ROTATE_X_MINUS
				new_size.y = size.z
				new_size.z = size.y
			Case ROTATE_Y_MINUS
				new_size.x = size.z
				new_size.z = size.x
			Case ROTATE_Z_MINUS
				new_size.x = size.y
				new_size.y = size.x
			Case ROTATE_X_PLUS
				new_size.y = size.z
				new_size.z = size.y
			Case ROTATE_Y_PLUS
				new_size.x = size.z
				new_size.z = size.x
			Case ROTATE_Z_PLUS
				new_size.x = size.y
				new_size.y = size.x
		EndSelect
		Local old_size:iso_coord = size.copy()
		size = new_size
		
		'reserve space for new replacement data
		Local new_grid:iso_grid = create( new_size )
		
		'make one pass through the old renderlist
		Local new_block:iso_block
		For Local iter:iso_block = EachIn renderlist
			new_block = iter.copy()
			
			'rotate the sprite
			new_block.rotate( operation )
			
			'rotate the coordinates around the origin, and then translate back into positive space
			Select operation
				Case ROTATE_X_MINUS
					new_block.offset.y = -iter.offset.z + old_size.z
					new_block.offset.z =  iter.offset.y
				Case ROTATE_Y_MINUS
					new_block.offset.x = -iter.offset.z + old_size.x
					new_block.offset.z =  iter.offset.x
				Case ROTATE_Z_MINUS
					new_block.offset.x = -iter.offset.y + old_size.y
					new_block.offset.y =  iter.offset.x
				Case ROTATE_X_PLUS
					new_block.offset.y =  iter.offset.z
					new_block.offset.z = -iter.offset.y + old_size.y
				Case ROTATE_Y_PLUS
					new_block.offset.x =  iter.offset.z
					new_block.offset.z = -iter.offset.x + old_size.z
				Case ROTATE_Z_PLUS
					new_block.offset.x =  iter.offset.y
					new_block.offset.y = -iter.offset.x + old_size.x
			EndSelect
			
			new_grid.set_filled( new_block.offset, True )
			new_grid.set_space( new_block.offset, new_block )
			new_grid.set_backref( new_block.offset, new_grid.renderlist.AddLast( new_block ))
			
		Next
		
		'point to the new data
		assign( new_grid )
		'I wish the following Sort() wasn't necessary, but I just don't see a way around it.
		'After all the rotating, the blocks are just all over the place.
		renderlist.Sort()
		
	EndMethod
	
	Rem
	'Calculate Bounds____________________________________________________________________________
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
	
	'To String________________________________________________________________
	Method str$()
		Local s$ = "[iso_grid]~n"
		Local num = 0
		For Local iter:iso_block = EachIn renderlist
			s :+ " "+num+" "+iter.str()+"~n"			
			num :+ 1
		Next
		
		Return s
	EndMethod

EndType



'Generalized Retrieval (set of 3)__________________________________________
Function grid_get_space:iso_block( v:iso_coord, g:iso_grid )
	Return g.space[ v.x, v.y, v.z ]
EndFunction 
Function grid_get_filled:Int( v:iso_coord, g:iso_grid )
	Return g.filled[ v.x, v.y, v.z ]
EndFunction 
Function grid_get_backref:TLink( v:iso_coord, g:iso_grid )
	Return g.backref[ v.x, v.y, v.z ]
EndFunction 
	
'Generalized Assignment (set of 3)_________________________________________
Function grid_set_space( v:iso_coord, g:iso_grid, new_block:iso_block )
	g.space[ v.x, v.y, v.z ] = new_block
EndFunction 
Function grid_set_filled( v:iso_coord, g:iso_grid, new_fill_value% )
	g.filled[ v.x, v.y, v.z ] = new_fill_value
EndFunction 
Function grid_set_backref( v:iso_coord, g:iso_grid, new_link:TLink )
	g.backref[ v.x, v.y, v.z ] = new_link
EndFunction


