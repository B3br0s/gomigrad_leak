-- "gamemodes\\homigradcom\\entities\\entities\\ent_jack_gmod_ezgrenade.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
-- Jackarunda 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda, TheOnly8Z"
ENT.Category = "JMod - EZ Explosives"
ENT.PrintName = "EZ Grenade Base"
ENT.NoSitAllowed = true
ENT.Spawnable = false
ENT.Model = "models/weapons/w_grenade.mdl"
ENT.Material = nil
ENT.ModelScale = nil
ENT.HardThrowStr = 500
ENT.SoftThrowStr = 250
ENT.Mass = 10
ENT.ImpactSound = {"weapons/m67/m67_bounce_01.wav", "weapons/m67/m67_bounce_02.wav"}
ENT.SpoonEnt = "ent_jack_spoon"
ENT.SpoonModel = nil
ENT.SpoonScale = nil
ENT.SpoonSound = nil
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
ENT.JModEZstorable = true

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "State")
end

if SERVER then
    function ENT:SpawnFunction(ply, tr)
        local SpawnPos = tr.HitPos + tr.HitNormal * 20
        local ent = ents.Create(self.ClassName)
        ent:SetAngles(Angle(0, 0, 0))
        ent:SetPos(SpawnPos)
        JMod.SetOwner(ent, ply)
        ent:Spawn()
        ent:Activate()
        return ent
    end

    function ENT:Initialize()
        self:SetModel(self.Model)
        if self.Material then self:SetMaterial(self.Material) end
        if self.ModelScale then self:SetModelScale(self.ModelScale, 0) end
        if self.Color then self:SetColor(self.Color) end

        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetUseType(ONOFF_USE)

        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:SetMass(self.Mass)
            phys:Wake()
        end

        self:SetState(JMod.EZ_STATE_OFF)
        self.NextDet = 0

        if istable(WireLib) then
            self.Inputs = WireLib.CreateInputs(self, {"Detonate", "Arm"}, {"This will directly detonate the bomb", "Arms bomb when > 0"})
            self.Outputs = WireLib.CreateOutputs(self, {"State"}, {"1 is armed\n0 is not\n-1 is broken"})
        end
    end

    function ENT:TriggerInput(iname, value)
        if iname == "Detonate" and value ~= 0 then
            self:Detonate()
        elseif iname == "Arm" and value > 0 then
            self:SetState(JMod.EZ_STATE_ARMED)
        end
    end

    function ENT:PhysicsCollide(data, physobj)
        if data.DeltaTime > 0.2 and data.Speed > 30 then
            self:EmitSound(table.Random(self.ImpactSound))
        end
    end

    function ENT:OnTakeDamage(dmginfo)
        if self.Exploded or dmginfo:GetInflictor() == self then return end
        self:TakePhysicsDamage(dmginfo)
        local dmg = dmginfo:GetDamage()

        if dmg >= 4 then
            local detChance = 0
            if dmginfo:IsDamageType(DMG_BLAST) then
                detChance = dmg / 150
            end

            if math.Rand(0, 1) < detChance then
                self:Detonate()
            elseif math.random(1, 10) == 3 and self:GetState() ~= JMod.EZ_STATE_BROKEN then
                self:SetState(JMod.EZ_STATE_BROKEN)
                self:EmitSound("Metal_Box.Break")
                SafeRemoveEntityDelayed(self, 10)
            end
        end
    end

    function ENT:Use(activator, activatorAgain, onOff)
        if self.Exploded then return end
        local user = activator or activatorAgain
        JMod.SetOwner(self, user)
        JMod.Hint(user, self.ClassName)
        if tobool(onOff) then
            local state = self:GetState()
            if state < 0 then return end

            if state == JMod.EZ_STATE_OFF and user:KeyDown(JMod.Config.AltFunctionKey) then
                self:Prime()
                JMod.Hint(user, "grenade")
            else
                JMod.ThrowablePickup(user, self, self.HardThrowStr, self.SoftThrowStr)
            end
        end
    end

    function ENT:SpoonEffect()
        if not self.SpoonEnt then return end
        local spoon = ents.Create(self.SpoonEnt)
        if self.SpoonModel then spoon:SetModel(self.SpoonModel) end
        if self.SpoonScale then spoon:SetModelScale(self.SpoonScale) end
        if self.SpoonSound then spoon.Sound = self.SpoonSound end

        spoon:SetPos(self:GetPos())
        spoon:Spawn()
        spoon:GetPhysicsObject():SetVelocity(self:GetPhysicsObject():GetVelocity() + VectorRand() * 250)
        self:EmitSound("snd_jack_spoonfling.wav", 60, math.random(90, 110))
    end

    function ENT:Think()
        if istable(WireLib) then
            WireLib.TriggerOutput(self, "State", self:GetState())
        end

        local state = self:GetState()
        if self.Exploded then return end

        if state == JMod.EZ_STATE_PRIMED and not self:IsPlayerHolding() then
            self:Arm()
        end

        if state == JMod.EZ_STATE_ARMED then
            JMod.EmitAIsound(self:GetPos(), 500, 0.5, 8)
            self:NextThink(CurTime() + 0.5)
            return true
        end
    end

    function ENT:Prime()
        self:SetState(JMod.EZ_STATE_PRIMED)
        self:EmitSound("weapons/pinpull.wav", 60, 100)
        self:SetBodygroup(1, 1)
    end

    function ENT:Arm()
        self:SetBodygroup(2, 1)
        self:SetState(JMod.EZ_STATE_ARMED)
        self:SpoonEffect()
    end

    function ENT:Detonate()
        if self.Exploded then return end
        self.Exploded = true
        self:Remove()
    end
end
