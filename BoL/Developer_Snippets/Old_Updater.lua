local Version = 1
local Auto_Update = true

class 'General'
function General:__init()
  if Auto_Update then
    self:OldUpdater()
  end
end

function General:OldUpdater()
	--[[Script: https://raw.githubusercontent.com/LegendBot/LegendSeries/master/BoL/LegendSeries.lua]]
	--[[Version: raw.github.com/LegendBot/LegendSeries/master/BoL/Version/LegendSeries.version]]
	local ServerResult = GetWebResult("raw.github.com","/LegendBot/LegendSeries/master/BoL/Version/LegendSeries.version")
	if ServerResult then
		ServerVersion = tonumber(ServerResult)
		if Version < ServerVersion then
			Print("A new version is available: v"..ServerVersion..". Attempting to download now.")
			DelayAction(function() DownloadFile("https://raw.githubusercontent.com/LegendBot/LegendSeries/master/BoL/LegendSeries.lua".."?rand"..math.random(1,9999), SCRIPT_PATH..GetCurrentEnv().FILE_NAME, function() Print("Successfully downloaded the latest version: v"..ServerVersion..".") end) end, 2)
		else
			Print("You are running the latest version: v"..Version..".")
		end
	else
		Print("Error finding server version.")
	end
end

function Print(m)
	print("<font color=\"#FF0000\">[LegendSeries]</font> <font color=\"#FFFFFF\">"..m.."</font>")
end
