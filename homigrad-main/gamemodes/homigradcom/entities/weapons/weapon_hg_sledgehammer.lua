-- "gamemodes\\homigradcom\\entities\\weapons\\weapon_hg_sledgehammer.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
SWEP.Base = "weapon_hg_melee_base"

if CLIENT then
	SWEP.PrintName = language.GetPhrase("hg.sledgehammer.name")
	SWEP.Instructions = language.GetPhrase("hg.sledgehammer.inst")
	SWEP.Category = language.GetPhrase("hg.category.melee")
end

SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false

SWEP.ViewModelFOV = 60
SWEP.ViewModel = "models/weapons/me_sledge/w_me_sledge.mdl"
SWEP.WorldModel = "models/weapons/me_sledge/w_me_sledge.mdl"
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

SWEP.Primary.Damage = 55
SWEP.Primary.Ammo = "none"
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Recoil = 0.5
SWEP.Primary.Delay = 1.4
SWEP.Primary.Force = 150

SWEP.Secondary.ClipSize = 0
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.DrawSound = "weapons/melee/holster_in_light.wav"
SWEP.HitSound = "physics/metal/metal_sheet_impact_hard2.wav"
SWEP.FlashHitSound = "weapons/melee/flesh_impact_blunt_04.wav"
SWEP.ShouldDecal = false
SWEP.HoldTypeWep = "melee2"
SWEP.DamageType = DMG_CLUB