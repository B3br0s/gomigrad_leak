-- "gamemodes\\homigradcom\\gamemode\\game\\levels\\riot\\init_tier_0_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
table.insert(LevelList,"riot")
riot = {}
riot.Name = "Riot"

riot.red = {"Полиция",Color(55,55,150),
	weapons = {"weapon_hands","weapon_police_bat","med_band_big","med_band_small","weapon_taser","weapon_handcuffs","weapon_radio"},
	main_weapon = {"weapon_pepperspray","medkit","painkiller","weapon_pepperspray","medkit","painkiller","weapon_beanbag"},
	secondary_weapon = {""},
	models = {"models/player/swat.mdl"}
}


riot.blue = {"Бунтующие",Color(75,45,45),
	weapons = {"weapon_hands","med_band_small"},
	main_weapon = {"weapon_hammer","med_band_big","med_band_small","weapon_hg_molotov","weapon_pepperspray","weapon_hammer","med_band_big","med_band_small","weapon_pepperspray"},
	secondary_weapon = {"weapon_hg_metalbat", "weapon_bat","weapon_pipe"},
	models = {"models/player/Group01/male_04.mdl","models/player/Group01/male_01.mdl","models/player/Group01/male_02.mdl","models/player/Group01/male_08.mdl"}
}

riot.teamEncoder = {
	[1] = "red",
	[2] = "blue"
}

function riot.StartRound()
	game.CleanUpMap(false)

	team.SetColor(1,riot.red[2])
	team.SetColor(2,riot.blue[2])

	if CLIENT then

		riot.StartRoundCL()
		return
	end

	riot.StartRoundSV()
end

riot.SupportCenter = true

riot.NoSelectRandom = true