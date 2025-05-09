-- "gamemodes\\homigradcom\\gamemode\\game\\levels\\tier_0_tdm\\init_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local playsound = false

DMZoneRadius = 5000
DMZoneOrigin = Vector(0,0,0)
GGrad_ZoneSoundStation = GGrad_ZoneSoundStation or nil

net.Receive("GGrad_ZoneRadius",function()
	DMZoneRadius = net.ReadInt(17)
	if DMZoneRadius >= 34999 then
		sound.PlayFile( "sound/ambient/energy/force_field_loop1.wav", "noblock", function( station, errCode, errStr )
			if ( IsValid( station ) ) then
				GGrad_ZoneSoundStation = station
				
				station:Play()
				station:EnableLooping( true )
				station:SetVolume(0)
			end
		end )
	end
end)

net.Receive("GGrad_ZoneOrigin", function()
	DMZoneOrigin = net.ReadVector()
end)

concommand.Add("getzoneinformation", function(ply)
	print(DMZoneRadius, DMZoneOrigin)
end)

function tdm.StartRoundCL()
	playsound = true
end

function tdm.HUDPaint_RoundLeft(white)
	local ply = LocalPlayer()
	local name, color = tdm.GetTeamName(ply)
	local startRound = roundTimeStart + 5 - CurTime()

	if startRound > 0 and ply:Alive() then
		if playsound then
			playsound = false

			ply:ScreenFade(SCREENFADE.IN, Color(0, 0, 0, 220), 0.5, 4)
		end

		draw.DrawText(language.GetPhrase("hg.modes.yourteam"):format(language.GetPhrase(name)), "HomigradRoundFont", ScrW() / 2, ScrH() / 2, Color(color.r, color.g, color.b, math.Clamp(startRound, 0, 1) * 255), TEXT_ALIGN_CENTER)
		draw.DrawText(language.GetPhrase("hg.tdm.name"), "HomigradRoundFont", ScrW() / 2, ScrH() / 8, Color(color.r, color.g, color.b, math.Clamp(startRound, 0, 1) * 255), TEXT_ALIGN_CENTER)
		draw.DrawText(language.GetPhrase("hg.tdm.desc"), "HomigradRoundFont", ScrW() / 2, ScrH() / 1.2, Color(55, 55, 55, math.Clamp(startRound, 0, 1) * 255), TEXT_ALIGN_CENTER)

		return
	end
end
local sphereMat = CreateMaterial("SpermaSphere", "UnlitGeneric", {
	["$basetexture"] = "models/debug/debugwhite",
	["$nocull"] = "1",                            
	["$translucent"] = "1",                       
	["$vertexalpha"] = "1",
	["$vertexcolor"] = "1"
})

local colorround = {
	["tdm"] = Color(145, 30, 30),
	["hl2dm"] = Color(216,38,38),
	["dm"] = Color(149,13,13),
}

hook.Add("PostDrawOpaqueRenderables", "Regodoll", function()
	if roundActiveName == "tdm" or roundActiveName == "hl2dm" or roundActiveName == "dm" then
		if DMZoneRadius and DMZoneOrigin then
			local doxswat = colorround[roundActiveName]
			doxswat.a = 100+math.sin( ( CurTime() * 5 ) )*40
			cam.Start3D()
				render.SetMaterial(sphereMat)
				render.DrawSphere(DMZoneOrigin, DMZoneRadius, 30, 30, doxswat)
			cam.End3D()
		end
	end
end)

local nextBeepTime = 0

hook.Add("Think", "SPHERARKNAMDSGKJSDNKG", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
	if roundActiveName == "tdm" or roundActiveName == "hl2dm" or roundActiveName == "dm" then
		local station = GGrad_ZoneSoundStation
		if not IsValid(station) then return end
		local radius = DMZoneRadius
		local volume = math.Clamp((LocalPlayer():GetPos():Distance(DMZoneOrigin) - radius) + 200,0,200) / 200
		station:SetVolume(volume)
		-- спасибо заранее кто писал дм код зсити я просто реально не знаю как еще сделать звук зоны, спасибо зсиске))
	end
end)