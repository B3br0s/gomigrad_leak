-- "gamemodes\\homigradcom\\gamemode\\game\\levels\\hunter\\init_tier_0_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
table.insert(LevelList, "hunter")

hunter = {}
hunter.Name = "hg.hideandseek.name"

hunter.red = {
	"#hg.hideandseek.team1", Color(255, 55, 55), weapons = {"weapon_radio", "weapon_kukri", "weapon_hands", "med_band_big", "med_band_small", "medkit", "painkiller"},
	main_weapon = {"weapon_m4super", "weapon_remington870", "weapon_xm1014"},
	secondary_weapon = {"weapon_p220", "weapon_mateba", "weapon_glock"},
	models = tdm.models
}

hunter.green = {
	"#hg.hideandseek.team2", Color(55, 255, 55), weapons = {"weapon_hands"},
	models = tdm.models
}

hunter.blue = {
	"#hg.modes.team.swat", Color(55, 55, 255), weapons = {"weapon_radio", "weapon_hands", "weapon_kabar", "med_band_big", "med_band_small", "medkit", "painkiller", "weapon_hg_f1", "weapon_handcuffs", "weapon_taser"},
	main_weapon = {"weapon_hk416", "weapon_m4a1", "weapon_m4super", "weapon_mp7", "weapon_xm1014", "weapon_sa80", "weapon_asval", "weapon_m249", "weapon_mp5", "weapon_p90"},
	secondary_weapon = {"weapon_beretta", "weapon_p99", "weapon_hk_usp"},
	models = {"models/player/urban.mdl"}
}

hunter.teamEncoder = {
	[1] = "red",
	[2] = "green",
	[3] = "blue"
}

function hunter.StartRound(data)
	game.CleanUpMap(false)

	team.SetColor(1, hunter.red[2])
	team.SetColor(2, hunter.green[2])
	team.SetColor(3, hunter.blue[2])

	if CLIENT then
		roundTimeLoot = data.roundTimeLoot

		return
	end

	return hunter.StartRoundSV()
end

hunter.SupportCenter = true
hunter.NoSelectRandom = true