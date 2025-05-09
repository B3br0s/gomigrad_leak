-- "gamemodes\\homigradcom\\gamemode\\game\\levels\\event\\init_tier_0_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
--table.insert(LevelList,"event")
event = {}
event.Name = "event"

local red,green,blue = Color(105, 196, 59),Color(105, 196, 59),Color(105, 196, 59)

function event.GetTeamName(ply)
    local teamID = ply:Team()

    if not event.twoteams then
        if teamID == 1 then return "Зелёные",green end
    else
        if teamID == 1 then
            return "Красные",red
        elseif teamID == 2 then
            return "Синие",blue
        end
    end
end

function event.StartRound(data)
    team.SetColor(1,red)
    team.SetColor(2,blue)
    team.SetColor(1,green)

    game.CleanUpMap(false)

    if CLIENT then
        event.twoteams = data.twoteams

        return
    end

    return event.StartRoundSV()
end