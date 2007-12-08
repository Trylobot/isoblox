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

Type iso_grid
	
	Field size:iso_coord     'dimensions of grid
	Field blocklist:TList    'list of [iso_block] objects
	Field filled:Int[,,]     'array of booleans, indicates status of entire grid
	Field bounds:scr_coord[] 'array of screen coordinates, for rendering optimization
	
	Method New()
		
		'reserve memory for an iso_grid of smallest size
		size = New iso_coord
		blocklist = CreateList()
		
	EndMethod
	
	Function Create:iso_grid( initial_size:iso_coord )
		
		'return a blank iso_grid of specified size
		Local new_grid:iso_grid = New iso_grid
		new_grid.resize( initial_size )

		Return new_grid
		
	EndFunction
	
	Method resize( new_size:iso_coord )
	
		If new_size.x > 0 And new_size.y > 0 And new_size.z > 0
			
			size = new_size.copy()			
			maintain_data_structures()
			
		EndIf
		
	EndMethod
	
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
	
	Method in_bounds( target:iso_coord )
		
		If ..
		target.x >= 0 And ..
		target.y >= 0 And ..
		target.z >= 0 And ..
		target.x < size.x And ..
		target.y < size.y And ..
		target.z < size.z
			Return True
		Else
			Return False
		EndIf
		
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
	
EndType

Type iso_ghost_grid
	
	Field size:iso_coord 'dimensions of grid
	Field facelist:TList 'list of [iso_face] objects
	
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
