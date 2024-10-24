local gore = {}
local RS = game:GetService("ReplicatedStorage")
local Blood = RS:WaitForChild("Blood")
local bloodDecals = Blood.bloodDecals:GetChildren()
local bloodDropSize = Vector3.new(0.08, 0.08, 0.08)
local bloodPoolColors = {Color3.new(1, 0, 0), Color3.new(0.337255, 0.0705882, 0.0705882),Color3.new(0.196078, 0, 0), Color3.new(0.701961, 0.262745, 0.207843)}
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.IgnoreWater = true

function gore.SpawnBlood(position, amount, velocity)
	for i = 0, amount, 1 do
		local c;
		local bloodDrop = Instance.new("Part")
		bloodDrop.Shape = Enum.PartType.Ball
		bloodDrop.Size = bloodDropSize * math.random(1, 2)
		bloodDrop.Parent =  workspace.bloodFolder
		bloodDrop.Position = position
		bloodDrop.Anchored = false
		bloodDrop.Velocity = Vector3.new(math.random(-1, 1), math.random(5, 10),math.random(-1, 1)) * velocity
		bloodDrop.Material = Enum.Material.Glass
		bloodDrop.Color = bloodPoolColors[math.random(1, #bloodPoolColors)]
		bloodDrop.Name = "Blood Drop"
		bloodDrop.CanQuery = false

		c = bloodDrop.Touched:Connect(function(touchedPart)

			if touchedPart.Parent and not touchedPart.Parent:IsA("Tool") and not touchedPart.Parent:FindFirstChildWhichIsA("Humanoid") and touchedPart.Name ~= bloodDrop.Name and touchedPart.Name ~= "splatterMaker" and touchedPart.Name ~= "Handle" then
				c:Disconnect()
				raycastParams.FilterDescendantsInstances = {touchedPart}
				local ray = workspace:Raycast(bloodDrop.Position, touchedPart.Position, raycastParams)
				local bloodPool = Blood.bloodPool:Clone()
				bloodPool.Anchored = true

				bloodPool.Parent = workspace.bloodFolder
				if ray then
					print("blood Pool is at "..ray.Instance.Name.."'s Position")
					bloodPool.CFrame = CFrame.lookAt(ray.Position, ray.Position + ray.Normal) * CFrame.Angles(0, math.rad(90),0)
					bloodPool.Color = bloodPoolColors[math.random(1, #bloodPoolColors)]
					bloodPool.Size = Vector3.new(0.001, math.random(0.3, 2), math.random(0.3, 2))
					bloodPool.Name = "Blood Pool"
					bloodDrop:Destroy()
					game.Debris:AddItem(bloodPool, 5)
				else
					bloodDrop:Destroy()
					bloodPool:Destroy()
				end
			end
		end)
	end
end

function gore.Splatter(splatterSize, amount, position)
	for i = 0, amount, 1 do
		local c;
		local splatterMaker = Instance.new("Part")
		
		splatterMaker.Size = Vector3.new(1,1,1)
		splatterMaker.Transparency = 1
		splatterMaker.Parent =  workspace.bloodFolder
		splatterMaker.Position = position
		splatterMaker.Anchored = false
		splatterMaker.Velocity = Vector3.new(math.random(-40, 40), math.random(-100, 100),math.random(-40, 40))
		splatterMaker.Name = "splatterMaker"
		splatterMaker.CanQuery = false

		c = splatterMaker.Touched:Connect(function(touchedPart)
 
			if touchedPart.Parent and not touchedPart.Parent:IsA("Tool") and not touchedPart.Parent:FindFirstChildWhichIsA("Humanoid") and touchedPart.Name ~= splatterMaker.Name and touchedPart.Name ~= "Handle" then
				c:Disconnect()
				raycastParams.FilterDescendantsInstances = {touchedPart}
				local ray = workspace:Raycast(splatterMaker.Position, touchedPart.Position, raycastParams)
				local splatter = bloodDecals[math.random(1, #bloodDecals)]:Clone()
				splatter.Anchored = true

				splatter.Parent = workspace.bloodFolder
				if ray then
					splatter.CFrame = CFrame.lookAt(ray.Position, ray.Position + ray.Normal)
					splatter.Size = Vector3.new(splatterSize, splatterSize, 0.001)
					splatter.Name = "Splatter"
					splatterMaker:Destroy()
					game.Debris:AddItem(splatter, 10)
				else
					splatterMaker:Destroy()
					splatter:Destroy()
				end
			end
		end)
	end
end
return gore
