--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TiltEvent = ReplicatedStorage.Tilt

local function onServerEvent(player: Player, lookVector: Vector3)
	-- 1.01 allows for tiny rounding errors while blocking malicious values
	if
		typeof(lookVector) ~= "Vector3"
		or lookVector ~= lookVector
		or lookVector.Magnitude > 1.01
	then
		return
	end

	local character = player.Character
	if not character or not character:FindFirstChild("Head") then
		return
	end

	-- Send lookVector to every player except sender
	for _, otherPlayer in Players:GetPlayers() do
		if otherPlayer == player then
			continue
		end
		TiltEvent:FireClient(otherPlayer, player, lookVector)
	end
end

TiltEvent.OnServerEvent:Connect(onServerEvent)
