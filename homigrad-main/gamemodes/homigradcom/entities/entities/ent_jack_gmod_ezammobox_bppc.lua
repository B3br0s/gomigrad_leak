-- "gamemodes\\homigradcom\\entities\\entities\\ent_jack_gmod_ezammobox_bppc.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal﻿-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezammobox"
ENT.PrintName = "EZ Black Powder Paper Cartridge"
ENT.Spawnable = true
ENT.Category = "JMod - EZ Special Ammo"
ENT.EZammo = "Black Powder Paper Cartridge"

---
if SERVER then
elseif CLIENT then
	--
	--language.Add(ENT.ClassName, ENT.PrintName)
end
