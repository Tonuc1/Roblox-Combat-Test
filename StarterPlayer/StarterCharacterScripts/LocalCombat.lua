local Players = game:GetService("Players")
local CAS = game:GetService("ContextActionService")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerHandler = RS:WaitForChild("CombatHandler")
local player = Players.LocalPlayer
local module = player.PlayerScripts.Stats
local playerStats = require(module)
local character = player.Character or player.CharacterAdded:Wait()
local Animations = character:WaitForChild("Animations")
local combatTracks = {character.Humanoid.Animator:LoadAnimation(Animations.rightPunch),character.Humanoid.Animator:LoadAnimation(Animations.leftPunch),character.Humanoid.Animator:LoadAnimation(Animations.lowPunch)}
local blockTrack = character.Humanoid.Animator:LoadAnimation(Animations.Block)
local cam = workspace.CurrentCamera
local number = 0
local blocking = false
local cooldown = false
local originalNeckC0 = character:WaitForChild("Torso"):WaitForChild("Neck").C0
local originalLeftArmC0, originalRightArmC0 = character.Torso["Left Shoulder"].C0, character.Torso["Right Shoulder"].C0
local lerp = 0.005
local ROM = 5
local blockRenderSteppedEvent;
local raycastParams = RaycastParams.new()
print(playerStats["Strength"])
function cooldown_(variable, cooldowntime)
	variable = true
	wait(cooldowntime)
	variable = false
end
local function ControlledPlay(animation)
	if animation.IsPlaying == false then
		animation:Play()
	end
end
local function animationsArePlaying(table_)
	for _, v in ipairs(table_) do
		if v.IsPlaying then
			return false
		end
	end
	return true
end
local function findTargets(basePart, distance, paramType, filterDescendantsInstances)
	local targets = {}
	raycastParams.FilterType = paramType
	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
	for _, v in pairs(workspace:GetChildren()) do
		if v:FindFirstChildWhichIsA("Humanoid") and v ~= character then
			if v.Humanoid.Health > 0 and (v.HumanoidRootPart.Position - basePart.Position).Magnitude < distance then
				local ray = workspace:Raycast(basePart.Position, v.HumanoidRootPart.Position, raycastParams)
				if ray then
				print(ray.Instance.Name, ray.Instance.Parent.Name)
				if ray.Instance:IsDescendantOf(v) then
				table.insert(targets, v)
				end
				end
			end
		end
	end
	return targets
end
function lookAtBlock(deltaTime)
	local diff = math.clamp(-cam.CFrame:ToEulerAnglesYXZ()*15, -30, 30)
	local camDir = character.HumanoidRootPart.CFrame:ToObjectSpace(cam.CFrame).LookVector
	local neckResult = originalNeckC0*CFrame.Angles(math.rad(diff), 0, 0)
	local Lresult, Rresult = originalLeftArmC0*CFrame.Angles(0,0,math.rad(diff)), originalRightArmC0*CFrame.Angles(0,0,math.rad(-diff))
	local lerpTime = math.clamp(1-lerp^deltaTime, 0, 1)
	character.Torso.Neck.C0 = character.Torso.Neck.C0:Lerp(neckResult, lerpTime)
	character.Torso["Left Shoulder"].C0 = character.Torso["Left Shoulder"].C0:Lerp(Lresult, lerpTime)
	character.Torso["Right Shoulder"].C0 = character.Torso["Right Shoulder"].C0:Lerp(Rresult, lerpTime)
end 

function punch(actionName, InputState, InputObject)
	if not character:FindFirstChildWhichIsA("Tool") then
	if InputState == Enum.UserInputState.Begin and not cooldown and not blocking then
	number = math.clamp(number+1, 0, 3)
	if number <= 3 then
		local victims = findTargets(character.HumanoidRootPart, 5, Enum.RaycastFilterType.Exclude, {character})
			ControlledPlay(combatTracks[number])
			ServerHandler:FireServer("Swing", victims, playerStats["Strength"]*10, false)
				
			
		end
	
		if number == 3 then
			number = 0
			cooldown = true
			wait(0.5)
			cooldown = false
		end
	end
	end
end
function block(actionName, InputState, InputObject)
	if not character:FindFirstChildWhichIsA("Tool") then
	if InputState == Enum.UserInputState.Begin then
		blocking = true
		blockTrack:Play()
		
		blockRenderSteppedEvent = RunService.RenderStepped:Connect(function(deltaTime)
			lookAtBlock(deltaTime)
		end)
	elseif InputState == Enum.UserInputState.End then
		blocking = false
		blockTrack:Stop()
		blockRenderSteppedEvent:Disconnect()
		for i = 0, 1, 0.01 do
			task.wait(.01)
			character.Torso.Neck.C0 = character.Torso.Neck.C0:Lerp(originalNeckC0, i)
			character.Torso["Left Shoulder"].C0 = character.Torso["Left Shoulder"].C0:Lerp(originalLeftArmC0, i)
			character.Torso["Right Shoulder"].C0 = character.Torso["Right Shoulder"].C0:Lerp(originalRightArmC0, i)
			if blocking then break end
		end
		character.Torso.Neck.C0 = originalNeckC0
		character.Torso["Left Shoulder"].C0 = originalLeftArmC0
		character.Torso["Right Shoulder"].C0 = originalRightArmC0
	end
	end
end

CAS:BindAction("Combat", punch, false, Enum.KeyCode.F)
CAS:BindAction("Block", block, false, Enum.KeyCode.Q)
-- Script to look at mouse R6 = CFrame.new(0, originalNeckC0.Y, 0)*CFrame.Angles(3*math.pi/2,0, math.pi)*CFrame.Angles(0,0, -math.asin(camDir.X))*CFrame.Angles(-math.asin(camDir.Y),0, 0)
