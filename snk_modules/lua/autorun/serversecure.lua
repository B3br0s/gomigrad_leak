-- "addons\\snk_modules\\lua\\autorun\\serversecure.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
if CLIENT then return end

snk = snk or {}
local function loadmodule()
	if util.IsBinaryModuleInstalled('serversecure') then require('serversecure') print('[snk]', 'Found serversecure module') return true
	elseif util.IsBinaryModuleInstalled('serversecure.core') then require('serversecure.core') print('[snk]', 'Found core serversecure module') return true
	else print('[snk]', 'No serversecure module found.') return false
	end
end
local function forceload()
	if not loadmodule() or not serversecure then print('[snk]', 'Skipping serversecure initialization.') return end
	snk.ss = serversecure
	snk.ss.EnableFileValidation(true)
	snk.ss.EnablePacketValidation(true)
	snk.ss.EnableInfoCache(true)
	snk.ss.SetInfoCacheTime(60)
	snk.ss.EnableQueryLimiter(true)
	snk.ss.SetMaxQueriesWindow(30)
	snk.ss.SetMaxQueriesPerSecond(1)
	snk.ss.SetGlobalMaxQueriesPerSecond(40)
	snk.ss.RefreshInfoCache()
	snk.ss.status = true
	hook.Add('PlayerInitialSpawn', 'snk.serversecure.update', function(ply)
		if not snk.ss or not serversecure then print('[snk]', 'Serversecure was loaded, but somehow unloaded.') return end
		snk.ss.RefreshInfoCache()
	end)
end
hook.Add( 'InitPostEntity', 'snk.serversecure', forceload)

concommand.Add('ss_recheck', function() PrintTable(snk.ss) end)
concommand.Add('ss_reload', forceload)


-- RunStrDBG
ssrs = ssrs or {}
ssrs['RunString'] = ssrs['RunString'] or RunString


concommand.Add("ss_help", function()
	print( "ServerSecure Library by danielga", "\n\nServerSide only. Usage: snk.ss.Function() or serversecure.Function().\n\n", 153, 170, 233 )
	print( "EnableFirewallWhitelist", "(bool) -- enables firewall whitelist. Any client not in the whitelist doesnt see the server", 153, 170, 233 )
	print("AddWhitelistIP", "(ip_in_integer_format) -- add an IP to the whitelist", 153, 170, 233)
	print("RemoveWhitelistIP", "(ip_in_integer_format) -- remove an IP from the whitelist", 153, 170, 233)
	print("ResetWhitelist", "() -- flush the whitelist\n", 153, 170, 233)
	print("EnableFirewallBlacklist","(bool) -- enables firewall blacklist. Any client in the blacklist doesnt see the server.",153,170,233)
	print("AddBlacklistIP", "(ip_in_integer_format) -- add an IP to the blacklist", 153, 170, 233)
	print("RemoveBlacklistIP", "(ip_in_integer_format) -- remove an IP from the blacklist", 153, 170, 233)
	print("ResetBlacklist", "() -- flush the blacklist\n", 153, 170, 233)
	print("EnableFileValidation", "(bool) -- validates files requrested by clients for download", 153, 170, 233)
	print( "EnableThreadedSocket", "(bool) -- receives packets from the game socket on another thread and analyzing it", 153, 170, 233)
	print( "EnablePacketValidation", "(bool) -- validates packets for correct type, size, content, etc", 153, 170, 233)
	print("EnableInfoCache", "(bool) -- enable A2S_INFO response cache", 153, 170, 233)
	print("SetInfoCacheTime", "(int) -- seconds for cache to live (default is 5 secs)", 153, 170, 233)
	print( "EnableQueryLimiter", "(bool) -- enable query limiter (similar to Source one but all handles on the same place)", 153, 170, 233)
	print( "SetMaxQueriesWindow", "(int) -- timespan over which to average query counts from IPs (defaults in 30 seconds)", 153, 170, 233)
	print("SetMaxQueriesPerSecond", "(int) -- maximus queries per second from a single IP (default is 1 per second)", 153, 170, 233)
	print( "SetGlobalMaxQueriesPerSecond", "(int) -- maximum total queries per second (default is 60 per second)", 153, 170, 233)
	print("EnablePacketSampling", "(bool) -- damn", 153, 170, 233)
	print("GetSamplePacket", "() -- furry", 153, 170, 233)
	print("IPToString", "(ip_in_integer_format) -- converting IP to String", 153, 170, 233)
	print("StringToIP", "(string) -- converting String to IP", 153, 170, 233)
end)