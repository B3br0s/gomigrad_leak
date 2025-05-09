-- "gamemodes\\homigradcom\\gamemode\\game\\scoreboard\\tier_1_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local red,green,white = Color(255,0,0),Color(0,255,0),Color(240,240,240)
local specColor = Color(155,155,155)
local whiteAdd = Color(255,255,255,5)
local unmutedicon = Material( "icon32/unmuted.png", "noclamp smooth" )
local mutedicon = Material( "icon32/muted.png", "noclamp smooth" )
choosedpanel = choosedpanel or "inventory"
local function ReadMuteStatusPlayers()
	return util.JSONToTable(file.Read("homigrad_mute.txt","DATA") or "") or {}
end

MutePlayers = ReadMuteStatusPlayers()

local function SaveMuteStatusPlayer(ply,value)
	if value == false then value = nil end
	MutePlayers[ply:SteamID()] = value
	file.Write("homigrad_mute.txt",util.TableToJSON(MutePlayers))
end

local function corter(a,b)
	return a:Team() < b:Team()
end

local grtodown = Material( "vgui/gradient-u" )
local grtoup = Material( "vgui/gradient-d" )
local grtoright = Material( "vgui/gradient-l" )
local grtoleft = Material( "vgui/gradient-r" )

muteallspectate = muteallspectate
mutealllives = mutealllives
local VLerp = Lerp

local TranslateNameInRound = {
    [1] = {
        ["homicide"] = "Невинный",
        ["tdm"] = "Красный",
        ["riot"] = "Бунтующий",
        ["hl2dm"] = "Повстанец",
        ["hunter"] = "Искатель",
    },
    [2] = {
        ["homicide"] = "Невинный",
        ["tdm"] = "Синий",
        ["riot"] = "Полиция",
        ["hl2dm"] = "Альянс",
        ["hunter"] = "Прячущийся",
    },
}

local TranslateModelInRound = {
    [1] = {
        ["tdm"] = "models/player/Group01/male_01.mdl",
        ["hl2dm"] = "models/player/Group03/male_01.mdl",
        ["riot"] = "models/player/Group01/male_01.mdl",
    },
    [2] = {
        ["tdm"] = "models/player/Group01/male_01.mdl",
        ["hl2dm"] = "models/player/combine_soldier.mdl",
        ["riot"] = "models/fbi_pack/fbi_01.mdl",
    },
}

local TranslateColorInRouund = {
    [1] = {
        ["tdm"] = Color(143,39,39),
        ["hl2dm"] = Color(141,84,23),
        ["riot"] = Color(141,84,23),
        ["hunter"] = Color(173,34,34),
    },
    [2] = {
        ["tdm"] = Color(37,21,175),
        ["riot"] = Color(37,21,175),
        ["hl2dm"] = Color(37,21,175),
        ["hunter"] = Color(21,155,44),
    }
}

local MADEL = "models/player/Group01/Male_01.mdl"

local madelki = {
    "models/player/Group01/Female_01.mdl",
    "models/player/Group01/Female_02.mdl",
    "models/player/Group01/Female_03.mdl",
    "models/player/Group01/Female_04.mdl",
    "models/player/Group01/Female_06.mdl",
    "models/player/Group01/Male_01.mdl",
    "models/player/Group01/male_02.mdl",
    "models/player/Group01/male_03.mdl",
    "models/player/Group01/Male_04.mdl",
    "models/player/Group01/Male_05.mdl",
    "models/player/Group01/male_06.mdl",
    "models/player/Group01/male_07.mdl",
    "models/player/Group01/male_08.mdl",
    "models/player/Group01/male_09.mdl",
}

local FastTDMArmors = {
    ["1"] = {
        ["col"] = {
            ["a"]	=	255,
            ["b"]	=	128,
            ["g"]	=	128,
            ["r"]	=	128,
        },
        ["name"] = "Altyn",
        ["tgl"]	 =	false,
    },
    ["2"] = {
        ["col"] = {
            ["a"]	=	255,
            ["b"]	=	128,
            ["g"]	=	128,
            ["r"]	=	128,
        },
        ["name"] = "Altyn Face Shield",
        ["tgl"]	 =	false,
    },
    ["3"] = {
        ["col"] = {
            ["a"]	=	255,
            ["b"]	=	128,
            ["g"]	=	128,
            ["r"]	=	128,
        },
        ["name"] = "TacTec",
        ["tgl"]	 =	false,
    },
}

local Beach = {
    ["1"] = {
        ["col"] = {
            ["a"]	=	255,
            ["b"]	=	128,
            ["g"]	=	128,
            ["r"]	=	128,
        },
        ["name"] = "Bastion",
        ["tgl"]	 =	false,
    },
    ["2"] = {
        ["col"] = {
            ["a"]	=	255,
            ["b"]	=	128,
            ["g"]	=	128,
            ["r"]	=	128,
        },
        ["name"] = "TT SK",
        ["tgl"]	 =	false,
    },
}

local ArmorsInRound = {
    ["tdm"] = {
        [1] = FastTDMArmors,
        [2] = FastTDMArmors,
    },
    ["hunter"] = {
        [1] = Beach,
    },
    ["hl2dm"] = {
        [1] = Beach,
    }
}

function XXXCreateModelButton(bgrund, parent, mdl, teamCommand)
    local w, h = parent:GetSize()
    local posX, posY = 0, 0

    local fovchkhik = 44
    local mdlPanel = vgui.Create("DModelPanel", parent)
    mdlPanel:SetSize(w, h)
    mdlPanel:SetModel(mdl)
    mdlPanel.dbtn = nil
	mdlPanel:SetLookAt(mdlPanel:GetEntity():GetBonePosition(0))
	mdlPanel:SetFOV(fovchkhik)
    local mEntity = mdlPanel:GetEntity()
    if IsValid(mdlPanel.Entity) then
        local clr = TranslateColorInRouund[teamCommand][roundActiveName] or Color(255,255,255,255)
        --mdlPanel.Entity:SetPlayerColor(Vector(clr.r/255, clr.g/255, clr.b/255))
        function mdlPanel.Entity:GetPlayerColor() return Vector(clr.r/255, clr.g/255, clr.b/255) end
    end
    mdlPanel.PostDrawModel = function(self, ent)
        if not IsValid(self) then return end
        if not IsValid(ent) then return end
        if ArmorsInRound == nil then return end
        if roundActiveName == nil then return end
        if teamCommand == nil then return end
        if ArmorsInRound[roundActiveName] == nil then return end
        if ArmorsInRound[roundActiveName][teamCommand] == nil then return end
		ent.Armors = (ArmorsInRound[roundActiveName][teamCommand] or {})
		JMod.HelloMyFriends(ent)
    end
    mdlPanel.Think = function(self)
        if teamCommand == 1 and (LocalPlayer():Team() == 1002 or roundActiveName == "homicide") then
            self:SetModel(MADEL)
        end
        if self.dbtn:IsHovered() then
            fovchkhik = VLerp(0.15, fovchkhik or 44, 40)
        else
            fovchkhik = VLerp(0.15, fovchkhik or 44, 44)
        end
        self:SetFOV(fovchkhik)
    end
    function mdlPanel:LayoutEntity(ent)
		ent:SetAngles( Angle( 0, 45, 0 ) )
	end

    local btn = vgui.Create("DButton", parent)
    btn:SetSize(w, h)
    btn:SetPos(posX, posY)
    btn:SetText("")
    btn.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(50, 50, 50, 200))
    end
    btn.DoClick = function()
        RunConsoleCommand("changeteam", teamCommand)
        bgrund:AlphaTo(0, 0.2, 0, nil)
    end
    btn.Paint = function(self, w, h)
        draw.SimpleText((TranslateNameInRound[teamCommand][roundActiveName] or "?"), "DefaultSmall", w/2, 10, Color(255,255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end
    mdlPanel.dbtn = btn
    
    return btn
end

timer.Create("ChangeModelKrasivzzco", 0.5, 0, function()
    MADEL = table.Random(madelki)
end)

local colorSpec = Color(155,155,155)
local colorRed = Color(205,55,55)
local colorGreen = Color(55,205,55)

ScoreboardRed = colorRed
ScoreboardSpec = colorSpec
ScoreboardGreen = colorGreen
ScoreboardBlack = Color(0,0,0,200)

ScoreboardList = ScoreboardList or {}
bxackgroundmkndhmvcd = bxackgroundmkndhmvcd or nil
local function timeSort(a,b)
	local time1 = math.floor(CurTime() - (a.TimeStart or 0) + (a.Time or 0))
	local time2 = math.floor(CurTime() - (b.TimeStart or 0) + (b.Time or 0))

	return time1 > time2
end

local TScoreB = {
	["user"] = {
		"",
		Color(15,15,15),
	},
	["megasponsor"] = {
		"Мега-Спонсор",
		Color(255,213,4),
	},
	["doperator"] = {
		"Донатный Оператор",
		Color(7,86,131),
	},
	["dadmin"] = {
		"Донатный Админ",
		Color(99,18,18),
	},
	["dsuperadmin"] = {
		"Донатный Супер-Админ",
		Color(129,20,20),
	},
	["intern"] = {
		"Интерн (стажер)",
		Color(182,69,69),
	},
	["operator"] = {
		"Оператор",
		Color(14,136,134),
	},
	["admin"] = {
		"Админ",
		Color(104,31,31),
	},
	["superadmin"] = {
		"Супер-Админ",
		Color(135,26,26)
	}
}
local gradient = Material("vgui/gradient_up") 

local function ToggleScoreboard(toggle)
	if toggle then
		if choosedpanel == "inventory" and not ply:Alive() then
			choosedpanel = "scoreboard"
		end

		if not IsValid(dv) then
			dv = vgui.Create( "DPanel" )
			dv:SetPos( ScrW()/1.08, ScrH()/2.6 )
			dv:SetSize( ScrW()*0.067, ScrH()/3.8)
			dv:SetBackgroundColor(Color(255,255,255,255))
			dv:MakePopup()
			dv.Paint = function(self,w,h)
				draw.RoundedBoxEx(10,0,0,w,h,Color(45,44,44,78), true, true, true ,true)
			end
			inv_button = vgui.Create( "DButton", dv )
			inv_button:SetPos( 0,0 )
			inv_button:SetSize( ScrW()/2, 90)
			inv_button:SetText("")
			inv_button.Paint = function(self,w,h)
				draw.RoundedBox(0,0,0,w,h,(self:IsHovered() and Color(92,92,92,155)) or Color(36,36,36,155))
				draw.SimpleText("Inventory", "TargetID", ScrW()*0.034, 90/2, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
			inv_button.DoClick = function(self)
				if ply:Alive() then
					ply:EmitSound("garrysmod/ui_click.wav")
					choosedpanel = "inventory"
					ToggleScoreboard(false)
					timer.Simple(0.001, function()
						ToggleScoreboard(true)
					end)
				else
					ply:ChatPrint("Вы мертвый.")
				end
			end

			scoreboard_button = vgui.Create( "DButton", dv )
			scoreboard_button:SetPos( 0,90 )
			scoreboard_button:SetSize( ScrW()/2, 90)
			scoreboard_button:SetText("")
			scoreboard_button.Paint = function(self,w,h)
				draw.RoundedBox(0,0,0,w,h,(self:IsHovered() and Color(92,92,92,155)) or Color(36,36,36,155))
				draw.SimpleText("Scoreboard", "TargetID", ScrW()*0.034, 90/2, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
			scoreboard_button.DoClick = function(self)
				ply:EmitSound("garrysmod/ui_click.wav")
				choosedpanel = "scoreboard"
				ToggleScoreboard(false)
				timer.Simple(0.001, function()
					ToggleScoreboard(true)
				end)
			end

			team_button = vgui.Create( "DButton", dv )
			team_button:SetPos( 0,90+90 )
			team_button:SetSize( ScrW()/2, 90)
			team_button:SetText("")
			team_button.Paint = function(self,w,h)
				draw.RoundedBox(0,0,0,w,h,(self:IsHovered() and Color(92,92,92,155)) or Color(36,36,36,155))
				draw.SimpleText("Teams", "TargetID", ScrW()*0.034, 90/2, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
			team_button.DoClick = function(self)
				ply:EmitSound("garrysmod/ui_click.wav")
				choosedpanel = "team"
				ToggleScoreboard(false)
				timer.Simple(0.001, function()
					ToggleScoreboard(true)
				end)
			end
		end
		if choosedpanel == "scoreboard" then
        	if IsValid(HomigradScoreboard) then return end--shut the fuck up

			showRoundInfo = CurTime() + 2.5

			local scrw,scrh = ScrW(),ScrH()

			HomigradScoreboard = vgui.Create("DFrame")
			HomigradScoreboard:SetTitle("")
			HomigradScoreboard:SetSize(scrw*.6,scrh*.8)
			HomigradScoreboard:Center()
			HomigradScoreboard:ShowCloseButton(false)
			HomigradScoreboard:SetDraggable(false)
        	HomigradScoreboard:MakePopup()
        	HomigradScoreboard:SetKeyboardInputEnabled(false)
			ScoreboardList[HomigradScoreboard] = true

			local wheelY = 0
			local animWheelUp,animWheelDown = 0,0

			function HomigradScoreboard:Sort()
				local teams = {}
				local lives,deads = {},{}
				if self.players then
					for ply in pairs(self.players) do
						if IsValid(ply) then
							ply.last = nil

							local teamID = ply:Team()
							teams[teamID] = teams[teamID] or {{},{}}
							teamID = teams[teamID]

							if ply:Alive() then
								teamID[1][#teamID[1] + 1] = ply
							else
								teamID[2][#teamID[2] + 1] = ply
							end
						end	
					end
				end

				for teamID,list in pairs(teams) do
					table.sort(list[1],timeSort)
					table.sort(list[2],timeSort)
				end

				local sort = {}

				local func = TableRound().ScoreboardSort
				if func then
					func(sort)
				else
					for teamID,team in pairs(teams) do
						for i,ply in pairs(team[1]) do sort[#sort + 1] = ply end
						for i,ply in pairs(team[2]) do sort[#sort + 1] = ply end

						local last = team[1][#team[1]]
						if last then
							local func = TableRound().Scoreboard_DrawLast
							if func and func(last) ~= nil then continue end

							last.last = #team[1]
						end

						last = team[2][#team[2]]
						if last then
							local func = TableRound().Scoreboard_DrawLast
							if func and func(last) ~= nil then continue end

							last.last = #team[2]
						end
					end
				end

				self.sort = sort
			end

			HomigradScoreboard.players = {}
			HomigradScoreboard.delaySort = 0
			HomigradScoreboard.Paint = function(self,w,h)

				surface.SetDrawColor(15,15,15,200)
				surface.DrawRect(0,0,w,h)

				draw.SimpleText("Статус","HomigradFont",100,15,white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
				draw.SimpleText("Имя","HomigradFont",w / 2,15,white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
				draw.SimpleText("GOMIGRAD","HomigradFontLarge",w / 2,h / 2,Color(155,155,165,10),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
				--draw.SimpleText("HOMIGRADED","HomigradFontLarge",w / 2,h / 2,Color(155,155,165,5),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
			
				--draw.SimpleText("Frags | Deaths","HomigradFont",w - 300,15,white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
				draw.SimpleText("Дни Часы Минуты","HomigradFont",w - 300,15,white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
				--draw.SimpleText("M","HomigradFont",w - 300 + 15,15,white,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
				draw.SimpleText("Пинг","HomigradFont",w - 200,15,white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
				draw.SimpleText("Команда","HomigradFont",w - 100,15,white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
				draw.SimpleText("Игроков: " .. table.Count(player.GetAll()),"HomigradFont",15,h - 25,green,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
				local tick = math.Round(1 / engine.ServerFrameTime())
				draw.SimpleText("TickRate Сервера: " .. tick,"HomigradFont",w - 15,h - 25,tick <= 35 and red or green,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)

				local players = self.players
				for i,ply in pairs(player.GetAll()) do
					if not players[ply] then self:AddPlayer(ply) self:Sort() end
				end

				for ply,panel in pairs(players) do
					if IsValid(ply) then continue end

					players[ply] = nil
					panel:Remove()

					self:Sort()
				end

				if self.delaySort < CurTime() then
					self.delaySort = CurTime() + 1 / 10

					self:Sort()
				end

				surface.SetMaterial(grtodown)
				surface.SetDrawColor(125,125,155,math.min(animWheelUp * 255,10))
				surface.DrawTexturedRect(0,0,w,animWheelUp)

				surface.SetMaterial(grtoup)
				surface.SetDrawColor(125,125,155,math.min(animWheelDown * 255,10))
				surface.DrawTexturedRect(0,h - animWheelDown,w,animWheelDown)

				local lerp = math.max(FrameTime() / (1 / 60) * 0.1,0)
				animWheelUp = Lerp(lerp,animWheelUp,0)
				animWheelDown = Lerp(lerp,animWheelDown,0)
				
				local yPos = -wheelY
				local sort = self.sort
				for i,ply in pairs(sort) do
					ply:SetMuted(MutePlayers[ply:SteamID()])

					if muteall then ply:SetMuted(true) end

					if muteAlldead and not ply:Alive() then ply:SetMuted(true) end

					local panel = players[ply]
					panel:SetPos(0,yPos)
					yPos = yPos + panel:GetTall() + 1
				end
			end

			local panelPlayers = vgui.Create("Panel",HomigradScoreboard)
			panelPlayers:SetPos(0,30)
			panelPlayers:SetSize(HomigradScoreboard:GetWide(),HomigradScoreboard:GetTall() - 90)
			function panelPlayers:Paint(w,h) end

			function HomigradScoreboard:OnMouseWheeled(wheel)
				local count = table.Count(self.players)
				local limit = count * 50 + count - panelPlayers:GetTall()

				if limit > 0 then
					wheelY = wheelY - math.Clamp(wheel,-1,1) * 50

					if wheelY < 0 then
						animWheelUp = animWheelUp + 132
						wheelY = 0
					elseif wheelY > limit then
						wheelY = limit
						animWheelDown = animWheelDown + 32
					end
				end
			end

			function HomigradScoreboard:AddPlayer(ply)
				local playerPanel = vgui.Create("DButton",panelPlayers)
				self.players[ply] = playerPanel
				playerPanel:SetText("")
				playerPanel:SetPos(0,0)
				playerPanel:SetSize(HomigradScoreboard:GetWide(),50)
				if ply.GetUserGroup then
					playerPanel.usergroup = ply:GetUserGroup()
				else
					playerPanel.usergroup = "user"
				end
				playerPanel.DoClick = function()
					local playerMenu = vgui.Create("DMenu")
					playerMenu:SetPos(input.GetCursorPos())
					playerMenu:AddOption("Скопировать SteamID", function()
						SetClipboardText(ply:SteamID())
						LocalPlayer():ChatPrint("SteamID " .. ply:Name() .. " скопирован! (" .. ply:SteamID() .. ")")
					end)
					playerMenu:AddOption("Скопировать SteamID64", function()
						SetClipboardText(ply:SteamID64())
						LocalPlayer():ChatPrint("SteamID64 " .. ply:Name() .. " скопирован! (" .. ply:SteamID64() .. ")")
					end)
					playerMenu:AddOption("Скопировать Ник", function()
						SetClipboardText(ply:Name())
					end)
					playerMenu:AddOption("Открыть профиль", function()
						ply:ShowProfile()
					end)
					playerMenu:AddOption("К нему", function()
						if LocalPlayer():IsUserGroup("superadmin") then	
							LocalPlayer():ConCommand("ulx goto " .. ply:Name())
						else
							LocalPlayer():ChatPrint("Ты не админ, иди нахуй!")
						end
					end)
					playerMenu:AddOption("Ко мне", function()
						if LocalPlayer():IsUserGroup("superadmin") then	
							LocalPlayer():ConCommand("ulx teleport " .. ply:Name())
						else
							LocalPlayer():ChatPrint("Ты не админ, иди нахуй!")
						end
					end)
					playerMenu:AddOption("Вернуть", function()
						if LocalPlayer():IsUserGroup("superadmin") then	
							LocalPlayer():ConCommand("ulx return " .. ply:Name())
						else
							LocalPlayer():ChatPrint("Ты не админ, иди нахуй!")
						end
					end)
					playerMenu:AddOption("Зареспавнить", function()
						if LocalPlayer():IsUserGroup("superadmin") then	
							LocalPlayer():ConCommand("ulx respawn " .. ply:Name())
						else
							LocalPlayer():ChatPrint("Ты не админ, иди нахуй!")
						end
					end)
					playerMenu:AddOption("Убить", function()
						if LocalPlayer():IsUserGroup("superadmin") then	
							LocalPlayer():ConCommand("ulx slay " .. ply:Name())
						else
							LocalPlayer():ChatPrint("Ты не админ, иди нахуй!")
						end
					end)
					
					playerMenu:MakePopup()

					ScoreboardList[playerMenu] = true
				end

				local name1 = ply:Name()
				local team = ply:Team()
				local usergroup = ply:GetUserGroup() or "user"
				local displayUsergroup
				if TScoreB[usergroup] then
					if TScoreB[usergroup][1] then
						displayUsergroup = TScoreB[usergroup][1]
					else
						displayUsergroup = TScoreB["user"][1]
					end
				else
					displayUsergroup = TScoreB["user"][1]
				end
				local alive
				local alivecol
				local colorAdd

				local func = TableRound().Scoreboard_Status
				if func then alive,alivecol,colorAdd = func(ply) end

				if not func or (func and alive == true) then
					if LocalPlayer():Team() == 1002 or not LocalPlayer():Alive() then
						if ply:Alive() then
							alive = "Живой"
							alivecol = colorGreen
						elseif ply:Team() == 1002 then
							alive = "Наблюдает"
							alivecol = colorSpec
						else
							alive = "Мёртв"
							alivecol = colorRed
							colorAdd = colorRed
						end
					elseif ply:Team() == 1002 then
						alive = "Наблюдает"
						alivecol = colorSpec
					else
						alive = "Неизвестно"
						alivecol = colorSpec
						colorAdd = colorSpec
					end
				end

				playerPanel.Paint = function(self,w,h)
					local colr = Color(15,15,15)
					if self.usergroup then
						if TScoreB[self.usergroup] then
							if TScoreB[self.usergroup][2] then
								colr = TScoreB[self.usergroup][2]
							end
						end
					end
					colr.a = playerPanel:IsHovered() and 122 or 55
					draw.RoundedBox(0, 0, 0, w, h, colr)

					surface.SetDrawColor(0, 0, 0, playerPanel:IsHovered() and 122 or 55)
					surface.SetMaterial(gradient)
					surface.DrawTexturedRect(0, 0, w,h)

					if colorAdd then
						surface.SetDrawColor(colorAdd.r,colorAdd.g,colorAdd.b,5)
						surface.DrawRect(0,0,w,h)
					end

					if ply == LocalPlayer() then
						draw.RoundedBox(0,0,0,w,h,whiteAdd)
					end

					if alive ~= "Неизвестно" and ply.last then
						--draw.SimpleText(ply.last,"HomigradFont",25,h / 2,white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
					end

					draw.SimpleText(alive,"HomigradFont",100,h / 2,alivecol,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
					-- Используем displayUsergroup вместо usergroup
					draw.SimpleText(displayUsergroup,"HomigradFont",300,h / 2,Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
					draw.SimpleText(name1, "HomigradFont", w / 2, h / 2, textColor1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
					
				
					if not ply.TimeStart then
						local kd = ply:Deaths() .. " | " .. ply:Frags()

						draw.SimpleText(kd,"HomigradFont",w - 300,h / 2,white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
					    else
					 	local time = math.floor(CurTime() - ply.TimeStart + (ply.Time or 0))
						local dTime,hTime,mTime = math.floor(time / 60 / 60 / 24),tostring(math.floor(time / 60 / 60) % 24),tostring(math.floor(time / 60) % 60)

						draw.SimpleText(dTime,"HomigradFont",w - 300 - 15,h / 2,white,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
						draw.SimpleText(hTime,"HomigradFont",w - 300,h / 2,white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
						draw.SimpleText(mTime,"HomigradFont",w - 300 + 15,h / 2,white,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
					end

					draw.SimpleText(ply:Ping(),"HomigradFont",w - 200,h / 2,white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

					local name,color = ply:PlayerClassEvent("TeamName")

					if not name then
						name,color = TableRound().GetTeamName(ply)
						name = name or "Наблюдатель"
						color = color or ScoreboardSpec
					end

					draw.SimpleText(name,"HomigradFont",w - 100,h / 2,color,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
				end

				if ply ~= LocalPlayer() then
					if ply and IsValid(ply) then
						local button = vgui.Create("DButton",playerPanel)
						button:SetSize(32,32)
						button:SetText("")
						local h = playerPanel:GetTall() / 2 - 32 / 2
						button:SetPos(playerPanel:GetWide() - playerPanel:GetTall() / 2 - 32 / 2,h)
						function button:DoClick()
							ply:SetMuted(not ply:IsMuted())
							SaveMuteStatusPlayer(ply,ply:IsMuted())
						end

						function button:Paint(w,h)
							if IsValid(ply) then
								surface.SetMaterial(ply:IsMuted() and mutedicon or unmutedicon)
								surface.SetDrawColor(255,255,255,255)
								surface.DrawTexturedRect(0,0,w,h)
							end
						end
					end
				end

				local avatar = vgui.Create("AvatarImage", playerPanel)
				avatar:SetSize(46, 46)
				avatar:SetPos(5, 2)
				avatar:SetPlayer(ply, 46)
			end

			local button = SB_CreateButton(HomigradScoreboard)
			button:SetSize(30,30)
			button:SetPos(HomigradScoreboard:GetWide() / 2 - button:GetWide() / 2,HomigradScoreboard:GetTall() - 15 - button:GetTall())
			button.text = "M"
			function button:DoClick()
				OpenHomigradMenu()
        	    HomigradScoreboard:Remove()
				if IsValid(dv) then
					dv:Remove()
				end
			end

			local muteAll = SB_CreateButton(HomigradScoreboard)
			muteAll:SetSize(175,30)
			muteAll:SetPos(-muteAll:GetWide() - 35 + HomigradScoreboard:GetWide() / 2,HomigradScoreboard:GetTall() - 45)
			muteAll.text = "Замутить всех"

			function muteAll:Paint(w,h)
				self.textColor = not muteall and green or red
				SB_PaintButton(self,w,h)
			end

			function muteAll:DoClick() muteall = not muteall end

			local muteAllDead = SB_CreateButton(HomigradScoreboard)
			muteAllDead:SetSize(175,30)
			muteAllDead:SetPos(35 + HomigradScoreboard:GetWide() / 2,HomigradScoreboard:GetTall() - 45)
			muteAllDead.text = "Замутить мертвых"

			function muteAllDead:Paint(w,h)
				self.textColor = not muteAlldead and green or red
				SB_PaintButton(self,w,h)
			end

			function muteAllDead:DoClick() muteAlldead = not muteAlldead end

			local func = TableRound().ScoreboardBuild

			if func then
				func(HomigradScoreboard,ScoreboardList)
			end
		elseif choosedpanel == "inventory" then
			if not IsValid(imenu) then
				CreateInventory()
			end
		elseif choosedpanel == "team" then
			bxackgroundmkndhmvcd = CreateTeamChangeGood()
		else
			choosedpanel = "scoreboard"
		end
	else
		ToggleScoreboard_Override = nil
		if IsValid(dv) then
			dv:Remove()
		end

		if IsValid(HomigradScoreboard) then
			HomigradScoreboard:Close()
		end
		if IsValid(bxackgroundmkndhmvcd) then
			bxackgroundmkndhmvcd:Remove()
		end
			
		RemoveInventory()
		for panel in pairs(ScoreboardList) do
			if not IsValid(panel) then continue end

			if panel.Close then panel:Close() else panel:Remove() end
		end 
	end
end

hook.Add("ScoreboardShow","HomigradOpenScoreboard",function()
	ToggleScoreboard(true)

	return false
end)

hook.Add("ScoreboardHide","HomigradHideScoreboard",function()
	if ToggleScoreboard_Override then return end
	choosedpanel = "inventory"
	ToggleScoreboard(false)
end)

net.Receive("close_tab",function(len)
	ToggleScoreboard(false)
end)

ToggleScoreboard(false)