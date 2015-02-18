class 'General'
function General:__init()
  self:OldLibs()
end

function General:OldLibs()
	local RequiredLibs = {
		["Prodiction"] = "https://bitbucket.org/Klokje/public-klokjes-bol-scripts/raw/master/Test/Prodiction/Prodiction.lua",
		["VPrediction"] = "https://raw.githubusercontent.com/Ralphlol/BoLGit/master/VPrediction.lua",
		["SxOrb"] = "https://raw.githubusercontent.com/Superx321/BoL/master/common/SxOrbWalk.lua",
	}
	for LibName, LibUrl in pairs(RequiredLibs) do
		if FileExist(LIB_PATH..LibName..".lua") then
			require(LibName)
		else
			Downloading = true
			Print("Attempting to Download "..LibName)
			DownloadFile(LibUrl,LIB_PATH..LibName..".lua",function() Print("Downloaded "..LibName.." successfully") end)
		end
	end
	if Downloading then Print("Once all Libraries are finished downloading, press F9 twice to reload.") return else Print("You have all current Libraries.") end
end

function Print(m)
	print("<font color=\"#FF0000\">[LegendSeries]</font> <font color=\"#FFFFFF\">"..m.."</font>")
end
