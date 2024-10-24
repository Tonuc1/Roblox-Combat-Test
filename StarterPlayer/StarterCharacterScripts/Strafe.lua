local RunService = game:GetService("RunService")
local players = game:GetService("Players")
local player = players.LocalPlayer
local character = player.Character
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")
local torso_ = character:WaitForChild("Torso")
local rootJointOriginalC0 = root:WaitForChild("RootJoint").C0


local ROM = 10
local lerpSpeed = 0.005


ROM = math.rad(ROM)

local function Calculate(deltaTime, humanoidRootPart, Humanoid, torso)
	local MovementDirection = humanoidRootPart.CFrame:VectorToObjectSpace(humanoidRootPart.AssemblyLinearVelocity)
	MovementDirection = Vector3.new(MovementDirection.X/Humanoid.WalkSpeed, 0, MovementDirection.Z/Humanoid.WalkSpeed)

	local XResult = -(MovementDirection.X*(ROM-(math.abs(MovementDirection.Z)*(ROM/2))))
	local ZResult = -math.clamp(MovementDirection.Z, -ROM, ROM)

	local RootJointResult = rootJointOriginalC0*CFrame.Angles(ZResult,XResult,0)

	local LerpTime = 1-lerpSpeed ^ deltaTime

	humanoidRootPart.RootJoint.C0 = humanoidRootPart.RootJoint.C0:Lerp(RootJointResult, LerpTime)
end

RunService.RenderStepped:Connect(function(deltaTime)

	Calculate(deltaTime,root, humanoid, torso_)
end)
