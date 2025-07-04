-- "gamemodes\\homigradcom\\gamemode\\game\\fog_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
--local diffDis = list2[game.GetMap()]
local fogMode = render.FogMode
local fogStart = render.FogStart
local fogEnd = render.FogEnd
local fogMaxDensity = render.FogMaxDensity
local fogColor = render.FogColor

local fogdefault = {165, 165, 165}

file.CreateDir("homigradcom")
--file.Write("homigradcom/fog_maps_color.txt","")

dataFog = util.JSONToTable(file.Read("homigradcom/fog_maps_color.txt") or "") or {}

dataFogMap = dataFog[game.GetMap()] or {
	{156, 156, 156},
	4500
}

dataFog[game.GetMap()] = dataFogMap

concommand.Add("hg_fogsetcolor", function(ply, cmd, args)
	local r, g, b = tonumber(args[1]), tonumber(args[2]), tonumber(args[3])

	dataFogMap[1] = {r, g, b}

	file.Write("homigradcom/fog_maps_color.txt", util.TableToJSON(dataFog))
end)

concommand.Add("hg_fogset", function(ply, cmd, args)
	dataFogMap[2] = tonumber(args[1])

	file.Write("homigradcom/fog_maps_color.txt", util.TableToJSON(dataFog))
end)

hook.Add("SetupWorldFog", "shlib", function()
	local distance = GetGlobalVar("Fog Dis")
	local upper = dataFogMap[2]
	local content = util.PointContents(EyePos())

	if ((bit.band(content, CONTENTS_SOLID) == CONTENTS_SOLID) and (LocalPlayer():GetMoveType() == MOVETYPE_NOCLIP and not LocalPlayer():InVehicle())) or (not distance and upper <= 0) then
		CAMERA_ZFAR = nil

		return
	end

	--adddis = math_sin(CurTime() / 100) * diffDis
	local custom = upper > 0

	if distance and upper > distance then
		custom = false
	end

	CAMERA_ZFAR = custom and math.Clamp(dataFogMap[2],3500,99999999) or distance

	fogMode(MATERIAL_FOG_LINEAR)
	fogStart(CAMERA_ZFAR / 16)
	fogEnd(CAMERA_ZFAR - 25)
	fogMaxDensity(1)

	local color = custom and dataFogMap[1] or GetGlobalVar("Fog Color", fogdefault)
	fogColor(color[1], color[2], color[3], 255)

	return true
end)

local white = Color(255, 255, 255)
local mat = Material("color")
local surface_SetMaterial = surface.SetMaterial
local surface_SetDrawColor = surface.SetDrawColor
local render_SetColorMaterial = render.SetColorMaterial
local render_DrawQuadEasy = render.DrawQuadEasy

hook.Add("PostDrawOpaqueRenderables", "shlib", function()
	if not CAMERA_ZFAR then return end

	local vec = Vector(CAMERA_ZFAR, 0, 0)
	local lply = LocalPlayer()

	vec:Rotate(EyeAngles())

	lply = EyePos()

	vec = lply + vec

	local normal = Vector(1, 0, 0)
	normal:Rotate((lply - vec):Angle())

	surface_SetDrawColor(155, 155, 155, 255)
	surface_SetMaterial(mat)
	render_SetColorMaterial()
	render_DrawQuadEasy(vec, normal, 100000, 100000, white)
end)

concommand.Add("hg_fog", function(ply)
	print(GetGlobalVar("Fog Dis"))
	print(GetGlobalVar("Fog Color"))
end)