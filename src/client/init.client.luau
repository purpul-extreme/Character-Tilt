--!strict

local MAX_NECK_BEND = math.rad(45)
local MAX_WAIST_BEND = math.rad(25)

local LERP_SPEED = 20
local SEND_RATE = 0.1

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local TiltRemote = ReplicatedStorage.Tilt
local Camera = workspace.CurrentCamera

-- Standard offsets for default Roblox rigs
local BaseR6NeckC1 = CFrame.new(0, -0.5, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0)
local BaseR15NeckC1 = CFrame.new(0, -0.475, 0)
local BaseR15WaistC1 = CFrame.new(0, -0.8, 0)

local LastSendTick = 0
local RemoteLookVectors = {}

local function getJoints(character: Model): (Motor6D?, Motor6D?, BasePart?)
	local head = character:FindFirstChild("Head")
	local upperTorso = character:FindFirstChild("UpperTorso")
	local torso = character:FindFirstChild("Torso")
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart") :: BasePart?

	local neck: Motor6D?
	local waist: Motor6D?

	if head and upperTorso then
		neck = head:FindFirstChild("Neck") :: Motor6D?
		waist = upperTorso:FindFirstChild("Waist") :: Motor6D?
	elseif torso then
		neck = torso:FindFirstChild("Neck") :: Motor6D?
		waist = nil
	end

	if not neck or not humanoidRootPart then
		return nil, nil, nil
	end

	return neck, waist, humanoidRootPart
end

local function onClientEvent(player: Player, lookVector: Vector3)
	RemoteLookVectors[player] = lookVector
end

local function onPreRender(deltaTimeRender: number)
	local alpha = math.clamp(deltaTimeRender * LERP_SPEED, 0, 1)

	for _, player in Players:GetPlayers() do
		local character = player.Character
		if not character then
			continue
		end

		local neck, waist, humanoidRootPart = getJoints(character)
		if not neck or not humanoidRootPart then
			continue
		end

		local lookVector: Vector3?
		if player == LocalPlayer then
			lookVector = Camera.CFrame.LookVector

			if os.clock() - LastSendTick > SEND_RATE then
				-- Only replicate to the server if there are other players to receive it
				if #Players:GetPlayers() > 1 then
					TiltRemote:FireServer(lookVector)
				end

				LastSendTick = os.clock()
			end
		else
			lookVector = RemoteLookVectors[player]
		end

		if not lookVector then
			continue
		end

		local relativeDirection = humanoidRootPart.CFrame:VectorToObjectSpace(lookVector).Unit

		local pitch = -relativeDirection.Y
		local yaw = relativeDirection.X

		if waist then
			local neckTarget = BaseR15NeckC1 * CFrame.Angles(pitch * MAX_NECK_BEND, yaw * MAX_NECK_BEND, 0)
			neck.C1 = neck.C1:Lerp(neckTarget, alpha)

			local waistTarget = BaseR15WaistC1 * CFrame.Angles(pitch * MAX_WAIST_BEND, yaw * MAX_WAIST_BEND, 0)
			waist.C1 = waist.C1:Lerp(waistTarget, alpha)
		else
			-- We use a different order of pitch, yaw because R6 differs from R15
			local neckTarget = BaseR6NeckC1 * CFrame.Angles(-pitch * MAX_NECK_BEND, 0, yaw * MAX_NECK_BEND)
			neck.C1 = neck.C1:Lerp(neckTarget, alpha)
		end
	end
end

RunService.PreRender:Connect(onPreRender)
TiltRemote.OnClientEvent:Connect(onClientEvent)
