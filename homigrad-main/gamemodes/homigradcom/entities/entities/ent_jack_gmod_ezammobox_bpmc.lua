-- "gamemodes\\homigradcom\\entities\\entities\\ent_jack_gmod_ezammobox_bpmc.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal﻿-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezammobox"
ENT.PrintName = "EZ Black Powder Metallic Cartridge"
ENT.Spawnable = false -- disabled until econ 2
ENT.Category = "JMod - EZ Special Ammo"
ENT.EZammo = "Black Powder Metallic Cartridge"

---
if SERVER then
elseif CLIENT then
	--
	--language.Add(ENT.ClassName, ENT.PrintName)
end
