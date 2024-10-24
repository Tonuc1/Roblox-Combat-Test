local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local starterGUI = game:GetService("StarterGui")
local player = Players.LocalPlayer
local VFX = RS:WaitForChild("VFX")
local VFXModule = RS:WaitForChild("spawnVFX")
local CameraFXModule = starterGUI:WaitForChild("CameraEffects")
local cameraEffect = require(CameraFXModule)
local event = RS:WaitForChild("VFXHandler")
local spawnVFX = require(VFXModule)
local cam = workspace.CurrentCamera

event.OnClientEvent:Connect(function(instruction, particle, p3, p4, p5)
	if instruction == "SpawnParticle" then
		local lifetime = p3
		local position = p4
		spawnVFX.Spawn(particle, position, lifetime)
	end
	if instruction == "StrikeWind" then
		spawnVFX.StrikeWind(particle, p3, p4, p5)
		cameraEffect.OffsetCameraShake(player.Character.Humanoid, 0.99, 1)
	end
end)
