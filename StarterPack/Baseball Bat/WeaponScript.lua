-- This script is placed in melee tools. Local script btw
local Players = game:GetService("Players")
local SG = game:GetService("StarterGui")
local CAS = game:GetService("ContextActionService")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local Weapon = script.Parent
local settingsModule = Weapon.WeaponSettings
local weaponSettings = require(settingsModule)
local WeaponHandler = RS:WaitForChild("MeleeWeaponHandler")
local cameraModule = SG:WaitForChild("CameraEffects")
local cameraEffects = require(cameraModule)
local mouse = player:GetMouse()
local animationTracks = {Equip = character.Humanoid.Animator:LoadAnimation(Weapon.basePart.Equip), Hold = character.Humanoid.Animator:LoadAnimation(Weapon.basePart.Hold), Attack1 = character.Humanoid.Animator:LoadAnimation(Weapon.basePart.AttackAnimations.Attack1), Attack2 = character.Humanoid.Animator:LoadAnimation(Weapon.basePart.AttackAnimations.Attack2), Finish = character.Humanoid.Animator:LoadAnimation(Weapon.basePart.Finish)}
local Attacks = {animationTracks.Attack1, animationTracks.Attack2}
local weaponFunctions = {}
local cam = workspace.CurrentCamera
local c;
local finishconnect;
local cooldown = false
local finishcooldown = false
local attackSequence = {1,2}
local weaponIsEquipped = false
local cameraOffset = Vector3.new(1, 1, 1)
local humanoidCameraOffset;
attackSequence.NextValue = function(table_, value)
	local index = table.find(table_, value, 1)
	if index == #table_ then
		return table_[1]
	else
		return table_[index+1]
	end
end
local currentAttack = Attacks[1]
print(currentAttack)


function weaponFunctions.FindTargets()
	local targets = {}
	for _, v in pairs(workspace:GetChildren()) do
		local humanoid = v:FindFirstChildWhichIsA("Humanoid")
		local humanoidRootPart = v:FindFirstChild("HumanoidRootPart")
		if humanoid and humanoidRootPart then
			if (humanoidRootPart.Position - Weapon.DamagePart.Position).Magnitude < weaponSettings["Range"] and v ~= character then
			table.insert(targets, v)
			end
		end
	end
	return targets
end

function weaponFunctions.playAndYield(animation)
	animation:Play()
	wait(animation.Length)
end

function weaponFunctions.StopAllAnimations(animationTable)
	for _, v in pairs(animationTable) do
		if v.IsPlaying then
			print("Animation Playing")
			v:Stop(.1)
		end
	end
end

function weaponFunctions.ControlledPlay(animation)
	if not animation.IsPlaying then
		animation:Play()
	end
end

function weaponFunctions.Finish(ActionName,InputState, InputObject)
	if InputState == Enum.UserInputState.Begin then
		if not finishcooldown then
			finishcooldown = true
		weaponFunctions.ControlledPlay(animationTracks.Finish)
		finishconnect = animationTracks.Finish:GetMarkerReachedSignal("Hit"):Connect(function()
			finishconnect:Disconnect()
			local targets = weaponFunctions.FindTargets()
			WeaponHandler:FireServer("Finish", Weapon, weaponSettings, targets)
		end)
		wait(weaponSettings["Cooldown"])
		finishcooldown = false
		end
	end
end
Weapon.Equipped:Connect(function()
	weaponIsEquipped = true
	character.HumanoidRootPart.MeleeWeaponMotor6D.Part1 = Weapon.basePart
	WeaponHandler:FireServer("ConnectMotor6D", Weapon, weaponSettings)
	
	weaponFunctions.playAndYield(animationTracks.Equip)
	if weaponIsEquipped then
	animationTracks.Hold:Play()
	end
	
end)
Weapon.Unequipped:Connect(function()
	weaponIsEquipped = false
	UIS.MouseBehavior = Enum.MouseBehavior.Default
	WeaponHandler:FireServer("DisconnectMotor6D")
	weaponFunctions.StopAllAnimations(animationTracks)
end)

mouse.Button1Down:Connect(function()
	if weaponIsEquipped then
		if not cooldown then
			cooldown = true
		
	print(currentAttack)
	local NextNumber = attackSequence.NextValue(Attacks, currentAttack)
	print(NextNumber)
	currentAttack = NextNumber
	weaponFunctions.ControlledPlay(currentAttack)
	c = currentAttack:GetMarkerReachedSignal("Hit"):Connect(function()
		c:Disconnect()
		local targets = weaponFunctions.FindTargets()
		WeaponHandler:FireServer("Attack", Weapon, weaponSettings, targets, weaponSettings["DamageAnimationNames"])
	end)
	
	wait(weaponSettings["Cooldown"])
	cooldown = false
		end
		end
end)

WeaponHandler.OnClientEvent:Connect(function(instruction, p2, p3, p4)
	if instruction == "Thud" then
		cameraEffects.OffsetCameraShake(character.Humanoid, 3, 1)
	end
end)
CAS:BindAction("Finish", weaponFunctions.Finish, false, Enum.KeyCode.G)
WeaponHandler:FireServer("LoadSounds", Weapon)


