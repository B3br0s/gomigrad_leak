-- "gamemodes\\homigradcom\\entities\\weapons\\weapon_m4super.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
SWEP.Base = "salat_base"

if CLIENT then
	SWEP.PrintName = language.GetPhrase("hg.m4super.name")
	SWEP.Author = "homigradcom"
	SWEP.Instructions = language.GetPhrase("hg.m4super.inst")
	SWEP.Category = language.GetPhrase("hg.category.weapons")
end

SWEP.WepSelectIcon = "pwb2/vgui/weapons/m4super90"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = 8
SWEP.Primary.DefaultClip = 8
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "12/70 gauge"
SWEP.Primary.Cone = 0.02
SWEP.Primary.Damage = 35
SWEP.Primary.Spread = 0
SWEP.Primary.Sound = "rifle_win1892/win1892_fire_01.wav"
SWEP.Primary.SoundFar = "toz_shotgun/toz_dist.wav"
SWEP.Primary.Force = 15
SWEP.ReloadTime = 2
SWEP.ShootWait = 0.4
SWEP.NumBullet = 8
SWEP.Sight = true
SWEP.TwoHands = true
SWEP.shotgun = true

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.HoldType = "ar2"

SWEP.Slot = 2
SWEP.SlotPos = 0
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = false

SWEP.ViewModel = "models/pwb2/weapons/w_m4super90.mdl"
SWEP.WorldModel = "models/pwb2/weapons/w_m4super90.mdl"

SWEP.vbwPos = Vector(-2, -3.7, 2)
SWEP.vbwAng = Angle(5, -30, 0)

SWEP.SightPos = Vector(-34, 1.5, -0.37)

function SWEP:ApplyEyeSpray()
	self.eyeSpray = self.eyeSpray - Angle(5, math.Rand(-2, 2), 0)
end