-- "gamemodes\\homigradcom\\entities\\weapons\\food_fishcan.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
SWEP.Base = "weapon_base"

AddCSLuaFile()

if CLIENT then
	SWEP.PrintName = language.GetPhrase("hg.fish.name")
	SWEP.Author = "homigradcom"
	SWEP.Purpose = language.GetPhrase("hg.fish.inst")
	SWEP.Category = language.GetPhrase("hg.category.food")
end

SWEP.Slot = 3
SWEP.SlotPos = 3
SWEP.Spawnable = true

SWEP.ViewModel = "models/jordfood/atun.mdl"
SWEP.WorldModel = "models/jordfood/atun.mdl"
SWEP.ViewModelFOV = 54
SWEP.UseHands = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.DrawCrosshair = false

function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)
	if not IsValid(DrawModel) then
		DrawModel = ClientsideModel(self.WorldModel, RENDER_GROUP_OPAQUE_ENTITY)
		DrawModel:SetNoDraw(true)
	else
		DrawModel:SetModel(self.WorldModel)

		local vec = Vector(55, 55, 55)
		local ang = Vector(-48, -48, -48):Angle()

		cam.Start3D(vec, ang, 20, x, y + 35, wide, tall, 5, 4096)
			cam.IgnoreZ(true)
			render.SuppressEngineLighting(true)
			render.SetLightingOrigin(self:GetPos())
			render.ResetModelLighting(50 / 255, 50 / 255, 50 / 255)
			render.SetColorModulation(1, 1, 1)
			render.SetBlend(255)
			render.SetModelLighting(4, 1, 1, 1)

			DrawModel:SetRenderAngles(Angle(0, RealTime() * 30 % 360, 0))
			DrawModel:DrawModel()
			DrawModel:SetRenderAngles()

			render.SetColorModulation(1, 1, 1)
			render.SetBlend(1)
			render.SuppressEngineLighting(false)
			cam.IgnoreZ(false)
		cam.End3D()
	end

	self:PrintWeaponInfo(x + wide + 20, y + tall * 0.95, alpha)
end

function SWEP:Initialize()
	self:SetHoldType("slam")

	if CLIENT then return end
end

if CLIENT then
	function SWEP:PreDrawViewModel(vm, wep, ply)
	end

	function SWEP:GetViewModelPosition(pos, ang)
		pos = pos - ang:Up() * 10 + ang:Forward() * 30 + ang:Right() * 7

		ang:RotateAroundAxis(ang:Up(), 90)
		ang:RotateAroundAxis(ang:Right(), -10)
		ang:RotateAroundAxis(ang:Forward(), -10)

		return pos, ang
	end

	if CLIENT then
		local WorldModel = ClientsideModel(SWEP.WorldModel)

		WorldModel:SetNoDraw(true)

		function SWEP:DrawWorldModel()
			local owner = self:GetOwner()

			if IsValid(owner) then
				local offsetVec = Vector(4, -1, 0)
				local offsetAng = Angle(180, -45, 90)

				local boneid = owner:LookupBone("ValveBiped.Bip01_R_Hand")
				if not boneid then return end

				local matrix = owner:GetBoneMatrix(boneid)
				if not matrix then return end

				local newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())

				WorldModel:SetPos(newPos)
				WorldModel:SetAngles(newAng)
				WorldModel:SetupBones()
			else
				WorldModel:SetPos(self:GetPos())
				WorldModel:SetAngles(self:GetAngles())
			end

			WorldModel:DrawModel()
		end
	end
end

SWEP.DelayFood = 0
SWEP.FoodMuch = 8

function SWEP:PrimaryAttack()
	if SERVER then
		local ply = self:GetOwner()
		if self.FoodMuch > 0 then
			if self.DelayFood < CurTime() then
				self.DelayFood = CurTime() + GGrad_DelayFoodBase
				self.FoodMuch = self.FoodMuch - 1
				self:GetOwner():SetAnimation(PLAYER_ATTACK1)
				AnimFoodOnClientPlease(self:GetOwner())
				self:GetOwner().hungryregen = self:GetOwner().hungryregen + 2

				sound.Play("snd_jack_hmcd_eat" .. math.random(1, 4) .. ".wav", self:GetPos(), 75, 100, 0.5)
			end
		end
		if self.FoodMuch <= 0 then
			ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_R_Forearm"), Angle(0,0,0), true)
			ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_R_Upperarm"), Angle(0,0,0), true)
			ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_R_Hand"), Angle(0,0,0), true)
			self:Remove()
			gelephant(self:GetOwner(), self.WorldModel)
			self:GetOwner():SelectWeapon("weapon_hands")
		end
	end
end

SWEP.LerpingForearm = 0

function SWEP:Think()
	local ply = self:GetOwner()
	if self.FoodMuch <= 0 then
		ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_R_Forearm"), Angle(0,0,0), true)
		ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_R_Upperarm"), Angle(0,0,0), true)
		ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_R_Hand"), Angle(0,0,0), true)
	end
	self.LerpingForearm = Lerp(0.45, self.LerpingForearm or 0, (ply:KeyDown(IN_ATTACK) and 60 or 0))
	ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_R_Forearm"), Angle(0,0,0), false)
	ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_R_Upperarm"), Angle(0,-self.LerpingForearm,(self.LerpingForearm/3)), false)
	if ply:KeyDown(IN_ATTACK) then
		ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_R_Hand"), Angle(0,math.sin(CurTime()*15)*30,0), false)
	else
		ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_R_Hand"), Angle(0,0,0), false)
	end
end

function SWEP:OnRemove()
	local ply = self:GetOwner()
	if IsValid(ply) and ply:LookupBone("ValveBiped.Bip01_R_Forearm") then
		ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_R_Forearm"), Angle(0,0,0), false)
		ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_R_Upperarm"), Angle(0,0,0), false)
		ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_R_Hand"), Angle(0,0,0), false)
	end
	return true
end

function SWEP:Deploy()
	local ply = self:GetOwner()
	if IsValid(ply) and ply:LookupBone("ValveBiped.Bip01_R_Forearm") then
		ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_R_Forearm"), Angle(0,0,0), false)
		ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_R_Upperarm"), Angle(0,0,0), false)
		ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_R_Hand"), Angle(0,0,0), false)
	end
	return true
end

function SWEP:Holster()
	local ply = self:GetOwner()
	if IsValid(ply) and ply:LookupBone("ValveBiped.Bip01_R_Forearm") then
		ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_R_Forearm"), Angle(0,0,0), false)
		ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_R_Upperarm"), Angle(0,0,0), false)
		ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_R_Hand"), Angle(0,0,0), false)
	end
	return true
end

function SWEP:SecondaryAttack()
end