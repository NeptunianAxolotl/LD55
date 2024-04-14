
local globals = {
	BACK_COL = {78/255, 70/255, 90/255},
	LINE_COL = {0.95,0.95,0.9},
	TEXT_COL = {0.73, 0.73, 0.75},
	
	WORLD_RADIUS = 2000,
	PLAY_WIDTH = 2000,
	PLAY_HEIGHT = 1200,
	
	MASTER_VOLUME = 0.05,
	MUSIC_VOLUME = 0.02,
	DEFAULT_MUSIC_DURATION = 174.69,
	CROSSFADE_TIME = 0,
	CAMERA_SPEED = 1000,
	
	DEBUG_PRINT_CLICK_POS = true,
	
	PHYSICS_SCALE = 300,
	LINE_SPACING = 36,
	INC_OFFSET = -15,
	
	WORLD_WIDTH = 5400,
	WORLD_HEIGHT = 3000,
	
	GRAVITY_MULT = 900,
	SPEED_LIMIT = 1800,
	TURN_MULT = 175,
	
	LINE_LENGTH = 12000,
	
	ANGLES = {
		math.pi/2,
		math.pi/3,
		math.pi*2/5,
		math.pi/4,
	},
	
	-- Enums
	LINE = 1,
	CIRCLE = 2,
}

return globals