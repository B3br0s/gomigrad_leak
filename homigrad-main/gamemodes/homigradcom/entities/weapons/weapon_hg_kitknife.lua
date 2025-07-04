-- "gamemodes\\homigradcom\\entities\\weapons\\weapon_hg_kitknife.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
SWEP.Base = "weapon_hg_melee_base"

if CLIENT then
	SWEP.PrintName = language.GetPhrase("hg.kitknife.name")
	SWEP.Instructions = language.GetPhrase("hg.kitknife.inst")
	SWEP.Category = language.GetPhrase("hg.category.melee")
end

SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false

SWEP.ViewModelFOV = 60
SWEP.ViewModel = "models/weapons/me_kitknife/w_me_kitknife.mdl"
SWEP.WorldModel = "models/weapons/me_kitknife/w_me_kitknife.mdl"
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

SWEP.Primary.Damage = 5
SWEP.Primary.Ammo = "none"
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Recoil = 0.5
SWEP.Primary.Delay = 0.7
SWEP.Primary.Force = 60

SWEP.Secondary.ClipSize = 0
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.DrawSound = "snd_jack_hmcd_knifedraw.wav"
SWEP.HitSound = "snd_jack_hmcd_knifehit.wav"
SWEP.FlashHitSound = "snd_jack_hmcd_slash.wav"
SWEP.ShouldDecal = true
SWEP.HoldTypeWep = "knife"
SWEP.DamageType = DMG_SLASH