-- "gamemodes\\homigradcom\\gamemode\\game\\level_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
LevelList = {}

function TableRound(name)
	return _G[(name or roundActiveName) or "homicide"]
end

timer.Simple(0, function()
	-- and not (string.find(string.lower(game.GetMap()), "rp_desert_conflict")) then
	if roundActiveName == nil then
		if GetConVar("hg_ConstructOnly"):GetBool() == true then
			roundActiveName = "construct"
			roundActiveNameNext = "construct"
		else
			roundActiveName = "homicide"
			roundActiveNameNext = "homicide"
		end
	end
end)

gameevent.Listen( "player_disconnect" )
hook.Add( "player_disconnect", "player_disconnect_example", function( data )
	local name = data.name
	local steamid = data.networkid
	local id = data.userid
	local bot = data.bot
	local reason = data.reason
	return false
end )

if SERVER then 
else
end