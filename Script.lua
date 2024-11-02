-- Fixed it. This script goes into ServerScriptService and works with a localscript given to any weapon plus a module script in said weapon called WeaponSettings.
local RS = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local PS = game:GetService("Players")
local contentProvider = game:GetService("ContentProvider")
local animHandler = RS:WaitForChild("animEvent")
local blooodHandler = RS:WaitForChild("bloodHandler")
local vfxmodule = RS:WaitForChild("spawnVFX")
local starterCharacterObjects = StarterPlayer:WaitForChild("StarterCharacterScripts")
local ServerMeleeWeaponHandler = RS:WaitForChild("MeleeWeaponHandler")
local VFX = require(vfxmodule)
local NewIstance = Instance.new
local motor6DName = "MeleeWeaponMotor6D"
local Yvector = Vector3.new(0,1,0)


PS.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(char)
		local M6D = NewIstance("Motor6D")
		M6D.Name = motor6DName
		M6D.Parent = char.HumanoidRootPart
		M6D.Part0 = player.Character.HumanoidRootPart
	end)
end)

ServerMeleeWeaponHandler.OnServerEvent:Connect(function(player, instruction, weapon, weaponSettings, p4, p5)
	if instruction == "LoadSounds" then
		local descendants = weapon:GetDescendants()
		
		for i, v in pairs(descendants) do
			if v:IsA("Sound") then
				contentProvider:PreloadAsync({v}, nil)
			end
		end
	end
	if instruction == "ConnectMotor6D" then
		local M6D = player.Character.HumanoidRootPart:FindFirstChild(motor6DName)
		if M6D then
			print("M6D found")
			M6D.Part0 = player.Character.HumanoidRootPart
			M6D.Part1 = weapon.basePart
		else
			warn(player.Name.." doesn't have a ".. motor6DName)
		end
	end
	if instruction == "DisconnectMotor6D" then
		local M6D = player.Character.HumanoidRootPart:FindFirstChild(motor6DName)
		M6D.Part1 = nil
	end
		if instruction == "Attack" then
		print("attacked")
		if #p4 == 0 then
			weapon.basePart.Swing:Play()
		else
			local pos;
			weapon.basePart.Hit:Play()
		for _, v in pairs(p4) do
			v.Humanoid:TakeDamage(weaponSettings["Damage"])
			
			local hurtAnim = p5[math.random(1,#p5)]
			animHandler:Fire("Play Animation", v, hurtAnim)
			
		if v.Humanoid.Health <= 0 then
					v.HumanoidRootPart.Velocity = player.Character.HumanoidRootPart.CFrame.LookVector*200
					blooodHandler:FireAllClients("spawnBloodDroplets", v.HumanoidRootPart.Position, 40)
				end
		if v.Humanoid.Health <= weaponSettings["ragdollHealth"] and v.Ragdoll.Value == false then
				animHandler:Fire("Ragdoll", v)
				if weaponSettings["weaponType"] == "Blunt" then
					ServerMeleeWeaponHandler:FireClient(player, "Thud")
				end
					blooodHandler:FireAllClients("spawnBloodDroplets", v.HumanoidRootPart.Position, 20)
					blooodHandler:FireAllClients("Splatter", v.Head.Position, math.random(1, 5))
					v.HumanoidRootPart.Velocity = player.Character.HumanoidRootPart.CFrame.LookVector*200
		end
				if weaponSettings["weaponType"] == "Sharp" then
					blooodHandler:FireAllClients("spawnBloodDroplets", v.HumanoidRootPart.Position, 4)
				end
			end
		end
		
		
	end
	if instruction == "Finish" then
		for _, v in pairs(p4) do
			if v.Ragdoll.Value == true then
				weapon.basePart.Hit:Play()
			v.Humanoid:TakeDamage(v.Humanoid.MaxHealth)
			v.HumanoidRootPart.Velocity += Yvector*100
				blooodHandler:FireAllClients("spawnBloodDroplets", v.HumanoidRootPart.Position, 30)
			end
		end
	end
end)
