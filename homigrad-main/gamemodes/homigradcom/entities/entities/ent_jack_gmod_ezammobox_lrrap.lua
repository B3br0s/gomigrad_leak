-- "gamemodes\\homigradcom\\entities\\entities\\ent_jack_gmod_ezammobox_lrrap.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal﻿-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezammobox"
ENT.PrintName = "EZ Light Rifle Round-Armor Piercing"
ENT.Spawnable = false -- soon(tm)
ENT.Category = "JMod - EZ Special Ammo"
ENT.EZammo = "Light Rifle Round-Armor Piercing"

---
if SERVER then
elseif CLIENT then
	--
	--language.Add(ENT.ClassName, ENT.PrintName)
end
