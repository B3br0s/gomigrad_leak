-- "gamemodes\\homigradcom\\entities\\weapons\\weapon_hg_hl2.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
SWEP.Base = "weapon_hg_grenade_base"
if CLIENT then
	SWEP.PrintName = language.GetPhrase("hg.hl2nade.name")
	SWEP.Author = "homigradcom"
	SWEP.Instructions = language.GetPhrase("hg.hl2nade.inst")
	SWEP.Category = language.GetPhrase("hg.category.grenades")
	SWEP.Slot = 4
	SWEP.SlotPos = 2
end

SWEP.Spawnable = true
SWEP.ViewModel = "models/weapons/w_grenade.mdl"
SWEP.WorldModel = "models/weapons/w_grenade.mdl"
SWEP.Grenade = "ent_hgjack_hl2nade"