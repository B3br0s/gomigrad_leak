-- "gamemodes\\homigradcom\\entities\\weapons\\weapon_glock.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
SWEP.Base = "salat_base"

if CLIENT then
	SWEP.PrintName = language.GetPhrase("hg.glock.name")
	SWEP.Author = "homigradcom"
	SWEP.Instructions = language.GetPhrase("hg.glock.inst")
	SWEP.Category = language.GetPhrase("hg.category.weapons")
end

SWEP.WepSelectIcon = "pwb/sprites/glock17"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = 17
SWEP.Primary.DefaultClip = 17
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "9x19 mm Parabellum"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 25
SWEP.Primary.Spread = 0
SWEP.Primary.Sound = "weapons/tfa_ins2/sandstorm_glock/fp.wav"
SWEP.Primary.SoundFar = "snd_jack_hmcd_smp_far.wav"
SWEP.Primary.Force = 90 / 3
SWEP.ReloadTime = 2
SWEP.ShootWait = 0.12

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.HoldType = "revolver"

SWEP.Slot = 2
SWEP.SlotPos = 1
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = false

SWEP.ViewModel = "models/pwb/weapons/w_glock17.mdl"
SWEP.WorldModel = "models/pwb/weapons/w_glock17.mdl"

SWEP.dwsPos = Vector(13, 13, 5)
SWEP.dwsItemPos = Vector(10, -1, -2)

SWEP.addAng = Angle(0, 0, 0)
SWEP.addPos = Vector(0, 0, -1)
-- SWEP.vbwPos = Vector(7, -10, -6)

SWEP.SightPos = Vector(-23, 0.1, -1.02)