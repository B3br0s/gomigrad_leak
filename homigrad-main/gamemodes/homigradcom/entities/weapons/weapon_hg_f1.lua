-- "gamemodes\\homigradcom\\entities\\weapons\\weapon_hg_f1.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
SWEP.Base = "weapon_hg_grenade_base"

if CLIENT then
	SWEP.PrintName = language.GetPhrase("hg.f1.name")
	SWEP.Author = "homigradcom"
	SWEP.Instructions = language.GetPhrase("hg.f1.inst")
	SWEP.Category = language.GetPhrase("hg.category.grenades")
end

SWEP.Slot = 4
SWEP.SlotPos = 2
SWEP.Spawnable = true

SWEP.ViewModel = "models/pwb/weapons/w_f1.mdl"
SWEP.WorldModel = "models/pwb/weapons/w_f1.mdl"

SWEP.Grenade = "ent_hgjack_f1nade"