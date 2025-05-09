-- "gamemodes\\homigradcom\\entities\\weapons\\food_spongebob_home.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
GGrad_DelayFoodBase = GGrad_DelayFoodBase or 1
if SERVER then
	util.AddNetworkString("GGrad_SendAttackAnimation")
	function AnimFoodOnClientPlease(ply)
		net.Start("GGrad_SendAttackAnimation")
		net.Send(ply)
	end
else
	net.Receive("GGrad_SendAttackAnimation", function()
		LocalPlayer():SetAnimation(PLAYER_ATTACK1)
	end)
end

SWEP.Base = "weapon_base"

AddCSLuaFile()

if CLIENT then
	SWEP.PrintName = language.GetPhrase("hg.pineapple.name")
	SWEP.Author = "homigradcom"
	SWEP.Purpose = language.GetPhrase("hg.pineapple.inst")
	SWEP.Category = language.GetPhrase("hg.category.food")
end

SWEP.Slot = 3
SWEP.SlotPos = 3
SWEP.Spawnable = true

SWEP.ViewModel = "models/jordfood/can.mdl"
SWEP.WorldModel = "models/jordfood/can.mdl"
SWEP.ViewModelFOV = 54
SWEP.UseHands = true
SWEP.FoodMuch = 5

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.DrawCrosshair = false

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

function SWEP:PrimaryAttack()
	if SERVER then
		local ply = self:GetOwner()
		if self.FoodMuch > 0 then
			if self.DelayFood < CurTime() then
				self.DelayFood = CurTime() + GGrad_DelayFoodBase
				self.FoodMuch = self.FoodMuch - 1
				self:GetOwner():SetAnimation(PLAYER_ATTACK1)
				AnimFoodOnClientPlease(self:GetOwner())
		
				self:GetOwner().hungryregen = self:GetOwner().hungryregen + 1

				sound.Play("snd_jack_hmcd_eat" .. math.random(1, 4) .. ".wav", self:GetPos(), 75, 100, 0.5)
			end
		end
		if self.FoodMuch <= 0 then
			ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_R_Forearm"), Angle(0,0,0), true)
			ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_R_Upperarm"), Angle(0,0,0), true)
			ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_R_Hand"), Angle(0,0,0), true)
			gelephant(self:GetOwner(), self.WorldModel)
			self:Remove()
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