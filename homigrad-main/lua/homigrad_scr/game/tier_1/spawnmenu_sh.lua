-- "lua\\homigrad_scr\\game\\tier_1\\spawnmenu_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local validUserGroup = {
	superadmin = true,
	admin = true,
	operator = true,
	doperator = true,
	dadmin = true,
	dsuperadmin = true,
    intern = true,
}

if SERVER then
	COMMANDS.accessspawn = {
		function(ply, args)
			-- SetGlobalBool("AccessSpawn", tonumber(args[1]) > 0)
			PrintMessage(3, "Spawn Menu Boolean: " .. tostring(GetGlobalBool("AccessSpawn")))
		end
	}

	local function CanUseSpawnMenu(ply, class)
		local func = TableRound().CanUseSpawnMenu
		func = func and func(ply, class)
		if func ~= nil then return func end

		if validUserGroup[ply:GetUserGroup()] and ply:Team() ~= TEAM_SPECTATOR or GetGlobalBool("AccessSpawn") or GetConVar("hg_ConstructOnly"):GetBool() then return true end

		if not validUserGroup[ply:GetUserGroup()] then
			ply:Kick("You do not have access to these tools.")
			return false
		end
	end

	hook.Add("PlayerSpawnVehicle", "Cantspawnbullshit", function(ply) return CanUseSpawnMenu(ply, "vehicle") end)
	hook.Add("PlayerSpawnRagdoll", "Cantspawnbullshit", function(ply) return CanUseSpawnMenu(ply, "ragdoll") end)
	hook.Add("PlayerSpawnEffect", "Cantspawnbullshit", function(ply) return CanUseSpawnMenu(ply, "effect") end)
	hook.Add("PlayerSpawnProp", "Cantspawnbullshit", function(ply) return CanUseSpawnMenu(ply, "prop") end)
	hook.Add("PlayerSpawnSENT", "Cantspawnbullshit", function(ply) return CanUseSpawnMenu(ply, "sent") end)
	hook.Add("PlayerSpawnNPC", "Cantspawnbullshit", function(ply) return CanUseSpawnMenu(ply, "npc") end)
	hook.Add("PlayerSpawnSWEP", "SpawnBlockSWEP", function(ply) return CanUseSpawnMenu(ply, "swep") end)
	hook.Add("PlayerGiveSWEP", "SpawnBlockSWEP", function(ply) return CanUseSpawnMenu(ply, "swep") end)

	local function spawn(ply, class, ent)
		local func = TableRound().CanUseSpawnMenu
		func = func and func(ply, class, ent)
	end

	hook.Add("PlayerSpawnedVehicle", "sv_round", function(ply, model, ent) spawn(ply, "vehicle", ent) end)
	hook.Add("PlayerSpawnedRagdoll", "sv_round", function(ply, model, ent) spawn(ply, "ragdoll", ent) end)
	hook.Add("PlayerSpawnedEffect", "sv_round", function(ply, model, ent) spawn(ply, "effect", ent) end)
	hook.Add("PlayerSpawnedProp", "sv_round", function(ply, model, ent) spawn(ply, "prop", ent) end)
	hook.Add("PlayerSpawnedSENT", "sv_round", function(ply, model, ent) spawn(ply, "sent", ent) end)
	hook.Add("PlayerSpawnedNPC", "sv_round", function(ply, model, ent) spawn(ply, "npc", ent) end)
else
	-- local admin_menu = CreateClientConVar("hg_admin_menu", "1", true, false, "enable admin menu", 0, 1)

	local function CanUseSpawnMenu()
		local ply = LocalPlayer()


		local func = TableRound().CanUseSpawnMenu
		func = func and func(LocalPlayer())
		if func ~= nil then return func end

		-- if not ply:IsAdmin() then return false end
		-- if not admin_menu:GetBool() then return false end
	end

	hook.Add("ContextMenuOpen", "hide_spawnmenu", CanUseSpawnMenu)
	hook.Add("SpawnMenuOpen", "hide_spawnmenu", CanUseSpawnMenu)
end