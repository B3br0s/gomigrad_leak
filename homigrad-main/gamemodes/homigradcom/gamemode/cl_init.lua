-- "gamemodes\\homigradcom\\gamemode\\cl_init.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
include("shared.lua")

surface.CreateFont("HomigradFont", {
	font = "Roboto",
	size = 14,
	weight = 1100,
	outline = false
})

surface.CreateFont("HomigradFontBig", {
	font = "Roboto",
	size = 20,
	weight = 1100,
	outline = false,
	shadow = true
})

surface.CreateFont("HomigradFontNotify", {
	font = "Roboto",
	size = ScreenScale(17),
	weight = 1100,
	outline = false
})

surface.CreateFont("HomigradFontBigger", {
	font = "Roboto",
	size = 24,
	weight = 1100,
	outline = false
})

surface.CreateFont("HomigradRoundFont", {
	font = "Roboto",
	size = ScreenScale(10),
	weight = 1100,
	outline = false
})

surface.CreateFont("HomigradFontLarge", {
	font = "Roboto",
	size = ScreenScale(25),
	weight = 1100,
	outline = false
})

surface.CreateFont("HomigradFontSmall", {
	font = "Roboto",
	size = ScreenScale(10),
	weight = 1100,
	outline = false
})

surface.CreateFont("TabLarge", {
	font = "Roboto",
	size = 16,
	weight = 700,
	antialias = true,
	shadow = false,
})

surface.CreateFont("HomigradDefaultFixedDropShadow", {
	font = "Trebuchet MS",
	size = 14,
	weight = 0,
	shadow = true,
	outline = false
})

-- Harrisons puts ConVar in worst script, asked to leave
CreateClientConVar("hg_scopespeed", "0.5", true, false, "Changes the speed of the sniper scope when zoomed in.", 0, 5)
CreateClientConVar("hg_usecustommodel", "false", true, true, "Allows usage of custom models.")

-- For player models!!
local validUserGroup = {
	superadmin = true,
	admin = true,
	operator = true,
	megasponsor = true,
	doperator = true,
	dadmin = true,
	dsuperadmin = true,
        intern = true,
	user = false,
}

net.Receive("round_active", function(len)
	roundActive = net.ReadBool()
	roundTimeStart = net.ReadFloat()
	roundTime = net.ReadFloat()
end)

net.Receive("hg_sendchat", function(len)
	local ply = LocalPlayer()
	local msg = net.ReadTable()
	if not msg then return end

	local tbl = {}
	for _, v in ipairs(msg) do
		tbl[#tbl + 1] = string.StartsWith(v, "#") and language.GetPhrase(v) or v
	end

	if IsValid(ply) then
		ply:ChatPrint(table.concat(tbl))
	end
end)

net.Receive("hg_sendchat_simple", function(len)
	local ply = LocalPlayer()
	local msg = net.ReadString()
	if not msg then return end

	if IsValid(ply) then
		ply:ChatPrint(string.StartsWith(msg, "#") and language.GetPhrase(msg) or msg)
	end
end)

net.Receive("hg_sendchat_format", function(len)
	local ply = LocalPlayer()
	local msg = net.ReadTable()
	if not msg then return end

	local tbl = {}
	for _, v in ipairs(msg) do
		tbl[#tbl + 1] = string.StartsWith(v, "#") and language.GetPhrase(v) or v
	end

	local text = tbl[1]
	local args = {unpack(tbl, 2)} -- Extract other args

	if IsValid(ply) then
		ply:ChatPrint(language.GetPhrase(text):format(unpack(args)))
	end
end)

local view = {}

hook.Add("PreCalcView", "spectate", function(lply, pos, ang, fov, znear, zfar)
	lply = LocalPlayer()
	if lply:Alive() or GetViewEntity() ~= lply then return end

	view.fov = CameraSetFOV

	local spec = lply:GetNWEntity("HeSpectateOn")
	if not IsValid(spec) then
		view.origin = lply:EyePos()
		view.angles = ang

		return view
	end

	spec = IsValid(spec:GetNWEntity("Ragdoll")) and spec:GetNWEntity("Ragdoll") or spec

	local dir = Vector(1, 0, 0)
	dir:Rotate(ang)

	local head = spec:LookupBone("ValveBiped.Bip01_Head1")
	local tr = {}
	tr.start = head and spec:GetBonePosition(head) or spec:EyePos()
	tr.endpos = tr.start - dir * 75

	tr.filter = {lply, spec, lply:GetVehicle()}

	view.origin = util.TraceLine(tr).HitPos
	view.angles = ang

	return view
end)

SpectateHideNick = SpectateHideNick or false

local keyOld, keyOld2
flashlight = flashlight or nil
flashlightOn = flashlightOn or false

local gradient_d = Material("vgui/gradient-d")

hook.Add("HUDPaint", "spectate", function()
	local lply = LocalPlayer()
	local spec = lply:GetNWEntity("HeSpectateOn")

	if lply:Alive() and IsValid(flashlight) then
		flashlight:Remove()
		flashlight = nil
	end

	local result = lply:PlayerClassEvent("CanUseSpectateHUD")
	if result == false then return end

	if (((not lply:Alive() or lply:Team() == 1002 or spec and lply:GetObserverMode() ~= OBS_MODE_NONE) or lply:GetMoveType() == MOVETYPE_NOCLIP) and not lply:InVehicle()) or result or hook.Run("CanUseSpectateHUD") then
		local ent = spec
		
		if IsValid(ent) then
			local health = math.Clamp(ent:Health(), 0, 150)
			local nick = ent:Nick()
		
			local w, h = 350, 90  
			local x, y = (ScrW() - w) / 2, ScrH() - h - 20  
		
			local gradient = Material("gui/gradient_up") 
		
			local sosal = ent:GetPlayerColor()

			draw.RoundedBox(12, x, y, w, h, Color(sosal[1]*255, sosal[2]*255, sosal[3]*255, 180))

			surface.SetDrawColor(0, 0, 0, 180)
			surface.SetMaterial(gradient)
			surface.DrawTexturedRect(x, y, w, h)
		
			draw.SimpleText(nick, "DefaultSmall", x + 15, y + 10, Color(255, 255, 255), TEXT_ALIGN_LEFT)
		
			draw.SimpleText("Здоровье", "DefaultVerySmall", x + 15, y + 45, Color(200, 200, 200), TEXT_ALIGN_LEFT)
		
			draw.RoundedBox(6, x + 60, y + 42, 260, 20, Color(60, 60, 60, 255))
			
			draw.RoundedBox(6, x + 60, y + 42, (health / 100) * 180, 20, Color(200 - (health * 2), health * 2, 50, 255))

			local func = TableRound().HUDPaint_Spectate
			if func then func(ent) end
		end

		local key = lply:KeyDown(IN_WALK)

		if keyOld ~= key and key then
			SpectateHideNick = not SpectateHideNick
			--chat.AddText("Ники игроков: " .. tostring(not SpectateHideNick))
		end

		keyOld = key
		local xcv
		if isstring(input.LookupBinding("+walk")) then
			xcv = input.LookupBinding("+walk")
		else
			xcv = "unknown"
		end
		draw.SimpleText(language.GetPhrase("hg.spec.names"):format(string.upper(xcv)), "HomigradFont", 15, ScrH() - 15, showRoundInfoColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
		local key = input.IsButtonDown(KEY_F)

		if not lply:Alive() and keyOld2 ~= key and key then
			flashlightOn = not flashlightOn

			if flashlightOn then
				if not IsValid(flashlight) then
					flashlight = ProjectedTexture()
					flashlight:SetTexture("effects/flashlight001")
					flashlight:SetFarZ(900)
					flashlight:SetFOV(70)
					flashlight:SetEnableShadows(false)
				end
			else
				if IsValid(flashlight) then
					flashlight:Remove()
					flashlight = nil
				end
			end
		end

		keyOld2 = key

		if flashlight then
			flashlight:SetPos(EyePos())
			flashlight:SetAngles(EyeAngles())
			flashlight:Update()
		end

		if not SpectateHideNick then
			local func = TableRound().HUDPaint_ESP

			if func then
				func()
			end

			-- ESP
			for _, v in ipairs(player.GetAll()) do
				if not v:Alive() or v == ent then continue end

				local ent = IsValid(v:GetNWEntity("Ragdoll")) and v:GetNWEntity("Ragdoll") or v
				local screenPosition = ent:GetPos():ToScreen()
				local x, y = screenPosition.x, screenPosition.y
				local teamColor = v:GetPlayerColor():ToColor()
				local distance = lply:GetPos():Distance(v:GetPos())
				local factor = 1 - math.Clamp(distance / 1024, 0, 1)
				local size = math.max(10, 32 * factor)
				local alpha = math.max(255 * factor, 80)

				local text = v:Name()
				surface.SetFont("Trebuchet18")
				local tw, th = surface.GetTextSize(text)

				surface.SetDrawColor(teamColor.r, teamColor.g, teamColor.b, alpha * 0.5)
				surface.SetMaterial(gradient_d)
				surface.DrawTexturedRect(x - size / 2 - tw / 2, y - th / 2, size + tw, th)

				surface.SetTextColor(255, 255, 255, alpha)
				surface.SetTextPos(x - tw / 2, y - th / 2)
				surface.DrawText(text)

				local barWidth = math.Clamp((v:Health() / 150) * (size + tw), 0, size + tw)
				local healthcolor = v:Health() / 150 * 255

				surface.SetDrawColor(255, healthcolor, healthcolor, alpha)
				surface.DrawRect(x - barWidth / 2, y + th / 1.5, barWidth, ScreenScale(1))
			end
		end
	end
end)

hook.Add("HUDDrawTargetID", "no", function() return false end)

local laserweps = {
	["weapon_xm1014"] = true,
	["weapon_p90"] = true,
	["weapon_m249"] = true,
	["weapon_p99"] = true,
	["weapon_hk_usp"] = true,
	["weapon_hk416"] = true,
	["weapon_p99"] = true,
	["weapon_fiveseven"] = true,
	["weapon_m4a1"] = true,
	["weapon_ar15"] = true,
	["weapon_m4super"] = true,
	["weapon_mp7"] = true,
	["weapon_p220"] = true,
	["weapon_galil"] = true,
	["weapon_mateba"] = true,
	["weapon_beanbag"] = true,
	["weapon_glock"] = true,
}

laserplayers = laserplayers or {}
local mat = Material("sprites/bluelaser1")
local mat2 = Material("Sprites/light_glow02_add_noz")

hook.Add("PostDrawOpaqueRenderables", "laser", function()
	for i, ply in pairs(laserplayers) do
		if not IsValid(ply) then
			laserplayers[i] = nil
		end
		if not IsValid(ply) then continue end
		ply.Laser = ply.Laser or false

		local wep = ply:GetActiveWeapon()
		wep = IsValid(wep) and wep or ply:GetNWEntity("ActiveWeapon")

		if IsValid(wep) and IsValid(ply) and ply.Laser and not ply:GetNWBool("unconscious") and laserweps[wep:GetClass()] then
			if not IsValid(wep) then continue end

			local pos, ang = wep:GetTrace()

			local t = {}
			t.start = pos + ang:Right() * 0 + ang:Forward() * -5 + ang:Up() * -0.5
			t.endpos = t.start + ang:Forward() * 9000
			t.filter = {ply, wep, LocalPlayer(), ply:GetNWEntity("Ragdoll"), ply:GetNWEntity("ragdollWeapon")}
			t.mask = MASK_SOLID
			local tr = util.TraceLine(t)

			cam.Start3D(EyePos(), EyeAngles())
				render.SetMaterial(mat)
				render.DrawBeam(tr.StartPos, tr.HitPos, 1, 0, 15.5, Color(255, 0, 0))

				local Size = math.random(3, 4)
				render.SetMaterial(mat2)

				local tra = util.TraceLine({
					start = tr.HitPos - (tr.HitPos - EyePos()):GetNormalized(),
					endpos = EyePos(),
					filter = {LocalPlayer(), ply, wep, ply:GetNWEntity("Ragdoll"), ply:GetNWEntity("ragdollWeapon")},
					mask = MASK_SHOT
				})

				if not tra.Hit then
					render.DrawSprite(tr.HitPos, Size, Size, Color(255, 0, 0))
				end
			cam.End3D()
		end
	end
end)

local function ToggleMenu(toggle)
	if toggle then
		local w, h = ScrW(), ScrH()

		if IsValid(wepMenu) then wepMenu:Remove() end

		local lply = LocalPlayer()

		local wep = lply:GetActiveWeapon()
		wep = IsValid(wep) and wep or lply:GetNWEntity("ActiveWeapon")
		if not IsValid(wep) then return end

		wepMenu = vgui.Create("DMenu")
		wepMenu:SetPos(w / 3, h / 2)
		wepMenu:MakePopup()
		wepMenu:SetKeyboardInputEnabled(false)

		if wep:GetClass() ~= "weapon_hands" then
			wepMenu:AddOption("#hg.cmenu.drop", function()
				LocalPlayer():ConCommand("say *drop")
			end)
		end

		if laserweps[wep:GetClass()] then
			wepMenu:AddOption("#hg.cmenu.laser", function()
				LocalPlayer():ConCommand("hg_togglelaser")
			end)
		end

		plyMenu = vgui.Create("DMenu")
		plyMenu:SetPos(w / 1.7, h / 2)
		plyMenu:MakePopup()
		plyMenu:SetKeyboardInputEnabled(false)

		local EZarmor = LocalPlayer().EZarmor

		if JMod.GetItemInSlot(EZarmor, "eyes") then
			plyMenu:AddOption("#hg.cmenu.head", function()
				LocalPlayer():ConCommand("jmod_ez_toggleeyes")
			end)
		end
	else
		if IsValid(wepMenu) then wepMenu:Remove() end
		if IsValid(plyMenu) then plyMenu:Remove() end
	end
end

local active, oldValue

hook.Add("Think", "hgContextMenu", function()
	active = input.IsKeyDown(KEY_C)

	if oldValue ~= active then
		oldValue = active

		if active then
			ToggleMenu(true)
		else
			ToggleMenu(false)
		end
	end
end)

net.Receive("lasertgg", function(len)
	local ply = net.ReadEntity()
	local boolen = net.ReadBool()

	if boolen then laserplayers[ply:EntIndex()] = ply
	else laserplayers[ply:EntIndex()] = nil end

	ply.Laser = boolen
end)

hook.Add("OnEntityCreated", "homigradcom-colorragdolls", function(ent)
	if ent:IsRagdoll() then
	end
end)

net.Receive("GGrad_RagdollColor", function()
	local rag = net.ReadEntity()
	local col = net.ReadVector()
	if IsValid(rag) then
		rag.playerColor = col
	end
end)

hook.Add("HUDShouldDraw", "HideHUD_ammo", function(name)
	if name == "CHudAmmo" then return false end
end)

net.Receive("remove_jmod_effects", function(len)
	LocalPlayer().EZvisionBlur = 0
	LocalPlayer().EZflashbanged = 0
end)

local meta = FindMetaTable("Player")

function meta:HasGodMode()
	return self:GetNWBool("HasGodMode")
end

concommand.Add("hg_togglelaser", function()
	local ply = LocalPlayer()
	local wep = ply:GetActiveWeapon()

	if IsValid(wep) and laserweps[wep:GetClass()] then
		ply.Laser = not ply.Laser

		net.Start("lasertgg")
			net.WriteBool(ply.Laser)
		net.SendToServer()

		ply:EmitSound("items/nvg_off.wav")
	end
end)

concommand.Add("hg_getentity", function()
	local ent = LocalPlayer():GetEyeTrace().Entity
	if not IsValid(ent) then return end

	print(ent)
	print(ent:GetModel())
	print(ent:GetClass())
end)

hook.Add("DrawDeathNotice", "no", function() return false end)

function GM:MouthMoveAnimation(ply)
	local ent = IsValid(ply:GetNWEntity("Ragdoll")) and ply:GetNWEntity("Ragdoll") or ply

	local flexes = {
		ent:GetFlexIDByName("jaw_drop"),
		ent:GetFlexIDByName("left_part"),
		ent:GetFlexIDByName("right_part"),
		ent:GetFlexIDByName("left_mouth_drop"),
		ent:GetFlexIDByName("right_mouth_drop")
	}

	local weight = ply:IsSpeaking() and math.Clamp(ply:VoiceVolume() * 6, 0, 6) or 0

	for _, v in ipairs(flexes) do
		ent:SetFlexWeight(v, weight * 4)
	end
end