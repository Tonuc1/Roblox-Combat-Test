-- Module Script
local camera = {}
local TS = game:GetService("TweenService")
local centerVector = Vector3.new(0,0,0)
local alttweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)

function camera.AngularCameraShake(cam, intensity, duration)
	local camCFrame = cam.CFrame
	local effect = true
	task.spawn(function()
		wait(duration)
		effect = not effect
	end)
	repeat
		local randomx, randomy, randomz = math.random(-90, 90),math.random(-10, 10),math.random(-90, 90) 
		local nextLocation = CFrame.Angles(math.rad(randomx), math.rad(randomy), math.rad(randomz))
		for i = 0, 1, 0.001 do
			task.wait(.01)
			cam.CFrame = cam.CFrame:Lerp(cam.CFrame*nextLocation, i)
		end
	until not effect
end

function camera.OffsetCameraShake(Humanoid, intensity, duration)
	local tweenduration = 1-(intensity/1.1)
	local tweenInfo = TweenInfo.new(tweenduration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true, 0)
	local returnTween = TS:Create(Humanoid, alttweenInfo, {CameraOffset = centerVector})
	local tickk = tick()
	print(duration/(tweenduration*2))
	for i = 0, math.round(duration/(tweenduration*2)), 1 do
		local randomx, randomy = math.random(-intensity*2, intensity*2), math.random(-intensity*2, intensity*2)
		local tween = TS:Create(Humanoid, tweenInfo, {CameraOffset = Vector3.new(randomx, randomy, 0)})
	tween:Play()
	tween.Completed:Wait()
	print("Tween Completed")
	continue
	end
	returnTween:Play()
	print(tick()-tickk)
end
return camera
