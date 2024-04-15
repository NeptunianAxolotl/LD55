
local globals = {
	BACK_COL = {78/255, 70/255, 90/255},
	LINE_COL = {0.95,0.95,0.9},
	LINE_HIGHLIGHT_COL = {0.98, 1, 0.6},
	POINT_TUTORIAL_COL = {0.98, 0.2, 0.6},
	RED_COL  = {0.95,0.2,0.2},
	
	PANEL_COL = {78/255, 70/255, 90/255},
	PANEL_DISABLE_COL = {78/255, 70/255, 90/255},
	PANEL_FLASH_COL = {78/255 + 0.1, 70/255, 90/25},
	PANEL_HIGHLIGHT_COL = {0.95,0.95,0.9},
	OUTLINE_COL = {0.95,0.2,0.9},
	OUTLINE_DISABLE_COL = {5/255, 5/255, 4/255},
	OUTLINE_FLASH_COL = {0.95,0.5,0.9},
	OUTLINE_HIGHLIGHT_COL = {0.2,0.5,0.9},
	AFFINITY_COLOR = {0.9,0.5,0.9},
	
	TEXT_MENU_COL       = {0, 0, 0},
	MENU_COL            = {78/255, 70/255, 90/255},
	MENU_OUTLINE_COL    = {0, 0, 0},
	
	TEXT_DISABLE_COL    = {0.5, 0.5, 0.5},
	TEXT_FLASH_COL      = {0.73, 0.73, 0.75},
	TEXT_HIGHLIGHT_COL  = {0.73, 0.73, 0.75},
	TEXT_COL            = {0.83, 0.83, 0.87},
	FLOATING_TEXT_COL   = {0.95,0.95,0.9},
	
	BUTTON_FLASH_PERIOD = 0.6,
	
	SHAPE_LINE_FADE_MULT = 0.1,
	SHAPE_LINE_ORPHAN_FADE_MULT = 2,
	CAN_REFRESH_ELEMENT = false,
	SPEED_RAMP_UP = 0.025,
	
	CIRCLE_PUSH_FORCE = 650,
	CIRCLE_PUSH_EXPONENT = 1.8,
	PUSH_RANGE_EXTRA = 180,
	
	AFFINITY_MAX_RADIUS = 1800,
	WORLD_RADIUS = 2000,
	SPEEDY_ELEMENT_RADIUS = 50,
	PLAYER_MOVE_RADIUS = 1950,
	CAMERA_BOUND = 1600,
	ENEMY_SPAWN_RADIUS = 3000,
	AFFINITY_RADIUS = 1200,
	ENEMY_SPAWN_WIGGLE = 250,
	PLAYER_SPEED = 220,
	SPEED_SCALING = 0.1,
	BASE_SHAPE_POWER = 8,
	BASE_PLAYER_HEALTH = 50,
	BASE_DRAW_RANGE= 260,
	
	CLICK_RADIUS = 20,
	CLICK_RECENT_RADIUS = 6,
	
	FREE_UPGRADES = false,
	
	MASTER_VOLUME = 1,
	MUSIC_VOLUME = 0.4,
	DEFAULT_MUSIC_DURATION = 174.69,
	CROSSFADE_TIME = 0,
	
	MOUSE_SCROLL_MULT = 1,
	KEYBOARD_SCROLL_MULT = 1.4,
	
	MOUSE_EDGE = 8,
	MOUSE_SCROLL = 1200,
	CAMERA_SPEED = 800,
	
	PHYSICS_SCALE = 300,
	LINE_SPACING = 36,
	INC_OFFSET = -15,
	
	WORLD_WIDTH = 5400,
	WORLD_HEIGHT = 3000,
	
	GRAVITY_MULT = 900,
	SPEED_LIMIT = 1800,
	TURN_MULT = 175,
	
	LINE_LENGTH = 12000,
	
	BOOK_SCALE = 0.075,
	
	RANDOM_TESTING_ELEMENTS = 0,
	ENEMY_SPAWN_MULT = 1,
	ZOOM_OUT = 1,
	SHAPE_IDLE_DRAIN_MULT = 1,
	ACT_IN_GAME_OVER = false,
	
	GAME_SPEED = false,
	
	DEBUG_UI              = false,
	DEBUG_PRINT_LINE      = false,
	DEBUG_PRINT_CIRCLE    = false,
	DEBUG_SHAPES          = false,
	DEBUG_CIRCLE_POINTS   = false,
	DEBUG_PRINT_CLICK_POS = false,
	DEBUG_PRINT_POINT     = false,
	DEBUG_POINT_INTERSECT = false,
	PRINT_SHAPE_FOUND     = false,
	DEBUG_SPECIAL_ANGLES  = false,
	
	-- Enums
	LINE = 1,
	CIRCLE = 2,
}

return globals