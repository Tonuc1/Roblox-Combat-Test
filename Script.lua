-- This is a simple grabbing script I made with other random stuff cuz i didn't know what else to add. I tried my best to put everything in a single 
--script, although there's a server script for the remote events plus two module scripts for other things (camera effects and the crater effect.)

-- There's also a module script for the character that makes a rig class, stores the animations and can store functions for crouching and other actions.
local runSer = game:GetService("RunService")
local CAS = game:GetService("ContextActionService")
local PS = game:GetService("Players") 
local RS = game:GetService("ReplicatedStorage")
local CPS = game:GetService("ContentProvider")
local UIS = game:GetService("UserInputService")
local player = PS.LocalPlayer
local cam = workspace.CurrentCamera
local mouse = player:GetMouse()
local playergui = player.PlayerGui
local screengui = playergui.ScreenGui
local frame = screengui.Frame
local currentMode = frame.currentMode
local character = player.Character or script.Parent
local holdModes = {"Physical", "Telekinesis"} -- Defining the two types of grabbing there is
local currentHoldMode = "Physical" -- The default holding mode you start with is physical.
local SFX = RS:WaitForChild("SFX") 
local actionsEvent = RS:WaitForChild("playerActionEvent") -- Remote event
local animations = character:WaitForChild("Animations") -- Animations folder in characterscripts
local objectHeld = character:WaitForChild("ObjectHeld") -- Object value stored in the character
local cameraFX = require(playergui.CameraFX) -- Module script for camera effects
local module = character:WaitForChild("characterFunctions")
local characterFunctions = require(module)
local rig = characterFunctions.NewRig(character)
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
rig:LoadAnimations()



-- function for loading all the animations in the animation folder and adding them to a table.

-- calling the function to get the animations table.

local grabOffset = CFrame.new(0,0,-3) -- the offset used when grabbing an object physically
local grabDistance = 10 -- How far you have to be from a part to grab it

-- This script is so you can switch hold modes, between physical and telekinesis. To use telekinesis you just hold click on an object.
-- To hold objects physically you have to get close to an unanchored part or rig then left click on it.
-- When you're holding an object you can either throw it (holding or clicking left mouse) or drop it (with T).
local function switchHoldMode(ActionName, InputState, InputObject)
	if InputState == Enum.UserInputState.End then
	local holdModeIndex = table.find(holdModes, currentHoldMode, 1)
		print(holdModeIndex)
		local nextHoldMode = holdModes[holdModeIndex+1]
		currentHoldMode = if nextHoldMode then nextHoldMode else holdModes[1]
		currentMode.Text = "Hold Mode: "..currentHoldMode
		SFX.Switch:Play()
	end
end

-- function used to drop the object
local function dropObject(ActionName, InputState, InputObject)
	if ActionName == "Drop Object" and InputState == Enum.UserInputState.End then
		local part = objectHeld.Value
		if part then
			local weld = character.HumanoidRootPart:FindFirstChild("WeldConstraint")
			rig.Animations.hold:Stop()
			if weld then
			actionsEvent:FireServer("Unweld", weld)
			end
			part.CanCollide = true
			objectHeld.Value = nil
			CAS:UnbindAction("Drop Object")
		end
	end
end
-- function used to throw the object
local function throwObject()
	local part = objectHeld.Value
	local mousedown = true
	local counter = 1
	local weld = character.HumanoidRootPart:FindFirstChild("WeldConstraint")
	rig.Animations.hold:Stop()
	rig.Animations.throw:Play()
	rig.Animations.throw:GetMarkerReachedSignal("TopMovement"):Connect(function()

		

		if mousedown then
			rig.Animations.throw:AdjustSpeed(0)
		end
		
	end)
	local c;
	c = mouse.Button1Up:Connect(function()
		mousedown = false
		objectHeld.Value = nil
		rig.Animations.throw:AdjustSpeed(1)
		-- Communicating with the server to destroy the weldconstraint connecting the object to the character
		actionsEvent:FireServer("Unweld", weld)
		c:Disconnect()

		actionsEvent:FireServer("Throw Part", part, character.HumanoidRootPart.CFrame.LookVector*counter)
		part.CanCollide = false
		wait(.5)
		part.CanCollide = true

		if part.Parent:FindFirstChild("Humanoid") then
			actionsEvent:FireServer("Debris", part.Parent)
		end

	end)
	while mousedown  do
		wait(.1)
		print("running while loop")
		counter += 50
	end

end
-- script to alternate between crouching and uncrouching, the actual crouching script is stored in a module.
local function Crouch(ActionName, InputState, InputObject)
	if InputState == Enum.UserInputState.Begin then
		rig:Crouch()
	elseif InputState == Enum.UserInputState.End then
		rig:Uncrouch()
	end
end

-- Binding the function for switching hold mode
CAS:BindAction("Switch Hold Mode", switchHoldMode, false, Enum.KeyCode.V)

-- Main function
mouse.Button1Down:Connect(function()
	if not objectHeld.Value then
		-- Gets the mouse target, then checks if it has the "Grabbable" tag. If so, you'll grab it.
		local target = mouse.Target 
	local grabPart = if mouse.Target.Parent:IsA("Model") and mouse.Target.Parent ~= workspace then target.Parent.PrimaryPart else mouse.Target
	local tag = if target then target:HasTag("Grabbable") or target.Parent:HasTag("Grabbable") else nil
	local model = if mouse.Target.Parent:IsA("Model") and mouse.Target.Parent ~= workspace then target.Parent else nil
	
		if currentHoldMode == "Physical" then
			if tag then
			local grabsuccessful = false
			local giveup = false
		local position = grabPart.Position
			local distance = (character.HumanoidRootPart.Position - position).Magnitude
				if distance <= grabDistance then
					grabsuccessful = true
				end
		
		
		if grabsuccessful then
			-- Making the alignposition for the picking up animation and the weldconstraint for actually holding the object.
				local att0 = Instance.new("Attachment")
				local alignPosition = Instance.new("AlignPosition")
				local ws = character.Humanoid.WalkSpeed
				att0.Parent = grabPart
				alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
				alignPosition.Attachment0 = att0
				alignPosition.Responsiveness = 3
				alignPosition.Parent = grabPart
				
			print("Grab was successful")
			grabPart.CanCollide = false
				
				alignPosition.Position = (character.HumanoidRootPart.CFrame *  grabOffset).Position
				character.Humanoid.WalkSpeed = 0
				objectHeld.Value = grabPart
								if model then 
									for _, v in pairs(model:GetChildren()) do
										if v:IsA("BasePart") then
											v.CanCollide = false
											v.Massless = true
						actionsEvent:FireServer("Set Network owner", model)
									end
									end
								else
				actionsEvent:FireServer("Set Network owner", grabPart)
								end
				
		rig.Animations.pickUp:Play()
		wait(rig.Animations.pickUp.Length)
		CAS:BindAction("Drop Object", dropObject, false, Enum.KeyCode.T)
		rig.Animations.hold:Play()
		alignPosition:Destroy()
		att0:Destroy()
				character.Humanoid.WalkSpeed = ws
		
		grabPart.Massless = true
		actionsEvent:FireServer("Weld", grabPart)	
		end
		end
		elseif currentHoldMode == "Telekinesis"	 then
			if tag then
			local mousemoved;
			local mousebutton1up;
			local alignPosition = Instance.new("AlignPosition")
			local att0 = Instance.new("Attachment")
			alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
			alignPosition.Attachment0 = att0
			att0.Parent = grabPart
			alignPosition.Parent = grabPart
			objectHeld.Value = grabPart
			-- Setting the network owner
			actionsEvent:FireServer("Set Network owner", grabPart)
			if grabPart.Parent:FindFirstChild("Humanoid") then
				grabPart.Parent.Humanoid.PlatformStand = true
			end
			mousemoved = mouse.Move:Connect(function()
				print("Mouse is moving")
				
				alignPosition.Position = character.Head.Position + (mouse.Hit.Position - character.Head.Position).Unit*30
				
				
			end)
			-- when LMB is released you let go of the object
		mousebutton1up = mouse.Button1Up:Connect(function()
			mousemoved:Disconnect()
			mousebutton1up:Disconnect()
			alignPosition:Destroy()
			att0:Destroy()
			objectHeld.Value = nil
		end)
			end
			end
	elseif currentHoldMode == "Physical" and objectHeld.Value then
		-- Throw Object
		if not rig.Animations.pickUp.IsPlaying then
		throwObject()
		end
		end
	
end)

-- when the object value of objectHeld is destroyed all the animations will stop.
objectHeld.Changed:Connect(function(value)
	print("Value Changed")
	if value then
	value.Destroying:Connect(function()
		print("Destroying")
		for _, animation in pairs(rig.Animations) do
			animation:Stop()
		end
	end)
	end
end)

-- For camera effects when you throw a person
actionsEvent.OnClientEvent:Connect(function(instruction, p2, p3, p4)
	if instruction == "Camera Thud" then
		print("fired client")
		cameraFX.Thud(cam, 5)
		
	end
end)

CAS:BindAction("Crouch", Crouch, false, Enum.KeyCode.C)
-- Preloading animations and sound effects
function preload(table_)
	for _, v in pairs(table_) do
		CPS:PreloadAsync({v})
	end
end
-- Load sounds
preload(SFX:GetChildren())
-- Load animations
preload(animations:GetChildren())
