-- "gamemodes\\homigradcom\\entities\\weapons\\weapon_hg_molotov.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
SWEP.Base = "weapon_hg_grenade_base"
if CLIENT then
	SWEP.PrintName = language.GetPhrase("hg.molotov.name")
	SWEP.Author = "homigradcom"
	SWEP.Instructions = language.GetPhrase("hg.molotov.inst")
	SWEP.Category = language.GetPhrase("hg.category.grenades")
	SWEP.Slot = 4
	SWEP.SlotPos = 2
end

SWEP.Spawnable = true
SWEP.ViewModel = "models/w_models/weapons/w_eq_molotov.mdl"
SWEP.WorldModel = "models/w_models/weapons/w_eq_molotov.mdl"
SWEP.Grenade = "ent_hgjack_molotov"
local angBack = Angle(0, 0, 180)
function SWEP:DrawWorldModel()
	local owner = self:GetOwner()
	if not IsValid(owner) then return self:DrawModel() end
	self.mdl = self.mdl or false
	if not IsValid(self.mdl) then
		self.mdl = ClientsideModel(self.WorldModel)
		self.mdl:SetNoDraw(true)
		self.mdl:SetModelScale(1)
	end

	self:CallOnRemove("hg_removemolotov", function() self.mdl:Remove() end)
	local matrix = self:GetOwner():GetBoneMatrix(self:GetOwner():LookupBone("ValveBiped.Bip01_R_Hand"))
	if not matrix then return end
	self.mdl:SetRenderOrigin(matrix:GetTranslation() + matrix:GetAngles():Forward() * 3 + matrix:GetAngles():Right() * 3)
	self.mdl:SetRenderAngles(matrix:GetAngles() + angBack)
	self.mdl:DrawModel()
end