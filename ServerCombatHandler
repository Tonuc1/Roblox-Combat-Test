-- Goes in ServerScriptService
local RS = game:GetService("ReplicatedStorage")
local CPS = game:GetService("ContentProvider")
local combatHandler = RS:WaitForChild("CombatHandler")
local VFXHandler = RS:WaitForChild("VFXHandler")
local VFX = RS:WaitForChild("VFX")
local soundmodule = RS:WaitForChild("spawnSFX")
local spawnSound = require(soundmodule)
local SFX = RS:WaitForChild("SFX")
local lookv3 = CFrame.new(0,0,-1)
local sizev3 = Vector3.new(10,10,0.001)
local Colors = {White = Color3.fromRGB(255,255,255)}
combatHandler.OnServerEvent:Connect(function(player, instruction, targets, damage, ragdoll)
	if instruction == "Swing" then
		spawnSound.parentAndPlaySound(SFX.Swing, player.Character.HumanoidRootPart)
		if #targets > 0 then
			task.wait(.2)
	 for _, v in ipairs(targets) do
			
			local Cframe = player.Character.HumanoidRootPart.CFrame:ToWorldSpace(lookv3).Position
			local lookat = CFrame.new(Cframe, v.HumanoidRootPart.Position)
			if v.Humanoid.Health - damage <= 0 then
				local bv = Instance.new("BodyVelocity")
				bv.Parent = v.Torso
					bv.Velocity = player.Character.HumanoidRootPart.CFrame.LookVector*3000
					game.Debris:AddItem(bv, 0.5)
				VFXHandler:FireAllClients("StrikeWind", VFX.StrikeWind, lookat, sizev3, 0.5)
				local trail = Instance.new("Trail")
				local att0, att1 = Instance.new("Attachment"), Instance.new("Attachment")
				trail.Parent = v.Torso
				att0.Parent = v.Torso
				att1.Parent = v.Torso
				trail.Enabled = true
				trail.Color = ColorSequence.new(Colors.White, Colors.White)
				trail.FaceCamera = true
				trail.Transparency = NumberSequence.new(0, 1)
				
				att1.CFrame = CFrame.new(0,0,-1)
				trail.Attachment0 = att0 trail.Attachment1 = att1
				game.Debris:AddItem(trail, 3)
				
			end
			v.Humanoid:TakeDamage(damage)
				VFXHandler:FireAllClients("SpawnParticle",VFX.StrikeEffect, 0.2, Cframe)
				spawnSound.parentAndPlaySound(SFX.Punch, player.Character.HumanoidRootPart)
			end
	 end
		
		end
end)

for _, v in pairs(SFX:GetChildren()) do
	CPS:PreloadAsync({v}, nil)
end
