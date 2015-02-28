local Version = 2
local Auto_Update = true
local Champions = {
	--[[Change true to false if you do not wish to use that champion.]]
	Karthus = true,
	Kennen = true,
}
local LSScriptName = GetCurrentEnv().FILE_NAME or "LegendSeries.lua"

--[[
	Features:
		All skillshots use VPrediction by Ralph!
		Kennen:
			Auto Q W E R in Combo and Harass.
		Karthus:
			Auto Q W E in Combo and Harras.
]]

AddLoadCallback(function()
	General()
end)

class 'General'
function General:__init()
	if Auto_Update then
		self:Updater()
	else
		self:Load()
	end
end

function General:Load()
	if _ENV[myHero.charName] and Champions[myHero.charName] then
		if not self:Libs() then
		Print("Loaded: "..myHero.charName)
		VP = VPrediction(true)
		Menu = scriptConfig("[LegendSeries] "..myHero.charName,"LegendSeries")
		Menu:addParam("Author","Author: Pain",5,"","")
		Menu:addParam("Version","Version: "..Version,5,"","")
		CurrentChampion = _ENV[myHero.charName]()
		end
	elseif not _ENV[myHero.charName] then
		Print(myHero.charName.." is not currently supported.")
	elseif Champions[myHero.charName] == false then
		Print(myHero.charName.." has been disabled by the user.")
	else
		Print("Error is not recognised, please ask for assistance.")
	end
end

function General:Libs()
	--[[Credits to Bilbao & Aroc]]
	self.LIB_NUMBER = 0
	self.RequiredLibs = {
		--["Prodiction"] = "bitbucket.org/Klokje/public-klokjes-bol-scripts/raw/master/Test/Prodiction/Prodiction.lua",
		["VPrediction"] = "raw.githubusercontent.com/Ralphlol/BoLGit/master/VPrediction.lua",
		["SxOrb"] = "raw.githubusercontent.com/Superx321/BoL/master/common/SxOrbWalk.lua",
	}
	if not Auto_Update then Print("Auto Update is disabled, the script cannot download any libraries.") end
	for LIB_NAME, LIB_URL in pairs(self.RequiredLibs) do
		if FileExist(LIB_PATH..LIB_NAME..".lua") then
			require(LIB_NAME)
		elseif Auto_Update then
			self.LIB_NUMBER = self.LIB_NUMBER + 1
			AddTickCallback(function()
				local LIB = LIB_NAME..".lua"
				if not FileExist(LIB_PATH..LIB) then
					self.LibSocket = self.LuaSocket.connect("sx-bol.eu", 80)
					self.LibSocket:send("GET /BoL/TCPUpdater/GetScript.php?script="..LIB_URL.."&rand="..tostring(math.random(1000)).." HTTP/1.0\r\n\r\n")
					self.LibReceive, self.LibStatus = self.LibSocket:receive('*a')
					self.LibRAW = string.sub(self.LibReceive, string.find(self.LibReceive, "<bols".."cript>")+11, string.find(self.LibReceive, "</bols".."cript>")-1)
					local LibFileOpen = io.open(LIB_PATH..LIB, "w+")
					LibFileOpen:write(self.LibRAW)
					LibFileOpen:close()
				else
					self.LIB_NUMBER = self.LIB_NUMBER - 1
				end
			end)
		elseif not Auto_Update then
			self.LIB_NUMBER = self.LIB_NUMBER + 1
			Print("Please download "..LIB_NAME.." manually.")
		end
	end
	if not Auto_Update and self.LIB_NUMBER ~= 0 then
		return true
	elseif self.LIB_NUMBER == 0 then
		return false
	else
		DelayAction(function() self:Load() end,0.5)
		return true
	end
end

function General:Updater()
	--[[Credits to Bilbao & Aroc]]
	self.Host = "raw.githubusercontent.com"
	self.VersionPath = "/LegendBot/LegendSeries/master/BoL/Version/LegendSeries.version"
	self.ScriptPath = "/LegendBot/LegendSeries/master/BoL/LegendSeries.lua"
	self.LuaSocket = require("socket")
	Print("Checking for updates and required libraries.")
	Print("If the script does not load soon, please disable auto update and reload.")
	AddTickCallback(function()
		if not self.OnlineVersion and not self.VersionSocket then
			self.VersionSocket = self.LuaSocket.connect("sx-bol.eu", 80)
			self.VersionSocket:send("GET /BoL/TCPUpdater/GetScript.php?script="..self.Host..self.VersionPath.."&rand="..tostring(math.random(1000)).." HTTP/1.0\r\n\r\n")
		end
		if not self.OnlineVersion and self.VersionSocket then
			self.VersionSocket:settimeout(0, 'b')
			self.VersionSocket:settimeout(99999999, 't')
			self.VersionReceive, self.VersionStatus = self.VersionSocket:receive('*a')
		end
		if not self.OnlineVersion and self.VersionSocket and self.VersionStatus ~= 'timeout' then
			if self.VersionReceive then
				self.OnlineVersion = tonumber(string.sub(self.VersionReceive, string.find(self.VersionReceive, "<bols".."cript>")+11, string.find(self.VersionReceive, "</bols".."cript>")-1))
			else
				Print("AutoUpdate has failed, please download manually.")
				self.OnlineVersion = 0
			end
			if self.OnlineVersion > Version then
				self.ScriptSocket = self.LuaSocket.connect("sx-bol.eu", 80)
				self.ScriptSocket:send("GET /BoL/TCPUpdater/GetScript.php?script="..self.Host..self.ScriptPath.."&rand="..tostring(math.random(1000)).." HTTP/1.0\r\n\r\n")
				self.ScriptReceive, self.ScriptStatus = self.ScriptSocket:receive('*a')
				self.ScriptRAW = string.sub(self.ScriptReceive, string.find(self.ScriptReceive, "<bols".."cript>")+11, string.find(self.ScriptReceive, "</bols".."cript>")-1)
				local ScriptFileOpen = io.open(SCRIPT_PATH..LSScriptName, "w+")
				ScriptFileOpen:write(self.ScriptRAW)
				ScriptFileOpen:close()
				Print("Automatically reloading "..LSScriptName)
				DelayAction(function() dofile(SCRIPT_PATH..LSScriptName) end, 0.5)
			else
				self:Load()
			end
		end
	end)
end

class 'Karthus'
function Karthus:__init()
	self.Data = {
		Q = {ready = false, range = 875, speed = 1700, delay = 0.5, width = 100},
		W = {ready = false, range = 1000, speed = 1600, delay = 0.5, width = 450},
		E = {ready = false, range = 550, speed = 1000, delay = 0.5, width = 550},
		R = {ready = false, range = math.huge, speed = math.huge, delay = 3, width = nil},
		TS = {range = 1000, mode = 8, damage = 1},
	}
	self:Menu()
	AddTickCallback(function() self:Checks() end)
	AddTickCallback(function() self:Combat() end)
	AddDrawCallback(function() self:Draw() end)
end

function Karthus:Menu()
	Menu:addSubMenu("[LegendSeries] Key Bindings","KB")
		Menu.KB:addParam("Combo","Combo",2,false,32)
		Menu.KB:addParam("Harass","Harass",2,false,string.byte("C"))
	Menu:addSubMenu("[LegendSeries] SxOrbWalk","OW")
		Menu.OW:addParam("OW","Orbwalker",7, 2, {"Off", "SxOrb"})
		SxOrb:LoadToMenu(Menu.OW)
	Menu:addSubMenu("[LegendSeries] Target Selector","TS")
		ts = TargetSelector(self.Data.TS.mode,self.Data.TS.range,self.Data.TS.damage,false)
		Menu.TS:addTS(ts)
	Menu:addSubMenu("[LegendSeries] Combo","C")
		Menu.C:addParam("Q","Use Q in Combo",1,true)
		Menu.C:addParam("W","Use W in Combo",1,true)
		Menu.C:addParam("E","Use E in Combo",1,true)
		--Menu.C:addParam("R","Use R in Combo",1,true)
	Menu:addSubMenu("[LegendSeries] Harass","H")
		Menu.H:addParam("Q","Use Q in Harass",1,true)
		Menu.H:addParam("W","Use W in Harass",1,true)
		Menu.H:addParam("E","Use E in Harass",1,true)
	Menu:addSubMenu("[LegendSeries] Prediction","P")
		Menu.P:addParam("P","Prediction to use",7,1,{"VPrediction",--[["Prodiction"]]})
		Menu.P:addParam("QHC","Q Hit Chance",4,2,1,5,0)
		Menu.P:addParam("WHC","W Hit Chance",4,2,1,5,0)
		--Menu.P:addParam("RU","R Units to Kill",4,2,1,5,0)
	Menu:addSubMenu("[LegendSeries] Draw","D")
		Menu.D:addParam("Q","Draw Q Range",1,true)
		Menu.D:addParam("W","Draw W Range",1,true)
		Menu.D:addParam("E","Draw E Range",1,true)
end

function Karthus:Checks()
	Combo = Menu.KB.Combo
	Harass = Menu.KB.Harass
	self.Data.Q.ready = myHero:CanUseSpell(_Q) == READY and ((Combo and Menu.C.Q) or (Harass and Menu.H.Q))
	self.Data.W.ready = myHero:CanUseSpell(_W) == READY and ((Combo and Menu.C.W) or (Harass and Menu.H.W))
	self.Data.E.ready = myHero:CanUseSpell(_E) == READY and ((Combo and Menu.C.E) or (Harass and Menu.H.E))
	self.Data.R.ready = myHero:CanUseSpell(_R) == READY and (Combo and Menu.C.R)
	if Menu.OW.OW == 1 then
		SxOrb:DisableAttacks()
		SxOrb:DisableMove()
	elseif Menu.OW.OW == 2 then
		SxOrb:EnableAttacks()
		SxOrb:EnableMove()
	end
	ts:update()
	Target = (Menu.OW.OW == 2 and SxOrb:GetTarget(1200)) or ts.target
end

function Karthus:Combat()
	--[[if self.Data.R.ready then
		local hc = 0
		for i = 1, heroManager.iCount do
			local h = heroManager:GetHero(i)
			if h.team ~= myHero.team and not h.dead and getDmg("R",h,myHero) > h.health then
				hc = hc + 1
			end
		end
		if hc >= Menu.P.RU then
			CastSpell(_R)
		end
	end]]
	if Target == nil then return end
	if self.Data.Q.ready then
		if Menu.P.P == 1 then
			local CastPosition, HitChance = VP:GetLineCastPosition(Target,self.Data.Q.delay,self.Data.Q.width,self.Data.Q.range,self.Data.Q.speed,myHero,true)
			if CastPosition ~= nil and GetDistance(myHero,CastPosition) < self.Data.Q.range and HitChance >= Menu.P.QHC then
				CastSpell(_Q,CastPosition.x,CastPosition.z)
			end
		end
	end
	if self.Data.W.ready then
		local CastPosition, HitChance = VP:GetLineCastPosition(Target,self.Data.W.delay,self.Data.W.width,self.Data.W.range,self.Data.W.speed,myHero,false)
		if CastPosition ~= nil and GetDistance(myHero,CastPosition) < self.Data.W.range and HitChance >= Menu.P.WHC then
			CastSpell(_W,CastPosition.x,CastPosition.z)
		end
	end
	if self.Data.E.ready and GetDistance(myHero,Target) < self.Data.E.range then
		CastSpell(_E)
	end
end

function Karthus:Draw()
	for i, k in pairs(self.Data) do
		if Menu.D[i] then DrawCircle(myHero.x,myHero.y,myHero.z,self.Data[i].range,0x00FFFF) end
	end
end

class 'Kennen'
function Kennen:__init()
	self.Data = {
		Q = {ready = false, range = 950, speed = 1200, delay = 0.7, width = 50},
		W = {ready = false, range = 900, speed = math.huge, delay = 0.5, width = 900},
		E = {ready = false, range = 300},
		R = {ready = false, range = 550, speed = math.huge, delay = 0.5, width = 550},
		TS = {range = 900, mode = 8, damage = 1},
	}
	self:Menu()
	AddTickCallback(function() self:Checks() end)
	AddTickCallback(function() self:Combat() end)
	AddDrawCallback(function() self:Draw() end)
end

function Kennen:Menu()
	Menu:addSubMenu("[LegendSeries] Key Bindings","KB")
		Menu.KB:addParam("Combo","Combo",2,false,32)
		Menu.KB:addParam("Harass","Harass",2,false,string.byte("C"))
	Menu:addSubMenu("[LegendSeries] SxOrbWalk","OW")
		Menu.OW:addParam("OW","Orbwalker",7, 2, {"Off", "SxOrb"})
		SxOrb:LoadToMenu(Menu.OW)
	Menu:addSubMenu("[LegendSeries] Target Selector","TS")
		ts = TargetSelector(self.Data.TS.mode,self.Data.TS.range,self.Data.TS.damage,false)
		Menu.TS:addTS(ts)
	Menu:addSubMenu("[LegendSeries] Combo","C")
		Menu.C:addParam("Q","Use Q in Combo",1,true)
		Menu.C:addParam("W","Use W in Combo",1,true)
		Menu.C:addParam("E","Use E in Combo",1,true)
		Menu.C:addParam("R","Use R in Combo",1,true)
	Menu:addSubMenu("[LegendSeries] Harass","H")
		Menu.H:addParam("Q","Use Q in Harass",1,true)
		Menu.H:addParam("W","Use W in Harass",1,true)
		Menu.H:addParam("E","Use E in Harass",1,true)
	Menu:addSubMenu("[LegendSeries] Prediction","P")
		Menu.P:addParam("P","Prediction to use",7,1,{"VPrediction",--[["Prodiction"]]})
		Menu.P:addParam("QHC","Q Hit Chance",4,2,1,5,0)
		Menu.P:addParam("RU","R Units to Hit",4,2,1,5,0)
	Menu:addSubMenu("[LegendSeries] Draw","D")
		Menu.D:addParam("Q","Draw Q Range",1,true)
		Menu.D:addParam("W","Draw W Range",1,true)
		Menu.D:addParam("E","Draw E Range",1,true)
		Menu.D:addParam("R","Draw R Range",1,true)
end

function Kennen:Checks()
	Combo = Menu.KB.Combo
	Harass = Menu.KB.Harass
	self.Data.Q.ready = myHero:CanUseSpell(_Q) == READY and ((Combo and Menu.C.Q) or (Harass and Menu.H.Q))
	self.Data.W.ready = myHero:CanUseSpell(_W) == READY and ((Combo and Menu.C.W) or (Harass and Menu.H.W))
	self.Data.E.ready = myHero:CanUseSpell(_E) == READY and ((Combo and Menu.C.E) or (Harass and Menu.H.E))
	self.Data.R.ready = myHero:CanUseSpell(_R) == READY and (Combo and Menu.C.R)
	if Menu.OW.OW == 1 then
		SxOrb:DisableAttacks()
		SxOrb:DisableMove()
	elseif Menu.OW.OW == 2 then
		SxOrb:EnableAttacks()
		SxOrb:EnableMove()
	end
	ts:update()
	Target = (Menu.OW.OW == 2 and SxOrb:GetTarget(1200)) or ts.target
end

function Kennen:Combat()
	if Target == nil then return end
	if self.Data.Q.ready then
		if Menu.P.P == 1 then
			local CastPosition, HitChance = VP:GetLineCastPosition(Target,self.Data.Q.delay,self.Data.Q.width,self.Data.Q.range,self.Data.Q.speed,myHero,true)
			if CastPosition ~= nil and GetDistance(myHero,CastPosition) < self.Data.Q.range and HitChance >= Menu.P.QHC then
				CastSpell(_Q,CastPosition.x,CastPosition.z)
			end
		end
	end
	if self.Data.W.ready and GetDistance(myHero,Target) < self.Data.W.range then
		CastSpell(_W)
	end
	if self.Data.E.ready and not self:Buff() and GetDistance(myHero,Target) < self.Data.E.range then
		CastSpell(_E)
	end
	if self.Data.R.ready then
		local hc = 0
		for i = 1, heroManager.iCount do
			local h = heroManager:GetHero(i)
			if h.team ~= myHero.team and not h.dead and GetDistance(myHero,h) <= self.Data.R.range then
				hc = hc + 1
			end
		end
		if hc >= Menu.P.RU then
			CastSpell(_R)
		end
	end
end

function Kennen:Draw()
	for i, k in pairs(self.Data) do
		if Menu.D[i] then DrawCircle(myHero.x,myHero.y,myHero.z,self.Data[i].range,0x00FFFF) end
	end
end

function Kennen:Buff()
	for i = 1, myHero.buffCount do
		local buff = myHero:getBuff(i)
		if BuffIsValid(buff) and string.lower(buff.name) == "kennenlightningrush" then
			return true
		end
	end
	return false
end

function Print(m)
	print("<font color=\"#FF0000\">[LegendSeries]</font> <font color=\"#FFFFFF\">"..m.."</font>")
end

if Debug then
	AddTickCallback(function()
		if os.clock() < (clock or 0) then return end
		clock = os.clock() + 1
		myHero:MoveTo(myHero.x,myHero.z) --[[AntiAfk, wooo]]
	end)
end

--[[
Notes:
	SAC:Reborn (I'll probably add it in the future.. Probably..):
		_G.Reborn_Initialised -- Returns true when Reborn is authed.
		_G.Reborn_Loaded -- Returns true if Reborn is injected.
		AutoCarry.MyHero:AttacksEnabled(false) -- Disables SACR Attacks.
		AutoCarry.MyHero:MovementEnabled(false) -- Disables SACR Movement.
]]
