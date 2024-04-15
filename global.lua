
local globals = {
	BACK_COL = {78/255, 70/255, 90/255},
	LINE_COL = {0.95,0.95,0.9},
	RED_COL  = {0.95,0.2,0.2},
	
	PANEL_COL = {78/255, 70/255, 90/255},
	PANEL_DISABLE_COL = {78/255, 70/255, 90/255},
	PANEL_FLASH_COL = {78/255 + 0.1, 70/255, 90/25},
	PANEL_HIGHLIGHT_COL = {0.95,0.95,0.9},
	OUTLINE_COL = {0.95,0.2,0.9},
	OUTLINE_DISABLE_COL = {5/255, 5/255, 4/255},
	OUTLINE_FLASH_COL = {0.95,0.5,0.9},
	OUTLINE_HIGHLIGHT_COL = {0.2,0.5,0.9},
	
	TEXT_MENU_COL       = {0, 0, 0},
	MENU_COL            = {78/255, 70/255, 90/255},
	MENU_OUTLINE_COL    = {0, 0, 0},
	
	TEXT_DISABLE_COL    = {0.5, 0.5, 0.5},
	TEXT_FLASH_COL      = {0.73, 0.73, 0.75},
	TEXT_HIGHLIGHT_COL  = {0.73, 0.73, 0.75},
	TEXT_COL            = {0.73, 0.73, 0.75},
	
	BUTTON_FLASH_PERIOD = 0.6,
	
	WORLD_RADIUS = 2000,
	CAMERA_BOUND = 1700,
	ENEMY_SPAWN_RADIUS = 3400,
	PLAYER_SPEED = 30,
	
	SHAPE_FADE_MULT = 0.1,
	SHAPE_BEFORE_FADE_MULT = 1.5,
	CAN_REFRESH_ELEMENT = false,
	
	MASTER_VOLUME = 0.05,
	MUSIC_VOLUME = 0.02,
	DEFAULT_MUSIC_DURATION = 174.69,
	CROSSFADE_TIME = 0,
	
	MOUSE_SCROLL_MULT = 0,
	KEYBOARD_SCROLL_MULT = 1,
	
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
	
	ACT_IN_GAME_OVER = false,
	
	DEBUG_PRINT_CLICK_POS = false,
	DEBUG_PRINT_POINT     = false,
	DEBUG_PRINT_LINE      = true,
	DEBUG_PRINT_CIRCLE    = true,
	DEBUG_POINT_INTERSECT = false,
	PRINT_SHAPE_FOUND     = false,
	DEBUG_SPECIAL_ANGLES  = false,
	
	-- Enums
	LINE = 1,
	CIRCLE = 2,
}

return globals