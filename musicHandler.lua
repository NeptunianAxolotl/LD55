-- Custom music handler because Beacon515L is a madman

local loopDefs = {
    ["A"] =
      {
        ["path"] = "resources/sounds/music/LD55_-_LOOP_A.ogg",
        ["tensionLow"] = -1,
        ["tensionHigh"] = 1,
        ["duration"] = 31.5
    },
    ["B"] =
      {
        ["path"] = "resources/sounds/music/LD55_-_LOOP_B.ogg",
        ["tensionLow"] = 1,
        ["tensionHigh"] = 2,
        ["duration"] = 7.5
    },
      ["C"] =
      {
        ["path"] = "resources/sounds/music/LD55_-_LOOP_C.ogg",
        ["tensionLow"] = 2,
        ["tensionHigh"] = 3,
        ["duration"] = 12
    }
  }
  
  local transitionDefs =
  {
      ["AB"] = {
        ["path"] = "resources/sounds/music/LD55_-_A_TO_B.ogg",
        ["duration"] = 3.0
      },
      ["BC"] = {
        ["path"] = "resources/sounds/music/LD55_-_B_TO_C.ogg",
        ["duration"] = 3.0
      },
      ["CA"] = {
        ["path"] = "resources/sounds/music/LD55_-_C_TO_A.ogg",
        ["duration"] = 6.0
        }
  }

local activeTrack = "A"
local alternateBank = false

-- set this to cause the music logic to transition through tracks
-- range is 0 through 3
bgmTension = 0

local self = {}
local api = {}
local cosmos

local musicBanks = {
  ["A"] = {},
  ["B"] = {}
}

local bgmTimer = 0

function loadSounds()
  for k, v in pairs(loopDefs) do
      musicBanks["A"][k] = love.audio.newSource(v["path"],"static")
      musicBanks["B"][k] = love.audio.newSource(v["path"],"static")
  end
  for k, v in pairs(transitionDefs) do
      musicBanks["A"][k] = love.audio.newSource(v["path"],"static")
      musicBanks["B"][k] = love.audio.newSource(v["path"],"static")
  end
  
end

function cueTrack(which)
  activeTrack = which
  musicBanks[alternateBank and "A" or "B"][activeTrack]:play()
  alternateBank = not alternateBank
  if (activeTrack:len() == 2) then
    bgmTimer = transitionDefs[which]["duration"]
  else
    bgmTimer = loopDefs[which]["duration"]
  end
end

function api.StopCurrentTrack(delay)
	-- implement as mute, not stop
end

function api.SetCurrentTrackFadeTime(fadeTime)
	-- implement as volume manipulation, not stop
end

function api.Update(dt)
	bgmTimer = bgmTimer - dt
  if bgmTimer < 0 then
    bgmTimer = 0
  end
  if bgmTimer == 0 then
    -- Transition case - cue the next loop based on tension value
    if (activeTrack:len() == 2) then
      for k, v in pairs(loopDefs) do
        if bgmTension > v["tensionLow"] and bgmTension <= v["tensionHigh"] then
          cueTrack(k)
          break
        end
      end
    -- Loop case - within limits of current loop
    elseif bgmTension > loopDefs[activeTrack]["tensionLow"] and bgmTension <= loopDefs[activeTrack]["tensionHigh"] then
        cueTrack(activeTrack)
    -- Loop case - below limits of current loop
    elseif bgmTension < loopDefs[activeTrack]["tensionLow"] then
        if activeTrack == "B" or activeTrack == "C" then
          cueTrack("CA");
        else 
          cueTrack(activeTrack);
        end
    -- Loop case(s) - above limits of current loop
    elseif activeTrack == "A" then
        cueTrack("AB");
    elseif activeTrack == "B" then
        cueTrack("BC");
    else 
        cueTrack(activeTrack);
    end
  end
end

function api.Initialize(newCosmos)
	self = {}
	cosmos = newCosmos
	
	volumeEct = cosmos.GetMusicVolume()
	loadSounds()
	cueTrack("A")
end


-- DEBUGGING - DO NOT FOR THE LOVE OF GOD LEAVE THIS IN
function love.keyreleased( key )
	if key == "j" then
		bgmTension = bgmTension + 1
	elseif key == "k" then
		bgmTension = bgmTension - 1
	end
end

return api