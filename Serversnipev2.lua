--//===============================
--// Bahagian 1: UI Modern
--//===============================
-- (code UI modern awak yang pertama letak sini, tak diubah langsung)
-- Contoh: Draggable, Resizable, Tab System, Button Style, dsb.
-- Saya skip paste ulang panjang tu, tapi awak letak balik 100% code asal awak di sini.


--//===============================
--// Bahagian 2: System Sniper (tanpa UI lama)
--//===============================
repeat task.wait() until game:IsLoaded()

local h = game:GetService("HttpService")
local RequestFunction

if syn and syn.request then
	RequestFunction = syn.request
elseif request then
	RequestFunction = request
elseif http and http.request then
	RequestFunction = http.request
elseif http_request then
	RequestFunction = http_request
end

if _G.cursor == nil then
	_G.cursor =
		RequestFunction({
			Url = "https://raw.githubusercontent.com/LeymansGuz/playerTokens/main/cursor.txt",
			Method = "GET"
		})
	_G.cursor = h:JSONDecode(_G.cursor.Body)
end

-- Fungsi utama dari script kedua (tak diubah)
function runScript(placeId, user, mode)
	spawn(function()
		local timecount = tick()

		if _G.available == nil then
			_G.available = true
		end

		function checktokens(tokens)
			local payload = {
				Url = "https://thumbnails.roblox.com/v1/batch",
				Headers = {
					["Content-Type"] = "application/json"
				},
				Method = "POST",
				Body = {}
			}

			for i, v in pairs(tokens) do
				table.insert(payload.Body, {
					requestId = "0:" .. v[3] .. ":AvatarHeadshot:150x150:png:regular",
					type = "AvatarHeadShot",
					targetId = 0,
					token = v[3],
					format = "png",
					size = "150x150"
				})
			end
			payload.Body = h:JSONEncode(payload.Body)
			local result = RequestFunction(payload)
			local s, data = pcall(h.JSONDecode, h, result.Body)
			return data.data
		end

		function json()
			found = false
			if #_G.token >= 1 then
				if #_G.token > 100 then
					tab = {}
					for i = 1, 100 do
						table.insert(tab, _G.token[i])
						table.insert(_G.playertoken, _G.token[i])
						table.remove(_G.token, i)
					end
					leymans = checktokens(tab)
					if leymans then
						for i, v in pairs(leymans) do
							if v.imageUrl == _G.image then
								id = string.sub(v.requestId, 3, #v.requestId - 35)
								for a, b in pairs(_G.playertoken) do
									if b[3] == id then
										if not found then
											found = true
											_G.available = true
											if _G.mode == "TP" or _G.mode == "TPLog" then
												game:GetService("TeleportService"):TeleportToPlaceInstance(b[1], b[2])
											elseif _G.mode == "Log" then
												return
											end
										end
										return
									end
								end
							end
						end
					end
				elseif #_G.token <= 100 then
					tab2 = {}
					for i, v in pairs(_G.token) do
						table.insert(tab2, _G.token[i])
						table.insert(_G.playertoken, _G.token[i])
						table.remove(_G.token, i)
					end
					video = checktokens(tab2)
					if video then
						for i, v in pairs(video) do
							if v.imageUrl == _G.image then
								id = string.sub(v.requestId, 3, #v.requestId - 35)
								for a, b in pairs(_G.playertoken) do
									if b[3] == id then
										if not found then
											found = true
											_G.available = true
											if _G.mode == "TP" or _G.mode == "TPLog" then
												game:GetService("TeleportService"):TeleportToPlaceInstance(b[1], b[2])
											elseif _G.mode == "Log" then
												return
											end
										end
									end
								end
							end
						end
					end
					task.wait(1.5)
				end
			end
		end

		function json2()
			repeat
				spawn(function() json() end)
				local ti = tick()
				repeat game.RunService.RenderStepped:Wait() until tick() - ti > 0.015
			until #_G.token == 0
			_G.available = true
		end

		function playertoken(gameid, target)
			_G.token = {}
			_G.playertoken = {}
			_G.logged = false
			local suc, err = pcall(function()
				if _G.cursor[tostring(gameid)] and _G.available then
					_G.available = false
					if tonumber(target) then
						_G.plrname = game.Players:GetNameFromUserIdAsync(tonumber(target))
					else
						_G.plrname = target
						target = game.Players:GetUserIdFromNameAsync(target)
					end

					_G.plr = target
					_G.mode = mode

					local url = RequestFunction({
						Url = "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=" ..
							target .. "&format=Png&size=150x150&isCircular=false",
						Method = "GET"
					})
					_G.image = h:JSONDecode(url.Body).data[1].imageUrl
					if string.sub(_G.image, 10, 10) ~= "r" then return end

					a = {}
					for i = 1, #_G.cursor[tostring(gameid)] + 1 do
						if i > 1 then
							a[i] = _G.cursor[tostring(gameid)][i - 1]
						else
							a[i] = ""
						end
					end

					for i, v in ipairs(a) do
						spawn(function()
							a[i] = RequestFunction({
								Url = "https://games.roblox.com/v1/games/" ..
									gameid .. "/servers/0?excludeFullGames=false&limit=100&cursor=" .. a[i],
								Method = "GET"
							})
							a[i] = h:JSONDecode(a[i].Body).data
						end)
						task.wait(1/3.2)
					end

					for i, v in pairs(a) do
						for i2, v2 in pairs(v) do
							for i3, v3 in pairs(v2.playerTokens) do
								table.insert(_G.token, {gameid, v2.id, v3})
							end
						end
					end

					json2()
				end
			end)
			if not suc then
				_G.available = true
			end
		end

		playertoken(placeId, user)
	end)
end


--//===============================
--// Bahagian 3: Integrasi UI ↔ System
--//===============================
-- Contoh: dalam Tab "Server Snipe" di UI Modern awak
-- letak 3 input box (PlaceId, Username, Mode) + button "Snipe"

-- Anggap UI Modern ada elemen:
-- InputPlaceId, InputUsername, DropdownMode, ButtonSnipe

ButtonSnipe.MouseButton1Click:Connect(function()
	local placeId = InputPlaceId.Text
	local username = InputUsername.Text
	local mode = DropdownMode.Text  -- pilihan: "TP", "Log", "TPLog"

	if placeId ~= "" and username ~= "" and (mode == "TP" or mode == "Log" or mode == "TPLog") then
		runScript(placeId, username, mode)
	end
end)
