-- "gamemodes\\homigradcom\\entities\\weapons\\weapon_hg_rgd5.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
SWEP.Base = "weapon_hg_grenade_base"
if CLIENT then
	SWEP.PrintName = language.GetPhrase("hg.rgd5.name")
	SWEP.Author = "homigradcom"
	SWEP.Instructions = language.GetPhrase("hg.rgd5.inst")
	SWEP.Category = language.GetPhrase("hg.category.grenades")
	SWEP.Slot = 4
	SWEP.SlotPos = 2
end

SWEP.Spawnable = true
SWEP.ViewModel = "models/pwb/weapons/w_rgd5.mdl"
SWEP.WorldModel = "models/pwb/weapons/w_rgd5.mdl"
SWEP.Grenade = "ent_hgjack_rgd5nade"