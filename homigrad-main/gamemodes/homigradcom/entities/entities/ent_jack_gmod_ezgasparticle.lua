-- "gamemodes\\homigradcom\\entities\\entities\\ent_jack_gmod_ezgasparticle.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal﻿-- Jackarunda 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.PrintName = "EZ Poison Gas"
ENT.Author = "Jackarunda"
ENT.NoSitAllowed = true
ENT.Editable = false
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.EZgasParticle = true

if SERVER then
	function ENT:Initialize()
		local Time = CurTime()
		self.LifeTime = math.random(50, 100) * JMod.Config.PoisonGasLingerTime
		self.DieTime = Time + self.LifeTime
		self:SetModel("models/dav0r/hoverball.mdl")
		self:SetMaterial("models/debug/debugwhite")
		self:RebuildPhysics()
		self:DrawShadow(false)
		self.NextDmg = Time + 5
	end

	function ENT:ShouldDamage(ent)
		if not IsValid(ent) then return end
		if ent:IsPlayer() then return ent:Alive() end
		if ent:IsRagdoll() and RagdollOwner(ent) then return RagdollOwner(ent):Alive() end

		if ent:IsNPC() and ent.Health and ent:Health() then
			local Phys = ent:GetPhysicsObject()

			if IsValid(Phys) then
				local Mat = Phys:GetMaterial()

				if Mat then
					if Mat == "metal" then return false end
					if Mat == "default" then return false end
				end
			end

			return ent:Health() > 0
		end

		return false
	end

	function ENT:CanSee(ent)
		local Tr = util.TraceLine({
			start = self:GetPos(),
			endpos = ent:GetPos(),
			filter = {self, ent},
			mask = MASK_SHOT
		})

		return not Tr.Hit
	end

	function ENT:Think()
		if CLIENT then return end
		local Time, SelfPos = CurTime(), self:GetPos()

		if self.DieTime < Time then
			self:Remove()

			return
		end

		local Force = VectorRand() * 10

		for key, obj in pairs(ents.FindInSphere(SelfPos, 300)) do
			if not (obj == self) and self:CanSee(obj) then
				if obj.EZgasParticle then
					local Vec = (obj:GetPos() - SelfPos):GetNormalized()
					Force = Force - Vec * 40
				elseif self:ShouldDamage(obj) and (math.random(1, 3) == 1) and (self.NextDmg < Time) then
					local Dmg, Helf = DamageInfo(), obj:Health()
					Dmg:SetDamageType(DMG_NERVEGAS)
					Dmg:SetDamage(math.random(1, 4) * JMod.Config.PoisonGasDamage)
					Dmg:SetInflictor(self)
					Dmg:SetAttacker(self:GetOwner() or self)
					Dmg:SetDamagePosition(obj:GetPos())
					obj:TakeDamageInfo(Dmg)

					if obj:IsPlayer() then
						JMod.TryCough(obj)
						obj.pain = obj.pain+25
					end
					if obj:IsRagdoll() and RagdollOwner(obj) then
						if !RagdollOwner(obj).unconscious then
							JMod.TryCough(RagdollOwner(obj))
						end
						RagdollOwner(obj).pain = RagdollOwner(obj).pain+15
					end
				end
			end
		end

		self:Extinguish()
		local Phys = self:GetPhysicsObject()
		Phys:SetVelocity(Phys:GetVelocity() * .8)
		Phys:ApplyForceCenter(Force)
		self:NextThink(Time + math.Rand(2, 4))

		return true
	end

	function ENT:RebuildPhysics()
		local size = 1
		self:PhysicsInitSphere(size, "gmod_silent")
		self:SetCollisionBounds(Vector(-.1, -.1, -.1), Vector(.1, .1, .1))
		self:PhysWake()
		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		local Phys = self:GetPhysicsObject()
		Phys:SetMass(1)
		Phys:EnableGravity(false)
		Phys:SetMaterial("gmod_silent")
	end

	function ENT:PhysicsCollide(data, physobj)
		self:GetPhysicsObject():ApplyForceCenter(-data.HitNormal * 100)
	end

	function ENT:OnTakeDamage(dmginfo)
	end

	--self:TakePhysicsDamage( dmginfo )
	function ENT:Use(activator, caller)
	end

	--
	function ENT:GravGunPickupAllowed(ply)
		return false
	end
elseif CLIENT then
	local Mat = Material("particle/smokestack")

	function ENT:Initialize()
		self.Col = Color(math.random(100, 120), math.random(100, 150), 100)
		self.Visible = true
		self.Show = true
		self.siz = 1

		timer.Simple(2, function()
			if IsValid(self) then
				self.Visible = math.random(1, 5) == 2
			end
		end)

		self.NextVisCheck = CurTime() + 6
		self.DebugShow = LocalPlayer().EZshowGasParticles

		if self.DebugShow then
			self:SetModelScale(2)
		end
	end

	function ENT:DrawTranslucent()
		if self.DebugShow then
			self:DrawModel()
		end

		if (self:GetDTBool(0)) then return end

		local Time = CurTime()

		if self.NextVisCheck < Time then
			self.NextVisCheck = Time + 1
			self.Show = self.Visible and 1 / FrameTime() > 50
		end

		if self.Show then
			local SelfPos = self:GetPos()
			render.SetMaterial(Mat)
			render.DrawSprite(SelfPos, self.siz, self.siz, Color(self.Col.r, self.Col.g, self.Col.b, 30))
			self.siz = math.Clamp(self.siz + FrameTime() * 200, 0, 500)
		end
	end
end
