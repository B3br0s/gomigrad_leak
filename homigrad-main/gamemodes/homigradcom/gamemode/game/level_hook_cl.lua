-- "gamemodes\\homigradcom\\gamemode\\game\\level_hook_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
hook.Add("Player Spawn", "level", function(ply)
    local func = TableRound().PlayerSpawn
    if func then func() end
end)

hook.Add("PlayerSwitchWeapon", "level", function(ply, old, new)
    local func = TableRound().PlayerSwitchWeapon
    func = func and func(ply, old, new)
    if func ~= nil then return func end
end)

hook.Add("OnContextMenuOpen", "level", function()
    if not roundActive then return end
    local func = TableRound().OnContextMenuOpen
    if func then func() end
end)

hook.Add("OnContextMenuClose", "level", function()
    local func = TableRound().OnContextMenuClose
    if func then func() end
end)

hook.Add("CanUseSpectateHUD", "level", function()
    local func = TableRound().CanUseSpectateHUD
    if func then return func() end
end)

hook.Add("Think", "level", function()
    --print(TableRound())
    local func = TableRound().Think
    if func then func() end
end)

hook.Add("PlayerStartVoice", "level", function(ply)
    -- Проверяем, что ply валиден
    if not IsValid(ply) then return end

    -- Если игрок жив — разрешаем голос
    if ply:Alive() then
        return true
    end
end)
