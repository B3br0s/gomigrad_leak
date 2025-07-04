-- "gamemodes\\homigradcom\\entities\\weapons\\weapon_p90.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
SWEP.Base = "salat_base"

if CLIENT then
	SWEP.PrintName = language.GetPhrase("hg.p90.name")
	SWEP.Author = "homigradcom"
	SWEP.Instructions = language.GetPhrase("hg.p90.inst")
	SWEP.Category = language.GetPhrase("hg.category.weapons")
end

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = 50
SWEP.Primary.DefaultClip = 50
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "5.7x28 mm"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 30
SWEP.Primary.Spread = 5
SWEP.Primary.Sound = "mp5k/mp5k_fp.wav"
SWEP.Primary.SoundFar = "mp5k/mp5k_dist.wav"
SWEP.Primary.Force = 120 / 3
SWEP.ReloadTime = 2
SWEP.ShootWait = 0.05
SWEP.TwoHands = true

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.HoldType = "smg"

SWEP.Slot = 2
SWEP.SlotPos = 0
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = false

SWEP.ViewModel = "models/pwb/weapons/w_p90.mdl"
SWEP.WorldModel = "models/pwb/weapons/w_p90.mdl"

SWEP.dwsPos = Vector(20, 20, 5)
SWEP.dwsItemPos = Vector(10, -1, -3)

SWEP.vbwPos = Vector(21, -1, -6)
SWEP.vbwAng = Angle(10, 10, 0)

SWEP.SightPos = Vector(-20, 3.3, -0.35)