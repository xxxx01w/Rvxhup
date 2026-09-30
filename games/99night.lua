-- 99 Nights in the Forest - RVX Hub game module
-- Converted from: Foxname 99night.txt
-- Uses the shared RVX Hub Window/WindUI; does not create a second Window.

local NineNight = {}

function NineNight.Init(Window, WindUI)
	if not Window or not WindUI then
		warn("[RVX Hub] 99 Nights: Window/WindUI was not provided")
		return
	end

	-- Preserve the source lobby behavior without affecting the shared RVX window.
	if game.PlaceId == 79546208627805 then
		local ok, result = pcall(function()
			local response = game:HttpGet("https://raw.githubusercontent.com/caomod2077/Script/refs/heads/main/Fn99n_Lobby.lua")
			local chunk = loadstring(response)
			if type(chunk) ~= "function" then
				error("Lobby loader returned " .. type(chunk))
			end
			return chunk()
		end)
		if not ok then
			warn("[FN99N] Lobby script failed to load: " .. tostring(result))
		end
		return
	end

task.spawn(function()
	do
		local StarterGui = game:GetService("StarterGui")
		local genv = getgenv and getgenv() or _G

		if genv.Fn_Running or genv.fn_running then
			warn("[Fn] Script is already running.")

			pcall(function()
				StarterGui:SetCore("SendNotification", { Title = "Foxname ss2", Text = "Script already running.", Duration = 6 })
			end)

			return
		end

		genv.Fn_Running = true
		genv.fn_running = true

		pcall(function()
			StarterGui:SetCore("SendNotification", { Title = "Foxname ss2", Text = "Loading Script...", Duration = 6 })
		end)
	end

	local lib
	lib = WindUI
	local RunService, localPlayer
	local Players = game:GetService("Players")
	RunService = game:GetService("RunService")
	localPlayer = Players.LocalPlayer
	local player = localPlayer
	local ReplicatedStorage
	ReplicatedStorage = game:GetService("ReplicatedStorage")
	game:GetService("Lighting")
	local HttpService, Workspace, tbl, str, str2, fn, theme, str3, n2, fn2
	local flag, fn3, v2, n3, v3, v4, v5, v6, v7, v8
	local v9, v10, v11, v12, configManager, json, flag2, flag3, fn4, fn5
	local fn6, fn7, fn8, fn9

	do
		local UserInputService = game:GetService("UserInputService")
		HttpService = game:GetService("HttpService")
		Workspace = game:GetService("Workspace")
		game:GetService("ProximityPromptService")
		local ContentProvider = game:GetService("ContentProvider")
		local request_ = http_request or request or syn and syn.request
		local request_2

		if request_ then
			request_2 = request_
		else
			request_2 = fluxus and fluxus.request
		end

		local v = getcustomasset or getsynasset

		local fn10 = makefolder or function()
		end

		local tbl2 = { Fetch = function(arg, arg2)
			local tbl2 = arg2 or {}
			local rootDir = tbl2.RootDir or "Assets"
			local str4 = rootDir .. "/" .. (tbl2.SubDir or "Data")
			local attempts = tbl2.Attempts or 3
			local minimumSize = tbl2.MinimumSize or 120
			local proxy = tbl2.Proxy or ""
			local forceUpdate = tbl2.ForceUpdate or false

			if not isfolder(rootDir) then
				fn10(rootDir)
			end

			if not isfolder(str4) then
				fn10(str4)
			end

			local tbl3 = {}
			local tbl4 = {}

			for k, v13 in pairs(arg) do
				local str5 = v13 .. (v13:find("?") and "&" or "?") .. "v=" .. tostring(os.time())
				local str6 = tostring(k):gsub("[^%w_%-]", "")
				local match = v13:match("%.([%w]+)$") or "png"
				local str7 = string.format("%s/%s.%s", str4, str6, match)
				local ok, result = pcall(readfile, str7)

				if forceUpdate or not ok or not result or #result < minimumSize then
					if request_2 then
						for i = 1, attempts do
							local v14 = request_2({ Url = proxy .. str5, Method = "GET" })

							if v14 and v14.StatusCode == 200 and v14.Body and #v14.Body >= minimumSize then
								writefile(str7, v14.Body)
								break
							else
								task.wait(0.25)
							end
						end
					end
				end

				if isfile(str7) then
					local ok2, result2 = pcall(v, str7)

					if ok2 and result2 then
						tbl3[k] = { id = result2, ext = match }
						tbl4[#tbl4 + 1] = result2
					end
				end
			end

			if #tbl4 > 0 then
				task.spawn(function()
					pcall(function()
						ContentProvider:PreloadAsync(tbl4)
					end)
				end)
			end

			return tbl3
		end }

		tbl = {}

		task.spawn(function()
			local ok, result = pcall(function()
				return tbl2.Fetch({
					owner_icon = "https://raw.githubusercontent.com/caomod2077/test-public/refs/heads/main/Kh%C3%B4ng%20C%C3%B3%20Ti%C3%AAu%20%C4%90%E1%BB%816_20260326105044.png",
					afkar_icon = "https://raw.githubusercontent.com/afkar-gg/bot-proxy/refs/heads/main/IMG-20250523-WA0002.jpg",
				}, { ForceUpdate = false })
			end)

			if ok and type(result) == "table" then
				tbl = result
			end
		end)

		lib:AddTheme({
			Name = "Mid Summer",
			Accent = lib:Gradient({
				["0"] = { Color = Color3.fromHex("#FFD194"), Transparency = 0 },
				["50"] = { Color = Color3.fromHex("#FF7E5F"), Transparency = 0 },
				["100"] = { Color = Color3.fromHex("#FF5F6D"), Transparency = 0 },
			}, { Rotation = 45 }),
			Dialog = lib:Gradient({
				["0"] = { Color = Color3.fromHex("#FFF3E0"), Transparency = 0 },
				["50"] = { Color = Color3.fromHex("#FFE0B2"), Transparency = 0 },
				["100"] = { Color = Color3.fromHex("#FFD194"), Transparency = 0 },
			}, { Rotation = 45 }),
			Outline = lib:Gradient({
				["0"] = { Color = Color3.fromHex("#FF8C42"), Transparency = 0 },
				["50"] = { Color = Color3.fromHex("#FF7E5F"), Transparency = 0 },
				["100"] = { Color = Color3.fromHex("#FF6A88"), Transparency = 0 },
			}, { Rotation = 45 }),
			Text = lib:Gradient({
				["0"] = { Color = Color3.fromHex("#6B4226"), Transparency = 0 },
				["50"] = { Color = Color3.fromHex("#8B4513"), Transparency = 0 },
				["100"] = { Color = Color3.fromHex("#A0522D"), Transparency = 0 },
			}, { Rotation = 45 }),
			Placeholder = lib:Gradient({
				["0"] = { Color = Color3.fromHex("#D9B08C"), Transparency = 0 },
				["50"] = { Color = Color3.fromHex("#C68642"), Transparency = 0 },
				["100"] = { Color = Color3.fromHex("#B5651D"), Transparency = 0 },
			}, { Rotation = 45 }),
			Background = lib:Gradient({
				["0"] = { Color = Color3.fromHex("#FFE5B4"), Transparency = 0 },
				["50"] = { Color = Color3.fromHex("#FFC87C"), Transparency = 0 },
				["100"] = { Color = Color3.fromHex("#FFAA5C"), Transparency = 0 },
			}, { Rotation = 45 }),
			Button = lib:Gradient({
				["0"] = { Color = Color3.fromHex("#FFAA5C"), Transparency = 0 },
				["50"] = { Color = Color3.fromHex("#FF7E5F"), Transparency = 0 },
				["100"] = { Color = Color3.fromHex("#FF5F6D"), Transparency = 0 },
			}, { Rotation = 45 }),
			Icon = lib:Gradient({
				["0"] = { Color = Color3.fromHex("#FF7F50"), Transparency = 0 },
				["50"] = { Color = Color3.fromHex("#FF6A88"), Transparency = 0 },
				["100"] = { Color = Color3.fromHex("#FF5F6D"), Transparency = 0 },
			}, { Rotation = 45 }),
		})

		lib:AddTheme({
			Name = "Lunar Moon",
			Accent = lib:Gradient({
				["0"] = { Color = Color3.fromHex("#232526"), Transparency = 0 },
				["50"] = { Color = Color3.fromHex("#636363"), Transparency = 0 },
				["100"] = { Color = Color3.fromHex("#E0E0E0"), Transparency = 0 },
			}, { Rotation = 90 }),
			Dialog = lib:Gradient({
				["0"] = { Color = Color3.fromHex("#1C1C1C"), Transparency = 0 },
				["50"] = { Color = Color3.fromHex("#3A3A3A"), Transparency = 0 },
				["100"] = { Color = Color3.fromHex("#636363"), Transparency = 0 },
			}, { Rotation = 90 }),
			Outline = lib:Gradient({
				["0"] = { Color = Color3.fromHex("#B0B0B0"), Transparency = 0 },
				["50"] = { Color = Color3.fromHex("#C0C0C0"), Transparency = 0 },
				["100"] = { Color = Color3.fromHex("#E0E0E0"), Transparency = 0 },
			}, { Rotation = 90 }),
			Text = lib:Gradient({
				["0"] = { Color = Color3.fromHex("#FFFFFF"), Transparency = 0 },
				["50"] = { Color = Color3.fromHex("#D9D9D9"), Transparency = 0 },
				["100"] = { Color = Color3.fromHex("#BFBFBF"), Transparency = 0 },
			}, { Rotation = 90 }),
			Placeholder = lib:Gradient({
				["0"] = { Color = Color3.fromHex("#A0A0A0"), Transparency = 0 },
				["50"] = { Color = Color3.fromHex("#B0B0B0"), Transparency = 0 },
				["100"] = { Color = Color3.fromHex("#C0C0C0"), Transparency = 0 },
			}, { Rotation = 90 }),
			Background = lib:Gradient({
				["0"] = { Color = Color3.fromHex("#101010"), Transparency = 0 },
				["50"] = { Color = Color3.fromHex("#3A3A3A"), Transparency = 0 },
				["100"] = { Color = Color3.fromHex("#636363"), Transparency = 0 },
			}, { Rotation = 90 }),
			Button = lib:Gradient({
				["0"] = { Color = Color3.fromHex("#3A3A3A"), Transparency = 0 },
				["50"] = { Color = Color3.fromHex("#636363"), Transparency = 0 },
				["100"] = { Color = Color3.fromHex("#A2A2A2"), Transparency = 0 },
			}, { Rotation = 90 }),
			Icon = lib:Gradient({
				["0"] = { Color = Color3.fromHex("#C0C0C0"), Transparency = 0 },
				["50"] = { Color = Color3.fromHex("#E0E0E0"), Transparency = 0 },
				["100"] = { Color = Color3.fromHex("#FFFFFF"), Transparency = 0 },
			}, { Rotation = 90 }),
		})

		lib:AddTheme({
			Name = "Winter Frost",
			Accent = lib:Gradient({
				["0"] = { Color = Color3.fromHex("#D0E8F2"), Transparency = 0 },
				["50"] = { Color = Color3.fromHex("#A0D4F2"), Transparency = 0 },
				["100"] = { Color = Color3.fromHex("#70C0F2"), Transparency = 0 },
			}, { Rotation = 45 }),
			Dialog = lib:Gradient({
				["0"] = { Color = Color3.fromHex("#E0F7FF"), Transparency = 0 },
				["50"] = { Color = Color3.fromHex("#B0EFFF"), Transparency = 0 },
				["100"] = { Color = Color3.fromHex("#80E7FF"), Transparency = 0 },
			}, { Rotation = 45 }),
			Outline = lib:Gradient({
				["0"] = { Color = Color3.fromHex("#70C0F2"), Transparency = 0 },
				["50"] = { Color = Color3.fromHex("#50B0E0"), Transparency = 0 },
				["100"] = { Color = Color3.fromHex("#30A0D0"), Transparency = 0 },
			}, { Rotation = 45 }),
			Text = lib:Gradient({
				["0"] = { Color = Color3.fromHex("#0D3B66"), Transparency = 0 },
				["50"] = { Color = Color3.fromHex("#145DA0"), Transparency = 0 },
				["100"] = { Color = Color3.fromHex("#1E81B0"), Transparency = 0 },
			}, { Rotation = 45 }),
			Placeholder = lib:Gradient({
				["0"] = { Color = Color3.fromHex("#7FB3D5"), Transparency = 0 },
				["50"] = { Color = Color3.fromHex("#5FA2C5"), Transparency = 0 },
				["100"] = { Color = Color3.fromHex("#3F91B5"), Transparency = 0 },
			}, { Rotation = 45 }),
			Background = lib:Gradient({
				["0"] = { Color = Color3.fromHex("#E6F0FA"), Transparency = 0 },
				["50"] = { Color = Color3.fromHex("#CDE0F5"), Transparency = 0 },
				["100"] = { Color = Color3.fromHex("#B4D1F0"), Transparency = 0 },
			}, { Rotation = 45 }),
			Button = lib:Gradient({
				["0"] = { Color = Color3.fromHex("#50B0E0"), Transparency = 0 },
				["50"] = { Color = Color3.fromHex("#30A0D0"), Transparency = 0 },
				["100"] = { Color = Color3.fromHex("#108FC0"), Transparency = 0 },
			}, { Rotation = 45 }),
			Icon = lib:Gradient({
				["0"] = { Color = Color3.fromHex("#30A0D0"), Transparency = 0 },
				["50"] = { Color = Color3.fromHex("#108FC0"), Transparency = 0 },
				["100"] = { Color = Color3.fromHex("#0D81B0"), Transparency = 0 },
			}, { Rotation = 45 }),
		})

		lib:AddTheme({
			Name = "Elegant Night",
			Accent = lib:Gradient({
				["0"] = { Color = Color3.fromHex("#3B0D5C"), Transparency = 0 },
				["50"] = { Color = Color3.fromHex("#6A1B9A"), Transparency = 0 },
				["100"] = { Color = Color3.fromHex("#9C27B0"), Transparency = 0 },
			}, { Rotation = 45 }),
			Dialog = lib:Gradient({
				["0"] = { Color = Color3.fromHex("#1A001A"), Transparency = 0 },
				["50"] = { Color = Color3.fromHex("#3D003D"), Transparency = 0 },
				["100"] = { Color = Color3.fromHex("#6A006A"), Transparency = 0 },
			}, { Rotation = 45 }),
			Outline = lib:Gradient({
				["0"] = { Color = Color3.fromHex("#9C27B0"), Transparency = 0 },
				["50"] = { Color = Color3.fromHex("#7B1FA2"), Transparency = 0 },
				["100"] = { Color = Color3.fromHex("#6A1B9A"), Transparency = 0 },
			}, { Rotation = 45 }),
			Text = lib:Gradient({
				["0"] = { Color = Color3.fromHex("#FFFFFF"), Transparency = 0 },
				["50"] = { Color = Color3.fromHex("#E0E0E0"), Transparency = 0 },
				["100"] = { Color = Color3.fromHex("#C0C0C0"), Transparency = 0 },
			}, { Rotation = 45 }),
			Placeholder = lib:Gradient({
				["0"] = { Color = Color3.fromHex("#B0A0B5"), Transparency = 0 },
				["50"] = { Color = Color3.fromHex("#9C8FA0"), Transparency = 0 },
				["100"] = { Color = Color3.fromHex("#7B6F8C"), Transparency = 0 },
			}, { Rotation = 45 }),
			Background = lib:Gradient({
				["0"] = { Color = Color3.fromHex("#10001A"), Transparency = 0 },
				["50"] = { Color = Color3.fromHex("#1A0033"), Transparency = 0 },
				["100"] = { Color = Color3.fromHex("#30004D"), Transparency = 0 },
			}, { Rotation = 45 }),
			Button = lib:Gradient({
				["0"] = { Color = Color3.fromHex("#6A1B9A"), Transparency = 0 },
				["50"] = { Color = Color3.fromHex("#9C27B0"), Transparency = 0 },
				["100"] = { Color = Color3.fromHex("#B55BC5"), Transparency = 0 },
			}, { Rotation = 45 }),
			Icon = lib:Gradient({
				["0"] = { Color = Color3.fromHex("#9C27B0"), Transparency = 0 },
				["50"] = { Color = Color3.fromHex("#B55BC5"), Transparency = 0 },
				["100"] = { Color = Color3.fromHex("#D084E0"), Transparency = 0 },
			}, { Rotation = 45 }),
		})

		lib:AddTheme({
			Name = "Lunar Abyss",
			Accent = lib:Gradient({
				["0"] = { Color = Color3.fromHex("#0D0D1A"), Transparency = 0 },
				["50"] = { Color = Color3.fromHex("#1A1A33"), Transparency = 0 },
				["100"] = { Color = Color3.fromHex("#2E2E5C"), Transparency = 0 },
			}, { Rotation = 90 }),
			Dialog = lib:Gradient({
				["0"] = { Color = Color3.fromHex("#101026"), Transparency = 0 },
				["50"] = { Color = Color3.fromHex("#1A1A3D"), Transparency = 0 },
				["100"] = { Color = Color3.fromHex("#333366"), Transparency = 0 },
			}, { Rotation = 90 }),
			Outline = lib:Gradient({
				["0"] = { Color = Color3.fromHex("#2E2E5C"), Transparency = 0 },
				["50"] = { Color = Color3.fromHex("#404080"), Transparency = 0 },
				["100"] = { Color = Color3.fromHex("#5050A0"), Transparency = 0 },
			}, { Rotation = 90 }),
			Text = lib:Gradient({
				["0"] = { Color = Color3.fromHex("#A0A0FF"), Transparency = 0 },
				["50"] = { Color = Color3.fromHex("#C0C0FF"), Transparency = 0 },
				["100"] = { Color = Color3.fromHex("#E0E0FF"), Transparency = 0 },
			}, { Rotation = 90 }),
			Placeholder = lib:Gradient({
				["0"] = { Color = Color3.fromHex("#6060A0"), Transparency = 0 },
				["50"] = { Color = Color3.fromHex("#8080C0"), Transparency = 0 },
				["100"] = { Color = Color3.fromHex("#A0A0E0"), Transparency = 0 },
			}, { Rotation = 90 }),
			Background = lib:Gradient({
				["0"] = { Color = Color3.fromHex("#0A0A1A"), Transparency = 0 },
				["50"] = { Color = Color3.fromHex("#1A1A33"), Transparency = 0 },
				["100"] = { Color = Color3.fromHex("#2E2E5C"), Transparency = 0 },
			}, { Rotation = 90 }),
			Button = lib:Gradient({
				["0"] = { Color = Color3.fromHex("#404080"), Transparency = 0 },
				["50"] = { Color = Color3.fromHex("#5050A0"), Transparency = 0 },
				["100"] = { Color = Color3.fromHex("#6060C0"), Transparency = 0 },
			}, { Rotation = 90 }),
			Icon = lib:Gradient({
				["0"] = { Color = Color3.fromHex("#6060C0"), Transparency = 0 },
				["50"] = { Color = Color3.fromHex("#8080E0"), Transparency = 0 },
				["100"] = { Color = Color3.fromHex("#A0A0FF"), Transparency = 0 },
			}, { Rotation = 90 }),
		})

		lib:AddTheme({
			Name = "Lunar Eclipse",
			Accent = lib:Gradient({
				["0"] = { Color = Color3.fromHex("#33001A"), Transparency = 0 },
				["50"] = { Color = Color3.fromHex("#660033"), Transparency = 0 },
				["100"] = { Color = Color3.fromHex("#99004D"), Transparency = 0 },
			}, { Rotation = 45 }),
			Dialog = lib:Gradient({
				["0"] = { Color = Color3.fromHex("#1A0014"), Transparency = 0 },
				["50"] = { Color = Color3.fromHex("#330028"), Transparency = 0 },
				["100"] = { Color = Color3.fromHex("#66003F"), Transparency = 0 },
			}, { Rotation = 45 }),
			Outline = lib:Gradient({
				["0"] = { Color = Color3.fromHex("#99004D"), Transparency = 0 },
				["50"] = { Color = Color3.fromHex("#CC3366"), Transparency = 0 },
				["100"] = { Color = Color3.fromHex("#FF6699"), Transparency = 0 },
			}, { Rotation = 45 }),
			Text = lib:Gradient({
				["0"] = { Color = Color3.fromHex("#FFE6F0"), Transparency = 0 },
				["50"] = { Color = Color3.fromHex("#FFB3CC"), Transparency = 0 },
				["100"] = { Color = Color3.fromHex("#FF80A0"), Transparency = 0 },
			}, { Rotation = 45 }),
			Placeholder = lib:Gradient({
				["0"] = { Color = Color3.fromHex("#CC6699"), Transparency = 0 },
				["50"] = { Color = Color3.fromHex("#FF99CC"), Transparency = 0 },
				["100"] = { Color = Color3.fromHex("#FFB3D9"), Transparency = 0 },
			}, { Rotation = 45 }),
			Background = lib:Gradient({
				["0"] = { Color = Color3.fromHex("#1A0014"), Transparency = 0 },
				["50"] = { Color = Color3.fromHex("#330028"), Transparency = 0 },
				["100"] = { Color = Color3.fromHex("#66003F"), Transparency = 0 },
			}, { Rotation = 45 }),
			Button = lib:Gradient({
				["0"] = { Color = Color3.fromHex("#66003F"), Transparency = 0 },
				["50"] = { Color = Color3.fromHex("#99004D"), Transparency = 0 },
				["100"] = { Color = Color3.fromHex("#CC3366"), Transparency = 0 },
			}, { Rotation = 45 }),
			Icon = lib:Gradient({
				["0"] = { Color = Color3.fromHex("#99004D"), Transparency = 0 },
				["50"] = { Color = Color3.fromHex("#CC3366"), Transparency = 0 },
				["100"] = { Color = Color3.fromHex("#FF6699"), Transparency = 0 },
			}, { Rotation = 45 }),
		})

		str = "__autosave"
		str2 = "rbxassetid://133610205520685"
		local udim2 = UDim2.fromOffset(680, 620)
		local udim22 = UDim2.fromOffset(580, 350)
		local function fn11(I)if makefolder and isfolder and not isfolder(I)then pcall(makefolder,I);end;end
		local function fn12(k,a)if not isfile or not readfile or not isfile(k)then return a;end;local K,S=pcall(function()return  HttpService :JSONDecode(readfile(k));end);return K and type(S)=="table"and S or a;end

		local function fn13(arg, arg2)
			if type(writefile) ~= "function" then
				return false
			end

			return (pcall(function()
				writefile(arg, HttpService:JSONEncode(arg2))
			end))
		end

		fn = function(I)I=tostring(I or""):match("^%s*(.-)%s*$");if I==""then return nil;end;if I:match("^%d+$")then return"rbxassetid://"..I;end;return I;end
		fn11("WindUI")
		fn11("WindUI/99NightsInTheForest")
		fn11("Foxname_99Nights")
		local json2 = fn12("Foxname_99Nights/WindowPrefs.json", {})
		theme = json2.Theme or "Elegant Night"
		str3 = fn(json2.BackgroundImage) or "rbxassetid://133610205520685"
		n2 = math.clamp(tonumber(json2.BackgroundImageTransparency) or 0.6, 0, 1)

		if not lib:GetThemes()[theme] then
			theme = "Elegant Night"
		end

		fn2 = function(...) end
		flag = true
		local touchEnabled = UserInputService.TouchEnabled

		if player and player.OsPlatform then
			local osPlatform = player.OsPlatform

			if osPlatform == Enum.Platform.IOS or osPlatform == Enum.Platform.Android then
				touchEnabled = true
			end
		end

		local function fn14(arg, arg2, arg3)
			local n = #arg
			local str4 = ""

			for i = 1, n do
				local n4 = (i - 1) / math.max(n - 1, 1)
				local n5 = math.floor(arg2.R * 255 + (arg3.R * 255 - arg2.R * 255) * n4)
				local n6 = math.floor(arg2.G * 255 + (arg3.G * 255 - arg2.G * 255) * n4)
				local n7 = math.floor(arg2.B * 255 + (arg3.B * 255 - arg2.B * 255) * n4)
				local format = string.format
				local str5 = arg:sub(i, i)
				str4 ..= format("<font color=\"rgb(%d,%d,%d)\">%s</font>", n5, n6, n7, str5)
			end

			return str4
		end

		local color = Color3.fromRGB
		fn3 = function(...) end

		v2 = Window
		v2.IsPC = not touchEnabled
		n3 = 0.9

		-- RVX Hub: use the shared game section/window instead of creating a second WindUI window.
		local rvxGameSection = Window.RVXGameSection or Window:Section({
			Title = "99 Nights",
			Icon = "trees",
			Opened = true,
		})

		-- Keep the original tab variables so the existing 99 Nights systems remain intact.
		v3 = rvxGameSection:Tab({ Title = "Discord", Icon = "messages-square" })
		v4 = rvxGameSection:Tab({ Title = "อัปเดต", Icon = "zap" })
		v5 = rvxGameSection:Tab({ Title = "สนับสนุน", Icon = "heart-handshake" })
		v6 = rvxGameSection:Tab({ Title = "หลัก", Icon = "terminal" })
		v7 = rvxGameSection:Tab({ Title = "นำของ", Icon = "package-open" })
		v8 = rvxGameSection:Tab({ Title = "วาร์ป", Icon = "map-pin" })
		v9 = rvxGameSection:Tab({ Title = "ผู้เล่น", Icon = "user" })
		v10 = rvxGameSection:Tab({ Title = "อื่นๆ", Icon = "sparkles" })
		v11 = rvxGameSection:Tab({ Title = "ต้นไม้", Icon = "tree-pine" })
		v12 = rvxGameSection:Tab({ Title = "ตั้งค่า 99 Nights", Icon = "settings" })
		configManager = v2.ConfigManager
		v2.PendingFlags = v2.PendingFlags or {}
		local json3 = fn12("WindUI/99NightsInTheForest/autosave-state.json", { enabled = true })
		json = fn12("WindUI/99NightsInTheForest/autoload-state.json", { enabled = false, name = "" })
		flag2 = json3.enabled ~= false
		flag3 = true
		local flag4 = false
		local autosave = (type(configManager) == "table" or type(configManager) == "userdata") and type(configManager.CreateConfig) == "function" and configManager:CreateConfig("__autosave") or nil
		fn4 = function(...) end
		fn5 = function(...) end

		fn6 = function()
			if not flag2 or flag3 then
				return
			end

			if autosave then
				if v2.PendingFlags then
					for k, pendingFlag in pairs(v2.PendingFlags) do
						autosave:Register(k, pendingFlag)
					end
				end

				pcall(function()
					autosave:Save()
				end)
			end

			if v2 and v2.GetFlags and v2.GetFlags then
				local ok, result = pcall(function()
					return v2:GetFlags()
				end)

				if ok and type(result) == "table" then
					local fn15 = nil

					fn15 = function(arg, arg2)
						if arg2 > 8 then
							return nil
						end
						local kind = typeof(arg)
						if kind == "EnumItem" then
							return arg.Name
						end

						if kind == "string" or kind == "number" or kind == "boolean" then
							return arg
						end

						if kind ~= "table" then
							return nil
						end
						local tbl3 = {}

						for k, v15 in pairs(arg) do
							local v16 = fn15(v15, arg2 + 1)

							if v16 ~= nil then
								tbl3[k] = v16
							end
						end

						return tbl3
					end

					local v15 = fn13
					local v16 = fn15(result, 0)
					v15("WindUI/99NightsInTheForest/autosave-flags.json", v16)
				end
			end
		end

		fn7 = function()
			task.spawn(function()
				task.wait(0.05)
				flag3 = true

				if v2.PendingFlags and autosave then
					for k, pendingFlag in pairs(v2.PendingFlags) do
						autosave:Register(k, pendingFlag)
					end
				end

				local path = flag2 and autosave and isfile and autosave.Path and isfile(autosave.Path)
				local flag5 = false

				if path then
					flag5 = pcall(function()
						autosave:Load()
					end)

					if flag5 then
						fn3("Config", "Auto save restored", "check", 3)
					end
				end

				if not flag5 and configManager and json.enabled and validConfigName(json.name) then
					selectedConfigName = json.name

					if pcall(function()
						local v15 = configManager:CreateConfig(json.name)

						if v2.PendingFlags then
							for k, pendingFlag in pairs(v2.PendingFlags) do
								v15:Register(k, pendingFlag)
							end
						end

						v15:Load()
					end) then
						fn3("Config", "Auto loaded: " .. json.name, "check", 3)
					end
				end

				task.delay(0.5, function()
					flag3 = false
					fn6()
				end)
			end)
		end

		fn8 = function()
			if not flag2 or flag4 then
				return
			end
			flag4 = true

			task.delay(0.75, function()
				flag4 = false
				fn6()
			end)
		end

		local function fn15(I)local k={};for a,K in pairs(I or{})do k[a]=K;end;return k;end
		local function fn16(I)local k=tostring(I or"Control"):gsub("[^%w]+","_"):gsub("^_+",""):gsub("_+$","");return k~=""and k or"Control";end
		local str4 = "Select All"
		local function fn17(I)return type(I)=="table"and(I.Value or I.Title)or I;end

		local function fn18(arg)
			local tbl3 = {}
			local v15 = ipairs
			local tbl4 = arg or {}

			for _, v16 in v15(tbl4) do
				table.insert(tbl3, v16)
			end

			return tbl3
		end

		local function fn19(arg)
			local tbl3 = { "Select All" }
			local v15 = ipairs
			arg = arg or {}

			for _, v16 in v15(arg) do
				local v17 = fn17(v16)

				if v17 and v17 ~= str4 then
					table.insert(tbl3, v16)
				end
			end

			return tbl3
		end

		local function fn20(arg)
			local v15 = pairs
			local tbl3 = arg or {}

			for k, v16 in v15(tbl3) do
				if (type(k) == "number" and fn17(v16) or v16 == true and k or nil) == str4 then
					return true
				end
			end

			return false
		end

		local function fn21(arg, arg2)
			if not fn20(arg) then
				return arg
			end
			local tbl3 = {}
			local v15 = ipairs
			arg2 = arg2 or {}

			for _, v16 in v15(arg2) do
				local flag5 = type(v16) == "table" and v16.Locked == true
				local flag6 = type(v16) == "table" and v16.Type == "Divider"
				local v17 = fn17(v16)

				if not flag5 and not flag6 and v17 ~= nil and v17 ~= str4 then
					table.insert(tbl3, v17)
				end
			end

			return tbl3
		end

		fn9 = function(arg, arg2)
			if not arg or arg.__FoxnameConfigTracked then
				return arg
			end
			arg.__FoxnameConfigTracked = true

			for _, v15 in ipairs({ "Toggle", "Dropdown", "Slider", "Input", "Colorpicker", "Keybind" }) do
				local v16 = arg[v15]

				if v16 then
					arg[v15] = function(arg3, arg4, ...)
						local flag5 = type(arg4) == "table" and fn15(arg4) or arg4

						if type(flag5) == "table" and not flag5.Flag and arg2 then
							flag5.Flag = arg2 .. "_" .. v15 .. "_" .. fn16(flag5.Title)
						end

						local v17 = nil

						if v15 == "Dropdown" and type(flag5) == "table" and flag5.Multi then
							v17 = fn18(flag5.Values)
							flag5.Values = fn19(v17)
						end

						if type(type(flag5) == "table" and flag5.Callback or nil) == "function" then
							flag5.Callback = function(...) end
						end

						local v18 = table.pack(...)
						local v19 = v16
						v18.n = 3 + v18.n - 1
						table.move(v18, 1, v18.n, 3, v18)
						v18[1] = arg3
						v18[2] = flag5
						local v20 = v19(table.unpack(v18, 1, v18.n))

						if v20 and type(flag5) == "table" and flag5.Flag then
							v2.PendingFlags = v2.PendingFlags or {}
							v2.PendingFlags[flag5.Flag] = v20

							if autosave then
								autosave:Register(flag5.Flag, v20)
							end
						end

						if v17 and v20 and v20.Refresh then
							local refresh = v20.Refresh

							v20.Refresh = function(arg5, arg6)
								v17 = fn18(arg6)
								return refresh(arg5, fn19(v17))
							end
						end

						return v20
					end
				end
			end

			for _, v15 in ipairs({ "Button", "Paragraph", "Divider", "Space" }) do
				local v16 = arg[v15]

				if v16 then
					arg[v15] = function(arg3, arg4, ...)
						local v17 = table.pack(...)
						local v18 = v16
						v17.n = 3 + v17.n - 1
						table.move(v17, 1, v17.n, 3, v17)
						v17[1] = arg3
						v17[2] = arg4
						return v18(table.unpack(v17, 1, v17.n))
					end
				end
			end

			return arg
		end

		local function fn22(arg, arg2)
			if not arg or arg.__FoxnameTabTracked then
				return
			end
			arg.__FoxnameTabTracked = true
			local section = arg.Section

			if section then
				arg.Section = function(arg3, arg4, ...)
					local flag5 = type(arg4) == "table"
					local configFlagKey

					if flag5 then
						configFlagKey = arg4.ConfigFlagKey or arg4.Title
					else
						configFlagKey = flag5
					end

					configFlagKey = configFlagKey or "Section"
					local flag6 = type(arg4) == "table" and fn15(arg4) or arg4

					if type(flag6) == "table" then
						flag6.ConfigFlagKey = nil
					end

					local v15 = table.pack(...)
					local v16 = section
					v15.n = 3 + v15.n - 1
					table.move(v15, 1, v15.n, 3, v15)
					v15[1] = arg3
					v15[2] = flag6
					return fn9(v16(table.unpack(v15, 1, v15.n)), arg2 and arg2 .. "_" .. fn16(configFlagKey) or nil)
				end
			end

			for _, v15 in ipairs({
				"Toggle",
				"Dropdown",
				"Slider",
				"Input",
				"Colorpicker",
				"Keybind",
				"Button",
				"Paragraph",
				"Divider",
				"Space",
			}) do
				local v16 = arg[v15]

				if v16 then
					arg[v15] = function(arg3, arg4, ...)
						local v17 = table.pack(...)
						local v18 = v16
						v17.n = 3 + v17.n - 1
						table.move(v17, 1, v17.n, 3, v17)
						v17[1] = arg3
						v17[2] = arg4
						return v18(table.unpack(v17, 1, v17.n))
					end
				end
			end
		end

		fn22(v3, "Discord")
		fn22(v4, "NewUpdate")
		fn22(v5, "Donate")
		fn22(v6, "Main")
		fn22(v7, "Bring")
		fn22(v8, "Teleport")
		fn22(v9, "LocalPlayer")
		fn22(v10, "Misc")
		fn22(v11, "Tree")
		fn22(v12, "Settings")
	end

	do
		local items = Workspace:WaitForChild("Items", 5) or Workspace:FindFirstChild("Items") or Workspace
		local tbl2 = {}

		for k in pairs(lib:GetThemes()) do
			table.insert(tbl2, k)
		end

		local function fn10(arg)
			if #arg == 0 then
				return
			end
			local cFrame = (localPlayer.Character or localPlayer.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart").CFrame

			if _G.ItemToPos == "Campfire" then
				cFrame = CFrame.new(0, 18, 0)
			elseif _G.ItemToPos == "Scrapper" then
				local scrapper = Workspace.Map.Campground:FindFirstChild("Scrapper")
				scrapper = scrapper and scrapper:FindFirstChildWhichIsA("BasePart")

				if scrapper then
					cFrame = scrapper.CFrame + Vector3.new(0, 15, 0)
				end
			end

			local requestStartDraggingItem = ReplicatedStorage.RemoteEvents.RequestStartDraggingItem
			local stopDraggingItem = ReplicatedStorage.RemoteEvents.StopDraggingItem

			for _, child in ipairs(items:GetChildren()) do
				if child:IsA("Model") and child.PrimaryPart and not string.find(string.lower(child.Name), "chest", 1, true) and table.find(arg, child.Name) then
					local primaryPart = child.PrimaryPart

					pcall(function()
						requestStartDraggingItem:FireServer(child)
					end)

					child:PivotTo(cFrame + Vector3.new(0, 2, 0))
					primaryPart.AssemblyLinearVelocity = Vector3.new(0, -25, 0)

					pcall(function()
						stopDraggingItem:FireServer(child)
					end)
				end
			end
		end

		local function fn11(arg)
			if #arg == 0 then
				return
			end
			local cFrame = (localPlayer.Character or localPlayer.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart").CFrame

			if _G.ItemToPos == "Campfire" then
				cFrame = CFrame.new(0, 18, 0)
			elseif _G.ItemToPos == "Scrapper" then
				local scrapper = Workspace.Map.Campground:FindFirstChild("Scrapper")
				scrapper = scrapper and scrapper:FindFirstChildWhichIsA("BasePart")

				if scrapper then
					cFrame = scrapper.CFrame + Vector3.new(0, 15, 0)
				end
			end

			local requestStartDraggingItem = ReplicatedStorage.RemoteEvents.RequestStartDraggingItem
			local stopDraggingItem = ReplicatedStorage.RemoteEvents.StopDraggingItem

			for _, child in ipairs(items:GetChildren()) do
				if child:IsA("Model") and child.PrimaryPart and not string.find(string.lower(child.Name), "chest", 1, true) and table.find(arg, child.Name) then
					local primaryPart = child.PrimaryPart

					pcall(function()
						requestStartDraggingItem:FireServer(child)
					end)

					child:PivotTo(cFrame + Vector3.new(0, 2, 0))
					primaryPart.AssemblyLinearVelocity = Vector3.new(0, -25, 0)

					pcall(function()
						stopDraggingItem:FireServer(child)
					end)

					task.wait(0.05)
				end
			end
		end
	end

	local localPlayer2
	localPlayer2 = game.Players.LocalPlayer

	if not localPlayer2.Character then
		localPlayer2.CharacterAdded:Wait()
	end

	game.ReplicatedStorage:WaitForChild("RemoteEvents", 5)
	localPlayer2:WaitForChild("Inventory", 5)

	do
		local characters = workspace:WaitForChild("Characters", 5)
		_G.KillAura = false
		_G.KillAuraRange = 100
		_G.GunAura = false
		_G.GunAuraRange = 150
		_G.ChopAura = false
		_G.ChopAuraRange = 100
		_G.ChopTreeType = {}
		v6:Space()

		local v = v6:Section({
			Title = "Combat Aura",
			ConfigFlagKey = "Kill Aura",
			Icon = "swords",
			Box = true,
			BoxBorder = true,
			Opened = true,
		})

		local overlapParams = OverlapParams.new()
		overlapParams.FilterType = Enum.RaycastFilterType.Include
		overlapParams.FilterDescendantsInstances = { characters }
		overlapParams.MaxParts = 0
		getgenv()
		require(localPlayer2.PlayerScripts:WaitForChild("Client"))
		local tbl2 = { ["Lost Child"] = true, Pelt = true, Deer = true, PeltTrader = true, Ram = true, Owl = true }

		local function fn10(arg)
			for k in pairs(tbl2) do
				if string.find(arg, k, 1, true) then
					return true
				end
			end

			return false
		end

		local function fn11(arg)
			local model = arg:FindFirstAncestorOfClass("Model")

			while model and model.Parent ~= characters do
				local parent = model.Parent
				model = parent and parent:IsA("Model") and parent or parent and parent:FindFirstAncestorOfClass("Model")
			end

			return model
		end

		local function fn12(arg)
			local parent = arg

			while parent and parent ~= Workspace do
				if parent:IsA("Model") then
					local attribute = parent:GetAttribute("Resource")
					if attribute == "IceBlock" or attribute == "MeteorNode" then
						return parent, attribute
					end
				end

				parent = parent.Parent
			end

			return fn11(arg), nil
		end

		v:Toggle({ Title = "Kill Aura", Default = false, Callback = function(...) end })

		v:Slider({
			Title = "Kill Aura Range",
			Step = 1,
			Value = { Min = 0, Max = 150, Default = 100 },
			Callback = function(I)_G.KillAuraRange=tonumber(I);end,
		})

		local genv = getgenv()
		genv.__FN99LiveGunAuraVersion = (genv.__FN99LiveGunAuraVersion or 0) + 1
		genv.__FN99GunReloadFixVersion = (genv.__FN99GunReloadFixVersion or 0) + 1
		local Client = require(localPlayer2.PlayerScripts:WaitForChild("Client"))
		local v13 = nil
		local n = 0
		local overlapParams2 = OverlapParams.new()
		overlapParams2.FilterType = Enum.RaycastFilterType.Include
		overlapParams2.FilterDescendantsInstances = { characters }
		overlapParams2.MaxParts = 0

		local function fn13(arg, arg2, arg3)
			if type(arg) ~= "table" or not arg3 and rawget(arg, "Equipped") ~= true then
				return false
			end
			local character = localPlayer2.Character
			local value = rawget(arg, "RealModel")
			local value2 = rawget(arg, "Model")
			return typeof(value) == "Instance" and value == arg2 and value:IsDescendantOf(localPlayer2) and value:GetAttribute("ToolName") == "Firearm" and typeof(value2) == "Instance" and typeof(character) == "Instance" and value2:IsDescendantOf(character) and value2:FindFirstChild("Barrel", true) ~= nil
		end

		local function fn14()
			local v14 = Client.InventoryHandler.GetCurrentlyEquipped()
			if typeof(v14) ~= "Instance" or v14:GetAttribute("ToolName") ~= "Firearm" then
				v13 = nil
				return nil
			end
			local v15 = Client.InventoryHandler.GetCurrentlyEquippedClass()
			local value = type(v15) == "table" and rawget(v15, "Tool") or nil
			if fn13(value, v14, true) then
				v13 = value
				return value
			end

			if fn13(v13, v14, false) then
				return v13
			end
			v13 = nil
			if os.clock() - n < 1 then
				return nil
			end
			n = os.clock()
			if type(getgc) ~= "function" then
				return nil
			end
			local ok, result = pcall(getgc, true)
			if not ok or type(result) ~= "table" then
				return nil
			end

			for _, v16 in ipairs(result) do
				if fn13(v16, v14, false) then
					local v17 = getmetatable(v16)
					if type(rawget(v16, "Reload") or type(v17) == "table" and rawget(v17, "Reload")) == "function" then
						v13 = v16
						return v16
					end
				end
			end

			return nil
		end

		local function fn15(arg)
			local n4 = tonumber(_G.GunAuraRange) or 150
			local tbl3 = {}
			overlapParams2.FilterDescendantsInstances = { characters }
			local v14 = nil
			local v15 = nil

			for _, v16 in ipairs(Workspace:GetPartBoundsInRadius(arg, n4, overlapParams2)) do
				local model = v16:FindFirstAncestorOfClass("Model")

				while model and model.Parent ~= characters do
					local parent = model.Parent
					model = parent and parent:IsA("Model") and parent or parent and parent:FindFirstAncestorOfClass("Model")
				end

				if not (not model or tbl3[model]) then
					tbl3[model] = true

					if not (not model:IsA("Model") or not model:HasTag("NPC") or model:GetAttribute("NotAttackable") or model:GetAttribute("NotDamageable") or model:GetAttribute("Destroyed") or model:GetAttribute("Dead") or model:GetAttribute("Lost") or model:GetAttribute("CanBeBagged") or model:GetAttribute("Tamed") and model.Name ~= "Chick") then
						local head = model:FindFirstChild("Head")

						if head and not head:IsA("BasePart") then
							head = head:FindFirstChildWhichIsA("BasePart", true)
						end

						local humanoidRootPart = head or model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)

						if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
							local magnitude = (humanoidRootPart.Position - arg).Magnitude

							if magnitude <= n4 then
								n4 = magnitude
								v14 = humanoidRootPart
								v15 = model
							end
						end
					end
				end
			end

			return v15, v14, n4
		end

		local function fn16(arg)
			if type(arg) ~= "table" or type(rawget(arg, "Ammo")) ~= "number" or type(rawget(arg, "MagazineSize")) ~= "number" or arg.Ammo >= arg.MagazineSize then
				return
			end
			local value = rawget(arg, "RealModel")
			if typeof(value) ~= "Instance" then
				return
			end
			local now = os.clock()
			if now < (tonumber(rawget(arg, "__FN99NextReloadAttempt")) or 0) then
				return
			end
			arg.__FN99NextReloadAttempt = now + 0.2
			local attribute = value:GetAttribute("ServerReloading")

			if not attribute then
				attribute = (value:GetAttribute("AmmoType") or "RifleAmmo") == "Energy"
			end

			if attribute then
				return
			end
			arg.Reloading = true

			local ok, result = pcall(function()
				return Client.Events.RequestReloadFirearm:InvokeServer(value)
			end)

			arg.Reloading = false

			if ok and type(result) == "table" and result.Success == true and type(result.Ammo) == "number" then
				arg.Ammo = result.Ammo
				arg.__FN99NextReloadAttempt = 0
				local num = tonumber(value:GetAttribute("ReloadFinishTime"))

				if num and num > time() then
					value:SetAttribute("ReloadFinishTime", time())
				end

				local v14 = getmetatable(arg)
				local value2 = rawget(arg, "UpdateAmmo") or type(v14) == "table" and rawget(v14, "UpdateAmmo")

				if type(value2) == "function" then
					pcall(value2, arg)
				end
			end
		end

		local function fn17(arg)
			local v14 = getmetatable(arg)
			local value = rawget(arg, "UpdateAmmo") or type(v14) == "table" and rawget(v14, "UpdateAmmo")

			if type(value) == "function" then
				pcall(value, arg)
			end
		end

		local function fn18(arg, arg2, arg3)
			if type(arg) ~= "table" or typeof(arg2) ~= "Instance" or typeof(arg3) ~= "Instance" or not arg2:IsDescendantOf(characters) or not arg3:IsDescendantOf(arg2) then
				return false
			end
			local value = rawget(arg, "RealModel")
			if typeof(value) ~= "Instance" or not value:IsDescendantOf(localPlayer2) then
				return false
			end
			local attribute = value:GetAttribute("AmmoType") or "RifleAmmo"

			if attribute == "Energy" then
				if not Client.EnergyResourceClient.CanUseEnergy(arg.EnergyCost) then
					return false
				end
			elseif type(rawget(arg, "Ammo")) ~= "number" or arg.Ammo <= 0 then
				fn16(arg)
				if type(rawget(arg, "Ammo")) ~= "number" or arg.Ammo <= 0 then
					return false
				end
			end

			local n4 = math.max(tonumber(rawget(arg, "FireRate")) or 1, 0.08)
			if time() < (tonumber(rawget(arg, "LastFired")) or 0) + n4 then
				return false
			end
			arg.LastFired = time()
			local v14 = Client.ProjectileClass.GetProjectileId()

			local ok, result = pcall(function()
				return Client.Events.RegisterProjectile:InvokeServer(value, v14)
			end)

			if not ok or type(result) ~= "table" or result.Success ~= true then
				return false
			end

			if attribute == "Energy" then
				Client.EnergyResourceClient.ConsumeEnergy(arg.EnergyCost)
			else
				arg.Ammo = math.max(0, arg.Ammo - 1)
				fn17(arg)
			end

			local n5 = tonumber(rawget(arg, "ProjectileDamage")) or tonumber(value:GetAttribute("ProjectileDamage")) or 0

			if arg3.Name == "Head" and not rawget(arg, "ExplosionRadius") then
				n5 *= Client.GlobalSettings.HeadshotMultiplier or 1
			end

			local flag4 = localPlayer2:GetAttribute("Class") == "Cyborg"

			if flag4 then
				flag4 = (localPlayer2:GetAttribute("ClassLevel") or 1) >= 2
			end

			if flag4 and attribute == "Energy" then
				n5 *= 1.25
			end

			if arg2:HasTag("Turret") then
				n5 *= Client.GlobalSettings.TurretRangedDamageMultiplier or 1
			end

			local num = tonumber(rawget(arg, "ExplosionRadius")) or tonumber(value:GetAttribute("ExplosionRadius"))
			local v15, ok2, result2

			if num then
				local v16 = Client.EnemyHandler.GetHitRegId()
				local v17
				v17, v15 = Client.EnemyHandler.ApplyLocalDamage(arg2, Client.CombatUtility.GetExplosiveDamage(n5, 0, num), v16)

				ok2, result2 = pcall(function()
					return Client.Events.ExplosiveProjectileDamageEnemy:InvokeServer({ { Model = arg2, Distance = 0 } }, v14, v16, arg3.Position)
				end)
			else
				local v16
				v16, v15 = Client.EnemyHandler.ApplyLocalDamage(arg2, n5)
				if not v16 then
					return false
				end

				ok2, result2 = pcall(function()
					return Client.Events.ProjectileDamageEnemy:InvokeServer(arg2, v14, v16, arg3)
				end)
			end

			ok2 = ok2 and type(result2) == "table" and result2.Success == true

			if not ok2 and type(v15) == "function" then
				pcall(v15)
			end

			if ok2 and attribute ~= "Energy" and type(rawget(arg, "Ammo")) == "number" and arg.Ammo <= 0 then
				task.spawn(fn16, arg)
			end

			return ok2
		end

		v:Toggle({ Title = "Gun Aura", Default = false, Callback = function(...) end })

		v:Slider({
			Title = "Gun Aura Range",
			Step = 1,
			Value = { Min = 10, Max = 500, Default = 150 },
			Callback = function(I)_G.GunAuraRange=tonumber(I)or 150;end,
		})
	end

	do
		local v = v6:Section({ Title = "Tree Aura", Icon = "axe", Box = true, BoxBorder = true, Opened = true })

		v:Slider({
			Title = "Chop Aura Range",
			Step = 1,
			Value = { Min = 50, Max = 150, Default = 100 },
			Callback = function(I)_G.ChopAuraRange=tonumber(I);end,
		})

		local tbl2 = {}
		local function fn10(I)return I and(I:IsA("Model"))and I:GetAttribute("Resource")=="Tree"and(I:GetAttribute("AllowTool_GenericAxe")==true or I:GetAttribute("AllowTool_Chainsaw")==true or I:FindFirstChild("Trunk")and(I:FindFirstChild("HitRegisters")));end

		local function fn11()
			local tbl3 = {}

			for k in pairs(tbl2) do
				table.insert(tbl3, k)
			end

			table.sort(tbl3, function(arg, arg2)
				return string.lower(arg) < string.lower(arg2)
			end)

			return tbl3
		end

		local function fn12(arg)
			if not arg then
				return
			end

			if fn10(arg) then
				tbl2[arg.Name] = true
			end

			local now = os.clock()

			for _, descendant in ipairs(arg:GetDescendants()) do
				if fn10(descendant) then
					tbl2[descendant.Name] = true
				end

				if os.clock() - now >= 0.002 then
					task.wait()
					now = os.clock()
				end
			end
		end

		local map = workspace:FindFirstChild("Map")

		if map then
			fn12(map:FindFirstChild("Foliage"))
			fn12(map:FindFirstChild("Landmarks"))
		end

		v:Dropdown({
			Title = "Tree Type",
			Flag = "Main_TreeAura_Dropdown_Tree_Type_v2",
			Values = fn11(),
			Value = { "Select All" },
			Multi = true,
			Callback = function(I)_G.ChopTreeType=I;end,
		})

		local function fn13(...) end

		if getgenv().__FN99TreeCatalogConnections then
			for _, fN99TreeCatalogConnection in ipairs(getgenv().__FN99TreeCatalogConnections) do
				pcall(function()
					fN99TreeCatalogConnection:Disconnect()
				end)
			end
		end

		getgenv().__FN99TreeCatalogConnections = {}
		local function fn14(k)if not k then return;end;table.insert(getgenv().__FN99TreeCatalogConnections,k.DescendantAdded:Connect(function(k)local a=k:IsA("Model")and k or(k:FindFirstAncestorOfClass("Model"));task.defer(function() fn13 (a);end);end));end

		if map then
			fn14(map:FindFirstChild("Foliage"))
			fn14(map:FindFirstChild("Landmarks"))
		end

		local overlapParams = OverlapParams.new()
		overlapParams.FilterType = Enum.RaycastFilterType.Include
		overlapParams.MaxParts = 0
		getgenv()

		local function fn15(arg, arg2)
			while arg and arg ~= arg2 do
				if fn10(arg) then
					return arg
				end
				arg = arg.Parent
			end

			return nil
		end

		v:Toggle({ Title = "Tree Aura", Default = false, Callback = function(...) end })
	end

	v6:Space()

	local v13 = v6:Section({
		Title = "Creature Control",
		ConfigFlagKey = "Stun",
		Icon = "zap",
		Box = true,
		BoxBorder = true,
		Opened = true,
	})

	v13:Toggle({
		Title = "Auto Stun Deer",
		Default = false,
		Callback = function(I)_G.AutoStunDeer=I;if not I then return;end;task.spawn(function()local I,k=game:GetService("ReplicatedStorage").RemoteEvents:WaitForChild("MonsterHitByTorch"),workspace:WaitForChild("Characters");while _G.AutoStunDeer do task.wait(0.1);local a=k:FindFirstChild("Deer");if a then local k={[1]=a};pcall(function()I:InvokeServer(unpack(k));end);end;end;end);end,
	})

	v13:Toggle({
		Title = "Auto Stun Owl",
		Default = false,
		Callback = function(I)_G.AutoStunOwl=I;if not I then return;end;task.spawn(function()local I,k=game:GetService("ReplicatedStorage").RemoteEvents:WaitForChild("MonsterHitByTorch"),workspace:WaitForChild("Characters");while _G.AutoStunOwl do task.wait(0.1);local a=k:FindFirstChild("Owl");if a then local k={[1]=a};pcall(function()I:InvokeServer(unpack(k));end);end;end;end);end,
	})

	v13:Toggle({
		Title = "Auto Stun Ram",
		Default = false,
		Callback = function(I)_G.AutoStunRam=I;if not I then return;end;task.spawn(function()local I,k=game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("MonsterHitByTorch"),workspace:WaitForChild("Characters");while _G.AutoStunRam do task.wait(0.1);local a;for K,K in ipairs(k:GetChildren())do if K.Name=="Ram"then a=K;break;end;end;if a then local k={a};pcall(function()I:InvokeServer(unpack(k));end);end;end;end);end,
	})

	v13:Toggle({
		Title = "Auto Stun Cat",
		Default = false,
		Callback = function(I)_G.AutoStunCat=I;if not I then return;end;task.spawn(function()local I,k=game:GetService("ReplicatedStorage").RemoteEvents:WaitForChild("MonsterHitByTorch"),workspace:WaitForChild("Characters");while _G.AutoStunCat do task.wait(0.1);local a=k:FindFirstChild("Cat");if a then local k={a};pcall(function()I:InvokeServer(unpack(k));end);end;end;end);end,
	})

	do
		local flag4 = false
		local flag5 = false

		local tbl2 = {
			NPCProjectileDamagePlayer = true,
			ClientTriggerNPCAttack = true,
			CheckLightningDamage = true,
			JungleSpikeTrapDamage = true,
			TriggerArrowTrap = true,
			HitByBatScream = true,
			DamagePlayer = true,
		}

		local function fn10(arg)
			if tbl2[arg] then
				return true
			end
			local v = string.lower(arg)
			if v:find("lightningdamage", 1, true) or v:find("spiketrapdamage", 1, true) or v:find("arrowtrap", 1, true) or v:find("batscream", 1, true) or v:find("projectileplayer", 1, true) or v:find("damageplayer", 1, true) or v:find("npcdamage", 1, true) or v:find("triggerattack", 1, true) then
				return true
			end
			return false
		end

		local function fn11()
			if flag5 then
				return
			end
			flag5 = true

			if typeof(hookfunction) == "function" then
				pcall(function()
					local v = nil

					local function fn12(arg, ...)
						if flag4 and arg and fn10(tostring(arg.Name)) then
							return
						end
						local v14 = table.pack(...)
						return v(arg, table.unpack(v14, 1, v14.n))
					end

					v = hookfunction
					v = v(Instance.new("RemoteEvent").FireServer, fn12)
				end)

				pcall(function()
					local v = nil

					local function fn12(arg, ...)
						if flag4 and arg and fn10(tostring(arg.Name)) then
							return
						end
						return v(arg, ...)
					end

					v = hookfunction
					v = v(Instance.new("RemoteFunction").InvokeServer, fn12)
				end)
			end

			if typeof(hookmetamethod) == "function" and typeof(getnamecallmethod) == "function" then
				local v = nil

				local function fn12(arg, ...)
					local v14 = getnamecallmethod()

					if (v14 == "FireServer" or v14 == "InvokeServer") and flag4 then
						local str4 = tostring(arg.Name)
						if fn10(str4) then
							return
						end
					end

					return v(arg, ...)
				end

				v = hookmetamethod
				v = v(game, "__namecall", fn12)
			elseif typeof(hookfunction) == "function" and typeof(getrawmetatable) == "function" and typeof(getnamecallmethod) == "function" then
				local v = getrawmetatable(game)

				if v and v.__namecall then
					local v14 = nil

					local function fn12(arg, ...)
						local v15 = getnamecallmethod()

						if (v15 == "FireServer" or v15 == "InvokeServer") and flag4 then
							local str4 = tostring(arg.Name)
							if fn10(str4) then
								return
							end
						end

						return v14(arg, ...)
					end

					v14 = hookfunction
					v14 = v14(v.__namecall, fn12)
				end
			end
		end
	end

	v6:Space()

	local v14 = v6:Section({
		Title = "Survival",
		ConfigFlagKey = "Godmode",
		Icon = "shield",
		Box = true,
		BoxBorder = true,
		Opened = true,
	})

	v14:Button({
		Title = "Godmode",
		Callback = function() v2 :Dialog({Title="Survival",Content="Godmode was patched, please use anti hit (you can still get damaged by hunger)",Icon="shield-alert",Buttons={{Title="OK",Icon="check",Variant="Primary",Callback=function()end}}});end,
	})

	v14:Toggle({ Title = "Anti Hit", Default = false, Callback = function(...) end })
	v6:Space()
	local v15

	v15 = v6:Section({
		Title = "General Automation",
		ConfigFlagKey = "Auto",
		Icon = "bot",
		Box = true,
		BoxBorder = true,
		Opened = true,
	})

	v15:Dropdown({
		Title = "Select Auto",
		Values = {
			"Collect Coins",
			"Collect Flowers",
			"Plants Seed Box",
			"Collect Ammo",
			"Collect Diamond",
			"Plants Tree",
			"Auto Day",
		},
		Value = { "" },
		Multi = true,
		Callback = function(I)_G.TypeAuto=I;end,
	})

	local ReplicatedStorage2
	ReplicatedStorage2 = game:GetService("ReplicatedStorage")

	do
		local items = workspace:FindFirstChild("Items")
		local requestConsumeItem = ReplicatedStorage2:FindFirstChild("RemoteEvents") and ReplicatedStorage2.RemoteEvents:FindFirstChild("RequestConsumeItem")

		local tbl2 = {
			["Collect Coins"] = function(arg)
				if arg.Name == "Coin Stack" then
					local requestCollectCoints = ReplicatedStorage2:FindFirstChild("RemoteEvents") and ReplicatedStorage2.RemoteEvents:FindFirstChild("RequestCollectCoints")

					if requestCollectCoints then
						pcall(function()
							requestCollectCoints:InvokeServer(arg)
						end)
					end
				end
			end,
			["Plants Seed Box"] = function(arg)
				if arg.Name == "Seed Box" then
					local requestPlantSeeds = ReplicatedStorage2:FindFirstChild("RemoteEvents") and ReplicatedStorage2.RemoteEvents:FindFirstChild("RequestPlantSeeds")

					if requestPlantSeeds then
						pcall(function()
							requestPlantSeeds:InvokeServer(arg)
						end)
					end
				end
			end,
			["Plants Tree"] = function(arg)
				if arg.Name == "Sapling" and arg:FindFirstChild("HitBox") then
					local requestPlantItem = ReplicatedStorage2:FindFirstChild("RemoteEvents") and ReplicatedStorage2.RemoteEvents:FindFirstChild("RequestPlantItem")

					if requestPlantItem then
						pcall(function()
							requestPlantItem:InvokeServer(arg, arg.HitBox.Position)
						end)
					end
				end
			end,
			["Collect Ammo"] = function(arg)
				if requestConsumeItem and items and arg:IsDescendantOf(items) and arg.Name:find("Ammo") then
					pcall(function()
						requestConsumeItem:InvokeServer(arg)
					end)
				end
			end,
			["Collect Diamond"] = function(arg)
				local requestTakeDiamonds = ReplicatedStorage2:FindFirstChild("RemoteEvents") and ReplicatedStorage2.RemoteEvents:FindFirstChild("RequestTakeDiamonds")

				if requestTakeDiamonds and arg.Name == "Diamond" then
					pcall(function()
						requestTakeDiamonds:FireServer(arg)
					end)
				end
			end,
		}
	end

	do
		local CollectionService = game:GetService("CollectionService")
		local requestPickFlower = ReplicatedStorage2:FindFirstChild("RemoteEvents") and ReplicatedStorage2.RemoteEvents:FindFirstChild("RequestPickFlower")
		local obj = setmetatable({}, { __mode = "k" })
		local obj2 = setmetatable({}, { __mode = "k" })

		local function fn10(arg)
			if arg:IsA("Model") then
				return arg:GetPivot().Position
			end

			if arg:IsA("BasePart") then
				return arg.Position
			end
			local basePart = arg:FindFirstChildWhichIsA("BasePart", true)
			return basePart and basePart.Position or nil
		end

		local function fn11()
			if not requestPickFlower or not requestPickFlower:IsA("RemoteFunction") then
				return
			end
			local character = localPlayer.Character
			character = character and character:FindFirstChild("HumanoidRootPart")
			if not character then
				return
			end
			local v = nil
			local now = os.clock()
			local n = 40

			for _, v16 in ipairs(CollectionService:GetTagged("Flower")) do
				local flag4 = v16.Name == "Flower" and v16:IsDescendantOf(workspace) and not obj[v16]

				if flag4 then
					flag4 = (obj2[v16] or 0) <= now
				end

				if flag4 then
					local ok, result = pcall(fn10, v16)

					if ok and result then
						local magnitude = (result - character.Position).Magnitude

						if magnitude <= n then
							v = v16
							n = magnitude
						end
					end
				end
			end

			if not v then
				return
			end

			local ok, result = pcall(function()
				return requestPickFlower:InvokeServer(v)
			end)

			if ok and type(result) == "table" and result.Success == true then
				obj[v] = true
			else
				obj2[v] = os.clock() + 3
			end
		end
	end

	game:GetService("VirtualInputManager")
	game:GetService("GuiService")

	do
		local playerGui = localPlayer:WaitForChild("PlayerGui")
		local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
		local craftItem = remoteEvents:FindFirstChild("CraftItem")
		local requestStartDraggingItem = remoteEvents:FindFirstChild("RequestStartDraggingItem")
		local stopDraggingItem = remoteEvents:FindFirstChild("StopDraggingItem")
		local requestBagStoreItem = remoteEvents:FindFirstChild("RequestBagStoreItem")
		local equipItemHandle = remoteEvents:FindFirstChild("EquipItemHandle")

		local tbl2 = {
			"Old Bed",
			"Crafting Bench 2",
			"Regular Bed",
			"Crafting Bench 3",
			"Good Bed",
			"Crafting Bench 4",
			"Giant Bed",
		}

		local tbl3 = { Coal = true, ["Fuel Canister"] = true, ["Oil Barrel"] = true, Biofuel = true }

		local tbl4 = {
			["Broken Fan"] = true,
			["Sheet Metal"] = true,
			Bolt = true,
			["Metal Chair"] = true,
			["Broken Microwave"] = true,
			["Old Car Engine"] = true,
			["Old Radio"] = true,
			WashingMachine = true,
			["Cultist Gem"] = true,
			Tyre = true,
			["Gem of the Forest Fragment"] = true,
			["UFO Junk"] = true,
			["UFO Component"] = true,
			Chair = true,
		}

		_G.AutoDayMoveItem = function(arg, arg2)
			if not _G.AutoStart then
				return
			end

			if not arg or not arg:IsDescendantOf(Workspace) then
				return
			end
			local primaryPart = arg:IsA("Model") and (arg.PrimaryPart or arg:FindFirstChildWhichIsA("BasePart") or arg:FindFirstChild("Handle")) or arg
			if not primaryPart or not primaryPart:IsA("BasePart") then
				return
			end

			if arg:IsA("Model") and not arg.PrimaryPart then
				pcall(function()
					arg.PrimaryPart = primaryPart
				end)
			end

			if not (typeof(sethiddenproperty) == "function") then
				return
			end

			pcall(function()
				if not arg:IsDescendantOf(Workspace) then
					return
				end
				sethiddenproperty(primaryPart, "NetworkOwnershipRule", Enum.NetworkOwnership.Manual)
				requestStartDraggingItem:FireServer(arg)

				if arg:IsA("Model") then
					arg:SetPrimaryPartCFrame(CFrame.new(arg2))
				else
					primaryPart.CFrame = CFrame.new(arg2)
				end

				if not arg:IsDescendantOf(Workspace) then
					pcall(function()
						sethiddenproperty(primaryPart, "NetworkOwnershipRule", Enum.NetworkOwnership.Automatic)
					end)

					return
				end

				stopDraggingItem:FireServer(arg)
				task.wait(0.2)

				pcall(function()
					sethiddenproperty(primaryPart, "NetworkOwnershipRule", Enum.NetworkOwnership.Automatic)
				end)
			end)
		end

		local function fn10(arg)
			if not _G.AutoStart then
				return arg.Position
			end
			local position = arg.Position
			_G.AutoDayStatus = "Expanding map..."
			_G.AutoDayExpanding = true

			task.spawn(function()
				while _G.AutoDayExpanding and _G.AutoStart do
					local map = Workspace:FindFirstChild("Map")
					map = map and map:FindFirstChild("Campground")
					map = map and map:FindFirstChild("Scrapper")
					local pivot

					if not map then
						pivot = nil
					else
						pivot = map:IsA("Model") and map:GetPivot() or map:IsA("BasePart") and map.CFrame

						if not pivot then
							pivot = map:FindFirstChildWhichIsA("BasePart")
							pivot = pivot and pivot.CFrame
						end

						pivot = pivot and pivot.Position + Vector3.new(0, 5, 0) or nil
					end

					local items = Workspace:FindFirstChild("Items")

					if items then
						for _, child in ipairs(items:GetChildren()) do
							if not (not _G.AutoDayExpanding or not _G.AutoStart) then
								if child.Name == "Log" or child.Name == "Coal" then
									_G.AutoDayMoveItem(child, Vector3.new(0, 19, 0))
									task.wait(0.03)
									continue
								elseif child.Name == "Cultist Gem" and pivot then
									local primaryPart = child:IsA("Model") and (child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart")) or child

									if primaryPart and primaryPart:IsA("BasePart") and child:IsDescendantOf(Workspace) then
										arg.CFrame = primaryPart.CFrame + Vector3.new(0, 5, 0)
										task.wait(1)

										if _G.AutoStart then
											if child:IsDescendantOf(Workspace) then
												_G.AutoDayMoveItem(child, pivot)
											end

											task.wait(0.5)
											continue
										end
									else
										continue
									end
								else
									if (tbl4[child.Name] or tbl3[child.Name]) and pivot then
										_G.AutoDayMoveItem(child, pivot)
										task.wait(0.03)
									end

									continue
								end
							end

							break
						end
					end

					task.wait(0.75)
				end
			end)

			local n = 0
			local n4 = 0

			while n <= 1400 do
				if _G.AutoStart then
					arg.CFrame = CFrame.new(position.X + n * math.cos(n4), 85, position.Z + n * math.sin(n4))
					n4 += 0.17453292519943295
					n += 1.25
					task.wait(0.05)
					continue
				end

				break
			end

			_G.AutoDayExpanding = false
			_G.AutoDayStatus = "Map expand done"
			return position
		end

		local function fn11(arg, arg2, arg3)
			if not _G.AutoStart then
				return
			end
			arg3 = arg3 or 3
			local now = tick()

			while tick() - now < arg3 do
				if not _G.AutoStart then
					return
				end

				if (arg.Position - arg2).Magnitude > 1 then
					arg.CFrame = CFrame.new(arg2)
				end

				task.wait(0.1)
			end

			if not _G.AutoStart then
				return
			end

			if (arg.Position - arg2).Magnitude > 1 then
				arg.CFrame = CFrame.new(arg2)
			end
		end

		local function fn12()
			if not _G.AutoStart then
				return
			end

			if not (typeof(fireproximityprompt) == "function") then
				return
			end
			_G.AutoDayStatus = "Opening chests..."
			local items = Workspace:FindFirstChild("Items")
			if not items then
				return
			end
			local tbl5 = {}

			for _, child in pairs(items:GetChildren()) do
				if not _G.AutoStart then
					return
				end

				if string.find(child.Name, "Chest") and child.Name ~= "Stronghold Diamond Chest" then
					for _, descendant in pairs(child:GetDescendants()) do
						if descendant:IsA("ProximityPrompt") then
							table.insert(tbl5, descendant)
						end
					end
				end
			end

			for _, v in ipairs(tbl5) do
				if not _G.AutoStart then
					return
				end

				if v and v:IsA("ProximityPrompt") and v.Enabled then
					pcall(function()
						v.HoldDuration = 0
						fireproximityprompt(v, 1)
					end)

					task.wait()
				end
			end
		end

		local function fn13()
			if not _G.AutoStart then
				return
			end
			_G.AutoDayStatus = "Pulling items..."
			local items = Workspace:FindFirstChild("Items")
			if not items then
				return
			end
			local map = Workspace:FindFirstChild("Map")
			map = map and map:FindFirstChild("Campground")
			map = map and map:FindFirstChild("CraftingBench")
			local pivot

			if not map then
				pivot = nil
			else
				pivot = map:IsA("Model") and map:GetPivot() or map:IsA("BasePart") and map.CFrame

				if not pivot then
					pivot = map:FindFirstChildWhichIsA("BasePart")
					pivot = pivot and pivot.CFrame
				end

				pivot = pivot and pivot.Position + Vector3.new(0, 12, 0) or nil
			end

			local map2 = Workspace:FindFirstChild("Map")
			local campground = map2 and map2:FindFirstChild("Campground")
			campground = campground and campground:FindFirstChild("Scrapper")

			if campground then
				local pivot2 = campground:IsA("Model") and campground:GetPivot() or campground:IsA("BasePart") and campground.CFrame

				if not pivot2 then
					pivot2 = campground:FindFirstChildWhichIsA("BasePart")
					pivot2 = pivot2 and pivot2.CFrame
				end

				if pivot2 then
				end
			end

			for _, child in ipairs(items:GetChildren()) do
				if _G.AutoStart then
					if tbl3[child.Name] then
						_G.AutoDayMoveItem(child, Vector3.new(0, 19, 0))
					elseif child.Name == "Log" then
						if pivot then
							_G.AutoDayMoveItem(child, pivot)
						end
					elseif tbl4[child.Name] then
						if pivot then
							_G.AutoDayMoveItem(child, pivot)
						end
					end

					task.wait(0.03)
					continue
				end

				break
			end
		end

		local function fn14()
			if not _G.AutoStart then
				return
			end
			_G.AutoDayStatus = "Collecting children..."
			local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
			local humanoidRootPart = character and character:WaitForChild("HumanoidRootPart", 5)
			if not humanoidRootPart then
				return
			end
			local inventory = localPlayer:FindFirstChild("Inventory")
			if not inventory then
				return
			end
			local v = nil
			local v16, v17, v18 = ipairs(inventory:GetChildren())
			local v19 = table.pack(L_1())

			if v19[1] then
				v = v19[3]
			end

			if not v then
				return
			end
			local tbl5 = {}

			for _, child in ipairs(Workspace.Characters:GetChildren()) do
				if not _G.AutoStart then
					return
				end

				if child:IsA("Model") and child:GetAttribute("Lost") == true and child.PrimaryPart then
					table.insert(tbl5, { Model = child, CFrame = child.PrimaryPart.CFrame })
				end
			end

			local map = Workspace:FindFirstChild("Map")
			map = map and map:FindFirstChild("Campground")
			local craftingBench = map and map:FindFirstChild("CraftingBench")
			local pivot

			if not craftingBench then
				pivot = nil
			elseif craftingBench:IsA("Model") then
				pivot = craftingBench:GetPivot()
			elseif craftingBench:IsA("BasePart") then
				pivot = craftingBench.CFrame
			else
				pivot = craftingBench:FindFirstChildWhichIsA("BasePart")
				pivot = pivot and pivot.CFrame or nil
			end

			for i, v20 in ipairs(tbl5) do
				if _G.AutoStart then
					_G.AutoDayStatus = "Collecting child " .. i .. "/" .. #tbl5 .. "..."

					pcall(function()
						humanoidRootPart.CFrame = v20.CFrame + Vector3.new(0, 3, 0)
					end)

					task.wait(0.8)

					if _G.AutoStart then
						pcall(function()
							requestBagStoreItem:InvokeServer(v, v20.Model)
						end)

						task.wait(1.2)

						if _G.AutoStart then
							if pivot and humanoidRootPart then
								humanoidRootPart.CFrame = pivot + Vector3.new(0, 12, 0)
							end

							task.wait(1.5)
							continue
						end
					end
				end

				break
			end
		end

		local function fn15()
			local interface = playerGui:FindFirstChild("Interface")
			interface = interface and interface:FindFirstChild("CraftingTable")
			interface = interface and interface:FindFirstChild("Materials")
			local gemAmount = interface and interface:FindFirstChild("GemAmount")
			return tonumber(gemAmount and gemAmount.Text) or 0
		end

		local function fn16()
			if not _G.AutoStart then
				return
			end

			if not craftItem then
				_G.AutoDayStatus = "CraftItem remote not found"
				return
			end
			local v = fn15()
			local flag4 = v >= 3

			if not flag4 then
				_G.AutoDayStatus = "Low gems (" .. v .. "/3) — skipping Bench 4 + Giant Bed"
				fn3("Auto Day", "Only " .. v .. "/3 gems — Crafting Bench 4 and Giant Bed will be skipped.", "alert-triangle", 8)

				pcall(function()
					v2:AddDialog("AutoDayGemWarning", {
						Title = "Gem shortage",
						Description = "You only have " .. v .. " / 3 Gem of the Forest fragments.\nCrafting Bench 4 and Giant Bed will be skipped. Beds will NOT be auto-placed.",
						AutoDismiss = true,
						OutsideClickDismiss = true,
						FooterButtons = { OK = { Title = "Got it", Variant = "Primary", Order = 1, Callback = function()end } },
					})
				end)
			end

			for _, v16 in ipairs(tbl2) do
				if _G.AutoStart then
					if not flag4 and (v16 == "Crafting Bench 4" or v16 == "Giant Bed") then
						_G.AutoDayStatus = "Skipping " .. v16 .. " (not enough gems)"
						task.wait(0.2)
						continue
					else
						_G.AutoDayStatus = "Crafting: " .. v16

						if not pcall(function()
							craftItem:InvokeServer(v16)
						end) then
							_G.AutoDayStatus = "Failed to craft: " .. v16
							break
						else
							task.wait(1)
							continue
						end
					end
				end

				break
			end

			if _G.AutoStart then
				_G.AutoDayStatus = "Crafting sequence done"
			end
		end

		local tbl5 = { "Strong Axe", "Poison Spear", "Spear", "Good Axe" }
		local requestHotbarItem = remoteEvents:FindFirstChild("RequestHotbarItem")

		local function fn17()
			if not _G.AutoStart then
				return
			end

			if not (typeof(fireproximityprompt) == "function") then
				return
			end
			_G.AutoDayStatus = "Picking up weapon..."
			local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
			local humanoidRootPart = character and character:WaitForChild("HumanoidRootPart", 5)
			if not humanoidRootPart then
				return
			end
			local items = Workspace:FindFirstChild("Items")
			if not items then
				return
			end

			for _, v in ipairs(tbl5) do
				if not _G.AutoStart then
					return
				end

				for _, child in ipairs(items:GetChildren()) do
					if not _G.AutoStart then
						return
					end

					if child.Name == v and child:IsDescendantOf(Workspace) then
						local primaryPart = child:IsA("Model") and (child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart") or child:FindFirstChild("Handle")) or child

						if primaryPart then
							local cFrame = humanoidRootPart.CFrame

							pcall(function()
								humanoidRootPart.CFrame = primaryPart.CFrame + Vector3.new(0, 5, 0)
							end)

							task.wait(0.5)
							if not _G.AutoStart then
								return
							end

							if child:IsDescendantOf(Workspace) then
								task.wait(0.5)
								if not _G.AutoStart then
									return
								end
								local v16 = nil

								for _, descendant in ipairs(child:GetDescendants()) do
									if descendant:IsA("ProximityPrompt") then
										v16 = descendant
										break
									end
								end

								if v16 then
									pcall(function()
										v16.HoldDuration = 0
										fireproximityprompt(v16, 1)
									end)
								elseif requestHotbarItem then
									pcall(function()
										requestHotbarItem:InvokeServer(child)
									end)
								end

								task.wait(1)
							end

							if not _G.AutoStart then
								return
							end

							pcall(function()
								humanoidRootPart.CFrame = cFrame
							end)

							local inventory = localPlayer:FindFirstChild("Inventory")

							if inventory and inventory:FindFirstChild(v) then
								if equipItemHandle then
									pcall(function()
										equipItemHandle:FireServer("FireAllClients", inventory[v])
									end)
								end

								return
							end
						end
					end
				end
			end
		end

		local function fn18()
			_G.AutoStart = false

			pcall(function()
				if Library and Library.Toggles and Library.Toggles["Auto Day"] then
					Library.Toggles["Auto Day"]:SetValue(false)
				elseif _G._AutoDayToggleRef and _G._AutoDayToggleRef.SetValue then
					_G._AutoDayToggleRef:SetValue(false)
				end
			end)
		end

		_G.AutoDayRun = function()
			local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
			character = character and character:WaitForChild("HumanoidRootPart", 5)
			if not character then
				_G.AutoDayStatus = "No character"
				return
			end
			_G.AutoDayStatus = "Starting Auto Day..."
			local v = fn10(character)
			if not _G.AutoStart then
				return
			end
			fn11(character, v, 3)
			if not _G.AutoStart then
				return
			end
			fn12()
			if not _G.AutoStart then
				return
			end
			fn17()
			if not _G.AutoStart then
				return
			end
			fn14()
			if not _G.AutoStart then
				return
			end
			_G.AutoDayStatus = "Final sweep + crafting..."
			local flag4 = false
			local flag5 = false

			task.spawn(function()
				fn16()
				flag4 = true
			end)

			task.spawn(function()
				fn13()
				flag5 = true
			end)

			while not (flag4 and flag5) do
				if not _G.AutoStart then
					return
				end
				task.wait(0.3)
			end

			if not _G.AutoStart then
				return
			end
			_G.AutoDayStatus = "Auto Day complete!"
			fn3("Auto Day", "Sequence complete! Auto Day has been disabled.", "check", 8)
			task.wait(0.5)
			fn18()
		end
	end

	_G.AutoToggleRef = v15:Toggle({ Title = "Auto", Default = false, Callback = function(...) end })

	v15:Toggle({
		Title = "Auto Revive Team(bandage)",
		Default = false,
		Callback = function(I)getgenv().AutoRevive=I;if not I then return;end;local I,k=game:GetService("Players").LocalPlayer,workspace:WaitForChild("Characters",9000000000);task.spawn(function()while getgenv().AutoRevive do task.wait(1);local a=I:FindFirstChild("Inventory");if not a then continue;end;if not a:FindFirstChild("Bandage")then continue;end;for I,a in pairs(k:GetChildren())do if string.find(a.Name,"Body")and(a:FindFirstChild("HumanoidRootPart"))then I=a.HumanoidRootPart:FindFirstChild("ProximityAttachment");if I and(I:FindFirstChild("ProximityInteraction"))then fireproximityprompt(I.ProximityInteraction);task.wait(0.5);end;end;end;end;end);end,
	})

	v15:Space()

	v15:Toggle({
		Title = "Auto Grab Children",
		Default = false,
		Callback = function(k)_G.AutoGrabChildren=k;getgenv().__FN99GrabChildrenRunId=(getgenv().__FN99GrabChildrenRunId or 0)+1;local a=getgenv().__FN99GrabChildrenRunId;if not k then return;end;task.spawn(function()local k,K=game:GetService("ReplicatedStorage"),game:GetService("CollectionService");local S=k:WaitForChild("TempStorage");local l=k:WaitForChild("RemoteEvents"):WaitForChild("RequestBagStoreItem");local H=setmetatable({},{__mode="k"});local t={};local function v()local x= localPlayer :FindFirstChild("Inventory");if not x then return nil;end;local n,p=-1;for Z,T in ipairs(x:GetChildren())do if T:IsA("Model")and(T:HasTag("ItemBag")or T:GetAttribute("ToolName")=="Item Bag")then local x,R=tonumber(T:GetAttribute("Capacity"))or 0, localPlayer :FindFirstChild("ItemBag");Z=R and#R:GetChildren()or 0;R=x-math.max(tonumber(T:GetAttribute("NumberItems"))or 0,Z);if R>n then n,p=R,T;end;end;end;return p,n;end;local function x(n)return n:IsA("Model")and n.Parent== Workspace :FindFirstChild("Characters")and n:GetAttribute("CanBeBagged")==true and(n:GetAttribute("Lost")==true or n:GetAttribute("NPCType")=="Lost Child"or(K:HasTag(n,"ChildNPC")));end;local function K(n)return n.PrimaryPart or(n:FindFirstChild("HumanoidRootPart"))or(n:FindFirstChild("Head"))or(n:FindFirstChildWhichIsA("BasePart"));end;k=nil;while _G.AutoGrabChildren and getgenv().__FN99GrabChildrenRunId==a do local n= localPlayer .Character;local p,Z,T,R=n and(n:FindFirstChild("HumanoidRootPart")), Workspace :FindFirstChild("Characters"),v();if not p or not Z then task.wait(0.5);continue;end;if not T then if k~="bag"then  fn3 ("Auto Grab Children","No item bag found in inventory.","triangle-alert",4);k="bag";end;task.wait(1);continue;elseif R<=0 then if k~="full"then  fn3 ("Auto Grab Children",T.Name.." is full.","triangle-alert",4);k="full";end;task.wait(1);continue;end;k=nil;n={};for k,k in ipairs(Z:GetChildren())do if x(k)and not H[k]then R=K(k);if R and(R:IsA("BasePart"))then table.insert(n,{Model=k,Part=R,Distance=(R.Position-p.Position).Magnitude});end;end;end;table.sort(n,function(k,K)return k.Distance<K.Distance;end);local k=n[1];if not k then R,n={}, localPlayer :FindFirstChild("ItemBag");if n then for K,v in ipairs(n:GetChildren())do K=v:GetAttribute("KidId");if K then R[K]=true;end;end;end;for K,v in ipairs(Z:GetChildren())do K=v:GetAttribute("KidId");if K then R[K]=true;end;end;local K,v= Workspace :FindFirstChild("Map")and( Workspace .Map:FindFirstChild("Landmarks"));local x=1/0;if K then for n,Z in ipairs(K:GetChildren())do n=Z:GetAttribute("KidId");local K=n and(t[n]or 0)or 1/0;if n and not R[n]and os.clock()-K>=1.5 and K<x then x,v=K,Z;end;end;end;if v then t[v:GetAttribute("KidId")]=os.clock();local K,t,x,n=p.CFrame,p.AssemblyLinearVelocity,p.AssemblyAngularVelocity,v:GetPivot().Position;pcall(function() localPlayer :RequestStreamAroundAsync(n,3);end);if _G.AutoGrabChildren and getgenv().__FN99GrabChildrenRunId==a and p.Parent then p.CFrame=CFrame.new(n+Vector3.new(0,5,0));p.AssemblyLinearVelocity=Vector3.new(0.0,0.0,0.0);p.AssemblyAngularVelocity=Vector3.new(0.0,0.0,0.0);task.wait(0.2);if p.Parent then p.CFrame=K;p.AssemblyLinearVelocity=t;p.AssemblyAngularVelocity=x;end;end;task.wait(0.2);else task.wait(0.5);end;continue;end;local K,t=k.Model,p.CFrame;local v,x=K.Parent,false;if(not pcall(function()p.CFrame=k.Part.CFrame+Vector3.new(0,3,0);task.wait(0.45);if not _G.AutoGrabChildren or getgenv().__FN99GrabChildrenRunId~=a or not K:IsDescendantOf( Workspace )then return;end;if K.PrimaryPart then K.PrimaryPart.AssemblyLinearVelocity=Vector3.new(0.0,0.0,0.0);end;K.Parent=S;local k=l:InvokeServer(T,K);x=type(k)=="table"and k.Success==true;end)or not x)and K.Parent==S then K.Parent=v;end;if p.Parent then p.CFrame=t;end;if x then H[K]=true; fn3 ("Grabbed Lost Child",K.Name.." \226\134\146 "..T.Name,"check",2);end;task.wait(x and 0.35 or 0.8);end;end);end,
	})

	v15:Space()
	v6:Space()
	local ReplicatedStorage3, items

	do
		local v = v6:Section({
			Title = "Resource Processing",
			ConfigFlagKey = "Auto",
			Icon = "factory",
			Box = true,
			BoxBorder = true,
			Opened = true,
		})

		ReplicatedStorage3 = game:GetService("ReplicatedStorage")
		local remoteEvents = ReplicatedStorage3:WaitForChild("RemoteEvents")
		items = workspace:WaitForChild("Items")

		local function fn10(arg, arg2, arg3)
			if not remoteEvents or not remoteEvents:FindFirstChild("RequestStartDraggingItem") then
				return
			end
			local tbl2 = {}

			for _, v16 in ipairs(arg) do
				tbl2[v16] = true
			end

			for _, child in ipairs(items:GetChildren()) do
				if child:IsA("Model") and tbl2[child.Name] then
					local primaryPart = child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart")
					local particleEmitter = child:FindFirstChild("ParticleEmitter", true)

					if primaryPart and (not particleEmitter or particleEmitter.Enabled == false) and arg3 then
						pcall(function()
							remoteEvents.RequestStartDraggingItem:FireServer(child)
						end)

						child:SetPrimaryPartCFrame(arg2)
						task.wait()
					end
				end
			end
		end

		_G.AutoFuelB = { "Log", "Coal", "Oil Barrel", "Fuel Canister", "Biofuel" }
		_G.AutoFuel = false

		v:Dropdown({
			Title = "Choose Fuel",
			Values = { "Log", "Coal", "Oil Barrel", "Fuel Canister", "Biofuel" },
			Multi = true,
			AllowNone = true,
			Value = _G.AutoFuelB,
			Callback = function(I)_G.AutoFuelB=I;end,
		})

		v:Toggle({
			Title = "Auto Fuel",
			Default = false,
			Callback = function(k)_G.AutoFuel=k;if not k then return;end;task.spawn(function()if MV_OBFUSCATED then MV_OMIT(function()while _G.AutoFuel do local k={};for a,a in ipairs(_G.AutoFuelB)do k[a]=true;end;for a,a in ipairs( items :GetChildren())do if a:IsA("Model")and k[a.Name]then local k,K=a.PrimaryPart or(a:FindFirstChildWhichIsA("BasePart")),a:FindFirstChild("ParticleEmitter",true);if k and(not K or K.Enabled==false)and _G.AutoFuel then pcall(function() remoteEvents .RequestStartDraggingItem:FireServer(a);end);a:SetPrimaryPartCFrame(CFrame.new(0,18,0));task.wait();end;end;end;task.wait(0.5);end;end)();else while _G.AutoFuel do local k={};for a,a in ipairs(_G.AutoFuelB)do k[a]=true;end;for a,a in ipairs( items :GetChildren())do if a:IsA("Model")and k[a.Name]then local k,K=a.PrimaryPart or(a:FindFirstChildWhichIsA("BasePart")),a:FindFirstChild("ParticleEmitter",true);if k and(not K or K.Enabled==false)and _G.AutoFuel then pcall(function() remoteEvents .RequestStartDraggingItem:FireServer(a);end);a:SetPrimaryPartCFrame(CFrame.new(0,18,0));task.wait();end;end;end;task.wait(0.5);end;end;end);end,
		})

		v:Space()
		_G.AutoFood = false
		v:Toggle({ Title = "Auto Cook", Default = false, Callback = function(...) end })
		v:Space()
		_G.AutoScrapperH = false

		local tbl2 = {
			"Log",
			"Chair",
			"Broken Fan",
			"Sheet Metal",
			"Bolt",
			"Metal Chair",
			"Broken Microwave",
			"Old Car Engine",
			"Old Radio",
			"Washing Machine",
			"Cultist Gem",
			"Tyre",
			"UFO Junk",
			"UFO Component",
		}

		local autoScrapper = {}

		for _, v16 in ipairs(tbl2) do
			if v16 ~= "Log" then
				table.insert(autoScrapper, v16)
			end
		end

		_G.AutoScrapper = autoScrapper

		v:Dropdown({
			Title = "Choose Scrapper",
			Values = tbl2,
			Multi = true,
			AllowNone = true,
			Value = autoScrapper,
			Callback = function(I)_G.AutoScrapper=I;end,
		})

		v:Toggle({
			Title = "Auto Scrapper",
			Default = false,
			Callback = function(k)_G.AutoScrapperH=k;if not k then return;end;task.spawn(function()if MV_OBFUSCATED then MV_OMIT(function()while _G.AutoScrapperH do local k=workspace.Map.Campground:FindFirstChild("Scrapper");local a=k and(k:FindFirstChildWhichIsA("BasePart"));local K,S=a and a.CFrame*CFrame.new(0,18,0)or(CFrame.new()),{};for l,l in ipairs(_G.AutoScrapper)do S[l]=true;end;for l,l in ipairs( items :GetChildren())do if l:IsA("Model")and S[l.Name]then a,k=l.PrimaryPart or(l:FindFirstChildWhichIsA("BasePart")),l:FindFirstChild("ParticleEmitter",true);if a and(not k or k.Enabled==false)and _G.AutoScrapperH then pcall(function() remoteEvents .RequestStartDraggingItem:FireServer(l);end);l:SetPrimaryPartCFrame(K);task.wait();end;end;end;task.wait(0.6);end;end)();else while _G.AutoScrapperH do local k=workspace.Map.Campground:FindFirstChild("Scrapper");local a=k and(k:FindFirstChildWhichIsA("BasePart"));local k,K=a and a.CFrame*CFrame.new(0,18,0)or(CFrame.new()),{};for S,S in ipairs(_G.AutoScrapper)do K[S]=true;end;for S,l in ipairs( items :GetChildren())do if l:IsA("Model")and K[l.Name]then a,S=l.PrimaryPart or(l:FindFirstChildWhichIsA("BasePart")),l:FindFirstChild("ParticleEmitter",true);if a and(not S or S.Enabled==false)and _G.AutoScrapperH then pcall(function() remoteEvents .RequestStartDraggingItem:FireServer(l);end);l:SetPrimaryPartCFrame(k);task.wait();end;end;end;task.wait(0.6);end;end;end);end,
		})

		v:Space()
		v:Toggle({ Title = "Auto Sacrifice", Default = false, Callback = function(...) end })
	end

	v6:Space()

	local v16 = v6:Section({
		Title = "Hunger",
		ConfigFlagKey = "Auto",
		Icon = "utensils",
		Box = true,
		BoxBorder = true,
		Opened = true,
	})

	_G.TypeFoodToFill = "Carrot"

	v16:Dropdown({
		Title = "Select Food to Fill Hunger",
		Values = { "Carrot", "Berry", "Cooked Morsel", "Cooked Steak" },
		Value = "Carrot",
		Callback = function(I)_G.TypeFoodToFill=I;end,
	})

	hunger = 150

	v16:Slider({
		Title = "Hunger Threshold",
		Step = 1,
		Value = { Min = 1, Max = 200, Default = 100 },
		Callback = function(I)hunger=tonumber(I);end,
	})

	_G.AutoEat = false

	v16:Toggle({
		Title = "Auto Eat",
		Default = false,
		Callback = function(k)_G.AutoEat=k;if not k then return;end;task.spawn(function()local k= ReplicatedStorage3 .RemoteEvents.RequestConsumeItem;local a= ReplicatedStorage3 .RemoteEvents.RequestStartDraggingItem;local K= localPlayer .Character and( localPlayer .Character:FindFirstChild("HumanoidRootPart"));local function S(l)if not K then return;end;if not(l.PrimaryPart or(l:FindFirstChildWhichIsA("BasePart")))then return;end;l:PivotTo(K.CFrame+Vector3.new(0,3,0));repeat if not l:IsDescendantOf( Workspace )then break;end;pcall(function()a:FireServer(l);end);pcall(function()k:InvokeServer(l);end);task.wait(0.05);until not l:IsDescendantOf( Workspace )or( localPlayer :GetAttribute("Hunger")or 0)>=200;end;while _G.AutoEat do if( localPlayer :GetAttribute("Hunger")or 0)<=tonumber(hunger)then for k,k in ipairs( items :GetChildren())do if k.Name==_G.TypeFoodToFill and(k:IsA("Model"))then S(k);break;end;end;end;task.wait(0.3);end;end);end,
	})

	v16:Space()

	do
		local v = v6:Section({
			Title = "Minigames",
			ConfigFlagKey = "Other",
			Icon = "ellipsis",
			Box = true,
			BoxBorder = true,
			Opened = true,
		})

		v:Space()

		local function fn10(arg, arg2)
			if type(getgc) ~= "function" then
				return nil
			end
			local ok, result = pcall(getgc, true)
			if not ok or type(result) ~= "table" then
				return nil
			end

			for _, v17 in ipairs(result) do
				if type(v17) ~= "table" then
					continue
				end
				local value = rawget(v17, "RealModel")
				if typeof(value) == "Instance" and value:GetAttribute("ToolName") == arg and arg2(v17) then
					return v17
				end
			end

			return nil
		end

		v:Toggle({
			Title = "Instant Catch Fish",
			Flag = "Main_Other_Toggle_100_Catch_fish",
			Default = false,
			Callback = function(...) end,
		})

		v:Toggle({
			Title = "Instant Taming Minigame",
			Flag = "Main_Other_Toggle_100_Successful_Taming_Flute",
			Default = false,
			Callback = function(...) end,
		})

		v:Button({
			Title = "Instant Complete 3 Minigame Maze",
			Locked = false,
			Callback = function()local I=game:GetService("ReplicatedStorage");local k,a=I:FindFirstChild("RemoteEvents")and(I.RemoteEvents:FindFirstChild("CarnivalCompleteBasketballGallery")),workspace:FindFirstChild("Map")and(workspace.Map:FindFirstChild("Landmarks"));I=a and(a:FindFirstChild("Halloween Carnival"));a=I and(I:FindFirstChild("Games"));if not k or not a then return;end;I={"Basketball Hoop","Ring Toss","Shooting Gallery","Maze Entrance"};for K,K in ipairs(I)do local I=a:FindFirstChild(K);if I then pcall(function()k:FireServer(I);end);task.wait(0.2);end;end;end,
		})
	end

	v6:Space()

	do
		local v = v6:Section({
			Title = "Chest Tools",
			ConfigFlagKey = "Chest",
			Icon = "lock",
			Box = true,
			BoxBorder = true,
			Opened = true,
		})

		local tbl2 = {}
		local tbl3 = {}
		local v17 = nil
		_G.AutoOpenAllChests = false

		local function fn10(arg, arg2)
			if #arg ~= #arg2 then
				return true
			end

			for i = 1, #arg do
				if arg[i] ~= arg2[i] then
					return true
				end
			end

			return false
		end

		local function fn11()
			local items2 = workspace:FindFirstChild("Items")
			if not items2 then
				return
			end
			local tbl4 = {}
			local tbl5 = {}
			local tbl6 = {}
			local children = items2:GetChildren()

			for i, child in ipairs(children) do
				if child:IsA("Model") and child.Name:find("Chest") then
					for _, descendant in pairs(child:GetDescendants()) do
						if descendant:IsA("ProximityPrompt") then
							local name = child.Name
							tbl6[name] = (tbl6[name] or 0) + 1
							local str4 = name .. " (" .. tbl6[name] .. ")"
							table.insert(tbl4, str4)
							tbl5[str4] = child
							break
						end
					end
				end

				if i % 40 == 0 then
					task.wait()
				end
			end

			table.sort(tbl4)

			if fn10(tbl2, tbl4) then
				tbl2 = tbl4
				tbl3 = tbl5

				if v17 then
					v17:Refresh(tbl2)

					if #tbl2 > 0 then
						v17:Select(tbl2[1])
					else
						v17:Select("None")
					end
				end
			end
		end

		task.spawn(function()
			while v2 and not v2.Destroyed do
				task.wait(20)
				fn11()
			end
		end)

		v17 = v:Dropdown({
			Title = "Choose Chest To Teleport",
			Values = tbl2,
			Value = "None",
			Multi = false,
			AllowNone = true,
			Callback = function(I)_G.ChestV=I;end,
		})

		v:Button({ Title = "Reset Chest List", Callback = function(...) end })
		v:Button({ Title = "Teleport To Chest", Callback = function(...) end })

		v:Button({
			Title = "Open All Chests",
			Callback = function()local I={};for k,k in pairs(workspace.Items:GetChildren())do if string.find(k.Name,"Chest")and k.Name~="Stronghold Diamond Chest"then for a,a in pairs(k:GetDescendants())do if a:IsA("ProximityPrompt")then table.insert(I,a);end;end;end;end;for k,k in ipairs(I)do if k and(k:IsA("ProximityPrompt"))and k.Enabled then pcall(function()k.HoldDuration=0;fireproximityprompt(k,1);if typeof(chestLooted)=="function"then chestLooted();end;end);task.wait(0.05);end;end;end,
		})

		v:Toggle({
			Title = "Auto Open All Chests",
			Default = false,
			Callback = function(I)_G.AutoOpenAllChests=I;while _G.AutoOpenAllChests do for I,I in pairs(workspace.Items:GetChildren())do if string.find(I.Name,"Chest")and I.Name~="Stronghold Diamond Chest"then for k,k in pairs(I:GetDescendants())do if k:IsA("ProximityPrompt")and k.Enabled then pcall(function()k.HoldDuration=0;fireproximityprompt(k,1);if typeof(chestLooted)=="function"then chestLooted();end;end);task.wait(0.05);end;end;end;end;task.wait(3);end;end,
		})
	end

	v6:Space()

	getgenv().TypeSelect = {
		Resources = {
			"Log",
			"Chair",
			"Sapling",
			"Diamond",
			"Cultist",
			"Crossbow Cultist",
			"Alien",
			"Hologram Emitter",
		},
		Food = {
			"Morsel",
			"Cooked Morsel",
			"Steak",
			"Cooked Steak",
			"Berry",
			"Carrot",
			"Cake",
			"Chilli",
			"Stew",
			"Meat? Sandwich",
			"Corn",
			"Pumpkin",
		},
		Fuel = { "Coal", "Oil Barrel", "Fuel Canister", "Biofuel" },
		Metal = {
			"Broken Fan",
			"Sheet Metal",
			"Bolt",
			"Metal Chair",
			"Broken Microwave",
			"Old Car Engine",
			"Old Radio",
			"WashingMachine",
			"Cultist Gem",
			"Tyre",
			"Gem of the Forest Fragment",
			"UFO Junk",
			"UFO Component",
		},
		Tool = {
			"Old Flashlight",
			"Strong Flashlight",
			"Good Axe",
			"Strong Axe",
			"Chainsaw",
			"Good Sack",
			"Giant Sack",
			"Kunai",
			"Morningstar",
			"Wildfire",
			"Infernal Sack",
			"Defense Blueprint",
			"Bear Trap Blueprint",
			"Lava Mine Blueprint",
			"MedKit",
			"Bandage",
			"Spear",
			"Poison Spear",
			"Thorn Body",
			"Obsidiron Body",
			"Obsidiron Hammer",
			"Obsidiron Boots",
			"Cultist King Mace",
		},
		Gun = {
			"Revolver",
			"Revolver Ammo",
			"Rifle",
			"Rifle Ammo",
			"Tactical Shotgun",
			"Raygun",
			"Laser Canon",
			"Crossbow",
			"Infernal Crossbow",
			"Leather Body",
			"Iron Body",
			"Alien Amour",
		},
		Other = {
			"Halloween Candle",
			"Meteor Shard",
			"Gold Shard",
			"Raw Obsidiron Ore",
			"Scalding Obsidiron Ingot",
			"Obsidiron Ingot",
			"Anvil Front",
			"Anvil Base",
			"Anvil Back",
			"Sacrifice Totem",
			"Bunny Foot",
			"Wolf Pelt",
			"Alpha Wolf Pelt",
			"Bear Pelt",
			"Wolf Corpse",
			"Alpha Wolf Corpse",
			"Bear Corpse",
			"Polar Bear Pelt",
			"Coin Stack",
			"Arctic Wolf Pelt",
			"Mammoth Tusk",
			"Cultist King Antler",
			"Scorpion Shell",
		},
	}

	local fn10

	do
		local tbl2 = { "Fuel", "Resources", "Metal", "Food", "Tool", "Gun", "Other" }
		local tbl3 = {}

		for _, v in ipairs(tbl2) do
			for _, v17 in ipairs(getgenv().TypeSelect[v]) do
				tbl3[v17] = v
			end
		end

		local tbl4 = {
			"morsel",
			"steak",
			"ribs",
			"cake",
			"apple",
			"stew",
			"sandwich",
			"corn",
			"carrot",
			"lollypop",
			"chowder",
			"pumpkin",
			"jelly",
			"dinner",
			"berry",
			"chilli",
			"stuffing",
			"turkey",
			"potato",
			"casserole",
			"pepper",
			"juice",
			"strawberry",
			"meat",
			"eel",
			"lionfish",
			"shark",
			"swordfish",
			"salmon",
			"mackerel",
			"clownfish",
			"char",
			"candy",
			"chocolate",
			"fish",
			"honeycomb",
			"egg",
			"mre",
			"fruit",
			"drink",
			"soup",
			"pie",
			"burger",
			"snack",
		}

		local tbl5 = {
			"gun",
			"revolver",
			"rifle",
			"shotgun",
			"cannon",
			"raygun",
			"crossbow",
			"ammo",
			"blowpipe",
			"flamethrower",
			"pelter",
			"dissolve ray",
			"blaster",
			"laser",
			"bow",
			"pistol",
			"launcher",
		}

		local tbl6 = {
			"axe",
			"sack",
			"flashlight",
			"spear",
			"sword",
			"shield",
			"katana",
			"kunai",
			"morningstar",
			"hammer",
			"staff",
			"dagger",
			"mace",
			"scythe",
			"trident",
			"trap",
			"flute",
			"rod",
			"helmet",
			"medkit",
			"meds kit",
			"bandage",
			"blueprint",
			"tablet",
			"recipe",
			"paint",
			"watering can",
			"boots",
			"armour",
			"armor",
			"body",
			"cloak",
			"shuriken",
			"shovel",
			"skates",
			"spanner",
			"grenade",
			"dynamite",
			"scanner",
			"claws",
			"pickaxe",
			"sickle",
			"vest",
			"key",
			"tool",
			"kit",
			"pack",
			"pouch",
		}

		local tbl7 = {
			"metal",
			"microwave",
			"washing machine",
			"washingmachine",
			"tyre",
			"radio",
			"car engine",
			"gears",
			"ufo component",
			"ufo junk",
			"ufo scrap",
			"broken fan",
			"super bolt",
			"bolt",
			"iron",
			"steel",
			"copper",
			"bronze",
			"scrap",
			"part",
			"wire",
			"circuit",
			"chip",
		}

		local tbl8 = {
			"log",
			"plank",
			"sapling",
			"pelt",
			"diamond",
			"feather",
			"shell",
			"antler",
			"tusk",
			"gem",
			"shard",
			"ore",
			"ingot",
			"fur tuft",
			"flower",
			"petal",
			"bulb",
			"mandrake",
			"dripleaf",
			"vine",
			"acorn",
			"seed",
			"wood",
			"stone",
			"rock",
			"crystal",
			"leather",
			"bone",
			"fossil",
			"relic",
			"artifact",
			"totem",
			"fragment",
			"essence",
		}

		local function fn11(arg, arg2)
			for _, v in ipairs(arg2) do
				if string.find(arg, v, 1, true) then
					return true
				end
			end

			return false
		end

		local tbl9 = {}

		local function fn12(arg, arg2)
			if tbl3[arg] then
				return tbl3[arg]
			end

			if tbl9[arg] then
				return tbl9[arg]
			end
			local str4 = nil

			if arg2 then
				str4 = nil

				if arg2:GetAttribute("RestoreHunger") ~= nil then
					str4 = "Food"
				end

				local flag4 = not str4
				local flag5

				if flag4 then
					flag5 = arg2:GetAttribute("AmmoType") ~= nil or arg2:GetAttribute("ProjectileDamage") ~= nil
				else
					flag5 = flag4
				end

				if flag5 then
					str4 = "Gun"
				end

				local str5 = tostring(arg2:GetAttribute("ToolName") or "")

				if not str4 and str5 == "Firearm" then
					str4 = "Gun"
				end

				if not str4 and (arg2:GetAttribute("Interaction") == "Tool" or str5 ~= "") then
					str4 = "Tool"
				end

				if not str4 and arg2:GetAttribute("FuelValue") ~= nil then
					str4 = "Fuel"
				end
			end

			if not str4 then
				local v = string.lower(arg)

				if fn11(v, tbl4) then
					str4 = "Food"
				elseif v == "coal" or v == "biofuel" or string.find(v, "fuel", 1, true) or string.find(v, "oil barrel", 1, true) then
					str4 = "Fuel"
				elseif fn11(v, tbl5) then
					str4 = "Gun"
				elseif fn11(v, tbl6) then
					str4 = "Tool"
				elseif fn11(v, tbl7) then
					str4 = "Metal"
				elseif fn11(v, tbl8) then
					str4 = "Resources"
				else
					str4 = "Other"
				end
			end

			tbl9[arg] = str4
			return str4
		end

		local tbl10 = {}

		for _, v in ipairs(tbl2) do
			tbl10[v] = {}

			for _, v17 in ipairs(getgenv().TypeSelect[v]) do
				table.insert(tbl10[v], v17)
			end
		end

		local tbl11 = {}
		local tbl12 = {}
		local tbl13 = {}
		local tbl14 = {}

		local function fn13()
			for _, v in ipairs(tbl2) do
				tbl11[v] = {}
				tbl12[v] = false
				tbl14[v] = tbl14[v] or {}
				local v17 = ipairs
				local tbl15 = tbl10[v] or {}

				for _, v18 in v17(tbl15) do
					tbl11[v][v18] = true
				end
			end
		end

		fn13()

		local function fn14(arg, arg2)
			if type(arg) ~= "string" or arg == "" then
				return false
			end

			if string.find(string.lower(arg), "chest", 1, true) then
				return false
			end

			for _, v in ipairs(tbl2) do
				if tbl11[v][arg] then
					return false
				end
			end

			local v = fn12(arg, arg2)
			tbl11[v][arg] = true
			tbl12[v] = true
			return true
		end

		local function fn15(arg)
			local tbl15 = {}
			local tbl16 = {}

			for k in pairs(tbl11[arg]) do
				if string.find(string.lower(k), "chest", 1, true) then
					tbl11[arg][k] = nil
				else
					table.insert(tbl15, k)
					tbl16[k] = string.lower(k)
				end
			end

			table.sort(tbl15, function(arg2, arg3)
				return tbl16[arg2] < tbl16[arg3]
			end)

			getgenv().TypeSelect[arg] = tbl15
			tbl12[arg] = false
			return tbl15
		end

		local function fn16()
			for _, v in ipairs(tbl2) do
				fn15(v)
			end
		end

		local flag4 = false
		local flag5 = false

		fn10 = function(arg, arg2)
			if flag4 then
				if type(arg2) == "function" then
					task.spawn(function()
						while flag4 do
							task.wait(0.1)
						end

						arg2()
					end)
				end

				return
			end

			flag4 = true

			task.spawn(function()
				pcall(function()
					local children = items:GetChildren()

					for i, child in ipairs(children) do
						fn14(child.Name, child)

						if i % 15 == 0 then
							task.wait()
						end
					end

					if flag5 then
						local foryxeAdminV3 = ReplicatedStorage3:FindFirstChild("ForyxeAdmin_V3")
						foryxeAdminV3 = foryxeAdminV3 and foryxeAdminV3:FindFirstChild("EnumHandler")
						foryxeAdminV3 = foryxeAdminV3 and foryxeAdminV3:FindFirstChild("Enums")
						foryxeAdminV3 = foryxeAdminV3 and foryxeAdminV3:FindFirstChild("itemnames")
						foryxeAdminV3 = foryxeAdminV3 and foryxeAdminV3:GetAttribute("EnumValues")

						if type(foryxeAdminV3) == "string" then
							local v = string.split(foryxeAdminV3, "\\")

							for i, v17 in ipairs(v) do
								fn14(v17)

								if i % 15 == 0 then
									task.wait()
								end
							end
						end
					end

					for _, v in ipairs(tbl2) do
						if tbl12[v] then
							local v17 = fn15(v)
							local v18 = tbl13[v]

							if v18 then
								task.wait(0.02)
								v18:Refresh(v17)
								v18:Select(tbl14[v] or {})
							end
						end
					end
				end)

				flag4 = false

				if type(arg2) == "function" then
					task.wait(0.1)
					arg2()
				end
			end)
		end

		fn16()
		v7:Space()
		_G.ItemToPos = "Player"

		local v = v7:Section({
			Title = "Bring Settings",
			ConfigFlagKey = "Settings",
			Icon = "settings",
			Box = true,
			BoxBorder = true,
			Opened = true,
		})

		v:Dropdown({
			Title = "Drop Item To",
			Values = { "Player", "Campfire", "Scrapper" },
			Value = "Player",
			Callback = function(I)_G.ItemToPos=I;end,
		})

		_G.BringWithoutTPMode = "Normal"

		v:Dropdown({
			Title = "Bring Mode",
			Values = { "Normal", "Fast" },
			Value = "Normal",
			Callback = function(I)_G.BringWithoutTPMode=I;end,
		})

		v:Toggle({
			Title = "Admin Only Items",
			Desc = "Include items from admin folder in database",
			Value = false,
			Type = "Checkbox",
			Callback = function(...) end,
		})

		v:Button({ Title = "Refresh Item Database", Icon = "refresh-cw", Callback = function(...) end })
		v7:Space()

		local tbl15 = {
			Fuel = "flame",
			Resources = "logs",
			Metal = "wrench",
			Food = "beef",
			Tool = "hammer",
			Gun = "crosshair",
			Other = "package",
		}

		for i, v17 in ipairs(tbl2) do
			local v18 = getgenv().TypeSelect[v17]
			v7:Space()

			local v19 = v7:Section({
				Title = v17,
				ConfigFlagKey = v17 .. " Section",
				Icon = tbl15[v17] or "box",
				Box = true,
				BoxBorder = true,
				Opened = true,
			})

			tbl13[v17] = v19:Dropdown({
				Title = "Select " .. v17,
				Values = v18,
				Value = {},
				Multi = true,
				AllowNone = true,
				Callback = function(...) end,
			})

			v19:Button({
				Title = "Bring " .. v17,
				Desc = "Bring selected " .. v17 .. " items",
				Callback = function(...) end,
			})

			if i % 2 == 0 then
				RunService.Heartbeat:Wait()
			end
		end

		task.spawn(function()
			pcall(function()
				lib:Notify({
					Title = "Getting Item Data..",
					Content = "Script is getting item data in background...",
					Duration = 3,
					Icon = "database",
				})
			end)

			task.wait(1.5)

			pcall(function()
				lib:Notify({
					Title = "Item Data Loaded",
					Content = "Bring item database is ready to use.",
					Duration = 3,
					Icon = "check-circle",
				})
			end)
		end)

		if getgenv().__FN99BringItemConnection then
			pcall(function()
				getgenv().__FN99BringItemConnection:Disconnect()
			end)
		end

		local childAdded = items.ChildAdded

		getgenv().__FN99BringItemConnection = childAdded:Connect(function(arg)
			fn14(arg.Name, arg)
		end)
	end

	RunService.Heartbeat:Wait()

	local v17 = v8:Section({
		Title = "Locations",
		ConfigFlagKey = "Teleport",
		Icon = "map-pin",
		Box = true,
		BoxBorder = true,
		Opened = true,
	})

	v17:Button({
		Title = "Tp to Campfire",
		Locked = false,
		Callback = function()local I=game:GetService("Players").LocalPlayer;if I and I.Character and(I.Character:FindFirstChild("HumanoidRootPart"))then I.Character:PivotTo(CFrame.new(0,9,0));end;end,
	})

	v17:Button({
		Title = "Tp to Fish",
		Locked = false,
		Callback = function()local k=game.Players.LocalPlayer;local a,K=k.Character and(k.Character:FindFirstChild("HumanoidRootPart")),workspace:FindFirstChild("Map")and(workspace.Map:FindFirstChild("Landmarks"))and(workspace.Map.Landmarks:FindFirstChild("Fishing Hut"));if a and K then a.CFrame=K:GetPivot().Position and(CFrame.new(K:GetPivot().Position))or K.CFrame;elseif not K then  fn3 ("No Fishing Hut","Please expand map","warning",2);end;end,
	})

	v17:Button({
		Title = "Tp to Skills Building",
		Locked = false,
		Callback = function()local k=game.Players.LocalPlayer;local a,K=k.Character and(k.Character:FindFirstChild("HumanoidRootPart")),workspace:FindFirstChild("Map");k=K and(K:FindFirstChild("Landmarks"))and(K.Landmarks:FindFirstChild("Skills Building"));if a and k then a.CFrame=k.PrimaryPart and k.PrimaryPart.CFrame or(k:GetPivot());else  fn3 ("No Skills Building","Please expand map","warning",2);end;end,
	})

	v17:Button({
		Title = "Tp to Stronghold",
		Locked = false,
		Callback = function()local k=game.Players.LocalPlayer;local a,K=k.Character and(k.Character:FindFirstChild("HumanoidRootPart")),workspace:FindFirstChild("Map");k=K and(K:FindFirstChild("Landmarks"))and(K.Landmarks:FindFirstChild("Stronghold"));if a and k then a.CFrame=k.PrimaryPart and k.PrimaryPart.CFrame or(k:GetPivot());else  fn3 ("No Stronghold","Please expand map","warning",2);end;end,
	})

	v17:Button({
		Title = "Tp to ToolWorkshop",
		Locked = false,
		Callback = function()local k=game.Players.LocalPlayer;local a,K=k.Character and(k.Character:FindFirstChild("HumanoidRootPart")),workspace:FindFirstChild("Map");k=K and(K:FindFirstChild("Landmarks"))and(K.Landmarks:FindFirstChild("ToolWorkshop"));if a and k then a.CFrame=k.PrimaryPart and k.PrimaryPart.CFrame or(k:GetPivot());else  fn3 ("No ToolWorkshop","Please expand map","warning",2);end;end,
	})

	v17:Button({
		Title = "Tp to Sacrifice area",
		Locked = false,
		Callback = function()local k=game.Players.LocalPlayer;local a,K=k.Character and(k.Character:FindFirstChild("HumanoidRootPart")),workspace:FindFirstChild("Map");if not K then return  fn3 ("No Sacrifice","Map not found","warning",2);end;k=K:FindFirstChild("Landmarks");if not k then return  fn3 ("No Sacrifice","Landmarks not found","warning",2);end;K=k:FindFirstChild("Volcano");if not K then return  fn3 ("No Sacrifice","Volcano not found","warning",2);end;k=K:FindFirstChild("Functional");if not k then return  fn3 ("No Sacrifice","Functional not found","warning",2);end;K=k:FindFirstChild("Sacrifice");if not K then return  fn3 ("No Sacrifice","Sacrifice not found","warning",2);end;if a then k=if K:IsA("BasePart")then K else if K:IsA("Model")then K.PrimaryPart or(K:FindFirstChildWhichIsA("BasePart"))else nil;if k then a.CFrame=k.CFrame+Vector3.new(0,5,0);else  fn3 ("No Sacrifice","Cannot find part inside Sacrifice model","warning",2);end;end;end,
	})

	v17:Button({
		Title = "Tp to Ice Temple",
		Locked = false,
		Callback = function()local k=game.Players.LocalPlayer;local a,K=k.Character and(k.Character:FindFirstChild("HumanoidRootPart")),workspace:FindFirstChild("Map");k=K and(K:FindFirstChild("Landmarks"))and(K.Landmarks:FindFirstChild("Ice Temple"));if a and k then a.CFrame=k.PrimaryPart and k.PrimaryPart.CFrame or(k:GetPivot());else  fn3 ("No Ice Temple","Please expand map","warning",2);end;end,
	})

	v17:Button({
		Title = "Tp to Snow Clothing Shop",
		Locked = false,
		Callback = function()local k=game.Players.LocalPlayer;local a,K=k.Character and(k.Character:FindFirstChild("HumanoidRootPart")),workspace:FindFirstChild("Map");k=K and(K:FindFirstChild("Landmarks"))and(K.Landmarks:FindFirstChild("Snow Clothing Shop"));if a and k then a.CFrame=k.PrimaryPart and k.PrimaryPart.CFrame or(k:GetPivot());else  fn3 ("No Snow Clothing Shop","Please expand map","warning",2);end;end,
	})

	v17:Button({
		Title = "Tp to Research Facility",
		Locked = false,
		Callback = function()local k=game.Players.LocalPlayer;local a,K=k.Character and(k.Character:FindFirstChild("HumanoidRootPart")),workspace:FindFirstChild("Map");k=K and(K:FindFirstChild("Landmarks"))and(K.Landmarks:FindFirstChild("Research Facility"));if a and k then a.CFrame=k.PrimaryPart and k.PrimaryPart.CFrame or(k:GetPivot());else  fn3 ("No Research Facility","Please expand map","warning",2);end;end,
	})

	v17:Button({
		Title = "Tp to Research Outpost",
		Locked = false,
		Callback = function()local k=game.Players.LocalPlayer;local a,K=k.Character and(k.Character:FindFirstChild("HumanoidRootPart")),workspace:FindFirstChild("Map");k=K and(K:FindFirstChild("Landmarks"))and(K.Landmarks:FindFirstChild("Research Outpost"));if a and k then a.CFrame=k.PrimaryPart and k.PrimaryPart.CFrame or(k:GetPivot());else  fn3 ("No Research Outpost","Please expand map","warning",2);end;end,
	})

	v8:Space()

	do
		local v = v8:Section({
			Title = "Player Teleport",
			ConfigFlagKey = "Player",
			Icon = "users",
			Box = true,
			BoxBorder = true,
			Opened = true,
		})

		local tbl2 = {}
		local dropdown = nil

		local function fn11()
			tbl2 = {}
			local v18 = ipairs
			local Players2 = game:GetService("Players")

			for _, player_ in v18(Players2:GetPlayers()) do
				table.insert(tbl2, player_.Name)
			end

			if dropdown then
				dropdown:Refresh(tbl2)
			end
		end

		fn11()
		game:GetService("Players").PlayerAdded:Connect(fn11)
		game:GetService("Players").PlayerRemoving:Connect(fn11)
		dropdown = v.Dropdown

		dropdown = dropdown(v, {
			Title = "Select Player",
			Values = tbl2,
			Value = "None",
			Callback = function(I)_G.SelectedTpPlayer=I;end,
		})

		v:Button({
			Title = "Tp to Selected Player",
			Callback = function()local k=game:GetService("Players").LocalPlayer;local a,K=k.Character and(k.Character:FindFirstChild("HumanoidRootPart")),_G.SelectedTpPlayer and(game:GetService("Players"):FindFirstChild(_G.SelectedTpPlayer));k=K and K.Character and(K.Character:FindFirstChild("HumanoidRootPart"));if a and k then a.CFrame=k.CFrame+Vector3.new(0,3,0);else  fn3 ("Teleport","Invalid player or no character","warning",2);end;end,
		})
	end

	do
		local v = v8:Section({
			Title = "NPC Teleport",
			ConfigFlagKey = "NPC",
			Icon = "bot",
			Box = true,
			BoxBorder = true,
			Opened = true,
		})

		local tbl2 = {}
		local dropdown = nil

		local function fn11()
			tbl2 = {}
			local characters = workspace:FindFirstChild("Characters")

			if characters then
				for _, child in ipairs(characters:GetChildren()) do
					if child:IsA("Model") and not table.find(tbl2, child.Name) then
						table.insert(tbl2, child.Name)
					end
				end
			end

			table.sort(tbl2)

			if #tbl2 == 0 then
				table.insert(tbl2, "None")
			end
		end

		local function fn12()
			fn11()

			if dropdown then
				dropdown:Refresh(tbl2)
			end
		end

		fn11()
		dropdown = v.Dropdown

		dropdown = dropdown(v, {
			Title = "Select NPC",
			Values = tbl2,
			Value = "None",
			Callback = function(I)_G.SelectedTpNpc=I;end,
		})

		v:Button({
			Title = "Tp to NPC",
			Callback = function()local k=_G.SelectedTpNpc;if not k or k=="None"then return  fn3 ("Tp to NPC","No NPC selected","warning",2);end;local a=workspace:FindFirstChild("Characters");local K=a and(a:FindFirstChild(k));local a,S=K and(K:FindFirstChild("HumanoidRootPart")or K.PrimaryPart or(K:FindFirstChildWhichIsA("BasePart"))),game.Players.LocalPlayer.Character and(game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart"));if S and a then S.CFrame=a.CFrame; fn3 ("Tp to NPC","Teleported to "..k,"info",2);else  fn3 ("Tp to NPC","Target NPC or part not found","warning",2);end;end,
		})

		v:Button({ Title = "Refresh NPC List", Callback = function(...) end })
	end

	do
		local function fn11()
			if _G.TreePreviewParts then
				for _, treePreviewPart in ipairs(_G.TreePreviewParts) do
					treePreviewPart:Destroy()
				end
			end

			_G.TreePreviewParts = {}
		end

		local function fn12(arg)
			fn11()
			if not _G.ShowcasePlant then
				return
			end

			for _, v in ipairs(arg) do
				local part = Instance.new("Part")
				part.Size = Vector3.new(0.5, 0.5, 0.5)
				part.Shape = Enum.PartType.Ball
				part.Material = Enum.Material.Neon
				part.Color = Color3.fromRGB(0, 255, 120)
				part.Anchored = true
				part.CanCollide = false
				part.Position = Vector3.new(v.X, _G.ShapeHeight or 0, v.Z)
				part.Parent = Workspace
				table.insert(_G.TreePreviewParts, part)
			end
		end

		local function fn13()
			if not _G.ShowcasePlant then
				return
			end
			local shape = _G.Shape
			local v = getgenv().TreeShapes[shape]
			if not v then
				return
			end
			local position

			if _G.PositionsChosenShape == "Player" then
				local character = localPlayer.Character

				if character and character:FindFirstChild("HumanoidRootPart") then
					position = character.HumanoidRootPart.Position
				else
					position = Vector3.zero
				end
			elseif _G.PositionsChosenShape == "Last Planted" and _G.LastPlantPos then
				position = _G.LastPlantPos
			else
				position = Workspace:WaitForChild("Map"):WaitForChild("Campground"):WaitForChild("MainFire"):GetPivot().Position
			end

			local v18 = v(position, _G.ShapeRadius or 20, _G.ShapeSpacing or 1)
			fn12(v18)
		end
	end

	getgenv().TreeShapes = {
		Square = function(arg, arg2, arg3)
			local tbl2 = {}
			local num = tonumber(arg2)
			local num2 = tonumber(arg3)

			for i = -num, num, num2 do
				tbl2[#tbl2 + 1] = Vector3.new(arg.X + i, 0, arg.Z - num)
				tbl2[#tbl2 + 1] = Vector3.new(arg.X + i, 0, arg.Z + num)
			end

			for i = -num + num2, num - num2, num2 do
				tbl2[#tbl2 + 1] = Vector3.new(arg.X - num, 0, arg.Z + i)
				tbl2[#tbl2 + 1] = Vector3.new(arg.X + num, 0, arg.Z + i)
			end

			return tbl2
		end,
		Circle = function(arg, arg2, arg3)
			local tbl2 = {}
			local num = tonumber(arg2)
			local n = math.floor(6.2831853071795862 * num / tonumber(arg3))
			local n4 = 6.2831853071795862 / n

			for i = 0, n - 1 do
				local n5 = n4 * i
				local n6 = #tbl2 + 1
				local z = arg.Z
				tbl2[n6] = Vector3.new(arg.X + num * math.cos(n5), 0, z + num * math.sin(n5))
			end

			return tbl2
		end,
		Spiral = function(arg, arg2, arg3)
			local tbl2 = {}
			local num = tonumber(arg2)
			local num2 = tonumber(arg3)
			local n = 0
			local n4 = 0

			while n < num do
				local n5 = #tbl2 + 1
				local z = arg.Z
				tbl2[n5] = Vector3.new(arg.X + n * math.cos(n4), 0, z + n * math.sin(n4))
				n4 += 0.2
				n += num2 / 6.2831853071795862
			end

			return tbl2
		end,
		Triangle = function(arg, arg2, arg3)
			local tbl2 = {}
			local num = tonumber(arg2)
			local num2 = tonumber(arg3)

			for i = -num, num, num2 do
				tbl2[#tbl2 + 1] = Vector3.new(arg.X + i, 0, arg.Z + num)
			end

			for i = 0, num, num2 do
				tbl2[#tbl2 + 1] = Vector3.new(arg.X - num + i, 0, arg.Z + num - i)
				tbl2[#tbl2 + 1] = Vector3.new(arg.X + num - i, 0, arg.Z + num - i)
			end

			return tbl2
		end,
		Diamond = function(arg, arg2, arg3)
			local tbl2 = {}
			local num = tonumber(arg2)

			for i = -num, num, tonumber(arg3) do
				local n = num - math.abs(i)
				tbl2[#tbl2 + 1] = Vector3.new(arg.X + i, 0, arg.Z + n)
				tbl2[#tbl2 + 1] = Vector3.new(arg.X + i, 0, arg.Z - n)
			end

			return tbl2
		end,
		Heart = function(arg, arg2, arg3)
			local tbl2 = {}
			local num = tonumber(arg2)

			for i = 0, 3.1415926535897931, tonumber(arg3) / 20 do
				tbl2[#tbl2 + 1] = Vector3.new(arg.X + num * 16 * math.sin(i) ^ 3 * 0.1, 0, arg.Z + num * (13 * math.cos(i) - 5 * math.cos(2 * i) - 2 * math.cos(3 * i) - math.cos(4 * i)) * 0.1)
			end

			return tbl2
		end,
		Cross = function(arg, arg2, arg3)
			local tbl2 = {}
			local num = tonumber(arg2)

			for i = -num, num, tonumber(arg3) do
				tbl2[#tbl2 + 1] = Vector3.new(arg.X + i, 0, arg.Z)
				tbl2[#tbl2 + 1] = Vector3.new(arg.X, 0, arg.Z + i)
			end

			return tbl2
		end,
		Star = function(arg, arg2, arg3)
			local tbl2 = {}
			local num = tonumber(arg2)
			tonumber(arg3)

			for i = 0, 9 do
				local n = i % 2 == 0 and num or num * 0.5
				local n4 = 0.62831853071795862 * i
				tbl2[#tbl2 + 1] = Vector3.new(arg.X + n * math.cos(n4), 0, arg.Z + n * math.sin(n4))
			end

			return tbl2
		end,
		Pentagon = function(arg, arg2, arg3)
			local tbl2 = {}
			local num = tonumber(arg2)
			tonumber(arg3)

			for i = 0, 4 do
				local n = i * 1.2566370614359172
				tbl2[#tbl2 + 1] = Vector3.new(arg.X + num * math.cos(n), 0, arg.Z + num * math.sin(n))
			end

			return tbl2
		end,
	}

	do
		local flag4 = true
		local tbl2 = {}
		local tbl3 = {}

		local function createBillboardGui()
			local assets = ReplicatedStorage2:FindFirstChild("Assets")
			assets = assets and assets:FindFirstChild("Interface")
			assets = assets and assets:FindFirstChild("HealthBars")
			assets = assets and assets:FindFirstChild("HealthBar")
			if assets then
				return assets:Clone()
			end
			local billboardGui = Instance.new("BillboardGui")
			billboardGui.Name = "HealthBar"
			billboardGui.Size = UDim2.new(4, 0, 0.8, 0)
			billboardGui.AlwaysOnTop = true
			billboardGui.MaxDistance = 300
			billboardGui.LightInfluence = 0
			local imageButton = Instance.new("ImageButton")
			imageButton.Name = "HealthBar"
			imageButton.Size = UDim2.new(0.8, 0, 0.5, 0)
			imageButton.Position = UDim2.new(0.5, 0, 0.5, 0)
			imageButton.AnchorPoint = Vector2.new(0.5, 0.5)
			imageButton.BackgroundColor3 = Color3.fromRGB(43, 43, 43)
			imageButton.BorderSizePixel = 0
			imageButton.Parent = billboardGui
			local uiStroke = Instance.new("UIStroke")
			uiStroke.Color = Color3.fromRGB(20, 20, 20)
			uiStroke.Thickness = 1
			uiStroke.Parent = imageButton
			local imageButton2 = Instance.new("ImageButton")
			imageButton2.Name = "Bar"
			imageButton2.Size = UDim2.new(1, 0, 1, 0)
			imageButton2.Position = UDim2.new(0, 0, 0.5, 0)
			imageButton2.AnchorPoint = Vector2.new(0, 0.5)
			imageButton2.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
			imageButton2.BorderSizePixel = 0
			imageButton2.Parent = imageButton

			for i = 1, 4 do
				local frame = Instance.new("Frame")
				frame.Name = "HealthLine"
				frame.Size = UDim2.new(0, 1, 1, 0)
				frame.Position = UDim2.new(i * 0.2, 0, 0.5, 0)
				frame.AnchorPoint = Vector2.new(0.5, 0.5)
				frame.BackgroundColor3 = Color3.fromRGB(43, 43, 43)
				frame.BorderSizePixel = 0
				frame.ZIndex = 2
				frame.Parent = imageButton
			end

			return billboardGui
		end

		local function fn11(arg, arg2)
			if not arg or not arg.Parent or not arg2 or not arg2.Parent then
				return
			end
			local attribute = arg:GetAttribute("Health")
			if not attribute then
				arg2.Enabled = false
				return
			end
			local attribute2 = arg:GetAttribute("MaxHealth") or arg:GetAttribute("_FoxnameMaxHealth")

			if not attribute2 or attribute2 <= 0 then
				arg:SetAttribute("_FoxnameMaxHealth", attribute)
				attribute2 = attribute
			end

			local hitRegisters = arg:FindFirstChild("HitRegisters")

			if hitRegisters then
				local n = 0

				for k, v in pairs(hitRegisters:GetAttributes()) do
					if type(v) == "number" and (k:sub(1, 6) == "Local_" or k:find("Damage")) then
						n += v
					end
				end

				attribute = math.max(0, attribute - n)
			end

			local n = math.clamp(attribute / attribute2, 0, 1)
			local healthBar = arg2:FindFirstChild("HealthBar")
			local bar = healthBar and healthBar:FindFirstChild("Bar")

			if bar then
				bar.Size = UDim2.new(n, 0, 1, 0)

				if n <= 0.25 then
					bar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
				else
					bar.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
				end
			end

			if attribute < attribute2 and attribute > 0 then
				arg2.Enabled = true
			else
				arg2.Enabled = false
			end
		end

		local function fn12(arg)
			if not arg or not arg:IsA("Model") then
				return
			end

			if not (arg:GetAttribute("Resource") == "Tree" or string.find(string.lower(arg.Name), "tree", 1, true)) then
				return
			end
			local trunk = arg:FindFirstChild("Trunk") or arg.PrimaryPart or arg:FindFirstChildWhichIsA("BasePart")
			if not trunk then
				return
			end

			if tbl2[arg] then
				pcall(function()
					tbl2[arg]:Destroy()
				end)

				tbl2[arg] = nil
			end

			local v = createBillboardGui()
			if not v then
				return
			end
			v.Name = "TreeCustomHealthBar"
			v.Adornee = trunk
			v.StudsOffset = Vector3.new(0, math.clamp(-(trunk.Size.Y / 2) + 4.5, -trunk.Size.Y / 2 + 1, trunk.Size.Y / 2 - 1), 0)
			v.Enabled = false
			v.Parent = trunk
			tbl2[arg] = v
			fn11(arg, v)

			local connection = arg:GetAttributeChangedSignal("Health"):Connect(function()
				if flag4 then
					fn11(arg, v)
				end
			end)

			local connection2 = arg.AncestryChanged:Connect(function(child, parent)
				if not parent then
					if tbl2[arg] then
						pcall(function()
							tbl2[arg]:Destroy()
						end)

						tbl2[arg] = nil
					end
				end
			end)

			table.insert(tbl3, connection)
			table.insert(tbl3, connection2)
		end

		local function fn13(arg)
			flag4 = arg

			for _, v in ipairs(tbl3) do
				if v and typeof(v.Disconnect) == "function" then
					v:Disconnect()
				end
			end

			table.clear(tbl3)

			for _, v in pairs(tbl2) do
				if v and v.Parent then
					pcall(function()
						v:Destroy()
					end)
				end
			end

			table.clear(tbl2)
			if not arg then
				return
			end
			local map = Workspace:FindFirstChild("Map")
			map = map and map:FindFirstChild("Foliage")

			if map then
				for _, child in ipairs(map:GetChildren()) do
					fn12(child)
				end

				local connection = map.ChildAdded:Connect(function(child)
					if flag4 then
						task.wait(0.1)
						fn12(child)
					end
				end)

				table.insert(tbl3, connection)
			end

			local connection = Workspace.DescendantAdded:Connect(function(descendant)
				if flag4 and descendant:IsA("Model") and (descendant:GetAttribute("Resource") == "Tree" or string.find(string.lower(descendant.Name), "tree", 1, true)) then
					task.wait(0.1)
					fn12(descendant)
				end
			end)

			table.insert(tbl3, connection)
		end

		v11:Space()

		v11:Section({
			Title = "Tree Visuals",
			ConfigFlagKey = "Visuals",
			Icon = "eye",
			Box = true,
			BoxBorder = true,
			Opened = true,
		}):Toggle({ Title = "Tree Health Bar", Default = true, Value = true, Callback = function(...) end })

		fn13(true)
	end

	v11:Space()

	local v18 = v11:Section({
		Title = "Tree Builder",
		ConfigFlagKey = "Settings",
		Icon = "sprout",
		Box = true,
		BoxBorder = true,
		Opened = true,
	})

	v18:Space()

	v18:Dropdown({
		Title = "Shape",
		Values = { "Square", "Circle", "Spiral", "Triangle", "Diamond", "Heart", "Cross", "Star", "Pentagon" },
		Value = "Circle",
		Callback = function(...) end,
	})

	v18:Slider({
		Title = "Spacing",
		Step = 0.1,
		Value = { Min = 0.2, Max = 10, Default = 1 },
		Callback = function(...) end,
	})

	v18:Slider({
		Title = "Size",
		Step = 1,
		Value = { Min = 5, Max = 200, Default = 20 },
		Callback = function(...) end,
	})

	v18:Input({
		Title = "Height",
		Value = "4",
		InputIcon = "chevron-up",
		Type = "Input",
		Placeholder = "",
		Callback = function(...) end,
	})

	v18:Dropdown({
		Title = "Speed",
		Values = { "Instant", "Fast", "Normal", "Slow" },
		Value = "Instant",
		Callback = function(I)_G.PlantSpeed=I;end,
	})

	v18:Dropdown({
		Title = "Origin",
		Values = { "Center", "Player", "Last Planted" },
		Value = "Center",
		Callback = function(...) end,
	})

	v18:Toggle({ Title = "Showcase plant", Default = false, Callback = function(...) end })

	v18:Button({
		Title = "Build Plant (Inf Tree)",
		Desc = "Consumes saplings from Items to plant trees in a shape pattern",
		Callback = function()local k=nil;if _G.PositionsChosenShape=="Player"then local a= localPlayer .Character;k=if a and(a:FindFirstChild("HumanoidRootPart"))then a.HumanoidRootPart.Position else(Vector3.new(0.0,0.0,0.0));else k=if _G.PositionsChosenShape=="Last Planted"and _G.LastPlantPos then _G.LastPlantPos else  Workspace :WaitForChild("Map"):WaitForChild("Campground"):WaitForChild("MainFire"):GetPivot().Position;end;local a=getgenv().TreeShapes[_G.Shape];if not a then return;end;local K,S,l=a(k,_G.ShapeRadius or 20,_G.ShapeSpacing or 1),game:GetService("ReplicatedStorage"), Workspace :FindFirstChild("Items");a=S:WaitForChild("TempStorage");local function H()if not l then return nil;end;for t,t in pairs(l:GetChildren())do if t.Name=="Sapling"and(t:FindFirstChild("HitBox"))and(t:HasTag("Plantable"))then return t;end;end;return nil;end;local function l(t)local v,x,n,p=RaycastParams.new(), Workspace .Map:FindFirstChild("Ground"), Workspace .Map:FindFirstChild("Snow"),{};if x then table.insert(p,x);end;if n then table.insert(p,n);end;v.FilterDescendantsInstances=p;v.FilterType=Enum.RaycastFilterType.Include;v.IgnoreWater=true;p=workspace:Raycast(t+Vector3.new(0,20,0),Vector3.new(0,-80,0),v);return p and p.Position or nil;end;_G.LastPlantIdx=0;local t=0;local v=0;for x,n in ipairs(K)do local K=H();if not K then _G.LastPlantPos=Vector3.new(n.X,_G.ShapeHeight or 4,n.Z);_G.LastPlantIdx=x; fn3 ("Tree","No more saplings! Planted "..t..". Last pos saved.","warning",3);break;end;k=Vector3.new(n.X,_G.ShapeHeight or 4,n.Z);local H,n=l(k)or k,K.Parent;K.Parent=a;local k;if pcall(function()k=S.RemoteEvents.RequestPlantItem:InvokeServer(K,H);end)and k and k.Success then t+=1;_G.LastPlantPos=H;_G.LastPlantIdx=x;else v+=1;end;if _G.PlantSpeed=="Fast"then task.wait(0.02);elseif _G.PlantSpeed=="Normal"then task.wait(0.05);elseif _G.PlantSpeed=="Slow"then task.wait(0.1);end;end; fn3 ("Tree","Planted "..t.." trees"..(v>0 and", "..v.." failed"or""),"check",4);end,
	})

	_G.Speed = 27
	_G.SpeedT = false
	_G.JumpPower = 50
	_G.JumpPowerT = false
	RunService.Heartbeat:Wait()

	do
		local v = v9:Section({
			Title = "Movement",
			ConfigFlagKey = "Player",
			Icon = "user",
			Box = true,
			BoxBorder = true,
			Opened = true,
		})

		v:Slider({
			Title = "Set WalkSpeed",
			Step = 1,
			Value = { Min = 27, Max = 430, Default = 27 },
			Callback = function(I)_G.Speed=I;end,
		})

		v:Toggle({
			Title = "Auto WalkSpeed",
			Type = "Toggle",
			Default = false,
			Callback = function(I)_G.SpeedT=I;while _G.SpeedT do if game:GetService("Players").LocalPlayer.Character and(game:GetService("Players").LocalPlayer.Character:FindFirstChild("Humanoid"))then game:GetService("Players").LocalPlayer.Character.Humanoid.WalkSpeed=_G.Speed;end;task.wait();end;end,
		})

		v:Slider({
			Title = "Set JumpPower",
			Step = 1,
			Value = { Min = 27, Max = 320, Default = 50 },
			Callback = function(k)_G.JumpPower=k;if not _G.JumpPowerT then return;end;k= localPlayer .Character;if k and(k:FindFirstChildOfClass("Humanoid"))then local I=k:FindFirstChildOfClass("Humanoid");if I.UseJumpPower then I.JumpPower=_G.JumpPower;else I.JumpHeight=_G.JumpPower;end;end;end,
		})

		v:Toggle({
			Title = "Auto JumpPower",
			Type = "Toggle",
			Default = false,
			Callback = function(k)_G.JumpPowerT=k;local function a(K)if K then if K.UseJumpPower then K.JumpPower=_G.JumpPower;else K.JumpHeight=_G.JumpPower;end;end;end;if k then if  localPlayer .Character and( localPlayer .Character:FindFirstChildOfClass("Humanoid"))then a( localPlayer .Character:FindFirstChildOfClass("Humanoid"));end; localPlayer .CharacterAdded:Connect(function(I)local k=I:WaitForChild("Humanoid",9000000000);task.wait(0.05);a(k);end);end;end,
		})

		local localPlayer3 = game.Players.LocalPlayer
		local UserInputService = game:GetService("UserInputService")
		local currentCamera = workspace.CurrentCamera
		local character = localPlayer3.Character or localPlayer3.CharacterAdded:Wait()
		local humanoid = character:WaitForChild("Humanoid")
		local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
		local flag4 = false

		if UserInputService then
			flag4 = table.find({ Enum.Platform.Android, Enum.Platform.IOS }, UserInputService:GetPlatform()) ~= nil
		end

		local tbl2 = { f = 0, b = 0, l = 0, r = 0 }

		UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed then
				return
			end

			if _G.SetSpeedFly and type(_G.SetSpeedFly) == "number" then
				if input.KeyCode == Enum.KeyCode.W then
					tbl2.f = _G.SetSpeedFly
				elseif input.KeyCode == Enum.KeyCode.S then
					tbl2.b = -_G.SetSpeedFly
				elseif input.KeyCode == Enum.KeyCode.A then
					tbl2.l = -_G.SetSpeedFly
				elseif input.KeyCode == Enum.KeyCode.D then
					tbl2.r = _G.SetSpeedFly
				end
			end
		end)

		UserInputService.InputEnded:Connect(function(input, gameProcessed)
			if gameProcessed then
				return
			end

			if input.KeyCode == Enum.KeyCode.W then
				tbl2.f = 0
			elseif input.KeyCode == Enum.KeyCode.S then
				tbl2.b = 0
			elseif input.KeyCode == Enum.KeyCode.A then
				tbl2.l = 0
			elseif input.KeyCode == Enum.KeyCode.D then
				tbl2.r = 0
			end
		end)

		_G.SetSpeedFly = 100
		_G.StartFly = false
		local tbl3 = { Active = false, PreviousPlatformStand = false, Velocity = nil, Gyro = nil }

		Fly = function(startFly)
			_G.StartFly = startFly

			if not _G.StartFly then
				if not tbl3.Active then
					return
				end

				if tbl3.Velocity and tbl3.Velocity.Parent then
					tbl3.Velocity:Destroy()
				end

				if tbl3.Gyro and tbl3.Gyro.Parent then
					tbl3.Gyro:Destroy()
				end

				humanoid.PlatformStand = tbl3.PreviousPlatformStand == true
				tbl3.Active = false
				tbl3.Velocity = nil
				tbl3.Gyro = nil
				return
			end

			if not tbl3.Active then
				tbl3.Active = true
				tbl3.PreviousPlatformStand = humanoid.PlatformStand
			end

			while _G.StartFly do
				if tbl3.Velocity and tbl3.Velocity.Parent and tbl3.Gyro and tbl3.Gyro.Parent then
					local velocity = tbl3.Velocity
					local gyro = tbl3.Gyro
					velocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
					gyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
					humanoid.PlatformStand = true
					gyro.CFrame = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + currentCamera.CFrame.LookVector)
					local vector

					if flag4 then
						local moveVector = require(localPlayer3.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule")):GetMoveVector()
						vector = Vector3.zero

						if moveVector.Magnitude > 0 then
							vector = (currentCamera.CFrame.RightVector * moveVector.X + currentCamera.CFrame.LookVector * -moveVector.Z) * _G.SetSpeedFly
						end
					else
						vector = currentCamera.CFrame.LookVector * (tbl2.f + tbl2.b) + currentCamera.CFrame.RightVector * (tbl2.r + tbl2.l)
					end

					velocity.Velocity = vector
				else
					local bodyVelocity = Instance.new("BodyVelocity")
					local bodyGyro = Instance.new("BodyGyro")
					bodyVelocity.Name = "VelocityHandler"
					bodyVelocity.Parent = humanoidRootPart
					bodyVelocity.MaxForce = Vector3.zero
					bodyVelocity.Velocity = Vector3.zero
					bodyGyro.Name = "GyroHandler"
					bodyGyro.Parent = humanoidRootPart
					bodyGyro.MaxTorque = Vector3.zero
					bodyGyro.P = 1000
					bodyGyro.D = 50
					tbl3.Velocity = bodyVelocity
					tbl3.Gyro = bodyGyro
				end

				task.wait()
			end
		end

		v:Slider({
			Title = "Set Fly Speed",
			Step = 1,
			Value = { Min = 30, Max = 500, Default = 100 },
			Callback = function(I)_G.SetSpeedFly=I;end,
		})

		v:Toggle({ Title = "Fly Toggle", Type = "Toggle", Default = false, Callback = function(I)Fly(I);end })
		v:Toggle({ Title = "Noclip", Type = "Toggle", Default = false, Callback = function(...) end })
	end

	v10:Space()

	do
		local v = v10:Section({
			Title = "Player Trap",
			ConfigFlagKey = "Trap",
			Icon = "skull",
			Box = true,
			BoxBorder = true,
			Opened = true,
		})

		v:Paragraph({
			Title = "How to use",
			Desc = "You need a Bear Trap to kill people. Place one nearby, then select a player and toggle kill.",
			Image = "info",
			ImageSize = 20,
			Locked = false,
		})

		v:Space()
		local tbl2 = {}
		local v19 = ipairs
		local Players2 = game:GetService("Players")

		for _, player_ in v19(Players2:GetPlayers()) do
			table.insert(tbl2, player_.Name)
		end

		v:Dropdown({
			Title = "choose player",
			Values = tbl2,
			Value = "None",
			Callback = function(I)_G.PlayersTrollChoseCharacter=I;end,
		})

		v:Toggle({
			Title = "Kill player",
			Type = "Toggle",
			Default = false,
			Callback = function(I)_G.AutoTrapPlayers=I;if not I then return;end;task.spawn(function()while _G.AutoTrapPlayers do local I=game.Players[_G.PlayersTrollChoseCharacter];local k=I and I.Character and(I.Character:FindFirstChild("HumanoidRootPart"));if not k then task.wait(0.5);continue;end;for a,a in ipairs(workspace:GetDescendants())do if a.Name=="Bear Trap"and(a:IsA("Model"))and a.PrimaryPart and a.Parent.Name=="Structures"then local K=a.PrimaryPart;if K then pcall(function()sethiddenproperty(K,"NetworkOwnershipRule",Enum.NetworkOwnership.Manual);end);getgenv().Network=getgenv().Network or{BaseParts={},Velocity=Vector3.new(14,14,14)};if not table.find(getgenv().Network.BaseParts,K)then table.insert(getgenv().Network.BaseParts,K);end;a:PivotTo(k.CFrame*CFrame.new(0,0,-1));task.wait(0.05);game.ReplicatedStorage.RemoteEvents.RequestStartDraggingItem:FireServer(a);I=a:FindFirstChildWhichIsA("ProximityPrompt",true);if I then fireproximityprompt(I);end;task.wait(0.05);game.ReplicatedStorage.RemoteEvents.StopDraggingItem:FireServer(a);table.remove(getgenv().Network.BaseParts,table.find(getgenv().Network.BaseParts,K));pcall(function()sethiddenproperty(K,"NetworkOwnershipRule",Enum.NetworkOwnership.Automatic);end);end;end;end;task.wait(0.1);end;end);end,
		})
	end

	v10:Space()

	v10:Section({
		Title = "Fun",
		ConfigFlagKey = "Fun",
		Icon = "sparkles",
		Box = true,
		BoxBorder = true,
		Opened = true,
	}):Paragraph({ Title = "soon", Desc = "coming soon", Icon = "lock", Locked = true })

	v10:Space()

	do
		local v = v10:Section({
			Title = "World & Performance",
			ConfigFlagKey = "Others",
			Icon = "ellipsis",
			Box = true,
			BoxBorder = true,
			Opened = true,
		})

		v:Space()

		v:Button({
			Title = "Hide Big Trees",
			Callback = function()local k=workspace:FindFirstChild("Map")and(workspace.Map:FindFirstChild("Foliage"));if not k then return;end;local a=0;for K,K in ipairs(k:GetChildren())do if K.Name=="TreeBig1"or K.Name=="TreeBig2"or K.Name=="TreeBig3"then K:Destroy();a+=1;end;end; fn3 ("Hide Big Trees",a.." big trees removed.","check",3);end,
		})

		local tbl2 = { "Anvil Base", "Anvil Back", "Anvil Front" }

		v:Button({
			Title = "Bring Anvil to Workshop",
			Callback = function()task.spawn(function()local k=workspace.Map.Landmarks.ToolWorkshop_MeteorShower:FindFirstChild("Functional");local a=k and(k:FindFirstChild("AnvilHologram"));if not a then k=workspace.Map.Landmarks.ToolWorkshop:FindFirstChild("Functional");a=k and(k:FindFirstChild("AnvilHologram"));end;if not a then warn("Kh\195\180ng t\195\172m th\225\186\165y AnvilHologram \225\187\159 c\225\186\163 hai khu v\225\187\177c, \196\145\225\187\163i ho\225\186\183c ki\225\187\131m tra map...");repeat task.wait(0.5);k=workspace.Map.Landmarks.ToolWorkshop_MeteorShower:FindFirstChild("Functional");a=k and(k:FindFirstChild("AnvilHologram"));if not a then k=workspace.Map.Landmarks.ToolWorkshop:FindFirstChild("Functional");a=k and(k:FindFirstChild("AnvilHologram"));end;until a;end;for K,S in ipairs( tbl2 )do k=workspace.Items:FindFirstChild(S);if k and(k:IsA("Model"))and k.PrimaryPart then local S=k.PrimaryPart;pcall(function()sethiddenproperty(S,"NetworkOwnershipRule",Enum.NetworkOwnership.Manual);end);getgenv().Network=getgenv().Network or{BaseParts={},Velocity=Vector3.new(14,14,14)};if not table.find(getgenv().Network.BaseParts,S)then table.insert(getgenv().Network.BaseParts,S);end;S.CFrame=a.CFrame+Vector3.new(0,20,0);task.wait(0.05); ReplicatedStorage3 .RemoteEvents.RequestStartDraggingItem:FireServer(k);task.wait(0.05); ReplicatedStorage3 .RemoteEvents.StopDraggingItem:FireServer(k);K=table.find(getgenv().Network.BaseParts,S);if K then table.remove(getgenv().Network.BaseParts,K);end;pcall(function()sethiddenproperty(S,"NetworkOwnershipRule",Enum.NetworkOwnership.Automatic);end);end;end;end);end,
		})

		game:GetService("Lighting")

		local function fn11(arg)
			for _, descendant in ipairs(arg:GetDescendants()) do
				if descendant:IsA("Decal") or descendant:IsA("Texture") then
					descendant:Destroy()
				elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") or descendant:IsA("Fire") or descendant:IsA("Smoke") or descendant:IsA("Light") then
					descendant.Enabled = false
				elseif descendant:IsA("SurfaceGui") or descendant:IsA("BillboardGui") or descendant:IsA("SurfaceLight") then
					descendant:Destroy()
				elseif descendant:IsA("MeshPart") then
					descendant.TextureID = ""
					descendant.Reflectance = 0
					descendant.Material = Enum.Material.Plastic
					descendant.Color = Color3.fromRGB(127, 127, 127)
				elseif descendant:IsA("UnionOperation") or descendant:IsA("Part") then
					descendant.Material = Enum.Material.Plastic
					descendant.Color = Color3.fromRGB(127, 127, 127)
					descendant.Reflectance = 0
				end
			end
		end

		v:Toggle({
			Title = "Ultra Clean Mode",
			Desc = "Removes textures, particles, shadows, terrain, and accessories to boost FPS.",
			Default = false,
			Callback = function(...) end,
		})

		v:Toggle({ Title = "Full Bright", Type = "Toggle", Default = false, Callback = function(...) end })

		v:Toggle({
			Title = "No Fog",
			Type = "Toggle",
			Default = false,
			Callback = function(I)_G.NoFog=I;while _G.NoFog do for I,I in pairs(workspace:FindFirstChild("Map")and(workspace.Map:FindFirstChild("Boundaries"))and(workspace.Map.Boundaries:GetChildren())or{})do if not I:IsA("Model")then I:Destroy();end;end;task.wait(1);end;end,
		})

		_G.AntiVoid = false
		_G.AntiVoidY = -150
		local connection = nil

		local function fn12()
			if connection then
				connection:Disconnect()
				connection = nil
			end
		end

		local function fn13()
			fn12()

			connection = RunService.Heartbeat:Connect(function(...)
				error("devirt: could not lift closure: index nil @0,162663 - 0,162671")
			end)
		end

		v:Toggle({ Title = "Anti Void", Type = "Toggle", Default = false, Callback = function(...) end })

		v:Toggle({
			Title = "Instant Proximity Prompt",
			Type = "Toggle",
			Default = false,
			Callback = function(...) end,
		})

		_G.UnlockFullMap = false
		local genv = getgenv()
		genv.__FN99MapStreamRunId = genv.__FN99MapStreamRunId or 0

		local function fn14(arg, arg2)
			local ok, result = pcall(function()
				return gethiddenproperty(workspace, arg)
			end)

			return ok and tonumber(result) or arg2
		end

		if genv.__FN99OriginalStreamingTargetRadius == nil then
			local StreamingTargetRadius = fn14("StreamingTargetRadius", 1024)
			genv.__FN99OriginalStreamingTargetRadius = StreamingTargetRadius >= 4096 and 1024 or StreamingTargetRadius
		end

		if genv.__FN99OriginalStreamingMinRadius == nil then
			local StreamingMinRadius = fn14("StreamingMinRadius", 64)
			genv.__FN99OriginalStreamingMinRadius = StreamingMinRadius >= 4096 and 64 or StreamingMinRadius
		end

		if genv.__FN99OriginalStreamingEnabled == nil then
			genv.__FN99OriginalStreamingEnabled = true
		end

		if genv.__FN99OriginalStreamOutBehavior == nil then
			genv.__FN99OriginalStreamOutBehavior = Enum.StreamOutBehavior.Opportunistic
		end

		if genv.__FN99OriginalStreamingIntegrityMode == nil then
			genv.__FN99OriginalStreamingIntegrityMode = Enum.StreamingIntegrityMode.PauseOutsideLoadedArea
		end

		local function fn15(arg, arg2)
			if type(sethiddenproperty) ~= "function" then
				return false
			end

			local ok = pcall(function()
				sethiddenproperty(workspace, "StreamingTargetRadius", arg)
			end)

			local ok2 = pcall(function()
				sethiddenproperty(workspace, "StreamingMinRadius", arg2)
			end)

			return ok and ok2
		end

		local function fn16(arg)
			if type(sethiddenproperty) ~= "function" then
				return false
			end

			return pcall(function()
				sethiddenproperty(workspace, "StreamingEnabled", arg)
			end)
		end

		local function fn17(arg, arg2)
			local ok = pcall(function()
				sethiddenproperty(workspace, "StreamOutBehavior", arg)
			end)

			local ok2 = pcall(function()
				sethiddenproperty(workspace, "StreamingIntegrityMode", arg2)
			end)

			return ok and ok2
		end

		local function fn18()
			local items2 = workspace:FindFirstChild("Items")
			if not items2 then
				return 0
			end
			local n = 0

			for _, child in ipairs(items2:GetChildren()) do
				local isModel = child:IsA("Model")
				local primaryPart

				if isModel then
					primaryPart = child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart", true)
				else
					primaryPart = isModel
				end

				primaryPart = primaryPart or child:IsA("BasePart") and child

				if primaryPart then
					n += 1
				end
			end

			return n
		end

		local function fn19()
			local v19 = ipairs
			local fN99MapPinConnections = genv.__FN99MapPinConnections or {}

			for _, fN99MapPinConnection in v19(fN99MapPinConnections) do
				pcall(function()
					fN99MapPinConnection:Disconnect()
				end)
			end

			genv.__FN99MapPinConnections = {}
		end

		local function fn20()
			fn19()
			local fN99MapPinConnections = {}
			genv.__FN99MapPinConnections = fN99MapPinConnections

			local function fn21(descendant)
				if descendant:IsA("Model") then
					pcall(function()
						descendant.ModelStreamingMode = Enum.ModelStreamingMode.Persistent
					end)
				end
			end

			local v19 = ipairs
			local tbl3 = {}
			local map = workspace:FindFirstChild("Map")
			local structures = workspace:FindFirstChild("Structures")
			local v20 = workspace
			local findFirstChild = v20.FindFirstChild
			tbl3[1] = map
			tbl3[2] = structures

			do
				local values = table.pack(findFirstChild(v20, "Items"))
				table.move(values, 1, values.n, 3, tbl3)
			end

			for _, v21 in v19(tbl3) do
				if v21 then
					fN99MapPinConnections[#fN99MapPinConnections + 1] = v21.DescendantAdded:Connect(fn21)
					local n = 0

					for _, descendant in ipairs(v21:GetDescendants()) do
						fn21(descendant)
						n += 1

						if n % 1000 == 0 then
							task.wait()
						end
					end
				end
			end
		end

		local function fn21()
			if type(getgc) ~= "function" or not debug or type(debug.getupvalues) ~= "function" then
				return false
			end
			local v19 = nil
			local v20 = nil

			for _, v21 in ipairs(getgc(true)) do
				if type(v21) == "function" then
					local ok, result = pcall(debug.info, v21, "n")

					if ok and (result == "UncoverTilesAroundPlayer" or result == "UpdateRow") then
						local ok2, result2 = pcall(debug.info, v21, "s")

						if ok2 and string.find(tostring(result2), "MapDrawClient", 1, true) then
							if result ~= "UncoverTilesAroundPlayer" then
								v20 = v21
							else
								v19 = v21
							end
						end
					end
				end

				if not (v19 and v20) then
					continue
				end
				break
			end

			if not v19 or not v20 then
				return false
			end
			local v21 = debug.getupvalues(v19)
			local v22 = v21 and v21[4]
			v21 = v21 and v21[5]
			if type(v22) ~= "table" then
				return false
			end
			local tbl3 = {}

			for k, v23 in pairs(v22) do
				if type(v23) == "table" then
					for k2, v24 in pairs(v23) do
						if v24 == "Fog" then
							v23[k2] = "Discovered"
							tbl3[k] = true
							local flag4 = type(v21) == "table" and v21[k] and v21[k][k2]

							if type(flag4) == "table" then
								for _, v25 in pairs(flag4) do
									if typeof(v25) == "Instance" and v25:IsA("GuiObject") then
										v25.Visible = true
									end
								end
							end
						end
					end
				end
			end

			local n = 0

			for k in pairs(tbl3) do
				pcall(v20, k)
				n += 1

				if n % 8 == 0 then
					task.wait()
				end
			end

			return true
		end

		v:Toggle({ Title = "Expand Map", Default = false, Callback = function(...) end })
		local Players2 = game:GetService("Players")
		local VirtualUser = game:GetService("VirtualUser")
		local localPlayer3 = Players2.LocalPlayer
		_G.AntiAFK = false

		v:Toggle({
			Title = "Anti AFK",
			Default = false,
			Callback = function(k)_G.AntiAFK=k;if getgenv().AntiAFKConnection then getgenv().AntiAFKConnection:Disconnect();getgenv().AntiAFKConnection=nil;end;if k then local k=getconnections or get_signal_cons;if k then for a,a in pairs(k( localPlayer3 .Idled))do if a.Disable then a:Disable();elseif a.Disconnect then a:Disconnect();end;end;end;getgenv().AntiAFKConnection= localPlayer3 .Idled:Connect(function()if not _G.AntiAFK then return;end; VirtualUser :CaptureController(); VirtualUser :ClickButton2(Vector2.new());end);end;end,
		})

		local function fn22()
			local str4 = "mSrMzVuc3h"
			local str5 = "https://discord.com/api/v10/invites/" .. str4 .. "?with_counts=true&with_expiration=true"

			local function fn23(arg, arg2)
				local ok = pcall(function()
					setclipboard(arg2)
				end)

				fn3(arg, ok and "Copied to clipboard" or arg2, ok and "check" or "link", 3)
			end

			local function fn24(arg)
				local request_ = http_request or request or syn and syn.request
				local request_2

				if request_ then
					request_2 = request_
				else
					request_2 = fluxus and fluxus.request
				end

				if not request_2 then
					return nil
				end

				local ok, result = pcall(function()
					return request_2({
						Url = arg,
						Method = "GET",
						Headers = { ["User-Agent"] = "RobloxBot/1.0", Accept = "application/json" },
					})
				end)

				if not ok or not result or not result.Body then
					return nil
				end

				local ok2, result2 = pcall(function()
					return HttpService:JSONDecode(result.Body)
				end)

				return ok2 and result2 or nil
			end

			local function fn25(arg)
				local str6 = tostring(math.max(tonumber(arg) or 0, 0))
				local v19

				repeat
					str6, v19 = str6:gsub("^(%-?%d+)(%d%d%d)", "%1,%2")
				until v19 == 0

				return str6
			end

			local v19 = nil
			local flag4 = false

			local function fn26(arg)
				if flag4 then
					return
				end
				flag4 = true
				v19:SetTitle("Syncing community...")
				v19:SetDesc("Fetching live member and online counts from Discord.")
				v19:SetImage("loader-circle", 34)

				task.spawn(function()
					local v20 = fn24(str5)

					if v20 and v20.guild then
						local guild = v20.guild
						local str6 = guild.icon and "https://cdn.discordapp.com/icons/" .. guild.id .. "/" .. guild.icon .. ".png?size=1024" or "messages-square"
						v19:SetTitle(guild.name or "99 Nights Community")
						local str7 = "</b> online" .. "\n<font color=\"#94A3B8\">discord.gg/" .. str4 .. "</font>"
						v19:SetDesc("<font color=\"#22C55E\"><b>LIVE</b></font>  Official community server" .. "\n\n<b>" .. fn25(v20.approximate_member_count) .. "</b> members" .. "   •   <b>" .. fn25(v20.approximate_presence_count) .. str7)
						v19:SetImage(str6, 46)

						if arg then
							fn3("Discord", "Community stats updated", "refresh-cw", 2)
						end
					else
						v19:SetTitle("Community unavailable")
						v19:SetDesc("Discord did not return server information.\nUse Refresh stats to try again.")
						v19:SetImage("wifi-off", 34)

						if arg then
							fn3("Discord", "Could not refresh server stats", "triangle-alert", 3)
						end
					end

					flag4 = false
				end)
			end

			v19 = v3:Section({ Title = "99 Nights Community", Icon = "users-round", Box = true, BoxBorder = true, Opened = true }):Paragraph({
				Title = "Connecting to Discord...",
				Desc = "Preparing the 99 Nights community card.",
				Image = "messages-square",
				ImageSize = 46,
				Buttons = {
					{ Title = "Copy invite", Icon = "copy", Variant = "Primary", Callback = function(...) end },
					{
						Title = "Refresh stats",
						Icon = "refresh-cw",
						Variant = "Secondary",
						Callback = function(...) end,
					},
				},
			})

			v3:Space()

			v3:Section({ Title = "Why join?", Icon = "sparkles", Box = true, Opened = true }):Paragraph({
				Title = "Survive smarter",
				Desc = [[• Get script updates and announcements
• Report bugs and receive support
• Follow 99 Nights changes in one place]],
				Image = "radio-tower",
				ImageSize = 34,
			})

			task.spawn(function()
				task.wait(3)

				pcall(function()
					fn26(false)
				end)
			end)

			local v20 = v4:Section({ Title = "Latest Update", Icon = "badge-check", Box = true, BoxBorder = true, Opened = true }):Paragraph({
				Title = "99 Nights — Stability & Automation Update",
				Desc = [[<b>Added</b>
• Dynamic Bring and Tree item catalogs with Select All in Multi dropdowns
• Instant fishing catch and instant taming minigame helpers
• Auto Grab Children, Auto Flower and direct Gun Aura damage
• Full-map streaming sweep with adaptive gap recovery and real-item pinning
• Fun item effects section (temporarily locked for a safer physics rewrite)

<b>Changed</b>
• Gun Aura now includes instant reload and avoids projectile obstruction
• Godmode blocks only the two hunger warning popups
• Map expansion uses low-memory streaming, batched requests and persistence
• Multi-select controls now refresh automatically when the game adds new items

<b>Fixed</b>
• Reduced local-register pressure by isolating large runtime blocks
• Fixed stale item ownership cleanup when automation stops
• Fixed saved dropdown selections when new item names appear

<font color="#94A3B8">The Fun physics section is locked temporarily while its replicated, low-load version is being finalized.</font>]],
				Thumbnail = "https://raw.githubusercontent.com/caomod2077/test-public/refs/heads/main/AhaTok_me4i4i_306e5328-00d9-47b6-9c08-7816822afe2c_.jpg",
				ThumbnailSize = 112,
				Locked = false,
			})

			v20:SetTitle("99 Nights Script Update")

			v20:SetDesc([[<b>Added</b>
- Added new 300 item dropdown etc
- Added Select All inside Multi dropdowns
- Added Auto Flower
- Added Auto Grab Children
- Added Gun Aura
- Added config, auto save, other options in Setting

<b>Changed</b>
- Reworked UI
- Godmode no longer shows annoying hunger notifications
- 100% fishing catch and 100% taming minigame are now instant
- Expanding the map is faster and loads the full map
- Chop Aura now works on all tree types

<b>Fixed</b>
- Fixed Grab Children across all sacks with more precise targeting
- Fixed something idk i forgor]])

			v4:Space()
			local v21 = v4:Section({ Title = "Developer", Icon = "code-xml", Box = true, BoxBorder = true, Opened = true })

			v21:Paragraph({
				Title = "Cao Mod",
				Desc = "Script developer and owner.\nJoin Discord for releases, support and bug reports.",
				Image = "https://raw.githubusercontent.com/caomod2077/test-public/refs/heads/main/Kh%C3%B4ng%20C%C3%B3%20Ti%C3%AAu%20%C4%90%E1%BB%816_20260326105044.png",
				ImageSize = 46,
				Locked = false,
			})

			v21:Paragraph({
				Title = "Afkar",
				Desc = "Script developer and maintainer.",
				Image = tbl.afkar_icon and tbl.afkar_icon.id or "rbxassetid://93459612901981",
				ImageSize = 42,
				Locked = false,
			})

			local tbl3 = {}

			for i in ipairs({
				"https://link-hub.net/1344347/P6MNdBTa7Seh",
				"https://link-hub.net/1344347/RJRf4xTOGe3o",
				"https://direct-link.net/1344347/iaXZcb4V6GjT",
				"https://link-hub.net/1344347/sNxKdBZn4wxj",
			}) do
				table.insert(tbl3, {
					Title = i == 1 and "Copy primary support link" or "Copy support link " .. i,
					Icon = i == 1 and "heart-handshake" or "copy",
					Variant = i == 1 and "Primary" or "Secondary",
					Callback = function(...) end,
				})
			end

			v5:Section({
				Title = "Support 99 Nights",
				Icon = "heart-handshake",
				Box = true,
				BoxBorder = true,
				Opened = true,
			}):Paragraph({
				Title = "Keep the campfire burning",
				Desc = "Support is optional, but every visit helps keep development active.\nChoose any link below; it will only be copied to your clipboard.",
				Image = "gift",
				ImageSize = 42,
				Buttons = tbl3,
			})

			v5:Space()

			v5:Section({ Title = "Before you continue", Icon = "info", Box = true, Opened = true }):Paragraph({
				Title = "Transparent support links",
				Desc = "These are external Linkvertise/direct-link pages. The script copies the selected URL and never opens it automatically.",
				Image = "shield-check",
				ImageSize = 34,
			})
		end

		fn22()
		_G.LastPlantPos = nil
		_G.LastPlantIdx = 0

		local function fn23()
			tostring(json.name or "")
			local v19 = nil

			local function fn24(arg)
				local match = tostring(arg or ""):match("^%s*(.-)%s*$")
				if match == "" or match == "-- no configs --" or match == str then
					return nil
				end

				if match:find("[\\/:*?\"<>|]") then
					return nil
				end
				return match
			end

			local function fn25()
				if not configManager then
					return {}
				end

				local ok, result = pcall(function()
					return configManager:AllConfigs()
				end)

				if not ok or type(result) ~= "table" then
					return {}
				end
				local tbl3 = {}

				for _, v20 in ipairs(result) do
					if v20 ~= str then
						table.insert(tbl3, v20)
					end
				end

				table.sort(tbl3)
				return tbl3
			end

			local function fn26()
				if not v19 then
					return
				end
				local tbl3 = fn25()

				if #tbl3 == 0 then
					tbl3 = { "-- no configs --" }
				end

				v19:Refresh(tbl3)
			end

			local v20 = v12:Section({ Title = "Config", Icon = "database", Box = true, BoxBorder = true, Opened = true })

			if not configManager then
				v20:Paragraph({
					Title = "Config unavailable",
					Desc = "This WindUI build did not provide ConfigManager.",
					Image = "triangle-alert",
					ImageSize = 34,
				})
			else
				v20:Input({ Title = "Config Name", Placeholder = "Type config name...", Callback = function(...) end })
				v20:Button({ Title = "Create Config", Icon = "file-plus-2", Callback = function(...) end })
				local tbl3 = fn25()

				if #tbl3 == 0 then
					tbl3 = { "-- no configs --" }
				end

				v19 = v20:Dropdown({ Title = "Select Config", Values = tbl3, Value = tbl3[1], Callback = function(...) end })
				v20:Toggle({ Title = "Auto Load Config", Value = json.enabled == true, Callback = function(...) end })
				v20:Toggle({ Title = "Auto Save Config", Value = flag2, Callback = function(...) end })
				v20:Button({ Title = "Load Config", Icon = "download", Callback = function(...) end })
				v20:Button({ Title = "Overwrite Config", Icon = "save", Callback = function(...) end })
				v20:Button({ Title = "Delete Config", Icon = "trash-2", Callback = function(...) end })
				v20:Button({ Title = "Refresh Config List", Icon = "refresh-cw", Callback = function(...) end })
			end

			v12:Space()
			local settingsInterface = fn9(v12:Section({ Title = "Interface", Icon = "panel-top", Box = true, BoxBorder = true, Opened = true }), "Settings_Interface")

			settingsInterface:Keybind({
				Title = "Toggle UI Key",
				Flag = "Settings_UIToggleKey",
				Value = "RightShift",
				Callback = function(...) end,
			})

			settingsInterface:Slider({
				Title = "UI Scale",
				Desc = "Default: 0.9",
				Flag = "Settings_UIScale09",
				Value = { Min = 0.65, Max = 1.15, Default = n3 },
				Step = 0.05,
				Callback = function(...) end,
			})

			settingsInterface:Toggle({
				Title = "Notifications",
				Flag = "Settings_Notifications",
				Value = true,
				Callback = function(...) end,
			})

			settingsInterface:Button({ Title = "Center Window", Icon = "scan", Callback = function(...) end })
			v12:Space()
			local settingsAppearance = fn9(v12:Section({ Title = "Appearance", Icon = "palette", Box = true, BoxBorder = true, Opened = true }), "Settings_Appearance")
			local tbl3 = {}

			for k in pairs(lib:GetThemes()) do
				table.insert(tbl3, k)
			end

			table.sort(tbl3)

			settingsAppearance:Dropdown({
				Title = "Select Theme",
				Flag = "Settings_SelectedTheme",
				Values = tbl3,
				Value = theme,
				Callback = function(...) end,
			})

			settingsAppearance:Button({ Title = "Apply Theme", Callback = function(...) end })

			settingsAppearance:Input({
				Title = "Background ID / URL",
				Flag = "Settings_BackgroundImage",
				Value = str3,
				Placeholder = "Asset ID or https:// image URL",
				Callback = function(...) end,
			})

			settingsAppearance:Slider({
				Title = "Background Transparency",
				Desc = "0 is solid and 1 is fully transparent",
				Flag = "Settings_BackgroundTransparency",
				Value = { Min = 0, Max = 1, Default = n2 },
				Step = 0.1,
				Callback = function(...) end,
			})

			settingsAppearance:Button({ Title = "Restore Default Background", Icon = "rotate-ccw", Callback = function(...) end })
			v12:Space()

			v12:Section({ Title = "About", Icon = "circle-help", Box = true, Opened = true }):Paragraph({
				Title = "99 Nights in the Forest",
				Desc = [[Modern WindUI build
Configs: WindUI/99NightsInTheForest/config
Preferences: Foxname_99Nights/WindowPrefs.json]],
				Image = "info",
				ImageSize = 34,
			})
		end

		fn23()
		fn7()

		if type(fn10) == "function" then
			fn10(true)
		end

		local function fn24()
			if type(fn12) == "function" then
				fn12()
			end

			local genv2 = getgenv and getgenv() or _G
			genv2.Fn_Running = false
			genv2.fn_running = false
		end

	end
end

return NineNight
