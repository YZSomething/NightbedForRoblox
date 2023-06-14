--[[
	Credits
	Infinite Yield - InfJump
	engospy - RemoteEvent
	Kavo Owner - kavo ui
	7GrandDadPGN (xylex) - Vape Entity
--]]
repeat task.wait() until game:IsLoaded()
local getasset = getsynasset or getcustomassetfunction or getcustomasset or function(location) return "rbxasset://"..location end
local entityLibrary = shared.vapeentity
local kavo = shared.kavogui
local FunctionsLibrary = shared.funcslib
local win = kavo:CreateWindow({
	["Title"] = "Nightbed",
	["Theme"] = "Luna"
})

local Settings = {
  ["InfiniteJump"] = false,
  ["Speed"] = {
    ["Enabled"] = false,
    ["Value"] = 54,
  },
  ["Cape"] = false
}

local runFunction = function(func) func() end

local Tabs = {
	["Combat"] = win.CreateTab("Combat"),
	["Blatant"] = win.CreateTab("Blatant"),
	["Render"] = win.CreateTab("Render"),
	["Utility"] = win.CreateTab("Utility"),
	["World"] = win.CreateTab("World")
}
local Sections = shared.SectionsLoaded
Sections = {
	["InfiniteJump"] = Tabs["Blatant"].CreateSection("InfiniteJump"),
	["Speed"] = Tabs["Blatant"].CreateSection("Speed"),
	["Cape"] = Tabs["Render"].CreateSection("Cape")
}

function createnotification(Titlez, Textz, Dur)
game.StarterGui:SetCore("SendNotification", {
    Title = Titlez;
    Text = Textz;
    Duration = Dur;
})
end
local InfiniteJumpConnection
local playersService = game:GetService("Players")
local lplr = playersService.LocalPlayer
local oldchar = lplr.Character
local gameCamera = workspace.CurrentCamera
local InputService = game:GetService("UserInputService")

runFunction(function()
	local InfiniteJump = {Enabled = false}
	local InfJump = true
	InfiniteJump = Sections["InfiniteJump"].CreateToggle({
		Name = "InfiniteJump",
		Function = function(callback)
			InfiniteJump.Enabled = callback
	  	if InfiniteJump.Enabled then
	  	  Settings["InfiniteJump"] = true
	  	  spawn(function()
    			InfiniteJumpConnection = InputService.JumpRequest:connect(function(jump)
		    		if InfJump then
		    			oldchar:FindFirstChildOfClass'Humanoid':ChangeState("Jumping")
    				end
		    	end)
				end)
			else
			  Settings["InfiniteJump"] = false
				InfiniteJumpConnection:Disconnect()
			end
		end,
		HoverText = "Make you can jump any place"
	})
end)

runFunction(function()
	local KillauraNoSwing = {Enabled = false}
	local KillauraNoSound = {Enabled = false}
	local killaurarange = {Value = 23}
	local Killaura = {Enabled = false}
	local killauraremote = bedwars.ClientHandler:Get(bedwars.AttackRemote)
	local function attackEntity(plr)
		local root = plr.Character.HumanoidRootPart
		if not root then
			return nil
		end
		local selfrootpos = lplr.Character.HumanoidRootPart.Position
		local selfpos = selfrootpos + (killaurarange.Value > 14 and (selfrootpos - root.Position).magnitude > 14 and (CFrame.lookAt(selfrootpos, root.Position).lookVector * 4) or Vector3.zero)
		local sword = getCurrentSword()
		killauraremote:SendToServer({
			["weapon"] = sword ~= nil and sword.tool,
			["entityInstance"] = plr.Character,
			["validate"] = {
				["raycast"] = {
					["cameraPosition"] = hashvec(cam.CFrame.Position),
					["cursorDirection"] = hashvec(Ray.new(cam.CFrame.Position, root.CFrame.Position).Unit.Direction)
				},
				["targetPosition"] = hashvec(root.CFrame.Position),
				["selfPosition"] = hashvec(selfpos)
			},
			["chargedAttack"] = {
				["chargeRatio"] = 0}
		})
		if not KillauraNoSwing.Enabled then
			if Killaura.Enabled then
				playAnimation("rbxassetid://4947108314")
			end
		end
		if not KillauraNoSound.Enabled then
			if Killaura.Enabled then
				playSound("rbxassetid://6760544639", 0.5)
			end
		end
	end
	Killaura = Sections["Killaura"].CreateToggle({
		Name = "Killaura",
		Function = function(callback)
			Killaura.Enabled = callback
			if Killaura.Enabled then
				Settings.Killaura.Enabled = true
				RunLoops:BindToHeartbeat("Killaura", 1, function()
					local plrs = GetAllNearestHumanoidToPosition(killaurarange.Value - 0.0001, 1)
					for i,plr in pairs(plrs) do
						task.spawn(attackEntity, plr)
					end
				end)
			else
				Settings.Killaura.Enabled = false
				RunLoops:UnbindFromHeartbeat("Killaura")
			end
		end,
		HoverText = "Attack players/enemies that are near."
	})
	KillauraNoSound = Sections["Killaura"].CreateToggle({
		Name = "No Sound",
		Function = function(val)
			Settings.Killaura.NoSound = val
			KillauraNoSound.Enabled = val
		end,
		HoverText = "Removes the swinging sound."
	})
	KillauraNoSwing = Sections["Killaura"].CreateToggle({
		Name = "No Swing",
		Function = function(val)
			Settings.Killaura.NoSwing = val
			KillauraNoSwing.Enabled = val
		end,
		HoverText = "Removes the swinging animation."
	})
end)
	
runFunction(function()
	local Speed = {Enabled = false}
	local speedval = {Value = 54}
	Speed = Sections["Speed"].CreateToggle({
		Name = "Speed",
		Function = function(callback)
			Speed.Enabled = callback
			Settings["Speed"]["Enabled"] = callback
			  if Speed.Enabled then
			    Settings["Speed"]["Enabled"] = true
			    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = speedval.Value
			  else
			    Settings["Speed"]["Enabled"] = false
			    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
				end
			end,
		HoverText = "Make you Faster"
	})
end)

--
runFunction(function()
	function Cape(char, texture)
        for i,v in pairs(char:GetDescendants()) do
            if v.Name == "Cape" then
                v:Remove()
            end
        end
        local hum = char:WaitForChild("Humanoid")
        if char:FindFirstChild("Torso") then
            torso = char.Torso
        else
            torso = char.UpperTorso
        end
        local p = Instance.new("Part", torso.Parent)
        p.Name = "Cape"
        p.Anchored = false
        p.CanCollide = false
        p.TopSurface = 0
        p.BottomSurface = 0
        p.FormFactor = "Custom"
        p.Size = Vector3.new(0.2,0.2,0.2)
        p.Transparency = 1
        local decal = Instance.new("Decal", p)
        decal.Texture = texture
        decal.Face = "Back"
        local msh = Instance.new("BlockMesh", p)
        msh.Scale = Vector3.new(9,17.5,0.5)
        local motor = Instance.new("Motor", p)
        motor.Part0 = p
        motor.Part1 = torso
        motor.MaxVelocity = 0.01
        motor.C0 = CFrame.new(0,2,0) * CFrame.Angles(0,math.rad(90),0)
        motor.C1 = CFrame.new(0,1,0.45) * CFrame.Angles(0,math.rad(90),0)
        local wave = false
        repeat wait(1/44)
            decal.Transparency = torso.Transparency
            local ang = 0.1
            local oldmag = torso.Velocity.magnitude
            local mv = 0.002
            if wave then
                ang = ang + ((torso.Velocity.magnitude/10) * 0.05) + 0.05
                wave = false
            else
                wave = true
            end
            ang = ang + math.min(torso.Velocity.magnitude/11, 0.5)
            motor.MaxVelocity = math.min((torso.Velocity.magnitude/111), 0.04) --+ mv
            motor.DesiredAngle = -ang
            if motor.CurrentAngle < -0.2 and motor.DesiredAngle > -0.2 then
                motor.MaxVelocity = 0.04
            end
            repeat wait() until motor.CurrentAngle == motor.DesiredAngle or math.abs(torso.Velocity.magnitude - oldmag) >= (torso.Velocity.magnitude/10) + 1
            if torso.Velocity.magnitude < 0.1 then
                wait(0.1)
            end
        until not p or p.Parent ~= torso.Parent
    end
	local Cape = {Enabled = false}
	Cape = Sections["Cape"].CreateToggle({
		Name = "Cape",
		Function = function(callback)
			Cape.Enabled = callback
				if Cape.Enabled then
				  Settings["Cape"] = true
					lplr.CharacterAdded:Connect(function(char)
						spawn(function()
							pcall(function() 
								Cape(char, "rbxassetid://13587951030")--("rbxthumb://type=Asset&id=" .. 13587951030 .. "&w=420&h=420"))
							end)
						end)
					end)
					if lplr.Character then
						spawn(function()
							pcall(function() 
								Cape(lplr.Character, "rbxassetid://13587951030") --("rbxthumb://type=Asset&id=" .. 13587951030 .. "&w=420&h=420"))
							end)
						end)
					end
				else
				  Settings["Cape"] = false
					if lplr.Character then
					for i,v in pairs(lplr.Character:GetDescendants()) do
						if v.Name == "Cape" then
							v:Remove()
						end
					end
				end
			end
		end,
		HoverText = "cool cape"
	})
end)
--]]

function SaveSettings()
  writefile("Nightbed/Profiles/AnyGame.json",game:GetService("HttpService"):JSONEncode(Settings))
end

if not shared.KavoLoaded then
  lplr.Character.Humanoid.WalkSpeed = 16
  InfiniteJumpConnection:Disconnect()
end

spawn(function()
	repeat
	  --writefile("Nightbed/Profiles/AnyGame.json",game:GetService("HttpService"):JSONEncode(Settings))
		SaveSettings()
		wait(1.5) -- DONT CHANGE THIS >:(
	until false
end)
local suc, res = pcall(function() return
game:GetService("HttpService"):JSONDecode(readfile("Nightbed/Profiles/AnyGame.json")) end)
if suc and type(res) == "table" then 
  Settings = res
  task.wait()
  if InfiniteJump.Enabled then
  	InfiniteJump.ToggleButton(Settings["InfiniteJump"])
  end
  if Speed.Enabled then
  	Speed.ToggleButton(Settings["Speed"]["Enabled"])
    speedval.Value = Settings["Speed"]["Value"]
  end
end
