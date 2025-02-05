-- test real
local kavo = shared.kavogui
local entityLibrary = shared.vapeentity
local FunctionsLibrary = shared.funcslib

local runFunction = function(func) func() end

local players = game:GetService("Players")
local lplr = players.LocalPlayer
local repstorage = game:GetService("ReplicatedStorage")
local workspace = game:GetService("Workspace")
local cam = workspace.CurrentCamera
local bedwars = {}

local function getremote(tab)
	for i,v in pairs(tab) do
		if v == "Client" then
			return tab[i + 1]
		end
	end
	return ""
end

runFunction(function()
  local flaggedremotes = {"SelfReport"}
  local Flamework = require(repstorage["rbxts_include"]["node_modules"]["@flamework"].core.out).Flamework
	repeat task.wait() until Flamework.isInitialized
  local KnitClient = debug.getupvalue(require(lplr.PlayerScripts.TS.knit).setup, 6)
  local Client = require(repstorage.TS.remotes).default.Client
  local OldClientGet = getmetatable(Client).Get
	local OldClientWaitFor = getmetatable(Client).WaitFor
    bedwars = {
			BedwarsKits = require(repstorage.TS.games.bedwars.kit["bedwars-kit-shop"]).BedwarsKitShop,
			ClientHandler = Client,
			ClientStoreHandler = require(lplr.PlayerScripts.TS.ui.store).ClientStore,
		  EmoteMeta = require(repstorage.TS.locker.emote["emote-meta"]).EmoteMeta,
		  QueryUtil = require(repstorage["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out).GameQueryUtil,
			KitMeta = require(repstorage.TS.games.bedwars.kit["bedwars-kit-meta"]).BedwarsKitMeta,
			LobbyClientEvents = KnitClient.Controllers.QueueController,
			sprintTable = KnitClient.Controllers.SprintController,
			WeldTable = require(repstorage.TS.util["weld-util"]).WeldUtil,
			QueueMeta = require(repstorage.TS.game["queue-meta"]).QueueMeta,
			getEntityTable = require(repstorage.TS.entity["entity-util"]).EntityUtil,
  	}
end)

local isAlive = function(plr, alivecheck)
	if plr then
		return plr and plr.Character and plr.Character.Parent ~= nil and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Head") and plr.Character:FindFirstChild("Humanoid")
	end
end

local win = kavo:CreateWindow({
	["Title"] = "Nightbed - Lobby",
	["Theme"] = "Luna"
})

local Tabs = {
	["Combat"] = win.CreateTab("Combat"),
	["Blatant"] = win.CreateTab("Blatant"),
	["Render"] = win.CreateTab("Render"),
	["Utility"] = win.CreateTab("Utility"),
	["World"] = win.CreateTab("World")
}

local Sections = {
	["Sprint"] = Tabs["Combat"].CreateSection("Sprint"),
	["AutoQueue"] = Tabs["Blatant"].CreateSection("AutoQueue")
}

runFunction(function()
	local Sprint = {["Enabled"] = false}
	Sprint = Sections["Sprint"].CreateToggle({
		["Name"] = "Sprint",
		["Function"] = function(callback)
			Sprint["Enabled"] = callback
			if Sprint["Enabled"] then
		  	task.spawn(function()
  				repeat
			  		task.wait()
  					if (not bedwars.sprintTable.sprinting) then
  						bedwars.sprintTable:startSprinting()
		  			end
  				until (not Sprint["Enabled"])
  			end)
  	  else
				bedwars.sprintTable:stopSprinting()
			end
		end,
		["HoverText"] = "Automatic Sprint."
	})
end)

runFunction(function()
  local function findfrom(name)
  	for i,v in pairs(bedwars.QueueMeta) do 
  		if v.title == name and i:find("voice") == nil then
  			return i
  		end
  	end
  	return "bedwars_to1"
  end
  local QueueTypes = {}
  for i,v in pairs(bedwars.QueueMeta) do 
  	if v.title:find("Test") == nil then
  		table.insert(QueueTypes, v.title..(i:find("voice") and " (VOICE)" or "")) 
  	end
  end
	local AutoQueue = {["Enabled"] = false}
	local AutoQueueMode = {["Value"] = ""}
	local QueueStart = true
	AutoQueue = Sections["AutoQueue"].CreateToggle({
		Name = "AutoQueue",
		HoverText = "Automatic Joins Queue",
		Function = function(callback)
			AutoQueue["Enabled"] = callback
			if AutoQueue["Enabled"] then
			  QueueStart = true
			  game:GetService("ReplicatedStorage")["events-@easy-games/lobby:shared/event/lobby-events@getEvents.Events"].joinQueue:FireServer({
          ["queueType"] = findfrom(AutoQueueMode["Value"]),
        })
		  else
			  print("Teleported 2")
			  QueueStart = false
        game:GetService("ReplicatedStorage")["events-@easy-games/lobby:shared/event/lobby-events@getEvents.Events"].leaveQueue:FireServer()
	  	end
  	end
	})
	AutoQueueMode = Sections["AutoQueue"].CreateDropdown({
		["Name"] = "Mode",
		["HoverText"] = "Mode queue that you want.",
		["List"] = QueueTypes,
		["Function"] = function(val)
			AutoQueueMode["Value"] = val
			if AutoQueue["Enabled"] and QueueStart == false then
				AutoQueue.ToggleButton(false)
				task.wait()
				AutoQueue.ToggleButton(true)
			end
		end
	})
end)