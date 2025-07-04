-- "gamemodes\\homigradcom\\entities\\weapons\\weapon_zs_zombie\\cl_init.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
include("shared.lua")

SWEP.ViewModelFOV = 70
SWEP.DrawCrosshair = false

function SWEP:Reload()
end

function SWEP:DrawWorldModel()
end

SWEP.DrawWorldModelTranslucent = SWEP.DrawWorldModel

function SWEP:DrawHUD()
	if GetConVar("crosshair"):GetInt() ~= 1 then return end

	self:DrawCrosshairDot()
end

function SWEP:DrawWeaponSelection(x, y, w, h, alpha)
	self:BaseDrawWeaponSelection(x, y, w, h, alpha)
end