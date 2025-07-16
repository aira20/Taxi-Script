-- ⚙️ SETTINGS
local TARGET_PATH = "World.Interactive.Mysterious Flower"
local CHECK_INTERVAL = 2
local HOP_DELAY = 2

-- 📦 SERVICES
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- 🔁 TRACKING
local PlaceId = game.PlaceId
local JobId = game.JobId
local cursor = ""
local triedServers = {}
local found = false

-- 🔍 FUNCTION: Search for Mysterious Flower
local function findMysteriousFlower()
	local node = workspace
	for segment in string.gmatch(TARGET_PATH, "[^%.]+") do
		if node:FindFirstChild(segment) then
			node = node[segment]
		else
			return nil
		end
	end
	if node:IsA("Model") then
		return node
	end
	return nil
end

-- 🌐 FUNCTION: Get Next Public Server
local function GetNewServer()
	local serverId = nil
	cursor = ""

	for attempt = 1, 10 do
		local url = ("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100%s"):format(
			PlaceId, cursor ~= "" and "&cursor=" .. cursor or ""
		)

		local success, result = pcall(function()
			return HttpService:JSONDecode(game:HttpGet(url))
		end)

		if success and result and result.data then
			for _, server in ipairs(result.data) do
				if server.playing < server.maxPlayers
					and server.id ~= JobId
					and not triedServers[server.id]
					and server.ping ~= nil
					and not server.hasSecureServer
				then
					triedServers[server.id] = true
					cursor = result.nextPageCursor or ""
					return server.id
				end
			end
			cursor = result.nextPageCursor or ""
		else
			warn("❌ Failed to fetch servers. Retrying...")
			task.wait(2)
		end
	end

	return nil
end

-- 🚀 MAIN LOOP
task.spawn(function()
	while not found do
		print("🔍 Scanning for Mysterious Flower...")
		local flower = findMysteriousFlower()

		if flower then
			warn("🌸 MYSTERIOUS FLOWER FOUND!")
			found = true
			break
		else
			print("❌ Not found. Hopping to next server...")
			task.wait(HOP_DELAY)

			local newServer = GetNewServer()
			if newServer then
				print("🔄 Teleporting to:", newServer)

				-- Optional: Requeue this script after teleport
				pcall(function()
					queueonteleport([[
						loadstring(game:HttpGet("https://pastebin.com/raw/YOUR_RAW_SCRIPT_LINK"))()
					]])
				end)

				TeleportService:TeleportToPlaceInstance(PlaceId, newServer, LocalPlayer)
				break -- Exit after teleport
			else
				warn("⚠️ No servers found. Retrying in 60 seconds...")
				task.wait(60)
			end
		end

		task.wait(CHECK_INTERVAL)
	end
end)
