-- "gamemodes\\homigradcom\\entities\\weapons\\weapon_suicidevest.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
SWEP.Base = "weapon_base"

if CLIENT then
	SWEP.PrintName = language.GetPhrase("hg.suicidevest.name")
	SWEP.Author = "Secret Society"
	SWEP.Instructions = language.GetPhrase("hg.suicidevest.inst")
	SWEP.Category = language.GetPhrase("hg.category.traitors")
end

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Slot = 4
SWEP.SlotPos = 2
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = false

SWEP.ViewModel = "models/props_junk/cardboard_jox004a.mdl"
SWEP.WorldModel = "models/props_junk/cardboard_jox004a.mdl"

SWEP.DrawWeaponSelection = DrawWeaponSelection
SWEP.OverridePaintIcon = OverridePaintIcon

SWEP.dwsPos = Vector(20, 20, 15)
SWEP.dwsItemPos = Vector(0, 0, 5)

if SERVER then
	function SWEP:Initialize()
		self:SetHoldType("normal")
	end

	function SWEP:PrimaryAttack()
		if self.kaboom then return end

		local owner = self:GetOwner()

		owner:EmitSound("snd_jack_hmcd_jihad1.wav", 75)

		self.kaboom = true

		timer.Simple(math.Rand(0.5, 1), function()
			if not IsValid(owner) then return end

			local SelfPos, PowerMult = owner:GetPos(), 6

			ParticleEffect("pcf_jack_groundsplode_large", SelfPos, vector_up:Angle())

			util.ScreenShake(SelfPos, 99999, 99999, 1, 3000)

			sound.Play("BaseExplosionEffect.Sound", SelfPos, 120, math.random(90, 110))

			for _ = 1, 4 do
				sound.Play("explosions/doi_ty_01_close.wav", SelfPos, 140, math.random(80, 110))
			end

			timer.Simple(.1, function()
				for _ = 1, 5 do
					local Tr = util.QuickTrace(SelfPos, VectorRand() * 20)
					if Tr.Hit then util.Decal("Scorch", Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal) end
				end
			end)

			JMod.WreckBuildings(ent, SelfPos, PowerMult)
			JMod.BlastDoors(ent, SelfPos, PowerMult)
			JMod.FragSplosion(self:GetOwner(), SelfPos + Vector(0, 0, 70), 3000, 80, 5000, self:GetOwner() or game.GetWorld())

			timer.Simple(0, function()
				local ZaWarudo = game.GetWorld()
				local Infl, Att = (IsValid(ent) and ent) or ZaWarudo, (IsValid(ent) and IsValid(ent.Owner) and ent.Owner) or (IsValid(ent) and ent) or ZaWarudo

				util.BlastDamage(Infl, Att, SelfPos, 120 * PowerMult, 120 * PowerMult)
				util.BlastDamage(Infl, Att, SelfPos, 20 * PowerMult, 1000 * PowerMult)
			end)
		end)
	end
else
	function SWEP:PrimaryAttack()
	end

	function SWEP:DrawWorldModel()
		local owner = self:GetOwner()
		if not IsValid(owner) then return self:DrawModel() end

		local mdl = self.worldModel
		if not IsValid(mdl) then
			mdl = ClientsideModel("models/props_junk/cardboard_jox004a.mdl")
			mdl:SetNoDraw(true)
			mdl:SetModelScale(0.5)
			self.worldModel = mdl
		end

		self:CallOnRemove("hg_removevest", function() mdl:Remove() end)

		local matrix = self:GetOwner():GetBoneMatrix(11)
		if not matrix then return end

		mdl:SetRenderOrigin(matrix:GetTranslation() + matrix:GetAngles():Forward() * 3 + matrix:GetAngles():Right() * 3)
		mdl:SetRenderAngles(matrix:GetAngles())
		mdl:DrawModel()
	end
end