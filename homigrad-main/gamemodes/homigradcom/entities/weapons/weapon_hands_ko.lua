-- "gamemodes\\homigradcom\\entities\\weapons\\weapon_hands_ko.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
--[[
if SERVER then
	AddCSLuaFile()
	SWEP.Weight = 5000
	SWEP.AutoSwitchTo = false
	SWEP.AutoSwitchFrom = false
else
	SWEP.PrintName = language.GetPhrase("hg.handsko.name")
	SWEP.Instructions = language.GetPhrase("hg.handsko.inst")
	SWEP.Slot = 0
	SWEP.SlotPos = 1
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
	SWEP.AdminOnly = true
	SWEP.ViewModelFOV = 45
	SWEP.BounceWeaponIcon = false
	SWEP.WepSelectIcon = surface.GetTextureID("vgui/wep_jack_hmcd_hands")

	local HandTex, ClosedTex = surface.GetTextureID("vgui/hud/gmod_hand"), surface.GetTextureID("vgui/hud/gmod_closedhand")

	function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)
		-- Set us up the texture
		surface.SetDrawColor(255, 255, 255, alpha)
		surface.SetTexture(self.WepSelectIcon)

		-- Lets get a sin wave to make it bounce
		local fsin = 0

		-- Borders
		y = y + 10
		x = x + 10
		wide = wide - 20

		-- Draw that mother
		surface.DrawTexturedRect(x + fsin, y - fsin, wide - fsin * 2, wide / 2 + fsin)

		-- Draw weapon info box
		self:PrintWeaponInfo(x + wide + 20, y + tall * 0.95, alpha)
	end

	function SWEP:DrawHUD()
		local eye = LocalPlayer():GetAttachment(LocalPlayer():LookupAttachment("eyes"))
		if not eye then return end

		if GetViewEntity() ~= LocalPlayer() then return end
		if LocalPlayer():InVehicle() then return end

		local ply = self:GetOwner()

		local t = {}
		t.start = eye.Pos
		t.start[3] = t.start[3] - 2
		t.endpos = t.start + ply:GetAngles():Forward() * 60
		t.filter = self:GetOwner()
		local Tr = util.TraceLine(t)

		if not self:GetFists() then
			-- local Tr = util.QuickTrace(ply:GetAttachment(ply:LookupAttachment("eyes")).Pos, self:GetOwner():GetAimVector() * self.ReachDistance, {self:GetOwner()})

			if Tr.Hit then
				if self:CanPickup(Tr.Entity) then
					local Size = math.max(1 - Tr.Fraction, 0.25)

					if self:GetOwner():KeyDown(IN_ATTACK2) then
						surface.SetTexture(ClosedTex)
					else
						surface.SetTexture(HandTex)
					end

					surface.SetDrawColor(Color(255, 255, 255, 255 * Size))
					surface.DrawTexturedRect(Tr.HitPos:ToScreen().x - 30, Tr.HitPos:ToScreen().y - 30, 128 * Size, 128 * Size)

					local col

					if Tr.Entity:IsPlayer() then
						col = Tr.Entity:GetPlayerColor():ToColor()
					elseif Tr.Entity.GetPlayerColor ~= nil then
						col = Tr.Entity.playerColor:ToColor()
					else
						col = Color(255, 255, 255, 255)
					end

					col.a = 255 * Size * 2

					draw.DrawText(Tr.Entity:IsPlayer() and Tr.Entity:Name() or Tr.Entity:GetNWString("Nickname") or "", "HomigradFontLarge", Tr.HitPos:ToScreen().x, Tr.HitPos:ToScreen().y - 30, col, TEXT_ALIGN_CENTER)
				else
					local Size = math.max(1 - Tr.Fraction, 0.25)

					surface.SetDrawColor(Color(200, 200, 200, 200))
					draw.NoTexture()

					Circle(Tr.HitPos:ToScreen().x, Tr.HitPos:ToScreen().y, 55 * Size, 32)
					surface.SetDrawColor(Color(255, 255, 255, 255 * Size / 0.5))
					draw.NoTexture()

					local col

					if Tr.Entity:IsPlayer() then
						col = Tr.Entity:GetPlayerColor():ToColor()
					elseif Tr.Entity.GetPlayerColor ~= nil then
						col = Tr.Entity.playerColor:ToColor()
					else
						col = Color(255, 255, 255, 255)
					end

					col.a = 255 * Size * 2

					Circle(Tr.HitPos:ToScreen().x, Tr.HitPos:ToScreen().y, 40 * Size, 32)
					draw.DrawText(Tr.Entity:IsPlayer() and Tr.Entity:Name() or Tr.Entity:GetNWString("Nickname") or "", "HomigradFontLarge", Tr.HitPos:ToScreen().x, Tr.HitPos:ToScreen().y + 30, col, TEXT_ALIGN_CENTER)
				end
			end
		else
			-- local Tr = util.QuickTrace(ply:GetAttachment(ply:LookupAttachment("eyes")).Pos, self:GetOwner():GetAimVector() * self.ReachDistance, {self:GetOwner()})

			if Tr.Hit then
				local Size = math.max(1 - Tr.Fraction, 0.25)

				surface.SetDrawColor(Color(200, 200, 200, 200))
				draw.NoTexture()

				Circle(Tr.HitPos:ToScreen().x, Tr.HitPos:ToScreen().y, 55 * Size, 32)
				surface.SetDrawColor(Color(255, 255, 255, 255 * Size / 0.5))
				draw.NoTexture()

				local col

				if Tr.Entity:IsPlayer() then
					col = Tr.Entity:GetPlayerColor():ToColor()
				elseif Tr.Entity.GetPlayerColor ~= nil then
					col = Tr.Entity.playerColor:ToColor()
				else
					col = Color(255, 255, 255, 255)
				end

				col.a = 255 * Size * 2

				Circle(Tr.HitPos:ToScreen().x, Tr.HitPos:ToScreen().y, 40 * Size, 32)
				draw.DrawText(Tr.Entity:IsPlayer() and Tr.Entity:Name() or Tr.Entity:GetNWString("Nickname") or "", "HomigradFontLarge", Tr.HitPos:ToScreen().x, Tr.HitPos:ToScreen().y + 30, col, TEXT_ALIGN_CENTER)
			end
		end
	end
end

function JMod.WhomILookinAt(ply, cone, dist)
	local CreatureTr, ObjTr, OtherTr = nil, nil, nil

	for _ = 1, 150 * cone do
		local Vec = (ply:GetAimVector() + VectorRand() * cone):GetNormalized()
		local Tr = util.QuickTrace(ply:GetAttachment(ply:LookupAttachment("eyes")).Pos, Vec * dist, {ply})

		if Tr.Hit and not Tr.HitSky and Tr.Entity then
			local Ent, Class = Tr.Entity, Tr.Entity:GetClass()
			if Ent:IsPlayer() or Ent:IsNPC() then
				CreatureTr = Tr
			elseif Class == "prop_physics" or Class == "prop_physics_multiplayer" or Class == "prop_ragdoll" then
				ObjTr = Tr
			else
				OtherTr = Tr
			end
		end
	end

	if CreatureTr then return CreatureTr.Entity, CreatureTr.HitPos, CreatureTr.HitNormal end
	if ObjTr then return ObjTr.Entity, ObjTr.HitPos, ObjTr.HitNormal end
	if OtherTr then return OtherTr.Entity, OtherTr.HitPos, OtherTr.HitNormal end

	return nil, nil, nil
end

SWEP.SwayScale = 3
SWEP.BobScale = 3
SWEP.InstantPickup = true -- FF compat
SWEP.Author = ""
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.HoldType = "normal"
SWEP.ViewModel = "models/weapons/c_arms_citizen.mdl"
SWEP.WorldModel = "models/props_junk/cardboard_box004a.mdl"
SWEP.UseHands = true
SWEP.AttackSlowDown = .05
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.ReachDistance = 100
SWEP.HomicideSWEP = true

function SWEP:SetupDataTables()
	self:NetworkVar("Float", 0, "NextIdle")
	self:NetworkVar("Bool", 2, "Fists")
	self:NetworkVar("Float", 1, "NextDown")
	self:NetworkVar("Bool", 3, "Blocking")
	self:NetworkVar("Bool", 4, "IsCarrying")
end

function SWEP:PreDrawViewModel(vm, wep, ply)
	vm:SetMaterial("engine/occlusionproxy") -- Hide that view model with hacky material
end

function SWEP:Initialize()
	self:SetNextIdle(CurTime() + 5)
	self:SetNextDown(CurTime() + 5)
	self:SetHoldType(self.HoldType)
	self:SetFists(false)
	self:SetBlocking(false)
end

function SWEP:Deploy()
	if not IsFirstTimePredicted() then
		self:DoBFSAnimation("fists_draw")
		self:GetOwner():GetViewModel():SetPlaybackRate(.1)

		return
	end

	self:SetNextPrimaryFire(CurTime() + .5)
	self:SetFists(false)
	self:SetNextDown(CurTime())
	self:DoBFSAnimation("fists_draw")

	return true
end

function SWEP:Holster()
	self:OnRemove()

	return true
end

function SWEP:CanPrimaryAttack()
	return true
end

local pickupWhiteList = {
	["prop_ragdoll"] = true,
	["prop_physics"] = true,
	["prop_physics_multiplayer"] = true
}

function SWEP:CanPickup(ent)
	if ent:IsNPC() then return false end
	if ent:IsPlayer() then return false end
	if ent:IsWorld() then return false end

	local class = ent:GetClass()

	if pickupWhiteList[class] then return true end
	if CLIENT then return true end
	if IsValid(ent:GetPhysicsObject()) then return true end

	return false
end

function SWEP:SecondaryAttack()
	if not IsFirstTimePredicted() then return end
	if self:GetFists() then return end

	if SERVER then
		self:SetCarrying()
		local ply = self:GetOwner()
		local tr = util.QuickTrace(ply:GetAttachment(ply:LookupAttachment("eyes")).Pos - vector_up * 2, self:GetOwner():GetAimVector() * self.ReachDistance, {self:GetOwner()})

		if IsValid(tr.Entity) and self:CanPickup(tr.Entity) and not tr.Entity:IsPlayer() then
			local Dist = (self:GetOwner():GetShootPos() - tr.HitPos):Length()

			if Dist < self.ReachDistance then
				sound.Play("Flesh.ImpactSoft", self:GetOwner():GetShootPos(), 65, math.random(90, 110))
				self:SetCarrying(tr.Entity, tr.PhysicsBone, tr.HitPos, Dist)
				CheckForPoison(ply, tr.Entity)
				tr.Entity.Touched = true
				self:ApplyForce()
			end
		elseif IsValid(tr.Entity) and tr.Entity:IsPlayer() then
			local Dist = (self:GetOwner():GetShootPos() - tr.HitPos):Length()

			if Dist < self.ReachDistance then
				sound.Play("Flesh.ImpactSoft", self:GetOwner():GetShootPos(), 65, math.random(90, 110))
				self:GetOwner():SetVelocity(self:GetOwner():GetAimVector() * 20)
				tr.Entity:SetVelocity(-self:GetOwner():GetAimVector() * 50)
				self:SetNextSecondaryFire(CurTime() + .25)
			end
		end
	end
end

function SWEP:FreezeMovement()
	if self:GetOwner():KeyDown(IN_USE) and self:GetOwner():KeyDown(IN_ATTACK2) and self:GetNWBool("Pickup") then return true end

	return false
end

function SWEP:ApplyForce()
	local target = self:GetOwner():GetAimVector() * self.CarryDist + self:GetOwner():GetShootPos()
	local phys = self.CarryEnt:GetPhysicsObjectNum(self.CarryBone)

	if IsValid(phys) then
		local TargetPos = phys:GetPos()

		if self.CarryPos then TargetPos = self.CarryEnt:LocalToWorld(self.CarryPos) end

		local vec = target - TargetPos
		local len, mul = vec:Length(), self.CarryEnt:GetPhysicsObject():GetMass()

		if len > self.ReachDistance then
			self:SetCarrying()

			return
		end

		if self.CarryEnt:GetClass() == "prop_ragdoll" then
			mul = mul * 300

			local ply = RagdollOwner(self.CarryEnt)

			if self:GetOwner():KeyPressed(IN_RELOAD) then
				if not ply then
					self:GetOwner():ChatPrint("There is no pulse. This person is dead.")
				else
					if ply.heartstop then
						self:GetOwner():ChatPrint("There is no pulse, but CPR can be performed to attempt to save them.")
					else
						local uncon = ply.unconscious and " They are unconscious." or ""
						self:GetOwner():ChatPrint((ply.nextPulse < 0.9 and "This person is in great condition." or ply.nextPulse <= 1.5 and "This person seems to be a little roughed up." or ply.nextPulse < 2 and "This person seems to be in a bad physical state." or ply.nextPulse >= 2 and "This person is barely holding onto their life.") .. uncon)
					end
				end
			end
		end

		vec:Normalize()

		if SERVER then
			local ply = RagdollOwner(self.CarryEnt)

			if self:GetOwner():KeyDown(IN_ATTACK) then
				if ply then
					if self.firstTimePrint then self:GetOwner():ChatPrint("You start to perform CPR (Hold Left Mouse down to keep the target alive)") end

					self.firstTimePrint = false

					if (self.CPRThink or 0) < CurTime() then
						self.CPRThink = CurTime() + 60 / 120

						ply.CPR = math.max(ply.CPR + 50, 0)
						ply.o2 = math.min(ply.o2 + 0.5, 1)
						ply.Blood = math.min(ply.Blood + 8, 5000) -- Stupid shit
						ply.pain = math.max(ply.pain - 3, 0)

						self.CarryEnt:EmitSound("physics/body/body_medium_impact_soft" .. tostring(math.random(7)) .. ".wav")
					end
				else
					if not ply and self.CarryEnt:GetClass() == "prop_ragdoll" then
						if self.firstTimePrint then self:GetOwner():ChatPrint("This person can't be saved. CPR is pointless.") end

						self.firstTimePrint = false
					end
				end
			else
				self.firstTimePrint = true
			end
		end

		local avec, velo = vec * len, phys:GetVelocity() - self:GetOwner():GetVelocity()
		local Force = (avec - velo / 2) * (self.CarryBone > 3 and mul / 10 or mul)
		local ForceMagnitude = Force:Length()

		if ForceMagnitude > 6000 * 1 then
			self:SetCarrying()

			return
		end

		if self.CarryPos then
			phys:ApplyForceOffset(Force, self.CarryEnt:LocalToWorld(self.CarryPos))
		else
			phys:ApplyForceCenter(Force)
		end

		if self:GetOwner():KeyDown(IN_USE) then
			SetAng = SetAng or self:GetOwner():EyeAngles()

			local commands = self:GetOwner():GetCurrentCommand()
			local x, y = commands:GetMouseX(), commands:GetMouseY()

			if self.CarryEnt:IsRagdoll() then
				rotate = Vector(x, y, 0) / 6
			else
				rotate = Vector(x, y, 0) / 4
			end

			phys:AddAngleVelocity(rotate)
		end

		phys:ApplyForceCenter(Vector(0, 0, mul))
		phys:AddAngleVelocity(-phys:GetAngleVelocity() / 10)
	end
end

function SWEP:OnRemove()
	if IsValid(self:GetOwner()) and CLIENT and self:GetOwner():IsPlayer() then
		local vm = self:GetOwner():GetViewModel()

		if IsValid(vm) then vm:SetMaterial("") end
	end
end

function SWEP:GetCarrying()
	return self.CarryEnt
end

-- hook.Add("ShouldCollide", "hjuyhhy", function(ent1, ent2)
-- 	if not ent1:IsPlayer() then return end
-- 	if not ent2:IsRagdoll() then return end

-- 	local wep = ent1:GetActiveWeapon()

-- 	if wep:GetClass() == "weapon_hands" then
-- 		print(wep.CarryEnt, ent2)
-- 		if wep.CarryEnt == ent2 then return false end
-- 	end
-- end)

function SWEP:SetCarrying(ent, bone, pos, dist)
	if IsValid(ent) then
		self:SetNWBool("Pickup", true)

		self.CarryEnt = ent
		self.CarryBone = bone
		self.CarryDist = dist

		if ent:GetClass() ~= "prop_ragdoll" then
			self.CarryPos = ent:WorldToLocal(pos)
		else
			self.CarryPos = nil
		end
	else
		self:SetNWBool("Pickup", false)

		self.CarryEnt = nil
		self.CarryBone = nil
		self.CarryPos = nil
		self.CarryDist = nil
	end
end

function SWEP:Think()
	if IsValid(self:GetOwner()) and self:GetOwner():KeyDown(IN_ATTACK2) and not self:GetFists() then
		if IsValid(self.CarryEnt) then self:ApplyForce() end
	elseif self.CarryEnt then
		self:SetCarrying()
	end

	if self:GetFists() and self:GetOwner():KeyDown(IN_ATTACK2) then
		self:SetNextPrimaryFire(CurTime() + .5)
		self:SetBlocking(true)
	else
		self:SetBlocking(false)
	end

	local HoldType = "fist"

	if self:GetFists() then
		HoldType = "fist"

		local Time = CurTime()

		if self:GetNextIdle() < Time then
			self:DoBFSAnimation("fists_idle_0" .. math.random(1, 2))
			self:UpdateNextIdle()
		end

		if self:GetBlocking() then
			self:SetNextDown(Time + 1)
			HoldType = "camera"
		end

		if self:GetNextDown() < Time or self:GetOwner():KeyDown(IN_SPEED) then
			self:SetNextDown(Time + 1)
			self:SetFists(false)
			self:SetBlocking(false)
		end
	else
		HoldType = "normal"

		self:DoBFSAnimation("fists_draw")
	end

	if IsValid(self.CarryEnt) or self.CarryEnt then HoldType = "magic" end
	if self:GetOwner():KeyDown(IN_SPEED) then HoldType = "normal" end
	if SERVER then self:SetHoldType(HoldType) end
end

function SWEP:PrimaryAttack()
	local side = "fists_left"

	if math.random(1, 2) == 1 then side = "fists_right" end
	if self:GetOwner():KeyDown(IN_ATTACK2) then return end

	self:SetNextDown(CurTime() + 7)

	if not self:GetFists() then
		self:SetFists(true)
		self:DoBFSAnimation("fists_draw")
		self:SetNextPrimaryFire(CurTime() + .35)

		return
	end

	if self:GetBlocking() then return end
	if self:GetOwner():KeyDown(IN_SPEED) then return end

	if not IsFirstTimePredicted() then
		self:DoBFSAnimation(side)
		self:GetOwner():GetViewModel():SetPlaybackRate(1.25)

		return
	end

	self:GetOwner():ViewPunch(Angle(0, 0, math.random(-2, 2)))
	self:DoBFSAnimation(side)
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	self:GetOwner():GetViewModel():SetPlaybackRate(1.25)
	self:UpdateNextIdle()

	if SERVER then
		sound.Play("weapons/slam/throw.wav", self:GetPos(), 65, math.random(90, 110))

		self:GetOwner():ViewPunch(Angle(0, 0, math.random(-2, 2)))

		timer.Simple(.075, function() if IsValid(self) then self:AttackFront() end end)
	end

	self:SetNextPrimaryFire(CurTime() + 0.01)
	self:SetNextSecondaryFire(CurTime() + 0.02)
end

function SWEP:AttackFront()
	if CLIENT then return end

	self:GetOwner():LagCompensation(true)

	local Ent, HitPos = JMod.WhomILookinAt(self:GetOwner(), .3, 55)
	local AimVec = self:GetOwner():GetAimVector()

	if IsValid(Ent) or Ent and Ent.IsWorld and Ent:IsWorld() then
		local SelfForce, Mul = -150, 1
		if self:IsEntSoft(Ent) then
			SelfForce = 0
			if Ent:IsPlayer() and IsValid(Ent:GetActiveWeapon()) and Ent:GetActiveWeapon().GetBlocking and Ent:GetActiveWeapon():GetBlocking() and not RagdollOwner(Ent) then
				sound.Play("Flesh.ImpactSoft", HitPos, 65, math.random(90, 110))
			else
				sound.Play("Flesh.ImpactHard", HitPos, 65, math.random(90, 110))
			end
		else
			sound.Play("Flesh.ImpactSoft", HitPos, 65, math.random(90, 110))
		end

		local Dam = DamageInfo()
		Dam:SetAttacker(self:GetOwner())
		Dam:SetInflictor(self)
		Dam:SetDamage(math.huge)
		Dam:SetDamageForce(math.huge)
		Dam:SetDamageType(DMG_CLUB)
		Dam:SetDamagePosition(HitPos)
		Ent:TakeDamageInfo(Dam)
		local Phys = Ent:GetPhysicsObject()
		if IsValid(Phys) then
			if Ent:IsPlayer() then
				Ent:SetVelocity(AimVec * SelfForce * 1) -- This would actually be so fucking good if we made a sonic boom and made it mach 10
			end

			Phys:ApplyForceOffset(AimVec * 50000 * Mul, HitPos)
			-- self:GetOwner():SetVelocity(-AimVec * SelfForce * .8)
		end

		if Ent:GetClass() == "func_breakable_surf" and math.random(1, 20) == 10 then
			Ent:Fire("break", "", 0)

			self:GetOwner().Bloodlosing = self:GetOwner():GetNWInt("BloodLosing") + 4
			self:GetOwner():SetNWInt("BloodLosing", self:GetOwner().Bloodlosing)
		end

		if Ent:GetClass() == "func_breakable" and math.random(7, 11) == 10 then
			Ent:Fire("break", "", 0)

			self:GetOwner().Bloodlosing = self:GetOwner():GetNWInt("BloodLosing") + 4
			self:GetOwner():SetNWInt("BloodLosing", self:GetOwner().Bloodlosing)
		end
	end

	self:GetOwner():LagCompensation(false)
end

-- self.CarryDist
-- self.CarryPos
-- self.CarryBone

function SWEP:Reload()
	if not IsFirstTimePredicted() then return end

	self:SetFists(false)
	self:SetBlocking(false)

	local ent = self:GetCarrying()

	if SERVER then
		local target = self:GetOwner():GetAimVector() * (self.CarryDist or 50) + self:GetOwner():GetShootPos()

		heldents = heldents or {}

		for i, tbl in pairs(heldents) do
			if tbl[2] == self:GetOwner() then heldents[i] = nil end
		end

		if IsValid(ent) then
			-- if heldents[ent:EntIndex()] then heldents[ent:EntIndex()] = nil end
			heldents[ent:EntIndex()] = {self.CarryEnt, self:GetOwner(), self.CarryDist, target, self.CarryBone, self.CarryPos}
		end
	end

	-- self:SetCarrying()
end

if SERVER then
	hook.Add("Think", "held-entities", function()
		heldents = heldents or {}

		for i, tbl in pairs(heldents) do
			if not tbl or not IsValid(tbl[1]) then
				heldents[i] = nil
				continue
			end

			local ent, ply, _, target, bone, pos = tbl[1], tbl[2], tbl[3], tbl[4], tbl[5], tbl[6]
			local phys = ent:GetPhysicsObjectNum(bone)

			local TargetPos = phys:GetPos()
			if pos then TargetPos = ent:LocalToWorld(pos) end

			local vec = target - TargetPos
			local len, mul = vec:Length(), ent:GetPhysicsObject():GetMass()

			vec:Normalize()

			local avec, velo = vec * len, phys:GetVelocity() - ply:GetVelocity()
			local Force = (avec - velo / 10) * (bone > 3 and mul / 10 or mul)

			if math.abs((tbl[2]:GetPos() - tbl[1]:GetPos()):Length()) < 80 and tbl[2]:GetGroundEntity() ~= tbl[1] then
				if tbl[6] then
					phys:ApplyForceOffset(Force, ent:LocalToWorld(pos))
				else
					phys:ApplyForceCenter(Force)
				end

				phys:ApplyForceCenter(Vector(0, 0, mul))
				phys:AddAngleVelocity(-phys:GetAngleVelocity() / 10)
			else
				heldents[i] = nil
			end
		end
	end)
end

function SWEP:DrawWorldModel()
end

-- no, do nothing
function SWEP:DoBFSAnimation(anim)
	-- local vm = self:GetOwner():GetViewModel()
	-- vm:SendViewModelMatchingSequence(vm:LookupSequence(anim))
end

function SWEP:UpdateNextIdle()
	local vm = self:GetOwner():GetViewModel()
	self:SetNextIdle(CurTime() + vm:SequenceDuration())
end

function SWEP:IsEntSoft(ent)
	return ent:IsNPC() or ent:IsPlayer() or RagdollOwner(ent) or ent:IsRagdoll()
end

if CLIENT then
	local BlockAmt = 0

	function SWEP:GetViewModelPosition(pos, ang)
		if self:GetBlocking() then
			BlockAmt = math.Clamp(BlockAmt + FrameTime() * 1.5, 0, 1)
		else
			BlockAmt = math.Clamp(BlockAmt - FrameTime() * 1.5, 0, 1)
		end

		pos = pos - ang:Up() * 15 * BlockAmt

		ang:RotateAroundAxis(ang:Right(), BlockAmt * 60)

		return pos, ang
	end
end
--]]