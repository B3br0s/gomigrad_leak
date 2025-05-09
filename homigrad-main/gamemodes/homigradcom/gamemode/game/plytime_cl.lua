-- "gamemodes\\homigradcom\\gamemode\\game\\plytime_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
net.Receive("Time Ply", function()
	local ply, time = net.ReadEntity(), tonumber(net.ReadString())

	ply.Time = time
	ply.TimeStart = CurTime()
end)