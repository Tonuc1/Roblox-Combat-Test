local RS = game:GetService("ReplicatedStorage")
local SG = game:GetService("StarterGui")
local players = game:GetService("Players")
local bloodHandler = RS:WaitForChild("bloodHandler")
local blood = RS:WaitForChild("Blood")
local bloodModule = SG:WaitForChild("bloodModule")
local bloodFunctions = require(bloodModule)



bloodHandler.OnClientEvent:Connect(function(instruction, position, p3)
	if instruction == "spawnBloodDroplets" then
		bloodFunctions.SpawnBlood(position, p3, 5)
	end
	if instruction == "Splatter" then
		bloodFunctions.Splatter(p3, 10, position)
	end
end)
