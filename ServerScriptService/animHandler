local players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local animEvent = RS:WaitForChild("animEvent")
local blooodHandler = RS:WaitForChild("bloodHandler")
local starterPlayer = game:GetService("StarterPlayer")
local starterCharacterObjects = starterPlayer:WaitForChild("StarterCharacterScripts")
local instance = Instance.new
function checkCharacterState(character, desiredstate, limittime)
	if character.Humanoid:GetState() == desiredstate then
		warn("Character is already in that state")
	else
		character.Humanoid:ChangeState(desiredstate)
		wait(limittime)
		if character.Humanoid:GetState() ~= desiredstate then
			checkCharacterState(character, desiredstate, limittime)
		else
			return
		end
	end
end
function ragdoll(character)
	local bool = character:WaitForChild("Ragdoll")
	bool.Value = true
	character.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
	for _, v in pairs(character:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CanCollide = true

		end
		if v:IsA("Motor6D") then
			local att0, att1 = instance("Attachment"), instance("Attachment")
			local ballSocketConstraint = instance("BallSocketConstraint")
			att0.Parent = v.Part0 att1.Parent = v.Part1
			ballSocketConstraint.Parent = v.Parent
			ballSocketConstraint.Attachment0 = att0
			ballSocketConstraint.Attachment1 = att1
			ballSocketConstraint.Name = "BSC"

			att0.CFrame = v.C0
			att1.CFrame = v.C1
			att0.Name = "ATT0"
			att1.Name = "ATT1"

			ballSocketConstraint.LimitsEnabled = true
			ballSocketConstraint.TwistLimitsEnabled = true
			ballSocketConstraint.MaxFrictionTorque = 1
			ballSocketConstraint.UpperAngle = 30
			ballSocketConstraint.TwistLowerAngle = 20
			ballSocketConstraint.Restitution = 10
			v.Enabled = false
		end

	end
end
function unragdoll(character)
	local bool = character:WaitForChild("Ragdoll")
	bool.Value = false

	for _, v in pairs(character:GetDescendants()) do
		if v:IsA("Motor6D") then
			local ATT0 = if v.Part0 then v.Part0:FindFirstChild("ATT0") else nil
			local ATT1 = if v.Part1 then v.Part1:FindFirstChild("ATT1") else nil
			local BSC = v.Parent:FindFirstChild("BSC")
			if ATT0 then
				ATT0:Destroy()
			end
			if ATT1 then
				ATT1:Destroy()
			end
			if BSC then
				BSC:Destroy()
			end

			v.Enabled = true
		end
	end
	character.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
end

function EnableRagdollForCharacter(char)
	local boolValue = Instance.new("BoolValue")
	boolValue.Parent = char
	boolValue.Name = "Ragdoll"
	char.Humanoid.BreakJointsOnDeath = false
	char.Humanoid.Died:Connect(function()
		
		if players:GetPlayerFromCharacter(char) then
			char.Strafe.Enabled = false
		end
		if char.Ragdoll.Value == false then
		ragdoll(char)
		end
		
	end)
end

function enableAnimationsforCharacter(char)
	local c;
	local folder = starterCharacterObjects.Animations:Clone()
	folder.Parent = char
	local anims = folder:GetChildren()
	local tracks = {}

	for i, v in ipairs(anims) do
		local animtrack = char.Humanoid.Animator:LoadAnimation(v)
		local trackName = v.Name
		table.insert(tracks, i, animtrack)
		
	end
	
	c = animEvent.Event:Connect(function(instruction, chosenCharacter, animationName)
		
		if chosenCharacter == char then
			if instruction == "Play Animation" then
			for i, v in pairs(anims) do
				if v.Name == animationName then
					tracks[i]:Play()
					break
				end
			end
			elseif instruction == "Ragdoll" then
				ragdoll(char)
				
				if char.Humanoid.Health > 0 then
					wait(5)
					unragdoll(char)
				end
				
			end
		end
	end)
end

workspace.ChildAdded:Connect(function(char)
	print("grah")
	if char:FindFirstChildWhichIsA("Humanoid") then
			EnableRagdollForCharacter(char)
			if not players:GetPlayerFromCharacter(char) then
				enableAnimationsforCharacter(char)
			end
			end
		
end)

for _,char in pairs(workspace:GetChildren()) do
	if char:FindFirstChildWhichIsA("Humanoid") then
		EnableRagdollForCharacter(char)
		
		if not players:GetPlayerFromCharacter(char) then
			enableAnimationsforCharacter(char)
		end
	end
end
