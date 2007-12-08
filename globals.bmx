Rem
_______________________________
Project isoblox
This is a BlitzMax source file
Author is Tyler W.R. Cole
Started on September 30th, 2006
_______________________________
EndRem

Strict

Import BRL.Timer
Import BRL.Audio

Const PROJECT_VERSION$ = "alpha 4"
Const CONFIG_FILENAME$ = "isoblox.cfg"

Global SCREEN_WIDTH  = 350
Global SCREEN_HEIGHT = 350
Global GRID_X = 16
Global GRID_Y = 16
Global GRID_Z = 16
Global SOUND = True
Global GRID_MAJOR_INTERVAL = 8
Global ORIGIN_X = SCREEN_WIDTH / 2
Global ORIGIN_Y = SCREEN_HEIGHT / 2

Global program_timer:TTimer = CreateTimer( 10 )
Global program_timer_ticks

Global MOUSE_LAST_X = 0
Global MOUSE_LAST_Y = 0

Global cursor_blink_timer:TTimer = CreateTimer( 300 )
Global ALPHA_BLINK_1#
Global ALPHA_BLINK_2#

Const COUNT_LIBS   = 6
Const COUNT_BLOCKS = 77
Global spritelib_blocks:TImage[ COUNT_LIBS, COUNT_BLOCKS ]
Global spritelib_blocks_map:TPixmap
Const COUNT_GROUPS = 6
Global group_starting_index[] = [ 0, 1, 13, 37, 61, 69 ]

Const COUNT_FACE_LIBS = 6
Const COUNT_FACES     = 8
Global spritelib_faces:TImage[ COUNT_FACE_LIBS, COUNT_FACES ]
Global spritelib_faces_map:TPixmap

Const LIB_BLOCKS     = 0
Const LIB_WIREFRAMES = 1
Const LIB_OUTLINES   = 2
Const LIB_SHADOWS_XY = 3
Const LIB_SHADOWS_YZ = 4
Const LIB_SHADOWS_XZ = 5

Const CURSOR_BASIC  = 0
Const CURSOR_BRUSH  = 1
Const CURSOR_SELECT = 2

Const ROTATE_X_MINUS = 0
Const ROTATE_Y_MINUS = 1
Const ROTATE_Z_MINUS = 2
Const ROTATE_X_PLUS  = 3
Const ROTATE_Y_PLUS  = 4
Const ROTATE_Z_PLUS  = 5
Global rotation_map[ 6, COUNT_BLOCKS ]

Const CHAR_HEIGHT = 9
Const CHAR_WIDTH  = 8
Const MAX_STATUS_MESSAGE_COUNT = 8
Const TOKEN_DARKGRAY$ = "$D"
Const TOKEN_BLACK$    = "$B"
Const TOKEN_RED$      = "$r"
Const TOKEN_GREEN$    = "$g"
Const TOKEN_BLUE$     = "$b"
Const TOKEN_YELLOW$   = "$y"
Const TOKEN_CYAN$     = "$c"
Const TOKEN_PURPLE$   = "$p"
Global spritelib_font:TImage[ 128 ]
Global spritelib_font_map:TPixmap
Const test_str$ = "$B !~q#$%'()*+$D,-./01234567$r89:;<=>?@ABC$gDEFGHIJKLMNO$bPQRSTUVWXYZ[$y\]^_`abcdefg$chijklmnopqrs$ptuvwxyz{|}~~"

Global high_click:TSound
Global low_click:TSound

