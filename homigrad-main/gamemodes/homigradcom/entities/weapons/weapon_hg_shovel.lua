-- "gamemodes\\homigradcom\\entities\\weapons\\weapon_hg_shovel.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
SWEP.Base = "weapon_hg_melee_base"

if CLIENT then
	SWEP.PrintName = language.GetPhrase("hg.shovel.name")
	SWEP.Instructions = language.GetPhrase("hg.shovel.inst")
	SWEP.Category = language.GetPhrase("hg.category.melee")
end

SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false

SWEP.ViewModelFOV = 60
SWEP.ViewModel = "models/weapons/me_spade/w_me_spade.mdl"
SWEP.WorldModel = "models/weapons/me_spade/w_me_spade.mdl"
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

SWEP.Primary.Damage = 25
SWEP.Primary.Ammo = "none"
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Recoil = 0.5
SWEP.Primary.Delay = 1.1
SWEP.Primary.Force = 180

SWEP.Secondary.ClipSize = 0
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.DrawSound = "weapons/melee/holster_in_light.wav"
SWEP.HitSound = "physics/metal/metal_sheet_impact_hard7.wav"
SWEP.FlashHitSound = "snd_jack_hmcd_axehit.wav"
SWEP.ShouldDecal = true
SWEP.HoldTypeWep = "melee2"
SWEP.DamageType = DMG_SLASH