-- "gamemodes\\homigradcom\\entities\\weapons\\weapon_hg_fubar.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
SWEP.Base = "weapon_hg_melee_base"

if CLIENT then
	SWEP.PrintName = language.GetPhrase("hg.fubar.name")
	SWEP.Instructions = language.GetPhrase("hg.fubar.inst")
	SWEP.Category = language.GetPhrase("hg.category.melee")
end

SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false

SWEP.ViewModelFOV = 60
SWEP.ViewModel = "models/weapons/me_fubar/w_me_fubar.mdl"
SWEP.WorldModel = "models/weapons/me_fubar/w_me_fubar.mdl"
SWEP.ViewModelFlip = false

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Slot = 1
SWEP.SlotPos = 2

SWEP.UseHands = true

-- SWEP.HoldType = "knife"

SWEP.FiresUnderwater = false

SWEP.DrawCrosshair = false

SWEP.DrawAmmo = true

SWEP.Primary.Damage = 35
SWEP.Primary.Ammo = "none"
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Recoil = 0.5
SWEP.Primary.Delay = 1.1
SWEP.Primary.Force = 100

SWEP.Secondary.ClipSize = 0
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.DrawSound = "weapons/melee/holster_in_light.wav"
SWEP.HitSound = "physics/metal/metal_sheet_impact_hard2.wav"
SWEP.FlashHitSound = "weapons/melee/flesh_impact_blunt_03.wav"
SWEP.ShouldDecal = false
SWEP.HoldTypeWep = "melee2"
SWEP.DamageType = DMG_CLUB