-- "gamemodes\\homigradcom\\gamemode\\game\\tier_0_playerclass\\classes\\combine_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local CLASS = player.RegClass("combine")
CLASS.main_weapons = {"weapon_sar2", "weapon_spas12", "weapon_mp7"}
function CLASS.Off(self)
	if CLIENT then return end
	self.isCombine = nil
	self.cantUsePepper = nil
end

function CLASS.On(self)
	if CLIENT then return end
	self:SetWalkSpeed(250)
	self:SetRunSpeed(350)
	self:SetHealth(150)
	self:SetMaxHealth(150)
	self:Give("weapon_hands")
	self.isCombine = true
	self.cantUsePepper = true
	self:EmitSound("radio/go.wav")
end

function CLASS.PlayerFootstep(self, pos, foot, name, volume, filter)
	if SERVER then return true end
	sound.Play(Sound("npc/combine_soldier/gear" .. math.random(1, 6) .. ".wav"), pos, 75, 100, 1)
	sound.Play(name, pos, 75, 100, volume)
	return true
end

local function getList(self)
	local list = {}
	for _, ply in RandomPairs(player.GetAll()) do
		if ply == self or not ply.isCombine then continue end
		local pos = ply:EyePos()
		local deathPos = self:GetPos()
		if pos:Distance(deathPos) > 1000 then continue end
		local trace = {
			start = pos
		}
		trace.endpos = deathPos
		trace.filter = ply
		if util.TraceLine(trace).HitPos:Distance(deathPos) <= 512 then
			list[#list + 1] = ply
		end
	end

	return list
end

function CLASS.PlayerDeath(self)
	sound.Play(Sound("npc/overwatch/radiovoice/die" .. math.random(1, 3) .. ".wav"), self:GetPos())
	for _, ply in RandomPairs(getList(self)) do
		ply:EmitSound(Sound("npc/combine_soldier/vo/ripcordripcord.wav"))
		break
	end

	self:SetPlayerClass()
end

function CLASS.Think(self)
end

function CLASS.PlayerStartVoice(self)
	for _, ply in player.Iterator() do
		if not ply.isCombine then continue end

		ply:EmitSound("npc/combine_soldier/vo/on" .. math.random(1, 3) .. ".wav")
	end
end

function CLASS.PlayerEndVoice(self)
	for _, ply in player.Iterator() do
		if not ply.isCombine then continue end

		ply:EmitSound("npc/combine_soldier/vo/off" .. math.random(1, 3) .. ".wav")
	end
end

function CLASS.CanLisenOutput(output, input, isChat)
	if not output:Alive() then return false end
end

function CLASS.CanLisenInput(input, output, isChat)
	if not output:Alive() then return false end
end

function CLASS.HomigradDamage(self, hitGroup, dmgInfo, rag)
	if (self.delaysoundpain or 0) > CurTime() then
		self.delaysoundpain = CurTime() + math.Rand(0.25, 0.5)

		self:EmitSound("npc/combine_soldier/pain" .. math.random(1, 3) .. ".wav")
	end
end