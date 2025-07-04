-- "gamemodes\\homigradcom\\entities\\weapons\\splint\\shared.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
AddCSLuaFile()
SWEP.Base = "medkit"
if CLIENT then
	SWEP.PrintName = language.GetPhrase("hg.splint.name")
	SWEP.Author = "homigradcom"
	SWEP.Instructions = language.GetPhrase("hg.splint.inst")
	SWEP.Category = language.GetPhrase("hg.category.medicine")
	SWEP.Slot = 3
	SWEP.SlotPos = 3
end

SWEP.Spawnable = true
SWEP.ViewModel = "models/alusplint.mdl"
SWEP.WorldModel = "models/alusplint.mdl"
SWEP.vbwPos = Vector(0, -1, -7)
SWEP.vbwAng = Angle(-90, 90, 180)
SWEP.vbwModelScale = 0.8
SWEP.dwsPos = Vector(15, 15, 15)
SWEP.dwmModeScale = 1
SWEP.dwmForward = 3
SWEP.dwmRight = 0.3
SWEP.dwmUp = 0
SWEP.dwmAUp = 0
SWEP.dwmARight = 180
SWEP.dwmAForward = 90
function SWEP:vbwFunc(ply)
	local ent = ply:GetWeapon("medkit")
	if ent and ent.vbwActive then return self.vbwPos, self.vbwAng end
	return self.vbwPos2, self.vbwAng2
end