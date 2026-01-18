--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ExistingRemotesFolder =
	ReplicatedStorage:FindFirstChild("Remotes") :: Folder?
if not ExistingRemotesFolder then
	ExistingRemotesFolder = Instance.new("Folder")
	ExistingRemotesFolder.Name = "Remotes"
	ExistingRemotesFolder.Parent = ReplicatedStorage
end

local RemotesFolder = ExistingRemotesFolder :: Folder

local ExistingTiltEvent =
	RemotesFolder:FindFirstChild("Tilt") :: UnreliableRemoteEvent?
if not ExistingTiltEvent then
	ExistingTiltEvent = Instance.new("UnreliableRemoteEvent")
	ExistingTiltEvent.Name = "Tilt"
	ExistingTiltEvent.Parent = RemotesFolder
end

local TiltEvent = ExistingTiltEvent :: UnreliableRemoteEvent

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
