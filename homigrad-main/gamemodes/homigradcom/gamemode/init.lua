AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

util.AddNetworkString("hg_sendchat")
util.AddNetworkString("hg_sendchat_simple")
util.AddNetworkString("hg_sendchat_format")
util.AddNetworkString("lasertgg")
util.AddNetworkString("remove_jmod_effects")

local specColor = Vector(0.25, 0.25, 0.25)

function GM:PlayerSpawn(ply)
	ply:SetNWEntity("HeSpectateOn", false)

	if PLYSPAWN_OVERRIDE then return end

	ply.allowFlashlights = false

	ply:RemoveFlags(FL_ONGROUND)
	ply:SetMaterial("")

	net.Start("remove_jmod_effects")
	net.Broadcast()

	ply.firstTimeNotifiedLeftLeg = true
	ply.firstTimeNotifiedRightLeg = true
	ply.firstTimeNotifiedRestrained = true

	ply.attackees = {}

	ply:SetCanZoom(false)

	ply.Blood = 5000
	ply.pain = 0

	if ply.NEEDKILLNOW then
		if ply.NEEDKILLNOW == 1 then
			ply:KillSilent()
		else
			ply:KillSilent()
		end

		ply.NEEDKILLNOW = nil

		return
	end

	if not ply:Alive() then return end

	ply:UnSpectate()
	ply:SetupHands()

	if ply:GetNWBool("DynamicFlashlight") then
		ply:Flashlight(false)
	end

	ply:SetHealth(150)
	ply:SetMaxHealth(150)
	ply:SetWalkSpeed(200)
	ply:SetRunSpeed(350)
	ply:SetSlowWalkSpeed(75)
	ply:SetLadderClimbSpeed(75)
	ply:SetJumpPower(200)

	ply:SetModel(table.Random(tdm.models))

	local size = 9

	ply.slots = {}

	ply:SetNWVector("HullMin", Vector(-size, -size, 0))
	ply:SetNWVector("Hull", Vector(size, size, DEFAULT_VIEW_OFFSET[3]))
	ply:SetNWVector("HullDuck", Vector(size, size, DEFAULT_VIEW_OFFSET_DUCKED[3]))

	ply:SetHull(ply:GetNWVector("HullMin"), ply:GetNWVector("Hull"))
	ply:SetHullDuck(ply:GetNWVector("HullMin"), ply:GetNWVector("HullDuck"))

	ply:SetViewOffset(DEFAULT_VIEW_OFFSET)
	ply:SetViewOffsetDucked(DEFAULT_VIEW_OFFSET_DUCKED)

	local phys = ply:GetPhysicsObject()

	-- This is for the player in non-ragdoll. Do not change
	if phys:IsValid() then
		phys:SetMass(DEFAULT_MASS)
	end

	ply:SetPlayerClass()

	if ply:Team() == 1002 then
		ply:SetModel("models/player/gman_high.mdl")
		ply:SetPlayerColor(specColor)

		ply:Give("weapon_hands")
		ply:Give("weapon_physgun")
		ply:Give("weapon_toolgun")

		ply:GodEnable()
		ply:SetNoDraw(true)

		return
	end

	ply:PlayerClassEvent("On")

	ply:Give("weapon_hands")

	if ply:IsUserGroup("sponsor") or ply:IsUserGroup("supporterplus") or ply:IsAdmin() then
		if math.random(1, 5) == 5 then ply:Give("weapon_gear_bloxycola") end
		if math.random(1, 5) == 5 then ply:Give("weapon_gear_cheezburger") end

		ply:Give("weapon_vape")
	end

	-- actually terrible code, but we need it for the time being to make sure that players who havent donated aren't reaping the benefits.
	-- We can remove this line of code in late Jan / early feb
	--[[
	if ply:GetUserGroup() == "user" or ply:GetUserGroup() == "regular" or ply:GetUserGroup() == "supporter" or ply:GetUserGroup() == "supporterplus" then
		RunConsoleCommand("hg_usecustommodel", "false")
		RunConsoleCommand("cl_playermodel", "none")
	end --]]

	TableRound().PlayerSpawn2(ply, ply:Team())
end

function GM:PlayerDeath(ply, inf, att)
	if not roundActive then return end

	if att == ply then att = ply.Attacker2 end
	if not IsValid(att) or att == ply or not att:IsPlayer() then return end

	ply.allowGrab = false

	timer.Simple(3, function()
		ply.allowGrab = true
	end)
end

hook.Add("HandlePlayerLanding", "hg_handleplayerlanding", function()
	return true
end)

function GM:PlayerInitialSpawn(ply)
	local func = TableRound().PlayerInitialSpawn

	if func then func(ply)
	else ply:SetTeam(1002) end

	if #player.GetAll() < 2 then EndRound() end

	ply.NEEDKILLNOW = 2
	ply.allowGrab = true

	RoundTimeSync(ply)
	RoundStateSync(ply, RoundData)
	RoundActiveSync(ply)
	RoundActiveNextSync(ply)

	SendSpawnPoint(ply)
end

function GM:PlayerDeathThink(ply)
	local tbl = {}

	for _, ply in ipairs(player.GetAll()) do
		if not ply:Alive() then continue end

		tbl[#tbl + 1] = ply
	end

	local key = ply:KeyDown(IN_RELOAD)

	if key ~= ply.oldKeyWalk and key then
		ply.EnableSpectate = not ply.EnableSpectate
		ply:ChatPrint(ply.EnableSpectate and "#hg.spec.orbit" or "#hg.spec.freecam")
	end

	ply.oldKeyWalk = key
	ply.SpectateGuy = ply.SpectateGuy or 0

	if ply.SpectateGuy > #tbl then
		ply.SpectateGuy = #tbl
	end

	if ply.EnableSpectate then
		ply:Spectate(OBS_MODE_CHASE)

		local key1 = ply:KeyDown(IN_ATTACK)
		local key2 = ply:KeyDown(IN_ATTACK2)

		if ply.oldKeyAttack1 ~= key1 and key1 then
			ply.SpectateGuy = ply.SpectateGuy + 1

			if ply.SpectateGuy > #tbl then
				ply.SpectateGuy = 1
			end
		elseif ply.oldKeyAttack2 ~= key2 and key2 then
			ply.SpectateGuy = ply.SpectateGuy - 1

			if ply.SpectateGuy == 0 then
				ply.SpectateGuy = #tbl
			end
		end

		local spec = tbl[ply.SpectateGuy]

		if not IsValid(spec) then
			ply.SpectateGuy = 1

			return
		end

		ply:SetPos(spec:GetPos() + Vector(0, 0, 40))
		local spec = spec
		ply:SetNWEntity("HeSpectateOn", spec)
		ply:SetMoveType(MOVETYPE_NONE)

		ply.oldKeyAttack1 = key1
		ply.oldKeyAttack2 = key2
	else
		ply:UnSpectate()

		ply:SetMoveType(MOVETYPE_NOCLIP)
		ply:SetNWEntity("HeSpectateOn", false)

		if ply:KeyDown(IN_ATTACK) then
			local tr = {}
			tr.start = ply:GetPos()
			tr.endpos = tr.start + ply:GetAimVector() * 128
			tr.filter = ply
			local traceResult = util.TraceLine(tr)

			local bot = traceResult.Entity
			if not bot:IsNPC() or not bot:IsNextBot() then return end

			hook.Run("Spectate NPC", ply, bot)
		end
	end

	local func = TableRound().PlayerDeathThink

	if func then
		return func(ply)
	else
		if roundActive then
			return false
		else
			return true
		end
	end
end

function GM:PlayerDisconnected(ply) end

function GM:PlayerDeathSound() return true end

local function PlayerCanJoinTeam(ply, teamID)
	local addT, addCT = 0, 0

	if teamID == 1 then addT = 1 end
	if teamID == 2 then addCT = 1 end

	local favorT, count = NeedAutoBalance(addT, addCT)

	if count and ((teamID == 1 and favorT) or (teamID == 2 and not favorT)) then
		ply:ChatPrint("Team is full.")

		return false
	end

	return true
end

function GM:PlayerCanJoinTeam(ply, teamID)
	if teamID == 1002 then ply.NEEDKILLNOW = 1 end
	if ply:Team() == 1002 then ply.NEEDKILLNOW = 2 end
	if teamID == 1002 then return true end

	local result = TableRound().PlayerCanJoinTeam(ply, teamID)
	if result ~= nil then return result end

	local result = PlayerCanJoinTeam(ply, teamID)
	if result ~= nil then return result end
end

COMMANDS.scared = {
	function(ply, args)
		if not args[1] then return end

		local value = (tonumber(args[1]) == 1 and true) or false

		ply:SetNWBool("scared", value)
		ply:ChatPrint("NoclipScary: " .. tostring(value))
	end
}

COMMANDS.nortv = {
	function(ply, args)
		if not ply:IsAdmin() or not args[1] then return end

		local value = (tonumber(args[1]) == 1 and true) or false

		HG_DISABLERTV = value

		PrintMessageChat(3, "nortv: " .. tostring(value))
	end,
	2
}

if not ulx.hvotemap then ulx.hvotemap = ulx.votemap end
if not ulx.hvotemap2 then ulx.hvotemap2 = ulx.votemap2 end

function ulx.votemap(...)
	if HG_DISABLERTV then
		ULib.tsayError(calling_ply, "no", true)
	else
		ulx.hvotemap(...)
	end
end

local votemap = ulx.command(CATEGORY_NAME, "ulx votemap", ulx.votemap, "!votemap")
votemap:addParam{
	type = ULib.cmds.StringArg,
	completes = ulx.votemaps,
	hint = "map",
	ULib.cmds.takeRestOfLine, ULib.cmds.optional
}
votemap:defaultAccess(ULib.ACCESS_ALL)
votemap:help("Vote for a map, no args lists available maps.")

function ulx.votemap2(...)
	if HG_DISABLERTV then
		ULib.tsayError(calling_ply, "no", true)
	else
		ulx.hvotemap2(...)
	end
end

local votemap2 = ulx.command(CATEGORY_NAME, "ulx votemap2", ulx.votemap2, "!votemap2")
votemap2:addParam{
	type = ULib.cmds.StringArg,
	completes = ulx.maps,
	hint = "map",
	error = "invalid map \"%s\" specified",
	ULib.cmds.restrictToCompletes, ULib.cmds.takeRestOfLine, repeat_min = 1,
	repeat_max = 10
}
votemap2:defaultAccess(ULib.ACCESS_ADMIN)
votemap2:help("Starts a public map vote.")

hook.Add("Player Think", "HasGodMode Rep", function(ply)
	ply:SetNWBool("HasGodMode", ply:HasGodMode())
end)

COMMANDS.roll = {
	function(ply, args)
		if not args[1] then args[1] = 20 end

		local r = math.random(1, tonumber(args[1]))

		for _, ply2 in player.Iterator() do
			if GAMEMODE:PlayerCanSeePlayersChat("gg", false, ply2, ply) then
				PrintMessageChat(ply2, r)
			end
		end
	end,
	nil, nil, true
}

COMMANDS.fullup = {
	function(ply, args)
		ply.stamina = 100
		ply.pain = 0
		ply.Blood = 5000
		ply.Bloodlosing = 0
		ply.dmgimpulse = 0
	end
}

function GM:DoPlayerDeath(ply) end

function GM:PlayerStartVoice(ply)
	if ply:Alive() then return true end
end

net.Receive("lasertgg", function(len, ply)
	net.Start("lasertgg")
		net.WriteEntity(ply)
		net.WriteBool(net.ReadBool())
	net.Broadcast()
end)

--[[
function GM:IsSpawnpointSuitable(ply, spawnpointent, bMakeSuitable)
	local Pos = spawnpointent:GetPos()
	local Blockers = 0
	local Ents = ents.FindInBox(Pos + Vector(-64, -64, 0), Pos + Vector(64, 64, 0))
	-- if ply:Team() == TEAM_SPECTATOR or ply:Team() == TEAM_UNASSIGNED then return true end
	if ply:Team() == 1 or ply:Team() == 2 or ply:Team() == 3 then return true end

	for _, v in pairs(Ents) do
		if IsValid(v) and v:IsPlayer() and v:Alive() then
			Blockers = Blockers + 1
		end
	end

	if bMakeSuitable then return true end
	if Blockers > 0 then return false end

	return true
end --]]